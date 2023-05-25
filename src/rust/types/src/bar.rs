use std::fmt;

use chrono::{DateTime, Duration, Utc};
#[cfg(feature = "serde")]
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct Bar {
    pub start_time: DateTime<Utc>,
    pub open: u64,
    pub high: u64,
    pub low: u64,
    pub close: u64,
    pub volume: u64,
}

#[derive(Clone, Debug)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub enum Resolution {
    #[cfg_attr(feature = "serde", serde(rename = "1m"))]
    R1m,
    #[cfg_attr(feature = "serde", serde(rename = "5m"))]
    R5m,
    #[cfg_attr(feature = "serde", serde(rename = "15m"))]
    R15m,
    #[cfg_attr(feature = "serde", serde(rename = "30m"))]
    R30m,
    #[cfg_attr(feature = "serde", serde(rename = "1h"))]
    R1h,
    #[cfg_attr(feature = "serde", serde(rename = "4h"))]
    R4h,
    #[cfg_attr(feature = "serde", serde(rename = "12h"))]
    R12h,
    #[cfg_attr(feature = "serde", serde(rename = "1d"))]
    R1d,
}

impl fmt::Display for Resolution {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let s = match self {
            Self::R1m => "1m",
            Self::R5m => "5m",
            Self::R15m => "15m",
            Self::R30m => "30m",
            Self::R1h => "1h",
            Self::R4h => "4h",
            Self::R12h => "12h",
            Self::R1d => "1d",
        };
        write!(f, "{}", s)
    }
}

impl From<Resolution> for Duration {
    fn from(value: Resolution) -> Self {
        match value {
            Resolution::R1m => Duration::minutes(1),
            Resolution::R5m => Duration::minutes(5),
            Resolution::R15m => Duration::minutes(15),
            Resolution::R30m => Duration::minutes(30),
            Resolution::R1h => Duration::hours(1),
            Resolution::R4h => Duration::hours(4),
            Resolution::R12h => Duration::hours(12),
            Resolution::R1d => Duration::days(1),
        }
    }
}
