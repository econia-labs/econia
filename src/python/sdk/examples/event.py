from os import environ

import httpx
import rel
import websocket
import jwt

JWT_SECRET_DEFAULT = "econia_0000000000000000000000000"
WS_URL_LOCAL_DEFAULT = "ws://0.0.0.0:3001"
WS_CHANNEL_DEFAULT = "fill_event"


def on_message(ws, message):
    print(message)


def on_error(ws, error):
    print(error)


def on_close(ws, close_status_code, close_msg):
    print("### closed ###")


def on_open(ws):
    print("Opened connection")


def get_ws_host() -> str:
    url = environ.get("WS_URL")
    if url == None:
        url_in = input(
            "Enter the URL of the WebSocket host (enter nothing to default to local OR re-run with WS_URL environment variable)\n"
        ).strip()
        if url_in == "":
            return WS_URL_LOCAL_DEFAULT
        else:
            return url_in
    else:
        return url


def get_channel() -> str:
    url = environ.get("WS_CHANNEL")
    if url == None:
        url_in = input(
            "Enter the channel to listen to (enter nothing to default to `fill_event` OR re-run with WS_CHANNEL environment variable)\n"
        ).strip()
        if url_in == "":
            return WS_CHANNEL_DEFAULT
        else:
            return url_in
    else:
        return url
    
def get_jwt_secret() -> str:
    jwt_sec = environ.get("JWT_SECRET")
    if jwt_sec == None:
        jwt_sec = input(
            "Enter the JWT secret (enter nothing to used default compromised key OR re-run with JWT_SECRET environment variable)\n"
        ).strip()
        if jwt_sec == "":
            return JWT_SECRET_DEFAULT
        else:
            return jwt_sec
    else:
        return jwt_sec


def start():
    token = jwt.encode(
        {'mode': 'r', 'channels': [get_channel()]},
        get_jwt_secret(),
        algorithm='HS256'
    ).decode('utf-8')
    host_ws = get_ws_host()
    ws = websocket.WebSocketApp(
        f"{host_ws}/{token}",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close,
    )
    ws.run_forever(
        dispatcher=rel # type: ignore
    )  # Set dispatcher to automatic reconnection, 5 second reconnect delay if connection closed unexpectedly
    rel.signal(2, rel.abort)  # Keyboard Interrupt
    rel.dispatch()
