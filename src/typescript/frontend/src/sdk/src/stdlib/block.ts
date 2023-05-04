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
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";

import * as Account from "./account";
import * as Error from "./error";
import * as Event from "./event";
import * as Option from "./option";
import * as Reconfiguration from "./reconfiguration";
import * as Stake from "./stake";
import * as State_storage from "./state_storage";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "block";

export const EINVALID_PROPOSER: U64 = u64("2");
export const ENUM_NEW_BLOCK_EVENTS_DOES_NOT_MATCH_BLOCK_HEIGHT: U64 = u64("1");
export const EZERO_EPOCH_INTERVAL: U64 = u64("3");
export const MAX_U64: U64 = u64("18446744073709551615");

export class BlockResource {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "BlockResource";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "height", typeTag: AtomicTypeTag.U64 },
    { name: "epoch_interval", typeTag: AtomicTypeTag.U64 },
    {
      name: "new_block_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "block", "NewBlockEvent", []),
      ]),
    },
    {
      name: "update_epoch_interval_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "block",
          "UpdateEpochIntervalEvent",
          []
        ),
      ]),
    },
  ];

  height: U64;
  epoch_interval: U64;
  new_block_events: Event.EventHandle;
  update_epoch_interval_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.height = proto["height"] as U64;
    this.epoch_interval = proto["epoch_interval"] as U64;
    this.new_block_events = proto["new_block_events"] as Event.EventHandle;
    this.update_epoch_interval_events = proto[
      "update_epoch_interval_events"
    ] as Event.EventHandle;
  }

  static BlockResourceParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): BlockResource {
    const proto = $.parseStructProto(data, typeTag, repo, BlockResource);
    return new BlockResource(proto, typeTag);
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
      BlockResource,
      typeParams
    );
    return result as unknown as BlockResource;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      BlockResource,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as BlockResource;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "BlockResource", []);
  }
  async loadFullState(app: $.AppType) {
    await this.new_block_events.loadFullState(app);
    await this.update_epoch_interval_events.loadFullState(app);
    this.__app = app;
  }
}

export class NewBlockEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "NewBlockEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "hash", typeTag: AtomicTypeTag.Address },
    { name: "epoch", typeTag: AtomicTypeTag.U64 },
    { name: "round", typeTag: AtomicTypeTag.U64 },
    { name: "height", typeTag: AtomicTypeTag.U64 },
    {
      name: "previous_block_votes_bitvec",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
    { name: "proposer", typeTag: AtomicTypeTag.Address },
    {
      name: "failed_proposer_indices",
      typeTag: new VectorTag(AtomicTypeTag.U64),
    },
    { name: "time_microseconds", typeTag: AtomicTypeTag.U64 },
  ];

  hash: HexString;
  epoch: U64;
  round: U64;
  height: U64;
  previous_block_votes_bitvec: U8[];
  proposer: HexString;
  failed_proposer_indices: U64[];
  time_microseconds: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.hash = proto["hash"] as HexString;
    this.epoch = proto["epoch"] as U64;
    this.round = proto["round"] as U64;
    this.height = proto["height"] as U64;
    this.previous_block_votes_bitvec = proto[
      "previous_block_votes_bitvec"
    ] as U8[];
    this.proposer = proto["proposer"] as HexString;
    this.failed_proposer_indices = proto["failed_proposer_indices"] as U64[];
    this.time_microseconds = proto["time_microseconds"] as U64;
  }

  static NewBlockEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): NewBlockEvent {
    const proto = $.parseStructProto(data, typeTag, repo, NewBlockEvent);
    return new NewBlockEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "NewBlockEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UpdateEpochIntervalEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UpdateEpochIntervalEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "old_epoch_interval", typeTag: AtomicTypeTag.U64 },
    { name: "new_epoch_interval", typeTag: AtomicTypeTag.U64 },
  ];

  old_epoch_interval: U64;
  new_epoch_interval: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.old_epoch_interval = proto["old_epoch_interval"] as U64;
    this.new_epoch_interval = proto["new_epoch_interval"] as U64;
  }

  static UpdateEpochIntervalEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UpdateEpochIntervalEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      UpdateEpochIntervalEvent
    );
    return new UpdateEpochIntervalEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "UpdateEpochIntervalEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function block_prologue_(
  vm: HexString,
  hash: HexString,
  epoch: U64,
  round: U64,
  proposer: HexString,
  failed_proposer_indices: U64[],
  previous_block_votes_bitvec: U8[],
  timestamp: U64,
  $c: AptosDataCache
): void {
  let temp$1, block_metadata_ref, new_block_event, proposer_index;
  System_addresses.assert_vm_(vm, $c);
  if ($.copy(proposer).hex() === new HexString("0x0").hex()) {
    temp$1 = true;
  } else {
    temp$1 = Stake.is_current_epoch_validator_($.copy(proposer), $c);
  }
  if (!temp$1) {
    throw $.abortCode(Error.permission_denied_($.copy(EINVALID_PROPOSER), $c));
  }
  proposer_index = Option.none_($c, [AtomicTypeTag.U64]);
  if ($.copy(proposer).hex() !== new HexString("0x0").hex()) {
    proposer_index = Option.some_(
      Stake.get_validator_index_($.copy(proposer), $c),
      $c,
      [AtomicTypeTag.U64]
    );
  } else {
  }
  block_metadata_ref = $c.borrow_global_mut<BlockResource>(
    new SimpleStructTag(BlockResource),
    new HexString("0x1")
  );
  block_metadata_ref.height = Event.counter_(
    block_metadata_ref.new_block_events,
    $c,
    [new SimpleStructTag(NewBlockEvent)]
  );
  new_block_event = new NewBlockEvent(
    {
      hash: $.copy(hash),
      epoch: $.copy(epoch),
      round: $.copy(round),
      height: $.copy(block_metadata_ref.height),
      previous_block_votes_bitvec: $.copy(previous_block_votes_bitvec),
      proposer: $.copy(proposer),
      failed_proposer_indices: $.copy(failed_proposer_indices),
      time_microseconds: $.copy(timestamp),
    },
    new SimpleStructTag(NewBlockEvent)
  );
  emit_new_block_event_(
    vm,
    block_metadata_ref.new_block_events,
    new_block_event,
    $c
  );
  Stake.update_performance_statistics_(
    $.copy(proposer_index),
    $.copy(failed_proposer_indices),
    $c
  );
  State_storage.on_new_block_(Reconfiguration.current_epoch_($c), $c);
  if (
    $.copy(timestamp)
      .sub(Reconfiguration.last_reconfiguration_time_($c))
      .ge($.copy(block_metadata_ref.epoch_interval))
  ) {
    Reconfiguration.reconfigure_($c);
  } else {
  }
  return;
}

export function emit_genesis_block_event_(
  vm: HexString,
  $c: AptosDataCache
): void {
  let block_metadata_ref, genesis_id;
  block_metadata_ref = $c.borrow_global_mut<BlockResource>(
    new SimpleStructTag(BlockResource),
    new HexString("0x1")
  );
  genesis_id = new HexString("0x0");
  emit_new_block_event_(
    vm,
    block_metadata_ref.new_block_events,
    new NewBlockEvent(
      {
        hash: $.copy(genesis_id),
        epoch: u64("0"),
        round: u64("0"),
        height: u64("0"),
        previous_block_votes_bitvec: Vector.empty_($c, [AtomicTypeTag.U8]),
        proposer: new HexString("0x0"),
        failed_proposer_indices: Vector.empty_($c, [AtomicTypeTag.U64]),
        time_microseconds: u64("0"),
      },
      new SimpleStructTag(NewBlockEvent)
    ),
    $c
  );
  return;
}

export function emit_new_block_event_(
  vm: HexString,
  event_handle: Event.EventHandle,
  new_block_event: NewBlockEvent,
  $c: AptosDataCache
): void {
  Timestamp.update_global_time_(
    vm,
    $.copy(new_block_event.proposer),
    $.copy(new_block_event.time_microseconds),
    $c
  );
  if (
    !Event.counter_(event_handle, $c, [new SimpleStructTag(NewBlockEvent)]).eq(
      $.copy(new_block_event.height)
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_(
        $.copy(ENUM_NEW_BLOCK_EVENTS_DOES_NOT_MATCH_BLOCK_HEIGHT),
        $c
      )
    );
  }
  Event.emit_event_(event_handle, new_block_event, $c, [
    new SimpleStructTag(NewBlockEvent),
  ]);
  return;
}

export function emit_writeset_block_event_(
  vm_signer: HexString,
  fake_block_hash: HexString,
  $c: AptosDataCache
): void {
  let block_metadata_ref;
  System_addresses.assert_vm_(vm_signer, $c);
  block_metadata_ref = $c.borrow_global_mut<BlockResource>(
    new SimpleStructTag(BlockResource),
    new HexString("0x1")
  );
  block_metadata_ref.height = Event.counter_(
    block_metadata_ref.new_block_events,
    $c,
    [new SimpleStructTag(NewBlockEvent)]
  );
  Event.emit_event_(
    block_metadata_ref.new_block_events,
    new NewBlockEvent(
      {
        hash: $.copy(fake_block_hash),
        epoch: Reconfiguration.current_epoch_($c),
        round: $.copy(MAX_U64),
        height: $.copy(block_metadata_ref.height),
        previous_block_votes_bitvec: Vector.empty_($c, [AtomicTypeTag.U8]),
        proposer: new HexString("0x0"),
        failed_proposer_indices: Vector.empty_($c, [AtomicTypeTag.U64]),
        time_microseconds: Timestamp.now_microseconds_($c),
      },
      new SimpleStructTag(NewBlockEvent)
    ),
    $c,
    [new SimpleStructTag(NewBlockEvent)]
  );
  return;
}

export function get_current_block_height_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<BlockResource>(
      new SimpleStructTag(BlockResource),
      new HexString("0x1")
    ).height
  );
}

export function get_epoch_interval_secs_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<BlockResource>(
      new SimpleStructTag(BlockResource),
      new HexString("0x1")
    ).epoch_interval
  ).div(u64("1000000"));
}

export function initialize_(
  aptos_framework: HexString,
  epoch_interval_microsecs: U64,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (!$.copy(epoch_interval_microsecs).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_EPOCH_INTERVAL), $c)
    );
  }
  $c.move_to(
    new SimpleStructTag(BlockResource),
    aptos_framework,
    new BlockResource(
      {
        height: u64("0"),
        epoch_interval: $.copy(epoch_interval_microsecs),
        new_block_events: Account.new_event_handle_(aptos_framework, $c, [
          new SimpleStructTag(NewBlockEvent),
        ]),
        update_epoch_interval_events: Account.new_event_handle_(
          aptos_framework,
          $c,
          [new SimpleStructTag(UpdateEpochIntervalEvent)]
        ),
      },
      new SimpleStructTag(BlockResource)
    )
  );
  return;
}

export function update_epoch_interval_microsecs_(
  aptos_framework: HexString,
  new_epoch_interval: U64,
  $c: AptosDataCache
): void {
  let block_resource, old_epoch_interval;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (!$.copy(new_epoch_interval).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_EPOCH_INTERVAL), $c)
    );
  }
  block_resource = $c.borrow_global_mut<BlockResource>(
    new SimpleStructTag(BlockResource),
    new HexString("0x1")
  );
  old_epoch_interval = $.copy(block_resource.epoch_interval);
  block_resource.epoch_interval = $.copy(new_epoch_interval);
  Event.emit_event_(
    block_resource.update_epoch_interval_events,
    new UpdateEpochIntervalEvent(
      {
        old_epoch_interval: $.copy(old_epoch_interval),
        new_epoch_interval: $.copy(new_epoch_interval),
      },
      new SimpleStructTag(UpdateEpochIntervalEvent)
    ),
    $c,
    [new SimpleStructTag(UpdateEpochIntervalEvent)]
  );
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::block::BlockResource",
    BlockResource.BlockResourceParser
  );
  repo.addParser(
    "0x1::block::NewBlockEvent",
    NewBlockEvent.NewBlockEventParser
  );
  repo.addParser(
    "0x1::block::UpdateEpochIntervalEvent",
    UpdateEpochIntervalEvent.UpdateEpochIntervalEventParser
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
  get BlockResource() {
    return BlockResource;
  }
  async loadBlockResource(owner: HexString, loadFull = true, fillCache = true) {
    const val = await BlockResource.load(
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
  get NewBlockEvent() {
    return NewBlockEvent;
  }
  get UpdateEpochIntervalEvent() {
    return UpdateEpochIntervalEvent;
  }
}
