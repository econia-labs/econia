import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Table from "./Table";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "IterableTable";



export class IterableTable 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "IterableTable";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "inner", typeTag: new StructTag(new HexString("0x1"), "Table", "Table", [new $.TypeParamIdx(0), new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)])]) },
  { name: "head", typeTag: new StructTag(new HexString("0x1"), "Option", "Option", [new $.TypeParamIdx(0)]) },
  { name: "tail", typeTag: new StructTag(new HexString("0x1"), "Option", "Option", [new $.TypeParamIdx(0)]) }];

  inner: Table.Table;
  head: Std.Option.Option;
  tail: Std.Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto['inner'] as Table.Table;
    this.head = proto['head'] as Std.Option.Option;
    this.tail = proto['tail'] as Std.Option.Option;
  }

  static IterableTableParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : IterableTable {
    const proto = $.parseStructProto(data, typeTag, repo, IterableTable);
    return new IterableTable(proto, typeTag);
  }

}

export class IterableValue 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "IterableValue";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "val", typeTag: new $.TypeParamIdx(1) },
  { name: "prev", typeTag: new StructTag(new HexString("0x1"), "Option", "Option", [new $.TypeParamIdx(0)]) },
  { name: "next", typeTag: new StructTag(new HexString("0x1"), "Option", "Option", [new $.TypeParamIdx(0)]) }];

  val: any;
  prev: Std.Option.Option;
  next: Std.Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.val = proto['val'] as any;
    this.prev = proto['prev'] as Std.Option.Option;
    this.next = proto['next'] as Std.Option.Option;
  }

  static IterableValueParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : IterableValue {
    const proto = $.parseStructProto(data, typeTag, repo, IterableValue);
    return new IterableValue(proto, typeTag);
  }

}
export function add$ (
  table: IterableTable,
  key: any,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let k, wrapped_value;
  wrapped_value = new IterableValue({ val: val, prev: $.copy(table.tail), next: Std.Option.none$($c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]]));
  Table.add$(table.inner, $.copy(key), wrapped_value, $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
  if (Std.Option.is_some$(table.tail, $c, [$p[0]] as TypeTag[])) {
    k = Std.Option.borrow$(table.tail, $c, [$p[0]] as TypeTag[]);
    Table.borrow_mut$(table.inner, $.copy(k), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]).next = Std.Option.some$($.copy(key), $c, [$p[0]] as TypeTag[]);
  }
  else{
    table.head = Std.Option.some$($.copy(key), $c, [$p[0]] as TypeTag[]);
  }
  table.tail = Std.Option.some$($.copy(key), $c, [$p[0]] as TypeTag[]);
  return;
}

export function append$ (
  v1: IterableTable,
  v2: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let key, next, val;
  key = head_key$(v2, $c, [$p[0], $p[1]] as TypeTag[]);
  while (Std.Option.is_some$(key, $c, [$p[0]] as TypeTag[])) {
    {
      [val, , next] = remove_iter$(v2, $.copy(Std.Option.borrow$(key, $c, [$p[0]] as TypeTag[])), $c, [$p[0], $p[1]] as TypeTag[]);
      add$(v1, $.copy(Std.Option.borrow$(key, $c, [$p[0]] as TypeTag[])), val, $c, [$p[0], $p[1]] as TypeTag[]);
      key = $.copy(next);
    }

  }return;
}

export function borrow$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table.borrow$(table.inner, $.copy(key), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]).val;
}

export function borrow_iter$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): [any, Std.Option.Option, Std.Option.Option] {
  let v;
  v = Table.borrow$(table.inner, $.copy(key), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
  return [v.val, $.copy(v.prev), $.copy(v.next)];
}

export function borrow_iter_mut$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): [any, Std.Option.Option, Std.Option.Option] {
  let v;
  v = Table.borrow_mut$(table.inner, $.copy(key), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
  return [v.val, $.copy(v.prev), $.copy(v.next)];
}

export function borrow_mut$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table.borrow_mut$(table.inner, $.copy(key), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]).val;
}

export function contains$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return Table.contains$(table.inner, $.copy(key), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
}

export function destroy_empty$ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  if (!empty$(table, $c, [$p[0], $p[1]] as TypeTag[])) {
    throw $.abortCode(u64("0"));
  }
  if (!Std.Option.is_none$(table.head, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(u64("0"));
  }
  if (!Std.Option.is_none$(table.tail, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(u64("0"));
  }
  let { inner: inner } = table;
  Table.destroy_empty$(inner, $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
  return;
}

export function empty$ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return Table.empty$(table.inner, $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
}

export function head_key$ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): Std.Option.Option {
  return $.copy(table.head);
}

export function length$ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return Table.length$(table.inner, $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
}

export function new__$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): IterableTable {
  return new IterableTable({ inner: Table.new__$($c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]), head: Std.Option.none$($c, [$p[0]] as TypeTag[]), tail: Std.Option.none$($c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "IterableTable", "IterableTable", [$p[0], $p[1]]));
}

export function remove$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let val;
  [val, , ] = remove_iter$(table, $.copy(key), $c, [$p[0], $p[1]] as TypeTag[]);
  return val;
}

export function remove_iter$ (
  table: IterableTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): [any, Std.Option.Option, Std.Option.Option] {
  let key__1, key__2, val;
  val = Table.remove$(table.inner, $.copy(key), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]);
  if (Std.Option.contains$(table.tail, key, $c, [$p[0]] as TypeTag[])) {
    table.tail = $.copy(val.prev);
  }
  else{
  }
  if (Std.Option.contains$(table.head, key, $c, [$p[0]] as TypeTag[])) {
    table.head = $.copy(val.next);
  }
  else{
  }
  if (Std.Option.is_some$(val.prev, $c, [$p[0]] as TypeTag[])) {
    key__1 = Std.Option.borrow$(val.prev, $c, [$p[0]] as TypeTag[]);
    Table.borrow_mut$(table.inner, $.copy(key__1), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]).next = $.copy(val.next);
  }
  else{
  }
  if (Std.Option.is_some$(val.next, $c, [$p[0]] as TypeTag[])) {
    key__2 = Std.Option.borrow$(val.next, $c, [$p[0]] as TypeTag[]);
    Table.borrow_mut$(table.inner, $.copy(key__2), $c, [$p[0], new StructTag(new HexString("0x1"), "IterableTable", "IterableValue", [$p[0], $p[1]])] as TypeTag[]).prev = $.copy(val.prev);
  }
  else{
  }
  let { val: val__3, prev: prev, next: next } = val;
  return [val__3, $.copy(prev), $.copy(next)];
}

export function tail_key$ (
  table: IterableTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): Std.Option.Option {
  return $.copy(table.tail);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::IterableTable::IterableTable", IterableTable.IterableTableParser);
  repo.addParser("0x1::IterableTable::IterableValue", IterableValue.IterableValueParser);
}

export class TypedIterableTable<K, V> {
  static buildFromField<K, V>(table: IterableTable, field: FieldDeclType): TypedIterableTable<K, V> {
    const tag = field.typeTag;
    if (!(tag instanceof StructTag)) {
      throw new Error();
    }
    if (tag.getParamlessName() !== '0x1::IterableTable::IterableTable') {
      throw new Error();
    }
    if (tag.typeParams.length !== 2) {
      throw new Error();
    }
    const [keyTag, valueTag] = tag.typeParams;
    return new TypedIterableTable<K, V>(table, keyTag, valueTag);
  }

  iterValueTag: StructTag;
  constructor(
    public table: IterableTable,
    public keyTag: TypeTag,
    public valueTag: TypeTag
  ) {
    this.iterValueTag = new StructTag(moduleAddress, moduleName, "IterableValue", [keyTag, valueTag])
  }

  async loadEntryRaw(client: AptosClient, key: K): Promise<any> {
    return await client.getTableItem(this.table.inner.handle.value.toString(), {
      key_type: $.getTypeTagFullname(this.keyTag),
      value_type: $.getTypeTagFullname(this.iterValueTag),
      key: $.moveValueToOpenApiObject(key, this.keyTag),
    });
  }

  async loadEntry(client: AptosClient, repo: AptosParserRepo, key: K): Promise<IterableValue> {
    const rawVal = await this.loadEntryRaw(client, key);
    return repo.parse(rawVal.data, this.iterValueTag) as IterableValue;
  }

  async fetchAll(client: AptosClient, repo: AptosParserRepo): Promise<[K, V][]> {
    const result: [K, V][] = [];
    const cache = new $.DummyCache();
    let next = this.table.head;
    while(next && Std.Option.is_some$(next, cache, [this.keyTag])) {
      const key = Std.Option.borrow$(next, cache, [this.keyTag]) as K;
      const iterVal = await this.loadEntry(client, repo, key);
      const value = iterVal.val as V;
      result.push([key, value]);
      next = iterVal.next;
    }
    return result;
  }
}


