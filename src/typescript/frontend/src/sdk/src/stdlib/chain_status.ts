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
export const moduleName = "chain_status";

export const ENOT_GENESIS: U64 = u64("2");
export const ENOT_OPERATING: U64 = u64("1");

export class GenesisEndMarker {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GenesisEndMarker";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static GenesisEndMarkerParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GenesisEndMarker {
    const proto = $.parseStructProto(data, typeTag, repo, GenesisEndMarker);
    return new GenesisEndMarker(proto, typeTag);
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
      GenesisEndMarker,
      typeParams
    );
    return result as unknown as GenesisEndMarker;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GenesisEndMarker,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GenesisEndMarker;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GenesisEndMarker", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function assert_genesis_($c: AptosDataCache): void {
  if (!is_genesis_($c)) {
    throw $.abortCode(Error.invalid_state_($.copy(ENOT_OPERATING), $c));
  }
  return;
}

export function assert_operating_($c: AptosDataCache): void {
  if (!is_operating_($c)) {
    throw $.abortCode(Error.invalid_state_($.copy(ENOT_OPERATING), $c));
  }
  return;
}

export function is_genesis_($c: AptosDataCache): boolean {
  return !$c.exists(
    new SimpleStructTag(GenesisEndMarker),
    new HexString("0x1")
  );
}

export function is_operating_($c: AptosDataCache): boolean {
  return $c.exists(new SimpleStructTag(GenesisEndMarker), new HexString("0x1"));
}

export function set_genesis_end_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $c.move_to(
    new SimpleStructTag(GenesisEndMarker),
    aptos_framework,
    new GenesisEndMarker({}, new SimpleStructTag(GenesisEndMarker))
  );
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::chain_status::GenesisEndMarker",
    GenesisEndMarker.GenesisEndMarkerParser
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
  get GenesisEndMarker() {
    return GenesisEndMarker;
  }
  async loadGenesisEndMarker(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await GenesisEndMarker.load(
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
