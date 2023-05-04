import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import {
  type FieldDeclType,
  type TypeParamDeclType,
} from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";

import * as Bcs from "./bcs";
import type * as Guid from "./guid";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "event";

export class EventHandle {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "EventHandle";
  static typeParameters: TypeParamDeclType[] = [{ name: "T", isPhantom: true }];
  static fields: FieldDeclType[] = [
    { name: "counter", typeTag: AtomicTypeTag.U64 },
    {
      name: "guid",
      typeTag: new StructTag(new HexString("0x1"), "guid", "GUID", []),
    },
  ];

  counter: U64;
  guid: Guid.GUID;

  constructor(proto: any, public typeTag: TypeTag) {
    this.counter = proto["counter"] as U64;
    this.guid = proto["guid"] as Guid.GUID;
  }

  static EventHandleParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): EventHandle {
    const proto = $.parseStructProto(data, typeTag, repo, EventHandle);
    return new EventHandle(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "EventHandle", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.guid.loadFullState(app);
    this.__app = app;
  }
}
export function counter_(
  handle_ref: EventHandle,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): U64 {
  return $.copy(handle_ref.counter);
}

export function destroy_handle_(
  handle: EventHandle,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): void {
  handle;
  return;
}

export function emit_event_(
  handle_ref: EventHandle,
  msg: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): void {
  write_to_event_store_(
    Bcs.to_bytes_(handle_ref.guid, $c, [
      new StructTag(new HexString("0x1"), "guid", "GUID", []),
    ]),
    $.copy(handle_ref.counter),
    msg,
    $c,
    [$p[0]]
  );
  handle_ref.counter = $.copy(handle_ref.counter).add(u64("1"));
  return;
}

export function guid_(
  handle_ref: EventHandle,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): Guid.GUID {
  return handle_ref.guid;
}

export function new_event_handle_(
  guid: Guid.GUID,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): EventHandle {
  return new EventHandle(
    { counter: u64("0"), guid: guid },
    new SimpleStructTag(EventHandle, [$p[0]])
  );
}

export function write_to_event_store_(
  guid: U8[],
  count: U64,
  msg: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): void {
  return $.aptos_framework_event_write_to_event_store(guid, count, msg, $c, [
    $p[0],
  ]);
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::event::EventHandle", EventHandle.EventHandleParser);
}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {}
  get moduleAddress() {
    {
      return moduleAddress;
    }
  }
  get moduleName() {
    {
      return moduleName;
    }
  }
  get EventHandle() {
    return EventHandle;
  }
}
