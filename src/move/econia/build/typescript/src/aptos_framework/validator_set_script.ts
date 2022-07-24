import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "validator_set_script";


export function add_validator$ (
  _account: HexString,
  _validator_addr: HexString,
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_add_validator (
  _validator_addr: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::add_validator",
    typeParamStrings,
    [
      $.payloadArg(_validator_addr),
    ]
  );

}
export function create_validator_account$ (
  _core_resource: HexString,
  _new_account_address: HexString,
  _human_name: U8[],
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_create_validator_account (
  _new_account_address: HexString,
  _human_name: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::create_validator_account",
    typeParamStrings,
    [
      $.payloadArg(_new_account_address),
      $.u8ArrayArg(_human_name),
    ]
  );

}
export function create_validator_operator_account$ (
  _core_resource: HexString,
  _new_account_address: HexString,
  _human_name: U8[],
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_create_validator_operator_account (
  _new_account_address: HexString,
  _human_name: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::create_validator_operator_account",
    typeParamStrings,
    [
      $.payloadArg(_new_account_address),
      $.u8ArrayArg(_human_name),
    ]
  );

}
export function register_validator_config$ (
  _validator_operator_account: HexString,
  _validator_address: HexString,
  _consensus_pubkey: U8[],
  _validator_network_addresses: U8[],
  _fullnode_network_addresses: U8[],
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_register_validator_config (
  _validator_address: HexString,
  _consensus_pubkey: U8[],
  _validator_network_addresses: U8[],
  _fullnode_network_addresses: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::register_validator_config",
    typeParamStrings,
    [
      $.payloadArg(_validator_address),
      $.u8ArrayArg(_consensus_pubkey),
      $.u8ArrayArg(_validator_network_addresses),
      $.u8ArrayArg(_fullnode_network_addresses),
    ]
  );

}
export function remove_validator$ (
  _account: HexString,
  _validator_addr: HexString,
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_remove_validator (
  _validator_addr: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::remove_validator",
    typeParamStrings,
    [
      $.payloadArg(_validator_addr),
    ]
  );

}
export function set_validator_config_and_reconfigure$ (
  _validator_operator_account: HexString,
  _validator_account: HexString,
  _consensus_pubkey: U8[],
  _validator_network_addresses: U8[],
  _fullnode_network_addresses: U8[],
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_set_validator_config_and_reconfigure (
  _validator_account: HexString,
  _consensus_pubkey: U8[],
  _validator_network_addresses: U8[],
  _fullnode_network_addresses: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::set_validator_config_and_reconfigure",
    typeParamStrings,
    [
      $.payloadArg(_validator_account),
      $.u8ArrayArg(_consensus_pubkey),
      $.u8ArrayArg(_validator_network_addresses),
      $.u8ArrayArg(_fullnode_network_addresses),
    ]
  );

}
export function set_validator_operator$ (
  _account: HexString,
  _operator_name: U8[],
  _operator_account: HexString,
  $c: AptosDataCache,
): void {
  return;
}


export function buildPayload_set_validator_operator (
  _operator_name: U8[],
  _operator_account: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::validator_set_script::set_validator_operator",
    typeParamStrings,
    [
      $.u8ArrayArg(_operator_name),
      $.payloadArg(_operator_account),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
}

