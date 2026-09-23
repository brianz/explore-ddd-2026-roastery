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
green-lot, and roastable data — not sandbox filler. They're plain JSON; read them
directly (`cat sam/skus.json`, or open them in your editor).

If your Lambda needs to read one of these files directly, note that SAM's `CodeUri`
only packages files inside that context's own `src/` folder — a JSON file one level
up isn't included automatically. The usual fix is a symlink from `src/skus.json` (or
whichever file) to `../../skus.json`, not a copy. If you do this, use plain `sam
build` — `sam build --use-container` builds in a container that can't see the
symlink target.

## Testing your EventBridge wiring

Every starter template ships with one placeholder Lambda listening for a
`SayHelloEvent` on the shared bus. Before you've built anything real, you can
prove the wiring works with plain AWS CLI — no admin tooling needed:

```bash
aws events put-events --entries '[{
  "Source": "manual-test",
  "DetailType": "SayHelloEvent",
  "Detail": "{}",
  "EventBusName": "roastery-bus"
}]'

aws logs tail /aws/events/roastery-bus --follow   # in a second terminal, leave it running
```

Because the placeholder event name is the same in every context's starter
template, this will make *every* team's placeholder Lambda log a line, not just
yours — that's expected, and only spans your own group's bus (group2 never
sees group 1's events, or vice versa). Once you design your own real events,
give them names only your team would plausibly publish. If you're group2,
point both commands at `roastery-bus-2` instead.

## What's yours to design

There is no predefined event catalog and no predefined table schema anywhere in
this repo. What events exist, what they carry, and what each context remembers is
entirely what your team and the others decide — see `docs/student/GROUND-RULES.md`.

## The exception: facilitator control events

Five events — `OrderPlaced`, `RoastQueueBuildRequested`, `RoastQueueRunRequested`,
`FulfillmentRunRequested`, `ResetRequested` — fire at specific moments in the
session, published only by the facilitator. The one thing in this workshop
that isn't up to your team to design is their shape. The full, real
EventBridge payload for each one (so you can write an `EventBridgeRule` that
matches it), when each one fires, and what's expected of `ResetRequested`
(every context clears its own table — nothing does that for you) are in
[`docs/student/CONTROL-EVENTS.md`](../docs/student/CONTROL-EVENTS.md).
