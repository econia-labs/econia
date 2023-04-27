use std::fmt;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Bar {
    pub start_time: DateTime<Utc>,
    pub open: u64,
    pub high: u64,
    pub low: u64,
    pub close: u64,
    pub volume: u64,
}

#[derive(Clone, Copy, Debug, Serialize, Deserialize)]
pub enum Resolution {
    #[serde(rename = "1m")]
    R1m,
    #[serde(rename = "5m")]
    R5m,
    #[serde(rename = "15m")]
    R15m,
    #[serde(rename = "30m")]
    R30m,
    #[serde(rename = "1h")]
    R1h,
}

impl fmt::Display for Resolution {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let s = match self {
            Self::R1m => "1m",
            Self::R5m => "5m",
            Self::R15m => "15m",
            Self::R30m => "30m",
            Self::R1h => "1h",
        };
        write!(f, "{}", s)
    }
}
