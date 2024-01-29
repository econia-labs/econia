//! The [`view`](crate::view) module exposes the view functionalities of the Econia package.
//!
//! You can create an [`EconiaViewClient`] from an [`EconiaClient`](crate::EconiaClient) using the
//! [`EconiaClient::view_client`](crate::EconiaClient::view_client) function.
//!
//! You can then call the functions provided here.
//!
//! There are also standalone functions which do not need any blockchain state and compute
//! locally. Those do not need an [`EconiaViewClient`] to execute.

use std::fmt::Display;
use std::str::FromStr;

use aptos_api_types::{IdentifierWrapper, MoveModuleId, MoveType, ViewRequest};
use aptos_sdk::rest_client::Client;
use aptos_sdk::types::account_address::AccountAddress;
use econia_types::order::{Order, Side, SHIFT_MARKET_ID};
use econia_types::order::{HI_64, HI_PRICE, NIL, SHIFT_COUNTER};
use serde::Serialize;
use serde::{Deserialize, Deserializer};
use serde_json::json;

use crate::errors::*;
use crate::EconiaResult;

pub struct EconiaViewClient<'a> {
    client: &'a Client,
    econia_address: AccountAddress,
}

fn from_str<'de, T, D>(deserializer: D) -> Result<T, D::Error>
where
    T: FromStr,
    T::Err: Display,
    D: Deserializer<'de>,
{
    let s = String::deserialize(deserializer)?;
    T::from_str(&s).map_err(serde::de::Error::custom)
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MarketEventHandleCreationInfo {
    pub resource_account_address: AccountAddress,
    #[serde(deserialize_with = "from_str")]
    pub cancel_order_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub place_swap_order_events_handle_creation_num: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct OrderView {
    #[serde(deserialize_with = "from_str")]
    pub market_id: u64,
    pub side: Side,
    #[serde(deserialize_with = "from_str")]
    pub order_id: u128,
    #[serde(deserialize_with = "from_str")]
    pub remaining_size: u64,
    #[serde(deserialize_with = "from_str")]
    pub price: u64,
    pub user: AccountAddress,
    #[serde(deserialize_with = "from_str")]
    pub custodian_id: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct OrdersView {
    pub asks: Vec<OrderView>,
    pub bids: Vec<OrderView>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PriceLevel {
    #[serde(deserialize_with = "from_str")]
    pub price: u64,
    #[serde(deserialize_with = "from_str")]
    pub size: u128,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PriceLevels {
    #[serde(deserialize_with = "from_str")]
    pub market_id: u64,
    pub asks: Vec<PriceLevel>,
    pub bids: Vec<PriceLevel>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SwapperEventHandleCreationNumbers {
    #[serde(deserialize_with = "from_str")]
    pub cancel_order_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub fill_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub place_swap_order_events_handle_creation_num: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MarketCounts {
    #[serde(deserialize_with = "from_str")]
    pub n_markets: u64,
    #[serde(deserialize_with = "from_str")]
    pub n_recognized_markets: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct AssetTypeView {
    pub package_address: AccountAddress,
    pub module_name: String,
    pub type_name: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MarketInfoView {
    #[serde(deserialize_with = "from_str")]
    pub market_id: u64,
    pub is_recognized: bool,
    pub base_type: AssetTypeView,
    pub base_name_generic: String,
    pub quote_type: AssetTypeView,
    #[serde(deserialize_with = "from_str")]
    pub lot_size: u64,
    #[serde(deserialize_with = "from_str")]
    pub tick_size: u64,
    #[serde(deserialize_with = "from_str")]
    pub min_size: u64,
    #[serde(deserialize_with = "from_str")]
    pub underwriter_id: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MarketAccountView {
    #[serde(deserialize_with = "from_str")]
    pub market_id: u64,
    #[serde(deserialize_with = "from_str")]
    pub custodian_id: u64,
    pub asks: Vec<Order>,
    pub bids: Vec<Order>,
    #[serde(deserialize_with = "from_str")]
    pub base_total: u64,
    #[serde(deserialize_with = "from_str")]
    pub base_available: u64,
    #[serde(deserialize_with = "from_str")]
    pub base_ceiling: u64,
    #[serde(deserialize_with = "from_str")]
    pub quote_total: u64,
    #[serde(deserialize_with = "from_str")]
    pub quote_available: u64,
    #[serde(deserialize_with = "from_str")]
    pub quote_ceiling: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MarketEventHandleCreationNumbers {
    #[serde(deserialize_with = "from_str")]
    pub cancel_order_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub change_order_size_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub fill_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub place_limit_order_events_handle_creation_num: u64,
    #[serde(deserialize_with = "from_str")]
    pub place_market_order_events_handle_creation_num: u64,
}

impl<'a> EconiaViewClient<'a> {
    pub fn new(client: &'a Client, econia_address: AccountAddress) -> Self {
        Self {
            client,
            econia_address,
        }
    }

    // Market related view functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Call `did_order_post` view function.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn did_order_post(&self, order_id: u128) -> EconiaResult<bool> {
        Ok(did_order_post(order_id))
    }

    /// Call `get_market_event_handle_creation_info` view function.
    ///
    /// Arguments:
    /// * `market_id`: the id of the market
    pub async fn get_market_event_handle_creation_info(
        &self,
        market_id: u64,
    ) -> EconiaResult<Option<MarketEventHandleCreationInfo>> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_event_handle_creation_info").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let data = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?["vec"]
            .get(0);
        Ok(match data {
            Some(n) => Some(serde_json::from_value(n.clone())?),
            None => None,
        })
    }

    /// Call `get_market_order_id_counter` view function.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn get_market_order_id_counter(&self, market_order_id: u128) -> EconiaResult<u64> {
        Ok(get_market_order_id_counter(market_order_id))
    }

    /// Call `get_market_order_id_price` view function.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn get_market_order_id_price(&self, market_order_id: u128) -> EconiaResult<u64> {
        get_market_order_id_price(market_order_id)
    }

    /// Call `get_open_order` view function.
    ///
    /// Arguments:
    /// * `market_id`: the id of the market the order is in.
    /// * `order_id`: the id of the order to get.
    pub async fn get_open_order(
        &self,
        market_id: u64,
        order_id: u128,
    ) -> EconiaResult<Option<OrderView>> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_open_order").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(market_id.to_string()), json!(order_id.to_string())],
                },
                None,
            )
            .await?;
        let data = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?["vec"]
            .get(0);
        Ok(match data {
            Some(n) => Some(serde_json::from_value(n.clone())?),
            None => None,
        })
    }

    /// Call `get_open_orders` view function.
    ///
    /// Arguments:
    /// * `market_id`: the id of the market to get the orders from.
    /// * `n_asks_max`: the maximum number of asks to index.
    /// * `n_bids_max`: the maximum number of bids to index.
    pub async fn get_open_orders(
        &self,
        market_id: u64,
        n_asks_max: u64,
        n_bids_max: u64,
    ) -> EconiaResult<OrdersView> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_open_orders").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![
                        json!(market_id.to_string()),
                        json!(n_asks_max.to_string()),
                        json!(n_bids_max.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let value: OrdersView = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_open_orders_all` view function.
    ///
    /// Arguments:
    /// * `market_id`: the id of the market to get the orders from.
    pub async fn get_open_orders_all(&self, market_id: u64) -> EconiaResult<OrdersView> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_open_orders_all").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let value: OrdersView = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_posted_order_id_side` view function.
    ///
    /// Arguments:
    /// * `user`: the address of the user to check market account ids for.
    /// * `market_id`: the id of the market to check market accounts for.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn get_posted_order_id_side(&self, order_id: u128) -> EconiaResult<bool> {
        get_posted_order_id_side(order_id)
    }

    /// Call `get_price_levels` view function.
    ///
    /// Arguments:
    /// * `market_id`: the id of the market to get the price levels from.
    /// * `n_ask_levels_max`: the maximum number of ask price levels to index.
    /// * `n_bid_levels_max`: the maximum number of bid price levels to index.
    pub async fn get_price_levels(
        &self,
        market_id: u64,
        n_ask_levels_max: u64,
        n_bid_levels_max: u64,
    ) -> EconiaResult<PriceLevels> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_price_levels").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![
                        json!(market_id.to_string()),
                        json!(n_ask_levels_max.to_string()),
                        json!(n_bid_levels_max.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let value: PriceLevels = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_price_levels_all` view function.
    ///
    /// Arguments:
    /// * `market_id`: the id of the market to get the price levels from.
    pub async fn get_price_levels_all(&self, market_id: u64) -> EconiaResult<PriceLevels> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_price_levels_all").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let value: PriceLevels = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_swapper_event_handle_creation_numbers` view function.
    pub async fn get_swapper_event_handle_creation_numbers(
        &self,
        swapper: AccountAddress,
        market_id: u64,
    ) -> EconiaResult<SwapperEventHandleCreationNumbers> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name =
            IdentifierWrapper::from_str("get_swapper_event_handle_creation_numbers").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(swapper.to_string()), json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let value: SwapperEventHandleCreationNumbers = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `has_open_order` view function.
    pub async fn has_open_order(&self, market_id: u64, order_id: u128) -> EconiaResult<bool> {
        let managed_coin = format!("{}::market", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("has_open_order").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(market_id.to_string()), json!(order_id.to_string())],
                },
                None,
            )
            .await?;
        let value = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?
            .as_bool()
            .ok_or(EconiaError::InvalidResponse)?;
        Ok(value)
    }

    // Market related view functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Registry related view functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Call `get_market_counts` view function.
    pub async fn get_market_counts(&self) -> EconiaResult<MarketCounts> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_counts").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![],
                },
                None,
            )
            .await?;
        let value: MarketCounts = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_market_id_base_coin` view function.
    pub async fn get_market_id_base_coin(
        &self,
        base_type: MoveType,
        quote_type: MoveType,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
    ) -> EconiaResult<Option<u64>> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_id_base_coin").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![base_type, quote_type],
                    arguments: vec![
                        json!(lot_size.to_string()),
                        json!(tick_size.to_string()),
                        json!(min_size.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let data = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?["vec"]
            .get(0);
        Ok(match data {
            Some(n) => Some(n.as_str().unwrap().parse().unwrap()),
            None => None,
        })
    }

    /// Call `get_market_id_base_generic` view function.
    pub async fn get_market_id_base_generic(
        &self,
        quote_type: MoveType,
        base_name_generic: String,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        underwriter_id: u64,
    ) -> EconiaResult<Option<u64>> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_id_base_generic").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![quote_type],
                    arguments: vec![
                        json!(base_name_generic),
                        json!(lot_size.to_string()),
                        json!(tick_size.to_string()),
                        json!(min_size.to_string()),
                        json!(underwriter_id.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let data = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?["vec"]
            .get(0);
        Ok(match data {
            Some(n) => Some(n.as_str().unwrap().parse().unwrap()),
            None => None,
        })
    }

    /// Call `get_market_info` view function.
    pub async fn get_market_info(&self, market_id: u64) -> EconiaResult<MarketInfoView> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_info").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let value: MarketInfoView = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_recognized_market_id_base_coin` view function.
    pub async fn get_recognized_market_id_base_coin(
        &self,
        base_type: MoveType,
        quote_type: MoveType,
    ) -> EconiaResult<u64> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_recognized_market_id_base_coin").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![base_type, quote_type],
                    arguments: vec![],
                },
                None,
            )
            .await?;
        let value: u64 = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_recognized_market_id_base_generic` view function.
    pub async fn get_recognized_market_id_base_generic(
        &self,
        quote_type: MoveType,
        base_name_generic: String,
    ) -> EconiaResult<u64> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_recognized_market_id_base_generic").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![quote_type],
                    arguments: vec![json!(base_name_generic)],
                },
                None,
            )
            .await?;
        let value: u64 = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `has_recognized_market_base_coin_by_type` view function.
    pub async fn has_recognized_market_base_coin_by_type(
        &self,
        base_type: MoveType,
        quote_type: MoveType,
    ) -> EconiaResult<bool> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("has_recognized_market_base_coin_by_type").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![base_type, quote_type],
                    arguments: vec![],
                },
                None,
            )
            .await?;
        let value = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?
            .as_bool()
            .ok_or(EconiaError::InvalidResponse)?;
        Ok(value)
    }

    /// Call `has_recognized_market_base_generic_by_type` view function.
    pub async fn has_recognized_market_base_generic_by_type(
        &self,
        quote_type: MoveType,
        base_name_generic: String,
    ) -> EconiaResult<bool> {
        let managed_coin = format!("{}::registry", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name =
            IdentifierWrapper::from_str("has_recognized_market_base_generic_by_type").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![quote_type],
                    arguments: vec![json!(base_name_generic)],
                },
                None,
            )
            .await?;
        let value = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?
            .as_bool()
            .ok_or(EconiaError::InvalidResponse)?;
        Ok(value)
    }

    // Registry related view functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // User related view functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Call `get_all_market_account_ids_for_market_id` view function.
    ///
    /// Arguments:
    /// * `user`: the address of the user to check market account ids for.
    /// * `market_id`: the id of the market to check market accounts for.
    pub async fn get_all_market_account_ids_for_market_id(
        &self,
        user: AccountAddress,
        market_id: u64,
    ) -> EconiaResult<Vec<u128>> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_all_market_account_ids_for_market_id").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(user.to_string()), json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let value: Vec<u128> = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_all_market_account_ids_for_user` view function.
    ///
    /// Arguments:
    /// * `user`: the address of the user to check market account ids for.
    pub async fn get_all_market_account_ids_for_user(
        &self,
        user: AccountAddress,
    ) -> EconiaResult<Vec<u128>> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_all_market_account_ids_for_user").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(user.to_string())],
                },
                None,
            )
            .await?;
        let value: Vec<u128> = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_custodian_id` view function.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn get_custodian_id(&self, market_account_id: u128) -> EconiaResult<u64> {
        Ok(get_custodian_id(market_account_id))
    }

    /// Call `get_market_account` view function.
    pub async fn get_market_account(
        &self,
        user: AccountAddress,
        market_id: u64,
        custodian_id: u64,
    ) -> EconiaResult<MarketAccountView> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_account").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![
                        json!(user.to_string()),
                        json!(market_id.to_string()),
                        json!(custodian_id.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let value: MarketAccountView = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_market_account_id` view function.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn get_market_account_id(&self, market_id: u64, custodian_id: u64) -> EconiaResult<u128> {
        Ok(get_market_account_id(market_id, custodian_id))
    }

    /// Call `get_market_accounts` view function.
    pub async fn get_market_accounts(
        &self,
        user: AccountAddress,
    ) -> EconiaResult<Vec<MarketAccountView>> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_accounts").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(user.to_string())],
                },
                None,
            )
            .await?;
        let value: Vec<MarketAccountView> = serde_json::from_value(
            response
                .inner()
                .get(0)
                .ok_or(EconiaError::InvalidResponse)?
                .clone(),
        )?;
        Ok(value)
    }

    /// Call `get_market_event_handle_creation_numbers` view function.
    pub async fn get_market_event_handle_creation_numbers(
        &self,
        user: AccountAddress,
        market_id: u64,
        custodian_id: u64,
    ) -> EconiaResult<Option<MarketEventHandleCreationNumbers>> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("get_market_event_handle_creation_numbers").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![
                        json!(user.to_string()),
                        json!(market_id.to_string()),
                        json!(custodian_id.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let data = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?["vec"]
            .get(0);
        Ok(match data {
            Some(n) => Some(serde_json::from_value(n.clone())?),
            None => None,
        })
    }

    /// Call `get_market_id` view function.
    ///
    /// This will not actually reach out to the blockchain. It will compute the result locally as it
    /// does not need blockchain data.
    ///
    /// This function just calls the standalone one. It is also exposed here for API consistency.
    pub fn get_market_id(&self, market_account_id: u128) -> EconiaResult<u64> {
        Ok(get_market_id(market_account_id))
    }

    /// Call `has_market_account` view function.
    ///
    /// Arguments:
    /// * `user`: the address of the user to check market account ids for.
    /// * `market_id`: the id of the market to check market accounts for.
    /// * `custodian_id`: the id of the custodian to check market accounts for.
    pub async fn has_market_account(
        &self,
        user: AccountAddress,
        market_id: u64,
        custodian_id: u64,
    ) -> EconiaResult<bool> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("has_market_account").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![
                        json!(user.to_string()),
                        json!(market_id.to_string()),
                        json!(custodian_id.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let value = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?
            .as_bool()
            .ok_or(EconiaError::InvalidResponse)?;
        Ok(value)
    }

    /// Call `has_market_account_by_market_account_id` view function.
    ///
    /// Arguments:
    /// * `user`: the address of the user to check market account ids for.
    /// * `market_account_id`: the id of the market account to check market accounts for.
    pub async fn has_market_account_by_market_account_id(
        &self,
        user: AccountAddress,
        market_account_id: u128,
    ) -> EconiaResult<bool> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("has_market_account_by_market_account_id").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![
                        json!(user.to_string()),
                        json!(market_account_id.to_string()),
                    ],
                },
                None,
            )
            .await?;
        let value = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?
            .as_bool()
            .ok_or(EconiaError::InvalidResponse)?;
        Ok(value)
    }

    /// Call `has_market_account_by_market_id` view function.
    ///
    /// Arguments:
    /// * `user`: the address of the user to check market account ids for.
    /// * `market_id`: the id of the market to check market accounts for.
    pub async fn has_market_account_by_market_id(
        &self,
        user: AccountAddress,
        market_id: u128,
    ) -> EconiaResult<bool> {
        let managed_coin = format!("{}::user", self.econia_address);
        let module = MoveModuleId::from_str(&managed_coin)
            .map_err(|a| EconiaError::InvalidModuleId(a.to_string()))?;
        let name = IdentifierWrapper::from_str("has_market_account_by_market_id").unwrap();
        let response = self
            .client
            .view(
                &ViewRequest {
                    function: aptos_api_types::EntryFunctionId { module, name },
                    type_arguments: vec![],
                    arguments: vec![json!(user.to_string()), json!(market_id.to_string())],
                },
                None,
            )
            .await?;
        let value = response
            .inner()
            .get(0)
            .ok_or(EconiaError::InvalidResponse)?
            .as_bool()
            .ok_or(EconiaError::InvalidResponse)?;
        Ok(value)
    }

    // User related view functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}

/// Call `did_order_post` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn did_order_post(order_id: u128) -> bool {
    (order_id & (0xffffffffffffffff as u128)) != (NIL as u128)
}

/// Call `get_market_order_id_counter` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn get_market_order_id_counter(market_order_id: u128) -> u64 {
    ((market_order_id >> SHIFT_COUNTER) & (HI_64 as u128)) as u64
}

/// Call `get_posted_order_id_side` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn get_posted_order_id_side(order_id: u128) -> EconiaResult<bool> {
    if !did_order_post(order_id) {
        Err(EconiaError::MarketError(MarketError::OrderDidNotPost))
    } else {
        let avlq_access_key = (order_id & (HI_64 as u128)) as u64;
        let result = if ((avlq_access_key >> 32u8) & 1u64) as u8 == 1 {
            Side::Ask
        } else {
            Side::Bid
        };
        Ok(result.into())
    }
}

/// Call `get_market_order_id_price` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn get_market_order_id_price(market_order_id: u128) -> EconiaResult<u64> {
    if !did_order_post(market_order_id) {
        Err(EconiaError::MarketError(MarketError::OrderDidNotPost))
    } else {
        Ok((market_order_id & (HI_PRICE as u128)) as u64)
    }
}

/// Call `get_custodian_id` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn get_custodian_id(market_account_id: u128) -> u64 {
    (market_account_id & (HI_64 as u128)) as u64
}

/// Call `get_market_account_id` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn get_market_account_id(market_id: u64, custodian_id: u64) -> u128 {
    ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128)
}

/// Call `get_market_id` view function.
///
/// This will not actually reach out to the blockchain. It will compute the result locally as it
/// does not need blockchain data.
pub fn get_market_id(market_account_id: u128) -> u64 {
    (market_account_id >> SHIFT_MARKET_ID) as u64
}
