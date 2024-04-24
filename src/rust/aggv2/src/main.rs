use bigdecimal::BigDecimal;
use chrono::{Utc, DateTime};
use numeric::{BlockStamp, OrderId, TransactionVersion, EventIndex};

mod feed;
mod numeric;

use numeric::*;

#[derive(Clone, Debug)]
pub enum Event {
    BalanceUpdatesByHandle {
        txn_version: TransactionVersion,
        market_id: MarketId,
        custodian_id: BigDecimal,
        time: DateTime<Utc>,
        base_total: BaseSubunit,
        base_available: BaseSubunit,
        base_ceiling: BaseSubunit,
        quote_total: QuoteSubunit,
        quote_available: QuoteSubunit,
        quote_ceiling: QuoteSubunit,
    },
    MarketRegistration {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        market_id: MarketId,
        time: DateTime<Utc>,
        base_account_address: Option<String>,
        base_module_name: Option<String>,
        base_struct_name: Option<String>,
        base_name_generic: Option<String>,
        quote_account_address: String,
        quote_module_name: String,
        quote_struct_name: String,
        lot_size: BigDecimal,
        tick_size: BigDecimal,
        min_size: Lot,
        underwriter_id: BigDecimal,
    },
    MarketRecognition {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        market_id: MarketId,
        time: DateTime<Utc>,
        base_account_address: Option<String>,
        base_module_name: Option<String>,
        base_struct_name: Option<String>,
        base_name_generic: Option<String>,
        quote_account_address: String,
        quote_module_name: String,
        quote_struct_name: String,
        lot_size: BigDecimal,
        tick_size: BigDecimal,
        min_size: Lot,
        underwriter_id: BigDecimal,
    },
    PlaceLimitOrder {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        time: DateTime<Utc>,
        market_id: MarketId,
        user: String,
        custodian_id: BigDecimal,
        order_id: OrderId,
        side: Direction,
        integrator: String,
        initial_size: Lot,
        price: Price,
        restriction: i16,
        self_match_behavior: i16,
        size: Lot,
    },
    PlaceMarketOrder {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        time: DateTime<Utc>,
        market_id: MarketId,
        user: String,
        custodian_id: BigDecimal,
        order_id: OrderId,
        direction: Direction,
        integrator: String,
        self_match_behavior: i16,
        size: Lot,
    },
    PlaceSwapOrder {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        time: DateTime<Utc>,
        market_id: MarketId,
        order_id: OrderId,
        direction: Direction,
        signing_account: String,
        integrator: String,
        min_base: BigDecimal,
        max_base: BigDecimal,
        min_quote: BigDecimal,
        max_quote: BigDecimal,
        limit_price: Price,
    },
    Fill {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        emit_address: String,
        time: DateTime<Utc>,
        maker_address: String,
        maker_custodian_id: BigDecimal,
        maker_order_id: OrderId,
        maker_side: Direction,
        market_id: MarketId,
        price: Price,
        sequence_number_for_trade: BigDecimal,
        size: Lot,
        taker_address: String,
        taker_custodian_id: BigDecimal,
        taker_order_id: OrderId,
        taker_quote_fees_paid: BigDecimal,
    },
    Cancel {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        time: DateTime<Utc>,
        market_id: MarketId,
        user: String,
        custodian_id: BigDecimal,
        order_id: OrderId,
        reason: i16,
    },
    ChangeSize {
        txn_version: TransactionVersion,
        event_idx: EventIndex,
        time: DateTime<Utc>,
        market_id: MarketId,
        user: String,
        custodian_id: BigDecimal,
        order_id: OrderId,
        side: Direction,
        new_size: Lot,
    },
}

impl Event {
    pub fn blockstamp(&self) -> BlockStamp {
        match self.clone() {
            Event::MarketRegistration { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::PlaceLimitOrder { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::PlaceMarketOrder { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::PlaceSwapOrder { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::Fill { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::Cancel { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::ChangeSize { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            },
            Event::BalanceUpdatesByHandle { txn_version, .. } => {
                BlockStamp::from_raw_parts(txn_version, EventIndex::new(0))
            },
            Event::MarketRecognition { txn_version, event_idx, .. } => {
                BlockStamp::from_raw_parts(txn_version, event_idx)
            }
        }
    }
}

#[derive(Clone, Debug)]
pub enum Direction {
    Ask,
    Bid,
}

impl From<bool> for Direction {
    fn from(value: bool) -> Self {
        if value {
            Self::Ask
        } else {
            Self::Bid
        }
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter("aggv2=TRACE")
        .init();
    feed::run().await?;
    Ok(())
}
