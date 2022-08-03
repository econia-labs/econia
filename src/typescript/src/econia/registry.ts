import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_framework from "../aptos_framework";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
import * as Capability from "./capability";
import * as Open_table from "./open_table";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "registry";

export const E_MARKET_EXISTS : U64 = u64("7");
export const E_MARKET_NOT_REGISTERED : U64 = u64("8");
export const E_NOT_COIN_BASE : U64 = u64("4");
export const E_NOT_COIN_QUOTE : U64 = u64("5");
export const E_NOT_ECONIA : U64 = u64("0");
export const E_NOT_EXPONENT_TYPE : U64 = u64("3");
export const E_NOT_IN_MARKET_PAIR : U64 = u64("9");
export const E_NO_REGISTRY : U64 = u64("2");
export const E_REGISTRY_EXISTS : U64 = u64("1");
export const E_SAME_COIN_TYPE : U64 = u64("6");
export const F0 : U64 = u64("1");
export const F1 : U64 = u64("10");
export const F10 : U64 = u64("10000000000");
export const F11 : U64 = u64("100000000000");
export const F12 : U64 = u64("1000000000000");
export const F13 : U64 = u64("10000000000000");
export const F14 : U64 = u64("100000000000000");
export const F15 : U64 = u64("1000000000000000");
export const F16 : U64 = u64("10000000000000000");
export const F17 : U64 = u64("100000000000000000");
export const F18 : U64 = u64("1000000000000000000");
export const F19 : U64 = u64("10000000000000000000");
export const F2 : U64 = u64("100");
export const F3 : U64 = u64("1000");
export const F4 : U64 = u64("10000");
export const F5 : U64 = u64("100000");
export const F6 : U64 = u64("1000000");
export const F7 : U64 = u64("10000000");
export const F8 : U64 = u64("100000000");
export const F9 : U64 = u64("1000000000");


export class CustodianCapability 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CustodianCapability";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "custodian_id", typeTag: AtomicTypeTag.U64 }];

  custodian_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.custodian_id = proto['custodian_id'] as U64;
  }

  static CustodianCapabilityParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CustodianCapability {
    const proto = $.parseStructProto(data, typeTag, repo, CustodianCapability);
    return new CustodianCapability(proto, typeTag);
  }

}

export class E0 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E0";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E0Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E0 {
    const proto = $.parseStructProto(data, typeTag, repo, E0);
    return new E0(proto, typeTag);
  }

}

export class E1 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E1";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E1Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E1 {
    const proto = $.parseStructProto(data, typeTag, repo, E1);
    return new E1(proto, typeTag);
  }

}

export class E10 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E10";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E10Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E10 {
    const proto = $.parseStructProto(data, typeTag, repo, E10);
    return new E10(proto, typeTag);
  }

}

export class E11 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E11";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E11Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E11 {
    const proto = $.parseStructProto(data, typeTag, repo, E11);
    return new E11(proto, typeTag);
  }

}

export class E12 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E12";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E12Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E12 {
    const proto = $.parseStructProto(data, typeTag, repo, E12);
    return new E12(proto, typeTag);
  }

}

export class E13 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E13";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E13Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E13 {
    const proto = $.parseStructProto(data, typeTag, repo, E13);
    return new E13(proto, typeTag);
  }

}

export class E14 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E14";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E14Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E14 {
    const proto = $.parseStructProto(data, typeTag, repo, E14);
    return new E14(proto, typeTag);
  }

}

export class E15 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E15";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E15Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E15 {
    const proto = $.parseStructProto(data, typeTag, repo, E15);
    return new E15(proto, typeTag);
  }

}

export class E16 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E16";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E16Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E16 {
    const proto = $.parseStructProto(data, typeTag, repo, E16);
    return new E16(proto, typeTag);
  }

}

export class E17 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E17";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E17Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E17 {
    const proto = $.parseStructProto(data, typeTag, repo, E17);
    return new E17(proto, typeTag);
  }

}

export class E18 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E18";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E18Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E18 {
    const proto = $.parseStructProto(data, typeTag, repo, E18);
    return new E18(proto, typeTag);
  }

}

export class E19 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E19";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E19Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E19 {
    const proto = $.parseStructProto(data, typeTag, repo, E19);
    return new E19(proto, typeTag);
  }

}

export class E2 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E2";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E2Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E2 {
    const proto = $.parseStructProto(data, typeTag, repo, E2);
    return new E2(proto, typeTag);
  }

}

export class E3 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E3";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E3Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E3 {
    const proto = $.parseStructProto(data, typeTag, repo, E3);
    return new E3(proto, typeTag);
  }

}

export class E4 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E4";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E4Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E4 {
    const proto = $.parseStructProto(data, typeTag, repo, E4);
    return new E4(proto, typeTag);
  }

}

export class E5 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E5";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E5Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E5 {
    const proto = $.parseStructProto(data, typeTag, repo, E5);
    return new E5(proto, typeTag);
  }

}

export class E6 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E6";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E6Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E6 {
    const proto = $.parseStructProto(data, typeTag, repo, E6);
    return new E6(proto, typeTag);
  }

}

export class E7 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E7";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E7Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E7 {
    const proto = $.parseStructProto(data, typeTag, repo, E7);
    return new E7(proto, typeTag);
  }

}

export class E8 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E8";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E8Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E8 {
    const proto = $.parseStructProto(data, typeTag, repo, E8);
    return new E8(proto, typeTag);
  }

}

export class E9 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "E9";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static E9Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : E9 {
    const proto = $.parseStructProto(data, typeTag, repo, E9);
    return new E9(proto, typeTag);
  }

}

export class MarketInfo 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MarketInfo";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "base_coin_type", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "quote_coin_type", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) },
  { name: "scale_exponent_type", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) }];

  base_coin_type: Aptos_std.Type_info.TypeInfo;
  quote_coin_type: Aptos_std.Type_info.TypeInfo;
  scale_exponent_type: Aptos_std.Type_info.TypeInfo;

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_coin_type = proto['base_coin_type'] as Aptos_std.Type_info.TypeInfo;
    this.quote_coin_type = proto['quote_coin_type'] as Aptos_std.Type_info.TypeInfo;
    this.scale_exponent_type = proto['scale_exponent_type'] as Aptos_std.Type_info.TypeInfo;
  }

  static MarketInfoParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MarketInfo {
    const proto = $.parseStructProto(data, typeTag, repo, MarketInfo);
    return new MarketInfo(proto, typeTag);
  }

}

export class Registry 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Registry";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "scales", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "open_table", "OpenTable", [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]) },
  { name: "markets", typeTag: new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "open_table", "OpenTable", [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []), AtomicTypeTag.Address]) },
  { name: "n_custodians", typeTag: AtomicTypeTag.U64 }];

  scales: Open_table.OpenTable;
  markets: Open_table.OpenTable;
  n_custodians: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.scales = proto['scales'] as Open_table.OpenTable;
    this.markets = proto['markets'] as Open_table.OpenTable;
    this.n_custodians = proto['n_custodians'] as U64;
  }

  static RegistryParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Registry {
    const proto = $.parseStructProto(data, typeTag, repo, Registry);
    return new Registry(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Registry, typeParams);
    return result as unknown as Registry;
  }
}
export function coin_is_base_coin_ (
  market_info: MarketInfo,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): boolean {
  let coin_type_info;
  coin_type_info = Aptos_std.Type_info.type_of_($c, [$p[0]]);
  if ($.deep_eq($.copy(coin_type_info), $.copy(market_info.base_coin_type))) {
    return true;
  }
  else{
  }
  if ($.deep_eq($.copy(coin_type_info), $.copy(market_info.quote_coin_type))) {
    return false;
  }
  else{
  }
  throw $.abortCode(E_NOT_IN_MARKET_PAIR);
}

export function coin_is_in_market_pair_ (
  market_info: MarketInfo,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): boolean {
  let temp$1, coin_type_info;
  coin_type_info = Aptos_std.Type_info.type_of_($c, [$p[0]]);
  if ($.deep_eq($.copy(coin_type_info), $.copy(market_info.base_coin_type))) {
    temp$1 = true;
  }
  else{
    temp$1 = $.deep_eq($.copy(coin_type_info), $.copy(market_info.quote_coin_type));
  }
  return temp$1;
}

export function custodian_id_ (
  custodian_capability_ref: CustodianCapability,
  $c: AptosDataCache,
): U64 {
  return $.copy(custodian_capability_ref.custodian_id);
}

export function init_registry_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let scales;
  if (!((Std.Signer.address_of_(account, $c)).hex() === (new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_REGISTRY_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), account, new Registry({ scales: Open_table.empty_($c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]), markets: Open_table.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []), AtomicTypeTag.Address]), n_custodians: u64("0") }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", [])));
  scales = $c.borrow_global_mut<Registry>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).scales;
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E0", [])]), F0, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E1", [])]), F1, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E2", [])]), F2, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E3", [])]), F3, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E4", [])]), F4, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E5", [])]), F5, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E6", [])]), F6, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E7", [])]), F7, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E8", [])]), F8, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E9", [])]), F9, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E10", [])]), F10, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E11", [])]), F11, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E12", [])]), F12, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E13", [])]), F13, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E14", [])]), F14, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E15", [])]), F15, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E16", [])]), F16, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E17", [])]), F17, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E18", [])]), F18, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  Open_table.add_(scales, Aptos_std.Type_info.type_of_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "E19", [])]), F19, $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]);
  return;
}

export function is_registered_ (
  market_info: MarketInfo,
  $c: AptosDataCache,
): boolean {
  let registry;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    return false;
  }
  else{
  }
  registry = $c.borrow_global_mut<Registry>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"));
  return Open_table.contains_(registry.markets, $.copy(market_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []), AtomicTypeTag.Address]);
}

export function is_registered_types_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  return is_registered_(market_info_($c, [$p[0], $p[1], $p[2]]), $c);
}

export function is_valid_custodian_id_ (
  custodian_id: U64,
  $c: AptosDataCache,
): boolean {
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    return false;
  }
  else{
  }
  return ($.copy(custodian_id)).le(n_custodians_($c));
}

export function market_info_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): MarketInfo {
  return new MarketInfo({ base_coin_type: Aptos_std.Type_info.type_of_($c, [$p[0]]), quote_coin_type: Aptos_std.Type_info.type_of_($c, [$p[1]]), scale_exponent_type: Aptos_std.Type_info.type_of_($c, [$p[2]]) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []));
}

export function n_custodians_ (
  $c: AptosDataCache,
): U64 {
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_NO_REGISTRY);
  }
  return $.copy($c.borrow_global<Registry>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).n_custodians);
}

export function register_custodian_capability_ (
  $c: AptosDataCache,
): CustodianCapability {
  let custodian_id, registry;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_NO_REGISTRY);
  }
  registry = $c.borrow_global_mut<Registry>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"));
  custodian_id = ($.copy(registry.n_custodians)).add(u64("1"));
  registry.n_custodians = $.copy(custodian_id);
  return new CustodianCapability({ custodian_id: $.copy(custodian_id) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "CustodianCapability", []));
}

export function register_market_internal_ (
  host: HexString,
  _econia_capability: Capability.EconiaCapability,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let base_coin_type, market_info, quote_coin_type, registry, scale_exponent_type;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_NO_REGISTRY);
  }
  if (!Aptos_framework.Coin.is_coin_initialized_($c, [$p[0]])) {
    throw $.abortCode(E_NOT_COIN_BASE);
  }
  if (!Aptos_framework.Coin.is_coin_initialized_($c, [$p[1]])) {
    throw $.abortCode(E_NOT_COIN_QUOTE);
  }
  base_coin_type = Aptos_std.Type_info.type_of_($c, [$p[0]]);
  quote_coin_type = Aptos_std.Type_info.type_of_($c, [$p[1]]);
  if (!$.deep_eq($.copy(base_coin_type), $.copy(quote_coin_type))) {
    throw $.abortCode(E_SAME_COIN_TYPE);
  }
  scale_exponent_type = Aptos_std.Type_info.type_of_($c, [$p[2]]);
  registry = $c.borrow_global_mut<Registry>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"));
  if (!Open_table.contains_(registry.scales, $.copy(scale_exponent_type), $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64])) {
    throw $.abortCode(E_NOT_EXPONENT_TYPE);
  }
  market_info = new MarketInfo({ base_coin_type: $.copy(base_coin_type), quote_coin_type: $.copy(quote_coin_type), scale_exponent_type: $.copy(scale_exponent_type) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []));
  if (!!Open_table.contains_(registry.markets, $.copy(market_info), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []), AtomicTypeTag.Address])) {
    throw $.abortCode(E_MARKET_EXISTS);
  }
  Open_table.add_(registry.markets, $.copy(market_info), $.copy(host), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "MarketInfo", []), AtomicTypeTag.Address]);
  return;
}

export function scale_factor_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <E>*/
): U64 {
  return scale_factor_from_type_info_(Aptos_std.Type_info.type_of_($c, [$p[0]]), $c);
}

export function scale_factor_from_market_info_ (
  market_info: MarketInfo,
  $c: AptosDataCache,
): U64 {
  return scale_factor_from_type_info_($.copy(market_info.scale_exponent_type), $c);
}

export function scale_factor_from_type_info_ (
  scale_exponent_type_info: Aptos_std.Type_info.TypeInfo,
  $c: AptosDataCache,
): U64 {
  let scales;
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_NO_REGISTRY);
  }
  scales = $c.borrow_global<Registry>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "registry", "Registry", []), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).scales;
  if (!Open_table.contains_(scales, $.copy(scale_exponent_type_info), $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64])) {
    throw $.abortCode(E_NOT_EXPONENT_TYPE);
  }
  return $.copy(Open_table.borrow_(scales, $.copy(scale_exponent_type_info), $c, [new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []), AtomicTypeTag.U64]));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::CustodianCapability", CustodianCapability.CustodianCapabilityParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E0", E0.E0Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E1", E1.E1Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E10", E10.E10Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E11", E11.E11Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E12", E12.E12Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E13", E13.E13Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E14", E14.E14Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E15", E15.E15Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E16", E16.E16Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E17", E17.E17Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E18", E18.E18Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E19", E19.E19Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E2", E2.E2Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E3", E3.E3Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E4", E4.E4Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E5", E5.E5Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E6", E6.E6Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E7", E7.E7Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E8", E8.E8Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::E9", E9.E9Parser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::MarketInfo", MarketInfo.MarketInfoParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::registry::Registry", Registry.RegistryParser);
}

