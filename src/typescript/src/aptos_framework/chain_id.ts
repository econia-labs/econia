import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "chain_id";

export const ECHAIN_ID : U64 = u64("0");


export class ChainId 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ChainId";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "id", typeTag: AtomicTypeTag.U8 }];

  id: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.id = proto['id'] as U8;
  }

  static ChainIdParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ChainId {
    const proto = $.parseStructProto(data, typeTag, repo, ChainId);
    return new ChainId(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, ChainId, typeParams);
    return result as unknown as ChainId;
  }
}
export function get_ (
  $c: AptosDataCache,
): U8 {
  Timestamp.assert_operating_($c);
  return $.copy($c.borrow_global<ChainId>(new StructTag(new HexString("0x1"), "chain_id", "ChainId", []), new HexString("0x1")).id);
}

export function initialize_ (
  account: HexString,
  id: U8,
  $c: AptosDataCache,
): void {
  Timestamp.assert_genesis_($c);
  System_addresses.assert_aptos_framework_(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "chain_id", "ChainId", []), Std.Signer.address_of_(account, $c))) {
    throw $.abortCode(Std.Error.already_exists_(ECHAIN_ID, $c));
  }
  return $c.move_to(new StructTag(new HexString("0x1"), "chain_id", "ChainId", []), account, new ChainId({ id: $.copy(id) }, new StructTag(new HexString("0x1"), "chain_id", "ChainId", [])));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::chain_id::ChainId", ChainId.ChainIdParser);
}

