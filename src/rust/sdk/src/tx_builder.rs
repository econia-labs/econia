use std::cmp::max;
use std::str::FromStr;

use anyhow::{anyhow, Context, Result};
use aptos_api_types::{AptosErrorCode, MoveModuleId, MoveType, Transaction};
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
