from typing import List, Optional

from aptos_sdk.account_address import AccountAddress

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


def get_market_counts(view: EconiaViewer) -> dict:
    returns = view.get_returns(
        "registry",
        "get_market_counts",
    )
    value = returns[0]
    return {
        "n_markets": int(value["n_markets"]),
        "n_recognized_markets": int(value["n_recognized_markets"]),
    }


class GetMarketInfoReturn(dict):
    def is_coin_market(self, viewer: EconiaViewer) -> bool:
        base_info = self["base_type"]
        is_econia = viewer.econia_address.hex() == base_info["package_address"]
        is_generic = (
            base_info["module_name"] == "registry"
            and base_info["type_name"] == "GenericAsset"
        )
        return not (is_econia and is_generic)

    def get_decimals_base(self, viewer: EconiaViewer):
        assert self.is_coin_market(
            viewer
        ), "Generic market has no decimals for base type!"
        return self._get_decimals(viewer, self["base_type"])

    def get_decimals_quote(self, viewer: EconiaViewer):
        return self._get_decimals(viewer, self["quote_type"])

    def _get_decimals(self, viewer: EconiaViewer, type_info: dict):
        request = f"{viewer.aptos_client.base_url}/view"
        address = type_info["package_address"].hex()
        module = type_info["module_name"]
        type_name = type_info["type_name"]
        response = viewer.aptos_client.client.post(
            request,
            json={
                "function": f"0x1::coin::decimals",
                "type_arguments": [f"{address}::{module}::{type_name}"],
                "arguments": [],
            },
        )

        if response.status_code >= 400:
            raise Exception(response.text, response.status_code)
        return int(response.json()[0])


def get_market_info(view: EconiaViewer, market_id: int) -> GetMarketInfoReturn:
    returns = view.get_returns(
        "registry", "get_market_info", [], [str(market_id)]
    )
    value = returns[0]
    return GetMarketInfoReturn(
        {
            "base_name_generic": value["base_name_generic"],
            "base_type": {
                "module_name": value["base_type"]["module_name"],
                "package_address": AccountAddress.from_hex(
                    value["base_type"]["package_address"]
                ),
                "type_name": value["base_type"]["type_name"],
            },
            "is_recognized": bool(value["is_recognized"]),
            "lot_size": int(value["lot_size"]),  # subunits of base
            "market_id": int(value["market_id"]),
            "min_size": int(value["min_size"]),
            "quote_type": {
                "module_name": value["quote_type"]["module_name"],
                "package_address": AccountAddress.from_hex(
                    value["quote_type"]["package_address"]
                ),
                "type_name": value["quote_type"]["type_name"],
            },
            "tick_size": int(value["tick_size"]),
            "underwriter_id": int(value["underwriter_id"]),
        }
    )


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
        [base_name_generic],
    )
    return bool(returns[0])


def get_market_id_base_coin(
    view: EconiaViewer,
    base_coin_type: str,
    quote_coin_type: str,
    lot_size: int,
    tick_size: int,
    min_size: int,
) -> Optional[int]:  # might be None
    returns = view.get_returns(
        "registry",
        "get_market_id_base_coin",
        [base_coin_type, quote_coin_type],
        [
            str(lot_size),
            str(tick_size),
            str(min_size),
        ],
    )
    opt_val = returns[0]["vec"]
    if len(opt_val) == 0:
        return None
    else:
        return int(opt_val[0])


def get_market_id_base_generic(
    view: EconiaViewer,
    quote_type: str,
    base_name_generic: str,
    lot_size: int,
    tick_size: int,
    min_size: int,
    underwriter_id: int = 0,
) -> Optional[int]:
    returns = view.get_returns(
        "registry",
        "get_market_id_base_generic",
        [quote_type],
        [
            base_name_generic,
            str(lot_size),
            str(tick_size),
            str(min_size),
            str(underwriter_id),
        ],
    )
    opt_val = returns[0]["vec"]
    if len(opt_val) == 0:
        return None
    else:
        return int(opt_val[0])


def get_market_registration_events(
    view: EconiaViewer, limit: Optional[int] = None
) -> List[dict]:
    events = view.get_events_by_handle(
        f"{view.econia_address.hex()}::registry::Registry",
        "market_registration_events",
        limit,
    )
    events_parsed = []
    for event in events:
        event_parsed = {
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
                "base_name_generic": event["data"]["base_name_generic"],
                "base_type": {
                    "account_address": AccountAddress.from_hex(
                        event["data"]["base_type"]["account_address"]
                    ),
                    "module_name": bytes.fromhex(
                        event["data"]["base_type"]["module_name"][2:]
                    ).decode("ascii"),
                    "struct_name": bytes.fromhex(
                        event["data"]["base_type"]["struct_name"][2:]
                    ).decode("ascii"),
                },
                "lot_size": int(event["data"]["lot_size"]),
                "market_id": int(event["data"]["market_id"]),
                "min_size": int(event["data"]["min_size"]),
                "quote_type": {
                    "account_address": AccountAddress.from_hex(
                        event["data"]["quote_type"]["account_address"]
                    ),
                    "module_name": bytes.fromhex(
                        event["data"]["quote_type"]["module_name"][2:]
                    ).decode("ascii"),
                    "struct_name": bytes.fromhex(
                        event["data"]["quote_type"]["struct_name"][2:]
                    ).decode("ascii"),
                },
                "tick_size": int(event["data"]["tick_size"]),
                "underwriter_id": int(event["data"]["underwriter_id"]),
            },
        }
        events_parsed.append(event_parsed)
    return events_parsed
