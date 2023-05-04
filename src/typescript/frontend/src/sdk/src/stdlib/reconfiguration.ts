import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, U128 } from "@manahippo/move-to-ts";
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
import * as Chain_status from "./chain_status";
import * as Error from "./error";
import * as Event from "./event";
import * as Signer from "./signer";
import * as Stake from "./stake";
import * as Storage_gas from "./storage_gas";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "reconfiguration";

export const ECONFIG: U64 = u64("2");
export const ECONFIGURATION: U64 = u64("1");
export const EINVALID_BLOCK_TIME: U64 = u64("4");
export const EINVALID_GUID_FOR_EVENT: U64 = u64("5");
export const EMODIFY_CAPABILITY: U64 = u64("3");

export class Configuration {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Configuration";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "epoch", typeTag: AtomicTypeTag.U64 },
    { name: "last_reconfiguration_time", typeTag: AtomicTypeTag.U64 },
    {
      name: "events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString("0x1"),
          "reconfiguration",
          "NewEpochEvent",
          []
        ),
      ]),
    },
  ];

  epoch: U64;
  last_reconfiguration_time: U64;
  events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto["epoch"] as U64;
    this.last_reconfiguration_time = proto["last_reconfiguration_time"] as U64;
    this.events = proto["events"] as Event.EventHandle;
  }

  static ConfigurationParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Configuration {
    const proto = $.parseStructProto(data, typeTag, repo, Configuration);
    return new Configuration(proto, typeTag);
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
      Configuration,
      typeParams
    );
    return result as unknown as Configuration;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Configuration,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Configuration;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Configuration", []);
  }
  async loadFullState(app: $.AppType) {
    await this.events.loadFullState(app);
    this.__app = app;
  }
}

export class DisableReconfiguration {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "DisableReconfiguration";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static DisableReconfigurationParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): DisableReconfiguration {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      DisableReconfiguration
    );
    return new DisableReconfiguration(proto, typeTag);
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
      DisableReconfiguration,
      typeParams
    );
    return result as unknown as DisableReconfiguration;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      DisableReconfiguration,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as DisableReconfiguration;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "DisableReconfiguration",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class NewEpochEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "NewEpochEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "epoch", typeTag: AtomicTypeTag.U64 },
  ];

  epoch: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto["epoch"] as U64;
  }

  static NewEpochEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): NewEpochEvent {
    const proto = $.parseStructProto(data, typeTag, repo, NewEpochEvent);
    return new NewEpochEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "NewEpochEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function current_epoch_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<Configuration>(
      new SimpleStructTag(Configuration),
      new HexString("0x1")
    ).epoch
  );
}

export function disable_reconfiguration_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (!reconfiguration_enabled_($c)) {
    throw $.abortCode(Error.invalid_state_($.copy(ECONFIGURATION), $c));
  }
  return $c.move_to(
    new SimpleStructTag(DisableReconfiguration),
    aptos_framework,
    new DisableReconfiguration({}, new SimpleStructTag(DisableReconfiguration))
  );
}

export function emit_genesis_reconfiguration_event_($c: AptosDataCache): void {
  let temp$1, config_ref;
  config_ref = $c.borrow_global_mut<Configuration>(
    new SimpleStructTag(Configuration),
    new HexString("0x1")
  );
  if ($.copy(config_ref.epoch).eq(u64("0"))) {
    temp$1 = $.copy(config_ref.last_reconfiguration_time).eq(u64("0"));
  } else {
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(Error.invalid_state_($.copy(ECONFIGURATION), $c));
  }
  config_ref.epoch = u64("1");
  Event.emit_event_(
    config_ref.events,
    new NewEpochEvent(
      { epoch: $.copy(config_ref.epoch) },
      new SimpleStructTag(NewEpochEvent)
    ),
    $c,
    [new SimpleStructTag(NewEpochEvent)]
  );
  return;
}

export function enable_reconfiguration_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (reconfiguration_enabled_($c)) {
    throw $.abortCode(Error.invalid_state_($.copy(ECONFIGURATION), $c));
  }
  $c.move_from<DisableReconfiguration>(
    new SimpleStructTag(DisableReconfiguration),
    Signer.address_of_(aptos_framework, $c)
  );
  return;
}

export function initialize_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (
    !Account.get_guid_next_creation_num_(
      Signer.address_of_(aptos_framework, $c),
      $c
    ).eq(u64("2"))
  ) {
    throw $.abortCode(
      Error.invalid_state_($.copy(EINVALID_GUID_FOR_EVENT), $c)
    );
  }
  $c.move_to(
    new SimpleStructTag(Configuration),
    aptos_framework,
    new Configuration(
      {
        epoch: u64("0"),
        last_reconfiguration_time: u64("0"),
        events: Account.new_event_handle_(aptos_framework, $c, [
          new SimpleStructTag(NewEpochEvent),
        ]),
      },
      new SimpleStructTag(Configuration)
    )
  );
  return;
}

export function last_reconfiguration_time_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<Configuration>(
      new SimpleStructTag(Configuration),
      new HexString("0x1")
    ).last_reconfiguration_time
  );
}

export function reconfiguration_enabled_($c: AptosDataCache): boolean {
  return !$c.exists(
    new SimpleStructTag(DisableReconfiguration),
    new HexString("0x1")
  );
}

export function reconfigure_($c: AptosDataCache): void {
  let temp$1, temp$2, config_ref, current_time;
  if (Chain_status.is_genesis_($c)) {
    temp$1 = true;
  } else {
    temp$1 = Timestamp.now_microseconds_($c).eq(u64("0"));
  }
  if (temp$1) {
    temp$2 = true;
  } else {
    temp$2 = !reconfiguration_enabled_($c);
  }
  if (temp$2) {
    return;
  } else {
  }
  config_ref = $c.borrow_global_mut<Configuration>(
    new SimpleStructTag(Configuration),
    new HexString("0x1")
  );
  current_time = Timestamp.now_microseconds_($c);
  if ($.copy(current_time).eq($.copy(config_ref.last_reconfiguration_time))) {
    return;
  } else {
  }
  Stake.on_new_epoch_($c);
  Storage_gas.on_reconfig_($c);
  if (!$.copy(current_time).gt($.copy(config_ref.last_reconfiguration_time))) {
    throw $.abortCode(Error.invalid_state_($.copy(EINVALID_BLOCK_TIME), $c));
  }
  config_ref.last_reconfiguration_time = $.copy(current_time);
  config_ref.epoch = $.copy(config_ref.epoch).add(u64("1"));
  Event.emit_event_(
    config_ref.events,
    new NewEpochEvent(
      { epoch: $.copy(config_ref.epoch) },
      new SimpleStructTag(NewEpochEvent)
    ),
    $c,
    [new SimpleStructTag(NewEpochEvent)]
  );
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::reconfiguration::Configuration",
    Configuration.ConfigurationParser
  );
  repo.addParser(
    "0x1::reconfiguration::DisableReconfiguration",
    DisableReconfiguration.DisableReconfigurationParser
  );
  repo.addParser(
    "0x1::reconfiguration::NewEpochEvent",
    NewEpochEvent.NewEpochEventParser
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
  get Configuration() {
    return Configuration;
  }
  async loadConfiguration(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Configuration.load(
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
  get DisableReconfiguration() {
    return DisableReconfiguration;
  }
  async loadDisableReconfiguration(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await DisableReconfiguration.load(
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
  get NewEpochEvent() {
    return NewEpochEvent;
  }
}
