import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "open_table";



export class OpenTable 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OpenTable";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "base_table", typeTag: new StructTag(new HexString("0x1"), "table", "Table", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)]) },
  { name: "keys", typeTag: new VectorTag(new $.TypeParamIdx(0)) }];

  base_table: Aptos_std.Table.Table;
  keys: any[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_table = proto['base_table'] as Aptos_std.Table.Table;
    this.keys = proto['keys'] as any[];
  }

  static OpenTableParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OpenTable {
    const proto = $.parseStructProto(data, typeTag, repo, OpenTable);
    return new OpenTable(proto, typeTag);
  }

}
export function add_ (
  open_table: OpenTable,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  Aptos_std.Table.add_(open_table.base_table, $.copy(key), value, $c, [$p[0], $p[1]]);
  Std.Vector.push_back_(open_table.keys, $.copy(key), $c, [$p[0]]);
  return;
}

export function borrow_ (
  open_table: OpenTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Aptos_std.Table.borrow_(open_table.base_table, $.copy(key), $c, [$p[0], $p[1]]);
}

export function borrow_mut_ (
  open_table: OpenTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  return Aptos_std.Table.borrow_mut_(open_table.base_table, $.copy(key), $c, [$p[0], $p[1]]);
}

export function contains_ (
  open_table: OpenTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  return Aptos_std.Table.contains_(open_table.base_table, $.copy(key), $c, [$p[0], $p[1]]);
}

export function empty_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): OpenTable {
  return new OpenTable({ base_table: Aptos_std.Table.new___($c, [$p[0], $p[1]]), keys: Std.Vector.empty_($c, [$p[0]]) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "open_table", "OpenTable", [$p[0], $p[1]]));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::open_table::OpenTable", OpenTable.OpenTableParser);
}

