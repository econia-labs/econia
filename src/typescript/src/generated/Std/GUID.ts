import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Signer from "./Signer";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "GUID";

export const EGUID_GENERATOR_NOT_PUBLISHED : U64 = u64("0");


export class CreateCapability 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CreateCapability";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "addr", typeTag: AtomicTypeTag.Address }];

  addr: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.addr = proto['addr'] as HexString;
  }

  static CreateCapabilityParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CreateCapability {
    const proto = $.parseStructProto(data, typeTag, repo, CreateCapability);
    return new CreateCapability(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, CreateCapability, typeParams);
    return result as unknown as CreateCapability;
  }
}

export class GUID 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GUID";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "id", typeTag: new StructTag(new HexString("0x1"), "GUID", "ID", []) }];

  id: ID;

  constructor(proto: any, public typeTag: TypeTag) {
    this.id = proto['id'] as ID;
  }

  static GUIDParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GUID {
    const proto = $.parseStructProto(data, typeTag, repo, GUID);
    return new GUID(proto, typeTag);
  }

}

export class Generator 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Generator";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "counter", typeTag: AtomicTypeTag.U64 }];

  counter: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.counter = proto['counter'] as U64;
  }

  static GeneratorParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Generator {
    const proto = $.parseStructProto(data, typeTag, repo, Generator);
    return new Generator(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Generator, typeParams);
    return result as unknown as Generator;
  }
}

export class ID 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ID";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "creation_num", typeTag: AtomicTypeTag.U64 },
  { name: "addr", typeTag: AtomicTypeTag.Address }];

  creation_num: U64;
  addr: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.creation_num = proto['creation_num'] as U64;
    this.addr = proto['addr'] as HexString;
  }

  static IDParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ID {
    const proto = $.parseStructProto(data, typeTag, repo, ID);
    return new ID(proto, typeTag);
  }

}
export function create$ (
  account: HexString,
  $c: AptosDataCache,
): GUID {
  let addr;
  addr = Signer.address_of$(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "GUID", "Generator", []), $.copy(addr))) {
    $c.move_to(new StructTag(new HexString("0x1"), "GUID", "Generator", []), account, new Generator({ counter: u64("0") }, new StructTag(new HexString("0x1"), "GUID", "Generator", [])));
  }
  else{
  }
  return create_impl$($.copy(addr), $c);
}

export function create_id$ (
  addr: HexString,
  creation_num: U64,
  $c: AptosDataCache,
): ID {
  return new ID({ creation_num: $.copy(creation_num), addr: $.copy(addr) }, new StructTag(new HexString("0x1"), "GUID", "ID", []));
}

export function create_impl$ (
  addr: HexString,
  $c: AptosDataCache,
): GUID {
  let creation_num, generator;
  generator = $c.borrow_global_mut<Generator>(new StructTag(new HexString("0x1"), "GUID", "Generator", []), $.copy(addr));
  creation_num = $.copy(generator.counter);
  generator.counter = $.copy(creation_num).add(u64("1"));
  return new GUID({ id: new ID({ creation_num: $.copy(creation_num), addr: $.copy(addr) }, new StructTag(new HexString("0x1"), "GUID", "ID", [])) }, new StructTag(new HexString("0x1"), "GUID", "GUID", []));
}

export function create_with_capability$ (
  addr: HexString,
  _cap: CreateCapability,
  $c: AptosDataCache,
): GUID {
  if (!$c.exists(new StructTag(new HexString("0x1"), "GUID", "Generator", []), $.copy(addr))) {
    throw $.abortCode(EGUID_GENERATOR_NOT_PUBLISHED);
  }
  return create_impl$($.copy(addr), $c);
}

export function creation_num$ (
  guid: GUID,
  $c: AptosDataCache,
): U64 {
  return $.copy(guid.id.creation_num);
}

export function creator_address$ (
  guid: GUID,
  $c: AptosDataCache,
): HexString {
  return $.copy(guid.id.addr);
}

export function eq_id$ (
  guid: GUID,
  id: ID,
  $c: AptosDataCache,
): boolean {
  return $.deep_eq(guid.id, id);
}

export function gen_create_capability$ (
  account: HexString,
  $c: AptosDataCache,
): CreateCapability {
  let addr;
  addr = Signer.address_of$(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "GUID", "Generator", []), $.copy(addr))) {
    $c.move_to(new StructTag(new HexString("0x1"), "GUID", "Generator", []), account, new Generator({ counter: u64("0") }, new StructTag(new HexString("0x1"), "GUID", "Generator", [])));
  }
  else{
  }
  return new CreateCapability({ addr: $.copy(addr) }, new StructTag(new HexString("0x1"), "GUID", "CreateCapability", []));
}

export function get_next_creation_num$ (
  addr: HexString,
  $c: AptosDataCache,
): U64 {
  let temp$1;
  if (!$c.exists(new StructTag(new HexString("0x1"), "GUID", "Generator", []), $.copy(addr))) {
    temp$1 = u64("0");
  }
  else{
    temp$1 = $.copy($c.borrow_global<Generator>(new StructTag(new HexString("0x1"), "GUID", "Generator", []), $.copy(addr)).counter);
  }
  return temp$1;
}

export function id$ (
  guid: GUID,
  $c: AptosDataCache,
): ID {
  return $.copy(guid.id);
}

export function id_creation_num$ (
  id: ID,
  $c: AptosDataCache,
): U64 {
  return $.copy(id.creation_num);
}

export function id_creator_address$ (
  id: ID,
  $c: AptosDataCache,
): HexString {
  return $.copy(id.addr);
}

export function publish_generator$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  return $c.move_to(new StructTag(new HexString("0x1"), "GUID", "Generator", []), account, new Generator({ counter: u64("0") }, new StructTag(new HexString("0x1"), "GUID", "Generator", [])));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::GUID::CreateCapability", CreateCapability.CreateCapabilityParser);
  repo.addParser("0x1::GUID::GUID", GUID.GUIDParser);
  repo.addParser("0x1::GUID::Generator", Generator.GeneratorParser);
  repo.addParser("0x1::GUID::ID", ID.IDParser);
}

