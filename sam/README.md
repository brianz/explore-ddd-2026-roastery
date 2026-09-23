# sam/ — running and deploying your context

No build step. SAM Lambdas run the same Python 3.14 you write; `sam build`
packages, it doesn't transpile.

## Deploying

The shared bus is deployed once by your facilitator — you don't touch it. From
your own context's folder:

```bash
cd sam/<your-context>
sam build && sam deploy
```

`samconfig.toml` in each context folder pins the stack name, region, and shared
bus name — no flags needed on the command line. One deploy captain at a time per
team; CloudFormation can't take two concurrent updates to one stack.

**If the room is split into two independent groups** (two universes of five
teams each, on two separate buses — your facilitator will tell you if this
applies), deploy with the second profile instead:

```bash
sam build && sam deploy --config-env group2
```

This targets `roastery-bus-2` instead of `roastery-bus` and suffixes every
physical resource name with `-2` (stack, function, table), so it can coexist
in the same AWS account without colliding with group 1's stack. Everything
else about your context is identical either way — same template, same code,
just a different bus.

## The shared catalogs

`sam/skus.json`, `sam/green_lots.json`, and `sam/roastables.json` are real product,
green-lot, and roastable data — not sandbox filler. Read them with the CLI:

```bash
cd sam/cli
just install          # once, per machine
just list-skus
just list-green-lots
just list-roastables
```

If your Lambda needs to read one of these files directly, note that SAM's `CodeUri`
only packages files inside that context's own `src/` folder — a JSON file one level
up isn't included automatically. The usual fix is a symlink from `src/skus.json` (or
whichever file) to `../../skus.json`, not a copy. If you do this, use plain `sam
build` — `sam build --use-container` builds in a container that can't see the
symlink target.

## Testing your EventBridge wiring

Every starter template ships with one placeholder Lambda listening for a
`SayHelloEvent` on the shared bus. Before you've built anything real, you can
prove the wiring works:

```bash
just publish SayHelloEvent '{"msg": "hi"}'
just logs   # in a second terminal, leave it running
```

Because the placeholder event name is the same in every context's starter
template, this will make *every* team's placeholder Lambda log a line, not just
yours — that's expected, and only spans your own group's bus (group2 never
sees group 1's events, or vice versa). Once you design your own real events,
give them names only your team would plausibly publish.

`just logs` tails every event on the shared bus (`aws logs tail
/aws/events/roastery-bus --follow` under the hood) — the single most useful thing
to leave open in a second terminal while you work. If you're group2,
`BUS=roastery-bus-2 just logs` (and `BUS=roastery-bus-2 just publish ...`) point
every CLI command at your bus instead.

## What the CLI does not do

`sam/cli/roastery_admin.py` has no opinion on any context's event shapes or table
schema — there aren't any predefined ones. It only knows the shared catalogs and
how to publish an arbitrary event for testing. Everything else — what events exist,
what they carry, what each context remembers — is what your team and the others
decide.
