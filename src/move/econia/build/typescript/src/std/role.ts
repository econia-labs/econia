import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as error$_ from "./error";
import * as signer$_ from "./signer";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "role";

export const EROLE : U64 = u64("0");


export class Role 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Role";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Type", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static RoleParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Role {
    const proto = $.parseStructProto(data, typeTag, repo, Role);
    return new Role(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Role, typeParams);
    return result as unknown as Role;
  }
}
export function assert_has_role$ (
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Type>*/
): void {
  if (!has_role$(signer$_.address_of$(account, $c), $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.not_found$(EROLE, $c));
  }
  return;
}

export function assign_role$ (
  to: HexString,
  _witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Type>*/
): void {
  if (!!has_role$(signer$_.address_of$(to, $c), $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.already_exists$(EROLE, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "role", "Role", [$p[0]]), to, new Role({  }, new StructTag(new HexString("0x1"), "role", "Role", [$p[0]])));
  return;
}

export function has_role$ (
  addr: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Type>*/
): boolean {
  return $c.exists(new StructTag(new HexString("0x1"), "role", "Role", [$p[0]]), $.copy(addr));
}

export function revoke_role$ (
  from: HexString,
  _witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Type>*/
): void {
  if (!has_role$(signer$_.address_of$(from, $c), $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.not_found$(EROLE, $c));
  }
  $c.move_from<Role>(new StructTag(new HexString("0x1"), "role", "Role", [$p[0]]), signer$_.address_of$(from, $c));
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::role::Role", Role.RoleParser);
}

