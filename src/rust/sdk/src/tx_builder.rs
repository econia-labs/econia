use std::cmp::max;
use std::str::FromStr;

use anyhow::{anyhow, Context, Result};
use aptos_api_types::{AptosErrorCode, MoveModuleId, MoveType, Transaction};
use aptos_sdk::bcs;
use aptos_sdk::move_types::account_address::AccountAddress;
use aptos_sdk::move_types::ident_str;
use aptos_sdk::move_types::language_storage::TypeTag;
use aptos_sdk::rest_client::error::RestError;
use aptos_sdk::transaction_builder::TransactionFactory;
use aptos_sdk::{move_types::language_storage::ModuleId, types::transaction::EntryFunction};
use econia_types::events::EconiaEvent;

use crate::{EconiaClient, EconiaTransaction};

const SUBMIT_ATTEMPTS: u8 = 10;

pub struct EconiaTransactionBuilder<'a> {
    client: &'a mut EconiaClient,
    retry_amount: Option<u8>,
    entry: Option<Result<EntryFunction>>,
}

impl<'a> EconiaTransactionBuilder<'a> {
    pub fn new(client: &'a mut EconiaClient) -> Self {
        Self {
            client,
            retry_amount: None,
            entry: None,
        }
    }

    pub fn retry_amount(mut self, amount: u8) -> Self {
        self.retry_amount = Some(amount);
        self
    }

    pub fn register_for_coin(mut self, coin: &TypeTag) -> Self {
        let Ok(id) = MoveModuleId::from_str("0x1::managed_coin") else {
            self.entry = Some(Err(anyhow!("invalid module id")));
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

    pub fn update_incentives(
        mut self,
        utility_coin: &TypeTag,
        market_registration_fee: u64,
        underwriter_registration_fee: u64,
        custodian_registration_fee: u64,
        taker_fee_divisor: u64,
        integrator_fee_store_tiers: Vec<Vec<u64>>,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn upgrade_integrator_fee_store_via_coinstore(
        mut self,
        quote_coin: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
        new_tier: u8,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("upgrade_integrator_fee_store_via_coinstore").to_owned(),
                vec![quote_coin.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&new_tier)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn withdraw_integrator_fees_via_coinstores(
        mut self,
        quote_coin: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("withdraw_integrator_fees_via_coinstores").to_owned(),
                vec![quote_coin.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    // Market entry functions

    pub fn cancel_all_orders_user(mut self, market_id: u64, side: bool) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("cancel_all_orders_user").to_owned(),
                vec![],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&side)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn cancel_order_user(mut self, market_id: u64, side: bool, market_order_id: u128) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn change_order_size_user(
        mut self,
        market_id: u64,
        side: bool,
        market_order_id: u128,
        new_size: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn place_limit_order_passive_advance_user_entry(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        integrator: &AccountAddress,
        side: bool,
        size: u64,
        advance_style: bool,
        target_advance_amount: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn place_limit_order_user_entry(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        integrator: &AccountAddress,
        side: bool,
        size: u64,
        price: u64,
        restriction: u8,
        self_match_behavior: u8,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn place_market_order_user_entry(
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
        self_match_behavior: u8,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("place_market_order_user_entry").to_owned(),
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
                    bcs::to_bytes(&self_match_behavior)?,
                ],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn register_market_base_coin_from_coinstore(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        utility_coin: &TypeTag,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn register_integrator_fee_store_base_tier(
        mut self,
        quote: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("register_integrator_fee_store_base_tier").to_owned(),
                vec![quote.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn register_integrator_fee_store_from_coinstore(
        mut self,
        quote: &TypeTag,
        utility_coin: &TypeTag,
        market_id: u64,
        tier: u8,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("register_integrator_fee_store_from_coinstore").to_owned(),
                vec![quote.clone(), utility_coin.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&tier)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn remove_recognized_markets(mut self, market_ids: Vec<u64>) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("remove_recognized_markets").to_owned(),
                vec![],
                vec![bcs::to_bytes(&market_ids)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn set_recognized_market(mut self, market_id: u64) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("set_recognized_market").to_owned(),
                vec![],
                vec![bcs::to_bytes(&market_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    // User functions

    pub fn deposit_from_coinstore(
        mut self,
        coin: &TypeTag,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
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

    pub fn register_market_account(
        mut self,
        base: &TypeTag,
        quote: &TypeTag,
        market_id: u64,
        custodian_id: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("register_market_account").to_owned(),
                vec![base.clone(), quote.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn register_market_account_generic_base(
        mut self,
        quote: &TypeTag,
        market_id: u64,
        custodian_id: u64,
    ) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("register_market_account_generic_base").to_owned(),
                vec![quote.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&custodian_id)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    pub fn withdraw_to_coinstore(mut self, coin: &TypeTag, market_id: u64, amount: u64) -> Self {
        let entry: Result<EntryFunction> = (|| {
            Ok(EntryFunction::new(
                ModuleId::from(self.client.econia_module().to_owned()),
                ident_str!("withdraw_to_coinstore").to_owned(),
                vec![coin.clone()],
                vec![bcs::to_bytes(&market_id)?, bcs::to_bytes(&amount)?],
            ))
        })();

        self.entry = Some(entry);
        self
    }

    async fn submit_tx_internal(&mut self, payload: &EntryFunction) -> Result<EconiaTransaction> {
        let addr = self.client.account().address();
        let tx = TransactionFactory::new(self.client.chain_id)
            .entry_function(payload.clone())
            .sender(addr)
            .sequence_number(self.client.account().sequence_number())
            .max_gas_amount(1_000_000)
            .build();

        let signed_tx = self.client.account().sign_transaction(tx);
        let pending = match self.client.aptos().submit(&signed_tx).await {
            Ok(res) => res.into_inner(),
            Err(RestError::Api(a)) => {
                return match a.error.error_code {
                    AptosErrorCode::InvalidTransactionUpdate
                    | AptosErrorCode::SequenceNumberTooOld
                    | AptosErrorCode::VmError => {
                        let seq_num = self.client.get_sequence_number().await?;
                        let acc_seq_num = self.client.account_mut().sequence_number_mut();
                        *acc_seq_num = max(seq_num, *acc_seq_num + 1);
                        Err(anyhow!(a))
                    }
                    _ => Err(anyhow!(a)),
                }
            }
            Err(e) => return Err(anyhow!(e)),
        };

        let Transaction::UserTransaction(ut) = self.client.aptos().wait_for_transaction(&pending).await?.into_inner() else {
            return Err(anyhow!("not a user transaction"))
        };

        let events = ut
            .events
            .iter()
            .filter(|e| matches!(&e.typ, MoveType::Struct(s) if s.address.inner() == self.client.econia()))
            .map(|e| serde_json::from_value(e.data.clone()).context("failed deserializing event"))
            .collect::<Result<Vec<EconiaEvent>>>()?;

        Ok(EconiaTransaction {
            info: ut.info.clone(),
            request: ut.request.clone(),
            events,
            timestamp: ut.timestamp,
        })
    }

    pub async fn submit_tx(mut self) -> Result<EconiaTransaction> {
        let Some(entry) = std::mem::take(&mut self.entry) else {
            return Err(anyhow!("no entry function provided"))
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
                Err(anyhow!("failed submitting tx"))
            }
            Err(e) => Err(e),
        }
    }
}
