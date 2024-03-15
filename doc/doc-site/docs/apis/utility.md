# Utility functions

## Market order ID getters

- [`did_order_post()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-did_order_post)
- [`get_market_order_id_counter()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_market_order_id_counter)
- [`get_market_order_id_price()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_market_order_id_price)
- [`get_posted_order_id_side()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_posted_order_id_side)

## Market account ID getters

- [`user::get_custodian_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_custodian_id)
- [`get_market_account_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_account_id)
- [`get_market_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_id)

## Capability ID getters

- [`registry::get_custodian_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_custodian_id)
- [`get_underwriter_id()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_underwriter_id)

## Event handle lookup

- [`market::get_market_event_handle_creation_info()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_market_event_handle_creation_info)
- [`market::get_swapper_event_handle_creation_numbers()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_swapper_event_handle_creation_numbers)
- [`user::get_market_event_handle_creation_numbers()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_market_event_handle_creation_numbers)

## View function struct decoders

- [`market::get_order_view_fields()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_order_view_fields)
- [`market::get_orders_view_fields()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_orders_view_fields)
- [`market::get_price_level_fields()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_price_level_fields)
- [`market::get_price_levels_fields()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_price_levels_fields)

## Constant getters

### Market module

- [`get_ABORT()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_abort)
- [`get_ASK()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_ask)
- [`get_BID()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_bid)
- [`get_BUY()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_buy)
- [`get_CANCEL_BOTH()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_cancel_both)
- [`get_CANCEL_TAKER()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_cancel_taker)
- [`get_CANCEL_MAKER()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_cancel_maker)
- [`get_FILL_OR_ABORT()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_fill_or_abort)
- [`get_HI_PRICE()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_hi_price)
- [`get_IMMEDIATE_OR_CANCEL()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_immediate_or_cancel)
- [`get_MAX_POSSIBLE()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_max_possible)
- [`get_NO_CUSTODIAN()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_no_custodian)
- [`get_NO_RESTRICTION()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_no_restriction)
- [`get_NO_UNDERWRITER()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_no_underwriter)
- [`get_POST_OR_ABORT()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_post_or_abort)
- [`get_PERCENT()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_percent)
- [`get_SELL()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_sell)
- [`get_TICKS()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#function-get_ticks)

### Registry module

- [`get_MAX_CHARACTERS_GENERIC()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_max_characters_generic)
- [`get_MIN_CHARACTERS_GENERIC()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_min_characters_generic)
- [`get_NO_CUSTODIAN()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_no_custodian)
- [`get_NO_UNDERWRITER()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#function-get_no_underwriter)

### Resource account module

- [`get_address()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/resource_account.md#function-get_address)

### User module

- [`get_ASK()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_ask)
- [`get_BID()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_bid)
- [`get_CANCEL_REASON_EVICTION()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_EVICTION)
- [`get_CANCEL_REASON_IMMEDIATE_OR_CANCEL()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_IMMEDIATE_OR_CANCEL)
- [`get_CANCEL_REASON_MANUAL_CANCEL()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_MANUAL_CANCEL)
- [`get_CANCEL_REASON_MAX_QUOTE_TRADED()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_MAX_QUOTE_TRADED)
- [`get_CANCEL_REASON_NOT_ENOUGH_LIQUIDITY()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_NOT_ENOUGH_LIQUIDITY)
- [`get_CANCEL_REASON_SELF_MATCH_MAKER()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_SELF_MATCH_MAKER)
- [`get_CANCEL_REASON_SELF_MATCH_TAKER()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_CANCEL_REASON_SELF_MATCH_TAKER)
- [`get_NO_CUSTODIAN()`](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#function-get_no_custodian)
