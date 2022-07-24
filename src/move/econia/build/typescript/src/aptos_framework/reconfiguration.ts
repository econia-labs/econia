import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as stake$_ from "./stake";
import * as system_addresses$_ from "./system_addresses";
import * as timestamp$_ from "./timestamp";
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
  events: std$_.event$_.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto['epoch'] as U64;
    this.last_reconfiguration_time = proto['last_reconfiguration_time'] as U64;
    this.events = proto['events'] as std$_.event$_.EventHandle;
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
export function disable_reconfiguration$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  system_addresses$_.assert_aptos_framework$(account, $c);
  if (!reconfiguration_enabled$($c)) {
    throw $.abortCode(std$_.errors$_.invalid_state$(ECONFIGURATION, $c));
  }
  return $c.move_to(new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", []), account, new DisableReconfiguration({  }, new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", [])));
}

export function emit_genesis_reconfiguration_event$ (
  $c: AptosDataCache,
): void {
  let temp$1, config_ref;
  if (!$c.exists(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"))) {
    throw $.abortCode(std$_.errors$_.not_published$(ECONFIGURATION, $c));
  }
  config_ref = $c.borrow_global_mut<Configuration>(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"));
  if ($.copy(config_ref.epoch).eq(u64("0"))) {
    temp$1 = $.copy(config_ref.last_reconfiguration_time).eq(u64("0"));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(std$_.errors$_.invalid_state$(ECONFIGURATION, $c));
  }
  config_ref.epoch = u64("1");
  std$_.event$_.emit_event$(config_ref.events, new NewEpochEvent({ epoch: $.copy(config_ref.epoch) }, new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])), $c, [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])] as TypeTag[]);
  return;
}

export function enable_reconfiguration$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  system_addresses$_.assert_aptos_framework$(account, $c);
  if (!!reconfiguration_enabled$($c)) {
    throw $.abortCode(std$_.errors$_.invalid_state$(ECONFIGURATION, $c));
  }
  $c.move_from<DisableReconfiguration>(new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", []), std$_.signer$_.address_of$(account, $c));
  return;
}

export function force_reconfigure$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  system_addresses$_.assert_aptos_framework$(account, $c);
  reconfigure$($c);
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
export function initialize$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  timestamp$_.assert_genesis$($c);
  system_addresses$_.assert_aptos_framework$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"))) {
    throw $.abortCode(std$_.errors$_.already_published$(ECONFIGURATION, $c));
  }
  if (!std$_.guid$_.get_next_creation_num$(std$_.signer$_.address_of$(account, $c), $c).eq(u64("2"))) {
    throw $.abortCode(std$_.errors$_.invalid_state$(EINVALID_GUID_FOR_EVENT, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), account, new Configuration({ epoch: u64("0"), last_reconfiguration_time: u64("0"), events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", [])));
  return;
}

export function last_reconfiguration_time$ (
  $c: AptosDataCache,
): U64 {
  return $.copy($c.borrow_global<Configuration>(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1")).last_reconfiguration_time);
}

export function reconfiguration_enabled$ (
  $c: AptosDataCache,
): boolean {
  return !$c.exists(new StructTag(new HexString("0x1"), "reconfiguration", "DisableReconfiguration", []), new HexString("0x1"));
}

export function reconfigure$ (
  $c: AptosDataCache,
): void {
  stake$_.on_new_epoch$($c);
  reconfigure_$($c);
  return;
}

export function reconfigure_$ (
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, config_ref, current_time;
  if (timestamp$_.is_genesis$($c)) {
    temp$1 = true;
  }
  else{
    temp$1 = timestamp$_.now_microseconds$($c).eq(u64("0"));
  }
  if (temp$1) {
    temp$2 = true;
  }
  else{
    temp$2 = !reconfiguration_enabled$($c);
  }
  if (temp$2) {
    return;
  }
  else{
  }
  config_ref = $c.borrow_global_mut<Configuration>(new StructTag(new HexString("0x1"), "reconfiguration", "Configuration", []), new HexString("0x1"));
  current_time = timestamp$_.now_microseconds$($c);
  if ($.copy(current_time).eq($.copy(config_ref.last_reconfiguration_time))) {
    return;
  }
  else{
  }
  if (!$.copy(current_time).gt($.copy(config_ref.last_reconfiguration_time))) {
    throw $.abortCode(std$_.errors$_.invalid_state$(EINVALID_BLOCK_TIME, $c));
  }
  config_ref.last_reconfiguration_time = $.copy(current_time);
  config_ref.epoch = $.copy(config_ref.epoch).add(u64("1"));
  std$_.event$_.emit_event$(config_ref.events, new NewEpochEvent({ epoch: $.copy(config_ref.epoch) }, new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])), $c, [new StructTag(new HexString("0x1"), "reconfiguration", "NewEpochEvent", [])] as TypeTag[]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::reconfiguration::Configuration", Configuration.ConfigurationParser);
  repo.addParser("0x1::reconfiguration::DisableReconfiguration", DisableReconfiguration.DisableReconfigurationParser);
  repo.addParser("0x1::reconfiguration::NewEpochEvent", NewEpochEvent.NewEpochEventParser);
}

