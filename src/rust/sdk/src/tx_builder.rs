use std::cmp::max;
use std::str::FromStr;

use aptos_api_types::{AptosErrorCode, MoveModuleId, MoveType, Transaction};
use aptos_sdk::bcs;
use aptos_sdk::move_types::account_address::AccountAddress;
use aptos_sdk::move_types::ident_str;
use aptos_sdk::move_types::language_storage::TypeTag;
use aptos_sdk::rest_client::error::RestError;
use aptos_sdk::transaction_builder::TransactionFactory;
use aptos_sdk::{move_types::language_storage::ModuleId, types::transaction::EntryFunction};
use econia_types::events::EconiaEvent;
use econia_types::order::{AdvanceStyle, Restriction, SelfMatchBehavior, Side};

use crate::errors::EconiaError;
use crate::{EconiaClient, EconiaResult, EconiaTransaction};

const SUBMIT_ATTEMPTS: u8 = 10;

pub struct EconiaTransactionBuilder<'a> {
    client: &'a mut EconiaClient,
    retry_amount: Option<u8>,
    entry: Option<EconiaResult<EntryFunction>>,
}

impl<'a> EconiaTransactionBuilder<'a> {
    /// Create a new [`EconiaTransactionBuilder`].
    ///
    /// Arguments:
    /// * `client`: a mutable reference to the underlying [`EconiaClient`].
    pub fn new(client: &'a mut EconiaClient) -> Self {
        Self {
            client,
            retry_amount: None,
            entry: None,
        }
    }

    /// Set the retry amount for the transaction.
    ///
    /// Arguments:
    /// * `amount`: the amount of times to retry the transaction.
    pub fn retry_amount(mut self, amount: u8) -> Self {
        self.retry_amount = Some(amount);
        self
    }

    /// Set the internal [`EntryFunction`] as register_for_coin
    ///
    /// Arguments:
    /// * `amount`: the amount of times to retry the transaction.
    pub fn register_for_coin(mut self, coin: &TypeTag) -> Self {
        let managed_coin = "0x1::managed_coin";
        let Ok(id) = MoveModuleId::from_str(managed_coin) else {
            self.entry = Some(Err(EconiaError::InvalidModuleId(managed_coin.to_string())));
            return self
        };

        let entry = EntryFunction::new(
            ModuleId::from(id),
            ident_str!("register").to_owned(),
            vec![coin.clone()],
            vec![],
        );

        self.entry = Some(Ok(entry));
        self
    }

    // Incentives entry functions

    /// Set the internal [`EntryFunction`] as [update_incentives](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_update_incentives)
    ///
    /// Arguments:
    /// * `utility_coin`: [`TypeTag`] of the utility coin to use.
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
        mut self,
        utility_coin: &TypeTag,
        market_registration_fee: u64,
        underwriter_registration_fee: u64,
        custodian_registration_fee: u64,
        taker_fee_divisor: u64,
        integrator_fee_store_tiers: Vec<Vec<u64>>,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::incentives", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [upgrade_integrator_fee_store_via_coinstore](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_upgrade_integrator_fee_store_via_coinstore)
    ///
    /// Arguments:
    /// * `quote_coin`: [`TypeTag`] of the quote coin to use.
    /// * `utility_coin`: [`TypeTag`] of the utility coin to use.
    /// * `market_id`: Market ID for corresponding market.
    /// * `new_tier`: Tier to upgrade to.
    pub fn upgrade_integrator_fee_store_via_coinstore(
        mut self,
        quote_coin: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
        new_tier: u8,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::incentives", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("upgrade_integrator_fee_store_via_coinstore").to_owned(),
                vec![quote_coin.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&new_tier)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [withdraw_integrator_fees_via_coinstores](https://github.com/econia-labs/econia/blob/dev/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_withdraw_integrator_fees_via_coinstores)
    ///
    /// Arguments:
    /// * `quote_coin`: [`TypeTag`] of the quote coin to use.
    /// * `utility_coin`: [`TypeTag`] of the utility coin to use.
    /// * `market_id`: Market ID for corresponding market.
    pub fn withdraw_integrator_fees_via_coinstores(
        mut self,
        quote_coin: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::incentives", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("withdraw_integrator_fees_via_coinstores").to_owned(),
                vec![quote_coin.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    // Market entry functions

    /// Set the internal [`EntryFunction`] as [cancel_all_orders_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_cancel_all_orders_user)
    ///
    /// Arguments:
    /// * `market_id`: Market ID for corresponding market.
    /// * `side`: Order [`Side`].
    pub fn cancel_all_orders_user(mut self, market_id: u64, side: Side) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("cancel_all_orders_user").to_owned(),
                vec![],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&side)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [cancel_order_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_cancel_order_user)
    ///
    /// Arguments:
    /// * `market_id`: Market ID for corresponding market.
    /// * `side`: Order [`Side`].
    /// * `market_order_id`: ID of the order to cancel.
    pub fn cancel_order_user(mut self, market_id: u64, side: Side, market_order_id: u128) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [change_order_size_user](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_change_order_size_user)
    ///
    /// Arguments:
    /// * `market_id`: Market ID for corresponding market.
    /// * `side`: Order [`Side`].
    /// * `market_order_id`: ID of the order to cancel.
    /// * `new_size`: New size of the order.
    pub fn change_order_size_user(
        mut self,
        market_id: u64,
        side: Side,
        market_order_id: u128,
        new_size: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [place_limit_order_passive_advance_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_passive_advance_user_entry)
    ///
    /// Arguments:
    /// * `base`: Aptos [`TypeTag`] for base coin.
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `integrator`: Integrator's [`AccountAddress`].
    /// * `side`: Order [`Side`].
    /// * `size`: Size of the order in lots.
    /// * `advance_style`: The [`AdvanceStyle`] of the order.
    /// * `target_advance_amount`: Target advance amount.
    #[allow(clippy::too_many_arguments)]
    pub fn place_limit_order_passive_advance_user_entry(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        integrator: &AccountAddress,
        side: Side,
        size: u64,
        advance_style: AdvanceStyle,
        target_advance_amount: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [place_limit_order_user_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_place_limit_order_user_entry)
    ///
    /// Arguments:
    /// * `base`: Aptos [`TypeTag`] for base coin.
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `integrator`: Integrator's [`AccountAddress`].
    /// * `side`: Order [`Side`].
    /// * `size`: Size of the order in lots.
    /// * `advance_style`: The [`AdvanceStyle`] of the order.
    /// * `target_advance_amount`: Target advance amount.
    #[allow(clippy::too_many_arguments)]
    pub fn place_limit_order_user_entry(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        integrator: &AccountAddress,
        side: Side,
        size: u64,
        price: u64,
        restriction: Restriction,
        self_match_behavior: SelfMatchBehavior,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [register_market_base_coin_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore)
    ///
    /// Arguments:
    /// * `base`: Aptos [`TypeTag`] for base coin.
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `utility_coin`: Aptos [`TypeTag`] for utility coin.
    /// * `lot_size`: Lot size for this market.
    /// * `tick_size`: Tick size for this market.
    /// * `min_size`: Minimum order size for this market.
    pub fn register_market_base_coin_from_coinstore(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        utility_coin: &TypeTag,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [swap_between_coinstores_entry](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#0xc0deb00c_market_swap_between_coinstores_entry)
    ///
    /// Arguments:
    /// * `base`: Aptos [`TypeTag`] for base coin.
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `utility_coin`: Aptos [`TypeTag`] for utility coin.
    /// * `lot_size`: Lot size for this market.
    /// * `tick_size`: Tick size for this market.
    /// * `min_size`: Minimum order size for this market.
    #[allow(clippy::too_many_arguments)]
    pub fn swap_between_coinstores_entry(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        integrator: &AccountAddress,
        direction: bool,
        min_base: u64,
        max_base: u64,
        min_quote: u64,
        max_quote: u64,
        limit_price: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::market", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("swap_between_coinstores_entry").to_owned(),
                vec![base.clone(), quote.clone()],
                vec![
                    bcs::to_bytes(&market_id)?,
                    bcs::to_bytes(&integrator)?,
                    bcs::to_bytes(&direction)?,
                    bcs::to_bytes(&min_base)?,
                    bcs::to_bytes(&max_base)?,
                    bcs::to_bytes(&min_quote)?,
                    bcs::to_bytes(&max_quote)?,
                    bcs::to_bytes(&limit_price)?,
                ],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    // Registry functions

    /// Set the internal [`EntryFunction`] as [register_integrator_fee_store_base_tier](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_base_tier)
    ///
    /// Arguments:
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `utility_coin`: Aptos [`TypeTag`] for utility coin.
    /// * `market_id`: Market ID for corresponding market.
    pub fn register_integrator_fee_store_base_tier(
        mut self,
        quote: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::registry", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("register_integrator_fee_store_base_tier").to_owned(),
                vec![quote.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [register_integrator_fee_store_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_from_coinstore)
    ///
    /// Arguments:
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `utility_coin`: Aptos [`TypeTag`] for utility coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `tier`: Fee tier.
    pub fn register_integrator_fee_store_from_coinstore(
        mut self,
        quote: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
        tier: u8,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::registry", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("register_integrator_fee_store_from_coinstore").to_owned(),
                vec![quote.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&tier)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [remove_recognized_markets](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_remove_recognized_markets)
    ///
    /// Arguments:
    /// * `market_ids`: Vector of market IDs to remove.
    pub fn remove_recognized_markets(mut self, market_ids: Vec<u64>) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::registry", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("remove_recognized_markets").to_owned(),
                vec![],
                vec![bcs::to_bytes(&market_ids)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [set_recognized_market](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_set_recognized_market)
    ///
    /// Arguments:
    /// * `market_id`: Market ID to recognize.
    pub fn set_recognized_market(mut self, market_id: u64) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::registry", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("set_recognized_market").to_owned(),
                vec![],
                vec![bcs::to_bytes(&market_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    // User functions

    /// Set the internal [`EntryFunction`] as [deposit_from_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_deposit_from_coinstore)
    ///
    /// Arguments:
    /// * `coin`: Aptos [`TypeTag`] for deposit coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `custodian_id`: ID of market custodian.
    /// * `amount`: Amount of coin to deposit.
    pub fn deposit_from_coinstore(
        mut self,
        coin: &TypeTag,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::user", self.client.econia_address))
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
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [register_market_account](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_register_market_account)
    ///
    /// Arguments:
    /// * `base`: Aptos [`TypeTag`] for base coin.
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `custodian_id`: ID of market custodian.
    pub fn register_market_account(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        custodian_id: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::user", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("register_market_account").to_owned(),
                vec![base.clone(), quote.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [register_market_account_generic_base](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_register_market_account_generic_base)
    ///
    /// Arguments:
    /// * `quote`: Aptos [`TypeTag`] for quote coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `custodian_id`: ID of market custodian.
    pub fn register_market_account_generic_base(
        mut self,
        quote: &TypeTag,
        market_id: u64,
        custodian_id: u64,
    ) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::user", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("register_market_account_generic_base").to_owned(),
                vec![quote.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    /// Set the internal [`EntryFunction`] as [withdraw_to_coinstore](https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/user.md#0xc0deb00c_user_withdraw_to_coinstore)
    ///
    /// Arguments:
    /// * `coin`: Aptos [`TypeTag`] for withdrawal coin.
    /// * `market_id`: Market ID for corresponding market.
    /// * `amount`: Amount of coin to withdraw.
    pub fn withdraw_to_coinstore(mut self, coin: &TypeTag, market_id: u64, amount: u64) -> Self {
        let entry: EconiaResult<EntryFunction> = (|| {
            let module = ModuleId::from(
                MoveModuleId::from_str(&format!("{}::user", self.client.econia_address))
                    .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?,
            );
            Ok(EntryFunction::new(
                module,
                ident_str!("withdraw_to_coinstore").to_owned(),
                vec![coin.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&amount)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    async fn submit_tx_internal(
        &mut self,
        payload: &EntryFunction,
    ) -> EconiaResult<EconiaTransaction> {
        let addr = self.client.user_account.address();
        let tx = TransactionFactory::new(self.client.chain_id)
            .entry_function(payload.clone())
            .sender(addr)
            .sequence_number(self.client.user_account.sequence_number())
            .max_gas_amount(1_000_000)
            .build();

        let signed_tx = self.client.user_account.sign_transaction(tx);
        let pending = match self.client.aptos_client.submit(&signed_tx).await {
            Ok(res) => res.into_inner(),
            Err(RestError::Api(a)) => {
                return match a.error.error_code {
                    AptosErrorCode::InvalidTransactionUpdate
                    | AptosErrorCode::SequenceNumberTooOld
                    | AptosErrorCode::VmError => {
                        let seq_num = self.client.get_sequence_number().await?;
                        let acc_seq_num = self.client.user_account.sequence_number_mut();
                        *acc_seq_num = max(seq_num, *acc_seq_num + 1);
                        Err(EconiaError::AptosError(RestError::Api(a)))
                    }
                    _ => Err(EconiaError::AptosError(RestError::Api(a))),
                }
            }
            Err(e) => return Err(EconiaError::AptosError(e)),
        };

        let tx = self
            .client
            .aptos_client
            .wait_for_transaction(&pending)
            .await?
            .into_inner();

        let Transaction::UserTransaction(ut) = tx else {
            return Err(EconiaError::InvalidTransaction)
        };

        let events = ut
            .events
            .iter()
            .filter(|e| matches!(&e.typ, MoveType::Struct(s) if s.address.inner() == &self.client.econia_address))
            .map(|e| serde_json::from_value(e.data.clone()))
            .collect::<Result<Vec<EconiaEvent>, serde_json::Error>>()?;

        Ok(EconiaTransaction {
            info: ut.info.clone(),
            request: ut.request.clone(),
            events,
            timestamp: ut.timestamp,
        })
    }

    /// Consume this [`EconiaTransactionBuilder`] and submit the transaction to the blockchain
    /// returning the an [`EconiaResult<EconiaTransaction>`].
    pub async fn submit_tx(mut self) -> EconiaResult<EconiaTransaction> {
        let Some(entry) = std::mem::take(&mut self.entry) else {
            return Err(EconiaError::TransactionMissingEntryFunction)
        };

        match entry {
            Ok(entry) => {
                for i in 0..(self.retry_amount.unwrap_or(SUBMIT_ATTEMPTS)) {
                    match self.submit_tx_internal(&entry).await {
                        Ok(lt) => return Ok(lt),
                        Err(e) if i == SUBMIT_ATTEMPTS - 1 => return Err(e),
                        _ => continue,
                    }
                }
                Err(EconiaError::FailedSubmittingTransaction)
            }
            Err(e) => Err(e),
        }
    }
}
