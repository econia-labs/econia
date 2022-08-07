import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Table from "./table";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "table_with_length";

export const EALREADY_EXISTS : U64 = u64("100");
export const ENOT_EMPTY : U64 = u64("102");
export const ENOT_FOUND : U64 = u64("101");


export class TableWithLength 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TableWithLength";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: true },
    { name: "V", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "inner", typeTag: new StructTag(new HexString("0x1"), "table", "Table", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)]) },
  { name: "length", typeTag: AtomicTypeTag.U64 }];

  inner: Table.Table;
  length: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto['inner'] as Table.Table;
    this.length = proto['length'] as U64;
  }

  static TableWithLengthParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TableWithLength {
    const proto = $.parseStructProto(data, typeTag, repo, TableWithLength);
    return new TableWithLength(proto, typeTag);
  }

}
export function add_ (
  table: TableWithLength,
  key: any,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  Table.add_(table.inner, $.copy(key), val, $c, [$p[0], $p[1]]);
  table.length = ($.copy(table.length)).add(u64("1"));
  return;
}

export function borrow_ (
  table: TableWithLength,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table.borrow_(table.inner, $.copy(key), $c, [$p[0], $p[1]]);
}

export function borrow_mut_ (
  table: TableWithLength,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table.borrow_mut_(table.inner, $.copy(key), $c, [$p[0], $p[1]]);
}

export function borrow_mut_with_default_ (
  table: TableWithLength,
  key: any,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Table.borrow_mut_with_default_(table.inner, $.copy(key), default__, $c, [$p[0], $p[1]]);
}

export function contains_ (
  table: TableWithLength,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return Table.contains_(table.inner, $.copy(key), $c, [$p[0], $p[1]]);
}

export function destroy_empty_ (
  table: TableWithLength,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  if (!($.copy(table.length)).eq((u64("0")))) {
    throw $.abortCode(Std.Error.invalid_state_(ENOT_EMPTY, $c));
  }
  let { inner: inner } = table;
  return Table.destroy_(inner, $c, [$p[0], $p[1]]);
}

export function empty_ (
  table: TableWithLength,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return ($.copy(table.length)).eq((u64("0")));
}

export function length_ (
  table: TableWithLength,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return $.copy(table.length);
}

export function new___ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): TableWithLength {
  return new TableWithLength({ inner: Table.new___($c, [$p[0], $p[1]]), length: u64("0") }, new StructTag(new HexString("0x1"), "table_with_length", "TableWithLength", [$p[0], $p[1]]));
}

export function remove_ (
  table: TableWithLength,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let val;
  val = Table.remove_(table.inner, $.copy(key), $c, [$p[0], $p[1]]);
  table.length = ($.copy(table.length)).sub(u64("1"));
  return val;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::table_with_length::TableWithLength", TableWithLength.TableWithLengthParser);
}

