# Control events

Everywhere else in this workshop, event shapes are yours to design — see
[GROUND-RULES.md](./GROUND-RULES.md). These five are the one exception.

They're injected by the facilitator, at specific moments in the session, from
the admin CLI — the same tool for every team, on the shared bus, with a shape
that never changes. Nothing here is a gap for you to negotiate. What *is*
still your decision, per event: **whether your context reacts to it at all,
and what your handler does when it does.** The worked example below ("Sales
definitely listens to `OrderPlaced`") is the obvious case, not a rule — work
out the rest with your team.

**These five names are reserved.** Don't reuse `OrderPlaced`,
`RoastQueueBuildRequested`, `RoastQueueRunRequested`, `FulfillmentRunRequested`,
or `ResetRequested` for an event you design yourselves — same for the starter
templates' placeholder `SayHelloEvent`.

## Reading these payloads

Every example below is the **full, real EventBridge event** — not just the
part your code cares about — captured from an actual run against the shared
bus. This is exactly the `event` object your Lambda handler receives, and
exactly what an `EventBridgeRule` `Pattern` matches against:

| Field | What it is |
|---|---|
| `version`, `id`, `account`, `region`, `resources` | EventBridge's own envelope. `id` is **EventBridge's** event id — not the same thing as `eventId` inside `detail` below, which is ours. Don't confuse the two. `account` will be the real 12-digit workshop account id, not the placeholder shown here. |
| `source` | Always `roastery.cli` for these five. |
| `detail-type` | The event name — this is almost always what you match a rule on. |
| `time` | When EventBridge received it (UTC, second precision). |
| `detail` | The payload our CLI actually built — `eventId` / `occurredAt` / `correlationId` plus whatever fields are specific to that event. |

**Envelope convention inside `detail`.** Every control event is its own root
— nothing caused it — so `correlationId` is set to that event's own
`eventId`, and there is no `causationId`. If your own events `follow()` one
of these (i.e., you're reacting to it and publishing something downstream),
carry its `correlationId` forward so the causal thread stays intact on the
projector's bus log.

**Matching one in your own `template.yaml`** looks exactly like your starter
template's placeholder rule, just with a different `detail-type`:

```yaml
Events:
  OnOrderPlaced:
    Type: EventBridgeRule
    Properties:
      EventBusName: !Ref BusName
      Pattern:
        source:
          - roastery.cli
        detail-type:
          - OrderPlaced
```

`source` is optional in the pattern (only `roastery.cli` publishes these
today), but including it is what stops your rule from ever accidentally
matching a same-named event from a different source later.

---

## `OrderPlaced`

**Fires when:** the facilitator runs a "customer walks in" moment — the
closest thing this workshop has to a front door.

```json
{
  "version": "0",
  "id": "bd03f5ed-298a-a2d8-efe3-f1c46a690a80",
  "detail-type": "OrderPlaced",
  "source": "roastery.cli",
  "account": "111111111111",
  "time": "2026-09-23T18:08:33Z",
  "region": "us-west-2",
  "resources": [],
  "detail": {
    "eventId": "53c9d78a-833e-4706-b8f9-19e66a5a525c",
    "occurredAt": "2026-09-23T18:08:32.539481+00:00",
    "correlationId": "53c9d78a-833e-4706-b8f9-19e66a5a525c",
    "orderId": "ord_f7096435",
    "channel": "DIRECT",
    "lines": [
      { "skuId": "sku_eth_guji_350g", "quantity": 5 },
      { "skuId": "sku_house_350g", "quantity": 2 }
    ]
  }
}
```

| `detail` field | Notes |
|---|---|
| `orderId` | Prefixed `ord_`. |
| `channel` | One of `DIRECT`, `SHOPIFY`, `AMAZON`, `WHOLESALE`, `CAFE` — the facilitator can send any of these live. See your team brief for what they mean; nothing here decides that for you. |
| `lines` | At least one `{ skuId, quantity }`. `skuId` is always a real value from the shared catalog (`sam/skus.json`) — it will never be garbage, but it may be *any* SKU in that file, in any combination, so don't assume a fixed set of "the" test SKUs. |

**Obvious case:** Sales is the one context that has to exist for this to mean
anything — it's your order to track. Whether Inventory & Packaging, Roastery,
or anyone else reacts is between you and them.

## `RoastQueueBuildRequested`

**Fires when:** the facilitator signals that it's time to look at
accumulated demand and decide what needs roasting. Nobody computes that
queue for you; this just marks the moment.

```json
{
  "version": "0",
  "id": "a817c6b3-8963-ba52-5b8e-415aff0fdd83",
  "detail-type": "RoastQueueBuildRequested",
  "source": "roastery.cli",
  "account": "111111111111",
  "time": "2026-09-23T18:08:39Z",
  "region": "us-west-2",
  "resources": [],
  "detail": {
    "eventId": "70ee2908-e23a-4868-bf34-d48f961b9626",
    "occurredAt": "2026-09-23T18:08:39.015023+00:00",
    "correlationId": "70ee2908-e23a-4868-bf34-d48f961b9626"
  }
}
```

No fields in `detail` beyond the envelope — there's nothing else to carry.
Whatever "the queue" is, and what it's built from, is a design conversation
between whoever tracks demand and whoever roasts.

## `RoastQueueRunRequested`

**Fires when:** the facilitator signals that production commits now —
whatever should get roasted, roast it.

```json
{
  "version": "0",
  "id": "7cccf261-8b5b-b359-a637-8e21df249503",
  "detail-type": "RoastQueueRunRequested",
  "source": "roastery.cli",
  "account": "111111111111",
  "time": "2026-09-23T18:08:40Z",
  "region": "us-west-2",
  "resources": [],
  "detail": {
    "eventId": "067ec019-aa82-4090-bd83-f859ee3bbd5c",
    "occurredAt": "2026-09-23T18:08:39.945632+00:00",
    "correlationId": "067ec019-aa82-4090-bd83-f859ee3bbd5c"
  }
}
```

Same `detail` shape as `RoastQueueBuildRequested` — envelope only. These are
two separate moments on purpose (build, then run) even though nothing here
forces time to pass between them; a real roast day has other work happening
in between.

## `FulfillmentRunRequested`

**Fires when:** the facilitator signals that a shipping batch runs now.
Fulfillment doesn't ship the instant a reservation lands (see your team
brief); it waits for this.

```json
{
  "version": "0",
  "id": "89839861-5053-8fbf-6392-410f19127684",
  "detail-type": "FulfillmentRunRequested",
  "source": "roastery.cli",
  "account": "111111111111",
  "time": "2026-09-23T18:08:41Z",
  "region": "us-west-2",
  "resources": [],
  "detail": {
    "eventId": "0e2617a3-7632-4abc-a776-7bd686a682ed",
    "occurredAt": "2026-09-23T18:08:40.871303+00:00",
    "correlationId": "0e2617a3-7632-4abc-a776-7bd686a682ed"
  }
}
```

Envelope only, same as the two roast-queue events above.

## `ResetRequested`

**Fires when:** the facilitator resets the room — announced out loud first,
since it affects everyone.

```json
{
  "version": "0",
  "id": "bb889d2c-4b78-b49a-594a-6eae40340df3",
  "detail-type": "ResetRequested",
  "source": "roastery.cli",
  "account": "111111111111",
  "time": "2026-09-23T18:08:42Z",
  "region": "us-west-2",
  "resources": [],
  "detail": {
    "eventId": "8a0df032-e3c5-4fb1-9939-7c343609a40e",
    "occurredAt": "2026-09-23T18:08:41.698112+00:00",
    "correlationId": "8a0df032-e3c5-4fb1-9939-7c343609a40e"
  }
}
```

**Nothing on the facilitator's side touches your DynamoDB table when this
fires — only this event gets published.** Every context is responsible for
clearing its *own* table(s) back to empty when it hears this. That's not a
convenience the facilitator provides; it's a handler your team has to build,
the same as any other event you react to. If your context never implements
it, a reset will do nothing to your data, which will make your team's state
drift from everyone else's the next time the room resets.
