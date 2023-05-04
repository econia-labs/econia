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
import * as Bls12381 from "./bls12381";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Event from "./event";
import * as Math64 from "./math64";
import * as Option from "./option";
import * as Signer from "./signer";
import * as Staking_config from "./staking_config";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "stake";

export const EALREADY_ACTIVE_VALIDATOR: U64 = u64("4");
export const EALREADY_REGISTERED: U64 = u64("8");
export const EINELIGIBLE_VALIDATOR: U64 = u64("17");
export const EINVALID_LOCKUP: U64 = u64("18");
export const EINVALID_PUBLIC_KEY: U64 = u64("11");
export const ELAST_VALIDATOR: U64 = u64("6");
export const ENOT_OPERATOR: U64 = u64("9");
export const ENOT_VALIDATOR: U64 = u64("5");
export const ENO_POST_GENESIS_VALIDATOR_SET_CHANGE_ALLOWED: U64 = u64("10");
export const EOWNER_CAP_ALREADY_EXISTS: U64 = u64("16");
export const EOWNER_CAP_NOT_FOUND: U64 = u64("15");
export const ESTAKE_EXCEEDS_MAX: U64 = u64("7");
export const ESTAKE_POOL_DOES_NOT_EXIST: U64 = u64("14");
export const ESTAKE_TOO_HIGH: U64 = u64("3");
export const ESTAKE_TOO_LOW: U64 = u64("2");
export const EVALIDATOR_CONFIG: U64 = u64("1");
export const EVALIDATOR_SET_TOO_LARGE: U64 = u64("12");
export const EVOTING_POWER_INCREASE_EXCEEDS_LIMIT: U64 = u64("13");
export const MAX_REWARDS_RATE: U64 = u64("1000000");
export const MAX_VALIDATOR_SET_SIZE: U64 = u64("65536");
export const VALIDATOR_STATUS_ACTIVE: U64 = u64("2");
export const VALIDATOR_STATUS_INACTIVE: U64 = u64("4");
export const VALIDATOR_STATUS_PENDING_ACTIVE: U64 = u64("1");
export const VALIDATOR_STATUS_PENDING_INACTIVE: U64 = u64("3");

export class AddStakeEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AddStakeEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount_added", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  amount_added: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.amount_added = proto["amount_added"] as U64;
  }

  static AddStakeEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AddStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, AddStakeEvent);
    return new AddStakeEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AddStakeEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class AllowedValidators {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AllowedValidators";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "accounts", typeTag: new VectorTag(AtomicTypeTag.Address) },
  ];

  accounts: HexString[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.accounts = proto["accounts"] as HexString[];
  }

  static AllowedValidatorsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AllowedValidators {
    const proto = $.parseStructProto(data, typeTag, repo, AllowedValidators);
    return new AllowedValidators(proto, typeTag);
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
      AllowedValidators,
      typeParams
    );
    return result as unknown as AllowedValidators;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      AllowedValidators,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as AllowedValidators;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AllowedValidators", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class AptosCoinCapabilities {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AptosCoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "mint_cap",
      typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
  ];

  mint_cap: Coin.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_cap = proto["mint_cap"] as Coin.MintCapability;
  }

  static AptosCoinCapabilitiesParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AptosCoinCapabilities {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      AptosCoinCapabilities
    );
    return new AptosCoinCapabilities(proto, typeTag);
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
      AptosCoinCapabilities,
      typeParams
    );
    return result as unknown as AptosCoinCapabilities;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      AptosCoinCapabilities,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as AptosCoinCapabilities;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "AptosCoinCapabilities",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.mint_cap.loadFullState(app);
    this.__app = app;
  }
}

export class DistributeRewardsEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "DistributeRewardsEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "rewards_amount", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  rewards_amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.rewards_amount = proto["rewards_amount"] as U64;
  }

  static DistributeRewardsEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): DistributeRewardsEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      DistributeRewardsEvent
    );
    return new DistributeRewardsEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "DistributeRewardsEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class IncreaseLockupEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "IncreaseLockupEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_locked_until_secs", typeTag: AtomicTypeTag.U64 },
    { name: "new_locked_until_secs", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  old_locked_until_secs: U64;
  new_locked_until_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.old_locked_until_secs = proto["old_locked_until_secs"] as U64;
    this.new_locked_until_secs = proto["new_locked_until_secs"] as U64;
  }

  static IncreaseLockupEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): IncreaseLockupEvent {
    const proto = $.parseStructProto(data, typeTag, repo, IncreaseLockupEvent);
    return new IncreaseLockupEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "IncreaseLockupEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class IndividualValidatorPerformance {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "IndividualValidatorPerformance";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "successful_proposals", typeTag: AtomicTypeTag.U64 },
    { name: "failed_proposals", typeTag: AtomicTypeTag.U64 },
  ];

  successful_proposals: U64;
  failed_proposals: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.successful_proposals = proto["successful_proposals"] as U64;
    this.failed_proposals = proto["failed_proposals"] as U64;
  }

  static IndividualValidatorPerformanceParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): IndividualValidatorPerformance {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      IndividualValidatorPerformance
    );
    return new IndividualValidatorPerformance(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "IndividualValidatorPerformance",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class JoinValidatorSetEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "JoinValidatorSetEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
  ];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
  }

  static JoinValidatorSetEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): JoinValidatorSetEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      JoinValidatorSetEvent
    );
    return new JoinValidatorSetEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "JoinValidatorSetEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class LeaveValidatorSetEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "LeaveValidatorSetEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
  ];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
  }

  static LeaveValidatorSetEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): LeaveValidatorSetEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      LeaveValidatorSetEvent
    );
    return new LeaveValidatorSetEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "LeaveValidatorSetEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class OwnerCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "OwnerCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
  ];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
  }

  static OwnerCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): OwnerCapability {
    const proto = $.parseStructProto(data, typeTag, repo, OwnerCapability);
    return new OwnerCapability(proto, typeTag);
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
      OwnerCapability,
      typeParams
    );
    return result as unknown as OwnerCapability;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      OwnerCapability,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as OwnerCapability;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "OwnerCapability", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ReactivateStakeEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ReactivateStakeEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.amount = proto["amount"] as U64;
  }

  static ReactivateStakeEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ReactivateStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, ReactivateStakeEvent);
    return new ReactivateStakeEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ReactivateStakeEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class RegisterValidatorCandidateEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RegisterValidatorCandidateEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
  ];

  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
  }

  static RegisterValidatorCandidateEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RegisterValidatorCandidateEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      RegisterValidatorCandidateEvent
    );
    return new RegisterValidatorCandidateEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "RegisterValidatorCandidateEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class RotateConsensusKeyEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RotateConsensusKeyEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "new_consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  pool_address: HexString;
  old_consensus_pubkey: U8[];
  new_consensus_pubkey: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.old_consensus_pubkey = proto["old_consensus_pubkey"] as U8[];
    this.new_consensus_pubkey = proto["new_consensus_pubkey"] as U8[];
  }

  static RotateConsensusKeyEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RotateConsensusKeyEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      RotateConsensusKeyEvent
    );
    return new RotateConsensusKeyEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "RotateConsensusKeyEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class SetOperatorEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SetOperatorEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_operator", typeTag: AtomicTypeTag.Address },
    { name: "new_operator", typeTag: AtomicTypeTag.Address },
  ];

  pool_address: HexString;
  old_operator: HexString;
  new_operator: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.old_operator = proto["old_operator"] as HexString;
    this.new_operator = proto["new_operator"] as HexString;
  }

  static SetOperatorEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SetOperatorEvent {
    const proto = $.parseStructProto(data, typeTag, repo, SetOperatorEvent);
    return new SetOperatorEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SetOperatorEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class StakePool {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StakePool";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "active",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
    {
      name: "inactive",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
    {
      name: "pending_active",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
    {
      name: "pending_inactive",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
    { name: "locked_until_secs", typeTag: AtomicTypeTag.U64 },
    { name: "operator_address", typeTag: AtomicTypeTag.Address },
    { name: "delegated_voter", typeTag: AtomicTypeTag.Address },
    {
      name: "initialize_validator_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "RegisterValidatorCandidateEvent",
          []
        ),
      ]),
    },
    {
      name: "set_operator_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "stake", "SetOperatorEvent", []),
      ]),
    },
    {
      name: "add_stake_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "stake", "AddStakeEvent", []),
      ]),
    },
    {
      name: "reactivate_stake_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "ReactivateStakeEvent",
          []
        ),
      ]),
    },
    {
      name: "rotate_consensus_key_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "RotateConsensusKeyEvent",
          []
        ),
      ]),
    },
    {
      name: "update_network_and_fullnode_addresses_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "UpdateNetworkAndFullnodeAddressesEvent",
          []
        ),
      ]),
    },
    {
      name: "increase_lockup_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "stake", "IncreaseLockupEvent", []),
      ]),
    },
    {
      name: "join_validator_set_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "JoinValidatorSetEvent",
          []
        ),
      ]),
    },
    {
      name: "distribute_rewards_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "DistributeRewardsEvent",
          []
        ),
      ]),
    },
    {
      name: "unlock_stake_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "stake", "UnlockStakeEvent", []),
      ]),
    },
    {
      name: "withdraw_stake_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "stake", "WithdrawStakeEvent", []),
      ]),
    },
    {
      name: "leave_validator_set_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "stake",
          "LeaveValidatorSetEvent",
          []
        ),
      ]),
    },
  ];

  active: Coin.Coin;
  inactive: Coin.Coin;
  pending_active: Coin.Coin;
  pending_inactive: Coin.Coin;
  locked_until_secs: U64;
  operator_address: HexString;
  delegated_voter: HexString;
  initialize_validator_events: Event.EventHandle;
  set_operator_events: Event.EventHandle;
  add_stake_events: Event.EventHandle;
  reactivate_stake_events: Event.EventHandle;
  rotate_consensus_key_events: Event.EventHandle;
  update_network_and_fullnode_addresses_events: Event.EventHandle;
  increase_lockup_events: Event.EventHandle;
  join_validator_set_events: Event.EventHandle;
  distribute_rewards_events: Event.EventHandle;
  unlock_stake_events: Event.EventHandle;
  withdraw_stake_events: Event.EventHandle;
  leave_validator_set_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.active = proto["active"] as Coin.Coin;
    this.inactive = proto["inactive"] as Coin.Coin;
    this.pending_active = proto["pending_active"] as Coin.Coin;
    this.pending_inactive = proto["pending_inactive"] as Coin.Coin;
    this.locked_until_secs = proto["locked_until_secs"] as U64;
    this.operator_address = proto["operator_address"] as HexString;
    this.delegated_voter = proto["delegated_voter"] as HexString;
    this.initialize_validator_events = proto[
      "initialize_validator_events"
    ] as Event.EventHandle;
    this.set_operator_events = proto[
      "set_operator_events"
    ] as Event.EventHandle;
    this.add_stake_events = proto["add_stake_events"] as Event.EventHandle;
    this.reactivate_stake_events = proto[
      "reactivate_stake_events"
    ] as Event.EventHandle;
    this.rotate_consensus_key_events = proto[
      "rotate_consensus_key_events"
    ] as Event.EventHandle;
    this.update_network_and_fullnode_addresses_events = proto[
      "update_network_and_fullnode_addresses_events"
    ] as Event.EventHandle;
    this.increase_lockup_events = proto[
      "increase_lockup_events"
    ] as Event.EventHandle;
    this.join_validator_set_events = proto[
      "join_validator_set_events"
    ] as Event.EventHandle;
    this.distribute_rewards_events = proto[
      "distribute_rewards_events"
    ] as Event.EventHandle;
    this.unlock_stake_events = proto[
      "unlock_stake_events"
    ] as Event.EventHandle;
    this.withdraw_stake_events = proto[
      "withdraw_stake_events"
    ] as Event.EventHandle;
    this.leave_validator_set_events = proto[
      "leave_validator_set_events"
    ] as Event.EventHandle;
  }

  static StakePoolParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StakePool {
    const proto = $.parseStructProto(data, typeTag, repo, StakePool);
    return new StakePool(proto, typeTag);
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
      StakePool,
      typeParams
    );
    return result as unknown as StakePool;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      StakePool,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as StakePool;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StakePool", []);
  }
  async loadFullState(app: $.AppType) {
    await this.active.loadFullState(app);
    await this.inactive.loadFullState(app);
    await this.pending_active.loadFullState(app);
    await this.pending_inactive.loadFullState(app);
    await this.initialize_validator_events.loadFullState(app);
    await this.set_operator_events.loadFullState(app);
    await this.add_stake_events.loadFullState(app);
    await this.reactivate_stake_events.loadFullState(app);
    await this.rotate_consensus_key_events.loadFullState(app);
    await this.update_network_and_fullnode_addresses_events.loadFullState(app);
    await this.increase_lockup_events.loadFullState(app);
    await this.join_validator_set_events.loadFullState(app);
    await this.distribute_rewards_events.loadFullState(app);
    await this.unlock_stake_events.loadFullState(app);
    await this.withdraw_stake_events.loadFullState(app);
    await this.leave_validator_set_events.loadFullState(app);
    this.__app = app;
  }
}

export class UnlockStakeEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UnlockStakeEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount_unlocked", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  amount_unlocked: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.amount_unlocked = proto["amount_unlocked"] as U64;
  }

  static UnlockStakeEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UnlockStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UnlockStakeEvent);
    return new UnlockStakeEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UnlockStakeEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UpdateNetworkAndFullnodeAddressesEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UpdateNetworkAndFullnodeAddressesEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "new_network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
    {
      name: "old_fullnode_addresses",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
    {
      name: "new_fullnode_addresses",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
  ];

  pool_address: HexString;
  old_network_addresses: U8[];
  new_network_addresses: U8[];
  old_fullnode_addresses: U8[];
  new_fullnode_addresses: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.old_network_addresses = proto["old_network_addresses"] as U8[];
    this.new_network_addresses = proto["new_network_addresses"] as U8[];
    this.old_fullnode_addresses = proto["old_fullnode_addresses"] as U8[];
    this.new_fullnode_addresses = proto["new_fullnode_addresses"] as U8[];
  }

  static UpdateNetworkAndFullnodeAddressesEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UpdateNetworkAndFullnodeAddressesEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      UpdateNetworkAndFullnodeAddressesEvent
    );
    return new UpdateNetworkAndFullnodeAddressesEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "UpdateNetworkAndFullnodeAddressesEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ValidatorConfig {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatorConfig";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "fullnode_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "validator_index", typeTag: AtomicTypeTag.U64 },
  ];

  consensus_pubkey: U8[];
  network_addresses: U8[];
  fullnode_addresses: U8[];
  validator_index: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.consensus_pubkey = proto["consensus_pubkey"] as U8[];
    this.network_addresses = proto["network_addresses"] as U8[];
    this.fullnode_addresses = proto["fullnode_addresses"] as U8[];
    this.validator_index = proto["validator_index"] as U64;
  }

  static ValidatorConfigParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatorConfig {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorConfig);
    return new ValidatorConfig(proto, typeTag);
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
      ValidatorConfig,
      typeParams
    );
    return result as unknown as ValidatorConfig;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      ValidatorConfig,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as ValidatorConfig;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ValidatorConfig", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ValidatorInfo {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatorInfo";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "addr", typeTag: AtomicTypeTag.Address },
    { name: "voting_power", typeTag: AtomicTypeTag.U64 },
    {
      name: "config",
      typeTag: new StructTag(
        new HexString("0x1"),
        "stake",
        "ValidatorConfig",
        []
      ),
    },
  ];

  addr: HexString;
  voting_power: U64;
  config: ValidatorConfig;

  constructor(proto: any, public typeTag: TypeTag) {
    this.addr = proto["addr"] as HexString;
    this.voting_power = proto["voting_power"] as U64;
    this.config = proto["config"] as ValidatorConfig;
  }

  static ValidatorInfoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatorInfo {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorInfo);
    return new ValidatorInfo(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ValidatorInfo", []);
  }
  async loadFullState(app: $.AppType) {
    await this.config.loadFullState(app);
    this.__app = app;
  }
}

export class ValidatorPerformance {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatorPerformance";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "validators",
      typeTag: new VectorTag(
        new StructTag(
          new HexString("0x1"),
          "stake",
          "IndividualValidatorPerformance",
          []
        )
      ),
    },
  ];

  validators: IndividualValidatorPerformance[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.validators = proto["validators"] as IndividualValidatorPerformance[];
  }

  static ValidatorPerformanceParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatorPerformance {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorPerformance);
    return new ValidatorPerformance(proto, typeTag);
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
      ValidatorPerformance,
      typeParams
    );
    return result as unknown as ValidatorPerformance;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      ValidatorPerformance,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as ValidatorPerformance;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ValidatorPerformance", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ValidatorSet {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatorSet";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "consensus_scheme", typeTag: AtomicTypeTag.U8 },
    {
      name: "active_validators",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])
      ),
    },
    {
      name: "pending_inactive",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])
      ),
    },
    {
      name: "pending_active",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "stake", "ValidatorInfo", [])
      ),
    },
    { name: "total_voting_power", typeTag: AtomicTypeTag.U128 },
    { name: "total_joining_power", typeTag: AtomicTypeTag.U128 },
  ];

  consensus_scheme: U8;
  active_validators: ValidatorInfo[];
  pending_inactive: ValidatorInfo[];
  pending_active: ValidatorInfo[];
  total_voting_power: U128;
  total_joining_power: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.consensus_scheme = proto["consensus_scheme"] as U8;
    this.active_validators = proto["active_validators"] as ValidatorInfo[];
    this.pending_inactive = proto["pending_inactive"] as ValidatorInfo[];
    this.pending_active = proto["pending_active"] as ValidatorInfo[];
    this.total_voting_power = proto["total_voting_power"] as U128;
    this.total_joining_power = proto["total_joining_power"] as U128;
  }

  static ValidatorSetParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatorSet {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatorSet);
    return new ValidatorSet(proto, typeTag);
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
      ValidatorSet,
      typeParams
    );
    return result as unknown as ValidatorSet;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      ValidatorSet,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as ValidatorSet;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ValidatorSet", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class WithdrawStakeEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "WithdrawStakeEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount_withdrawn", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  amount_withdrawn: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.amount_withdrawn = proto["amount_withdrawn"] as U64;
  }

  static WithdrawStakeEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): WithdrawStakeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, WithdrawStakeEvent);
    return new WithdrawStakeEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "WithdrawStakeEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function add_stake_(
  owner: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  let owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  add_stake_with_cap_(
    ownership_cap,
    Coin.withdraw_(owner, $.copy(amount), $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    $c
  );
  return;
}

export function buildPayload_add_stake(
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "add_stake",
    typeParamStrings,
    [amount],
    isJSON
  );
}
export function add_stake_with_cap_(
  owner_cap: OwnerCapability,
  coins: Coin.Coin,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    amount,
    maximum_stake,
    pool_address,
    stake_pool,
    validator_set,
    voting_power;
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  amount = Coin.value_(coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  if ($.copy(amount).eq(u64("0"))) {
    Coin.destroy_zero_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
    return;
  } else {
  }
  validator_set = $c.borrow_global_mut<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  temp$1 = find_validator_(
    validator_set.active_validators,
    $.copy(pool_address),
    $c
  );
  if (Option.is_some_(temp$1, $c, [AtomicTypeTag.U64])) {
    temp$3 = true;
  } else {
    temp$2 = find_validator_(
      validator_set.pending_active,
      $.copy(pool_address),
      $c
    );
    temp$3 = Option.is_some_(temp$2, $c, [AtomicTypeTag.U64]);
  }
  if (temp$3) {
    update_voting_power_increase_($.copy(amount), $c);
  } else {
  }
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  if (is_current_epoch_validator_($.copy(pool_address), $c)) {
    Coin.merge_(stake_pool.pending_active, coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  } else {
    Coin.merge_(stake_pool.active, coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  }
  temp$4 = Staking_config.get_($c);
  [, maximum_stake] = Staking_config.get_required_stake_(temp$4, $c);
  voting_power = get_next_epoch_voting_power_(stake_pool, $c);
  if (!$.copy(voting_power).le($.copy(maximum_stake))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ESTAKE_EXCEEDS_MAX), $c));
  }
  Event.emit_event_(
    stake_pool.add_stake_events,
    new AddStakeEvent(
      { pool_address: $.copy(pool_address), amount_added: $.copy(amount) },
      new SimpleStructTag(AddStakeEvent)
    ),
    $c,
    [new SimpleStructTag(AddStakeEvent)]
  );
  return;
}

export function append_(
  v1: any[],
  v2: any[],
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): void {
  while (!Vector.is_empty_(v2, $c, [$p[0]])) {
    {
      Vector.push_back_(v1, Vector.pop_back_(v2, $c, [$p[0]]), $c, [$p[0]]);
    }
  }
  return;
}

export function assert_owner_cap_exists_(
  owner: HexString,
  $c: AptosDataCache
): void {
  if (!$c.exists(new SimpleStructTag(OwnerCapability), $.copy(owner))) {
    throw $.abortCode(Error.not_found_($.copy(EOWNER_CAP_NOT_FOUND), $c));
  }
  return;
}

export function assert_stake_pool_exists_(
  pool_address: HexString,
  $c: AptosDataCache
): void {
  if (!stake_pool_exists_($.copy(pool_address), $c)) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ESTAKE_POOL_DOES_NOT_EXIST), $c)
    );
  }
  return;
}

export function calculate_rewards_amount_(
  stake_amount: U64,
  num_successful_proposals: U64,
  num_total_proposals: U64,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, rewards_denominator, rewards_numerator;
  rewards_numerator = u128($.copy(stake_amount))
    .mul(u128($.copy(rewards_rate)))
    .mul(u128($.copy(num_successful_proposals)));
  rewards_denominator = u128($.copy(rewards_rate_denominator)).mul(
    u128($.copy(num_total_proposals))
  );
  if ($.copy(rewards_denominator).gt(u128("0"))) {
    temp$1 = u64($.copy(rewards_numerator).div($.copy(rewards_denominator)));
  } else {
    temp$1 = u64("0");
  }
  return temp$1;
}

export function configure_allowed_validators_(
  aptos_framework: HexString,
  accounts: HexString[],
  $c: AptosDataCache
): void {
  let allowed, aptos_framework_address;
  aptos_framework_address = Signer.address_of_(aptos_framework, $c);
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (
    !$c.exists(
      new SimpleStructTag(AllowedValidators),
      $.copy(aptos_framework_address)
    )
  ) {
    $c.move_to(
      new SimpleStructTag(AllowedValidators),
      aptos_framework,
      new AllowedValidators(
        { accounts: $.copy(accounts) },
        new SimpleStructTag(AllowedValidators)
      )
    );
  } else {
    allowed = $c.borrow_global_mut<AllowedValidators>(
      new SimpleStructTag(AllowedValidators),
      $.copy(aptos_framework_address)
    );
    allowed.accounts = $.copy(accounts);
  }
  return;
}

export function deposit_owner_cap_(
  owner: HexString,
  owner_cap: OwnerCapability,
  $c: AptosDataCache
): void {
  if (
    $c.exists(
      new SimpleStructTag(OwnerCapability),
      Signer.address_of_(owner, $c)
    )
  ) {
    throw $.abortCode(Error.not_found_($.copy(EOWNER_CAP_ALREADY_EXISTS), $c));
  }
  $c.move_to(new SimpleStructTag(OwnerCapability), owner, owner_cap);
  return;
}

export function destroy_owner_cap_(
  owner_cap: OwnerCapability,
  $c: AptosDataCache
): void {
  owner_cap;
  return;
}

export function distribute_rewards_(
  stake: Coin.Coin,
  num_successful_proposals: U64,
  num_total_proposals: U64,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, mint_cap, rewards, rewards_amount, stake_amount;
  stake_amount = Coin.value_(stake, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  if ($.copy(stake_amount).gt(u64("0"))) {
    temp$1 = calculate_rewards_amount_(
      $.copy(stake_amount),
      $.copy(num_successful_proposals),
      $.copy(num_total_proposals),
      $.copy(rewards_rate),
      $.copy(rewards_rate_denominator),
      $c
    );
  } else {
    temp$1 = u64("0");
  }
  rewards_amount = temp$1;
  if ($.copy(rewards_amount).gt(u64("0"))) {
    mint_cap = $c.borrow_global<AptosCoinCapabilities>(
      new SimpleStructTag(AptosCoinCapabilities),
      new HexString("0x1")
    ).mint_cap;
    rewards = Coin.mint_($.copy(rewards_amount), mint_cap, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
    Coin.merge_(stake, rewards, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  } else {
  }
  return $.copy(rewards_amount);
}

export function extract_owner_cap_(
  owner: HexString,
  $c: AptosDataCache
): OwnerCapability {
  let owner_address;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  return $c.move_from<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
}

export function find_validator_(
  v: ValidatorInfo[],
  addr: HexString,
  $c: AptosDataCache
): Option.Option {
  let i, len;
  i = u64("0");
  len = Vector.length_(v, $c, [new SimpleStructTag(ValidatorInfo)]);
  while (true) {
    {
    }
    if (!$.copy(i).lt($.copy(len))) break;
    {
      if (
        $.copy(
          Vector.borrow_(v, $.copy(i), $c, [new SimpleStructTag(ValidatorInfo)])
            .addr
        ).hex() === $.copy(addr).hex()
      ) {
        return Option.some_($.copy(i), $c, [AtomicTypeTag.U64]);
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return Option.none_($c, [AtomicTypeTag.U64]);
}

export function generate_validator_info_(
  addr: HexString,
  stake_pool: StakePool,
  config: ValidatorConfig,
  $c: AptosDataCache
): ValidatorInfo {
  let voting_power;
  voting_power = get_next_epoch_voting_power_(stake_pool, $c);
  return new ValidatorInfo(
    {
      addr: $.copy(addr),
      voting_power: $.copy(voting_power),
      config: $.copy(config),
    },
    new SimpleStructTag(ValidatorInfo)
  );
}

export function get_current_epoch_proposal_counts_(
  validator_index: U64,
  $c: AptosDataCache
): [U64, U64] {
  let validator_performance, validator_performances;
  validator_performances = $c.borrow_global<ValidatorPerformance>(
    new SimpleStructTag(ValidatorPerformance),
    new HexString("0x1")
  ).validators;
  validator_performance = Vector.borrow_(
    validator_performances,
    $.copy(validator_index),
    $c,
    [new SimpleStructTag(IndividualValidatorPerformance)]
  );
  return [
    $.copy(validator_performance.successful_proposals),
    $.copy(validator_performance.failed_proposals),
  ];
}

export function get_current_epoch_voting_power_(
  pool_address: HexString,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2, active_stake, pending_inactive_stake, validator_state;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  validator_state = get_validator_state_($.copy(pool_address), $c);
  if ($.copy(validator_state).eq($.copy(VALIDATOR_STATUS_ACTIVE))) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(validator_state).eq(
      $.copy(VALIDATOR_STATUS_PENDING_INACTIVE)
    );
  }
  if (temp$1) {
    active_stake = Coin.value_(
      $c.borrow_global<StakePool>(
        new SimpleStructTag(StakePool),
        $.copy(pool_address)
      ).active,
      $c,
      [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
    );
    pending_inactive_stake = Coin.value_(
      $c.borrow_global<StakePool>(
        new SimpleStructTag(StakePool),
        $.copy(pool_address)
      ).pending_inactive,
      $c,
      [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
    );
    temp$2 = $.copy(active_stake).add($.copy(pending_inactive_stake));
  } else {
    temp$2 = u64("0");
  }
  return temp$2;
}

export function get_delegated_voter_(
  pool_address: HexString,
  $c: AptosDataCache
): HexString {
  assert_stake_pool_exists_($.copy(pool_address), $c);
  return $.copy(
    $c.borrow_global<StakePool>(
      new SimpleStructTag(StakePool),
      $.copy(pool_address)
    ).delegated_voter
  );
}

export function get_lockup_secs_(
  pool_address: HexString,
  $c: AptosDataCache
): U64 {
  assert_stake_pool_exists_($.copy(pool_address), $c);
  return $.copy(
    $c.borrow_global<StakePool>(
      new SimpleStructTag(StakePool),
      $.copy(pool_address)
    ).locked_until_secs
  );
}

export function get_next_epoch_voting_power_(
  stake_pool: StakePool,
  $c: AptosDataCache
): U64 {
  let value_active, value_pending_active, value_pending_inactive;
  value_pending_active = Coin.value_(stake_pool.pending_active, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  value_active = Coin.value_(stake_pool.active, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  value_pending_inactive = Coin.value_(stake_pool.pending_inactive, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  return $.copy(value_pending_active)
    .add($.copy(value_active))
    .add($.copy(value_pending_inactive));
}

export function get_operator_(
  pool_address: HexString,
  $c: AptosDataCache
): HexString {
  assert_stake_pool_exists_($.copy(pool_address), $c);
  return $.copy(
    $c.borrow_global<StakePool>(
      new SimpleStructTag(StakePool),
      $.copy(pool_address)
    ).operator_address
  );
}

export function get_owned_pool_address_(
  owner_cap: OwnerCapability,
  $c: AptosDataCache
): HexString {
  return $.copy(owner_cap.pool_address);
}

export function get_remaining_lockup_secs_(
  pool_address: HexString,
  $c: AptosDataCache
): U64 {
  let temp$1, lockup_time;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  lockup_time = $.copy(
    $c.borrow_global<StakePool>(
      new SimpleStructTag(StakePool),
      $.copy(pool_address)
    ).locked_until_secs
  );
  if ($.copy(lockup_time).le(Timestamp.now_seconds_($c))) {
    temp$1 = u64("0");
  } else {
    temp$1 = $.copy(lockup_time).sub(Timestamp.now_seconds_($c));
  }
  return temp$1;
}

export function get_stake_(
  pool_address: HexString,
  $c: AptosDataCache
): [U64, U64, U64, U64] {
  let stake_pool;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  return [
    Coin.value_(stake_pool.active, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    Coin.value_(stake_pool.inactive, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    Coin.value_(stake_pool.pending_active, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    Coin.value_(stake_pool.pending_inactive, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
  ];
}

export function get_validator_config_(
  pool_address: HexString,
  $c: AptosDataCache
): [U8[], U8[], U8[]] {
  let validator_config;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  validator_config = $c.borrow_global<ValidatorConfig>(
    new SimpleStructTag(ValidatorConfig),
    $.copy(pool_address)
  );
  return [
    $.copy(validator_config.consensus_pubkey),
    $.copy(validator_config.network_addresses),
    $.copy(validator_config.fullnode_addresses),
  ];
}

export function get_validator_index_(
  pool_address: HexString,
  $c: AptosDataCache
): U64 {
  assert_stake_pool_exists_($.copy(pool_address), $c);
  return $.copy(
    $c.borrow_global<ValidatorConfig>(
      new SimpleStructTag(ValidatorConfig),
      $.copy(pool_address)
    ).validator_index
  );
}

export function get_validator_state_(
  pool_address: HexString,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, validator_set;
  validator_set = $c.borrow_global<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  temp$1 = find_validator_(
    validator_set.pending_active,
    $.copy(pool_address),
    $c
  );
  if (Option.is_some_(temp$1, $c, [AtomicTypeTag.U64])) {
    temp$6 = $.copy(VALIDATOR_STATUS_PENDING_ACTIVE);
  } else {
    temp$2 = find_validator_(
      validator_set.active_validators,
      $.copy(pool_address),
      $c
    );
    if (Option.is_some_(temp$2, $c, [AtomicTypeTag.U64])) {
      temp$5 = $.copy(VALIDATOR_STATUS_ACTIVE);
    } else {
      temp$3 = find_validator_(
        validator_set.pending_inactive,
        $.copy(pool_address),
        $c
      );
      if (Option.is_some_(temp$3, $c, [AtomicTypeTag.U64])) {
        temp$4 = $.copy(VALIDATOR_STATUS_PENDING_INACTIVE);
      } else {
        temp$4 = $.copy(VALIDATOR_STATUS_INACTIVE);
      }
      temp$5 = temp$4;
    }
    temp$6 = temp$5;
  }
  return temp$6;
}

export function increase_lockup_(owner: HexString, $c: AptosDataCache): void {
  let owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  increase_lockup_with_cap_(ownership_cap, $c);
  return;
}

export function buildPayload_increase_lockup(
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "increase_lockup",
    typeParamStrings,
    [],
    isJSON
  );
}
export function increase_lockup_with_cap_(
  owner_cap: OwnerCapability,
  $c: AptosDataCache
): void {
  let config,
    new_locked_until_secs,
    old_locked_until_secs,
    pool_address,
    stake_pool;
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  config = Staking_config.get_($c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  old_locked_until_secs = $.copy(stake_pool.locked_until_secs);
  new_locked_until_secs = Timestamp.now_seconds_($c).add(
    Staking_config.get_recurring_lockup_duration_(config, $c)
  );
  if (!$.copy(old_locked_until_secs).lt($.copy(new_locked_until_secs))) {
    throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_LOCKUP), $c));
  }
  stake_pool.locked_until_secs = $.copy(new_locked_until_secs);
  Event.emit_event_(
    stake_pool.increase_lockup_events,
    new IncreaseLockupEvent(
      {
        pool_address: $.copy(pool_address),
        old_locked_until_secs: $.copy(old_locked_until_secs),
        new_locked_until_secs: $.copy(new_locked_until_secs),
      },
      new SimpleStructTag(IncreaseLockupEvent)
    ),
    $c,
    [new SimpleStructTag(IncreaseLockupEvent)]
  );
  return;
}

export function initialize_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  temp$7 = aptos_framework;
  temp$1 = u8("0");
  temp$2 = Vector.empty_($c, [new SimpleStructTag(ValidatorInfo)]);
  temp$3 = Vector.empty_($c, [new SimpleStructTag(ValidatorInfo)]);
  temp$4 = Vector.empty_($c, [new SimpleStructTag(ValidatorInfo)]);
  temp$5 = u128("0");
  temp$6 = u128("0");
  $c.move_to(
    new SimpleStructTag(ValidatorSet),
    temp$7,
    new ValidatorSet(
      {
        consensus_scheme: temp$1,
        active_validators: temp$2,
        pending_inactive: temp$4,
        pending_active: temp$3,
        total_voting_power: temp$5,
        total_joining_power: temp$6,
      },
      new SimpleStructTag(ValidatorSet)
    )
  );
  $c.move_to(
    new SimpleStructTag(ValidatorPerformance),
    aptos_framework,
    new ValidatorPerformance(
      {
        validators: Vector.empty_($c, [
          new SimpleStructTag(IndividualValidatorPerformance),
        ]),
      },
      new SimpleStructTag(ValidatorPerformance)
    )
  );
  return;
}

export function initialize_owner_(owner: HexString, $c: AptosDataCache): void {
  let temp$1,
    temp$10,
    temp$11,
    temp$12,
    temp$13,
    temp$14,
    temp$15,
    temp$16,
    temp$17,
    temp$18,
    temp$19,
    temp$2,
    temp$20,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    owner_address;
  owner_address = Signer.address_of_(owner, $c);
  if (!is_allowed_($.copy(owner_address), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EINELIGIBLE_VALIDATOR), $c));
  }
  if (stake_pool_exists_($.copy(owner_address), $c)) {
    throw $.abortCode(Error.already_exists_($.copy(EALREADY_REGISTERED), $c));
  }
  temp$20 = owner;
  temp$1 = Coin.zero_($c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  temp$2 = Coin.zero_($c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  temp$3 = Coin.zero_($c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  temp$4 = Coin.zero_($c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  temp$5 = u64("0");
  temp$6 = $.copy(owner_address);
  temp$7 = $.copy(owner_address);
  temp$8 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(RegisterValidatorCandidateEvent),
  ]);
  temp$9 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(SetOperatorEvent),
  ]);
  temp$10 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(AddStakeEvent),
  ]);
  temp$11 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(ReactivateStakeEvent),
  ]);
  temp$12 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(RotateConsensusKeyEvent),
  ]);
  temp$13 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(UpdateNetworkAndFullnodeAddressesEvent),
  ]);
  temp$14 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(IncreaseLockupEvent),
  ]);
  temp$15 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(JoinValidatorSetEvent),
  ]);
  temp$16 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(DistributeRewardsEvent),
  ]);
  temp$17 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(UnlockStakeEvent),
  ]);
  temp$18 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(WithdrawStakeEvent),
  ]);
  temp$19 = Account.new_event_handle_(owner, $c, [
    new SimpleStructTag(LeaveValidatorSetEvent),
  ]);
  $c.move_to(
    new SimpleStructTag(StakePool),
    temp$20,
    new StakePool(
      {
        active: temp$1,
        inactive: temp$4,
        pending_active: temp$2,
        pending_inactive: temp$3,
        locked_until_secs: temp$5,
        operator_address: temp$6,
        delegated_voter: temp$7,
        initialize_validator_events: temp$8,
        set_operator_events: temp$9,
        add_stake_events: temp$10,
        reactivate_stake_events: temp$11,
        rotate_consensus_key_events: temp$12,
        update_network_and_fullnode_addresses_events: temp$13,
        increase_lockup_events: temp$14,
        join_validator_set_events: temp$15,
        distribute_rewards_events: temp$16,
        unlock_stake_events: temp$17,
        withdraw_stake_events: temp$18,
        leave_validator_set_events: temp$19,
      },
      new SimpleStructTag(StakePool)
    )
  );
  $c.move_to(
    new SimpleStructTag(OwnerCapability),
    owner,
    new OwnerCapability(
      { pool_address: $.copy(owner_address) },
      new SimpleStructTag(OwnerCapability)
    )
  );
  return;
}

export function initialize_stake_owner_(
  owner: HexString,
  initial_stake_amount: U64,
  operator: HexString,
  voter: HexString,
  $c: AptosDataCache
): void {
  let account_address;
  initialize_owner_(owner, $c);
  $c.move_to(
    new SimpleStructTag(ValidatorConfig),
    owner,
    new ValidatorConfig(
      {
        consensus_pubkey: Vector.empty_($c, [AtomicTypeTag.U8]),
        network_addresses: Vector.empty_($c, [AtomicTypeTag.U8]),
        fullnode_addresses: Vector.empty_($c, [AtomicTypeTag.U8]),
        validator_index: u64("0"),
      },
      new SimpleStructTag(ValidatorConfig)
    )
  );
  if ($.copy(initial_stake_amount).gt(u64("0"))) {
    add_stake_(owner, $.copy(initial_stake_amount), $c);
  } else {
  }
  account_address = Signer.address_of_(owner, $c);
  if ($.copy(account_address).hex() !== $.copy(operator).hex()) {
    set_operator_(owner, $.copy(operator), $c);
  } else {
  }
  if ($.copy(account_address).hex() !== $.copy(voter).hex()) {
    set_delegated_voter_(owner, $.copy(voter), $c);
  } else {
  }
  return;
}

export function buildPayload_initialize_stake_owner(
  initial_stake_amount: U64,
  operator: HexString,
  voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "initialize_stake_owner",
    typeParamStrings,
    [initial_stake_amount, operator, voter],
    isJSON
  );
}
export function initialize_validator_(
  account: HexString,
  consensus_pubkey: U8[],
  proof_of_possession: U8[],
  network_addresses: U8[],
  fullnode_addresses: U8[],
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, pubkey_from_pop;
  temp$2 = $.copy(consensus_pubkey);
  temp$1 = Bls12381.proof_of_possession_from_bytes_(
    $.copy(proof_of_possession),
    $c
  );
  temp$3 = Bls12381.public_key_from_bytes_with_pop_(temp$2, temp$1, $c);
  pubkey_from_pop = temp$3;
  if (
    !Option.is_some_(pubkey_from_pop, $c, [
      new StructTag(new HexString("0x1"), "bls12381", "PublicKeyWithPoP", []),
    ])
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_PUBLIC_KEY), $c));
  }
  initialize_owner_(account, $c);
  $c.move_to(
    new SimpleStructTag(ValidatorConfig),
    account,
    new ValidatorConfig(
      {
        consensus_pubkey: $.copy(consensus_pubkey),
        network_addresses: $.copy(network_addresses),
        fullnode_addresses: $.copy(fullnode_addresses),
        validator_index: u64("0"),
      },
      new SimpleStructTag(ValidatorConfig)
    )
  );
  return;
}

export function buildPayload_initialize_validator(
  consensus_pubkey: U8[],
  proof_of_possession: U8[],
  network_addresses: U8[],
  fullnode_addresses: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "initialize_validator",
    typeParamStrings,
    [
      consensus_pubkey,
      proof_of_possession,
      network_addresses,
      fullnode_addresses,
    ],
    isJSON
  );
}
export function is_allowed_(account: HexString, $c: AptosDataCache): boolean {
  let temp$1, allowed;
  if (
    !$c.exists(new SimpleStructTag(AllowedValidators), new HexString("0x1"))
  ) {
    temp$1 = true;
  } else {
    allowed = $c.borrow_global<AllowedValidators>(
      new SimpleStructTag(AllowedValidators),
      new HexString("0x1")
    );
    temp$1 = Vector.contains_(allowed.accounts, account, $c, [
      AtomicTypeTag.Address,
    ]);
  }
  return temp$1;
}

export function is_current_epoch_validator_(
  pool_address: HexString,
  $c: AptosDataCache
): boolean {
  let temp$1, validator_state;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  validator_state = get_validator_state_($.copy(pool_address), $c);
  if ($.copy(validator_state).eq($.copy(VALIDATOR_STATUS_ACTIVE))) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(validator_state).eq(
      $.copy(VALIDATOR_STATUS_PENDING_INACTIVE)
    );
  }
  return temp$1;
}

export function join_validator_set_(
  operator: HexString,
  pool_address: HexString,
  $c: AptosDataCache
): void {
  let temp$1;
  temp$1 = Staking_config.get_($c);
  if (!Staking_config.get_allow_validator_set_change_(temp$1, $c)) {
    throw $.abortCode(
      Error.invalid_argument_(
        $.copy(ENO_POST_GENESIS_VALIDATOR_SET_CHANGE_ALLOWED),
        $c
      )
    );
  }
  join_validator_set_internal_(operator, $.copy(pool_address), $c);
  return;
}

export function buildPayload_join_validator_set(
  pool_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "join_validator_set",
    typeParamStrings,
    [pool_address],
    isJSON
  );
}
export function join_validator_set_internal_(
  operator: HexString,
  pool_address: HexString,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    config,
    maximum_stake,
    minimum_stake,
    stake_pool,
    validator_config,
    validator_set,
    validator_set_size,
    voting_power;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  if (
    !(
      Signer.address_of_(operator, $c).hex() ===
      $.copy(stake_pool.operator_address).hex()
    )
  ) {
    throw $.abortCode(Error.unauthenticated_($.copy(ENOT_OPERATOR), $c));
  }
  if (
    !get_validator_state_($.copy(pool_address), $c).eq(
      $.copy(VALIDATOR_STATUS_INACTIVE)
    )
  ) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EALREADY_ACTIVE_VALIDATOR), $c)
    );
  }
  config = Staking_config.get_($c);
  [minimum_stake, maximum_stake] = Staking_config.get_required_stake_(
    config,
    $c
  );
  voting_power = get_next_epoch_voting_power_(stake_pool, $c);
  if (!$.copy(voting_power).ge($.copy(minimum_stake))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ESTAKE_TOO_LOW), $c));
  }
  if (!$.copy(voting_power).le($.copy(maximum_stake))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ESTAKE_TOO_HIGH), $c));
  }
  update_voting_power_increase_($.copy(voting_power), $c);
  validator_config = $c.borrow_global_mut<ValidatorConfig>(
    new SimpleStructTag(ValidatorConfig),
    $.copy(pool_address)
  );
  if (
    Vector.is_empty_(validator_config.consensus_pubkey, $c, [AtomicTypeTag.U8])
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_PUBLIC_KEY), $c));
  }
  validator_set = $c.borrow_global_mut<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  temp$4 = validator_set.pending_active;
  [temp$1, temp$2, temp$3] = [
    $.copy(pool_address),
    stake_pool,
    $.copy(validator_config),
  ];
  Vector.push_back_(
    temp$4,
    generate_validator_info_(temp$1, temp$2, temp$3, $c),
    $c,
    [new SimpleStructTag(ValidatorInfo)]
  );
  validator_set_size = Vector.length_(validator_set.active_validators, $c, [
    new SimpleStructTag(ValidatorInfo),
  ]).add(
    Vector.length_(validator_set.pending_active, $c, [
      new SimpleStructTag(ValidatorInfo),
    ])
  );
  if (!$.copy(validator_set_size).le($.copy(MAX_VALIDATOR_SET_SIZE))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EVALIDATOR_SET_TOO_LARGE), $c)
    );
  }
  Event.emit_event_(
    stake_pool.join_validator_set_events,
    new JoinValidatorSetEvent(
      { pool_address: $.copy(pool_address) },
      new SimpleStructTag(JoinValidatorSetEvent)
    ),
    $c,
    [new SimpleStructTag(JoinValidatorSetEvent)]
  );
  return;
}

export function leave_validator_set_(
  operator: HexString,
  pool_address: HexString,
  $c: AptosDataCache
): void {
  let config,
    maybe_active_index,
    maybe_pending_active_index,
    stake_pool,
    validator_info,
    validator_set,
    validator_stake;
  config = Staking_config.get_($c);
  if (!Staking_config.get_allow_validator_set_change_(config, $c)) {
    throw $.abortCode(
      Error.invalid_argument_(
        $.copy(ENO_POST_GENESIS_VALIDATOR_SET_CHANGE_ALLOWED),
        $c
      )
    );
  }
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  if (
    !(
      Signer.address_of_(operator, $c).hex() ===
      $.copy(stake_pool.operator_address).hex()
    )
  ) {
    throw $.abortCode(Error.unauthenticated_($.copy(ENOT_OPERATOR), $c));
  }
  validator_set = $c.borrow_global_mut<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  maybe_pending_active_index = find_validator_(
    validator_set.pending_active,
    $.copy(pool_address),
    $c
  );
  if (Option.is_some_(maybe_pending_active_index, $c, [AtomicTypeTag.U64])) {
    Vector.swap_remove_(
      validator_set.pending_active,
      Option.extract_(maybe_pending_active_index, $c, [AtomicTypeTag.U64]),
      $c,
      [new SimpleStructTag(ValidatorInfo)]
    );
    validator_stake = u128(get_next_epoch_voting_power_(stake_pool, $c));
    if ($.copy(validator_set.total_joining_power).gt($.copy(validator_stake))) {
      validator_set.total_joining_power = $.copy(
        validator_set.total_joining_power
      ).sub($.copy(validator_stake));
    } else {
      validator_set.total_joining_power = u128("0");
    }
  } else {
    maybe_active_index = find_validator_(
      validator_set.active_validators,
      $.copy(pool_address),
      $c
    );
    if (!Option.is_some_(maybe_active_index, $c, [AtomicTypeTag.U64])) {
      throw $.abortCode(Error.invalid_state_($.copy(ENOT_VALIDATOR), $c));
    }
    validator_info = Vector.swap_remove_(
      validator_set.active_validators,
      Option.extract_(maybe_active_index, $c, [AtomicTypeTag.U64]),
      $c,
      [new SimpleStructTag(ValidatorInfo)]
    );
    if (
      !Vector.length_(validator_set.active_validators, $c, [
        new SimpleStructTag(ValidatorInfo),
      ]).gt(u64("0"))
    ) {
      throw $.abortCode(Error.invalid_state_($.copy(ELAST_VALIDATOR), $c));
    }
    Vector.push_back_(
      validator_set.pending_inactive,
      $.copy(validator_info),
      $c,
      [new SimpleStructTag(ValidatorInfo)]
    );
    Event.emit_event_(
      stake_pool.leave_validator_set_events,
      new LeaveValidatorSetEvent(
        { pool_address: $.copy(pool_address) },
        new SimpleStructTag(LeaveValidatorSetEvent)
      ),
      $c,
      [new SimpleStructTag(LeaveValidatorSetEvent)]
    );
  }
  return;
}

export function buildPayload_leave_validator_set(
  pool_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "leave_validator_set",
    typeParamStrings,
    [pool_address],
    isJSON
  );
}
export function on_new_epoch_($c: AptosDataCache): void {
  let temp$1,
    temp$11,
    temp$12,
    temp$13,
    temp$2,
    temp$3,
    temp$7,
    temp$8,
    temp$9,
    config,
    i,
    i__10,
    i__4,
    len,
    len__5,
    minimum_stake,
    new_validator_info,
    next_epoch_validators,
    old_validator_info,
    pool_address,
    recurring_lockup_duration_secs,
    stake_pool,
    stake_pool__16,
    total_voting_power,
    validator,
    validator__6,
    validator_config,
    validator_config__15,
    validator_index,
    validator_info,
    validator_perf,
    validator_set,
    vlen,
    vlen__14;
  validator_set = $c.borrow_global_mut<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  config = Staking_config.get_($c);
  validator_perf = $c.borrow_global_mut<ValidatorPerformance>(
    new SimpleStructTag(ValidatorPerformance),
    new HexString("0x1")
  );
  i = u64("0");
  len = Vector.length_(validator_set.active_validators, $c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  while ($.copy(i).lt($.copy(len))) {
    {
      validator = Vector.borrow_(
        validator_set.active_validators,
        $.copy(i),
        $c,
        [new SimpleStructTag(ValidatorInfo)]
      );
      [temp$1, temp$2, temp$3] = [
        validator_perf,
        $.copy(validator.addr),
        config,
      ];
      update_stake_pool_(temp$1, temp$2, temp$3, $c);
      i = $.copy(i).add(u64("1"));
    }
  }
  i__4 = u64("0");
  len__5 = Vector.length_(validator_set.pending_inactive, $c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  while ($.copy(i__4).lt($.copy(len__5))) {
    {
      validator__6 = Vector.borrow_(
        validator_set.pending_inactive,
        $.copy(i__4),
        $c,
        [new SimpleStructTag(ValidatorInfo)]
      );
      [temp$7, temp$8, temp$9] = [
        validator_perf,
        $.copy(validator__6.addr),
        config,
      ];
      update_stake_pool_(temp$7, temp$8, temp$9, $c);
      i__4 = $.copy(i__4).add(u64("1"));
    }
  }
  append_(validator_set.active_validators, validator_set.pending_active, $c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  validator_set.pending_inactive = Vector.empty_($c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  next_epoch_validators = Vector.empty_($c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  [minimum_stake] = Staking_config.get_required_stake_(config, $c);
  vlen = Vector.length_(validator_set.active_validators, $c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  total_voting_power = u128("0");
  i__10 = u64("0");
  while (true) {
    {
    }
    if (!$.copy(i__10).lt($.copy(vlen))) break;
    {
      old_validator_info = Vector.borrow_mut_(
        validator_set.active_validators,
        $.copy(i__10),
        $c,
        [new SimpleStructTag(ValidatorInfo)]
      );
      pool_address = $.copy(old_validator_info.addr);
      validator_config = $c.borrow_global_mut<ValidatorConfig>(
        new SimpleStructTag(ValidatorConfig),
        $.copy(pool_address)
      );
      stake_pool = $c.borrow_global_mut<StakePool>(
        new SimpleStructTag(StakePool),
        $.copy(pool_address)
      );
      [temp$11, temp$12, temp$13] = [
        $.copy(pool_address),
        stake_pool,
        $.copy(validator_config),
      ];
      new_validator_info = generate_validator_info_(
        temp$11,
        temp$12,
        temp$13,
        $c
      );
      if ($.copy(new_validator_info.voting_power).ge($.copy(minimum_stake))) {
        total_voting_power = $.copy(total_voting_power).add(
          u128($.copy(new_validator_info.voting_power))
        );
        Vector.push_back_(
          next_epoch_validators,
          $.copy(new_validator_info),
          $c,
          [new SimpleStructTag(ValidatorInfo)]
        );
      } else {
      }
      i__10 = $.copy(i__10).add(u64("1"));
    }
  }
  validator_set.active_validators = $.copy(next_epoch_validators);
  validator_set.total_voting_power = $.copy(total_voting_power);
  validator_set.total_joining_power = u128("0");
  validator_perf.validators = Vector.empty_($c, [
    new SimpleStructTag(IndividualValidatorPerformance),
  ]);
  recurring_lockup_duration_secs =
    Staking_config.get_recurring_lockup_duration_(config, $c);
  vlen__14 = Vector.length_(validator_set.active_validators, $c, [
    new SimpleStructTag(ValidatorInfo),
  ]);
  validator_index = u64("0");
  while (true) {
    {
    }
    if (!$.copy(validator_index).lt($.copy(vlen__14))) break;
    {
      validator_info = Vector.borrow_mut_(
        validator_set.active_validators,
        $.copy(validator_index),
        $c,
        [new SimpleStructTag(ValidatorInfo)]
      );
      validator_info.config.validator_index = $.copy(validator_index);
      validator_config__15 = $c.borrow_global_mut<ValidatorConfig>(
        new SimpleStructTag(ValidatorConfig),
        $.copy(validator_info.addr)
      );
      validator_config__15.validator_index = $.copy(validator_index);
      Vector.push_back_(
        validator_perf.validators,
        new IndividualValidatorPerformance(
          { successful_proposals: u64("0"), failed_proposals: u64("0") },
          new SimpleStructTag(IndividualValidatorPerformance)
        ),
        $c,
        [new SimpleStructTag(IndividualValidatorPerformance)]
      );
      stake_pool__16 = $c.borrow_global_mut<StakePool>(
        new SimpleStructTag(StakePool),
        $.copy(validator_info.addr)
      );
      if (
        $.copy(stake_pool__16.locked_until_secs).le(Timestamp.now_seconds_($c))
      ) {
        stake_pool__16.locked_until_secs = Timestamp.now_seconds_($c).add(
          $.copy(recurring_lockup_duration_secs)
        );
      } else {
      }
      validator_index = $.copy(validator_index).add(u64("1"));
    }
  }
  return;
}

export function reactivate_stake_(
  owner: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  let owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  reactivate_stake_with_cap_(ownership_cap, $.copy(amount), $c);
  return;
}

export function buildPayload_reactivate_stake(
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "reactivate_stake",
    typeParamStrings,
    [amount],
    isJSON
  );
}
export function reactivate_stake_with_cap_(
  owner_cap: OwnerCapability,
  amount: U64,
  $c: AptosDataCache
): void {
  let pool_address, reactivated_coins, stake_pool, total_pending_inactive;
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  total_pending_inactive = Coin.value_(stake_pool.pending_inactive, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  amount = Math64.min_($.copy(amount), $.copy(total_pending_inactive), $c);
  reactivated_coins = Coin.extract_(
    stake_pool.pending_inactive,
    $.copy(amount),
    $c,
    [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
  );
  Coin.merge_(stake_pool.active, reactivated_coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  Event.emit_event_(
    stake_pool.reactivate_stake_events,
    new ReactivateStakeEvent(
      { pool_address: $.copy(pool_address), amount: $.copy(amount) },
      new SimpleStructTag(ReactivateStakeEvent)
    ),
    $c,
    [new SimpleStructTag(ReactivateStakeEvent)]
  );
  return;
}

export function remove_validators_(
  aptos_framework: HexString,
  validators: HexString[],
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    active_validators,
    i,
    len,
    pending_inactive,
    validator,
    validator_index,
    validator_info,
    validator_set;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  validator_set = $c.borrow_global_mut<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  active_validators = validator_set.active_validators;
  pending_inactive = validator_set.pending_inactive;
  len = Vector.length_(validators, $c, [AtomicTypeTag.Address]);
  i = u64("0");
  while (true) {
    {
    }
    if (!$.copy(i).lt($.copy(len))) break;
    {
      validator = $.copy(
        Vector.borrow_(validators, $.copy(i), $c, [AtomicTypeTag.Address])
      );
      [temp$1, temp$2] = [active_validators, $.copy(validator)];
      validator_index = find_validator_(temp$1, temp$2, $c);
      if (Option.is_some_(validator_index, $c, [AtomicTypeTag.U64])) {
        validator_info = Vector.swap_remove_(
          active_validators,
          $.copy(Option.borrow_(validator_index, $c, [AtomicTypeTag.U64])),
          $c,
          [new SimpleStructTag(ValidatorInfo)]
        );
        Vector.push_back_(pending_inactive, $.copy(validator_info), $c, [
          new SimpleStructTag(ValidatorInfo),
        ]);
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function rotate_consensus_key_(
  operator: HexString,
  pool_address: HexString,
  new_consensus_pubkey: U8[],
  proof_of_possession: U8[],
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    old_consensus_pubkey,
    pubkey_from_pop,
    stake_pool,
    validator_info;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  if (
    !(
      Signer.address_of_(operator, $c).hex() ===
      $.copy(stake_pool.operator_address).hex()
    )
  ) {
    throw $.abortCode(Error.unauthenticated_($.copy(ENOT_OPERATOR), $c));
  }
  if (!$c.exists(new SimpleStructTag(ValidatorConfig), $.copy(pool_address))) {
    throw $.abortCode(Error.not_found_($.copy(EVALIDATOR_CONFIG), $c));
  }
  validator_info = $c.borrow_global_mut<ValidatorConfig>(
    new SimpleStructTag(ValidatorConfig),
    $.copy(pool_address)
  );
  old_consensus_pubkey = $.copy(validator_info.consensus_pubkey);
  temp$2 = $.copy(new_consensus_pubkey);
  temp$1 = Bls12381.proof_of_possession_from_bytes_(
    $.copy(proof_of_possession),
    $c
  );
  temp$3 = Bls12381.public_key_from_bytes_with_pop_(temp$2, temp$1, $c);
  pubkey_from_pop = temp$3;
  if (
    !Option.is_some_(pubkey_from_pop, $c, [
      new StructTag(new HexString("0x1"), "bls12381", "PublicKeyWithPoP", []),
    ])
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_PUBLIC_KEY), $c));
  }
  validator_info.consensus_pubkey = $.copy(new_consensus_pubkey);
  Event.emit_event_(
    stake_pool.rotate_consensus_key_events,
    new RotateConsensusKeyEvent(
      {
        pool_address: $.copy(pool_address),
        old_consensus_pubkey: $.copy(old_consensus_pubkey),
        new_consensus_pubkey: $.copy(new_consensus_pubkey),
      },
      new SimpleStructTag(RotateConsensusKeyEvent)
    ),
    $c,
    [new SimpleStructTag(RotateConsensusKeyEvent)]
  );
  return;
}

export function buildPayload_rotate_consensus_key(
  pool_address: HexString,
  new_consensus_pubkey: U8[],
  proof_of_possession: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "rotate_consensus_key",
    typeParamStrings,
    [pool_address, new_consensus_pubkey, proof_of_possession],
    isJSON
  );
}
export function set_delegated_voter_(
  owner: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  let owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  set_delegated_voter_with_cap_(ownership_cap, $.copy(new_voter), $c);
  return;
}

export function buildPayload_set_delegated_voter(
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "set_delegated_voter",
    typeParamStrings,
    [new_voter],
    isJSON
  );
}
export function set_delegated_voter_with_cap_(
  owner_cap: OwnerCapability,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  let pool_address, stake_pool;
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  stake_pool.delegated_voter = $.copy(new_voter);
  return;
}

export function set_operator_(
  owner: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  set_operator_with_cap_(ownership_cap, $.copy(new_operator), $c);
  return;
}

export function buildPayload_set_operator(
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "set_operator",
    typeParamStrings,
    [new_operator],
    isJSON
  );
}
export function set_operator_with_cap_(
  owner_cap: OwnerCapability,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let old_operator, pool_address, stake_pool;
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  old_operator = $.copy(stake_pool.operator_address);
  stake_pool.operator_address = $.copy(new_operator);
  Event.emit_event_(
    stake_pool.set_operator_events,
    new SetOperatorEvent(
      {
        pool_address: $.copy(pool_address),
        old_operator: $.copy(old_operator),
        new_operator: $.copy(new_operator),
      },
      new SimpleStructTag(SetOperatorEvent)
    ),
    $c,
    [new SimpleStructTag(SetOperatorEvent)]
  );
  return;
}

export function stake_pool_exists_(
  addr: HexString,
  $c: AptosDataCache
): boolean {
  return $c.exists(new SimpleStructTag(StakePool), $.copy(addr));
}

export function store_aptos_coin_mint_cap_(
  aptos_framework: HexString,
  mint_cap: Coin.MintCapability,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  return $c.move_to(
    new SimpleStructTag(AptosCoinCapabilities),
    aptos_framework,
    new AptosCoinCapabilities(
      { mint_cap: $.copy(mint_cap) },
      new SimpleStructTag(AptosCoinCapabilities)
    )
  );
}

export function unlock_(
  owner: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  let owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  unlock_with_cap_($.copy(amount), ownership_cap, $c);
  return;
}

export function buildPayload_unlock(
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "unlock",
    typeParamStrings,
    [amount],
    isJSON
  );
}
export function unlock_with_cap_(
  amount: U64,
  owner_cap: OwnerCapability,
  $c: AptosDataCache
): void {
  let amount__1, pool_address, stake_pool, unlocked_stake;
  if ($.copy(amount).eq(u64("0"))) {
    return;
  } else {
  }
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  amount__1 = Math64.min_(
    $.copy(amount),
    Coin.value_(stake_pool.active, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    $c
  );
  unlocked_stake = Coin.extract_(stake_pool.active, $.copy(amount__1), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  Coin.merge_(stake_pool.pending_inactive, unlocked_stake, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  Event.emit_event_(
    stake_pool.unlock_stake_events,
    new UnlockStakeEvent(
      {
        pool_address: $.copy(pool_address),
        amount_unlocked: $.copy(amount__1),
      },
      new SimpleStructTag(UnlockStakeEvent)
    ),
    $c,
    [new SimpleStructTag(UnlockStakeEvent)]
  );
  return;
}

export function update_network_and_fullnode_addresses_(
  operator: HexString,
  pool_address: HexString,
  new_network_addresses: U8[],
  new_fullnode_addresses: U8[],
  $c: AptosDataCache
): void {
  let old_fullnode_addresses, old_network_addresses, stake_pool, validator_info;
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  if (
    !(
      Signer.address_of_(operator, $c).hex() ===
      $.copy(stake_pool.operator_address).hex()
    )
  ) {
    throw $.abortCode(Error.unauthenticated_($.copy(ENOT_OPERATOR), $c));
  }
  if (!$c.exists(new SimpleStructTag(ValidatorConfig), $.copy(pool_address))) {
    throw $.abortCode(Error.not_found_($.copy(EVALIDATOR_CONFIG), $c));
  }
  validator_info = $c.borrow_global_mut<ValidatorConfig>(
    new SimpleStructTag(ValidatorConfig),
    $.copy(pool_address)
  );
  old_network_addresses = $.copy(validator_info.network_addresses);
  validator_info.network_addresses = $.copy(new_network_addresses);
  old_fullnode_addresses = $.copy(validator_info.fullnode_addresses);
  validator_info.fullnode_addresses = $.copy(new_fullnode_addresses);
  Event.emit_event_(
    stake_pool.update_network_and_fullnode_addresses_events,
    new UpdateNetworkAndFullnodeAddressesEvent(
      {
        pool_address: $.copy(pool_address),
        old_network_addresses: $.copy(old_network_addresses),
        new_network_addresses: $.copy(new_network_addresses),
        old_fullnode_addresses: $.copy(old_fullnode_addresses),
        new_fullnode_addresses: $.copy(new_fullnode_addresses),
      },
      new SimpleStructTag(UpdateNetworkAndFullnodeAddressesEvent)
    ),
    $c,
    [new SimpleStructTag(UpdateNetworkAndFullnodeAddressesEvent)]
  );
  return;
}

export function buildPayload_update_network_and_fullnode_addresses(
  pool_address: HexString,
  new_network_addresses: U8[],
  new_fullnode_addresses: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "update_network_and_fullnode_addresses",
    typeParamStrings,
    [pool_address, new_network_addresses, new_fullnode_addresses],
    isJSON
  );
}
export function update_performance_statistics_(
  proposer_index: Option.Option,
  failed_proposer_indices: U64[],
  $c: AptosDataCache
): void {
  let cur_proposer_index,
    f,
    f_len,
    validator,
    validator__1,
    validator_index,
    validator_len,
    validator_perf;
  validator_perf = $c.borrow_global_mut<ValidatorPerformance>(
    new SimpleStructTag(ValidatorPerformance),
    new HexString("0x1")
  );
  validator_len = Vector.length_(validator_perf.validators, $c, [
    new SimpleStructTag(IndividualValidatorPerformance),
  ]);
  if (Option.is_some_(proposer_index, $c, [AtomicTypeTag.U64])) {
    cur_proposer_index = Option.extract_(proposer_index, $c, [
      AtomicTypeTag.U64,
    ]);
    if ($.copy(cur_proposer_index).lt($.copy(validator_len))) {
      validator = Vector.borrow_mut_(
        validator_perf.validators,
        $.copy(cur_proposer_index),
        $c,
        [new SimpleStructTag(IndividualValidatorPerformance)]
      );
      validator.successful_proposals = $.copy(
        validator.successful_proposals
      ).add(u64("1"));
    } else {
    }
  } else {
  }
  f = u64("0");
  f_len = Vector.length_(failed_proposer_indices, $c, [AtomicTypeTag.U64]);
  while (true) {
    {
    }
    if (!$.copy(f).lt($.copy(f_len))) break;
    {
      validator_index = $.copy(
        Vector.borrow_(failed_proposer_indices, $.copy(f), $c, [
          AtomicTypeTag.U64,
        ])
      );
      if ($.copy(validator_index).lt($.copy(validator_len))) {
        validator__1 = Vector.borrow_mut_(
          validator_perf.validators,
          $.copy(validator_index),
          $c,
          [new SimpleStructTag(IndividualValidatorPerformance)]
        );
        validator__1.failed_proposals = $.copy(
          validator__1.failed_proposals
        ).add(u64("1"));
      } else {
      }
      f = $.copy(f).add(u64("1"));
    }
  }
  return;
}

export function update_stake_pool_(
  validator_perf: ValidatorPerformance,
  pool_address: HexString,
  staking_config: Staking_config.StakingConfig,
  $c: AptosDataCache
): void {
  let cur_validator_perf,
    current_lockup_expiration,
    num_successful_proposals,
    num_total_proposals,
    rewards_active,
    rewards_amount,
    rewards_pending_inactive,
    rewards_rate,
    rewards_rate_denominator,
    stake_pool,
    validator_config;
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  validator_config = $c.borrow_global<ValidatorConfig>(
    new SimpleStructTag(ValidatorConfig),
    $.copy(pool_address)
  );
  cur_validator_perf = Vector.borrow_(
    validator_perf.validators,
    $.copy(validator_config.validator_index),
    $c,
    [new SimpleStructTag(IndividualValidatorPerformance)]
  );
  num_successful_proposals = $.copy(cur_validator_perf.successful_proposals);
  num_total_proposals = $.copy(cur_validator_perf.successful_proposals).add(
    $.copy(cur_validator_perf.failed_proposals)
  );
  [rewards_rate, rewards_rate_denominator] = Staking_config.get_reward_rate_(
    staking_config,
    $c
  );
  rewards_active = distribute_rewards_(
    stake_pool.active,
    $.copy(num_successful_proposals),
    $.copy(num_total_proposals),
    $.copy(rewards_rate),
    $.copy(rewards_rate_denominator),
    $c
  );
  rewards_pending_inactive = distribute_rewards_(
    stake_pool.pending_inactive,
    $.copy(num_successful_proposals),
    $.copy(num_total_proposals),
    $.copy(rewards_rate),
    $.copy(rewards_rate_denominator),
    $c
  );
  rewards_amount = $.copy(rewards_active).add($.copy(rewards_pending_inactive));
  Coin.merge_(
    stake_pool.active,
    Coin.extract_all_(stake_pool.pending_active, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    $c,
    [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
  );
  current_lockup_expiration = $.copy(stake_pool.locked_until_secs);
  if (Timestamp.now_seconds_($c).ge($.copy(current_lockup_expiration))) {
    Coin.merge_(
      stake_pool.inactive,
      Coin.extract_all_(stake_pool.pending_inactive, $c, [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
      $c,
      [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
    );
  } else {
  }
  Event.emit_event_(
    stake_pool.distribute_rewards_events,
    new DistributeRewardsEvent(
      {
        pool_address: $.copy(pool_address),
        rewards_amount: $.copy(rewards_amount),
      },
      new SimpleStructTag(DistributeRewardsEvent)
    ),
    $c,
    [new SimpleStructTag(DistributeRewardsEvent)]
  );
  return;
}

export function update_voting_power_increase_(
  increase_amount: U64,
  $c: AptosDataCache
): void {
  let temp$1, validator_set, voting_power_increase_limit;
  validator_set = $c.borrow_global_mut<ValidatorSet>(
    new SimpleStructTag(ValidatorSet),
    new HexString("0x1")
  );
  temp$1 = Staking_config.get_($c);
  voting_power_increase_limit = u128(
    Staking_config.get_voting_power_increase_limit_(temp$1, $c)
  );
  validator_set.total_joining_power = $.copy(
    validator_set.total_joining_power
  ).add(u128($.copy(increase_amount)));
  if ($.copy(validator_set.total_voting_power).gt(u128("0"))) {
    if (
      !$.copy(validator_set.total_joining_power).le(
        $.copy(validator_set.total_voting_power)
          .mul($.copy(voting_power_increase_limit))
          .div(u128("100"))
      )
    ) {
      throw $.abortCode(
        Error.invalid_argument_(
          $.copy(EVOTING_POWER_INCREASE_EXCEEDS_LIMIT),
          $c
        )
      );
    }
  } else {
  }
  return;
}

export function withdraw_(
  owner: HexString,
  withdraw_amount: U64,
  $c: AptosDataCache
): void {
  let coins, owner_address, ownership_cap;
  owner_address = Signer.address_of_(owner, $c);
  assert_owner_cap_exists_($.copy(owner_address), $c);
  ownership_cap = $c.borrow_global<OwnerCapability>(
    new SimpleStructTag(OwnerCapability),
    $.copy(owner_address)
  );
  coins = withdraw_with_cap_(ownership_cap, $.copy(withdraw_amount), $c);
  Coin.deposit_($.copy(owner_address), coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  return;
}

export function buildPayload_withdraw(
  withdraw_amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "stake",
    "withdraw",
    typeParamStrings,
    [withdraw_amount],
    isJSON
  );
}
export function withdraw_with_cap_(
  owner_cap: OwnerCapability,
  withdraw_amount: U64,
  $c: AptosDataCache
): Coin.Coin {
  let temp$1, pending_inactive_stake, pool_address, stake_pool;
  pool_address = $.copy(owner_cap.pool_address);
  assert_stake_pool_exists_($.copy(pool_address), $c);
  stake_pool = $c.borrow_global_mut<StakePool>(
    new SimpleStructTag(StakePool),
    $.copy(pool_address)
  );
  if (
    get_validator_state_($.copy(pool_address), $c).eq(
      $.copy(VALIDATOR_STATUS_INACTIVE)
    )
  ) {
    temp$1 = Timestamp.now_seconds_($c).ge(
      $.copy(stake_pool.locked_until_secs)
    );
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    pending_inactive_stake = Coin.extract_all_(
      stake_pool.pending_inactive,
      $c,
      [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
    );
    Coin.merge_(stake_pool.inactive, pending_inactive_stake, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  } else {
  }
  withdraw_amount = Math64.min_(
    $.copy(withdraw_amount),
    Coin.value_(stake_pool.inactive, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
    $c
  );
  if ($.copy(withdraw_amount).eq(u64("0"))) {
    return Coin.zero_($c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  } else {
  }
  Event.emit_event_(
    stake_pool.withdraw_stake_events,
    new WithdrawStakeEvent(
      {
        pool_address: $.copy(pool_address),
        amount_withdrawn: $.copy(withdraw_amount),
      },
      new SimpleStructTag(WithdrawStakeEvent)
    ),
    $c,
    [new SimpleStructTag(WithdrawStakeEvent)]
  );
  return Coin.extract_(stake_pool.inactive, $.copy(withdraw_amount), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::stake::AddStakeEvent",
    AddStakeEvent.AddStakeEventParser
  );
  repo.addParser(
    "0x1::stake::AllowedValidators",
    AllowedValidators.AllowedValidatorsParser
  );
  repo.addParser(
    "0x1::stake::AptosCoinCapabilities",
    AptosCoinCapabilities.AptosCoinCapabilitiesParser
  );
  repo.addParser(
    "0x1::stake::DistributeRewardsEvent",
    DistributeRewardsEvent.DistributeRewardsEventParser
  );
  repo.addParser(
    "0x1::stake::IncreaseLockupEvent",
    IncreaseLockupEvent.IncreaseLockupEventParser
  );
  repo.addParser(
    "0x1::stake::IndividualValidatorPerformance",
    IndividualValidatorPerformance.IndividualValidatorPerformanceParser
  );
  repo.addParser(
    "0x1::stake::JoinValidatorSetEvent",
    JoinValidatorSetEvent.JoinValidatorSetEventParser
  );
  repo.addParser(
    "0x1::stake::LeaveValidatorSetEvent",
    LeaveValidatorSetEvent.LeaveValidatorSetEventParser
  );
  repo.addParser(
    "0x1::stake::OwnerCapability",
    OwnerCapability.OwnerCapabilityParser
  );
  repo.addParser(
    "0x1::stake::ReactivateStakeEvent",
    ReactivateStakeEvent.ReactivateStakeEventParser
  );
  repo.addParser(
    "0x1::stake::RegisterValidatorCandidateEvent",
    RegisterValidatorCandidateEvent.RegisterValidatorCandidateEventParser
  );
  repo.addParser(
    "0x1::stake::RotateConsensusKeyEvent",
    RotateConsensusKeyEvent.RotateConsensusKeyEventParser
  );
  repo.addParser(
    "0x1::stake::SetOperatorEvent",
    SetOperatorEvent.SetOperatorEventParser
  );
  repo.addParser("0x1::stake::StakePool", StakePool.StakePoolParser);
  repo.addParser(
    "0x1::stake::UnlockStakeEvent",
    UnlockStakeEvent.UnlockStakeEventParser
  );
  repo.addParser(
    "0x1::stake::UpdateNetworkAndFullnodeAddressesEvent",
    UpdateNetworkAndFullnodeAddressesEvent.UpdateNetworkAndFullnodeAddressesEventParser
  );
  repo.addParser(
    "0x1::stake::ValidatorConfig",
    ValidatorConfig.ValidatorConfigParser
  );
  repo.addParser(
    "0x1::stake::ValidatorInfo",
    ValidatorInfo.ValidatorInfoParser
  );
  repo.addParser(
    "0x1::stake::ValidatorPerformance",
    ValidatorPerformance.ValidatorPerformanceParser
  );
  repo.addParser("0x1::stake::ValidatorSet", ValidatorSet.ValidatorSetParser);
  repo.addParser(
    "0x1::stake::WithdrawStakeEvent",
    WithdrawStakeEvent.WithdrawStakeEventParser
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
  get AddStakeEvent() {
    return AddStakeEvent;
  }
  get AllowedValidators() {
    return AllowedValidators;
  }
  async loadAllowedValidators(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await AllowedValidators.load(
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
  get AptosCoinCapabilities() {
    return AptosCoinCapabilities;
  }
  async loadAptosCoinCapabilities(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await AptosCoinCapabilities.load(
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
  get DistributeRewardsEvent() {
    return DistributeRewardsEvent;
  }
  get IncreaseLockupEvent() {
    return IncreaseLockupEvent;
  }
  get IndividualValidatorPerformance() {
    return IndividualValidatorPerformance;
  }
  get JoinValidatorSetEvent() {
    return JoinValidatorSetEvent;
  }
  get LeaveValidatorSetEvent() {
    return LeaveValidatorSetEvent;
  }
  get OwnerCapability() {
    return OwnerCapability;
  }
  async loadOwnerCapability(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await OwnerCapability.load(
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
  get ReactivateStakeEvent() {
    return ReactivateStakeEvent;
  }
  get RegisterValidatorCandidateEvent() {
    return RegisterValidatorCandidateEvent;
  }
  get RotateConsensusKeyEvent() {
    return RotateConsensusKeyEvent;
  }
  get SetOperatorEvent() {
    return SetOperatorEvent;
  }
  get StakePool() {
    return StakePool;
  }
  async loadStakePool(owner: HexString, loadFull = true, fillCache = true) {
    const val = await StakePool.load(
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
  get UnlockStakeEvent() {
    return UnlockStakeEvent;
  }
  get UpdateNetworkAndFullnodeAddressesEvent() {
    return UpdateNetworkAndFullnodeAddressesEvent;
  }
  get ValidatorConfig() {
    return ValidatorConfig;
  }
  async loadValidatorConfig(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await ValidatorConfig.load(
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
  get ValidatorInfo() {
    return ValidatorInfo;
  }
  get ValidatorPerformance() {
    return ValidatorPerformance;
  }
  async loadValidatorPerformance(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await ValidatorPerformance.load(
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
  get ValidatorSet() {
    return ValidatorSet;
  }
  async loadValidatorSet(owner: HexString, loadFull = true, fillCache = true) {
    const val = await ValidatorSet.load(
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
  get WithdrawStakeEvent() {
    return WithdrawStakeEvent;
  }
  payload_add_stake(
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_add_stake(amount, isJSON);
  }
  async add_stake(
    _account: AptosAccount,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_add_stake(amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_increase_lockup(
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_increase_lockup(isJSON);
  }
  async increase_lockup(
    _account: AptosAccount,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_increase_lockup(_isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_initialize_stake_owner(
    initial_stake_amount: U64,
    operator: HexString,
    voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_initialize_stake_owner(
      initial_stake_amount,
      operator,
      voter,
      isJSON
    );
  }
  async initialize_stake_owner(
    _account: AptosAccount,
    initial_stake_amount: U64,
    operator: HexString,
    voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_initialize_stake_owner(
      initial_stake_amount,
      operator,
      voter,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_initialize_validator(
    consensus_pubkey: U8[],
    proof_of_possession: U8[],
    network_addresses: U8[],
    fullnode_addresses: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_initialize_validator(
      consensus_pubkey,
      proof_of_possession,
      network_addresses,
      fullnode_addresses,
      isJSON
    );
  }
  async initialize_validator(
    _account: AptosAccount,
    consensus_pubkey: U8[],
    proof_of_possession: U8[],
    network_addresses: U8[],
    fullnode_addresses: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_initialize_validator(
      consensus_pubkey,
      proof_of_possession,
      network_addresses,
      fullnode_addresses,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_join_validator_set(
    pool_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_join_validator_set(pool_address, isJSON);
  }
  async join_validator_set(
    _account: AptosAccount,
    pool_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_join_validator_set(pool_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_leave_validator_set(
    pool_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_leave_validator_set(pool_address, isJSON);
  }
  async leave_validator_set(
    _account: AptosAccount,
    pool_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_leave_validator_set(pool_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_reactivate_stake(
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_reactivate_stake(amount, isJSON);
  }
  async reactivate_stake(
    _account: AptosAccount,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_reactivate_stake(amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_rotate_consensus_key(
    pool_address: HexString,
    new_consensus_pubkey: U8[],
    proof_of_possession: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_rotate_consensus_key(
      pool_address,
      new_consensus_pubkey,
      proof_of_possession,
      isJSON
    );
  }
  async rotate_consensus_key(
    _account: AptosAccount,
    pool_address: HexString,
    new_consensus_pubkey: U8[],
    proof_of_possession: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_rotate_consensus_key(
      pool_address,
      new_consensus_pubkey,
      proof_of_possession,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_delegated_voter(
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_delegated_voter(new_voter, isJSON);
  }
  async set_delegated_voter(
    _account: AptosAccount,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_delegated_voter(new_voter, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_operator(
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_operator(new_operator, isJSON);
  }
  async set_operator(
    _account: AptosAccount,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_operator(new_operator, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_unlock(
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_unlock(amount, isJSON);
  }
  async unlock(
    _account: AptosAccount,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_unlock(amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_update_network_and_fullnode_addresses(
    pool_address: HexString,
    new_network_addresses: U8[],
    new_fullnode_addresses: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_update_network_and_fullnode_addresses(
      pool_address,
      new_network_addresses,
      new_fullnode_addresses,
      isJSON
    );
  }
  async update_network_and_fullnode_addresses(
    _account: AptosAccount,
    pool_address: HexString,
    new_network_addresses: U8[],
    new_fullnode_addresses: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_update_network_and_fullnode_addresses(
      pool_address,
      new_network_addresses,
      new_fullnode_addresses,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw(
    withdraw_amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw(withdraw_amount, isJSON);
  }
  async withdraw(
    _account: AptosAccount,
    withdraw_amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw(withdraw_amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
