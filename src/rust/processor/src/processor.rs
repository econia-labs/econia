use aptos_indexer_processor_sdk::{aptos_indexer_transaction_stream::utils::time::parse_timestamp, postgres::utils::database::ArcDbPool};
use anyhow::anyhow;
use aptos_indexer_processor_sdk::aptos_protos::transaction::v1::{transaction::TxnData, write_set_change::Change, Transaction};
use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use diesel::{result::Error, QueryResult};
use diesel_async::{AsyncPgConnection, RunQueryDsl};
use dbv2::{
    models::{
        BalanceUpdate, CancelOrderEvent, ChangeOrderSizeEvent, FillEvent, MarketAccountHandle,
        MarketRegistrationEvent, PlaceLimitOrderEvent, PlaceMarketOrderEvent, PlaceSwapOrderEvent,
        RecognizedMarketEvent,
    },
    schema::public::{
        balance_updates_by_handle, cancel_order_events, change_order_size_events, fill_events,
        market_account_handles, market_registration_events, place_limit_order_events,
        place_market_order_events, place_swap_order_events, recognized_market_events,
    },
};
use diesel_async::scoped_futures::ScopedFutureExt;

use serde_json::Value;
use std::{collections::HashMap, str::FromStr};

use crate::events::EventModel;

pub const MAX_EVENTS_PER_CHUNCK: usize = 1000;

pub const MAX_TRANSACTION_RETRIES: usize = 10;

lazy_static::lazy_static! {
    static ref MODULE_ADDRESS: String = std::env::var("ECONIA_ADDRESS")
        .expect("ECONIA_ADDRESS must be set.")
        .to_owned();
}

pub fn strip_hex_number(hex: String) -> anyhow::Result<String> {
    let (start, end) = hex.split_at(2);

    if start != "0x" {
        Err(anyhow!("Invalid hex provided ({}).", hex))
    } else {
        let r = format!("0x{}", end.trim_start_matches("0"));
        if r == "0x" {
            Ok(String::from("0x0"))
        } else {
            Ok(r)
        }
    }
}

const HI_64: u128 = 0xffffffffffffffff;
const SHIFT_MARKET_ID: u8 = 64;

fn hex_to_string(hex: &str) -> anyhow::Result<String> {
    if !hex.starts_with("0x") {
        return Err(anyhow!("Hex string is not 0x-prefixed"));
    }

    let mut hex_no_prefix = hex[2..].to_owned();
    // If an odd number of characters, prepend a 0 so that bytes can be decoded.
    if hex_no_prefix.len() % 2 != 0 {
        hex_no_prefix = format!("0{}", hex_no_prefix);
    }
    let hex_bytes =
        hex::decode(hex_no_prefix).map_err(|e| anyhow!("Failed to decode hex: {}", e))?;

    String::from_utf8(hex_bytes)
        .map_err(|e| anyhow!("Failed to convert hex bytes to utf-8 string: {}", e))
}

fn opt_value_to_bool(value: Option<&Value>) -> anyhow::Result<bool> {
    match value {
        Some(Value::Bool(b)) => Ok(b.clone()),
        _ => Err(anyhow!("key not found or not a supported type")),
    }
}

fn opt_value_to_big_decimal(value: Option<&Value>) -> anyhow::Result<BigDecimal> {
    match value {
        Some(Value::String(s)) => Ok(BigDecimal::from_str(s)?),
        Some(Value::Number(n)) if n.is_u64() => Ok(BigDecimal::from(n.as_u64().unwrap())),
        _ => Err(anyhow!(
            "key not found or not a supported number type (i.e float)"
        )),
    }
}

fn opt_value_to_string(value: Option<&Value>) -> anyhow::Result<String> {
    match value {
        Some(Value::String(s)) => Ok(s.clone()),
        _ => Err(anyhow!("key not found or not a supported type")),
    }
}

fn opt_value_to_i16(value: Option<&Value>) -> anyhow::Result<i16> {
    match value {
        Some(Value::String(s)) => Ok(s.parse()?),
        Some(Value::Number(n)) => {
            if n.is_u64() {
                Ok(n.as_u64().unwrap().try_into()?)
            } else if n.is_i64() {
                Ok(n.as_i64().unwrap().try_into()?)
            } else {
                Err(anyhow!(
                    "key not found or not a supported number type (i.e float)"
                ))
            }
        },
        _ => Err(anyhow!(
            "key not found or not a supported number type (i.e float)"
        )),
    }
}

// If we try to insert an event twice, as according to its transaction
// version and event index, the second insertion will just be dropped
// and lost to the wind. It will not return an error.

async fn insert_balance_updates(
    conn: &mut AsyncPgConnection,
    handles: Vec<BalanceUpdate>,
) -> QueryResult<()> {
    let chunks = handles.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(balance_updates_by_handle::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_cancel_order_events(
    conn: &mut AsyncPgConnection,
    events: Vec<CancelOrderEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(cancel_order_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_change_order_size_events(
    conn: &mut AsyncPgConnection,
    events: Vec<ChangeOrderSizeEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(change_order_size_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_fill_events(
    conn: &mut AsyncPgConnection,
    events: Vec<FillEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(fill_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_market_account_handles(
    conn: &mut AsyncPgConnection,
    handles: Vec<MarketAccountHandle>,
) -> Result<(), diesel::result::Error> {
    let chunks = handles.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(market_account_handles::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_recognized_market_events(
    conn: &mut AsyncPgConnection,
    events: Vec<RecognizedMarketEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(recognized_market_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_market_registration_events(
    conn: &mut AsyncPgConnection,
    events: Vec<MarketRegistrationEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(market_registration_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_place_limit_order_events(
    conn: &mut AsyncPgConnection,
    events: Vec<PlaceLimitOrderEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(place_limit_order_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_place_market_order_events(
    conn: &mut AsyncPgConnection,
    events: Vec<PlaceMarketOrderEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(place_market_order_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

async fn insert_place_swap_order_events(
    conn: &mut AsyncPgConnection,
    events: Vec<PlaceSwapOrderEvent>,
) -> Result<(), diesel::result::Error> {
    let chunks = events.chunks(MAX_EVENTS_PER_CHUNCK);
    for e in chunks {
        diesel::insert_into(place_swap_order_events::table)
            .values(e)
            .on_conflict_do_nothing()
            .execute(conn)
            .await?;
    }
    Ok(())
}

fn event_data_to_cancel_order_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<CancelOrderEvent> {
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let user = strip_hex_number(opt_value_to_string(event.data.get("user"))?)?;
    let custodian_id = opt_value_to_big_decimal(event.data.get("custodian_id"))?;
    let order_id = opt_value_to_big_decimal(event.data.get("order_id"))?;
    let reason = opt_value_to_i16(event.data.get("reason"))?;

    let cancel_order_event = CancelOrderEvent {
        txn_version,
        event_idx,
        time,
        user,
        custodian_id,
        order_id,
        market_id,
        reason,
    };

    Ok(cancel_order_event)
}

fn event_data_to_change_order_size_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<ChangeOrderSizeEvent> {
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let user = strip_hex_number(opt_value_to_string(event.data.get("user"))?)?;
    let custodian_id = opt_value_to_big_decimal(event.data.get("custodian_id"))?;
    let order_id = opt_value_to_big_decimal(event.data.get("order_id"))?;
    let side = opt_value_to_bool(event.data.get("side"))?;
    let new_size = opt_value_to_big_decimal(event.data.get("new_size"))?;

    let change_order_size_event = ChangeOrderSizeEvent {
        txn_version,
        event_idx,
        time,
        user,
        custodian_id,
        order_id,
        market_id,
        side,
        new_size,
    };

    Ok(change_order_size_event)
}

fn event_data_to_fill_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<FillEvent> {
    let emit_address = strip_hex_number(event.account_address.to_string())?;
    let maker_address = strip_hex_number(opt_value_to_string(event.data.get("maker"))?)?;
    let maker_custodian_id = opt_value_to_big_decimal(event.data.get("maker_custodian_id"))?;
    let maker_order_id = opt_value_to_big_decimal(event.data.get("maker_order_id"))?;
    let maker_side = opt_value_to_bool(event.data.get("maker_side"))?;
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let price = opt_value_to_big_decimal(event.data.get("price"))?;
    let sequence_number_for_trade =
        opt_value_to_big_decimal(event.data.get("sequence_number_for_trade"))?;
    let size = opt_value_to_big_decimal(event.data.get("size"))?;
    let taker_address = strip_hex_number(opt_value_to_string(event.data.get("taker"))?)?;
    let taker_custodian_id = opt_value_to_big_decimal(event.data.get("taker_custodian_id"))?;
    let taker_order_id = opt_value_to_big_decimal(event.data.get("taker_order_id"))?;
    let taker_quote_fees_paid = opt_value_to_big_decimal(event.data.get("taker_quote_fees_paid"))?;

    let fill_event = FillEvent {
        txn_version,
        event_idx,
        emit_address,
        time,
        maker_address,
        maker_custodian_id,
        maker_order_id,
        maker_side,
        market_id,
        price,
        sequence_number_for_trade,
        size,
        taker_address,
        taker_custodian_id,
        taker_order_id,
        taker_quote_fees_paid,
    };

    Ok(fill_event)
}

fn event_data_to_recognized_market_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<RecognizedMarketEvent> {
    let market_info = event
        .data
        .get("recognized_market_info")
        .unwrap()
        .get("vec")
        .unwrap()
        .as_array()
        .unwrap()
        .get(0);
    let mut lot_size = None;
    let mut market_id = None;
    let mut min_size = None;
    let mut tick_size = None;
    let mut underwriter_id = None;
    match market_info {
        Some(info) => {
            lot_size = Some(opt_value_to_big_decimal(info.get("lot_size"))?);
            market_id = Some(opt_value_to_big_decimal(info.get("market_id"))?);
            min_size = Some(opt_value_to_big_decimal(info.get("min_size"))?);
            tick_size = Some(opt_value_to_big_decimal(info.get("tick_size"))?);
            underwriter_id = Some(opt_value_to_big_decimal(info.get("underwriter_id"))?);
        },
        _ => {},
    }
    let type_data = event.data.get("trading_pair").unwrap();
    let (base_name_generic, base_account_address, base_module_name_hex, base_struct_name_hex) =
        if opt_value_to_string(type_data.get("base_name_generic"))?.is_empty() {
            if let Some(base_type) = type_data.get("base_type") {
                (
                    None,
                    Some(strip_hex_number(opt_value_to_string(
                        base_type.get("account_address"),
                    )?)?),
                    Some(opt_value_to_string(base_type.get("module_name"))?),
                    Some(opt_value_to_string(base_type.get("struct_name"))?),
                )
            } else {
                anyhow::bail!("could not determine base");
            }
        } else {
            (
                Some(opt_value_to_string(type_data.get("base_name_generic"))?),
                None,
                None,
                None,
            )
        };
    let base_module_name =
        base_module_name_hex.map(|s| hex_to_string(s.as_str()).expect("Expected hex string"));
    let base_struct_name =
        base_struct_name_hex.map(|s| hex_to_string(s.as_str()).expect("Expected hex string"));

    let (quote_account_address, quote_module_name_hex, quote_struct_name_hex) =
        if let Some(quote_type) = type_data.get("quote_type") {
            (
                strip_hex_number(opt_value_to_string(quote_type.get("account_address"))?)?,
                opt_value_to_string(quote_type.get("module_name"))?,
                opt_value_to_string(quote_type.get("struct_name"))?,
            )
        } else {
            anyhow::bail!("could not determine quote");
        };
    let quote_module_name = hex_to_string(&quote_module_name_hex)?;
    let quote_struct_name = hex_to_string(&quote_struct_name_hex)?;

    let recognized_market_event = RecognizedMarketEvent {
        txn_version,
        event_idx,
        market_id,
        time,
        base_name_generic,
        base_account_address,
        base_module_name,
        base_struct_name,
        quote_account_address,
        quote_module_name,
        quote_struct_name,
        lot_size,
        tick_size,
        min_size,
        underwriter_id,
    };

    Ok(recognized_market_event)
}

fn event_data_to_market_registration_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<MarketRegistrationEvent> {
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let lot_size = opt_value_to_big_decimal(event.data.get("lot_size"))?;
    let tick_size = opt_value_to_big_decimal(event.data.get("tick_size"))?;
    let min_size = opt_value_to_big_decimal(event.data.get("min_size"))?;
    let underwriter_id = opt_value_to_big_decimal(event.data.get("underwriter_id"))?;
    let (base_name_generic, base_account_address, base_module_name_hex, base_struct_name_hex) =
        if opt_value_to_string(event.data.get("base_name_generic"))?.is_empty() {
            if let Some(base_type) = event.data.get("base_type") {
                (
                    None,
                    Some(strip_hex_number(opt_value_to_string(
                        base_type.get("account_address"),
                    )?)?),
                    Some(opt_value_to_string(base_type.get("module_name"))?),
                    Some(opt_value_to_string(base_type.get("struct_name"))?),
                )
            } else {
                anyhow::bail!("could not determine base");
            }
        } else {
            (
                Some(opt_value_to_string(event.data.get("base_name_generic"))?),
                None,
                None,
                None,
            )
        };
    let base_module_name =
        base_module_name_hex.map(|s| hex_to_string(s.as_str()).expect("Expected hex string"));
    let base_struct_name =
        base_struct_name_hex.map(|s| hex_to_string(s.as_str()).expect("Expected hex string"));

    let (quote_account_address, quote_module_name_hex, quote_struct_name_hex) =
        if let Some(quote_type) = event.data.get("quote_type") {
            (
                strip_hex_number(opt_value_to_string(quote_type.get("account_address"))?)?,
                opt_value_to_string(quote_type.get("module_name"))?,
                opt_value_to_string(quote_type.get("struct_name"))?,
            )
        } else {
            anyhow::bail!("could not determine quote");
        };
    let quote_module_name = hex_to_string(&quote_module_name_hex)?;
    let quote_struct_name = hex_to_string(&quote_struct_name_hex)?;

    let market_registration_event = MarketRegistrationEvent {
        txn_version,
        event_idx,
        market_id,
        time,
        base_name_generic,
        base_account_address,
        base_module_name,
        base_struct_name,
        quote_account_address,
        quote_module_name,
        quote_struct_name,
        lot_size,
        tick_size,
        min_size,
        underwriter_id,
    };

    Ok(market_registration_event)
}

fn event_data_to_place_market_order_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<PlaceMarketOrderEvent> {
    let custodian_id = opt_value_to_big_decimal(event.data.get("custodian_id"))?;
    let order_id = opt_value_to_big_decimal(event.data.get("order_id"))?;
    let direction = event.data.get("direction").unwrap().as_bool().unwrap();
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let size = opt_value_to_big_decimal(event.data.get("size"))?;
    let self_match_behavior = opt_value_to_i16(event.data.get("self_match_behavior"))?;
    let user = strip_hex_number(opt_value_to_string(event.data.get("user"))?)?;
    let integrator = strip_hex_number(opt_value_to_string(event.data.get("integrator"))?)?;

    let place_market_order_event = PlaceMarketOrderEvent {
        txn_version,
        event_idx,
        market_id,
        time,
        user,
        custodian_id,
        order_id,
        direction,
        size,
        self_match_behavior,
        integrator,
    };

    Ok(place_market_order_event)
}

fn event_data_to_place_limit_order_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<PlaceLimitOrderEvent> {
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let user = strip_hex_number(opt_value_to_string(event.data.get("user"))?)?;
    let integrator = strip_hex_number(opt_value_to_string(event.data.get("integrator"))?)?;
    let custodian_id = opt_value_to_big_decimal(event.data.get("custodian_id"))?;
    let order_id = opt_value_to_big_decimal(event.data.get("order_id"))?;
    let side = opt_value_to_bool(event.data.get("side"))?;
    let restriction = opt_value_to_i16(event.data.get("restriction"))?;
    let self_match_behavior = opt_value_to_i16(event.data.get("self_match_behavior"))?;
    let price = opt_value_to_big_decimal(event.data.get("price"))?;
    let initial_size = opt_value_to_big_decimal(event.data.get("size"))?;
    let size = opt_value_to_big_decimal(event.data.get("remaining_size"))?;

    let place_limit_order_event = PlaceLimitOrderEvent {
        txn_version,
        event_idx,
        time,
        user,
        integrator,
        custodian_id,
        order_id,
        side,
        market_id,
        price,
        initial_size,
        size,
        restriction,
        self_match_behavior,
    };

    Ok(place_limit_order_event)
}

fn event_data_to_place_swap_order_event(
    event: &EventModel,
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
) -> anyhow::Result<PlaceSwapOrderEvent> {
    let market_id = opt_value_to_big_decimal(event.data.get("market_id"))?;
    let order_id = opt_value_to_big_decimal(event.data.get("order_id"))?;
    let direction = opt_value_to_bool(event.data.get("direction"))?;
    let integrator = strip_hex_number(opt_value_to_string(event.data.get("integrator"))?)?;
    let min_base = opt_value_to_big_decimal(event.data.get("min_base"))?;
    let max_base = opt_value_to_big_decimal(event.data.get("max_base"))?;
    let min_quote = opt_value_to_big_decimal(event.data.get("min_quote"))?;
    let max_quote = opt_value_to_big_decimal(event.data.get("max_quote"))?;
    let limit_price = opt_value_to_big_decimal(event.data.get("limit_price"))?;
    let signing_account =
        strip_hex_number(opt_value_to_string(event.data.get("signing_account"))?)?;

    let place_swap_order_event = PlaceSwapOrderEvent {
        txn_version,
        event_idx,
        time,
        integrator,
        order_id,
        market_id,
        min_base,
        max_base,
        min_quote,
        max_quote,
        direction,
        limit_price,
        signing_account,
    };

    Ok(place_swap_order_event)
}

pub async fn process_transactions(
    transactions: Vec<Transaction>,
    pool: ArcDbPool,
) -> anyhow::Result<()> {
    let mut conn = pool.get().await?;

    // Create a hashmap to store block_height to timestamp.
    let mut block_height_to_timestamp: HashMap<i64, DateTime<Utc>> = HashMap::new();
    let mut user_transactions = vec![];
    for txn in &transactions {
        let txn_version = txn.version as i64;
        let block_height = txn.block_height as i64;
        let txn_data = txn.txn_data.as_ref();
        if let Some(TxnData::User(_)) = txn_data {
            block_height_to_timestamp.insert(
                block_height,
                parse_timestamp(txn.timestamp.as_ref().unwrap(), txn_version)
            );
            user_transactions.push(txn);
        }
    }

    let econia_address = strip_hex_number(MODULE_ADDRESS.clone())?;
    let market_accounts_type_string = format!("{econia_address}::user::MarketAccounts");
    let market_account_type_string = format!("{econia_address}::user::MarketAccount");

    let cancel_order_type = format!("{}::user::CancelOrderEvent", econia_address);
    let change_order_size_type = format!("{}::user::ChangeOrderSizeEvent", econia_address);
    let fill_type = format!("{}::user::FillEvent", econia_address);
    let market_registration_type =
        format!("{}::registry::MarketRegistrationEvent", econia_address);
    let place_limit_order_type = format!("{}::user::PlaceLimitOrderEvent", econia_address);
    let place_market_order_type = format!("{}::user::PlaceMarketOrderEvent", econia_address);
    let place_swap_order_type = format!("{}::market::PlaceSwapOrderEvent", econia_address);
    let recognized_market_type = format!("{}::registry::RecognizedMarketEvent", econia_address);

    let mut balance_updates = vec![];
    let mut cancel_order_events = vec![];
    let mut change_order_size_events = vec![];
    let mut fill_events = vec![];
    let mut market_account_handles = vec![];
    let mut market_registration_events = vec![];
    let mut place_limit_order_events = vec![];
    let mut place_market_order_events = vec![];
    let mut place_swap_order_events = vec![];
    let mut recognized_market_events = vec![];

    for txn in user_transactions {
        let time = *block_height_to_timestamp
            .get(&txn.block_height.try_into().unwrap())
            .expect("No block time");
        let txn_version = txn.version as i64;
        let block_height = txn.block_height as i64;
        let txn_data = txn.txn_data.as_ref().expect("Txn Data doesn't exit!");
        let default = vec![];
        let raw_events = match txn_data {
            TxnData::BlockMetadata(tx_inner) => &tx_inner.events,
            TxnData::Genesis(tx_inner) => &tx_inner.events,
            TxnData::User(tx_inner) => &tx_inner.events,
            _ => &default,
        };
        let events = EventModel::from_events(raw_events, txn_version, block_height);
        for (index, event) in events.iter().enumerate() {
            let split = event.type_.split_once("::");
            let (address, tail) = if let Some(e) = split {
                e
            } else {
                continue;
            };
            let address = if let Ok(addr) = strip_hex_number(address.to_string()) {
                addr
            } else {
                continue;
            };
            let event_type = format!("{address}::{tail}");
            let txn_version = BigDecimal::from(txn.version);
            let event_idx = BigDecimal::from(index as u64);
            if event_type == recognized_market_type {
                recognized_market_events.push(event_data_to_recognized_market_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == cancel_order_type {
                cancel_order_events.push(event_data_to_cancel_order_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == change_order_size_type {
                change_order_size_events.push(event_data_to_change_order_size_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == fill_type {
                fill_events.push(event_data_to_fill_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == market_registration_type {
                market_registration_events.push(event_data_to_market_registration_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == place_limit_order_type {
                place_limit_order_events.push(event_data_to_place_limit_order_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == place_market_order_type {
                place_market_order_events.push(event_data_to_place_market_order_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            } else if event_type == place_swap_order_type {
                place_swap_order_events.push(event_data_to_place_swap_order_event(
                    event,
                    txn_version,
                    event_idx,
                    time,
                )?);
            }
        }
        // Index transaction write set.
        let info = &txn.info.as_ref().expect("No transaction info");
        for change in &info.changes {
            match change.change.as_ref().expect("No transaction changes") {
                Change::WriteResource(resource) => {
                    let resource_type = resource.r#type.as_ref().expect("No resource type");
                    if let Ok(address) = strip_hex_number(resource_type.address.to_string()) {
                        let resource_type = format!(
                            "{address}::{}::{}",
                            resource_type.module, resource_type.name
                        );
                        if resource_type == market_accounts_type_string {
                            let data: serde_json::Value = serde_json::from_str(&resource.data)
                                .expect("Failed to parse MarketAccounts");
                            let map_field = data.get("map").expect("No map field");
                            market_account_handles.push(MarketAccountHandle {
                                user: strip_hex_number(resource.address.clone())?,
                                handle: strip_hex_number(opt_value_to_string(map_field.get("handle"))?)?,
                                creation_time: time,
                            })
                        }
                    }
                },
                Change::WriteTableItem(write) => {
                    let table_data = write.data.as_ref().expect("No WriteTableItem data");
                    let split = table_data.value_type.split_once("::");
                    let (address, tail) = if let Some(e) = split {
                        e
                    } else {
                        continue;
                    };
                    if let Ok(address) = strip_hex_number(address.to_string()) {
                        let value_type = format!("{address}::{tail}");
                        if value_type != market_account_type_string {
                            continue;
                        }
                        let table_key: serde_json::Value =
                            serde_json::from_str(&table_data.key)
                                .expect("Failed to parse market account ID to JSON");
                        let market_account_id = u128::from_str(
                            &table_key
                                .as_str()
                                .expect("Failed to parse market account ID to string"),
                        )
                        .expect("Failed to parse market account ID to u128");
                        let data: serde_json::Value = serde_json::from_str(&table_data.value)
                            .expect("Failed to parse MarketAccount");
                        balance_updates.push(BalanceUpdate {
                            txn_version: txn_version.into(),
                            handle: strip_hex_number(write.handle.to_string())?,
                            market_id: ((market_account_id >> SHIFT_MARKET_ID) as u64).into(),
                            custodian_id: ((market_account_id & HI_64) as u64).into(),
                            time,
                            base_total: opt_value_to_big_decimal(data.get("base_total"))?,
                            base_available: opt_value_to_big_decimal(
                                data.get("base_available"),
                            )?,
                            base_ceiling: opt_value_to_big_decimal(data.get("base_ceiling"))?,
                            quote_total: opt_value_to_big_decimal(data.get("quote_total"))?,
                            quote_available: opt_value_to_big_decimal(
                                data.get("quote_available"),
                            )?,
                            quote_ceiling: opt_value_to_big_decimal(data.get("quote_ceiling"))?,
                        })
                    }
                },
                _ => continue,
            }
        }
    }

    // Insert to the database all events and write sets.
    let mut t = conn.build_transaction().serializable();
    for i in 0..MAX_TRANSACTION_RETRIES {
        let balance_updates = balance_updates.clone();
        let cancel_order_events = cancel_order_events.clone();
        let change_order_size_events = change_order_size_events.clone();
        let fill_events = fill_events.clone();
        let market_account_handles = market_account_handles.clone();
        let market_registration_events = market_registration_events.clone();
        let place_limit_order_events = place_limit_order_events.clone();
        let place_market_order_events = place_market_order_events.clone();
        let place_swap_order_events = place_swap_order_events.clone();
        let recognized_market_events = recognized_market_events.clone();
        if t.run::<_, Error, _>(|pg_conn| {
            async move {
                insert_balance_updates(pg_conn, balance_updates).await?;
                insert_cancel_order_events(pg_conn, cancel_order_events).await?;
                insert_change_order_size_events(pg_conn, change_order_size_events).await?;
                insert_fill_events(pg_conn, fill_events).await?;
                insert_market_account_handles(pg_conn, market_account_handles).await?;
                insert_market_registration_events(pg_conn, market_registration_events).await?;
                insert_place_limit_order_events(pg_conn, place_limit_order_events).await?;
                insert_place_market_order_events(pg_conn, place_market_order_events).await?;
                insert_place_swap_order_events(pg_conn, place_swap_order_events).await?;
                insert_recognized_market_events(pg_conn, recognized_market_events).await?;
                Ok(())
            }
            .scope_boxed()
        }).await
        .is_ok()
        {
            break;
        }
        tracing::warn!(
            "transaction error, retrying... (retries left: {})",
            MAX_TRANSACTION_RETRIES - i - 1
        );
        if i == MAX_TRANSACTION_RETRIES - 1 {
            return Err(anyhow!("could not run transaction, quitting"));
        }
    }

    Ok(())

    //Ok(ProcessingResult::DefaultProcessingResult(DefaultProcessingResult {
    //    start_version,
    //    end_version,
    //    last_transaction_timestamp: transactions.last().map(|e| e.timestamp.clone()).flatten(),
    //    processing_duration_in_secs: time_delta.num_milliseconds() as f64 / 1000f64,
    //    db_insertion_duration_in_secs: db_time_delta.num_milliseconds() as f64 / 1000f64,
    //}))
}
