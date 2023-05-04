import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, type U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import {
  type FieldDeclType,
  type TypeParamDeclType,
} from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";

import * as Account from "./account";
import * as Bcs from "./bcs";
import * as Error from "./error";
import * as Event from "./event";
import * as From_bcs from "./from_bcs";
import * as Option from "./option";
import * as Signer from "./signer";
import * as Simple_map from "./simple_map";
import * as String from "./string";
import * as Table from "./table";
import * as Timestamp from "./timestamp";
import * as Transaction_context from "./transaction_context";
import * as Type_info from "./type_info";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "voting";

export const EINVALID_MIN_VOTE_THRESHOLD: U64 = u64("7");
export const EPROPOSAL_ALREADY_RESOLVED: U64 = u64("3");
export const EPROPOSAL_CANNOT_BE_RESOLVED: U64 = u64("2");
export const EPROPOSAL_EMPTY_EXECUTION_HASH: U64 = u64("4");
export const EPROPOSAL_EXECUTION_HASH_NOT_MATCHING: U64 = u64("1");
export const EPROPOSAL_VOTING_ALREADY_ENDED: U64 = u64("5");
export const ERESOLUTION_CANNOT_BE_ATOMIC: U64 = u64("8");
export const EVOTING_FORUM_ALREADY_REGISTERED: U64 = u64("6");
export const PROPOSAL_STATE_FAILED: U64 = u64("3");
export const PROPOSAL_STATE_PENDING: U64 = u64("0");
export const PROPOSAL_STATE_SUCCEEDED: U64 = u64("1");
export const RESOLVABLE_TIME_METADATA_KEY: U8[] = [
  u8("82"),
  u8("69"),
  u8("83"),
  u8("79"),
  u8("76"),
  u8("86"),
  u8("65"),
  u8("66"),
  u8("76"),
  u8("69"),
  u8("95"),
  u8("84"),
  u8("73"),
  u8("77"),
  u8("69"),
  u8("95"),
  u8("77"),
  u8("69"),
  u8("84"),
  u8("65"),
  u8("68"),
  u8("65"),
  u8("84"),
  u8("65"),
  u8("95"),
  u8("75"),
  u8("69"),
  u8("89"),
];

export class CreateProposalEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CreateProposalEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
    {
      name: "early_resolution_vote_threshold",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        AtomicTypeTag.U128,
      ]),
    },
    { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "expiration_secs", typeTag: AtomicTypeTag.U64 },
    {
      name: "metadata",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        new StructTag(new HexString("0x1"), "string", "String", []),
        new VectorTag(AtomicTypeTag.U8),
      ]),
    },
    { name: "min_vote_threshold", typeTag: AtomicTypeTag.U128 },
  ];

  proposal_id: U64;
  early_resolution_vote_threshold: Option.Option;
  execution_hash: U8[];
  expiration_secs: U64;
  metadata: Simple_map.SimpleMap;
  min_vote_threshold: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto["proposal_id"] as U64;
    this.early_resolution_vote_threshold = proto[
      "early_resolution_vote_threshold"
    ] as Option.Option;
    this.execution_hash = proto["execution_hash"] as U8[];
    this.expiration_secs = proto["expiration_secs"] as U64;
    this.metadata = proto["metadata"] as Simple_map.SimpleMap;
    this.min_vote_threshold = proto["min_vote_threshold"] as U128;
  }

  static CreateProposalEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CreateProposalEvent {
    const proto = $.parseStructProto(data, typeTag, repo, CreateProposalEvent);
    return new CreateProposalEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "CreateProposalEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.early_resolution_vote_threshold.loadFullState(app);
    await this.metadata.loadFullState(app);
    this.__app = app;
  }
}

export class Proposal {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Proposal";
  static typeParameters: TypeParamDeclType[] = [
    { name: "ProposalType", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    { name: "proposer", typeTag: AtomicTypeTag.Address },
    {
      name: "execution_content",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "metadata",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        new StructTag(new HexString("0x1"), "string", "String", []),
        new VectorTag(AtomicTypeTag.U8),
      ]),
    },
    { name: "creation_time_secs", typeTag: AtomicTypeTag.U64 },
    { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "min_vote_threshold", typeTag: AtomicTypeTag.U128 },
    { name: "expiration_secs", typeTag: AtomicTypeTag.U64 },
    {
      name: "early_resolution_vote_threshold",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        AtomicTypeTag.U128,
      ]),
    },
    { name: "yes_votes", typeTag: AtomicTypeTag.U128 },
    { name: "no_votes", typeTag: AtomicTypeTag.U128 },
    { name: "is_resolved", typeTag: AtomicTypeTag.Bool },
    { name: "resolution_time_secs", typeTag: AtomicTypeTag.U64 },
  ];

  proposer: HexString;
  execution_content: Option.Option;
  metadata: Simple_map.SimpleMap;
  creation_time_secs: U64;
  execution_hash: U8[];
  min_vote_threshold: U128;
  expiration_secs: U64;
  early_resolution_vote_threshold: Option.Option;
  yes_votes: U128;
  no_votes: U128;
  is_resolved: boolean;
  resolution_time_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposer = proto["proposer"] as HexString;
    this.execution_content = proto["execution_content"] as Option.Option;
    this.metadata = proto["metadata"] as Simple_map.SimpleMap;
    this.creation_time_secs = proto["creation_time_secs"] as U64;
    this.execution_hash = proto["execution_hash"] as U8[];
    this.min_vote_threshold = proto["min_vote_threshold"] as U128;
    this.expiration_secs = proto["expiration_secs"] as U64;
    this.early_resolution_vote_threshold = proto[
      "early_resolution_vote_threshold"
    ] as Option.Option;
    this.yes_votes = proto["yes_votes"] as U128;
    this.no_votes = proto["no_votes"] as U128;
    this.is_resolved = proto["is_resolved"] as boolean;
    this.resolution_time_secs = proto["resolution_time_secs"] as U64;
  }

  static ProposalParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Proposal {
    const proto = $.parseStructProto(data, typeTag, repo, Proposal);
    return new Proposal(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Proposal", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.execution_content.loadFullState(app);
    await this.metadata.loadFullState(app);
    await this.early_resolution_vote_threshold.loadFullState(app);
    this.__app = app;
  }
}

export class RegisterForumEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RegisterForumEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "hosting_account", typeTag: AtomicTypeTag.Address },
    {
      name: "proposal_type_info",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
  ];

  hosting_account: HexString;
  proposal_type_info: Type_info.TypeInfo;

  constructor(proto: any, public typeTag: TypeTag) {
    this.hosting_account = proto["hosting_account"] as HexString;
    this.proposal_type_info = proto["proposal_type_info"] as Type_info.TypeInfo;
  }

  static RegisterForumEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RegisterForumEvent {
    const proto = $.parseStructProto(data, typeTag, repo, RegisterForumEvent);
    return new RegisterForumEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RegisterForumEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.proposal_type_info.loadFullState(app);
    this.__app = app;
  }
}

export class ResolveProposal {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ResolveProposal";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
    { name: "yes_votes", typeTag: AtomicTypeTag.U128 },
    { name: "no_votes", typeTag: AtomicTypeTag.U128 },
    { name: "resolved_early", typeTag: AtomicTypeTag.Bool },
  ];

  proposal_id: U64;
  yes_votes: U128;
  no_votes: U128;
  resolved_early: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto["proposal_id"] as U64;
    this.yes_votes = proto["yes_votes"] as U128;
    this.no_votes = proto["no_votes"] as U128;
    this.resolved_early = proto["resolved_early"] as boolean;
  }

  static ResolveProposalParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ResolveProposal {
    const proto = $.parseStructProto(data, typeTag, repo, ResolveProposal);
    return new ResolveProposal(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ResolveProposal", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class VoteEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VoteEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
    { name: "num_votes", typeTag: AtomicTypeTag.U64 },
  ];

  proposal_id: U64;
  num_votes: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto["proposal_id"] as U64;
    this.num_votes = proto["num_votes"] as U64;
  }

  static VoteEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VoteEvent {
    const proto = $.parseStructProto(data, typeTag, repo, VoteEvent);
    return new VoteEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "VoteEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class VotingEvents {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VotingEvents";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "create_proposal_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "voting",
          "CreateProposalEvent",
          []
        ),
      ]),
    },
    {
      name: "register_forum_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "voting", "RegisterForumEvent", []),
      ]),
    },
    {
      name: "resolve_proposal_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "voting", "ResolveProposal", []),
      ]),
    },
    {
      name: "vote_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "voting", "VoteEvent", []),
      ]),
    },
  ];

  create_proposal_events: Event.EventHandle;
  register_forum_events: Event.EventHandle;
  resolve_proposal_events: Event.EventHandle;
  vote_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.create_proposal_events = proto[
      "create_proposal_events"
    ] as Event.EventHandle;
    this.register_forum_events = proto[
      "register_forum_events"
    ] as Event.EventHandle;
    this.resolve_proposal_events = proto[
      "resolve_proposal_events"
    ] as Event.EventHandle;
    this.vote_events = proto["vote_events"] as Event.EventHandle;
  }

  static VotingEventsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VotingEvents {
    const proto = $.parseStructProto(data, typeTag, repo, VotingEvents);
    return new VotingEvents(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "VotingEvents", []);
  }
  async loadFullState(app: $.AppType) {
    await this.create_proposal_events.loadFullState(app);
    await this.register_forum_events.loadFullState(app);
    await this.resolve_proposal_events.loadFullState(app);
    await this.vote_events.loadFullState(app);
    this.__app = app;
  }
}

export class VotingForum {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VotingForum";
  static typeParameters: TypeParamDeclType[] = [
    { name: "ProposalType", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "proposals",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        AtomicTypeTag.U64,
        new StructTag(new HexString("0x1"), "voting", "Proposal", [
          new $.TypeParamIdx(0),
        ]),
      ]),
    },
    {
      name: "events",
      typeTag: new StructTag(
        new HexString("0x1"),
        "voting",
        "VotingEvents",
        []
      ),
    },
    { name: "next_proposal_id", typeTag: AtomicTypeTag.U64 },
  ];

  proposals: Table.Table;
  events: VotingEvents;
  next_proposal_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposals = proto["proposals"] as Table.Table;
    this.events = proto["events"] as VotingEvents;
    this.next_proposal_id = proto["next_proposal_id"] as U64;
  }

  static VotingForumParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VotingForum {
    const proto = $.parseStructProto(data, typeTag, repo, VotingForum);
    return new VotingForum(proto, typeTag);
  }

  static async load(
    repo: AptosParserRepo,
    client: AptosClient,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await repo.loadResource(
      client,
      address,
      VotingForum,
      typeParams
    );
    return result as unknown as VotingForum;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      VotingForum,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as VotingForum;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "VotingForum", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.proposals.loadFullState(app);
    await this.events.loadFullState(app);
    this.__app = app;
  }
}
export function can_be_resolved_early_(
  proposal: Proposal,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): boolean {
  let temp$1, early_resolution_threshold;
  if (
    Option.is_some_(proposal.early_resolution_vote_threshold, $c, [
      AtomicTypeTag.U128,
    ])
  ) {
    early_resolution_threshold = $.copy(
      Option.borrow_(proposal.early_resolution_vote_threshold, $c, [
        AtomicTypeTag.U128,
      ])
    );
    if ($.copy(proposal.yes_votes).ge($.copy(early_resolution_threshold))) {
      temp$1 = true;
    } else {
      temp$1 = $.copy(proposal.no_votes).ge($.copy(early_resolution_threshold));
    }
    if (temp$1) {
      return true;
    } else {
    }
  } else {
  }
  return false;
}

export function create_proposal_(
  proposer: HexString,
  voting_forum_address: HexString,
  execution_content: any,
  execution_hash: U8[],
  min_vote_threshold: U128,
  expiration_secs: U64,
  early_resolution_vote_threshold: Option.Option,
  metadata: Simple_map.SimpleMap,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): U64 {
  let temp$1,
    temp$10,
    temp$11,
    temp$12,
    temp$13,
    temp$14,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    proposal_id,
    voting_forum;
  if (
    Option.is_some_(early_resolution_vote_threshold, $c, [AtomicTypeTag.U128])
  ) {
    if (
      !$.copy(min_vote_threshold).le(
        $.copy(
          Option.borrow_(early_resolution_vote_threshold, $c, [
            AtomicTypeTag.U128,
          ])
        )
      )
    ) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EINVALID_MIN_VOTE_THRESHOLD), $c)
      );
    }
  } else {
  }
  if (!Vector.length_(execution_hash, $c, [AtomicTypeTag.U8]).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EPROPOSAL_EMPTY_EXECUTION_HASH), $c)
    );
  }
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal_id = $.copy(voting_forum.next_proposal_id);
  voting_forum.next_proposal_id = $.copy(voting_forum.next_proposal_id).add(
    u64("1")
  );
  temp$14 = voting_forum.proposals;
  temp$13 = $.copy(proposal_id);
  temp$1 = $.copy(proposer);
  temp$2 = Timestamp.now_seconds_($c);
  temp$3 = Option.some_(execution_content, $c, [$p[0]]);
  temp$4 = $.copy(execution_hash);
  temp$5 = $.copy(metadata);
  temp$6 = $.copy(min_vote_threshold);
  temp$7 = $.copy(expiration_secs);
  temp$8 = $.copy(early_resolution_vote_threshold);
  temp$9 = u128("0");
  temp$10 = u128("0");
  temp$11 = false;
  temp$12 = u64("0");
  Table.add_(
    temp$14,
    temp$13,
    new Proposal(
      {
        proposer: temp$1,
        execution_content: temp$3,
        metadata: temp$5,
        creation_time_secs: temp$2,
        execution_hash: temp$4,
        min_vote_threshold: temp$6,
        expiration_secs: temp$7,
        early_resolution_vote_threshold: temp$8,
        yes_votes: temp$9,
        no_votes: temp$10,
        is_resolved: temp$11,
        resolution_time_secs: temp$12,
      },
      new SimpleStructTag(Proposal, [$p[0]])
    ),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  Event.emit_event_(
    voting_forum.events.create_proposal_events,
    new CreateProposalEvent(
      {
        proposal_id: $.copy(proposal_id),
        early_resolution_vote_threshold: $.copy(
          early_resolution_vote_threshold
        ),
        execution_hash: $.copy(execution_hash),
        expiration_secs: $.copy(expiration_secs),
        metadata: $.copy(metadata),
        min_vote_threshold: $.copy(min_vote_threshold),
      },
      new SimpleStructTag(CreateProposalEvent)
    ),
    $c,
    [new SimpleStructTag(CreateProposalEvent)]
  );
  return $.copy(proposal_id);
}

export function get_execution_hash_(
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): U8[] {
  let proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal = Table.borrow_mut_(
    voting_forum.proposals,
    $.copy(proposal_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  return $.copy(proposal.execution_hash);
}

export function get_proposal_expiration_secs_(
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): U64 {
  let proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal = Table.borrow_mut_(
    voting_forum.proposals,
    $.copy(proposal_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  return $.copy(proposal.expiration_secs);
}

export function get_proposal_state_(
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): U64 {
  let temp$1, temp$2, temp$3, no_votes, proposal, voting_forum, yes_votes;
  if (
    is_voting_closed_($.copy(voting_forum_address), $.copy(proposal_id), $c, [
      $p[0],
    ])
  ) {
    voting_forum = $c.borrow_global<VotingForum>(
      new SimpleStructTag(VotingForum, [$p[0]]),
      $.copy(voting_forum_address)
    );
    proposal = Table.borrow_(voting_forum.proposals, $.copy(proposal_id), $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(Proposal, [$p[0]]),
    ]);
    yes_votes = $.copy(proposal.yes_votes);
    no_votes = $.copy(proposal.no_votes);
    if ($.copy(yes_votes).gt($.copy(no_votes))) {
      temp$1 = $.copy(yes_votes)
        .add($.copy(no_votes))
        .ge($.copy(proposal.min_vote_threshold));
    } else {
      temp$1 = false;
    }
    if (temp$1) {
      temp$2 = $.copy(PROPOSAL_STATE_SUCCEEDED);
    } else {
      temp$2 = $.copy(PROPOSAL_STATE_FAILED);
    }
    temp$3 = temp$2;
  } else {
    temp$3 = $.copy(PROPOSAL_STATE_PENDING);
  }
  return temp$3;
}

export function is_resolved_(
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): boolean {
  let proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal = Table.borrow_mut_(
    voting_forum.proposals,
    $.copy(proposal_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  return $.copy(proposal.is_resolved);
}

export function is_voting_closed_(
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): boolean {
  let temp$1, proposal, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal = Table.borrow_mut_(
    voting_forum.proposals,
    $.copy(proposal_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  if (can_be_resolved_early_(proposal, $c, [$p[0]])) {
    temp$1 = true;
  } else {
    temp$1 = is_voting_period_over_(proposal, $c, [$p[0]]);
  }
  return temp$1;
}

export function is_voting_period_over_(
  proposal: Proposal,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): boolean {
  return Timestamp.now_seconds_($c).gt($.copy(proposal.expiration_secs));
}

export function register_(
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): void {
  let temp$1, temp$2, temp$3, addr, voting_forum;
  addr = Signer.address_of_(account, $c);
  if ($c.exists(new SimpleStructTag(VotingForum, [$p[0]]), $.copy(addr))) {
    throw $.abortCode(
      Error.already_exists_($.copy(EVOTING_FORUM_ALREADY_REGISTERED), $c)
    );
  }
  temp$1 = u64("0");
  temp$2 = Table.new___($c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(Proposal, [$p[0]]),
  ]);
  temp$3 = new VotingEvents(
    {
      create_proposal_events: Account.new_event_handle_(account, $c, [
        new SimpleStructTag(CreateProposalEvent),
      ]),
      register_forum_events: Account.new_event_handle_(account, $c, [
        new SimpleStructTag(RegisterForumEvent),
      ]),
      resolve_proposal_events: Account.new_event_handle_(account, $c, [
        new SimpleStructTag(ResolveProposal),
      ]),
      vote_events: Account.new_event_handle_(account, $c, [
        new SimpleStructTag(VoteEvent),
      ]),
    },
    new SimpleStructTag(VotingEvents)
  );
  voting_forum = new VotingForum(
    { proposals: temp$2, events: temp$3, next_proposal_id: temp$1 },
    new SimpleStructTag(VotingForum, [$p[0]])
  );
  Event.emit_event_(
    voting_forum.events.register_forum_events,
    new RegisterForumEvent(
      {
        hosting_account: $.copy(addr),
        proposal_type_info: Type_info.type_of_($c, [$p[0]]),
      },
      new SimpleStructTag(RegisterForumEvent)
    ),
    $c,
    [new SimpleStructTag(RegisterForumEvent)]
  );
  $c.move_to(new SimpleStructTag(VotingForum, [$p[0]]), account, voting_forum);
  return;
}

export function resolve_(
  voting_forum_address: HexString,
  proposal_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): any {
  let temp$1,
    temp$2,
    proposal,
    proposal_state,
    resolvable_time,
    resolved_early,
    voting_forum;
  proposal_state = get_proposal_state_(
    $.copy(voting_forum_address),
    $.copy(proposal_id),
    $c,
    [$p[0]]
  );
  if (!$.copy(proposal_state).eq($.copy(PROPOSAL_STATE_SUCCEEDED))) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EPROPOSAL_CANNOT_BE_RESOLVED), $c)
    );
  }
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal = Table.borrow_mut_(
    voting_forum.proposals,
    $.copy(proposal_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  if ($.copy(proposal.is_resolved)) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EPROPOSAL_ALREADY_RESOLVED), $c)
    );
  }
  temp$2 = proposal.metadata;
  temp$1 = String.utf8_($.copy(RESOLVABLE_TIME_METADATA_KEY), $c);
  resolvable_time = From_bcs.to_u64_(
    $.copy(
      Simple_map.borrow_(temp$2, temp$1, $c, [
        new StructTag(new HexString("0x1"), "string", "String", []),
        new VectorTag(AtomicTypeTag.U8),
      ])
    ),
    $c
  );
  if (!Timestamp.now_seconds_($c).gt($.copy(resolvable_time))) {
    throw $.abortCode(
      Error.invalid_state_($.copy(ERESOLUTION_CANNOT_BE_ATOMIC), $c)
    );
  }
  resolved_early = can_be_resolved_early_(proposal, $c, [$p[0]]);
  proposal.is_resolved = true;
  proposal.resolution_time_secs = Timestamp.now_seconds_($c);
  if (
    !$.veq(
      Transaction_context.get_script_hash_($c),
      $.copy(proposal.execution_hash)
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EPROPOSAL_EXECUTION_HASH_NOT_MATCHING), $c)
    );
  }
  Event.emit_event_(
    voting_forum.events.resolve_proposal_events,
    new ResolveProposal(
      {
        proposal_id: $.copy(proposal_id),
        yes_votes: $.copy(proposal.yes_votes),
        no_votes: $.copy(proposal.no_votes),
        resolved_early: resolved_early,
      },
      new SimpleStructTag(ResolveProposal)
    ),
    $c,
    [new SimpleStructTag(ResolveProposal)]
  );
  return Option.extract_(proposal.execution_content, $c, [$p[0]]);
}

export function vote_(
  _proof: any,
  voting_forum_address: HexString,
  proposal_id: U64,
  num_votes: U64,
  should_pass: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <ProposalType>*/
): void {
  let temp$1, key, proposal, timestamp_secs_bytes, voting_forum;
  voting_forum = $c.borrow_global_mut<VotingForum>(
    new SimpleStructTag(VotingForum, [$p[0]]),
    $.copy(voting_forum_address)
  );
  proposal = Table.borrow_mut_(
    voting_forum.proposals,
    $.copy(proposal_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Proposal, [$p[0]])]
  );
  if (is_voting_period_over_(proposal, $c, [$p[0]])) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EPROPOSAL_VOTING_ALREADY_ENDED), $c)
    );
  }
  if ($.copy(proposal.is_resolved)) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EPROPOSAL_ALREADY_RESOLVED), $c)
    );
  }
  if (should_pass) {
    proposal.yes_votes = $.copy(proposal.yes_votes).add(
      u128($.copy(num_votes))
    );
  } else {
    proposal.no_votes = $.copy(proposal.no_votes).add(u128($.copy(num_votes)));
  }
  temp$1 = Timestamp.now_seconds_($c);
  timestamp_secs_bytes = Bcs.to_bytes_(temp$1, $c, [AtomicTypeTag.U64]);
  key = String.utf8_($.copy(RESOLVABLE_TIME_METADATA_KEY), $c);
  if (
    Simple_map.contains_key_(proposal.metadata, key, $c, [
      new StructTag(new HexString("0x1"), "string", "String", []),
      new VectorTag(AtomicTypeTag.U8),
    ])
  ) {
    $.set(
      Simple_map.borrow_mut_(proposal.metadata, key, $c, [
        new StructTag(new HexString("0x1"), "string", "String", []),
        new VectorTag(AtomicTypeTag.U8),
      ]),
      $.copy(timestamp_secs_bytes)
    );
  } else {
    Simple_map.add_(
      proposal.metadata,
      $.copy(key),
      $.copy(timestamp_secs_bytes),
      $c,
      [
        new StructTag(new HexString("0x1"), "string", "String", []),
        new VectorTag(AtomicTypeTag.U8),
      ]
    );
  }
  Event.emit_event_(
    voting_forum.events.vote_events,
    new VoteEvent(
      { proposal_id: $.copy(proposal_id), num_votes: $.copy(num_votes) },
      new SimpleStructTag(VoteEvent)
    ),
    $c,
    [new SimpleStructTag(VoteEvent)]
  );
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::voting::CreateProposalEvent",
    CreateProposalEvent.CreateProposalEventParser
  );
  repo.addParser("0x1::voting::Proposal", Proposal.ProposalParser);
  repo.addParser(
    "0x1::voting::RegisterForumEvent",
    RegisterForumEvent.RegisterForumEventParser
  );
  repo.addParser(
    "0x1::voting::ResolveProposal",
    ResolveProposal.ResolveProposalParser
  );
  repo.addParser("0x1::voting::VoteEvent", VoteEvent.VoteEventParser);
  repo.addParser("0x1::voting::VotingEvents", VotingEvents.VotingEventsParser);
  repo.addParser("0x1::voting::VotingForum", VotingForum.VotingForumParser);
}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {}
  get moduleAddress() {
    {
      return moduleAddress;
    }
  }
  get moduleName() {
    {
      return moduleName;
    }
  }
  get CreateProposalEvent() {
    return CreateProposalEvent;
  }
  get Proposal() {
    return Proposal;
  }
  get RegisterForumEvent() {
    return RegisterForumEvent;
  }
  get ResolveProposal() {
    return ResolveProposal;
  }
  get VoteEvent() {
    return VoteEvent;
  }
  get VotingEvents() {
    return VotingEvents;
  }
  get VotingForum() {
    return VotingForum;
  }
  async loadVotingForum(
    owner: HexString,
    $p: TypeTag[] /* <ProposalType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await VotingForum.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
}
