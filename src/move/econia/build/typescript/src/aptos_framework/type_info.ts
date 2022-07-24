import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "type_info";



export class TypeInfo 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TypeInfo";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "account_address", typeTag: AtomicTypeTag.Address },
  { name: "module_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "struct_name", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  account_address: HexString;
  module_name: U8[];
  struct_name: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.account_address = proto['account_address'] as HexString;
    this.module_name = proto['module_name'] as U8[];
    this.struct_name = proto['struct_name'] as U8[];
  }

  static TypeInfoParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TypeInfo {
    const proto = $.parseStructProto(data, typeTag, repo, TypeInfo);
    return new TypeInfo(proto, typeTag);
  }

}
export function account_address$ (
  type_info: TypeInfo,
  $c: AptosDataCache,
): HexString {
  return $.copy(type_info.account_address);
}

export function module_name$ (
  type_info: TypeInfo,
  $c: AptosDataCache,
): U8[] {
  return $.copy(type_info.module_name);
}

export function struct_name$ (
  type_info: TypeInfo,
  $c: AptosDataCache,
): U8[] {
  return $.copy(type_info.struct_name);
}

export function type_of$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): TypeInfo {
  return $.aptos_framework_type_info_type_of($c, [$p[0]]);

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::type_info::TypeInfo", TypeInfo.TypeInfoParser);
}

