import { type BCS, type Types } from "aptos";
import { type MaybeHexString } from "aptos";

import { type AdvanceStyle, type Side } from "../types/order";
import { type Restriction } from "../types/order";
import { type SelfMatchBehavior } from "../types/order";
import { type EconiaClient } from ".";

export class EconiaTransactionBuilder {
  client: EconiaClient;
  retryAmount?: number;
  entry?: Types.EntryFunctionPayload;

  public constructor(client: EconiaClient) {
    this.client = client;
  }

  public setRetryAmount(retryAmount: number): EconiaTransactionBuilder {
    this.retryAmount = retryAmount;
    return this;
  }

  // Incentives entry functions

  public updateIncentives(
    utilityCoin: Types.MoveType,
    marketRegistrationFee: BCS.Uint64,
    underwriterRegistrationFee: BCS.Uint64,
    custodianRegistrationFee: BCS.Uint64,
    takerFeeDivisor: BCS.Uint64,
    integratorFeeStoreTiers: Array<Array<BCS.Uint64>>
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::incentives::update_incentives`,
      type_arguments: [utilityCoin],
      arguments: [
        marketRegistrationFee,
        underwriterRegistrationFee,
        custodianRegistrationFee,
        takerFeeDivisor,
        integratorFeeStoreTiers,
      ],
    };
    this.entry = entry;
    return this;
  }

  public upgradeIntegratorFeeStoreViaCoinstore(
    quoteCoin: Types.MoveType,
    utilityCoin: Types.MoveType,
    marketId: BCS.Uint64,
    newTier: BCS.Uint8
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::incentives::upgrade_integrator_fee_store_via_coinstore`,
      type_arguments: [quoteCoin, utilityCoin],
      arguments: [marketId, newTier],
    };
    this.entry = entry;
    return this;
  }

  public withdrawIntegratorFeesViaCoinstores(
    quoteCoin: Types.MoveType,
    utilityCoin: Types.MoveType,
    marketId: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::incentives::withdraw_integrator_fees_via_coinstores`,
      type_arguments: [quoteCoin, utilityCoin],
      arguments: [marketId],
    };
    this.entry = entry;
    return this;
  }

  // market entry functions

  public cancelAllOrdersUser(
    marketId: BCS.Uint64,
    side: Side
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::cancel_all_orders_user`,
      type_arguments: [],
      arguments: [marketId, side],
    };
    this.entry = entry;
    return this;
  }

  public cancelOrderUser(
    marketId: BCS.Uint64,
    side: Side,
    marketOrderId: BCS.Uint128
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::cancel_order_user`,
      type_arguments: [],
      arguments: [marketId, side, marketOrderId],
    };
    this.entry = entry;
    return this;
  }

  public changeOrderSizeUser(
    marketId: BCS.Uint64,
    side: Side,
    marketOrderId: BCS.Uint128,
    newSize: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::change_order_size_user`,
      type_arguments: [],
      arguments: [marketId, side, marketOrderId, newSize],
    };
    this.entry = entry;
    return this;
  }

  public placeLimitOrderPassiveAdvanceUserEntry(
    base: Types.MoveType,
    quote: Types.MoveType,
    marketId: BCS.Uint64,
    integrator: MaybeHexString,
    side: Side,
    size: BCS.Uint64,
    advanceStyle: AdvanceStyle,
    targetAdvanceAmount: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::place_limit_order_passive_advance_user_entry`,
      type_arguments: [base, quote],
      arguments: [
        marketId,
        integrator,
        side,
        size,
        advanceStyle,
        targetAdvanceAmount,
      ],
    };
    this.entry = entry;
    return this;
  }

  public placeLimitOrderUserEntry(
    base: Types.MoveType,
    quote: Types.MoveType,
    marketId: BCS.Uint64,
    integrator: MaybeHexString,
    side: Side,
    size: BCS.Uint64,
    price: BCS.Uint64,
    restriction: Restriction,
    selfMatchBehavior: SelfMatchBehavior
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::place_limit_order_user_entry`,
      type_arguments: [base, quote],
      arguments: [
        marketId,
        integrator,
        side,
        size,
        price,
        restriction,
        selfMatchBehavior,
      ],
    };
    this.entry = entry;
    return this;
  }

  public placeMarketOrderUserEntry(
    base: Types.MoveType,
    quote: Types.MoveType,
    marketId: BCS.Uint64,
    integrator: MaybeHexString,
    direction: boolean,
    minBase: BCS.Uint64,
    maxBase: BCS.Uint64,
    minQuote: BCS.Uint64,
    maxQuote: BCS.Uint64,
    limitPrice: BCS.Uint64,
    selfMatchBehavior: SelfMatchBehavior
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::place_market_order_user_entry`,
      type_arguments: [base, quote],
      arguments: [
        marketId,
        integrator,
        direction,
        minBase,
        maxBase,
        minQuote,
        maxQuote,
        limitPrice,
        selfMatchBehavior,
      ],
    };
    this.entry = entry;
    return this;
  }

  public registerMarketBaseCoinFromCoinstore(
    base: Types.MoveType,
    quote: Types.MoveType,
    utilityCoin: Types.MoveType,
    lotSize: BCS.Uint64,
    tickSize: BCS.Uint64,
    minSize: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::register_market_base_coin_from_coinstore`,
      type_arguments: [base, quote, utilityCoin],
      arguments: [lotSize, tickSize, minSize],
    };
    this.entry = entry;
    return this;
  }

  public swapBetweenCoinstoresEntry(
    base: Types.MoveType,
    quote: Types.MoveType,
    marketId: BCS.Uint64,
    integrator: MaybeHexString,
    direction: boolean,
    minBase: BCS.Uint64,
    maxBase: BCS.Uint64,
    minQuote: BCS.Uint64,
    maxQuote: BCS.Uint64,
    limitPrice: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::market::register_market_base_coin_from_coinstore`,
      type_arguments: [base, quote],
      arguments: [
        marketId,
        integrator,
        direction,
        minBase,
        maxBase,
        minQuote,
        maxQuote,
        limitPrice,
      ],
    };
    this.entry = entry;
    return this;
  }
}
