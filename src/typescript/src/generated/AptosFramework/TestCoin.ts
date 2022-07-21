import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Coin from "./Coin";
import * as SystemAddresses from "./SystemAddresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "TestCoin";

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
  { name: "mint_cap", typeTag: new StructTag(new HexString("0x1"), "Coin", "MintCapability", [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])]) }];

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
  { name: "inner", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])) }];

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
  maybe_index = find_delegation$(Std.Signer.address_of$(account, $c), $c);
  if (!Std.Option.is_some$(maybe_index, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(EDELEGATION_NOT_FOUND);
  }
  idx = $.copy(Std.Option.borrow$(maybe_index, $c, [AtomicTypeTag.U64] as TypeTag[]));
  delegations = $c.borrow_global_mut<Delegations>(new StructTag(new HexString("0x1"), "TestCoin", "Delegations", []), new HexString("0xa550c18")).inner;
  Std.Vector.swap_remove$(delegations, $.copy(idx), $c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]);
  mint_cap = $.copy($c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", []), new HexString("0x1")).mint_cap);
  $c.move_to(new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", []), account, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", [])));
  return;
}


export function buildPayload_claim_mint_capability (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::TestCoin::claim_mint_capability",
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
  SystemAddresses.assert_core_resource$(account, $c);
  delegations = $c.borrow_global_mut<Delegations>(new StructTag(new HexString("0x1"), "TestCoin", "Delegations", []), new HexString("0xa550c18")).inner;
  i = u64("0");
  while ($.copy(i).lt(Std.Vector.length$(delegations, $c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]))) {
    {
      [temp$1, temp$2] = [delegations, $.copy(i)];
      element = Std.Vector.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]);
      if (!($.copy(element.to).hex() !== $.copy(to).hex())) {
        throw $.abortCode(Std.Errors.invalid_argument$(EALREADY_DELEGATED, $c));
      }
      i = $.copy(i).add(u64("1"));
    }

  }Std.Vector.push_back$(delegations, new DelegatedMintCapability({ to: $.copy(to) }, new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])), $c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]);
  return;
}


export function buildPayload_delegate_mint_capability (
  to: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::TestCoin::delegate_mint_capability",
    typeParamStrings,
    [
      $.payloadArg(to),
    ]
  );

}
export function find_delegation$ (
  addr: HexString,
  $c: AptosDataCache,
): Std.Option.Option {
  let delegations, element, i, index, len;
  delegations = $c.borrow_global<Delegations>(new StructTag(new HexString("0x1"), "TestCoin", "Delegations", []), new HexString("0xa550c18")).inner;
  i = u64("0");
  len = Std.Vector.length$(delegations, $c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]);
  index = Std.Option.none$($c, [AtomicTypeTag.U64] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      element = Std.Vector.borrow$(delegations, $.copy(i), $c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]);
      if (($.copy(element.to).hex() === $.copy(addr).hex())) {
        index = Std.Option.some$($.copy(i), $c, [AtomicTypeTag.U64] as TypeTag[]);
        break;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }return $.copy(index);
}

export function initialize$ (
  core_framework: HexString,
  core_resource: HexString,
  $c: AptosDataCache,
): [Coin.MintCapability, Coin.BurnCapability] {
  let burn_cap, coins, mint_cap;
  SystemAddresses.assert_core_resource$(core_resource, $c);
  [mint_cap, burn_cap] = Coin.initialize$(core_framework, Std.ASCII.string$([u8("84"), u8("101"), u8("115"), u8("116"), u8("32"), u8("67"), u8("111"), u8("105"), u8("110")], $c), Std.ASCII.string$([u8("84"), u8("67")], $c), u64("6"), false, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  Coin.register_internal$(core_resource, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  coins = Coin.mint$(u64("18446744073709551615"), mint_cap, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  Coin.deposit$(Std.Signer.address_of$(core_resource, $c), coins, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", []), core_framework, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", []), core_resource, new Capabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "TestCoin", "Delegations", []), core_resource, new Delegations({ inner: Std.Vector.empty$($c, [new StructTag(new HexString("0x1"), "TestCoin", "DelegatedMintCapability", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "TestCoin", "Delegations", [])));
  return [$.copy(mint_cap), $.copy(burn_cap)];
}

export function mint$ (
  account: HexString,
  dst_addr: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  let account_addr, capabilities, coins_minted;
  account_addr = Std.Signer.address_of$(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", []), $.copy(account_addr))) {
    throw $.abortCode(Std.Errors.not_published$(ENO_CAPABILITIES, $c));
  }
  capabilities = $c.borrow_global<Capabilities>(new StructTag(new HexString("0x1"), "TestCoin", "Capabilities", []), $.copy(account_addr));
  coins_minted = Coin.mint$($.copy(amount), capabilities.mint_cap, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  Coin.deposit$($.copy(dst_addr), coins_minted, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  return;
}


export function buildPayload_mint (
  dst_addr: HexString,
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::TestCoin::mint",
    typeParamStrings,
    [
      $.payloadArg(dst_addr),
      $.payloadArg(amount),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::TestCoin::Capabilities", Capabilities.CapabilitiesParser);
  repo.addParser("0x1::TestCoin::DelegatedMintCapability", DelegatedMintCapability.DelegatedMintCapabilityParser);
  repo.addParser("0x1::TestCoin::Delegations", Delegations.DelegationsParser);
  repo.addParser("0x1::TestCoin::TestCoin", TestCoin.TestCoinParser);
}

