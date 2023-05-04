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

import * as Error from "./error";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "state_storage";

export const ESTATE_STORAGE_USAGE: U64 = u64("0");

export class GasParameter {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GasParameter";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "usage",
      typeTag: new StructTag(
        new HexString("0x1"),
        "state_storage",
        "Usage",
        []
      ),
    },
  ];

  usage: Usage;

  constructor(proto: any, public typeTag: TypeTag) {
    this.usage = proto["usage"] as Usage;
  }

  static GasParameterParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GasParameter {
    const proto = $.parseStructProto(data, typeTag, repo, GasParameter);
    return new GasParameter(proto, typeTag);
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
      GasParameter,
      typeParams
    );
    return result as unknown as GasParameter;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GasParameter,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GasParameter;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GasParameter", []);
  }
  async loadFullState(app: $.AppType) {
    await this.usage.loadFullState(app);
    this.__app = app;
  }
}

export class StateStorageUsage {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StateStorageUsage";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "epoch", typeTag: AtomicTypeTag.U64 },
    {
      name: "usage",
      typeTag: new StructTag(
        new HexString("0x1"),
        "state_storage",
        "Usage",
        []
      ),
    },
  ];

  epoch: U64;
  usage: Usage;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto["epoch"] as U64;
    this.usage = proto["usage"] as Usage;
  }

  static StateStorageUsageParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StateStorageUsage {
    const proto = $.parseStructProto(data, typeTag, repo, StateStorageUsage);
    return new StateStorageUsage(proto, typeTag);
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
      StateStorageUsage,
      typeParams
    );
    return result as unknown as StateStorageUsage;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      StateStorageUsage,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as StateStorageUsage;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StateStorageUsage", []);
  }
  async loadFullState(app: $.AppType) {
    await this.usage.loadFullState(app);
    this.__app = app;
  }
}

export class Usage {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Usage";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "items", typeTag: AtomicTypeTag.U64 },
    { name: "bytes", typeTag: AtomicTypeTag.U64 },
  ];

  items: U64;
  bytes: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.items = proto["items"] as U64;
    this.bytes = proto["bytes"] as U64;
  }

  static UsageParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Usage {
    const proto = $.parseStructProto(data, typeTag, repo, Usage);
    return new Usage(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Usage", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function current_items_and_bytes_($c: AptosDataCache): [U64, U64] {
  let usage;
  if (
    !$c.exists(new SimpleStructTag(StateStorageUsage), new HexString("0x1"))
  ) {
    throw $.abortCode(Error.not_found_($.copy(ESTATE_STORAGE_USAGE), $c));
  }
  usage = $c.borrow_global<StateStorageUsage>(
    new SimpleStructTag(StateStorageUsage),
    new HexString("0x1")
  );
  return [$.copy(usage.usage.items), $.copy(usage.usage.bytes)];
}

export function get_state_storage_usage_only_at_epoch_beginning_(
  $c: AptosDataCache
): Usage {
  return $.aptos_framework_state_storage_get_state_storage_usage_only_at_epoch_beginning(
    $c
  );
}
export function initialize_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if ($c.exists(new SimpleStructTag(StateStorageUsage), new HexString("0x1"))) {
    throw $.abortCode(Error.already_exists_($.copy(ESTATE_STORAGE_USAGE), $c));
  }
  $c.move_to(
    new SimpleStructTag(StateStorageUsage),
    aptos_framework,
    new StateStorageUsage(
      {
        epoch: u64("0"),
        usage: new Usage(
          { items: u64("0"), bytes: u64("0") },
          new SimpleStructTag(Usage)
        ),
      },
      new SimpleStructTag(StateStorageUsage)
    )
  );
  return;
}

export function on_new_block_(epoch: U64, $c: AptosDataCache): void {
  let usage;
  if (
    !$c.exists(new SimpleStructTag(StateStorageUsage), new HexString("0x1"))
  ) {
    throw $.abortCode(Error.not_found_($.copy(ESTATE_STORAGE_USAGE), $c));
  }
  usage = $c.borrow_global_mut<StateStorageUsage>(
    new SimpleStructTag(StateStorageUsage),
    new HexString("0x1")
  );
  if ($.copy(epoch).neq($.copy(usage.epoch))) {
    usage.epoch = $.copy(epoch);
    usage.usage = get_state_storage_usage_only_at_epoch_beginning_($c);
  } else {
  }
  return;
}

export function on_reconfig_($c: AptosDataCache): void {
  throw $.abortCode(u64("0"));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::state_storage::GasParameter",
    GasParameter.GasParameterParser
  );
  repo.addParser(
    "0x1::state_storage::StateStorageUsage",
    StateStorageUsage.StateStorageUsageParser
  );
  repo.addParser("0x1::state_storage::Usage", Usage.UsageParser);
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
  get GasParameter() {
    return GasParameter;
  }
  async loadGasParameter(owner: HexString, loadFull = true, fillCache = true) {
    const val = await GasParameter.load(
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
  get StateStorageUsage() {
    return StateStorageUsage;
  }
  async loadStateStorageUsage(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await StateStorageUsage.load(
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
  get Usage() {
    return Usage;
  }
}
