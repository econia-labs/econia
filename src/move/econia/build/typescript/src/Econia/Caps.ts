import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as Book$_ from "./Book";
import * as Orders$_ from "./Orders";
export const packageName = "Econia";
export const moduleAddress = new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9");
export const moduleName = "Caps";

export const E_FC_EXISTS : U64 = u64("1");
export const E_NOT_ECONIA : U64 = u64("0");
export const E_NO_FC : U64 = u64("2");


export class FC 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "FC";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "b", typeTag: new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Book", "FriendCap", []) },
  { name: "o", typeTag: new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Orders", "FriendCap", []) }];

  b: Book$_.FriendCap;
  o: Orders$_.FriendCap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.b = proto['b'] as Book$_.FriendCap;
    this.o = proto['o'] as Orders$_.FriendCap;
  }

  static FCParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : FC {
    const proto = $.parseStructProto(data, typeTag, repo, FC);
    return new FC(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, FC, typeParams);
    return result as unknown as FC;
  }
}
export function book_f_c$ (
  $c: AptosDataCache,
): Book$_.FriendCap {
  if (!has_f_c$($c)) {
    throw $.abortCode(E_NO_FC);
  }
  return $.copy($c.borrow_global<FC>(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Caps", "FC", []), new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9")).b);
}

export function has_f_c$ (
  $c: AptosDataCache,
): boolean {
  return $c.exists(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Caps", "FC", []), new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"));
}

export function init_caps$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let addr;
  addr = std$_.signer$_.address_of$(account, $c);
  if (!($.copy(addr).hex() === new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Caps", "FC", []), $.copy(addr))) {
    throw $.abortCode(E_FC_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Caps", "FC", []), account, new FC({ b: Book$_.get_friend_cap$(account, $c), o: Orders$_.get_friend_cap$(account, $c) }, new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Caps", "FC", [])));
  return;
}

export function orders_f_c$ (
  $c: AptosDataCache,
): Orders$_.FriendCap {
  if (!has_f_c$($c)) {
    throw $.abortCode(E_NO_FC);
  }
  return $.copy($c.borrow_global<FC>(new StructTag(new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9"), "Caps", "FC", []), new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9")).o);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Caps::FC", FC.FCParser);
}

