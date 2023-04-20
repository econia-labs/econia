import { type BCS, type Types } from "aptos";
import { type MaybeHexString } from "aptos";

import { type AdvanceStyle, type Side } from "../types/order";
import { type Restriction } from "../types/order";
import { type SelfMatchBehavior } from "../types/order";
import { type EconiaClient } from ".";

export class EconiaTransactionBuilder {
  client: EconiaClient;
  entry?: Types.EntryFunctionPayload;

  public constructor(client: EconiaClient) {
    this.client = client;
  }

  // Incentives entry functions

  public updateIncentives(
    utilityCoin: Types.MoveType,
    marketRegistrationFee: BCS.Uint64,
    underwriterRegistrationFee: BCS.Uint64,
    custodianRegistrationFee: BCS.Uint64,
    takerFeeDivisor: BCS.Uint64,
    integratorFeeStoreTiers: BCS.Uint64[][]
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

  // registry functions

  public registerIntegratorFeeStoreBaseTier(
    quote: Types.MoveType,
    utilityCoin: Types.MoveType,
    marketId: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::registry::register_integrator_fee_store_base_tier`,
      type_arguments: [quote, utilityCoin],
      arguments: [marketId],
    };
    this.entry = entry;
    return this;
  }

  public registerIntegratorFeeStoreFromCoinstore(
    quote: Types.MoveType,
    utilityCoin: Types.MoveType,
    marketId: BCS.Uint64,
    tier: BCS.Uint8
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::registry::register_integrator_fee_store_from_coinstore`,
      type_arguments: [quote, utilityCoin],
      arguments: [marketId, tier],
    };
    this.entry = entry;
    return this;
  }

  public removeRecognizedMarkets(
    marketIds: BCS.Uint64[]
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::registry::remove_recognized_markets`,
      type_arguments: [],
      arguments: [marketIds],
    };
    this.entry = entry;
    return this;
  }

  public setRecognizedMarket(marketId: BCS.Uint64): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::registry::set_recognized_market`,
      type_arguments: [],
      arguments: [marketId],
    };
    this.entry = entry;
    return this;
  }

  public depositFromCoinstore(
    coin: Types.MoveType,
    marketId: BCS.Uint64,
    custodianId: BCS.Uint64,
    amount: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::user::deposit_from_coinstore`,
      type_arguments: [coin],
      arguments: [marketId, custodianId, amount],
    };
    this.entry = entry;
    return this;
  }

  public registerMarketAccount(
    base: Types.MoveType,
    quote: Types.MoveType,
    marketId: BCS.Uint64,
    custodianId: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::user::register_market_account`,
      type_arguments: [base, quote],
      arguments: [marketId, custodianId],
    };
    this.entry = entry;
    return this;
  }

  public registerMarketAccountGenericBase(
    quote: Types.MoveType,
    marketId: BCS.Uint64,
    custodianId: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::user::register_market_account_generic_base`,
      type_arguments: [quote],
      arguments: [marketId, custodianId],
    };
    this.entry = entry;
    return this;
  }

  public withdrawToCoinstore(
    coin: Types.MoveType,
    marketId: BCS.Uint64,
    amount: BCS.Uint64
  ): EconiaTransactionBuilder {
    const entry: Types.EntryFunctionPayload = {
      function: `${this.client.econiaAddress}::user::withdraw_to_coinstore`,
      type_arguments: [coin],
      arguments: [marketId, amount],
    };
    this.entry = entry;
    return this;
  }

  public async submitTx(): Promise<Types.Transaction> {
    if (!this.entry) {
      throw new Error("No entry function set");
    }
    const tx = await this.client.aptosClient.generateTransaction(
      this.client.userAccount.address(),
      this.entry
    );
    const signedTx = await this.client.aptosClient.signTransaction(
      this.client.userAccount,
      tx
    );
    const pendingTx = await this.client.aptosClient.submitTransaction(signedTx);
    const result = await this.client.aptosClient.waitForTransactionWithResult(
      pendingTx.hash
    );
    return result;
  }
}
