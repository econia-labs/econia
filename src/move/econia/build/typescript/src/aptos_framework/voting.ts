import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as table$_ from "./table";
import * as timestamp$_ from "./timestamp";
import * as transaction_context$_ from "./transaction_context";
import * as type_info$_ from "./type_info";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "voting";

export const EPROPOSAL_ALREADY_RESOLVED : U64 = u64("3");
export const EPROPOSAL_CANNOT_BE_RESOLVED : U64 = u64("2");
export const EPROPOSAL_EXECUTION_HASH_NOT_MATCHING : U64 = u64("1");
export const PROPOSAL_STATE_FAILED : U64 = u64("3");
export const PROPOSAL_STATE_PENDING : U64 = u64("0");
export const PROPOSAL_STATE_SUCCEEDED : U64 = u64("1");


export class CreateProposalEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CreateProposalEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
  { name: "early_resolution_vote_threshold", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [AtomicTypeTag.U128]) },
  { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "expiration_secs", typeTag: AtomicTypeTag.U64 },
  { name: "min_vote_threshold", typeTag: AtomicTypeTag.U128 }];

  proposal_id: U64;
  early_resolution_vote_threshold: std$_.option$_.Option;
  execution_hash: U8[];
  expiration_secs: U64;
  min_vote_threshold: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto['proposal_id'] as U64;
    this.early_resolution_vote_threshold = proto['early_resolution_vote_threshold'] as std$_.option$_.Option;
    this.execution_hash = proto['execution_hash'] as U8[];
    this.expiration_secs = proto['expiration_secs'] as U64;
    this.min_vote_threshold = proto['min_vote_threshold'] as U128;
  }

  static CreateProposalEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CreateProposalEvent {
    const proto = $.parseStructProto(data, typeTag, repo, CreateProposalEvent);
    return new CreateProposalEvent(proto, typeTag);
  }

}

export class Proposal 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Proposal";
  static typeParameters: TypeParamDeclType[] = [
    { name: "ProposalType", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "proposer", typeTag: AtomicTypeTag.Address },
  { name: "execution_content", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [new $.TypeParamIdx(0)]) },
  { name: "creation_time_secs", typeTag: AtomicTypeTag.U64 },
  { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "min_vote_threshold", typeTag: AtomicTypeTag.U128 },
  { name: "expiration_secs", typeTag: AtomicTypeTag.U64 },
  { name: "early_resolution_vote_threshold", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [AtomicTypeTag.U128]) },
  { name: "yes_votes", typeTag: AtomicTypeTag.U128 },
  { name: "no_votes", typeTag: AtomicTypeTag.U128 },
  { name: "is_resolved", typeTag: AtomicTypeTag.Bool }];

  proposer: HexString;
  execution_content: std$_.option$_.Option;
  creation_time_secs: U64;
  execution_hash: U8[];
  min_vote_threshold: U128;
  expiration_secs: U64;
  early_resolution_vote_threshold: std$_.option$_.Option;
  yes_votes: U128;
  no_votes: U128;
  is_resolved: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposer = proto['proposer'] as HexString;
    this.execution_content = proto['execution_content'] as std$_.option$_.Option;
    this.creation_time_secs = proto['creation_time_secs'] as U64;
    this.execution_hash = proto['execution_hash'] as U8[];
    this.min_vote_threshold = proto['min_vote_threshold'] as U128;
    this.expiration_secs = proto['expiration_secs'] as U64;
    this.early_resolution_vote_threshold = proto['early_resolution_vote_threshold'] as std$_.option$_.Option;
    this.yes_votes = proto['yes_votes'] as U128;
    this.no_votes = proto['no_votes'] as U128;
    this.is_resolved = proto['is_resolved'] as boolean;
  }

  static ProposalParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Proposal {
    const proto = $.parseStructProto(data, typeTag, repo, Proposal);
    return new Proposal(proto, typeTag);
  }

}

export class RegisterForumEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "RegisterForumEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "hosting_account", typeTag: AtomicTypeTag.Address },
  { name: "proposal_type_info", typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []) }];

  hosting_account: HexString;
  proposal_type_info: type_info$_.TypeInfo;

  constructor(proto: any, public typeTag: TypeTag) {
    this.hosting_account = proto['hosting_account'] as HexString;
    this.proposal_type_info = proto['proposal_type_info'] as type_info$_.TypeInfo;
  }

  static RegisterForumEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : RegisterForumEvent {
    const proto = $.parseStructProto(data, typeTag, repo, RegisterForumEvent);
    return new RegisterForumEvent(proto, typeTag);
  }

}

export class ResolveProposal 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ResolveProposal";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
  { name: "yes_votes", typeTag: AtomicTypeTag.U128 },
  { name: "no_votes", typeTag: AtomicTypeTag.U128 },
  { name: "resolved_early", typeTag: AtomicTypeTag.Bool }];

  proposal_id: U64;
  yes_votes: U128;
  no_votes: U128;
  resolved_early: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto['proposal_id'] as U64;
    this.yes_votes = proto['yes_votes'] as U128;
    this.no_votes = proto['no_votes'] as U128;
    this.resolved_early = proto['resolved_early'] as boolean;
  }

  static ResolveProposalParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ResolveProposal {
    const proto = $.parseStructProto(data, typeTag, repo, ResolveProposal);
    return new ResolveProposal(proto, typeTag);
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
  { name: "num_votes", typeTag: AtomicTypeTag.U64 }];

  proposal_id: U64;
  num_votes: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto['proposal_id'] as U64;
    this.num_votes = proto['num_votes'] as U64;
  }

  static VoteEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VoteEvent {
    const proto = $.parseStructProto(data, typeTag, repo, VoteEvent);
    return new VoteEvent(proto, typeTag);
  }

}

export class VotingEvents 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VotingEvents";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "create_proposal_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "voting", "CreateProposalEvent", [])]) },
  { name: "register_forum_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "voting", "RegisterForumEvent", [])]) },
  { name: "resolve_proposal_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "voting", "ResolveProposal", [])]) },
  { name: "vote_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "voting", "VoteEvent", [])]) }];

  create_proposal_events: std$_.event$_.EventHandle;
  register_forum_events: std$_.event$_.EventHandle;
  resolve_proposal_events: std$_.event$_.EventHandle;
  vote_events: std$_.event$_.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.create_proposal_events = proto['create_proposal_events'] as std$_.event$_.EventHandle;
    this.register_forum_events = proto['register_forum_events'] as std$_.event$_.EventHandle;
    this.resolve_proposal_events = proto['resolve_proposal_events'] as std$_.event$_.EventHandle;
    this.vote_events = proto['vote_events'] as std$_.event$_.EventHandle;
  }

  static VotingEventsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VotingEvents {
    const proto = $.parseStructProto(data, typeTag, repo, VotingEvents);
    return new VotingEvents(proto, typeTag);
  }

}

export class VotingForum 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VotingForum";
  static typeParameters: TypeParamDeclType[] = [
    { name: "ProposalType", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "proposals", typeTag: new StructTag(new HexString("0x1"), "table", "Table", [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [new $.TypeParamIdx(0)])]) },
  { name: "events", typeTag: new StructTag(new HexString("0x1"), "voting", "VotingEvents", []) },
  { name: "next_proposal_id", typeTag: AtomicTypeTag.U64 }];

  proposals: table$_.Table;
  events: VotingEvents;
  next_proposal_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposals = proto['proposals'] as table$_.Table;
    this.events = proto['events'] as VotingEvents;
    this.next_proposal_id = proto['next_proposal_id'] as U64;
  }

  static VotingForumParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VotingForum {
    const proto = $.parseStructProto(data, typeTag, repo, VotingForum);
    return new VotingForum(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, VotingForum, typeParams);
    return result as unknown as VotingForum;
  }
}
export function can_be_resolved_early$ (
  proposal: Proposal,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): boolean {
  let temp$1, early_resolution_threshold;
  if (std$_.option$_.is_some$(proposal.early_resolution_vote_threshold, $c, [AtomicTypeTag.U128] as TypeTag[])) {
    early_resolution_threshold = $.copy(std$_.option$_.borrow$(proposal.early_resolution_vote_threshold, $c, [AtomicTypeTag.U128] as TypeTag[]));
    if ($.copy(proposal.yes_votes).ge($.copy(early_resolution_threshold))) {
      temp$1 = true;
    }
    else{
      temp$1 = $.copy(proposal.no_votes).ge($.copy(early_resolution_threshold));
    }
    if (temp$1) {
      return true;
    }
    else{
    }
  }
  else{
  }
  return false;
}

export function create_proposal$ (
  proposer: HexString,
  voting_forum_address: HexString,
  execution_content: any,
  execution_hash: U8[],
  min_vote_threshold: U128,
  expiration_secs: U64,
  early_resolution_vote_threshold: std$_.option$_.Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): U64 {
  let temp$1, temp$10, temp$11, temp$12, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, proposal_id, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), $.copy(voting_forum_address));
  proposal_id = $.copy(voting_forum.next_proposal_id);
  voting_forum.next_proposal_id = $.copy(voting_forum.next_proposal_id).add(u64("1"));
  temp$12 = voting_forum.proposals;
  temp$11 = $.copy(proposal_id);
  temp$1 = $.copy(proposer);
  temp$2 = timestamp$_.now_seconds$($c);
  temp$3 = std$_.option$_.some$(execution_content, $c, [$p[0]] as TypeTag[]);
  temp$4 = $.copy(execution_hash);
  temp$5 = $.copy(min_vote_threshold);
  temp$6 = $.copy(expiration_secs);
  temp$7 = $.copy(early_resolution_vote_threshold);
  temp$8 = u128("0");
  temp$9 = u128("0");
  temp$10 = false;
  table$_.add$(temp$12, temp$11, new Proposal({ proposer: temp$1, execution_content: temp$3, creation_time_secs: temp$2, execution_hash: temp$4, min_vote_threshold: temp$5, expiration_secs: temp$6, early_resolution_vote_threshold: temp$7, yes_votes: temp$8, no_votes: temp$9, is_resolved: temp$10 }, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])), $c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
  std$_.event$_.emit_event$(voting_forum.events.create_proposal_events, new CreateProposalEvent({ proposal_id: $.copy(proposal_id), early_resolution_vote_threshold: $.copy(early_resolution_vote_threshold), execution_hash: $.copy(execution_hash), expiration_secs: $.copy(expiration_secs), min_vote_threshold: $.copy(min_vote_threshold) }, new StructTag(new HexString("0x1"), "voting", "CreateProposalEvent", [])), $c, [new StructTag(new HexString("0x1"), "voting", "CreateProposalEvent", [])] as TypeTag[]);
  return $.copy(proposal_id);
}

export function get_proposal_expiration_secs$ (
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): U64 {
  let proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), $.copy(voting_forum_address));
  proposal = table$_.borrow_mut$(voting_forum.proposals, $.copy(proposal_id), $c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
  return $.copy(proposal.expiration_secs);
}

export function get_proposal_state$ (
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): U64 {
  let temp$1, temp$2, temp$3, no_votes, proposal, voting_forum, yes_votes;
  if (is_voting_closed$($.copy(voting_forum_address), $.copy(proposal_id), $c, [$p[0]] as TypeTag[])) {
    voting_forum = $c.borrow_global<VotingForum>(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), $.copy(voting_forum_address));
    proposal = table$_.borrow$(voting_forum.proposals, $.copy(proposal_id), $c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
    yes_votes = $.copy(proposal.yes_votes);
    no_votes = $.copy(proposal.no_votes);
    if ($.copy(yes_votes).gt($.copy(no_votes))) {
      temp$1 = $.copy(yes_votes).add($.copy(no_votes)).ge($.copy(proposal.min_vote_threshold));
    }
    else{
      temp$1 = false;
    }
    if (temp$1) {
      temp$2 = PROPOSAL_STATE_SUCCEEDED;
    }
    else{
      temp$2 = PROPOSAL_STATE_FAILED;
    }
    temp$3 = temp$2;
  }
  else{
    temp$3 = PROPOSAL_STATE_PENDING;
  }
  return temp$3;
}

export function is_voting_closed$ (
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): boolean {
  let temp$1, proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), $.copy(voting_forum_address));
  proposal = table$_.borrow_mut$(voting_forum.proposals, $.copy(proposal_id), $c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
  if (can_be_resolved_early$(proposal, $c, [$p[0]] as TypeTag[])) {
    temp$1 = true;
  }
  else{
    temp$1 = timestamp$_.now_seconds$($c).ge($.copy(proposal.expiration_secs));
  }
  return temp$1;
}

export function register$ (
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): void {
  let temp$1, temp$2, temp$3, voting_forum;
  temp$1 = u64("0");
  temp$2 = table$_.new__$($c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
  temp$3 = new VotingEvents({ create_proposal_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "voting", "CreateProposalEvent", [])] as TypeTag[]), register_forum_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "voting", "RegisterForumEvent", [])] as TypeTag[]), resolve_proposal_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "voting", "ResolveProposal", [])] as TypeTag[]), vote_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "voting", "VoteEvent", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "voting", "VotingEvents", []));
  voting_forum = new VotingForum({ proposals: temp$2, events: temp$3, next_proposal_id: temp$1 }, new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]));
  std$_.event$_.emit_event$(voting_forum.events.register_forum_events, new RegisterForumEvent({ hosting_account: std$_.signer$_.address_of$(account, $c), proposal_type_info: type_info$_.type_of$($c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "voting", "RegisterForumEvent", [])), $c, [new StructTag(new HexString("0x1"), "voting", "RegisterForumEvent", [])] as TypeTag[]);
  $c.move_to(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), account, voting_forum);
  return;
}

export function resolve$ (
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): any {
  let proposal, proposal_state, resolved_early, voting_forum;
  proposal_state = get_proposal_state$($.copy(voting_forum_address), $.copy(proposal_id), $c, [$p[0]] as TypeTag[]);
  if (!$.copy(proposal_state).eq(PROPOSAL_STATE_SUCCEEDED)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EPROPOSAL_CANNOT_BE_RESOLVED, $c));
  }
  voting_forum = $c.borrow_global_mut<VotingForum>(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), $.copy(voting_forum_address));
  proposal = table$_.borrow_mut$(voting_forum.proposals, $.copy(proposal_id), $c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
  if (!!$.copy(proposal.is_resolved)) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EPROPOSAL_ALREADY_RESOLVED, $c));
  }
  resolved_early = can_be_resolved_early$(proposal, $c, [$p[0]] as TypeTag[]);
  proposal.is_resolved = true;
  if (!$.veq(transaction_context$_.get_script_hash$($c), $.copy(proposal.execution_hash))) {
    throw $.abortCode(std$_.errors$_.invalid_argument$(EPROPOSAL_EXECUTION_HASH_NOT_MATCHING, $c));
  }
  std$_.event$_.emit_event$(voting_forum.events.resolve_proposal_events, new ResolveProposal({ proposal_id: $.copy(proposal_id), yes_votes: $.copy(proposal.yes_votes), no_votes: $.copy(proposal.no_votes), resolved_early: resolved_early }, new StructTag(new HexString("0x1"), "voting", "ResolveProposal", [])), $c, [new StructTag(new HexString("0x1"), "voting", "ResolveProposal", [])] as TypeTag[]);
  return std$_.option$_.extract$(proposal.execution_content, $c, [$p[0]] as TypeTag[]);
}

export function vote$ (
  _proof: any,
  voting_forum_address: HexString,
  proposal_id: U64,
  num_votes: U64,
  should_pass: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <ProposalType>*/
): void {
  let proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(new StructTag(new HexString("0x1"), "voting", "VotingForum", [$p[0]]), $.copy(voting_forum_address));
  proposal = table$_.borrow_mut$(voting_forum.proposals, $.copy(proposal_id), $c, [AtomicTypeTag.U64, new StructTag(new HexString("0x1"), "voting", "Proposal", [$p[0]])] as TypeTag[]);
  if (should_pass) {
    proposal.yes_votes = $.copy(proposal.yes_votes).add(u128($.copy(num_votes)));
  }
  else{
    proposal.no_votes = $.copy(proposal.no_votes).add(u128($.copy(num_votes)));
  }
  std$_.event$_.emit_event$(voting_forum.events.vote_events, new VoteEvent({ proposal_id: $.copy(proposal_id), num_votes: $.copy(num_votes) }, new StructTag(new HexString("0x1"), "voting", "VoteEvent", [])), $c, [new StructTag(new HexString("0x1"), "voting", "VoteEvent", [])] as TypeTag[]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::voting::CreateProposalEvent", CreateProposalEvent.CreateProposalEventParser);
  repo.addParser("0x1::voting::Proposal", Proposal.ProposalParser);
  repo.addParser("0x1::voting::RegisterForumEvent", RegisterForumEvent.RegisterForumEventParser);
  repo.addParser("0x1::voting::ResolveProposal", ResolveProposal.ResolveProposalParser);
  repo.addParser("0x1::voting::VoteEvent", VoteEvent.VoteEventParser);
  repo.addParser("0x1::voting::VotingEvents", VotingEvents.VotingEventsParser);
  repo.addParser("0x1::voting::VotingForum", VotingForum.VotingForumParser);
}

