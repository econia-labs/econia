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
import * as Open_table from "./open_table";
import * as Order_id from "./order_id";
import * as Registry from "./registry";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "user";

export const ASK : boolean = true;
export const BID : boolean = false;
export const E_BASE_PARCELS_0 : U64 = u64("9");
export const E_CUSTODIAN_OVERRIDE : U64 = u64("6");
export const E_INVALID_CUSTODIAN_ID : U64 = u64("1");
export const E_MARKET_ACCOUNT_REGISTERED : U64 = u64("2");
export const E_NOT_ENOUGH_COLLATERAL : U64 = u64("4");
export const E_NO_MARKET : U64 = u64("0");
export const E_NO_MARKET_ACCOUNT : U64 = u64("3");
export const E_NO_MARKET_ACCOUNTS : U64 = u64("7");
export const E_OVERFLOW_BASE : U64 = u64("10");
export const E_OVERFLOW_QUOTE : U64 = u64("11");
export const E_PRICE_0 : U64 = u64("8");
export const E_UNAUTHORIZED_CUSTODIAN : U64 = u64("5");
export const HI_64 : U64 = u64("18446744073709551615");
export const IN : boolean = true;
export const NO_CUSTODIAN : U64 = u64("0");
export const OUT : boolean = false;


export class Collateral 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Collateral";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "map", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "open_table", "OpenTable", [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [new $.TypeParamIdx(0)])]) }];

  map: Open_table.OpenTable;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto['map'] as Open_table.OpenTable;
  }

  static CollateralParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Collateral {
    const proto = $.parseStructProto(data, typeTag, repo, Collateral);
    return new Collateral(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Collateral, typeParams);
    return result as unknown as Collateral;
  }
}

export class MarketAccount 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MarketAccount";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "scale_factor", typeTag: AtomicTypeTag.U64 },
  { name: "asks", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "CritBitTree", [AtomicTypeTag.U64]) },
  { name: "bids", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "CritBitTree", [AtomicTypeTag.U64]) },
  { name: "base_coins_total", typeTag: AtomicTypeTag.U64 },
  { name: "base_coins_available", typeTag: AtomicTypeTag.U64 },
  { name: "quote_coins_total", typeTag: AtomicTypeTag.U64 },
  { name: "quote_coins_available", typeTag: AtomicTypeTag.U64 }];

  scale_factor: U64;
  asks: Critbit.CritBitTree;
  bids: Critbit.CritBitTree;
  base_coins_total: U64;
  base_coins_available: U64;
  quote_coins_total: U64;
  quote_coins_available: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.scale_factor = proto['scale_factor'] as U64;
    this.asks = proto['asks'] as Critbit.CritBitTree;
    this.bids = proto['bids'] as Critbit.CritBitTree;
    this.base_coins_total = proto['base_coins_total'] as U64;
    this.base_coins_available = proto['base_coins_available'] as U64;
    this.quote_coins_total = proto['quote_coins_total'] as U64;
    this.quote_coins_available = proto['quote_coins_available'] as U64;
  }

  static MarketAccountParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MarketAccount {
    const proto = $.parseStructProto(data, typeTag, repo, MarketAccount);
    return new MarketAccount(proto, typeTag);
  }

}

export class MarketAccountInfo 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MarketAccountInfo";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "market_info", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []) },
  { name: "custodian_id", typeTag: AtomicTypeTag.U64 }];

  market_info: Registry.MarketInfo;
  custodian_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_info = proto['market_info'] as Registry.MarketInfo;
    this.custodian_id = proto['custodian_id'] as U64;
  }

  static MarketAccountInfoParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MarketAccountInfo {
    const proto = $.parseStructProto(data, typeTag, repo, MarketAccountInfo);
    return new MarketAccountInfo(proto, typeTag);
  }

}

export class MarketAccounts 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MarketAccounts";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "map", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "open_table", "OpenTable", [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]) }];

  map: Open_table.OpenTable;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto['map'] as Open_table.OpenTable;
  }

  static MarketAccountsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MarketAccounts {
    const proto = $.parseStructProto(data, typeTag, repo, MarketAccounts);
    return new MarketAccounts(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, MarketAccounts, typeParams);
    return result as unknown as MarketAccounts;
  }
}
export function add_order_internal_ (
  user: HexString,
  custodian_id: U64,
  side: boolean,
  order_id: U128,
  base_parcels: U64,
  price: U64,
  _econia_capability: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, base_to_fill, coins_available_ref_mut, coins_required, market_account, market_account_info, market_accounts_map, quote_to_fill, tree_ref_mut;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user))) {
    throw $.abortCode(E_NO_MARKET_ACCOUNTS);
  }
  market_account_info = market_account_info_($.copy(custodian_id), $c, [$p[0], $p[1], $p[2]]);
  market_accounts_map = $c.borrow_global_mut<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user)).map;
  [temp$1, temp$2] = [market_accounts_map, $.copy(market_account_info)];
  if (!Open_table.contains_(temp$1, temp$2, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])])) {
    throw $.abortCode(E_NO_MARKET_ACCOUNT);
  }
  market_account = Open_table.borrow_mut_(market_accounts_map, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]);
  [base_to_fill, quote_to_fill] = range_check_order_fills_($.copy(market_account.scale_factor), $.copy(base_parcels), $.copy(price), $c);
  if ((side == ASK)) {
    [temp$3, temp$4, temp$5] = [market_account.asks, market_account.base_coins_available, $.copy(base_to_fill)];
  }
  else{
    [temp$3, temp$4, temp$5] = [market_account.bids, market_account.quote_coins_available, $.copy(quote_to_fill)];
  }
  [tree_ref_mut, coins_available_ref_mut, coins_required] = [temp$3, temp$4, temp$5];
  if (!($.copy(coins_required)).le($.copy(coins_available_ref_mut))) {
    throw $.abortCode(E_NOT_ENOUGH_COLLATERAL);
  }
  $.set(coins_available_ref_mut, ($.copy(coins_available_ref_mut)).sub($.copy(coins_required)));
  Critbit.insert_(tree_ref_mut, $.copy(order_id), $.copy(base_parcels), $c, [AtomicTypeTag.U64]);
  return;
}

export function borrow_coin_counts_mut_ (
  market_accounts_map: Open_table.OpenTable,
  market_account_info: MarketAccountInfo,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): [U64, U64] {
  let temp$1, temp$2, is_base_coin, market_account;
  is_base_coin = Registry.coin_is_base_coin_(market_account_info.market_info, $c, [$p[0]]);
  market_account = Open_table.borrow_mut_(market_accounts_map, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]);
  if (is_base_coin) {
    [temp$1, temp$2] = [market_account.base_coins_total, market_account.base_coins_available];
  }
  else{
    [temp$1, temp$2] = [market_account.quote_coins_total, market_account.quote_coins_available];
  }
  return [temp$1, temp$2];
}

export function deposit_collateral_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  coins: Aptos_framework.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let coins_available_ref_mut, coins_total_ref_mut, collateral, collateral_map, market_accounts_map;
  if (!exists_market_account_($.copy(market_account_info), $.copy(user), $c)) {
    throw $.abortCode(E_NO_MARKET_ACCOUNT);
  }
  market_accounts_map = $c.borrow_global_mut<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user)).map;
  [coins_total_ref_mut, coins_available_ref_mut] = borrow_coin_counts_mut_(market_accounts_map, $.copy(market_account_info), $c, [$p[0]]);
  $.set(coins_total_ref_mut, ($.copy(coins_total_ref_mut)).add(Aptos_framework.Coin.value_(coins, $c, [$p[0]])));
  $.set(coins_available_ref_mut, ($.copy(coins_available_ref_mut)).add(Aptos_framework.Coin.value_(coins, $c, [$p[0]])));
  collateral_map = $c.borrow_global_mut<Collateral>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]]), $.copy(user)).map;
  collateral = Open_table.borrow_mut_(collateral_map, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]);
  Aptos_framework.Coin.merge_(collateral, coins, $c, [$p[0]]);
  return;
}

export function exists_market_account_ (
  market_account_info: MarketAccountInfo,
  user: HexString,
  $c: AptosDataCache,
): boolean {
  let market_accounts_map;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user))) {
    return false;
  }
  else{
  }
  market_accounts_map = $c.borrow_global<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user)).map;
  return Open_table.contains_(market_accounts_map, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]);
}

export function fill_order_internal_ (
  user: HexString,
  custodian_id: U64,
  side: boolean,
  order_id: U128,
  complete_fill: boolean,
  base_parcels_filled: U64,
  base_coins_ref_mut: Aptos_framework.Coin.Coin,
  quote_coins_ref_mut: Aptos_framework.Coin.Coin,
  base_to_route: U64,
  quote_to_route: U64,
  _econia_capability: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let market_account_info;
  market_account_info = market_account_info_($.copy(custodian_id), $c, [$p[0], $p[1], $p[2]]);
  fill_order_update_market_account_($.copy(user), $.copy(market_account_info), side, $.copy(order_id), complete_fill, $.copy(base_parcels_filled), $.copy(base_to_route), $.copy(quote_to_route), $c);
  fill_order_route_collateral_($.copy(user), $.copy(market_account_info), side, base_coins_ref_mut, quote_coins_ref_mut, $.copy(base_to_route), $.copy(quote_to_route), $c, [$p[0], $p[1]]);
  return;
}

export function fill_order_route_collateral_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  side: boolean,
  base_coins_ref_mut: Aptos_framework.Coin.Coin,
  quote_coins_ref_mut: Aptos_framework.Coin.Coin,
  base_to_route: U64,
  quote_to_route: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q>*/
): void {
  let temp$1, temp$2, base_direction, quote_direction;
  if ((side == ASK)) {
    [temp$1, temp$2] = [OUT, IN];
  }
  else{
    [temp$1, temp$2] = [IN, OUT];
  }
  [base_direction, quote_direction] = [temp$1, temp$2];
  fill_order_route_collateral_single_($.copy(user), $.copy(market_account_info), base_coins_ref_mut, $.copy(base_to_route), base_direction, $c, [$p[0]]);
  fill_order_route_collateral_single_($.copy(user), $.copy(market_account_info), quote_coins_ref_mut, $.copy(quote_to_route), quote_direction, $c, [$p[1]]);
  return;
}

export function fill_order_route_collateral_single_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  external_coins_ref_mut: Aptos_framework.Coin.Coin,
  amount: U64,
  direction: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let collateral_map_ref_mut, collateral_ref_mut;
  collateral_map_ref_mut = $c.borrow_global_mut<Collateral>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]]), $.copy(user)).map;
  collateral_ref_mut = Open_table.borrow_mut_(collateral_map_ref_mut, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]);
  if ((direction == IN)) {
    Aptos_framework.Coin.merge_(collateral_ref_mut, Aptos_framework.Coin.extract_(external_coins_ref_mut, $.copy(amount), $c, [$p[0]]), $c, [$p[0]]);
  }
  else{
    Aptos_framework.Coin.merge_(external_coins_ref_mut, Aptos_framework.Coin.extract_(collateral_ref_mut, $.copy(amount), $c, [$p[0]]), $c, [$p[0]]);
  }
  return;
}

export function fill_order_update_market_account_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  side: boolean,
  order_id: U128,
  complete_fill: boolean,
  base_parcels_filled: U64,
  base_to_route: U64,
  quote_to_route: U64,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, coins_in, coins_in_available_ref_mut, coins_in_total_ref_mut, coins_out, coins_out_total_ref_mut, market_account_ref_mut, market_accounts_map_ref_mut, order_base_parcels_ref_mut, order_tree_ref_mut;
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user)).map;
  market_account_ref_mut = Open_table.borrow_mut_(market_accounts_map_ref_mut, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]);
  if ((side == ASK)) {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6] = [market_account_ref_mut.asks, $.copy(quote_to_route), market_account_ref_mut.quote_coins_total, market_account_ref_mut.quote_coins_available, $.copy(base_to_route), market_account_ref_mut.base_coins_total];
  }
  else{
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6] = [market_account_ref_mut.bids, $.copy(base_to_route), market_account_ref_mut.base_coins_total, market_account_ref_mut.base_coins_available, $.copy(quote_to_route), market_account_ref_mut.quote_coins_total];
  }
  [order_tree_ref_mut, coins_in, coins_in_total_ref_mut, coins_in_available_ref_mut, coins_out, coins_out_total_ref_mut] = [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6];
  if (complete_fill) {
    Critbit.pop_(order_tree_ref_mut, $.copy(order_id), $c, [AtomicTypeTag.U64]);
  }
  else{
    order_base_parcels_ref_mut = Critbit.borrow_mut_(order_tree_ref_mut, $.copy(order_id), $c, [AtomicTypeTag.U64]);
    $.set(order_base_parcels_ref_mut, ($.copy(order_base_parcels_ref_mut)).sub($.copy(base_parcels_filled)));
  }
  $.set(coins_in_total_ref_mut, ($.copy(coins_in_total_ref_mut)).add($.copy(coins_in)));
  $.set(coins_in_available_ref_mut, ($.copy(coins_in_available_ref_mut)).add($.copy(coins_in)));
  $.set(coins_out_total_ref_mut, ($.copy(coins_out_total_ref_mut)).sub($.copy(coins_out)));
  return;
}

export function market_account_info_ (
  custodian_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): MarketAccountInfo {
  return new MarketAccountInfo({ market_info: Registry.market_info_($c, [$p[0], $p[1], $p[2]]), custodian_id: $.copy(custodian_id) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []));
}

export function range_check_order_fills_ (
  scale_factor: U64,
  base_parcels: U64,
  price: U64,
  $c: AptosDataCache,
): [U64, U64] {
  let base_to_fill, quote_to_fill;
  if (!($.copy(price)).gt(u64("0"))) {
    throw $.abortCode(E_PRICE_0);
  }
  if (!($.copy(base_parcels)).gt(u64("0"))) {
    throw $.abortCode(E_BASE_PARCELS_0);
  }
  base_to_fill = (u128($.copy(scale_factor))).mul(u128($.copy(base_parcels)));
  if (!!($.copy(base_to_fill)).gt(u128(HI_64))) {
    throw $.abortCode(E_OVERFLOW_BASE);
  }
  quote_to_fill = (u128($.copy(price))).mul(u128($.copy(base_parcels)));
  if (!!($.copy(quote_to_fill)).gt(u128(HI_64))) {
    throw $.abortCode(E_OVERFLOW_QUOTE);
  }
  return [u64($.copy(base_to_fill)), u64($.copy(quote_to_fill))];
}

export function register_collateral_entry_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let temp$1, temp$2, map, user_address;
  user_address = Std.Signer.address_of_(user, $c);
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]]), $.copy(user_address))) {
    $c.move_to(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]]), user, new Collateral({ map: Open_table.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]])));
  }
  else{
  }
  map = $c.borrow_global_mut<Collateral>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]]), $.copy(user_address)).map;
  [temp$1, temp$2] = [map, $.copy(market_account_info)];
  if (!!Open_table.contains_(temp$1, temp$2, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])])) {
    throw $.abortCode(E_MARKET_ACCOUNT_REGISTERED);
  }
  Open_table.add_(map, $.copy(market_account_info), Aptos_framework.Coin.zero_($c, [$p[0]]), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]);
  return;
}

export function register_market_account_ (
  user: HexString,
  custodian_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let market_account_info, market_info;
  market_info = Registry.market_info_($c, [$p[0], $p[1], $p[2]]);
  if (!Registry.is_registered_($.copy(market_info), $c)) {
    throw $.abortCode(E_NO_MARKET);
  }
  if (!Registry.is_valid_custodian_id_($.copy(custodian_id), $c)) {
    throw $.abortCode(E_INVALID_CUSTODIAN_ID);
  }
  market_account_info = new MarketAccountInfo({ market_info: $.copy(market_info), custodian_id: $.copy(custodian_id) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []));
  register_market_accounts_entry_(user, $.copy(market_account_info), $c);
  register_collateral_entry_(user, $.copy(market_account_info), $c, [$p[0]]);
  register_collateral_entry_(user, $.copy(market_account_info), $c, [$p[1]]);
  return;
}


export function buildPayload_register_market_account (
  custodian_id: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::user::register_market_account",
    typeParamStrings,
    [
      $.payloadArg(custodian_id),
    ]
  );

}

export function register_market_accounts_entry_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, map, scale_factor, user_address;
  user_address = Std.Signer.address_of_(user, $c);
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user_address))) {
    $c.move_to(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), user, new MarketAccounts({ map: Open_table.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", [])));
  }
  else{
  }
  map = $c.borrow_global_mut<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user_address)).map;
  [temp$1, temp$2] = [map, $.copy(market_account_info)];
  if (!!Open_table.contains_(temp$1, temp$2, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])])) {
    throw $.abortCode(E_MARKET_ACCOUNT_REGISTERED);
  }
  scale_factor = Registry.scale_factor_from_market_info_(market_account_info.market_info, $c);
  Open_table.add_(map, $.copy(market_account_info), new MarketAccount({ scale_factor: $.copy(scale_factor), asks: Critbit.empty_($c, [AtomicTypeTag.U64]), bids: Critbit.empty_($c, [AtomicTypeTag.U64]), base_coins_total: u64("0"), base_coins_available: u64("0"), quote_coins_total: u64("0"), quote_coins_available: u64("0") }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]);
  return;
}

export function remove_order_internal_ (
  user: HexString,
  custodian_id: U64,
  side: boolean,
  order_id: U128,
  _econia_capability: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, base_parcel_multiplier, base_parcels, coins_available_ref_mut, coins_unlocked, market_account, market_account_info, market_accounts_map, tree_ref_mut;
  market_account_info = market_account_info_($.copy(custodian_id), $c, [$p[0], $p[1], $p[2]]);
  market_accounts_map = $c.borrow_global_mut<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user)).map;
  market_account = Open_table.borrow_mut_(market_accounts_map, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccount", [])]);
  if ((side == ASK)) {
    [temp$1, temp$2, temp$3] = [market_account.asks, market_account.base_coins_available, $.copy(market_account.scale_factor)];
  }
  else{
    [temp$1, temp$2, temp$3] = [market_account.bids, market_account.quote_coins_available, Order_id.price_($.copy(order_id), $c)];
  }
  [tree_ref_mut, coins_available_ref_mut, base_parcel_multiplier] = [temp$1, temp$2, temp$3];
  base_parcels = Critbit.pop_(tree_ref_mut, $.copy(order_id), $c, [AtomicTypeTag.U64]);
  coins_unlocked = ($.copy(base_parcels)).mul($.copy(base_parcel_multiplier));
  $.set(coins_available_ref_mut, ($.copy(coins_available_ref_mut)).add($.copy(coins_unlocked)));
  return;
}

export function withdraw_collateral_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): Aptos_framework.Coin.Coin {
  let coins_available_ref_mut, coins_total_ref_mut, collateral, collateral_map, market_accounts_map;
  if (!exists_market_account_($.copy(market_account_info), $.copy(user), $c)) {
    throw $.abortCode(E_NO_MARKET_ACCOUNT);
  }
  market_accounts_map = $c.borrow_global_mut<MarketAccounts>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccounts", []), $.copy(user)).map;
  [coins_total_ref_mut, coins_available_ref_mut] = borrow_coin_counts_mut_(market_accounts_map, $.copy(market_account_info), $c, [$p[0]]);
  if (!($.copy(amount)).le($.copy(coins_available_ref_mut))) {
    throw $.abortCode(E_NOT_ENOUGH_COLLATERAL);
  }
  $.set(coins_total_ref_mut, ($.copy(coins_total_ref_mut)).sub($.copy(amount)));
  $.set(coins_available_ref_mut, ($.copy(coins_available_ref_mut)).sub($.copy(amount)));
  collateral_map = $c.borrow_global_mut<Collateral>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "Collateral", [$p[0]]), $.copy(user)).map;
  collateral = Open_table.borrow_mut_(collateral_map, $.copy(market_account_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "user", "MarketAccountInfo", []), new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]);
  return Aptos_framework.Coin.extract_(collateral, $.copy(amount), $c, [$p[0]]);
}

export function withdraw_collateral_custodian_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  amount: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): Aptos_framework.Coin.Coin {
  if (!(Registry.custodian_id_(custodian_capability_ref, $c)).eq(($.copy(market_account_info.custodian_id)))) {
    throw $.abortCode(E_UNAUTHORIZED_CUSTODIAN);
  }
  return withdraw_collateral_($.copy(user), $.copy(market_account_info), $.copy(amount), $c, [$p[0]]);
}

export function withdraw_collateral_internal_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  amount: U64,
  _econia_capability: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): Aptos_framework.Coin.Coin {
  return withdraw_collateral_($.copy(user), $.copy(market_account_info), $.copy(amount), $c, [$p[0]]);
}

export function withdraw_collateral_user_ (
  user: HexString,
  market_account_info: MarketAccountInfo,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): Aptos_framework.Coin.Coin {
  if (!($.copy(market_account_info.custodian_id)).eq((NO_CUSTODIAN))) {
    throw $.abortCode(E_CUSTODIAN_OVERRIDE);
  }
  return withdraw_collateral_(Std.Signer.address_of_(user, $c), $.copy(market_account_info), $.copy(amount), $c, [$p[0]]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::user::Collateral", Collateral.CollateralParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::user::MarketAccount", MarketAccount.MarketAccountParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::user::MarketAccountInfo", MarketAccountInfo.MarketAccountInfoParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::user::MarketAccounts", MarketAccounts.MarketAccountsParser);
}

