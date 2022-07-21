import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as SystemAddresses from "./SystemAddresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Timestamp";

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
export function assert_genesis$ (
  $c: AptosDataCache,
): void {
  if (!is_genesis$($c)) {
    throw $.abortCode(Std.Errors.invalid_state$(ENOT_GENESIS, $c));
  }
  return;
}

export function assert_operating$ (
  $c: AptosDataCache,
): void {
  if (!is_operating$($c)) {
    throw $.abortCode(Std.Errors.invalid_state$(ENOT_OPERATING, $c));
  }
  return;
}

export function is_genesis$ (
  $c: AptosDataCache,
): boolean {
  return !$c.exists(new StructTag(new HexString("0x1"), "Timestamp", "CurrentTimeMicroseconds", []), new HexString("0xa550c18"));
}

export function is_operating$ (
  $c: AptosDataCache,
): boolean {
  return $c.exists(new StructTag(new HexString("0x1"), "Timestamp", "CurrentTimeMicroseconds", []), new HexString("0xa550c18"));
}

export function now_microseconds$ (
  $c: AptosDataCache,
): U64 {
  assert_operating$($c);
  return $.copy($c.borrow_global<CurrentTimeMicroseconds>(new StructTag(new HexString("0x1"), "Timestamp", "CurrentTimeMicroseconds", []), new HexString("0xa550c18")).microseconds);
}

export function now_seconds$ (
  $c: AptosDataCache,
): U64 {
  return now_microseconds$($c).div(MICRO_CONVERSION_FACTOR);
}

export function set_time_has_started$ (
  root_account: HexString,
  $c: AptosDataCache,
): void {
  let timer;
  assert_genesis$($c);
  SystemAddresses.assert_core_resource$(root_account, $c);
  timer = new CurrentTimeMicroseconds({ microseconds: u64("0") }, new StructTag(new HexString("0x1"), "Timestamp", "CurrentTimeMicroseconds", []));
  $c.move_to(new StructTag(new HexString("0x1"), "Timestamp", "CurrentTimeMicroseconds", []), root_account, timer);
  return;
}

export function update_global_time$ (
  account: HexString,
  proposer: HexString,
  timestamp: U64,
  $c: AptosDataCache,
): void {
  let global_timer, now;
  assert_operating$($c);
  SystemAddresses.assert_vm$(account, $c);
  global_timer = $c.borrow_global_mut<CurrentTimeMicroseconds>(new StructTag(new HexString("0x1"), "Timestamp", "CurrentTimeMicroseconds", []), new HexString("0xa550c18"));
  now = $.copy(global_timer.microseconds);
  if (($.copy(proposer).hex() === new HexString("0x0").hex())) {
    if (!$.copy(now).eq($.copy(timestamp))) {
      throw $.abortCode(Std.Errors.invalid_argument$(ETIMESTAMP, $c));
    }
  }
  else{
    if (!$.copy(now).lt($.copy(timestamp))) {
      throw $.abortCode(Std.Errors.invalid_argument$(ETIMESTAMP, $c));
    }
  }
  global_timer.microseconds = $.copy(timestamp);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::Timestamp::CurrentTimeMicroseconds", CurrentTimeMicroseconds.CurrentTimeMicrosecondsParser);
}

