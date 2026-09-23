# explore-ddd-2026-roastery — workshop attendee repo

This is a hands-on DDD workshop. Five teams each own one bounded context of a
coffee roastery (`sam/sales/`, `sam/inventory-and-packaging/`, `sam/roastery/`,
`sam/green-coffee-purchasing/`, `sam/fulfillment/`), deployed independently on
AWS SAM, integrating only through events on one shared EventBridge bus.

**Nothing here is a finished implementation.** Every context folder starts as a
walking-skeleton stub: a template that deploys a Lambda triggered by a placeholder
EventBridge event and prints "hello world," plus a placeholder DynamoDB table with
a bare single-attribute key. There is no predefined catalog of event shapes and no
predefined table schema — deciding those, with the teams on the other end of each
event, is the exercise.

## If you're an AI assistant working in this repo

**Read the `CLAUDE.md` in whichever `sam/<context>/` folder you're editing before
you touch anything.** It has that context's specific boundary rules. This file is
the shared orientation; that one is the one that matters once you're inside a team's
folder.

The single most important rule, repeated in every context's `CLAUDE.md`: **only
edit files inside the one context folder you've been asked to work on.** Do not
import another context's code, read another context's DynamoDB table, or design a
model that spans two contexts because it would be "more consistent." If a change
would be easier by reaching into another folder, that's the signal to stop and
suggest the human ask that other team for an event instead — not a green light to
merge the boundary away. Left alone, that instinct is the most common way a
5-team workshop quietly becomes a 1-team monolith by the debrief.

## Layout

```
docs/student/GROUND-RULES.md   # the shared rules of the room — read this first
docs/student/<context>.md      # what your team owns, open questions, who to talk to
docs/ATTENDEE-QUICKSTART.md    # environment setup

sam/skus.json                  # the real SKU catalog — shared, read-only reference data
sam/green_lots.json            # the real green-lot catalog
sam/roastables.json            # the real roastable catalog

sam/<context>/template.yaml    # your stack: starts as a hello-world placeholder
sam/<context>/src/app.py       # your Lambda handler: starts as a hello-world placeholder
sam/<context>/CLAUDE.md        # that context's specific boundary rules — read this
sam/<context>/samconfig.toml   # deploy config, already pinned — no flags needed

sam/cli/                       # shared admin tooling: catalogs, and a generic
                                #   `publish` command for testing your EventBridge
                                #   wiring. It has no opinion on your event shapes.
```

## Working conventions

- **Design your events with the team on the other end, then write the agreed shape
  down in both teams' `CLAUDE.md`.** There is no central schema file — that
  conversation *is* the exercise.
- **EventBridge delivers at-least-once.** Design for a redelivered event, don't
  assume it can't happen.
- **One deploy captain per context.** CloudFormation can't take two concurrent
  updates to one stack.
