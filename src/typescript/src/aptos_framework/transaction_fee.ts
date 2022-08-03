import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Coin from "./coin";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "transaction_fee";



export class AptosCoinCapabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "AptosCoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "burn_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]) }];

  burn_cap: Coin.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.burn_cap = proto['burn_cap'] as Coin.BurnCapability;
  }

  static AptosCoinCapabilitiesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : AptosCoinCapabilities {
    const proto = $.parseStructProto(data, typeTag, repo, AptosCoinCapabilities);
    return new AptosCoinCapabilities(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, AptosCoinCapabilities, typeParams);
    return result as unknown as AptosCoinCapabilities;
  }
}
export function burn_fee_ (
  account: HexString,
  fee: U64,
  $c: AptosDataCache,
): void {
  Coin.burn_from_($.copy(account), $.copy(fee), $c.borrow_global<AptosCoinCapabilities>(new StructTag(new HexString("0x1"), "transaction_fee", "AptosCoinCapabilities", []), new HexString("0x1")).burn_cap, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  return;
}

export function store_aptos_coin_burn_cap_ (
  account: HexString,
  burn_cap: Coin.BurnCapability,
  $c: AptosDataCache,
): void {
  System_addresses.assert_aptos_framework_(account, $c);
  return $c.move_to(new StructTag(new HexString("0x1"), "transaction_fee", "AptosCoinCapabilities", []), account, new AptosCoinCapabilities({ burn_cap: $.copy(burn_cap) }, new StructTag(new HexString("0x1"), "transaction_fee", "AptosCoinCapabilities", [])));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::transaction_fee::AptosCoinCapabilities", AptosCoinCapabilities.AptosCoinCapabilitiesParser);
}

