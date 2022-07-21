import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Account from "./Account";
import * as SimpleMap from "./SimpleMap";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "ResourceAccount";

export const ECONTAINER_NOT_PUBLISHED : U64 = u64("0");


export class Container 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Container";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "store", typeTag: new StructTag(new HexString("0x1"), "SimpleMap", "SimpleMap", [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "Account", "SignerCapability", [])]) }];

  store: SimpleMap.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.store = proto['store'] as SimpleMap.SimpleMap;
  }

  static ContainerParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Container {
    const proto = $.parseStructProto(data, typeTag, repo, Container);
    return new Container(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Container, typeParams);
    return result as unknown as Container;
  }
}
export function create_resource_account$ (
  origin: HexString,
  seed: U8[],
  optional_auth_key: U8[],
  $c: AptosDataCache,
): void {
  let temp$1, auth_key, container, origin_addr, resource, resource_addr, resource_signer_cap;
  [resource, resource_signer_cap] = Account.create_resource_account$(origin, $.copy(seed), $c);
  origin_addr = Std.Signer.address_of$(origin, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "ResourceAccount", "Container", []), $.copy(origin_addr))) {
    $c.move_to(new StructTag(new HexString("0x1"), "ResourceAccount", "Container", []), origin, new Container({ store: SimpleMap.create$($c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "Account", "SignerCapability", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "ResourceAccount", "Container", [])));
  }
  else{
  }
  container = $c.borrow_global_mut<Container>(new StructTag(new HexString("0x1"), "ResourceAccount", "Container", []), $.copy(origin_addr));
  resource_addr = Std.Signer.address_of$(resource, $c);
  SimpleMap.add$(container.store, $.copy(resource_addr), resource_signer_cap, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "Account", "SignerCapability", [])] as TypeTag[]);
  if (Std.Vector.is_empty$(optional_auth_key, $c, [AtomicTypeTag.U8] as TypeTag[])) {
    temp$1 = Account.get_authentication_key$($.copy(origin_addr), $c);
  }
  else{
    temp$1 = $.copy(optional_auth_key);
  }
  auth_key = temp$1;
  Account.rotate_authentication_key_internal$(resource, $.copy(auth_key), $c);
  return;
}


export function buildPayload_create_resource_account (
  seed: U8[],
  optional_auth_key: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::ResourceAccount::create_resource_account",
    typeParamStrings,
    [
      $.u8ArrayArg(seed),
      $.u8ArrayArg(optional_auth_key),
    ]
  );

}
export function retrieve_resource_account_cap$ (
  resource: HexString,
  source_addr: HexString,
  $c: AptosDataCache,
): Account.SignerCapability {
  let _resource_addr, container, container__1, empty_container, resource__2, resource_addr, resource_signer_cap, signer_cap, zero_auth_key;
  if (!$c.exists(new StructTag(new HexString("0x1"), "ResourceAccount", "Container", []), $.copy(source_addr))) {
    throw $.abortCode(Std.Errors.not_published$(ECONTAINER_NOT_PUBLISHED, $c));
  }
  resource_addr = Std.Signer.address_of$(resource, $c);
  container = $c.borrow_global_mut<Container>(new StructTag(new HexString("0x1"), "ResourceAccount", "Container", []), $.copy(source_addr));
  [_resource_addr, signer_cap] = SimpleMap.remove$(container.store, resource_addr, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "Account", "SignerCapability", [])] as TypeTag[]);
  [resource_signer_cap, empty_container] = [signer_cap, SimpleMap.length$(container.store, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "Account", "SignerCapability", [])] as TypeTag[]).eq(u64("0"))];
  if (empty_container) {
    container__1 = $c.move_from<Container>(new StructTag(new HexString("0x1"), "ResourceAccount", "Container", []), $.copy(source_addr));
    let { store: store } = container__1;
    SimpleMap.destroy_empty$(store, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "Account", "SignerCapability", [])] as TypeTag[]);
  }
  else{
  }
  zero_auth_key = [u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0")];
  resource__2 = Account.create_signer_with_capability$(resource_signer_cap, $c);
  Account.rotate_authentication_key_internal$(resource__2, $.copy(zero_auth_key), $c);
  return resource_signer_cap;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::ResourceAccount::Container", Container.ContainerParser);
}

