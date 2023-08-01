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
    """
    Calculate cost to upgrade `IntegratorFeeStore` to higher tier.

    Type Parameters:
    * `QuoteCoinType`: The quote coin type for market.
    * `UtilityCoinType`: The utility coin type.

    Parameters:
    * `integrator_address`: Integrator address.
    * `market_id`: Market ID for corresponding market.
    * `new_tier`: Tier to upgrade to.

    Returns:
    * `u64`: Cost, in utility coins, to upgrade to given tier,
      calculated as the difference between the cumulative activation
      cost for each tier. For example, if it costs 1000 to activate
      to tier 3 and 100 to activate to tier 1, it costs 900 to
      upgrade from tier 1 to tier 3.

    Aborts:
    * `E_NOT_AN_UPGRADE`: `new_tier` is not higher than the one
       that the `IntegratorFeeStore` is already activated to.
    * `E_TIER_COST_NOT_INCREASE`: Cumulative activation fee for new
      tier is not greater than that of current tier.

    Restrictions:
    * Restricted to private view function to prevent excessive
      public queries on an `IntegratorFeeStore` and thus transaction
      collisions with the matching engine.
    """
    returns = view.get_returns(
        "incentives",
        "get_cost_to_upgrade_integrator_fee_store_view",
        [quote_coin_type, utility_coin_type],
        [integrator_address.address.hex(), str(market_id), str(new_tier)],
    )
    return int(returns[0])


def get_custodian_registration_fee(view: EconiaViewer) -> int:
    """
    Return custodian registration fee.
    """
    returns = view.get_returns("incentives", "get_custodian_registration_fee")
    return int(returns[0])


def get_fee_share_divisor(view: EconiaViewer, tier: int) -> int:
    """
    Return integrator fee share divisor for `tier`.
    """
    returns = view.get_returns("incentives", "get_fee_share_divisor", [], [str(tier)])
    return int(returns[0])


def get_integrator_withdrawal_fee_view(
    view: EconiaViewer,
    quote_coin_type: str,
    integrator_address: AccountAddress,
    market_id: int,
) -> int:
    """
    Return withdrawal fee for given `integrator_address` and
    `market_id`.

    Restrictions:
    * Restricted to private view function to prevent excessive
      public queries on an `IntegratorFeeStore` and thus transaction
      collisions with the matching engine.
    """
    returns = view.get_returns(
        "incentives",
        "get_integrator_withdrawal_fee_view",
        [quote_coin_type],
        [
            integrator_address.address.hex(),
            market_id,
        ],
    )
    return int(returns[0])


def get_market_registration_fee(view: EconiaViewer) -> int:
    """
    Return market registration fee.
    """
    returns = view.get_returns(
        "incentives",
        "get_market_registration_fee",
    )
    return int(returns[0])


def get_n_fee_store_tiers(view: EconiaViewer) -> int:
    """
    Return number of fee store tiers.
    """
    returns = view.get_returns(
        "incentives",
        "get_n_fee_store_tiers",
    )
    return int(returns[0])


def get_taker_fee_divisor(view: EconiaViewer) -> int:
    """
    Return taker fee divisor.
    """
    returns = view.get_returns(
        "incentives",
        "get_taker_fee_divisor",
    )
    return int(returns[0])


def get_tier_activation_fee(view: EconiaViewer, tier: int) -> int:
    """
    Return fee to activate an `IntegratorFeeStore` to given `tier`.
    """
    returns = view.get_returns("incentives", "get_tier_activation_fee", [], [str(tier)])
    return int(returns[0])


def get_tier_withdrawal_fee(view: EconiaViewer, tier: int) -> int:
    """
    Return fee to withdraw from `IntegratorFeeStore` activated to
    given `tier`.
    """
    returns = view.get_returns("incentives", "get_tier_withdrawal_fee", [], [str(tier)])
    return int(returns[0])


def get_underwriter_registration_fee(view: EconiaViewer) -> int:
    """
    Return underwriter registration fee.
    """
    returns = view.get_returns(
        "incentives",
        "get_underwriter_registration_fee",
    )
    return int(returns[0])


def is_utility_coin_type(view: EconiaViewer, type: str) -> int:
    """
    Return `true` if `type` is the utility coin type.
    """
    returns = view.get_returns("incentives", "is_utility_coin_type", [type])
    return int(returns[0])
