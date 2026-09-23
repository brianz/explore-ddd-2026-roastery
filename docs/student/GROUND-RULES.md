# Ground rules

One AWS account, one event bus, everyone in it at once. These are the few rules
that keep 30 people from stepping on each other.

## Where you work

| Team                    | Your folder                    |
| ----------------------- | ------------------------------ |
| Sales                   | `sam/sales/`                   |
| Inventory & Packaging   | `sam/inventory-and-packaging/` |
| Roastery                | `sam/roastery/`                |
| Green Coffee Purchasing | `sam/green-coffee-purchasing/` |
| Fulfillment             | `sam/fulfillment/`             |

Each folder has a `CLAUDE.md`. Point your AI assistant at it first.

## Your first fifteen minutes

1. Write your charter on an index card — what you're called, what you listen
   for, what you send — and post it on the board in your context's area.
2. Mark the board with dots: one color on the events you'll publish, another on
   the events you'll listen for. A dot with nobody on the other end is a
   conversation you owe somebody.
3. Go have that conversation. Your brief names who to talk to first. A question for
   another team goes on a red sticky note in their part of the board.

## Rules of the room

- **Only edit your own folder.** Never import another team's code or read
  another team's tables. If you need to know something they know, ask them to
  publish it.
- **There is no predefined catalog of event shapes.** You and the other teams
  invent them. When you and another team agree on one, write it down in both
  teams' `CLAUDE.md` — that's your contract, not a schema file anywhere else.
- **Push straight to `main`. Pull before you push.** No pull requests.
- **One deploy captain per team.** CloudFormation can't take two updates to one
  stack at once. Everyone can build; one person at a time runs
  `sam build && sam deploy`.
- **The starter template's placeholder event (`SayHelloEvent`) is the same
  name in all five contexts on purpose.** Every team's starter Lambda is
  listening for it, so testing your own wiring (see "Checking your work"
  below) will make everyone else's placeholder Lambda log a line too — that's
  expected, not a bug. Once you design your own real events, give them names
  only your team would plausibly publish.
- **Five events are fixed, not yours to design: `OrderPlaced`,
  `RoastQueueBuildRequested`, `RoastQueueRunRequested`, `FulfillmentRunRequested`,
  `ResetRequested`.** Only the facilitator publishes these, at specific
  moments, from their own admin tooling — you don't run these yourself and
  there's no CLI for them in this repo. See
  [CONTROL-EVENTS.md](./CONTROL-EVENTS.md) for their exact payload so you can
  write an `EventBridgeRule` that matches them. If you need one fired for a
  reason not obvious from the room's flow, ask the facilitator.

## Working with your AI assistant

Tell it the boundary, not just the feature: _"Read `sam/<your-folder>/CLAUDE.md`.
Only edit files in that folder."_ Left alone, an assistant will happily merge
five contexts into one model, or reach into another team's data because it's
right there. Read what it writes.

## Checking your work

Plain AWS CLI — no admin tooling needed, no venv, nothing to install beyond
what's already in the container:

```bash
# every event on the bus — leave this running in a second terminal
aws logs tail /aws/events/roastery-bus --follow

# trigger every team's starter Lambda, to prove your own EventBridge rule fires
aws events put-events --entries '[{
  "Source": "manual-test",
  "DetailType": "SayHelloEvent",
  "Detail": "{}",
  "EventBusName": "roastery-bus"
}]'
```

## If you're stuck

Ask your teammates, then the team next to you, then a facilitator. The worst
thing you can do is go quiet: a context that isn't publishing looks exactly like
one that isn't coming.
