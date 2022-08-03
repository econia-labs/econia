import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Error from "./error";
import * as Vector from "./vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "acl";

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
export function add_ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2;
  [temp$1, temp$2] = [acl.list, addr];
  if (!!Vector.contains_(temp$1, temp$2, $c, [AtomicTypeTag.Address])) {
    throw $.abortCode(Error.invalid_argument_(ECONTAIN, $c));
  }
  Vector.push_back_(acl.list, $.copy(addr), $c, [AtomicTypeTag.Address]);
  return;
}

export function assert_contains_ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): void {
  if (!contains_(acl, $.copy(addr), $c)) {
    throw $.abortCode(Error.invalid_argument_(ENOT_CONTAIN, $c));
  }
  return;
}

export function contains_ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): boolean {
  return Vector.contains_(acl.list, addr, $c, [AtomicTypeTag.Address]);
}

export function empty_ (
  $c: AptosDataCache,
): ACL {
  return new ACL({ list: Vector.empty_($c, [AtomicTypeTag.Address]) }, new StructTag(new HexString("0x1"), "acl", "ACL", []));
}

export function remove_ (
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, found, index;
  [temp$1, temp$2] = [acl.list, addr];
  [found, index] = Vector.index_of_(temp$1, temp$2, $c, [AtomicTypeTag.Address]);
  if (!found) {
    throw $.abortCode(Error.invalid_argument_(ENOT_CONTAIN, $c));
  }
  Vector.remove_(acl.list, $.copy(index), $c, [AtomicTypeTag.Address]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::acl::ACL", ACL.ACLParser);
}

