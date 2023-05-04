import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import { FieldDeclType, TypeParamDeclType } from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Econia from "../econia";
import * as Stdlib from "../stdlib";
export const packageName = "Econia Wrappers";
export const moduleAddress = new HexString(
  "0x5ccea8ed10638110d0f5df241b5f68512ba09916a7567bbb939b4ff4fbca11ef"
);
export const moduleName = "wrappers";

export const BID = false;
export const BUY = false;
export const CANCEL_BOTH: U8 = u8("1");
export const CANCEL_MAKER: U8 = u8("2");
export const CANCEL_TAKER: U8 = u8("3");
export const NO_CUSTODIAN: U64 = u64("0");
export const SHIFT_MARKET_ID: U8 = u8("64");

export function before_order_placement_(
  user: HexString,
  deposit_amount: U64,
  market_id: U64,
  side: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  let user_addr, user_market_account_id;
  user_addr = Stdlib.Signer.address_of_(user, $c);
  user_market_account_id = Econia.User.get_market_account_id_(
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $c
  );
  if (
    !Econia.User.has_market_account_by_market_account_id_(
      $.copy(user_addr),
      $.copy(user_market_account_id),
      $c
    )
  ) {
    Econia.User.register_market_account_(
      user,
      $.copy(market_id),
      $.copy(NO_CUSTODIAN),
      $c,
      [$p[0], $p[1]]
    );
  } else {
  }
  if (side == $.copy(BID)) {
    Econia.User.deposit_from_coinstore_(
      user,
      $.copy(market_id),
      $.copy(NO_CUSTODIAN),
      $.copy(deposit_amount),
      $c,
      [$p[1]]
    );
    if (!Stdlib.Coin.is_account_registered_($.copy(user_addr), $c, [$p[0]])) {
      Stdlib.Coin.register_(user, $c, [$p[0]]);
    } else {
    }
  } else {
    Econia.User.deposit_from_coinstore_(
      user,
      $.copy(market_id),
      $.copy(NO_CUSTODIAN),
      $.copy(deposit_amount),
      $c,
      [$p[0]]
    );
    if (!Stdlib.Coin.is_account_registered_($.copy(user_addr), $c, [$p[1]])) {
      Stdlib.Coin.register_(user, $c, [$p[1]]);
    } else {
    }
  }
  return;
}

export function place_limit_order_user_entry_(
  user: HexString,
  deposit_amount: U64,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behaviour: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  before_order_placement_(
    user,
    $.copy(deposit_amount),
    $.copy(market_id),
    side,
    $c,
    [$p[0], $p[1]]
  );
  Econia.Market.place_limit_order_user_entry_(
    user,
    $.copy(market_id),
    $.copy(integrator),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(restriction),
    $.copy(self_match_behaviour),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_place_limit_order_user_entry(
  deposit_amount: U64,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behaviour: U8,
  $p: TypeTag[] /* <BaseType, QuoteType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x5ccea8ed10638110d0f5df241b5f68512ba09916a7567bbb939b4ff4fbca11ef"
    ),
    "wrappers",
    "place_limit_order_user_entry",
    typeParamStrings,
    [
      deposit_amount,
      market_id,
      integrator,
      side,
      size,
      price,
      restriction,
      self_match_behaviour,
    ],
    isJSON
  );
}

export function place_market_order_user_entry_(
  user: HexString,
  deposit_amount: U64,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behaviour: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  let base_traded, quote_traded;
  before_order_placement_(
    user,
    $.copy(deposit_amount),
    $.copy(market_id),
    !direction,
    $c,
    [$p[0], $p[1]]
  );
  [base_traded, quote_traded] = Econia.Market.place_market_order_user_(
    user,
    $.copy(market_id),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    $.copy(self_match_behaviour),
    $c,
    [$p[0], $p[1]]
  );
  if (direction == $.copy(BUY)) {
    Econia.User.withdraw_to_coinstore_(
      user,
      $.copy(market_id),
      $.copy(base_traded),
      $c,
      [$p[0]]
    );
  } else {
    Econia.User.withdraw_to_coinstore_(
      user,
      $.copy(market_id),
      $.copy(quote_traded),
      $c,
      [$p[1]]
    );
  }
  return;
}

export function buildPayload_place_market_order_user_entry(
  deposit_amount: U64,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behaviour: U8,
  $p: TypeTag[] /* <BaseType, QuoteType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x5ccea8ed10638110d0f5df241b5f68512ba09916a7567bbb939b4ff4fbca11ef"
    ),
    "wrappers",
    "place_market_order_user_entry",
    typeParamStrings,
    [
      deposit_amount,
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      self_match_behaviour,
    ],
    isJSON
  );
}

export function loadParsers(repo: AptosParserRepo) {}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {}
  get moduleAddress() {
    {
      return moduleAddress;
    }
  }
  get moduleName() {
    {
      return moduleName;
    }
  }
  payload_place_limit_order_user_entry(
    deposit_amount: U64,
    market_id: U64,
    integrator: HexString,
    side: boolean,
    size: U64,
    price: U64,
    restriction: U8,
    self_match_behaviour: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_place_limit_order_user_entry(
      deposit_amount,
      market_id,
      integrator,
      side,
      size,
      price,
      restriction,
      self_match_behaviour,
      $p,
      isJSON
    );
  }
  async place_limit_order_user_entry(
    _account: AptosAccount,
    deposit_amount: U64,
    market_id: U64,
    integrator: HexString,
    side: boolean,
    size: U64,
    price: U64,
    restriction: U8,
    self_match_behaviour: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_place_limit_order_user_entry(
      deposit_amount,
      market_id,
      integrator,
      side,
      size,
      price,
      restriction,
      self_match_behaviour,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_place_market_order_user_entry(
    deposit_amount: U64,
    market_id: U64,
    integrator: HexString,
    direction: boolean,
    min_base: U64,
    max_base: U64,
    min_quote: U64,
    max_quote: U64,
    limit_price: U64,
    self_match_behaviour: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_place_market_order_user_entry(
      deposit_amount,
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      self_match_behaviour,
      $p,
      isJSON
    );
  }
  async place_market_order_user_entry(
    _account: AptosAccount,
    deposit_amount: U64,
    market_id: U64,
    integrator: HexString,
    direction: boolean,
    min_base: U64,
    max_base: U64,
    min_quote: U64,
    max_quote: U64,
    limit_price: U64,
    self_match_behaviour: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_place_market_order_user_entry(
      deposit_amount,
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      self_match_behaviour,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
