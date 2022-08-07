import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
import * as Stake from "./stake";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "reconfiguration";

export const ECONFIG : U64 = u64("1");
export const ECONFIGURATION : U64 = u64("0");
export const EINVALID_BLOCK_TIME : U64 = u64("3");
export const EINVALID_GUID_FOR_EVENT : U64 = u64("4");
export const EMODIFY_CAPABILITY : U64 = u64("2");
export const MAX_U64 : U64 = u64("18446744073709551615");


export class Configuration 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Configuration";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "epoch", typeTag: AtomicTypeTag.U64 },
  { name: "last_reconfiguration_time", typeTag: AtomicTypeTag.U64 },
  { name: "events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])]) }];

  epoch: U64;
  last_reconfiguration_time: U64;
  events: Aptos_std.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto['epoch'] as U64;
    this.last_reconfiguration_time = proto['last_reconfiguration_time'] as U64;
    this.events = proto['events'] as Aptos_std.Event.EventHandle;
  }

  static ConfigurationParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Configuration {
    const proto = $.parseStructProto(data, typeTag, repo, Configuration);
    return new Configuration(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Configuration, typeParams);
    return result as unknown as Configuration;
  }
}

export class DisableReconfiguration 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "DisableReconfiguration";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  ];

  constructor(proto: any, public typeTag: TypeTag) {

  }

  static DisableReconfigurationParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : DisableReconfiguration {
    const proto = $.parseStructProto(data, typeTag, repo, DisableReconfiguration);
    return new DisableReconfiguration(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, DisableReconfiguration, typeParams);
    return result as unknown as DisableReconfiguration;
  }
}

export class NewEpochEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "NewEpochEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "epoch", typeTag: AtomicTypeTag.U64 }];

  epoch: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto['epoch'] as U64;
  }

  static NewEpochEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : NewEpochEvent {
    const proto = $.parseStructProto(data, typeTag, repo, NewEpochEvent);
    return new NewEpochEvent(proto, typeTag);
  }

}
export function disable_reconfiguration_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  System_addresses.assert_aptos_framework_(account, $c);
  if (!reconfiguration_enabled_($c)) {
    throw $.abortCode(Std.Error.invalid_state_(ECONFIGURATION, $c));
  }
  return $c.move_to(new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", []), account, new DisableReconfiguration({  }, new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", [])));
}

export function emit_genesis_reconfiguration_event_ (
  $c: AptosDataCache,
): void {
  let temp$1, config_ref;
  if (!$c.exists(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"))) {
    throw $.abortCode(Std.Error.not_found_(ECONFIGURATION, $c));
  }
  config_ref = $c.borrow_global_mut<Configuration>(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"));
  if (($.copy(config_ref.epoch)).eq((u64("0")))) {
    temp$1 = ($.copy(config_ref.last_reconfiguration_time)).eq((u64("0")));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(Std.Error.invalid_state_(ECONFIGURATION, $c));
  }
  config_ref.epoch = u64("1");
  Aptos_std.Event.emit_event_(config_ref.events, new NewEpochEvent({ epoch: $.copy(config_ref.epoch) }, new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])), $c, [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])]);
  return;
}

export function enable_reconfiguration_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  System_addresses.assert_aptos_framework_(account, $c);
  if (!!reconfiguration_enabled_($c)) {
    throw $.abortCode(Std.Error.invalid_state_(ECONFIGURATION, $c));
  }
  $c.move_from<DisableReconfiguration>(new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", []), Std.Signer.address_of_(account, $c));
  return;
}

export function force_reconfigure_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  System_addresses.assert_aptos_framework_(account, $c);
  reconfigure_($c);
  return;
}


export function buildPayload_force_reconfigure (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::reconfiguration::force_reconfigure",
    typeParamStrings,
    []
  );

}
export function initialize_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  Timestamp.assert_genesis_($c);
  System_addresses.assert_aptos_framework_(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"))) {
    throw $.abortCode(Std.Error.already_exists_(ECONFIGURATION, $c));
  }
  if (!(Std.Guid.get_next_creation_num_(Std.Signer.address_of_(account, $c), $c)).eq((u64("1")))) {
    throw $.abortCode(Std.Error.invalid_state_(EINVALID_GUID_FOR_EVENT, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), account, new Configuration({ epoch: u64("0"), last_reconfiguration_time: u64("0"), events: Aptos_std.Event.new_event_handle_(account, $c, [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])]) }, new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", [])));
  return;
}

export function last_reconfiguration_time_ (
  $c: AptosDataCache,
): U64 {
  return $.copy($c.borrow_global<Configuration>(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1")).last_reconfiguration_time);
}

export function reconfiguration_enabled_ (
  $c: AptosDataCache,
): boolean {
  return !$c.exists(new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", []), new HexString("0x1"));
}

export function reconfigure_ (
  $c: AptosDataCache,
): void {
  Stake.on_new_epoch_($c);
  reconfigure__($c);
  return;
}

export function reconfigure__ (
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, config_ref, current_time;
  if (Timestamp.is_genesis_($c)) {
    temp$1 = true;
  }
  else{
    temp$1 = (Timestamp.now_microseconds_($c)).eq((u64("0")));
  }
  if (temp$1) {
    temp$2 = true;
  }
  else{
    temp$2 = !reconfiguration_enabled_($c);
  }
  if (temp$2) {
    return;
  }
  else{
  }
  config_ref = $c.borrow_global_mut<Configuration>(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"));
  current_time = Timestamp.now_microseconds_($c);
  if (($.copy(current_time)).eq(($.copy(config_ref.last_reconfiguration_time)))) {
    return;
  }
  else{
  }
  if (!($.copy(current_time)).gt($.copy(config_ref.last_reconfiguration_time))) {
    throw $.abortCode(Std.Error.invalid_state_(EINVALID_BLOCK_TIME, $c));
  }
  config_ref.last_reconfiguration_time = $.copy(current_time);
  config_ref.epoch = ($.copy(config_ref.epoch)).add(u64("1"));
  Aptos_std.Event.emit_event_(config_ref.events, new NewEpochEvent({ epoch: $.copy(config_ref.epoch) }, new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])), $c, [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::reconfiguration::Configuration", Configuration.ConfigurationParser);
  repo.addParser("0x1::reconfiguration::DisableReconfiguration", DisableReconfiguration.DisableReconfigurationParser);
  repo.addParser("0x1::reconfiguration::NewEpochEvent", NewEpochEvent.NewEpochEventParser);
}

