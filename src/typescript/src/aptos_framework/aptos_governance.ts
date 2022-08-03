import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
import * as Account from "./account";
import * as Coin from "./coin";
import * as Governance_proposal from "./governance_proposal";
import * as Reconfiguration from "./reconfiguration";
import * as Stake from "./stake";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
import * as Voting from "./voting";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aptos_governance";

export const EALREADY_VOTED : U64 = u64("4");
export const EINSUFFICIENT_PROPOSER_STAKE : U64 = u64("1");
export const EINSUFFICIENT_STAKE_LOCKUP : U64 = u64("3");
export const ENOT_DELEGATED_VOTER : U64 = u64("2");
export const ENO_VOTING_POWER : U64 = u64("5");


export class CreateProposalEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CreateProposalEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "proposer", typeTag: AtomicTypeTag.Address },
  { name: "stake_pool", typeTag: AtomicTypeTag.Address },
  { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
  { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "metadata_location", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "metadata_hash", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  proposer: HexString;
  stake_pool: HexString;
  proposal_id: U64;
  execution_hash: U8[];
  metadata_location: U8[];
  metadata_hash: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposer = proto['proposer'] as HexString;
    this.stake_pool = proto['stake_pool'] as HexString;
    this.proposal_id = proto['proposal_id'] as U64;
    this.execution_hash = proto['execution_hash'] as U8[];
    this.metadata_location = proto['metadata_location'] as U8[];
    this.metadata_hash = proto['metadata_hash'] as U8[];
  }

  static CreateProposalEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CreateProposalEvent {
    const proto = $.parseStructProto(data, typeTag, repo, CreateProposalEvent);
    return new CreateProposalEvent(proto, typeTag);
  }

}

export class GovernanceConfig 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GovernanceConfig";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "min_voting_threshold", typeTag: AtomicTypeTag.U128 },
  { name: "required_proposer_stake", typeTag: AtomicTypeTag.U64 },
  { name: "voting_period_secs", typeTag: AtomicTypeTag.U64 }];

  min_voting_threshold: U128;
  required_proposer_stake: U64;
  voting_period_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.min_voting_threshold = proto['min_voting_threshold'] as U128;
    this.required_proposer_stake = proto['required_proposer_stake'] as U64;
    this.voting_period_secs = proto['voting_period_secs'] as U64;
  }

  static GovernanceConfigParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GovernanceConfig {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceConfig);
    return new GovernanceConfig(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, GovernanceConfig, typeParams);
    return result as unknown as GovernanceConfig;
  }
}

export class GovernanceEvents 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GovernanceEvents";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "create_proposal_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "aptos_governance", "CreateProposalEvent", [])]) },
  { name: "update_config_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "aptos_governance", "UpdateConfigEvent", [])]) },
  { name: "vote_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "aptos_governance", "VoteEvent", [])]) }];

  create_proposal_events: Aptos_std.Event.EventHandle;
  update_config_events: Aptos_std.Event.EventHandle;
  vote_events: Aptos_std.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.create_proposal_events = proto['create_proposal_events'] as Aptos_std.Event.EventHandle;
    this.update_config_events = proto['update_config_events'] as Aptos_std.Event.EventHandle;
    this.vote_events = proto['vote_events'] as Aptos_std.Event.EventHandle;
  }

  static GovernanceEventsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GovernanceEvents {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceEvents);
    return new GovernanceEvents(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, GovernanceEvents, typeParams);
    return result as unknown as GovernanceEvents;
  }
}

export class GovernanceResponsbility 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GovernanceResponsbility";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "signer_cap", typeTag: new StructTag(new HexString("0x1"), "account", "SignerCapability", []) }];

  signer_cap: Account.SignerCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.signer_cap = proto['signer_cap'] as Account.SignerCapability;
  }

  static GovernanceResponsbilityParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GovernanceResponsbility {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceResponsbility);
    return new GovernanceResponsbility(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, GovernanceResponsbility, typeParams);
    return result as unknown as GovernanceResponsbility;
  }
}

export class RecordKey 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "RecordKey";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "stake_pool", typeTag: AtomicTypeTag.Address },
  { name: "proposal_id", typeTag: AtomicTypeTag.U64 }];

  stake_pool: HexString;
  proposal_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.stake_pool = proto['stake_pool'] as HexString;
    this.proposal_id = proto['proposal_id'] as U64;
  }

  static RecordKeyParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : RecordKey {
    const proto = $.parseStructProto(data, typeTag, repo, RecordKey);
    return new RecordKey(proto, typeTag);
  }

}

export class UpdateConfigEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "UpdateConfigEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "min_voting_threshold", typeTag: AtomicTypeTag.U128 },
  { name: "required_proposer_stake", typeTag: AtomicTypeTag.U64 },
  { name: "voting_period_secs", typeTag: AtomicTypeTag.U64 }];

  min_voting_threshold: U128;
  required_proposer_stake: U64;
  voting_period_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.min_voting_threshold = proto['min_voting_threshold'] as U128;
    this.required_proposer_stake = proto['required_proposer_stake'] as U64;
    this.voting_period_secs = proto['voting_period_secs'] as U64;
  }

  static UpdateConfigEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : UpdateConfigEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UpdateConfigEvent);
    return new UpdateConfigEvent(proto, typeTag);
  }

}

export class VoteEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VoteEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
  { name: "voter", typeTag: AtomicTypeTag.Address },
  { name: "stake_pool", typeTag: AtomicTypeTag.Address },
  { name: "num_votes", typeTag: AtomicTypeTag.U64 },
  { name: "should_pass", typeTag: AtomicTypeTag.Bool }];

  proposal_id: U64;
  voter: HexString;
  stake_pool: HexString;
  num_votes: U64;
  should_pass: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto['proposal_id'] as U64;
    this.voter = proto['voter'] as HexString;
    this.stake_pool = proto['stake_pool'] as HexString;
    this.num_votes = proto['num_votes'] as U64;
    this.should_pass = proto['should_pass'] as boolean;
  }

  static VoteEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VoteEvent {
    const proto = $.parseStructProto(data, typeTag, repo, VoteEvent);
    return new VoteEvent(proto, typeTag);
  }

}

export class VotingRecords 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VotingRecords";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "votes", typeTag: new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "aptos_governance", "RecordKey", []), AtomicTypeTag.Bool]) }];

  votes: Aptos_std.Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.votes = proto['votes'] as Aptos_std.Table.Table;
  }

  static VotingRecordsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VotingRecords {
    const proto = $.parseStructProto(data, typeTag, repo, VotingRecords);
    return new VotingRecords(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, VotingRecords, typeParams);
    return result as unknown as VotingRecords;
  }
}
export function create_proposal_ (
  proposer: HexString,
  stake_pool: HexString,
  execution_hash: U8[],
  metadata_location: U8[],
  metadata_hash: U8[],
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, current_time, early_resolution_vote_threshold, events, governance_config, proposal_expiration, proposal_id, proposer_address, stake_balance, total_supply, total_voting_token_supply;
  proposer_address = Std.Signer.address_of_(proposer, $c);
  if (!((Stake.get_delegated_voter_($.copy(stake_pool), $c)).hex() === ($.copy(proposer_address)).hex())) {
    throw $.abortCode(Std.Error.invalid_argument_(ENOT_DELEGATED_VOTER, $c));
  }
  governance_config = $c.borrow_global<GovernanceConfig>(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceConfig", []), new HexString("0x1"));
  stake_balance = Stake.get_active_staked_balance_($.copy(stake_pool), $c);
  if (!($.copy(stake_balance)).ge($.copy(governance_config.required_proposer_stake))) {
    throw $.abortCode(Std.Error.invalid_argument_(EINSUFFICIENT_PROPOSER_STAKE, $c));
  }
  current_time = Timestamp.now_seconds_($c);
  proposal_expiration = ($.copy(current_time)).add($.copy(governance_config.voting_period_secs));
  if (!(Stake.get_lockup_secs_($.copy(stake_pool), $c)).ge($.copy(proposal_expiration))) {
    throw $.abortCode(Std.Error.invalid_argument_(EINSUFFICIENT_STAKE_LOCKUP, $c));
  }
  total_voting_token_supply = Coin.supply_($c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  early_resolution_vote_threshold = Std.Option.none_($c, [AtomicTypeTag.U128]);
  if (Std.Option.is_some_(total_voting_token_supply, $c, [AtomicTypeTag.U128])) {
    total_supply = $.copy(Std.Option.borrow_(total_voting_token_supply, $c, [AtomicTypeTag.U128]));
    early_resolution_vote_threshold = Std.Option.some_((($.copy(total_supply)).div(u128("2"))).add(u128("1")), $c, [AtomicTypeTag.U128]);
  }
  else{
  }
  proposal_id = Voting.create_proposal_($.copy(proposer_address), new HexString("0x1"), Governance_proposal.create_proposal_(Std.String.utf8_($.copy(metadata_location), $c), Std.String.utf8_($.copy(metadata_hash), $c), $c), $.copy(execution_hash), $.copy(governance_config.min_voting_threshold), $.copy(proposal_expiration), $.copy(early_resolution_vote_threshold), $c, [new StructTag(new HexString("0x1"), "governance_proposal", "GovernanceProposal", [])]);
  events = $c.borrow_global_mut<GovernanceEvents>(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceEvents", []), new HexString("0x1"));
  temp$7 = events.create_proposal_events;
  temp$1 = $.copy(proposal_id);
  temp$2 = $.copy(proposer_address);
  temp$3 = $.copy(stake_pool);
  temp$4 = $.copy(execution_hash);
  temp$5 = $.copy(metadata_location);
  temp$6 = $.copy(metadata_hash);
  Aptos_std.Event.emit_event_(temp$7, new CreateProposalEvent({ proposer: temp$2, stake_pool: temp$3, proposal_id: temp$1, execution_hash: temp$4, metadata_location: temp$5, metadata_hash: temp$6 }, new StructTag(new HexString("0x1"), "aptos_governance", "CreateProposalEvent", [])), $c, [new StructTag(new HexString("0x1"), "aptos_governance", "CreateProposalEvent", [])]);
  return;
}


export function buildPayload_create_proposal (
  stake_pool: HexString,
  execution_hash: U8[],
  metadata_location: U8[],
  metadata_hash: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::aptos_governance::create_proposal",
    typeParamStrings,
    [
      $.payloadArg(stake_pool),
      $.u8ArrayArg(execution_hash),
      $.u8ArrayArg(metadata_location),
      $.u8ArrayArg(metadata_hash),
    ]
  );

}
export function get_framework_signer_ (
  _proposal: Governance_proposal.GovernanceProposal,
  $c: AptosDataCache,
): HexString {
  let governance_responsibility;
  governance_responsibility = $c.borrow_global<GovernanceResponsbility>(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceResponsbility", []), new HexString("0x1"));
  return Account.create_signer_with_capability_(governance_responsibility.signer_cap, $c);
}

export function initialize_ (
  aptos_framework: HexString,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_period_secs: U64,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  Voting.register_(aptos_framework, $c, [new StructTag(new HexString("0x1"), "governance_proposal", "GovernanceProposal", [])]);
  temp$4 = aptos_framework;
  temp$1 = $.copy(voting_period_secs);
  temp$2 = $.copy(min_voting_threshold);
  temp$3 = $.copy(required_proposer_stake);
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceConfig", []), temp$4, new GovernanceConfig({ min_voting_threshold: temp$2, required_proposer_stake: temp$3, voting_period_secs: temp$1 }, new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceConfig", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceEvents", []), aptos_framework, new GovernanceEvents({ create_proposal_events: Aptos_std.Event.new_event_handle_(aptos_framework, $c, [new StructTag(new HexString("0x1"), "aptos_governance", "CreateProposalEvent", [])]), update_config_events: Aptos_std.Event.new_event_handle_(aptos_framework, $c, [new StructTag(new HexString("0x1"), "aptos_governance", "UpdateConfigEvent", [])]), vote_events: Aptos_std.Event.new_event_handle_(aptos_framework, $c, [new StructTag(new HexString("0x1"), "aptos_governance", "VoteEvent", [])]) }, new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceEvents", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_governance", "VotingRecords", []), aptos_framework, new VotingRecords({ votes: Aptos_std.Table.new___($c, [new StructTag(new HexString("0x1"), "aptos_governance", "RecordKey", []), AtomicTypeTag.Bool]) }, new StructTag(new HexString("0x1"), "aptos_governance", "VotingRecords", [])));
  return;
}

export function reconfigure_ (
  _proposal: Governance_proposal.GovernanceProposal,
  $c: AptosDataCache,
): void {
  Reconfiguration.reconfigure_($c);
  return;
}

export function store_signer_cap_ (
  aptos_framework: HexString,
  signer_cap: Account.SignerCapability,
  $c: AptosDataCache,
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $c.move_to(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceResponsbility", []), aptos_framework, new GovernanceResponsbility({ signer_cap: signer_cap }, new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceResponsbility", [])));
  return;
}

export function update_governance_config_ (
  _proposal: Governance_proposal.GovernanceProposal,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_period_secs: U64,
  $c: AptosDataCache,
): void {
  let events, governance_config;
  governance_config = $c.borrow_global_mut<GovernanceConfig>(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceConfig", []), new HexString("0x1"));
  governance_config.voting_period_secs = $.copy(voting_period_secs);
  governance_config.min_voting_threshold = $.copy(min_voting_threshold);
  governance_config.required_proposer_stake = $.copy(required_proposer_stake);
  events = $c.borrow_global_mut<GovernanceEvents>(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceEvents", []), new HexString("0x1"));
  Aptos_std.Event.emit_event_(events.update_config_events, new UpdateConfigEvent({ min_voting_threshold: $.copy(min_voting_threshold), required_proposer_stake: $.copy(required_proposer_stake), voting_period_secs: $.copy(voting_period_secs) }, new StructTag(new HexString("0x1"), "aptos_governance", "UpdateConfigEvent", [])), $c, [new StructTag(new HexString("0x1"), "aptos_governance", "UpdateConfigEvent", [])]);
  return;
}

export function vote_ (
  voter: HexString,
  stake_pool: HexString,
  proposal_id: U64,
  should_pass: boolean,
  $c: AptosDataCache,
): void {
  let temp$1, events, proposal_expiration, record_key, voter_address, voting_power, voting_records;
  voter_address = Std.Signer.address_of_(voter, $c);
  if (!((Stake.get_delegated_voter_($.copy(stake_pool), $c)).hex() === ($.copy(voter_address)).hex())) {
    throw $.abortCode(Std.Error.invalid_argument_(ENOT_DELEGATED_VOTER, $c));
  }
  voting_power = Stake.get_active_staked_balance_($.copy(stake_pool), $c);
  if (!($.copy(voting_power)).gt(u64("0"))) {
    throw $.abortCode(Std.Error.invalid_argument_(ENO_VOTING_POWER, $c));
  }
  proposal_expiration = Voting.get_proposal_expiration_secs_(new HexString("0x1"), $.copy(proposal_id), $c, [new StructTag(new HexString("0x1"), "governance_proposal", "GovernanceProposal", [])]);
  if (!(Stake.get_lockup_secs_($.copy(stake_pool), $c)).ge($.copy(proposal_expiration))) {
    throw $.abortCode(Std.Error.invalid_argument_(EINSUFFICIENT_STAKE_LOCKUP, $c));
  }
  voting_records = $c.borrow_global_mut<VotingRecords>(new StructTag(new HexString("0x1"), "aptos_governance", "VotingRecords", []), new HexString("0x1"));
  record_key = new RecordKey({ stake_pool: $.copy(stake_pool), proposal_id: $.copy(proposal_id) }, new StructTag(new HexString("0x1"), "aptos_governance", "RecordKey", []));
  if (!!Aptos_std.Table.contains_(voting_records.votes, $.copy(record_key), $c, [new StructTag(new HexString("0x1"), "aptos_governance", "RecordKey", []), AtomicTypeTag.Bool])) {
    throw $.abortCode(Std.Error.invalid_argument_(EALREADY_VOTED, $c));
  }
  Aptos_std.Table.add_(voting_records.votes, $.copy(record_key), true, $c, [new StructTag(new HexString("0x1"), "aptos_governance", "RecordKey", []), AtomicTypeTag.Bool]);
  temp$1 = Governance_proposal.create_empty_proposal_($c);
  Voting.vote_(temp$1, new HexString("0x1"), $.copy(proposal_id), $.copy(voting_power), should_pass, $c, [new StructTag(new HexString("0x1"), "governance_proposal", "GovernanceProposal", [])]);
  events = $c.borrow_global_mut<GovernanceEvents>(new StructTag(new HexString("0x1"), "aptos_governance", "GovernanceEvents", []), new HexString("0x1"));
  Aptos_std.Event.emit_event_(events.vote_events, new VoteEvent({ proposal_id: $.copy(proposal_id), voter: $.copy(voter_address), stake_pool: $.copy(stake_pool), num_votes: $.copy(voting_power), should_pass: should_pass }, new StructTag(new HexString("0x1"), "aptos_governance", "VoteEvent", [])), $c, [new StructTag(new HexString("0x1"), "aptos_governance", "VoteEvent", [])]);
  return;
}


export function buildPayload_vote (
  stake_pool: HexString,
  proposal_id: U64,
  should_pass: boolean,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::aptos_governance::vote",
    typeParamStrings,
    [
      $.payloadArg(stake_pool),
      $.payloadArg(proposal_id),
      $.payloadArg(should_pass),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::aptos_governance::CreateProposalEvent", CreateProposalEvent.CreateProposalEventParser);
  repo.addParser("0x1::aptos_governance::GovernanceConfig", GovernanceConfig.GovernanceConfigParser);
  repo.addParser("0x1::aptos_governance::GovernanceEvents", GovernanceEvents.GovernanceEventsParser);
  repo.addParser("0x1::aptos_governance::GovernanceResponsbility", GovernanceResponsbility.GovernanceResponsbilityParser);
  repo.addParser("0x1::aptos_governance::RecordKey", RecordKey.RecordKeyParser);
  repo.addParser("0x1::aptos_governance::UpdateConfigEvent", UpdateConfigEvent.UpdateConfigEventParser);
  repo.addParser("0x1::aptos_governance::VoteEvent", VoteEvent.VoteEventParser);
  repo.addParser("0x1::aptos_governance::VotingRecords", VotingRecords.VotingRecordsParser);
}

