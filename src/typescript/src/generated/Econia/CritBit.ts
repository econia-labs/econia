import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
export const moduleName = "CritBit";

export const E_BIT_NOT_0_OR_1 : U64 = u64("0");
export const E_BORROW_EMPTY : U64 = u64("3");
export const E_DESTROY_NOT_EMPTY : U64 = u64("1");
export const E_HAS_K : U64 = u64("2");
export const E_INSERT_FULL : U64 = u64("5");
export const E_LOOKUP_EMPTY : U64 = u64("7");
export const E_NOT_HAS_K : U64 = u64("4");
export const E_POP_EMPTY : U64 = u64("6");
export const HI_128 : U128 = u128("340282366920938463463374607431768211455");
export const HI_64 : U64 = u64("18446744073709551615");
export const IN : U64 = u64("0");
export const L : boolean = true;
export const MSB_u128 : U8 = u8("127");
export const N_TYPE : U8 = u8("63");
export const OUT : U64 = u64("1");
export const R : boolean = false;
export const ROOT : U64 = u64("18446744073709551615");


export class CB 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CB";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "r", typeTag: AtomicTypeTag.U64 },
  { name: "i", typeTag: new VectorTag(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])) },
  { name: "o", typeTag: new VectorTag(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [new $.TypeParamIdx(0)])) }];

  r: U64;
  i: I[];
  o: O[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.r = proto['r'] as U64;
    this.i = proto['i'] as I[];
    this.o = proto['o'] as O[];
  }

  static CBParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CB {
    const proto = $.parseStructProto(data, typeTag, repo, CB);
    return new CB(proto, typeTag);
  }

}

export class I 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "I";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "c", typeTag: AtomicTypeTag.U8 },
  { name: "p", typeTag: AtomicTypeTag.U64 },
  { name: "l", typeTag: AtomicTypeTag.U64 },
  { name: "r", typeTag: AtomicTypeTag.U64 }];

  c: U8;
  p: U64;
  l: U64;
  r: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.c = proto['c'] as U8;
    this.p = proto['p'] as U64;
    this.l = proto['l'] as U64;
    this.r = proto['r'] as U64;
  }

  static IParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : I {
    const proto = $.parseStructProto(data, typeTag, repo, I);
    return new I(proto, typeTag);
  }

}

export class O 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "O";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "k", typeTag: AtomicTypeTag.U128 },
  { name: "v", typeTag: new $.TypeParamIdx(0) },
  { name: "p", typeTag: AtomicTypeTag.U64 }];

  k: U128;
  v: any;
  p: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.k = proto['k'] as U128;
    this.v = proto['v'] as any;
    this.p = proto['p'] as U64;
  }

  static OParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : O {
    const proto = $.parseStructProto(data, typeTag, repo, O);
    return new O(proto, typeTag);
  }

}
export function b_s_o$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): O {
  let temp$1, i_c, n;
  if (is_out$($.copy(cb.r), $c)) {
    return Std.Vector.borrow$(cb.o, o_v$($.copy(cb.r), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  }
  else{
  }
  n = Std.Vector.borrow$(cb.i, $.copy(cb.r), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  while (true) {
    if (is_set$($.copy(k), $.copy(n.c), $c)) {
      temp$1 = $.copy(n.r);
    }
    else{
      temp$1 = $.copy(n.l);
    }
    i_c = temp$1;
    if (is_out$($.copy(i_c), $c)) {
      return Std.Vector.borrow$(cb.o, o_v$($.copy(i_c), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
    }
    else{
    }
    n = Std.Vector.borrow$(cb.i, $.copy(i_c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  }
}

export function b_s_o_m$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): O {
  let temp$1, i_c, n;
  if (is_out$($.copy(cb.r), $c)) {
    return Std.Vector.borrow_mut$(cb.o, o_v$($.copy(cb.r), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  }
  else{
  }
  n = Std.Vector.borrow$(cb.i, $.copy(cb.r), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  while (true) {
    if (is_set$($.copy(k), $.copy(n.c), $c)) {
      temp$1 = $.copy(n.r);
    }
    else{
      temp$1 = $.copy(n.l);
    }
    i_c = temp$1;
    if (is_out$($.copy(i_c), $c)) {
      return Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_c), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
    }
    else{
    }
    n = Std.Vector.borrow$(cb.i, $.copy(i_c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  }
}

export function borrow$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let c_o;
  if (!!is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_BORROW_EMPTY);
  }
  c_o = b_s_o$(cb, $.copy(k), $c, [$p[0]] as TypeTag[]);
  if (!$.copy(c_o.k).eq($.copy(k))) {
    throw $.abortCode(E_NOT_HAS_K);
  }
  return c_o.v;
}

export function borrow_mut$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let c_o;
  if (!!is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_BORROW_EMPTY);
  }
  c_o = b_s_o_m$(cb, $.copy(k), $c, [$p[0]] as TypeTag[]);
  if (!$.copy(c_o.k).eq($.copy(k))) {
    throw $.abortCode(E_NOT_HAS_K);
  }
  return c_o.v;
}

export function check_len$ (
  l: U64,
  $c: AptosDataCache,
): void {
  if (!$.copy(l).lt(HI_64.xor(OUT.shl(N_TYPE)))) {
    throw $.abortCode(E_INSERT_FULL);
  }
  return;
}

export function crit_bit$ (
  s1: U128,
  s2: U128,
  $c: AptosDataCache,
): U8 {
  let l, m, s, u, x;
  x = $.copy(s1).xor($.copy(s2));
  l = u8("0");
  u = MSB_u128;
  while (true) {
    m = $.copy(l).add($.copy(u)).div(u8("2"));
    s = $.copy(x).shr($.copy(m));
    if ($.copy(s).eq(u128("1"))) {
      return $.copy(m);
    }
    else{
    }
    if ($.copy(s).gt(u128("1"))) {
      l = $.copy(m).add(u8("1"));
    }
    else{
      u = $.copy(m).sub(u8("1"));
    }
  }
}

export function destroy_empty$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  if (!is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_DESTROY_NOT_EMPTY);
  }
  let { i: i, o: o } = cb;
  Std.Vector.destroy_empty$(i, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  Std.Vector.destroy_empty$(o, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  return;
}

export function empty$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): CB {
  return new CB({ r: u64("0"), i: Std.Vector.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]), o: Std.Vector.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "CB", [$p[0]]));
}

export function has_key$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): boolean {
  if (is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    return false;
  }
  else{
  }
  return $.copy(b_s_o$(cb, $.copy(k), $c, [$p[0]] as TypeTag[]).k).eq($.copy(k));
}

export function insert$ (
  cb: CB,
  k: U128,
  v: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let l;
  l = length$(cb, $c, [$p[0]] as TypeTag[]);
  check_len$($.copy(l), $c);
  if ($.copy(l).eq(u64("0"))) {
    insert_empty$(cb, $.copy(k), v, $c, [$p[0]] as TypeTag[]);
  }
  else{
    if ($.copy(l).eq(u64("1"))) {
      insert_singleton$(cb, $.copy(k), v, $c, [$p[0]] as TypeTag[]);
    }
    else{
      insert_general$(cb, $.copy(k), v, $.copy(l), $c, [$p[0]] as TypeTag[]);
    }
  }
  return;
}

export function insert_above$ (
  cb: CB,
  k: U128,
  v: any,
  n_o: U64,
  i_n_i: U64,
  i_s_p: U64,
  c: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let i_n_r, n_r;
  i_n_r = $.copy(Std.Vector.borrow$(cb.i, $.copy(i_s_p), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).p);
  while (true) {
    if ($.copy(i_n_r).eq(ROOT)) {
      return insert_above_root$(cb, $.copy(k), v, $.copy(n_o), $.copy(i_n_i), $.copy(c), $c, [$p[0]] as TypeTag[]);
    }
    else{
      n_r = Std.Vector.borrow_mut$(cb.i, $.copy(i_n_r), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
      if ($.copy(c).lt($.copy(n_r.c))) {
        return insert_below_walk$(cb, $.copy(k), v, $.copy(n_o), $.copy(i_n_i), $.copy(i_n_r), $.copy(c), $c, [$p[0]] as TypeTag[]);
      }
      else{
        i_n_r = $.copy(n_r.p);
      }
    }
  }
}

export function insert_above_root$ (
  cb: CB,
  k: U128,
  v: any,
  n_o: U64,
  i_n_i: U64,
  c: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let i_o_r;
  i_o_r = $.copy(cb.r);
  Std.Vector.borrow_mut$(cb.i, $.copy(i_o_r), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).p = $.copy(i_n_i);
  cb.r = $.copy(i_n_i);
  push_back_insert_nodes$(cb, $.copy(k), v, $.copy(i_n_i), $.copy(c), ROOT, is_set$($.copy(k), $.copy(c), $c), $.copy(i_o_r), o_c$($.copy(n_o), $c), $c, [$p[0]] as TypeTag[]);
  return;
}

export function insert_below$ (
  cb: CB,
  k: U128,
  v: any,
  n_o: U64,
  i_n_i: U64,
  i_s_o: U64,
  s_s_o: boolean,
  k_s_o: U128,
  i_s_p: U64,
  c: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let s_p;
  s_p = Std.Vector.borrow_mut$(cb.i, $.copy(i_s_p), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  if ((s_s_o == L)) {
    s_p.l = $.copy(i_n_i);
  }
  else{
    s_p.r = $.copy(i_n_i);
  }
  Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_s_o), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).p = $.copy(i_n_i);
  push_back_insert_nodes$(cb, $.copy(k), v, $.copy(i_n_i), $.copy(c), $.copy(i_s_p), $.copy(k).lt($.copy(k_s_o)), o_c$($.copy(n_o), $c), $.copy(i_s_o), $c, [$p[0]] as TypeTag[]);
  return;
}

export function insert_below_walk$ (
  cb: CB,
  k: U128,
  v: any,
  n_o: U64,
  i_n_i: U64,
  i_n_r: U64,
  c: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, temp$2, i_w_c, n_r, s_w_c;
  n_r = Std.Vector.borrow_mut$(cb.i, $.copy(i_n_r), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  if (is_set$($.copy(k), $.copy(n_r.c), $c)) {
    [temp$1, temp$2] = [R, $.copy(n_r.r)];
  }
  else{
    [temp$1, temp$2] = [L, $.copy(n_r.l)];
  }
  [s_w_c, i_w_c] = [temp$1, temp$2];
  if ((s_w_c == L)) {
    n_r.l = $.copy(i_n_i);
  }
  else{
    n_r.r = $.copy(i_n_i);
  }
  Std.Vector.borrow_mut$(cb.i, $.copy(i_w_c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).p = $.copy(i_n_i);
  push_back_insert_nodes$(cb, $.copy(k), v, $.copy(i_n_i), $.copy(c), $.copy(i_n_r), is_set$($.copy(k), $.copy(c), $c), $.copy(i_w_c), o_c$($.copy(n_o), $c), $c, [$p[0]] as TypeTag[]);
  return;
}

export function insert_empty$ (
  cb: CB,
  k: U128,
  v: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  Std.Vector.push_back$(cb.o, new O({ k: $.copy(k), v: v, p: ROOT }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  cb.r = OUT.shl(N_TYPE);
  return;
}

export function insert_general$ (
  cb: CB,
  k: U128,
  v: any,
  n_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, temp$2, c, i_n_i, i_s_o, i_s_p, k_s_o, s_p_c, s_s_o;
  i_n_i = Std.Vector.length$(cb.i, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  [temp$1, temp$2] = [cb, $.copy(k)];
  [i_s_o, s_s_o, k_s_o, i_s_p, s_p_c] = search_outer$(temp$1, temp$2, $c, [$p[0]] as TypeTag[]);
  if (!$.copy(k_s_o).neq($.copy(k))) {
    throw $.abortCode(E_HAS_K);
  }
  c = crit_bit$($.copy(k_s_o), $.copy(k), $c);
  if ($.copy(c).lt($.copy(s_p_c))) {
    insert_below$(cb, $.copy(k), v, $.copy(n_o), $.copy(i_n_i), $.copy(i_s_o), s_s_o, $.copy(k_s_o), $.copy(i_s_p), $.copy(c), $c, [$p[0]] as TypeTag[]);
  }
  else{
    insert_above$(cb, $.copy(k), v, $.copy(n_o), $.copy(i_n_i), $.copy(i_s_p), $.copy(c), $c, [$p[0]] as TypeTag[]);
  }
  return;
}

export function insert_singleton$ (
  cb: CB,
  k: U128,
  v: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let c, n;
  n = Std.Vector.borrow$(cb.o, u64("0"), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  if (!$.copy(k).neq($.copy(n.k))) {
    throw $.abortCode(E_HAS_K);
  }
  c = crit_bit$($.copy(n.k), $.copy(k), $c);
  push_back_insert_nodes$(cb, $.copy(k), v, u64("0"), $.copy(c), ROOT, $.copy(k).gt($.copy(n.k)), o_c$(u64("0"), $c), o_c$(u64("1"), $c), $c, [$p[0]] as TypeTag[]);
  cb.r = u64("0");
  Std.Vector.borrow_mut$(cb.o, u64("0"), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).p = u64("0");
  return;
}

export function is_empty$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): boolean {
  return Std.Vector.is_empty$(cb.o, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
}

export function is_out$ (
  i: U64,
  $c: AptosDataCache,
): boolean {
  return $.copy(i).shr(N_TYPE).and(OUT).eq(OUT);
}

export function is_set$ (
  k: U128,
  b: U8,
  $c: AptosDataCache,
): boolean {
  return $.copy(k).shr($.copy(b)).and(u128("1")).eq(u128("1"));
}

export function length$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  return Std.Vector.length$(cb.o, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
}

export function max_key$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U128 {
  if (!!is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_LOOKUP_EMPTY);
  }
  return $.copy(Std.Vector.borrow$(cb.o, o_v$(max_node_c_i$(cb, $c, [$p[0]] as TypeTag[]), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).k);
}

export function max_node_c_i$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  let i_n;
  i_n = $.copy(cb.r);
  while (true) {
    if (is_out$($.copy(i_n), $c)) {
      return $.copy(i_n);
    }
    else{
    }
    i_n = $.copy(Std.Vector.borrow$(cb.i, $.copy(i_n), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).r);
  }
}

export function min_key$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U128 {
  if (!!is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_LOOKUP_EMPTY);
  }
  return $.copy(Std.Vector.borrow$(cb.o, o_v$(min_node_c_i$(cb, $c, [$p[0]] as TypeTag[]), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).k);
}

export function min_node_c_i$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  let i_n;
  i_n = $.copy(cb.r);
  while (true) {
    if (is_out$($.copy(i_n), $c)) {
      return $.copy(i_n);
    }
    else{
    }
    i_n = $.copy(Std.Vector.borrow$(cb.i, $.copy(i_n), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).l);
  }
}

export function o_c$ (
  v: U64,
  $c: AptosDataCache,
): U64 {
  return $.copy(v).or(OUT.shl(N_TYPE));
}

export function o_v$ (
  c: U64,
  $c: AptosDataCache,
): U64 {
  return $.copy(c).and(HI_64).xor(OUT.shl(N_TYPE));
}

export function pop$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let temp$1, l;
  if (!!is_empty$(cb, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_POP_EMPTY);
  }
  l = length$(cb, $c, [$p[0]] as TypeTag[]);
  if ($.copy(l).eq(u64("1"))) {
    temp$1 = pop_singleton$(cb, $.copy(k), $c, [$p[0]] as TypeTag[]);
  }
  else{
    temp$1 = pop_general$(cb, $.copy(k), $.copy(l), $c, [$p[0]] as TypeTag[]);
  }
  return temp$1;
}

export function pop_destroy_nodes$ (
  cb: CB,
  i_i: U64,
  i_o: U64,
  n_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let n_i;
  n_i = Std.Vector.length$(cb.i, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  Std.Vector.swap_remove$(cb.i, $.copy(i_i), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  if ($.copy(i_i).lt($.copy(n_i).sub(u64("1")))) {
    stitch_swap_remove$(cb, $.copy(i_i), $.copy(n_i), $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  let { v: v } = Std.Vector.swap_remove$(cb.o, o_v$($.copy(i_o), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  if (o_v$($.copy(i_o), $c).lt($.copy(n_o).sub(u64("1")))) {
    stitch_swap_remove$(cb, $.copy(i_o), $.copy(n_o), $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  return v;
}

export function pop_general$ (
  cb: CB,
  k: U128,
  n_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let temp$1, temp$2, i_s_o, i_s_p, k_s_o, s_s_o;
  [temp$1, temp$2] = [cb, $.copy(k)];
  [i_s_o, s_s_o, k_s_o, i_s_p, ] = search_outer$(temp$1, temp$2, $c, [$p[0]] as TypeTag[]);
  if (!$.copy(k_s_o).eq($.copy(k))) {
    throw $.abortCode(E_NOT_HAS_K);
  }
  pop_update_relationships$(cb, s_s_o, $.copy(i_s_p), $c, [$p[0]] as TypeTag[]);
  return pop_destroy_nodes$(cb, $.copy(i_s_p), $.copy(i_s_o), $.copy(n_o), $c, [$p[0]] as TypeTag[]);
}

export function pop_singleton$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  if (!$.copy(Std.Vector.borrow$(cb.o, u64("0"), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).k).eq($.copy(k))) {
    throw $.abortCode(E_NOT_HAS_K);
  }
  cb.r = u64("0");
  let { v: v } = Std.Vector.pop_back$(cb.o, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  return v;
}

export function pop_update_relationships$ (
  cb: CB,
  s_c: boolean,
  i_p: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, g_p, i_p_p, i_s, p;
  p = Std.Vector.borrow$(cb.i, $.copy(i_p), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  if ((s_c == L)) {
    temp$1 = $.copy(p.r);
  }
  else{
    temp$1 = $.copy(p.l);
  }
  i_s = temp$1;
  i_p_p = $.copy(p.p);
  if (is_out$($.copy(i_s), $c)) {
    Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_s), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).p = $.copy(i_p_p);
  }
  else{
    Std.Vector.borrow_mut$(cb.i, $.copy(i_s), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).p = $.copy(i_p_p);
  }
  if ($.copy(i_p_p).eq(ROOT)) {
    cb.r = $.copy(i_s);
  }
  else{
    g_p = Std.Vector.borrow_mut$(cb.i, $.copy(i_p_p), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
    if ($.copy(g_p.l).eq($.copy(i_p))) {
      g_p.l = $.copy(i_s);
    }
    else{
      g_p.r = $.copy(i_s);
    }
  }
  return;
}

export function push_back_insert_nodes$ (
  cb: CB,
  k: U128,
  v: any,
  i_n_i: U64,
  c: U8,
  i_p: U64,
  i_n_c_c: boolean,
  c1: U64,
  c2: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, temp$2, l, r;
  if (i_n_c_c) {
    [temp$1, temp$2] = [$.copy(c1), $.copy(c2)];
  }
  else{
    [temp$1, temp$2] = [$.copy(c2), $.copy(c1)];
  }
  [l, r] = [temp$1, temp$2];
  Std.Vector.push_back$(cb.o, new O({ k: $.copy(k), v: v, p: $.copy(i_n_i) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  Std.Vector.push_back$(cb.i, new I({ c: $.copy(c), p: $.copy(i_p), l: $.copy(l), r: $.copy(r) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  return;
}

export function search_outer$ (
  cb: CB,
  k: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U64, boolean, U128, U64, U8] {
  let temp$1, temp$2, i, s, s_o, s_p;
  s_p = Std.Vector.borrow$(cb.i, $.copy(cb.r), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  while (true) {
    if (is_set$($.copy(k), $.copy(s_p.c), $c)) {
      [temp$1, temp$2] = [$.copy(s_p.r), R];
    }
    else{
      [temp$1, temp$2] = [$.copy(s_p.l), L];
    }
    [i, s] = [temp$1, temp$2];
    if (is_out$($.copy(i), $c)) {
      s_o = Std.Vector.borrow$(cb.o, o_v$($.copy(i), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
      return [$.copy(i), s, $.copy(s_o.k), $.copy(s_o.p), $.copy(s_p.c)];
    }
    else{
    }
    s_p = Std.Vector.borrow$(cb.i, $.copy(i), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  }
}

export function singleton$ (
  k: U128,
  v: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): CB {
  let cb;
  cb = new CB({ r: u64("0"), i: Std.Vector.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]), o: Std.Vector.empty$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "CB", [$p[0]]));
  insert_empty$(cb, $.copy(k), v, $c, [$p[0]] as TypeTag[]);
  return cb;
}

export function stitch_child_of_parent$ (
  cb: CB,
  i_n: U64,
  i_p: U64,
  i_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let p;
  p = Std.Vector.borrow_mut$(cb.i, $.copy(i_p), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  if ($.copy(p.l).eq($.copy(i_o))) {
    p.l = $.copy(i_n);
  }
  else{
    p.r = $.copy(i_n);
  }
  return;
}

export function stitch_parent_of_child$ (
  cb: CB,
  i_n: U64,
  i_c: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  if (is_out$($.copy(i_c), $c)) {
    Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_c), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).p = $.copy(i_n);
  }
  else{
    Std.Vector.borrow_mut$(cb.i, $.copy(i_c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).p = $.copy(i_n);
  }
  return;
}

export function stitch_swap_remove$ (
  cb: CB,
  i_n: U64,
  n_n: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let i_l, i_p, i_p__1, i_r, n;
  if (is_out$($.copy(i_n), $c)) {
    i_p = $.copy(Std.Vector.borrow$(cb.o, o_v$($.copy(i_n), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]).p);
    if ($.copy(i_p).eq(ROOT)) {
      cb.r = $.copy(i_n);
      return;
    }
    else{
    }
    stitch_child_of_parent$(cb, $.copy(i_n), $.copy(i_p), o_c$($.copy(n_n).sub(u64("1")), $c), $c, [$p[0]] as TypeTag[]);
  }
  else{
    n = Std.Vector.borrow$(cb.i, $.copy(i_n), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
    [i_p__1, i_l, i_r] = [$.copy(n.p), $.copy(n.l), $.copy(n.r)];
    stitch_parent_of_child$(cb, $.copy(i_n), $.copy(i_l), $c, [$p[0]] as TypeTag[]);
    stitch_parent_of_child$(cb, $.copy(i_n), $.copy(i_r), $c, [$p[0]] as TypeTag[]);
    if ($.copy(i_p__1).eq(ROOT)) {
      cb.r = $.copy(i_n);
      return;
    }
    else{
    }
    stitch_child_of_parent$(cb, $.copy(i_n), $.copy(i_p__1), $.copy(n_n).sub(u64("1")), $c, [$p[0]] as TypeTag[]);
  }
  return;
}

export function traverse_c_i$ (
  cb: CB,
  k: U128,
  p_f: U64,
  d: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  let temp$1, temp$2, c_f, p;
  p = Std.Vector.borrow$(cb.i, $.copy(p_f), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
  while ((d != is_set$($.copy(k), $.copy(p.c), $c))) {
    {
      p = Std.Vector.borrow$(cb.i, $.copy(p.p), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]);
    }

  }if ((d == L)) {
    temp$1 = $.copy(p.l);
  }
  else{
    temp$1 = $.copy(p.r);
  }
  c_f = temp$1;
  while (!is_out$($.copy(c_f), $c)) {
    {
      if ((d == L)) {
        temp$2 = $.copy(Std.Vector.borrow$(cb.i, $.copy(c_f), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).r);
      }
      else{
        temp$2 = $.copy(Std.Vector.borrow$(cb.i, $.copy(c_f), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).l);
      }
      c_f = temp$2;
    }

  }return $.copy(c_f);
}

export function traverse_end_pop$ (
  cb: CB,
  p_f: U64,
  c_i: U64,
  n_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let temp$1, n_s_c;
  if ($.copy(n_o).eq(u64("1"))) {
    cb.r = u64("0");
    let { v: v } = Std.Vector.pop_back$(cb.o, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
    temp$1 = v;
  }
  else{
    n_s_c = $.copy(Std.Vector.borrow$(cb.i, $.copy(p_f), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).l).eq($.copy(c_i));
    pop_update_relationships$(cb, n_s_c, $.copy(p_f), $c, [$p[0]] as TypeTag[]);
    temp$1 = pop_destroy_nodes$(cb, $.copy(p_f), $.copy(c_i), $.copy(n_o), $c, [$p[0]] as TypeTag[]);
  }
  return temp$1;
}

export function traverse_init_mut$ (
  cb: CB,
  d: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  let temp$1, i_n, n;
  if ((d == L)) {
    temp$1 = max_node_c_i$(cb, $c, [$p[0]] as TypeTag[]);
  }
  else{
    temp$1 = min_node_c_i$(cb, $c, [$p[0]] as TypeTag[]);
  }
  i_n = temp$1;
  n = Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_n), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  return [$.copy(n.k), n.v, $.copy(n.p), $.copy(i_n)];
}

export function traverse_mut$ (
  cb: CB,
  k: U128,
  p_f: U64,
  d: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  let temp$1, temp$2, temp$3, temp$4, i_t, t;
  [temp$1, temp$2, temp$3, temp$4] = [cb, $.copy(k), $.copy(p_f), d];
  i_t = traverse_c_i$(temp$1, temp$2, temp$3, temp$4, $c, [$p[0]] as TypeTag[]);
  t = Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_t), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  return [$.copy(t.k), t.v, $.copy(t.p), $.copy(i_t)];
}

export function traverse_p_init_mut$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_init_mut$(cb, L, $c, [$p[0]] as TypeTag[]);
}

export function traverse_p_mut$ (
  cb: CB,
  k: U128,
  p_f: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_mut$(cb, $.copy(k), $.copy(p_f), L, $c, [$p[0]] as TypeTag[]);
}

export function traverse_p_pop_mut$ (
  cb: CB,
  k: U128,
  p_f: U64,
  c_i: U64,
  n_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64, any] {
  return traverse_pop_mut$(cb, $.copy(k), $.copy(p_f), $.copy(c_i), $.copy(n_o), L, $c, [$p[0]] as TypeTag[]);
}

export function traverse_pop_mut$ (
  cb: CB,
  k: U128,
  p_f: U64,
  c_i: U64,
  n_o: U64,
  d: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64, any] {
  let temp$1, temp$2, temp$3, temp$4, i_t, s_s, s_v, t;
  s_s = $.copy(Std.Vector.borrow$(cb.i, $.copy(p_f), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "I", [])] as TypeTag[]).l).eq($.copy(c_i));
  [temp$1, temp$2, temp$3, temp$4] = [cb, $.copy(k), $.copy(p_f), d];
  i_t = traverse_c_i$(temp$1, temp$2, temp$3, temp$4, $c, [$p[0]] as TypeTag[]);
  pop_update_relationships$(cb, s_s, $.copy(p_f), $c, [$p[0]] as TypeTag[]);
  s_v = pop_destroy_nodes$(cb, $.copy(p_f), $.copy(c_i), $.copy(n_o), $c, [$p[0]] as TypeTag[]);
  if (o_v$($.copy(i_t), $c).eq($.copy(n_o).sub(u64("1")))) {
    i_t = $.copy(c_i);
  }
  else{
  }
  t = Std.Vector.borrow_mut$(cb.o, o_v$($.copy(i_t), $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "CritBit", "O", [$p[0]])] as TypeTag[]);
  return [$.copy(t.k), t.v, $.copy(t.p), $.copy(i_t), s_v];
}

export function traverse_s_init_mut$ (
  cb: CB,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_init_mut$(cb, R, $c, [$p[0]] as TypeTag[]);
}

export function traverse_s_mut$ (
  cb: CB,
  k: U128,
  p_f: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_mut$(cb, $.copy(k), $.copy(p_f), R, $c, [$p[0]] as TypeTag[]);
}

export function traverse_s_pop_mut$ (
  cb: CB,
  k: U128,
  p_f: U64,
  c_i: U64,
  n_o: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64, any] {
  return traverse_pop_mut$(cb, $.copy(k), $.copy(p_f), $.copy(c_i), $.copy(n_o), R, $c, [$p[0]] as TypeTag[]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::CritBit::CB", CB.CBParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::CritBit::I", I.IParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::CritBit::O", O.OParser);
}

