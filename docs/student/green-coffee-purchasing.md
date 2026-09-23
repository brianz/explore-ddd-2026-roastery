# You own: Green Coffee Purchasing

**Your folder:** `sam/green-coffee-purchasing/` · read [GROUND-RULES.md](./GROUND-RULES.md) first.

You are the front of the chain. Nothing exists until you buy it, and when
your supply runs out, everything downstream eventually stops.

Your clock runs differently from everyone else's in the room. Every other
team can react within the hour. You can't — green coffee takes weeks to
arrive once it's ordered, which means by the time a shortage is visible to
anyone, it's already too late for you to fix it today. You're buying against
a forecast, not against a shortage.

## Your responsibilities as a team

- Keep track of exactly which lots of green coffee you have — not just how
  much, but which specific batch, from where, from which harvest.
- Notice when a specific lot is running low, and decide what to do about it.
- Buy more, on a timescale that's realistic for how long green coffee
  actually takes to arrive.
- Avoid ordering more of something that's already on its way.

## Words you need

- **Lot** — one specific purchase of coffee, from one place, at one time. Not
  a type of coffee — a particular batch that exists, gets used up, and is
  then gone for good. Buying "more Colombia" later gets you a *different*
  lot, not a refill.
- **Origin / harvest year / moisture** — the facts that make one lot different
  from another, even when they're nominally "the same" coffee.
- **Purchase order** — your commitment to buy something that doesn't exist in
  your warehouse yet. (Note: Sales also has "orders" — completely different
  thing, different direction, different lifecycle.)
- **Committed vs. on hand vs. in transit** — "how much do I have" has more
  than one honest answer, depending on what you're trying to decide.

## Events to think about

- Coffee gets used up the moment a batch is *scheduled*, or the moment it's
  *actually roasted* — are those the same instant here, and does the
  difference matter to what you track?
- A batch gets ruined and the green coffee inside is destroyed. Does anyone
  need to know that happened, and would knowing change what you'd do
  differently?
- Your decisions take weeks to land. Is the same signal that's useful to you
  also useful to a team whose decisions take minutes — or does it need to
  mean something different to each of you?
- Somebody wants to know, right now, how much green coffee is on hand,
  without asking you directly. What would you have to tell them, and how
  often?

## Before you write any code

Write a one-line charter on an index card — what you're called, what you
listen for, what you send — and post it on the board in your context's area.
Then mark the board: one color of dot on the events you'll publish, another on
the events you'll listen for. You'll notice you have the fewest events of any
team — that's not because your job is small, it's because most of your real
work is figuring out what other teams need from you, not writing handlers.
Find the Roastery team and agree on how you'll learn what's already been
promised to a scheduled batch, before it's actually been consumed.
