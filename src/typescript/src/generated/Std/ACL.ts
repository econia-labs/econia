import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Errors from "./Errors";
import * as Vector from "./Vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "ACL";

export const ECONTAIN : U64 = u64("0");
export const ENOT_CONTAIN : U64 = u64("1");


export class ACL 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ACL";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "list", typeTag: new VectorTag(AtomicTypeTag.Address) }];

  list: HexString[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.list = proto['list'] as HexString[];
  }

  static ACLParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ACL {
    const proto = $.parseStructProto(data, typeTag, repo, ACL);
    return new ACL(proto, typeTag);
  }

}
export function add$ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2;
  [temp$1, temp$2] = [acl.list, addr];
  if (!!Vector.contains$(temp$1, temp$2, $c, [AtomicTypeTag.Address] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(ECONTAIN, $c));
  }
  Vector.push_back$(acl.list, $.copy(addr), $c, [AtomicTypeTag.Address] as TypeTag[]);
  return;
}

export function assert_contains$ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): void {
  if (!contains$(acl, $.copy(addr), $c)) {
    throw $.abortCode(Errors.invalid_argument$(ENOT_CONTAIN, $c));
  }
  return;
}

export function contains$ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): boolean {
  return Vector.contains$(acl.list, addr, $c, [AtomicTypeTag.Address] as TypeTag[]);
}

export function empty$ (
  $c: AptosDataCache,
): ACL {
  return new ACL({ list: Vector.empty$($c, [AtomicTypeTag.Address] as TypeTag[]) }, new StructTag(new HexString("0x1"), "ACL", "ACL", []));
}

export function remove$ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, found, index;
  [temp$1, temp$2] = [acl.list, addr];
  [found, index] = Vector.index_of$(temp$1, temp$2, $c, [AtomicTypeTag.Address] as TypeTag[]);
  if (!found) {
    throw $.abortCode(Errors.invalid_argument$(ENOT_CONTAIN, $c));
  }
  Vector.remove$(acl.list, $.copy(index), $c, [AtomicTypeTag.Address] as TypeTag[]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::ACL::ACL", ACL.ACLParser);
}

