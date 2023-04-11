use anyhow::{anyhow, Context, Result};
use aptos_api_types::{MoveModuleId, TransactionInfo, UserTransactionRequest, U64};
use aptos_sdk::crypto::ed25519::Ed25519PrivateKey;
use aptos_sdk::crypto::ValidCryptoMaterialStringExt;
use aptos_sdk::move_types::ident_str;
use aptos_sdk::move_types::language_storage::{ModuleId, TypeTag};
use aptos_sdk::rest_client::aptos::Balance;
use aptos_sdk::rest_client::{Client, Resource};
use aptos_sdk::types::account_address::AccountAddress;
use aptos_sdk::types::chain_id::ChainId;
use aptos_sdk::types::transaction::EntryFunction;
use aptos_sdk::types::{AccountKey, LocalAccount};
use econia_types::events::Events;
use reqwest::Url;
use serde::Deserialize;
use std::collections::HashMap;
use std::fmt::Debug;
use std::fs::File;
use std::str::FromStr;

pub const SUBMIT_ATTEMPTS: u8 = 10;

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

pub struct EconiaTransaction {
    pub info: TransactionInfo,
    pub request: UserTransactionRequest,
    pub events: Vec<Events>,
    pub timestamp: U64,
}

pub struct EconiaClient {
    econia: AccountAddress,
    aptos: Client,
    chain_id: ChainId,
    account: LocalAccount,
}

impl EconiaClient {
    /// Connect to an Aptos node and initialize the Econia client.
    ///
    /// # Arguments:
    ///
    /// * `node_url` - Url of aptos node.
    /// * `econia_address` - Aptos `AccountAddress`.
    /// * `account` - `LocalAccount` representing Aptos user account
    pub async fn connect(
        node_url: Url,
        econia: AccountAddress,
        mut account: LocalAccount,
    ) -> Result<Self> {
        let aptos = Client::new(node_url);
        let index = aptos.get_index().await?.into_inner();
        let chain_id = ChainId::new(index.chain_id);
        let account_info = aptos.get_account(account.address()).await?.into_inner();
        let seq_num = account_info.sequence_number;
        let acc_seq_num = account.sequence_number_mut();
        *acc_seq_num = seq_num;

        Ok(Self {
            econia,
            aptos,
            chain_id,
            account,
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
    ///
    /// # Panics:
    ///
    /// * If provided url is not valid.
    /// * If provided private key is invalid.
    pub async fn connect_with_strings(
        node_url: &str,
        econia_address: &str,
        account_address: &str,
        account_private_key: &str,
    ) -> Result<Self> {
        let node_url = Url::parse(node_url).expect("node url is not valid");
        let econia = AccountAddress::from_hex_literal(econia_address)?;
        let account_address = AccountAddress::from_hex_literal(account_address)?;
        let private_key = Ed25519PrivateKey::from_encoded_string(account_private_key)
            .expect("private key provided is not valid");
        let account_key = AccountKey::from(private_key);
        let account = LocalAccount::new(account_address, account_key, 0);
        Self::connect(node_url, econia, account).await
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
    pub async fn connect_with_config(
        node_url: &str,
        econia_address: &str,
        config_path: &str,
        config_profile_name: &str,
    ) -> Result<Self> {
        let config = AptosConfig::from_config(config_path, config_profile_name);
        Self::connect_with_strings(
            node_url,
            econia_address,
            &config.account,
            &config.private_key,
        )
        .await
    }

    pub fn econia(&self) -> &AccountAddress {
        &self.econia
    }

    pub fn aptos(&self) -> &Client {
        &self.aptos
    }

    pub fn account(&self) -> &LocalAccount {
        &self.account
    }

    /// Update the econia clients aptos chain id.
    /// If the aptos team pushes out a new node deployment, the chain id may change.
    /// In case of a change the internal chain id needs to be updated
    pub async fn update_chain_id(&mut self) -> Result<()> {
        let index = self.aptos.get_index().await?.into_inner();
        let chain_id = ChainId::new(index.chain_id);
        self.chain_id = chain_id;
        Ok(())
    }

    // TODO doc strings for these functions
    pub async fn get_sequence_number(&self) -> Result<u64> {
        self.aptos
            .get_account(self.account.address())
            .await
            .with_context(|| {
                format!(
                    "failed getting account: {}",
                    self.account.address().to_hex_literal()
                )
            })
            .map(|a| a.inner().sequence_number)
    }

    async fn fetch_resource(
        &self,
        address: AccountAddress,
        resource: &str,
    ) -> Result<Option<Resource>> {
        self.aptos
            .get_account_resource(address, resource)
            .await
            .with_context(|| {
                format!(
                    "failed getting resource: {} for account: {}",
                    resource,
                    address.to_hex_literal()
                )
            })
            .map(|a| a.into_inner())
    }

    pub async fn does_coin_exist(&self, coin: &TypeTag) -> Result<bool> {
        let coin_info = format!("0x1::coin::CoinInfo<{}>", coin);
        let TypeTag::Struct(tag) = coin else {
            return Err(anyhow!("failed extracting coin typetag"))
        };

        self.fetch_resource(tag.address, &coin_info)
            .await
            .map(|r| r.is_some())
    }

    pub async fn is_registered_for_coin(&self, coin: &TypeTag) -> Result<bool> {
        let coin_store = format!("0x1::coin::CoinStore<{}>", coin);
        self.fetch_resource(self.account.address(), &coin_store)
            .await
            .map(|r| r.is_some())
    }

    pub fn register_for_coin(coin: &TypeTag) -> Result<EntryFunction> {
        let entry = EntryFunction::new(
            ModuleId::from(MoveModuleId::from_str("0x1::managed_coin")?),
            ident_str!("register").to_owned(),
            vec![coin.clone()],
            vec![],
        );

        Ok(entry)
    }

    pub async fn get_coin_balance(&self, coin: &TypeTag) -> Result<U64> {
        let coin_store = format!("0x1::coin::CoinStore<{}>", coin);
        self.fetch_resource(self.account.address(), &coin_store)
            .await?
            .with_context(|| format!("user is not registered for coin: {}", &coin_store))
            .and_then(|r| {
                serde_json::from_value::<Balance>(r.data).context("failed deserializing balance")
            })
            .map(|b| b.coin.value)
    }
}

#[cfg(test)]
mod tests {}
