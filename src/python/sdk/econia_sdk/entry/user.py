# User entry functions

from aptos_sdk.account_address import AccountAddress
from aptos_sdk.bcs import Serializer, encoder
from aptos_sdk.transactions import EntryFunction, ModuleId
from aptos_sdk.type_tag import TypeTag


def get_module_id(econia_address: AccountAddress) -> ModuleId:
    return ModuleId.from_str("{}::user".format(econia_address))


def deposit_from_coinstore(
    econia_address: AccountAddress,
    coin: TypeTag,
    market_id: int,
    custodian_id: int,
    amount: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [deposit_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_deposit_from_coinstore)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `coin`: Aptos TypeTag for deposit coin.
    * `market_id`: Market ID for corresponding market.
    * `custodian_id`: ID of market custodian.
    * `amount`: Amount of coin to deposit.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "deposit_from_coinstore",
        [coin],
        [
            encoder(market_id, Serializer.u64),
            encoder(custodian_id, Serializer.u64),
            encoder(amount, Serializer.u64),
        ],
    )


def register_market_account(
    econia_address: AccountAddress,
    base: TypeTag,
    quote: TypeTag,
    market_id: int,
    custodian_id: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [register_market_account](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_register_market_account)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `base`: Aptos TypeTag for base coin.
    * `quote`: Aptos TypeTag for quote coin.
    * `market_id`: Market ID for corresponding market.
    * `custodian_id`: ID of market custodian.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "register_market_account",
        [base, quote],
        [
            encoder(market_id, Serializer.u64),
            encoder(custodian_id, Serializer.u64),
        ],
    )


def register_market_account_generic_base(
    econia_address: AccountAddress,
    quote: TypeTag,
    market_id: int,
    custodian_id: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [register_market_account_generic_base](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_register_market_account_generic_base)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `quote`: Aptos TypeTag for quote coin.
    * `market_id`: Market ID for corresponding market.
    * `custodian_id`: ID of market custodian.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "register_market_account_generic_base",
        [quote],
        [
            encoder(market_id, Serializer.u64),
            encoder(custodian_id, Serializer.u64),
        ],
    )


def withdraw_to_coinstore(
    econia_address: AccountAddress,
    coin: TypeTag,
    market_id: int,
    amount: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [withdraw_to_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_withdraw_to_coinstore)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `coin`: Aptos TypeTag for withdrawal coin.
    * `market_id`: Market ID for corresponding market.
    * `amount`: Amount of coin to withdraw.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "withdraw_to_coinstore",
        [coin],
        [encoder(market_id, Serializer.u64), encoder(amount, Serializer.u64)],
    )
