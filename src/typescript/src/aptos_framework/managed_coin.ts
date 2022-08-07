import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Coin from "./coin";
import * as Coins from "./coins";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "managed_coin";

export const ENO_CAPABILITIES : U64 = u64("0");


export class Capabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Capabilities";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "mint_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new $.TypeParamIdx(0)]) },
  { name: "burn_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new $.TypeParamIdx(0)]) }];

  mint_cap: Coin.MintCapability;
  burn_cap: Coin.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_cap = proto['mint_cap'] as Coin.MintCapability;
    this.burn_cap = proto['burn_cap'] as Coin.BurnCapability;
  }

  static CapabilitiesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Capabilities {
    const proto = $.parseStructProto(data, typeTag, repo, Capabilities);
    return new Capabilities(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Capabilities, typeParams);
    return result as unknown as Capabilities;
  }
}
export function burn_ (
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let account_addr, capabilities, to_burn;
  account_addr = Std.Signer.address_of_(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "managed_coin", "Capabilities", [$p[0]]), $.copy(account_addr))) {
    throw $.abortCode(Std.Error.not_found_(ENO_CAPABILITIES, $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "managed_coin", "Capabilities", [$p[0]]), $.copy(account_addr));
  to_burn = Coin.withdraw_(account, $.copy(amount), $c, [$p[0]]);
  Coin.burn_(to_burn, capabilities.burn_cap, $c, [$p[0]]);
  return;
}


export function buildPayload_burn (
  amount: U64,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x1::managed_coin::burn",
    typeParamStrings,
    [
      $.payloadArg(amount),
    ]
  );

}
export function initialize_ (
  account: HexString,
  name: U8[],
  symbol: U8[],
  decimals: U64,
  monitor_supply: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let burn_cap, mint_cap;
  [mint_cap, burn_cap] = Coin.initialize_(account, Std.String.utf8_($.copy(name), $c), Std.String.utf8_($.copy(symbol), $c), $.copy(decimals), monitor_supply, $c, [$p[0]]);
  $c.move_to(new StructTag(new HexString("0x1"), "managed_coin", "Capabilities", [$p[0]]), account, new Capabilities({ mint_cap: $.copy(mint_cap), burn_cap: $.copy(burn_cap) }, new StructTag(new HexString("0x1"), "managed_coin", "Capabilities", [$p[0]])));
  return;
}


export function buildPayload_initialize (
  name: U8[],
  symbol: U8[],
  decimals: U64,
  monitor_supply: boolean,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x1::managed_coin::initialize",
    typeParamStrings,
    [
      $.u8ArrayArg(name),
      $.u8ArrayArg(symbol),
      $.payloadArg(decimals),
      $.payloadArg(monitor_supply),
    ]
  );

}
export function mint_ (
  account: HexString,
  dst_addr: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  let account_addr, capabilities, coins_minted;
  account_addr = Std.Signer.address_of_(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "managed_coin", "Capabilities", [$p[0]]), $.copy(account_addr))) {
    throw $.abortCode(Std.Error.not_found_(ENO_CAPABILITIES, $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "managed_coin", "Capabilities", [$p[0]]), $.copy(account_addr));
  coins_minted = Coin.mint_($.copy(amount), capabilities.mint_cap, $c, [$p[0]]);
  Coin.deposit_($.copy(dst_addr), coins_minted, $c, [$p[0]]);
  return;
}


export function buildPayload_mint (
  dst_addr: HexString,
  amount: U64,
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x1::managed_coin::mint",
    typeParamStrings,
    [
      $.payloadArg(dst_addr),
      $.payloadArg(amount),
    ]
  );

}
export function register_ (
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <CoinType>*/
): void {
  Coins.register_(account, $c, [$p[0]]);
  return;
}


export function buildPayload_register (
  $p: TypeTag[], /* <CoinType>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x1::managed_coin::register",
    typeParamStrings,
    []
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::managed_coin::Capabilities", Capabilities.CapabilitiesParser);
}

