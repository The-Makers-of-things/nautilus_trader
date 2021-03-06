# NautilusTrader 1.109.0 Beta - Release Notes

The main thrust of this release is to refine and further bed down the changes
to the identifier model via `Security`, and fix some bugs.

Errors in the CCXT clients caused by the last release have been addressed.

## Breaking Changes
- `Security` now takes first class value object `Symbol`.
- `Security` `asset_class` and `asset_type` no longer optional.
- `SimulatedExchange.venue` changed to `SimulatedExchange.id`.

## Enhancements
- Ensure `TestTimer` advances monotonically increase.
- Add `AssetClass.BETTING`.

## Fixes
- CCXT data and execution clients regarding `security` vs `symbol` naming.
- `Security` equality and hashing.
- Various docstrings.

---

# NautilusTrader 1.108.0 Beta - Release Notes

This release executes a major refactoring of `Symbol` and how securities are
generally identified within the platform. This will allow a smoother integration
with Interactive Brokers and other exchanges, brokerages and trading
counterparties.

Previously the `Symbol` identifier also included a venue which confused the concept.
The replacement `Security` identifier more clearly expresses the domain with a
symbol string, a primary `Venue`, `AssetClass` and `AssetType` properties.

## Breaking Changes
- All previous serializations.
- `Security` replaces `Symbol` with expanded properties.
- `AssetClass.EQUITY` changed to `AssetClass.STOCK`.
- `from_serializable_string` changed to `from_serializable_str`.
- `to_serializable_string` changed to `to_serializable_str`.

## Enhancements
- Reports now include full security name.
- Add `AssetType.WARRANT`.

## Fixes
- `StopLimitOrder` serialization.

---

# NautilusTrader 1.107.1 Beta - Release Notes

This is a patch release which applies various fixes and refactorings.

The behaviour of the `StopLimitOrder` continued to be fixed and refined.
`SimulatedExchange` was refactored further to reduce complexity.

## Breaking Changes
None

## Enhancements
None

## Fixes
- `TRIGGERED` states in order FSM.
- `StopLimitOrder` triggering behaviour.
- `OrderFactory.stop_limit` missing `post_only` and `hidden`.
- `Order` and `StopLimitOrder` `__repr__` string (duplicate id).

---

# NautilusTrader 1.107.0 Beta - Release Notes

The main thrust of this release is to refine some subtleties relating to order
matching and amendment behaviour for improved realism. This involved a fairly substantial refactoring
of `SimulatedExchange` to manage its complexity, and support extending the order types.

The `post_only` flag for LIMIT orders now results in the expected behaviour regarding
when a marketable limit order will become a liquidity `TAKER` during order placement
and amendment.

Test coverage was moderately increased.

## Breaking Changes
None

## Enhancements
- Refactored `SimulatedExchange` order matching and amendment logic.
- Add `risk` sub-package to group risk components.

## Fixes
- `StopLimitOrder` triggering behaviour.
- All flake8 warnings.

---

# NautilusTrader 1.106.0 Beta - Release Notes

The main thrust of this release is to introduce the Interactive Brokers
integration, and begin adding platform capabilities to support this effort.

## Breaking Changes
- `from_serializable_string` methods changed to `from_serializable_str`.

## Enhancements
- Scaffold Interactive Brokers integration in `adapters/ib`.
- Add the `Future` instrument type.
- Add the `StopLimitOrder` order type.
- Add the `Data` and `DataType` types to support custom data handling.
- Add the `Security` identifier types initial implementation to support extending the platforms capabilities.

## Fixes
- `BracketOrder` correctness.
- CCXT precision parsing bug.
- Some log formatting.

---
