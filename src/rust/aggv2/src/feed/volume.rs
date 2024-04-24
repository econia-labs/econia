use std::collections::HashMap;

use chrono::{DateTime, Utc};
use sqlx::Transaction;
use sqlx_postgres::{PgPool, Postgres, PgConnection};

use crate::{numeric::*, Event};

use super::{FeedFromEventsAndPrevState, InsertableFeed};

#[derive(Debug, Clone)]
pub struct Volume {
    markets: HashMap<MarketId, MarketVolume>,
}

#[derive(Clone, Debug)]
pub struct MarketVolume {
    pub cumulative: Tick,
    pub period: Tick,
}

impl FeedFromEventsAndPrevState for Volume {
    fn update<'a>(&mut self, events: impl Iterator<Item = &'a Event>) {
        for prev_vol in self.markets.iter_mut() {
            prev_vol.1.period = Tick::new(0);
        }
        for event in events {
            match event {
                Event::MarketRegistration { market_id, .. } => {
                    self.markets.insert(MarketId::from(market_id.clone()), MarketVolume {
                        cumulative: Tick::new(0),
                        period: Tick::new(0),
                    });
                }
                Event::Fill { size, price, market_id, .. } => {
                    let market_volume = self.markets.get_mut(&MarketId::from(market_id.clone())).unwrap();
                    market_volume.cumulative += size * price;
                    market_volume.period += size * price;
                },
                _ => {}
            }
        }
    }

    async fn get_prev_state(pool: &PgPool) -> Self {
        let r = sqlx::query!(
            r#"SELECT DISTINCT ON (market_id) * FROM aggv2.volume ORDER BY market_id, "time" DESC"#
        ).fetch_all(pool)
        .await.unwrap();
        let mut volume = Volume {
            markets: Default::default()
        };
        for row in r {
            let market = volume.markets.entry(MarketId::new(row.market_id)).or_insert(MarketVolume {
                cumulative: Tick::new(0),
                period: Tick::new(0),
            });
            market.cumulative = Tick::new(row.cumulative);
            market.period = Tick::new(row.period);
        }
        volume
    }
}

impl InsertableFeed for Volume {
    async fn save<'a>(&self, timestamp: DateTime<Utc>, transaction: &mut Transaction<'a, Postgres>) {
        for (key, value) in &self.markets {
            sqlx::query!(
                "INSERT INTO aggv2.volume VALUES ($1, $2, $3, $4)",
                timestamp,
                key.clone().inner(),
                value.clone().cumulative.inner(),
                value.clone().period.inner()
            ).execute(transaction as &mut PgConnection)
            .await.unwrap();
        }
    }
}
