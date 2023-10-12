use aptos_api_types::{
    AptosErrorCode, MoveType, Transaction, TransactionInfo, UserTransactionRequest, VersionedEvent,
    U64,
};
use aptos_sdk::crypto::ed25519::Ed25519PrivateKey;
use aptos_sdk::crypto::ValidCryptoMaterialStringExt;
use aptos_sdk::move_types::language_storage::TypeTag;
use aptos_sdk::rest_client::aptos::Balance;
use aptos_sdk::rest_client::error::RestError;
use aptos_sdk::rest_client::{Client, Resource};
use aptos_sdk::transaction_builder::TransactionFactory;
use aptos_sdk::types::account_address::AccountAddress;
use aptos_sdk::types::chain_id::ChainId;
use aptos_sdk::types::transaction::EntryFunction;
use aptos_sdk::types::{AccountKey, LocalAccount};
use econia_types::events::EconiaEvent;
use errors::EconiaError;
use reqwest::Url;
use serde::Deserialize;
use std::cmp::max;
use std::collections::HashMap;
use std::default;
use std::fmt::Debug;
use std::fs::File;
use view::EconiaViewClient;

pub mod entry;
pub mod errors;
pub mod view;

pub use econia_types as types;

pub const SUBMIT_ATTEMPTS: u8 = 10;
pub const MAX_GAS_AMOUNT: u64 = 1_000_000;

#[derive(Deserialize, Debug, Clone)]
struct AptosConfig {
    private_key: String,
    account: String,
}

type AptosConfigYaml = HashMap<String, HashMap<String, AptosConfig>>;

impl AptosConfig {
    pub fn from_config(path: &str, profile_name: &str) -> Self {
        let file = File::open(path).expect("invalid config path provided");
        let config =
            serde_yaml::from_reader::<File, AptosConfigYaml>(file).expect("config file is invalid");
        let profiles = config
            .get("profiles")
            .expect("profiles section missing in config file");
        profiles
            .get(profile_name)
            .expect("given profile name is missing in config file")
            .clone()
    }
}

pub type EconiaResult<T> = std::result::Result<T, EconiaError>;

#[derive(Debug, Clone)]
pub struct EconiaTransaction {
    /// Aptos `TransactionInfo`
    pub info: TransactionInfo,
    /// Transaction request sent to Aptos `UserTransactionRequest`
    pub request: UserTransactionRequest,
    /// List of [`EconiaEvent`] generated by the transaction
    pub events: Vec<EconiaEvent>,
    /// The time the transaction occurred.
    pub timestamp: U64,
}

#[derive(Debug)]
pub struct EconiaClientConfig {
    /// Amount of times to attempt submitting a transaction.
    pub retry_count: u8,
    /// Max gas to use in an Aptos transaction.
    pub max_gas_amount: u64,
}

impl default::Default for EconiaClientConfig {
    fn default() -> Self {
        Self {
            retry_count: SUBMIT_ATTEMPTS,
            max_gas_amount: MAX_GAS_AMOUNT,
        }
    }
}

#[derive(Debug)]
pub struct EconiaClient {
    /// Aptos `AccountAddress` of the account that holds the econia modules.
    pub econia_address: AccountAddress,
    /// Aptos `Client` used to communicate with the Aptos node.
    pub aptos_client: Client,
    /// Aptos `ChainId` of the Aptos node.
    pub chain_id: ChainId,
    /// Aptos `LocalAccount` representing the user account of this client.
    pub user_account: LocalAccount,
    /// `EconiaClientConfig`
    pub config: EconiaClientConfig,
}

impl EconiaClient {
    /// Connect to an Aptos node and initialize the Econia client.
    ///
    /// # Arguments:
    ///
    /// * `node_url` - Url of aptos node.
    /// * `econia_address` - Aptos `AccountAddress`.
    /// * `account` - `LocalAccount` representing Aptos user account.
    /// * `config` - `EconiaClientConfig` to configure the Econia client, if `None` default values will be used.
    pub async fn connect(
        node_url: Url,
        econia: AccountAddress,
        mut account: LocalAccount,
        config: Option<EconiaClientConfig>,
    ) -> EconiaResult<Self> {
        let aptos = Client::new(node_url);
        let index = aptos.get_index().await?.into_inner();
        let chain_id = ChainId::new(index.chain_id);
        let account_info = aptos.get_account(account.address()).await?.into_inner();
        let seq_num = account_info.sequence_number;
        account.set_sequence_number(seq_num);

        Ok(Self {
            econia_address: econia,
            aptos_client: aptos,
            chain_id,
            user_account: account,
            config: config.unwrap_or_default(),
        })
    }

    /// Connect to an Aptos node and initialize the econia client using
    /// url strings, account address string and private key string.
    ///
    /// # Arguments:
    ///
    /// * `node_url` - url string of aptos node to connect to.
    /// * `econia_address` - hex encoded address string of account that holds the econia modules.
    /// * `account_address` - hex encoded address string of user using this client.
    /// * `account_private_key` - hex encoded private key string of user using this client.
    /// * `config` - `EconiaClientConfig` to configure the Econia client, if `None` default values will be used.
    pub async fn connect_with_strings(
        node_url: &str,
        econia_address: &str,
        account_address: &str,
        account_private_key: &str,
        config: Option<EconiaClientConfig>,
    ) -> EconiaResult<Self> {
        let node_url = Url::parse(node_url).expect("node url is not valid");
        let econia = AccountAddress::from_hex_literal(econia_address)?;
        let account_address = AccountAddress::from_hex_literal(account_address)?;
        let private_key = Ed25519PrivateKey::from_encoded_string(account_private_key)?;
        let account_key = AccountKey::from(private_key);
        let account = LocalAccount::new(account_address, account_key, 0);
        Self::connect(node_url, econia, account, config).await
    }

    /// Connect to an Aptos node and initialize the econia client using a config file.
    /// The config file format is the default format created by the aptos cli.
    ///
    /// # Arguments:
    ///
    /// * `node_url` - Url string of aptos node to connect to.
    /// * `econia_address` - Hex encoded address string of account that holds the econia modules.
    /// * `config_path` - Path to config file.
    /// * `config_profile_name` - Name of profile to use in the config file.
    /// * `config` - `EconiaClientConfig` to configure the Econia client, if `None` default values will be used.
    pub async fn connect_with_config(
        node_url: &str,
        econia_address: &str,
        aptos_config_path: &str,
        aptos_config_profile_name: &str,
        config: Option<EconiaClientConfig>,
    ) -> EconiaResult<Self> {
        let aptos_config = AptosConfig::from_config(aptos_config_path, aptos_config_profile_name);
        Self::connect_with_strings(
            node_url,
            econia_address,
            &aptos_config.account,
            &aptos_config.private_key,
            config,
        )
        .await
    }

    /// Update the econia client's aptos chain id.
    /// If the aptos team pushes out a new node deployment, the chain id may change.
    /// In case of a change the internal chain id needs to be updated.
    pub async fn update_chain_id(&mut self) -> EconiaResult<()> {
        let index = self.aptos_client.get_index().await?.into_inner();
        let chain_id = ChainId::new(index.chain_id);
        self.chain_id = chain_id;
        Ok(())
    }

    /// Return the current aptos sequence number for the user account
    /// in this econia client.
    pub async fn get_sequence_number(&self) -> EconiaResult<u64> {
        self.aptos_client
            .get_account(self.user_account.address())
            .await
            .map(|a| a.inner().sequence_number)
            .map_err(EconiaError::AptosError)
    }

    async fn fetch_resource(
        &self,
        address: AccountAddress,
        resource: &str,
    ) -> EconiaResult<Option<Resource>> {
        self.aptos_client
            .get_account_resource(address, resource)
            .await
            .map(|a| a.into_inner())
            .map_err(EconiaError::AptosError)
    }

    pub async fn get_events_by_creation_number(
        &self,
        creation_number: u64,
        address: AccountAddress,
        start: Option<u64>,
        limit: Option<u16>,
    ) -> EconiaResult<Vec<VersionedEvent>> {
        let url = self
            .aptos_client
            .build_path(&format!(
                "accounts/{}/events/{}",
                address.to_hex_literal(),
                creation_number,
            ))
            .map_err(EconiaError::AptosError)?;

        let client = reqwest::Client::new();
        let mut request = client.get(url);

        if let Some(start) = start {
            request = request.query(&[("start", start)])
        }

        if let Some(limit) = limit {
            request = request.query(&[("limit", limit)])
        }

        let response = request
            .send()
            .await
            .map_err(|e| EconiaError::Custom(Box::new(e)))?;
        Ok(response
            .json()
            .await
            .map_err(|e| EconiaError::Custom(Box::new(e)))?)
    }

    /// Checks if a coin exists on the aptos chain.
    ///
    /// # Arguments:
    ///
    /// * `coin` - Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for the given coin.
    pub async fn does_coin_exist(&self, coin: &TypeTag) -> EconiaResult<bool> {
        let coin_info = format!("0x1::coin::CoinInfo<{}>", coin);
        let TypeTag::Struct(tag) = coin else {
            return Err(EconiaError::InvalidTypeTag(coin.clone()));
        };

        self.fetch_resource(tag.address, &coin_info)
            .await
            .map(|r| r.is_some())
    }

    /// Checks if the user is registered for a coin's CoinStore.
    ///
    /// # Arguments:
    ///
    /// * `coin` - Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for the given coin.
    pub async fn is_registered_for_coin(&self, coin: &TypeTag) -> EconiaResult<bool> {
        let coin_store = format!("0x1::coin::CoinStore<{}>", coin);
        self.fetch_resource(self.user_account.address(), &coin_store)
            .await
            .map(|r| r.is_some())
    }

    /// Returns the user's coin balance in their CoinStore.
    ///
    /// # Arguments:
    ///
    /// * `coin` - Aptos [`TypeTag`](https://docs.rs/move-core-types/0.0.3/move_core_types/language_storage/enum.TypeTag.html) for the given coin.
    pub async fn get_coin_balance(&self, coin: &TypeTag) -> EconiaResult<U64> {
        let coin_store = format!("0x1::coin::CoinStore<{}>", coin);
        self.fetch_resource(self.user_account.address(), &coin_store)
            .await?
            .ok_or_else(|| EconiaError::AccountNotRegisteredForCoin(coin.clone()))
            .and_then(|r| serde_json::from_value::<Balance>(r.data).map_err(EconiaError::JsonError))
            .map(|b| b.coin.value)
    }

    async fn submit_tx_internal(
        &mut self,
        payload: &EntryFunction,
    ) -> EconiaResult<EconiaTransaction> {
        let addr = self.user_account.address();
        let tx = TransactionFactory::new(self.chain_id)
            .entry_function(payload.clone())
            .sender(addr)
            .sequence_number(self.user_account.sequence_number())
            .max_gas_amount(self.config.max_gas_amount)
            .build();

        let signed_tx = self.user_account.sign_transaction(tx);
        let pending = match self.aptos_client.submit(&signed_tx).await {
            Ok(res) => {
                let seq_num = self.get_sequence_number().await?;
                let acc_seq_num = self.user_account.sequence_number();
                self.user_account
                    .set_sequence_number(max(seq_num + 1, acc_seq_num + 1));
                res.into_inner()
            }
            Err(RestError::Api(a)) => {
                let seq_num = self.get_sequence_number().await?;
                let acc_seq_num = self.user_account.sequence_number();
                self.user_account
                    .set_sequence_number(max(seq_num + 1, acc_seq_num + 1));
                return match a.error.error_code {
                    AptosErrorCode::InvalidTransactionUpdate
                    | AptosErrorCode::SequenceNumberTooOld
                    | AptosErrorCode::VmError => {
                        Err(EconiaError::AptosError(RestError::Api(a)))
                    }
                    _ => {
                        Err(EconiaError::AptosError(RestError::Api(a)))
                    },
                }
            }
            Err(e) => {
                let seq_num = self.get_sequence_number().await?;
                let acc_seq_num = self.user_account.sequence_number();
                self.user_account
                    .set_sequence_number(max(seq_num + 1, acc_seq_num + 1));
                return Err(EconiaError::AptosError(e))
            },
        };

        let tx = self
            .aptos_client
            .wait_for_transaction(&pending)
            .await?
            .into_inner();

        let Transaction::UserTransaction(ut) = tx else {
            return Err(EconiaError::InvalidTransaction);
        };

        let events = ut
            .events
            .iter()
            .filter(|e| matches!(&e.typ, MoveType::Struct(s) if s.address.inner() == &self.econia_address))
            .map(|e| serde_json::from_value(e.data.clone()))
            .collect::<Result<Vec<EconiaEvent>, serde_json::Error>>()?;

        Ok(EconiaTransaction {
            info: ut.info.clone(),
            request: ut.request.clone(),
            events,
            timestamp: ut.timestamp,
        })
    }

    /// Create and submit a transaction to the blockchain returning the an [`EconiaResult<EconiaTransaction>`].
    ///
    /// # Arguments:
    ///
    /// * `entry` - `EntryFunction` to be submitted as part of the transaction to the blockchain.
    pub async fn submit_tx(&mut self, entry: EntryFunction) -> EconiaResult<EconiaTransaction> {
        for i in 0..(self.config.retry_count) {
            match self.submit_tx_internal(&entry).await {
                Ok(lt) => return Ok(lt),
                Err(e) if i == SUBMIT_ATTEMPTS - 1 => return Err(e),
                _ => continue,
            }
        }
        Err(EconiaError::FailedSubmittingTransaction)
    }

    pub fn view_client(&self) -> EconiaViewClient {
        EconiaViewClient::new(&self.aptos_client, self.econia_address.clone())
    }
}

#[cfg(test)]
mod tests {}
