from typing import List, Optional

from aptos_sdk.account_address import AccountAddress

from econia_sdk.lib import EconiaViewer
from econia_sdk.types import CancelReason, Restriction, SelfMatchBehavior, Side


def get_ASK(view: EconiaViewer) -> bool:
    returns = view.get_returns("user", "get_ASK")
    return bool(returns[0])


def get_BID(view: EconiaViewer) -> bool:
    returns = view.get_returns("user", "get_BID")
    return bool(returns[0])


def get_NO_CUSTODIAN(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_NO_CUSTODIAN")
    return int(returns[0])


def get_CANCEL_REASON_EVICTION(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_CANCEL_REASON_EVICTION")
    return int(returns[0])


def get_CANCEL_REASON_IMMEDIATE_OR_CANCEL(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_CANCEL_REASON_IMMEDIATE_OR_CANCEL")
    return int(returns[0])


def get_CANCEL_REASON_MANUAL_CANCEL(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_CANCEL_REASON_MANUAL_CANCEL")
    return int(returns[0])


def get_CANCEL_REASON_MAX_QUOTE_TRADED(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_CANCEL_REASON_MAX_QUOTE_TRADED")
    return int(returns[0])


def get_CANCEL_REASON_NOT_ENOUGH_LIQUIDITY(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_CANCEL_REASON_NOT_ENOUGH_LIQUIDITY")
    return int(returns[0])


def get_CANCEL_REASON_SELF_MATCH_TAKER(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_CANCEL_REASON_SELF_MATCH_TAKER")
    return int(returns[0])


def get_CANCEL_REASON_TOO_SMALL_AFTER_MATCHING(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "user", "get_CANCEL_REASON_TOO_SMALL_AFTER_MATCHING"
    )
    return int(returns[0])


def get_market_event_handle_creation_numbers(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
) -> Optional[dict]:
    returns = view.get_returns(
        "user",
        "get_market_event_handle_creation_numbers",
        [],
        [serialize_address(user), str(market_id), str(custodian_id)],
    )
    opt_val = returns[0]["vec"]
    if len(opt_val) == 0:
        return None
    else:
        val = opt_val[0]
        return {
            "cancel_order_events_handle_creation_num": int(
                val["cancel_order_events_handle_creation_num"]
            ),
            "change_order_size_events_handle_creation_num": int(
                val["change_order_size_events_handle_creation_num"]
            ),
            "fill_events_handle_creation_num": int(
                val["fill_events_handle_creation_num"]
            ),
            "place_limit_order_events_handle_creation_num": int(
                val["place_limit_order_events_handle_creation_num"]
            ),
            "place_market_order_events_handle_creation_num": int(
                val["place_market_order_events_handle_creation_num"]
            ),
        }


def get_change_order_size_events(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
    limit: Optional[int] = None,
    start: Optional[int] = None,
) -> List[dict]:
    creation_numbers = get_market_event_handle_creation_numbers(
        view, user, market_id, custodian_id
    )
    if creation_numbers is not None:
        events = view.get_events_by_creation_number(
            user,
            creation_numbers["change_order_size_events_handle_creation_num"],
            limit,
            start,
        )
        returns = []
        for event in events:
            returns.append(
                {
                    "version": int(event["version"]),
                    "guid": {
                        "creation_number": int(
                            event["guid"]["creation_number"]
                        ),
                        "account_address": AccountAddress.from_hex(
                            event["guid"]["account_address"]
                        ),
                    },
                    "sequence_number": int(event["sequence_number"]),
                    "type": event["type"],
                    "data": {
                        "custodian_id": int(event["data"]["custodian_id"]),
                        "market_id": int(event["data"]["market_id"]),
                        "new_size": int(event["data"]["new_size"]),
                        "order_id": int(event["data"]["order_id"]),
                        "side": Side.ASK if event["data"]["side"] else Side.BID,
                        "user": AccountAddress.from_hex(event["data"]["user"]),
                    },
                }
            )
        return returns
    else:
        return []


def _convert_cancel_order_event(event: dict) -> dict:
    return {
        "version": int(event["version"]),
        "guid": {
            "creation_number": int(event["guid"]["creation_number"]),
            "account_address": AccountAddress.from_hex(
                event["guid"]["account_address"]
            ),
        },
        "sequence_number": int(event["sequence_number"]),
        "type": event["type"],
        "data": {
            "custodian_id": int(event["data"]["custodian_id"]),
            "market_id": int(event["data"]["market_id"]),
            "order_id": int(event["data"]["order_id"]),
            "reason": CancelReason(int(event["data"]["reason"])),
            "user": AccountAddress.from_hex(event["data"]["user"]),
        },
    }


def get_cancel_order_events(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
    limit: Optional[int] = None,
    start: Optional[int] = None,
) -> List[dict]:
    creation_numbers = get_market_event_handle_creation_numbers(
        view, user, market_id, custodian_id
    )
    if creation_numbers is not None:
        events = view.get_events_by_creation_number(
            user,
            creation_numbers["cancel_order_events_handle_creation_num"],
            limit,
            start,
        )
        returns = []
        for event in events:
            returns.append(_convert_cancel_order_event(event))
        return returns
    else:
        return []


def _convert_fill_order_event(event: dict) -> dict:
    return {
        "version": int(event["version"]),
        "guid": {
            "creation_number": int(event["guid"]["creation_number"]),
            "account_address": AccountAddress.from_hex(
                event["guid"]["account_address"]
            ),
        },
        "sequence_number": int(event["sequence_number"]),
        "type": event["type"],
        "data": {
            "maker": AccountAddress.from_hex(event["data"]["maker"]),
            "maker_custodian_id": int(event["data"]["maker_custodian_id"]),
            "maker_order_id": int(event["data"]["maker_order_id"]),
            "maker_side": Side.ASK if event["data"]["maker_side"] else Side.BID,
            "market_id": int(event["data"]["market_id"]),
            "price": int(event["data"]["price"]),
            "sequence_number_for_trade": int(
                event["data"]["sequence_number_for_trade"]
            ),
            "size": int(event["data"]["size"]),
            "taker": AccountAddress.from_hex(event["data"]["taker"]),
            "taker_custodian_id": int(event["data"]["taker_custodian_id"]),
            "taker_order_id": int(event["data"]["taker_order_id"]),
            "taker_quote_fees_paid": int(
                event["data"]["taker_quote_fees_paid"]
            ),
        },
    }


def get_fill_events(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
    limit: Optional[int] = None,
    start: Optional[int] = None,
) -> List[dict]:
    creation_numbers = get_market_event_handle_creation_numbers(
        view, user, market_id, custodian_id
    )
    if creation_numbers is not None:
        events = view.get_events_by_creation_number(
            user,
            creation_numbers["fill_events_handle_creation_num"],
            limit,
            start,
        )
        returns = []
        for event in events:
            returns.append(_convert_fill_order_event(event))
        return returns
    else:
        return []


def get_place_market_order_events(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
    limit: Optional[int] = None,
    start: Optional[int] = None,
) -> List[dict]:
    creation_numbers = get_market_event_handle_creation_numbers(
        view, user, market_id, custodian_id
    )
    if creation_numbers is not None:
        events = view.get_events_by_creation_number(
            user,
            creation_numbers["place_market_order_events_handle_creation_num"],
            limit,
            start,
        )
        returns = []
        for event in events:
            returns.append(
                {
                    "version": int(event["version"]),
                    "guid": {
                        "creation_number": int(
                            event["guid"]["creation_number"]
                        ),
                        "account_address": AccountAddress.from_hex(
                            event["guid"]["account_address"]
                        ),
                    },
                    "sequence_number": int(event["sequence_number"]),
                    "type": event["type"],
                    "data": {
                        "custodian_id": int(event["data"]["custodian_id"]),
                        "direction": Side.ASK
                        if bool(event["data"]["direction"])
                        else Side.BID,
                        "integrator": AccountAddress.from_hex(
                            event["data"]["integrator"]
                        ),
                        "market_id": int(event["data"]["market_id"]),
                        "order_id": int(event["data"]["order_id"]),
                        "self_match_behavior": SelfMatchBehavior(
                            int(event["data"]["self_match_behavior"])
                        ),
                        "size": int(event["data"]["size"]),
                        "user": AccountAddress.from_hex(event["data"]["user"]),
                    },
                }
            )
        return returns
    else:
        return []


def get_place_limit_order_events(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
    limit: Optional[int] = None,
    start: Optional[int] = None,
) -> List[dict]:
    creation_numbers = get_market_event_handle_creation_numbers(
        view, user, market_id, custodian_id
    )
    if creation_numbers is not None:
        events = view.get_events_by_creation_number(
            user,
            creation_numbers["place_limit_order_events_handle_creation_num"],
            limit,
            start,
        )
        returns = []
        for event in events:
            returns.append(
                {
                    "version": int(event["version"]),
                    "guid": {
                        "creation_number": int(
                            event["guid"]["creation_number"]
                        ),
                        "account_address": AccountAddress.from_hex(
                            event["guid"]["account_address"]
                        ),
                    },
                    "sequence_number": int(event["sequence_number"]),
                    "type": event["type"],
                    "data": {
                        "custodian_id": int(event["data"]["custodian_id"]),
                        "integrator": AccountAddress.from_hex(
                            event["data"]["integrator"]
                        ),
                        "market_id": int(event["data"]["market_id"]),
                        "order_id": int(event["data"]["order_id"]),
                        "price": int(event["data"]["price"]),
                        "remaining_size": int(event["data"]["remaining_size"]),
                        "restriction": Restriction(
                            int(event["data"]["restriction"])
                        ),
                        "self_match_behavior": SelfMatchBehavior(
                            int(event["data"]["self_match_behavior"])
                        ),
                        "side": Side.ASK
                        if bool(event["data"]["side"])
                        else Side.BID,
                        "size": int(event["data"]["size"]),
                        "user": AccountAddress.from_hex(event["data"]["user"]),
                    },
                }
            )
        return returns
    else:
        return []


def serialize_address(addr: AccountAddress) -> str:
    return addr.address.hex()


def get_all_market_account_ids_for_market_id(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
) -> list[int]:
    returns = view.get_returns(
        "user",
        "get_all_market_account_ids_for_market_id",
        [],
        [serialize_address(user), str(market_id)],
    )
    ids = []
    for id in returns[0]:
        ids.append(int(id))
    return ids


def get_all_market_account_ids_for_user(
    view: EconiaViewer,
    user: AccountAddress,
) -> list[int]:
    returns = view.get_returns(
        "user",
        "get_all_market_account_ids_for_user",
        [],
        [serialize_address(user)],
    )
    ids = []
    for id in returns[0]:
        ids.append(int(id))
    return ids


def get_custodian_id(view: EconiaViewer, market_account_id: int) -> int:
    returns = view.get_returns(
        "user", "get_custodian_id", [], [str(market_account_id)]
    )
    return int(returns[0])


def get_market_account(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int,
) -> dict:
    returns = view.get_returns(
        "user",
        "get_market_account",
        [],
        [serialize_address(user), str(market_id), str(custodian_id)],
    )
    return _convert_market_account_value(returns[0])


def _convert_market_account_value(value) -> dict:
    asks = []
    for ask in value["asks"]:
        asks.append(
            {
                "market_order_id": int(ask["market_order_id"]),
                "size": int(ask["size"]),  # in units of (base) lots
            }
        )
    bids = []
    for bid in value["bids"]:
        bids.append(
            {
                "market_order_id": int(bid["market_order_id"]),
                "size": int(bid["size"]),  # in units of (base) lots
            }
        )
    return {
        "asks": asks,
        "bids": bids,
        "base_available": int(value["base_available"]),  # subunits
        "base_ceiling": int(value["base_ceiling"]),  # subunits
        "base_total": int(value["base_total"]),  # subunits
        "custodian_id": int(value["custodian_id"]),
        "market_id": int(value["market_id"]),
        "quote_available": int(value["quote_available"]),  # subunits
        "quote_ceiling": int(value["quote_ceiling"]),  # subunits
        "quote_total": int(value["quote_total"]),  # subunits
    }


def get_market_account_id(
    view: EconiaViewer,
    market_id: int,
    custodian_id: int,
) -> int:
    returns = view.get_returns(
        "user",
        "get_market_account_id",
        [],
        [
            str(market_id),
            str(custodian_id),
        ],
    )
    return int(returns[0])


def get_market_accounts(view: EconiaViewer, user: AccountAddress) -> list[dict]:
    returns = view.get_returns(
        "user",
        "get_market_accounts",
        [],
        [serialize_address(user)],
    )
    value = returns[0]
    accounts = []
    for account in value:
        accounts.append(_convert_market_account_value(account))
    return accounts


def get_market_id(
    view: EconiaViewer,
    market_account_id: int,
) -> int:
    returns = view.get_returns(
        "user",
        "get_market_id",
        [],
        [str(market_account_id)],
    )
    return int(returns[0])


def has_market_account(
    view: EconiaViewer, user: AccountAddress, market_id: int, custodian_id: int
) -> bool:
    returns = view.get_returns(
        "user",
        "has_market_account",
        [],
        [serialize_address(user), str(market_id), str(custodian_id)],
    )
    return bool(returns[0])


def has_market_account_by_market_account_id(
    view: EconiaViewer,
    user: AccountAddress,
    market_account_id: int,
) -> bool:
    returns = view.get_returns(
        "user",
        "has_market_account",
        [],
        [
            serialize_address(user),
            str(market_account_id),
        ],
    )
    return bool(returns[0])


def has_market_account_by_market_id(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
) -> bool:
    returns = view.get_returns(
        "user",
        "has_market_account_by_market_id",
        [],
        [
            serialize_address(user),
            str(market_id),
        ],
    )
    return bool(returns[0])
