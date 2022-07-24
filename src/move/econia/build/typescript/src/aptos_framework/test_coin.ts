import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as coin$_ from "./coin";
import * as system_addresses$_ from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "test_coin";

export const EALREADY_DELEGATED : U64 = u64("2");
export const EDELEGATION_NOT_FOUND : U64 = u64("3");
export const ENO_CAPABILITIES : U64 = u64("1");


export class Capabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Capabilities";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "mint_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) }];

  mint_cap: coin$_.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_cap = proto['mint_cap'] as coin$_.MintCapability;
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
  { name: "inner", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])) }];

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

export class TestCoin 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TestCoin";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static TestCoinParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TestCoin {
    const proto = $.parseStructProto(data, typeTag, repo, TestCoin);
    return new TestCoin(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, TestCoin, typeParams);
    return result as unknown as TestCoin;
  }
}
export function claim_mint_capability$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let delegations, idx, maybe_index, mint_cap;
  maybe_index = find_delegation$(std$_.signer$_.address_of$(account, $c), $c);
  if (!std$_.option$_.is_some$(maybe_index, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(EDELEGATION_NOT_FOUND);
  }
  idx = $.copy(std$_.option$_.borrow$(maybe_index, $c, [AtomicTypeTag.U64] as TypeTag[]));
  delegations = $c.borrow_global_mut<Delegations>(new StructTag(new HexString("0x1"), "test_coin", "Delegations", []), new HexString("0xa550c18")).inner;
  std$_.vector$_.swap_remove$(delegations, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]);
  mint_cap = $.copy($c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "test_coin", "Capabilities", []), new HexString("0xa550c18")).mint_cap);
  $c.move_to(new StructTag(new HexString("0x1"), "test_coin", "Capabilities", []), account, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "test_coin", "Capabilities", [])));
  return;
}


export function buildPayload_claim_mint_capability (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::test_coin::claim_mint_capability",
    typeParamStrings,
    []
  );

}
export function delegate_mint_capability$ (
  account: HexString,
  to: HexString,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, delegations, element, i;
  system_addresses$_.assert_core_resource$(account, $c);
  delegations = $c.borrow_global_mut<Delegations>(new StructTag(new HexString("0x1"), "test_coin", "Delegations", []), new HexString("0xa550c18")).inner;
  i = u64("0");
  while ($.copy(i).lt(std$_.vector$_.length$(delegations, $c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]))) {
    {
      [temp$1, temp$2] = [delegations, $.copy(i)];
      element = std$_.vector$_.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]);
      if (!($.copy(element.to).hex() !== $.copy(to).hex())) {
        throw $.abortCode(std$_.errors$_.invalid_argument$(EALREADY_DELEGATED, $c));
      }
      i = $.copy(i).add(u64("1"));
    }

  }std$_.vector$_.push_back$(delegations, new DelegatedMintCapability({ to: $.copy(to) }, new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])), $c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]);
  return;
}


export function buildPayload_delegate_mint_capability (
  to: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::test_coin::delegate_mint_capability",
    typeParamStrings,
    [
      $.payloadArg(to),
    ]
  );

}
export function find_delegation$ (
  addr: HexString,
  $c: AptosDataCache,
): std$_.option$_.Option {
  let delegations, element, i, index, len;
  delegations = $c.borrow_global<Delegations>(new StructTag(new HexString("0x1"), "test_coin", "Delegations", []), new HexString("0xa550c18")).inner;
  i = u64("0");
  len = std$_.vector$_.length$(delegations, $c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]);
  index = std$_.option$_.none$($c, [AtomicTypeTag.U64] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      element = std$_.vector$_.borrow$(delegations, $.copy(i), $c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]);
      if (($.copy(element.to).hex() === $.copy(addr).hex())) {
        index = std$_.option$_.some$($.copy(i), $c, [AtomicTypeTag.U64] as TypeTag[]);
        break;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }return $.copy(index);
}

export function initialize$ (
  aptos_framework: HexString,
  core_resource: HexString,
  $c: AptosDataCache,
): [coin$_.MintCapability, coin$_.BurnCapability] {
  let burn_cap, coins, mint_cap;
  system_addresses$_.assert_aptos_framework$(aptos_framework, $c);
  [mint_cap, burn_cap] = coin$_.initialize$(aptos_framework, std$_.string$_.utf8$([u8("84"), u8("101"), u8("115"), u8("116"), u8("32"), u8("67"), u8("111"), u8("105"), u8("110")], $c), std$_.string$_.utf8$([u8("84"), u8("67")], $c), u64("6"), false, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x1"), "test_coin", "Capabilities", []), aptos_framework, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "test_coin", "Capabilities", [])));
  coin$_.register_internal$(core_resource, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  coins = coin$_.mint$(u64("18446744073709551615"), mint_cap, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  coin$_.deposit$(std$_.signer$_.address_of$(core_resource, $c), coins, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x1"), "test_coin", "Capabilities", []), core_resource, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "test_coin", "Capabilities", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "test_coin", "Delegations", []), core_resource, new Delegations({ inner: std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "test_coin", "DelegatedMintCapability", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "test_coin", "Delegations", [])));
  return [$.copy(mint_cap), $.copy(burn_cap)];
}

export function mint$ (
  account: HexString,
  dst_addr: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  let account_addr, capabilities, coins_minted;
  account_addr = std$_.signer$_.address_of$(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "test_coin", "Capabilities", []), $.copy(account_addr))) {
    throw $.abortCode(std$_.errors$_.not_published$(ENO_CAPABILITIES, $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "test_coin", "Capabilities", []), $.copy(account_addr));
  coins_minted = coin$_.mint$($.copy(amount), capabilities.mint_cap, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  coin$_.deposit$($.copy(dst_addr), coins_minted, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  return;
}


export function buildPayload_mint (
  dst_addr: HexString,
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::test_coin::mint",
    typeParamStrings,
    [
      $.payloadArg(dst_addr),
      $.payloadArg(amount),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::test_coin::Capabilities", Capabilities.CapabilitiesParser);
  repo.addParser("0x1::test_coin::DelegatedMintCapability", DelegatedMintCapability.DelegatedMintCapabilityParser);
  repo.addParser("0x1::test_coin::Delegations", Delegations.DelegationsParser);
  repo.addParser("0x1::test_coin::TestCoin", TestCoin.TestCoinParser);
}

