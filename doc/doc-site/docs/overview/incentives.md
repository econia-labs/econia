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
1. The cumulative fee, denominated in the utility coin, to activate to the given tier.
1. The fee, denominated in the utility coin, to withdraw quote coins from an integrator's fee store.
   Charged so as to disincentivize excessively-frequent withdrawals and thus potential transaction collisions with the matching engine.

See the assorted [incentives module getters] for parameter lookup during runtime.

## Mainnet incentive parameters

Upon mainnet publication, Econia's incentive parameters were set to hard-coded genesis values as discussed in [issue 49].
The number of tiers cannot be decreased, which means that there must always be at least 7 tiers for the Econia mainnet deployment.

Since mainnet genesis, the incentive parameters have been modified via a community governance vote, with the actual values displayed under the [`IncentiveParameters`] resource at the [mainnet account address].

## Fee stores

When the [matching] engine calls [`assess_taker_fees()`], Econia assesses the flat taker fee defined at [`IncentiveParameters`], attempts to route a portion to the indicated integrator's [`IntegratorFeeStore`], then routes the remainder to an [`EconiaFeeStore`] for the market.
Integrators can then withdraw any fees they have collected via [`withdraw_integrator_fees()`].

:::caution

An integrator *must* register an [`IntegratorFeeStore`] before they can collect any fees, via any of the following:

- [`register_integrator_fee_store()`]
- [`register_integrator_fee_store_base_tier()`]
- [`register_integrator_fee_store_from_coinstore()`]

If they route volume through Econia without first registering an [`IntegratorFeeStore`], all generated taker fees will go to Econia.

:::

[incentives module documentation]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md
[incentives module getters]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/incentives.md#public-getters
[issue 49]: https://github.com/econia-labs/econia/issues/49
[mainnet account address]: ../welcome.md#account-addresses
[matching]: ./matching
[register a custodian capability]: ./registry#custodians
[register a market]: ./registry#markets
[register an underwriter capability]: ./registry#underwriters
[`assess_taker_fees()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_assess_taker_fees
[`econiafeestore`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_EconiaFeeStore
[`incentiveparameters`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_IncentiveParameters
[`integratorfeestoretierparameters`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_IntegratorFeeStoreTierParameters
[`integratorfeestore`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_IntegratorFeeStore
[`register_integrator_fee_store()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store
[`register_integrator_fee_store_base_tier()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_base_tier
[`register_integrator_fee_store_from_coinstore()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/registry.md#0xc0deb00c_registry_register_integrator_fee_store_from_coinstore
[`withdraw_integrator_fees()`]: https://github.com/econia-labs/econia/tree/main/src/move/econia/doc/incentives.md#0xc0deb00c_incentives_withdraw_integrator_fees
