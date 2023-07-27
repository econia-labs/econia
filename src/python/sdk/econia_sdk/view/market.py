from typing import Any, Optional

from aptos_sdk.account_address import AccountAddress

from econia_sdk.lib import EconiaViewer
from econia_sdk.types import Side

_HI_64 = 18446744073709551615


def get_ABORT(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_ABORT")[0])
    return result


def get_ASK(view: EconiaViewer) -> bool:
    result = bool(view.get_returns("market", "get_ASK")[0])
    return result


def get_BID(view: EconiaViewer) -> bool:
    result = bool(view.get_returns("market", "get_BID")[0])
    return result


def get_BUY(view: EconiaViewer) -> bool:
    result = bool(view.get_returns("market", "get_BUY")[0])
    return result


def get_CANCEL_BOTH(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_CANCEL_BOTH")[0])
    return result


def get_CANCEL_MAKER(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_CANCEL_MAKER")[0])
    return result


def get_CANCEL_TAKER(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_CANCEL_TAKER")[0])
    return result


def get_FILL_OR_ABORT(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_FILL_OR_ABORT")[0])
    return result


def get_HI_PRICE(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_HI_PRICE")[0])
    return result


def get_IMMEDIATE_OR_CANCEL(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_IMMEDIATE_OR_CANCEL")[0])
    return result


def get_MAX_POSSIBLE(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_MAX_POSSIBLE")[0])
    return result


def get_NO_CUSTODIAN(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_NO_CUSTODIAN")[0])
    return result


def get_NO_RESTRICTION(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_NO_RESTRICTION")[0])
    return result


def get_NO_UNDERWRITER(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_NO_UNDERWRITER")[0])
    return result


def get_POST_OR_ABORT(view: EconiaViewer) -> int:
    result = int(view.get_returns("market", "get_POST_OR_ABORT")[0])
    return result


def get_PERCENT(view: EconiaViewer) -> int:
    result = bool(view.get_returns("market", "get_PERCENT")[0])
    return result


def get_SELL(view: EconiaViewer) -> int:
    result = bool(view.get_returns("market", "get_SELL")[0])
    return result


def get_TICKS(view: EconiaViewer) -> int:
    result = bool(view.get_returns("market", "get_TICKS")[0])
    return result


def get_market_order_id_counter(
    view: EconiaViewer, market_order_id: int
) -> int:
    returns = view.get_returns(
        "market", "get_market_order_id_counter", [], [str(market_order_id)]
    )
    return int(returns[0])


def get_market_order_id_price(view: EconiaViewer, market_order_id: int) -> int:
    returns = view.get_returns(
        "market", "get_market_order_id_price", [], [str(market_order_id)]
    )
    return int(returns[0])


def get_posted_order_id_side(view: EconiaViewer, market_order_id: int) -> bool:
    returns = view.get_returns(
        "market", "get_posted_order_id_side", [], [str(market_order_id)]
    )
    return bool(returns[0])


def get_open_order(
    view: EconiaViewer, market_id: int, market_order_id: int
) -> Optional[dict]:
    returns = view.get_returns(
        "market", "get_open_order", [], [str(market_id), str(market_order_id)]
    )
    opt_val = returns[0]["vec"]
    if len(opt_val) == 0:
        return None
    else:
        return _convert_open_order_value(opt_val[0])


def get_open_orders(
    view: EconiaViewer,
    market_id: int,
    n_asks_max: int = _HI_64,
    n_bids_max: int = _HI_64,
) -> dict:
    returns = view.get_returns(
        "market",
        "get_open_orders",
        [],
        [
            str(market_id),
            str(n_asks_max),
            str(n_bids_max),
        ],
    )
    value = returns[0]
    bids = []
    for bid in value["bids"]:
        bids.append(_convert_open_order_value(bid))
    asks = []
    for ask in value["asks"]:
        asks.append(_convert_open_order_value(ask))
    return {"bids": bids, "asks": asks}


def _convert_open_order_value(value) -> dict:
    side = Side.BID
    if value["side"]:
        side = Side.ASK
    return {
        "custodian_id": int(value["custodian_id"]),
        "market_id": int(value["market_id"]),
        "order_id": int(value["order_id"]),
        "price": int(value["price"]),  # ticks per lot
        "side": side,
        "remaining_size": int(value["remaining_size"]),  # lots of base
        "user": AccountAddress.from_hex(value["user"]),
    }


def get_open_orders_all(view: EconiaViewer, market_id: int) -> dict:
    return get_open_orders(view, market_id)


def get_price_levels(
    view: EconiaViewer,
    market_id: int,
    n_ask_levels_max: int = _HI_64,
    n_bid_levels_max: int = _HI_64,
) -> dict:
    returns = view.get_returns(
        "market",
        "get_price_levels",
        [],
        [
            str(market_id),
            str(n_ask_levels_max),
            str(n_bid_levels_max),
        ],
    )
    value = returns[0]
    asks = []
    for ask in value["asks"]:
        asks.append({"price": int(ask["price"]), "size": int(ask["size"])})
    bids = []
    for bid in value["bids"]:
        bids.append({"price": int(bid["price"]), "size": int(bid["size"])})
    return {"asks": asks, "bids": bids, "market_id": int(value["market_id"])}


def get_price_levels_all(view: EconiaViewer, market_id: int) -> dict:
    return get_price_levels(view, market_id)


def has_open_order(
    view: EconiaViewer, market_id: int, market_order_id: int
) -> bool:
    returns = view.get_returns(
        "market", "has_open_order", [], [str(market_id), str(market_order_id)]
    )
    return bool(returns[0])


def did_order_post(view: EconiaViewer, order_id: int) -> bool:
    returns = view.get_returns("market", "did_order_post", [], [str(order_id)])
    return bool(returns[0])


def get_market_event_handle_creation_info(
    view: EconiaViewer, market_id: int
) -> Optional[Any]:
    returns = view.get_returns(
        "market", "get_market_event_handle_creation_info", [], [str(market_id)]
    )
    opt_val = returns[0]["vec"]
    if len(opt_val) == 0:
        return None
    else:
        return opt_val[0]


def get_swapper_event_handle_creation_numbers(
    view: EconiaViewer, swapper: AccountAddress, market_id: int
) -> Optional[Any]:
    returns = view.get_returns(
        "market",
        "get_swapper_event_handle_creation_numbers",
        [],
        [swapper.address.hex(), str(market_id)],
    )
    opt_val = returns[0]["vec"]
    if len(opt_val) == 0:
        return None
    else:
        return opt_val[0]
