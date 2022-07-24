import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as comparator$_ from "./comparator";
export const packageName = "AptosFramework";
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
export function add$ (
  map: SimpleMap,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): void {
  let temp$1, temp$2, end, maybe_idx, maybe_placement, placement;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, maybe_placement] = find$(temp$1, temp$2, $c, [$p[0], $p[1]] as TypeTag[]);
  if (!std$_.option$_.is_none$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EKEY_ALREADY_EXISTS, $c));
  }
  std$_.vector$_.push_back$(map.data, new Element({ key: key, value: value }, new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
  placement = std$_.option$_.extract$(maybe_placement, $c, [AtomicTypeTag.U64] as TypeTag[]);
  end = std$_.vector$_.length$(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]).sub(u64("1"));
  while ($.copy(placement).lt($.copy(end))) {
    {
      std$_.vector$_.swap$(map.data, $.copy(placement), $.copy(end), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
      placement = $.copy(placement).add(u64("1"));
    }

  }return;
}

export function borrow$ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): any {
  let idx, maybe_idx;
  [maybe_idx, ] = find$(map, key, $c, [$p[0], $p[1]] as TypeTag[]);
  if (!std$_.option$_.is_some$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EKEY_NOT_FOUND, $c));
  }
  idx = std$_.option$_.extract$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[]);
  return std$_.vector$_.borrow$(map.data, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]).value;
}

export function borrow_mut$ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): any {
  let temp$1, temp$2, idx, maybe_idx;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, ] = find$(temp$1, temp$2, $c, [$p[0], $p[1]] as TypeTag[]);
  if (!std$_.option$_.is_some$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EKEY_NOT_FOUND, $c));
  }
  idx = std$_.option$_.extract$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[]);
  return std$_.vector$_.borrow_mut$(map.data, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]).value;
}

export function contains_key$ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): boolean {
  let maybe_idx;
  [maybe_idx, ] = find$(map, key, $c, [$p[0], $p[1]] as TypeTag[]);
  return std$_.option$_.is_some$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[]);
}

export function create$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): SimpleMap {
  return new SimpleMap({ data: std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [$p[0], $p[1]]));
}

export function destroy_empty$ (
  map: SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): void {
  let { data: data } = map;
  std$_.vector$_.destroy_empty$(data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
  return;
}

export function find$ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): [std$_.option$_.Option, std$_.option$_.Option] {
  let temp$1, temp$2, temp$3, temp$4, left, length, mid, potential_key, right;
  length = std$_.vector$_.length$(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
  if ($.copy(length).eq(u64("0"))) {
    return [std$_.option$_.none$($c, [AtomicTypeTag.U64] as TypeTag[]), std$_.option$_.some$(u64("0"), $c, [AtomicTypeTag.U64] as TypeTag[])];
  }
  else{
  }
  left = u64("0");
  right = $.copy(length);
  while ($.copy(left).neq($.copy(right))) {
    {
      mid = $.copy(left).add($.copy(right)).div(u64("2"));
      potential_key = std$_.vector$_.borrow$(map.data, $.copy(mid), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]).key;
      temp$1 = comparator$_.compare$(potential_key, key, $c, [$p[0]] as TypeTag[]);
      if (comparator$_.is_smaller_than$(temp$1, $c)) {
        left = $.copy(mid).add(u64("1"));
      }
      else{
        right = $.copy(mid);
      }
    }

  }if ($.copy(left).neq($.copy(length))) {
    temp$2 = $.dyn_eq($p[0], key, std$_.vector$_.borrow$(map.data, $.copy(left), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]).key);
  }
  else{
    temp$2 = false;
  }
  if (temp$2) {
    [temp$3, temp$4] = [std$_.option$_.some$($.copy(left), $c, [AtomicTypeTag.U64] as TypeTag[]), std$_.option$_.none$($c, [AtomicTypeTag.U64] as TypeTag[])];
  }
  else{
    [temp$3, temp$4] = [std$_.option$_.none$($c, [AtomicTypeTag.U64] as TypeTag[]), std$_.option$_.some$($.copy(left), $c, [AtomicTypeTag.U64] as TypeTag[])];
  }
  return [temp$3, temp$4];
}

export function length$ (
  map: SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): U64 {
  return std$_.vector$_.length$(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
}

export function remove$ (
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Key, Value>*/
): [any, any] {
  let temp$1, temp$2, end, maybe_idx, placement;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, ] = find$(temp$1, temp$2, $c, [$p[0], $p[1]] as TypeTag[]);
  if (!std$_.option$_.is_some$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EKEY_NOT_FOUND, $c));
  }
  placement = std$_.option$_.extract$(maybe_idx, $c, [AtomicTypeTag.U64] as TypeTag[]);
  end = std$_.vector$_.length$(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]).sub(u64("1"));
  while ($.copy(placement).lt($.copy(end))) {
    {
      std$_.vector$_.swap$(map.data, $.copy(placement), $.copy(placement).add(u64("1")), $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
      placement = $.copy(placement).add(u64("1"));
    }

  }let { key: key__3, value: value } = std$_.vector$_.pop_back$(map.data, $c, [new StructTag(new HexString("0x1"), "simple_map", "Element", [$p[0], $p[1]])] as TypeTag[]);
  return [key__3, value];
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::simple_map::Element", Element.ElementParser);
  repo.addParser("0x1::simple_map::SimpleMap", SimpleMap.SimpleMapParser);
}

