import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, type U128 } from "@manahippo/move-to-ts";
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

import * as Account from "./account";
import * as Error from "./error";
import * as Event from "./event";
import * as Option from "./option";
import * as Optional_aggregator from "./optional_aggregator";
import * as Signer from "./signer";
import * as String from "./string";
import * as System_addresses from "./system_addresses";
import * as Type_info from "./type_info";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "coin";

export const ECOIN_INFO_ADDRESS_MISMATCH: U64 = u64("1");
export const ECOIN_INFO_ALREADY_PUBLISHED: U64 = u64("2");
export const ECOIN_INFO_NOT_PUBLISHED: U64 = u64("3");
export const ECOIN_NAME_TOO_LONG: U64 = u64("12");
export const ECOIN_STORE_ALREADY_PUBLISHED: U64 = u64("4");
export const ECOIN_STORE_NOT_PUBLISHED: U64 = u64("5");
export const ECOIN_SUPPLY_UPGRADE_NOT_SUPPORTED: U64 = u64("11");
export const ECOIN_SYMBOL_TOO_LONG: U64 = u64("13");
export const EDESTRUCTION_OF_NONZERO_TOKEN: U64 = u64("7");
export const EFROZEN: U64 = u64("10");
export const EINSUFFICIENT_BALANCE: U64 = u64("6");
export const EZERO_COIN_AMOUNT: U64 = u64("9");
export const MAX_COIN_NAME_LENGTH: U64 = u64("32");
export const MAX_COIN_SYMBOL_LENGTH: U64 = u64("10");
export const MAX_U128: U128 = u128("340282366920938463463374607431768211455");

export class BurnCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "BurnCapability";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static BurnCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): BurnCapability {
    const proto = $.parseStructProto(data, typeTag, repo, BurnCapability);
    return new BurnCapability(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "BurnCapability", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class Coin {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Coin";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "value", typeTag: AtomicTypeTag.U64 },
  ];

  value: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.value = proto["value"] as U64;
  }

  static CoinParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): Coin {
    const proto = $.parseStructProto(data, typeTag, repo, Coin);
    return new Coin(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Coin", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class CoinInfo {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CoinInfo";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "name",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    {
      name: "symbol",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    { name: "decimals", typeTag: AtomicTypeTag.U8 },
    {
      name: "supply",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new StructTag(
          new HexString("0x1"),
          "optional_aggregator",
          "OptionalAggregator",
          []
        ),
      ]),
    },
  ];

  name: String.String;
  symbol: String.String;
  decimals: U8;
  supply: Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.name = proto["name"] as String.String;
    this.symbol = proto["symbol"] as String.String;
    this.decimals = proto["decimals"] as U8;
    this.supply = proto["supply"] as Option.Option;
  }

  static CoinInfoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CoinInfo {
    const proto = $.parseStructProto(data, typeTag, repo, CoinInfo);
    return new CoinInfo(proto, typeTag);
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
      CoinInfo,
      typeParams
    );
    return result as unknown as CoinInfo;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CoinInfo,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CoinInfo;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CoinInfo", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.name.loadFullState(app);
    await this.symbol.loadFullState(app);
    await this.supply.loadFullState(app);
    this.__app = app;
  }
}

export class CoinStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CoinStore";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "coin",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new $.TypeParamIdx(0),
      ]),
    },
    { name: "frozen", typeTag: AtomicTypeTag.Bool },
    {
      name: "deposit_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "coin", "DepositEvent", []),
      ]),
    },
    {
      name: "withdraw_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "coin", "WithdrawEvent", []),
      ]),
    },
  ];

  coin: Coin;
  frozen: boolean;
  deposit_events: Event.EventHandle;
  withdraw_events: Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.coin = proto["coin"] as Coin;
    this.frozen = proto["frozen"] as boolean;
    this.deposit_events = proto["deposit_events"] as Event.EventHandle;
    this.withdraw_events = proto["withdraw_events"] as Event.EventHandle;
  }

  static CoinStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CoinStore {
    const proto = $.parseStructProto(data, typeTag, repo, CoinStore);
    return new CoinStore(proto, typeTag);
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
      CoinStore,
      typeParams
    );
    return result as unknown as CoinStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CoinStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CoinStore;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CoinStore", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.coin.loadFullState(app);
    await this.deposit_events.loadFullState(app);
    await this.withdraw_events.loadFullState(app);
    this.__app = app;
  }
}

export class DepositEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "DepositEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.amount = proto["amount"] as U64;
  }

  static DepositEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): DepositEvent {
    const proto = $.parseStructProto(data, typeTag, repo, DepositEvent);
    return new DepositEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "DepositEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class FreezeCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "FreezeCapability";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static FreezeCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): FreezeCapability {
    const proto = $.parseStructProto(data, typeTag, repo, FreezeCapability);
    return new FreezeCapability(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "FreezeCapability", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class MintCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MintCapability";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static MintCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MintCapability {
    const proto = $.parseStructProto(data, typeTag, repo, MintCapability);
    return new MintCapability(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "MintCapability", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class SupplyConfig {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SupplyConfig";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "allow_upgrades", typeTag: AtomicTypeTag.Bool },
  ];

  allow_upgrades: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.allow_upgrades = proto["allow_upgrades"] as boolean;
  }

  static SupplyConfigParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SupplyConfig {
    const proto = $.parseStructProto(data, typeTag, repo, SupplyConfig);
    return new SupplyConfig(proto, typeTag);
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
      SupplyConfig,
      typeParams
    );
    return result as unknown as SupplyConfig;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      SupplyConfig,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as SupplyConfig;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SupplyConfig", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class WithdrawEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "WithdrawEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "amount", typeTag: AtomicTypeTag.U64 },
  ];

  amount: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.amount = proto["amount"] as U64;
  }

  static WithdrawEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): WithdrawEvent {
    const proto = $.parseStructProto(data, typeTag, repo, WithdrawEvent);
    return new WithdrawEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "WithdrawEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function allow_supply_upgrades_(
  aptos_framework: HexString,
  allowed: boolean,
  $c: AptosDataCache
): void {
  let allow_upgrades;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  allow_upgrades = $c.borrow_global_mut<SupplyConfig>(
    new SimpleStructTag(SupplyConfig),
    new HexString("0x1")
  ).allow_upgrades;
  $.set(allow_upgrades, allowed);
  return;
}

export function balance_(
  owner: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): U64 {
  if (!is_account_registered_($.copy(owner), $c, [$p[0]])) {
    throw $.abortCode(Error.not_found_($.copy(ECOIN_STORE_NOT_PUBLISHED), $c));
  }
  return $.copy(
    $c.borrow_global<CoinStore>(
      new SimpleStructTag(CoinStore, [$p[0]]),
      $.copy(owner)
    ).coin.value
  );
}

export function burn_(
  coin: Coin,
  _cap: BurnCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let maybe_supply, supply;
  const { value: amount } = coin;
  if (!$.copy(amount).gt(u64("0"))) {
    throw $.abortCode(Error.invalid_argument_($.copy(EZERO_COIN_AMOUNT), $c));
  }
  maybe_supply = $c.borrow_global_mut<CoinInfo>(
    new SimpleStructTag(CoinInfo, [$p[0]]),
    coin_address_($c, [$p[0]])
  ).supply;
  if (
    Option.is_some_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ])
  ) {
    supply = Option.borrow_mut_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ]);
    Optional_aggregator.sub_(supply, u128($.copy(amount)), $c);
  } else {
  }
  return;
}

export function burn_from_(
  account_addr: HexString,
  amount: U64,
  burn_cap: BurnCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let coin_store, coin_to_burn;
  if ($.copy(amount).eq(u64("0"))) {
    return;
  } else {
  }
  coin_store = $c.borrow_global_mut<CoinStore>(
    new SimpleStructTag(CoinStore, [$p[0]]),
    $.copy(account_addr)
  );
  coin_to_burn = extract_(coin_store.coin, $.copy(amount), $c, [$p[0]]);
  burn_(coin_to_burn, burn_cap, $c, [$p[0]]);
  return;
}

export function coin_address_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): HexString {
  let type_info;
  type_info = Type_info.type_of_($c, [$p[0]]);
  return Type_info.account_address_(type_info, $c);
}

export function decimals_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): U8 {
  return $.copy(
    $c.borrow_global<CoinInfo>(
      new SimpleStructTag(CoinInfo, [$p[0]]),
      coin_address_($c, [$p[0]])
    ).decimals
  );
}

export function deposit_(
  account_addr: HexString,
  coin: Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let coin_store;
  if (!is_account_registered_($.copy(account_addr), $c, [$p[0]])) {
    throw $.abortCode(Error.not_found_($.copy(ECOIN_STORE_NOT_PUBLISHED), $c));
  }
  coin_store = $c.borrow_global_mut<CoinStore>(
    new SimpleStructTag(CoinStore, [$p[0]]),
    $.copy(account_addr)
  );
  if ($.copy(coin_store.frozen)) {
    throw $.abortCode(Error.permission_denied_($.copy(EFROZEN), $c));
  }
  Event.emit_event_(
    coin_store.deposit_events,
    new DepositEvent(
      { amount: $.copy(coin.value) },
      new SimpleStructTag(DepositEvent)
    ),
    $c,
    [new SimpleStructTag(DepositEvent)]
  );
  merge_(coin_store.coin, coin, $c, [$p[0]]);
  return;
}

export function destroy_burn_cap_(
  burn_cap: BurnCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  $.copy(burn_cap);
  return;
}

export function destroy_freeze_cap_(
  freeze_cap: FreezeCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  $.copy(freeze_cap);
  return;
}

export function destroy_mint_cap_(
  mint_cap: MintCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  $.copy(mint_cap);
  return;
}

export function destroy_zero_(
  zero_coin: Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  const { value: value } = zero_coin;
  if (!$.copy(value).eq(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EDESTRUCTION_OF_NONZERO_TOKEN), $c)
    );
  }
  return;
}

export function extract_(
  coin: Coin,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Coin {
  if (!$.copy(coin.value).ge($.copy(amount))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_BALANCE), $c)
    );
  }
  coin.value = $.copy(coin.value).sub($.copy(amount));
  return new Coin(
    { value: $.copy(amount) },
    new SimpleStructTag(Coin, [$p[0]])
  );
}

export function extract_all_(
  coin: Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Coin {
  let total_value;
  total_value = $.copy(coin.value);
  coin.value = u64("0");
  return new Coin(
    { value: $.copy(total_value) },
    new SimpleStructTag(Coin, [$p[0]])
  );
}

export function freeze_coin_store_(
  account_addr: HexString,
  _freeze_cap: FreezeCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let coin_store;
  coin_store = $c.borrow_global_mut<CoinStore>(
    new SimpleStructTag(CoinStore, [$p[0]]),
    $.copy(account_addr)
  );
  coin_store.frozen = true;
  return;
}

export function initialize_(
  account: HexString,
  name: String.String,
  symbol: String.String,
  decimals: U8,
  monitor_supply: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): [BurnCapability, FreezeCapability, MintCapability] {
  return initialize_internal_(
    account,
    $.copy(name),
    $.copy(symbol),
    $.copy(decimals),
    monitor_supply,
    false,
    $c,
    [$p[0]]
  );
}

export function initialize_internal_(
  account: HexString,
  name: String.String,
  symbol: String.String,
  decimals: U8,
  monitor_supply: boolean,
  parallelizable: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): [BurnCapability, FreezeCapability, MintCapability] {
  let temp$1, temp$2, temp$3, temp$4, account_addr, coin_info;
  account_addr = Signer.address_of_(account, $c);
  if (!(coin_address_($c, [$p[0]]).hex() === $.copy(account_addr).hex())) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ECOIN_INFO_ADDRESS_MISMATCH), $c)
    );
  }
  if ($c.exists(new SimpleStructTag(CoinInfo, [$p[0]]), $.copy(account_addr))) {
    throw $.abortCode(
      Error.already_exists_($.copy(ECOIN_INFO_ALREADY_PUBLISHED), $c)
    );
  }
  if (!String.length_(name, $c).le($.copy(MAX_COIN_NAME_LENGTH))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ECOIN_NAME_TOO_LONG), $c));
  }
  if (!String.length_(symbol, $c).le($.copy(MAX_COIN_SYMBOL_LENGTH))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ECOIN_SYMBOL_TOO_LONG), $c)
    );
  }
  temp$4 = $.copy(name);
  temp$3 = $.copy(symbol);
  temp$2 = $.copy(decimals);
  if (monitor_supply) {
    temp$1 = Option.some_(
      Optional_aggregator.new___($.copy(MAX_U128), parallelizable, $c),
      $c,
      [
        new StructTag(
          new HexString("0x1"),
          "optional_aggregator",
          "OptionalAggregator",
          []
        ),
      ]
    );
  } else {
    temp$1 = Option.none_($c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ]);
  }
  coin_info = new CoinInfo(
    { name: temp$4, symbol: temp$3, decimals: temp$2, supply: temp$1 },
    new SimpleStructTag(CoinInfo, [$p[0]])
  );
  $c.move_to(new SimpleStructTag(CoinInfo, [$p[0]]), account, coin_info);
  return [
    new BurnCapability({}, new SimpleStructTag(BurnCapability, [$p[0]])),
    new FreezeCapability({}, new SimpleStructTag(FreezeCapability, [$p[0]])),
    new MintCapability({}, new SimpleStructTag(MintCapability, [$p[0]])),
  ];
}

export function initialize_supply_config_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $c.move_to(
    new SimpleStructTag(SupplyConfig),
    aptos_framework,
    new SupplyConfig(
      { allow_upgrades: false },
      new SimpleStructTag(SupplyConfig)
    )
  );
  return;
}

export function initialize_with_parallelizable_supply_(
  account: HexString,
  name: String.String,
  symbol: String.String,
  decimals: U8,
  monitor_supply: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): [BurnCapability, FreezeCapability, MintCapability] {
  System_addresses.assert_aptos_framework_(account, $c);
  return initialize_internal_(
    account,
    $.copy(name),
    $.copy(symbol),
    $.copy(decimals),
    monitor_supply,
    true,
    $c,
    [$p[0]]
  );
}

export function is_account_registered_(
  account_addr: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): boolean {
  return $c.exists(
    new SimpleStructTag(CoinStore, [$p[0]]),
    $.copy(account_addr)
  );
}

export function is_coin_initialized_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): boolean {
  return $c.exists(
    new SimpleStructTag(CoinInfo, [$p[0]]),
    coin_address_($c, [$p[0]])
  );
}

export function merge_(
  dst_coin: Coin,
  source_coin: Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  dst_coin.value = $.copy(dst_coin.value).add($.copy(source_coin.value));
  source_coin;
  return;
}

export function mint_(
  amount: U64,
  _cap: MintCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Coin {
  let maybe_supply, supply;
  if ($.copy(amount).eq(u64("0"))) {
    return zero_($c, [$p[0]]);
  } else {
  }
  maybe_supply = $c.borrow_global_mut<CoinInfo>(
    new SimpleStructTag(CoinInfo, [$p[0]]),
    coin_address_($c, [$p[0]])
  ).supply;
  if (
    Option.is_some_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ])
  ) {
    supply = Option.borrow_mut_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ]);
    Optional_aggregator.add_(supply, u128($.copy(amount)), $c);
  } else {
  }
  return new Coin(
    { value: $.copy(amount) },
    new SimpleStructTag(Coin, [$p[0]])
  );
}

export function name_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): String.String {
  return $.copy(
    $c.borrow_global<CoinInfo>(
      new SimpleStructTag(CoinInfo, [$p[0]]),
      coin_address_($c, [$p[0]])
    ).name
  );
}

export function register_(
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let account_addr, coin_store;
  account_addr = Signer.address_of_(account, $c);
  if (is_account_registered_($.copy(account_addr), $c, [$p[0]])) {
    throw $.abortCode(
      Error.already_exists_($.copy(ECOIN_STORE_ALREADY_PUBLISHED), $c)
    );
  }
  Account.register_coin_($.copy(account_addr), $c, [$p[0]]);
  coin_store = new CoinStore(
    {
      coin: new Coin({ value: u64("0") }, new SimpleStructTag(Coin, [$p[0]])),
      frozen: false,
      deposit_events: Account.new_event_handle_(account, $c, [
        new SimpleStructTag(DepositEvent),
      ]),
      withdraw_events: Account.new_event_handle_(account, $c, [
        new SimpleStructTag(WithdrawEvent),
      ]),
    },
    new SimpleStructTag(CoinStore, [$p[0]])
  );
  $c.move_to(new SimpleStructTag(CoinStore, [$p[0]]), account, coin_store);
  return;
}

export function supply_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Option.Option {
  let temp$1, maybe_supply, supply, value;
  maybe_supply = $c.borrow_global<CoinInfo>(
    new SimpleStructTag(CoinInfo, [$p[0]]),
    coin_address_($c, [$p[0]])
  ).supply;
  if (
    Option.is_some_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ])
  ) {
    supply = Option.borrow_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ]);
    value = Optional_aggregator.read_(supply, $c);
    temp$1 = Option.some_($.copy(value), $c, [AtomicTypeTag.U128]);
  } else {
    temp$1 = Option.none_($c, [AtomicTypeTag.U128]);
  }
  return temp$1;
}

export function symbol_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): String.String {
  return $.copy(
    $c.borrow_global<CoinInfo>(
      new SimpleStructTag(CoinInfo, [$p[0]]),
      coin_address_($c, [$p[0]])
    ).symbol
  );
}

export function transfer_(
  from: HexString,
  to: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let coin;
  coin = withdraw_(from, $.copy(amount), $c, [$p[0]]);
  deposit_($.copy(to), coin, $c, [$p[0]]);
  return;
}

export function buildPayload_transfer(
  to: HexString,
  amount: U64,
  $p: TypeTag[] /* <CoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x1"),
    "coin",
    "transfer",
    typeParamStrings,
    [to, amount],
    isJSON
  );
}
export function unfreeze_coin_store_(
  account_addr: HexString,
  _freeze_cap: FreezeCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let coin_store;
  coin_store = $c.borrow_global_mut<CoinStore>(
    new SimpleStructTag(CoinStore, [$p[0]]),
    $.copy(account_addr)
  );
  coin_store.frozen = false;
  return;
}

export function upgrade_supply_(
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let account_addr, maybe_supply, supply;
  account_addr = Signer.address_of_(account, $c);
  if (!(coin_address_($c, [$p[0]]).hex() === $.copy(account_addr).hex())) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ECOIN_INFO_ADDRESS_MISMATCH), $c)
    );
  }
  if (
    !$.copy(
      $c.borrow_global_mut<SupplyConfig>(
        new SimpleStructTag(SupplyConfig),
        new HexString("0x1")
      ).allow_upgrades
    )
  ) {
    throw $.abortCode(
      Error.permission_denied_($.copy(ECOIN_SUPPLY_UPGRADE_NOT_SUPPORTED), $c)
    );
  }
  maybe_supply = $c.borrow_global_mut<CoinInfo>(
    new SimpleStructTag(CoinInfo, [$p[0]]),
    $.copy(account_addr)
  ).supply;
  if (
    Option.is_some_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ])
  ) {
    supply = Option.borrow_mut_(maybe_supply, $c, [
      new StructTag(
        new HexString("0x1"),
        "optional_aggregator",
        "OptionalAggregator",
        []
      ),
    ]);
    if (!Optional_aggregator.is_parallelizable_(supply, $c)) {
      Optional_aggregator.switch_(supply, $c);
    } else {
    }
  } else {
  }
  return;
}

export function buildPayload_upgrade_supply(
  $p: TypeTag[] /* <CoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString("0x1"),
    "coin",
    "upgrade_supply",
    typeParamStrings,
    [],
    isJSON
  );
}
export function value_(
  coin: Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): U64 {
  return $.copy(coin.value);
}

export function withdraw_(
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Coin {
  let account_addr, coin_store;
  account_addr = Signer.address_of_(account, $c);
  if (!is_account_registered_($.copy(account_addr), $c, [$p[0]])) {
    throw $.abortCode(Error.not_found_($.copy(ECOIN_STORE_NOT_PUBLISHED), $c));
  }
  coin_store = $c.borrow_global_mut<CoinStore>(
    new SimpleStructTag(CoinStore, [$p[0]]),
    $.copy(account_addr)
  );
  if ($.copy(coin_store.frozen)) {
    throw $.abortCode(Error.permission_denied_($.copy(EFROZEN), $c));
  }
  Event.emit_event_(
    coin_store.withdraw_events,
    new WithdrawEvent(
      { amount: $.copy(amount) },
      new SimpleStructTag(WithdrawEvent)
    ),
    $c,
    [new SimpleStructTag(WithdrawEvent)]
  );
  return extract_(coin_store.coin, $.copy(amount), $c, [$p[0]]);
}

export function zero_($c: AptosDataCache, $p: TypeTag[] /* <CoinType>*/): Coin {
  return new Coin({ value: u64("0") }, new SimpleStructTag(Coin, [$p[0]]));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::coin::BurnCapability",
    BurnCapability.BurnCapabilityParser
  );
  repo.addParser("0x1::coin::Coin", Coin.CoinParser);
  repo.addParser("0x1::coin::CoinInfo", CoinInfo.CoinInfoParser);
  repo.addParser("0x1::coin::CoinStore", CoinStore.CoinStoreParser);
  repo.addParser("0x1::coin::DepositEvent", DepositEvent.DepositEventParser);
  repo.addParser(
    "0x1::coin::FreezeCapability",
    FreezeCapability.FreezeCapabilityParser
  );
  repo.addParser(
    "0x1::coin::MintCapability",
    MintCapability.MintCapabilityParser
  );
  repo.addParser("0x1::coin::SupplyConfig", SupplyConfig.SupplyConfigParser);
  repo.addParser("0x1::coin::WithdrawEvent", WithdrawEvent.WithdrawEventParser);
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
  get BurnCapability() {
    return BurnCapability;
  }
  get Coin() {
    return Coin;
  }
  get CoinInfo() {
    return CoinInfo;
  }
  async loadCoinInfo(
    owner: HexString,
    $p: TypeTag[] /* <CoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CoinInfo.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get CoinStore() {
    return CoinStore;
  }
  async loadCoinStore(
    owner: HexString,
    $p: TypeTag[] /* <CoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CoinStore.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get DepositEvent() {
    return DepositEvent;
  }
  get FreezeCapability() {
    return FreezeCapability;
  }
  get MintCapability() {
    return MintCapability;
  }
  get SupplyConfig() {
    return SupplyConfig;
  }
  async loadSupplyConfig(owner: HexString, loadFull = true, fillCache = true) {
    const val = await SupplyConfig.load(
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
  get WithdrawEvent() {
    return WithdrawEvent;
  }
  payload_transfer(
    to: HexString,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_transfer(to, amount, $p, isJSON);
  }
  async transfer(
    _account: AptosAccount,
    to: HexString,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_transfer(to, amount, $p, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_upgrade_supply(
    $p: TypeTag[] /* <CoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_upgrade_supply($p, isJSON);
  }
  async upgrade_supply(
    _account: AptosAccount,
    $p: TypeTag[] /* <CoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_upgrade_supply($p, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
