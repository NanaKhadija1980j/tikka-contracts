# Glossary: Amounts, Tokens and Units

Every monetary value handled by the Tikka contracts is an **integer amount in the
base units of one specific token**.  This document states, for every amount-like
field, which token the value is denominated in, so integrators never compare
two numbers that refer to different assets.

> **Rule of thumb (#1218):** `ticket_price` is always denominated in
> `payment_token`.  `prize_amount` is denominated in `prize_token`, which
> defaults to `payment_token` but may be a *different* asset.  The two values
> may only be compared numerically when both tokens are the same asset; a
> different asset can have a different asset type and a different number of
> decimals, so the raw base-unit numbers are not comparable.

## Token identifiers

| Term | Meaning |
|---|---|
| `payment_token` | The Stellar asset contract used to **buy tickets**.  Configured by the creator in `RaffleConfig.payment_token`. |
| `prize_token` | The Stellar asset contract used to **deposit and pay out the prize**.  Configured in `RaffleConfig.prize_token`; when `None` it defaults to `payment_token`.  Stored on the raffle as `Raffle.prize_token`. |
| `tikka_token` | Optional protocol token used for incentive / swap features.  It never denominates ticket prices or prizes. |
| `treasury_address` | Recipient of the protocol fees collected in `payment_token`. |

## Amounts in `RaffleConfig` (creation parameters)

| Field | Unit / denomination | Notes |
|---|---|---|
| `ticket_price` | `payment_token` base units | Minimum `MIN_TICKET_PRICE` (10 000). |
| `prize_amount` | `prize_token` base units | Total prize pool.  Maximum `MAX_PRIZE_AMOUNT`.  Compared with `ticket_price` **only** when `prize_token == payment_token`. |
| `prizes` | basis points of `prize_amount` | Distribution vector; must sum to 10 000 (100 %). |
| `protocol_fee_bp` | basis points (dimensionless) | 100 = 1 %.  Applied to `payment_token` amounts at ticket purchase and to `prize_token` amounts at claim. |
| `early_bird_discount_bp` | basis points (dimensionless) | Discount applied to `ticket_price` (a `payment_token` amount). |
| `early_bird_ticket_percentage` | percent (dimensionless) | Share of `max_tickets` covered by the early-bird window. |
| `claim_lockup_seconds` | seconds (dimensionless) | Delay between finalization and the first claim. |
| `swap_deadline_seconds` | seconds (dimensionless) | Swap deadline window. |

## Amounts in `Raffle` (on-chain state)

| Field | Unit / denomination | Notes |
|---|---|---|
| `ticket_price` | `payment_token` base units | Base price of one ticket. |
| `prize_amount` | `prize_token` base units | Total prize pool funded by the creator. |
| `tickets_sold` | count | Number of tickets sold; also an input of the internal draw seed. |
| `prizes` | basis points of `prize_amount` | Per-tier allocation. |
| `protocol_fee_bp` | basis points (dimensionless) | Snapshot of the fee in force at creation time. |

## Amounts in events

| Event / field | Unit / denomination |
|---|---|
| `RaffleCreated.ticket_price` | `payment_token` base units |
| `RaffleCreated.prize_amount` | `prize_token` base units |
| `PrizeDeposited.amount` | `prize_token` base units |
| `PrizeRefunded.amount` | `prize_token` base units |
| `PrizeClaimed.gross_amount` | `prize_token` base units |
| `PrizeClaimed.net_amount` | `prize_token` base units (after fees) |
| `PrizeClaimed.platform_fee` | `prize_token` base units |
| `TicketPurchased.ticket_price` | `payment_token` base units |
| `TicketPurchased.effective_ticket_price` | `payment_token` base units (after any early-bird discount) |
| `TicketPurchased.total_paid` | `payment_token` base units |
| `TicketPurchased.protocol_fee` | `payment_token` base units |
| `TicketRefunded.amount` | `payment_token` base units |
| `FeesWithdrawn.amount` | `payment_token` base units |
| `EmergencyWithdrawn.amount` | `prize_token` base units |
| `TokensRescued.amount` | the token named by `TokensRescued.token` |

## Other units

| Term | Unit |
|---|---|
| `end_time`, `finalized_at`, `draw_timestamp`, `timestamp` | unix seconds |
| `max_tickets`, `max_tickets_per_tx`, `min_tickets`, `tickets_sold` | ticket count |
| `draw_sequence`, `request_ledger`, `fallback_ledger` | ledger sequence number |
| `seed` | 64-bit draw seed derived from the randomness pre-image |
