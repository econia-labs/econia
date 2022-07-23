import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as aptos_framework$_ from "../aptos_framework";
import * as std$_ from "../std";
export const packageName = "Econia";
export const moduleAddress = new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9");
export const moduleName = "Coins";

export const BCT_CN : U8[] = [u8("66"), u8("97"), u8("115"), u8("101")];
export const BCT_CS : U8[] = [u8("66")];
export const BCT_D : U64 = u64("4");
export const BCT_TN : U8[] = [u8("66"), u8("67"), u8("84")];
export const E_NOT_ECONIA : U64 = u64("0");
export const QCT_CN : U8[] = [u8("81"), u8("117"), u8("111"), u8("116"), u8("101")];
export const QCT_CS : U8[] = [u8("81")];
export const QCT_D : U64 = u64("8");
export const QCT_TN : U8[] = [u8("81"), u8("67"), u8("84")];


export class BCC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BCC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "m", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCT", [])]) },
  { name: "b", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCT", [])]) }];

  m: aptos_framework$_.coin$_.MintCapability;
  b: aptos_framework$_.coin$_.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.m = proto['m'] as aptos_framework$_.coin$_.MintCapability;
    this.b = proto['b'] as aptos_framework$_.coin$_.BurnCapability;
  }

  static BCCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BCC {
    const proto = $.parseStructProto(data, typeTag, repo, BCC);
    return new BCC(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, BCC, typeParams);
    return result as unknown as BCC;
  }
}

export class BCT 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BCT";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static BCTParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BCT {
    const proto = $.parseStructProto(data, typeTag, repo, BCT);
    return new BCT(proto, typeTag);
  }

}

export class QCC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "QCC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "m", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCT", [])]) },
  { name: "b", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCT", [])]) }];

  m: aptos_framework$_.coin$_.MintCapability;
  b: aptos_framework$_.coin$_.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.m = proto['m'] as aptos_framework$_.coin$_.MintCapability;
    this.b = proto['b'] as aptos_framework$_.coin$_.BurnCapability;
  }

  static QCCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : QCC {
    const proto = $.parseStructProto(data, typeTag, repo, QCC);
    return new QCC(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, QCC, typeParams);
    return result as unknown as QCC;
  }
}

export class QCT 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "QCT";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static QCTParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : QCT {
    const proto = $.parseStructProto(data, typeTag, repo, QCT);
    return new QCT(proto, typeTag);
  }

}
export function init_coin_types$ (
  econia: HexString,
  $c: AptosDataCache,
): void {
  let b, b__2, m, m__1;
  if (!(std$_.signer$_.address_of$(econia, $c).hex() === new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  [m, b] = aptos_framework$_.coin$_.initialize$(econia, std$_.string$_.utf8$(BCT_CN, $c), std$_.string$_.utf8$(BCT_CS, $c), BCT_D, false, $c, [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCT", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCC", []), econia, new BCC({ m: $.copy(m), b: $.copy(b) }, new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCC", [])));
  [m__1, b__2] = aptos_framework$_.coin$_.initialize$(econia, std$_.string$_.utf8$(QCT_CN, $c), std$_.string$_.utf8$(QCT_CS, $c), QCT_D, false, $c, [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCT", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCC", []), econia, new QCC({ m: $.copy(m__1), b: $.copy(b__2) }, new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCC", [])));
  return;
}


export function buildPayload_init_coin_types (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Coins::init_coin_types",
    typeParamStrings,
    []
  );

}
export function mint_to$ (
  econia: HexString,
  user: HexString,
  val_bct: U64,
  val_qct: U64,
  $c: AptosDataCache,
): void {
  if (!(std$_.signer$_.address_of$(econia, $c).hex() === new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  aptos_framework$_.coin$_.deposit$($.copy(user), aptos_framework$_.coin$_.mint$($.copy(val_bct), $c.borrow_global<BCC>(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCC", []), new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9")).m, $c, [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCT", [])] as TypeTag[]), $c, [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "BCT", [])] as TypeTag[]);
  aptos_framework$_.coin$_.deposit$($.copy(user), aptos_framework$_.coin$_.mint$($.copy(val_qct), $c.borrow_global<QCC>(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCC", []), new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9")).m, $c, [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCT", [])] as TypeTag[]), $c, [new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Coins", "QCT", [])] as TypeTag[]);
  return;
}


export function buildPayload_mint_to (
  user: HexString,
  val_bct: U64,
  val_qct: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Coins::mint_to",
    typeParamStrings,
    [
      $.payloadArg(user),
      $.payloadArg(val_bct),
      $.payloadArg(val_qct),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Coins::BCC", BCC.BCCParser);
  repo.addParser("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Coins::BCT", BCT.BCTParser);
  repo.addParser("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Coins::QCC", QCC.QCCParser);
  repo.addParser("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Coins::QCT", QCT.QCTParser);
}

