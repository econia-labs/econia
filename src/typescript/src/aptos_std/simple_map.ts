import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Comparator from "./comparator";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "simple_map";

export const EKEY_ALREADY_EXISTS : U64 = u64("0");
export const EKEY_NOT_FOUND : U64 = u64("1");


export class Element 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Element";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Key", isPhantom: false },
    { name: "Value", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "key", typeTag: new $.TypeParamIdx(0) },
  { name: "value", typeTag: new $.TypeParamIdx(1) }];

  key: any;
  value: any;

  constructor(proto: any, public typeTag: TypeTag) {
    this.key = proto['key'] as any;
    this.value = proto['value'] as any;
  }

  static ElementParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Element {
    const proto = $.parseStructProto(data, typeTag, repo, Element);
    return new Element(proto, typeTag);
  }

}

export class SimpleMap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "SimpleMap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Key", isPhantom: false },
    { name: "Value", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "data", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "simple_map", "Element", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)])) }];

  data: Element[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.data = proto['data'] as Element[];
  }

  static SimpleMapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : SimpleMap {
    const proto = $.parseStructProto(data, typeTag, repo, SimpleMap);
    return new SimpleMap(proto, typeTag);
  }

}
export function add_ (
  map: SimpleMap,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): void {
  let temp$1, temp$2, end, maybe_idx, maybe_placement, placement;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, maybe_placement] = find_(temp$1, temp$2, $c, [$p[0], $p[1]]);
  if (!Std.Option.is_none_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Std.Error.invalid_argument_(EKEY_ALREADY_EXISTS, $c));
  }
  Std.Vector.push_back_(map.data, new Element({ key: key, value: value }, new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
  placement = Std.Option.extract_(maybe_placement, $c, [AtomicTypeTag.U64]);
  end = (Std.Vector.length_(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])])).sub(u64("1"));
  while (($.copy(placement)).lt($.copy(end))) {
    {
      Std.Vector.swap_(map.data, $.copy(placement), $.copy(end), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
      placement = ($.copy(placement)).add(u64("1"));
    }

  }return;
}

export function borrow_ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): any {
  let idx, maybe_idx;
  [maybe_idx, ] = find_(map, key, $c, [$p[0], $p[1]]);
  if (!Std.Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Std.Error.invalid_argument_(EKEY_NOT_FOUND, $c));
  }
  idx = Std.Option.extract_(maybe_idx, $c, [AtomicTypeTag.U64]);
  return Std.Vector.borrow_(map.data, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]).value;
}

export function borrow_mut_ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): any {
  let temp$1, temp$2, idx, maybe_idx;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, ] = find_(temp$1, temp$2, $c, [$p[0], $p[1]]);
  if (!Std.Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Std.Error.invalid_argument_(EKEY_NOT_FOUND, $c));
  }
  idx = Std.Option.extract_(maybe_idx, $c, [AtomicTypeTag.U64]);
  return Std.Vector.borrow_mut_(map.data, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]).value;
}

export function contains_key_ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): boolean {
  let maybe_idx;
  [maybe_idx, ] = find_(map, key, $c, [$p[0], $p[1]]);
  return Std.Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64]);
}

export function create_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): SimpleMap {
  return new SimpleMap({ data: Std.Vector.empty_($c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]) }, new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [$p[0], $p[1]]));
}

export function destroy_empty_ (
  map: SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): void {
  let { data: data } = map;
  Std.Vector.destroy_empty_(data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
  return;
}

export function find_ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): [Std.Option.Option, Std.Option.Option] {
  let temp$1, temp$2, temp$3, temp$4, left, length, mid, potential_key, right;
  length = Std.Vector.length_(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
  if (($.copy(length)).eq((u64("0")))) {
    return [Std.Option.none_($c, [AtomicTypeTag.U64]), Std.Option.some_(u64("0"), $c, [AtomicTypeTag.U64])];
  }
  else{
  }
  left = u64("0");
  right = $.copy(length);
  while (($.copy(left)).neq($.copy(right))) {
    {
      mid = (($.copy(left)).add($.copy(right))).div(u64("2"));
      potential_key = Std.Vector.borrow_(map.data, $.copy(mid), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]).key;
      temp$1 = Comparator.compare_(potential_key, key, $c, [$p[0]]);
      if (Comparator.is_smaller_than_(temp$1, $c)) {
        left = ($.copy(mid)).add(u64("1"));
      }
      else{
        right = $.copy(mid);
      }
    }

  }if (($.copy(left)).neq($.copy(length))) {
    temp$2 = $.dyn_eq($p[0], key, Std.Vector.borrow_(map.data, $.copy(left), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]).key);
  }
  else{
    temp$2 = false;
  }
  if (temp$2) {
    [temp$3, temp$4] = [Std.Option.some_($.copy(left), $c, [AtomicTypeTag.U64]), Std.Option.none_($c, [AtomicTypeTag.U64])];
  }
  else{
    [temp$3, temp$4] = [Std.Option.none_($c, [AtomicTypeTag.U64]), Std.Option.some_($.copy(left), $c, [AtomicTypeTag.U64])];
  }
  return [temp$3, temp$4];
}

export function length_ (
  map: SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): U64 {
  return Std.Vector.length_(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
}

export function remove_ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): [any, any] {
  let temp$1, temp$2, end, maybe_idx, placement;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, ] = find_(temp$1, temp$2, $c, [$p[0], $p[1]]);
  if (!Std.Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Std.Error.invalid_argument_(EKEY_NOT_FOUND, $c));
  }
  placement = Std.Option.extract_(maybe_idx, $c, [AtomicTypeTag.U64]);
  end = (Std.Vector.length_(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])])).sub(u64("1"));
  while (($.copy(placement)).lt($.copy(end))) {
    {
      Std.Vector.swap_(map.data, $.copy(placement), ($.copy(placement)).add(u64("1")), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
      placement = ($.copy(placement)).add(u64("1"));
    }

  }let { key: key__3, value: value } = Std.Vector.pop_back_(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])]);
  return [key__3, value];
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::simple_map::Element", Element.ElementParser);
  repo.addParser("0x1::simple_map::SimpleMap", SimpleMap.SimpleMapParser);
}

