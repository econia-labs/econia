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
export const moduleName = "timestamp";

export const EINVALID_TIMESTAMP: U64 = u64("2");
export const ENOT_OPERATING: U64 = u64("1");
export const MICRO_CONVERSION_FACTOR: U64 = u64("1000000");

export class CurrentTimeMicroseconds {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CurrentTimeMicroseconds";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "microseconds", typeTag: AtomicTypeTag.U64 },
  ];

  microseconds: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.microseconds = proto["microseconds"] as U64;
  }

  static CurrentTimeMicrosecondsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CurrentTimeMicroseconds {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      CurrentTimeMicroseconds
    );
    return new CurrentTimeMicroseconds(proto, typeTag);
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
      CurrentTimeMicroseconds,
      typeParams
    );
    return result as unknown as CurrentTimeMicroseconds;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CurrentTimeMicroseconds,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CurrentTimeMicroseconds;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "CurrentTimeMicroseconds",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function now_microseconds_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<CurrentTimeMicroseconds>(
      new SimpleStructTag(CurrentTimeMicroseconds),
      new HexString("0x1")
    ).microseconds
  );
}

export function now_seconds_($c: AptosDataCache): U64 {
  return now_microseconds_($c).div($.copy(MICRO_CONVERSION_FACTOR));
}

export function set_time_has_started_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  let timer;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  timer = new CurrentTimeMicroseconds(
    { microseconds: u64("0") },
    new SimpleStructTag(CurrentTimeMicroseconds)
  );
  $c.move_to(
    new SimpleStructTag(CurrentTimeMicroseconds),
    aptos_framework,
    timer
  );
  return;
}

export function update_global_time_(
  account: HexString,
  proposer: HexString,
  timestamp: U64,
  $c: AptosDataCache
): void {
  let global_timer, now;
  System_addresses.assert_vm_(account, $c);
  global_timer = $c.borrow_global_mut<CurrentTimeMicroseconds>(
    new SimpleStructTag(CurrentTimeMicroseconds),
    new HexString("0x1")
  );
  now = $.copy(global_timer.microseconds);
  if ($.copy(proposer).hex() === new HexString("0x0").hex()) {
    if (!$.copy(now).eq($.copy(timestamp))) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EINVALID_TIMESTAMP), $c)
      );
    }
  } else {
    if (!$.copy(now).lt($.copy(timestamp))) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EINVALID_TIMESTAMP), $c)
      );
    }
    global_timer.microseconds = $.copy(timestamp);
  }
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::timestamp::CurrentTimeMicroseconds",
    CurrentTimeMicroseconds.CurrentTimeMicrosecondsParser
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
  get CurrentTimeMicroseconds() {
    return CurrentTimeMicroseconds;
  }
  async loadCurrentTimeMicroseconds(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CurrentTimeMicroseconds.load(
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
