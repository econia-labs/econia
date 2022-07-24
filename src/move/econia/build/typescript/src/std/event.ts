import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as bcs$_ from "./bcs";
import * as guid$_ from "./guid";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "event";



export class EventHandle 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "EventHandle";
  static typeParameters: TypeParamDeclType[] = [
    { name: "T", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "counter", typeTag: AtomicTypeTag.U64 },
  { name: "guid", typeTag: new StructTag(new HexString("0x1"), "guid", "GUID", []) }];

  counter: U64;
  guid: guid$_.GUID;

  constructor(proto: any, public typeTag: TypeTag) {
    this.counter = proto['counter'] as U64;
    this.guid = proto['guid'] as guid$_.GUID;
  }

  static EventHandleParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : EventHandle {
    const proto = $.parseStructProto(data, typeTag, repo, EventHandle);
    return new EventHandle(proto, typeTag);
  }

}

export class EventHandleGenerator 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "EventHandleGenerator";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "counter", typeTag: AtomicTypeTag.U64 },
  { name: "addr", typeTag: AtomicTypeTag.Address }];

  counter: U64;
  addr: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.counter = proto['counter'] as U64;
    this.addr = proto['addr'] as HexString;
  }

  static EventHandleGeneratorParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : EventHandleGenerator {
    const proto = $.parseStructProto(data, typeTag, repo, EventHandleGenerator);
    return new EventHandleGenerator(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, EventHandleGenerator, typeParams);
    return result as unknown as EventHandleGenerator;
  }
}
export function destroy_handle$ (
  handle: EventHandle,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  handle;
  return;
}

export function emit_event$ (
  handle_ref: EventHandle,
  msg: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  write_to_event_store$(bcs$_.to_bytes$(handle_ref.guid, $c, [new StructTag(new HexString("0x1"), "guid", "GUID", [])] as TypeTag[]), $.copy(handle_ref.counter), msg, $c, [$p[0]] as TypeTag[]);
  handle_ref.counter = $.copy(handle_ref.counter).add(u64("1"));
  return;
}

export function guid$ (
  handle_ref: EventHandle,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): guid$_.GUID {
  return handle_ref.guid;
}

export function new_event_handle$ (
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): EventHandle {
  return new EventHandle({ counter: u64("0"), guid: guid$_.create$(account, $c) }, new StructTag(new HexString("0x1"), "event", "EventHandle", [$p[0]]));
}

export function write_to_event_store$ (
  guid: U8[],
  count: U64,
  msg: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  return $.std_event_write_to_event_store(guid, count, msg, $c, [$p[0]]);

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::event::EventHandle", EventHandle.EventHandleParser);
  repo.addParser("0x1::event::EventHandleGenerator", EventHandleGenerator.EventHandleGeneratorParser);
}

