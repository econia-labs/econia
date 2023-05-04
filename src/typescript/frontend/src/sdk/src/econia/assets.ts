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

import * as Stdlib from "../stdlib";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "assets";

export const BASE_COIN_DECIMALS: U8 = u8("4");
export const BASE_COIN_NAME: U8[] = [
  u8("66"),
  u8("97"),
  u8("115"),
  u8("101"),
  u8("32"),
  u8("99"),
  u8("111"),
  u8("105"),
  u8("110"),
];
export const BASE_COIN_SYMBOL: U8[] = [u8("66"), u8("67")];
export const E_HAS_CAPABILITIES: U64 = u64("1");
export const E_NOT_ECONIA: U64 = u64("0");
export const QUOTE_COIN_DECIMALS: U8 = u8("12");
export const QUOTE_COIN_NAME: U8[] = [
  u8("81"),
  u8("117"),
  u8("111"),
  u8("116"),
  u8("101"),
  u8("32"),
  u8("99"),
  u8("111"),
  u8("105"),
  u8("110"),
];
export const QUOTE_COIN_SYMBOL: U8[] = [u8("81"), u8("67")];
export const UTILITY_COIN_DECIMALS: U8 = u8("10");
export const UTILITY_COIN_NAME: U8[] = [
  u8("85"),
  u8("116"),
  u8("105"),
  u8("108"),
  u8("105"),
  u8("116"),
  u8("121"),
  u8("32"),
  u8("99"),
  u8("111"),
  u8("105"),
  u8("110"),
];
export const UTILITY_COIN_SYMBOL: U8[] = [u8("85"), u8("67")];

export class BC {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "BC";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static BCParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): BC {
    const proto = $.parseStructProto(data, typeTag, repo, BC);
    return new BC(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "BC", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class CoinCapabilities {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CoinCapabilities";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "burn_capability",
      typeTag: new StructTag(new HexString("0x1"), "coin", "BurnCapability", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "freeze_capability",
      typeTag: new StructTag(new HexString("0x1"), "coin", "FreezeCapability", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "mint_capability",
      typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [
        new $.TypeParamIdx(0),
      ]),
    },
  ];

  burn_capability: Stdlib.Coin.BurnCapability;
  freeze_capability: Stdlib.Coin.FreezeCapability;
  mint_capability: Stdlib.Coin.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.burn_capability = proto[
      "burn_capability"
    ] as Stdlib.Coin.BurnCapability;
    this.freeze_capability = proto[
      "freeze_capability"
    ] as Stdlib.Coin.FreezeCapability;
    this.mint_capability = proto[
      "mint_capability"
    ] as Stdlib.Coin.MintCapability;
  }

  static CoinCapabilitiesParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CoinCapabilities {
    const proto = $.parseStructProto(data, typeTag, repo, CoinCapabilities);
    return new CoinCapabilities(proto, typeTag);
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
      CoinCapabilities,
      typeParams
    );
    return result as unknown as CoinCapabilities;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CoinCapabilities,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CoinCapabilities;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CoinCapabilities", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.burn_capability.loadFullState(app);
    await this.freeze_capability.loadFullState(app);
    await this.mint_capability.loadFullState(app);
    this.__app = app;
  }
}

export class QC {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "QC";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static QCParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): QC {
    const proto = $.parseStructProto(data, typeTag, repo, QC);
    return new QC(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "QC", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UC {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UC";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static UCParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): UC {
    const proto = $.parseStructProto(data, typeTag, repo, UC);
    return new UC(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UC", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function burn_(
  coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let burn_capability;
  burn_capability = $c.borrow_global<CoinCapabilities>(
    new SimpleStructTag(CoinCapabilities, [$p[0]]),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).burn_capability;
  Stdlib.Coin.burn_(coins, burn_capability, $c, [$p[0]]);
  return;
}

export function init_coin_type_(
  account: HexString,
  coin_name: U8[],
  coin_symbol: U8[],
  decimals: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let burn_capability, freeze_capability, mint_capability;
  if (
    !(
      Stdlib.Signer.address_of_(account, $c).hex() ===
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ).hex()
    )
  ) {
    throw $.abortCode($.copy(E_NOT_ECONIA));
  }
  if (
    $c.exists(
      new SimpleStructTag(CoinCapabilities, [$p[0]]),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    )
  ) {
    throw $.abortCode($.copy(E_HAS_CAPABILITIES));
  }
  [burn_capability, freeze_capability, mint_capability] =
    Stdlib.Coin.initialize_(
      account,
      Stdlib.String.utf8_($.copy(coin_name), $c),
      Stdlib.String.utf8_($.copy(coin_symbol), $c),
      $.copy(decimals),
      false,
      $c,
      [$p[0]]
    );
  $c.move_to(
    new SimpleStructTag(CoinCapabilities, [$p[0]]),
    account,
    new CoinCapabilities(
      {
        burn_capability: $.copy(burn_capability),
        freeze_capability: $.copy(freeze_capability),
        mint_capability: $.copy(mint_capability),
      },
      new SimpleStructTag(CoinCapabilities, [$p[0]])
    )
  );
  return;
}

export function init_module_(account: HexString, $c: AptosDataCache): void {
  init_coin_type_(
    account,
    $.copy(BASE_COIN_NAME),
    $.copy(BASE_COIN_SYMBOL),
    $.copy(BASE_COIN_DECIMALS),
    $c,
    [new SimpleStructTag(BC)]
  );
  init_coin_type_(
    account,
    $.copy(QUOTE_COIN_NAME),
    $.copy(QUOTE_COIN_SYMBOL),
    $.copy(QUOTE_COIN_DECIMALS),
    $c,
    [new SimpleStructTag(QC)]
  );
  init_coin_type_(
    account,
    $.copy(UTILITY_COIN_NAME),
    $.copy(UTILITY_COIN_SYMBOL),
    $.copy(UTILITY_COIN_DECIMALS),
    $c,
    [new SimpleStructTag(UC)]
  );
  return;
}

export function mint_(
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Stdlib.Coin.Coin {
  let account_address, mint_capability;
  account_address = Stdlib.Signer.address_of_(account, $c);
  if (
    !(
      $.copy(account_address).hex() ===
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ).hex()
    )
  ) {
    throw $.abortCode($.copy(E_NOT_ECONIA));
  }
  mint_capability = $c.borrow_global<CoinCapabilities>(
    new SimpleStructTag(CoinCapabilities, [$p[0]]),
    $.copy(account_address)
  ).mint_capability;
  return Stdlib.Coin.mint_($.copy(amount), mint_capability, $c, [$p[0]]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::assets::BC",
    BC.BCParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::assets::CoinCapabilities",
    CoinCapabilities.CoinCapabilitiesParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::assets::QC",
    QC.QCParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::assets::UC",
    UC.UCParser
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
  get BC() {
    return BC;
  }
  get CoinCapabilities() {
    return CoinCapabilities;
  }
  async loadCoinCapabilities(
    owner: HexString,
    $p: TypeTag[] /* <CoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CoinCapabilities.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get QC() {
    return QC;
  }
  get UC() {
    return UC;
  }
}
