use std::{collections::HashSet, time::Duration};

use anyhow::Result;
use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use rumqttc::{AsyncClient, MqttOptions, QoS, Transport};
use serde::{Deserialize, Serialize};
use sqlx_postgres::PgListener;

#[derive(Serialize, Deserialize)]
struct PlaceLimitOrderNotif {
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
    market_id: BigDecimal,
    user: String,
    custodian_id: BigDecimal,
    order_id: BigDecimal,
    side: bool,
    integrator: String,
    initial_size: BigDecimal,
    price: BigDecimal,
    restriction: i16,
    self_match_behavior: i16,
    size: BigDecimal,
}
#[derive(Serialize, Deserialize)]
struct PlaceMarketOrderNotif {
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
    market_id: BigDecimal,
    user: String,
    custodian_id: BigDecimal,
    order_id: BigDecimal,
    direction: bool,
    integrator: String,
    self_match_behavior: i16,
    size: BigDecimal,
}
#[derive(Serialize, Deserialize)]
struct PlaceSwapOrderNotif {
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
    market_id: BigDecimal,
    order_id: BigDecimal,
    direction: bool,
    signing_account: String,
    integrator: String,
    min_base: BigDecimal,
    max_base: BigDecimal,
    min_quote: BigDecimal,
    max_quote: BigDecimal,
    limit_price: BigDecimal,
}
#[derive(Serialize, Deserialize)]
struct ChangeOrderSizeNotif {
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
    market_id: BigDecimal,
    user: String,
    custodian_id: BigDecimal,
    order_id: BigDecimal,
    side: bool,
    new_size: BigDecimal,
}
#[derive(Serialize, Deserialize)]
struct CancelOrderNotif {
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    time: DateTime<Utc>,
    market_id: BigDecimal,
    user: String,
    custodian_id: BigDecimal,
    order_id: BigDecimal,
    reason: i16,
}
#[derive(Serialize, Deserialize)]
struct FillNotif {
    txn_version: BigDecimal,
    event_idx: BigDecimal,
    emit_address: String,
    time: DateTime<Utc>,
    maker_address: String,
    maker_custodian_id: BigDecimal,
    maker_order_id: BigDecimal,
    maker_side: bool,
    market_id: BigDecimal,
    price: BigDecimal,
    sequence_number_for_trade: BigDecimal,
    size: BigDecimal,
    taker_address: String,
    taker_custodian_id: BigDecimal,
    taker_order_id: BigDecimal,
    taker_quote_fees_paid: BigDecimal,
}

#[tokio::main]
async fn main() -> Result<()> {
    let mut emitted_fills: HashSet<(
        BigDecimal,
        String,
        BigDecimal,
        String,
        BigDecimal,
        BigDecimal,
    )> = Default::default();
    let mqtt_url = std::env::var("MQTT_URL")?;
    let db_url = std::env::var("DATABASE_URL")?;

    let mut mqttoptions = MqttOptions::parse_url(mqtt_url).unwrap();
    mqttoptions.set_transport(Transport::Tcp);
    mqttoptions.set_keep_alive(Duration::from_secs(5));
    let (client, mut eventloop) = AsyncClient::new(mqttoptions, 10);

    let mut listener = PgListener::connect(&db_url).await?;

    let channels = vec![
        "place_limit_order",
        "place_market_order",
        "place_swap_order",
        "change_order_size",
        "cancel_order",
        "fill",
    ];

    listener.listen_all(channels).await?;

    tokio::task::spawn(async move {
        loop {
            eventloop.poll().await.unwrap();
        }
    });

    loop {
        let notification = listener.recv().await?;
        match notification.channel() {
            "place_limit_order" => {
                let data: PlaceLimitOrderNotif = serde_json::from_str(notification.payload())?;
                client
                    .publish(
                        format!(
                            "place_limit_order/{}/{}/{}/{}",
                            data.market_id, data.user, data.custodian_id, data.integrator
                        ),
                        QoS::AtLeastOnce,
                        false,
                        serde_json::to_string(&data)?,
                    )
                    .await?;
            }
            "place_market_order" => {
                let data: PlaceMarketOrderNotif = serde_json::from_str(notification.payload())?;
                client
                    .publish(
                        format!(
                            "place_market_order/{}/{}/{}/{}",
                            data.market_id, data.user, data.custodian_id, data.integrator
                        ),
                        QoS::AtLeastOnce,
                        false,
                        serde_json::to_string(&data)?,
                    )
                    .await?;
            }
            "place_swap_order" => {
                let data: PlaceSwapOrderNotif = serde_json::from_str(notification.payload())?;
                client
                    .publish(
                        format!(
                            "place_swap_order/{}/{}/{}",
                            data.market_id, data.integrator, data.signing_account
                        ),
                        QoS::AtLeastOnce,
                        false,
                        serde_json::to_string(&data)?,
                    )
                    .await?;
            }
            "change_order_size" => {
                let data: ChangeOrderSizeNotif = serde_json::from_str(notification.payload())?;
                client
                    .publish(
                        format!(
                            "change_order_size/{}/{}/{}",
                            data.market_id, data.user, data.custodian_id
                        ),
                        QoS::AtLeastOnce,
                        false,
                        serde_json::to_string(&data)?,
                    )
                    .await?;
            }
            "cancel_order" => {
                let data: CancelOrderNotif = serde_json::from_str(notification.payload())?;
                client
                    .publish(
                        format!(
                            "cancel_order/{}/{}/{}",
                            data.market_id, data.user, data.custodian_id
                        ),
                        QoS::AtLeastOnce,
                        false,
                        serde_json::to_string(&data)?,
                    )
                    .await?;
            }
            "fill" => {
                let data: FillNotif = serde_json::from_str(notification.payload())?;
                if !emitted_fills.remove(&(
                    data.market_id.clone(),
                    data.maker_address.clone(),
                    data.maker_custodian_id.clone(),
                    data.taker_address.clone(),
                    data.taker_custodian_id.clone(),
                    data.sequence_number_for_trade.clone(),
                )) {
                    client
                        .publish(
                            format!(
                                "fill/{}/{}/{}",
                                data.market_id, data.maker_address, data.maker_custodian_id
                            ),
                            QoS::AtLeastOnce,
                            false,
                            serde_json::to_string(&data)?,
                        )
                        .await?;
                    client
                        .publish(
                            format!(
                                "fill/{}/{}/{}",
                                data.market_id, data.taker_address, data.taker_custodian_id
                            ),
                            QoS::AtLeastOnce,
                            false,
                            serde_json::to_string(&data)?,
                        )
                        .await?;
                    emitted_fills.insert((
                        data.market_id,
                        data.maker_address,
                        data.maker_custodian_id,
                        data.taker_address,
                        data.taker_custodian_id,
                        data.sequence_number_for_trade,
                    ));
                }
            }
            _ => {}
        }
    }
}
