# You own: Inventory & Packaging

**Your folder:** `sam/inventory-and-packaging/` · read [GROUND-RULES.md](./GROUND-RULES.md) first.

You are the boundary between "we're making it" and "we can sell it." Coffee
arrives from the roasting side as loose beans, by weight; your job is turning
that into bags with a product code and a count.

When a customer wants three bags of something, nobody asks whether beans have
been roasted yet — they ask you whether there are three bags.

## Your responsibilities as a team

- Decide whether an order can be filled, and say exactly what's missing when
  it can't.
- Keep track of how many bags of each product physically exist, and how many
  of those are already promised to someone.
- Turn roasted bulk coffee into sellable, bagged products — including
  products made by combining more than one roasted coffee.
- Decide what happens to a request you can't fill right now. Does the demand
  just disappear?

## Words you need

- **Green coffee / roasting / bulk** — you don't do any of this yourself, but
  you're handed the result: loose roasted coffee, by weight.
- **SKU** — one sellable product: a specific coffee in a specific bag size.
- **Packaging** — scooping bulk into bags. This is your job, and it's what
  turns work-in-progress into something sellable.
- **Threshold vs. par** — a threshold is an alarm ("we're getting low").
  A par is a target ("this is where the shelf should sit when things are
  healthy"). They sound similar and are not the same number.

## Events to think about

- When you can't fill an order, what exactly should you tell people is
  missing — just "no," or something more useful than that?
- Somebody roasted more coffee. Whose job is it to turn that into sellable
  bags, and how would you know it's actually ready to be bagged?
- Some of your products are made by combining two different roasted coffees.
  What has to be true about *both* of them before you can bag one?
- If a customer's order can't be filled today, could it be filled tomorrow
  once more coffee exists? Who needs to know that it's still waiting?

## Before you write any code

Write a one-line charter on an index card — what you're called, what you
listen for, what you send — and post it on the board in your context's area.
Then mark the board: one color of dot on the events you'll publish, another on
the events you'll listen for. Next, find the Roastery team and agree on who
decides it's time to make more of something — you noticing and asking, or them
watching and deciding on their own.
