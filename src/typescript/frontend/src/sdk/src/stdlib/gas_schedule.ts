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

import * as Error from "./error";
import * as Reconfiguration from "./reconfiguration";
import * as Storage_gas from "./storage_gas";
import type * as String from "./string";
import * as System_addresses from "./system_addresses";
import * as Util from "./util";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "gas_schedule";

export const EINVALID_GAS_FEATURE_VERSION: U64 = u64("2");
export const EINVALID_GAS_SCHEDULE: U64 = u64("1");

export class GasEntry {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GasEntry";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "key",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    { name: "val", typeTag: AtomicTypeTag.U64 },
  ];

  key: String.String;
  val: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.key = proto["key"] as String.String;
    this.val = proto["val"] as U64;
  }

  static GasEntryParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GasEntry {
    const proto = $.parseStructProto(data, typeTag, repo, GasEntry);
    return new GasEntry(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GasEntry", []);
  }
  async loadFullState(app: $.AppType) {
    await this.key.loadFullState(app);
    this.__app = app;
  }
}

export class GasSchedule {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GasSchedule";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "entries",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "gas_schedule", "GasEntry", [])
      ),
    },
  ];

  entries: GasEntry[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.entries = proto["entries"] as GasEntry[];
  }

  static GasScheduleParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GasSchedule {
    const proto = $.parseStructProto(data, typeTag, repo, GasSchedule);
    return new GasSchedule(proto, typeTag);
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
      GasSchedule,
      typeParams
    );
    return result as unknown as GasSchedule;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GasSchedule,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GasSchedule;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GasSchedule", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class GasScheduleV2 {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GasScheduleV2";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "feature_version", typeTag: AtomicTypeTag.U64 },
    {
      name: "entries",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "gas_schedule", "GasEntry", [])
      ),
    },
  ];

  feature_version: U64;
  entries: GasEntry[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.feature_version = proto["feature_version"] as U64;
    this.entries = proto["entries"] as GasEntry[];
  }

  static GasScheduleV2Parser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GasScheduleV2 {
    const proto = $.parseStructProto(data, typeTag, repo, GasScheduleV2);
    return new GasScheduleV2(proto, typeTag);
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
      GasScheduleV2,
      typeParams
    );
    return result as unknown as GasScheduleV2;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GasScheduleV2,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GasScheduleV2;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GasScheduleV2", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function initialize_(
  aptos_framework: HexString,
  gas_schedule_blob: U8[],
  $c: AptosDataCache
): void {
  let gas_schedule;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (Vector.is_empty_(gas_schedule_blob, $c, [AtomicTypeTag.U8])) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_GAS_SCHEDULE), $c)
    );
  }
  gas_schedule = Util.from_bytes_($.copy(gas_schedule_blob), $c, [
    new SimpleStructTag(GasScheduleV2),
  ]);
  $c.move_to(
    new SimpleStructTag(GasScheduleV2),
    aptos_framework,
    $.copy(gas_schedule)
  );
  return;
}

export function set_gas_schedule_(
  aptos_framework: HexString,
  gas_schedule_blob: U8[],
  $c: AptosDataCache
): void {
  let gas_schedule, new_gas_schedule, new_gas_schedule__1;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (Vector.is_empty_(gas_schedule_blob, $c, [AtomicTypeTag.U8])) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_GAS_SCHEDULE), $c)
    );
  }
  if ($c.exists(new SimpleStructTag(GasScheduleV2), new HexString("0x1"))) {
    gas_schedule = $c.borrow_global_mut<GasScheduleV2>(
      new SimpleStructTag(GasScheduleV2),
      new HexString("0x1")
    );
    new_gas_schedule = Util.from_bytes_($.copy(gas_schedule_blob), $c, [
      new SimpleStructTag(GasScheduleV2),
    ]);
    if (
      !$.copy(new_gas_schedule.feature_version).ge(
        $.copy(gas_schedule.feature_version)
      )
    ) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EINVALID_GAS_FEATURE_VERSION), $c)
      );
    }
    $.set(gas_schedule, $.copy(new_gas_schedule));
  } else {
    if ($c.exists(new SimpleStructTag(GasSchedule), new HexString("0x1"))) {
      $c.move_from<GasSchedule>(
        new SimpleStructTag(GasSchedule),
        new HexString("0x1")
      );
    } else {
    }
    new_gas_schedule__1 = Util.from_bytes_($.copy(gas_schedule_blob), $c, [
      new SimpleStructTag(GasScheduleV2),
    ]);
    $c.move_to(
      new SimpleStructTag(GasScheduleV2),
      aptos_framework,
      $.copy(new_gas_schedule__1)
    );
  }
  Reconfiguration.reconfigure_($c);
  return;
}

export function set_storage_gas_config_(
  aptos_framework: HexString,
  config: Storage_gas.StorageGasConfig,
  $c: AptosDataCache
): void {
  Storage_gas.set_config_(aptos_framework, $.copy(config), $c);
  Reconfiguration.reconfigure_($c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::gas_schedule::GasEntry", GasEntry.GasEntryParser);
  repo.addParser(
    "0x1::gas_schedule::GasSchedule",
    GasSchedule.GasScheduleParser
  );
  repo.addParser(
    "0x1::gas_schedule::GasScheduleV2",
    GasScheduleV2.GasScheduleV2Parser
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
  get GasEntry() {
    return GasEntry;
  }
  get GasSchedule() {
    return GasSchedule;
  }
  async loadGasSchedule(owner: HexString, loadFull = true, fillCache = true) {
    const val = await GasSchedule.load(
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
  get GasScheduleV2() {
    return GasScheduleV2;
  }
  async loadGasScheduleV2(owner: HexString, loadFull = true, fillCache = true) {
    const val = await GasScheduleV2.load(
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
}
