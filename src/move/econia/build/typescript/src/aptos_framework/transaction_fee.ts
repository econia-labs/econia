import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as coin$_ from "./coin";
import * as system_addresses$_ from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "transaction_fee";



export class TestCoinCapabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TestCoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "burn_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) }];

  burn_cap: coin$_.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.burn_cap = proto['burn_cap'] as coin$_.BurnCapability;
  }

  static TestCoinCapabilitiesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TestCoinCapabilities {
    const proto = $.parseStructProto(data, typeTag, repo, TestCoinCapabilities);
    return new TestCoinCapabilities(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, TestCoinCapabilities, typeParams);
    return result as unknown as TestCoinCapabilities;
  }
}
export function burn_fee$ (
  account: HexString,
  fee: U64,
  $c: AptosDataCache,
): void {
  coin$_.burn_from$($.copy(account), $.copy(fee), $c.borrow_global<TestCoinCapabilities>(new StructTag(new HexString("0x1"), "transaction_fee", "TestCoinCapabilities", []), new HexString("0x1")).burn_cap, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  return;
}

export function store_test_coin_burn_cap$ (
  account: HexString,
  burn_cap: coin$_.BurnCapability,
  $c: AptosDataCache,
): void {
  system_addresses$_.assert_aptos_framework$(account, $c);
  return $c.move_to(new StructTag(new HexString("0x1"), "transaction_fee", "TestCoinCapabilities", []), account, new TestCoinCapabilities({ burn_cap: $.copy(burn_cap) }, new StructTag(new HexString("0x1"), "transaction_fee", "TestCoinCapabilities", [])));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::transaction_fee::TestCoinCapabilities", TestCoinCapabilities.TestCoinCapabilitiesParser);
}

