# You own: Sales

**Your folder:** `sam/sales/` · read [GROUND-RULES.md](./GROUND-RULES.md) first.

You are the front door. Every order in this system starts with something your
team publishes — nothing else has anything to react to until you do.

An "order" isn't one thing here. It arrives through five different channels,
and two of them aren't really customers asking you anything — they're other
systems telling you something that's already happened and can't be
renegotiated. A sixth kind of "order" isn't a sale at all: it's coffee moving
between two parts of the same company.

## Your responsibilities as a team

- Take orders from wherever they come from, and turn each one into a single,
  clean shape everyone downstream can understand.
- Decide how you'll track an order's status over its life. Nothing hands you
  this — you have to invent it.
- Recognize that some of your channels aren't yours to accept or reject —
  they've already happened by the time you hear about them.
- Decide what a cancellation actually means, and whose call it is to make one.

## Words you need

- **SKU** — one sellable product: a specific coffee in a specific bag size.
  Your orders are lists of SKUs and counts.
- **Channel** — where an order came from. There are five, and they don't
  behave alike: some are small and immediate, some arrive already paid for,
  and one isn't a sale at all.
- **Resting** — fresh-roasted coffee can't ship the moment it exists. That
  means "in stock" and "able to ship today" are sometimes different answers.
- **Roast day / demand cutoff** — the roastery doesn't roast per order; it
  gathers demand and roasts on a schedule. An order can arrive after that
  day's plan has already been decided.

## Events to think about

- Two of your five channels hand you an order that's already been paid for
  and accepted. Should your context treat those the same way it treats a
  walk-up order from your own website?
- When another team tells you they couldn't set aside enough coffee for an
  order, what should happen to it — is it dead, or just waiting?
- A customer wants to know when their order will ship. What would you need to
  know, that you don't currently know, to answer that honestly?
- If an order ships in two parts on two different days, does anything you
  publish reflect that — or does it look, from the outside, like the order
  either fully happened or didn't happen at all?

## Before you write any code

Write a one-line charter on an index card — what you're called, what you
listen for, what you send — and post it on the board in your context's area.
Then mark the board: one color of dot on the events you'll publish, another on
the events you'll listen for. Next, find the Inventory & Packaging team and
agree on who decides that an order that can't be filled today is cancelled
outright, versus still waiting for coffee that hasn't been made yet.
