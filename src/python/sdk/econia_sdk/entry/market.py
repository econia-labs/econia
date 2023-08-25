# Market entry functions

from aptos_sdk.account_address import AccountAddress
from aptos_sdk.bcs import Serializer, encoder
from aptos_sdk.transactions import EntryFunction, ModuleId
from aptos_sdk.type_tag import TypeTag

from econia_sdk.types import AdvanceStyle, Restriction, SelfMatchBehavior, Side


def get_module_id(econia_address: AccountAddress) -> ModuleId:
    return ModuleId.from_str("{}::market".format(econia_address))


def cancel_all_orders_user(
    econia_address: AccountAddress, market_id: int, side: Side
) -> EntryFunction:
    """
    Create the `EntryFunction` for [cancel_all_orders_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_cancel_all_orders_user)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `market_id`: Market ID for corresponding market.
    * `side`: Order [`Side`].
    """
    return EntryFunction(
        get_module_id(econia_address),
        "cancel_all_orders_user",
        [],
        [
            encoder(market_id, Serializer.u64),
            encoder(side, Serializer.u8),
        ],
    )


def cancel_order_user(
    econia_address: AccountAddress,
    market_id: int,
    side: Side,
    market_order_id: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [cancel_order_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_cancel_order_user)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `market_id`: Market ID for corresponding market.
    * `side`: Order [`Side`].
    * `market_order_id`: ID of the order to cancel.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "cancel_order_user",
        [],
        [
            encoder(market_id, Serializer.u64),
            encoder(side, Serializer.u8),
            encoder(market_order_id, Serializer.u128),
        ],
    )


def change_order_size_user(
    econia_address: AccountAddress,
    market_id: int,
    side: Side,
    market_order_id: int,
    new_size: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [change_order_size_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_change_order_size_user)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `market_id`: Market ID for corresponding market.
    * `side`: Order [`Side`].
    * `market_order_id`: ID of the order to cancel.
    * `new_size`: New size of the order.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "change_order_size_user",
        [],
        [
            encoder(market_id, Serializer.u64),
            encoder(side, Serializer.u8),
            encoder(market_order_id, Serializer.u128),
            encoder(new_size, Serializer.u64),
        ],
    )


def place_limit_order_passive_advance_user_entry(
    econia_address: AccountAddress,
    base: TypeTag,
    quote: TypeTag,
    market_id: int,
    integrator: AccountAddress,
    side: Side,
    size: int,
    advance_style: AdvanceStyle,
    target_advance_amount: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [place_limit_order_passive_advance_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_passive_advance_user_entry)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `base`: Aptos TypeTag for base coin.
    * `quote`: Aptos TypeTag for quote coin.
    * `market_id`: Market ID for corresponding market.
    * `integrator`: Integrator's AccountAddress.
    * `side`: Order [`Side`].
    * `size`: Size of the order in lots.
    * `advance_style`: The [`AdvanceStyle`] of the order.
    * `target_advance_amount`: Target advance amount.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "place_limit_order_passive_advance_user_entry",
        [base, quote],
        [
            encoder(market_id, Serializer.u64),
            encoder(integrator.address, Serializer.fixed_bytes),
            encoder(side, Serializer.u8),
            encoder(size, Serializer.u64),
            encoder(advance_style, Serializer.u8),
            encoder(target_advance_amount, Serializer.u64),
        ],
    )


def place_limit_order_user_entry(
    econia_address: AccountAddress,
    base: TypeTag,
    quote: TypeTag,
    market_id: int,
    integrator: AccountAddress,
    side: Side,
    size: int,
    price: int,
    restriction: Restriction,
    self_match_behavior: SelfMatchBehavior,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [place_limit_order_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_user_entry)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `base`: Aptos TypeTag for base coin.
    * `quote`: Aptos TypeTag for quote coin.
    * `market_id`: Market ID for corresponding market.
    * `integrator`: Integrator's [`AccountAddress`].
    * `side`: Order [`Side`].
    * `size`: Size of the order in lots.
    * `advance_style`: The [`AdvanceStyle`] of the order.
    * `target_advance_amount`: Target advance amount.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "place_limit_order_user_entry",
        [base, quote],
        [
            encoder(market_id, Serializer.u64),
            encoder(integrator.address, Serializer.fixed_bytes),
            encoder(side, Serializer.u8),
            encoder(size, Serializer.u64),
            encoder(price, Serializer.u64),
            encoder(restriction, Serializer.u8),
            encoder(self_match_behavior, Serializer.u8),
        ],
    )


def register_market_base_coin_from_coinstore(
    econia_address: AccountAddress,
    base: TypeTag,
    quote: TypeTag,
    utility_coin: TypeTag,
    lot_size: int,
    tick_size: int,
    min_size: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [register_market_base_coin_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `base`: Aptos TypeTag for base coin.
    * `quote`: Aptos TypeTag for quote coin.
    * `utility_coin`: Aptos TypeTag for utility coin.
    * `lot_size`: Lot size for this market.
    * `tick_size`: Tick size for this market.
    * `min_size`: Minimum order size for this market.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "register_market_base_coin_from_coinstore",
        [base, quote, utility_coin],
        [
            encoder(lot_size, Serializer.u64),
            encoder(tick_size, Serializer.u64),
            encoder(min_size, Serializer.u64),
        ],
    )


def swap_between_coinstores_entry(
    econia_address: AccountAddress,
    base: TypeTag,
    quote: TypeTag,
    market_id: int,
    integrator: AccountAddress,
    side: Side,
    min_base: int,
    max_base: int,
    min_quote: int,
    max_quote: int,
    limit_price: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [swap_between_coinstores_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_swap_between_coinstores_entry)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `base`: Aptos TypeTag for base coin.
    * `quote`: Aptos TypeTag for quote coin.
    * `utility_coin`: Aptos TypeTag for utility coin.
    * `lot_size`: Lot size for this market.
    * `tick_size`: Tick size for this market.
    * `min_size`: Minimum order size for this market.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "swap_between_coinstores_entry",
        [base, quote],
        [
            encoder(market_id, Serializer.u64),
            encoder(integrator.address, Serializer.fixed_bytes),
            encoder(side, Serializer.u8),
            encoder(min_base, Serializer.u64),
            encoder(max_base, Serializer.u64),
            encoder(min_quote, Serializer.u64),
            encoder(max_quote, Serializer.u64),
            encoder(limit_price, Serializer.u64),
        ],
    )


def place_market_order_user_entry(
    econia_address: AccountAddress,
    base: TypeTag,
    quote: TypeTag,
    market_id: int,
    integrator: AccountAddress,
    side: Side,
    size: int,
    self_match_behavior: SelfMatchBehavior,
) -> EntryFunction:
    return EntryFunction(
        get_module_id(econia_address),
        "place_market_order_user_entry",
        [base, quote],
        [
            encoder(market_id, Serializer.u64),
            encoder(integrator.address, Serializer.fixed_bytes),
            encoder(side, Serializer.u8),
            encoder(size, Serializer.u64),
            encoder(self_match_behavior, Serializer.u8),
        ],
    )
