import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as coin$_ from "./coin";
import * as comparator$_ from "./comparator";
import * as governance_proposal$_ from "./governance_proposal";
import * as signature$_ from "./signature";
import * as system_addresses$_ from "./system_addresses";
import * as timestamp$_ from "./timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "stake";

export const EALREADY_ACTIVE_VALIDATOR : U64 = u64("6");
export const EALREADY_REGISTERED : U64 = u64("10");
export const EINVALID_LOCKUP_RANGE : U64 = u64("18");
export const EINVALID_PUBLIC_KEY : U64 = u64("16");
export const EINVALID_REWARDS_RATE : U64 = u64("19");
export const EINVALID_STAKE_AMOUNT : U64 = u64("20");
export const EINVALID_STAKE_RANGE : U64 = u64("17");
export const ELAST_VALIDATOR : U64 = u64("8");
export const ELOCK_TIME_TOO_LONG : U64 = u64("14");
export const ELOCK_TIME_TOO_SHORT : U64 = u64("1");
export const ENOT_OPERATOR : U64 = u64("13");
export const ENOT_OWNER : U64 = u64("11");
export const ENOT_VALIDATOR : U64 = u64("7");
export const ENO_COINS_TO_WITHDRAW : U64 = u64("12");
export const ENO_POST_GENESIS_VALIDATOR_SET_CHANGE_ALLOWED : U64 = u64("15");
export const ESTAKE_EXCEEDS_MAX : U64 = u64("9");
export const ESTAKE_TOO_HIGH : U64 = u64("5");
export const ESTAKE_TOO_LOW : U64 = u64("4");
export const EVALIDATOR_CONFIG : U64 = u64("3");
export const EWITHDRAW_NOT_ALLOWED : U64 = u64("2");
export const VALIDATOR_STATUS_ACTIVE : U64 = u64("2");
export const VALIDATOR_STATUS_INACTIVE : U64 = u64("4");
export const VALIDATOR_STATUS_PENDING_ACTIVE : U64 = u64("1");
export const VALIDATOR_STATUS_PENDING_INACTIVE : U64 = u64("3");


export class AddStakeEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "AddStakeEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "amount_added", typeTag: AtomicTypeTag.U64 }];

  pool_address: HexString;
  amount_added: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.amount_added = proto['amount_added'] as U64;
  }

  static AddStakeEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : AddStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, AddStakeEvent);
    return new AddStakeEvent(proto, typeTag);
  }

}

export class DistributeRewardsEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "DistributeRewardsEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "rewards_amount", typeTag: AtomicTypeTag.U64 }];

  pool_address: HexString;
  rewards_amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.rewards_amount = proto['rewards_amount'] as U64;
  }

  static DistributeRewardsEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : DistributeRewardsEvent {
    const proto = $.parseStructProto(data, typeTag, repo, DistributeRewardsEvent);
    return new DistributeRewardsEvent(proto, typeTag);
  }

}

export class IncreaseLockupEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "IncreaseLockupEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "old_locked_until_secs", typeTag: AtomicTypeTag.U64 },
  { name: "new_locked_until_secs", typeTag: AtomicTypeTag.U64 }];

  pool_address: HexString;
  old_locked_until_secs: U64;
  new_locked_until_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.old_locked_until_secs = proto['old_locked_until_secs'] as U64;
    this.new_locked_until_secs = proto['new_locked_until_secs'] as U64;
  }

  static IncreaseLockupEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : IncreaseLockupEvent {
    const proto = $.parseStructProto(data, typeTag, repo, IncreaseLockupEvent);
    return new IncreaseLockupEvent(proto, typeTag);
  }

}

export class JoinValidatorSetEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "JoinValidatorSetEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address }];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
  }

  static JoinValidatorSetEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : JoinValidatorSetEvent {
    const proto = $.parseStructProto(data, typeTag, repo, JoinValidatorSetEvent);
    return new JoinValidatorSetEvent(proto, typeTag);
  }

}

export class LeaveValidatorSetEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "LeaveValidatorSetEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address }];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
  }

  static LeaveValidatorSetEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : LeaveValidatorSetEvent {
    const proto = $.parseStructProto(data, typeTag, repo, LeaveValidatorSetEvent);
    return new LeaveValidatorSetEvent(proto, typeTag);
  }

}

export class OwnerCapability 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OwnerCapability";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address }];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
  }

  static OwnerCapabilityParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OwnerCapability {
    const proto = $.parseStructProto(data, typeTag, repo, OwnerCapability);
    return new OwnerCapability(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, OwnerCapability, typeParams);
    return result as unknown as OwnerCapability;
  }
}

export class RegisterValidatorCandidateEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "RegisterValidatorCandidateEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address }];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
  }

  static RegisterValidatorCandidateEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : RegisterValidatorCandidateEvent {
    const proto = $.parseStructProto(data, typeTag, repo, RegisterValidatorCandidateEvent);
    return new RegisterValidatorCandidateEvent(proto, typeTag);
  }

}

export class RotateConsensusKeyEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "RotateConsensusKeyEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "old_consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "new_consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  pool_address: HexString;
  old_consensus_pubkey: U8[];
  new_consensus_pubkey: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.old_consensus_pubkey = proto['old_consensus_pubkey'] as U8[];
    this.new_consensus_pubkey = proto['new_consensus_pubkey'] as U8[];
  }

  static RotateConsensusKeyEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : RotateConsensusKeyEvent {
    const proto = $.parseStructProto(data, typeTag, repo, RotateConsensusKeyEvent);
    return new RotateConsensusKeyEvent(proto, typeTag);
  }

}

export class SetOperatorEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "SetOperatorEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "old_operator", typeTag: AtomicTypeTag.Address },
  { name: "new_operator", typeTag: AtomicTypeTag.Address }];

  pool_address: HexString;
  old_operator: HexString;
  new_operator: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.old_operator = proto['old_operator'] as HexString;
    this.new_operator = proto['new_operator'] as HexString;
  }

  static SetOperatorEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : SetOperatorEvent {
    const proto = $.parseStructProto(data, typeTag, repo, SetOperatorEvent);
    return new SetOperatorEvent(proto, typeTag);
  }

}

export class StakePool 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "StakePool";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "active", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) },
  { name: "inactive", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) },
  { name: "pending_active", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) },
  { name: "pending_inactive", typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) },
  { name: "locked_until_secs", typeTag: AtomicTypeTag.U64 },
  { name: "operator_address", typeTag: AtomicTypeTag.Address },
  { name: "delegated_voter", typeTag: AtomicTypeTag.Address }];

  active: coin$_.Coin;
  inactive: coin$_.Coin;
  pending_active: coin$_.Coin;
  pending_inactive: coin$_.Coin;
  locked_until_secs: U64;
  operator_address: HexString;
  delegated_voter: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.active = proto['active'] as coin$_.Coin;
    this.inactive = proto['inactive'] as coin$_.Coin;
    this.pending_active = proto['pending_active'] as coin$_.Coin;
    this.pending_inactive = proto['pending_inactive'] as coin$_.Coin;
    this.locked_until_secs = proto['locked_until_secs'] as U64;
    this.operator_address = proto['operator_address'] as HexString;
    this.delegated_voter = proto['delegated_voter'] as HexString;
  }

  static StakePoolParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : StakePool {
    const proto = $.parseStructProto(data, typeTag, repo, StakePool);
    return new StakePool(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, StakePool, typeParams);
    return result as unknown as StakePool;
  }
}

export class StakePoolEvents 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "StakePoolEvents";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "register_validator_candidate_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "RegisterValidatorCandidateEvent", [])]) },
  { name: "set_operator_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "SetOperatorEvent", [])]) },
  { name: "add_stake_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "AddStakeEvent", [])]) },
  { name: "rotate_consensus_key_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "RotateConsensusKeyEvent", [])]) },
  { name: "update_network_and_fullnode_addresses_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "UpdateNetworkAndFullnodeAddressesEvent", [])]) },
  { name: "increase_lockup_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "IncreaseLockupEvent", [])]) },
  { name: "join_validator_set_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "JoinValidatorSetEvent", [])]) },
  { name: "distribute_rewards_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "DistributeRewardsEvent", [])]) },
  { name: "unlock_stake_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "UnlockStakeEvent", [])]) },
  { name: "withdraw_stake_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "WithdrawStakeEvent", [])]) },
  { name: "leave_validator_set_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "stake", "LeaveValidatorSetEvent", [])]) }];

  register_validator_candidate_events: std$_.event$_.EventHandle;
  set_operator_events: std$_.event$_.EventHandle;
  add_stake_events: std$_.event$_.EventHandle;
  rotate_consensus_key_events: std$_.event$_.EventHandle;
  update_network_and_fullnode_addresses_events: std$_.event$_.EventHandle;
  increase_lockup_events: std$_.event$_.EventHandle;
  join_validator_set_events: std$_.event$_.EventHandle;
  distribute_rewards_events: std$_.event$_.EventHandle;
  unlock_stake_events: std$_.event$_.EventHandle;
  withdraw_stake_events: std$_.event$_.EventHandle;
  leave_validator_set_events: std$_.event$_.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.register_validator_candidate_events = proto['register_validator_candidate_events'] as std$_.event$_.EventHandle;
    this.set_operator_events = proto['set_operator_events'] as std$_.event$_.EventHandle;
    this.add_stake_events = proto['add_stake_events'] as std$_.event$_.EventHandle;
    this.rotate_consensus_key_events = proto['rotate_consensus_key_events'] as std$_.event$_.EventHandle;
    this.update_network_and_fullnode_addresses_events = proto['update_network_and_fullnode_addresses_events'] as std$_.event$_.EventHandle;
    this.increase_lockup_events = proto['increase_lockup_events'] as std$_.event$_.EventHandle;
    this.join_validator_set_events = proto['join_validator_set_events'] as std$_.event$_.EventHandle;
    this.distribute_rewards_events = proto['distribute_rewards_events'] as std$_.event$_.EventHandle;
    this.unlock_stake_events = proto['unlock_stake_events'] as std$_.event$_.EventHandle;
    this.withdraw_stake_events = proto['withdraw_stake_events'] as std$_.event$_.EventHandle;
    this.leave_validator_set_events = proto['leave_validator_set_events'] as std$_.event$_.EventHandle;
  }

  static StakePoolEventsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : StakePoolEvents {
    const proto = $.parseStructProto(data, typeTag, repo, StakePoolEvents);
    return new StakePoolEvents(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, StakePoolEvents, typeParams);
    return result as unknown as StakePoolEvents;
  }
}

export class TestCoinCapabilities 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TestCoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "mint_cap", typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])]) }];

  mint_cap: coin$_.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_cap = proto['mint_cap'] as coin$_.MintCapability;
  }

  static TestCoinCapabilitiesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TestCoinCapabilities {
    const proto = $.parseStructProto(data, typeTag, repo, TestCoinCapabilities);
    return new TestCoinCapabilities(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, TestCoinCapabilities, typeParams);
    return result as unknown as TestCoinCapabilities;
  }
}

export class UnlockStakeEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "UnlockStakeEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "amount_unlocked", typeTag: AtomicTypeTag.U64 }];

  pool_address: HexString;
  amount_unlocked: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.amount_unlocked = proto['amount_unlocked'] as U64;
  }

  static UnlockStakeEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : UnlockStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UnlockStakeEvent);
    return new UnlockStakeEvent(proto, typeTag);
  }

}

export class UpdateNetworkAndFullnodeAddressesEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "UpdateNetworkAndFullnodeAddressesEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "old_network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "new_network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "old_fullnode_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "new_fullnode_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  pool_address: HexString;
  old_network_addresses: U8[];
  new_network_addresses: U8[];
  old_fullnode_addresses: U8[];
  new_fullnode_addresses: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.old_network_addresses = proto['old_network_addresses'] as U8[];
    this.new_network_addresses = proto['new_network_addresses'] as U8[];
    this.old_fullnode_addresses = proto['old_fullnode_addresses'] as U8[];
    this.new_fullnode_addresses = proto['new_fullnode_addresses'] as U8[];
  }

  static UpdateNetworkAndFullnodeAddressesEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : UpdateNetworkAndFullnodeAddressesEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UpdateNetworkAndFullnodeAddressesEvent);
    return new UpdateNetworkAndFullnodeAddressesEvent(proto, typeTag);
  }

}

export class ValidatorConfig 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ValidatorConfig";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "fullnode_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "validator_index", typeTag: AtomicTypeTag.U64 }];

  consensus_pubkey: U8[];
  network_addresses: U8[];
  fullnode_addresses: U8[];
  validator_index: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.consensus_pubkey = proto['consensus_pubkey'] as U8[];
    this.network_addresses = proto['network_addresses'] as U8[];
    this.fullnode_addresses = proto['fullnode_addresses'] as U8[];
    this.validator_index = proto['validator_index'] as U64;
  }

  static ValidatorConfigParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ValidatorConfig {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorConfig);
    return new ValidatorConfig(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, ValidatorConfig, typeParams);
    return result as unknown as ValidatorConfig;
  }
}

export class ValidatorInfo 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ValidatorInfo";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "addr", typeTag: AtomicTypeTag.Address },
  { name: "voting_power", typeTag: AtomicTypeTag.U64 },
  { name: "config", typeTag: new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []) }];

  addr: HexString;
  voting_power: U64;
  config: ValidatorConfig;

  constructor(proto: any, public typeTag: TypeTag) {
    this.addr = proto['addr'] as HexString;
    this.voting_power = proto['voting_power'] as U64;
    this.config = proto['config'] as ValidatorConfig;
  }

  static ValidatorInfoParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ValidatorInfo {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorInfo);
    return new ValidatorInfo(proto, typeTag);
  }

}

export class ValidatorPerformance 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ValidatorPerformance";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "num_blocks", typeTag: AtomicTypeTag.U64 },
  { name: "missed_votes", typeTag: new VectorTag(AtomicTypeTag.U64) }];

  num_blocks: U64;
  missed_votes: U64[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.num_blocks = proto['num_blocks'] as U64;
    this.missed_votes = proto['missed_votes'] as U64[];
  }

  static ValidatorPerformanceParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ValidatorPerformance {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorPerformance);
    return new ValidatorPerformance(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, ValidatorPerformance, typeParams);
    return result as unknown as ValidatorPerformance;
  }
}

export class ValidatorSet 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ValidatorSet";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "consensus_scheme", typeTag: AtomicTypeTag.U8 },
  { name: "active_validators", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])) },
  { name: "pending_inactive", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])) },
  { name: "pending_active", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])) }];

  consensus_scheme: U8;
  active_validators: ValidatorInfo[];
  pending_inactive: ValidatorInfo[];
  pending_active: ValidatorInfo[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.consensus_scheme = proto['consensus_scheme'] as U8;
    this.active_validators = proto['active_validators'] as ValidatorInfo[];
    this.pending_inactive = proto['pending_inactive'] as ValidatorInfo[];
    this.pending_active = proto['pending_active'] as ValidatorInfo[];
  }

  static ValidatorSetParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ValidatorSet {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorSet);
    return new ValidatorSet(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, ValidatorSet, typeParams);
    return result as unknown as ValidatorSet;
  }
}

export class ValidatorSetConfiguration 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ValidatorSetConfiguration";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "minimum_stake", typeTag: AtomicTypeTag.U64 },
  { name: "maximum_stake", typeTag: AtomicTypeTag.U64 },
  { name: "min_lockup_duration_secs", typeTag: AtomicTypeTag.U64 },
  { name: "max_lockup_duration_secs", typeTag: AtomicTypeTag.U64 },
  { name: "allow_validator_set_change", typeTag: AtomicTypeTag.Bool },
  { name: "rewards_rate", typeTag: AtomicTypeTag.U64 },
  { name: "rewards_rate_denominator", typeTag: AtomicTypeTag.U64 }];

  minimum_stake: U64;
  maximum_stake: U64;
  min_lockup_duration_secs: U64;
  max_lockup_duration_secs: U64;
  allow_validator_set_change: boolean;
  rewards_rate: U64;
  rewards_rate_denominator: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.minimum_stake = proto['minimum_stake'] as U64;
    this.maximum_stake = proto['maximum_stake'] as U64;
    this.min_lockup_duration_secs = proto['min_lockup_duration_secs'] as U64;
    this.max_lockup_duration_secs = proto['max_lockup_duration_secs'] as U64;
    this.allow_validator_set_change = proto['allow_validator_set_change'] as boolean;
    this.rewards_rate = proto['rewards_rate'] as U64;
    this.rewards_rate_denominator = proto['rewards_rate_denominator'] as U64;
  }

  static ValidatorSetConfigurationParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ValidatorSetConfiguration {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorSetConfiguration);
    return new ValidatorSetConfiguration(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, ValidatorSetConfiguration, typeParams);
    return result as unknown as ValidatorSetConfiguration;
  }
}

export class WithdrawStakeEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "WithdrawStakeEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pool_address", typeTag: AtomicTypeTag.Address },
  { name: "amount_withdrawn", typeTag: AtomicTypeTag.U64 }];

  pool_address: HexString;
  amount_withdrawn: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto['pool_address'] as HexString;
    this.amount_withdrawn = proto['amount_withdrawn'] as U64;
  }

  static WithdrawStakeEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : WithdrawStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, WithdrawStakeEvent);
    return new WithdrawStakeEvent(proto, typeTag);
  }

}
export function add_stake$ (
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  let account_addr, ownership_cap;
  account_addr = std$_.signer$_.address_of$(account, $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), $.copy(account_addr));
  add_stake_with_cap$($.copy(account_addr), ownership_cap, coin$_.withdraw$(account, $.copy(amount), $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]), $c);
  return;
}


export function buildPayload_add_stake (
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::add_stake",
    typeParamStrings,
    [
      $.payloadArg(amount),
    ]
  );

}
export function add_stake_with_cap$ (
  pool_address: HexString,
  owner_cap: OwnerCapability,
  coins: coin$_.Coin,
  $c: AptosDataCache,
): void {
  let amount, maximum_stake, stake_pool, stake_pool_events, total_stake;
  if (!($.copy(owner_cap.pool_address).hex() === $.copy(pool_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OWNER, $c));
  }
  amount = coin$_.value$(coins, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  if (!$.copy(amount).gt(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_STAKE_AMOUNT, $c));
  }
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  if (is_current_epoch_validator$($.copy(pool_address), $c)) {
    coin$_.merge$(stake_pool.pending_active, coins, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  }
  else{
    coin$_.merge$(stake_pool.active, coins, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  }
  maximum_stake = $.copy($c.borrow_global<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1")).maximum_stake);
  total_stake = coin$_.value$(stake_pool.active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]).add(coin$_.value$(stake_pool.pending_active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]));
  if (!$.copy(total_stake).le($.copy(maximum_stake))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ESTAKE_EXCEEDS_MAX, $c));
  }
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.add_stake_events, new AddStakeEvent({ pool_address: $.copy(pool_address), amount_added: $.copy(amount) }, new StructTag(new HexString("0x1"), "stake", "AddStakeEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "AddStakeEvent", [])] as TypeTag[]);
  return;
}

export function append$ (
  v1: any[],
  v2: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  while (!std$_.vector$_.is_empty$(v2, $c, [$p[0]] as TypeTag[])) {
    {
      std$_.vector$_.push_back$(v1, std$_.vector$_.pop_back$(v2, $c, [$p[0]] as TypeTag[]), $c, [$p[0]] as TypeTag[]);
    }

  }return;
}

export function deposit_owner_cap$ (
  account: HexString,
  owner_cap: OwnerCapability,
  $c: AptosDataCache,
): void {
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), account, owner_cap);
  return;
}

export function extract_owner_cap$ (
  account: HexString,
  $c: AptosDataCache,
): OwnerCapability {
  return $c.move_from<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), std$_.signer$_.address_of$(account, $c));
}

export function find_validator$ (
  v: ValidatorInfo[],
  addr: HexString,
  $c: AptosDataCache,
): std$_.option$_.Option {
  let i, len;
  i = u64("0");
  len = std$_.vector$_.length$(v, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      if (($.copy(std$_.vector$_.borrow$(v, $.copy(i), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]).addr).hex() === $.copy(addr).hex())) {
        return std$_.option$_.some$($.copy(i), $c, [AtomicTypeTag.U64] as TypeTag[]);
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }return std$_.option$_.none$($c, [AtomicTypeTag.U64] as TypeTag[]);
}

export function generate_validator_info$ (
  addr: HexString,
  config: ValidatorConfig,
  $c: AptosDataCache,
): ValidatorInfo {
  let stake_pool, voting_power;
  stake_pool = $c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(addr));
  voting_power = coin$_.value$(stake_pool.active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  return new ValidatorInfo({ addr: $.copy(addr), voting_power: $.copy(voting_power), config: $.copy(config) }, new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", []));
}

export function get_active_staked_balance$ (
  pool_address: HexString,
  $c: AptosDataCache,
): U64 {
  let temp$1;
  if (get_validator_state$($.copy(pool_address), $c).eq(VALIDATOR_STATUS_INACTIVE)) {
    temp$1 = u64("0");
  }
  else{
    temp$1 = coin$_.value$($c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address)).active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  }
  return temp$1;
}

export function get_delegated_voter$ (
  pool_address: HexString,
  $c: AptosDataCache,
): HexString {
  return $.copy($c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address)).delegated_voter);
}

export function get_lockup_secs$ (
  pool_address: HexString,
  $c: AptosDataCache,
): U64 {
  return $.copy($c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address)).locked_until_secs);
}

export function get_operator$ (
  pool_address: HexString,
  $c: AptosDataCache,
): HexString {
  return $.copy($c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address)).operator_address);
}

export function get_stake$ (
  pool_address: HexString,
  $c: AptosDataCache,
): [U64, U64, U64, U64] {
  let stake_pool;
  stake_pool = $c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  return [coin$_.value$(stake_pool.active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]), coin$_.value$(stake_pool.inactive, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]), coin$_.value$(stake_pool.pending_active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]), coin$_.value$(stake_pool.pending_inactive, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[])];
}

export function get_validator_state$ (
  pool_address: HexString,
  $c: AptosDataCache,
): U64 {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, validator_set;
  validator_set = $c.borrow_global<ValidatorSet>(new StructTag(new HexString("0x1"), "stake", "ValidatorSet", []), new HexString("0x1"));
  temp$1 = find_validator$(validator_set.pending_active, $.copy(pool_address), $c);
  if (std$_.option$_.is_some$(temp$1, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    temp$6 = VALIDATOR_STATUS_PENDING_ACTIVE;
  }
  else{
    temp$2 = find_validator$(validator_set.active_validators, $.copy(pool_address), $c);
    if (std$_.option$_.is_some$(temp$2, $c, [AtomicTypeTag.U64] as TypeTag[])) {
      temp$5 = VALIDATOR_STATUS_ACTIVE;
    }
    else{
      temp$3 = find_validator$(validator_set.pending_inactive, $.copy(pool_address), $c);
      if (std$_.option$_.is_some$(temp$3, $c, [AtomicTypeTag.U64] as TypeTag[])) {
        temp$4 = VALIDATOR_STATUS_PENDING_INACTIVE;
      }
      else{
        temp$4 = VALIDATOR_STATUS_INACTIVE;
      }
      temp$5 = temp$4;
    }
    temp$6 = temp$5;
  }
  return temp$6;
}

export function increase_lockup$ (
  account: HexString,
  new_locked_until_secs: U64,
  $c: AptosDataCache,
): void {
  let account_addr, ownership_cap;
  account_addr = std$_.signer$_.address_of$(account, $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), $.copy(account_addr));
  increase_lockup_with_cap$($.copy(account_addr), ownership_cap, $.copy(new_locked_until_secs), $c);
  return;
}


export function buildPayload_increase_lockup (
  new_locked_until_secs: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::increase_lockup",
    typeParamStrings,
    [
      $.payloadArg(new_locked_until_secs),
    ]
  );

}
export function increase_lockup_with_cap$ (
  pool_address: HexString,
  owner_cap: OwnerCapability,
  new_locked_until_secs: U64,
  $c: AptosDataCache,
): void {
  let old_locked_until_secs, stake_pool, stake_pool_events, validator_set_config;
  if (!($.copy(owner_cap.pool_address).hex() === $.copy(pool_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OWNER, $c));
  }
  validator_set_config = $c.borrow_global<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  validate_lockup_time$($.copy(new_locked_until_secs), validator_set_config, $c);
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  old_locked_until_secs = $.copy(stake_pool.locked_until_secs);
  stake_pool.locked_until_secs = $.copy(new_locked_until_secs);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.increase_lockup_events, new IncreaseLockupEvent({ pool_address: $.copy(pool_address), old_locked_until_secs: $.copy(old_locked_until_secs), new_locked_until_secs: $.copy(new_locked_until_secs) }, new StructTag(new HexString("0x1"), "stake", "IncreaseLockupEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "IncreaseLockupEvent", [])] as TypeTag[]);
  return;
}

export function initialize_validator_set$ (
  aptos_framework: HexString,
  minimum_stake: U64,
  maximum_stake: U64,
  min_lockup_duration_secs: U64,
  max_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5;
  system_addresses$_.assert_aptos_framework$(aptos_framework, $c);
  validate_required_stake$($.copy(minimum_stake), $.copy(maximum_stake), $c);
  validate_required_lockup$($.copy(min_lockup_duration_secs), $.copy(max_lockup_duration_secs), $c);
  if (!$.copy(rewards_rate_denominator).gt(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_REWARDS_RATE, $c));
  }
  temp$5 = aptos_framework;
  temp$1 = u8("0");
  temp$2 = std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  temp$3 = std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  temp$4 = std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "ValidatorSet", []), temp$5, new ValidatorSet({ consensus_scheme: temp$1, active_validators: temp$2, pending_inactive: temp$4, pending_active: temp$3 }, new StructTag(new HexString("0x1"), "stake", "ValidatorSet", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), aptos_framework, new ValidatorSetConfiguration({ minimum_stake: $.copy(minimum_stake), maximum_stake: $.copy(maximum_stake), min_lockup_duration_secs: $.copy(min_lockup_duration_secs), max_lockup_duration_secs: $.copy(max_lockup_duration_secs), allow_validator_set_change: allow_validator_set_change, rewards_rate: $.copy(rewards_rate), rewards_rate_denominator: $.copy(rewards_rate_denominator) }, new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "ValidatorPerformance", []), aptos_framework, new ValidatorPerformance({ num_blocks: u64("0"), missed_votes: std$_.vector$_.empty$($c, [AtomicTypeTag.U64] as TypeTag[]) }, new StructTag(new HexString("0x1"), "stake", "ValidatorPerformance", [])));
  return;
}

export function is_current_epoch_validator$ (
  addr: HexString,
  $c: AptosDataCache,
): boolean {
  let temp$1, temp$2, temp$3, validator_set;
  validator_set = $c.borrow_global<ValidatorSet>(new StructTag(new HexString("0x1"), "stake", "ValidatorSet", []), new HexString("0x1"));
  temp$1 = find_validator$(validator_set.active_validators, $.copy(addr), $c);
  if (std$_.option$_.is_some$(temp$1, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    temp$3 = true;
  }
  else{
    temp$2 = find_validator$(validator_set.pending_inactive, $.copy(addr), $c);
    temp$3 = std$_.option$_.is_some$(temp$2, $c, [AtomicTypeTag.U64] as TypeTag[]);
  }
  return temp$3;
}

export function join_validator_set$ (
  account: HexString,
  pool_address: HexString,
  $c: AptosDataCache,
): void {
  let validator_set_config;
  validator_set_config = $c.borrow_global<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  if (!$.copy(validator_set_config.allow_validator_set_change)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENO_POST_GENESIS_VALIDATOR_SET_CHANGE_ALLOWED, $c));
  }
  join_validator_set_internal$(account, $.copy(pool_address), $c);
  return;
}


export function buildPayload_join_validator_set (
  pool_address: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::join_validator_set",
    typeParamStrings,
    [
      $.payloadArg(pool_address),
    ]
  );

}
export function join_validator_set_internal$ (
  account: HexString,
  pool_address: HexString,
  $c: AptosDataCache,
): void {
  let stake_pool, stake_pool_events, validator_config, validator_set, validator_set_config, voting_power;
  stake_pool = $c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  if (!(std$_.signer$_.address_of$(account, $c).hex() === $.copy(stake_pool.operator_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OPERATOR, $c));
  }
  validator_set_config = $c.borrow_global<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  validate_lockup_time$($.copy(stake_pool.locked_until_secs), validator_set_config, $c);
  if (!get_validator_state$($.copy(pool_address), $c).eq(VALIDATOR_STATUS_INACTIVE)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EALREADY_ACTIVE_VALIDATOR, $c));
  }
  voting_power = coin$_.value$(stake_pool.active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  if (!$.copy(voting_power).ge($.copy(validator_set_config.minimum_stake))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ESTAKE_TOO_LOW, $c));
  }
  if (!$.copy(voting_power).le($.copy(validator_set_config.maximum_stake))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ESTAKE_TOO_HIGH, $c));
  }
  validator_config = $c.borrow_global_mut<ValidatorConfig>(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address));
  validator_set = $c.borrow_global_mut<ValidatorSet>(new StructTag(new HexString("0x1"), "stake", "ValidatorSet", []), new HexString("0x1"));
  std$_.vector$_.push_back$(validator_set.pending_active, generate_validator_info$($.copy(pool_address), $.copy(validator_config), $c), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.join_validator_set_events, new JoinValidatorSetEvent({ pool_address: $.copy(pool_address) }, new StructTag(new HexString("0x1"), "stake", "JoinValidatorSetEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "JoinValidatorSetEvent", [])] as TypeTag[]);
  return;
}

export function leave_validator_set$ (
  account: HexString,
  pool_address: HexString,
  $c: AptosDataCache,
): void {
  let index, maybe_index, stake_pool, stake_pool_events, validator_info, validator_set, validator_set_config;
  validator_set_config = $c.borrow_global_mut<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  if (!$.copy(validator_set_config.allow_validator_set_change)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENO_POST_GENESIS_VALIDATOR_SET_CHANGE_ALLOWED, $c));
  }
  stake_pool = $c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  if (!(std$_.signer$_.address_of$(account, $c).hex() === $.copy(stake_pool.operator_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OPERATOR, $c));
  }
  validator_set = $c.borrow_global_mut<ValidatorSet>(new StructTag(new HexString("0x1"), "stake", "ValidatorSet", []), new HexString("0x1"));
  maybe_index = find_validator$(validator_set.active_validators, $.copy(pool_address), $c);
  if (!std$_.option$_.is_some$(maybe_index, $c, [AtomicTypeTag.U64] as TypeTag[])) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_VALIDATOR, $c));
  }
  index = std$_.option$_.extract$(maybe_index, $c, [AtomicTypeTag.U64] as TypeTag[]);
  validator_info = std$_.vector$_.swap_remove$(validator_set.active_validators, $.copy(index), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  if (!std$_.vector$_.length$(validator_set.active_validators, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]).gt(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ELAST_VALIDATOR, $c));
  }
  std$_.vector$_.push_back$(validator_set.pending_inactive, $.copy(validator_info), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.leave_validator_set_events, new LeaveValidatorSetEvent({ pool_address: $.copy(pool_address) }, new StructTag(new HexString("0x1"), "stake", "LeaveValidatorSetEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "LeaveValidatorSetEvent", [])] as TypeTag[]);
  return;
}


export function buildPayload_leave_validator_set (
  pool_address: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::leave_validator_set",
    typeParamStrings,
    [
      $.payloadArg(pool_address),
    ]
  );

}
export function mint_reward$ (
  voting_power: U64,
  num_blocks: U64,
  num_successful_votes: U64,
  remaining_lockup_time: U64,
  validator_set_config: ValidatorSetConfiguration,
  $c: AptosDataCache,
): coin$_.Coin {
  let base_rewards, mint_cap, rewards_amount, rewards_denominator;
  base_rewards = $.copy(voting_power).mul($.copy(validator_set_config.rewards_rate)).div($.copy(validator_set_config.rewards_rate_denominator));
  rewards_denominator = $.copy(num_blocks).mul($.copy(validator_set_config.max_lockup_duration_secs));
  rewards_amount = $.copy(base_rewards).mul($.copy(num_successful_votes)).mul($.copy(remaining_lockup_time)).div($.copy(rewards_denominator));
  if ($.copy(rewards_amount).gt(u64("0"))) {
    mint_cap = $c.borrow_global<TestCoinCapabilities>(new StructTag(new HexString("0x1"), "stake", "TestCoinCapabilities", []), new HexString("0x1")).mint_cap;
    return coin$_.mint$($.copy(rewards_amount), mint_cap, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  }
  else{
  }
  return coin$_.zero$($c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
}

export function on_new_epoch$ (
  $c: AptosDataCache,
): void {
  let temp$1, temp$10, temp$11, temp$2, temp$3, temp$4, temp$8, temp$9, active_validators, i, i__12, i__14, i__5, len, len__13, len__15, len__6, new_validator_info, old_validator_info, pool_address, pool_address__16, validator, validator__7, validator_config, validator_config__17, validator_info, validator_perf, validator_set, validator_set_config;
  validator_set = $c.borrow_global_mut<ValidatorSet>(new StructTag(new HexString("0x1"), "stake", "ValidatorSet", []), new HexString("0x1"));
  validator_set_config = $c.borrow_global_mut<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  validator_perf = $c.borrow_global_mut<ValidatorPerformance>(new StructTag(new HexString("0x1"), "stake", "ValidatorPerformance", []), new HexString("0x1"));
  i = u64("0");
  len = std$_.vector$_.length$(validator_set.active_validators, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      validator = std$_.vector$_.borrow$(validator_set.active_validators, $.copy(i), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
      [temp$1, temp$2, temp$3, temp$4] = [validator, validator_perf, $.copy(validator.addr), validator_set_config];
      update_stake_pool$(temp$1, temp$2, temp$3, temp$4, $c);
      i = $.copy(i).add(u64("1"));
    }

  }i__5 = u64("0");
  len__6 = std$_.vector$_.length$(validator_set.pending_inactive, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  while ($.copy(i__5).lt($.copy(len__6))) {
    {
      validator__7 = std$_.vector$_.borrow$(validator_set.pending_inactive, $.copy(i__5), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
      [temp$8, temp$9, temp$10, temp$11] = [validator__7, validator_perf, $.copy(validator__7.addr), validator_set_config];
      update_stake_pool$(temp$8, temp$9, temp$10, temp$11, $c);
      i__5 = $.copy(i__5).add(u64("1"));
    }

  }append$(validator_set.active_validators, validator_set.pending_active, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  validator_set.pending_inactive = std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  i__12 = u64("0");
  len__13 = std$_.vector$_.length$(validator_set.active_validators, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  active_validators = std$_.vector$_.empty$($c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  validator_perf.num_blocks = u64("0");
  validator_perf.missed_votes = std$_.vector$_.empty$($c, [AtomicTypeTag.U64] as TypeTag[]);
  while ($.copy(i__12).lt($.copy(len__13))) {
    {
      old_validator_info = std$_.vector$_.borrow_mut$(validator_set.active_validators, $.copy(i__12), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
      pool_address = $.copy(old_validator_info.addr);
      validator_config = $c.borrow_global_mut<ValidatorConfig>(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address));
      new_validator_info = generate_validator_info$($.copy(pool_address), $.copy(validator_config), $c);
      if ($.copy(new_validator_info.voting_power).gt($.copy(validator_set_config.maximum_stake))) {
        new_validator_info.voting_power = $.copy(validator_set_config.maximum_stake);
      }
      else{
      }
      if ($.copy(new_validator_info.voting_power).ge($.copy(validator_set_config.minimum_stake))) {
        std$_.vector$_.push_back$(active_validators, $.copy(new_validator_info), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
        std$_.vector$_.push_back$(validator_perf.missed_votes, u64("0"), $c, [AtomicTypeTag.U64] as TypeTag[]);
      }
      else{
      }
      i__12 = $.copy(i__12).add(u64("1"));
    }

  }sort_validators$(active_validators, $c);
  i__14 = u64("0");
  len__15 = std$_.vector$_.length$(active_validators, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  while ($.copy(i__14).lt($.copy(len__15))) {
    {
      validator_info = std$_.vector$_.borrow_mut$(active_validators, $.copy(i__14), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
      pool_address__16 = $.copy(validator_info.addr);
      validator_config__17 = $c.borrow_global_mut<ValidatorConfig>(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address__16));
      validator_config__17.validator_index = $.copy(i__14);
      validator_info.config.validator_index = $.copy(i__14);
      i__14 = $.copy(i__14).add(u64("1"));
    }

  }validator_set.active_validators = $.copy(active_validators);
  return;
}

export function register_validator_candidate$ (
  account: HexString,
  consensus_pubkey: U8[],
  proof_of_possession: U8[],
  network_addresses: U8[],
  fullnode_addresses: U8[],
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, account_address;
  account_address = std$_.signer$_.address_of$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(account_address))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EALREADY_REGISTERED, $c));
  }
  if (!signature$_.bls12381_validate_pubkey$($.copy(consensus_pubkey), $.copy(proof_of_possession), $c)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_PUBLIC_KEY, $c));
  }
  temp$8 = account;
  temp$1 = coin$_.zero$($c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  temp$2 = coin$_.zero$($c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  temp$3 = coin$_.zero$($c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  temp$4 = coin$_.zero$($c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  temp$5 = u64("0");
  temp$6 = $.copy(account_address);
  temp$7 = $.copy(account_address);
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "StakePool", []), temp$8, new StakePool({ active: temp$1, inactive: temp$4, pending_active: temp$2, pending_inactive: temp$3, locked_until_secs: temp$5, operator_address: temp$6, delegated_voter: temp$7 }, new StructTag(new HexString("0x1"), "stake", "StakePool", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), account, new StakePoolEvents({ register_validator_candidate_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "RegisterValidatorCandidateEvent", [])] as TypeTag[]), set_operator_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "SetOperatorEvent", [])] as TypeTag[]), add_stake_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "AddStakeEvent", [])] as TypeTag[]), rotate_consensus_key_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "RotateConsensusKeyEvent", [])] as TypeTag[]), update_network_and_fullnode_addresses_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "UpdateNetworkAndFullnodeAddressesEvent", [])] as TypeTag[]), increase_lockup_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "IncreaseLockupEvent", [])] as TypeTag[]), join_validator_set_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "JoinValidatorSetEvent", [])] as TypeTag[]), distribute_rewards_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "DistributeRewardsEvent", [])] as TypeTag[]), unlock_stake_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "UnlockStakeEvent", [])] as TypeTag[]), withdraw_stake_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "WithdrawStakeEvent", [])] as TypeTag[]), leave_validator_set_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "stake", "LeaveValidatorSetEvent", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), account, new ValidatorConfig({ consensus_pubkey: $.copy(consensus_pubkey), network_addresses: $.copy(network_addresses), fullnode_addresses: $.copy(fullnode_addresses), validator_index: u64("0") }, new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), account, new OwnerCapability({ pool_address: $.copy(account_address) }, new StructTag(new HexString("0x1"), "stake", "OwnerCapability", [])));
  return;
}


export function buildPayload_register_validator_candidate (
  consensus_pubkey: U8[],
  proof_of_possession: U8[],
  network_addresses: U8[],
  fullnode_addresses: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::register_validator_candidate",
    typeParamStrings,
    [
      $.u8ArrayArg(consensus_pubkey),
      $.u8ArrayArg(proof_of_possession),
      $.u8ArrayArg(network_addresses),
      $.u8ArrayArg(fullnode_addresses),
    ]
  );

}
export function rotate_consensus_key$ (
  account: HexString,
  pool_address: HexString,
  new_consensus_pubkey: U8[],
  proof_of_possession: U8[],
  $c: AptosDataCache,
): void {
  let old_consensus_pubkey, stake_pool, stake_pool_events, validator_info;
  stake_pool = $c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  if (!(std$_.signer$_.address_of$(account, $c).hex() === $.copy(stake_pool.operator_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OPERATOR, $c));
  }
  if (!$c.exists(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address))) {
    throw $.abortCode(std$_.errors$_.not_published$(EVALIDATOR_CONFIG, $c));
  }
  validator_info = $c.borrow_global_mut<ValidatorConfig>(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address));
  old_consensus_pubkey = $.copy(validator_info.consensus_pubkey);
  if (!signature$_.bls12381_validate_pubkey$($.copy(new_consensus_pubkey), $.copy(proof_of_possession), $c)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_PUBLIC_KEY, $c));
  }
  validator_info.consensus_pubkey = $.copy(new_consensus_pubkey);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.rotate_consensus_key_events, new RotateConsensusKeyEvent({ pool_address: $.copy(pool_address), old_consensus_pubkey: $.copy(old_consensus_pubkey), new_consensus_pubkey: $.copy(new_consensus_pubkey) }, new StructTag(new HexString("0x1"), "stake", "RotateConsensusKeyEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "RotateConsensusKeyEvent", [])] as TypeTag[]);
  return;
}


export function buildPayload_rotate_consensus_key (
  pool_address: HexString,
  new_consensus_pubkey: U8[],
  proof_of_possession: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::rotate_consensus_key",
    typeParamStrings,
    [
      $.payloadArg(pool_address),
      $.u8ArrayArg(new_consensus_pubkey),
      $.u8ArrayArg(proof_of_possession),
    ]
  );

}
export function set_delegated_voter$ (
  account: HexString,
  new_delegated_voter: HexString,
  $c: AptosDataCache,
): void {
  let account_addr, ownership_cap;
  account_addr = std$_.signer$_.address_of$(account, $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), $.copy(account_addr));
  set_delegated_voter_with_cap$($.copy(account_addr), ownership_cap, $.copy(new_delegated_voter), $c);
  return;
}


export function buildPayload_set_delegated_voter (
  new_delegated_voter: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::set_delegated_voter",
    typeParamStrings,
    [
      $.payloadArg(new_delegated_voter),
    ]
  );

}
export function set_delegated_voter_with_cap$ (
  pool_address: HexString,
  owner_cap: OwnerCapability,
  new_delegated_voter: HexString,
  $c: AptosDataCache,
): void {
  let stake_pool;
  if (!($.copy(owner_cap.pool_address).hex() === $.copy(pool_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OWNER, $c));
  }
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  stake_pool.delegated_voter = $.copy(new_delegated_voter);
  return;
}

export function set_operator$ (
  account: HexString,
  new_operator: HexString,
  $c: AptosDataCache,
): void {
  let account_addr, ownership_cap;
  account_addr = std$_.signer$_.address_of$(account, $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), $.copy(account_addr));
  set_operator_with_cap$($.copy(account_addr), ownership_cap, $.copy(new_operator), $c);
  return;
}


export function buildPayload_set_operator (
  new_operator: HexString,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::set_operator",
    typeParamStrings,
    [
      $.payloadArg(new_operator),
    ]
  );

}
export function set_operator_with_cap$ (
  pool_address: HexString,
  owner_cap: OwnerCapability,
  new_operator: HexString,
  $c: AptosDataCache,
): void {
  let old_operator, stake_pool, stake_pool_events;
  if (!($.copy(owner_cap.pool_address).hex() === $.copy(pool_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OWNER, $c));
  }
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  old_operator = $.copy(stake_pool.operator_address);
  stake_pool.operator_address = $.copy(new_operator);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.set_operator_events, new SetOperatorEvent({ pool_address: $.copy(pool_address), old_operator: $.copy(old_operator), new_operator: $.copy(new_operator) }, new StructTag(new HexString("0x1"), "stake", "SetOperatorEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "SetOperatorEvent", [])] as TypeTag[]);
  return;
}

export function sort_validators$ (
  validators: ValidatorInfo[],
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, idx, left, length, ordered, right;
  length = std$_.vector$_.length$(validators, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
  if ($.copy(length).eq(u64("0"))) {
    return;
  }
  else{
  }
  ordered = false;
  while (!ordered) {
    {
      ordered = true;
      idx = u64("0");
      while ($.copy(idx).lt($.copy(length).sub(u64("1")))) {
        {
          [temp$1, temp$2] = [validators, $.copy(idx)];
          left = std$_.vector$_.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
          [temp$3, temp$4] = [validators, $.copy(idx).add(u64("1"))];
          right = std$_.vector$_.borrow$(temp$3, temp$4, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
          temp$5 = comparator$_.compare$(left, right, $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
          if (comparator$_.is_greater_than$(temp$5, $c)) {
            ordered = false;
            std$_.vector$_.swap$(validators, $.copy(idx), $.copy(idx).add(u64("1")), $c, [new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])] as TypeTag[]);
          }
          else{
          }
          idx = $.copy(idx).add(u64("1"));
        }

      }}

  }return;
}

export function store_test_coin_mint_cap$ (
  account: HexString,
  mint_cap: coin$_.MintCapability,
  $c: AptosDataCache,
): void {
  system_addresses$_.assert_aptos_framework$(account, $c);
  return $c.move_to(new StructTag(new HexString("0x1"), "stake", "TestCoinCapabilities", []), account, new TestCoinCapabilities({ mint_cap: $.copy(mint_cap) }, new StructTag(new HexString("0x1"), "stake", "TestCoinCapabilities", [])));
}

export function unlock$ (
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  let account_addr, ownership_cap;
  account_addr = std$_.signer$_.address_of$(account, $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), $.copy(account_addr));
  unlock_with_cap$($.copy(account_addr), $.copy(amount), ownership_cap, $c);
  return;
}


export function buildPayload_unlock (
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::unlock",
    typeParamStrings,
    [
      $.payloadArg(amount),
    ]
  );

}
export function unlock_with_cap$ (
  pool_address: HexString,
  amount: U64,
  owner_cap: OwnerCapability,
  $c: AptosDataCache,
): void {
  let stake_pool, stake_pool_events, unlocked_stake;
  if (!($.copy(owner_cap.pool_address).hex() === $.copy(pool_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OWNER, $c));
  }
  if ($.copy(amount).eq(u64("0"))) {
    return;
  }
  else{
  }
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  unlocked_stake = coin$_.extract$(stake_pool.active, $.copy(amount), $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  if ($.copy(stake_pool.locked_until_secs).gt(timestamp$_.now_seconds$($c))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EWITHDRAW_NOT_ALLOWED, $c));
  }
  else{
  }
  if (is_current_epoch_validator$($.copy(pool_address), $c)) {
    coin$_.merge$(stake_pool.pending_inactive, unlocked_stake, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  }
  else{
    coin$_.merge$(stake_pool.inactive, unlocked_stake, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  }
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.unlock_stake_events, new UnlockStakeEvent({ pool_address: $.copy(pool_address), amount_unlocked: $.copy(amount) }, new StructTag(new HexString("0x1"), "stake", "UnlockStakeEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "UnlockStakeEvent", [])] as TypeTag[]);
  return;
}

export function update_network_and_fullnode_addresses$ (
  account: HexString,
  pool_address: HexString,
  new_network_addresses: U8[],
  new_fullnode_addresses: U8[],
  $c: AptosDataCache,
): void {
  let old_fullnode_addresses, old_network_addresses, stake_pool, stake_pool_events, validator_info;
  stake_pool = $c.borrow_global<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  if (!(std$_.signer$_.address_of$(account, $c).hex() === $.copy(stake_pool.operator_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OPERATOR, $c));
  }
  if (!$c.exists(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address))) {
    throw $.abortCode(std$_.errors$_.not_published$(EVALIDATOR_CONFIG, $c));
  }
  validator_info = $c.borrow_global_mut<ValidatorConfig>(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address));
  old_network_addresses = $.copy(validator_info.network_addresses);
  validator_info.network_addresses = $.copy(new_network_addresses);
  old_fullnode_addresses = $.copy(validator_info.fullnode_addresses);
  validator_info.fullnode_addresses = $.copy(new_fullnode_addresses);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.update_network_and_fullnode_addresses_events, new UpdateNetworkAndFullnodeAddressesEvent({ pool_address: $.copy(pool_address), old_network_addresses: $.copy(old_network_addresses), new_network_addresses: $.copy(new_network_addresses), old_fullnode_addresses: $.copy(old_fullnode_addresses), new_fullnode_addresses: $.copy(new_fullnode_addresses) }, new StructTag(new HexString("0x1"), "stake", "UpdateNetworkAndFullnodeAddressesEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "UpdateNetworkAndFullnodeAddressesEvent", [])] as TypeTag[]);
  return;
}


export function buildPayload_update_network_and_fullnode_addresses (
  pool_address: HexString,
  new_network_addresses: U8[],
  new_fullnode_addresses: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::update_network_and_fullnode_addresses",
    typeParamStrings,
    [
      $.payloadArg(pool_address),
      $.u8ArrayArg(new_network_addresses),
      $.u8ArrayArg(new_fullnode_addresses),
    ]
  );

}
export function update_performance_statistics$ (
  missed_votes: U64[],
  $c: AptosDataCache,
): void {
  let i, len, missed_votes_count, validator_index, validator_missed_votes_counts, validator_perf;
  validator_perf = $c.borrow_global_mut<ValidatorPerformance>(new StructTag(new HexString("0x1"), "stake", "ValidatorPerformance", []), new HexString("0x1"));
  validator_missed_votes_counts = validator_perf.missed_votes;
  i = u64("0");
  len = std$_.vector$_.length$(missed_votes, $c, [AtomicTypeTag.U64] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      validator_index = $.copy(std$_.vector$_.borrow$(missed_votes, $.copy(i), $c, [AtomicTypeTag.U64] as TypeTag[]));
      if ($.copy(validator_index).lt(std$_.vector$_.length$(validator_missed_votes_counts, $c, [AtomicTypeTag.U64] as TypeTag[]))) {
        missed_votes_count = std$_.vector$_.borrow_mut$(validator_missed_votes_counts, $.copy(validator_index), $c, [AtomicTypeTag.U64] as TypeTag[]);
        $.set(missed_votes_count, $.copy(missed_votes_count).add(u64("1")));
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }validator_perf.num_blocks = $.copy(validator_perf.num_blocks).add(u64("1"));
  return;
}

export function update_required_lockup$ (
  _gov_proposal: governance_proposal$_.GovernanceProposal,
  min_lockup_duration_secs: U64,
  max_lockup_duration_secs: U64,
  $c: AptosDataCache,
): void {
  let validator_set_config;
  validate_required_lockup$($.copy(min_lockup_duration_secs), $.copy(max_lockup_duration_secs), $c);
  validator_set_config = $c.borrow_global_mut<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  validator_set_config.min_lockup_duration_secs = $.copy(min_lockup_duration_secs);
  validator_set_config.max_lockup_duration_secs = $.copy(max_lockup_duration_secs);
  return;
}

export function update_required_stake$ (
  _gov_proposal: governance_proposal$_.GovernanceProposal,
  minimum_stake: U64,
  maximum_stake: U64,
  $c: AptosDataCache,
): void {
  let validator_set_config;
  validate_required_stake$($.copy(minimum_stake), $.copy(maximum_stake), $c);
  validator_set_config = $c.borrow_global_mut<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  validator_set_config.minimum_stake = $.copy(minimum_stake);
  validator_set_config.maximum_stake = $.copy(maximum_stake);
  return;
}

export function update_rewards_rate$ (
  _gov_proposal: governance_proposal$_.GovernanceProposal,
  new_rewards_rate: U64,
  new_rewards_rate_denominator: U64,
  $c: AptosDataCache,
): void {
  let validator_set_config;
  if (!$.copy(new_rewards_rate_denominator).gt(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_REWARDS_RATE, $c));
  }
  validator_set_config = $c.borrow_global_mut<ValidatorSetConfiguration>(new StructTag(new HexString("0x1"), "stake", "ValidatorSetConfiguration", []), new HexString("0x1"));
  validator_set_config.rewards_rate = $.copy(new_rewards_rate);
  validator_set_config.rewards_rate_denominator = $.copy(new_rewards_rate_denominator);
  return;
}

export function update_stake_pool$ (
  validator: ValidatorInfo,
  validator_perf: ValidatorPerformance,
  pool_address: HexString,
  validator_set_config: ValidatorSetConfiguration,
  $c: AptosDataCache,
): void {
  let current_time, num_blocks, num_missed_votes, num_successful_votes, remaining_lockup_time, rewards, rewards_amount, stake_pool, stake_pool_events, validator_config;
  validator_config = $c.borrow_global<ValidatorConfig>(new StructTag(new HexString("0x1"), "stake", "ValidatorConfig", []), $.copy(pool_address));
  num_missed_votes = $.copy(std$_.vector$_.borrow$(validator_perf.missed_votes, $.copy(validator_config.validator_index), $c, [AtomicTypeTag.U64] as TypeTag[]));
  num_blocks = $.copy(validator_perf.num_blocks);
  num_successful_votes = $.copy(num_blocks).sub($.copy(num_missed_votes));
  current_time = timestamp$_.now_seconds$($c);
  remaining_lockup_time = u64("1");
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  if ($.copy(current_time).lt($.copy(stake_pool.locked_until_secs))) {
    remaining_lockup_time = $.copy(stake_pool.locked_until_secs).sub($.copy(current_time));
  }
  else{
  }
  rewards = mint_reward$($.copy(validator.voting_power), $.copy(num_blocks), $.copy(num_successful_votes), $.copy(remaining_lockup_time), validator_set_config, $c);
  rewards_amount = coin$_.value$(rewards, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  coin$_.merge$(stake_pool.active, rewards, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  coin$_.merge$(stake_pool.active, coin$_.extract_all$(stake_pool.pending_active, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]), $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  coin$_.merge$(stake_pool.inactive, coin$_.extract_all$(stake_pool.pending_inactive, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]), $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.distribute_rewards_events, new DistributeRewardsEvent({ pool_address: $.copy(pool_address), rewards_amount: $.copy(rewards_amount) }, new StructTag(new HexString("0x1"), "stake", "DistributeRewardsEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "DistributeRewardsEvent", [])] as TypeTag[]);
  return;
}

export function validate_lockup_time$ (
  locked_until_secs: U64,
  validator_set_config: ValidatorSetConfiguration,
  $c: AptosDataCache,
): void {
  let current_time;
  current_time = timestamp$_.now_seconds$($c);
  if ($.copy(current_time).eq(u64("0"))) {
    return;
  }
  else{
  }
  if (!$.copy(current_time).add($.copy(validator_set_config.min_lockup_duration_secs)).le($.copy(locked_until_secs))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ELOCK_TIME_TOO_SHORT, $c));
  }
  if (!$.copy(locked_until_secs).le($.copy(current_time).add($.copy(validator_set_config.max_lockup_duration_secs)))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ELOCK_TIME_TOO_LONG, $c));
  }
  return;
}

export function validate_required_lockup$ (
  min_lockup_duration_secs: U64,
  max_lockup_duration_secs: U64,
  $c: AptosDataCache,
): void {
  let temp$1;
  if ($.copy(min_lockup_duration_secs).le($.copy(max_lockup_duration_secs))) {
    temp$1 = $.copy(max_lockup_duration_secs).gt(u64("0"));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_LOCKUP_RANGE, $c));
  }
  return;
}

export function validate_required_stake$ (
  minimum_stake: U64,
  maximum_stake: U64,
  $c: AptosDataCache,
): void {
  let temp$1;
  if ($.copy(minimum_stake).le($.copy(maximum_stake))) {
    temp$1 = $.copy(maximum_stake).gt(u64("0"));
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EINVALID_STAKE_RANGE, $c));
  }
  return;
}

export function withdraw$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  let account_addr, coins, ownership_cap;
  account_addr = std$_.signer$_.address_of$(account, $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(new StructTag(new HexString("0x1"), "stake", "OwnerCapability", []), $.copy(account_addr));
  coins = withdraw_with_cap$($.copy(account_addr), ownership_cap, $c);
  coin$_.deposit$($.copy(account_addr), coins, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  return;
}


export function buildPayload_withdraw (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::stake::withdraw",
    typeParamStrings,
    []
  );

}
export function withdraw_with_cap$ (
  pool_address: HexString,
  owner_cap: OwnerCapability,
  $c: AptosDataCache,
): coin$_.Coin {
  let stake_pool, stake_pool_events, withdraw_amount;
  if (!($.copy(owner_cap.pool_address).hex() === $.copy(pool_address).hex())) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENOT_OWNER, $c));
  }
  stake_pool = $c.borrow_global_mut<StakePool>(new StructTag(new HexString("0x1"), "stake", "StakePool", []), $.copy(pool_address));
  withdraw_amount = coin$_.value$(stake_pool.inactive, $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
  if (!$.copy(withdraw_amount).gt(u64("0"))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(ENO_COINS_TO_WITHDRAW, $c));
  }
  stake_pool_events = $c.borrow_global_mut<StakePoolEvents>(new StructTag(new HexString("0x1"), "stake", "StakePoolEvents", []), $.copy(pool_address));
  std$_.event$_.emit_event$(stake_pool_events.withdraw_stake_events, new WithdrawStakeEvent({ pool_address: $.copy(pool_address), amount_withdrawn: $.copy(withdraw_amount) }, new StructTag(new HexString("0x1"), "stake", "WithdrawStakeEvent", [])), $c, [new StructTag(new HexString("0x1"), "stake", "WithdrawStakeEvent", [])] as TypeTag[]);
  return coin$_.extract$(stake_pool.inactive, $.copy(withdraw_amount), $c, [new StructTag(new HexString("0x1"), "test_coin", "TestCoin", [])] as TypeTag[]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::stake::AddStakeEvent", AddStakeEvent.AddStakeEventParser);
  repo.addParser("0x1::stake::DistributeRewardsEvent", DistributeRewardsEvent.DistributeRewardsEventParser);
  repo.addParser("0x1::stake::IncreaseLockupEvent", IncreaseLockupEvent.IncreaseLockupEventParser);
  repo.addParser("0x1::stake::JoinValidatorSetEvent", JoinValidatorSetEvent.JoinValidatorSetEventParser);
  repo.addParser("0x1::stake::LeaveValidatorSetEvent", LeaveValidatorSetEvent.LeaveValidatorSetEventParser);
  repo.addParser("0x1::stake::OwnerCapability", OwnerCapability.OwnerCapabilityParser);
  repo.addParser("0x1::stake::RegisterValidatorCandidateEvent", RegisterValidatorCandidateEvent.RegisterValidatorCandidateEventParser);
  repo.addParser("0x1::stake::RotateConsensusKeyEvent", RotateConsensusKeyEvent.RotateConsensusKeyEventParser);
  repo.addParser("0x1::stake::SetOperatorEvent", SetOperatorEvent.SetOperatorEventParser);
  repo.addParser("0x1::stake::StakePool", StakePool.StakePoolParser);
  repo.addParser("0x1::stake::StakePoolEvents", StakePoolEvents.StakePoolEventsParser);
  repo.addParser("0x1::stake::TestCoinCapabilities", TestCoinCapabilities.TestCoinCapabilitiesParser);
  repo.addParser("0x1::stake::UnlockStakeEvent", UnlockStakeEvent.UnlockStakeEventParser);
  repo.addParser("0x1::stake::UpdateNetworkAndFullnodeAddressesEvent", UpdateNetworkAndFullnodeAddressesEvent.UpdateNetworkAndFullnodeAddressesEventParser);
  repo.addParser("0x1::stake::ValidatorConfig", ValidatorConfig.ValidatorConfigParser);
  repo.addParser("0x1::stake::ValidatorInfo", ValidatorInfo.ValidatorInfoParser);
  repo.addParser("0x1::stake::ValidatorPerformance", ValidatorPerformance.ValidatorPerformanceParser);
  repo.addParser("0x1::stake::ValidatorSet", ValidatorSet.ValidatorSetParser);
  repo.addParser("0x1::stake::ValidatorSetConfiguration", ValidatorSetConfiguration.ValidatorSetConfigurationParser);
  repo.addParser("0x1::stake::WithdrawStakeEvent", WithdrawStakeEvent.WithdrawStakeEventParser);
}

