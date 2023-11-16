from typing import Any, Optional

from aptos_sdk.account_address import AccountAddress

from econia_sdk.lib import EconiaViewer
from econia_sdk.types import Side

_HI_64 = 18446744073709551615


def get_ABORT(view: EconiaViewer) -> int:
    """
    Public constant getter for `ABORT`.
    """
    result = int(view.get_returns("market", "get_ABORT")[0])
    return result


def get_ASK(view: EconiaViewer) -> bool:
    """
    Public constant getter for `ASK`.
    """
    result = bool(view.get_returns("market", "get_ASK")[0])
    return result


def get_BID(view: EconiaViewer) -> bool:
    """
    Public constant getter for `BID`.
    """
    result = bool(view.get_returns("market", "get_BID")[0])
    return result


def get_BUY(view: EconiaViewer) -> bool:
    """
    Public constant getter for `BUY`.
    """
    result = bool(view.get_returns("market", "get_BUY")[0])
    return result


def get_CANCEL_BOTH(view: EconiaViewer) -> int:
    """
    Public constant getter for `CANCEL_BOTH`.
    """
    result = int(view.get_returns("market", "get_CANCEL_BOTH")[0])
    return result


def get_CANCEL_MAKER(view: EconiaViewer) -> int:
    """
    Public constant getter for `CANCEL_MAKER`.
    """
    result = int(view.get_returns("market", "get_CANCEL_MAKER")[0])
    return result


def get_CANCEL_TAKER(view: EconiaViewer) -> int:
    """
    Public constant getter for `CANCEL_TAKER`.
    """
    result = int(view.get_returns("market", "get_CANCEL_TAKER")[0])
    return result


def get_FILL_OR_ABORT(view: EconiaViewer) -> int:
    """
    Public constant getter for `FILL_OR_ABORT`.
    """
    result = int(view.get_returns("market", "get_FILL_OR_ABORT")[0])
    return result


def get_HI_PRICE(view: EconiaViewer) -> int:
    """
    Public constant getter for `HI_PRICE`.
    """
    result = int(view.get_returns("market", "get_HI_PRICE")[0])
    return result


def get_IMMEDIATE_OR_CANCEL(view: EconiaViewer) -> int:
    """
    Public constant getter for `IMMEDIATE_OR_CANCEL`.
    """
    result = int(view.get_returns("market", "get_IMMEDIATE_OR_CANCEL")[0])
    return result


def get_MAX_POSSIBLE(view: EconiaViewer) -> int:
    """
    Public constant getter for `MAX_POSSIBLE`.
    """
    result = int(view.get_returns("market", "get_MAX_POSSIBLE")[0])
    return result


def get_NO_CUSTODIAN(view: EconiaViewer) -> int:
    """
    Public constant getter for `NO_CUSTODIAN`.
    """
    result = int(view.get_returns("market", "get_NO_CUSTODIAN")[0])
    return result


def get_NO_RESTRICTION(view: EconiaViewer) -> int:
    """
    Public constant getter for `NO_RESTRICTION`.
    """
    result = int(view.get_returns("market", "get_NO_RESTRICTION")[0])
    return result


def get_NO_UNDERWRITER(view: EconiaViewer) -> int:
    """
    Public constant getter for `NO_UNDERWRITER`.
    """
    result = int(view.get_returns("market", "get_NO_UNDERWRITER")[0])
    return result


def get_POST_OR_ABORT(view: EconiaViewer) -> int:
    """
    Public constant getter for `POST_OR_ABORT`.
    """
    result = int(view.get_returns("market", "get_POST_OR_ABORT")[0])
    return result


def get_PERCENT(view: EconiaViewer) -> int:
    """
    Public constant getter for `PERCENT`.
    """
    result = bool(view.get_returns("market", "get_PERCENT")[0])
    return result


def get_SELL(view: EconiaViewer) -> int:
    """
    Public constant getter for `SELL`.
    """
    result = bool(view.get_returns("market", "get_SELL")[0])
    return result


def get_TICKS(view: EconiaViewer) -> int:
    """
    Public constant getter for `TICKS`.
    """
    result = bool(view.get_returns("market", "get_TICKS")[0])
    return result


def get_market_order_id_counter(view: EconiaViewer, market_order_id: int) -> int:
    """
    Return order counter encoded in market order ID.
    """
    returns = view.get_returns(
        "market", "get_market_order_id_counter", [], [str(market_order_id)]
    )
    return int(returns[0])


def get_market_order_id_price(view: EconiaViewer, market_order_id: int) -> int:
    """
    For an order that resulted in a post to the order book, return
    the order price encoded in its market order ID, corresponding to
    the price that the maker portion of the order posted to the book
    at.

    Aborts:
    * `E_ORDER_DID_NOT_POST`: Order ID corresponds to an order that
      did not post to the book.
    """
    returns = view.get_returns(
        "market", "get_market_order_id_price", [], [str(market_order_id)]
    )
    return int(returns[0])


def get_posted_order_id_side(view: EconiaViewer, market_order_id: int) -> bool:
    """
    For an order that resulted in a post to the order book, return
    the order side encoded in its order ID, corresponding to the
    side that the maker portion of the order posted to the book at.

    Aborts:
    * `E_ORDER_DID_NOT_POST`: Order ID corresponds to an order that
      did not post to the book.
    """
    returns = view.get_returns(
        "market", "get_posted_order_id_side", [], [str(market_order_id)]
    )
    return bool(returns[0])


def get_open_order(
    view: EconiaViewer, market_id: int, market_order_id: int
) -> Optional[dict]:
    """
    Returns a view of the order for `market_id` and `market_order_id`,
    should it not exist returns `None`.
    """
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
    """
    Index order book for given market ID into "asks" and "bids"
    vectors. Vectors sorted by price-time priority.

    Parameters:
    * `market_id`: Market ID of maker orders to index.
    * `n_asks_max`: Maximum number of asks to index.
    * `n_bids_max`: Maximum number of bids to index.

    Aborts:
    * `E_INVALID_MARKET_ID`: No market with given ID.
    """
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
    """
    Wrapped call to `get_open_orders()` for getting all open orders
    on both sides.
    """
    return get_open_orders(view, market_id)


def get_price_levels(
    view: EconiaViewer,
    market_id: int,
    n_ask_levels_max: int = _HI_64,
    n_bid_levels_max: int = _HI_64,
) -> dict:
    """
    Index order book for given market ID into price level "bids" and
    "asks" vectors.

    Vectors sorted by price priority.

    Parameters:
    * `market_id`: Market ID of price levels to index.
    * `n_ask_levels_max`: Maximum number of ask price levels to
      index.
    * `n_bid_levels_max`: Maximum number of bid price levels to
      index.
    """
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
    """
    Wrapped call to `get_price_levels()` for getting all price
    levels on both sides.
    """
    return get_price_levels(view, market_id)


def get_open_orders_paginated(
    viewer: EconiaViewer,
    market_id: int,
    ask_page_size: int,
    bid_page_size: int,
    next_ask_idx: int,
    next_bid_idx: int,
    ledger_version: int,
):
    returns = viewer.get_returns(
        "market",
        "get_open_orders_paginated",
        [],
        [
            str(market_id),
            str(ask_page_size),
            str(bid_page_size),
            str(next_ask_idx),
            str(next_bid_idx),
        ],
        ledger_version=ledger_version,
    )
    return returns


def get_open_orders_with_pagination(
    viewer: EconiaViewer,
    market_id: int,
    max_asks: int = 100,
    max_bids: int = 100,
    page_size: int = 100,
) -> dict:
    info = viewer.aptos_client.info()
    ledger_version = int(info["ledger_version"])

    next_ask_idx = "0"
    next_bid_idx = "0"
    bid_page_size = ask_page_size = page_size

    asks = []
    bids = []

    keep_looping = True
    while keep_looping:
        returns = get_open_orders_paginated(
            viewer,
            market_id,
            min(ask_page_size, max(max_asks - len(asks), 0)),
            min(bid_page_size, max(max_bids - len(bids), 0)),
            int(next_ask_idx),
            int(next_bid_idx),
            ledger_version,
        )

        value = returns[0]
        next_ask_idx = returns[1]
        next_bid_idx = returns[2]

        for ask in value["asks"]:
            asks.append(_convert_open_order_value(ask))
        for bid in value["bids"]:
            bids.append(_convert_open_order_value(bid))

        if (len(asks) >= max_asks or next_ask_idx == "0") and (
            len(bids) >= max_bids or next_bid_idx == "0"
        ):
            keep_looping = False
        elif next_ask_idx == "0" or next_bid_idx == "0":
            if next_ask_idx == "0":
                ask_page_size = 0
            else:
                bid_page_size = 0

    return {"asks": asks, "bids": bids, "market_id": market_id}


def get_price_levels_paginated(
    viewer: EconiaViewer,
    market_id: int,
    ask_page_size: int,
    bid_page_size: int,
    next_ask_idx: int,
    next_bid_idx: int,
    ledger_version: int,
):
    returns = viewer.get_returns(
        "market",
        "get_price_levels_paginated",
        [],
        [
            str(market_id),
            str(ask_page_size),
            str(bid_page_size),
            str(next_ask_idx),
            str(next_bid_idx),
        ],
        ledger_version=ledger_version,
    )
    return returns


def get_price_levels_with_pagination(
    viewer: EconiaViewer,
    market_id: int,
    max_asks: int = 100,
    max_bids: int = 100,
    page_size: int = 100,
) -> dict:
    info = viewer.aptos_client.info()
    ledger_version = int(info["ledger_version"])

    next_ask_idx = "0"
    next_bid_idx = "0"
    bid_page_size = ask_page_size = page_size

    asks = dict()
    n_indexed_asks = 0
    bids = dict()
    n_indexed_bids = 0

    keep_looping = True
    while keep_looping:
        returns = get_price_levels_paginated(
            viewer,
            market_id,
            min(ask_page_size, max(max_asks - n_indexed_asks, 0)),
            min(bid_page_size, max(max_bids - n_indexed_bids, 0)),
            int(next_ask_idx),
            int(next_bid_idx),
            ledger_version,
        )

        value = returns[0]
        next_ask_idx = returns[1]
        next_bid_idx = returns[2]

        for ask in value["asks"]:
            price = int(ask["price"])
            size = int(ask["size"])
            if price in asks:
                asks[price] += size
            else:
                asks[price] = size
        for bid in value["bids"]:
            price = int(bid["price"])
            size = int(bid["size"])
            if price in bids:
                bids[price] += size
            else:
                bids[price] = size
        n_indexed_asks += ask_page_size
        n_indexed_bids += bid_page_size

        if (n_indexed_asks >= max_asks or next_ask_idx == "0") and (
            n_indexed_bids >= max_bids or next_bid_idx == "0"
        ):
            keep_looping = False
        elif next_ask_idx == "0" or next_bid_idx == "0":
            if next_ask_idx == "0":
                ask_page_size = 0
            else:
                bid_page_size = 0

    asks_levels = [{"price": price, "size": size} for price, size in asks.items()]
    bids_levels = [{"price": price, "size": size} for price, size in bids.items()]
    return {"asks": asks_levels, "bids": bids_levels, "market_id": market_id}


def has_open_order(view: EconiaViewer, market_id: int, market_order_id: int) -> bool:
    """
    Return `True` if `order_id` corresponds to open order for given
    `market_id`.
    """
    returns = view.get_returns(
        "market", "has_open_order", [], [str(market_id), str(market_order_id)]
    )
    return bool(returns[0])


def did_order_post(view: EconiaViewer, order_id: int) -> bool:
    """
    Return `True` if the order ID corresponds to an order that
    resulted in a post to the order book (including an order that
    filled across the spread as a taker before posting as a maker).
    """
    returns = view.get_returns("market", "did_order_post", [], [str(order_id)])
    return bool(returns[0])


def get_market_event_handle_creation_info(
    view: EconiaViewer, market_id: int
) -> Optional[Any]:
    """
    Return the market event creation numbers for `market_id`, if
    Econia resource account has event handles for indicated market.
    """
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
    """
    Return a swapper event creation numbers for `market_id`, if
    signing `swapper` has event handles for indicated market.
    """
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
