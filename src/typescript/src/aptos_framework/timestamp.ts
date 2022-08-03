import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "timestamp";

export const ENOT_GENESIS : U64 = u64("0");
export const ENOT_OPERATING : U64 = u64("1");
export const ETIMESTAMP : U64 = u64("2");
export const MICRO_CONVERSION_FACTOR : U64 = u64("1000000");


export class CurrentTimeMicroseconds 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CurrentTimeMicroseconds";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "microseconds", typeTag: AtomicTypeTag.U64 }];

  microseconds: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.microseconds = proto['microseconds'] as U64;
  }

  static CurrentTimeMicrosecondsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CurrentTimeMicroseconds {
    const proto = $.parseStructProto(data, typeTag, repo, CurrentTimeMicroseconds);
    return new CurrentTimeMicroseconds(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, CurrentTimeMicroseconds, typeParams);
    return result as unknown as CurrentTimeMicroseconds;
  }
}
export function assert_genesis_ (
  $c: AptosDataCache,
): void {
  if (!is_genesis_($c)) {
    throw $.abortCode(Std.Error.invalid_state_(ENOT_GENESIS, $c));
  }
  return;
}

export function assert_operating_ (
  $c: AptosDataCache,
): void {
  if (!is_operating_($c)) {
    throw $.abortCode(Std.Error.invalid_state_(ENOT_OPERATING, $c));
  }
  return;
}

export function is_genesis_ (
  $c: AptosDataCache,
): boolean {
  return !$c.exists(new StructTag(new HexString("0x1"), "timestamp", "CurrentTimeMicroseconds", []), new HexString("0x1"));
}

export function is_operating_ (
  $c: AptosDataCache,
): boolean {
  return $c.exists(new StructTag(new HexString("0x1"), "timestamp", "CurrentTimeMicroseconds", []), new HexString("0x1"));
}

export function now_microseconds_ (
  $c: AptosDataCache,
): U64 {
  assert_operating_($c);
  return $.copy($c.borrow_global<CurrentTimeMicroseconds>(new StructTag(new HexString("0x1"), "timestamp", "CurrentTimeMicroseconds", []), new HexString("0x1")).microseconds);
}

export function now_seconds_ (
  $c: AptosDataCache,
): U64 {
  return (now_microseconds_($c)).div(MICRO_CONVERSION_FACTOR);
}

export function set_time_has_started_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let timer;
  assert_genesis_($c);
  System_addresses.assert_aptos_framework_(account, $c);
  timer = new CurrentTimeMicroseconds({ microseconds: u64("0") }, new StructTag(new HexString("0x1"), "timestamp", "CurrentTimeMicroseconds", []));
  $c.move_to(new StructTag(new HexString("0x1"), "timestamp", "CurrentTimeMicroseconds", []), account, timer);
  return;
}

export function update_global_time_ (
  account: HexString,
  proposer: HexString,
  timestamp: U64,
  $c: AptosDataCache,
): void {
  let global_timer, now;
  assert_operating_($c);
  System_addresses.assert_vm_(account, $c);
  global_timer = $c.borrow_global_mut<CurrentTimeMicroseconds>(new StructTag(new HexString("0x1"), "timestamp", "CurrentTimeMicroseconds", []), new HexString("0x1"));
  now = $.copy(global_timer.microseconds);
  if ((($.copy(proposer)).hex() === (new HexString("0x0")).hex())) {
    if (!($.copy(now)).eq(($.copy(timestamp)))) {
      throw $.abortCode(Std.Error.invalid_argument_(ETIMESTAMP, $c));
    }
  }
  else{
    if (!($.copy(now)).lt($.copy(timestamp))) {
      throw $.abortCode(Std.Error.invalid_argument_(ETIMESTAMP, $c));
    }
  }
  global_timer.microseconds = $.copy(timestamp);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::timestamp::CurrentTimeMicroseconds", CurrentTimeMicroseconds.CurrentTimeMicrosecondsParser);
}

