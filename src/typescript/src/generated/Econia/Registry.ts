import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as AptosFramework from "../AptosFramework";
import * as Std from "../Std";
import * as Book from "./Book";
import * as Caps from "./Caps";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
export const moduleName = "Registry";

export const E_NOT_COIN : U64 = u64("5");
export const E_NOT_ECONIA : U64 = u64("0");
export const E_NO_REGISTRY : U64 = u64("3");
export const E_REGISTERED : U64 = u64("4");
export const E_REGISTRY_EXISTS : U64 = u64("6");
export const E_WRONG_EXPONENT_T : U64 = u64("2");
export const E_WRONG_MODULE : U64 = u64("1");
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
export const M_NAME : U8[] = [u8("82"), u8("101"), u8("103"), u8("105"), u8("115"), u8("116"), u8("114"), u8("121")];


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

export class MI 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MI";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "b", typeTag: new StructTag(new HexString("0x1"), "TypeInfo", "TypeInfo", []) },
  { name: "q", typeTag: new StructTag(new HexString("0x1"), "TypeInfo", "TypeInfo", []) },
  { name: "e", typeTag: new StructTag(new HexString("0x1"), "TypeInfo", "TypeInfo", []) }];

  b: AptosFramework.TypeInfo.TypeInfo;
  q: AptosFramework.TypeInfo.TypeInfo;
  e: AptosFramework.TypeInfo.TypeInfo;

  constructor(proto: any, public typeTag: TypeTag) {
    this.b = proto['b'] as AptosFramework.TypeInfo.TypeInfo;
    this.q = proto['q'] as AptosFramework.TypeInfo.TypeInfo;
    this.e = proto['e'] as AptosFramework.TypeInfo.TypeInfo;
  }

  static MIParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MI {
    const proto = $.parseStructProto(data, typeTag, repo, MI);
    return new MI(proto, typeTag);
  }

}

export class MR 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MR";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "t", typeTag: new StructTag(new HexString("0x1"), "IterableTable", "IterableTable", [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []), AtomicTypeTag.Address]) }];

  t: AptosFramework.IterableTable.IterableTable;

  constructor(proto: any, public typeTag: TypeTag) {
    this.t = proto['t'] as AptosFramework.IterableTable.IterableTable;
  }

  static MRParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MR {
    const proto = $.parseStructProto(data, typeTag, repo, MR);
    return new MR(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, MR, typeParams);
    return result as unknown as MR;
  }
}
export function init_registry$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let addr;
  addr = Std.Signer.address_of$(account, $c);
  if (!($.copy(addr).hex() === new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", []), $.copy(addr))) {
    throw $.abortCode(E_REGISTRY_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", []), account, new MR({ t: AptosFramework.IterableTable.new__$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []), AtomicTypeTag.Address] as TypeTag[]) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", [])));
  return;
}

export function is_registered$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): boolean {
  let m_i;
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"))) {
    return false;
  }
  else{
  }
  m_i = new MI({ b: AptosFramework.TypeInfo.type_of$($c, [$p[0]] as TypeTag[]), q: AptosFramework.TypeInfo.type_of$($c, [$p[1]] as TypeTag[]), e: AptosFramework.TypeInfo.type_of$($c, [$p[2]] as TypeTag[]) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []));
  return AptosFramework.IterableTable.contains$($c.borrow_global<MR>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659")).t, $.copy(m_i), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []), AtomicTypeTag.Address] as TypeTag[]);
}

export function register_market$ (
  host: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, m_i, r_t;
  verify_market_types$($c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  if (!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"))) {
    throw $.abortCode(E_NO_REGISTRY);
  }
  m_i = new MI({ b: AptosFramework.TypeInfo.type_of$($c, [$p[0]] as TypeTag[]), q: AptosFramework.TypeInfo.type_of$($c, [$p[1]] as TypeTag[]), e: AptosFramework.TypeInfo.type_of$($c, [$p[2]] as TypeTag[]) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []));
  r_t = $c.borrow_global_mut<MR>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MR", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659")).t;
  [temp$1, temp$2] = [r_t, $.copy(m_i)];
  if (!!AptosFramework.IterableTable.contains$(temp$1, temp$2, $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []), AtomicTypeTag.Address] as TypeTag[])) {
    throw $.abortCode(E_REGISTERED);
  }
  temp$5 = host;
  temp$4 = scale_factor$($c, [$p[2]] as TypeTag[]);
  temp$3 = Caps.book_f_c$($c);
  Book.init_book$(temp$5, temp$4, temp$3, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  AptosFramework.IterableTable.add$(r_t, $.copy(m_i), Std.Signer.address_of$(host, $c), $c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "MI", []), AtomicTypeTag.Address] as TypeTag[]);
  return;
}


export function buildPayload_register_market (
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::register_market",
    typeParamStrings,
    []
  );

}
export function scale_factor$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <E>*/
): U64 {
  let temp$1, temp$10, temp$11, temp$12, temp$13, temp$14, temp$15, temp$16, temp$17, temp$18, temp$19, temp$2, temp$20, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, s_n, t_i;
  t_i = AptosFramework.TypeInfo.type_of$($c, [$p[0]] as TypeTag[]);
  verify_address$(AptosFramework.TypeInfo.account_address$(t_i, $c), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), E_NOT_ECONIA, $c);
  verify_bytestring$(AptosFramework.TypeInfo.module_name$(t_i, $c), M_NAME, E_WRONG_MODULE, $c);
  s_n = AptosFramework.TypeInfo.struct_name$(t_i, $c);
  temp$1 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E0", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$1, $c))) {
    return F0;
  }
  else{
  }
  temp$2 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E1", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$2, $c))) {
    return F1;
  }
  else{
  }
  temp$3 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E2", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$3, $c))) {
    return F2;
  }
  else{
  }
  temp$4 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E3", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$4, $c))) {
    return F3;
  }
  else{
  }
  temp$5 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E4", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$5, $c))) {
    return F4;
  }
  else{
  }
  temp$6 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E5", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$6, $c))) {
    return F5;
  }
  else{
  }
  temp$7 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E6", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$7, $c))) {
    return F6;
  }
  else{
  }
  temp$8 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E7", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$8, $c))) {
    return F7;
  }
  else{
  }
  temp$9 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E8", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$9, $c))) {
    return F8;
  }
  else{
  }
  temp$10 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E9", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$10, $c))) {
    return F9;
  }
  else{
  }
  temp$11 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E10", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$11, $c))) {
    return F10;
  }
  else{
  }
  temp$12 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E11", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$12, $c))) {
    return F11;
  }
  else{
  }
  temp$13 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E12", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$13, $c))) {
    return F12;
  }
  else{
  }
  temp$14 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E13", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$14, $c))) {
    return F13;
  }
  else{
  }
  temp$15 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E14", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$15, $c))) {
    return F14;
  }
  else{
  }
  temp$16 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E15", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$16, $c))) {
    return F15;
  }
  else{
  }
  temp$17 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E16", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$17, $c))) {
    return F16;
  }
  else{
  }
  temp$18 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E17", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$18, $c))) {
    return F17;
  }
  else{
  }
  temp$19 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E18", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$19, $c))) {
    return F18;
  }
  else{
  }
  temp$20 = AptosFramework.TypeInfo.type_of$($c, [new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Registry", "E19", [])] as TypeTag[]);
  if ($.veq($.copy(s_n), AptosFramework.TypeInfo.struct_name$(temp$20, $c))) {
    return F19;
  }
  else{
  }
  throw $.abortCode(E_WRONG_EXPONENT_T);
}

export function verify_address$ (
  a1: HexString,
  a2: HexString,
  e: U64,
  $c: AptosDataCache,
): void {
  if (!($.copy(a1).hex() === $.copy(a2).hex())) {
    throw $.abortCode($.copy(e));
  }
  return;
}

export function verify_bytestring$ (
  bs1: U8[],
  bs2: U8[],
  e: U64,
  $c: AptosDataCache,
): void {
  if (!$.veq($.copy(bs1), $.copy(bs2))) {
    throw $.abortCode($.copy(e));
  }
  return;
}

export function verify_market_types$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  if (!AptosFramework.Coin.is_coin_initialized$($c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(E_NOT_COIN);
  }
  if (!AptosFramework.Coin.is_coin_initialized$($c, [$p[1]] as TypeTag[])) {
    throw $.abortCode(E_NOT_COIN);
  }
  scale_factor$($c, [$p[2]] as TypeTag[]);
  return;
}

export function verify_t_i$ (
  t1: AptosFramework.TypeInfo.TypeInfo,
  t2: AptosFramework.TypeInfo.TypeInfo,
  e: U64,
  $c: AptosDataCache,
): void {
  verify_address$(AptosFramework.TypeInfo.account_address$(t1, $c), AptosFramework.TypeInfo.account_address$(t2, $c), $.copy(e), $c);
  verify_bytestring$(AptosFramework.TypeInfo.module_name$(t1, $c), AptosFramework.TypeInfo.module_name$(t2, $c), $.copy(e), $c);
  verify_bytestring$(AptosFramework.TypeInfo.struct_name$(t1, $c), AptosFramework.TypeInfo.struct_name$(t2, $c), $.copy(e), $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E0", E0.E0Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E1", E1.E1Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E10", E10.E10Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E11", E11.E11Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E12", E12.E12Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E13", E13.E13Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E14", E14.E14Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E15", E15.E15Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E16", E16.E16Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E17", E17.E17Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E18", E18.E18Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E19", E19.E19Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E2", E2.E2Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E3", E3.E3Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E4", E4.E4Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E5", E5.E5Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E6", E6.E6Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E7", E7.E7Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E8", E8.E8Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::E9", E9.E9Parser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::MI", MI.MIParser);
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Registry::MR", MR.MRParser);
}

