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

import * as Coin from "./coin";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "transaction_fee";

export class AptosCoinCapabilities {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AptosCoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "burn_cap",
      typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
  ];

  burn_cap: Coin.BurnCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.burn_cap = proto["burn_cap"] as Coin.BurnCapability;
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
    await this.burn_cap.loadFullState(app);
    this.__app = app;
  }
}
export function burn_fee_(
  account: HexString,
  fee: U64,
  $c: AptosDataCache
): void {
  Coin.burn_from_(
    $.copy(account),
    $.copy(fee),
    $c.borrow_global<AptosCoinCapabilities>(
      new SimpleStructTag(AptosCoinCapabilities),
      new HexString("0x1")
    ).burn_cap,
    $c,
    [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
  );
  return;
}

export function store_aptos_coin_burn_cap_(
  aptos_framework: HexString,
  burn_cap: Coin.BurnCapability,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  return $c.move_to(
    new SimpleStructTag(AptosCoinCapabilities),
    aptos_framework,
    new AptosCoinCapabilities(
      { burn_cap: $.copy(burn_cap) },
      new SimpleStructTag(AptosCoinCapabilities)
    )
  );
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::transaction_fee::AptosCoinCapabilities",
    AptosCoinCapabilities.AptosCoinCapabilitiesParser
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
}
