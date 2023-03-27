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
use types::message::{Channel, InboundMessage, OutboundMessage, Update};

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
) -> Result<(), WebSocketError> {
    while let Some(msg) = rx.recv().await {
        let s = serde_json::to_string(&msg)?;
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
            Update::Orders { ref data } => {
                let ch = Channel::Orders {
                    user_address: data.user_address.clone(),
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

async fn inbound_message_handler(
    mut receiver: SplitStream<WebSocket>,
    tx: mpsc::Sender<OutboundMessage>,
    who: SocketAddr,
) -> Result<(), WebSocketError> {
    while let Some(Ok(msg)) = receiver.next().await {
        match msg {
            Message::Text(s) => {
                if let Ok(msg_i) = serde_json::from_str::<InboundMessage>(&s) {
                    match msg_i {
                        InboundMessage::Ping => {
                            tracing::info!("received ping message from client {}", who);
                            let msg_o = OutboundMessage::Pong;
                            tx.send(msg_o).await?;
                        }
                        _ => {
                            // TODO
                        }
                    }
                } else {
                    let re = Regex::new(r"\n|\s+").unwrap();
                    tracing::warn!(
                        "could not parse message `{}` received from client {}",
                        re.replace_all(&s, ""),
                        who
                    );
                    let msg_o = OutboundMessage::Error {
                        message: "could not parse message".into(),
                    };
                    tx.send(msg_o).await?;
                }
            }
            Message::Close(c) => {
                if let Some(cf) = c {
                    tracing::info!("client {} sent close with code {}", who, cf.code);
                } else {
                    tracing::info!("client {} sent close without CloseFrame", who);
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
        if let Err(e) = forward_message_handler(sender, mrx).await {
            tracing::error!(
                "websocket connection with client {} failed on message forward task: {}",
                who,
                e
            );
        }
    });

    let mtx1 = mtx.clone();
    let mut send_task = tokio::spawn(async move {
        if let Err(e) = outbound_message_handler(brx, mtx1, &subs).await {
            tracing::error!(
                "websocket connection with client {} failed on outbound message handler: {}",
                who,
                e
            );
        }
    });

    let mut recv_task = tokio::spawn(async move {
        if let Err(e) = inbound_message_handler(receiver, mtx, who).await {
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
