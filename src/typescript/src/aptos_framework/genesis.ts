import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Account from "./account";
import * as Aptos_coin from "./aptos_coin";
import * as Aptos_governance from "./aptos_governance";
import * as Block from "./block";
import * as Chain_id from "./chain_id";
import * as Coins from "./coins";
import * as Consensus_config from "./consensus_config";
import * as Reconfiguration from "./reconfiguration";
import * as Stake from "./stake";
import * as Timestamp from "./timestamp";
import * as Transaction_fee from "./transaction_fee";
import * as Version from "./version";
import * as Vm_config from "./vm_config";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "genesis";

export const EINVALID_EPOCH_DURATION : U64 = u64("1");

export function create_initialize_validators_ (
  aptos_framework_account: HexString,
  owners: HexString[],
  consensus_pubkeys: U8[][],
  proof_of_possession: U8[][],
  validator_network_addresses: U8[][],
  full_node_network_addresses: U8[][],
  staking_distribution: U64[],
  $c: AptosDataCache,
): void {
  let amount, consensus_pubkey, cur_full_node_network_addresses, cur_validator_network_addresses, i, num_full_node_network_addresses, num_owners, num_staking, num_validator_network_addresses, owner, owner_account, pop;
  num_owners = Std.Vector.length_(owners, $c, [AtomicTypeTag.Address]);
  num_validator_network_addresses = Std.Vector.length_(validator_network_addresses, $c, [new VectorTag(AtomicTypeTag.U8)]);
  num_full_node_network_addresses = Std.Vector.length_(full_node_network_addresses, $c, [new VectorTag(AtomicTypeTag.U8)]);
  if (!($.copy(num_validator_network_addresses)).eq(($.copy(num_full_node_network_addresses)))) {
    throw $.abortCode(u64("0"));
  }
  num_staking = Std.Vector.length_(staking_distribution, $c, [AtomicTypeTag.U64]);
  if (!($.copy(num_full_node_network_addresses)).eq(($.copy(num_staking)))) {
    throw $.abortCode(u64("0"));
  }
  i = u64("0");
  while (($.copy(i)).lt($.copy(num_owners))) {
    {
      owner = Std.Vector.borrow_(owners, $.copy(i), $c, [AtomicTypeTag.Address]);
      owner_account = Account.create_account_internal_($.copy(owner), $c);
      cur_validator_network_addresses = $.copy(Std.Vector.borrow_(validator_network_addresses, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)]));
      cur_full_node_network_addresses = $.copy(Std.Vector.borrow_(full_node_network_addresses, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)]));
      consensus_pubkey = $.copy(Std.Vector.borrow_(consensus_pubkeys, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)]));
      pop = $.copy(Std.Vector.borrow_(proof_of_possession, $.copy(i), $c, [new VectorTag(AtomicTypeTag.U8)]));
      Stake.register_validator_candidate_(owner_account, $.copy(consensus_pubkey), $.copy(pop), $.copy(cur_validator_network_addresses), $.copy(cur_full_node_network_addresses), $c);
      Stake.increase_lockup_(owner_account, $c);
      amount = $.copy(Std.Vector.borrow_(staking_distribution, $.copy(i), $c, [AtomicTypeTag.U64]));
      Coins.register_(owner_account, $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
      Aptos_coin.mint_(aptos_framework_account, $.copy(owner), $.copy(amount), $c);
      Stake.add_stake_(owner_account, $.copy(amount), $c);
      Stake.join_validator_set_internal_(owner_account, $.copy(owner), $c);
      i = ($.copy(i)).add(u64("1"));
    }

  }Stake.on_new_epoch_($c);
  return;
}

export function initialize_ (
  core_resource_account: HexString,
  core_resource_account_auth_key: U8[],
  instruction_schedule: U8[],
  native_schedule: U8[],
  chain_id: U8,
  initial_version: U64,
  consensus_config: U8[],
  min_price_per_gas_unit: U64,
  epoch_interval: U64,
  minimum_stake: U64,
  maximum_stake: U64,
  recurring_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  $c: AptosDataCache,
): void {
  let aptos_framework_account, burn_cap, framework_signer_cap, mint_cap;
  if (!($.copy(epoch_interval)).gt(u64("0"))) {
    throw $.abortCode(Std.Error.invalid_argument_(EINVALID_EPOCH_DURATION, $c));
  }
  Account.create_account_internal_(Std.Signer.address_of_(core_resource_account, $c), $c);
  Account.rotate_authentication_key_internal_(core_resource_account, $.copy(core_resource_account_auth_key), $c);
  [aptos_framework_account, framework_signer_cap] = Account.create_core_framework_account_($c);
  Account.initialize_(aptos_framework_account, new HexString("0x1"), [u8("97"), u8("99"), u8("99"), u8("111"), u8("117"), u8("110"), u8("116")], [u8("115"), u8("99"), u8("114"), u8("105"), u8("112"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("109"), u8("111"), u8("100"), u8("117"), u8("108"), u8("101"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("119"), u8("114"), u8("105"), u8("116"), u8("101"), u8("115"), u8("101"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("109"), u8("117"), u8("108"), u8("116"), u8("105"), u8("95"), u8("97"), u8("103"), u8("101"), u8("110"), u8("116"), u8("95"), u8("115"), u8("99"), u8("114"), u8("105"), u8("112"), u8("116"), u8("95"), u8("112"), u8("114"), u8("111"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("101"), u8("112"), u8("105"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], [u8("119"), u8("114"), u8("105"), u8("116"), u8("101"), u8("115"), u8("101"), u8("116"), u8("95"), u8("101"), u8("112"), u8("105"), u8("108"), u8("111"), u8("103"), u8("117"), u8("101")], $c);
  Aptos_governance.store_signer_cap_(aptos_framework_account, framework_signer_cap, $c);
  Consensus_config.initialize_(aptos_framework_account, $c);
  Version.initialize_(aptos_framework_account, $.copy(initial_version), $c);
  Stake.initialize_validator_set_(aptos_framework_account, $.copy(minimum_stake), $.copy(maximum_stake), $.copy(recurring_lockup_duration_secs), allow_validator_set_change, $.copy(rewards_rate), $.copy(rewards_rate_denominator), $c);
  Vm_config.initialize_(aptos_framework_account, $.copy(instruction_schedule), $.copy(native_schedule), $.copy(min_price_per_gas_unit), $c);
  Consensus_config.set_(aptos_framework_account, $.copy(consensus_config), $c);
  [mint_cap, burn_cap] = Aptos_coin.initialize_(aptos_framework_account, core_resource_account, $c);
  Stake.store_aptos_coin_mint_cap_(aptos_framework_account, $.copy(mint_cap), $c);
  Transaction_fee.store_aptos_coin_burn_cap_(aptos_framework_account, $.copy(burn_cap), $c);
  Chain_id.initialize_(aptos_framework_account, $.copy(chain_id), $c);
  Reconfiguration.initialize_(aptos_framework_account, $c);
  Block.initialize_block_metadata_(aptos_framework_account, $.copy(epoch_interval), $c);
  Timestamp.set_time_has_started_(aptos_framework_account, $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
}

