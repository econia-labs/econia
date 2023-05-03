# Registry entry functions

from typing import List
from aptos_sdk.type_tag import TypeTag
from aptos_sdk.transactions import EntryFunction, ModuleId
from aptos_sdk.account_address import AccountAddress
from aptos_sdk.bcs import encoder, Serializer


def get_module_id(econia_address: AccountAddress) -> ModuleId:
    return ModuleId.from_str("{}::registry".format(econia_address))


"""
Create the `EntryFunction` for [register_integrator_fee_store_base_tier](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_base_tier)

Arguments:
* `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
* `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
* `utility_coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for utility coin.
* `market_id`: Market ID for corresponding market.
"""


def register_integrator_fee_store_base_tier(
    econia_address: AccountAddress,
    quote: TypeTag,
    utility_coin: TypeTag,
    market_id: int,
) -> EntryFunction:
    return EntryFunction(
        get_module_id(econia_address),
        "register_integrator_fee_store_base_tier",
        [quote, utility_coin],
        [encoder(market_id, Serializer.u64)],
    )


"""
Create the `EntryFunction` for [register_integrator_fee_store_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_from_coinstore)

Arguments:
* `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
* `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
* `utility_coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for utility coin.
* `market_id`: Market ID for corresponding market.
* `tier`: Fee tier.
"""


def register_integrator_fee_store_from_coinstore(
    econia_address: AccountAddress,
    quote: TypeTag,
    utility_coin: TypeTag,
    market_id: int,
    tier: int,
) -> EntryFunction:
    return EntryFunction(
        get_module_id(econia_address),
        "register_integrator_fee_store_from_coinstore",
        [quote, utility_coin],
        [encoder(market_id, Serializer.u64), encoder(tier, Serializer.u8)],
    )


"""
Create the `EntryFunction` for [remove_recognized_markets](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_remove_recognized_markets)

Arguments:
* `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
* `market_ids`: Vector of market IDs to remove.
"""


def remove_recognized_markets(
    econia_address: AccountAddress,
    market_ids: List[int],
) -> EntryFunction:
    serializer = Serializer()
    seq_ser = Serializer.sequence_serializer(Serializer.u64)  # type: ignore
    seq_ser(serializer, market_ids)
    market_id_bytes = serializer.output()

    return EntryFunction(
        get_module_id(econia_address),
        "remove_recognized_markets",
        [],
        [market_id_bytes],
    )


"""
Create the `EntryFunction` for [set_recognized_market](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_set_recognized_market)

Arguments:
* `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
* `market_id`: Market ID to recognize.
"""


def set_recognized_market(
    econia_address: AccountAddress,
    market_id: int,
) -> EntryFunction:
    return EntryFunction(
        get_module_id(econia_address),
        "set_recognized_market",
        [],
        [encoder(market_id, Serializer.u64)],
    )
