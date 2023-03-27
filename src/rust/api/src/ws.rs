use core::panic;
use std::{
    collections::HashSet,
    net::SocketAddr,
    sync::{Arc, Mutex},
};

use axum::{
    extract::{
        ws::{Message, WebSocket},
        ConnectInfo, State, WebSocketUpgrade,
    },
    response::IntoResponse,
};
use futures_util::{
    stream::{SplitSink, SplitStream},
    SinkExt, StreamExt,
};
use regex::Regex;
use tokio::sync::{broadcast, mpsc};
use types::message::{Channel, ConfirmMethod, InboundMessage, OutboundMessage, Update};

use crate::{error::WebSocketError, AppState};

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<AppState>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> impl IntoResponse {
    tracing::info!("new websocket connection with client {}", addr);
    ws.on_upgrade(move |ws| handle_socket(ws, state.sender, addr))
}

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

async fn outbound_message_handler(
    mut brx: broadcast::Receiver<Update>,
    tx: mpsc::Sender<OutboundMessage>,
    subs: &Arc<Mutex<HashSet<Channel>>>,
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
    subs: &Arc<Mutex<HashSet<Channel>>>,
) -> Result<OutboundMessage, WebSocketError> {
    match msg_i {
        InboundMessage::Ping => Ok(OutboundMessage::Pong),
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
    subs: &Arc<Mutex<HashSet<Channel>>>,
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
                        let msg_o = get_response_message(msg_i, subs)?;
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

async fn handle_socket(ws: WebSocket, btx: broadcast::Sender<Update>, who: SocketAddr) {
    let (sender, receiver) = ws.split();
    let brx = btx.subscribe();
    let (mtx, mrx) = mpsc::channel(16);
    let subs = Arc::new(Mutex::new(HashSet::<Channel>::new()));

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
        if let Err(e) = outbound_message_handler(brx, mtx1, &subs1).await {
            tracing::error!(
                "websocket connection with client {} failed on outbound message handler: {}",
                who,
                e
            );
        }
    });

    let mut recv_task = tokio::spawn(async move {
        if let Err(e) = inbound_message_handler(receiver, mtx, &subs, who).await {
            tracing::error!(
                "websocket connection with client {} failed on inbound message handler: {}",
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
        }
        _ = &mut recv_task => {
            fwd_task.abort();
            send_task.abort();
        }
        _ = &mut fwd_task => {
            recv_task.abort();
            send_task.abort();
        }
    }

    tracing::info!("websocket context for client {} destroyed", who);
}
