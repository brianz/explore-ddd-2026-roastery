# Attendee quickstart

**Before you arrive — do this, not just read it:**

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and
   [VS Code](https://code.visualstudio.com/), plus VS Code's **Dev Containers**
   extension.
2. Clone this repo and open it in VS Code.
3. Run **Dev Containers: Reopen in Container** (Cmd/Ctrl+Shift+P → type it) and
   let it finish building. This pulls a base image and installs tools — it takes
   a few minutes on a fresh machine, and there's no way to pre-cache it the way a
   cloud IDE would, so doing this before the session means you're not spending
   workshop time on it.

No AWS account to bring — that's provided (see below). **Bring your own coding
assistant.** The Claude Code CLI and VS Code extension are preinstalled as a
convenience, but nothing here configures or authenticates one — sign in with
whatever assistant and account you already use (Claude Code, Cursor, Copilot,
Codex, or none at all).

## Get coding

1. **Download your `.env` file** from the link your facilitator gives you at the
   start of the session, and save it as `.env` directly in the root of this repo
   (same folder as `.devcontainer/`). It contains the shared AWS credential —
   everyone in the room uses the same one.
2. If you haven't already, **Dev Containers: Reopen in Container**. (If you built
   it before arriving per the prerequisites above, this reopens instantly; if the
   `.env` file wasn't there yet when you first built it, use **Dev Containers:
   Rebuild Container** instead so the values actually load.)
3. Confirm the credential landed: `aws sts get-caller-identity` in the integrated
   terminal.
4. Sign in to your own coding assistant, however it normally works.
5. You're ready. Your team's code lives in `sam/<your-context>/` — that folder plus
   the shared `sam/skus.json` and the bus name are the only things you touch.

## The commands you'll use

The shared catalogs are plain JSON files — read them directly, no tool needed:

```bash
cat sam/skus.json
cat sam/green_lots.json
cat sam/roastables.json
```

Watching the bus and testing your own EventBridge wiring is plain AWS CLI —
see "Checking your work" in
[`docs/student/GROUND-RULES.md`](./student/GROUND-RULES.md).

There is no seed data and no shared starting state to reset — every context begins
empty, and what (if anything) gets written to a table is up to the design your team
lands on. The facilitator injects a handful of fixed-shape events at specific
moments (new orders, roast-day and fulfillment triggers, a room-wide reset) from
their own admin tooling, not from anything in this repo — see
[`docs/student/CONTROL-EVENTS.md`](./student/CONTROL-EVENTS.md) for their exact
shape so you can write a rule that matches them.

To deploy your context after you change it (from `sam/<your-context>/`):

```bash
sam build && sam deploy
```

(Your context's `samconfig.toml` pins the stack name, region, bus, and non-interactive
flags — no flags needed on the command line.)

The full command reference is in `sam/README.md`.

## Good to know

- **Don't use `sam build --use-container`.** If you symlink one of the shared
  catalog files into your `src/` folder (SAM's `CodeUri` only packages files inside
  that folder, so a symlink is the usual trick to reuse them without copying), a
  containerized build can't see it. Plain `sam build` (the default here) can.
- **Everyone shares one AWS account and one event bus.** Deploy only your team's
  stack, and follow the naming convention in `sam/README.md` so your events land on
  the shared bus.

Container won't build, or `aws sts get-caller-identity` fails after adding `.env`?
Grab a TA — they're floating during the intro.
