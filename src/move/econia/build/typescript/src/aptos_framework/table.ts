import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "table";

export const EALREADY_EXISTS : U64 = u64("100");
export const ENOT_EMPTY : U64 = u64("102");
export const ENOT_FOUND : U64 = u64("101");


export class Box 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Box";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "val", typeTag: new $.TypeParamIdx(0) }];

  val: any;

  constructor(proto: any, public typeTag: TypeTag) {
    this.val = proto['val'] as any;
  }

  static BoxParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Box {
    const proto = $.parseStructProto(data, typeTag, repo, Box);
    return new Box(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Box, typeParams);
    return result as unknown as Box;
  }
}

export class Table 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Table";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: true },
    { name: "V", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "handle", typeTag: AtomicTypeTag.U128 },
  { name: "length", typeTag: AtomicTypeTag.U64 }];

  handle: U128;
  length: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.handle = proto['handle'] as U128;
    this.length = proto['length'] as U64;
  }

  static TableParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Table {
    const proto = $.parseStructProto(data, typeTag, repo, Table);
    return new Table(proto, typeTag);
  }

}
export function add$ (
  table: Table,
  key: any,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  add_box$(table, $.copy(key), new Box({ val: val }, new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])), $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]);
  table.length = $.copy(table.length).add(u64("1"));
  return;
}

export function add_box$ (
  table: Table,
  key: any,
  val: Box,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): void {
  return $.aptos_framework_table_add_box(table, key, val, $c, [$p[0], $p[1], $p[2]]);

}
export function borrow$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return borrow_box$(table, $.copy(key), $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]).val;
}

export function borrow_box$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): Box {
  return $.aptos_framework_table_borrow_box(table, key, $c, [$p[0], $p[1], $p[2]]);

}
export function borrow_box_mut$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): Box {
  return $.aptos_framework_table_borrow_box_mut(table, key, $c, [$p[0], $p[1], $p[2]]);

}
export function borrow_mut$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return borrow_box_mut$(table, $.copy(key), $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]).val;
}

export function borrow_mut_with_default$ (
  table: Table,
  key: any,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let temp$1, temp$2;
  [temp$1, temp$2] = [table, $.copy(key)];
  if (!contains$(temp$1, temp$2, $c, [$p[0], $p[1]] as TypeTag[])) {
    add$(table, $.copy(key), default__, $c, [$p[0], $p[1]] as TypeTag[]);
  }
  else{
  }
  return borrow_mut$(table, $.copy(key), $c, [$p[0], $p[1]] as TypeTag[]);
}

export function contains$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return contains_box$(table, $.copy(key), $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]);
}

export function contains_box$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): boolean {
  return $.aptos_framework_table_contains_box(table, key, $c, [$p[0], $p[1], $p[2]]);

}
export function destroy_empty$ (
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  if (!$.copy(table.length).eq(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_state$(ENOT_EMPTY, $c));
  }
  destroy_empty_box$(table, $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]);
  return drop_unchecked_box$(table, $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]);
}

export function destroy_empty_box$ (
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): void {
  return $.aptos_framework_table_destroy_empty_box(table, $c, [$p[0], $p[1], $p[2]]);

}
export function drop_unchecked_box$ (
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): void {
  return $.aptos_framework_table_drop_unchecked_box(table, $c, [$p[0], $p[1], $p[2]]);

}
export function empty$ (
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return $.copy(table.length).eq(u64("0"));
}

export function length$ (
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return $.copy(table.length);
}

export function new__$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): Table {
  return new Table({ handle: new_table_handle$($c, [$p[0], $p[1]] as TypeTag[]), length: u64("0") }, new StructTag(new HexString("0x1"), "table", "Table", [$p[0], $p[1]]));
}

export function new_table_handle$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U128 {
  return $.aptos_framework_table_new_table_handle($c, [$p[0], $p[1]]);

}
export function remove$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let { val: val } = remove_box$(table, $.copy(key), $c, [$p[0], $p[1], new StructTag(new HexString("0x1"), "table", "Box", [$p[1]])] as TypeTag[]);
  table.length = $.copy(table.length).sub(u64("1"));
  return val;
}

export function remove_box$ (
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V, B>*/
): Box {
  return $.aptos_framework_table_remove_box(table, key, $c, [$p[0], $p[1], $p[2]]);

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::table::Box", Box.BoxParser);
  repo.addParser("0x1::table::Table", Table.TableParser);
}

export class TypedTable<K, V> {
  static buildFromField<K, V>(table: Table, field: FieldDeclType): TypedTable<K, V> {
    const tag = field.typeTag;
    if (!(tag instanceof StructTag)) {
      throw new Error();
    }
    if (tag.getParamlessName() !== '0x1::table::Table') {
      throw new Error();
    }
    if (tag.typeParams.length !== 2) {
      throw new Error();
    }
    const [keyTag, valueTag] = tag.typeParams;
    return new TypedTable<K, V>(table, keyTag, valueTag);
  }

  constructor(
    public table: Table,
    public keyTag: TypeTag,
    public valueTag: TypeTag
  ) {
  }

  async loadEntryRaw(client: AptosClient, key: K): Promise<any> {
    return await client.getTableItem(this.table.handle.value.toString(), {
      key_type: $.getTypeTagFullname(this.keyTag),
      value_type: $.getTypeTagFullname(this.valueTag),
      key: $.moveValueToOpenApiObject(key, this.keyTag),
    });
  }

  async loadEntry(client: AptosClient, repo: AptosParserRepo, key: K): Promise<V> {
    const rawVal = await this.loadEntryRaw(client, key);
    return repo.parse(rawVal.data, this.valueTag);
  }
}


