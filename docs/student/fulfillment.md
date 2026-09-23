# You own: Fulfillment

**Your folder:** `sam/fulfillment/` · read [GROUND-RULES.md](./GROUND-RULES.md) first.

Pick, pack, ship. You are the last stop before a box leaves the building. By
the time an order reaches you, somebody has already bought the coffee, roasted
it, bagged it, and set those specific bags aside for this specific customer.

Your job is the physical act at the end: find the bags, box them, hand them to
a carrier, and tell everyone it left.

## Your responsibilities as a team

- Decide when a reservation is ready to become a shipment — and what "ready"
  actually depends on.
- Track a shipment through whatever states you think it needs (at least:
  something like packed, and something like shipped).
- Actually ship it, and announce that it happened.
- Handle the case where an order gets cancelled while you're still holding it.

## Words you need

- **SKU** — one sellable product: a specific coffee in a specific bag size. You
  ship SKUs and counts, never grams.
- **Reservation** — somebody else has already set specific bags aside for one
  order. That's your instruction sheet.
- **Resting** — fresh-roasted coffee needs time before it can ship. Different
  products rest for different lengths of time.
- **Post-roast blend** — a product made by combining two coffees that were
  roasted *separately*. Combining them does not make either one more rested.

## Events to think about

- Somebody else will tell you that coffee has been set aside for an order.
  Does that mean you should pack it immediately — or is there something you
  need to check first?
- Coffee that just came out of the roaster may not be allowed to ship yet.
  How would you find out whether it's actually OK to send?
- Once you ship an order, who else in the building might care that it's done?
  Think about what "this order is no longer outstanding" is useful for, and to
  whom.
- What should happen to a shipment that's sitting there, waiting to become
  shippable, when word comes through that the order behind it was cancelled?

## Before you write any code

Write a one-line charter on an index card — what you're called, what you
listen for, what you send — and post it on the board in your context's area.
Then mark the board: one color of dot on the events you'll publish, another on
the events you'll listen for. Next, find the Inventory & Packaging team and
agree on how you'll learn whether an order is actually allowed to ship yet.
That's the one conversation worth having before anyone opens an editor.
