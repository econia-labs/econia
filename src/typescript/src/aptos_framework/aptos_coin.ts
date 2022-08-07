import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Coin from "./coin";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aptos_coin";

export const EALREADY_DELEGATED : U64 = u64("2");
export const EDELEGATION_NOT_FOUND : U64 = u64("3");
export const ENO_CAPABILITIES : U64 = u64("1");


export class AptosCoin 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "AptosCoin";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static AptosCoinParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : AptosCoin {
    const proto = $.parseStructProto(data, typeTag, repo, AptosCoin);
    return new AptosCoin(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, AptosCoin, typeParams);
    return result as unknown as AptosCoin;
  }
}

export class Capabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Capabilities";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "mint_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]) }];

  mint_cap: Coin.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_cap = proto['mint_cap'] as Coin.MintCapability;
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

export class DelegatedMintCapability 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "DelegatedMintCapability";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "to", typeTag: AtomicTypeTag.Address }];

  to: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.to = proto['to'] as HexString;
  }

  static DelegatedMintCapabilityParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : DelegatedMintCapability {
    const proto = $.parseStructProto(data, typeTag, repo, DelegatedMintCapability);
    return new DelegatedMintCapability(proto, typeTag);
  }

}

export class Delegations 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Delegations";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "inner", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])) }];

  inner: DelegatedMintCapability[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto['inner'] as DelegatedMintCapability[];
  }

  static DelegationsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Delegations {
    const proto = $.parseStructProto(data, typeTag, repo, Delegations);
    return new Delegations(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Delegations, typeParams);
    return result as unknown as Delegations;
  }
}
export function claim_mint_capability_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let delegations, idx, maybe_index, mint_cap;
  maybe_index = find_delegation_(Std.Signer.address_of_(account, $c), $c);
  if (!Std.Option.is_some_(maybe_index, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode(EDELEGATION_NOT_FOUND);
  }
  idx = $.copy(Std.Option.borrow_(maybe_index, $c, [AtomicTypeTag.U64]));
  delegations = $c.borrow_global_mut<Delegations>(new StructTag(new HexString("0x1"), "aptos_coin", "Delegations", []), new HexString("0xa550c18")).inner;
  Std.Vector.swap_remove_(delegations, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]);
  mint_cap = $.copy($c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", []), new HexString("0xa550c18")).mint_cap);
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", []), account, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", [])));
  return;
}


export function buildPayload_claim_mint_capability (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::aptos_coin::claim_mint_capability",
    typeParamStrings,
    []
  );

}
export function delegate_mint_capability_ (
  account: HexString,
  to: HexString,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, delegations, element, i;
  System_addresses.assert_core_resource_(account, $c);
  delegations = $c.borrow_global_mut<Delegations>(new StructTag(new HexString("0x1"), "aptos_coin", "Delegations", []), new HexString("0xa550c18")).inner;
  i = u64("0");
  while (($.copy(i)).lt(Std.Vector.length_(delegations, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]))) {
    {
      [temp$1, temp$2] = [delegations, $.copy(i)];
      element = Std.Vector.borrow_(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]);
      if (!(($.copy(element.to)).hex() !== ($.copy(to)).hex())) {
        throw $.abortCode(Std.Error.invalid_argument_(EALREADY_DELEGATED, $c));
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }Std.Vector.push_back_(delegations, new DelegatedMintCapability({ to: $.copy(to) }, new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])), $c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]);
  return;
}


export function buildPayload_delegate_mint_capability (
  to: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::aptos_coin::delegate_mint_capability",
    typeParamStrings,
    [
      $.payloadArg(to),
    ]
  );

}
export function find_delegation_ (
  addr: HexString,
  $c: AptosDataCache,
): Std.Option.Option {
  let delegations, element, i, index, len;
  delegations = $c.borrow_global<Delegations>(new StructTag(new HexString("0x1"), "aptos_coin", "Delegations", []), new HexString("0xa550c18")).inner;
  i = u64("0");
  len = Std.Vector.length_(delegations, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]);
  index = Std.Option.none_($c, [AtomicTypeTag.U64]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      element = Std.Vector.borrow_(delegations, $.copy(i), $c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]);
      if ((($.copy(element.to)).hex() === ($.copy(addr)).hex())) {
        index = Std.Option.some_($.copy(i), $c, [AtomicTypeTag.U64]);
        break;
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }return $.copy(index);
}

export function initialize_ (
  aptos_framework: HexString,
  core_resource: HexString,
  $c: AptosDataCache,
): [Coin.MintCapability, Coin.BurnCapability] {
  let burn_cap, coins, mint_cap;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  [mint_cap, burn_cap] = Coin.initialize_(aptos_framework, Std.String.utf8_([u8("65"), u8("112"), u8("116"), u8("111"), u8("115"), u8("32"), u8("67"), u8("111"), u8("105"), u8("110")], $c), Std.String.utf8_([u8("65"), u8("80"), u8("84"), u8("79"), u8("83")], $c), u64("8"), false, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", []), aptos_framework, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", [])));
  Coin.register_(core_resource, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  coins = Coin.mint_(u64("18446744073709551615"), mint_cap, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  Coin.deposit_(Std.Signer.address_of_(core_resource, $c), coins, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", []), core_resource, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_coin", "Delegations", []), core_resource, new Delegations({ inner: Std.Vector.empty_($c, [new StructTag(new HexString("0x1"), "aptos_coin", "DelegatedMintCapability", [])]) }, new StructTag(new HexString("0x1"), "aptos_coin", "Delegations", [])));
  return [$.copy(mint_cap), $.copy(burn_cap)];
}

export function mint_ (
  account: HexString,
  dst_addr: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  let account_addr, capabilities, coins_minted;
  account_addr = Std.Signer.address_of_(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", []), $.copy(account_addr))) {
    throw $.abortCode(Std.Error.not_found_(ENO_CAPABILITIES, $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "aptos_coin", "Capabilities", []), $.copy(account_addr));
  coins_minted = Coin.mint_($.copy(amount), capabilities.mint_cap, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  Coin.deposit_($.copy(dst_addr), coins_minted, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  return;
}


export function buildPayload_mint (
  dst_addr: HexString,
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::aptos_coin::mint",
    typeParamStrings,
    [
      $.payloadArg(dst_addr),
      $.payloadArg(amount),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::aptos_coin::AptosCoin", AptosCoin.AptosCoinParser);
  repo.addParser("0x1::aptos_coin::Capabilities", Capabilities.CapabilitiesParser);
  repo.addParser("0x1::aptos_coin::DelegatedMintCapability", DelegatedMintCapability.DelegatedMintCapabilityParser);
  repo.addParser("0x1::aptos_coin::Delegations", Delegations.DelegationsParser);
}

