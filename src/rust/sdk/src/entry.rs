//! The [`entry`](crate::entry) module exposes the entry functionalities of the Econia package.
//!
//! Here you can find helper functions to generate payloads for the
//! [`EconiaClient::submit_tx`](crate::EconiaClient::submit_tx).
//!
//! For every entry function that the Econia package exposes, there is a corresponding function
//! here.
use std::str::FromStr;

use aptos_api_types::MoveModuleId;
use aptos_sdk::bcs;
use aptos_sdk::move_types::account_address::AccountAddress;
use aptos_sdk::move_types::ident_str;
use aptos_sdk::move_types::language_storage::TypeTag;
use aptos_sdk::{move_types::language_storage::ModuleId, types::transaction::EntryFunction};
use econia_types::order::{AdvanceStyle, Restriction, SelfMatchBehavior, Side};

use crate::errors::EconiaError;
use crate::EconiaResult;

/// Create the `EntryFunction` for register_for_coin
///
/// Arguments:
/// * `amount`: the amount of times to retry the transaction.
pub fn register_for_coin(coin: &TypeTag) -> EconiaResult<EntryFunction> {
    let managed_coin = "0x1::managed_coin";
    let id = MoveModuleId::from_str(managed_coin)
        .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
    Ok(EntryFunction::new(
        ModuleId::from(id),
        ident_str!("register").to_owned(),
        vec![coin.clone()],
        vec![],
    ))
}

// Incentives entry functions

/// Create the `EntryFunction` for [update_incentives](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_update_incentives)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `utility_coin`: [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) of the utility coin to use.
/// * `market_registration_fee`: Market registration fee to set.
/// * `underwriter_registration_fee`: Underwriter registration fee
///   to set.
/// * `custodian_registration_fee`: Custodian registration fee to
///   set.
/// * `taker_fee_divisor`: Taker fee divisor to set.
/// * `integrator_fee_store_tiers_ref`: Immutable reference to
///   0-indexed vector of 3-element vectors, with each 3-element
///   vector containing fields for a corresponding
///   `IntegratorFeeStoreTierParameters`.
pub fn update_incentives(
    econia_address: AccountAddress,
    utility_coin: &TypeTag,
    market_registration_fee: u64,
    underwriter_registration_fee: u64,
    custodian_registration_fee: u64,
    taker_fee_divisor: u64,
    integrator_fee_store_tiers: Vec<Vec<u64>>,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::incentives", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("update_incentives").to_owned(),
        vec![utility_coin.clone()],
        vec![
            bcs::to_bytes(&market_registration_fee)?,
            bcs::to_bytes(&underwriter_registration_fee)?,
            bcs::to_bytes(&custodian_registration_fee)?,
            bcs::to_bytes(&taker_fee_divisor)?,
            bcs::to_bytes(&integrator_fee_store_tiers)?,
        ],
    ))
}

/// Create the `EntryFunction` for [upgrade_integrator_fee_store_via_coinstore](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_upgrade_integrator_fee_store_via_coinstore)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `quote_coin`: [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) of the quote coin to use.
/// * `utility_coin`: [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) of the utility coin to use.
/// * `market_id`: Market ID for corresponding market.
/// * `new_tier`: Tier to upgrade to.
pub fn upgrade_integrator_fee_store_via_coinstore(
    econia_address: AccountAddress,
    quote_coin: &TypeTag,
    utility_coin: &TypeTag,
    market_id: u64,
    new_tier: u8,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::incentives", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("upgrade_integrator_fee_store_via_coinstore").to_owned(),
        vec![quote_coin.clone(), utility_coin.clone()],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&new_tier)?],
    ))
}

/// Create the `EntryFunction` for [withdraw_integrator_fees_via_coinstores](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_withdraw_integrator_fees_via_coinstores)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `quote_coin`: [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) of the quote coin to use.
/// * `utility_coin`: [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) of the utility coin to use.
/// * `market_id`: Market ID for corresponding market.
pub fn withdraw_integrator_fees_via_coinstores(
    econia_address: AccountAddress,
    quote_coin: &TypeTag,
    utility_coin: &TypeTag,
    market_id: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::incentives", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("withdraw_integrator_fees_via_coinstores").to_owned(),
        vec![quote_coin.clone(), utility_coin.clone()],
        vec![bcs::to_bytes(&market_id)?],
    ))
}

// Market entry functions

/// Create the `EntryFunction` for [cancel_all_orders_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_cancel_all_orders_user)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `market_id`: Market ID for corresponding market.
/// * `side`: Order [`Side`].
pub fn cancel_all_orders_user(
    econia_address: AccountAddress,
    market_id: u64,
    side: Side,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("cancel_all_orders_user").to_owned(),
        vec![],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&side)?],
    ))
}

/// Create the `EntryFunction` for [cancel_order_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_cancel_order_user)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `market_id`: Market ID for corresponding market.
/// * `side`: Order [`Side`].
/// * `market_order_id`: ID of the order to cancel.
pub fn cancel_order_user(
    econia_address: AccountAddress,
    market_id: u64,
    side: Side,
    market_order_id: u128,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("cancel_order_user").to_owned(),
        vec![],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(&side)?,
            bcs::to_bytes(&market_order_id)?,
        ],
    ))
}

/// Create the `EntryFunction` for [change_order_size_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_change_order_size_user)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `market_id`: Market ID for corresponding market.
/// * `side`: Order [`Side`].
/// * `market_order_id`: ID of the order to cancel.
/// * `new_size`: New size of the order.
pub fn change_order_size_user(
    econia_address: AccountAddress,
    market_id: u64,
    side: Side,
    market_order_id: u128,
    new_size: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("change_order_size_user").to_owned(),
        vec![],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(&side)?,
            bcs::to_bytes(&market_order_id)?,
            bcs::to_bytes(&new_size)?,
        ],
    ))
}

/// Create the `EntryFunction` for [place_limit_order_passive_advance_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_passive_advance_user_entry)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `base`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for base coin.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `market_id`: Market ID for corresponding market.
/// * `integrator`: Integrator's `AccountAddress`.
/// * `side`: Order [`Side`].
/// * `size`: Size of the order in lots.
/// * `advance_style`: The [`AdvanceStyle`] of the order.
/// * `target_advance_amount`: Target advance amount.
#[allow(clippy::too_many_arguments)]
pub fn place_limit_order_passive_advance_user_entry(
    econia_address: AccountAddress,
    base: &TypeTag,
    quote: &TypeTag,
    market_id: u64,
    integrator: &AccountAddress,
    side: Side,
    size: u64,
    advance_style: AdvanceStyle,
    target_advance_amount: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("place_limit_order_passive_advance_user_entry").to_owned(),
        vec![base.clone(), quote.clone()],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(&integrator)?,
            bcs::to_bytes(&side)?,
            bcs::to_bytes(&size)?,
            bcs::to_bytes(&advance_style)?,
            bcs::to_bytes(&target_advance_amount)?,
        ],
    ))
}

/// Create the `EntryFunction` for [place_limit_order_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_user_entry)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `base`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for base coin.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `market_id`: Market ID for corresponding market.
/// * `integrator`: Integrator's [`AccountAddress`].
/// * `side`: Order [`Side`].
/// * `size`: Size of the order in lots.
/// * `price`: Price of the order.
/// * `restriction`: The [`Restriction`] of the order.
/// * `self_match_behavior`: The [`SelfMatchBehavior`] of the order.
#[allow(clippy::too_many_arguments)]
pub fn place_limit_order_user_entry(
    econia_address: AccountAddress,
    base: &TypeTag,
    quote: &TypeTag,
    market_id: u64,
    integrator: &AccountAddress,
    side: Side,
    size: u64,
    price: u64,
    restriction: Restriction,
    self_match_behavior: SelfMatchBehavior,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("place_limit_order_user_entry").to_owned(),
        vec![base.clone(), quote.clone()],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(&integrator)?,
            bcs::to_bytes(&side)?,
            bcs::to_bytes(&size)?,
            bcs::to_bytes(&price)?,
            bcs::to_bytes(&restriction)?,
            bcs::to_bytes(&self_match_behavior)?,
        ],
    ))
}

/// Create the `EntryFunction` for [register_market_base_coin_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `base`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for base coin.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `utility_coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for utility coin.
/// * `lot_size`: Lot size for this market.
/// * `tick_size`: Tick size for this market.
/// * `min_size`: Minimum order size for this market.
pub fn register_market_base_coin_from_coinstore(
    econia_address: AccountAddress,
    base: &TypeTag,
    quote: &TypeTag,
    utility_coin: &TypeTag,
    lot_size: u64,
    tick_size: u64,
    min_size: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("register_market_base_coin_from_coinstore").to_owned(),
        vec![base.clone(), quote.clone(), utility_coin.clone()],
        vec![
            bcs::to_bytes(&lot_size)?,
            bcs::to_bytes(&tick_size)?,
            bcs::to_bytes(&min_size)?,
        ],
    ))
}

/// Create the `EntryFunction` for [swap_between_coinstores_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_swap_between_coinstores_entry)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `base`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for base coin.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `utility_coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for utility coin.
/// * `lot_size`: Lot size for this market.
/// * `tick_size`: Tick size for this market.
/// * `min_size`: Minimum order size for this market.
#[allow(clippy::too_many_arguments)]
pub fn swap_between_coinstores_entry(
    econia_address: AccountAddress,
    base: &TypeTag,
    quote: &TypeTag,
    market_id: u64,
    integrator: &AccountAddress,
    side: Side,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("swap_between_coinstores_entry").to_owned(),
        vec![base.clone(), quote.clone()],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(&integrator)?,
            bcs::to_bytes(&side)?,
            bcs::to_bytes(&min_base)?,
            bcs::to_bytes(&max_base)?,
            bcs::to_bytes(&min_quote)?,
            bcs::to_bytes(&max_quote)?,
            bcs::to_bytes(&limit_price)?,
        ],
    ))
}

// Registry functions

/// Create the `EntryFunction` for [register_integrator_fee_store_base_tier](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_base_tier)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `utility_coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for utility coin.
/// * `market_id`: Market ID for corresponding market.
pub fn register_integrator_fee_store_base_tier(
    econia_address: AccountAddress,
    quote: &TypeTag,
    utility_coin: &TypeTag,
    market_id: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::registry", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("register_integrator_fee_store_base_tier").to_owned(),
        vec![quote.clone(), utility_coin.clone()],
        vec![bcs::to_bytes(&market_id)?],
    ))
}

/// Create the `EntryFunction` for [register_integrator_fee_store_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_from_coinstore)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `utility_coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for utility coin.
/// * `market_id`: Market ID for corresponding market.
/// * `tier`: Fee tier.
pub fn register_integrator_fee_store_from_coinstore(
    econia_address: AccountAddress,
    quote: &TypeTag,
    utility_coin: &TypeTag,
    market_id: u64,
    tier: u8,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::registry", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("register_integrator_fee_store_from_coinstore").to_owned(),
        vec![quote.clone(), utility_coin.clone()],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&tier)?],
    ))
}

/// Create the `EntryFunction` for [remove_recognized_markets](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_remove_recognized_markets)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `market_ids`: Vector of market IDs to remove.
pub fn remove_recognized_markets(
    econia_address: AccountAddress,
    market_ids: Vec<u64>,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::registry", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("remove_recognized_markets").to_owned(),
        vec![],
        vec![bcs::to_bytes(&market_ids)?],
    ))
}

/// Create the `EntryFunction` for [set_recognized_market](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_set_recognized_market)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `market_id`: Market ID to recognize.
pub fn set_recognized_market(
    econia_address: AccountAddress,
    market_id: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::registry", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("set_recognized_market").to_owned(),
        vec![],
        vec![bcs::to_bytes(&market_id)?],
    ))
}

// User functions

/// Create the `EntryFunction` for [deposit_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_deposit_from_coinstore)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for deposit coin.
/// * `market_id`: Market ID for corresponding market.
/// * `custodian_id`: ID of market custodian.
/// * `amount`: Amount of coin to deposit.
pub fn deposit_from_coinstore(
    econia_address: AccountAddress,
    coin: &TypeTag,
    market_id: u64,
    custodian_id: u64,
    amount: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::user", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("deposit_from_coinstore").to_owned(),
        vec![coin.clone()],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(&custodian_id)?,
            bcs::to_bytes(&amount)?,
        ],
    ))
}

/// Create the `EntryFunction` for [register_market_account](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_register_market_account)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `base`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for base coin.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `market_id`: Market ID for corresponding market.
/// * `custodian_id`: ID of market custodian.
pub fn register_market_account(
    econia_address: AccountAddress,
    base: &TypeTag,
    quote: &TypeTag,
    market_id: u64,
    custodian_id: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::user", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("register_market_account").to_owned(),
        vec![base.clone(), quote.clone()],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
    ))
}

/// Create the `EntryFunction` for [register_market_account_generic_base](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_register_market_account_generic_base)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `market_id`: Market ID for corresponding market.
/// * `custodian_id`: ID of market custodian.
pub fn register_market_account_generic_base(
    econia_address: AccountAddress,
    quote: &TypeTag,
    market_id: u64,
    custodian_id: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::user", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("register_market_account_generic_base").to_owned(),
        vec![quote.clone()],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
    ))
}

/// Create the `EntryFunction` for [withdraw_to_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_withdraw_to_coinstore)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `coin`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for withdrawal coin.
/// * `market_id`: Market ID for corresponding market.
/// * `amount`: Amount of coin to withdraw.
pub fn withdraw_to_coinstore(
    econia_address: AccountAddress,
    coin: &TypeTag,
    market_id: u64,
    amount: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::user", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("withdraw_to_coinstore").to_owned(),
        vec![coin.clone()],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&amount)?],
    ))
}

/// Create the `EntryFunction` for [init_market_event_handle_if_missing](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_init_market_event_handles_if_missing)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `market_id`: Market ID for corresponding market.
/// * `custodian_id`: ID of market custodian.
pub fn init_market_event_handles_if_missing(
    econia_address: AccountAddress,
    market_id: u64,
    custodian_id: u64,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::user", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("init_market_event_handles_if_missing").to_owned(),
        vec![],
        vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
    ))
}

/// Create the `EntryFunction` for [place_market_order_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_market_place_market_order_user_entry)
///
/// Arguments:
/// * `econia_address`: Aptos `AccountAddress` of the account that holds the econia modules.
/// * `base`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for base coin.
/// * `quote`: Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for quote coin.
/// * `market_id`: Market ID for corresponding market.
/// * `integrator`: Integrator's AccountAddress.
/// * `side`: Order [`Side`].
/// * `size`: Size of the order in lots.
/// * `restriction`: The [`Restriction`] of the order.
/// * `self_match_behavior`: The [`SelfMatchBehavior`] of the order.
pub fn place_market_order_user_entry(
    econia_address: AccountAddress,
    base: &TypeTag,
    quote: &TypeTag,
    market_id: u64,
    integrator: &AccountAddress,
    side: Side,
    size: u64,
    self_match_behavior: SelfMatchBehavior,
) -> EconiaResult<EntryFunction> {
    let module = ModuleId::from(
        MoveModuleId::from_str(&format!("{}::market", econia_address))
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
    );
    Ok(EntryFunction::new(
        module,
        ident_str!("place_market_order_user_entry").to_owned(),
        vec![base.clone(), quote.clone()],
        vec![
            bcs::to_bytes(&market_id)?,
            bcs::to_bytes(integrator)?,
            bcs::to_bytes(&side)?,
            bcs::to_bytes(&size)?,
            bcs::to_bytes(&self_match_behavior)?,
        ],
    ))
}
