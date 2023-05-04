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
import * as Bcs from "./bcs";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Event from "./event";
import * as Pool_u64 from "./pool_u64";
import * as Signer from "./signer";
import * as Simple_map from "./simple_map";
import * as Stake from "./stake";
import * as Staking_config from "./staking_config";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "staking_contract";

export const ECANT_MERGE_STAKING_CONTRACTS: U64 = u64("5");
export const EINSUFFICIENT_ACTIVE_STAKE_TO_WITHDRAW: U64 = u64("7");
export const EINSUFFICIENT_STAKE_AMOUNT: U64 = u64("1");
export const EINVALID_COMMISSION_PERCENTAGE: U64 = u64("2");
export const ENOT_STAKER_OR_OPERATOR: U64 = u64("8");
export const ENO_STAKING_CONTRACT_FOUND_FOR_OPERATOR: U64 = u64("4");
export const ENO_STAKING_CONTRACT_FOUND_FOR_STAKER: U64 = u64("3");
export const ESTAKING_CONTRACT_ALREADY_EXISTS: U64 = u64("6");
export const MAXIMUM_PENDING_DISTRIBUTIONS: U64 = u64("20");
export const SALT: U8[] = [
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
  u8("115"),
  u8("116"),
  u8("97"),
  u8("107"),
  u8("105"),
  u8("110"),
  u8("103"),
  u8("95"),
  u8("99"),
  u8("111"),
  u8("110"),
  u8("116"),
  u8("114"),
  u8("97"),
  u8("99"),
  u8("116"),
];

export class AddDistributionEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AddDistributionEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  pool_address: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
    this.amount = proto["amount"] as U64;
  }

  static AddDistributionEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AddDistributionEvent {
    const proto = $.parseStructProto(data, typeTag, repo, AddDistributionEvent);
    return new AddDistributionEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AddDistributionEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class AddStakeEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AddStakeEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  pool_address: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
    this.amount = proto["amount"] as U64;
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

export class CreateStakingContractEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CreateStakingContractEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "voter", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "principal", typeTag: AtomicTypeTag.U64 },
    { name: "commission_percentage", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  voter: HexString;
  pool_address: HexString;
  principal: U64;
  commission_percentage: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.voter = proto["voter"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
    this.principal = proto["principal"] as U64;
    this.commission_percentage = proto["commission_percentage"] as U64;
  }

  static CreateStakingContractEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CreateStakingContractEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      CreateStakingContractEvent
    );
    return new CreateStakingContractEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "CreateStakingContractEvent",
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
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "recipient", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  pool_address: HexString;
  recipient: HexString;
  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
    this.recipient = proto["recipient"] as HexString;
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

export class RequestCommissionEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RequestCommissionEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "accumulated_rewards", typeTag: AtomicTypeTag.U64 },
    { name: "commission_amount", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  pool_address: HexString;
  accumulated_rewards: U64;
  commission_amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
    this.accumulated_rewards = proto["accumulated_rewards"] as U64;
    this.commission_amount = proto["commission_amount"] as U64;
  }

  static RequestCommissionEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RequestCommissionEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      RequestCommissionEvent
    );
    return new RequestCommissionEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "RequestCommissionEvent",
      []
    );
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
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
  ];

  operator: HexString;
  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
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

export class StakingContract {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StakingContract";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "principal", typeTag: AtomicTypeTag.U64 },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    {
      name: "owner_cap",
      typeTag: new StructTag(
        new HexString("0x1"),
        "stake",
        "OwnerCapability",
        []
      ),
    },
    { name: "commission_percentage", typeTag: AtomicTypeTag.U64 },
    {
      name: "distribution_pool",
      typeTag: new StructTag(new HexString("0x1"), "pool_u64", "Pool", []),
    },
    {
      name: "signer_cap",
      typeTag: new StructTag(
        new HexString("0x1"),
        "account",
        "SignerCapability",
        []
      ),
    },
  ];

  principal: U64;
  pool_address: HexString;
  owner_cap: Stake.OwnerCapability;
  commission_percentage: U64;
  distribution_pool: Pool_u64.Pool;
  signer_cap: Account.SignerCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.principal = proto["principal"] as U64;
    this.pool_address = proto["pool_address"] as HexString;
    this.owner_cap = proto["owner_cap"] as Stake.OwnerCapability;
    this.commission_percentage = proto["commission_percentage"] as U64;
    this.distribution_pool = proto["distribution_pool"] as Pool_u64.Pool;
    this.signer_cap = proto["signer_cap"] as Account.SignerCapability;
  }

  static StakingContractParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StakingContract {
    const proto = $.parseStructProto(data, typeTag, repo, StakingContract);
    return new StakingContract(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StakingContract", []);
  }
  async loadFullState(app: $.AppType) {
    await this.owner_cap.loadFullState(app);
    await this.distribution_pool.loadFullState(app);
    await this.signer_cap.loadFullState(app);
    this.__app = app;
  }
}

export class Store {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Store";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "staking_contracts",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        AtomicTypeTag.Address,
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "StakingContract",
          []
        ),
      ]),
    },
    {
      name: "create_staking_contract_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "CreateStakingContractEvent",
          []
        ),
      ]),
    },
    {
      name: "update_voter_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "UpdateVoterEvent",
          []
        ),
      ]),
    },
    {
      name: "reset_lockup_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "ResetLockupEvent",
          []
        ),
      ]),
    },
    {
      name: "add_stake_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "AddStakeEvent",
          []
        ),
      ]),
    },
    {
      name: "request_commission_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "RequestCommissionEvent",
          []
        ),
      ]),
    },
    {
      name: "unlock_stake_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "UnlockStakeEvent",
          []
        ),
      ]),
    },
    {
      name: "switch_operator_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "SwitchOperatorEvent",
          []
        ),
      ]),
    },
    {
      name: "add_distribution_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "AddDistributionEvent",
          []
        ),
      ]),
    },
    {
      name: "distribute_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "staking_contract",
          "DistributeEvent",
          []
        ),
      ]),
    },
  ];

  staking_contracts: Simple_map.SimpleMap;
  create_staking_contract_events: Event.EventHandle;
  update_voter_events: Event.EventHandle;
  reset_lockup_events: Event.EventHandle;
  add_stake_events: Event.EventHandle;
  request_commission_events: Event.EventHandle;
  unlock_stake_events: Event.EventHandle;
  switch_operator_events: Event.EventHandle;
  add_distribution_events: Event.EventHandle;
  distribute_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.staking_contracts = proto["staking_contracts"] as Simple_map.SimpleMap;
    this.create_staking_contract_events = proto[
      "create_staking_contract_events"
    ] as Event.EventHandle;
    this.update_voter_events = proto[
      "update_voter_events"
    ] as Event.EventHandle;
    this.reset_lockup_events = proto[
      "reset_lockup_events"
    ] as Event.EventHandle;
    this.add_stake_events = proto["add_stake_events"] as Event.EventHandle;
    this.request_commission_events = proto[
      "request_commission_events"
    ] as Event.EventHandle;
    this.unlock_stake_events = proto[
      "unlock_stake_events"
    ] as Event.EventHandle;
    this.switch_operator_events = proto[
      "switch_operator_events"
    ] as Event.EventHandle;
    this.add_distribution_events = proto[
      "add_distribution_events"
    ] as Event.EventHandle;
    this.distribute_events = proto["distribute_events"] as Event.EventHandle;
  }

  static StoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Store {
    const proto = $.parseStructProto(data, typeTag, repo, Store);
    return new Store(proto, typeTag);
  }

  static async load(
    repo: AptosParserRepo,
    client: AptosClient,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await repo.loadResource(client, address, Store, typeParams);
    return result as unknown as Store;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Store,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Store;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Store", []);
  }
  async loadFullState(app: $.AppType) {
    await this.staking_contracts.loadFullState(app);
    await this.create_staking_contract_events.loadFullState(app);
    await this.update_voter_events.loadFullState(app);
    await this.reset_lockup_events.loadFullState(app);
    await this.add_stake_events.loadFullState(app);
    await this.request_commission_events.loadFullState(app);
    await this.unlock_stake_events.loadFullState(app);
    await this.switch_operator_events.loadFullState(app);
    await this.add_distribution_events.loadFullState(app);
    await this.distribute_events.loadFullState(app);
    this.__app = app;
  }
}

export class SwitchOperatorEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SwitchOperatorEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "old_operator", typeTag: AtomicTypeTag.Address },
    { name: "new_operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
  ];

  old_operator: HexString;
  new_operator: HexString;
  pool_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.old_operator = proto["old_operator"] as HexString;
    this.new_operator = proto["new_operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
  }

  static SwitchOperatorEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SwitchOperatorEvent {
    const proto = $.parseStructProto(data, typeTag, repo, SwitchOperatorEvent);
    return new SwitchOperatorEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SwitchOperatorEvent", []);
  }
  async loadFullState(app: $.AppType) {
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
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "amount", typeTag: AtomicTypeTag.U64 },
    { name: "commission_paid", typeTag: AtomicTypeTag.U64 },
  ];

  operator: HexString;
  pool_address: HexString;
  amount: U64;
  commission_paid: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
    this.amount = proto["amount"] as U64;
    this.commission_paid = proto["commission_paid"] as U64;
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

export class UpdateVoterEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UpdateVoterEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "operator", typeTag: AtomicTypeTag.Address },
    { name: "pool_address", typeTag: AtomicTypeTag.Address },
    { name: "old_voter", typeTag: AtomicTypeTag.Address },
    { name: "new_voter", typeTag: AtomicTypeTag.Address },
  ];

  operator: HexString;
  pool_address: HexString;
  old_voter: HexString;
  new_voter: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.operator = proto["operator"] as HexString;
    this.pool_address = proto["pool_address"] as HexString;
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
export function add_distribution_(
  operator: HexString,
  staking_contract: StakingContract,
  recipient: HexString,
  coins_amount: U64,
  add_distribution_events: Event.EventHandle,
  $c: AptosDataCache
): void {
  let distribution_pool, pool_address, total_distribution_amount;
  distribution_pool = staking_contract.distribution_pool;
  [, , , total_distribution_amount] = Stake.get_stake_(
    $.copy(staking_contract.pool_address),
    $c
  );
  update_distribution_pool_(
    distribution_pool,
    $.copy(total_distribution_amount),
    $.copy(operator),
    $.copy(staking_contract.commission_percentage),
    $c
  );
  Pool_u64.buy_in_(
    distribution_pool,
    $.copy(recipient),
    $.copy(coins_amount),
    $c
  );
  pool_address = $.copy(staking_contract.pool_address);
  Event.emit_event_(
    add_distribution_events,
    new AddDistributionEvent(
      {
        operator: $.copy(operator),
        pool_address: $.copy(pool_address),
        amount: $.copy(coins_amount),
      },
      new SimpleStructTag(AddDistributionEvent)
    ),
    $c,
    [new SimpleStructTag(AddDistributionEvent)]
  );
  return;
}

export function add_stake_(
  staker: HexString,
  operator: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  let pool_address, staked_coins, staker_address, staking_contract, store;
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_($.copy(staker_address), $.copy(operator), $c);
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker_address)
  );
  staking_contract = Simple_map.borrow_mut_(
    store.staking_contracts,
    operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  staked_coins = Coin.withdraw_(staker, $.copy(amount), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  Stake.add_stake_with_cap_(staking_contract.owner_cap, staked_coins, $c);
  staking_contract.principal = $.copy(staking_contract.principal).add(
    $.copy(amount)
  );
  pool_address = $.copy(staking_contract.pool_address);
  Event.emit_event_(
    store.add_stake_events,
    new AddStakeEvent(
      {
        operator: $.copy(operator),
        pool_address: $.copy(pool_address),
        amount: $.copy(amount),
      },
      new SimpleStructTag(AddStakeEvent)
    ),
    $c,
    [new SimpleStructTag(AddStakeEvent)]
  );
  return;
}

export function buildPayload_add_stake(
  operator: HexString,
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "add_stake",
    typeParamStrings,
    [operator, amount],
    isJSON
  );
}
export function assert_staking_contract_exists_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, staking_contracts;
  if (!$c.exists(new SimpleStructTag(Store), $.copy(staker))) {
    throw $.abortCode(
      Error.not_found_($.copy(ENO_STAKING_CONTRACT_FOUND_FOR_STAKER), $c)
    );
  }
  staking_contracts = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  ).staking_contracts;
  [temp$1, temp$2] = [staking_contracts, operator];
  if (
    !Simple_map.contains_key_(temp$1, temp$2, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ])
  ) {
    throw $.abortCode(
      Error.not_found_($.copy(ENO_STAKING_CONTRACT_FOUND_FOR_OPERATOR), $c)
    );
  }
  return;
}

export function commission_percentage_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): U64 {
  let staking_contracts;
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  staking_contracts = $c.borrow_global<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  ).staking_contracts;
  return $.copy(
    Simple_map.borrow_(staking_contracts, operator, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ]).commission_percentage
  );
}

export function create_stake_pool_(
  staker: HexString,
  operator: HexString,
  voter: HexString,
  contract_creation_seed: U8[],
  $c: AptosDataCache
): [HexString, Account.SignerCapability, Stake.OwnerCapability] {
  let temp$1, owner_cap, seed, stake_pool_signer, stake_pool_signer_cap;
  temp$1 = Signer.address_of_(staker, $c);
  seed = Bcs.to_bytes_(temp$1, $c, [AtomicTypeTag.Address]);
  Vector.append_(
    seed,
    Bcs.to_bytes_(operator, $c, [AtomicTypeTag.Address]),
    $c,
    [AtomicTypeTag.U8]
  );
  Vector.append_(seed, $.copy(SALT), $c, [AtomicTypeTag.U8]);
  Vector.append_(seed, $.copy(contract_creation_seed), $c, [AtomicTypeTag.U8]);
  [stake_pool_signer, stake_pool_signer_cap] = Account.create_resource_account_(
    staker,
    $.copy(seed),
    $c
  );
  Stake.initialize_stake_owner_(
    stake_pool_signer,
    u64("0"),
    $.copy(operator),
    $.copy(voter),
    $c
  );
  owner_cap = Stake.extract_owner_cap_(stake_pool_signer, $c);
  return [stake_pool_signer, stake_pool_signer_cap, owner_cap];
}

export function create_staking_contract_(
  staker: HexString,
  operator: HexString,
  voter: HexString,
  amount: U64,
  commission_percentage: U64,
  contract_creation_seed: U8[],
  $c: AptosDataCache
): void {
  let staked_coins;
  staked_coins = Coin.withdraw_(staker, $.copy(amount), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  create_staking_contract_with_coins_(
    staker,
    $.copy(operator),
    $.copy(voter),
    staked_coins,
    $.copy(commission_percentage),
    $.copy(contract_creation_seed),
    $c
  );
  return;
}

export function buildPayload_create_staking_contract(
  operator: HexString,
  voter: HexString,
  amount: U64,
  commission_percentage: U64,
  contract_creation_seed: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "create_staking_contract",
    typeParamStrings,
    [operator, voter, amount, commission_percentage, contract_creation_seed],
    isJSON
  );
}
export function create_staking_contract_with_coins_(
  staker: HexString,
  operator: HexString,
  voter: HexString,
  coins: Coin.Coin,
  commission_percentage: U64,
  contract_creation_seed: U8[],
  $c: AptosDataCache
): HexString {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    min_stake_required,
    owner_cap,
    pool_address,
    principal,
    stake_pool_signer,
    stake_pool_signer_cap,
    staker_address,
    staking_contracts,
    store;
  if ($.copy(commission_percentage).ge(u64("0"))) {
    temp$1 = $.copy(commission_percentage).le(u64("100"));
  } else {
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_COMMISSION_PERCENTAGE), $c)
    );
  }
  temp$2 = Staking_config.get_($c);
  [min_stake_required] = Staking_config.get_required_stake_(temp$2, $c);
  principal = Coin.value_(coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  if (!$.copy(principal).ge($.copy(min_stake_required))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_STAKE_AMOUNT), $c)
    );
  }
  staker_address = Signer.address_of_(staker, $c);
  if (!$c.exists(new SimpleStructTag(Store), $.copy(staker_address))) {
    $c.move_to(
      new SimpleStructTag(Store),
      staker,
      new_staking_contracts_holder_(staker, $c)
    );
  } else {
  }
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker_address)
  );
  staking_contracts = store.staking_contracts;
  [temp$3, temp$4] = [staking_contracts, operator];
  if (
    Simple_map.contains_key_(temp$3, temp$4, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ])
  ) {
    throw $.abortCode(
      Error.already_exists_($.copy(ESTAKING_CONTRACT_ALREADY_EXISTS), $c)
    );
  }
  [stake_pool_signer, stake_pool_signer_cap, owner_cap] = create_stake_pool_(
    staker,
    $.copy(operator),
    $.copy(voter),
    $.copy(contract_creation_seed),
    $c
  );
  Stake.add_stake_with_cap_(owner_cap, coins, $c);
  pool_address = Signer.address_of_(stake_pool_signer, $c);
  Simple_map.add_(
    staking_contracts,
    $.copy(operator),
    new StakingContract(
      {
        principal: $.copy(principal),
        pool_address: $.copy(pool_address),
        owner_cap: owner_cap,
        commission_percentage: $.copy(commission_percentage),
        distribution_pool: Pool_u64.create_(
          $.copy(MAXIMUM_PENDING_DISTRIBUTIONS),
          $c
        ),
        signer_cap: stake_pool_signer_cap,
      },
      new SimpleStructTag(StakingContract)
    ),
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  Event.emit_event_(
    store.create_staking_contract_events,
    new CreateStakingContractEvent(
      {
        operator: $.copy(operator),
        voter: $.copy(voter),
        pool_address: $.copy(pool_address),
        principal: $.copy(principal),
        commission_percentage: $.copy(commission_percentage),
      },
      new SimpleStructTag(CreateStakingContractEvent)
    ),
    $c,
    [new SimpleStructTag(CreateStakingContractEvent)]
  );
  return $.copy(pool_address);
}

export function distribute_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): void {
  let staking_contract, store;
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  );
  staking_contract = Simple_map.borrow_mut_(
    store.staking_contracts,
    operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  distribute_internal_(
    $.copy(staker),
    $.copy(operator),
    staking_contract,
    store.distribute_events,
    $c
  );
  return;
}

export function buildPayload_distribute(
  staker: HexString,
  operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "distribute",
    typeParamStrings,
    [staker, operator],
    isJSON
  );
}
export function distribute_internal_(
  staker: HexString,
  operator: HexString,
  staking_contract: StakingContract,
  distribute_events: Event.EventHandle,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    amount_to_distribute,
    coins,
    current_shares,
    distribution_amount,
    distribution_pool,
    inactive,
    pending_inactive,
    pool_address,
    recipient,
    recipients,
    total_potential_withdrawable;
  pool_address = $.copy(staking_contract.pool_address);
  [, inactive, , pending_inactive] = Stake.get_stake_($.copy(pool_address), $c);
  total_potential_withdrawable = $.copy(inactive).add($.copy(pending_inactive));
  coins = Stake.withdraw_with_cap_(
    staking_contract.owner_cap,
    $.copy(total_potential_withdrawable),
    $c
  );
  distribution_amount = Coin.value_(coins, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  if ($.copy(distribution_amount).eq(u64("0"))) {
    Coin.destroy_zero_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
    return;
  } else {
  }
  distribution_pool = staking_contract.distribution_pool;
  update_distribution_pool_(
    distribution_pool,
    $.copy(distribution_amount),
    $.copy(operator),
    $.copy(staking_contract.commission_percentage),
    $c
  );
  while (Pool_u64.shareholders_count_(distribution_pool, $c).gt(u64("0"))) {
    {
      recipients = Pool_u64.shareholders_(distribution_pool, $c);
      [temp$1, temp$2] = [recipients, u64("0")];
      recipient = $.copy(
        Vector.borrow_(temp$1, temp$2, $c, [AtomicTypeTag.Address])
      );
      [temp$3, temp$4] = [distribution_pool, $.copy(recipient)];
      current_shares = Pool_u64.shares_(temp$3, temp$4, $c);
      amount_to_distribute = Pool_u64.redeem_shares_(
        distribution_pool,
        $.copy(recipient),
        $.copy(current_shares),
        $c
      );
      Coin.deposit_(
        $.copy(recipient),
        Coin.extract_(coins, $.copy(amount_to_distribute), $c, [
          new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
        ]),
        $c,
        [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
      );
      Event.emit_event_(
        distribute_events,
        new DistributeEvent(
          {
            operator: $.copy(operator),
            pool_address: $.copy(pool_address),
            recipient: $.copy(recipient),
            amount: $.copy(amount_to_distribute),
          },
          new SimpleStructTag(DistributeEvent)
        ),
        $c,
        [new SimpleStructTag(DistributeEvent)]
      );
    }
  }
  if (
    Coin.value_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]).gt(u64("0"))
  ) {
    Coin.deposit_($.copy(staker), coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
    Pool_u64.update_total_coins_(distribution_pool, u64("0"), $c);
  } else {
    Coin.destroy_zero_(coins, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
  }
  return;
}

export function get_staking_contract_amounts_internal_(
  staking_contract: StakingContract,
  $c: AptosDataCache
): [U64, U64, U64] {
  let accumulated_rewards,
    active,
    commission_amount,
    pending_active,
    total_active_stake;
  [active, , pending_active] = Stake.get_stake_(
    $.copy(staking_contract.pool_address),
    $c
  );
  total_active_stake = $.copy(active).add($.copy(pending_active));
  accumulated_rewards = $.copy(total_active_stake).sub(
    $.copy(staking_contract.principal)
  );
  commission_amount = $.copy(accumulated_rewards)
    .mul($.copy(staking_contract.commission_percentage))
    .div(u64("100"));
  return [
    $.copy(total_active_stake),
    $.copy(accumulated_rewards),
    $.copy(commission_amount),
  ];
}

export function last_recorded_principal_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): U64 {
  let staking_contracts;
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  staking_contracts = $c.borrow_global<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  ).staking_contracts;
  return $.copy(
    Simple_map.borrow_(staking_contracts, operator, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ]).principal
  );
}

export function new_staking_contracts_holder_(
  staker: HexString,
  $c: AptosDataCache
): Store {
  return new Store(
    {
      staking_contracts: Simple_map.create_($c, [
        AtomicTypeTag.Address,
        new SimpleStructTag(StakingContract),
      ]),
      create_staking_contract_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(CreateStakingContractEvent),
      ]),
      update_voter_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(UpdateVoterEvent),
      ]),
      reset_lockup_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(ResetLockupEvent),
      ]),
      add_stake_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(AddStakeEvent),
      ]),
      request_commission_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(RequestCommissionEvent),
      ]),
      unlock_stake_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(UnlockStakeEvent),
      ]),
      switch_operator_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(SwitchOperatorEvent),
      ]),
      add_distribution_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(AddDistributionEvent),
      ]),
      distribute_events: Account.new_event_handle_(staker, $c, [
        new SimpleStructTag(DistributeEvent),
      ]),
    },
    new SimpleStructTag(Store)
  );
}

export function pending_distribution_counts_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): U64 {
  let staking_contracts;
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  staking_contracts = $c.borrow_global<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  ).staking_contracts;
  return Pool_u64.shareholders_count_(
    Simple_map.borrow_(staking_contracts, operator, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ]).distribution_pool,
    $c
  );
}

export function request_commission_(
  account: HexString,
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): void {
  let temp$1, account_addr, staking_contract, store;
  account_addr = Signer.address_of_(account, $c);
  if ($.copy(account_addr).hex() === $.copy(staker).hex()) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(account_addr).hex() === $.copy(operator).hex();
  }
  if (!temp$1) {
    throw $.abortCode(
      Error.unauthenticated_($.copy(ENOT_STAKER_OR_OPERATOR), $c)
    );
  }
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  );
  staking_contract = Simple_map.borrow_mut_(
    store.staking_contracts,
    operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  if ($.copy(staking_contract.commission_percentage).eq(u64("0"))) {
    return;
  } else {
  }
  distribute_internal_(
    $.copy(staker),
    $.copy(operator),
    staking_contract,
    store.distribute_events,
    $c
  );
  request_commission_internal_(
    $.copy(operator),
    staking_contract,
    store.add_distribution_events,
    store.request_commission_events,
    $c
  );
  return;
}

export function buildPayload_request_commission(
  staker: HexString,
  operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "request_commission",
    typeParamStrings,
    [staker, operator],
    isJSON
  );
}
export function request_commission_internal_(
  operator: HexString,
  staking_contract: StakingContract,
  add_distribution_events: Event.EventHandle,
  request_commission_events: Event.EventHandle,
  $c: AptosDataCache
): U64 {
  let accumulated_rewards, commission_amount, pool_address, total_active_stake;
  [total_active_stake, accumulated_rewards, commission_amount] =
    get_staking_contract_amounts_internal_(staking_contract, $c);
  staking_contract.principal = $.copy(total_active_stake).sub(
    $.copy(commission_amount)
  );
  if ($.copy(commission_amount).eq(u64("0"))) {
    return u64("0");
  } else {
  }
  add_distribution_(
    $.copy(operator),
    staking_contract,
    $.copy(operator),
    $.copy(commission_amount),
    add_distribution_events,
    $c
  );
  Stake.unlock_with_cap_(
    $.copy(commission_amount),
    staking_contract.owner_cap,
    $c
  );
  pool_address = $.copy(staking_contract.pool_address);
  Event.emit_event_(
    request_commission_events,
    new RequestCommissionEvent(
      {
        operator: $.copy(operator),
        pool_address: $.copy(pool_address),
        accumulated_rewards: $.copy(accumulated_rewards),
        commission_amount: $.copy(commission_amount),
      },
      new SimpleStructTag(RequestCommissionEvent)
    ),
    $c,
    [new SimpleStructTag(RequestCommissionEvent)]
  );
  return $.copy(commission_amount);
}

export function reset_lockup_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): void {
  let pool_address, staker_address, staking_contract, store;
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_($.copy(staker_address), $.copy(operator), $c);
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker_address)
  );
  staking_contract = Simple_map.borrow_mut_(
    store.staking_contracts,
    operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  pool_address = $.copy(staking_contract.pool_address);
  Stake.increase_lockup_with_cap_(staking_contract.owner_cap, $c);
  Event.emit_event_(
    store.reset_lockup_events,
    new ResetLockupEvent(
      { operator: $.copy(operator), pool_address: $.copy(pool_address) },
      new SimpleStructTag(ResetLockupEvent)
    ),
    $c,
    [new SimpleStructTag(ResetLockupEvent)]
  );
  return;
}

export function buildPayload_reset_lockup(
  operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "reset_lockup",
    typeParamStrings,
    [operator],
    isJSON
  );
}
export function stake_pool_address_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): HexString {
  let staking_contracts;
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  staking_contracts = $c.borrow_global<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  ).staking_contracts;
  return $.copy(
    Simple_map.borrow_(staking_contracts, operator, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ]).pool_address
  );
}

export function staking_contract_amounts_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): [U64, U64, U64] {
  let staking_contract, staking_contracts;
  assert_staking_contract_exists_($.copy(staker), $.copy(operator), $c);
  staking_contracts = $c.borrow_global<Store>(
    new SimpleStructTag(Store),
    $.copy(staker)
  ).staking_contracts;
  staking_contract = Simple_map.borrow_(staking_contracts, operator, $c, [
    AtomicTypeTag.Address,
    new SimpleStructTag(StakingContract),
  ]);
  return get_staking_contract_amounts_internal_(staking_contract, $c);
}

export function staking_contract_exists_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): boolean {
  let store;
  if (!$c.exists(new SimpleStructTag(Store), $.copy(staker))) {
    return false;
  } else {
  }
  store = $c.borrow_global<Store>(new SimpleStructTag(Store), $.copy(staker));
  return Simple_map.contains_key_(store.staking_contracts, operator, $c, [
    AtomicTypeTag.Address,
    new SimpleStructTag(StakingContract),
  ]);
}

export function switch_operator_(
  staker: HexString,
  old_operator: HexString,
  new_operator: HexString,
  new_commission_percentage: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    pool_address,
    staker_address,
    staking_contract,
    staking_contracts,
    store;
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_(
    $.copy(staker_address),
    $.copy(old_operator),
    $c
  );
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker_address)
  );
  staking_contracts = store.staking_contracts;
  [temp$1, temp$2] = [staking_contracts, new_operator];
  if (
    Simple_map.contains_key_(temp$1, temp$2, $c, [
      AtomicTypeTag.Address,
      new SimpleStructTag(StakingContract),
    ])
  ) {
    throw $.abortCode(
      Error.invalid_state_($.copy(ECANT_MERGE_STAKING_CONTRACTS), $c)
    );
  }
  [, staking_contract] = Simple_map.remove_(
    staking_contracts,
    old_operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  distribute_internal_(
    $.copy(staker_address),
    $.copy(old_operator),
    staking_contract,
    store.distribute_events,
    $c
  );
  request_commission_internal_(
    $.copy(old_operator),
    staking_contract,
    store.add_distribution_events,
    store.request_commission_events,
    $c
  );
  Stake.set_operator_with_cap_(
    staking_contract.owner_cap,
    $.copy(new_operator),
    $c
  );
  staking_contract.commission_percentage = $.copy(new_commission_percentage);
  pool_address = $.copy(staking_contract.pool_address);
  Simple_map.add_(
    staking_contracts,
    $.copy(new_operator),
    staking_contract,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  temp$6 = store.switch_operator_events;
  temp$3 = $.copy(pool_address);
  temp$4 = $.copy(old_operator);
  temp$5 = $.copy(new_operator);
  Event.emit_event_(
    temp$6,
    new SwitchOperatorEvent(
      { old_operator: temp$4, new_operator: temp$5, pool_address: temp$3 },
      new SimpleStructTag(SwitchOperatorEvent)
    ),
    $c,
    [new SimpleStructTag(SwitchOperatorEvent)]
  );
  return;
}

export function buildPayload_switch_operator(
  old_operator: HexString,
  new_operator: HexString,
  new_commission_percentage: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "switch_operator",
    typeParamStrings,
    [old_operator, new_operator, new_commission_percentage],
    isJSON
  );
}
export function switch_operator_with_same_commission_(
  staker: HexString,
  old_operator: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let commission_percentage, staker_address;
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_(
    $.copy(staker_address),
    $.copy(old_operator),
    $c
  );
  commission_percentage = commission_percentage_(
    $.copy(staker_address),
    $.copy(old_operator),
    $c
  );
  switch_operator_(
    staker,
    $.copy(old_operator),
    $.copy(new_operator),
    $.copy(commission_percentage),
    $c
  );
  return;
}

export function buildPayload_switch_operator_with_same_commission(
  old_operator: HexString,
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "switch_operator_with_same_commission",
    typeParamStrings,
    [old_operator, new_operator],
    isJSON
  );
}
export function unlock_rewards_(
  staker: HexString,
  operator: HexString,
  $c: AptosDataCache
): void {
  let accumulated_rewards, staker_address, staker_rewards, unpaid_commission;
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_($.copy(staker_address), $.copy(operator), $c);
  [, accumulated_rewards, unpaid_commission] = staking_contract_amounts_(
    $.copy(staker_address),
    $.copy(operator),
    $c
  );
  staker_rewards = $.copy(accumulated_rewards).sub($.copy(unpaid_commission));
  unlock_stake_(staker, $.copy(operator), $.copy(staker_rewards), $c);
  return;
}

export function buildPayload_unlock_rewards(
  operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "unlock_rewards",
    typeParamStrings,
    [operator],
    isJSON
  );
}
export function unlock_stake_(
  staker: HexString,
  operator: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    active,
    commission_paid,
    pool_address,
    staker_address,
    staking_contract,
    store;
  if ($.copy(amount).eq(u64("0"))) {
    return;
  } else {
  }
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_($.copy(staker_address), $.copy(operator), $c);
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker_address)
  );
  staking_contract = Simple_map.borrow_mut_(
    store.staking_contracts,
    operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  distribute_internal_(
    $.copy(staker_address),
    $.copy(operator),
    staking_contract,
    store.distribute_events,
    $c
  );
  commission_paid = request_commission_internal_(
    $.copy(operator),
    staking_contract,
    store.add_distribution_events,
    store.request_commission_events,
    $c
  );
  [active, , ,] = Stake.get_stake_($.copy(staking_contract.pool_address), $c);
  if ($.copy(active).lt($.copy(amount))) {
    amount = $.copy(active);
  } else {
  }
  staking_contract.principal = $.copy(staking_contract.principal).sub(
    $.copy(amount)
  );
  add_distribution_(
    $.copy(operator),
    staking_contract,
    $.copy(staker_address),
    $.copy(amount),
    store.add_distribution_events,
    $c
  );
  Stake.unlock_with_cap_($.copy(amount), staking_contract.owner_cap, $c);
  pool_address = $.copy(staking_contract.pool_address);
  temp$5 = store.unlock_stake_events;
  temp$1 = $.copy(pool_address);
  temp$2 = $.copy(operator);
  temp$3 = $.copy(amount);
  temp$4 = $.copy(commission_paid);
  Event.emit_event_(
    temp$5,
    new UnlockStakeEvent(
      {
        operator: temp$2,
        pool_address: temp$1,
        amount: temp$3,
        commission_paid: temp$4,
      },
      new SimpleStructTag(UnlockStakeEvent)
    ),
    $c,
    [new SimpleStructTag(UnlockStakeEvent)]
  );
  return;
}

export function buildPayload_unlock_stake(
  operator: HexString,
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "unlock_stake",
    typeParamStrings,
    [operator, amount],
    isJSON
  );
}
export function update_distribution_pool_(
  distribution_pool: Pool_u64.Pool,
  updated_total_coins: U64,
  operator: HexString,
  commission_percentage: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$10,
    temp$11,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    current_worth,
    i,
    len,
    previous_worth,
    shareholder,
    shareholders,
    shares,
    shares_to_transfer,
    unpaid_commission;
  if (
    Pool_u64.total_coins_(distribution_pool, $c).eq($.copy(updated_total_coins))
  ) {
    return;
  } else {
  }
  temp$1 = Pool_u64.shareholders_(distribution_pool, $c);
  shareholders = temp$1;
  len = Vector.length_(shareholders, $c, [AtomicTypeTag.Address]);
  i = u64("0");
  while ($.copy(i).lt($.copy(len))) {
    {
      shareholder = $.copy(
        Vector.borrow_(shareholders, $.copy(i), $c, [AtomicTypeTag.Address])
      );
      if ($.copy(shareholder).hex() !== $.copy(operator).hex()) {
        [temp$2, temp$3] = [distribution_pool, $.copy(shareholder)];
        shares = Pool_u64.shares_(temp$2, temp$3, $c);
        [temp$4, temp$5] = [distribution_pool, $.copy(shareholder)];
        previous_worth = Pool_u64.balance_(temp$4, temp$5, $c);
        [temp$6, temp$7, temp$8] = [
          distribution_pool,
          $.copy(shares),
          $.copy(updated_total_coins),
        ];
        current_worth = Pool_u64.shares_to_amount_with_total_coins_(
          temp$6,
          temp$7,
          temp$8,
          $c
        );
        unpaid_commission = $.copy(current_worth)
          .sub($.copy(previous_worth))
          .mul($.copy(commission_percentage))
          .div(u64("100"));
        [temp$9, temp$10, temp$11] = [
          distribution_pool,
          $.copy(unpaid_commission),
          $.copy(updated_total_coins),
        ];
        shares_to_transfer = Pool_u64.amount_to_shares_with_total_coins_(
          temp$9,
          temp$10,
          temp$11,
          $c
        );
        Pool_u64.transfer_shares_(
          distribution_pool,
          $.copy(shareholder),
          $.copy(operator),
          $.copy(shares_to_transfer),
          $c
        );
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  Pool_u64.update_total_coins_(
    distribution_pool,
    $.copy(updated_total_coins),
    $c
  );
  return;
}

export function update_voter_(
  staker: HexString,
  operator: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  let old_voter, pool_address, staker_address, staking_contract, store;
  staker_address = Signer.address_of_(staker, $c);
  assert_staking_contract_exists_($.copy(staker_address), $.copy(operator), $c);
  store = $c.borrow_global_mut<Store>(
    new SimpleStructTag(Store),
    $.copy(staker_address)
  );
  staking_contract = Simple_map.borrow_mut_(
    store.staking_contracts,
    operator,
    $c,
    [AtomicTypeTag.Address, new SimpleStructTag(StakingContract)]
  );
  pool_address = $.copy(staking_contract.pool_address);
  old_voter = Stake.get_delegated_voter_($.copy(pool_address), $c);
  Stake.set_delegated_voter_with_cap_(
    staking_contract.owner_cap,
    $.copy(new_voter),
    $c
  );
  Event.emit_event_(
    store.update_voter_events,
    new UpdateVoterEvent(
      {
        operator: $.copy(operator),
        pool_address: $.copy(pool_address),
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
  operator: HexString,
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_contract",
    "update_voter",
    typeParamStrings,
    [operator, new_voter],
    isJSON
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::staking_contract::AddDistributionEvent",
    AddDistributionEvent.AddDistributionEventParser
  );
  repo.addParser(
    "0x1::staking_contract::AddStakeEvent",
    AddStakeEvent.AddStakeEventParser
  );
  repo.addParser(
    "0x1::staking_contract::CreateStakingContractEvent",
    CreateStakingContractEvent.CreateStakingContractEventParser
  );
  repo.addParser(
    "0x1::staking_contract::DistributeEvent",
    DistributeEvent.DistributeEventParser
  );
  repo.addParser(
    "0x1::staking_contract::RequestCommissionEvent",
    RequestCommissionEvent.RequestCommissionEventParser
  );
  repo.addParser(
    "0x1::staking_contract::ResetLockupEvent",
    ResetLockupEvent.ResetLockupEventParser
  );
  repo.addParser(
    "0x1::staking_contract::StakingContract",
    StakingContract.StakingContractParser
  );
  repo.addParser("0x1::staking_contract::Store", Store.StoreParser);
  repo.addParser(
    "0x1::staking_contract::SwitchOperatorEvent",
    SwitchOperatorEvent.SwitchOperatorEventParser
  );
  repo.addParser(
    "0x1::staking_contract::UnlockStakeEvent",
    UnlockStakeEvent.UnlockStakeEventParser
  );
  repo.addParser(
    "0x1::staking_contract::UpdateVoterEvent",
    UpdateVoterEvent.UpdateVoterEventParser
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
  get AddDistributionEvent() {
    return AddDistributionEvent;
  }
  get AddStakeEvent() {
    return AddStakeEvent;
  }
  get CreateStakingContractEvent() {
    return CreateStakingContractEvent;
  }
  get DistributeEvent() {
    return DistributeEvent;
  }
  get RequestCommissionEvent() {
    return RequestCommissionEvent;
  }
  get ResetLockupEvent() {
    return ResetLockupEvent;
  }
  get StakingContract() {
    return StakingContract;
  }
  get Store() {
    return Store;
  }
  async loadStore(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Store.load(
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
  get SwitchOperatorEvent() {
    return SwitchOperatorEvent;
  }
  get UnlockStakeEvent() {
    return UnlockStakeEvent;
  }
  get UpdateVoterEvent() {
    return UpdateVoterEvent;
  }
  payload_add_stake(
    operator: HexString,
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_add_stake(operator, amount, isJSON);
  }
  async add_stake(
    _account: AptosAccount,
    operator: HexString,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_add_stake(operator, amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_create_staking_contract(
    operator: HexString,
    voter: HexString,
    amount: U64,
    commission_percentage: U64,
    contract_creation_seed: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_create_staking_contract(
      operator,
      voter,
      amount,
      commission_percentage,
      contract_creation_seed,
      isJSON
    );
  }
  async create_staking_contract(
    _account: AptosAccount,
    operator: HexString,
    voter: HexString,
    amount: U64,
    commission_percentage: U64,
    contract_creation_seed: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_create_staking_contract(
      operator,
      voter,
      amount,
      commission_percentage,
      contract_creation_seed,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_distribute(
    staker: HexString,
    operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_distribute(staker, operator, isJSON);
  }
  async distribute(
    _account: AptosAccount,
    staker: HexString,
    operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_distribute(staker, operator, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_request_commission(
    staker: HexString,
    operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_request_commission(staker, operator, isJSON);
  }
  async request_commission(
    _account: AptosAccount,
    staker: HexString,
    operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_request_commission(
      staker,
      operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_reset_lockup(
    operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_reset_lockup(operator, isJSON);
  }
  async reset_lockup(
    _account: AptosAccount,
    operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_reset_lockup(operator, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_switch_operator(
    old_operator: HexString,
    new_operator: HexString,
    new_commission_percentage: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_switch_operator(
      old_operator,
      new_operator,
      new_commission_percentage,
      isJSON
    );
  }
  async switch_operator(
    _account: AptosAccount,
    old_operator: HexString,
    new_operator: HexString,
    new_commission_percentage: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_switch_operator(
      old_operator,
      new_operator,
      new_commission_percentage,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_switch_operator_with_same_commission(
    old_operator: HexString,
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_switch_operator_with_same_commission(
      old_operator,
      new_operator,
      isJSON
    );
  }
  async switch_operator_with_same_commission(
    _account: AptosAccount,
    old_operator: HexString,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_switch_operator_with_same_commission(
      old_operator,
      new_operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_unlock_rewards(
    operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_unlock_rewards(operator, isJSON);
  }
  async unlock_rewards(
    _account: AptosAccount,
    operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_unlock_rewards(operator, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_unlock_stake(
    operator: HexString,
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_unlock_stake(operator, amount, isJSON);
  }
  async unlock_stake(
    _account: AptosAccount,
    operator: HexString,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_unlock_stake(operator, amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_update_voter(
    operator: HexString,
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_update_voter(operator, new_voter, isJSON);
  }
  async update_voter(
    _account: AptosAccount,
    operator: HexString,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_update_voter(operator, new_voter, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
