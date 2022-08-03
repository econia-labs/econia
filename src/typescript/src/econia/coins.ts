import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_framework from "../aptos_framework";
import * as Std from "../std";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "coins";

export const BASE_COIN_DECIMALS : U64 = u64("4");
export const BASE_COIN_NAME : U8[] = [u8("66"), u8("97"), u8("115"), u8("101"), u8("32"), u8("99"), u8("111"), u8("105"), u8("110")];
export const BASE_COIN_SYMBOL : U8[] = [u8("66"), u8("67")];
export const E_HAS_CAPABILITIES : U64 = u64("1");
export const E_NOT_ECONIA : U64 = u64("0");
export const E_NO_CAPABILITIES : U64 = u64("2");
export const QUOTE_COIN_DECIMALS : U64 = u64("12");
export const QUOTE_COIN_NAME : U8[] = [u8("81"), u8("117"), u8("111"), u8("116"), u8("101"), u8("32"), u8("99"), u8("111"), u8("105"), u8("110")];
export const QUOTE_COIN_SYMBOL : U8[] = [u8("81"), u8("67")];


export class BC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static BCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BC {
    const proto = $.parseStructProto(data, typeTag, repo, BC);
    return new BC(proto, typeTag);
  }

}

export class CoinCapabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "mint_capability", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new $.TypeParamIdx(0)]) },
  { name: "burn_capability", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new $.TypeParamIdx(0)]) }];

  mint_capability: Aptos_framework.Coin.MintCapability;
  burn_capability: Aptos_framework.Coin.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_capability = proto['mint_capability'] as Aptos_framework.Coin.MintCapability;
    this.burn_capability = proto['burn_capability'] as Aptos_framework.Coin.BurnCapability;
  }

  static CoinCapabilitiesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CoinCapabilities {
    const proto = $.parseStructProto(data, typeTag, repo, CoinCapabilities);
    return new CoinCapabilities(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, CoinCapabilities, typeParams);
    return result as unknown as CoinCapabilities;
  }
}

export class QC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "QC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static QCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : QC {
    const proto = $.parseStructProto(data, typeTag, repo, QC);
    return new QC(proto, typeTag);
  }

}
export function burn_ (
  coins: Aptos_framework.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let burn_capability;
  burn_capability = $c.borrow_global<CoinCapabilities>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "CoinCapabilities", [$p[0]]), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).burn_capability;
  Aptos_framework.Coin.burn_(coins, burn_capability, $c, [$p[0]]);
  return;
}

export function init_coin_type_ (
  account: HexString,
  coin_name: U8[],
  coin_symbol: U8[],
  decimals: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let burn_capability, mint_capability;
  if (!((Std.Signer.address_of_(account, $c)).hex() === (new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "CoinCapabilities", [$p[0]]), new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"))) {
    throw $.abortCode(E_HAS_CAPABILITIES);
  }
  [mint_capability, burn_capability] = Aptos_framework.Coin.initialize_(account, Std.String.utf8_($.copy(coin_name), $c), Std.String.utf8_($.copy(coin_symbol), $c), $.copy(decimals), false, $c, [$p[0]]);
  $c.move_to(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "CoinCapabilities", [$p[0]]), account, new CoinCapabilities({ mint_capability: $.copy(mint_capability), burn_capability: $.copy(burn_capability) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "CoinCapabilities", [$p[0]])));
  return;
}

export function init_coin_types_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  init_coin_type_(account, BASE_COIN_NAME, BASE_COIN_SYMBOL, BASE_COIN_DECIMALS, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "BC", [])]);
  init_coin_type_(account, QUOTE_COIN_NAME, QUOTE_COIN_SYMBOL, QUOTE_COIN_DECIMALS, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "QC", [])]);
  return;
}


export function buildPayload_init_coin_types (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::coins::init_coin_types",
    typeParamStrings,
    []
  );

}

export function mint_ (
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): Aptos_framework.Coin.Coin {
  let account_address, mint_capability;
  account_address = Std.Signer.address_of_(account, $c);
  if (!(($.copy(account_address)).hex() === (new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!$c.exists(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "CoinCapabilities", [$p[0]]), $.copy(account_address))) {
    throw $.abortCode(E_NO_CAPABILITIES);
  }
  mint_capability = $c.borrow_global<CoinCapabilities>(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "coins", "CoinCapabilities", [$p[0]]), $.copy(account_address)).mint_capability;
  return Aptos_framework.Coin.mint_($.copy(amount), mint_capability, $c, [$p[0]]);
}


export function buildPayload_mint (
  amount: U64,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::coins::mint",
    typeParamStrings,
    [
      $.payloadArg(amount),
    ]
  );

}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::coins::BC", BC.BCParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::coins::CoinCapabilities", CoinCapabilities.CoinCapabilitiesParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::coins::QC", QC.QCParser);
}

