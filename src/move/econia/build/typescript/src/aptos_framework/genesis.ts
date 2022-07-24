import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as account$_ from "./account";
import * as aptos_governance$_ from "./aptos_governance";
import * as block$_ from "./block";
import * as chain_id$_ from "./chain_id";
import * as coin$_ from "./coin";
import * as consensus_config$_ from "./consensus_config";
import * as reconfiguration$_ from "./reconfiguration";
import * as stake$_ from "./stake";
import * as test_coin$_ from "./test_coin";
import * as timestamp$_ from "./timestamp";
import * as transaction_fee$_ from "./transaction_fee";
import * as transaction_publishing_option$_ from "./transaction_publishing_option";
import * as version$_ from "./version";
import * as vm_config$_ from "./vm_config";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "genesis";

export const EINVALID_EPOCH_DURATION : U64 = u64("1");

export function create_initialize_validators$ (
  aptos_framework_account: HexString,
  owners: HexString[],
  consensus_pubkeys: U8[][],
  proof_of_possession: U8[][],
  validator_network_addresses: U8[][],
  full_node_network_addresses: U8[][],
  staking_distribution: U64[],
  initial_lockup_timestamp: U64,
  $c: AptosDataCache,
): void {
  let amount, consensus_pubkey, cur_full_node_network_addresses, cur_validator_network_addresses, i, num_full_node_network_addresses, num_owners, num_staking, num_validator_network_addresses, owner, owner_account, pop;
  num_owners = std$_.vector$_.length$(owners, $c, [AtomicTypeTag.Address] as TypeTag[]);
  num_validator_network_addresses = std$_.vector$_.length$(validator_network_addresses, $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]);
  num_full_node_network_addresses = std$_.vector$_.length$(full_node_network_addresses, $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]);
  if (!$.copy(num_validator_network_addresses).eq($.copy(num_full_node_network_addresses))) {
    throw $.abortCode(u64("0"));
  }
  num_staking = std$_.vector$_.length$(staking_distribution, $c, [AtomicTypeTag.U64] as TypeTag[]);
  if (!$.copy(num_full_node_network_addresses).eq($.copy(num_staking))) {
    throw $.abortCode(u64("0"));
  }
  i = u64("0");
  while ($.copy(i).lt($.copy(num_owners))) {
    {
      owner = std$_.vector$_.borrow$(owners, $.copy(i), $c, [AtomicTypeTag.Address] as TypeTag[]);
      owner_account = account$_.create_account_internal$($.copy(owner), $c);
      cur_validator_network_addresses = $.copy(std$_.vector$_.borrow$(validator_network_addresses, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      cur_full_node_network_addresses = $.copy(std$_.vector$_.borrow$(full_node_network_addresses, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      consensus_pubkey = $.copy(std$_.vector$_.borrow$(consensus_pubkeys, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      pop = $.copy(std$_.vector$_.borrow$(proof_of_possession, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      stake$_.register_validator_candidate$(owner_account, $.copy(consensus_pubkey), $.copy(pop), $.copy(cur_validator_network_addresses), $.copy(cur_full_node_network_addresses), $c);
      stake$_.increase_lockup$(owner_account, $.copy(initial_lockup_timestamp), $c);
      amount = $.copy(std$_.vector$_.borrow$(staking_distribution, $.copy(i), $c, [AtomicTypeTag.U64] as TypeTag[]));
      coin$_.register$(owner_account, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
      test_coin$_.mint$(aptos_framework_account, $.copy(owner), $.copy(amount), $c);
      stake$_.add_stake$(owner_account, $.copy(amount), $c);
      stake$_.join_validator_set_internal$(owner_account, $.copy(owner), $c);
      i = $.copy(i).add(u64("1"));
    }

  }stake$_.on_new_epoch$($c);
  return;
}


export function buildPayload_create_initialize_validators (
  owners: HexString[],
  consensus_pubkeys: U8[][],
  proof_of_possession: U8[][],
  validator_network_addresses: U8[][],
  full_node_network_addresses: U8[][],
  staking_distribution: U64[],
  initial_lockup_timestamp: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::genesis::create_initialize_validators",
    typeParamStrings,
    [
      owners.map(element => $.payloadArg(element)),
      consensus_pubkeys.map(array => $.u8ArrayArg(array)),
      proof_of_possession.map(array => $.u8ArrayArg(array)),
      validator_network_addresses.map(array => $.u8ArrayArg(array)),
      full_node_network_addresses.map(array => $.u8ArrayArg(array)),
      staking_distribution.map(element => $.payloadArg(element)),
      $.payloadArg(initial_lockup_timestamp),
    ]
  );

}
export function initialize$ (
  core_resource_account: HexString,
  core_resource_account_auth_key: U8[],
  initial_script_allow_list: U8[][],
  is_open_module: boolean,
  instruction_schedule: U8[],
  native_schedule: U8[],
  chain_id: U8,
  initial_version: U64,
  consensus_config: U8[],
  min_price_per_gas_unit: U64,
  epoch_interval: U64,
  minimum_stake: U64,
  maximum_stake: U64,
  min_lockup_duration_secs: U64,
  max_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  $c: AptosDataCache,
): void {
  if (!$.copy(epoch_interval).gt(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_EPOCH_DURATION, $c));
  }
  return initialize_internal$(core_resource_account, $.copy(core_resource_account_auth_key), $.copy(initial_script_allow_list), is_open_module, $.copy(instruction_schedule), $.copy(native_schedule), $.copy(chain_id), $.copy(initial_version), $.copy(consensus_config), $.copy(min_price_per_gas_unit), $.copy(epoch_interval), $.copy(minimum_stake), $.copy(maximum_stake), $.copy(min_lockup_duration_secs), $.copy(max_lockup_duration_secs), allow_validator_set_change, $.copy(rewards_rate), $.copy(rewards_rate_denominator), $c);
}

export function initialize_internal$ (
  core_resource_account: HexString,
  core_resource_account_auth_key: U8[],
  initial_script_allow_list: U8[][],
  is_open_module: boolean,
  instruction_schedule: U8[],
  native_schedule: U8[],
  chain_id: U8,
  initial_version: U64,
  consensus_config: U8[],
  min_price_per_gas_unit: U64,
  epoch_interval: U64,
  minimum_stake: U64,
  maximum_stake: U64,
  min_lockup_duration_secs: U64,
  max_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  $c: AptosDataCache,
): void {
  let aptos_framework_account, burn_cap, framework_signer_cap, mint_cap;
  account$_.create_account_internal$(std$_.signer$_.address_of$(core_resource_account, $c), $c);
  account$_.rotate_authentication_key_internal$(core_resource_account, $.copy(core_resource_account_auth_key), $c);
  [aptos_framework_account, framework_signer_cap] = account$_.create_core_framework_account$($c);
  account$_.initialize$(aptos_framework_account, new HexString("0x1"), [u8("97"), u8("99"), u8("99"), u8("111"), u8("117"), u8("110"), u8("116")], [u8("115"), u8("99"), u8("114"), u8("105"), u8("112"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("109"), u8("111"), u8("100"), u8("117"), u8("108"), u8("101"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("119"), u8("114"), u8("105"), u8("116"), u8("101"), u8("115"), u8("101"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("109"), u8("117"), u8("108"), u8("116"), u8("105"), u8("95"), u8("97"), u8("103"), u8("101"), u8("110"), u8("116"), u8("95"), u8("115"), u8("99"), u8("114"), u8("105"), u8("112"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("101"), u8("112"), u8("105"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("119"), u8("114"), u8("105"), u8("116"), u8("101"), u8("115"), u8("101"), u8("116"), u8("95"), u8("101"), u8("112"), u8("105"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], false, $c);
  aptos_governance$_.store_signer_cap$(aptos_framework_account, framework_signer_cap, $c);
  consensus_config$_.initialize$(aptos_framework_account, $c);
  version$_.initialize$(aptos_framework_account, $.copy(initial_version), $c);
  stake$_.initialize_validator_set$(aptos_framework_account, $.copy(minimum_stake), $.copy(maximum_stake), $.copy(min_lockup_duration_secs), $.copy(max_lockup_duration_secs), allow_validator_set_change, $.copy(rewards_rate), $.copy(rewards_rate_denominator), $c);
  vm_config$_.initialize$(aptos_framework_account, $.copy(instruction_schedule), $.copy(native_schedule), $.copy(min_price_per_gas_unit), $c);
  consensus_config$_.set$(aptos_framework_account, $.copy(consensus_config), $c);
  transaction_publishing_option$_.initialize$(aptos_framework_account, $.copy(initial_script_allow_list), is_open_module, $c);
  [mint_cap, burn_cap] = test_coin$_.initialize$(aptos_framework_account, core_resource_account, $c);
  stake$_.store_test_coin_mint_cap$(aptos_framework_account, $.copy(mint_cap), $c);
  transaction_fee$_.store_test_coin_burn_cap$(aptos_framework_account, $.copy(burn_cap), $c);
  std$_.event$_.destroy_handle$(std$_.event$_.new_event_handle$(aptos_framework_account, $c, [AtomicTypeTag.U64] as TypeTag[]), $c, [AtomicTypeTag.U64] as TypeTag[]);
  std$_.event$_.destroy_handle$(std$_.event$_.new_event_handle$(aptos_framework_account, $c, [AtomicTypeTag.U64] as TypeTag[]), $c, [AtomicTypeTag.U64] as TypeTag[]);
  chain_id$_.initialize$(aptos_framework_account, $.copy(chain_id), $c);
  reconfiguration$_.initialize$(aptos_framework_account, $c);
  block$_.initialize_block_metadata$(aptos_framework_account, $.copy(epoch_interval), $c);
  timestamp$_.set_time_has_started$(aptos_framework_account, $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
}

