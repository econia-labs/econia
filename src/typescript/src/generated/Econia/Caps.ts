import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Book from "./Book";
import * as Orders from "./Orders";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
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
  { name: "b", typeTag: new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Book", "FriendCap", []) },
  { name: "o", typeTag: new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Orders", "FriendCap", []) }];

  b: Book.FriendCap;
  o: Orders.FriendCap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.b = proto['b'] as Book.FriendCap;
    this.o = proto['o'] as Orders.FriendCap;
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
): Book.FriendCap {
  if (!has_f_c$($c)) {
    throw $.abortCode(E_NO_FC);
  }
  return $.copy($c.borrow_global<FC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Caps", "FC", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659")).b);
}

export function has_f_c$ (
  $c: AptosDataCache,
): boolean {
  return $c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Caps", "FC", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"));
}

export function init_caps$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let addr;
  addr = Std.Signer.address_of$(account, $c);
  if (!($.copy(addr).hex() === new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  if (!!$c.exists(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Caps", "FC", []), $.copy(addr))) {
    throw $.abortCode(E_FC_EXISTS);
  }
  $c.move_to(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Caps", "FC", []), account, new FC({ b: Book.get_friend_cap$(account, $c), o: Orders.get_friend_cap$(account, $c) }, new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Caps", "FC", [])));
  return;
}

export function orders_f_c$ (
  $c: AptosDataCache,
): Orders.FriendCap {
  if (!has_f_c$($c)) {
    throw $.abortCode(E_NO_FC);
  }
  return $.copy($c.borrow_global<FC>(new StructTag(new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659"), "Caps", "FC", []), new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659")).o);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Caps::FC", FC.FCParser);
}

