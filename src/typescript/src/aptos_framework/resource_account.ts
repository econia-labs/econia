import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
import * as Account from "./account";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "resource_account";

export const ECONTAINER_NOT_PUBLISHED : U64 = u64("0");


export class Container 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Container";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "store", typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "account", "SignerCapability", [])]) }];

  store: Aptos_std.Simple_map.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.store = proto['store'] as Aptos_std.Simple_map.SimpleMap;
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
export function create_resource_account_ (
  origin: HexString,
  seed: U8[],
  optional_auth_key: U8[],
  $c: AptosDataCache,
): void {
  let temp$1, auth_key, container, origin_addr, resource, resource_addr, resource_signer_cap;
  [resource, resource_signer_cap] = Account.create_resource_account_(origin, $.copy(seed), $c);
  origin_addr = Std.Signer.address_of_(origin, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "resource_account", "Container", []), $.copy(origin_addr))) {
    $c.move_to(new StructTag(new HexString("0x1"), "resource_account", "Container", []), origin, new Container({ store: Aptos_std.Simple_map.create_($c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "account", "SignerCapability", [])]) }, new StructTag(new HexString("0x1"), "resource_account", "Container", [])));
  }
  else{
  }
  container = $c.borrow_global_mut<Container>(new StructTag(new HexString("0x1"), "resource_account", "Container", []), $.copy(origin_addr));
  resource_addr = Std.Signer.address_of_(resource, $c);
  Aptos_std.Simple_map.add_(container.store, $.copy(resource_addr), resource_signer_cap, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "account", "SignerCapability", [])]);
  if (Std.Vector.is_empty_(optional_auth_key, $c, [AtomicTypeTag.U8])) {
    temp$1 = Account.get_authentication_key_($.copy(origin_addr), $c);
  }
  else{
    temp$1 = $.copy(optional_auth_key);
  }
  auth_key = temp$1;
  Account.rotate_authentication_key_internal_(resource, $.copy(auth_key), $c);
  return;
}


export function buildPayload_create_resource_account (
  seed: U8[],
  optional_auth_key: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::resource_account::create_resource_account",
    typeParamStrings,
    [
      $.u8ArrayArg(seed),
      $.u8ArrayArg(optional_auth_key),
    ]
  );

}
export function retrieve_resource_account_cap_ (
  resource: HexString,
  source_addr: HexString,
  $c: AptosDataCache,
): Account.SignerCapability {
  let _resource_addr, container, container__1, empty_container, resource__2, resource_addr, resource_signer_cap, signer_cap, zero_auth_key;
  if (!$c.exists(new StructTag(new HexString("0x1"), "resource_account", "Container", []), $.copy(source_addr))) {
    throw $.abortCode(Std.Error.not_found_(ECONTAINER_NOT_PUBLISHED, $c));
  }
  resource_addr = Std.Signer.address_of_(resource, $c);
  container = $c.borrow_global_mut<Container>(new StructTag(new HexString("0x1"), "resource_account", "Container", []), $.copy(source_addr));
  [_resource_addr, signer_cap] = Aptos_std.Simple_map.remove_(container.store, resource_addr, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "account", "SignerCapability", [])]);
  [resource_signer_cap, empty_container] = [signer_cap, (Aptos_std.Simple_map.length_(container.store, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "account", "SignerCapability", [])])).eq((u64("0")))];
  if (empty_container) {
    container__1 = $c.move_from<Container>(new StructTag(new HexString("0x1"), "resource_account", "Container", []), $.copy(source_addr));
    let { store: store } = container__1;
    Aptos_std.Simple_map.destroy_empty_(store, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "account", "SignerCapability", [])]);
  }
  else{
  }
  zero_auth_key = [u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0"), u8("0")];
  resource__2 = Account.create_signer_with_capability_(resource_signer_cap, $c);
  Account.rotate_authentication_key_internal_(resource__2, $.copy(zero_auth_key), $c);
  return resource_signer_cap;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::resource_account::Container", Container.ContainerParser);
}

