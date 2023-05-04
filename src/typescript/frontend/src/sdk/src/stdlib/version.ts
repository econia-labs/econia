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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Error from "./error";
import * as Reconfiguration from "./reconfiguration";
import * as Signer from "./signer";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "version";

export const EINVALID_MAJOR_VERSION_NUMBER: U64 = u64("1");
export const ENOT_AUTHORIZED: U64 = u64("2");

export class SetVersionCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SetVersionCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static SetVersionCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SetVersionCapability {
    const proto = $.parseStructProto(data, typeTag, repo, SetVersionCapability);
    return new SetVersionCapability(proto, typeTag);
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
      SetVersionCapability,
      typeParams
    );
    return result as unknown as SetVersionCapability;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      SetVersionCapability,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as SetVersionCapability;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SetVersionCapability", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class Version {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Version";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "major", typeTag: AtomicTypeTag.U64 },
  ];

  major: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.major = proto["major"] as U64;
  }

  static VersionParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Version {
    const proto = $.parseStructProto(data, typeTag, repo, Version);
    return new Version(proto, typeTag);
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
      Version,
      typeParams
    );
    return result as unknown as Version;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Version,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Version;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Version", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function initialize_(
  aptos_framework: HexString,
  initial_version: U64,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $c.move_to(
    new SimpleStructTag(Version),
    aptos_framework,
    new Version(
      { major: $.copy(initial_version) },
      new SimpleStructTag(Version)
    )
  );
  $c.move_to(
    new SimpleStructTag(SetVersionCapability),
    aptos_framework,
    new SetVersionCapability({}, new SimpleStructTag(SetVersionCapability))
  );
  return;
}

export function initialize_for_test_(
  core_resources: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_core_resource_(core_resources, $c);
  $c.move_to(
    new SimpleStructTag(SetVersionCapability),
    core_resources,
    new SetVersionCapability({}, new SimpleStructTag(SetVersionCapability))
  );
  return;
}

export function set_version_(
  account: HexString,
  major: U64,
  $c: AptosDataCache
): void {
  let config, old_major;
  if (
    !$c.exists(
      new SimpleStructTag(SetVersionCapability),
      Signer.address_of_(account, $c)
    )
  ) {
    throw $.abortCode(Error.permission_denied_($.copy(ENOT_AUTHORIZED), $c));
  }
  old_major = $.copy(
    $c.borrow_global<Version>(
      new SimpleStructTag(Version),
      new HexString("0x1")
    ).major
  );
  if (!$.copy(old_major).lt($.copy(major))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_MAJOR_VERSION_NUMBER), $c)
    );
  }
  config = $c.borrow_global_mut<Version>(
    new SimpleStructTag(Version),
    new HexString("0x1")
  );
  config.major = $.copy(major);
  Reconfiguration.reconfigure_($c);
  return;
}

export function buildPayload_set_version(
  major: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "version",
    "set_version",
    typeParamStrings,
    [major],
    isJSON
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::version::SetVersionCapability",
    SetVersionCapability.SetVersionCapabilityParser
  );
  repo.addParser("0x1::version::Version", Version.VersionParser);
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
  get SetVersionCapability() {
    return SetVersionCapability;
  }
  async loadSetVersionCapability(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await SetVersionCapability.load(
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
  get Version() {
    return Version;
  }
  async loadVersion(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Version.load(
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
  payload_set_version(
    major: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_version(major, isJSON);
  }
  async set_version(
    _account: AptosAccount,
    major: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_version(major, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
