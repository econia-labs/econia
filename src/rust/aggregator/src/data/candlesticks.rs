use std::time::{Duration, Instant};

pub struct CandleSticks {
    interval: Duration,
    market_id: u64,
    last_index_timestamp: Option<Instant>,
}
