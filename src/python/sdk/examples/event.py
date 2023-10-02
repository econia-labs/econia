from os import environ

import httpx
import websocket
import rel


REST_URL_LOCAL_DEFAULT = "http://0.0.0.0:3000"
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

def get_rest_host() -> str:
    url = environ.get("REST_URL")
    if url == None:
        url_in = input(
            "Enter the URL of the REST host (enter nothing to default to local OR re-run with REST_URL environment variable)\n"
        ).strip()
        if url_in == "":
            return REST_URL_LOCAL_DEFAULT
        else:
            return url_in
    else:
        return url

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

def start():
    host_rest = get_rest_host()
    channel = get_channel()
    response = httpx.post(f"{host_rest}/rpc/jwt", json={"channels": [channel]})

    host_ws = get_ws_host()
    ws = websocket.WebSocketApp(
        f"{host_ws}/{response.text[1:-1]}",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.run_forever(dispatcher=rel)  # Set dispatcher to automatic reconnection, 5 second reconnect delay if connection closed unexpectedly
    rel.signal(2, rel.abort)  # Keyboard Interrupt
    rel.dispatch()