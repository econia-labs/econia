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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Account from "./account";
import * as Aptos_coin from "./aptos_coin";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Event from "./event";
import * as Governance_proposal from "./governance_proposal";
import * as Option from "./option";
import * as Reconfiguration from "./reconfiguration";
import * as Signer from "./signer";
import * as Simple_map from "./simple_map";
import * as Stake from "./stake";
import * as Staking_config from "./staking_config";
import * as String from "./string";
import * as System_addresses from "./system_addresses";
import * as Table from "./table";
import * as Timestamp from "./timestamp";
import * as Voting from "./voting";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aptos_governance";

export const EALREADY_VOTED: U64 = u64("4");
export const EINSUFFICIENT_PROPOSER_STAKE: U64 = u64("1");
export const EINSUFFICIENT_STAKE_LOCKUP: U64 = u64("3");
export const EMETADATA_HASH_TOO_LONG: U64 = u64("10");
export const EMETADATA_LOCATION_TOO_LONG: U64 = u64("9");
export const ENOT_DELEGATED_VOTER: U64 = u64("2");
export const ENO_VOTING_POWER: U64 = u64("5");
export const EPROPOSAL_NOT_RESOLVABLE_YET: U64 = u64("6");
export const EPROPOSAL_NOT_RESOLVED_YET: U64 = u64("8");
export const EUNAUTHORIZED: U64 = u64("11");
export const METADATA_HASH_KEY: U8[] = [
  u8("109"),
  u8("101"),
  u8("116"),
  u8("97"),
  u8("100"),
  u8("97"),
  u8("116"),
  u8("97"),
  u8("95"),
  u8("104"),
  u8("97"),
  u8("115"),
  u8("104"),
];
export const METADATA_LOCATION_KEY: U8[] = [
  u8("109"),
  u8("101"),
  u8("116"),
  u8("97"),
  u8("100"),
  u8("97"),
  u8("116"),
  u8("97"),
  u8("95"),
  u8("108"),
  u8("111"),
  u8("99"),
  u8("97"),
  u8("116"),
  u8("105"),
  u8("111"),
  u8("110"),
];
export const PROPOSAL_STATE_SUCCEEDED: U64 = u64("1");

export class ApprovedExecutionHashes {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ApprovedExecutionHashes";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "hashes",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        AtomicTypeTag.U64,
        new VectorTag(AtomicTypeTag.U8),
      ]),
    },
  ];

  hashes: Simple_map.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.hashes = proto["hashes"] as Simple_map.SimpleMap;
  }

  static ApprovedExecutionHashesParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ApprovedExecutionHashes {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      ApprovedExecutionHashes
    );
    return new ApprovedExecutionHashes(proto, typeTag);
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
      ApprovedExecutionHashes,
      typeParams
    );
    return result as unknown as ApprovedExecutionHashes;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      ApprovedExecutionHashes,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as ApprovedExecutionHashes;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "ApprovedExecutionHashes",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.hashes.loadFullState(app);
    this.__app = app;
  }
}

export class CreateProposalEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CreateProposalEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "proposer", typeTag: AtomicTypeTag.Address },
    { name: "stake_pool", typeTag: AtomicTypeTag.Address },
    { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
    { name: "execution_hash", typeTag: new VectorTag(AtomicTypeTag.U8) },
    {
      name: "proposal_metadata",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        new StructTag(new HexString("0x1"), "string", "String", []),
        new VectorTag(AtomicTypeTag.U8),
      ]),
    },
  ];

  proposer: HexString;
  stake_pool: HexString;
  proposal_id: U64;
  execution_hash: U8[];
  proposal_metadata: Simple_map.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposer = proto["proposer"] as HexString;
    this.stake_pool = proto["stake_pool"] as HexString;
    this.proposal_id = proto["proposal_id"] as U64;
    this.execution_hash = proto["execution_hash"] as U8[];
    this.proposal_metadata = proto["proposal_metadata"] as Simple_map.SimpleMap;
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
    await this.proposal_metadata.loadFullState(app);
    this.__app = app;
  }
}

export class GovernanceConfig {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GovernanceConfig";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "min_voting_threshold", typeTag: AtomicTypeTag.U128 },
    { name: "required_proposer_stake", typeTag: AtomicTypeTag.U64 },
    { name: "voting_duration_secs", typeTag: AtomicTypeTag.U64 },
  ];

  min_voting_threshold: U128;
  required_proposer_stake: U64;
  voting_duration_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.min_voting_threshold = proto["min_voting_threshold"] as U128;
    this.required_proposer_stake = proto["required_proposer_stake"] as U64;
    this.voting_duration_secs = proto["voting_duration_secs"] as U64;
  }

  static GovernanceConfigParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GovernanceConfig {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceConfig);
    return new GovernanceConfig(proto, typeTag);
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
      GovernanceConfig,
      typeParams
    );
    return result as unknown as GovernanceConfig;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GovernanceConfig,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GovernanceConfig;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GovernanceConfig", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class GovernanceEvents {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GovernanceEvents";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "create_proposal_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "aptos_governance",
          "CreateProposalEvent",
          []
        ),
      ]),
    },
    {
      name: "update_config_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "aptos_governance",
          "UpdateConfigEvent",
          []
        ),
      ]),
    },
    {
      name: "vote_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "aptos_governance",
          "VoteEvent",
          []
        ),
      ]),
    },
  ];

  create_proposal_events: Event.EventHandle;
  update_config_events: Event.EventHandle;
  vote_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.create_proposal_events = proto[
      "create_proposal_events"
    ] as Event.EventHandle;
    this.update_config_events = proto[
      "update_config_events"
    ] as Event.EventHandle;
    this.vote_events = proto["vote_events"] as Event.EventHandle;
  }

  static GovernanceEventsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GovernanceEvents {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceEvents);
    return new GovernanceEvents(proto, typeTag);
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
      GovernanceEvents,
      typeParams
    );
    return result as unknown as GovernanceEvents;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GovernanceEvents,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GovernanceEvents;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GovernanceEvents", []);
  }
  async loadFullState(app: $.AppType) {
    await this.create_proposal_events.loadFullState(app);
    await this.update_config_events.loadFullState(app);
    await this.vote_events.loadFullState(app);
    this.__app = app;
  }
}

export class GovernanceResponsbility {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GovernanceResponsbility";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "signer_caps",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        AtomicTypeTag.Address,
        new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
      ]),
    },
  ];

  signer_caps: Simple_map.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.signer_caps = proto["signer_caps"] as Simple_map.SimpleMap;
  }

  static GovernanceResponsbilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GovernanceResponsbility {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      GovernanceResponsbility
    );
    return new GovernanceResponsbility(proto, typeTag);
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
      GovernanceResponsbility,
      typeParams
    );
    return result as unknown as GovernanceResponsbility;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GovernanceResponsbility,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GovernanceResponsbility;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "GovernanceResponsbility",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.signer_caps.loadFullState(app);
    this.__app = app;
  }
}

export class RecordKey {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RecordKey";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "stake_pool", typeTag: AtomicTypeTag.Address },
    { name: "proposal_id", typeTag: AtomicTypeTag.U64 },
  ];

  stake_pool: HexString;
  proposal_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.stake_pool = proto["stake_pool"] as HexString;
    this.proposal_id = proto["proposal_id"] as U64;
  }

  static RecordKeyParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RecordKey {
    const proto = $.parseStructProto(data, typeTag, repo, RecordKey);
    return new RecordKey(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RecordKey", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UpdateConfigEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UpdateConfigEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "min_voting_threshold", typeTag: AtomicTypeTag.U128 },
    { name: "required_proposer_stake", typeTag: AtomicTypeTag.U64 },
    { name: "voting_duration_secs", typeTag: AtomicTypeTag.U64 },
  ];

  min_voting_threshold: U128;
  required_proposer_stake: U64;
  voting_duration_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.min_voting_threshold = proto["min_voting_threshold"] as U128;
    this.required_proposer_stake = proto["required_proposer_stake"] as U64;
    this.voting_duration_secs = proto["voting_duration_secs"] as U64;
  }

  static UpdateConfigEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UpdateConfigEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UpdateConfigEvent);
    return new UpdateConfigEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UpdateConfigEvent", []);
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
    { name: "voter", typeTag: AtomicTypeTag.Address },
    { name: "stake_pool", typeTag: AtomicTypeTag.Address },
    { name: "num_votes", typeTag: AtomicTypeTag.U64 },
    { name: "should_pass", typeTag: AtomicTypeTag.Bool },
  ];

  proposal_id: U64;
  voter: HexString;
  stake_pool: HexString;
  num_votes: U64;
  should_pass: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.proposal_id = proto["proposal_id"] as U64;
    this.voter = proto["voter"] as HexString;
    this.stake_pool = proto["stake_pool"] as HexString;
    this.num_votes = proto["num_votes"] as U64;
    this.should_pass = proto["should_pass"] as boolean;
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

export class VotingRecords {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VotingRecords";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "votes",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        new StructTag(
          new HexString("0x1"),
          "aptos_governance",
          "RecordKey",
          []
        ),
        AtomicTypeTag.Bool,
      ]),
    },
  ];

  votes: Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.votes = proto["votes"] as Table.Table;
  }

  static VotingRecordsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VotingRecords {
    const proto = $.parseStructProto(data, typeTag, repo, VotingRecords);
    return new VotingRecords(proto, typeTag);
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
      VotingRecords,
      typeParams
    );
    return result as unknown as VotingRecords;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      VotingRecords,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as VotingRecords;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "VotingRecords", []);
  }
  async loadFullState(app: $.AppType) {
    await this.votes.loadFullState(app);
    this.__app = app;
  }
}
export function add_approved_script_hash_(
  proposal_id: U64,
  $c: AptosDataCache
): void {
  let approved_hashes, execution_hash, proposal_state;
  approved_hashes = $c.borrow_global_mut<ApprovedExecutionHashes>(
    new SimpleStructTag(ApprovedExecutionHashes),
    new HexString("0x1")
  );
  if (
    Simple_map.contains_key_(approved_hashes.hashes, proposal_id, $c, [
      AtomicTypeTag.U64,
      new VectorTag(AtomicTypeTag.U8),
    ])
  ) {
    return;
  } else {
  }
  proposal_state = Voting.get_proposal_state_(
    new HexString("0x1"),
    $.copy(proposal_id),
    $c,
    [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ]
  );
  if (!$.copy(proposal_state).eq($.copy(PROPOSAL_STATE_SUCCEEDED))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EPROPOSAL_NOT_RESOLVABLE_YET), $c)
    );
  }
  execution_hash = Voting.get_execution_hash_(
    new HexString("0x1"),
    $.copy(proposal_id),
    $c,
    [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ]
  );
  Simple_map.add_(
    approved_hashes.hashes,
    $.copy(proposal_id),
    $.copy(execution_hash),
    $c,
    [AtomicTypeTag.U64, new VectorTag(AtomicTypeTag.U8)]
  );
  return;
}

export function add_approved_script_hash_script_(
  proposal_id: U64,
  $c: AptosDataCache
): void {
  return add_approved_script_hash_($.copy(proposal_id), $c);
}

export function buildPayload_add_approved_script_hash_script(
  proposal_id: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_governance",
    "add_approved_script_hash_script",
    typeParamStrings,
    [proposal_id],
    isJSON
  );
}
export function create_proposal_(
  proposer: HexString,
  stake_pool: HexString,
  execution_hash: U8[],
  metadata_location: U8[],
  metadata_hash: U8[],
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    current_time,
    early_resolution_vote_threshold,
    events,
    governance_config,
    proposal_expiration,
    proposal_id,
    proposal_metadata,
    proposer_address,
    stake_balance,
    total_supply,
    total_voting_token_supply;
  proposer_address = Signer.address_of_(proposer, $c);
  if (
    !(
      Stake.get_delegated_voter_($.copy(stake_pool), $c).hex() ===
      $.copy(proposer_address).hex()
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ENOT_DELEGATED_VOTER), $c)
    );
  }
  governance_config = $c.borrow_global<GovernanceConfig>(
    new SimpleStructTag(GovernanceConfig),
    new HexString("0x1")
  );
  stake_balance = get_voting_power_($.copy(stake_pool), $c);
  if (
    !$.copy(stake_balance).ge($.copy(governance_config.required_proposer_stake))
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_PROPOSER_STAKE), $c)
    );
  }
  current_time = Timestamp.now_seconds_($c);
  proposal_expiration = $.copy(current_time).add(
    $.copy(governance_config.voting_duration_secs)
  );
  if (
    !Stake.get_lockup_secs_($.copy(stake_pool), $c).ge(
      $.copy(proposal_expiration)
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_STAKE_LOCKUP), $c)
    );
  }
  proposal_metadata = create_proposal_metadata_(
    $.copy(metadata_location),
    $.copy(metadata_hash),
    $c
  );
  total_voting_token_supply = Coin.supply_($c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  early_resolution_vote_threshold = Option.none_($c, [AtomicTypeTag.U128]);
  if (Option.is_some_(total_voting_token_supply, $c, [AtomicTypeTag.U128])) {
    total_supply = $.copy(
      Option.borrow_(total_voting_token_supply, $c, [AtomicTypeTag.U128])
    );
    early_resolution_vote_threshold = Option.some_(
      $.copy(total_supply).div(u128("2")).add(u128("1")),
      $c,
      [AtomicTypeTag.U128]
    );
  } else {
  }
  proposal_id = Voting.create_proposal_(
    $.copy(proposer_address),
    new HexString("0x1"),
    Governance_proposal.create_proposal_($c),
    $.copy(execution_hash),
    $.copy(governance_config.min_voting_threshold),
    $.copy(proposal_expiration),
    $.copy(early_resolution_vote_threshold),
    $.copy(proposal_metadata),
    $c,
    [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ]
  );
  events = $c.borrow_global_mut<GovernanceEvents>(
    new SimpleStructTag(GovernanceEvents),
    new HexString("0x1")
  );
  temp$6 = events.create_proposal_events;
  temp$1 = $.copy(proposal_id);
  temp$2 = $.copy(proposer_address);
  temp$3 = $.copy(stake_pool);
  temp$4 = $.copy(execution_hash);
  temp$5 = $.copy(proposal_metadata);
  Event.emit_event_(
    temp$6,
    new CreateProposalEvent(
      {
        proposer: temp$2,
        stake_pool: temp$3,
        proposal_id: temp$1,
        execution_hash: temp$4,
        proposal_metadata: temp$5,
      },
      new SimpleStructTag(CreateProposalEvent)
    ),
    $c,
    [new SimpleStructTag(CreateProposalEvent)]
  );
  return;
}

export function buildPayload_create_proposal(
  stake_pool: HexString,
  execution_hash: U8[],
  metadata_location: U8[],
  metadata_hash: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_governance",
    "create_proposal",
    typeParamStrings,
    [stake_pool, execution_hash, metadata_location, metadata_hash],
    isJSON
  );
}
export function create_proposal_metadata_(
  metadata_location: U8[],
  metadata_hash: U8[],
  $c: AptosDataCache
): Simple_map.SimpleMap {
  let temp$1, temp$2, metadata;
  temp$1 = String.utf8_($.copy(metadata_location), $c);
  if (!String.length_(temp$1, $c).le(u64("256"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EMETADATA_LOCATION_TOO_LONG), $c)
    );
  }
  temp$2 = String.utf8_($.copy(metadata_hash), $c);
  if (!String.length_(temp$2, $c).le(u64("256"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EMETADATA_HASH_TOO_LONG), $c)
    );
  }
  metadata = Simple_map.create_($c, [
    new StructTag(new HexString("0x1"), "string", "String", []),
    new VectorTag(AtomicTypeTag.U8),
  ]);
  Simple_map.add_(
    metadata,
    String.utf8_($.copy(METADATA_LOCATION_KEY), $c),
    $.copy(metadata_location),
    $c,
    [
      new StructTag(new HexString("0x1"), "string", "String", []),
      new VectorTag(AtomicTypeTag.U8),
    ]
  );
  Simple_map.add_(
    metadata,
    String.utf8_($.copy(METADATA_HASH_KEY), $c),
    $.copy(metadata_hash),
    $c,
    [
      new StructTag(new HexString("0x1"), "string", "String", []),
      new VectorTag(AtomicTypeTag.U8),
    ]
  );
  return $.copy(metadata);
}

export function get_min_voting_threshold_($c: AptosDataCache): U128 {
  return $.copy(
    $c.borrow_global<GovernanceConfig>(
      new SimpleStructTag(GovernanceConfig),
      new HexString("0x1")
    ).min_voting_threshold
  );
}

export function get_required_proposer_stake_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<GovernanceConfig>(
      new SimpleStructTag(GovernanceConfig),
      new HexString("0x1")
    ).required_proposer_stake
  );
}

export function get_signer_(
  signer_address: HexString,
  $c: AptosDataCache
): HexString {
  let governance_responsibility, signer_cap;
  governance_responsibility = $c.borrow_global<GovernanceResponsbility>(
    new SimpleStructTag(GovernanceResponsbility),
    new HexString("0x1")
  );
  signer_cap = Simple_map.borrow_(
    governance_responsibility.signer_caps,
    signer_address,
    $c,
    [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
    ]
  );
  return Account.create_signer_with_capability_(signer_cap, $c);
}

export function get_signer_testnet_only_(
  core_resources: HexString,
  signer_address: HexString,
  $c: AptosDataCache
): HexString {
  System_addresses.assert_core_resource_(core_resources, $c);
  if (!Aptos_coin.has_mint_capability_(core_resources, $c)) {
    throw $.abortCode(Error.unauthenticated_($.copy(EUNAUTHORIZED), $c));
  }
  return get_signer_($.copy(signer_address), $c);
}

export function get_voting_duration_secs_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<GovernanceConfig>(
      new SimpleStructTag(GovernanceConfig),
      new HexString("0x1")
    ).voting_duration_secs
  );
}

export function get_voting_power_(
  pool_address: HexString,
  $c: AptosDataCache
): U64 {
  let temp$1,
    temp$2,
    active,
    allow_validator_set_change,
    pending_active,
    pending_inactive;
  temp$1 = Staking_config.get_($c);
  allow_validator_set_change = Staking_config.get_allow_validator_set_change_(
    temp$1,
    $c
  );
  if (allow_validator_set_change) {
    [active, , pending_active, pending_inactive] = Stake.get_stake_(
      $.copy(pool_address),
      $c
    );
    temp$2 = $.copy(active)
      .add($.copy(pending_active))
      .add($.copy(pending_inactive));
  } else {
    temp$2 = Stake.get_current_epoch_voting_power_($.copy(pool_address), $c);
  }
  return temp$2;
}

export function initialize_(
  aptos_framework: HexString,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_duration_secs: U64,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, temp$4;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  Voting.register_(aptos_framework, $c, [
    new StructTag(
      new HexString("0x1"),
      "governance_proposal",
      "GovernanceProposal",
      []
    ),
  ]);
  temp$4 = aptos_framework;
  temp$1 = $.copy(voting_duration_secs);
  temp$2 = $.copy(min_voting_threshold);
  temp$3 = $.copy(required_proposer_stake);
  $c.move_to(
    new SimpleStructTag(GovernanceConfig),
    temp$4,
    new GovernanceConfig(
      {
        min_voting_threshold: temp$2,
        required_proposer_stake: temp$3,
        voting_duration_secs: temp$1,
      },
      new SimpleStructTag(GovernanceConfig)
    )
  );
  $c.move_to(
    new SimpleStructTag(GovernanceEvents),
    aptos_framework,
    new GovernanceEvents(
      {
        create_proposal_events: Account.new_event_handle_(aptos_framework, $c, [
          new SimpleStructTag(CreateProposalEvent),
        ]),
        update_config_events: Account.new_event_handle_(aptos_framework, $c, [
          new SimpleStructTag(UpdateConfigEvent),
        ]),
        vote_events: Account.new_event_handle_(aptos_framework, $c, [
          new SimpleStructTag(VoteEvent),
        ]),
      },
      new SimpleStructTag(GovernanceEvents)
    )
  );
  $c.move_to(
    new SimpleStructTag(VotingRecords),
    aptos_framework,
    new VotingRecords(
      {
        votes: Table.new___($c, [
          new SimpleStructTag(RecordKey),
          AtomicTypeTag.Bool,
        ]),
      },
      new SimpleStructTag(VotingRecords)
    )
  );
  return $c.move_to(
    new SimpleStructTag(ApprovedExecutionHashes),
    aptos_framework,
    new ApprovedExecutionHashes(
      {
        hashes: Simple_map.create_($c, [
          AtomicTypeTag.U64,
          new VectorTag(AtomicTypeTag.U8),
        ]),
      },
      new SimpleStructTag(ApprovedExecutionHashes)
    )
  );
}

export function initialize_for_verification_(
  aptos_framework: HexString,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_duration_secs: U64,
  $c: AptosDataCache
): void {
  initialize_(
    aptos_framework,
    $.copy(min_voting_threshold),
    $.copy(required_proposer_stake),
    $.copy(voting_duration_secs),
    $c
  );
  return;
}

export function reconfigure_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  Reconfiguration.reconfigure_($c);
  return;
}

export function remove_approved_hash_(
  proposal_id: U64,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, approved_hashes;
  if (
    !Voting.is_resolved_(new HexString("0x1"), $.copy(proposal_id), $c, [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ])
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EPROPOSAL_NOT_RESOLVED_YET), $c)
    );
  }
  approved_hashes = $c.borrow_global_mut<ApprovedExecutionHashes>(
    new SimpleStructTag(ApprovedExecutionHashes),
    new HexString("0x1")
  ).hashes;
  [temp$1, temp$2] = [approved_hashes, proposal_id];
  if (
    Simple_map.contains_key_(temp$1, temp$2, $c, [
      AtomicTypeTag.U64,
      new VectorTag(AtomicTypeTag.U8),
    ])
  ) {
    Simple_map.remove_(approved_hashes, proposal_id, $c, [
      AtomicTypeTag.U64,
      new VectorTag(AtomicTypeTag.U8),
    ]);
  } else {
  }
  return;
}

export function resolve_(
  proposal_id: U64,
  signer_address: HexString,
  $c: AptosDataCache
): HexString {
  Voting.resolve_(new HexString("0x1"), $.copy(proposal_id), $c, [
    new StructTag(
      new HexString("0x1"),
      "governance_proposal",
      "GovernanceProposal",
      []
    ),
  ]);
  remove_approved_hash_($.copy(proposal_id), $c);
  return get_signer_($.copy(signer_address), $c);
}

export function store_signer_cap_(
  aptos_framework: HexString,
  signer_address: HexString,
  signer_cap: Account.SignerCapability,
  $c: AptosDataCache
): void {
  let signer_caps;
  System_addresses.assert_framework_reserved_address_(aptos_framework, $c);
  if (
    !$c.exists(
      new SimpleStructTag(GovernanceResponsbility),
      new HexString("0x1")
    )
  ) {
    $c.move_to(
      new SimpleStructTag(GovernanceResponsbility),
      aptos_framework,
      new GovernanceResponsbility(
        {
          signer_caps: Simple_map.create_($c, [
            AtomicTypeTag.Address,
            new StructTag(
              new HexString("0x1"),
              "account",
              "SignerCapability",
              []
            ),
          ]),
        },
        new SimpleStructTag(GovernanceResponsbility)
      )
    );
  } else {
  }
  signer_caps = $c.borrow_global_mut<GovernanceResponsbility>(
    new SimpleStructTag(GovernanceResponsbility),
    new HexString("0x1")
  ).signer_caps;
  Simple_map.add_(signer_caps, $.copy(signer_address), signer_cap, $c, [
    AtomicTypeTag.Address,
    new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
  ]);
  return;
}

export function update_governance_config_(
  aptos_framework: HexString,
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_duration_secs: U64,
  $c: AptosDataCache
): void {
  let events, governance_config;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  governance_config = $c.borrow_global_mut<GovernanceConfig>(
    new SimpleStructTag(GovernanceConfig),
    new HexString("0x1")
  );
  governance_config.voting_duration_secs = $.copy(voting_duration_secs);
  governance_config.min_voting_threshold = $.copy(min_voting_threshold);
  governance_config.required_proposer_stake = $.copy(required_proposer_stake);
  events = $c.borrow_global_mut<GovernanceEvents>(
    new SimpleStructTag(GovernanceEvents),
    new HexString("0x1")
  );
  Event.emit_event_(
    events.update_config_events,
    new UpdateConfigEvent(
      {
        min_voting_threshold: $.copy(min_voting_threshold),
        required_proposer_stake: $.copy(required_proposer_stake),
        voting_duration_secs: $.copy(voting_duration_secs),
      },
      new SimpleStructTag(UpdateConfigEvent)
    ),
    $c,
    [new SimpleStructTag(UpdateConfigEvent)]
  );
  return;
}

export function vote_(
  voter: HexString,
  stake_pool: HexString,
  proposal_id: U64,
  should_pass: boolean,
  $c: AptosDataCache
): void {
  let temp$1,
    events,
    proposal_expiration,
    proposal_state,
    record_key,
    voter_address,
    voting_power,
    voting_records;
  voter_address = Signer.address_of_(voter, $c);
  if (
    !(
      Stake.get_delegated_voter_($.copy(stake_pool), $c).hex() ===
      $.copy(voter_address).hex()
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ENOT_DELEGATED_VOTER), $c)
    );
  }
  voting_records = $c.borrow_global_mut<VotingRecords>(
    new SimpleStructTag(VotingRecords),
    new HexString("0x1")
  );
  record_key = new RecordKey(
    { stake_pool: $.copy(stake_pool), proposal_id: $.copy(proposal_id) },
    new SimpleStructTag(RecordKey)
  );
  if (
    Table.contains_(voting_records.votes, $.copy(record_key), $c, [
      new SimpleStructTag(RecordKey),
      AtomicTypeTag.Bool,
    ])
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(EALREADY_VOTED), $c));
  }
  Table.add_(voting_records.votes, $.copy(record_key), true, $c, [
    new SimpleStructTag(RecordKey),
    AtomicTypeTag.Bool,
  ]);
  voting_power = get_voting_power_($.copy(stake_pool), $c);
  if (!$.copy(voting_power).gt(u64("0"))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ENO_VOTING_POWER), $c));
  }
  proposal_expiration = Voting.get_proposal_expiration_secs_(
    new HexString("0x1"),
    $.copy(proposal_id),
    $c,
    [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ]
  );
  if (
    !Stake.get_lockup_secs_($.copy(stake_pool), $c).ge(
      $.copy(proposal_expiration)
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_STAKE_LOCKUP), $c)
    );
  }
  temp$1 = Governance_proposal.create_empty_proposal_($c);
  Voting.vote_(
    temp$1,
    new HexString("0x1"),
    $.copy(proposal_id),
    $.copy(voting_power),
    should_pass,
    $c,
    [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ]
  );
  events = $c.borrow_global_mut<GovernanceEvents>(
    new SimpleStructTag(GovernanceEvents),
    new HexString("0x1")
  );
  Event.emit_event_(
    events.vote_events,
    new VoteEvent(
      {
        proposal_id: $.copy(proposal_id),
        voter: $.copy(voter_address),
        stake_pool: $.copy(stake_pool),
        num_votes: $.copy(voting_power),
        should_pass: should_pass,
      },
      new SimpleStructTag(VoteEvent)
    ),
    $c,
    [new SimpleStructTag(VoteEvent)]
  );
  proposal_state = Voting.get_proposal_state_(
    new HexString("0x1"),
    $.copy(proposal_id),
    $c,
    [
      new StructTag(
        new HexString("0x1"),
        "governance_proposal",
        "GovernanceProposal",
        []
      ),
    ]
  );
  if ($.copy(proposal_state).eq($.copy(PROPOSAL_STATE_SUCCEEDED))) {
    add_approved_script_hash_($.copy(proposal_id), $c);
  } else {
  }
  return;
}

export function buildPayload_vote(
  stake_pool: HexString,
  proposal_id: U64,
  should_pass: boolean,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_governance",
    "vote",
    typeParamStrings,
    [stake_pool, proposal_id, should_pass],
    isJSON
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::aptos_governance::ApprovedExecutionHashes",
    ApprovedExecutionHashes.ApprovedExecutionHashesParser
  );
  repo.addParser(
    "0x1::aptos_governance::CreateProposalEvent",
    CreateProposalEvent.CreateProposalEventParser
  );
  repo.addParser(
    "0x1::aptos_governance::GovernanceConfig",
    GovernanceConfig.GovernanceConfigParser
  );
  repo.addParser(
    "0x1::aptos_governance::GovernanceEvents",
    GovernanceEvents.GovernanceEventsParser
  );
  repo.addParser(
    "0x1::aptos_governance::GovernanceResponsbility",
    GovernanceResponsbility.GovernanceResponsbilityParser
  );
  repo.addParser("0x1::aptos_governance::RecordKey", RecordKey.RecordKeyParser);
  repo.addParser(
    "0x1::aptos_governance::UpdateConfigEvent",
    UpdateConfigEvent.UpdateConfigEventParser
  );
  repo.addParser("0x1::aptos_governance::VoteEvent", VoteEvent.VoteEventParser);
  repo.addParser(
    "0x1::aptos_governance::VotingRecords",
    VotingRecords.VotingRecordsParser
  );
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
  get ApprovedExecutionHashes() {
    return ApprovedExecutionHashes;
  }
  async loadApprovedExecutionHashes(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await ApprovedExecutionHashes.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get CreateProposalEvent() {
    return CreateProposalEvent;
  }
  get GovernanceConfig() {
    return GovernanceConfig;
  }
  async loadGovernanceConfig(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await GovernanceConfig.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get GovernanceEvents() {
    return GovernanceEvents;
  }
  async loadGovernanceEvents(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await GovernanceEvents.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get GovernanceResponsbility() {
    return GovernanceResponsbility;
  }
  async loadGovernanceResponsbility(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await GovernanceResponsbility.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get RecordKey() {
    return RecordKey;
  }
  get UpdateConfigEvent() {
    return UpdateConfigEvent;
  }
  get VoteEvent() {
    return VoteEvent;
  }
  get VotingRecords() {
    return VotingRecords;
  }
  async loadVotingRecords(owner: HexString, loadFull = true, fillCache = true) {
    const val = await VotingRecords.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  payload_add_approved_script_hash_script(
    proposal_id: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_add_approved_script_hash_script(proposal_id, isJSON);
  }
  async add_approved_script_hash_script(
    _account: AptosAccount,
    proposal_id: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_add_approved_script_hash_script(
      proposal_id,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_create_proposal(
    stake_pool: HexString,
    execution_hash: U8[],
    metadata_location: U8[],
    metadata_hash: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_create_proposal(
      stake_pool,
      execution_hash,
      metadata_location,
      metadata_hash,
      isJSON
    );
  }
  async create_proposal(
    _account: AptosAccount,
    stake_pool: HexString,
    execution_hash: U8[],
    metadata_location: U8[],
    metadata_hash: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_create_proposal(
      stake_pool,
      execution_hash,
      metadata_location,
      metadata_hash,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_vote(
    stake_pool: HexString,
    proposal_id: U64,
    should_pass: boolean,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_vote(stake_pool, proposal_id, should_pass, isJSON);
  }
  async vote(
    _account: AptosAccount,
    stake_pool: HexString,
    proposal_id: U64,
    should_pass: boolean,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_vote(
      stake_pool,
      proposal_id,
      should_pass,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
