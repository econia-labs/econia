# Incentives entry functions

from typing import List

from aptos_sdk.account_address import AccountAddress
from aptos_sdk.bcs import Serializer, encoder
from aptos_sdk.transactions import EntryFunction, ModuleId
from aptos_sdk.type_tag import TypeTag


def get_module_id(econia_address: AccountAddress) -> ModuleId:
    return ModuleId.from_str("{}::incentives".format(econia_address))


def update_incentives(
    econia_address: AccountAddress,
    utility_coin: TypeTag,
    market_registration_fee: int,
    underwriter_registration_fee: int,
    custodian_registration_fee: int,
    taker_fee_divisor: int,
    integrator_fee_store_tiers: List[List[int]],
) -> EntryFunction:
    """
    Create the `EntryFunction` for [update_incentives](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_update_incentives)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `utility_coin`: TypeTag of the utility coin to use.
    * `market_registration_fee`: Market registration fee to set.
    * `underwriter_registration_fee`: Underwriter registration fee
      to set.
    * `custodian_registration_fee`: Custodian registration fee to
      set.
    * `taker_fee_divisor`: Taker fee divisor to set.
    * `integrator_fee_store_tiers_ref`: Immutable reference to
      0-indexed vector of 3-element vectors, with each 3-element
      vector containing fields for a corresponding
      `IntegratorFeeStoreTierParameters`.
    """
    serializer = Serializer()
    seq_ser = Serializer.sequence_serializer(Serializer.u64)  # type: ignore
    seq_ser(serializer, integrator_fee_store_tiers)
    integrator_fee_store_tiers_bytes = serializer.output()

    return EntryFunction(
        get_module_id(econia_address),
        "update_incentives",
        [utility_coin],
        [
            encoder(market_registration_fee, Serializer.u64),
            encoder(underwriter_registration_fee, Serializer.u64),
            encoder(custodian_registration_fee, Serializer.u64),
            encoder(taker_fee_divisor, Serializer.u64),
            integrator_fee_store_tiers_bytes,
        ],
    )


def upgrade_integrator_fee_store_via_coinstore(
    econia_address: AccountAddress,
    quote_coin: TypeTag,
    utility_coin: TypeTag,
    market_id: int,
    new_tier: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [upgrade_integrator_fee_store_via_coinstore](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_upgrade_integrator_fee_store_via_coinstore)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `quote_coin`: TypeTag of the quote coin to use.
    * `utility_coin`: TypeTag of the utility coin to use.
    * `market_id`: Market ID for corresponding market.
    * `new_tier`: Tier to upgrade to.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "upgrade_integrator_fee_store_via_coinstore",
        [quote_coin, utility_coin],
        [
            encoder(market_id, Serializer.u64),
            encoder(new_tier, Serializer.u8),
        ],
    )


def withdraw_integrator_fees_via_coinstores(
    econia_address: AccountAddress,
    quote_coin: TypeTag,
    utility_coin: TypeTag,
    market_id: int,
) -> EntryFunction:
    """
    Create the `EntryFunction` for [withdraw_integrator_fees_via_coinstores](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_withdraw_integrator_fees_via_coinstores)

    Arguments:
    * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
    * `quote_coin`: TypeTag of the quote coin to use.
    * `utility_coin`: TypeTag of the utility coin to use.
    * `market_id`: Market ID for corresponding market.
    """
    return EntryFunction(
        get_module_id(econia_address),
        "withdraw_integrator_fees_via_coinstores",
        [quote_coin, utility_coin],
        [
            encoder(market_id, Serializer.u64),
        ],
    )
