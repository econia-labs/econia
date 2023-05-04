import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, type U128 } from "@manahippo/move-to-ts";
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

import type * as Aggregator from "./aggregator";
import * as Error from "./error";
import * as System_addresses from "./system_addresses";
import * as Table from "./table";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aggregator_factory";

export const EAGGREGATOR_FACTORY_NOT_FOUND: U64 = u64("1");

export class AggregatorFactory {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AggregatorFactory";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "phantom_table",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        AtomicTypeTag.Address,
        AtomicTypeTag.U128,
      ]),
    },
  ];

  phantom_table: Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.phantom_table = proto["phantom_table"] as Table.Table;
  }

  static AggregatorFactoryParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AggregatorFactory {
    const proto = $.parseStructProto(data, typeTag, repo, AggregatorFactory);
    return new AggregatorFactory(proto, typeTag);
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
      AggregatorFactory,
      typeParams
    );
    return result as unknown as AggregatorFactory;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      AggregatorFactory,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as AggregatorFactory;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AggregatorFactory", []);
  }
  async loadFullState(app: $.AppType) {
    await this.phantom_table.loadFullState(app);
    this.__app = app;
  }
}
export function create_aggregator_(
  account: HexString,
  limit: U128,
  $c: AptosDataCache
): Aggregator.Aggregator {
  System_addresses.assert_aptos_framework_(account, $c);
  return create_aggregator_internal_($.copy(limit), $c);
}

export function create_aggregator_internal_(
  limit: U128,
  $c: AptosDataCache
): Aggregator.Aggregator {
  let aggregator_factory;
  if (
    !$c.exists(new SimpleStructTag(AggregatorFactory), new HexString("0x1"))
  ) {
    throw $.abortCode(
      Error.not_found_($.copy(EAGGREGATOR_FACTORY_NOT_FOUND), $c)
    );
  }
  aggregator_factory = $c.borrow_global_mut<AggregatorFactory>(
    new SimpleStructTag(AggregatorFactory),
    new HexString("0x1")
  );
  return new_aggregator_(aggregator_factory, $.copy(limit), $c);
}

export function initialize_aggregator_factory_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  let aggregator_factory;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  aggregator_factory = new AggregatorFactory(
    {
      phantom_table: Table.new___($c, [
        AtomicTypeTag.Address,
        AtomicTypeTag.U128,
      ]),
    },
    new SimpleStructTag(AggregatorFactory)
  );
  $c.move_to(
    new SimpleStructTag(AggregatorFactory),
    aptos_framework,
    aggregator_factory
  );
  return;
}

export function new_aggregator_(
  aggregator_factory: AggregatorFactory,
  limit: U128,
  $c: AptosDataCache
): Aggregator.Aggregator {
  return $.aptos_framework_aggregator_factory_new_aggregator(
    aggregator_factory,
    limit,
    $c
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::aggregator_factory::AggregatorFactory",
    AggregatorFactory.AggregatorFactoryParser
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
  get AggregatorFactory() {
    return AggregatorFactory;
  }
  async loadAggregatorFactory(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await AggregatorFactory.load(
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
