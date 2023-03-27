use std::net::SocketAddr;

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
use types::message::{InboundMessage, OutboundMessage, Update};

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
) -> Result<(), WebSocketError> {
    while let Ok(update) = brx.recv().await {
        let msg = OutboundMessage::Update(update);
        tx.send(msg).await?;
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

    tokio::spawn(async move {
        forward_message_handler(sender, mrx).await;
    });

    let mtx1 = mtx.clone();
    tokio::spawn(async move {
        outbound_message_handler(brx, mtx1).await;
    });

    tokio::spawn(async move {
        inbound_message_handler(receiver, mtx, who).await;
    });
}
