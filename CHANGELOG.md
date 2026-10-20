# Changelog

All notable changes to this project are documented here.  
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
Versioning: [Semantic Versioning](https://semver.org/)

## [Unreleased]

### Added
- Contributor docs: `docs/DEPLOYMENT.md`, `docs/STORAGE.md`, `docs/RANDOMNESS.md`, and `docs/FAQ.md`.
- Architecture documentation with factory -> instance -> oracle flow and state-machine diagrams (`docs/ARCHITECTURE.md`).
- Comprehensive rustdoc comments for all public `raffle-shared` enums, structs, fields, constants, and functions.
- Pull request template requiring changelog updates for non-trivial changes.
- `docs/GLOSSARY.md`: reference for every monetary/config field, stating which token each amount is denominated in.
- `scripts/smoke-test.sh`: smoke test for a deployed raffle instance, including the new `finalize_raffle` caller argument.
- `RaffleConfig.prize_token`: optional prize asset for raffles whose prize is paid in a token other than the ticket payment token (#1218).

### Changed
- README documentation section now links to architecture docs.
- **Breaking (contract ABI):** `finalize_raffle` now takes an explicit `caller: Address` argument. The caller must authorise the call and is reported as the `caller` of the `DrawTriggered` event; finalization itself is permissionless once the raffle has ended or sold out (#1253).
- The internal draw seed now mixes the raffle id and `tickets_sold` into the pre-image in addition to the ledger timestamp and sequence (#1201).
- Factory pause flags (`Paused`) are stored in persistent storage, matching every other factory key (#1219).

### Fixed
- `init` no longer compares `prize_amount` (denominated in `prize_token`) against `ticket_price` (denominated in `payment_token`) when the two tokens differ; each amount is validated independently instead (#1218).
- `DrawTriggered.caller` reports the address that actually triggered the draw instead of always reporting the creator (#1253).

### Documented
- Standardized event emission model and event catalog (`docs/EVENTS.md`).
- Lifecycle/admin event coverage and event publishing patterns from the previous implementation summary.
- Admin key migration was recorded as a historical note (source file existed but contained no additional details).
- Internal draw seed construction is documented accurately: a SHA-256 pre-image of `timestamp + sequence + raffle_id + tickets_sold`, with no `env.prng()` involved (#1201).

## [0.2.0] - 2025-01-01

### Added
- Commit-reveal randomness source.
- Max tickets per transaction cap.
- Claim lockup delay configuration.
- Drawing/finalization guard state.

### Fixed
- Admin zero-address validation in `set_admin`.
- Duplicate winner selection in oracle finalization path.
