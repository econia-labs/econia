import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Reconfiguration from "./Reconfiguration";
import * as SystemAddresses from "./SystemAddresses";
import * as Timestamp from "./Timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "VMConfig";

export const ECONFIG : U64 = u64("0");
export const EGAS_CONSTANT_INCONSISTENCY : U64 = u64("1");


export class GasConstants 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GasConstants";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "global_memory_per_byte_cost", typeTag: AtomicTypeTag.U64 },
  { name: "global_memory_per_byte_write_cost", typeTag: AtomicTypeTag.U64 },
  { name: "min_transaction_gas_units", typeTag: AtomicTypeTag.U64 },
  { name: "large_transaction_cutoff", typeTag: AtomicTypeTag.U64 },
  { name: "intrinsic_gas_per_byte", typeTag: AtomicTypeTag.U64 },
  { name: "maximum_number_of_gas_units", typeTag: AtomicTypeTag.U64 },
  { name: "min_price_per_gas_unit", typeTag: AtomicTypeTag.U64 },
  { name: "max_price_per_gas_unit", typeTag: AtomicTypeTag.U64 },
  { name: "max_transaction_size_in_bytes", typeTag: AtomicTypeTag.U64 },
  { name: "gas_unit_scaling_factor", typeTag: AtomicTypeTag.U64 },
  { name: "default_account_size", typeTag: AtomicTypeTag.U64 }];

  global_memory_per_byte_cost: U64;
  global_memory_per_byte_write_cost: U64;
  min_transaction_gas_units: U64;
  large_transaction_cutoff: U64;
  intrinsic_gas_per_byte: U64;
  maximum_number_of_gas_units: U64;
  min_price_per_gas_unit: U64;
  max_price_per_gas_unit: U64;
  max_transaction_size_in_bytes: U64;
  gas_unit_scaling_factor: U64;
  default_account_size: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.global_memory_per_byte_cost = proto['global_memory_per_byte_cost'] as U64;
    this.global_memory_per_byte_write_cost = proto['global_memory_per_byte_write_cost'] as U64;
    this.min_transaction_gas_units = proto['min_transaction_gas_units'] as U64;
    this.large_transaction_cutoff = proto['large_transaction_cutoff'] as U64;
    this.intrinsic_gas_per_byte = proto['intrinsic_gas_per_byte'] as U64;
    this.maximum_number_of_gas_units = proto['maximum_number_of_gas_units'] as U64;
    this.min_price_per_gas_unit = proto['min_price_per_gas_unit'] as U64;
    this.max_price_per_gas_unit = proto['max_price_per_gas_unit'] as U64;
    this.max_transaction_size_in_bytes = proto['max_transaction_size_in_bytes'] as U64;
    this.gas_unit_scaling_factor = proto['gas_unit_scaling_factor'] as U64;
    this.default_account_size = proto['default_account_size'] as U64;
  }

  static GasConstantsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GasConstants {
    const proto = $.parseStructProto(data, typeTag, repo, GasConstants);
    return new GasConstants(proto, typeTag);
  }

}

export class GasSchedule 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GasSchedule";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "instruction_schedule", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "native_schedule", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "gas_constants", typeTag: new StructTag(new HexString("0x1"), "VMConfig", "GasConstants", []) }];

  instruction_schedule: U8[];
  native_schedule: U8[];
  gas_constants: GasConstants;

  constructor(proto: any, public typeTag: TypeTag) {
    this.instruction_schedule = proto['instruction_schedule'] as U8[];
    this.native_schedule = proto['native_schedule'] as U8[];
    this.gas_constants = proto['gas_constants'] as GasConstants;
  }

  static GasScheduleParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GasSchedule {
    const proto = $.parseStructProto(data, typeTag, repo, GasSchedule);
    return new GasSchedule(proto, typeTag);
  }

}

export class VMConfig 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VMConfig";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "gas_schedule", typeTag: new StructTag(new HexString("0x1"), "VMConfig", "GasSchedule", []) }];

  gas_schedule: GasSchedule;

  constructor(proto: any, public typeTag: TypeTag) {
    this.gas_schedule = proto['gas_schedule'] as GasSchedule;
  }

  static VMConfigParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VMConfig {
    const proto = $.parseStructProto(data, typeTag, repo, VMConfig);
    return new VMConfig(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, VMConfig, typeParams);
    return result as unknown as VMConfig;
  }
}
export function initialize$ (
  account: HexString,
  instruction_schedule: U8[],
  native_schedule: U8[],
  min_price_per_gas_unit: U64,
  $c: AptosDataCache,
): void {
  let gas_constants;
  Timestamp.assert_genesis$($c);
  SystemAddresses.assert_core_resource$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "VMConfig", "VMConfig", []), new HexString("0xa550c18"))) {
    throw $.abortCode(Std.Errors.already_published$(ECONFIG, $c));
  }
  gas_constants = new GasConstants({ global_memory_per_byte_cost: u64("4"), global_memory_per_byte_write_cost: u64("9"), min_transaction_gas_units: u64("600"), large_transaction_cutoff: u64("600"), intrinsic_gas_per_byte: u64("8"), maximum_number_of_gas_units: u64("4000000"), min_price_per_gas_unit: $.copy(min_price_per_gas_unit), max_price_per_gas_unit: u64("10000"), max_transaction_size_in_bytes: u64("262144"), gas_unit_scaling_factor: u64("1000"), default_account_size: u64("800") }, new StructTag(new HexString("0x1"), "VMConfig", "GasConstants", []));
  $c.move_to(new StructTag(new HexString("0x1"), "VMConfig", "VMConfig", []), account, new VMConfig({ gas_schedule: new GasSchedule({ instruction_schedule: $.copy(instruction_schedule), native_schedule: $.copy(native_schedule), gas_constants: $.copy(gas_constants) }, new StructTag(new HexString("0x1"), "VMConfig", "GasSchedule", [])) }, new StructTag(new HexString("0x1"), "VMConfig", "VMConfig", [])));
  return;
}

export function set_gas_constants$ (
  account: HexString,
  global_memory_per_byte_cost: U64,
  global_memory_per_byte_write_cost: U64,
  min_transaction_gas_units: U64,
  large_transaction_cutoff: U64,
  intrinsic_gas_per_byte: U64,
  maximum_number_of_gas_units: U64,
  min_price_per_gas_unit: U64,
  max_price_per_gas_unit: U64,
  max_transaction_size_in_bytes: U64,
  gas_unit_scaling_factor: U64,
  default_account_size: U64,
  $c: AptosDataCache,
): void {
  let gas_constants;
  Timestamp.assert_operating$($c);
  SystemAddresses.assert_core_resource$(account, $c);
  if (!$.copy(min_price_per_gas_unit).le($.copy(max_price_per_gas_unit))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EGAS_CONSTANT_INCONSISTENCY, $c));
  }
  if (!$.copy(min_transaction_gas_units).le($.copy(maximum_number_of_gas_units))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EGAS_CONSTANT_INCONSISTENCY, $c));
  }
  if (!$c.exists(new StructTag(new HexString("0x1"), "VMConfig", "VMConfig", []), new HexString("0xa550c18"))) {
    throw $.abortCode(Std.Errors.not_published$(ECONFIG, $c));
  }
  gas_constants = $c.borrow_global_mut<VMConfig>(new StructTag(new HexString("0x1"), "VMConfig", "VMConfig", []), new HexString("0xa550c18")).gas_schedule.gas_constants;
  gas_constants.global_memory_per_byte_cost = $.copy(global_memory_per_byte_cost);
  gas_constants.global_memory_per_byte_write_cost = $.copy(global_memory_per_byte_write_cost);
  gas_constants.min_transaction_gas_units = $.copy(min_transaction_gas_units);
  gas_constants.large_transaction_cutoff = $.copy(large_transaction_cutoff);
  gas_constants.intrinsic_gas_per_byte = $.copy(intrinsic_gas_per_byte);
  gas_constants.maximum_number_of_gas_units = $.copy(maximum_number_of_gas_units);
  gas_constants.min_price_per_gas_unit = $.copy(min_price_per_gas_unit);
  gas_constants.max_price_per_gas_unit = $.copy(max_price_per_gas_unit);
  gas_constants.max_transaction_size_in_bytes = $.copy(max_transaction_size_in_bytes);
  gas_constants.gas_unit_scaling_factor = $.copy(gas_unit_scaling_factor);
  gas_constants.default_account_size = $.copy(default_account_size);
  Reconfiguration.reconfigure$($c);
  return;
}


export function buildPayload_set_gas_constants (
  global_memory_per_byte_cost: U64,
  global_memory_per_byte_write_cost: U64,
  min_transaction_gas_units: U64,
  large_transaction_cutoff: U64,
  intrinsic_gas_per_byte: U64,
  maximum_number_of_gas_units: U64,
  min_price_per_gas_unit: U64,
  max_price_per_gas_unit: U64,
  max_transaction_size_in_bytes: U64,
  gas_unit_scaling_factor: U64,
  default_account_size: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::VMConfig::set_gas_constants",
    typeParamStrings,
    [
      $.payloadArg(global_memory_per_byte_cost),
      $.payloadArg(global_memory_per_byte_write_cost),
      $.payloadArg(min_transaction_gas_units),
      $.payloadArg(large_transaction_cutoff),
      $.payloadArg(intrinsic_gas_per_byte),
      $.payloadArg(maximum_number_of_gas_units),
      $.payloadArg(min_price_per_gas_unit),
      $.payloadArg(max_price_per_gas_unit),
      $.payloadArg(max_transaction_size_in_bytes),
      $.payloadArg(gas_unit_scaling_factor),
      $.payloadArg(default_account_size),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::VMConfig::GasConstants", GasConstants.GasConstantsParser);
  repo.addParser("0x1::VMConfig::GasSchedule", GasSchedule.GasScheduleParser);
  repo.addParser("0x1::VMConfig::VMConfig", VMConfig.VMConfigParser);
}

