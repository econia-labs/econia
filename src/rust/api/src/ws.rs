use std::net::SocketAddr;

use axum::{
    extract::{
        ws::{Message, WebSocket},
        ConnectInfo, WebSocketUpgrade,
    },
    response::IntoResponse,
};
use futures_util::{SinkExt, StreamExt};
use regex::Regex;
use types::message::{InboundMessage, OutboundMessage};

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> impl IntoResponse {
    tracing::info!("new websocket connection with client {}", addr);
    ws.on_upgrade(move |ws| handle_socket(ws, addr))
}

async fn handle_socket(ws: WebSocket, who: SocketAddr) {
    let (mut sender, mut receiver) = ws.split();

    while let Some(Ok(msg)) = receiver.next().await {
        match msg {
            Message::Text(s) => {
                if let Ok(msg_i) = serde_json::from_str::<InboundMessage>(&s) {
                    match msg_i {
                        InboundMessage::Ping => {
                            tracing::info!("received ping message from client {}", who);
                            let msg_o = OutboundMessage::Pong;
                            let msg_str = serde_json::to_string(&msg_o).unwrap();
                            sender.send(Message::Text(msg_str)).await.unwrap();
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
                    let msg_str = serde_json::to_string(&msg_o).unwrap();
                    sender.send(Message::Text(msg_str)).await.unwrap();
                }
            }
            _ => {
                // TODO
            }
        }
    }
}
