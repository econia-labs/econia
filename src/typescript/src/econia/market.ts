import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_framework from "../aptos_framework";
import * as Std from "../std";
import * as Capability from "./capability";
import * as Critbit from "./critbit";
import * as Order_id from "./order_id";
import * as Registry from "./registry";
import * as User from "./user";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "market";

export const ASK : boolean = true;
export const BID : boolean = false;
export const BUY : boolean = true;
export const E_BOOK_EXISTS : U64 = u64("0");
export const E_CROSSED_SPREAD : U64 = u64("8");
export const E_ECONIA_CAPABILITY_STORE_EXISTS : U64 = u64("2");
export const E_INVALID_CUSTODIAN : U64 = u64("7");
export const E_INVALID_USER : U64 = u64("6");
export const E_NOT_ECONIA : U64 = u64("1");
export const E_NO_ECONIA_CAPABILITY_STORE : U64 = u64("3");
export const E_NO_ORDER_BOOK : U64 = u64("4");
export const E_NO_SUCH_ORDER : U64 = u64("5");
export const HI_64 : U64 = u64("18446744073709551615");
export const LEFT : boolean = true;
export const MAX_BID_DEFAULT : U128 = u128("0");
export const MIN_ASK_DEFAULT : U128 = u128("340282366920938463463374607431768211455");
export const NO_CUSTODIAN : U64 = u64("0");
export const RIGHT : boolean = false;
export const SELL : boolean = false;


export class EconiaCapabilityStore 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "EconiaCapabilityStore";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "econia_capability", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "capability", "EconiaCapability", []) }];

  econia_capability: Capability.EconiaCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.econia_capability = proto['econia_capability'] as Capability.EconiaCapability;
  }

  static EconiaCapabilityStoreParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : EconiaCapabilityStore {
    const proto = $.parseStructProto(data, typeTag, repo, EconiaCapabilityStore);
    return new EconiaCapabilityStore(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, EconiaCapabilityStore, typeParams);
    return result as unknown as EconiaCapabilityStore;
  }
}

export class Order 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Order";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "base_parcels", typeTag: AtomicTypeTag.U64 },
  { name: "user", typeTag: AtomicTypeTag.Address },
  { name: "custodian_id", typeTag: AtomicTypeTag.U64 }];

  base_parcels: U64;
  user: HexString;
  custodian_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_parcels = proto['base_parcels'] as U64;
    this.user = proto['user'] as HexString;
    this.custodian_id = proto['custodian_id'] as U64;
  }

  static OrderParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Order {
    const proto = $.parseStructProto(data, typeTag, repo, Order);
    return new Order(proto, typeTag);
  }

}

export class OrderBook 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OrderBook";
  static typeParameters: TypeParamDeclType[] = [
    { name: "B", isPhantom: true },
    { name: "Q", isPhantom: true },
    { name: "E", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "scale_factor", typeTag: AtomicTypeTag.U64 },
  { name: "asks", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "CritBitTree", [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]) },
  { name: "bids", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "CritBitTree", [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]) },
  { name: "min_ask", typeTag: AtomicTypeTag.U128 },
  { name: "max_bid", typeTag: AtomicTypeTag.U128 },
  { name: "counter", typeTag: AtomicTypeTag.U64 }];

  scale_factor: U64;
  asks: Critbit.CritBitTree;
  bids: Critbit.CritBitTree;
  min_ask: U128;
  max_bid: U128;
  counter: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.scale_factor = proto['scale_factor'] as U64;
    this.asks = proto['asks'] as Critbit.CritBitTree;
    this.bids = proto['bids'] as Critbit.CritBitTree;
    this.min_ask = proto['min_ask'] as U128;
    this.max_bid = proto['max_bid'] as U128;
    this.counter = proto['counter'] as U64;
  }

  static OrderBookParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OrderBook {
    const proto = $.parseStructProto(data, typeTag, repo, OrderBook);
    return new OrderBook(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, OrderBook, typeParams);
    return result as unknown as OrderBook;
  }

  book_orders_sdk() {
    const cache = new DummyCache();
    const tags = (this.typeTag as StructTag).typeParams;
    return book_orders_sdk_(this, cache, tags);
  }

  book_price_levels_sdk() {
    const cache = new DummyCache();
    const tags = (this.typeTag as StructTag).typeParams;
    return book_price_levels_sdk_(this, cache, tags);
  }

}

export class PriceLevel 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "PriceLevel";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "price", typeTag: AtomicTypeTag.U64 },
  { name: "base_parcels", typeTag: AtomicTypeTag.U64 }];

  price: U64;
  base_parcels: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.price = proto['price'] as U64;
    this.base_parcels = proto['base_parcels'] as U64;
  }

  static PriceLevelParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PriceLevel {
    const proto = $.parseStructProto(data, typeTag, repo, PriceLevel);
    return new PriceLevel(proto, typeTag);
  }

}

export class SimpleOrder 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "SimpleOrder";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "price", typeTag: AtomicTypeTag.U64 },
  { name: "base_parcels", typeTag: AtomicTypeTag.U64 }];

  price: U64;
  base_parcels: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.price = proto['price'] as U64;
    this.base_parcels = proto['base_parcels'] as U64;
  }

  static SimpleOrderParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : SimpleOrder {
    const proto = $.parseStructProto(data, typeTag, repo, SimpleOrder);
    return new SimpleOrder(proto, typeTag);
  }

}
export function book_orders_sdk_ (
  order_book_ref_mut: OrderBook,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [SimpleOrder[], SimpleOrder[]] {
  return [get_orders_sdk_(order_book_ref_mut, ASK, $c, [$p[0], $p[1], $p[2]]), get_orders_sdk_(order_book_ref_mut, BID, $c, [$p[0], $p[1], $p[2]])];
}

export function book_price_levels_sdk_ (
  order_book_ref_mut: OrderBook,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [PriceLevel[], PriceLevel[]] {
  return [get_price_levels_sdk_(get_orders_sdk_(order_book_ref_mut, ASK, $c, [$p[0], $p[1], $p[2]]), $c), get_price_levels_sdk_(get_orders_sdk_(order_book_ref_mut, BID, $c, [$p[0], $p[1], $p[2]]), $c)];
}

export function cancel_limit_order_ (
  user: HexString,
  host: HexString,
  custodian_id: U64,
  side: boolean,
  order_id: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$10, temp$11, temp$12, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, order_book_ref_mut, tree_ref_mut;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host))) {
    throw $.abortCode(E_NO_ORDER_BOOK);
  }
  order_book_ref_mut = $c.borrow_global_mut<OrderBook>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host));
  if ((side == ASK)) {
    temp$1 = order_book_ref_mut.asks;
  }
  else{
    temp$1 = order_book_ref_mut.bids;
  }
  tree_ref_mut = temp$1;
  [temp$2, temp$3] = [tree_ref_mut, $.copy(order_id)];
  if (!Critbit.has_key_(temp$2, temp$3, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])])) {
    throw $.abortCode(E_NO_SUCH_ORDER);
  }
  let { user: order_user, custodian_id: order_custodian_id } = Critbit.pop_(tree_ref_mut, $.copy(order_id), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
  if (!(($.copy(user)).hex() === ($.copy(order_user)).hex())) {
    throw $.abortCode(E_INVALID_USER);
  }
  if (!($.copy(custodian_id)).eq(($.copy(order_custodian_id)))) {
    throw $.abortCode(E_INVALID_CUSTODIAN);
  }
  if ((side == ASK)) {
    temp$4 = ($.copy(order_id)).eq(($.copy(order_book_ref_mut.min_ask)));
  }
  else{
    temp$4 = false;
  }
  if (temp$4) {
    if (Critbit.is_empty_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])])) {
      temp$5 = MIN_ASK_DEFAULT;
    }
    else{
      temp$5 = Critbit.min_key_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
    }
    order_book_ref_mut.min_ask = temp$5;
  }
  else{
    if ((side == BID)) {
      temp$6 = ($.copy(order_id)).eq(($.copy(order_book_ref_mut.max_bid)));
    }
    else{
      temp$6 = false;
    }
    if (temp$6) {
      if (Critbit.is_empty_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])])) {
        temp$7 = MAX_BID_DEFAULT;
      }
      else{
        temp$7 = Critbit.max_key_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
      }
      order_book_ref_mut.max_bid = temp$7;
    }
    else{
    }
  }
  temp$12 = $.copy(user);
  temp$11 = $.copy(custodian_id);
  temp$10 = side;
  temp$9 = $.copy(order_id);
  temp$8 = get_econia_capability_($c);
  User.remove_order_internal_(temp$12, temp$11, temp$10, temp$9, temp$8, $c, [$p[0], $p[1], $p[2]]);
  return;
}

export function cancel_limit_order_custodian_ (
  user: HexString,
  host: HexString,
  side: boolean,
  order_id: U128,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let custodian_id;
  custodian_id = Registry.custodian_id_(custodian_capability_ref, $c);
  cancel_limit_order_($.copy(user), $.copy(host), $.copy(custodian_id), side, $.copy(order_id), $c, [$p[0], $p[1], $p[2]]);
  return;
}

export function cancel_limit_order_user_ (
  user: HexString,
  host: HexString,
  side: boolean,
  order_id: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  cancel_limit_order_(Std.Signer.address_of_(user, $c), $.copy(host), NO_CUSTODIAN, side, $.copy(order_id), $c, [$p[0], $p[1], $p[2]]);
  return;
}


export function buildPayload_cancel_limit_order_user (
  host: HexString,
  side: boolean,
  order_id: U128,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::cancel_limit_order_user",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(side),
      $.payloadArg(order_id),
    ]
  );

}

export function fill_market_order_ (
  order_book_ref_mut: OrderBook,
  scale_factor: U64,
  style: boolean,
  max_base_parcels: U64,
  max_quote_units: U64,
  base_coins_ref_mut: Aptos_framework.Coin.Coin,
  quote_coins_ref_mut: Aptos_framework.Coin.Coin,
  econia_capability_ref: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, base_parcels_to_fill, n_orders, side, spread_maker_ref_mut, traversal_direction, tree_ref_mut;
  if (($.copy(max_base_parcels)).eq((u64("0")))) {
    temp$2 = true;
  }
  else{
    if ((style == BUY)) {
      temp$1 = ($.copy(max_quote_units)).eq((u64("0")));
    }
    else{
      temp$1 = false;
    }
    temp$2 = temp$1;
  }
  if (temp$2) {
    return;
  }
  else{
  }
  [base_parcels_to_fill, side, tree_ref_mut, spread_maker_ref_mut, n_orders, traversal_direction] = fill_market_order_init_(order_book_ref_mut, style, $.copy(max_base_parcels), $c, [$p[0], $p[1], $p[2]]);
  if (($.copy(n_orders)).neq(u64("0"))) {
    fill_market_order_traverse_loop_(style, side, $.copy(scale_factor), tree_ref_mut, traversal_direction, $.copy(n_orders), spread_maker_ref_mut, $.copy(base_parcels_to_fill), base_coins_ref_mut, quote_coins_ref_mut, econia_capability_ref, $c, [$p[0], $p[1], $p[2]]);
  }
  else{
  }
  return;
}

export function fill_market_order_break_cleanup_ (
  null_order: Order,
  spread_maker_ref_mut: U128,
  new_spread_maker: U128,
  should_pop: boolean,
  tree_ref_mut: Critbit.CritBitTree,
  target_order_id: U128,
  $c: AptosDataCache,
): void {
  null_order;
  $.set(spread_maker_ref_mut, $.copy(new_spread_maker));
  if (should_pop) {
    Critbit.pop_(tree_ref_mut, $.copy(target_order_id), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
  }
  else{
  }
  return;
}

export function fill_market_order_check_base_parcels_to_fill_ (
  style: boolean,
  target_price: U64,
  quote_coins_ref: Aptos_framework.Coin.Coin,
  target_order_ref_mut: Order,
  base_parcels_to_fill_ref_mut: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Q>*/
): void {
  let base_parcels_can_afford;
  if ((style == SELL)) {
    return;
  }
  else{
  }
  base_parcels_can_afford = (Aptos_framework.Coin.value_(quote_coins_ref, $c, [$p[0]])).div($.copy(target_price));
  if (($.copy(base_parcels_can_afford)).lt($.copy(target_order_ref_mut.base_parcels))) {
    if (($.copy(base_parcels_can_afford)).lt($.copy(base_parcels_to_fill_ref_mut))) {
      $.set(base_parcels_to_fill_ref_mut, $.copy(base_parcels_can_afford));
    }
    else{
    }
  }
  else{
  }
  return;
}

export function fill_market_order_custodian_ (
  user: HexString,
  host: HexString,
  style: boolean,
  max_base_parcels: U64,
  max_quote_units: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let custodian_id;
  custodian_id = Registry.custodian_id_(custodian_capability_ref, $c);
  fill_market_order_from_market_account_($.copy(user), $.copy(host), $.copy(custodian_id), style, $.copy(max_base_parcels), $.copy(max_quote_units), $c, [$p[0], $p[1], $p[2]]);
  return;
}

export function fill_market_order_from_market_account_ (
  user: HexString,
  host: HexString,
  custodian_id: U64,
  style: boolean,
  max_base_parcels: U64,
  max_quote_units: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, base_coins, econia_capability, market_account_info, order_book_ref_mut, quote_coins, scale_factor;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host))) {
    throw $.abortCode(E_NO_ORDER_BOOK);
  }
  order_book_ref_mut = $c.borrow_global_mut<OrderBook>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host));
  scale_factor = $.copy(order_book_ref_mut.scale_factor);
  market_account_info = User.market_account_info_($.copy(custodian_id), $c, [$p[0], $p[1], $p[2]]);
  econia_capability = get_econia_capability_($c);
  if ((style == BUY)) {
    [temp$1, temp$2] = [Aptos_framework.Coin.zero_($c, [$p[0]]), User.withdraw_collateral_internal_($.copy(user), $.copy(market_account_info), $.copy(max_quote_units), econia_capability, $c, [$p[1]])];
  }
  else{
    [temp$1, temp$2] = [User.withdraw_collateral_internal_($.copy(user), $.copy(market_account_info), ($.copy(max_base_parcels)).mul($.copy(scale_factor)), econia_capability, $c, [$p[0]]), Aptos_framework.Coin.zero_($c, [$p[1]])];
  }
  [base_coins, quote_coins] = [temp$1, temp$2];
  fill_market_order_(order_book_ref_mut, $.copy(scale_factor), style, $.copy(max_base_parcels), $.copy(max_quote_units), base_coins, quote_coins, econia_capability, $c, [$p[0], $p[1], $p[2]]);
  User.deposit_collateral_($.copy(user), $.copy(market_account_info), base_coins, $c, [$p[0]]);
  User.deposit_collateral_($.copy(user), $.copy(market_account_info), quote_coins, $c, [$p[1]]);
  return;
}

export function fill_market_order_init_ (
  order_book_ref_mut: OrderBook,
  style: boolean,
  max_base_parcels: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U64, boolean, Critbit.CritBitTree, U128, U64, boolean] {
  let temp$1, temp$2, temp$3, temp$4, base_parcels_to_fill, n_orders, side, spread_maker_ref_mut, traversal_direction, tree_ref_mut;
  base_parcels_to_fill = $.copy(max_base_parcels);
  if ((style == BUY)) {
    [temp$1, temp$2, temp$3, temp$4] = [ASK, order_book_ref_mut.asks, order_book_ref_mut.min_ask, RIGHT];
  }
  else{
    [temp$1, temp$2, temp$3, temp$4] = [BID, order_book_ref_mut.bids, order_book_ref_mut.max_bid, LEFT];
  }
  [side, tree_ref_mut, spread_maker_ref_mut, traversal_direction] = [temp$1, temp$2, temp$3, temp$4];
  n_orders = Critbit.length_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
  return [$.copy(base_parcels_to_fill), side, tree_ref_mut, spread_maker_ref_mut, $.copy(n_orders), traversal_direction];
}

export function fill_market_order_loop_order_follow_up_ (
  side: boolean,
  base_parcels_to_fill: U64,
  complete_fill: boolean,
  traversal_direction: boolean,
  tree_ref_mut: Critbit.CritBitTree,
  n_orders: U64,
  target_order_id: U128,
  target_order_ref_mut: Order,
  target_parent_index: U64,
  target_child_index: U64,
  $c: AptosDataCache,
): [boolean, boolean, U128, U64, U128, Order, U64, U64] {
  let temp$1, new_spread_maker, should_break, should_pop;
  [new_spread_maker, should_break, should_pop] = [$.copy(target_order_id), true, false];
  if (($.copy(n_orders)).eq((u64("1")))) {
    if (complete_fill) {
      should_pop = true;
      if ((side == ASK)) {
        temp$1 = MIN_ASK_DEFAULT;
      }
      else{
        temp$1 = MAX_BID_DEFAULT;
      }
      new_spread_maker = temp$1;
    }
    else{
    }
  }
  else{
    if (complete_fill) {
      [target_order_id, target_order_ref_mut, target_parent_index, target_child_index, {  }] = Critbit.traverse_pop_mut_(tree_ref_mut, $.copy(target_order_id), $.copy(target_parent_index), $.copy(target_child_index), $.copy(n_orders), traversal_direction, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
      if (($.copy(base_parcels_to_fill)).eq((u64("0")))) {
        new_spread_maker = $.copy(target_order_id);
      }
      else{
        should_break = false;
        n_orders = ($.copy(n_orders)).sub(u64("1"));
      }
    }
    else{
    }
  }
  return [should_break, should_pop, $.copy(new_spread_maker), $.copy(n_orders), $.copy(target_order_id), target_order_ref_mut, $.copy(target_parent_index), $.copy(target_child_index)];
}

export function fill_market_order_process_loop_order_ (
  style: boolean,
  side: boolean,
  scale_factor: U64,
  base_parcels_to_fill_ref_mut: U64,
  target_order_id: U128,
  target_order_ref_mut: Order,
  base_coins_ref_mut: Aptos_framework.Coin.Coin,
  quote_coins_ref_mut: Aptos_framework.Coin.Coin,
  econia_capability_ref: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, base_parcels_filled, base_to_route, complete_fill, quote_to_route, target_price;
  target_price = Order_id.price_($.copy(target_order_id), $c);
  [temp$1, temp$2, temp$3, temp$4, temp$5] = [style, $.copy(target_price), quote_coins_ref_mut, target_order_ref_mut, base_parcels_to_fill_ref_mut];
  fill_market_order_check_base_parcels_to_fill_(temp$1, temp$2, temp$3, temp$4, temp$5, $c, [$p[1]]);
  if (($.copy(base_parcels_to_fill_ref_mut)).eq((u64("0")))) {
    return false;
  }
  else{
  }
  complete_fill = ($.copy(base_parcels_to_fill_ref_mut)).ge($.copy(target_order_ref_mut.base_parcels));
  if (complete_fill) {
    temp$6 = $.copy(target_order_ref_mut.base_parcels);
  }
  else{
    temp$6 = $.copy(base_parcels_to_fill_ref_mut);
  }
  base_parcels_filled = temp$6;
  $.set(base_parcels_to_fill_ref_mut, ($.copy(base_parcels_to_fill_ref_mut)).sub($.copy(base_parcels_filled)));
  base_to_route = ($.copy(base_parcels_filled)).mul($.copy(scale_factor));
  quote_to_route = ($.copy(base_parcels_filled)).mul($.copy(target_price));
  User.fill_order_internal_($.copy(target_order_ref_mut.user), $.copy(target_order_ref_mut.custodian_id), side, $.copy(target_order_id), complete_fill, $.copy(base_parcels_filled), base_coins_ref_mut, quote_coins_ref_mut, $.copy(base_to_route), $.copy(quote_to_route), econia_capability_ref, $c, [$p[0], $p[1], $p[2]]);
  if (!complete_fill) {
    target_order_ref_mut.base_parcels = ($.copy(target_order_ref_mut.base_parcels)).sub($.copy(base_parcels_filled));
  }
  else{
  }
  return complete_fill;
}

export function fill_market_order_traverse_loop_ (
  style: boolean,
  side: boolean,
  scale_factor: U64,
  tree_ref_mut: Critbit.CritBitTree,
  traversal_direction: boolean,
  n_orders: U64,
  spread_maker_ref_mut: U128,
  base_parcels_to_fill: U64,
  base_coins_ref_mut: Aptos_framework.Coin.Coin,
  quote_coins_ref_mut: Aptos_framework.Coin.Coin,
  econia_capability_ref: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, complete_fill, new_spread_maker, null_order, should_break, should_pop, target_child_index, target_order_id, target_order_ref_mut, target_parent_index;
  [target_order_id, target_order_ref_mut, target_parent_index, target_child_index] = Critbit.traverse_init_mut_(tree_ref_mut, traversal_direction, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
  temp$1 = new HexString("0x0");
  temp$2 = u64("0");
  temp$3 = u64("0");
  null_order = new Order({ base_parcels: temp$3, user: temp$1, custodian_id: temp$2 }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", []));
  while (true) {
    complete_fill = fill_market_order_process_loop_order_(style, side, $.copy(scale_factor), base_parcels_to_fill, $.copy(target_order_id), target_order_ref_mut, base_coins_ref_mut, quote_coins_ref_mut, econia_capability_ref, $c, [$p[0], $p[1], $p[2]]);
    [should_break, should_pop, new_spread_maker, n_orders, target_order_id, target_order_ref_mut, target_parent_index, target_child_index] = fill_market_order_loop_order_follow_up_(side, $.copy(base_parcels_to_fill), complete_fill, traversal_direction, tree_ref_mut, $.copy(n_orders), $.copy(target_order_id), null_order, $.copy(target_parent_index), $.copy(target_child_index), $c);
    if (should_break) {
      fill_market_order_break_cleanup_(null_order, spread_maker_ref_mut, $.copy(new_spread_maker), should_pop, tree_ref_mut, $.copy(target_order_id), $c);
      break;
    }
    else{
    }
  }
  return;
}

export function fill_market_order_user_ (
  user: HexString,
  host: HexString,
  style: boolean,
  max_base_parcels: U64,
  max_quote_units: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  fill_market_order_from_market_account_(Std.Signer.address_of_(user, $c), $.copy(host), NO_CUSTODIAN, style, $.copy(max_base_parcels), $.copy(max_quote_units), $c, [$p[0], $p[1], $p[2]]);
  return;
}


export function buildPayload_fill_market_order_user (
  host: HexString,
  style: boolean,
  max_base_parcels: U64,
  max_quote_units: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::fill_market_order_user",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(style),
      $.payloadArg(max_base_parcels),
      $.payloadArg(max_quote_units),
    ]
  );

}

export function get_econia_capability_ (
  $c: AptosDataCache,
): Capability.EconiaCapability {
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "EconiaCapabilityStore", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_NO_ECONIA_CAPABILITY_STORE);
  }
  return $.copy($c.borrow_global<EconiaCapabilityStore>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "EconiaCapabilityStore", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).econia_capability);
}

export function get_orders_sdk_ (
  order_book_ref_mut: OrderBook,
  side: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): SimpleOrder[] {
  let temp$1, temp$2, remaining_traversals, simple_orders, target_id, target_order_ref_mut, target_parent_index, traversal_direction, tree_ref_mut;
  simple_orders = Std.Vector.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])]);
  if ((side == ASK)) {
    [temp$1, temp$2] = [order_book_ref_mut.asks, RIGHT];
  }
  else{
    [temp$1, temp$2] = [order_book_ref_mut.bids, LEFT];
  }
  [tree_ref_mut, traversal_direction] = [temp$1, temp$2];
  if (Critbit.is_empty_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])])) {
    return $.copy(simple_orders);
  }
  else{
  }
  remaining_traversals = (Critbit.length_(tree_ref_mut, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])])).sub(u64("1"));
  [target_id, target_order_ref_mut, target_parent_index, ] = Critbit.traverse_init_mut_(tree_ref_mut, traversal_direction, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
  while (true) {
    Std.Vector.push_back_(simple_orders, new SimpleOrder({ price: Order_id.price_($.copy(target_id), $c), base_parcels: $.copy(target_order_ref_mut.base_parcels) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])]);
    if (($.copy(remaining_traversals)).eq((u64("0")))) {
      return $.copy(simple_orders);
    }
    else{
    }
    [target_id, target_order_ref_mut, target_parent_index, ] = Critbit.traverse_mut_(tree_ref_mut, $.copy(target_id), $.copy(target_parent_index), traversal_direction, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
    remaining_traversals = ($.copy(remaining_traversals)).sub(u64("1"));
  }
}

export function get_price_levels_sdk_ (
  simple_orders: SimpleOrder[],
  $c: AptosDataCache,
): PriceLevel[] {
  let level_base_parcels, level_price, n_simple_orders, price_levels, simple_order_index, simple_order_ref;
  price_levels = Std.Vector.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "PriceLevel", [])]);
  if (Std.Vector.is_empty_(simple_orders, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])])) {
    return $.copy(price_levels);
  }
  else{
  }
  simple_order_ref = Std.Vector.borrow_(simple_orders, u64("0"), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])]);
  level_price = $.copy(simple_order_ref.price);
  level_base_parcels = $.copy(simple_order_ref.base_parcels);
  n_simple_orders = Std.Vector.length_(simple_orders, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])]);
  simple_order_index = u64("1");
  while (($.copy(simple_order_index)).lt($.copy(n_simple_orders))) {
    {
      simple_order_ref = Std.Vector.borrow_(simple_orders, $.copy(simple_order_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "SimpleOrder", [])]);
      if (($.copy(simple_order_ref.price)).neq($.copy(level_price))) {
        Std.Vector.push_back_(price_levels, new PriceLevel({ price: $.copy(level_price), base_parcels: $.copy(level_base_parcels) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "PriceLevel", [])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "PriceLevel", [])]);
        [level_price, level_base_parcels] = [$.copy(simple_order_ref.price), $.copy(simple_order_ref.base_parcels)];
      }
      else{
        level_base_parcels = ($.copy(level_base_parcels)).add($.copy(simple_order_ref.base_parcels));
      }
      simple_order_index = ($.copy(simple_order_index)).add(u64("1"));
    }

  }Std.Vector.push_back_(price_levels, new PriceLevel({ price: $.copy(level_price), base_parcels: $.copy(level_base_parcels) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "PriceLevel", [])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "PriceLevel", [])]);
  return $.copy(price_levels);
}

export function get_serial_id_ (
  order_book_ref_mut: OrderBook,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  let count, counter_ref_mut;
  counter_ref_mut = order_book_ref_mut.counter;
  count = $.copy(counter_ref_mut);
  $.set(counter_ref_mut, ($.copy(count)).add(u64("1")));
  return $.copy(count);
}

export function init_book_ (
  host: HexString,
  scale_factor: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  if (!!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), Std.Signer.address_of_(host, $c))) {
    throw $.abortCode(E_BOOK_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), host, new OrderBook({ scale_factor: $.copy(scale_factor), asks: Critbit.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]), bids: Critbit.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]), min_ask: MIN_ASK_DEFAULT, max_bid: MAX_BID_DEFAULT, counter: u64("0") }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]])));
  return;
}

export function init_econia_capability_store_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let econia_capability;
  if (!((Std.Signer.address_of_(account, $c)).hex() === (new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "EconiaCapabilityStore", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_ECONIA_CAPABILITY_STORE_EXISTS);
  }
  econia_capability = Capability.get_econia_capability_(account, $c);
  $c.move_to(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "EconiaCapabilityStore", []), account, new EconiaCapabilityStore({ econia_capability: $.copy(econia_capability) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "EconiaCapabilityStore", [])));
  return;
}

export function place_limit_order_ (
  user: HexString,
  host: HexString,
  custodian_id: U64,
  side: boolean,
  base_parcels: U64,
  price: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$10, temp$11, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, crossed_spread, new_spread_maker, order_book_ref_mut, order_id, spread_maker_ref_mut, tree_ref_mut;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host))) {
    throw $.abortCode(E_NO_ORDER_BOOK);
  }
  order_book_ref_mut = $c.borrow_global_mut<OrderBook>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host));
  order_id = Order_id.order_id_($.copy(price), get_serial_id_(order_book_ref_mut, $c, [$p[0], $p[1], $p[2]]), side, $c);
  temp$7 = $.copy(user);
  temp$6 = $.copy(custodian_id);
  temp$5 = side;
  temp$4 = $.copy(order_id);
  temp$3 = $.copy(base_parcels);
  temp$2 = $.copy(price);
  temp$1 = get_econia_capability_($c);
  User.add_order_internal_(temp$7, temp$6, temp$5, temp$4, temp$3, temp$2, temp$1, $c, [$p[0], $p[1], $p[2]]);
  if ((side == ASK)) {
    [temp$8, temp$9, temp$10, temp$11] = [order_book_ref_mut.asks, ($.copy(order_id)).lt($.copy(order_book_ref_mut.min_ask)), ($.copy(price)).le(Order_id.price_($.copy(order_book_ref_mut.max_bid), $c)), order_book_ref_mut.min_ask];
  }
  else{
    [temp$8, temp$9, temp$10, temp$11] = [order_book_ref_mut.bids, ($.copy(order_id)).gt($.copy(order_book_ref_mut.max_bid)), ($.copy(price)).ge(Order_id.price_($.copy(order_book_ref_mut.min_ask), $c)), order_book_ref_mut.max_bid];
  }
  [tree_ref_mut, new_spread_maker, crossed_spread, spread_maker_ref_mut] = [temp$8, temp$9, temp$10, temp$11];
  if (!!crossed_spread) {
    throw $.abortCode(E_CROSSED_SPREAD);
  }
  if (new_spread_maker) {
    $.set(spread_maker_ref_mut, $.copy(order_id));
  }
  else{
  }
  Critbit.insert_(tree_ref_mut, $.copy(order_id), new Order({ base_parcels: $.copy(base_parcels), user: $.copy(user), custodian_id: $.copy(custodian_id) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "Order", [])]);
  return;
}

export function place_limit_order_custodian_ (
  user: HexString,
  host: HexString,
  side: boolean,
  base_parcels: U64,
  price: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let custodian_id;
  custodian_id = Registry.custodian_id_(custodian_capability_ref, $c);
  place_limit_order_($.copy(user), $.copy(host), $.copy(custodian_id), side, $.copy(base_parcels), $.copy(price), $c, [$p[0], $p[1], $p[2]]);
  return;
}

export function place_limit_order_user_ (
  user: HexString,
  host: HexString,
  side: boolean,
  base_parcels: U64,
  price: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  place_limit_order_(Std.Signer.address_of_(user, $c), $.copy(host), NO_CUSTODIAN, side, $.copy(base_parcels), $.copy(price), $c, [$p[0], $p[1], $p[2]]);
  return;
}


export function buildPayload_place_limit_order_user (
  host: HexString,
  side: boolean,
  base_parcels: U64,
  price: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::place_limit_order_user",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(side),
      $.payloadArg(base_parcels),
      $.payloadArg(price),
    ]
  );

}

export function register_market_ (
  host: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2;
  temp$2 = Std.Signer.address_of_(host, $c);
  temp$1 = get_econia_capability_($c);
  Registry.register_market_internal_(temp$2, temp$1, $c, [$p[0], $p[1], $p[2]]);
  init_book_(host, Registry.scale_factor_($c, [$p[2]]), $c, [$p[0], $p[1], $p[2]]);
  return;
}


export function buildPayload_register_market (
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::register_market",
    typeParamStrings,
    []
  );

}

export function swap_ (
  style: boolean,
  host: HexString,
  base_coins_ref_mut: Aptos_framework.Coin.Coin,
  quote_coins_ref_mut: Aptos_framework.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, econia_capability, max_base_parcels, max_quote_units, order_book_ref_mut, scale_factor;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host))) {
    throw $.abortCode(E_NO_ORDER_BOOK);
  }
  order_book_ref_mut = $c.borrow_global_mut<OrderBook>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "market", "OrderBook", [$p[0], $p[1], $p[2]]), $.copy(host));
  scale_factor = $.copy(order_book_ref_mut.scale_factor);
  econia_capability = get_econia_capability_($c);
  if ((style == BUY)) {
    [temp$1, temp$2] = [HI_64, Aptos_framework.Coin.value_(quote_coins_ref_mut, $c, [$p[1]])];
  }
  else{
    [temp$1, temp$2] = [(Aptos_framework.Coin.value_(base_coins_ref_mut, $c, [$p[0]])).div($.copy(scale_factor)), u64("0")];
  }
  [max_base_parcels, max_quote_units] = [temp$1, temp$2];
  fill_market_order_(order_book_ref_mut, $.copy(scale_factor), style, $.copy(max_base_parcels), $.copy(max_quote_units), base_coins_ref_mut, quote_coins_ref_mut, econia_capability, $c, [$p[0], $p[1], $p[2]]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::EconiaCapabilityStore", EconiaCapabilityStore.EconiaCapabilityStoreParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::Order", Order.OrderParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::OrderBook", OrderBook.OrderBookParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::PriceLevel", PriceLevel.PriceLevelParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::market::SimpleOrder", SimpleOrder.SimpleOrderParser);
}

