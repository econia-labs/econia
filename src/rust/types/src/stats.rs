#[cfg(feature = "serde")]
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct Stats {
    pub market_id: u64,
    pub open: u64,
    pub high: u64,
    pub low: u64,
    pub close: u64,
    pub change: f64,
    pub volume: u64,
}
