import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Coin from "./Coin";
import * as GovernanceProposal from "./GovernanceProposal";
import * as Stake from "./Stake";
import * as SystemAddresses from "./SystemAddresses";
import * as Table from "./Table";
import * as Timestamp from "./Timestamp";
import * as Voting from "./Voting";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "AptosGovernance";

export const EALREADY_VOTED : U64 = u64("4");
export const EINSUFFICIENT_PROPOSER_STAKE : U64 = u64("1");
export const EINSUFFICIENT_STAKE_LOCKUP : U64 = u64("3");
export const ENOT_DELEGATED_VOTER : U64 = u64("2");


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
  { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  proposer: HexString;
  stake_pool: HexString;
  proposal_id: U64;
  execution_hash: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposer = proto['proposer'] as HexString;
    this.stake_pool = proto['stake_pool'] as HexString;
    this.proposal_id = proto['proposal_id'] as U64;
    this.execution_hash = proto['execution_hash'] as U8[];
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
  { name: "create_proposal_events", typeTag: new StructTag(new HexString("0x1"), "Event", "EventHandle", [new StructTag(new HexString("0x1"), "AptosGovernance", "CreateProposalEvent", [])]) },
  { name: "update_config_events", typeTag: new StructTag(new HexString("0x1"), "Event", "EventHandle", [new StructTag(new HexString("0x1"), "AptosGovernance", "UpdateConfigEvent", [])]) },
  { name: "vote_events", typeTag: new StructTag(new HexString("0x1"), "Event", "EventHandle", [new StructTag(new HexString("0x1"), "AptosGovernance", "VoteEvent", [])]) }];

  create_proposal_events: Std.Event.EventHandle;
  update_config_events: Std.Event.EventHandle;
  vote_events: Std.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.create_proposal_events = proto['create_proposal_events'] as Std.Event.EventHandle;
    this.update_config_events = proto['update_config_events'] as Std.Event.EventHandle;
    this.vote_events = proto['vote_events'] as Std.Event.EventHandle;
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
  { name: "votes", typeTag: new StructTag(new HexString("0x1"), "Table", "Table", [new StructTag(new HexString("0x1"), "AptosGovernance", "RecordKey", []), AtomicTypeTag.Bool]) }];

  votes: Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.votes = proto['votes'] as Table.Table;
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
export function create_proposal$ (
  proposer: HexString,
  stake_pool: HexString,
  execution_hash: U8[],
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, current_time, early_resolution_vote_threshold, events, governance_config, proposal_expiration, proposal_id, proposer_address, stake_balance, total_supply, total_voting_token_supply;
  proposer_address = Std.Signer.address_of$(proposer, $c);
  if (!Stake.is_delegated_voter$($.copy(stake_pool), $.copy(proposer_address), $c)) {
    throw $.abortCode(Std.Errors.invalid_argument$(ENOT_DELEGATED_VOTER, $c));
  }
  governance_config = $c.borrow_global<GovernanceConfig>(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceConfig", []), new HexString("0x1"));
  stake_balance = Stake.get_active_staked_balance$($.copy(stake_pool), $c);
  if (!$.copy(stake_balance).ge($.copy(governance_config.required_proposer_stake))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EINSUFFICIENT_PROPOSER_STAKE, $c));
  }
  current_time = Timestamp.now_seconds$($c);
  proposal_expiration = $.copy(current_time).add($.copy(governance_config.voting_period_secs));
  if (!Stake.get_lockup_secs$($.copy(stake_pool), $c).ge($.copy(proposal_expiration))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EINSUFFICIENT_STAKE_LOCKUP, $c));
  }
  total_voting_token_supply = Coin.supply$($c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  early_resolution_vote_threshold = Std.Option.none$($c, [AtomicTypeTag.U128] as TypeTag[]);
  if (Std.Option.is_some$(total_voting_token_supply, $c, [AtomicTypeTag.U128] as TypeTag[])) {
    total_supply = $.copy(Std.Option.borrow$(total_voting_token_supply, $c, [AtomicTypeTag.U128] as TypeTag[]));
    early_resolution_vote_threshold = Std.Option.some$($.copy(total_supply).div(u128("2")).add(u128("1")), $c, [AtomicTypeTag.U128] as TypeTag[]);
  }
  else{
  }
  proposal_id = Voting.create_proposal$(new HexString("0x1"), GovernanceProposal.create_proposal$($c), $.copy(execution_hash), $.copy(governance_config.min_voting_threshold), $.copy(proposal_expiration), $.copy(early_resolution_vote_threshold), $c, [new StructTag(new HexString("0x1"), "GovernanceProposal", "GovernanceProposal", [])] as TypeTag[]);
  events = $c.borrow_global_mut<GovernanceEvents>(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceEvents", []), new HexString("0x1"));
  temp$5 = events.create_proposal_events;
  temp$1 = $.copy(proposal_id);
  temp$2 = $.copy(proposer_address);
  temp$3 = $.copy(stake_pool);
  temp$4 = $.copy(execution_hash);
  Std.Event.emit_event$(temp$5, new CreateProposalEvent({ proposer: temp$2, stake_pool: temp$3, proposal_id: temp$1, execution_hash: temp$4 }, new StructTag(new HexString("0x1"), "AptosGovernance", "CreateProposalEvent", [])), $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "CreateProposalEvent", [])] as TypeTag[]);
  return;
}


export function buildPayload_create_proposal (
  stake_pool: HexString,
  execution_hash: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::AptosGovernance::create_proposal",
    typeParamStrings,
    [
      $.payloadArg(stake_pool),
      $.u8ArrayArg(execution_hash),
    ]
  );

}
export function initialize$ (
  core_framework: HexString,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_period_secs: U64,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4;
  SystemAddresses.assert_core_framework$(core_framework, $c);
  Voting.register$(core_framework, $c, [new StructTag(new HexString("0x1"), "GovernanceProposal", "GovernanceProposal", [])] as TypeTag[]);
  temp$4 = core_framework;
  temp$1 = $.copy(voting_period_secs);
  temp$2 = $.copy(min_voting_threshold);
  temp$3 = $.copy(required_proposer_stake);
  $c.move_to(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceConfig", []), temp$4, new GovernanceConfig({ min_voting_threshold: temp$2, required_proposer_stake: temp$3, voting_period_secs: temp$1 }, new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceConfig", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceEvents", []), core_framework, new GovernanceEvents({ create_proposal_events: Std.Event.new_event_handle$(core_framework, $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "CreateProposalEvent", [])] as TypeTag[]), update_config_events: Std.Event.new_event_handle$(core_framework, $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "UpdateConfigEvent", [])] as TypeTag[]), vote_events: Std.Event.new_event_handle$(core_framework, $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "VoteEvent", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceEvents", [])));
  $c.move_to(new StructTag(new HexString("0x1"), "AptosGovernance", "VotingRecords", []), core_framework, new VotingRecords({ votes: Table.new__$($c, [new StructTag(new HexString("0x1"), "AptosGovernance", "RecordKey", []), AtomicTypeTag.Bool] as TypeTag[]) }, new StructTag(new HexString("0x1"), "AptosGovernance", "VotingRecords", [])));
  return;
}

export function update_governance_config$ (
  _proposal: GovernanceProposal.GovernanceProposal,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_period_secs: U64,
  $c: AptosDataCache,
): void {
  let events, governance_config;
  governance_config = $c.borrow_global_mut<GovernanceConfig>(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceConfig", []), new HexString("0x1"));
  governance_config.voting_period_secs = $.copy(voting_period_secs);
  governance_config.min_voting_threshold = $.copy(min_voting_threshold);
  governance_config.required_proposer_stake = $.copy(required_proposer_stake);
  events = $c.borrow_global_mut<GovernanceEvents>(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceEvents", []), new HexString("0x1"));
  Std.Event.emit_event$(events.update_config_events, new UpdateConfigEvent({ min_voting_threshold: $.copy(min_voting_threshold), required_proposer_stake: $.copy(required_proposer_stake), voting_period_secs: $.copy(voting_period_secs) }, new StructTag(new HexString("0x1"), "AptosGovernance", "UpdateConfigEvent", [])), $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "UpdateConfigEvent", [])] as TypeTag[]);
  return;
}

export function vote$ (
  voter: HexString,
  stake_pool: HexString,
  proposal_id: U64,
  should_pass: boolean,
  $c: AptosDataCache,
): void {
  let temp$1, events, proposal_expiration, record_key, voter_address, voting_power, voting_records;
  voter_address = Std.Signer.address_of$(voter, $c);
  if (!Stake.is_delegated_voter$($.copy(stake_pool), $.copy(voter_address), $c)) {
    throw $.abortCode(Std.Errors.invalid_argument$(ENOT_DELEGATED_VOTER, $c));
  }
  proposal_expiration = Voting.get_proposal_expiration_secs$(new HexString("0x1"), $.copy(proposal_id), $c, [new StructTag(new HexString("0x1"), "GovernanceProposal", "GovernanceProposal", [])] as TypeTag[]);
  if (!Stake.get_lockup_secs$($.copy(stake_pool), $c).ge($.copy(proposal_expiration))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EINSUFFICIENT_STAKE_LOCKUP, $c));
  }
  voting_records = $c.borrow_global_mut<VotingRecords>(new StructTag(new HexString("0x1"), "AptosGovernance", "VotingRecords", []), new HexString("0x1"));
  record_key = new RecordKey({ stake_pool: $.copy(stake_pool), proposal_id: $.copy(proposal_id) }, new StructTag(new HexString("0x1"), "AptosGovernance", "RecordKey", []));
  if (!!Table.contains$(voting_records.votes, $.copy(record_key), $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "RecordKey", []), AtomicTypeTag.Bool] as TypeTag[])) {
    throw $.abortCode(Std.Errors.invalid_argument$(EALREADY_VOTED, $c));
  }
  Table.add$(voting_records.votes, $.copy(record_key), true, $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "RecordKey", []), AtomicTypeTag.Bool] as TypeTag[]);
  voting_power = Stake.get_active_staked_balance$($.copy(stake_pool), $c);
  temp$1 = GovernanceProposal.create_proposal$($c);
  Voting.vote$(temp$1, new HexString("0x1"), $.copy(proposal_id), $.copy(voting_power), should_pass, $c, [new StructTag(new HexString("0x1"), "GovernanceProposal", "GovernanceProposal", [])] as TypeTag[]);
  events = $c.borrow_global_mut<GovernanceEvents>(new StructTag(new HexString("0x1"), "AptosGovernance", "GovernanceEvents", []), new HexString("0x1"));
  Std.Event.emit_event$(events.vote_events, new VoteEvent({ proposal_id: $.copy(proposal_id), voter: $.copy(voter_address), stake_pool: $.copy(stake_pool), num_votes: $.copy(voting_power), should_pass: should_pass }, new StructTag(new HexString("0x1"), "AptosGovernance", "VoteEvent", [])), $c, [new StructTag(new HexString("0x1"), "AptosGovernance", "VoteEvent", [])] as TypeTag[]);
  return;
}


export function buildPayload_vote (
  stake_pool: HexString,
  proposal_id: U64,
  should_pass: boolean,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::AptosGovernance::vote",
    typeParamStrings,
    [
      $.payloadArg(stake_pool),
      $.payloadArg(proposal_id),
      $.payloadArg(should_pass),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::AptosGovernance::CreateProposalEvent", CreateProposalEvent.CreateProposalEventParser);
  repo.addParser("0x1::AptosGovernance::GovernanceConfig", GovernanceConfig.GovernanceConfigParser);
  repo.addParser("0x1::AptosGovernance::GovernanceEvents", GovernanceEvents.GovernanceEventsParser);
  repo.addParser("0x1::AptosGovernance::RecordKey", RecordKey.RecordKeyParser);
  repo.addParser("0x1::AptosGovernance::UpdateConfigEvent", UpdateConfigEvent.UpdateConfigEventParser);
  repo.addParser("0x1::AptosGovernance::VoteEvent", VoteEvent.VoteEventParser);
  repo.addParser("0x1::AptosGovernance::VotingRecords", VotingRecords.VotingRecordsParser);
}

