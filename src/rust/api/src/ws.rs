use std::{
    collections::HashSet,
    net::SocketAddr,
    sync::{Arc, Mutex},
    time::Duration,
};

use axum::{
    extract::{
        ws::{Message, WebSocket},
        ConnectInfo, State, WebSocketUpgrade,
    },
    response::IntoResponse,
};
use chrono::{DateTime, Utc};
use futures_util::{
    stream::{SplitSink, SplitStream},
    SinkExt, StreamExt,
};
use regex::Regex;
use tokio::sync::{broadcast, mpsc};
use types::message::{Channel, ConfirmMethod, InboundMessage, OutboundMessage, Update};

use crate::{error::WebSocketError, AppState};

/// The maximum time allowed since the last ping message is set to 1 hour.
/// If it has been over an hour since the last ping message was received, the
/// WebSocket connection is terminated.
static PING_ELAPSED_TIME_LIMIT: Duration = Duration::from_secs(3600);

/// The interval for checking that the time elapsed since the last ping has not
/// exceeded the limit. Set to every 10 minutes.
static PING_CHECK_INTERVAL: Duration = Duration::from_secs(600);

/// Handler for WebSocket handshake request.
pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<AppState>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> impl IntoResponse {
    tracing::info!("new websocket connection with client {}", addr);
    ws.on_upgrade(move |ws| handle_socket(ws, state.sender, state.market_ids, addr))
}

/// Checks whether the message received from the broadcast channel belongs to a
/// channel that the client has subscribed to, and then sends the messages to an
/// mpsc channel to be forwarded to the WebSocket client if it does.
///
/// # Arguments
///
/// * `brx` - a broadcast receiver which receives updates from the indexer via redis pubsub.
/// * `tx` - an mpsc channel for sending messages that should be passed on to the client.
/// * `subs` - a hashset containing the channels that the client is subscribed to.
async fn outbound_message_handler(
    mut brx: broadcast::Receiver<Update>,
    tx: mpsc::Sender<OutboundMessage>,
    subs: Arc<Mutex<HashSet<Channel>>>,
) -> Result<(), WebSocketError> {
    while let Ok(update) = brx.recv().await {
        let subbed = match update {
            Update::Orders(ref order) => {
                let ch = Channel::Orders {
                    market_id: order.market_id,
                    user_address: order.user_address.clone(),
                };
                let lock = subs.lock().unwrap();
                (*lock).contains(&ch)
            }
            Update::Fills(ref fill) => {
                let ch = Channel::Fills {
                    market_id: fill.market_id,
                    user_address: fill.maker.clone(),
                };
                let lock = subs.lock().unwrap();
                (*lock).contains(&ch)
            }
            Update::PriceLevels(ref price_level) => {
                let ch = Channel::PriceLevel {
                    market_id: price_level.market_id,
                };
                let lock = subs.lock().unwrap();
                (*lock).contains(&ch)
            }
        };
        if subbed {
            let msg = OutboundMessage::Update(update);
            tx.send(msg).await?;
        }
    }
    Ok(())
}

/// Given an inbound message received from the WebSocket client and the current
/// client state, returns a response message and updates the client state.
///
/// This function serves to both declutter the inbound message handler, and also
/// enforces the rule that every client message should have a response from the
/// WebSocket API.
///
/// # Arguments
///
/// * `msg_i` - inbound message received from WebSocket client.
/// * `subs` - mutex containing a hashset storing all the channels the client is subscribed to.
/// * `market_ids` - hashset containing the ids of every available market.
/// * `last_ping` - a mutex containing the date and time at which the last ping message was received.
/// * `who` - client address.
fn get_response_message(
    msg_i: InboundMessage,
    subs: &Mutex<HashSet<Channel>>,
    market_ids: &HashSet<u64>,
    last_ping: &Mutex<DateTime<Utc>>,
    who: SocketAddr,
) -> Result<OutboundMessage, WebSocketError> {
    match msg_i {
        InboundMessage::Ping => {
            let now = Utc::now();
            tracing::info!(
                "updated last ping received time for client {} to {}",
                who,
                now
            );
            let mut lock = last_ping.lock().unwrap();
            (*lock) = now;
            Ok(OutboundMessage::Pong)
        }
        InboundMessage::Subscribe(channel) => {
            let subbed = {
                let mut lock = subs.lock().unwrap();
                let b = (*lock).contains(&channel);
                if !b {
                    (*lock).insert(channel.clone());
                }
                b
            };
            if subbed {
                let s = serde_json::to_string(&channel)?;
                Ok(OutboundMessage::Error {
                    message: format!("already subscribed to channel `{}`", s),
                })
            } else {
                match channel {
                    Channel::Orders {
                        ref market_id,
                        user_address: _,
                    } => {
                        if !market_ids.contains(market_id) {
                            return Ok(OutboundMessage::Error {
                                message: format!("market with id `{}` not found", market_id),
                            });
                        }
                    }
                    Channel::Fills {
                        ref market_id,
                        user_address: _,
                    } => {
                        if !market_ids.contains(market_id) {
                            return Ok(OutboundMessage::Error {
                                message: format!("market with id `{}` not found", market_id),
                            });
                        }
                    }
                    _ => {}
                }
                Ok(OutboundMessage::Confirm {
                    channel,
                    method: ConfirmMethod::Subscribe,
                })
            }
        }
        InboundMessage::Unsubscribe(channel) => {
            let subbed = {
                let mut lock = subs.lock().unwrap();
                let b = (*lock).contains(&channel);
                if b {
                    (*lock).remove(&channel);
                }
                b
            };
            if !subbed {
                let s = serde_json::to_string(&channel)?;
                Ok(OutboundMessage::Error {
                    message: format!("not subscribed to channel `{}`", s),
                })
            } else {
                Ok(OutboundMessage::Confirm {
                    channel,
                    method: ConfirmMethod::Unsubscribe,
                })
            }
        }
    }
}

/// Reads messages received from the WebSocket client, updates the client state
/// according to any ping, subscribe, or unsubscribe messages it receives, and
/// sends a response message to an mpsc sender to be forwarded to the client.
///
/// # Arguments
///
/// * `receiver` - stream of messages from the client.
/// * `tx` - mpsc sender to send messages to be forwarded to the client.
/// * `subs`- mutex containing a hashset storing all the channels the client is subscribed to.
/// * `last_ping` - a mutex containing the date and time at which the last ping message was received.
/// * `who` - client address.
async fn inbound_message_handler(
    mut receiver: SplitStream<WebSocket>,
    tx: mpsc::Sender<OutboundMessage>,
    subs: Arc<Mutex<HashSet<Channel>>>,
    market_ids: HashSet<u64>,
    last_ping: Arc<Mutex<DateTime<Utc>>>,
    who: SocketAddr,
) -> Result<(), WebSocketError> {
    // define regex to remove line breaks and whitespace
    let re = Regex::new(r"\n|\s+").unwrap();
    while let Some(Ok(msg)) = receiver.next().await {
        match msg {
            Message::Text(s) => {
                tracing::info!(
                    "received message from client {}: {}",
                    who,
                    re.replace_all(&s, ""),
                );
                match serde_json::from_str::<InboundMessage>(&s) {
                    Ok(msg_i) => {
                        let msg_o =
                            get_response_message(msg_i, &subs, &market_ids, &last_ping, who)?;
                        tx.send(msg_o).await?;
                    }
                    Err(e) => {
                        tracing::warn!(
                            "could not parse message `{}` received from client {}: {}",
                            re.replace_all(&s, ""),
                            who,
                            e
                        );
                        // remove `at position` text from serde error messages,
                        // since it is not useful information for websocket clients.
                        let e_msg = if let Some(m) = e.to_string().split(" at ").next() {
                            m.to_string()
                        } else {
                            "could not parse message".to_string()
                        };
                        let msg_o = OutboundMessage::Error { message: e_msg };
                        tx.send(msg_o).await?;
                    }
                }
            }
            Message::Close(c) => {
                if let Some(cf) = c {
                    tracing::info!("client {} sent close message with code {}", who, cf.code);
                } else {
                    tracing::info!("client {} sent close message without CloseFrame", who);
                }
                return Ok(());
            }
            _ => {
                // TODO
            }
        }
    }
    Ok(())
}

/// Checks the time at which the client last sent a ping message at a regular
/// interval, and sends a message indicating that too much time has passed since
/// the last ping message and closes the WebSocket connection if too much time
/// has passed.
///
/// # Arguments
///
/// * `tx` - mpsc sender to send messages to be forwarded to the client.
/// * `last_ping` - a mutex containing the date and time at which the last ping message was received.
/// * `who` - client address.
async fn ping_check_handler(
    tx: mpsc::Sender<OutboundMessage>,
    last_ping: Arc<Mutex<DateTime<Utc>>>,
    who: SocketAddr,
) -> Result<(), WebSocketError> {
    let mut interval = tokio::time::interval(PING_CHECK_INTERVAL);
    loop {
        interval.tick().await;

        let too_much_time_elapsed = {
            let last_ping_time = last_ping.lock().unwrap();
            let elapsed_time = Utc::now() - *last_ping_time;
            elapsed_time > chrono::Duration::from_std(PING_ELAPSED_TIME_LIMIT).unwrap()
        };

        if too_much_time_elapsed {
            tracing::info!(
                "more than 1 hour elapsed since last ping from client {}",
                who
            );
            tx.send(OutboundMessage::Error {
                message: "more than 1 hour elapsed since last ping; closing connection".to_string(),
            })
            .await?;
            tokio::time::sleep(std::time::Duration::from_millis(100)).await;
            return Ok(());
        }
    }
}

/// Forwards messages from the mpsc receiver to the WebSocket client.
///
/// # Arguments
///
/// * `sender` - sink to send messages to websocket client
/// * `rx` - mpsc receiver for receiving messages forwarded from the outbound, inbound, and ping check handlers.
/// * `who` - client address.
async fn forward_message_handler(
    mut sender: SplitSink<WebSocket, Message>,
    mut rx: mpsc::Receiver<OutboundMessage>,
    who: SocketAddr,
) -> Result<(), WebSocketError> {
    while let Some(msg) = rx.recv().await {
        let s = serde_json::to_string(&msg)?;
        tracing::info!("sending message `{}` to client {}", s, who);
        sender.send(Message::Text(s)).await?;
    }
    Ok(())
}

/// WebSocket connection handler.
async fn handle_socket(
    ws: WebSocket,
    btx: broadcast::Sender<Update>,
    market_ids: HashSet<u64>,
    who: SocketAddr,
) {
    let (sender, receiver) = ws.split();
    let brx = btx.subscribe();
    let (mtx, mrx) = mpsc::channel(16);
    let subs = Arc::new(Mutex::new(HashSet::<Channel>::new()));
    let last_ping = Arc::new(Mutex::new(Utc::now()));

    let mut fwd_task = tokio::spawn(async move {
        if let Err(e) = forward_message_handler(sender, mrx, who).await {
            tracing::error!(
                "websocket connection with client {} failed on message forward task: {}",
                who,
                e
            );
        }
    });

    let mtx1 = mtx.clone();
    let subs1 = subs.clone();
    let mut send_task = tokio::spawn(async move {
        if let Err(e) = outbound_message_handler(brx, mtx1, subs1).await {
            tracing::error!(
                "websocket connection with client {} failed on outbound message handler: {}",
                who,
                e
            );
        }
    });

    let mtx2 = mtx.clone();
    let last_ping1 = last_ping.clone();
    let mut recv_task = tokio::spawn(async move {
        if let Err(e) =
            inbound_message_handler(receiver, mtx2, subs, market_ids, last_ping1, who).await
        {
            tracing::error!(
                "websocket connection with client {} failed on inbound message handler: {}",
                who,
                e
            );
        }
    });

    let mut ping_check_task = tokio::spawn(async move {
        if let Err(e) = ping_check_handler(mtx, last_ping, who).await {
            tracing::error!(
                "websocket connection with client {} failed on ping check handler: {}",
                who,
                e
            );
        }
    });

    // if one of these tasks end, abort the others
    tokio::select! {
        _ = &mut send_task => {
            fwd_task.abort();
            recv_task.abort();
            ping_check_task.abort();
        }
        _ = &mut recv_task => {
            fwd_task.abort();
            send_task.abort();
            ping_check_task.abort();
        }
        _ = &mut fwd_task => {
            recv_task.abort();
            send_task.abort();
            ping_check_task.abort();
        }
        _ = &mut ping_check_task => {
            fwd_task.abort();
            recv_task.abort();
            send_task.abort();
        }
    }

    tracing::info!("websocket context for client {} destroyed", who);
}

#[cfg(test)]
mod tests {
    use std::net::TcpListener;

    use axum::extract::connect_info::MockConnectInfo;
    use chrono::TimeZone;
    use redis::AsyncCommands;
    use sqlx::PgPool;
    use tokio_tungstenite::{connect_async, tungstenite::Message};
    use url::Url;

    use crate::{get_market_ids, load_config, routes::router, start_redis_channels};

    use super::*;

    /// Test to send a ping message to the WebSocket API and checks that
    /// a pong message is returned.
    #[tokio::test]
    async fn test_websocket_ping_response() {
        let config = load_config();
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3000))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });

        let ws_url = Url::parse(&format!("ws://{}/ws", addr)).unwrap();
        let (mut ws_stream, _) = connect_async(ws_url).await.unwrap();

        let ping_msg = InboundMessage::Ping;

        ws_stream
            .send(Message::Text(serde_json::to_string(&ping_msg).unwrap()))
            .await
            .unwrap();

        if let Some(Ok(msg)) = ws_stream.next().await {
            assert_eq!(msg.to_string(), r#"{"event":"pong"}"#);
        } else {
            panic!("did not receive response from websocket");
        }
    }

    /// Test to send a subscribe message to the WebSocket API and checks that
    /// a confirmation message is returned, and that the confirmation message
    /// is in the correct format.
    #[tokio::test]
    async fn test_websocket_subscribe_response() {
        let config = load_config();
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3001))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });

        let ws_url = Url::parse(&format!("ws://{}/ws", addr)).unwrap();
        let (mut ws_stream, _) = connect_async(ws_url).await.unwrap();

        let sub_msg = InboundMessage::Subscribe(Channel::Orders {
            market_id: 0,
            user_address: "0x1".into(),
        });

        ws_stream
            .send(Message::Text(serde_json::to_string(&sub_msg).unwrap()))
            .await
            .unwrap();

        if let Some(Ok(msg)) = ws_stream.next().await {
            assert_eq!(
                msg.to_string(),
                r#"{"event":"confirm","channel":"orders","params":{"market_id":0,"user_address":"0x1"},"method":"subscribe"}"#
            );
        } else {
            panic!("did not receive response from websocket");
        }
    }

    /// Test to send a subscribe message to the WebSocket API and first checks
    /// that the correct confirmation message is returned. Then, it sends an
    /// order update to the corresponding Redis pubsub channel, and checks that
    /// the correct order update message is sent to the client.
    #[tokio::test]
    async fn test_websocket_order_update() {
        let config = load_config();
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let mut conn =
            start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3002))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });

        let ws_url = Url::parse(&format!("ws://{}/ws", addr)).unwrap();
        let (mut ws_stream, _) = connect_async(ws_url).await.unwrap();

        let market_id = 0;
        let user_address = "0x1".to_string();

        let sub_msg = InboundMessage::Subscribe(Channel::Orders {
            market_id,
            user_address: user_address.clone(),
        });

        ws_stream
            .send(Message::Text(serde_json::to_string(&sub_msg).unwrap()))
            .await
            .unwrap();

        tokio::spawn(async move {
            let order = types::order::Order {
                market_order_id: 100,
                market_id,
                side: types::order::Side::Bid,
                size: 1000,
                price: 1000,
                user_address,
                custodian_id: None,
                order_state: types::order::OrderState::Open,
                created_at: Utc.with_ymd_and_hms(2023, 3, 1, 0, 0, 0).unwrap(),
            };
            let update: Update = Update::Orders(order);
            let s = serde_json::to_string(&update).unwrap();

            conn.publish::<&str, String, i32>(format!("orders:{}", market_id).as_str(), s.clone())
                .await
                .unwrap();
        });

        let mut i = 0;
        while let Some(Ok(msg)) = ws_stream.next().await {
            match i {
                0 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"confirm","channel":"orders","params":{"market_id":0,"user_address":"0x1"},"method":"subscribe"}"#
                    );
                }
                1 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"update","channel":"orders","data":{"market_order_id":100,"market_id":0,"side":"bid","size":1000,"price":1000,"user_address":"0x1","custodian_id":null,"order_state":"open","created_at":"2023-03-01T00:00:00Z"}}"#
                    );
                    return;
                }
                _ => {
                    panic!("received more messages than expected");
                }
            }
            i += 1;
        }
    }

    /// Test to send a subscribe message to the WebSocket API and first checks
    /// that the correct confirmation message is returned. Then, it sends an
    /// fill update to the corresponding Redis pubsub channel, and checks that
    /// the correct fill update message is sent to the client.
    #[tokio::test]
    async fn test_websocket_fill_update() {
        let config = load_config();
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let mut conn =
            start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3003))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });

        let ws_url = Url::parse(&format!("ws://{}/ws", addr)).unwrap();
        let (mut ws_stream, _) = connect_async(ws_url).await.unwrap();

        let market_id = 0;
        let user_address = "0x1".to_string();

        let sub_msg = InboundMessage::Subscribe(Channel::Fills {
            market_id,
            user_address: user_address.clone(),
        });

        ws_stream
            .send(Message::Text(serde_json::to_string(&sub_msg).unwrap()))
            .await
            .unwrap();

        tokio::spawn(async move {
            let fill = types::order::Fill {
                market_id,
                maker_order_id: 100,
                maker: user_address,
                maker_side: types::order::Side::Bid,
                custodian_id: None,
                size: 1000,
                price: 1000,
                time: Utc.with_ymd_and_hms(2023, 3, 1, 0, 0, 0).unwrap(),
            };
            let update: Update = Update::Fills(fill);
            let s = serde_json::to_string(&update).unwrap();

            conn.publish::<&str, String, i32>(format!("fills:{}", market_id).as_str(), s.clone())
                .await
                .unwrap();
        });

        let mut i = 0;
        while let Some(Ok(msg)) = ws_stream.next().await {
            match i {
                0 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"confirm","channel":"fills","params":{"market_id":0,"user_address":"0x1"},"method":"subscribe"}"#
                    );
                }
                1 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"update","channel":"fills","data":{"market_id":0,"maker_order_id":100,"maker":"0x1","maker_side":"bid","custodian_id":null,"size":1000,"price":1000,"time":"2023-03-01T00:00:00Z"}}"#
                    );
                    return;
                }
                _ => {
                    panic!("received more messages than expected");
                }
            }
            i += 1;
        }
    }

    /// Test to send a subscribe message to the WebSocket API with an invalid
    /// `market_id` parameter, and checks that an error message indicating that
    /// a market with the provided ID could not be found is sent.
    #[tokio::test]
    async fn test_websocket_unknown_market_id() {
        let config = load_config();
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let _conn = start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3004))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });

        let ws_url = Url::parse(&format!("ws://{}/ws", addr)).unwrap();
        let (mut ws_stream, _) = connect_async(ws_url).await.unwrap();

        let market_id = 999;
        let user_address = "0x1".to_string();

        let sub_msg = InboundMessage::Subscribe(Channel::Orders {
            market_id,
            user_address: user_address.clone(),
        });

        ws_stream
            .send(Message::Text(serde_json::to_string(&sub_msg).unwrap()))
            .await
            .unwrap();

        if let Some(Ok(msg)) = ws_stream.next().await {
            assert_eq!(
                msg.to_string(),
                r#"{"event":"error","message":"market with id `999` not found"}"#
            );
        } else {
            panic!("did not receive response from websocket");
        }
    }

    /// Test to send a subscribe message to the WebSocket API and first checks
    /// that the correct confirmation message is returned. Then, it sends a
    /// cancellation update to the corresponding Redis pubsub channel, and checks
    /// that the correct order update is sent to the client.
    #[tokio::test]
    async fn test_websocket_order_cancel() {
        let config = load_config();
        let pool = PgPool::connect(&config.database_url)
            .await
            .expect("Could not connect to DATABASE_URL");

        let market_ids = get_market_ids(pool.clone()).await;

        let (btx, mut brx) = broadcast::channel(16);
        let mut conn =
            start_redis_channels(config.redis_url, market_ids.clone(), btx.clone()).await;

        let state = AppState {
            pool,
            sender: btx,
            market_ids: HashSet::from_iter(market_ids.into_iter()),
        };
        let app = router(state).layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3005))));

        tokio::spawn(async move {
            // keep broadcast channel alive
            while let Ok(_) = brx.recv().await {}
        });

        let listener = TcpListener::bind("0.0.0.0:8000".parse::<SocketAddr>().unwrap()).unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::Server::from_tcp(listener)
                .unwrap()
                .serve(app.into_make_service())
                .await
                .unwrap();
        });

        let ws_url = Url::parse(&format!("ws://{}/ws", addr)).unwrap();
        let (mut ws_stream, _) = connect_async(ws_url).await.unwrap();

        let market_id = 0;
        let user_address = "0x1".to_string();

        let sub_msg = InboundMessage::Subscribe(Channel::Orders {
            market_id,
            user_address: user_address.clone(),
        });

        ws_stream
            .send(Message::Text(serde_json::to_string(&sub_msg).unwrap()))
            .await
            .unwrap();

        tokio::spawn(async move {
            // Send message for placing order.
            let order = types::order::Order {
                market_order_id: 100,
                market_id,
                side: types::order::Side::Bid,
                size: 1000,
                price: 1000,
                user_address: user_address.clone(),
                custodian_id: None,
                order_state: types::order::OrderState::Open,
                created_at: Utc.with_ymd_and_hms(2023, 3, 1, 0, 0, 0).unwrap(),
            };
            let update: Update = Update::Orders(order);
            let s = serde_json::to_string(&update).unwrap();

            conn.publish::<&str, String, i32>(format!("orders:{}", market_id).as_str(), s.clone())
                .await
                .unwrap();

            // Send message for cancelling order.
            let order = types::order::Order {
                market_order_id: 100,
                market_id,
                side: types::order::Side::Bid,
                size: 1000,
                price: 1000,
                user_address,
                custodian_id: None,
                order_state: types::order::OrderState::Cancelled,
                created_at: Utc.with_ymd_and_hms(2023, 3, 1, 0, 0, 0).unwrap(),
            };
            let update: Update = Update::Orders(order);
            let s = serde_json::to_string(&update).unwrap();

            conn.publish::<&str, String, i32>(format!("orders:{}", market_id).as_str(), s.clone())
                .await
                .unwrap();
        });

        let mut i = 0;
        while let Some(Ok(msg)) = ws_stream.next().await {
            match i {
                0 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"confirm","channel":"orders","params":{"market_id":0,"user_address":"0x1"},"method":"subscribe"}"#
                    );
                }
                1 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"update","channel":"orders","data":{"market_order_id":100,"market_id":0,"side":"bid","size":1000,"price":1000,"user_address":"0x1","custodian_id":null,"order_state":"open","created_at":"2023-03-01T00:00:00Z"}}"#
                    );
                }
                2 => {
                    assert_eq!(
                        msg.to_string(),
                        r#"{"event":"update","channel":"orders","data":{"market_order_id":100,"market_id":0,"side":"bid","size":1000,"price":1000,"user_address":"0x1","custodian_id":null,"order_state":"cancelled","created_at":"2023-03-01T00:00:00Z"}}"#
                    );
                    return;
                }
                _ => {
                    panic!("received more messages than expected");
                }
            }
            i += 1;
        }
    }
}
