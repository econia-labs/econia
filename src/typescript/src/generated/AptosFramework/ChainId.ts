import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as SystemAddresses from "./SystemAddresses";
import * as Timestamp from "./Timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "ChainId";

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
export function get$ (
  $c: AptosDataCache,
): U8 {
  Timestamp.assert_operating$($c);
  return $.copy($c.borrow_global<ChainId>(new StructTag(new HexString("0x1"), "ChainId", "ChainId", []), new HexString("0xa550c18")).id);
}

export function initialize$ (
  account: HexString,
  id: U8,
  $c: AptosDataCache,
): void {
  Timestamp.assert_genesis$($c);
  SystemAddresses.assert_core_resource$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "ChainId", "ChainId", []), Std.Signer.address_of$(account, $c))) {
    throw $.abortCode(Std.Errors.already_published$(ECHAIN_ID, $c));
  }
  return $c.move_to(new StructTag(new HexString("0x1"), "ChainId", "ChainId", []), account, new ChainId({ id: $.copy(id) }, new StructTag(new HexString("0x1"), "ChainId", "ChainId", [])));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::ChainId::ChainId", ChainId.ChainIdParser);
}

