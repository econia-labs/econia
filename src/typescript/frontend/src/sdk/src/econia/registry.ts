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
import * as Incentives from "./incentives";
import * as Tablist from "./tablist";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "registry";

export const E_BASE_NOT_COIN: U64 = u64("6");
export const E_BASE_QUOTE_SAME: U64 = u64("4");
export const E_GENERIC_TOO_FEW_CHARACTERS: U64 = u64("7");
export const E_GENERIC_TOO_MANY_CHARACTERS: U64 = u64("8");
export const E_INVALID_BASE: U64 = u64("13");
export const E_INVALID_MARKET_ID: U64 = u64("12");
export const E_INVALID_QUOTE: U64 = u64("14");
export const E_LOT_SIZE_0: U64 = u64("0");
export const E_MARKET_REGISTERED: U64 = u64("5");
export const E_MIN_SIZE_0: U64 = u64("2");
export const E_NOT_ECONIA: U64 = u64("9");
export const E_NO_RECOGNIZED_MARKET: U64 = u64("10");
export const E_QUOTE_NOT_COIN: U64 = u64("3");
export const E_TICK_SIZE_0: U64 = u64("1");
export const E_WRONG_RECOGNIZED_MARKET: U64 = u64("11");
export const MAX_CHARACTERS_GENERIC: U64 = u64("72");
export const MIN_CHARACTERS_GENERIC: U64 = u64("4");
export const NO_CUSTODIAN: U64 = u64("0");
export const NO_UNDERWRITER: U64 = u64("0");

export class CustodianCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CustodianCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "custodian_id", typeTag: AtomicTypeTag.U64 },
  ];

  custodian_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.custodian_id = proto["custodian_id"] as U64;
  }

  static CustodianCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CustodianCapability {
    const proto = $.parseStructProto(data, typeTag, repo, CustodianCapability);
    return new CustodianCapability(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "CustodianCapability", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class GenericAsset {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GenericAsset";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static GenericAssetParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GenericAsset {
    const proto = $.parseStructProto(data, typeTag, repo, GenericAsset);
    return new GenericAsset(proto, typeTag);
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
      GenericAsset,
      typeParams
    );
    return result as unknown as GenericAsset;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      GenericAsset,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as GenericAsset;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GenericAsset", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class MarketInfo {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MarketInfo";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "base_type",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
    {
      name: "base_name_generic",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    {
      name: "quote_type",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
    { name: "lot_size", typeTag: AtomicTypeTag.U64 },
    { name: "tick_size", typeTag: AtomicTypeTag.U64 },
    { name: "min_size", typeTag: AtomicTypeTag.U64 },
    { name: "underwriter_id", typeTag: AtomicTypeTag.U64 },
  ];

  base_type: Stdlib.Type_info.TypeInfo;
  base_name_generic: Stdlib.String.String;
  quote_type: Stdlib.Type_info.TypeInfo;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_type = proto["base_type"] as Stdlib.Type_info.TypeInfo;
    this.base_name_generic = proto["base_name_generic"] as Stdlib.String.String;
    this.quote_type = proto["quote_type"] as Stdlib.Type_info.TypeInfo;
    this.lot_size = proto["lot_size"] as U64;
    this.tick_size = proto["tick_size"] as U64;
    this.min_size = proto["min_size"] as U64;
    this.underwriter_id = proto["underwriter_id"] as U64;
  }

  static MarketInfoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MarketInfo {
    const proto = $.parseStructProto(data, typeTag, repo, MarketInfo);
    return new MarketInfo(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "MarketInfo", []);
  }
  async loadFullState(app: $.AppType) {
    await this.base_type.loadFullState(app);
    await this.base_name_generic.loadFullState(app);
    await this.quote_type.loadFullState(app);
    this.__app = app;
  }
}

export class MarketRegistrationEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MarketRegistrationEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "market_id", typeTag: AtomicTypeTag.U64 },
    {
      name: "base_type",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
    {
      name: "base_name_generic",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    {
      name: "quote_type",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
    { name: "lot_size", typeTag: AtomicTypeTag.U64 },
    { name: "tick_size", typeTag: AtomicTypeTag.U64 },
    { name: "min_size", typeTag: AtomicTypeTag.U64 },
    { name: "underwriter_id", typeTag: AtomicTypeTag.U64 },
  ];

  market_id: U64;
  base_type: Stdlib.Type_info.TypeInfo;
  base_name_generic: Stdlib.String.String;
  quote_type: Stdlib.Type_info.TypeInfo;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_id = proto["market_id"] as U64;
    this.base_type = proto["base_type"] as Stdlib.Type_info.TypeInfo;
    this.base_name_generic = proto["base_name_generic"] as Stdlib.String.String;
    this.quote_type = proto["quote_type"] as Stdlib.Type_info.TypeInfo;
    this.lot_size = proto["lot_size"] as U64;
    this.tick_size = proto["tick_size"] as U64;
    this.min_size = proto["min_size"] as U64;
    this.underwriter_id = proto["underwriter_id"] as U64;
  }

  static MarketRegistrationEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MarketRegistrationEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      MarketRegistrationEvent
    );
    return new MarketRegistrationEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "MarketRegistrationEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.base_type.loadFullState(app);
    await this.base_name_generic.loadFullState(app);
    await this.quote_type.loadFullState(app);
    this.__app = app;
  }
}

export class RecognizedMarketEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RecognizedMarketEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "trading_pair",
      typeTag: new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "registry",
        "TradingPair",
        []
      ),
    },
    {
      name: "recognized_market_info",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "RecognizedMarketInfo",
          []
        ),
      ]),
    },
  ];

  trading_pair: TradingPair;
  recognized_market_info: Stdlib.Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.trading_pair = proto["trading_pair"] as TradingPair;
    this.recognized_market_info = proto[
      "recognized_market_info"
    ] as Stdlib.Option.Option;
  }

  static RecognizedMarketEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RecognizedMarketEvent {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      RecognizedMarketEvent
    );
    return new RecognizedMarketEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "RecognizedMarketEvent",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.trading_pair.loadFullState(app);
    await this.recognized_market_info.loadFullState(app);
    this.__app = app;
  }
}

export class RecognizedMarketInfo {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RecognizedMarketInfo";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "market_id", typeTag: AtomicTypeTag.U64 },
    { name: "lot_size", typeTag: AtomicTypeTag.U64 },
    { name: "tick_size", typeTag: AtomicTypeTag.U64 },
    { name: "min_size", typeTag: AtomicTypeTag.U64 },
    { name: "underwriter_id", typeTag: AtomicTypeTag.U64 },
  ];

  market_id: U64;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_id = proto["market_id"] as U64;
    this.lot_size = proto["lot_size"] as U64;
    this.tick_size = proto["tick_size"] as U64;
    this.min_size = proto["min_size"] as U64;
    this.underwriter_id = proto["underwriter_id"] as U64;
  }

  static RecognizedMarketInfoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RecognizedMarketInfo {
    const proto = $.parseStructProto(data, typeTag, repo, RecognizedMarketInfo);
    return new RecognizedMarketInfo(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RecognizedMarketInfo", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class RecognizedMarkets {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RecognizedMarkets";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "map",
      typeTag: new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "tablist",
        "Tablist",
        [
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "registry",
            "TradingPair",
            []
          ),
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "registry",
            "RecognizedMarketInfo",
            []
          ),
        ]
      ),
    },
    {
      name: "recognized_market_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "RecognizedMarketEvent",
          []
        ),
      ]),
    },
  ];

  map: Tablist.Tablist;
  recognized_market_events: Stdlib.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto["map"] as Tablist.Tablist;
    this.recognized_market_events = proto[
      "recognized_market_events"
    ] as Stdlib.Event.EventHandle;
  }

  static RecognizedMarketsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RecognizedMarkets {
    const proto = $.parseStructProto(data, typeTag, repo, RecognizedMarkets);
    return new RecognizedMarkets(proto, typeTag);
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
      RecognizedMarkets,
      typeParams
    );
    return result as unknown as RecognizedMarkets;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      RecognizedMarkets,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as RecognizedMarkets;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RecognizedMarkets", []);
  }
  async loadFullState(app: $.AppType) {
    await this.map.loadFullState(app);
    await this.recognized_market_events.loadFullState(app);
    this.__app = app;
  }
}

export class Registry {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Registry";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "market_id_to_info",
      typeTag: new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "tablist",
        "Tablist",
        [
          AtomicTypeTag.U64,
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "registry",
            "MarketInfo",
            []
          ),
        ]
      ),
    },
    {
      name: "market_info_to_id",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "MarketInfo",
          []
        ),
        AtomicTypeTag.U64,
      ]),
    },
    { name: "n_custodians", typeTag: AtomicTypeTag.U64 },
    { name: "n_underwriters", typeTag: AtomicTypeTag.U64 },
    {
      name: "market_registration_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "MarketRegistrationEvent",
          []
        ),
      ]),
    },
  ];

  market_id_to_info: Tablist.Tablist;
  market_info_to_id: Stdlib.Table.Table;
  n_custodians: U64;
  n_underwriters: U64;
  market_registration_events: Stdlib.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_id_to_info = proto["market_id_to_info"] as Tablist.Tablist;
    this.market_info_to_id = proto["market_info_to_id"] as Stdlib.Table.Table;
    this.n_custodians = proto["n_custodians"] as U64;
    this.n_underwriters = proto["n_underwriters"] as U64;
    this.market_registration_events = proto[
      "market_registration_events"
    ] as Stdlib.Event.EventHandle;
  }

  static RegistryParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Registry {
    const proto = $.parseStructProto(data, typeTag, repo, Registry);
    return new Registry(proto, typeTag);
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
      Registry,
      typeParams
    );
    return result as unknown as Registry;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Registry,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Registry;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Registry", []);
  }
  async loadFullState(app: $.AppType) {
    await this.market_id_to_info.loadFullState(app);
    await this.market_info_to_id.loadFullState(app);
    await this.market_registration_events.loadFullState(app);
    this.__app = app;
  }
}

export class TradingPair {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "TradingPair";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "base_type",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
    {
      name: "base_name_generic",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    {
      name: "quote_type",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
  ];

  base_type: Stdlib.Type_info.TypeInfo;
  base_name_generic: Stdlib.String.String;
  quote_type: Stdlib.Type_info.TypeInfo;

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_type = proto["base_type"] as Stdlib.Type_info.TypeInfo;
    this.base_name_generic = proto["base_name_generic"] as Stdlib.String.String;
    this.quote_type = proto["quote_type"] as Stdlib.Type_info.TypeInfo;
  }

  static TradingPairParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): TradingPair {
    const proto = $.parseStructProto(data, typeTag, repo, TradingPair);
    return new TradingPair(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "TradingPair", []);
  }
  async loadFullState(app: $.AppType) {
    await this.base_type.loadFullState(app);
    await this.base_name_generic.loadFullState(app);
    await this.quote_type.loadFullState(app);
    this.__app = app;
  }
}

export class UnderwriterCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UnderwriterCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "underwriter_id", typeTag: AtomicTypeTag.U64 },
  ];

  underwriter_id: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.underwriter_id = proto["underwriter_id"] as U64;
  }

  static UnderwriterCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UnderwriterCapability {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      UnderwriterCapability
    );
    return new UnderwriterCapability(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "UnderwriterCapability",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function get_MAX_CHARACTERS_GENERIC_($c: AptosDataCache): U64 {
  return $.copy(MAX_CHARACTERS_GENERIC);
}

export function get_MIN_CHARACTERS_GENERIC_($c: AptosDataCache): U64 {
  return $.copy(MIN_CHARACTERS_GENERIC);
}

export function get_NO_CUSTODIAN_($c: AptosDataCache): U64 {
  return $.copy(NO_CUSTODIAN);
}

export function get_NO_UNDERWRITER_($c: AptosDataCache): U64 {
  return $.copy(NO_UNDERWRITER);
}

export function get_custodian_id_(
  custodian_capability_ref: CustodianCapability,
  $c: AptosDataCache
): U64 {
  return $.copy(custodian_capability_ref.custodian_id);
}

export function get_market_info_for_market_account_(
  market_id: U64,
  base_type: Stdlib.Type_info.TypeInfo,
  quote_type: Stdlib.Type_info.TypeInfo,
  $c: AptosDataCache
): [Stdlib.String.String, U64, U64, U64, U64] {
  let market_info_ref, markets_map_ref;
  markets_map_ref = $c.borrow_global<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).market_id_to_info;
  if (
    !Tablist.contains_(markets_map_ref, $.copy(market_id), $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(MarketInfo),
    ])
  ) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ID));
  }
  market_info_ref = Tablist.borrow_(markets_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(MarketInfo),
  ]);
  if (!$.deep_eq($.copy(base_type), $.copy(market_info_ref.base_type))) {
    throw $.abortCode($.copy(E_INVALID_BASE));
  }
  if (!$.deep_eq($.copy(quote_type), $.copy(market_info_ref.quote_type))) {
    throw $.abortCode($.copy(E_INVALID_QUOTE));
  }
  return [
    $.copy(market_info_ref.base_name_generic),
    $.copy(market_info_ref.lot_size),
    $.copy(market_info_ref.tick_size),
    $.copy(market_info_ref.min_size),
    $.copy(market_info_ref.underwriter_id),
  ];
}

export function get_recognized_market_info_(
  trading_pair: TradingPair,
  $c: AptosDataCache
): [U64, U64, U64, U64, U64] {
  let recognized_map_ref, recognized_market_info_ref;
  recognized_map_ref = $c.borrow_global<RecognizedMarkets>(
    new SimpleStructTag(RecognizedMarkets),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).map;
  if (
    !Tablist.contains_(recognized_map_ref, $.copy(trading_pair), $c, [
      new SimpleStructTag(TradingPair),
      new SimpleStructTag(RecognizedMarketInfo),
    ])
  ) {
    throw $.abortCode($.copy(E_NO_RECOGNIZED_MARKET));
  }
  recognized_market_info_ref = $.copy(
    Tablist.borrow_(recognized_map_ref, $.copy(trading_pair), $c, [
      new SimpleStructTag(TradingPair),
      new SimpleStructTag(RecognizedMarketInfo),
    ])
  );
  return [
    $.copy(recognized_market_info_ref.market_id),
    $.copy(recognized_market_info_ref.lot_size),
    $.copy(recognized_market_info_ref.tick_size),
    $.copy(recognized_market_info_ref.min_size),
    $.copy(recognized_market_info_ref.underwriter_id),
  ];
}

export function get_recognized_market_info_base_coin_(
  base_type: Stdlib.Type_info.TypeInfo,
  quote_type: Stdlib.Type_info.TypeInfo,
  $c: AptosDataCache
): [U64, U64, U64, U64, U64] {
  let base_name_generic, trading_pair;
  base_name_generic = Stdlib.String.utf8_([], $c);
  trading_pair = new TradingPair(
    {
      base_type: $.copy(base_type),
      base_name_generic: $.copy(base_name_generic),
      quote_type: $.copy(quote_type),
    },
    new SimpleStructTag(TradingPair)
  );
  return get_recognized_market_info_($.copy(trading_pair), $c);
}

export function get_recognized_market_info_base_coin_by_type_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseCoinType, QuoteCoinType>*/
): [U64, U64, U64, U64, U64] {
  return get_recognized_market_info_base_coin_(
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    Stdlib.Type_info.type_of_($c, [$p[1]]),
    $c
  );
}

export function get_recognized_market_info_base_generic_(
  base_name_generic: Stdlib.String.String,
  quote_type: Stdlib.Type_info.TypeInfo,
  $c: AptosDataCache
): [U64, U64, U64, U64, U64] {
  let base_type, trading_pair;
  base_type = Stdlib.Type_info.type_of_($c, [
    new SimpleStructTag(GenericAsset),
  ]);
  trading_pair = new TradingPair(
    {
      base_type: $.copy(base_type),
      base_name_generic: $.copy(base_name_generic),
      quote_type: $.copy(quote_type),
    },
    new SimpleStructTag(TradingPair)
  );
  return get_recognized_market_info_($.copy(trading_pair), $c);
}

export function get_recognized_market_info_base_generic_by_type_(
  base_name_generic: Stdlib.String.String,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): [U64, U64, U64, U64, U64] {
  return get_recognized_market_info_base_generic_(
    $.copy(base_name_generic),
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    $c
  );
}

export function get_underwriter_id_(
  underwriter_capability_ref: UnderwriterCapability,
  $c: AptosDataCache
): U64 {
  return $.copy(underwriter_capability_ref.underwriter_id);
}

export function has_recognized_market_(
  trading_pair: TradingPair,
  $c: AptosDataCache
): boolean {
  let recognized_map_ref;
  recognized_map_ref = $c.borrow_global<RecognizedMarkets>(
    new SimpleStructTag(RecognizedMarkets),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).map;
  return Tablist.contains_(recognized_map_ref, $.copy(trading_pair), $c, [
    new SimpleStructTag(TradingPair),
    new SimpleStructTag(RecognizedMarketInfo),
  ]);
}

export function has_recognized_market_base_coin_(
  base_type: Stdlib.Type_info.TypeInfo,
  quote_type: Stdlib.Type_info.TypeInfo,
  $c: AptosDataCache
): boolean {
  let base_name_generic, trading_pair;
  base_name_generic = Stdlib.String.utf8_([], $c);
  trading_pair = new TradingPair(
    {
      base_type: $.copy(base_type),
      base_name_generic: $.copy(base_name_generic),
      quote_type: $.copy(quote_type),
    },
    new SimpleStructTag(TradingPair)
  );
  return has_recognized_market_($.copy(trading_pair), $c);
}

export function has_recognized_market_base_coin_by_type_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseCoinType, QuoteCoinType>*/
): boolean {
  return has_recognized_market_base_coin_(
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    Stdlib.Type_info.type_of_($c, [$p[1]]),
    $c
  );
}

export function has_recognized_market_base_generic_(
  base_name_generic: Stdlib.String.String,
  quote_type: Stdlib.Type_info.TypeInfo,
  $c: AptosDataCache
): boolean {
  let base_type, trading_pair;
  base_type = Stdlib.Type_info.type_of_($c, [
    new SimpleStructTag(GenericAsset),
  ]);
  trading_pair = new TradingPair(
    {
      base_type: $.copy(base_type),
      base_name_generic: $.copy(base_name_generic),
      quote_type: $.copy(quote_type),
    },
    new SimpleStructTag(TradingPair)
  );
  return has_recognized_market_($.copy(trading_pair), $c);
}

export function has_recognized_market_base_generic_by_type_(
  base_name_generic: Stdlib.String.String,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): boolean {
  return has_recognized_market_base_generic_(
    $.copy(base_name_generic),
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    $c
  );
}

export function init_module_(econia: HexString, $c: AptosDataCache): void {
  $c.move_to(
    new SimpleStructTag(Registry),
    econia,
    new Registry(
      {
        market_id_to_info: Tablist.new___($c, [
          AtomicTypeTag.U64,
          new SimpleStructTag(MarketInfo),
        ]),
        market_info_to_id: Stdlib.Table.new___($c, [
          new SimpleStructTag(MarketInfo),
          AtomicTypeTag.U64,
        ]),
        n_custodians: u64("0"),
        n_underwriters: u64("0"),
        market_registration_events: Stdlib.Account.new_event_handle_(
          econia,
          $c,
          [new SimpleStructTag(MarketRegistrationEvent)]
        ),
      },
      new SimpleStructTag(Registry)
    )
  );
  $c.move_to(
    new SimpleStructTag(RecognizedMarkets),
    econia,
    new RecognizedMarkets(
      {
        map: Tablist.new___($c, [
          new SimpleStructTag(TradingPair),
          new SimpleStructTag(RecognizedMarketInfo),
        ]),
        recognized_market_events: Stdlib.Account.new_event_handle_(econia, $c, [
          new SimpleStructTag(RecognizedMarketEvent),
        ]),
      },
      new SimpleStructTag(RecognizedMarkets)
    )
  );
  return;
}

export function is_registered_custodian_id_(
  custodian_id: U64,
  $c: AptosDataCache
): boolean {
  let temp$1, n_custodians;
  n_custodians = $.copy(
    $c.borrow_global<Registry>(
      new SimpleStructTag(Registry),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    ).n_custodians
  );
  if ($.copy(custodian_id).le($.copy(n_custodians))) {
    temp$1 = $.copy(custodian_id).neq($.copy(NO_CUSTODIAN));
  } else {
    temp$1 = false;
  }
  return temp$1;
}

export function register_custodian_capability_(
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): CustodianCapability {
  let custodian_id, registry_ref_mut;
  registry_ref_mut = $c.borrow_global_mut<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  );
  custodian_id = $.copy(registry_ref_mut.n_custodians).add(u64("1"));
  registry_ref_mut.n_custodians = $.copy(custodian_id);
  Incentives.deposit_custodian_registration_utility_coins_(utility_coins, $c, [
    $p[0],
  ]);
  return new CustodianCapability(
    { custodian_id: $.copy(custodian_id) },
    new SimpleStructTag(CustodianCapability)
  );
}

export function register_integrator_fee_store_(
  integrator: HexString,
  market_id: U64,
  tier: U8,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  let market_info_ref, market_map_ref;
  market_map_ref = $c.borrow_global<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).market_id_to_info;
  if (
    !Tablist.contains_(market_map_ref, $.copy(market_id), $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(MarketInfo),
    ])
  ) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ID));
  }
  market_info_ref = Tablist.borrow_(market_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(MarketInfo),
  ]);
  if (
    !$.deep_eq(
      $.copy(market_info_ref.quote_type),
      Stdlib.Type_info.type_of_($c, [$p[0]])
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_QUOTE));
  }
  Incentives.register_integrator_fee_store_(
    integrator,
    $.copy(market_id),
    $.copy(tier),
    utility_coins,
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function register_integrator_fee_store_base_tier_(
  integrator: HexString,
  market_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  register_integrator_fee_store_(
    integrator,
    $.copy(market_id),
    u8("0"),
    Stdlib.Coin.zero_($c, [$p[1]]),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_register_integrator_fee_store_base_tier(
  market_id: U64,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "registry",
    "register_integrator_fee_store_base_tier",
    typeParamStrings,
    [market_id],
    isJSON
  );
}

export function register_integrator_fee_store_from_coinstore_(
  integrator: HexString,
  market_id: U64,
  tier: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  register_integrator_fee_store_(
    integrator,
    $.copy(market_id),
    $.copy(tier),
    Stdlib.Coin.withdraw_(
      integrator,
      Incentives.get_tier_activation_fee_($.copy(tier), $c),
      $c,
      [$p[1]]
    ),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_register_integrator_fee_store_from_coinstore(
  market_id: U64,
  tier: U8,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "registry",
    "register_integrator_fee_store_from_coinstore",
    typeParamStrings,
    [market_id, tier],
    isJSON
  );
}

export function register_market_base_coin_internal_(
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseCoinType, QuoteCoinType, UtilityCoinType>*/
): U64 {
  if (!Stdlib.Coin.is_coin_initialized_($c, [$p[0]])) {
    throw $.abortCode($.copy(E_BASE_NOT_COIN));
  }
  return register_market_internal_(
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    Stdlib.String.utf8_([], $c),
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
    $.copy(NO_UNDERWRITER),
    utility_coins,
    $c,
    [$p[1], $p[2]]
  );
}

export function register_market_base_generic_internal_(
  base_name_generic: Stdlib.String.String,
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  underwriter_capability_ref: UnderwriterCapability,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): U64 {
  let name_length, underwriter_id;
  name_length = Stdlib.String.length_(base_name_generic, $c);
  if (!$.copy(name_length).ge($.copy(MIN_CHARACTERS_GENERIC))) {
    throw $.abortCode($.copy(E_GENERIC_TOO_FEW_CHARACTERS));
  }
  if (!$.copy(name_length).le($.copy(MAX_CHARACTERS_GENERIC))) {
    throw $.abortCode($.copy(E_GENERIC_TOO_MANY_CHARACTERS));
  }
  underwriter_id = $.copy(underwriter_capability_ref.underwriter_id);
  return register_market_internal_(
    Stdlib.Type_info.type_of_($c, [new SimpleStructTag(GenericAsset)]),
    $.copy(base_name_generic),
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
    $.copy(underwriter_id),
    utility_coins,
    $c,
    [$p[0], $p[1]]
  );
}

export function register_market_internal_(
  base_type: Stdlib.Type_info.TypeInfo,
  base_name_generic: Stdlib.String.String,
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  underwriter_id: U64,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): U64 {
  let temp$1,
    temp$2,
    event_handle_ref_mut,
    id_to_info_ref_mut,
    info_to_id_ref_mut,
    market_id,
    market_info,
    quote_type,
    registry_ref_mut;
  if (!$.copy(lot_size).gt(u64("0"))) {
    throw $.abortCode($.copy(E_LOT_SIZE_0));
  }
  if (!$.copy(tick_size).gt(u64("0"))) {
    throw $.abortCode($.copy(E_TICK_SIZE_0));
  }
  if (!$.copy(min_size).gt(u64("0"))) {
    throw $.abortCode($.copy(E_MIN_SIZE_0));
  }
  if (!Stdlib.Coin.is_coin_initialized_($c, [$p[0]])) {
    throw $.abortCode($.copy(E_QUOTE_NOT_COIN));
  }
  quote_type = Stdlib.Type_info.type_of_($c, [$p[0]]);
  if ($.deep_eq($.copy(base_type), $.copy(quote_type))) {
    throw $.abortCode($.copy(E_BASE_QUOTE_SAME));
  }
  market_info = new MarketInfo(
    {
      base_type: $.copy(base_type),
      base_name_generic: $.copy(base_name_generic),
      quote_type: $.copy(quote_type),
      lot_size: $.copy(lot_size),
      tick_size: $.copy(tick_size),
      min_size: $.copy(min_size),
      underwriter_id: $.copy(underwriter_id),
    },
    new SimpleStructTag(MarketInfo)
  );
  registry_ref_mut = $c.borrow_global_mut<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  );
  info_to_id_ref_mut = registry_ref_mut.market_info_to_id;
  [temp$1, temp$2] = [info_to_id_ref_mut, $.copy(market_info)];
  if (
    Stdlib.Table.contains_(temp$1, temp$2, $c, [
      new SimpleStructTag(MarketInfo),
      AtomicTypeTag.U64,
    ])
  ) {
    throw $.abortCode($.copy(E_MARKET_REGISTERED));
  }
  id_to_info_ref_mut = registry_ref_mut.market_id_to_info;
  market_id = Tablist.length_(id_to_info_ref_mut, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(MarketInfo),
  ]).add(u64("1"));
  Stdlib.Table.add_(
    info_to_id_ref_mut,
    $.copy(market_info),
    $.copy(market_id),
    $c,
    [new SimpleStructTag(MarketInfo), AtomicTypeTag.U64]
  );
  Tablist.add_(id_to_info_ref_mut, $.copy(market_id), $.copy(market_info), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(MarketInfo),
  ]);
  event_handle_ref_mut = registry_ref_mut.market_registration_events;
  Stdlib.Event.emit_event_(
    event_handle_ref_mut,
    new MarketRegistrationEvent(
      {
        market_id: $.copy(market_id),
        base_type: $.copy(base_type),
        base_name_generic: $.copy(base_name_generic),
        quote_type: $.copy(quote_type),
        lot_size: $.copy(lot_size),
        tick_size: $.copy(tick_size),
        min_size: $.copy(min_size),
        underwriter_id: $.copy(underwriter_id),
      },
      new SimpleStructTag(MarketRegistrationEvent)
    ),
    $c,
    [new SimpleStructTag(MarketRegistrationEvent)]
  );
  Incentives.deposit_market_registration_utility_coins_(utility_coins, $c, [
    $p[1],
  ]);
  return $.copy(market_id);
}

export function register_underwriter_capability_(
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): UnderwriterCapability {
  let registry_ref_mut, underwriter_id;
  registry_ref_mut = $c.borrow_global_mut<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  );
  underwriter_id = $.copy(registry_ref_mut.n_underwriters).add(u64("1"));
  registry_ref_mut.n_underwriters = $.copy(underwriter_id);
  Incentives.deposit_underwriter_registration_utility_coins_(
    utility_coins,
    $c,
    [$p[0]]
  );
  return new UnderwriterCapability(
    { underwriter_id: $.copy(underwriter_id) },
    new SimpleStructTag(UnderwriterCapability)
  );
}

export function remove_recognized_market_(
  account: HexString,
  market_id: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    event_handle_ref_mut,
    market_info_ref,
    markets_map_ref,
    recognized_map_ref_mut,
    recognized_market_id_for_trading_pair,
    recognized_markets_ref_mut,
    trading_pair;
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
  markets_map_ref = $c.borrow_global<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).market_id_to_info;
  market_info_ref = Tablist.borrow_(markets_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(MarketInfo),
  ]);
  trading_pair = new TradingPair(
    {
      base_type: $.copy(market_info_ref.base_type),
      base_name_generic: $.copy(market_info_ref.base_name_generic),
      quote_type: $.copy(market_info_ref.quote_type),
    },
    new SimpleStructTag(TradingPair)
  );
  recognized_markets_ref_mut = $c.borrow_global_mut<RecognizedMarkets>(
    new SimpleStructTag(RecognizedMarkets),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  );
  recognized_map_ref_mut = recognized_markets_ref_mut.map;
  [temp$1, temp$2] = [recognized_map_ref_mut, $.copy(trading_pair)];
  if (
    !Tablist.contains_(temp$1, temp$2, $c, [
      new SimpleStructTag(TradingPair),
      new SimpleStructTag(RecognizedMarketInfo),
    ])
  ) {
    throw $.abortCode($.copy(E_NO_RECOGNIZED_MARKET));
  }
  [temp$3, temp$4] = [recognized_map_ref_mut, $.copy(trading_pair)];
  recognized_market_id_for_trading_pair = $.copy(
    Tablist.borrow_(temp$3, temp$4, $c, [
      new SimpleStructTag(TradingPair),
      new SimpleStructTag(RecognizedMarketInfo),
    ]).market_id
  );
  if (!$.copy(recognized_market_id_for_trading_pair).eq($.copy(market_id))) {
    throw $.abortCode($.copy(E_WRONG_RECOGNIZED_MARKET));
  }
  Tablist.remove_(recognized_map_ref_mut, $.copy(trading_pair), $c, [
    new SimpleStructTag(TradingPair),
    new SimpleStructTag(RecognizedMarketInfo),
  ]);
  event_handle_ref_mut = recognized_markets_ref_mut.recognized_market_events;
  Stdlib.Event.emit_event_(
    event_handle_ref_mut,
    new RecognizedMarketEvent(
      {
        trading_pair: $.copy(trading_pair),
        recognized_market_info: Stdlib.Option.none_($c, [
          new SimpleStructTag(RecognizedMarketInfo),
        ]),
      },
      new SimpleStructTag(RecognizedMarketEvent)
    ),
    $c,
    [new SimpleStructTag(RecognizedMarketEvent)]
  );
  return;
}

export function buildPayload_remove_recognized_market(
  market_id: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "registry",
    "remove_recognized_market",
    typeParamStrings,
    [market_id],
    isJSON
  );
}

export function remove_recognized_markets_(
  account: HexString,
  market_ids: U64[],
  $c: AptosDataCache
): void {
  let i, market_id, n_markets;
  n_markets = Stdlib.Vector.length_(market_ids, $c, [AtomicTypeTag.U64]);
  i = u64("0");
  while ($.copy(i).lt($.copy(n_markets))) {
    {
      market_id = $.copy(
        Stdlib.Vector.borrow_(market_ids, $.copy(i), $c, [AtomicTypeTag.U64])
      );
      remove_recognized_market_(account, $.copy(market_id), $c);
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function buildPayload_remove_recognized_markets(
  market_ids: U64[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "registry",
    "remove_recognized_markets",
    typeParamStrings,
    [market_ids],
    isJSON
  );
}

export function set_recognized_market_(
  account: HexString,
  market_id: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    base_name_generic,
    base_type,
    event_handle_ref_mut,
    lot_size,
    market_info_ref,
    markets_map_ref,
    min_size,
    new__,
    optional_market_info,
    quote_type,
    recognized_map_ref_mut,
    recognized_market_info,
    recognized_markets_ref_mut,
    tick_size,
    trading_pair,
    underwriter_id;
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
  markets_map_ref = $c.borrow_global<Registry>(
    new SimpleStructTag(Registry),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).market_id_to_info;
  market_info_ref = Tablist.borrow_(markets_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(MarketInfo),
  ]);
  [
    base_type,
    base_name_generic,
    quote_type,
    lot_size,
    tick_size,
    min_size,
    underwriter_id,
  ] = [
    $.copy(market_info_ref.base_type),
    $.copy(market_info_ref.base_name_generic),
    $.copy(market_info_ref.quote_type),
    $.copy(market_info_ref.lot_size),
    $.copy(market_info_ref.tick_size),
    $.copy(market_info_ref.min_size),
    $.copy(market_info_ref.underwriter_id),
  ];
  trading_pair = new TradingPair(
    {
      base_type: $.copy(base_type),
      base_name_generic: $.copy(base_name_generic),
      quote_type: $.copy(quote_type),
    },
    new SimpleStructTag(TradingPair)
  );
  recognized_market_info = new RecognizedMarketInfo(
    {
      market_id: $.copy(market_id),
      lot_size: $.copy(lot_size),
      tick_size: $.copy(tick_size),
      min_size: $.copy(min_size),
      underwriter_id: $.copy(underwriter_id),
    },
    new SimpleStructTag(RecognizedMarketInfo)
  );
  recognized_markets_ref_mut = $c.borrow_global_mut<RecognizedMarkets>(
    new SimpleStructTag(RecognizedMarkets),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  );
  recognized_map_ref_mut = recognized_markets_ref_mut.map;
  [temp$1, temp$2] = [recognized_map_ref_mut, $.copy(trading_pair)];
  new__ = !Tablist.contains_(temp$1, temp$2, $c, [
    new SimpleStructTag(TradingPair),
    new SimpleStructTag(RecognizedMarketInfo),
  ]);
  if (new__) {
    Tablist.add_(
      recognized_map_ref_mut,
      $.copy(trading_pair),
      $.copy(recognized_market_info),
      $c,
      [
        new SimpleStructTag(TradingPair),
        new SimpleStructTag(RecognizedMarketInfo),
      ]
    );
  } else {
    $.set(
      Tablist.borrow_mut_(recognized_map_ref_mut, $.copy(trading_pair), $c, [
        new SimpleStructTag(TradingPair),
        new SimpleStructTag(RecognizedMarketInfo),
      ]),
      $.copy(recognized_market_info)
    );
  }
  optional_market_info = Stdlib.Option.some_(
    $.copy(recognized_market_info),
    $c,
    [new SimpleStructTag(RecognizedMarketInfo)]
  );
  event_handle_ref_mut = recognized_markets_ref_mut.recognized_market_events;
  Stdlib.Event.emit_event_(
    event_handle_ref_mut,
    new RecognizedMarketEvent(
      {
        trading_pair: $.copy(trading_pair),
        recognized_market_info: $.copy(optional_market_info),
      },
      new SimpleStructTag(RecognizedMarketEvent)
    ),
    $c,
    [new SimpleStructTag(RecognizedMarketEvent)]
  );
  return;
}

export function buildPayload_set_recognized_market(
  market_id: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "registry",
    "set_recognized_market",
    typeParamStrings,
    [market_id],
    isJSON
  );
}

export function set_recognized_markets_(
  account: HexString,
  market_ids: U64[],
  $c: AptosDataCache
): void {
  let i, market_id, n_markets;
  n_markets = Stdlib.Vector.length_(market_ids, $c, [AtomicTypeTag.U64]);
  i = u64("0");
  while ($.copy(i).lt($.copy(n_markets))) {
    {
      market_id = $.copy(
        Stdlib.Vector.borrow_(market_ids, $.copy(i), $c, [AtomicTypeTag.U64])
      );
      set_recognized_market_(account, $.copy(market_id), $c);
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function buildPayload_set_recognized_markets(
  market_ids: U64[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "registry",
    "set_recognized_markets",
    typeParamStrings,
    [market_ids],
    isJSON
  );
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::CustodianCapability",
    CustodianCapability.CustodianCapabilityParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::GenericAsset",
    GenericAsset.GenericAssetParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::MarketInfo",
    MarketInfo.MarketInfoParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::MarketRegistrationEvent",
    MarketRegistrationEvent.MarketRegistrationEventParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::RecognizedMarketEvent",
    RecognizedMarketEvent.RecognizedMarketEventParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::RecognizedMarketInfo",
    RecognizedMarketInfo.RecognizedMarketInfoParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::RecognizedMarkets",
    RecognizedMarkets.RecognizedMarketsParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::Registry",
    Registry.RegistryParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::TradingPair",
    TradingPair.TradingPairParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::registry::UnderwriterCapability",
    UnderwriterCapability.UnderwriterCapabilityParser
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
  get CustodianCapability() {
    return CustodianCapability;
  }
  get GenericAsset() {
    return GenericAsset;
  }
  async loadGenericAsset(owner: HexString, loadFull = true, fillCache = true) {
    const val = await GenericAsset.load(
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
  get MarketInfo() {
    return MarketInfo;
  }
  get MarketRegistrationEvent() {
    return MarketRegistrationEvent;
  }
  get RecognizedMarketEvent() {
    return RecognizedMarketEvent;
  }
  get RecognizedMarketInfo() {
    return RecognizedMarketInfo;
  }
  get RecognizedMarkets() {
    return RecognizedMarkets;
  }
  async loadRecognizedMarkets(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await RecognizedMarkets.load(
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
  get Registry() {
    return Registry;
  }
  async loadRegistry(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Registry.load(
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
  get TradingPair() {
    return TradingPair;
  }
  get UnderwriterCapability() {
    return UnderwriterCapability;
  }
  payload_register_integrator_fee_store_base_tier(
    market_id: U64,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_register_integrator_fee_store_base_tier(
      market_id,
      $p,
      isJSON
    );
  }
  async register_integrator_fee_store_base_tier(
    _account: AptosAccount,
    market_id: U64,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_register_integrator_fee_store_base_tier(
      market_id,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_register_integrator_fee_store_from_coinstore(
    market_id: U64,
    tier: U8,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_register_integrator_fee_store_from_coinstore(
      market_id,
      tier,
      $p,
      isJSON
    );
  }
  async register_integrator_fee_store_from_coinstore(
    _account: AptosAccount,
    market_id: U64,
    tier: U8,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_register_integrator_fee_store_from_coinstore(
      market_id,
      tier,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_remove_recognized_market(
    market_id: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_remove_recognized_market(market_id, isJSON);
  }
  async remove_recognized_market(
    _account: AptosAccount,
    market_id: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_remove_recognized_market(market_id, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_remove_recognized_markets(
    market_ids: U64[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_remove_recognized_markets(market_ids, isJSON);
  }
  async remove_recognized_markets(
    _account: AptosAccount,
    market_ids: U64[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_remove_recognized_markets(
      market_ids,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_recognized_market(
    market_id: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_recognized_market(market_id, isJSON);
  }
  async set_recognized_market(
    _account: AptosAccount,
    market_id: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_recognized_market(market_id, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_recognized_markets(
    market_ids: U64[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_recognized_markets(market_ids, isJSON);
  }
  async set_recognized_markets(
    _account: AptosAccount,
    market_ids: U64[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_recognized_markets(market_ids, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  app_get_MAX_CHARACTERS_GENERIC() {
    return get_MAX_CHARACTERS_GENERIC_(this.cache);
  }
  app_get_MIN_CHARACTERS_GENERIC() {
    return get_MIN_CHARACTERS_GENERIC_(this.cache);
  }
  app_get_NO_CUSTODIAN() {
    return get_NO_CUSTODIAN_(this.cache);
  }
  app_get_NO_UNDERWRITER() {
    return get_NO_UNDERWRITER_(this.cache);
  }
  app_get_custodian_id(custodian_capability_ref: CustodianCapability) {
    return get_custodian_id_(custodian_capability_ref, this.cache);
  }
  app_get_recognized_market_info_base_coin(
    base_type: Stdlib.Type_info.TypeInfo,
    quote_type: Stdlib.Type_info.TypeInfo
  ) {
    return get_recognized_market_info_base_coin_(
      base_type,
      quote_type,
      this.cache
    );
  }
  app_get_recognized_market_info_base_coin_by_type($p: TypeTag[]) {
    return get_recognized_market_info_base_coin_by_type_(this.cache, $p);
  }
  app_get_recognized_market_info_base_generic(
    base_name_generic: Stdlib.String.String,
    quote_type: Stdlib.Type_info.TypeInfo
  ) {
    return get_recognized_market_info_base_generic_(
      base_name_generic,
      quote_type,
      this.cache
    );
  }
  app_get_recognized_market_info_base_generic_by_type(
    base_name_generic: Stdlib.String.String,
    $p: TypeTag[]
  ) {
    return get_recognized_market_info_base_generic_by_type_(
      base_name_generic,
      this.cache,
      $p
    );
  }
  app_get_underwriter_id(underwriter_capability_ref: UnderwriterCapability) {
    return get_underwriter_id_(underwriter_capability_ref, this.cache);
  }
  app_has_recognized_market_base_coin(
    base_type: Stdlib.Type_info.TypeInfo,
    quote_type: Stdlib.Type_info.TypeInfo
  ) {
    return has_recognized_market_base_coin_(base_type, quote_type, this.cache);
  }
  app_has_recognized_market_base_coin_by_type($p: TypeTag[]) {
    return has_recognized_market_base_coin_by_type_(this.cache, $p);
  }
  app_has_recognized_market_base_generic(
    base_name_generic: Stdlib.String.String,
    quote_type: Stdlib.Type_info.TypeInfo
  ) {
    return has_recognized_market_base_generic_(
      base_name_generic,
      quote_type,
      this.cache
    );
  }
  app_has_recognized_market_base_generic_by_type(
    base_name_generic: Stdlib.String.String,
    $p: TypeTag[]
  ) {
    return has_recognized_market_base_generic_by_type_(
      base_name_generic,
      this.cache,
      $p
    );
  }
}
