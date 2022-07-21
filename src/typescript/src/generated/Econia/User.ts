import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as AptosFramework from "../AptosFramework";
import * as Std from "../Std";
import * as Book from "./Book";
import * as Caps from "./Caps";
import * as ID from "./ID";
import * as Orders from "./Orders";
import * as Registry from "./Registry";
import * as Version from "./Version";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
export const moduleName = "User";

export const ASK : boolean = true;
export const BID : boolean = false;
export const E_CROSSES_SPREAD : U64 = u64("10");
export const E_INVALID_S_N : U64 = u64("5");
export const E_NOT_ENOUGH_COLLATERAL : U64 = u64("9");
export const E_NO_MARKET : U64 = u64("1");
export const E_NO_O_C : U64 = u64("6");
export const E_NO_S_C : U64 = u64("4");
export const E_NO_TRANSFER : U64 = u64("7");
export const E_O_C_EXISTS : U64 = u64("0");
export const E_O_O_EXISTS : U64 = u64("2");
export const E_S_C_EXISTS : U64 = u64("3");
export const E_WITHDRAW_TOO_MUCH : U64 = u64("8");


export class OC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OC";
  static typeParameters: TypeParamDeclType[] = [
    { name: "B", isPhantom: true },
    { name: "Q", isPhantom: true },
    { name: "E", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "b_a", typeTag: AtomicTypeTag.U64 },
  { name: "b_c", typeTag: new StructTag(new HexString("0x1"), "Coin", "Coin", [new $.TypeParamIdx(0)]) },
  { name: "q_a", typeTag: AtomicTypeTag.U64 },
  { name: "q_c", typeTag: new StructTag(new HexString("0x1"), "Coin", "Coin", [new $.TypeParamIdx(1)]) }];

  b_a: U64;
  b_c: AptosFramework.Coin.Coin;
  q_a: U64;
  q_c: AptosFramework.Coin.Coin;

  constructor(proto: any, public typeTag: TypeTag) {
    this.b_a = proto['b_a'] as U64;
    this.b_c = proto['b_c'] as AptosFramework.Coin.Coin;
    this.q_a = proto['q_a'] as U64;
    this.q_c = proto['q_c'] as AptosFramework.Coin.Coin;
  }

  static OCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OC {
    const proto = $.parseStructProto(data, typeTag, repo, OC);
    return new OC(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, OC, typeParams);
    return result as unknown as OC;
  }
}

export class SC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "SC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "i", typeTag: AtomicTypeTag.U64 }];

  i: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.i = proto['i'] as U64;
  }

  static SCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : SC {
    const proto = $.parseStructProto(data, typeTag, repo, SC);
    return new SC(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, SC, typeParams);
    return result as unknown as SC;
  }
}
export function cancel_ask$ (
  user: HexString,
  host: HexString,
  id: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  cancel_order$(user, $.copy(host), ASK, $.copy(id), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}


export function buildPayload_cancel_ask (
  host: HexString,
  id: U128,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::cancel_ask",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(id),
    ]
  );

}
export function cancel_bid$ (
  user: HexString,
  host: HexString,
  id: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  cancel_order$(user, $.copy(host), BID, $.copy(id), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}


export function buildPayload_cancel_bid (
  host: HexString,
  id: U128,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::cancel_bid",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(id),
    ]
  );

}
export function cancel_order$ (
  user: HexString,
  host: HexString,
  side: boolean,
  id: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$10, temp$11, temp$12, temp$13, temp$15, temp$16, temp$17, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, addr, o_c, s_s, s_s__14;
  temp$2 = user;
  temp$1 = Caps.orders_f_c$($c);
  update_s_c$(temp$2, temp$1, $c);
  addr = Std.Signer.address_of$(user, $c);
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr))) {
    throw $.abortCode(E_NO_O_C);
  }
  o_c = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr));
  if ((side == ASK)) {
    temp$5 = $.copy(addr);
    temp$4 = $.copy(id);
    temp$3 = Caps.orders_f_c$($c);
    s_s = Orders.cancel_ask$(temp$5, temp$4, temp$3, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    temp$8 = $.copy(host);
    temp$7 = $.copy(id);
    temp$6 = Caps.book_f_c$($c);
    Book.cancel_ask$(temp$8, temp$7, temp$6, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    temp$10 = $.copy(addr);
    temp$9 = Caps.orders_f_c$($c);
    o_c.b_a = $.copy(o_c.b_a).add($.copy(s_s).mul(Orders.scale_factor$(temp$10, temp$9, $c, [$p[0], $p[1], $p[2]] as TypeTag[])));
  }
  else{
    temp$13 = $.copy(addr);
    temp$12 = $.copy(id);
    temp$11 = Caps.orders_f_c$($c);
    s_s__14 = Orders.cancel_bid$(temp$13, temp$12, temp$11, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    temp$17 = $.copy(host);
    temp$16 = $.copy(id);
    temp$15 = Caps.book_f_c$($c);
    Book.cancel_bid$(temp$17, temp$16, temp$15, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    o_c.q_a = $.copy(o_c.q_a).add($.copy(s_s__14).mul(ID.price$($.copy(id), $c)));
  }
  return;
}

export function dec_available_collateral$ (
  user: HexString,
  base: U64,
  quote: U64,
  _c: Orders.FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let order_collateral;
  order_collateral = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(user));
  order_collateral.b_a = $.copy(order_collateral.b_a).sub($.copy(base));
  order_collateral.q_a = $.copy(order_collateral.q_a).sub($.copy(quote));
  return;
}

export function deposit$ (
  user: HexString,
  b_val: U64,
  q_val: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, addr, o_c;
  addr = Std.Signer.address_of$(user, $c);
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr))) {
    throw $.abortCode(E_NO_O_C);
  }
  if ($.copy(b_val).gt(u64("0"))) {
    temp$1 = true;
  }
  else{
    temp$1 = $.copy(q_val).gt(u64("0"));
  }
  if (!temp$1) {
    throw $.abortCode(E_NO_TRANSFER);
  }
  o_c = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr));
  if ($.copy(b_val).gt(u64("0"))) {
    AptosFramework.Coin.merge$(o_c.b_c, AptosFramework.Coin.withdraw$(user, $.copy(b_val), $c, [$p[0]] as TypeTag[]), $c, [$p[0]] as TypeTag[]);
    o_c.b_a = $.copy(o_c.b_a).add($.copy(b_val));
  }
  else{
  }
  if ($.copy(q_val).gt(u64("0"))) {
    AptosFramework.Coin.merge$(o_c.q_c, AptosFramework.Coin.withdraw$(user, $.copy(q_val), $c, [$p[1]] as TypeTag[]), $c, [$p[1]] as TypeTag[]);
    o_c.q_a = $.copy(o_c.q_a).add($.copy(q_val));
  }
  else{
  }
  temp$3 = user;
  temp$2 = Caps.orders_f_c$($c);
  update_s_c$(temp$3, temp$2, $c);
  return;
}


export function buildPayload_deposit (
  b_val: U64,
  q_val: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::deposit",
    typeParamStrings,
    [
      $.payloadArg(b_val),
      $.payloadArg(q_val),
    ]
  );

}
export function exists_o_c$ (
  a: HexString,
  _c: Orders.FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  return $c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(a));
}

export function get_available_collateral$ (
  user: HexString,
  _c: Orders.FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U64, U64] {
  let order_collateral;
  order_collateral = $c.borrow_global<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(user));
  return [$.copy(order_collateral.b_a), $.copy(order_collateral.q_a)];
}

export function init_containers$ (
  user: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, o_c, user_addr;
  if (!Registry.is_registered$($c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_MARKET);
  }
  user_addr = Std.Signer.address_of$(user, $c);
  if (!!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(user_addr))) {
    throw $.abortCode(E_O_C_EXISTS);
  }
  if (!!Orders.exists_orders$($.copy(user_addr), $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_O_O_EXISTS);
  }
  temp$1 = AptosFramework.Coin.zero$($c, [$p[0]] as TypeTag[]);
  temp$2 = u64("0");
  temp$3 = AptosFramework.Coin.zero$($c, [$p[1]] as TypeTag[]);
  temp$4 = u64("0");
  o_c = new OC({ b_a: temp$2, b_c: temp$1, q_a: temp$4, q_c: temp$3 }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]));
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), user, o_c);
  temp$7 = user;
  temp$6 = Registry.scale_factor$($c, [$p[2]] as TypeTag[]);
  temp$5 = Caps.orders_f_c$($c);
  Orders.init_orders$(temp$7, temp$6, temp$5, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}


export function buildPayload_init_containers (
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::init_containers",
    typeParamStrings,
    []
  );

}
export function init_o_c$ (
  user: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, temp$4, o_c;
  if (!!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), Std.Signer.address_of$(user, $c))) {
    throw $.abortCode(E_O_C_EXISTS);
  }
  if (!Registry.is_registered$($c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_MARKET);
  }
  temp$1 = AptosFramework.Coin.zero$($c, [$p[0]] as TypeTag[]);
  temp$2 = u64("0");
  temp$3 = AptosFramework.Coin.zero$($c, [$p[1]] as TypeTag[]);
  temp$4 = u64("0");
  o_c = new OC({ b_a: temp$2, b_c: temp$1, q_a: temp$4, q_c: temp$3 }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]));
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), user, o_c);
  return;
}

export function init_user$ (
  user: HexString,
  $c: AptosDataCache,
): void {
  let user_addr;
  user_addr = Std.Signer.address_of$(user, $c);
  if (!!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "SC", []), $.copy(user_addr))) {
    throw $.abortCode(E_S_C_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "SC", []), user, new SC({ i: AptosFramework.Account.get_sequence_number$($.copy(user_addr), $c) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "SC", [])));
  return;
}


export function buildPayload_init_user (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::init_user",
    typeParamStrings,
    []
  );

}
export function process_fill$ (
  target: HexString,
  incoming: HexString,
  side: boolean,
  id: U128,
  size: U64,
  scale_factor: U64,
  complete: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, base_coins, base_from, base_to, base_to_route, gets_base, gets_quote, orders_cap, quote_coins, quote_to_route, yields_base;
  orders_cap = Caps.orders_f_c$($c);
  if (complete) {
    Orders.remove_order$($.copy(target), side, $.copy(id), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  else{
    Orders.decrement_order_size$($.copy(target), side, $.copy(id), $.copy(size), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  base_to_route = $.copy(size).mul($.copy(scale_factor));
  quote_to_route = $.copy(size).mul(ID.price$($.copy(id), $c));
  if ((side == ASK)) {
    [temp$1, temp$2] = [$.copy(incoming), $.copy(target)];
  }
  else{
    [temp$1, temp$2] = [$.copy(target), $.copy(incoming)];
  }
  [base_to, base_from] = [temp$1, temp$2];
  yields_base = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(base_from));
  base_coins = AptosFramework.Coin.extract$(yields_base.b_c, $.copy(base_to_route), $c, [$p[0]] as TypeTag[]);
  gets_base = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(base_to));
  AptosFramework.Coin.merge$(gets_base.b_c, base_coins, $c, [$p[0]] as TypeTag[]);
  gets_base.b_a = $.copy(gets_base.b_a).add($.copy(base_to_route));
  quote_coins = AptosFramework.Coin.extract$(gets_base.q_c, $.copy(quote_to_route), $c, [$p[1]] as TypeTag[]);
  gets_quote = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(base_from));
  AptosFramework.Coin.merge$(gets_quote.q_c, quote_coins, $c, [$p[1]] as TypeTag[]);
  gets_quote.q_a = $.copy(gets_quote.q_a).add($.copy(quote_to_route));
  return;
}

export function submit_ask$ (
  user: HexString,
  host: HexString,
  price: U64,
  size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  submit_limit_order$(user, $.copy(host), ASK, $.copy(price), $.copy(size), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}


export function buildPayload_submit_ask (
  host: HexString,
  price: U64,
  size: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::submit_ask",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(price),
      $.payloadArg(size),
    ]
  );

}
export function submit_bid$ (
  user: HexString,
  host: HexString,
  price: U64,
  size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  submit_limit_order$(user, $.copy(host), BID, $.copy(price), $.copy(size), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}


export function buildPayload_submit_bid (
  host: HexString,
  price: U64,
  size: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::submit_bid",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(price),
      $.payloadArg(size),
    ]
  );

}
export function submit_limit_order$ (
  user: HexString,
  host: HexString,
  side: boolean,
  price: U64,
  size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$10, temp$11, temp$12, temp$13, temp$14, temp$15, temp$17, temp$18, temp$19, temp$2, temp$20, temp$21, temp$22, temp$23, temp$24, temp$25, temp$26, temp$27, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, addr, b_c_subs, c_s, id, id__16, o_c, q_c_subs, v_n;
  temp$2 = user;
  temp$1 = Caps.orders_f_c$($c);
  update_s_c$(temp$2, temp$1, $c);
  temp$4 = $.copy(host);
  temp$3 = Caps.book_f_c$($c);
  if (!Book.exists_book$(temp$4, temp$3, $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_MARKET);
  }
  addr = Std.Signer.address_of$(user, $c);
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr))) {
    throw $.abortCode(E_NO_O_C);
  }
  o_c = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr));
  v_n = Version.get_v_n$($c);
  if ((side == ASK)) {
    id = ID.id_a$($.copy(price), $.copy(v_n), $c);
    temp$9 = $.copy(addr);
    temp$8 = $.copy(id);
    temp$7 = $.copy(price);
    temp$6 = $.copy(size);
    temp$5 = Caps.orders_f_c$($c);
    [b_c_subs, ] = Orders.add_ask$(temp$9, temp$8, temp$7, temp$6, temp$5, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    if (!!$.copy(b_c_subs).gt($.copy(o_c.b_a))) {
      throw $.abortCode(E_NOT_ENOUGH_COLLATERAL);
    }
    o_c.b_a = $.copy(o_c.b_a).sub($.copy(b_c_subs));
    temp$15 = $.copy(host);
    temp$14 = $.copy(addr);
    temp$13 = $.copy(id);
    temp$12 = $.copy(price);
    temp$11 = $.copy(size);
    temp$10 = Caps.book_f_c$($c);
    c_s = Book.add_ask$(temp$15, temp$14, temp$13, temp$12, temp$11, temp$10, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  else{
    id__16 = ID.id_b$($.copy(price), $.copy(v_n), $c);
    temp$21 = $.copy(addr);
    temp$20 = $.copy(id__16);
    temp$19 = $.copy(price);
    temp$18 = $.copy(size);
    temp$17 = Caps.orders_f_c$($c);
    [, q_c_subs] = Orders.add_bid$(temp$21, temp$20, temp$19, temp$18, temp$17, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    if (!!$.copy(q_c_subs).gt($.copy(o_c.q_a))) {
      throw $.abortCode(E_NOT_ENOUGH_COLLATERAL);
    }
    o_c.q_a = $.copy(o_c.q_a).sub($.copy(q_c_subs));
    temp$27 = $.copy(host);
    temp$26 = $.copy(addr);
    temp$25 = $.copy(id__16);
    temp$24 = $.copy(price);
    temp$23 = $.copy(size);
    temp$22 = Caps.book_f_c$($c);
    c_s = Book.add_bid$(temp$27, temp$26, temp$25, temp$24, temp$23, temp$22, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  if (!!c_s) {
    throw $.abortCode(E_CROSSES_SPREAD);
  }
  return;
}

export function update_s_c$ (
  u: HexString,
  _c: Orders.FriendCap,
  $c: AptosDataCache,
): void {
  let s_c, s_n, user_addr;
  user_addr = Std.Signer.address_of$(u, $c);
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "SC", []), $.copy(user_addr))) {
    throw $.abortCode(E_NO_S_C);
  }
  s_c = $c.borrow_global_mut<SC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "SC", []), $.copy(user_addr));
  s_n = AptosFramework.Account.get_sequence_number$($.copy(user_addr), $c);
  if (!$.copy(s_n).gt($.copy(s_c.i))) {
    throw $.abortCode(E_INVALID_S_N);
  }
  s_c.i = $.copy(s_n);
  return;
}

export function withdraw$ (
  user: HexString,
  b_val: U64,
  q_val: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, addr, o_c;
  addr = Std.Signer.address_of$(user, $c);
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr))) {
    throw $.abortCode(E_NO_O_C);
  }
  if ($.copy(b_val).gt(u64("0"))) {
    temp$1 = true;
  }
  else{
    temp$1 = $.copy(q_val).gt(u64("0"));
  }
  if (!temp$1) {
    throw $.abortCode(E_NO_TRANSFER);
  }
  o_c = $c.borrow_global_mut<OC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "User", "OC", [$p[0], $p[1], $p[2]]), $.copy(addr));
  if ($.copy(b_val).gt(u64("0"))) {
    if (!!$.copy(b_val).gt($.copy(o_c.b_a))) {
      throw $.abortCode(E_WITHDRAW_TOO_MUCH);
    }
    AptosFramework.Coin.deposit$($.copy(addr), AptosFramework.Coin.extract$(o_c.b_c, $.copy(b_val), $c, [$p[0]] as TypeTag[]), $c, [$p[0]] as TypeTag[]);
    o_c.b_a = $.copy(o_c.b_a).sub($.copy(b_val));
  }
  else{
  }
  if ($.copy(q_val).gt(u64("0"))) {
    if (!!$.copy(q_val).gt($.copy(o_c.q_a))) {
      throw $.abortCode(E_WITHDRAW_TOO_MUCH);
    }
    AptosFramework.Coin.deposit$($.copy(addr), AptosFramework.Coin.extract$(o_c.q_c, $.copy(q_val), $c, [$p[1]] as TypeTag[]), $c, [$p[1]] as TypeTag[]);
    o_c.q_a = $.copy(o_c.q_a).sub($.copy(q_val));
  }
  else{
  }
  temp$3 = user;
  temp$2 = Caps.orders_f_c$($c);
  update_s_c$(temp$3, temp$2, $c);
  return;
}


export function buildPayload_withdraw (
  b_val: U64,
  q_val: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::withdraw",
    typeParamStrings,
    [
      $.payloadArg(b_val),
      $.payloadArg(q_val),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::OC", OC.OCParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::User::SC", SC.SCParser);
}

