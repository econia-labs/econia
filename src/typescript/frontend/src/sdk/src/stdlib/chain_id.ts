import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, U64, U128 } from "@manahippo/move-to-ts";
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

import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "chain_id";

export class ChainId {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ChainId";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [{ name: "id", typeTag: AtomicTypeTag.U8 }];

  id: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.id = proto["id"] as U8;
  }

  static ChainIdParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ChainId {
    const proto = $.parseStructProto(data, typeTag, repo, ChainId);
    return new ChainId(proto, typeTag);
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
      ChainId,
      typeParams
    );
    return result as unknown as ChainId;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      ChainId,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as ChainId;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ChainId", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function get_($c: AptosDataCache): U8 {
  return $.copy(
    $c.borrow_global<ChainId>(
      new SimpleStructTag(ChainId),
      new HexString("0x1")
    ).id
  );
}

export function initialize_(
  aptos_framework: HexString,
  id: U8,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  return $c.move_to(
    new SimpleStructTag(ChainId),
    aptos_framework,
    new ChainId({ id: $.copy(id) }, new SimpleStructTag(ChainId))
  );
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::chain_id::ChainId", ChainId.ChainIdParser);
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
  get ChainId() {
    return ChainId;
  }
  async loadChainId(owner: HexString, loadFull = true, fillCache = true) {
    const val = await ChainId.load(
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
