#!/usr/bin/env bash
# ExploreDDD devcontainer setup — runs once when the local Dev Container is built
# (Docker Desktop + VS Code). Installs the tools the base image doesn't carry,
# creates the CLI virtualenv, and stages Claude Code's Bedrock config so there is
# no login step.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "==> ExploreDDD devcontainer setup (root: $ROOT)"

# --- just: the command runner sam/cli/justfile is written for ---------------------
if ! command -v just >/dev/null 2>&1; then
  echo "==> installing just"
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
    | sudo bash -s -- --to /usr/local/bin
fi

# --- AWS SAM CLI: packages and deploys each context -------------------------------
# Native `sam build` (never --use-container) follows the shared-catalog symlinks;
# see sam/README.md. pipx keeps its deps off the workshop venv.
if ! command -v sam >/dev/null 2>&1; then
  echo "==> installing aws-sam-cli"
  pipx install aws-sam-cli
fi

# --- Claude Code CLI: the terminal interface --------------------------------------
# The VS Code extension is installed by devcontainer.json; this adds `claude` in the
# integrated terminal for attendees who prefer the CLI. Both read the same config.
if ! command -v claude >/dev/null 2>&1; then
  echo "==> installing Claude Code CLI"
  npm install -g @anthropic-ai/claude-code
fi

# --- CLI virtualenv: roastery_admin.py + boto3 ------------------------------------
# sam/cli/.venv is a separate volume (see devcontainer.json), not the bind mount, so
# it's created fresh by Docker and owned by root — claim it before writing. It also
# persists across container rebuilds, so --clear guarantees a clean venv even if a
# previous postCreate run died partway through.
echo "==> creating sam/cli virtualenv"
sudo chown -R "$(id -u):$(id -g)" "$ROOT/sam/cli/.venv"
python3 -m venv --clear "$ROOT/sam/cli/.venv"
"$ROOT/sam/cli/.venv/bin/pip" install --quiet --upgrade pip
"$ROOT/sam/cli/.venv/bin/pip" install --quiet -r "$ROOT/sam/cli/requirements.txt"

# --- Claude Code settings: Bedrock + low-friction permissions ---------------------
# No secrets are written here — AWS credentials come from whatever is already in the
# container's environment (devcontainer.json's remoteEnv, sourced from the vended
# credential your facilitator gave you) via the standard AWS credential chain. We
# only pin the models (if set) and pick permission defaults that keep the room
# moving. Verify the exact model ids against `aws bedrock list-inference-profiles`.
echo "==> writing ~/.claude/settings.json"
python3 - <<'PY'
import json, os, pathlib

env = {"CLAUDE_CODE_USE_BEDROCK": "1"}
if os.environ.get("ANTHROPIC_MODEL"):
    env["ANTHROPIC_MODEL"] = os.environ["ANTHROPIC_MODEL"]
# ANTHROPIC_DEFAULT_HAIKU_MODEL replaced the deprecated ANTHROPIC_SMALL_FAST_MODEL.
if os.environ.get("ANTHROPIC_DEFAULT_HAIKU_MODEL"):
    env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = os.environ["ANTHROPIC_DEFAULT_HAIKU_MODEL"]

settings = {
    "env": env,
    "permissions": {
        # acceptEdits: file edits apply without a prompt; listed Bash commands run
        # without a prompt. Everything else still asks. For a truly promptless room
        # you can change this to "bypassPermissions" — acceptable only because this
        # is a throwaway account, and the container itself is disposable.
        "defaultMode": "acceptEdits",
        "allow": [
            "Bash(sam:*)",
            "Bash(aws:*)",
            "Bash(just:*)",
            "Bash(python3:*)",
            "Bash(pip:*)",
            "Bash(git:*)",
        ],
    },
}

d = pathlib.Path.home() / ".claude"
d.mkdir(exist_ok=True)
(d / "settings.json").write_text(json.dumps(settings, indent=2) + "\n")
print("wrote", d / "settings.json")
if "ANTHROPIC_MODEL" not in env:
    print("WARNING: ANTHROPIC_MODEL not set — Claude Code will use its Bedrock "
          "default, which may be an expensive model. Set it in the .env file.")
PY

# --- Lock the model: managed settings, not just a default -------------------------
# ~/.claude/settings.json above only sets an *initial* selection — any attendee can
# still `/model` switch, or export their own ANTHROPIC_MODEL, straight past it.
# availableModels in managed-settings.json is the actual enforcement point: Claude
# Code applies it as-is (no merging with anything a user sets) to /model, --model,
# ANTHROPIC_MODEL, and the ANTHROPIC_DEFAULT_*_MODEL aliases alike. See
# code.claude.com/docs/en/model-config#restrict-model-selection. Both ANTHROPIC_MODEL
# (Sonnet) and ANTHROPIC_DEFAULT_HAIKU_MODEL stay allowed — restricting to Sonnet
# alone also blocks Claude Code's own background-task use of Haiku, which would push
# that load onto Sonnet instead, worsening the Bedrock throttling risk a ~30-person
# room puts on one shared account.
if [ -n "${ANTHROPIC_MODEL:-}" ]; then
  echo "==> writing /etc/claude-code/managed-settings.json (model lock)"
  sudo mkdir -p /etc/claude-code
  python3 - <<'PY' | sudo tee /etc/claude-code/managed-settings.json >/dev/null
import json, os

allowed = [os.environ["ANTHROPIC_MODEL"]]
haiku = os.environ.get("ANTHROPIC_DEFAULT_HAIKU_MODEL")
if haiku and haiku not in allowed:
    allowed.append(haiku)

print(json.dumps({
    "model": os.environ["ANTHROPIC_MODEL"],
    "availableModels": allowed,
    "enforceAvailableModels": True,
}, indent=2))
PY
  echo "wrote /etc/claude-code/managed-settings.json"
else
  echo "WARNING: ANTHROPIC_MODEL not set — skipping the model lock" \
       "(/etc/claude-code/managed-settings.json). Attendees could /model switch freely."
fi

# --- Persist env into ~/.bashrc ---------------------------------------------------
# devcontainer.json's remoteEnv already puts these into every VS Code-launched
# terminal, but a plain `docker exec -it <container> bash` (or any shell VS Code
# didn't spawn) won't see them. ~/.bashrc lives in the container's home directory,
# not the bind-mounted repo, so this never touches the host filesystem or git —
# it's gone the moment the container is removed. Idempotent: reruns replace the
# block instead of duplicating it.
echo "==> writing env into ~/.bashrc"
BASHRC="$HOME/.bashrc"
MARK_START="# --- ExploreDDD workshop env (written by postCreate.sh; not committed) ---"
MARK_END="# --- end ExploreDDD workshop env ---"
touch "$BASHRC"
if grep -qF "$MARK_START" "$BASHRC"; then
  sed -i "/$MARK_START/,/$MARK_END/d" "$BASHRC"
fi
{
  echo "$MARK_START"
  for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_DEFAULT_REGION \
             ANTHROPIC_MODEL ANTHROPIC_DEFAULT_HAIKU_MODEL CLAUDE_CODE_USE_BEDROCK; do
    val="${!var:-}"
    if [ -n "$val" ]; then
      printf 'export %s=%q\n' "$var" "$val"
    fi
  done
  echo "$MARK_END"
} >> "$BASHRC"

echo "==> done. Run 'claude' or open the Claude Code panel — you are on Bedrock."
