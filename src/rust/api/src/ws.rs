use core::panic;
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

// The maximum time allowed since the last ping message is set to 1 hour.
// If it has been over an hour since the last ping message was received, the
// WebSocket connection is terminated.
static PING_ELAPSED_TIME_LIMIT: Duration = Duration::from_secs(3600);

// The interval for checking that the time elapsed since the last ping has not
// exceeded the limit. Set to every 10 minutes.
static PING_CHECK_INTERVAL: Duration = Duration::from_secs(600);

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<AppState>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> impl IntoResponse {
    tracing::info!("new websocket connection with client {}", addr);
    ws.on_upgrade(move |ws| handle_socket(ws, state.sender, addr))
}

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
        };
        if subbed {
            let msg = OutboundMessage::Update(update);
            tx.send(msg).await?;
        }
    }
    Ok(())
}

fn get_response_message(
    msg_i: InboundMessage,
    subs: &Mutex<HashSet<Channel>>,
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

async fn inbound_message_handler(
    mut receiver: SplitStream<WebSocket>,
    tx: mpsc::Sender<OutboundMessage>,
    subs: Arc<Mutex<HashSet<Channel>>>,
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
                        let msg_o = get_response_message(msg_i, &subs, &last_ping, who)?;
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

async fn forward_message_handler(
    mut sender: SplitSink<WebSocket, Message>,
    mut rx: mpsc::Receiver<OutboundMessage>,
    who: SocketAddr,
) -> Result<(), WebSocketError> {
    while let Some(msg) = rx.recv().await {
        let s = serde_json::to_string(&msg)?;
        tracing::debug!("sending message `{}` to client {}", s, who);
        sender.send(Message::Text(s)).await?;
    }
    Ok(())
}

async fn handle_socket(ws: WebSocket, btx: broadcast::Sender<Update>, who: SocketAddr) {
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
    let subs1 = Arc::clone(&subs);
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
    let last_ping1 = Arc::clone(&last_ping);
    let mut recv_task = tokio::spawn(async move {
        if let Err(e) = inbound_message_handler(receiver, mtx2, subs, last_ping1, who).await {
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
