import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as CritBit from "./CritBit";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
export const moduleName = "Orders";

export const ASK : boolean = true;
export const BID : boolean = false;
export const E_BASE_OVERFLOW : U64 = u64("4");
export const E_NOT_ECONIA : U64 = u64("2");
export const E_NO_ORDERS : U64 = u64("1");
export const E_NO_SUCH_ORDER : U64 = u64("7");
export const E_ORDERS_EXISTS : U64 = u64("0");
export const E_PRICE_0 : U64 = u64("3");
export const E_QUOTE_OVERFLOW : U64 = u64("5");
export const E_SIZE_0 : U64 = u64("6");
export const HI_64 : U64 = u64("18446744073709551615");


export class FriendCap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "FriendCap";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static FriendCapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : FriendCap {
    const proto = $.parseStructProto(data, typeTag, repo, FriendCap);
    return new FriendCap(proto, typeTag);
  }

}

export class OO 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OO";
  static typeParameters: TypeParamDeclType[] = [
    { name: "B", isPhantom: true },
    { name: "Q", isPhantom: true },
    { name: "E", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "f", typeTag: AtomicTypeTag.U64 },
  { name: "a", typeTag: new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "CB", [AtomicTypeTag.U64]) },
  { name: "b", typeTag: new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "CB", [AtomicTypeTag.U64]) }];

  f: U64;
  a: CritBit.CB;
  b: CritBit.CB;

  constructor(proto: any, public typeTag: TypeTag) {
    this.f = proto['f'] as U64;
    this.a = proto['a'] as CritBit.CB;
    this.b = proto['b'] as CritBit.CB;
  }

  static OOParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OO {
    const proto = $.parseStructProto(data, typeTag, repo, OO);
    return new OO(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, OO, typeParams);
    return result as unknown as OO;
  }
}
export function add_ask$ (
  addr: HexString,
  id: U128,
  price: U64,
  size: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U64, U64] {
  return add_order$($.copy(addr), ASK, $.copy(id), $.copy(price), $.copy(size), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function add_bid$ (
  addr: HexString,
  id: U128,
  price: U64,
  size: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U64, U64] {
  return add_order$($.copy(addr), BID, $.copy(id), $.copy(price), $.copy(size), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function add_order$ (
  addr: HexString,
  side: boolean,
  id: U128,
  price: U64,
  size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U64, U64] {
  let base_subunits, o_o, quote_subunits, s_f;
  if (!$.copy(price).gt(u64("0"))) {
    throw $.abortCode(E_PRICE_0);
  }
  if (!$.copy(size).gt(u64("0"))) {
    throw $.abortCode(E_SIZE_0);
  }
  if (!exists_orders$($.copy(addr), $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_ORDERS);
  }
  o_o = $c.borrow_global_mut<OO>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(addr));
  s_f = $.copy(o_o.f);
  base_subunits = u128($.copy(size)).mul(u128($.copy(s_f)));
  if (!!$.copy(base_subunits).gt(u128(HI_64))) {
    throw $.abortCode(E_BASE_OVERFLOW);
  }
  quote_subunits = u128($.copy(size)).mul(u128($.copy(price)));
  if (!!$.copy(quote_subunits).gt(u128(HI_64))) {
    throw $.abortCode(E_QUOTE_OVERFLOW);
  }
  if ((side == ASK)) {
    CritBit.insert$(o_o.a, $.copy(id), $.copy(size), $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
  else{
    CritBit.insert$(o_o.b, $.copy(id), $.copy(size), $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
  return [u64($.copy(base_subunits)), u64($.copy(quote_subunits))];
}

export function cancel_ask$ (
  addr: HexString,
  id: U128,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  return cancel_order$($.copy(addr), ASK, $.copy(id), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function cancel_bid$ (
  addr: HexString,
  id: U128,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  return cancel_order$($.copy(addr), BID, $.copy(id), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function cancel_order$ (
  addr: HexString,
  side: boolean,
  id: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  let o_o;
  if (!exists_orders$($.copy(addr), $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_ORDERS);
  }
  o_o = $c.borrow_global_mut<OO>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(addr));
  if ((side == ASK)) {
    if (!CritBit.has_key$(o_o.a, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[])) {
      throw $.abortCode(E_NO_SUCH_ORDER);
    }
    return CritBit.pop$(o_o.a, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
  else{
    if (!CritBit.has_key$(o_o.b, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[])) {
      throw $.abortCode(E_NO_SUCH_ORDER);
    }
    return CritBit.pop$(o_o.b, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
}

export function decrement_order_size$ (
  user_addr: HexString,
  side: boolean,
  id: U128,
  amount: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, order_size, tree;
  if ((side == ASK)) {
    temp$1 = $c.borrow_global_mut<OO>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(user_addr)).a;
  }
  else{
    temp$1 = $c.borrow_global_mut<OO>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(user_addr)).b;
  }
  tree = temp$1;
  order_size = CritBit.borrow_mut$(tree, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[]);
  $.set(order_size, $.copy(order_size).sub($.copy(amount)));
  return;
}

export function exists_orders$ (
  a: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  return $c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(a));
}

export function get_friend_cap$ (
  account: HexString,
  $c: AptosDataCache,
): FriendCap {
  if (!(Std.Signer.address_of$(account, $c).hex() === new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  return new FriendCap({  }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "FriendCap", []));
}

export function init_orders$ (
  user: HexString,
  f: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let o_o;
  if (!!exists_orders$(Std.Signer.address_of$(user, $c), $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_ORDERS_EXISTS);
  }
  o_o = new OO({ f: $.copy(f), a: CritBit.empty$($c, [AtomicTypeTag.U64] as TypeTag[]), b: CritBit.empty$($c, [AtomicTypeTag.U64] as TypeTag[]) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]));
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), user, o_o);
  return;
}

export function remove_order$ (
  user_addr: HexString,
  side: boolean,
  id: U128,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let open_orders;
  open_orders = $c.borrow_global_mut<OO>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(user_addr));
  if ((side == ASK)) {
    CritBit.pop$(open_orders.a, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
  else{
    CritBit.pop$(open_orders.b, $.copy(id), $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
  return;
}

export function scale_factor$ (
  addr: HexString,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  return $.copy($c.borrow_global<OO>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "OO", [$p[0], $p[1], $p[2]]), $.copy(addr)).f);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Orders::FriendCap", FriendCap.FriendCapParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Orders::OO", OO.OOParser);
}

