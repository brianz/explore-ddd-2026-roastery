# Context: Inventory & Packaging

You are working inside **one bounded context of five**. This file exists so you build
*this* context and not a helpful merger of all five. If a change you are about to make
would be easier if two contexts shared a model, that is the signal to stop, not to
proceed.

Team brief: [`docs/student/inventory-and-packaging.md`](../../docs/student/inventory-and-packaging.md).
Read it first — it has the responsibilities and open questions this file doesn't repeat.

## Where things stand

`template.yaml` and `src/app.py` in this folder are a **starter, not a partial
solution**: one Lambda, triggered by a placeholder `SayHelloEvent` rule, that prints
a hello-world line and whatever event it received. One placeholder DynamoDB table
(`HelloTable`, a single `id` HASH key) exists so you can see the wiring pattern —
it is not a schema to build on. Replace all of it once your team has decided what
this context actually needs to track and react to.

## Do not

- **Do not model quantity loosely.** Whatever unit the Roastery hands you (weight,
  in grams) is not the unit you sell in (bags, whole units). Crossing that boundary
  without a deliberate conversion is the single most likely bug in this workshop.
- **Do not import from another context's directory.** Not `sam/roastery/`, not any
  other `sam/<context>/`. If you need something another context knows, you need
  their event — go negotiate it with them, then write the agreed shape in both
  teams' `CLAUDE.md`.
- **Do not invent an event shape and treat it as settled** until the team on the
  other end has agreed to it. A shape only one of you knows about isn't a contract.
- **Do not assume delivery is exactly-once.** EventBridge delivers at-least-once —
  a redelivered event that double-reserves stock is a real failure mode to design
  against, not a hypothetical.
- **Do not have two people deploy this stack at once.** One deploy captain runs
  `sam build && sam deploy` from this folder at a time.
