import { type BCS, type Types } from "aptos";
import { type MaybeHexString } from "aptos";

import {
  type AdvanceStyle,
  type Restriction,
  type SelfMatchBehavior,
  type Side,
} from "./order";
import {
  advanceStyleToNumber,
  restrictionToNumber,
  selfMatchBehaviorToNumber,
  sideToBoolean,
  sideToNumber,
} from "./utils";

// Incentives entry functions

export const updateIncentives = (
  econiaAddress: MaybeHexString,
  utilityCoin: Types.MoveType,
  marketRegistrationFee: BCS.Uint64,
  underwriterRegistrationFee: BCS.Uint64,
  custodianRegistrationFee: BCS.Uint64,
  takerFeeDivisor: BCS.Uint64,
  integratorFeeStoreTiers: BCS.Uint64[][]
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::incentives::update_incentives`,
  type_arguments: [utilityCoin],
  arguments: [
    marketRegistrationFee,
    underwriterRegistrationFee,
    custodianRegistrationFee,
    takerFeeDivisor,
    integratorFeeStoreTiers,
  ],
});

export const upgradeIntegratorFeeStoreViaCoinstore = (
  econiaAddress: MaybeHexString,
  quoteCoin: Types.MoveType,
  utilityCoin: Types.MoveType,
  marketId: BCS.Uint64,
  newTier: BCS.Uint8
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::incentives::upgrade_integrator_fee_store_via_coinstore`,
  type_arguments: [quoteCoin, utilityCoin],
  arguments: [marketId, newTier],
});

export const withdrawIntegratorFeesViaCoinstores = (
  econiaAddress: MaybeHexString,
  quoteCoin: Types.MoveType,
  utilityCoin: Types.MoveType,
  marketId: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::incentives::withdraw_integrator_fees_via_coinstores`,
  type_arguments: [quoteCoin, utilityCoin],
  arguments: [marketId],
});

// market entry functions

export const cancelAllOrdersUser = (
  econiaAddress: MaybeHexString,
  marketId: BCS.Uint64,
  side: Side
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::cancel_all_orders_user`,
  type_arguments: [],
  arguments: [marketId, sideToNumber(side)],
});

export const cancelOrderUser = (
  econiaAddress: MaybeHexString,
  marketId: BCS.Uint64,
  side: Side,
  marketOrderId: BCS.Uint128
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::cancel_order_user`,
  type_arguments: [],
  arguments: [marketId, sideToNumber(side), marketOrderId],
});

export const changeOrderSizeUser = (
  econiaAddress: MaybeHexString,
  marketId: BCS.Uint64,
  side: Side,
  marketOrderId: BCS.Uint128,
  newSize: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::change_order_size_user`,
  type_arguments: [],
  arguments: [marketId, sideToNumber(side), marketOrderId, newSize],
});

export const placeLimitOrderPassiveAdvanceUserEntry = (
  econiaAddress: MaybeHexString,
  base: Types.MoveType,
  quote: Types.MoveType,
  marketId: BCS.Uint64,
  integrator: MaybeHexString,
  side: Side,
  size: BCS.Uint64,
  advanceStyle: AdvanceStyle,
  targetAdvanceAmount: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::place_limit_order_passive_advance_user_entry`,
  type_arguments: [base, quote],
  arguments: [
    marketId,
    integrator,
    sideToNumber(side),
    size,
    advanceStyleToNumber(advanceStyle),
    targetAdvanceAmount,
  ],
});

export const placeLimitOrderUserEntry = (
  econiaAddress: MaybeHexString,
  base: Types.MoveType,
  quote: Types.MoveType,
  marketId: BCS.Uint64,
  integrator: MaybeHexString,
  side: Side,
  size: BCS.Uint64,
  price: BCS.Uint64,
  restriction: Restriction,
  selfMatchBehavior: SelfMatchBehavior
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::place_limit_order_user_entry`,
  type_arguments: [base, quote],
  arguments: [
    marketId,
    integrator,
    sideToBoolean(side),
    size,
    price,
    restrictionToNumber(restriction),
    selfMatchBehaviorToNumber(selfMatchBehavior),
  ],
});

export const placeMarketOrderUserEntry = (
  econiaAddress: MaybeHexString,
  base: Types.MoveType,
  quote: Types.MoveType,
  marketId: BCS.Uint64,
  integrator: MaybeHexString,
  side: Side,
  size: BCS.Uint64,
  selfMatchBehavior: SelfMatchBehavior
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::place_market_order_user_entry`,
  type_arguments: [base, quote],
  arguments: [
    marketId,
    integrator,
    sideToBoolean(side),
    size,
    selfMatchBehaviorToNumber(selfMatchBehavior),
  ],
});

export const registerMarketBaseCoinFromCoinstore = (
  econiaAddress: MaybeHexString,
  base: Types.MoveType,
  quote: Types.MoveType,
  utilityCoin: Types.MoveType,
  lotSize: BCS.Uint64,
  tickSize: BCS.Uint64,
  minSize: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::register_market_base_coin_from_coinstore`,
  type_arguments: [base, quote, utilityCoin],
  arguments: [lotSize, tickSize, minSize],
});

export const swapBetweenCoinstoresEntry = (
  econiaAddress: MaybeHexString,
  base: Types.MoveType,
  quote: Types.MoveType,
  marketId: BCS.Uint64,
  integrator: MaybeHexString,
  side: Side,
  minBase: BCS.Uint64,
  maxBase: BCS.Uint64,
  minQuote: BCS.Uint64,
  maxQuote: BCS.Uint64,
  limitPrice: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::market::register_market_base_coin_from_coinstore`,
  type_arguments: [base, quote],
  arguments: [
    marketId,
    integrator,
    sideToBoolean(side),
    minBase,
    maxBase,
    minQuote,
    maxQuote,
    limitPrice,
  ],
});

// registry functions

export const registerIntegratorFeeStoreBaseTier = (
  econiaAddress: MaybeHexString,
  quote: Types.MoveType,
  utilityCoin: Types.MoveType,
  marketId: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::registry::register_integrator_fee_store_base_tier`,
  type_arguments: [quote, utilityCoin],
  arguments: [marketId],
});

export const registerIntegratorFeeStoreFromCoinstore = (
  econiaAddress: MaybeHexString,
  quote: Types.MoveType,
  utilityCoin: Types.MoveType,
  marketId: BCS.Uint64,
  tier: BCS.Uint8
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::registry::register_integrator_fee_store_from_coinstore`,
  type_arguments: [quote, utilityCoin],
  arguments: [marketId, tier],
});

export const removeRecognizedMarkets = (
  econiaAddress: MaybeHexString,
  marketIds: BCS.Uint64[]
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::registry::remove_recognized_markets`,
  type_arguments: [],
  arguments: [marketIds],
});

export const setRecognizedMarket = (
  econiaAddress: MaybeHexString,
  marketId: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::registry::set_recognized_market`,
  type_arguments: [],
  arguments: [marketId],
});

export const depositFromCoinstore = (
  econiaAddress: MaybeHexString,
  coin: Types.MoveType,
  marketId: BCS.Uint64,
  custodianId: BCS.Uint64,
  amount: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::user::deposit_from_coinstore`,
  type_arguments: [coin],
  arguments: [marketId, custodianId, amount],
});

export const registerMarketAccount = (
  econiaAddress: MaybeHexString,
  base: Types.MoveType,
  quote: Types.MoveType,
  marketId: BCS.Uint64,
  custodianId: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::user::register_market_account`,
  type_arguments: [base, quote],
  arguments: [marketId, custodianId],
});

export const registerMarketAccountGenericBase = (
  econiaAddress: MaybeHexString,
  quote: Types.MoveType,
  marketId: BCS.Uint64,
  custodianId: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::user::register_market_account_generic_base`,
  type_arguments: [quote],
  arguments: [marketId, custodianId],
});

export const withdrawToCoinstore = (
  econiaAddress: MaybeHexString,
  coin: Types.MoveType,
  marketId: BCS.Uint64,
  amount: BCS.Uint64
): Types.EntryFunctionPayload => ({
  function: `${econiaAddress}::user::withdraw_to_coinstore`,
  type_arguments: [coin],
  arguments: [marketId, amount],
});
