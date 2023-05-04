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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Stdlib from "../stdlib";
export const packageName = "Aptos Faucet";
export const moduleAddress = new HexString(
  "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
);
export const moduleName = "test_coin";

export class CapStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CapStore";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "burn_cap",
      typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "freeze_cap",
      typeTag: new StructTag(new HexString("0x1"), "coin", "FreezeCapability", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "mint_cap",
      typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [
        new $.TypeParamIdx(0),
      ]),
    },
  ];

  burn_cap: Stdlib.Coin.BurnCapability;
  freeze_cap: Stdlib.Coin.FreezeCapability;
  mint_cap: Stdlib.Coin.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.burn_cap = proto["burn_cap"] as Stdlib.Coin.BurnCapability;
    this.freeze_cap = proto["freeze_cap"] as Stdlib.Coin.FreezeCapability;
    this.mint_cap = proto["mint_cap"] as Stdlib.Coin.MintCapability;
  }

  static CapStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CapStore {
    const proto = $.parseStructProto(data, typeTag, repo, CapStore);
    return new CapStore(proto, typeTag);
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
      CapStore,
      typeParams
    );
    return result as unknown as CapStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CapStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CapStore;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CapStore", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.burn_cap.loadFullState(app);
    await this.freeze_cap.loadFullState(app);
    await this.mint_cap.loadFullState(app);
    this.__app = app;
  }
}
export function coin_address_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): HexString {
  let type_info;
  type_info = Stdlib.Type_info.type_of_($c, [$p[0]]);
  return Stdlib.Type_info.account_address_(type_info, $c);
}

export function initialize_(
  account: HexString,
  name: Stdlib.String.String,
  symbol: Stdlib.String.String,
  decimals: U8,
  monitor_supply: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let burn_cap, freeze_cap, mint_cap;
  [burn_cap, freeze_cap, mint_cap] = Stdlib.Coin.initialize_(
    account,
    $.copy(name),
    $.copy(symbol),
    $.copy(decimals),
    monitor_supply,
    $c,
    [$p[0]]
  );
  $c.move_to(
    new SimpleStructTag(CapStore, [$p[0]]),
    account,
    new CapStore(
      {
        burn_cap: $.copy(burn_cap),
        freeze_cap: $.copy(freeze_cap),
        mint_cap: $.copy(mint_cap),
      },
      new SimpleStructTag(CapStore, [$p[0]])
    )
  );
  return;
}

export function buildPayload_initialize(
  name: Stdlib.String.String,
  symbol: Stdlib.String.String,
  decimals: U8,
  monitor_supply: boolean,
  $p: TypeTag[] /* <CoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
    ),
    "test_coin",
    "initialize",
    typeParamStrings,
    [name, symbol, decimals, monitor_supply],
    isJSON
  );
}
export function mint_(
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let cap_store;
  cap_store = $c.borrow_global_mut<CapStore>(
    new SimpleStructTag(CapStore, [$p[0]]),
    coin_address_($c, [$p[0]])
  );
  Stdlib.Coin.deposit_(
    Stdlib.Signer.address_of_(account, $c),
    Stdlib.Coin.mint_($.copy(amount), cap_store.mint_cap, $c, [$p[0]]),
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_mint(
  amount: U64,
  $p: TypeTag[] /* <CoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942"
    ),
    "test_coin",
    "mint",
    typeParamStrings,
    [amount],
    isJSON
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_coin::CapStore",
    CapStore.CapStoreParser
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
  get CapStore() {
    return CapStore;
  }
  async loadCapStore(
    owner: HexString,
    $p: TypeTag[] /* <CoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CapStore.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  payload_initialize(
    name: Stdlib.String.String,
    symbol: Stdlib.String.String,
    decimals: U8,
    monitor_supply: boolean,
    $p: TypeTag[] /* <CoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_initialize(
      name,
      symbol,
      decimals,
      monitor_supply,
      $p,
      isJSON
    );
  }
  async initialize(
    _account: AptosAccount,
    name: Stdlib.String.String,
    symbol: Stdlib.String.String,
    decimals: U8,
    monitor_supply: boolean,
    $p: TypeTag[] /* <CoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_initialize(
      name,
      symbol,
      decimals,
      monitor_supply,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_mint(
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_mint(amount, $p, isJSON);
  }
  async mint(
    _account: AptosAccount,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_mint(amount, $p, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
