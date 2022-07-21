import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as CritBit from "./CritBit";
import * as ID from "./ID";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
export const moduleName = "Book";

export const ASK : boolean = true;
export const BID : boolean = false;
export const E_BOOK_EXISTS : U64 = u64("0");
export const E_NOT_ECONIA : U64 = u64("1");
export const E_NO_BOOK : U64 = u64("3");
export const E_SELF_MATCH : U64 = u64("2");
export const HI_128 : U128 = u128("340282366920938463463374607431768211455");
export const L : boolean = true;
export const MAX_BID_DEFAULT : U128 = u128("0");
export const MIN_ASK_DEFAULT : U128 = u128("340282366920938463463374607431768211455");
export const R : boolean = false;


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

export class OB 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OB";
  static typeParameters: TypeParamDeclType[] = [
    { name: "B", isPhantom: true },
    { name: "Q", isPhantom: true },
    { name: "E", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "f", typeTag: AtomicTypeTag.U64 },
  { name: "a", typeTag: new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "CB", [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])]) },
  { name: "b", typeTag: new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "CB", [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])]) },
  { name: "m_a", typeTag: AtomicTypeTag.U128 },
  { name: "m_b", typeTag: AtomicTypeTag.U128 }];

  f: U64;
  a: CritBit.CB;
  b: CritBit.CB;
  m_a: U128;
  m_b: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.f = proto['f'] as U64;
    this.a = proto['a'] as CritBit.CB;
    this.b = proto['b'] as CritBit.CB;
    this.m_a = proto['m_a'] as U128;
    this.m_b = proto['m_b'] as U128;
  }

  static OBParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OB {
    const proto = $.parseStructProto(data, typeTag, repo, OB);
    return new OB(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, OB, typeParams);
    return result as unknown as OB;
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
  { name: "price", typeTag: AtomicTypeTag.U64 },
  { name: "size", typeTag: AtomicTypeTag.U64 }];

  price: U64;
  size: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.price = proto['price'] as U64;
    this.size = proto['size'] as U64;
  }

  static OrderParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Order {
    const proto = $.parseStructProto(data, typeTag, repo, Order);
    return new Order(proto, typeTag);
  }

}

export class P 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "P";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "s", typeTag: AtomicTypeTag.U64 },
  { name: "a", typeTag: AtomicTypeTag.Address }];

  s: U64;
  a: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.s = proto['s'] as U64;
    this.a = proto['a'] as HexString;
  }

  static PParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : P {
    const proto = $.parseStructProto(data, typeTag, repo, P);
    return new P(proto, typeTag);
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
  { name: "size", typeTag: AtomicTypeTag.U64 }];

  price: U64;
  size: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.price = proto['price'] as U64;
    this.size = proto['size'] as U64;
  }

  static PriceLevelParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PriceLevel {
    const proto = $.parseStructProto(data, typeTag, repo, PriceLevel);
    return new PriceLevel(proto, typeTag);
  }

}
export function add_ask$ (
  host: HexString,
  user: HexString,
  id: U128,
  price: U64,
  size: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  return add_position$($.copy(host), $.copy(user), ASK, $.copy(id), $.copy(price), $.copy(size), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function add_bid$ (
  host: HexString,
  user: HexString,
  id: U128,
  price: U64,
  size: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  return add_position$($.copy(host), $.copy(user), BID, $.copy(id), $.copy(price), $.copy(size), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function add_position$ (
  host: HexString,
  user: HexString,
  side: boolean,
  id: U128,
  price: U64,
  size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  let m_a_p, m_b_p, o_b;
  o_b = $c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host));
  [m_a_p, m_b_p] = [ID.price$($.copy(o_b.m_a), $c), ID.price$($.copy(o_b.m_b), $c)];
  if ((side == ASK)) {
    if ($.copy(price).gt($.copy(m_b_p))) {
      CritBit.insert$(o_b.a, $.copy(id), new P({ s: $.copy(size), a: $.copy(user) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
      if ($.copy(price).lt($.copy(m_a_p))) {
        o_b.m_a = $.copy(id);
      }
      else{
      }
    }
    else{
      return true;
    }
  }
  else{
    if ($.copy(price).lt($.copy(m_a_p))) {
      CritBit.insert$(o_b.b, $.copy(id), new P({ s: $.copy(size), a: $.copy(user) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
      if ($.copy(price).gt($.copy(m_b_p))) {
        o_b.m_b = $.copy(id);
      }
      else{
      }
    }
    else{
      return true;
    }
  }
  return false;
}

export function cancel_ask$ (
  host: HexString,
  id: U128,
  friend_cap: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  cancel_position$($.copy(host), ASK, $.copy(id), friend_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}

export function cancel_bid$ (
  host: HexString,
  id: U128,
  friend_cap: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  cancel_position$($.copy(host), BID, $.copy(id), friend_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}

export function cancel_position$ (
  host: HexString,
  side: boolean,
  id: U128,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, asks, bids, o_b;
  o_b = $c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host));
  if ((side == ASK)) {
    asks = o_b.a;
    CritBit.pop$(asks, $.copy(id), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
    if ($.copy(o_b.m_a).eq($.copy(id))) {
      if (CritBit.is_empty$(asks, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[])) {
        temp$1 = MIN_ASK_DEFAULT;
      }
      else{
        temp$1 = CritBit.min_key$(asks, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
      }
      o_b.m_a = temp$1;
    }
    else{
    }
  }
  else{
    bids = o_b.b;
    CritBit.pop$(bids, $.copy(id), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
    if ($.copy(o_b.m_b).eq($.copy(id))) {
      if (CritBit.is_empty$(bids, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[])) {
        temp$2 = MAX_BID_DEFAULT;
      }
      else{
        temp$2 = CritBit.max_key$(bids, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
      }
      o_b.m_b = temp$2;
    }
    else{
    }
  }
  return;
}

export function check_size$ (
  side: boolean,
  target_id: U128,
  target_size: U64,
  size_left: U64,
  quote_available: U64,
  $c: AptosDataCache,
): [boolean, U64] {
  let temp$1, quote_to_fill, target_price;
  if ((side == BID)) {
    return [false, $.copy(size_left)];
  }
  else{
  }
  target_price = ID.price$($.copy(target_id), $c);
  if ($.copy(size_left).ge($.copy(target_size))) {
    temp$1 = $.copy(target_price).mul($.copy(target_size));
  }
  else{
    temp$1 = $.copy(target_price).mul($.copy(size_left));
  }
  quote_to_fill = temp$1;
  if ($.copy(quote_to_fill).gt($.copy(quote_available))) {
    return [true, $.copy(quote_available).div($.copy(target_price))];
  }
  else{
    return [false, $.copy(size_left)];
  }
}

export function exists_book$ (
  a: HexString,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  return $c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(a));
}

export function get_friend_cap$ (
  account: HexString,
  $c: AptosDataCache,
): FriendCap {
  if (!(Std.Signer.address_of$(account, $c).hex() === new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  return new FriendCap({  }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "FriendCap", []));
}

export function get_orders$ (
  host_address: HexString,
  side: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): Order[] {
  let temp$1, temp$2, n_positions, orders, price, remaining_traversals, size, target_id, target_parent_field, target_position_ref_mut, traversal_dir, tree;
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host_address))) {
    throw $.abortCode(E_NO_BOOK);
  }
  orders = Std.Vector.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "Order", [])] as TypeTag[]);
  if ((side == ASK)) {
    [temp$1, temp$2] = [$c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host_address)).a, R];
  }
  else{
    [temp$1, temp$2] = [$c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host_address)).b, L];
  }
  [tree, traversal_dir] = [temp$1, temp$2];
  n_positions = CritBit.length$(tree, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
  if ($.copy(n_positions).eq(u64("0"))) {
    return orders;
  }
  else{
  }
  remaining_traversals = $.copy(n_positions).sub(u64("1"));
  [target_id, target_position_ref_mut, target_parent_field, ] = CritBit.traverse_init_mut$(tree, traversal_dir, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
  while (true) {
    price = ID.price$($.copy(target_id), $c);
    size = $.copy(target_position_ref_mut.s);
    Std.Vector.push_back$(orders, new Order({ price: $.copy(price), size: $.copy(size) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "Order", [])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "Order", [])] as TypeTag[]);
    if ($.copy(remaining_traversals).eq(u64("0"))) {
      return orders;
    }
    else{
    }
    [target_id, target_position_ref_mut, target_parent_field, ] = CritBit.traverse_mut$(tree, $.copy(target_id), $.copy(target_parent_field), traversal_dir, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
    remaining_traversals = $.copy(remaining_traversals).sub(u64("1"));
  }
}

export function get_price_levels$ (
  orders: Order[],
  $c: AptosDataCache,
): PriceLevel[] {
  let level_price, level_size, n_orders, order, order_index, price_levels;
  price_levels = Std.Vector.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "PriceLevel", [])] as TypeTag[]);
  n_orders = Std.Vector.length$(orders, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "Order", [])] as TypeTag[]);
  if ($.copy(n_orders).eq(u64("0"))) {
    return price_levels;
  }
  else{
  }
  [order_index, level_price, level_size] = [u64("0"), u64("0"), u64("0")];
  while (true) {
    order = Std.Vector.borrow$(orders, $.copy(order_index), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "Order", [])] as TypeTag[]);
    if ($.copy(order.price).neq($.copy(level_price))) {
      if ($.copy(order_index).gt(u64("0"))) {
        Std.Vector.push_back$(price_levels, new PriceLevel({ price: $.copy(level_price), size: $.copy(level_size) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "PriceLevel", [])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "PriceLevel", [])] as TypeTag[]);
      }
      else{
      }
      [level_price, level_size] = [$.copy(order.price), $.copy(order.size)];
    }
    else{
      level_size = $.copy(level_size).add($.copy(order.size));
    }
    order_index = $.copy(order_index).add(u64("1"));
    if ($.copy(order_index).eq($.copy(n_orders))) {
      Std.Vector.push_back$(price_levels, new PriceLevel({ price: $.copy(level_price), size: $.copy(level_size) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "PriceLevel", [])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "PriceLevel", [])] as TypeTag[]);
      break;
    }
    else{
    }
  }
  return price_levels;
}

export function init_book$ (
  host: HexString,
  f: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, m_a, m_b, o_b;
  temp$2 = Std.Signer.address_of$(host, $c);
  temp$1 = new FriendCap({  }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "FriendCap", []));
  if (!!exists_book$(temp$2, temp$1, $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_BOOK_EXISTS);
  }
  m_a = MIN_ASK_DEFAULT;
  m_b = MAX_BID_DEFAULT;
  o_b = new OB({ f: $.copy(f), a: CritBit.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]), b: CritBit.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]), m_a: $.copy(m_a), m_b: $.copy(m_b) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]));
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), host, o_b);
  return;
}

export function n_asks$ (
  addr: HexString,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  return CritBit.length$($c.borrow_global<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(addr)).a, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
}

export function n_bids$ (
  addr: HexString,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  return CritBit.length$($c.borrow_global<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(addr)).b, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
}

export function process_fill_scenarios$ (
  i_addr: HexString,
  t_p_r: P,
  size: U64,
  $c: AptosDataCache,
): [U64, boolean] {
  let filled, perfect_match;
  perfect_match = false;
  if (!($.copy(i_addr).hex() !== $.copy(t_p_r.a).hex())) {
    throw $.abortCode(E_SELF_MATCH);
  }
  if ($.copy(size).lt($.copy(t_p_r.s))) {
    filled = $.copy(size);
    t_p_r.s = $.copy(t_p_r.s).sub($.copy(size));
  }
  else{
    if ($.copy(size).gt($.copy(t_p_r.s))) {
      filled = $.copy(t_p_r.s);
    }
    else{
      filled = $.copy(size);
      perfect_match = true;
    }
  }
  return [$.copy(filled), perfect_match];
}

export function refresh_extreme_order_id$ (
  addr: HexString,
  side: boolean,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, order_book;
  order_book = $c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(addr));
  if ((side == ASK)) {
    if (CritBit.is_empty$(order_book.a, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[])) {
      temp$1 = MIN_ASK_DEFAULT;
    }
    else{
      temp$1 = CritBit.min_key$(order_book.a, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
    }
    order_book.m_a = temp$1;
  }
  else{
    if (CritBit.is_empty$(order_book.b, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[])) {
      temp$2 = MAX_BID_DEFAULT;
    }
    else{
      temp$2 = CritBit.max_key$(order_book.b, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
    }
    order_book.m_b = temp$2;
  }
  return;
}

export function scale_factor$ (
  addr: HexString,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): U64 {
  return $.copy($c.borrow_global<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(addr)).f);
}

export function traverse_fill$ (
  host: HexString,
  incoming_address: HexString,
  side: boolean,
  size_left: U64,
  quote_available: U64,
  init: boolean,
  n_positions: U64,
  start_id: U128,
  start_parent_field: U64,
  start_child_index: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U128, HexString, U64, U64, U64, boolean, boolean] {
  let temp$1, temp$2, filled, insufficient_quote, perfect, size, target_address, target_child_index, target_id, target_parent_field, target_position_ref_mut, traversal_dir, tree;
  if ((side == ASK)) {
    [temp$1, temp$2] = [$c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host)).a, R];
  }
  else{
    [temp$1, temp$2] = [$c.borrow_global_mut<OB>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "OB", [$p[0], $p[1], $p[2]]), $.copy(host)).b, L];
  }
  [tree, traversal_dir] = [temp$1, temp$2];
  if (init) {
    [target_id, target_position_ref_mut, target_parent_field, target_child_index] = CritBit.traverse_init_mut$(tree, traversal_dir, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
  }
  else{
    [target_id, target_position_ref_mut, target_parent_field, target_child_index, {  }] = CritBit.traverse_pop_mut$(tree, $.copy(start_id), $.copy(start_parent_field), $.copy(start_child_index), $.copy(n_positions), traversal_dir, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "P", [])] as TypeTag[]);
  }
  target_address = $.copy(target_position_ref_mut.a);
  [insufficient_quote, size] = check_size$(side, $.copy(target_id), $.copy(target_position_ref_mut.s), $.copy(size_left), $.copy(quote_available), $c);
  [filled, perfect] = process_fill_scenarios$($.copy(incoming_address), target_position_ref_mut, $.copy(size), $c);
  return [$.copy(target_id), $.copy(target_address), $.copy(target_parent_field), $.copy(target_child_index), $.copy(filled), perfect, insufficient_quote];
}

export function traverse_init_fill$ (
  host: HexString,
  incoming_address: HexString,
  side: boolean,
  size_left: U64,
  quote_available: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U128, HexString, U64, U64, U64, boolean, boolean] {
  return traverse_fill$($.copy(host), $.copy(incoming_address), side, $.copy(size_left), $.copy(quote_available), true, u64("0"), u128("0"), u64("0"), u64("0"), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function traverse_pop_fill$ (
  host: HexString,
  incoming_address: HexString,
  side: boolean,
  size_left: U64,
  quote_available: U64,
  n_positions: U64,
  start_id: U128,
  start_parent_field: U64,
  start_child_index: U64,
  _c: FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U128, HexString, U64, U64, U64, boolean, boolean] {
  return traverse_fill$($.copy(host), $.copy(incoming_address), side, $.copy(size_left), $.copy(quote_available), false, $.copy(n_positions), $.copy(start_id), $.copy(start_parent_field), $.copy(start_child_index), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Book::FriendCap", FriendCap.FriendCapParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Book::OB", OB.OBParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Book::Order", Order.OrderParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Book::P", P.PParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Book::PriceLevel", PriceLevel.PriceLevelParser);
}

