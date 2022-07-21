import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Account from "./Account";
import * as Block from "./Block";
import * as ChainId from "./ChainId";
import * as Coin from "./Coin";
import * as ConsensusConfig from "./ConsensusConfig";
import * as Reconfiguration from "./Reconfiguration";
import * as Stake from "./Stake";
import * as TestCoin from "./TestCoin";
import * as Timestamp from "./Timestamp";
import * as TransactionFee from "./TransactionFee";
import * as TransactionPublishingOption from "./TransactionPublishingOption";
import * as VMConfig from "./VMConfig";
import * as Version from "./Version";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Genesis";


export function create_initialize_validators$ (
  core_resource_account: HexString,
  owners: HexString[],
  consensus_pubkeys: U8[][],
  proof_of_possession: U8[][],
  validator_network_addresses: U8[][],
  full_node_network_addresses: U8[][],
  staking_distribution: U64[],
  $c: AptosDataCache,
): void {
  let amount, consensus_pubkey, cur_full_node_network_addresses, cur_validator_network_addresses, i, num_full_node_network_addresses, num_owners, num_staking, num_validator_network_addresses, owner, owner_account, pop;
  num_owners = Std.Vector.length$(owners, $c, [AtomicTypeTag.Address] as TypeTag[]);
  num_validator_network_addresses = Std.Vector.length$(validator_network_addresses, $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]);
  num_full_node_network_addresses = Std.Vector.length$(full_node_network_addresses, $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]);
  if (!$.copy(num_validator_network_addresses).eq($.copy(num_full_node_network_addresses))) {
    throw $.abortCode(u64("0"));
  }
  num_staking = Std.Vector.length$(staking_distribution, $c, [AtomicTypeTag.U64] as TypeTag[]);
  if (!$.copy(num_full_node_network_addresses).eq($.copy(num_staking))) {
    throw $.abortCode(u64("0"));
  }
  i = u64("0");
  while ($.copy(i).lt($.copy(num_owners))) {
    {
      owner = Std.Vector.borrow$(owners, $.copy(i), $c, [AtomicTypeTag.Address] as TypeTag[]);
      owner_account = Account.create_account_internal$($.copy(owner), $c);
      cur_validator_network_addresses = $.copy(Std.Vector.borrow$(validator_network_addresses, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      cur_full_node_network_addresses = $.copy(Std.Vector.borrow$(full_node_network_addresses, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      consensus_pubkey = $.copy(Std.Vector.borrow$(consensus_pubkeys, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      pop = $.copy(Std.Vector.borrow$(proof_of_possession, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]));
      Stake.register_validator_candidate$(owner_account, $.copy(consensus_pubkey), $.copy(pop), $.copy(cur_validator_network_addresses), $.copy(cur_full_node_network_addresses), $c);
      Stake.increase_lockup$(owner_account, u64("100000"), $c);
      amount = $.copy(Std.Vector.borrow$(staking_distribution, $.copy(i), $c, [AtomicTypeTag.U64] as TypeTag[]));
      Coin.register$(owner_account, $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
      Coin.transfer$(core_resource_account, $.copy(owner), $.copy(amount), $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
      Stake.add_stake$(owner_account, $.copy(amount), $c);
      Stake.join_validator_set_internal$(owner_account, $.copy(owner), $c);
      i = $.copy(i).add(u64("1"));
    }

  }Stake.on_new_epoch$($c);
  return;
}


export function buildPayload_create_initialize_validators (
  owners: HexString[],
  consensus_pubkeys: U8[][],
  proof_of_possession: U8[][],
  validator_network_addresses: U8[][],
  full_node_network_addresses: U8[][],
  staking_distribution: U64[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::Genesis::create_initialize_validators",
    typeParamStrings,
    [
      owners.map(element => $.payloadArg(element)),
      consensus_pubkeys.map(array => $.u8ArrayArg(array)),
      proof_of_possession.map(array => $.u8ArrayArg(array)),
      validator_network_addresses.map(array => $.u8ArrayArg(array)),
      full_node_network_addresses.map(array => $.u8ArrayArg(array)),
      staking_distribution.map(element => $.payloadArg(element)),
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
  let burn_cap, core_framework_account, mint_cap;
  Account.initialize$(core_resource_account, new HexString("0x1"), [u8("65"), u8("99"), u8("99"), u8("111"), u8("117"), u8("110"), u8("116")], [u8("115"), u8("99"), u8("114"), u8("105"), u8("112"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("109"), u8("111"), u8("100"), u8("117"), u8("108"), u8("101"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("119"), u8("114"), u8("105"), u8("116"), u8("101"), u8("115"), u8("101"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("109"), u8("117"), u8("108"), u8("116"), u8("105"), u8("95"), u8("97"), u8("103"), u8("101"), u8("110"), u8("116"), u8("95"), u8("115"), u8("99"), u8("114"), u8("105"), u8("112"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("101"), u8("112"), u8("105"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("119"), u8("114"), u8("105"), u8("116"), u8("101"), u8("115"), u8("101"), u8("116"), u8("95"), u8("101"), u8("112"), u8("105"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], false, $c);
  Account.create_account_internal$(Std.Signer.address_of$(core_resource_account, $c), $c);
  Account.rotate_authentication_key_internal$(core_resource_account, $.copy(core_resource_account_auth_key), $c);
  core_framework_account = Account.create_core_framework_account$($c);
  ConsensusConfig.initialize$(core_resource_account, $c);
  Version.initialize$(core_resource_account, $.copy(initial_version), $c);
  Stake.initialize_validator_set$(core_resource_account, $.copy(minimum_stake), $.copy(maximum_stake), $.copy(min_lockup_duration_secs), $.copy(max_lockup_duration_secs), allow_validator_set_change, $.copy(rewards_rate), $.copy(rewards_rate_denominator), $c);
  VMConfig.initialize$(core_resource_account, $.copy(instruction_schedule), $.copy(native_schedule), $.copy(min_price_per_gas_unit), $c);
  ConsensusConfig.set$(core_resource_account, $.copy(consensus_config), $c);
  TransactionPublishingOption.initialize$(core_resource_account, $.copy(initial_script_allow_list), is_open_module, $c);
  [mint_cap, burn_cap] = TestCoin.initialize$(core_framework_account, core_resource_account, $c);
  Stake.store_test_coin_mint_cap$(core_resource_account, $.copy(mint_cap), $c);
  TransactionFee.store_test_coin_burn_cap$(core_framework_account, $.copy(burn_cap), $c);
  Std.Event.destroy_handle$(Std.Event.new_event_handle$(core_resource_account, $c, [AtomicTypeTag.U64] as TypeTag[]), $c, [AtomicTypeTag.U64] as TypeTag[]);
  Std.Event.destroy_handle$(Std.Event.new_event_handle$(core_resource_account, $c, [AtomicTypeTag.U64] as TypeTag[]), $c, [AtomicTypeTag.U64] as TypeTag[]);
  ChainId.initialize$(core_resource_account, $.copy(chain_id), $c);
  Reconfiguration.initialize$(core_resource_account, $c);
  Block.initialize_block_metadata$(core_resource_account, $.copy(epoch_interval), $c);
  Timestamp.set_time_has_started$(core_resource_account, $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
}

