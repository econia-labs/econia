import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
export const packageName = "Econia";
export const moduleAddress = new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9");
export const moduleName = "Version";

export const E_MC_EXISTS : U64 = u64("1");
export const E_NOT_ECONIA : U64 = u64("0");


export class MC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "MC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "i", typeTag: AtomicTypeTag.U64 }];

  i: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.i = proto['i'] as U64;
  }

  static MCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : MC {
    const proto = $.parseStructProto(data, typeTag, repo, MC);
    return new MC(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, MC, typeParams);
    return result as unknown as MC;
  }
}
export function get_updated_mock_version_number$ (
  $c: AptosDataCache,
): U64 {
  let v_n;
  v_n = $c.borrow_global_mut<MC>(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Version", "MC", []), new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9")).i;
  $.set(v_n, $.copy(v_n).add(u64("1")));
  return $.copy(v_n);
}

export function get_v_n$ (
  $c: AptosDataCache,
): U64 {
  return get_updated_mock_version_number$($c);
}

export function init_mock_version_number$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let addr;
  addr = std$_.signer$_.address_of$(account, $c);
  if (!($.copy(addr).hex() === new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Version", "MC", []), $.copy(addr))) {
    throw $.abortCode(E_MC_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Version", "MC", []), account, new MC({ i: u64("0") }, new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Version", "MC", [])));
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Version::MC", MC.MCParser);
}

