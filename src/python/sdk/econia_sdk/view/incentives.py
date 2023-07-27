from aptos_sdk.account_address import AccountAddress

from econia_sdk.lib import EconiaViewer


def get_cost_to_upgrade_integrator_fee_store_view(
    view: EconiaViewer,
    quote_coin_type: str,
    utility_coin_type: str,
    integrator_address: AccountAddress,
    market_id: int,
    new_tier: int,
) -> int:
    returns = view.get_returns(
        "incentives",
        "get_cost_to_upgrade_integrator_fee_store_view",
        [quote_coin_type, utility_coin_type],
        [integrator_address.address.hex(), str(market_id), str(new_tier)],
    )
    return int(returns[0])


def get_custodian_registration_fee(view: EconiaViewer) -> int:
    returns = view.get_returns("incentives", "get_custodian_registration_fee")
    return int(returns[0])


def get_fee_share_divisor(view: EconiaViewer, tier: int) -> int:
    returns = view.get_returns(
        "incentives", "get_fee_share_divisor", [], [str(tier)]
    )
    return int(returns[0])


def get_integrator_withdrawal_fee_view(
    view: EconiaViewer,
    quote_coin_type: str,
    integrator_address: AccountAddress,
    market_id: int,
) -> int:
    returns = view.get_returns(
        "incentives",
        "get_integrator_withdrawal_fee_view",
        [quote_coin_type],
        [
            integrator_address.address.hex(),
        ],
    )
    return int(returns[0])


def get_market_registration_fee(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "incentives",
        "get_market_registration_fee",
    )
    return int(returns[0])


def get_n_fee_store_tiers(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "incentives",
        "get_n_fee_store_tiers",
    )
    return int(returns[0])


def get_taker_fee_divisor(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "incentives",
        "get_taker_fee_divisor",
    )
    return int(returns[0])


def get_tier_activation_fee(view: EconiaViewer, tier: int) -> int:
    returns = view.get_returns(
        "incentives", "get_tier_activation_fee", [], [str(tier)]
    )
    return int(returns[0])


def get_tier_withdrawal_fee(view: EconiaViewer, tier: int) -> int:
    returns = view.get_returns(
        "incentives", "get_tier_withdrawal_fee", [], [str(tier)]
    )
    return int(returns[0])


def get_underwriter_registration_fee(view: EconiaViewer) -> int:
    returns = view.get_returns(
        "incentives",
        "get_underwriter_registration_fee",
    )
    return int(returns[0])


def is_utility_coin_type(view: EconiaViewer, type: str) -> int:
    returns = view.get_returns("incentives", "is_utility_coin_type", [type])
    return int(returns[0])
