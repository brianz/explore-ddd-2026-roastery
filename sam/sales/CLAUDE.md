# Context: Sales

You are working inside **one bounded context of five**. This file exists so you build
*this* context and not a helpful merger of all five. If a change you are about to make
would be easier if two contexts shared a model, that is the signal to stop, not to
proceed.

Team brief: [`docs/student/sales.md`](../../docs/student/sales.md). Read it first —
it has the responsibilities and open questions this file doesn't repeat.

## Where things stand

`template.yaml` and `src/app.py` in this folder are a **starter, not a partial
solution**: one Lambda, triggered by a placeholder `SayHelloEvent` rule, that prints
a hello-world line and whatever event it received. One placeholder DynamoDB table
(`HelloTable`, a single `id` HASH key) exists so you can see the wiring pattern —
it is not a schema to build on. Replace all of it once your team has decided what
this context actually needs to track and react to.

## Do not

- **Do not decide whether stock exists, or whether an order can be filled.** That's
  Inventory & Packaging's call. You record facts about an order's life; you don't
  second-guess another team's answer.
- **Do not import from another context's directory.** Not `sam/inventory-and-packaging/`,
  not any other `sam/<context>/`. If you need something another context knows, you
  need their event — go negotiate it with them, then write the agreed shape in both
  teams' `CLAUDE.md`.
- **Do not invent an event shape and treat it as settled** until the team on the
  other end has agreed to it. A shape only one of you knows about isn't a contract.
- **Do not assume delivery is exactly-once.** EventBridge delivers at-least-once —
  design for a redelivered event landing twice, don't assume it won't happen.
- **Do not have two people deploy this stack at once.** One deploy captain runs
  `sam build && sam deploy` from this folder at a time.
