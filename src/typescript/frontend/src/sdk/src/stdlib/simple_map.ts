import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import {
  type FieldDeclType,
  type TypeParamDeclType,
} from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";

import * as Comparator from "./comparator";
import * as Error from "./error";
import * as Option from "./option";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "simple_map";

export const EKEY_ALREADY_EXISTS: U64 = u64("1");
export const EKEY_NOT_FOUND: U64 = u64("2");

export class Element {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Element";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Key", isPhantom: false },
    { name: "Value", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    { name: "key", typeTag: new $.TypeParamIdx(0) },
    { name: "value", typeTag: new $.TypeParamIdx(1) },
  ];

  key: any;
  value: any;

  constructor(proto: any, public typeTag: TypeTag) {
    this.key = proto["key"] as any;
    this.value = proto["value"] as any;
  }

  static ElementParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Element {
    const proto = $.parseStructProto(data, typeTag, repo, Element);
    return new Element(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Element", $p);
  }
  async loadFullState(app: $.AppType) {
    if (this.key.typeTag instanceof StructTag) {
      await this.key.loadFullState(app);
    }
    if (this.value.typeTag instanceof StructTag) {
      await this.value.loadFullState(app);
    }
    this.__app = app;
  }
}

export class SimpleMap {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SimpleMap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Key", isPhantom: false },
    { name: "Value", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "data",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "simple_map", "Element", [
          new $.TypeParamIdx(0),
          new $.TypeParamIdx(1),
        ])
      ),
    },
  ];

  data: Element[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.data = proto["data"] as Element[];
  }

  static SimpleMapParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SimpleMap {
    const proto = $.parseStructProto(data, typeTag, repo, SimpleMap);
    return new SimpleMap(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "SimpleMap", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function add_(
  map: SimpleMap,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): void {
  let temp$1, temp$2, end, maybe_idx, maybe_placement, placement;
  [temp$1, temp$2] = [map, key];
  [maybe_idx, maybe_placement] = find_(temp$1, temp$2, $c, [$p[0], $p[1]]);
  if (!Option.is_none_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Error.invalid_argument_($.copy(EKEY_ALREADY_EXISTS), $c));
  }
  Vector.push_back_(
    map.data,
    new Element(
      { key: key, value: value },
      new SimpleStructTag(Element, [$p[0], $p[1]])
    ),
    $c,
    [new SimpleStructTag(Element, [$p[0], $p[1]])]
  );
  placement = Option.extract_(maybe_placement, $c, [AtomicTypeTag.U64]);
  end = Vector.length_(map.data, $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]).sub(u64("1"));
  while ($.copy(placement).lt($.copy(end))) {
    {
      Vector.swap_(map.data, $.copy(placement), $.copy(end), $c, [
        new SimpleStructTag(Element, [$p[0], $p[1]]),
      ]);
      placement = $.copy(placement).add(u64("1"));
    }
  }
  return;
}

export function borrow_(
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): any {
  let idx, maybe_idx;
  [maybe_idx] = find_(map, key, $c, [$p[0], $p[1]]);
  if (!Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Error.invalid_argument_($.copy(EKEY_NOT_FOUND), $c));
  }
  idx = Option.extract_(maybe_idx, $c, [AtomicTypeTag.U64]);
  return Vector.borrow_(map.data, $.copy(idx), $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]).value;
}

export function borrow_mut_(
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): any {
  let temp$1, temp$2, idx, maybe_idx;
  [temp$1, temp$2] = [map, key];
  [maybe_idx] = find_(temp$1, temp$2, $c, [$p[0], $p[1]]);
  if (!Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Error.invalid_argument_($.copy(EKEY_NOT_FOUND), $c));
  }
  idx = Option.extract_(maybe_idx, $c, [AtomicTypeTag.U64]);
  return Vector.borrow_mut_(map.data, $.copy(idx), $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]).value;
}

export function contains_key_(
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): boolean {
  let maybe_idx;
  [maybe_idx] = find_(map, key, $c, [$p[0], $p[1]]);
  return Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64]);
}

export function create_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): SimpleMap {
  return new SimpleMap(
    { data: Vector.empty_($c, [new SimpleStructTag(Element, [$p[0], $p[1]])]) },
    new SimpleStructTag(SimpleMap, [$p[0], $p[1]])
  );
}

export function destroy_empty_(
  map: SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): void {
  const { data: data } = map;
  Vector.destroy_empty_(data, $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]);
  return;
}

export function find_(
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): [Option.Option, Option.Option] {
  let temp$1, temp$2, temp$3, temp$4, left, length, mid, potential_key, right;
  length = Vector.length_(map.data, $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]);
  if ($.copy(length).eq(u64("0"))) {
    return [
      Option.none_($c, [AtomicTypeTag.U64]),
      Option.some_(u64("0"), $c, [AtomicTypeTag.U64]),
    ];
  } else {
  }
  left = u64("0");
  right = $.copy(length);
  while ($.copy(left).neq($.copy(right))) {
    {
      mid = $.copy(left).add($.copy(right).sub($.copy(left)).div(u64("2")));
      potential_key = Vector.borrow_(map.data, $.copy(mid), $c, [
        new SimpleStructTag(Element, [$p[0], $p[1]]),
      ]).key;
      temp$1 = Comparator.compare_(potential_key, key, $c, [$p[0]]);
      if (Comparator.is_smaller_than_(temp$1, $c)) {
        left = $.copy(mid).add(u64("1"));
      } else {
        right = $.copy(mid);
      }
    }
  }
  if ($.copy(left).neq($.copy(length))) {
    temp$2 = $.dyn_eq(
      $p[0],
      key,
      Vector.borrow_(map.data, $.copy(left), $c, [
        new SimpleStructTag(Element, [$p[0], $p[1]]),
      ]).key
    );
  } else {
    temp$2 = false;
  }
  if (temp$2) {
    [temp$3, temp$4] = [
      Option.some_($.copy(left), $c, [AtomicTypeTag.U64]),
      Option.none_($c, [AtomicTypeTag.U64]),
    ];
  } else {
    [temp$3, temp$4] = [
      Option.none_($c, [AtomicTypeTag.U64]),
      Option.some_($.copy(left), $c, [AtomicTypeTag.U64]),
    ];
  }
  return [temp$3, temp$4];
}

export function length_(
  map: SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): U64 {
  return Vector.length_(map.data, $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]);
}

export function remove_(
  map: SimpleMap,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Key, Value>*/
): [any, any] {
  let temp$1, temp$2, end, maybe_idx, placement;
  [temp$1, temp$2] = [map, key];
  [maybe_idx] = find_(temp$1, temp$2, $c, [$p[0], $p[1]]);
  if (!Option.is_some_(maybe_idx, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(Error.invalid_argument_($.copy(EKEY_NOT_FOUND), $c));
  }
  placement = Option.extract_(maybe_idx, $c, [AtomicTypeTag.U64]);
  end = Vector.length_(map.data, $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]).sub(u64("1"));
  while ($.copy(placement).lt($.copy(end))) {
    {
      Vector.swap_(
        map.data,
        $.copy(placement),
        $.copy(placement).add(u64("1")),
        $c,
        [new SimpleStructTag(Element, [$p[0], $p[1]])]
      );
      placement = $.copy(placement).add(u64("1"));
    }
  }
  const { key: key__3, value: value } = Vector.pop_back_(map.data, $c, [
    new SimpleStructTag(Element, [$p[0], $p[1]]),
  ]);
  return [key__3, value];
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::simple_map::Element", Element.ElementParser);
  repo.addParser("0x1::simple_map::SimpleMap", SimpleMap.SimpleMapParser);
}
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
  get Element() {
    return Element;
  }
  get SimpleMap() {
    return SimpleMap;
  }
}
