# Earmark

**Send money home, with strings attached — the good kind.**

## The Problem

Remittances are a $900B+ annual lifeline, but senders lose all control the moment funds land. Money meant for school fees, rent, or medicine gets redirected or burned through in a week instead of a month. This isn't a trust problem with family — it's a tooling problem. Senders care deeply about *how* their money is used, but every rail today offers the same all-or-nothing deal: send the lump sum and hope.

This is universal. A nurse in the UK supporting parents in Nigeria, a construction worker in the US sending to Mexico, a domestic worker in Singapore funding a sibling's tuition in the Philippines — same need, same gap, regardless of corridor.

## What Earmark Does

Earmark lets senders attach conditions to remittances before funds are released:

- **Conditional release** — Funds unlock only when a verifiable condition is met: a school confirms enrollment, a registered clinic issues an invoice, a utility account is credited.
- **Streaming** — Send daily or weekly drips instead of one lump sum, so a month's support actually lasts a month. Pause or redirect anytime.
- **Direct-to-purpose** — Route funds straight to a verified school, landlord, clinic, or merchant, bypassing the temptation of cash while still letting recipients keep a flexible spending portion.

All onchain, settled in stablecoins — fast, low-fee, and transparent to both sides.

## Why This Has to Be Onchain

Three things only smart contracts can do together:

1. **Programmable escrow without an intermediary** — Funds are held and released by code, not a company that can freeze, skim, or fold. Neither sender nor recipient has to trust Earmark with custody.
2. **Corridor-agnostic settlement** — Stablecoins don't care about borders or banking hours. The same contract works US→Mexico, UK→Nigeria, or Gulf→South Asia without partnering with a bank in every country. This is the key to *not* being one-country: traditional remittance startups die building corridor-by-corridor licensing and banking relationships; an onchain rail inherits global reach by default.
3. **Verifiable conditions** — Both parties (and any oracle/recipient institution) can independently confirm what condition was set and whether it was met. No "he said / she said," no opaque middleman.

## The Hard Part (and where the real product lives)

The honest challenge isn't the smart contract — escrow and streaming are well-trodden. It's the **last mile**:

- **Verification & oracles** — How does the contract *know* enrollment was confirmed or rent was paid? This needs verified institutional recipients, lightweight attestation from schools/clinics/landlords, and fallback dispute paths. This is the moat.
- **On/off-ramps per corridor** — Recipients ultimately need local currency for many expenses. The stablecoin layer is global, but cash-out still touches local rails (mobile money, bank, agent networks). Worth integrating ramp aggregators rather than building these.
- **Recipient UX** — Recipients are often less crypto-native than senders. The recipient experience should hide the chain entirely: they see "funds available for school fees," not a wallet address.
- **Dignity & consent** — "Strings attached" can feel paternalistic. The framing and product should make this collaborative (recipient opts in, sees the plan, keeps a discretionary portion) rather than surveillance-y. This is a real adoption risk worth designing around.

## Open Decisions Before Building

- **Broad launch vs. beachhead corridor** — The pitch should stay corridor-agnostic, but v1 execution almost certainly needs one corridor where the off-ramp, recipient institutions, and demand are strongest (a common starting point is US→Mexico or a Gulf→South Asia route given volume and existing stablecoin liquidity).
- **Which conditions ship first** — Streaming is the easiest to build and the most universally useful; conditional/direct-to-purpose release depends on having verified recipient institutions, so it may follow.
- **Custody & regulatory posture** — Non-custodial design dodges much of the money-transmitter burden, but on/off-ramp partners pull regulation back in. Worth scoping early.
- **How recipient consent is captured** — Determines whether the product reads as empowering or controlling, which directly affects adoption.
