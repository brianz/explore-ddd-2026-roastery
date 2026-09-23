#!/usr/bin/env bash
# ExploreDDD devcontainer setup — runs once when the local Dev Container is built
# (Docker Desktop + VS Code). Installs the tools the base image doesn't carry and
# creates the CLI virtualenv.
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

# --- Claude Code CLI: installed, not configured -----------------------------------
# The VS Code extension is installed by devcontainer.json; this adds `claude` in the
# integrated terminal too. Neither is wired to any backend or model here — bring
# your own coding assistant and your own login/API key. This CLI install is just a
# convenience if you'd like to use Claude Code specifically.
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
  for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_DEFAULT_REGION; do
    val="${!var:-}"
    if [ -n "$val" ]; then
      printf 'export %s=%q\n' "$var" "$val"
    fi
  done
  echo "$MARK_END"
} >> "$BASHRC"

echo "==> done. Run 'sam deploy' from your context's folder, and configure your own coding assistant."
