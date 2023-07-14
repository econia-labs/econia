from aptos_sdk.account_address import AccountAddress
from typing import Any
from econia_sdk.lib import EconiaViewer

def get_ASK(view: EconiaViewer) -> bool:
    returns = view.get_returns("user", "get_ASK")
    return bool(returns[0])

def get_BID(view: EconiaViewer) -> bool:
    returns = view.get_returns("user", "get_BID")
    return bool(returns[0])

def get_NO_CUSTODIAN(view: EconiaViewer) -> int:
    returns = view.get_returns("user", "get_NO_CUSTODIAN")
    return int(returns[0])

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
        [
            serialize_address(user),
            str(market_id)
        ]
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
        [serialize_address(user)]
    )
    ids = []
    for id in returns[0]:
        ids.append(int(id))
    return ids

def get_custodian_id(
    view: EconiaViewer,
    market_account_id: int
) -> int:
    returns = view.get_returns(
        "user",
        "get_custodian_id",
        [],
        [str(market_account_id)]
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
        [
            serialize_address(user),
            str(market_id),
            str(custodian_id)
        ]
    )
    return _convert_market_account_value(returns[0])
    

def _convert_market_account_value(value) -> dict:
    asks = []
    for ask in value["asks"]:
        asks.append({
            "market_order_id": int(ask["market_order_id"]),
            "size": int(ask["size"]) # in units of (base) lots
        })
    bids = []
    for bid in value["bids"]:
        bids.append({
            "market_order_id": int(bid["market_order_id"]),
            "size": int(bid["size"]) # in units of (base) lots
        })
    return {
        "asks": asks,
        "bids": bids,
        "base_available": int(value["base_available"]), # subunits
        "base_ceiling": int(value["base_ceiling"]), # subunits
        "base_total": int(value["base_total"]), # subunits
        "custodian_id": int(value["custodian_id"]),
        "market_id": int(value["market_id"]),
        "quote_available": int(value["quote_available"]), # subunits
        "quote_ceiling": int(value["quote_ceiling"]), # subunits
        "quote_total": int(value["quote_total"]) # subunits
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
        ]
    )
    return int(returns[0])

def get_market_accounts(
    view: EconiaViewer,
    user: AccountAddress
) -> list[dict]:
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
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
    custodian_id: int
  ) -> bool:
    returns = view.get_returns(
        "user",
        "has_market_account",
        [],
        [
            serialize_address(user),
            str(market_id),
            str(custodian_id)
        ]
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
        ]
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
        ]
    )
    return bool(returns[0])