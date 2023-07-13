from aptos_sdk.account_address import AccountAddress
from aptos_sdk.bcs import Serializer, encoder
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

def serialize_address(addr: AccountAddress) -> Any:
    return addr.address.hex()

def get_all_market_account_ids_for_market_id(
    view: EconiaViewer,
    user: AccountAddress,
    market_id: int,
) -> Any:
    returns = view.get_returns(
        "user",
        "get_all_market_account_ids_for_market_id",
        [],
        [
            serialize_address(user),
            str(market_id)
        ]
    )
    return returns[0]

def get_all_market_account_ids_for_user(
    view: EconiaViewer,
    user: AccountAddress,
) -> Any:
    returns = view.get_returns(
        "user",
        "get_all_market_account_ids_for_user",
        []
        [serialize_address(user)]
    )
    return returns[0]

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
) -> Any:
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
    return returns[0]

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
) -> Any:
    returns = view.get_returns(
        "user",
        "get_market_accounts",
        [],
        [serialize_address(user)],
    )
    return returns[0]

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