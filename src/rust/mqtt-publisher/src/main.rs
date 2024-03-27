use std::{collections::HashSet, time::Duration};

use anyhow::Result;
use chrono::{DateTime, Utc};
use rumqttc::{AsyncClient, MqttOptions, QoS, Transport};
use serde::{Deserialize, Serialize};
use sqlx_postgres::PgListener;

#[derive(Serialize, Deserialize)]
struct PlaceLimitOrderNotif {
    txn_version: u128,
    event_idx: u128,
    time: DateTime<Utc>,
    market_id: u128,
    user: String,
    custodian_id: u128,
    order_id: u128,
    side: bool,
    integrator: String,
    initial_size: u128,
    price: u128,
    restriction: i16,
    self_match_behavior: i16,
    size: u128,
}
#[derive(Serialize, Deserialize)]
struct PlaceMarketOrderNotif {
    txn_version: u128,
    event_idx: u128,
    time: DateTime<Utc>,
    market_id: u128,
    user: String,
    custodian_id: u128,
    order_id: u128,
    direction: bool,
    integrator: String,
    self_match_behavior: i16,
    size: u128,
}
#[derive(Serialize, Deserialize)]
struct PlaceSwapOrderNotif {
    txn_version: u128,
    event_idx: u128,
    time: DateTime<Utc>,
    market_id: u128,
    order_id: u128,
    direction: bool,
    signing_account: String,
    integrator: String,
    min_base: u128,
    max_base: u128,
    min_quote: u128,
    max_quote: u128,
    limit_price: u128,
}
#[derive(Serialize, Deserialize)]
struct ChangeOrderSizeNotif {
    txn_version: u128,
    event_idx: u128,
    time: DateTime<Utc>,
    market_id: u128,
    user: String,
    custodian_id: u128,
    order_id: u128,
    side: bool,
    new_size: u128,
}
#[derive(Serialize, Deserialize)]
struct CancelOrderNotif {
    txn_version: u128,
    event_idx: u128,
    time: DateTime<Utc>,
    market_id: u128,
    user: String,
    custodian_id: u128,
    order_id: u128,
    reason: i16,
}
#[derive(Serialize, Deserialize)]
struct FillNotif {
    txn_version: u128,
    event_idx: u128,
    emit_address: String,
    time: DateTime<Utc>,
    maker_address: String,
    maker_custodian_id: u128,
    maker_order_id: u128,
    maker_side: bool,
    market_id: u128,
    price: u128,
    sequence_number_for_trade: u128,
    size: u128,
    taker_address: String,
    taker_custodian_id: u128,
    taker_order_id: u128,
    taker_quote_fees_paid: u128,
}

#[tokio::main]
async fn main() -> Result<()> {
    let mut emitted_fills: HashSet<(
        u128,
        u128,
        u128,
    )> = Default::default();
    let mqtt_url = std::env::var("MQTT_URL")?;
    let mqtt_password = std::env::var("MQTT_PASSWORD")?;
    let db_url = std::env::var("DATABASE_URL")?;

    let mut mqttoptions = MqttOptions::parse_url(format!("{mqtt_url}/?client_id=mqtt_publisher")).unwrap();
    mqttoptions.set_credentials("mqtt_publisher", mqtt_password);
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
                    data.taker_order_id.clone(),
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
                        data.taker_order_id,
                        data.sequence_number_for_trade,
                    ));
                }
            }
            _ => {}
        }
    }
}
