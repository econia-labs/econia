# Incentives

## General

As described in the [incentives module documentation], Econia is a permissionless system that mitigates denial-of-service (DoS) attacks by charging utility coins for assorted operations.

Econia also charges taker fees, denominated in the quote coin for a given market, which are distributed between integrators and Econia.
The share of taker fees distributed between an integrator and Econia, for a given market, is determined by the "tier" to which the integrator has "activated" their fee store:
when the matching engine fills a taker order, the integrator who facilitated the transaction has a portion of taker fees deposited to their fee store, and Econia gets the rest, with the split thereof determined by the integrator's fee store tier for the given market.

Econia does not charge maker fees.

## Parameters

Econia involves several major incentive parameters, defined at [`IncentiveParameters`]:

1. The utility coin type, set to `APT` at mainnet genesis and later switched to the Econia coin.
1. The fee, denominated in the utility coin, to [register a market].
1. The fee, denominated in the utility coin, to [register an underwriter capability].
1. The fee, denominated in the utility coin, to [register a custodian capability].
1. The taker fee divisor, denoting the portion of quote coins for a particular trade, paid by the taker, to be split between the integrator who facilitated the trade, and Econia.
   A taker fee divisor of 2000, for instance, implies a flat $\frac{100\%}{2000}  = 0.05\%$ taker fee, or 5 basis points.


[`IncentiveParameters`] also includes a vector of [`IntegratorFeeStoreTierParameters`], which define 3 parameters per tier:

1. The portion of the taker fee divisor reserved for an integrator activated to a given tier.
2. The cumulative fee, denominated in the utility coin, to activate to the given tier.
3. The fee, denominated in the utility coin, to withdraw quote coins from an integrator's fee store.
   Charged so as to disincentivize excessively-frequent withdrawals and thus potential transaction collisions with the matching engine.

See the assorted [incentives module getters] for parameter lookup during runtime.

## Genesis parameters

Upon module publication, Econia's incentive parameters will be set to genesis values that are calibrated against the market price of `APT`, denominated in US dollars (USD).
Later, the incentive parameters can be tuned to account for variations in market prices.

See [issue 49] for an in-depth discussion of genesis parameter value selection, and [commit `8f892b`] which calibrates against an approximate market price of 4 USD per `APT`:

| Incentive parameter          | Genesis value |
|------------------------------|---------------|
| Utility coin type            | `APT`         |
| Market registration fee      | 25 USD        |
| Underwriter registration fee | 0.01 USD      |
| Custodian registration fee   | 0.01 USD      |
| Taker fee divisor (as a %)   | 2000 (0.05%)  |

| Tier | Fee share (%) | Activation fee (USD) | Withdrawal fee (USD) |
|------|---------------|----------------------|----------------------|
| Base | 0.01          | Free                 | 0.20                 |
| 1    | 0.012         | 0.20                 | 0.19                 |
| 2    | 0.013         | 3.00                 | 0.18                 |
| 3    | 0.014         | 40                   | 0.17                 |
| 4    | 0.015         | 500                  | 0.16                 |
| 5    | 0.016         | 6000                 | 0.15                 |
| 6    | 0.017         | 70000                | 0.14                 |

For example, consider a hypothetical `APT/USDC` market:
by default, an integrator who routes traffic through Econia can collect 0.01% of the 0.05% taker fees collected on the market, but can collect 0.014% if they pay the 40 USD equivalent fee to activate to tier 3.

Hence if they route five million USD of volume through Econia on the given market, at the base tier they will only collect 500 `USDC` in fees, but if they activate to tier 3 they will collect 700 `USDC`, paying off the $40 USD equivalent charged for activation and thus profiting $160 for activating to tier 3.

## Fee stores

When the [matching] engine calls [`assess_taker_fees()`], Econia assesses the flat taker fee defined at [`IncentiveParameters`], attempts to route a portion to the indicated integrator's [`IntegratorFeeStore`], then routes the remainder to an [`EconiaFeeStore`] for the market.
Integrators can then withdraw any fees they have collected via [`withdraw_integrator_fees()`].

:::caution

An integrator *must* register an [`IntegratorFeeStore`] before they can collect any fees, via any of the following:

* [`register_integrator_fee_store()`]
* [`register_integrator_fee_store_base_tier()`]
* [`register_integrator_fee_store_from_coinstore()`]

If they route volume through Econia without first registering an [`IntegratorFeeStore`], all generated taker fees will go to Econia.

:::

<!---Alphabetized reference links-->

[commit `8f892b`]:                                  https://github.com/econia-labs/econia/commit/8f892b96e2cde646837fd64330699b92736a3bc7
[incentives module documentation]:                  https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md
[incentives module getters]:                        https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#public-getters
[issue 49]:                                         https://github.com/econia-labs/econia/issues/49
[matching]:                                         matching
[register a market]:                                registry#markets
[register a custodian capability]:                  registry#custodians
[register an underwriter capability]:               registry#underwriters
[`EconiaFeeStore`]:                                 https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_EconiaFeeStore
[`IncentiveParameters`]:                            https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_IncentiveParameters
[`IntegratorFeeStore`]:                             https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_IntegratorFeeStore
[`IntegratorFeeStoreTierParameters`]:               https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_IntegratorFeeStoreTierParameters
[`assess_taker_fees()`]:                            https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_assess_taker_fees
[`register_integrator_fee_store()`]:                https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store
[`register_integrator_fee_store_base_tier()`]:      https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_base_tier
[`register_integrator_fee_store_from_coinstore()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_from_coinstore
[`withdraw_integrator_fees()`]:                     https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_withdraw_integrator_fees