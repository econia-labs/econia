from aptos_sdk.bcs import Serializer
from typing import Any
from econia_sdk.lib import EconiaViewer

def get_MAX_CHARACTERS_GENERIC(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "registry",
        "get_MAX_CHARACTERS_GENERIC",
    )
    return int(returns[0])

def get_MIN_CHARACTERS_GENERIC(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "registry",
        "get_MIN_CHARACTERS_GENERIC",
    )
    return int(returns[0])

def get_NO_CUSTODIAN(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "registry",
        "get_NO_CUSTODIAN",
    )
    return int(returns[0])

def get_NO_UNDERWRITER(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "registry",
        "get_NO_UNDERWRITER",
    )
    return int(returns[0])

def get_market_counts(view: EconiaViewer) -> Any:
    returns = view.get_returns(
      "registry",
      "get_market_counts",
    )
    return returns[0]

def get_market_info(view: EconiaViewer, market_id: int) -> Any:
    returns = view.get_returns(
        "registry",
        "get_market_info",
        [],
        [Serializer.u64(market_id)]
    )
    return returns[0]

def get_recognized_market_id_base_coin(
    view: EconiaViewer,
    base_coin_type: str,
    quote_coin_type: str,
) -> int:
    returns = view.get_returns(
        "registry",
        "get_recognized_market_id_base_coin",
        [base_coin_type, quote_coin_type],
    )
    return int(returns[0])

def get_recognized_market_id_base_generic(
    view: EconiaViewer,
    quote_coin_type: str,
) -> int:
    returns = view.get_returns(
        "registry",
        "get_recognized_market_id_base_generic",
        [quote_coin_type],
    )
    return int(returns[0])

def has_recognized_market_base_coin_by_type(
    view: EconiaViewer,
    base_coin_type: str,
    quote_coin_type: str,
) -> bool:
    returns = view.get_returns(
        "registry",
        "has_recognized_market_base_coin_by_type",
        [base_coin_type, quote_coin_type],
    )
    return bool(returns[0])

def has_recognized_market_base_generic_by_type(
    view: EconiaViewer,
    quote_coin_type: str,
    base_name_generic: str,
) -> bool:
    returns = view.get_returns(
        "registry",
        "has_recognized_market_base_generic_by_type",
        [quote_coin_type],
        [Serializer.str(base_name_generic)]
    )
    return bool(returns[0])
