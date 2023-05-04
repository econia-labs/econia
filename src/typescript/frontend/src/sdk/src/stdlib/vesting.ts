import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, U128 } from "@manahippo/move-to-ts";
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
import * as Aptos_account from "./aptos_account";
import * as Bcs from "./bcs";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Event from "./event";
import * as Fixed_point32 from "./fixed_point32";
import * as Math64 from "./math64";
import * as Pool_u64 from "./pool_u64";
import * as Signer from "./signer";
import * as Simple_map from "./simple_map";
import * as Stake from "./stake";
import * as Staking_contract from "./staking_contract";
import * as String from "./string";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "vesting";

export const EEMPTY_VESTING_SCHEDULE: U64 = u64("2");
export const EINVALID_WITHDRAWAL_ADDRESS: U64 = u64("1");
export const ENOT_ADMIN: U64 = u64("7");
export const ENO_SHAREHOLDERS: U64 = u64("4");
export const EPENDING_STAKE_FOUND: U64 = u64("11");
export const EPERMISSION_DENIED: U64 = u64("15");
export const EROLE_NOT_FOUND: U64 = u64("14");
export const ESHARES_LENGTH_MISMATCH: U64 = u64("5");
export const EVESTING_ACCOUNT_HAS_NO_ROLES: U64 = u64("13");
export const EVESTING_CONTRACT_NOT_ACTIVE: U64 = u64("8");
export const EVESTING_CONTRACT_NOT_FOUND: U64 = u64("10");
export const EVESTING_CONTRACT_STILL_ACTIVE: U64 = u64("9");
export const EVESTING_START_TOO_SOON: U64 = u64("6");
export const EZERO_GRANT: U64 = u64("12");
export const EZERO_VESTING_SCHEDULE_PERIOD: U64 = u64("3");
export const MAXIMUM_SHAREHOLDERS: U64 = u64("30");
export const ROLE_BENEFICIARY_RESETTER: U8[] = [
  u8("82"),
  u8("79"),
  u8("76"),
  u8("69"),
  u8("95"),
  u8("66"),
  u8("69"),
  u8("78"),
  u8("69"),
  u8("70"),
  u8("73"),
  u8("67"),
  u8("73"),
  u8("65"),
  u8("82"),
  u8("89"),
  u8("95"),
  u8("82"),
  u8("69"),
  u8("83"),
  u8("69"),
  u8("84"),
  u8("84"),
  u8("69"),
  u8("82"),
];
export const VESTING_POOL_ACTIVE: U64 = u64("1");
export const VESTING_POOL_SALT: U8[] = [
  u8("97"),
  u8("112"),
  u8("116"),
  u8("111"),
  u8("115"),
  u8("95"),
  u8("102"),
  u8("114"),
  u8("97"),
  u8("109"),
  u8("101"),
  u8("119"),
  u8("111"),
  u8("114"),
  u8("107"),
  u8("58"),
  u8("58"),
  u8("118"),
  u8("101"),
  u8("115"),
  u8("116"),
  u8("105"),
  u8("110"),
  u8("103"),
];
export const VESTING_POOL_TERMINATED: U64 = u64("2");

export class AdminStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AdminStore";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "vesting_contracts",
      typeTag: new VectorTag(AtomicTypeTag.Address),
    },
    { name: "nonce", typeTag: AtomicTypeTag.U64 },
    {
      name: "create_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "vesting",
          "CreateVestingContractEvent",
          []
        ),
      ]),
    },
  ];

  vesting_contracts: HexString[];
  nonce: U64;
  create_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.vesting_contracts = proto["vesting_contracts"] as HexString[];
    this.nonce = proto["nonce"] as U64;
    this.create_events = proto["create_events"] as Event.EventHandle;
  }

  static AdminStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AdminStore {
    const proto = $.parseStructProto(data, typeTag, repo, AdminStore);
    return new AdminStore(proto, typeTag);
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
      AdminStore,
      typeParams
    );
    return result as unknown as AdminStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      AdminStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as AdminStore;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AdminStore", []);
  }
  async loadFullState(app: $.AppType) {
    await this.create_events.loadFullState(app);
    this.__app = app;
  }
}

export class AdminWithdrawEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AdminWithdrawEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.amount = proto["amount"] as U64;
  }

  static AdminWithdrawEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AdminWithdrawEvent {
    const proto = $.parseStructProto(data, typeTag, repo, AdminWithdrawEvent);
    return new AdminWithdrawEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AdminWithdrawEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class CreateVestingContractEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CreateVestingContractEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "voter", typeTag: AtomicTypeTag.Address },
    { name: "grant_amount", typeTag: AtomicTypeTag.U64 },
    { name: "withdrawal_address", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "staking_pool_address", typeTag: AtomicTypeTag.Address },
    { name: "commission_percentage", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  voter: HexString;
  grant_amount: U64;
  withdrawal_address: HexString;
  vesting_contract_address: HexString;
  staking_pool_address: HexString;
  commission_percentage: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.voter = proto["voter"] as HexString;
    this.grant_amount = proto["grant_amount"] as U64;
    this.withdrawal_address = proto["withdrawal_address"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.staking_pool_address = proto["staking_pool_address"] as HexString;
    this.commission_percentage = proto["commission_percentage"] as U64;
  }

  static CreateVestingContractEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CreateVestingContractEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      CreateVestingContractEvent
    );
    return new CreateVestingContractEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "CreateVestingContractEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class DistributeEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "DistributeEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.amount = proto["amount"] as U64;
  }

  static DistributeEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): DistributeEvent {
    const proto = $.parseStructProto(data, typeTag, repo, DistributeEvent);
    return new DistributeEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "DistributeEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ResetLockupEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ResetLockupEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "staking_pool_address", typeTag: AtomicTypeTag.Address },
    { name: "new_lockup_expiration_secs", typeTag: AtomicTypeTag.U64 },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  staking_pool_address: HexString;
  new_lockup_expiration_secs: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.staking_pool_address = proto["staking_pool_address"] as HexString;
    this.new_lockup_expiration_secs = proto[
      "new_lockup_expiration_secs"
    ] as U64;
  }

  static ResetLockupEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ResetLockupEvent {
    const proto = $.parseStructProto(data, typeTag, repo, ResetLockupEvent);
    return new ResetLockupEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ResetLockupEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class SetBeneficiaryEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SetBeneficiaryEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "shareholder", typeTag: AtomicTypeTag.Address },
    { name: "old_beneficiary", typeTag: AtomicTypeTag.Address },
    { name: "new_beneficiary", typeTag: AtomicTypeTag.Address },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  shareholder: HexString;
  old_beneficiary: HexString;
  new_beneficiary: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.shareholder = proto["shareholder"] as HexString;
    this.old_beneficiary = proto["old_beneficiary"] as HexString;
    this.new_beneficiary = proto["new_beneficiary"] as HexString;
  }

  static SetBeneficiaryEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SetBeneficiaryEvent {
    const proto = $.parseStructProto(data, typeTag, repo, SetBeneficiaryEvent);
    return new SetBeneficiaryEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SetBeneficiaryEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class StakingInfo {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StakingInfo";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "voter", typeTag: AtomicTypeTag.Address },
    { name: "commission_percentage", typeTag: AtomicTypeTag.U64 },
  ];

  pool_address: HexString;
  operator: HexString;
  voter: HexString;
  commission_percentage: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pool_address = proto["pool_address"] as HexString;
    this.operator = proto["operator"] as HexString;
    this.voter = proto["voter"] as HexString;
    this.commission_percentage = proto["commission_percentage"] as U64;
  }

  static StakingInfoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StakingInfo {
    const proto = $.parseStructProto(data, typeTag, repo, StakingInfo);
    return new StakingInfo(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StakingInfo", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class TerminateEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "TerminateEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
  ];

  admin: HexString;
  vesting_contract_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
  }

  static TerminateEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): TerminateEvent {
    const proto = $.parseStructProto(data, typeTag, repo, TerminateEvent);
    return new TerminateEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "TerminateEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UnlockRewardsEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UnlockRewardsEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "staking_pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  staking_pool_address: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.staking_pool_address = proto["staking_pool_address"] as HexString;
    this.amount = proto["amount"] as U64;
  }

  static UnlockRewardsEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UnlockRewardsEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UnlockRewardsEvent);
    return new UnlockRewardsEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UnlockRewardsEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UpdateOperatorEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UpdateOperatorEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "staking_pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_operator", typeTag: AtomicTypeTag.Address },
    { name: "new_operator", typeTag: AtomicTypeTag.Address },
    { name: "commission_percentage", typeTag: AtomicTypeTag.U64 },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  staking_pool_address: HexString;
  old_operator: HexString;
  new_operator: HexString;
  commission_percentage: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.staking_pool_address = proto["staking_pool_address"] as HexString;
    this.old_operator = proto["old_operator"] as HexString;
    this.new_operator = proto["new_operator"] as HexString;
    this.commission_percentage = proto["commission_percentage"] as U64;
  }

  static UpdateOperatorEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UpdateOperatorEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UpdateOperatorEvent);
    return new UpdateOperatorEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UpdateOperatorEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UpdateVoterEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UpdateVoterEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "staking_pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_voter", typeTag: AtomicTypeTag.Address },
    { name: "new_voter", typeTag: AtomicTypeTag.Address },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  staking_pool_address: HexString;
  old_voter: HexString;
  new_voter: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.staking_pool_address = proto["staking_pool_address"] as HexString;
    this.old_voter = proto["old_voter"] as HexString;
    this.new_voter = proto["new_voter"] as HexString;
  }

  static UpdateVoterEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UpdateVoterEvent {
    const proto = $.parseStructProto(data, typeTag, repo, UpdateVoterEvent);
    return new UpdateVoterEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UpdateVoterEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class VestEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VestEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "admin", typeTag: AtomicTypeTag.Address },
    { name: "vesting_contract_address", typeTag: AtomicTypeTag.Address },
    { name: "staking_pool_address", typeTag: AtomicTypeTag.Address },
    { name: "period_vested", typeTag: AtomicTypeTag.U64 },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  admin: HexString;
  vesting_contract_address: HexString;
  staking_pool_address: HexString;
  period_vested: U64;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.admin = proto["admin"] as HexString;
    this.vesting_contract_address = proto[
      "vesting_contract_address"
    ] as HexString;
    this.staking_pool_address = proto["staking_pool_address"] as HexString;
    this.period_vested = proto["period_vested"] as U64;
    this.amount = proto["amount"] as U64;
  }

  static VestEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VestEvent {
    const proto = $.parseStructProto(data, typeTag, repo, VestEvent);
    return new VestEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "VestEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class VestingAccountManagement {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VestingAccountManagement";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "roles",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        new StructTag(new HexString("0x1"), "string", "String", []),
        AtomicTypeTag.Address,
      ]),
    },
  ];

  roles: Simple_map.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.roles = proto["roles"] as Simple_map.SimpleMap;
  }

  static VestingAccountManagementParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VestingAccountManagement {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      VestingAccountManagement
    );
    return new VestingAccountManagement(proto, typeTag);
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
      VestingAccountManagement,
      typeParams
    );
    return result as unknown as VestingAccountManagement;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      VestingAccountManagement,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as VestingAccountManagement;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "VestingAccountManagement",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.roles.loadFullState(app);
    this.__app = app;
  }
}

export class VestingContract {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VestingContract";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "state", typeTag: AtomicTypeTag.U64 },
    { name: "admin", typeTag: AtomicTypeTag.Address },
    {
      name: "grant_pool",
      typeTag: new StructTag(new HexString("0x1"), "pool_u64", "Pool", []),
    },
    {
      name: "beneficiaries",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        AtomicTypeTag.Address,
        AtomicTypeTag.Address,
      ]),
    },
    {
      name: "vesting_schedule",
      typeTag: new StructTag(
        new HexString("0x1"),
        "vesting",
        "VestingSchedule",
        []
      ),
    },
    { name: "withdrawal_address", typeTag: AtomicTypeTag.Address },
    {
      name: "staking",
      typeTag: new StructTag(
        new HexString("0x1"),
        "vesting",
        "StakingInfo",
        []
      ),
    },
    { name: "remaining_grant", typeTag: AtomicTypeTag.U64 },
    {
      name: "signer_cap",
      typeTag: new StructTag(
        new HexString("0x1"),
        "account",
        "SignerCapability",
        []
      ),
    },
    {
      name: "update_operator_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "vesting",
          "UpdateOperatorEvent",
          []
        ),
      ]),
    },
    {
      name: "update_voter_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "vesting", "UpdateVoterEvent", []),
      ]),
    },
    {
      name: "reset_lockup_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "vesting", "ResetLockupEvent", []),
      ]),
    },
    {
      name: "set_beneficiary_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "vesting",
          "SetBeneficiaryEvent",
          []
        ),
      ]),
    },
    {
      name: "unlock_rewards_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "vesting",
          "UnlockRewardsEvent",
          []
        ),
      ]),
    },
    {
      name: "vest_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "vesting", "VestEvent", []),
      ]),
    },
    {
      name: "distribute_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "vesting", "DistributeEvent", []),
      ]),
    },
    {
      name: "terminate_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "vesting", "TerminateEvent", []),
      ]),
    },
    {
      name: "admin_withdraw_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "vesting",
          "AdminWithdrawEvent",
          []
        ),
      ]),
    },
  ];

  state: U64;
  admin: HexString;
  grant_pool: Pool_u64.Pool;
  beneficiaries: Simple_map.SimpleMap;
  vesting_schedule: VestingSchedule;
  withdrawal_address: HexString;
  staking: StakingInfo;
  remaining_grant: U64;
  signer_cap: Account.SignerCapability;
  update_operator_events: Event.EventHandle;
  update_voter_events: Event.EventHandle;
  reset_lockup_events: Event.EventHandle;
  set_beneficiary_events: Event.EventHandle;
  unlock_rewards_events: Event.EventHandle;
  vest_events: Event.EventHandle;
  distribute_events: Event.EventHandle;
  terminate_events: Event.EventHandle;
  admin_withdraw_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.state = proto["state"] as U64;
    this.admin = proto["admin"] as HexString;
    this.grant_pool = proto["grant_pool"] as Pool_u64.Pool;
    this.beneficiaries = proto["beneficiaries"] as Simple_map.SimpleMap;
    this.vesting_schedule = proto["vesting_schedule"] as VestingSchedule;
    this.withdrawal_address = proto["withdrawal_address"] as HexString;
    this.staking = proto["staking"] as StakingInfo;
    this.remaining_grant = proto["remaining_grant"] as U64;
    this.signer_cap = proto["signer_cap"] as Account.SignerCapability;
    this.update_operator_events = proto[
      "update_operator_events"
    ] as Event.EventHandle;
    this.update_voter_events = proto[
      "update_voter_events"
    ] as Event.EventHandle;
    this.reset_lockup_events = proto[
      "reset_lockup_events"
    ] as Event.EventHandle;
    this.set_beneficiary_events = proto[
      "set_beneficiary_events"
    ] as Event.EventHandle;
    this.unlock_rewards_events = proto[
      "unlock_rewards_events"
    ] as Event.EventHandle;
    this.vest_events = proto["vest_events"] as Event.EventHandle;
    this.distribute_events = proto["distribute_events"] as Event.EventHandle;
    this.terminate_events = proto["terminate_events"] as Event.EventHandle;
    this.admin_withdraw_events = proto[
      "admin_withdraw_events"
    ] as Event.EventHandle;
  }

  static VestingContractParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VestingContract {
    const proto = $.parseStructProto(data, typeTag, repo, VestingContract);
    return new VestingContract(proto, typeTag);
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
      VestingContract,
      typeParams
    );
    return result as unknown as VestingContract;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      VestingContract,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as VestingContract;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "VestingContract", []);
  }
  async loadFullState(app: $.AppType) {
    await this.grant_pool.loadFullState(app);
    await this.beneficiaries.loadFullState(app);
    await this.vesting_schedule.loadFullState(app);
    await this.staking.loadFullState(app);
    await this.signer_cap.loadFullState(app);
    await this.update_operator_events.loadFullState(app);
    await this.update_voter_events.loadFullState(app);
    await this.reset_lockup_events.loadFullState(app);
    await this.set_beneficiary_events.loadFullState(app);
    await this.unlock_rewards_events.loadFullState(app);
    await this.vest_events.loadFullState(app);
    await this.distribute_events.loadFullState(app);
    await this.terminate_events.loadFullState(app);
    await this.admin_withdraw_events.loadFullState(app);
    this.__app = app;
  }
}

export class VestingSchedule {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "VestingSchedule";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "schedule",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "fixed_point32", "FixedPoint32", [])
      ),
    },
    { name: "start_timestamp_secs", typeTag: AtomicTypeTag.U64 },
    { name: "period_duration", typeTag: AtomicTypeTag.U64 },
    { name: "last_vested_period", typeTag: AtomicTypeTag.U64 },
  ];

  schedule: Fixed_point32.FixedPoint32[];
  start_timestamp_secs: U64;
  period_duration: U64;
  last_vested_period: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.schedule = proto["schedule"] as Fixed_point32.FixedPoint32[];
    this.start_timestamp_secs = proto["start_timestamp_secs"] as U64;
    this.period_duration = proto["period_duration"] as U64;
    this.last_vested_period = proto["last_vested_period"] as U64;
  }

  static VestingScheduleParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): VestingSchedule {
    const proto = $.parseStructProto(data, typeTag, repo, VestingSchedule);
    return new VestingSchedule(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "VestingSchedule", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function admin_withdraw_(
  admin: HexString,
  contract_address: HexString,
  $c: AptosDataCache
): void {
  let temp$2,
    temp$3,
    temp$4,
    temp$5,
    amount,
    coins,
    vesting_contract,
    vesting_contract__1;
  vesting_contract = $c.borrow_global<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  if (!$.copy(vesting_contract.state).eq($.copy(VESTING_POOL_TERMINATED))) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EVESTING_CONTRACT_STILL_ACTIVE), $c)
    );
  }
  vesting_contract__1 = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$2, temp$3] = [admin, vesting_contract__1];
  verify_admin_(temp$2, temp$3, $c);
  [temp$4, temp$5] = [vesting_contract__1, $.copy(contract_address)];
  coins = withdraw_stake_(temp$4, temp$5, $c);
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
  Coin.deposit_($.copy(vesting_contract__1.withdrawal_address), coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  Event.emit_event_(
    vesting_contract__1.admin_withdraw_events,
    new AdminWithdrawEvent(
      {
        admin: $.copy(vesting_contract__1.admin),
        vesting_contract_address: $.copy(contract_address),
        amount: $.copy(amount),
      },
      new SimpleStructTag(AdminWithdrawEvent)
    ),
    $c,
    [new SimpleStructTag(AdminWithdrawEvent)]
  );
  return;
}

export function buildPayload_admin_withdraw(
  contract_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "admin_withdraw",
    typeParamStrings,
    [contract_address],
    isJSON
  );
}
export function assert_active_vesting_contract_(
  contract_address: HexString,
  $c: AptosDataCache
): void {
  let vesting_contract;
  assert_vesting_contract_exists_($.copy(contract_address), $c);
  vesting_contract = $c.borrow_global<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  if (!$.copy(vesting_contract.state).eq($.copy(VESTING_POOL_ACTIVE))) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EVESTING_CONTRACT_NOT_ACTIVE), $c)
    );
  }
  return;
}

export function assert_vesting_contract_exists_(
  contract_address: HexString,
  $c: AptosDataCache
): void {
  if (
    !$c.exists(new SimpleStructTag(VestingContract), $.copy(contract_address))
  ) {
    throw $.abortCode(
      Error.not_found_($.copy(EVESTING_CONTRACT_NOT_FOUND), $c)
    );
  }
  return;
}

export function beneficiary_(
  vesting_contract_address: HexString,
  shareholder: HexString,
  $c: AptosDataCache
): HexString {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return get_beneficiary_(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ),
    $.copy(shareholder),
    $c
  );
}

export function create_vesting_contract_(
  admin: HexString,
  shareholders: HexString[],
  buy_ins: Simple_map.SimpleMap,
  vesting_schedule: VestingSchedule,
  withdrawal_address: HexString,
  operator: HexString,
  voter: HexString,
  commission_percentage: U64,
  contract_creation_seed: U8[],
  $c: AptosDataCache
): HexString {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    admin_address,
    admin_store,
    buy_in,
    buy_in_amount,
    contract_address,
    contract_signer,
    contract_signer_cap,
    grant,
    grant_amount,
    grant_pool,
    i,
    len,
    pool_address,
    shareholder;
  if (System_addresses.is_reserved_address_($.copy(withdrawal_address), $c)) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_WITHDRAWAL_ADDRESS), $c)
    );
  }
  Aptos_account.assert_account_is_registered_for_apt_(
    $.copy(withdrawal_address),
    $c
  );
  if (!Vector.length_(shareholders, $c, [AtomicTypeTag.Address]).gt(u64("0"))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ENO_SHAREHOLDERS), $c));
  }
  if (
    !Simple_map.length_(buy_ins, $c, [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    ]).eq(Vector.length_(shareholders, $c, [AtomicTypeTag.Address]))
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ESHARES_LENGTH_MISMATCH), $c)
    );
  }
  grant = Coin.zero_($c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  grant_amount = u64("0");
  grant_pool = Pool_u64.create_($.copy(MAXIMUM_SHAREHOLDERS), $c);
  len = Vector.length_(shareholders, $c, [AtomicTypeTag.Address]);
  i = u64("0");
  while ($.copy(i).lt($.copy(len))) {
    {
      shareholder = $.copy(
        Vector.borrow_(shareholders, $.copy(i), $c, [AtomicTypeTag.Address])
      );
      [, buy_in] = Simple_map.remove_(buy_ins, shareholder, $c, [
        AtomicTypeTag.Address,
        new StructTag(new HexString("0x1"), "coin", "Coin", [
          new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
        ]),
      ]);
      buy_in_amount = Coin.value_(buy_in, $c, [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]);
      Coin.merge_(grant, buy_in, $c, [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]);
      Pool_u64.buy_in_(
        grant_pool,
        $.copy(
          Vector.borrow_(shareholders, $.copy(i), $c, [AtomicTypeTag.Address])
        ),
        $.copy(buy_in_amount),
        $c
      );
      grant_amount = $.copy(grant_amount).add($.copy(buy_in_amount));
      i = $.copy(i).add(u64("1"));
    }
  }
  if (!$.copy(grant_amount).gt(u64("0"))) {
    throw $.abortCode(Error.invalid_argument_($.copy(EZERO_GRANT), $c));
  }
  admin_address = Signer.address_of_(admin, $c);
  if (!$c.exists(new SimpleStructTag(AdminStore), $.copy(admin_address))) {
    $c.move_to(
      new SimpleStructTag(AdminStore),
      admin,
      new AdminStore(
        {
          vesting_contracts: Vector.empty_($c, [AtomicTypeTag.Address]),
          nonce: u64("0"),
          create_events: Account.new_event_handle_(admin, $c, [
            new SimpleStructTag(CreateVestingContractEvent),
          ]),
        },
        new SimpleStructTag(AdminStore)
      )
    );
  } else {
  }
  [contract_signer, contract_signer_cap] = create_vesting_contract_account_(
    admin,
    $.copy(contract_creation_seed),
    $c
  );
  pool_address = Staking_contract.create_staking_contract_with_coins_(
    contract_signer,
    $.copy(operator),
    $.copy(voter),
    grant,
    $.copy(commission_percentage),
    $.copy(contract_creation_seed),
    $c
  );
  contract_address = Signer.address_of_(contract_signer, $c);
  admin_store = $c.borrow_global_mut<AdminStore>(
    new SimpleStructTag(AdminStore),
    $.copy(admin_address)
  );
  Vector.push_back_(
    admin_store.vesting_contracts,
    $.copy(contract_address),
    $c,
    [AtomicTypeTag.Address]
  );
  temp$8 = admin_store.create_events;
  temp$1 = $.copy(operator);
  temp$2 = $.copy(voter);
  temp$3 = $.copy(withdrawal_address);
  temp$4 = $.copy(grant_amount);
  temp$5 = $.copy(contract_address);
  temp$6 = $.copy(pool_address);
  temp$7 = $.copy(commission_percentage);
  Event.emit_event_(
    temp$8,
    new CreateVestingContractEvent(
      {
        operator: temp$1,
        voter: temp$2,
        grant_amount: temp$4,
        withdrawal_address: temp$3,
        vesting_contract_address: temp$5,
        staking_pool_address: temp$6,
        commission_percentage: temp$7,
      },
      new SimpleStructTag(CreateVestingContractEvent)
    ),
    $c,
    [new SimpleStructTag(CreateVestingContractEvent)]
  );
  $c.move_to(
    new SimpleStructTag(VestingContract),
    contract_signer,
    new VestingContract(
      {
        state: $.copy(VESTING_POOL_ACTIVE),
        admin: $.copy(admin_address),
        grant_pool: grant_pool,
        beneficiaries: Simple_map.create_($c, [
          AtomicTypeTag.Address,
          AtomicTypeTag.Address,
        ]),
        vesting_schedule: $.copy(vesting_schedule),
        withdrawal_address: $.copy(withdrawal_address),
        staking: new StakingInfo(
          {
            pool_address: $.copy(pool_address),
            operator: $.copy(operator),
            voter: $.copy(voter),
            commission_percentage: $.copy(commission_percentage),
          },
          new SimpleStructTag(StakingInfo)
        ),
        remaining_grant: $.copy(grant_amount),
        signer_cap: contract_signer_cap,
        update_operator_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(UpdateOperatorEvent),
        ]),
        update_voter_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(UpdateVoterEvent),
        ]),
        reset_lockup_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(ResetLockupEvent),
        ]),
        set_beneficiary_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(SetBeneficiaryEvent),
        ]),
        unlock_rewards_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(UnlockRewardsEvent),
        ]),
        vest_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(VestEvent),
        ]),
        distribute_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(DistributeEvent),
        ]),
        terminate_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(TerminateEvent),
        ]),
        admin_withdraw_events: Account.new_event_handle_(contract_signer, $c, [
          new SimpleStructTag(AdminWithdrawEvent),
        ]),
      },
      new SimpleStructTag(VestingContract)
    )
  );
  Simple_map.destroy_empty_(buy_ins, $c, [
    AtomicTypeTag.Address,
    new StructTag(new HexString("0x1"), "coin", "Coin", [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]),
  ]);
  return $.copy(contract_address);
}

export function create_vesting_contract_account_(
  admin: HexString,
  contract_creation_seed: U8[],
  $c: AptosDataCache
): [HexString, Account.SignerCapability] {
  let temp$1, account_signer, admin_store, seed, signer_cap;
  admin_store = $c.borrow_global_mut<AdminStore>(
    new SimpleStructTag(AdminStore),
    Signer.address_of_(admin, $c)
  );
  temp$1 = Signer.address_of_(admin, $c);
  seed = Bcs.to_bytes_(temp$1, $c, [AtomicTypeTag.Address]);
  Vector.append_(
    seed,
    Bcs.to_bytes_(admin_store.nonce, $c, [AtomicTypeTag.U64]),
    $c,
    [AtomicTypeTag.U8]
  );
  admin_store.nonce = $.copy(admin_store.nonce).add(u64("1"));
  Vector.append_(seed, $.copy(VESTING_POOL_SALT), $c, [AtomicTypeTag.U8]);
  Vector.append_(seed, $.copy(contract_creation_seed), $c, [AtomicTypeTag.U8]);
  [account_signer, signer_cap] = Account.create_resource_account_(
    admin,
    $.copy(seed),
    $c
  );
  Coin.register_(account_signer, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  return [account_signer, signer_cap];
}

export function create_vesting_schedule_(
  schedule: Fixed_point32.FixedPoint32[],
  start_timestamp_secs: U64,
  period_duration: U64,
  $c: AptosDataCache
): VestingSchedule {
  if (
    !Vector.length_(schedule, $c, [
      new StructTag(new HexString("0x1"), "fixed_point32", "FixedPoint32", []),
    ]).gt(u64("0"))
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EEMPTY_VESTING_SCHEDULE), $c)
    );
  }
  if (!$.copy(period_duration).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_VESTING_SCHEDULE_PERIOD), $c)
    );
  }
  if (!$.copy(start_timestamp_secs).ge(Timestamp.now_seconds_($c))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EVESTING_START_TOO_SOON), $c)
    );
  }
  return new VestingSchedule(
    {
      schedule: $.copy(schedule),
      start_timestamp_secs: $.copy(start_timestamp_secs),
      period_duration: $.copy(period_duration),
      last_vested_period: u64("0"),
    },
    new SimpleStructTag(VestingSchedule)
  );
}

export function distribute_(
  contract_address: HexString,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    amount,
    coins,
    grant_pool,
    i,
    len,
    recipient_address,
    share_of_coins,
    shareholder,
    shareholders,
    shares,
    total_distribution_amount,
    vesting_contract;
  assert_active_vesting_contract_($.copy(contract_address), $c);
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [vesting_contract, $.copy(contract_address)];
  coins = withdraw_stake_(temp$1, temp$2, $c);
  total_distribution_amount = Coin.value_(coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  if ($.copy(total_distribution_amount).eq(u64("0"))) {
    Coin.destroy_zero_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
    return;
  } else {
  }
  grant_pool = vesting_contract.grant_pool;
  temp$3 = Pool_u64.shareholders_(grant_pool, $c);
  shareholders = temp$3;
  len = Vector.length_(shareholders, $c, [AtomicTypeTag.Address]);
  i = u64("0");
  while ($.copy(i).lt($.copy(len))) {
    {
      shareholder = $.copy(
        Vector.borrow_(shareholders, $.copy(i), $c, [AtomicTypeTag.Address])
      );
      shares = Pool_u64.shares_(grant_pool, $.copy(shareholder), $c);
      amount = Pool_u64.shares_to_amount_with_total_coins_(
        grant_pool,
        $.copy(shares),
        $.copy(total_distribution_amount),
        $c
      );
      share_of_coins = Coin.extract_(coins, $.copy(amount), $c, [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]);
      [temp$4, temp$5] = [vesting_contract, $.copy(shareholder)];
      recipient_address = get_beneficiary_(temp$4, temp$5, $c);
      Coin.deposit_($.copy(recipient_address), share_of_coins, $c, [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]);
      i = $.copy(i).add(u64("1"));
    }
  }
  if (
    Coin.value_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]).gt(u64("0"))
  ) {
    Coin.deposit_($.copy(vesting_contract.withdrawal_address), coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  } else {
    Coin.destroy_zero_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  }
  Event.emit_event_(
    vesting_contract.distribute_events,
    new DistributeEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
        amount: $.copy(total_distribution_amount),
      },
      new SimpleStructTag(DistributeEvent)
    ),
    $c,
    [new SimpleStructTag(DistributeEvent)]
  );
  return;
}

export function buildPayload_distribute(
  contract_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "distribute",
    typeParamStrings,
    [contract_address],
    isJSON
  );
}
export function get_beneficiary_(
  contract: VestingContract,
  shareholder: HexString,
  $c: AptosDataCache
): HexString {
  let temp$1;
  if (
    Simple_map.contains_key_(contract.beneficiaries, shareholder, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.Address,
    ])
  ) {
    temp$1 = $.copy(
      Simple_map.borrow_(contract.beneficiaries, shareholder, $c, [
        AtomicTypeTag.Address,
        AtomicTypeTag.Address,
      ])
    );
  } else {
    temp$1 = $.copy(shareholder);
  }
  return temp$1;
}

export function get_role_holder_(
  contract_address: HexString,
  role: String.String,
  $c: AptosDataCache
): HexString {
  let roles;
  if (
    !$c.exists(
      new SimpleStructTag(VestingAccountManagement),
      $.copy(contract_address)
    )
  ) {
    throw $.abortCode(
      Error.not_found_($.copy(EVESTING_ACCOUNT_HAS_NO_ROLES), $c)
    );
  }
  roles = $c.borrow_global<VestingAccountManagement>(
    new SimpleStructTag(VestingAccountManagement),
    $.copy(contract_address)
  ).roles;
  if (
    !Simple_map.contains_key_(roles, role, $c, [
      new StructTag(new HexString("0x1"), "string", "String", []),
      AtomicTypeTag.Address,
    ])
  ) {
    throw $.abortCode(Error.not_found_($.copy(EROLE_NOT_FOUND), $c));
  }
  return $.copy(
    Simple_map.borrow_(roles, role, $c, [
      new StructTag(new HexString("0x1"), "string", "String", []),
      AtomicTypeTag.Address,
    ])
  );
}

export function get_vesting_account_signer_(
  admin: HexString,
  contract_address: HexString,
  $c: AptosDataCache
): HexString {
  let temp$1, temp$2, vesting_contract;
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  return get_vesting_account_signer_internal_(vesting_contract, $c);
}

export function get_vesting_account_signer_internal_(
  vesting_contract: VestingContract,
  $c: AptosDataCache
): HexString {
  return Account.create_signer_with_capability_(
    vesting_contract.signer_cap,
    $c
  );
}

export function operator_(
  vesting_contract_address: HexString,
  $c: AptosDataCache
): HexString {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return $.copy(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ).staking.operator
  );
}

export function operator_commission_percentage_(
  vesting_contract_address: HexString,
  $c: AptosDataCache
): U64 {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return $.copy(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ).staking.commission_percentage
  );
}

export function remaining_grant_(
  vesting_contract_address: HexString,
  $c: AptosDataCache
): U64 {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return $.copy(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ).remaining_grant
  );
}

export function reset_beneficiary_(
  account: HexString,
  contract_address: HexString,
  shareholder: HexString,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, addr, beneficiaries, vesting_contract;
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  addr = Signer.address_of_(account, $c);
  if ($.copy(addr).hex() === $.copy(vesting_contract.admin).hex()) {
    temp$1 = true;
  } else {
    temp$1 =
      $.copy(addr).hex() ===
      get_role_holder_(
        $.copy(contract_address),
        String.utf8_($.copy(ROLE_BENEFICIARY_RESETTER), $c),
        $c
      ).hex();
  }
  if (!temp$1) {
    throw $.abortCode(Error.permission_denied_($.copy(EPERMISSION_DENIED), $c));
  }
  beneficiaries = vesting_contract.beneficiaries;
  [temp$2, temp$3] = [beneficiaries, shareholder];
  if (
    Simple_map.contains_key_(temp$2, temp$3, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.Address,
    ])
  ) {
    Simple_map.remove_(beneficiaries, shareholder, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.Address,
    ]);
  } else {
  }
  return;
}

export function buildPayload_reset_beneficiary(
  contract_address: HexString,
  shareholder: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "reset_beneficiary",
    typeParamStrings,
    [contract_address, shareholder],
    isJSON
  );
}
export function reset_lockup_(
  admin: HexString,
  contract_address: HexString,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, contract_signer, vesting_contract;
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  temp$3 = get_vesting_account_signer_internal_(vesting_contract, $c);
  contract_signer = temp$3;
  Staking_contract.reset_lockup_(
    contract_signer,
    $.copy(vesting_contract.staking.operator),
    $c
  );
  Event.emit_event_(
    vesting_contract.reset_lockup_events,
    new ResetLockupEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
        staking_pool_address: $.copy(vesting_contract.staking.pool_address),
        new_lockup_expiration_secs: Stake.get_lockup_secs_(
          $.copy(vesting_contract.staking.pool_address),
          $c
        ),
      },
      new SimpleStructTag(ResetLockupEvent)
    ),
    $c,
    [new SimpleStructTag(ResetLockupEvent)]
  );
  return;
}

export function buildPayload_reset_lockup(
  contract_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "reset_lockup",
    typeParamStrings,
    [contract_address],
    isJSON
  );
}
export function set_beneficiary_(
  admin: HexString,
  contract_address: HexString,
  shareholder: HexString,
  new_beneficiary: HexString,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    beneficiaries,
    beneficiary,
    old_beneficiary,
    vesting_contract;
  Aptos_account.assert_account_is_registered_for_apt_(
    $.copy(new_beneficiary),
    $c
  );
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  [temp$3, temp$4] = [vesting_contract, $.copy(shareholder)];
  old_beneficiary = get_beneficiary_(temp$3, temp$4, $c);
  beneficiaries = vesting_contract.beneficiaries;
  [temp$5, temp$6] = [beneficiaries, shareholder];
  if (
    Simple_map.contains_key_(temp$5, temp$6, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.Address,
    ])
  ) {
    beneficiary = Simple_map.borrow_mut_(beneficiaries, shareholder, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.Address,
    ]);
    $.set(beneficiary, $.copy(new_beneficiary));
  } else {
    Simple_map.add_(
      beneficiaries,
      $.copy(shareholder),
      $.copy(new_beneficiary),
      $c,
      [AtomicTypeTag.Address, AtomicTypeTag.Address]
    );
  }
  Event.emit_event_(
    vesting_contract.set_beneficiary_events,
    new SetBeneficiaryEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
        shareholder: $.copy(shareholder),
        old_beneficiary: $.copy(old_beneficiary),
        new_beneficiary: $.copy(new_beneficiary),
      },
      new SimpleStructTag(SetBeneficiaryEvent)
    ),
    $c,
    [new SimpleStructTag(SetBeneficiaryEvent)]
  );
  return;
}

export function buildPayload_set_beneficiary(
  contract_address: HexString,
  shareholder: HexString,
  new_beneficiary: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "set_beneficiary",
    typeParamStrings,
    [contract_address, shareholder, new_beneficiary],
    isJSON
  );
}
export function set_beneficiary_resetter_(
  admin: HexString,
  contract_address: HexString,
  beneficiary_resetter: HexString,
  $c: AptosDataCache
): void {
  set_management_role_(
    admin,
    $.copy(contract_address),
    String.utf8_($.copy(ROLE_BENEFICIARY_RESETTER), $c),
    $.copy(beneficiary_resetter),
    $c
  );
  return;
}

export function buildPayload_set_beneficiary_resetter(
  contract_address: HexString,
  beneficiary_resetter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "set_beneficiary_resetter",
    typeParamStrings,
    [contract_address, beneficiary_resetter],
    isJSON
  );
}
export function set_management_role_(
  admin: HexString,
  contract_address: HexString,
  role: String.String,
  role_holder: HexString,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    contract_signer,
    roles,
    vesting_contract;
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  if (
    !$c.exists(
      new SimpleStructTag(VestingAccountManagement),
      $.copy(contract_address)
    )
  ) {
    temp$3 = get_vesting_account_signer_internal_(vesting_contract, $c);
    contract_signer = temp$3;
    $c.move_to(
      new SimpleStructTag(VestingAccountManagement),
      contract_signer,
      new VestingAccountManagement(
        {
          roles: Simple_map.create_($c, [
            new StructTag(new HexString("0x1"), "string", "String", []),
            AtomicTypeTag.Address,
          ]),
        },
        new SimpleStructTag(VestingAccountManagement)
      )
    );
  } else {
  }
  roles = $c.borrow_global_mut<VestingAccountManagement>(
    new SimpleStructTag(VestingAccountManagement),
    $.copy(contract_address)
  ).roles;
  [temp$4, temp$5] = [roles, role];
  if (
    Simple_map.contains_key_(temp$4, temp$5, $c, [
      new StructTag(new HexString("0x1"), "string", "String", []),
      AtomicTypeTag.Address,
    ])
  ) {
    $.set(
      Simple_map.borrow_mut_(roles, role, $c, [
        new StructTag(new HexString("0x1"), "string", "String", []),
        AtomicTypeTag.Address,
      ]),
      $.copy(role_holder)
    );
  } else {
    Simple_map.add_(roles, $.copy(role), $.copy(role_holder), $c, [
      new StructTag(new HexString("0x1"), "string", "String", []),
      AtomicTypeTag.Address,
    ]);
  }
  return;
}

export function buildPayload_set_management_role(
  contract_address: HexString,
  role: String.String,
  role_holder: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "set_management_role",
    typeParamStrings,
    [contract_address, role, role_holder],
    isJSON
  );
}
export function stake_pool_address_(
  vesting_contract_address: HexString,
  $c: AptosDataCache
): HexString {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return $.copy(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ).staking.pool_address
  );
}

export function terminate_vesting_contract_(
  admin: HexString,
  contract_address: HexString,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    active_stake,
    pending_active_stake,
    vesting_contract;
  assert_active_vesting_contract_($.copy(contract_address), $c);
  distribute_($.copy(contract_address), $c);
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  [active_stake, , pending_active_stake] = Stake.get_stake_(
    $.copy(vesting_contract.staking.pool_address),
    $c
  );
  if (!$.copy(pending_active_stake).eq(u64("0"))) {
    throw $.abortCode(Error.invalid_state_($.copy(EPENDING_STAKE_FOUND), $c));
  }
  vesting_contract.state = $.copy(VESTING_POOL_TERMINATED);
  vesting_contract.remaining_grant = u64("0");
  [temp$3, temp$4] = [vesting_contract, $.copy(active_stake)];
  unlock_stake_(temp$3, temp$4, $c);
  Event.emit_event_(
    vesting_contract.terminate_events,
    new TerminateEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
      },
      new SimpleStructTag(TerminateEvent)
    ),
    $c,
    [new SimpleStructTag(TerminateEvent)]
  );
  return;
}

export function buildPayload_terminate_vesting_contract(
  contract_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "terminate_vesting_contract",
    typeParamStrings,
    [contract_address],
    isJSON
  );
}
export function unlock_rewards_(
  contract_address: HexString,
  $c: AptosDataCache
): void {
  let temp$1, contract_signer, vesting_contract;
  assert_active_vesting_contract_($.copy(contract_address), $c);
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  temp$1 = get_vesting_account_signer_internal_(vesting_contract, $c);
  contract_signer = temp$1;
  Staking_contract.unlock_rewards_(
    contract_signer,
    $.copy(vesting_contract.staking.operator),
    $c
  );
  return;
}

export function buildPayload_unlock_rewards(
  contract_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "unlock_rewards",
    typeParamStrings,
    [contract_address],
    isJSON
  );
}
export function unlock_stake_(
  vesting_contract: VestingContract,
  amount: U64,
  $c: AptosDataCache
): void {
  let temp$1, contract_signer;
  temp$1 = get_vesting_account_signer_internal_(vesting_contract, $c);
  contract_signer = temp$1;
  Staking_contract.unlock_stake_(
    contract_signer,
    $.copy(vesting_contract.staking.operator),
    $.copy(amount),
    $c
  );
  return;
}

export function update_operator_(
  admin: HexString,
  contract_address: HexString,
  new_operator: HexString,
  commission_percentage: U64,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, contract_signer, old_operator, vesting_contract;
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  temp$3 = get_vesting_account_signer_internal_(vesting_contract, $c);
  contract_signer = temp$3;
  old_operator = $.copy(vesting_contract.staking.operator);
  Staking_contract.switch_operator_(
    contract_signer,
    $.copy(old_operator),
    $.copy(new_operator),
    $.copy(commission_percentage),
    $c
  );
  vesting_contract.staking.operator = $.copy(new_operator);
  vesting_contract.staking.commission_percentage = $.copy(
    commission_percentage
  );
  Event.emit_event_(
    vesting_contract.update_operator_events,
    new UpdateOperatorEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
        staking_pool_address: $.copy(vesting_contract.staking.pool_address),
        old_operator: $.copy(old_operator),
        new_operator: $.copy(new_operator),
        commission_percentage: $.copy(commission_percentage),
      },
      new SimpleStructTag(UpdateOperatorEvent)
    ),
    $c,
    [new SimpleStructTag(UpdateOperatorEvent)]
  );
  return;
}

export function buildPayload_update_operator(
  contract_address: HexString,
  new_operator: HexString,
  commission_percentage: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "update_operator",
    typeParamStrings,
    [contract_address, new_operator, commission_percentage],
    isJSON
  );
}
export function update_operator_with_same_commission_(
  admin: HexString,
  contract_address: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let commission_percentage;
  commission_percentage = operator_commission_percentage_(
    $.copy(contract_address),
    $c
  );
  update_operator_(
    admin,
    $.copy(contract_address),
    $.copy(new_operator),
    $.copy(commission_percentage),
    $c
  );
  return;
}

export function buildPayload_update_operator_with_same_commission(
  contract_address: HexString,
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "update_operator_with_same_commission",
    typeParamStrings,
    [contract_address, new_operator],
    isJSON
  );
}
export function update_voter_(
  admin: HexString,
  contract_address: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, contract_signer, old_voter, vesting_contract;
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  [temp$1, temp$2] = [admin, vesting_contract];
  verify_admin_(temp$1, temp$2, $c);
  temp$3 = get_vesting_account_signer_internal_(vesting_contract, $c);
  contract_signer = temp$3;
  old_voter = $.copy(vesting_contract.staking.voter);
  Staking_contract.update_voter_(
    contract_signer,
    $.copy(vesting_contract.staking.operator),
    $.copy(new_voter),
    $c
  );
  vesting_contract.staking.voter = $.copy(new_voter);
  Event.emit_event_(
    vesting_contract.update_voter_events,
    new UpdateVoterEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
        staking_pool_address: $.copy(vesting_contract.staking.pool_address),
        old_voter: $.copy(old_voter),
        new_voter: $.copy(new_voter),
      },
      new SimpleStructTag(UpdateVoterEvent)
    ),
    $c,
    [new SimpleStructTag(UpdateVoterEvent)]
  );
  return;
}

export function buildPayload_update_voter(
  contract_address: HexString,
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "update_voter",
    typeParamStrings,
    [contract_address, new_voter],
    isJSON
  );
}
export function verify_admin_(
  admin: HexString,
  vesting_contract: VestingContract,
  $c: AptosDataCache
): void {
  if (
    !(
      Signer.address_of_(admin, $c).hex() ===
      $.copy(vesting_contract.admin).hex()
    )
  ) {
    throw $.abortCode(Error.unauthenticated_($.copy(ENOT_ADMIN), $c));
  }
  return;
}

export function vest_(contract_address: HexString, $c: AptosDataCache): void {
  let temp$1,
    temp$2,
    temp$3,
    last_completed_period,
    last_vested_period,
    next_period_to_vest,
    schedule,
    schedule_index,
    total_grant,
    vested_amount,
    vesting_contract,
    vesting_fraction,
    vesting_schedule;
  unlock_rewards_($.copy(contract_address), $c);
  vesting_contract = $c.borrow_global_mut<VestingContract>(
    new SimpleStructTag(VestingContract),
    $.copy(contract_address)
  );
  if (
    $.copy(vesting_contract.vesting_schedule.start_timestamp_secs).gt(
      Timestamp.now_seconds_($c)
    )
  ) {
    return;
  } else {
  }
  vesting_schedule = vesting_contract.vesting_schedule;
  last_vested_period = $.copy(vesting_schedule.last_vested_period);
  next_period_to_vest = $.copy(last_vested_period).add(u64("1"));
  last_completed_period = Timestamp.now_seconds_($c)
    .sub($.copy(vesting_schedule.start_timestamp_secs))
    .div($.copy(vesting_schedule.period_duration));
  if ($.copy(last_completed_period).lt($.copy(next_period_to_vest))) {
    return;
  } else {
  }
  schedule = vesting_schedule.schedule;
  schedule_index = $.copy(next_period_to_vest).sub(u64("1"));
  if (
    $.copy(schedule_index).lt(
      Vector.length_(schedule, $c, [
        new StructTag(
          new HexString("0x1"),
          "fixed_point32",
          "FixedPoint32",
          []
        ),
      ])
    )
  ) {
    temp$1 = $.copy(
      Vector.borrow_(schedule, $.copy(schedule_index), $c, [
        new StructTag(
          new HexString("0x1"),
          "fixed_point32",
          "FixedPoint32",
          []
        ),
      ])
    );
  } else {
    temp$1 = $.copy(
      Vector.borrow_(
        schedule,
        Vector.length_(schedule, $c, [
          new StructTag(
            new HexString("0x1"),
            "fixed_point32",
            "FixedPoint32",
            []
          ),
        ]).sub(u64("1")),
        $c,
        [
          new StructTag(
            new HexString("0x1"),
            "fixed_point32",
            "FixedPoint32",
            []
          ),
        ]
      )
    );
  }
  vesting_fraction = temp$1;
  total_grant = Pool_u64.total_coins_(vesting_contract.grant_pool, $c);
  vested_amount = Fixed_point32.multiply_u64_(
    $.copy(total_grant),
    $.copy(vesting_fraction),
    $c
  );
  vested_amount = Math64.min_(
    $.copy(vested_amount),
    $.copy(vesting_contract.remaining_grant),
    $c
  );
  vesting_contract.remaining_grant = $.copy(
    vesting_contract.remaining_grant
  ).sub($.copy(vested_amount));
  vesting_schedule.last_vested_period = $.copy(next_period_to_vest);
  [temp$2, temp$3] = [vesting_contract, $.copy(vested_amount)];
  unlock_stake_(temp$2, temp$3, $c);
  Event.emit_event_(
    vesting_contract.vest_events,
    new VestEvent(
      {
        admin: $.copy(vesting_contract.admin),
        vesting_contract_address: $.copy(contract_address),
        staking_pool_address: $.copy(vesting_contract.staking.pool_address),
        period_vested: $.copy(next_period_to_vest),
        amount: $.copy(vested_amount),
      },
      new SimpleStructTag(VestEvent)
    ),
    $c,
    [new SimpleStructTag(VestEvent)]
  );
  return;
}

export function buildPayload_vest(
  contract_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "vesting",
    "vest",
    typeParamStrings,
    [contract_address],
    isJSON
  );
}
export function vesting_contracts_(
  admin: HexString,
  $c: AptosDataCache
): HexString[] {
  let temp$1;
  if (!$c.exists(new SimpleStructTag(AdminStore), $.copy(admin))) {
    temp$1 = Vector.empty_($c, [AtomicTypeTag.Address]);
  } else {
    temp$1 = $.copy(
      $c.borrow_global<AdminStore>(
        new SimpleStructTag(AdminStore),
        $.copy(admin)
      ).vesting_contracts
    );
  }
  return temp$1;
}

export function vesting_start_secs_(
  vesting_contract_address: HexString,
  $c: AptosDataCache
): U64 {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return $.copy(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ).vesting_schedule.start_timestamp_secs
  );
}

export function voter_(
  vesting_contract_address: HexString,
  $c: AptosDataCache
): HexString {
  assert_vesting_contract_exists_($.copy(vesting_contract_address), $c);
  return $.copy(
    $c.borrow_global<VestingContract>(
      new SimpleStructTag(VestingContract),
      $.copy(vesting_contract_address)
    ).staking.voter
  );
}

export function withdraw_stake_(
  vesting_contract: VestingContract,
  contract_address: HexString,
  $c: AptosDataCache
): Coin.Coin {
  let temp$1, contract_signer, withdrawn_coins;
  Staking_contract.distribute_(
    $.copy(contract_address),
    $.copy(vesting_contract.staking.operator),
    $c
  );
  withdrawn_coins = Coin.balance_($.copy(contract_address), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  temp$1 = get_vesting_account_signer_internal_(vesting_contract, $c);
  contract_signer = temp$1;
  return Coin.withdraw_(contract_signer, $.copy(withdrawn_coins), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::vesting::AdminStore", AdminStore.AdminStoreParser);
  repo.addParser(
    "0x1::vesting::AdminWithdrawEvent",
    AdminWithdrawEvent.AdminWithdrawEventParser
  );
  repo.addParser(
    "0x1::vesting::CreateVestingContractEvent",
    CreateVestingContractEvent.CreateVestingContractEventParser
  );
  repo.addParser(
    "0x1::vesting::DistributeEvent",
    DistributeEvent.DistributeEventParser
  );
  repo.addParser(
    "0x1::vesting::ResetLockupEvent",
    ResetLockupEvent.ResetLockupEventParser
  );
  repo.addParser(
    "0x1::vesting::SetBeneficiaryEvent",
    SetBeneficiaryEvent.SetBeneficiaryEventParser
  );
  repo.addParser("0x1::vesting::StakingInfo", StakingInfo.StakingInfoParser);
  repo.addParser(
    "0x1::vesting::TerminateEvent",
    TerminateEvent.TerminateEventParser
  );
  repo.addParser(
    "0x1::vesting::UnlockRewardsEvent",
    UnlockRewardsEvent.UnlockRewardsEventParser
  );
  repo.addParser(
    "0x1::vesting::UpdateOperatorEvent",
    UpdateOperatorEvent.UpdateOperatorEventParser
  );
  repo.addParser(
    "0x1::vesting::UpdateVoterEvent",
    UpdateVoterEvent.UpdateVoterEventParser
  );
  repo.addParser("0x1::vesting::VestEvent", VestEvent.VestEventParser);
  repo.addParser(
    "0x1::vesting::VestingAccountManagement",
    VestingAccountManagement.VestingAccountManagementParser
  );
  repo.addParser(
    "0x1::vesting::VestingContract",
    VestingContract.VestingContractParser
  );
  repo.addParser(
    "0x1::vesting::VestingSchedule",
    VestingSchedule.VestingScheduleParser
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
  get AdminStore() {
    return AdminStore;
  }
  async loadAdminStore(owner: HexString, loadFull = true, fillCache = true) {
    const val = await AdminStore.load(
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
  get AdminWithdrawEvent() {
    return AdminWithdrawEvent;
  }
  get CreateVestingContractEvent() {
    return CreateVestingContractEvent;
  }
  get DistributeEvent() {
    return DistributeEvent;
  }
  get ResetLockupEvent() {
    return ResetLockupEvent;
  }
  get SetBeneficiaryEvent() {
    return SetBeneficiaryEvent;
  }
  get StakingInfo() {
    return StakingInfo;
  }
  get TerminateEvent() {
    return TerminateEvent;
  }
  get UnlockRewardsEvent() {
    return UnlockRewardsEvent;
  }
  get UpdateOperatorEvent() {
    return UpdateOperatorEvent;
  }
  get UpdateVoterEvent() {
    return UpdateVoterEvent;
  }
  get VestEvent() {
    return VestEvent;
  }
  get VestingAccountManagement() {
    return VestingAccountManagement;
  }
  async loadVestingAccountManagement(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await VestingAccountManagement.load(
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
  get VestingContract() {
    return VestingContract;
  }
  async loadVestingContract(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await VestingContract.load(
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
  get VestingSchedule() {
    return VestingSchedule;
  }
  payload_admin_withdraw(
    contract_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_admin_withdraw(contract_address, isJSON);
  }
  async admin_withdraw(
    _account: AptosAccount,
    contract_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_admin_withdraw(contract_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_distribute(
    contract_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_distribute(contract_address, isJSON);
  }
  async distribute(
    _account: AptosAccount,
    contract_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_distribute(contract_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_reset_beneficiary(
    contract_address: HexString,
    shareholder: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_reset_beneficiary(
      contract_address,
      shareholder,
      isJSON
    );
  }
  async reset_beneficiary(
    _account: AptosAccount,
    contract_address: HexString,
    shareholder: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_reset_beneficiary(
      contract_address,
      shareholder,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_reset_lockup(
    contract_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_reset_lockup(contract_address, isJSON);
  }
  async reset_lockup(
    _account: AptosAccount,
    contract_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_reset_lockup(contract_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_beneficiary(
    contract_address: HexString,
    shareholder: HexString,
    new_beneficiary: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_beneficiary(
      contract_address,
      shareholder,
      new_beneficiary,
      isJSON
    );
  }
  async set_beneficiary(
    _account: AptosAccount,
    contract_address: HexString,
    shareholder: HexString,
    new_beneficiary: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_beneficiary(
      contract_address,
      shareholder,
      new_beneficiary,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_beneficiary_resetter(
    contract_address: HexString,
    beneficiary_resetter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_beneficiary_resetter(
      contract_address,
      beneficiary_resetter,
      isJSON
    );
  }
  async set_beneficiary_resetter(
    _account: AptosAccount,
    contract_address: HexString,
    beneficiary_resetter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_beneficiary_resetter(
      contract_address,
      beneficiary_resetter,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_management_role(
    contract_address: HexString,
    role: String.String,
    role_holder: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_management_role(
      contract_address,
      role,
      role_holder,
      isJSON
    );
  }
  async set_management_role(
    _account: AptosAccount,
    contract_address: HexString,
    role: String.String,
    role_holder: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_management_role(
      contract_address,
      role,
      role_holder,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_terminate_vesting_contract(
    contract_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_terminate_vesting_contract(contract_address, isJSON);
  }
  async terminate_vesting_contract(
    _account: AptosAccount,
    contract_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_terminate_vesting_contract(
      contract_address,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_unlock_rewards(
    contract_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_unlock_rewards(contract_address, isJSON);
  }
  async unlock_rewards(
    _account: AptosAccount,
    contract_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_unlock_rewards(contract_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_update_operator(
    contract_address: HexString,
    new_operator: HexString,
    commission_percentage: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_update_operator(
      contract_address,
      new_operator,
      commission_percentage,
      isJSON
    );
  }
  async update_operator(
    _account: AptosAccount,
    contract_address: HexString,
    new_operator: HexString,
    commission_percentage: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_update_operator(
      contract_address,
      new_operator,
      commission_percentage,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_update_operator_with_same_commission(
    contract_address: HexString,
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_update_operator_with_same_commission(
      contract_address,
      new_operator,
      isJSON
    );
  }
  async update_operator_with_same_commission(
    _account: AptosAccount,
    contract_address: HexString,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_update_operator_with_same_commission(
      contract_address,
      new_operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_update_voter(
    contract_address: HexString,
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_update_voter(contract_address, new_voter, isJSON);
  }
  async update_voter(
    _account: AptosAccount,
    contract_address: HexString,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_update_voter(
      contract_address,
      new_voter,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_vest(
    contract_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_vest(contract_address, isJSON);
  }
  async vest(
    _account: AptosAccount,
    contract_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_vest(contract_address, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
