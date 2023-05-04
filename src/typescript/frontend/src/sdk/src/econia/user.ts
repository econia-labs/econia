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

import * as Stdlib from "../stdlib";
import * as Registry from "./registry";
import * as Tablist from "./tablist";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "user";

export const ASK = true;
export const BID = false;
export const E_ACCESS_KEY_MISMATCH: U64 = u64("17");
export const E_ASSET_NOT_IN_PAIR: U64 = u64("4");
export const E_CHANGE_ORDER_NO_CHANGE: U64 = u64("14");
export const E_COIN_AMOUNT_MISMATCH: U64 = u64("16");
export const E_COIN_TYPE_IS_GENERIC_ASSET: U64 = u64("18");
export const E_DEPOSIT_OVERFLOW_ASSET_CEILING: U64 = u64("5");
export const E_EXISTS_MARKET_ACCOUNT: U64 = u64("0");
export const E_INVALID_MARKET_ORDER_ID: U64 = u64("15");
export const E_INVALID_UNDERWRITER: U64 = u64("6");
export const E_NOT_ENOUGH_ASSET_OUT: U64 = u64("13");
export const E_NO_MARKET_ACCOUNT: U64 = u64("3");
export const E_NO_MARKET_ACCOUNTS: U64 = u64("2");
export const E_OVERFLOW_ASSET_IN: U64 = u64("12");
export const E_PRICE_0: U64 = u64("8");
export const E_PRICE_TOO_HIGH: U64 = u64("9");
export const E_SIZE_TOO_LOW: U64 = u64("10");
export const E_START_SIZE_MISMATCH: U64 = u64("19");
export const E_TICKS_OVERFLOW: U64 = u64("11");
export const E_UNREGISTERED_CUSTODIAN: U64 = u64("1");
export const E_WITHDRAW_TOO_LITTLE_AVAILABLE: U64 = u64("7");
export const HI_64: U64 = u64("18446744073709551615");
export const HI_PRICE: U64 = u64("4294967295");
export const NIL: U64 = u64("0");
export const NO_CUSTODIAN: U64 = u64("0");
export const NO_UNDERWRITER: U64 = u64("0");
export const SHIFT_MARKET_ID: U8 = u8("64");

export class Collateral {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Collateral";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
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
          AtomicTypeTag.U128,
          new StructTag(new HexString("0x1"), "coin", "Coin", [
            new $.TypeParamIdx(0),
          ]),
        ]
      ),
    },
  ];

  map: Tablist.Tablist;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto["map"] as Tablist.Tablist;
  }

  static CollateralParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Collateral {
    const proto = $.parseStructProto(data, typeTag, repo, Collateral);
    return new Collateral(proto, typeTag);
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
      Collateral,
      typeParams
    );
    return result as unknown as Collateral;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Collateral,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Collateral;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Collateral", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.map.loadFullState(app);
    this.__app = app;
  }
}

export class MarketAccount {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MarketAccount";
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
    {
      name: "asks",
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
            "user",
            "Order",
            []
          ),
        ]
      ),
    },
    {
      name: "bids",
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
            "user",
            "Order",
            []
          ),
        ]
      ),
    },
    { name: "asks_stack_top", typeTag: AtomicTypeTag.U64 },
    { name: "bids_stack_top", typeTag: AtomicTypeTag.U64 },
    { name: "base_total", typeTag: AtomicTypeTag.U64 },
    { name: "base_available", typeTag: AtomicTypeTag.U64 },
    { name: "base_ceiling", typeTag: AtomicTypeTag.U64 },
    { name: "quote_total", typeTag: AtomicTypeTag.U64 },
    { name: "quote_available", typeTag: AtomicTypeTag.U64 },
    { name: "quote_ceiling", typeTag: AtomicTypeTag.U64 },
  ];

  base_type: Stdlib.Type_info.TypeInfo;
  base_name_generic: Stdlib.String.String;
  quote_type: Stdlib.Type_info.TypeInfo;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;
  asks: Tablist.Tablist;
  bids: Tablist.Tablist;
  asks_stack_top: U64;
  bids_stack_top: U64;
  base_total: U64;
  base_available: U64;
  base_ceiling: U64;
  quote_total: U64;
  quote_available: U64;
  quote_ceiling: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_type = proto["base_type"] as Stdlib.Type_info.TypeInfo;
    this.base_name_generic = proto["base_name_generic"] as Stdlib.String.String;
    this.quote_type = proto["quote_type"] as Stdlib.Type_info.TypeInfo;
    this.lot_size = proto["lot_size"] as U64;
    this.tick_size = proto["tick_size"] as U64;
    this.min_size = proto["min_size"] as U64;
    this.underwriter_id = proto["underwriter_id"] as U64;
    this.asks = proto["asks"] as Tablist.Tablist;
    this.bids = proto["bids"] as Tablist.Tablist;
    this.asks_stack_top = proto["asks_stack_top"] as U64;
    this.bids_stack_top = proto["bids_stack_top"] as U64;
    this.base_total = proto["base_total"] as U64;
    this.base_available = proto["base_available"] as U64;
    this.base_ceiling = proto["base_ceiling"] as U64;
    this.quote_total = proto["quote_total"] as U64;
    this.quote_available = proto["quote_available"] as U64;
    this.quote_ceiling = proto["quote_ceiling"] as U64;
  }

  static MarketAccountParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MarketAccount {
    const proto = $.parseStructProto(data, typeTag, repo, MarketAccount);
    return new MarketAccount(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "MarketAccount", []);
  }
  async loadFullState(app: $.AppType) {
    await this.base_type.loadFullState(app);
    await this.base_name_generic.loadFullState(app);
    await this.quote_type.loadFullState(app);
    await this.asks.loadFullState(app);
    await this.bids.loadFullState(app);
    this.__app = app;
  }
}

export class MarketAccounts {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MarketAccounts";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "map",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        AtomicTypeTag.U128,
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "user",
          "MarketAccount",
          []
        ),
      ]),
    },
    {
      name: "custodians",
      typeTag: new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "tablist",
        "Tablist",
        [AtomicTypeTag.U64, new VectorTag(AtomicTypeTag.U64)]
      ),
    },
  ];

  map: Stdlib.Table.Table;
  custodians: Tablist.Tablist;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto["map"] as Stdlib.Table.Table;
    this.custodians = proto["custodians"] as Tablist.Tablist;
  }

  static MarketAccountsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MarketAccounts {
    const proto = $.parseStructProto(data, typeTag, repo, MarketAccounts);
    return new MarketAccounts(proto, typeTag);
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
      MarketAccounts,
      typeParams
    );
    return result as unknown as MarketAccounts;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      MarketAccounts,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as MarketAccounts;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "MarketAccounts", []);
  }
  async loadFullState(app: $.AppType) {
    await this.map.loadFullState(app);
    await this.custodians.loadFullState(app);
    this.__app = app;
  }
}

export class Order {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Order";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "market_order_id", typeTag: AtomicTypeTag.U128 },
    { name: "size", typeTag: AtomicTypeTag.U64 },
  ];

  market_order_id: U128;
  size: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_order_id = proto["market_order_id"] as U128;
    this.size = proto["size"] as U64;
  }

  static OrderParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Order {
    const proto = $.parseStructProto(data, typeTag, repo, Order);
    return new Order(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Order", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function cancel_order_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  start_size: U64,
  price: U64,
  order_access_key: U64,
  market_order_id: U128,
  $c: AptosDataCache
): U128 {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    available_increment_amount,
    ceiling_decrement_amount,
    in_ceiling_ref_mut,
    market_account_id,
    market_account_ref_mut,
    market_accounts_map_ref_mut,
    order_ref_mut,
    orders_ref_mut,
    out_available_ref_mut,
    size,
    size_multiplier_available,
    size_multiplier_ceiling,
    stack_top_ref_mut;
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  market_account_ref_mut = Stdlib.Table.borrow_mut_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (side == $.copy(ASK)) {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6] = [
      market_account_ref_mut.asks,
      market_account_ref_mut.asks_stack_top,
      market_account_ref_mut.quote_ceiling,
      market_account_ref_mut.base_available,
      $.copy(price).mul($.copy(market_account_ref_mut.tick_size)),
      $.copy(market_account_ref_mut.lot_size),
    ];
  } else {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6] = [
      market_account_ref_mut.bids,
      market_account_ref_mut.bids_stack_top,
      market_account_ref_mut.base_ceiling,
      market_account_ref_mut.quote_available,
      $.copy(market_account_ref_mut.lot_size),
      $.copy(price).mul($.copy(market_account_ref_mut.tick_size)),
    ];
  }
  [
    orders_ref_mut,
    stack_top_ref_mut,
    in_ceiling_ref_mut,
    out_available_ref_mut,
    size_multiplier_ceiling,
    size_multiplier_available,
  ] = [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6];
  order_ref_mut = Tablist.borrow_mut_(
    orders_ref_mut,
    $.copy(order_access_key),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Order)]
  );
  size = $.copy(order_ref_mut.size);
  if (!$.copy(size).eq($.copy(start_size))) {
    throw $.abortCode($.copy(E_START_SIZE_MISMATCH));
  }
  if ($.copy(market_order_id).eq(u128($.copy(NIL)))) {
    market_order_id = $.copy(order_ref_mut.market_order_id);
  } else {
    if (!$.copy(order_ref_mut.market_order_id).eq($.copy(market_order_id))) {
      throw $.abortCode($.copy(E_INVALID_MARKET_ORDER_ID));
    }
  }
  order_ref_mut.market_order_id = u128($.copy(NIL));
  order_ref_mut.size = $.copy(stack_top_ref_mut);
  $.set(stack_top_ref_mut, $.copy(order_access_key));
  available_increment_amount = $.copy(size).mul(
    $.copy(size_multiplier_available)
  );
  $.set(
    out_available_ref_mut,
    $.copy(out_available_ref_mut).add($.copy(available_increment_amount))
  );
  ceiling_decrement_amount = $.copy(size).mul($.copy(size_multiplier_ceiling));
  $.set(
    in_ceiling_ref_mut,
    $.copy(in_ceiling_ref_mut).sub($.copy(ceiling_decrement_amount))
  );
  return $.copy(market_order_id);
}

export function change_order_size_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  start_size: U64,
  new_size: U64,
  price: U64,
  order_access_key: U64,
  market_order_id: U128,
  $c: AptosDataCache
): void {
  let temp$1,
    market_account_id,
    market_account_ref_mut,
    market_accounts_map_ref_mut,
    order_ref,
    orders_ref;
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  market_account_ref_mut = Stdlib.Table.borrow_mut_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (side == $.copy(ASK)) {
    temp$1 = market_account_ref_mut.asks;
  } else {
    temp$1 = market_account_ref_mut.bids;
  }
  orders_ref = temp$1;
  order_ref = Tablist.borrow_(orders_ref, $.copy(order_access_key), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(Order),
  ]);
  if (!$.copy(order_ref.size).neq($.copy(new_size))) {
    throw $.abortCode($.copy(E_CHANGE_ORDER_NO_CHANGE));
  }
  cancel_order_internal_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $.copy(start_size),
    $.copy(price),
    $.copy(order_access_key),
    $.copy(market_order_id),
    $c
  );
  place_order_internal_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $.copy(new_size),
    $.copy(price),
    $.copy(market_order_id),
    $.copy(order_access_key),
    $c
  );
  return;
}

export function deposit_asset_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  optional_coins: Stdlib.Option.Option,
  underwriter_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <AssetType>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    asset_type,
    available_ref_mut,
    ceiling_ref_mut,
    coins,
    collateral_map_ref_mut,
    collateral_ref_mut,
    has_market_account,
    market_account_id,
    market_account_ref_mut,
    market_accounts_map_ref_mut,
    total_ref_mut;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNTS));
  }
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  [temp$1, temp$2] = [market_accounts_map_ref_mut, $.copy(market_account_id)];
  has_market_account = Stdlib.Table.contains_(temp$1, temp$2, $c, [
    AtomicTypeTag.U128,
    new SimpleStructTag(MarketAccount),
  ]);
  if (!has_market_account) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNT));
  }
  market_account_ref_mut = Stdlib.Table.borrow_mut_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  asset_type = Stdlib.Type_info.type_of_($c, [$p[0]]);
  if ($.deep_eq($.copy(asset_type), $.copy(market_account_ref_mut.base_type))) {
    [temp$6, temp$7, temp$8] = [
      market_account_ref_mut.base_total,
      market_account_ref_mut.base_available,
      market_account_ref_mut.base_ceiling,
    ];
  } else {
    if (
      $.deep_eq($.copy(asset_type), $.copy(market_account_ref_mut.quote_type))
    ) {
      [temp$3, temp$4, temp$5] = [
        market_account_ref_mut.quote_total,
        market_account_ref_mut.quote_available,
        market_account_ref_mut.quote_ceiling,
      ];
    } else {
      throw $.abortCode($.copy(E_ASSET_NOT_IN_PAIR));
    }
    [temp$6, temp$7, temp$8] = [temp$3, temp$4, temp$5];
  }
  [total_ref_mut, available_ref_mut, ceiling_ref_mut] = [
    temp$6,
    temp$7,
    temp$8,
  ];
  if (
    !u128($.copy(ceiling_ref_mut))
      .add(u128($.copy(amount)))
      .le(u128($.copy(HI_64)))
  ) {
    throw $.abortCode($.copy(E_DEPOSIT_OVERFLOW_ASSET_CEILING));
  }
  $.set(total_ref_mut, $.copy(total_ref_mut).add($.copy(amount)));
  $.set(available_ref_mut, $.copy(available_ref_mut).add($.copy(amount)));
  $.set(ceiling_ref_mut, $.copy(ceiling_ref_mut).add($.copy(amount)));
  if (
    $.deep_eq(
      $.copy(asset_type),
      Stdlib.Type_info.type_of_($c, [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "GenericAsset",
          []
        ),
      ])
    )
  ) {
    if (
      !$.copy(underwriter_id).eq($.copy(market_account_ref_mut.underwriter_id))
    ) {
      throw $.abortCode($.copy(E_INVALID_UNDERWRITER));
    }
    Stdlib.Option.destroy_none_(optional_coins, $c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]);
  } else {
    coins = Stdlib.Option.destroy_some_(optional_coins, $c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]);
    if (!$.copy(amount).eq(Stdlib.Coin.value_(coins, $c, [$p[0]]))) {
      throw $.abortCode($.copy(E_COIN_AMOUNT_MISMATCH));
    }
    collateral_map_ref_mut = $c.borrow_global_mut<Collateral>(
      new SimpleStructTag(Collateral, [$p[0]]),
      $.copy(user_address)
    ).map;
    collateral_ref_mut = Tablist.borrow_mut_(
      collateral_map_ref_mut,
      $.copy(market_account_id),
      $c,
      [
        AtomicTypeTag.U128,
        new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
      ]
    );
    Stdlib.Coin.merge_(collateral_ref_mut, coins, $c, [$p[0]]);
  }
  return;
}

export function deposit_assets_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  base_amount: U64,
  optional_base_coins: Stdlib.Option.Option,
  quote_coins: Stdlib.Coin.Coin,
  underwriter_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  deposit_asset_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    $.copy(base_amount),
    optional_base_coins,
    $.copy(underwriter_id),
    $c,
    [$p[0]]
  );
  deposit_coins_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    quote_coins,
    $c,
    [$p[1]]
  );
  return;
}

export function deposit_coins_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let coin_type_is_generic_asset;
  coin_type_is_generic_asset = $.deep_eq(
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    Stdlib.Type_info.type_of_($c, [
      new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "registry",
        "GenericAsset",
        []
      ),
    ])
  );
  if (coin_type_is_generic_asset) {
    throw $.abortCode($.copy(E_COIN_TYPE_IS_GENERIC_ASSET));
  }
  deposit_asset_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    Stdlib.Coin.value_(coins, $c, [$p[0]]),
    Stdlib.Option.some_(coins, $c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]),
    $.copy(NO_UNDERWRITER),
    $c,
    [$p[0]]
  );
  return;
}

export function deposit_from_coinstore_(
  user: HexString,
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  deposit_coins_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(custodian_id),
    Stdlib.Coin.withdraw_(user, $.copy(amount), $c, [$p[0]]),
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_deposit_from_coinstore(
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  $p: TypeTag[] /* <CoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "user",
    "deposit_from_coinstore",
    typeParamStrings,
    [market_id, custodian_id, amount],
    isJSON
  );
}

export function deposit_generic_asset_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  underwriter_capability_ref: Registry.UnderwriterCapability,
  $c: AptosDataCache
): void {
  deposit_asset_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    $.copy(amount),
    Stdlib.Option.none_($c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "GenericAsset",
          []
        ),
      ]),
    ]),
    Registry.get_underwriter_id_(underwriter_capability_ref, $c),
    $c,
    [
      new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "registry",
        "GenericAsset",
        []
      ),
    ]
  );
  return;
}

export function fill_order_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  order_access_key: U64,
  start_size: U64,
  fill_size: U64,
  complete_fill: boolean,
  optional_base_coins: Stdlib.Option.Option,
  quote_coins: Stdlib.Coin.Coin,
  base_to_route: U64,
  quote_to_route: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [Stdlib.Option.Option, Stdlib.Coin.Coin, U128] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    asset_in,
    asset_in_available_ref_mut,
    asset_in_total_ref_mut,
    asset_out,
    asset_out_ceiling_ref_mut,
    asset_out_total_ref_mut,
    base_coins_ref_mut,
    collateral_map_ref_mut,
    collateral_map_ref_mut__9,
    collateral_ref_mut,
    collateral_ref_mut__10,
    market_account_id,
    market_account_ref_mut,
    market_accounts_map_ref_mut,
    market_order_id,
    order_ref_mut,
    orders_ref_mut,
    stack_top_ref_mut;
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  market_account_ref_mut = Stdlib.Table.borrow_mut_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (side == $.copy(ASK)) {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8] = [
      market_account_ref_mut.asks,
      market_account_ref_mut.asks_stack_top,
      $.copy(quote_to_route),
      market_account_ref_mut.quote_total,
      market_account_ref_mut.quote_available,
      $.copy(base_to_route),
      market_account_ref_mut.base_total,
      market_account_ref_mut.base_ceiling,
    ];
  } else {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8] = [
      market_account_ref_mut.bids,
      market_account_ref_mut.bids_stack_top,
      $.copy(base_to_route),
      market_account_ref_mut.base_total,
      market_account_ref_mut.base_available,
      $.copy(quote_to_route),
      market_account_ref_mut.quote_total,
      market_account_ref_mut.quote_ceiling,
    ];
  }
  [
    orders_ref_mut,
    stack_top_ref_mut,
    asset_in,
    asset_in_total_ref_mut,
    asset_in_available_ref_mut,
    asset_out,
    asset_out_total_ref_mut,
    asset_out_ceiling_ref_mut,
  ] = [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8];
  order_ref_mut = Tablist.borrow_mut_(
    orders_ref_mut,
    $.copy(order_access_key),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(Order)]
  );
  market_order_id = $.copy(order_ref_mut.market_order_id);
  if (!$.copy(order_ref_mut.size).eq($.copy(start_size))) {
    throw $.abortCode($.copy(E_START_SIZE_MISMATCH));
  }
  if (complete_fill) {
    order_ref_mut.market_order_id = u128($.copy(NIL));
    order_ref_mut.size = $.copy(stack_top_ref_mut);
    $.set(stack_top_ref_mut, $.copy(order_access_key));
  } else {
    order_ref_mut.size = $.copy(order_ref_mut.size).sub($.copy(fill_size));
  }
  $.set(
    asset_in_total_ref_mut,
    $.copy(asset_in_total_ref_mut).add($.copy(asset_in))
  );
  $.set(
    asset_in_available_ref_mut,
    $.copy(asset_in_available_ref_mut).add($.copy(asset_in))
  );
  $.set(
    asset_out_total_ref_mut,
    $.copy(asset_out_total_ref_mut).sub($.copy(asset_out))
  );
  $.set(
    asset_out_ceiling_ref_mut,
    $.copy(asset_out_ceiling_ref_mut).sub($.copy(asset_out))
  );
  if (
    Stdlib.Option.is_some_(optional_base_coins, $c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ])
  ) {
    collateral_map_ref_mut = $c.borrow_global_mut<Collateral>(
      new SimpleStructTag(Collateral, [$p[0]]),
      $.copy(user_address)
    ).map;
    collateral_ref_mut = Tablist.borrow_mut_(
      collateral_map_ref_mut,
      $.copy(market_account_id),
      $c,
      [
        AtomicTypeTag.U128,
        new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
      ]
    );
    base_coins_ref_mut = Stdlib.Option.borrow_mut_(optional_base_coins, $c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]);
    if (side == $.copy(ASK)) {
      Stdlib.Coin.merge_(
        base_coins_ref_mut,
        Stdlib.Coin.extract_(collateral_ref_mut, $.copy(base_to_route), $c, [
          $p[0],
        ]),
        $c,
        [$p[0]]
      );
    } else {
      Stdlib.Coin.merge_(
        collateral_ref_mut,
        Stdlib.Coin.extract_(base_coins_ref_mut, $.copy(base_to_route), $c, [
          $p[0],
        ]),
        $c,
        [$p[0]]
      );
    }
  } else {
  }
  collateral_map_ref_mut__9 = $c.borrow_global_mut<Collateral>(
    new SimpleStructTag(Collateral, [$p[1]]),
    $.copy(user_address)
  ).map;
  collateral_ref_mut__10 = Tablist.borrow_mut_(
    collateral_map_ref_mut__9,
    $.copy(market_account_id),
    $c,
    [
      AtomicTypeTag.U128,
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[1]]),
    ]
  );
  if (side == $.copy(ASK)) {
    Stdlib.Coin.merge_(
      collateral_ref_mut__10,
      Stdlib.Coin.extract_(quote_coins, $.copy(quote_to_route), $c, [$p[1]]),
      $c,
      [$p[1]]
    );
  } else {
    Stdlib.Coin.merge_(
      quote_coins,
      Stdlib.Coin.extract_(collateral_ref_mut__10, $.copy(quote_to_route), $c, [
        $p[1],
      ]),
      $c,
      [$p[1]]
    );
  }
  return [optional_base_coins, quote_coins, $.copy(market_order_id)];
}

export function get_ASK_($c: AptosDataCache): boolean {
  return $.copy(ASK);
}

export function get_BID_($c: AptosDataCache): boolean {
  return $.copy(BID);
}

export function get_NO_CUSTODIAN_($c: AptosDataCache): U64 {
  return $.copy(NO_CUSTODIAN);
}

export function get_active_market_order_ids_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  $c: AptosDataCache
): U128[] {
  let temp$1,
    i,
    market_account_id,
    market_account_ref,
    market_accounts_map_ref,
    market_order_ids,
    n,
    order_ref,
    orders_ref;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNTS));
  }
  market_accounts_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  if (
    !Stdlib.Table.contains_(
      market_accounts_map_ref,
      $.copy(market_account_id),
      $c,
      [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
    )
  ) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNT));
  }
  market_account_ref = Stdlib.Table.borrow_(
    market_accounts_map_ref,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (side == $.copy(ASK)) {
    temp$1 = market_account_ref.asks;
  } else {
    temp$1 = market_account_ref.bids;
  }
  orders_ref = temp$1;
  market_order_ids = Stdlib.Vector.empty_($c, [AtomicTypeTag.U128]);
  [i, n] = [
    u64("1"),
    Tablist.length_(orders_ref, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(Order),
    ]),
  ];
  while ($.copy(i).le($.copy(n))) {
    {
      order_ref = Tablist.borrow_(orders_ref, $.copy(i), $c, [
        AtomicTypeTag.U64,
        new SimpleStructTag(Order),
      ]);
      if ($.copy(order_ref.market_order_id).neq(u128($.copy(NIL)))) {
        Stdlib.Vector.push_back_(
          market_order_ids,
          $.copy(order_ref.market_order_id),
          $c,
          [AtomicTypeTag.U128]
        );
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return $.copy(market_order_ids);
}

export function get_all_market_account_ids_for_market_id_(
  user: HexString,
  market_id: U64,
  $c: AptosDataCache
): U128[] {
  let custodian_id,
    custodians_map_ref,
    custodians_ref,
    i,
    market_account_id,
    market_account_ids,
    n_custodians;
  market_account_ids = Stdlib.Vector.empty_($c, [AtomicTypeTag.U128]);
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user))) {
    return $.copy(market_account_ids);
  } else {
  }
  custodians_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user)
  ).custodians;
  if (
    !Tablist.contains_(custodians_map_ref, $.copy(market_id), $c, [
      AtomicTypeTag.U64,
      new VectorTag(AtomicTypeTag.U64),
    ])
  ) {
    return $.copy(market_account_ids);
  } else {
  }
  custodians_ref = Tablist.borrow_(custodians_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new VectorTag(AtomicTypeTag.U64),
  ]);
  [i, n_custodians] = [
    u64("0"),
    Stdlib.Vector.length_(custodians_ref, $c, [AtomicTypeTag.U64]),
  ];
  while ($.copy(i).lt($.copy(n_custodians))) {
    {
      custodian_id = $.copy(
        Stdlib.Vector.borrow_(custodians_ref, $.copy(i), $c, [
          AtomicTypeTag.U64,
        ])
      );
      market_account_id = u128($.copy(market_id))
        .shl($.copy(SHIFT_MARKET_ID))
        .or(u128($.copy(custodian_id)));
      Stdlib.Vector.push_back_(
        market_account_ids,
        $.copy(market_account_id),
        $c,
        [AtomicTypeTag.U128]
      );
      i = $.copy(i).add(u64("1"));
    }
  }
  return $.copy(market_account_ids);
}

export function get_all_market_account_ids_for_user_(
  user: HexString,
  $c: AptosDataCache
): U128[] {
  let custodian_id,
    custodians_map_ref,
    custodians_ref,
    i,
    market_account_id,
    market_account_ids,
    market_id,
    market_id_option,
    n_custodians,
    next;
  market_account_ids = Stdlib.Vector.empty_($c, [AtomicTypeTag.U128]);
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user))) {
    return $.copy(market_account_ids);
  } else {
  }
  custodians_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user)
  ).custodians;
  market_id_option = Tablist.get_head_key_(custodians_map_ref, $c, [
    AtomicTypeTag.U64,
    new VectorTag(AtomicTypeTag.U64),
  ]);
  while (Stdlib.Option.is_some_(market_id_option, $c, [AtomicTypeTag.U64])) {
    {
      market_id = $.copy(
        Stdlib.Option.borrow_(market_id_option, $c, [AtomicTypeTag.U64])
      );
      [custodians_ref, , next] = Tablist.borrow_iterable_(
        custodians_map_ref,
        $.copy(market_id),
        $c,
        [AtomicTypeTag.U64, new VectorTag(AtomicTypeTag.U64)]
      );
      [i, n_custodians] = [
        u64("0"),
        Stdlib.Vector.length_(custodians_ref, $c, [AtomicTypeTag.U64]),
      ];
      while ($.copy(i).lt($.copy(n_custodians))) {
        {
          custodian_id = $.copy(
            Stdlib.Vector.borrow_(custodians_ref, $.copy(i), $c, [
              AtomicTypeTag.U64,
            ])
          );
          market_account_id = u128($.copy(market_id))
            .shl($.copy(SHIFT_MARKET_ID))
            .or(u128($.copy(custodian_id)));
          Stdlib.Vector.push_back_(
            market_account_ids,
            $.copy(market_account_id),
            $c,
            [AtomicTypeTag.U128]
          );
          i = $.copy(i).add(u64("1"));
        }
      }
      market_id_option = $.copy(next);
    }
  }
  return $.copy(market_account_ids);
}

export function get_asset_counts_custodian_(
  user_address: HexString,
  market_id: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache
): [U64, U64, U64, U64, U64, U64] {
  return get_asset_counts_internal_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $c
  );
}

export function get_asset_counts_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  $c: AptosDataCache
): [U64, U64, U64, U64, U64, U64] {
  let market_account_id, market_account_ref, market_accounts_map_ref;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNTS));
  }
  market_accounts_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  if (
    !Stdlib.Table.contains_(
      market_accounts_map_ref,
      $.copy(market_account_id),
      $c,
      [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
    )
  ) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNT));
  }
  market_account_ref = Stdlib.Table.borrow_(
    market_accounts_map_ref,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  return [
    $.copy(market_account_ref.base_total),
    $.copy(market_account_ref.base_available),
    $.copy(market_account_ref.base_ceiling),
    $.copy(market_account_ref.quote_total),
    $.copy(market_account_ref.quote_available),
    $.copy(market_account_ref.quote_ceiling),
  ];
}

export function get_asset_counts_user_(
  user: HexString,
  market_id: U64,
  $c: AptosDataCache
): [U64, U64, U64, U64, U64, U64] {
  return get_asset_counts_internal_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $c
  );
}

export function get_custodian_id_(
  market_account_id: U128,
  $c: AptosDataCache
): U64 {
  return u64($.copy(market_account_id).and(u128($.copy(HI_64))));
}

export function get_market_account_id_(
  market_id: U64,
  custodian_id: U64,
  $c: AptosDataCache
): U128 {
  return u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
}

export function get_market_account_market_info_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  $c: AptosDataCache
): [
  Stdlib.Type_info.TypeInfo,
  Stdlib.String.String,
  Stdlib.Type_info.TypeInfo,
  U64,
  U64,
  U64,
  U64
] {
  let market_account_id, market_account_ref, market_accounts_map_ref;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNTS));
  }
  market_accounts_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  if (
    !Stdlib.Table.contains_(
      market_accounts_map_ref,
      $.copy(market_account_id),
      $c,
      [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
    )
  ) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNT));
  }
  market_account_ref = Stdlib.Table.borrow_(
    market_accounts_map_ref,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  return [
    $.copy(market_account_ref.base_type),
    $.copy(market_account_ref.base_name_generic),
    $.copy(market_account_ref.quote_type),
    $.copy(market_account_ref.lot_size),
    $.copy(market_account_ref.tick_size),
    $.copy(market_account_ref.min_size),
    $.copy(market_account_ref.underwriter_id),
  ];
}

export function get_market_account_market_info_custodian_(
  user_address: HexString,
  market_id: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache
): [
  Stdlib.Type_info.TypeInfo,
  Stdlib.String.String,
  Stdlib.Type_info.TypeInfo,
  U64,
  U64,
  U64,
  U64
] {
  return get_market_account_market_info_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $c
  );
}

export function get_market_account_market_info_user_(
  user: HexString,
  market_id: U64,
  $c: AptosDataCache
): [
  Stdlib.Type_info.TypeInfo,
  Stdlib.String.String,
  Stdlib.Type_info.TypeInfo,
  U64,
  U64,
  U64,
  U64
] {
  return get_market_account_market_info_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $c
  );
}

export function get_market_id_(
  market_account_id: U128,
  $c: AptosDataCache
): U64 {
  return u64($.copy(market_account_id).shr($.copy(SHIFT_MARKET_ID)));
}

export function get_next_order_access_key_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  $c: AptosDataCache
): U64 {
  let temp$1,
    temp$2,
    temp$3,
    has_market_account,
    market_account_id,
    market_account_ref,
    market_accounts_map_ref,
    orders_ref,
    stack_top_ref;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNTS));
  }
  market_accounts_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  has_market_account = Stdlib.Table.contains_(
    market_accounts_map_ref,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (!has_market_account) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNT));
  }
  market_account_ref = Stdlib.Table.borrow_(
    market_accounts_map_ref,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (side == $.copy(ASK)) {
    [temp$1, temp$2] = [
      market_account_ref.asks,
      market_account_ref.asks_stack_top,
    ];
  } else {
    [temp$1, temp$2] = [
      market_account_ref.bids,
      market_account_ref.bids_stack_top,
    ];
  }
  [orders_ref, stack_top_ref] = [temp$1, temp$2];
  if ($.copy(stack_top_ref).eq($.copy(NIL))) {
    temp$3 = Tablist.length_(orders_ref, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(Order),
    ]).add(u64("1"));
  } else {
    temp$3 = $.copy(stack_top_ref);
  }
  return temp$3;
}

export function has_market_account_by_market_account_id_(
  user: HexString,
  market_account_id: U128,
  $c: AptosDataCache
): boolean {
  let market_accounts_map;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user))) {
    return false;
  } else {
  }
  market_accounts_map = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user)
  ).map;
  return Stdlib.Table.contains_(
    market_accounts_map,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
}

export function has_market_account_by_market_id_(
  user: HexString,
  market_id: U64,
  $c: AptosDataCache
): boolean {
  let custodians_map_ref;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user))) {
    return false;
  } else {
  }
  custodians_map_ref = $c.borrow_global<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user)
  ).custodians;
  return Tablist.contains_(custodians_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new VectorTag(AtomicTypeTag.U64),
  ]);
}

export function place_order_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  size: U64,
  price: U64,
  market_order_id: U128,
  order_access_key_expected: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$8,
    base_fill,
    in_ceiling_ref_mut,
    in_fill,
    market_account_id,
    market_account_ref_mut,
    market_accounts_map_ref_mut,
    order_access_key,
    order_access_key__7,
    order_access_key__9,
    order_ref_mut,
    orders_ref_mut,
    out_available_ref_mut,
    out_fill,
    quote_fill,
    stack_top_ref_mut,
    ticks;
  if (!$.copy(price).gt(u64("0"))) {
    throw $.abortCode($.copy(E_PRICE_0));
  }
  if (!$.copy(price).le($.copy(HI_PRICE))) {
    throw $.abortCode($.copy(E_PRICE_TOO_HIGH));
  }
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  market_account_ref_mut = Stdlib.Table.borrow_mut_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  if (!$.copy(size).ge($.copy(market_account_ref_mut.min_size))) {
    throw $.abortCode($.copy(E_SIZE_TOO_LOW));
  }
  base_fill = u128($.copy(size)).mul(
    u128($.copy(market_account_ref_mut.lot_size))
  );
  ticks = u128($.copy(size)).mul(u128($.copy(price)));
  if (!$.copy(ticks).le(u128($.copy(HI_64)))) {
    throw $.abortCode($.copy(E_TICKS_OVERFLOW));
  }
  quote_fill = $.copy(ticks).mul(
    u128($.copy(market_account_ref_mut.tick_size))
  );
  if (side == $.copy(ASK)) {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6] = [
      market_account_ref_mut.asks,
      market_account_ref_mut.asks_stack_top,
      market_account_ref_mut.quote_ceiling,
      market_account_ref_mut.base_available,
      $.copy(quote_fill),
      $.copy(base_fill),
    ];
  } else {
    [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6] = [
      market_account_ref_mut.bids,
      market_account_ref_mut.bids_stack_top,
      market_account_ref_mut.base_ceiling,
      market_account_ref_mut.quote_available,
      $.copy(base_fill),
      $.copy(quote_fill),
    ];
  }
  [
    orders_ref_mut,
    stack_top_ref_mut,
    in_ceiling_ref_mut,
    out_available_ref_mut,
    in_fill,
    out_fill,
  ] = [temp$1, temp$2, temp$3, temp$4, temp$5, temp$6];
  if (
    !$.copy(in_fill)
      .add(u128($.copy(in_ceiling_ref_mut)))
      .le(u128($.copy(HI_64)))
  ) {
    throw $.abortCode($.copy(E_OVERFLOW_ASSET_IN));
  }
  if (!$.copy(out_fill).le(u128($.copy(out_available_ref_mut)))) {
    throw $.abortCode($.copy(E_NOT_ENOUGH_ASSET_OUT));
  }
  $.set(
    in_ceiling_ref_mut,
    $.copy(in_ceiling_ref_mut).add(u64($.copy(in_fill)))
  );
  $.set(
    out_available_ref_mut,
    $.copy(out_available_ref_mut).sub(u64($.copy(out_fill)))
  );
  if ($.copy(stack_top_ref_mut).eq($.copy(NIL))) {
    order_access_key = Tablist.length_(orders_ref_mut, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(Order),
    ]).add(u64("1"));
    Tablist.add_(
      orders_ref_mut,
      $.copy(order_access_key),
      new Order(
        { market_order_id: $.copy(market_order_id), size: $.copy(size) },
        new SimpleStructTag(Order)
      ),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(Order)]
    );
    temp$8 = $.copy(order_access_key);
  } else {
    order_access_key__7 = $.copy(stack_top_ref_mut);
    order_ref_mut = Tablist.borrow_mut_(
      orders_ref_mut,
      $.copy(order_access_key__7),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(Order)]
    );
    $.set(stack_top_ref_mut, $.copy(order_ref_mut.size));
    order_ref_mut.market_order_id = $.copy(market_order_id);
    order_ref_mut.size = $.copy(size);
    temp$8 = $.copy(order_access_key__7);
  }
  order_access_key__9 = temp$8;
  if (!$.copy(order_access_key__9).eq($.copy(order_access_key_expected))) {
    throw $.abortCode($.copy(E_ACCESS_KEY_MISMATCH));
  }
  return;
}

export function register_market_account_(
  user: HexString,
  market_id: U64,
  custodian_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  let market_account_id;
  if ($.copy(custodian_id).neq($.copy(NO_CUSTODIAN))) {
    if (!Registry.is_registered_custodian_id_($.copy(custodian_id), $c)) {
      throw $.abortCode($.copy(E_UNREGISTERED_CUSTODIAN));
    }
  } else {
  }
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  register_market_account_account_entries_(
    user,
    $.copy(market_account_id),
    $.copy(market_id),
    $.copy(custodian_id),
    $c,
    [$p[0], $p[1]]
  );
  if (Stdlib.Coin.is_coin_initialized_($c, [$p[0]])) {
    register_market_account_collateral_entry_(
      user,
      $.copy(market_account_id),
      $c,
      [$p[0]]
    );
  } else {
  }
  register_market_account_collateral_entry_(
    user,
    $.copy(market_account_id),
    $c,
    [$p[1]]
  );
  return;
}

export function buildPayload_register_market_account(
  market_id: U64,
  custodian_id: U64,
  $p: TypeTag[] /* <BaseType, QuoteType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "user",
    "register_market_account",
    typeParamStrings,
    [market_id, custodian_id],
    isJSON
  );
}

export function register_market_account_account_entries_(
  user: HexString,
  market_account_id: U128,
  market_id: U64,
  custodian_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    base_name_generic,
    base_type,
    custodians_ref_mut,
    lot_size,
    market_accounts_map_ref_mut,
    market_custodians_ref_mut,
    min_size,
    quote_type,
    tick_size,
    underwriter_id,
    user_address;
  user_address = Stdlib.Signer.address_of_(user, $c);
  [base_type, quote_type] = [
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    Stdlib.Type_info.type_of_($c, [$p[1]]),
  ];
  [base_name_generic, lot_size, tick_size, min_size, underwriter_id] =
    Registry.get_market_info_for_market_account_(
      $.copy(market_id),
      $.copy(base_type),
      $.copy(quote_type),
      $c
    );
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    $c.move_to(
      new SimpleStructTag(MarketAccounts),
      user,
      new MarketAccounts(
        {
          map: Stdlib.Table.new___($c, [
            AtomicTypeTag.U128,
            new SimpleStructTag(MarketAccount),
          ]),
          custodians: Tablist.new___($c, [
            AtomicTypeTag.U64,
            new VectorTag(AtomicTypeTag.U64),
          ]),
        },
        new SimpleStructTag(MarketAccounts)
      )
    );
  } else {
  }
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  [temp$1, temp$2] = [market_accounts_map_ref_mut, $.copy(market_account_id)];
  if (
    Stdlib.Table.contains_(temp$1, temp$2, $c, [
      AtomicTypeTag.U128,
      new SimpleStructTag(MarketAccount),
    ])
  ) {
    throw $.abortCode($.copy(E_EXISTS_MARKET_ACCOUNT));
  }
  Stdlib.Table.add_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    new MarketAccount(
      {
        base_type: $.copy(base_type),
        base_name_generic: $.copy(base_name_generic),
        quote_type: $.copy(quote_type),
        lot_size: $.copy(lot_size),
        tick_size: $.copy(tick_size),
        min_size: $.copy(min_size),
        underwriter_id: $.copy(underwriter_id),
        asks: Tablist.new___($c, [
          AtomicTypeTag.U64,
          new SimpleStructTag(Order),
        ]),
        bids: Tablist.new___($c, [
          AtomicTypeTag.U64,
          new SimpleStructTag(Order),
        ]),
        asks_stack_top: $.copy(NIL),
        bids_stack_top: $.copy(NIL),
        base_total: u64("0"),
        base_available: u64("0"),
        base_ceiling: u64("0"),
        quote_total: u64("0"),
        quote_available: u64("0"),
        quote_ceiling: u64("0"),
      },
      new SimpleStructTag(MarketAccount)
    ),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  custodians_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).custodians;
  [temp$3, temp$4] = [custodians_ref_mut, $.copy(market_id)];
  if (
    !Tablist.contains_(temp$3, temp$4, $c, [
      AtomicTypeTag.U64,
      new VectorTag(AtomicTypeTag.U64),
    ])
  ) {
    Tablist.add_(
      custodians_ref_mut,
      $.copy(market_id),
      Stdlib.Vector.singleton_($.copy(custodian_id), $c, [AtomicTypeTag.U64]),
      $c,
      [AtomicTypeTag.U64, new VectorTag(AtomicTypeTag.U64)]
    );
  } else {
    market_custodians_ref_mut = Tablist.borrow_mut_(
      custodians_ref_mut,
      $.copy(market_id),
      $c,
      [AtomicTypeTag.U64, new VectorTag(AtomicTypeTag.U64)]
    );
    Stdlib.Vector.push_back_(
      market_custodians_ref_mut,
      $.copy(custodian_id),
      $c,
      [AtomicTypeTag.U64]
    );
  }
  return;
}

export function register_market_account_collateral_entry_(
  user: HexString,
  market_account_id: U128,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let collateral_map_ref_mut, user_address;
  user_address = Stdlib.Signer.address_of_(user, $c);
  if (
    !$c.exists(new SimpleStructTag(Collateral, [$p[0]]), $.copy(user_address))
  ) {
    $c.move_to(
      new SimpleStructTag(Collateral, [$p[0]]),
      user,
      new Collateral(
        {
          map: Tablist.new___($c, [
            AtomicTypeTag.U128,
            new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
          ]),
        },
        new SimpleStructTag(Collateral, [$p[0]])
      )
    );
  } else {
  }
  collateral_map_ref_mut = $c.borrow_global_mut<Collateral>(
    new SimpleStructTag(Collateral, [$p[0]]),
    $.copy(user_address)
  ).map;
  Tablist.add_(
    collateral_map_ref_mut,
    $.copy(market_account_id),
    Stdlib.Coin.zero_($c, [$p[0]]),
    $c,
    [
      AtomicTypeTag.U128,
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]
  );
  return;
}

export function register_market_account_generic_base_(
  user: HexString,
  market_id: U64,
  custodian_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteType>*/
): void {
  register_market_account_(user, $.copy(market_id), $.copy(custodian_id), $c, [
    new StructTag(
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ),
      "registry",
      "GenericAsset",
      []
    ),
    $p[0],
  ]);
  return;
}

export function buildPayload_register_market_account_generic_base(
  market_id: U64,
  custodian_id: U64,
  $p: TypeTag[] /* <QuoteType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "user",
    "register_market_account_generic_base",
    typeParamStrings,
    [market_id, custodian_id],
    isJSON
  );
}

export function withdraw_asset_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  underwriter_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <AssetType>*/
): Stdlib.Option.Option {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    asset_type,
    available_ref_mut,
    ceiling_ref_mut,
    collateral_map_ref_mut,
    collateral_ref_mut,
    has_market_account,
    market_account_id,
    market_account_ref_mut,
    market_accounts_map_ref_mut,
    total_ref_mut;
  if (!$c.exists(new SimpleStructTag(MarketAccounts), $.copy(user_address))) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNTS));
  }
  market_accounts_map_ref_mut = $c.borrow_global_mut<MarketAccounts>(
    new SimpleStructTag(MarketAccounts),
    $.copy(user_address)
  ).map;
  market_account_id = u128($.copy(market_id))
    .shl($.copy(SHIFT_MARKET_ID))
    .or(u128($.copy(custodian_id)));
  [temp$1, temp$2] = [market_accounts_map_ref_mut, $.copy(market_account_id)];
  has_market_account = Stdlib.Table.contains_(temp$1, temp$2, $c, [
    AtomicTypeTag.U128,
    new SimpleStructTag(MarketAccount),
  ]);
  if (!has_market_account) {
    throw $.abortCode($.copy(E_NO_MARKET_ACCOUNT));
  }
  market_account_ref_mut = Stdlib.Table.borrow_mut_(
    market_accounts_map_ref_mut,
    $.copy(market_account_id),
    $c,
    [AtomicTypeTag.U128, new SimpleStructTag(MarketAccount)]
  );
  asset_type = Stdlib.Type_info.type_of_($c, [$p[0]]);
  if ($.deep_eq($.copy(asset_type), $.copy(market_account_ref_mut.base_type))) {
    [temp$6, temp$7, temp$8] = [
      market_account_ref_mut.base_total,
      market_account_ref_mut.base_available,
      market_account_ref_mut.base_ceiling,
    ];
  } else {
    if (
      $.deep_eq($.copy(asset_type), $.copy(market_account_ref_mut.quote_type))
    ) {
      [temp$3, temp$4, temp$5] = [
        market_account_ref_mut.quote_total,
        market_account_ref_mut.quote_available,
        market_account_ref_mut.quote_ceiling,
      ];
    } else {
      throw $.abortCode($.copy(E_ASSET_NOT_IN_PAIR));
    }
    [temp$6, temp$7, temp$8] = [temp$3, temp$4, temp$5];
  }
  [total_ref_mut, available_ref_mut, ceiling_ref_mut] = [
    temp$6,
    temp$7,
    temp$8,
  ];
  if (!$.copy(amount).le($.copy(available_ref_mut))) {
    throw $.abortCode($.copy(E_WITHDRAW_TOO_LITTLE_AVAILABLE));
  }
  $.set(total_ref_mut, $.copy(total_ref_mut).sub($.copy(amount)));
  $.set(available_ref_mut, $.copy(available_ref_mut).sub($.copy(amount)));
  $.set(ceiling_ref_mut, $.copy(ceiling_ref_mut).sub($.copy(amount)));
  if (
    $.deep_eq(
      $.copy(asset_type),
      Stdlib.Type_info.type_of_($c, [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "GenericAsset",
          []
        ),
      ])
    )
  ) {
    if (
      !$.copy(underwriter_id).eq($.copy(market_account_ref_mut.underwriter_id))
    ) {
      throw $.abortCode($.copy(E_INVALID_UNDERWRITER));
    }
    temp$9 = Stdlib.Option.none_($c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]);
  } else {
    collateral_map_ref_mut = $c.borrow_global_mut<Collateral>(
      new SimpleStructTag(Collateral, [$p[0]]),
      $.copy(user_address)
    ).map;
    collateral_ref_mut = Tablist.borrow_mut_(
      collateral_map_ref_mut,
      $.copy(market_account_id),
      $c,
      [
        AtomicTypeTag.U128,
        new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
      ]
    );
    temp$9 = Stdlib.Option.some_(
      Stdlib.Coin.extract_(collateral_ref_mut, $.copy(amount), $c, [$p[0]]),
      $c,
      [new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]
    );
  }
  return temp$9;
}

export function withdraw_assets_internal_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  base_amount: U64,
  quote_amount: U64,
  underwriter_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [Stdlib.Option.Option, Stdlib.Coin.Coin] {
  return [
    withdraw_asset_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $.copy(base_amount),
      $.copy(underwriter_id),
      $c,
      [$p[0]]
    ),
    withdraw_coins_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $.copy(quote_amount),
      $c,
      [$p[1]]
    ),
  ];
}

export function withdraw_coins_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Stdlib.Coin.Coin {
  return Stdlib.Option.destroy_some_(
    withdraw_asset_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $.copy(amount),
      $.copy(NO_UNDERWRITER),
      $c,
      [$p[0]]
    ),
    $c,
    [new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]
  );
}

export function withdraw_coins_custodian_(
  user_address: HexString,
  market_id: U64,
  amount: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Stdlib.Coin.Coin {
  return withdraw_coins_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $.copy(amount),
    $c,
    [$p[0]]
  );
}

export function withdraw_coins_user_(
  user: HexString,
  market_id: U64,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): Stdlib.Coin.Coin {
  return withdraw_coins_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $.copy(amount),
    $c,
    [$p[0]]
  );
}

export function withdraw_generic_asset_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  amount: U64,
  underwriter_capability_ref: Registry.UnderwriterCapability,
  $c: AptosDataCache
): void {
  return Stdlib.Option.destroy_none_(
    withdraw_asset_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $.copy(amount),
      Registry.get_underwriter_id_(underwriter_capability_ref, $c),
      $c,
      [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "GenericAsset",
          []
        ),
      ]
    ),
    $c,
    [
      new StructTag(new HexString("0x1"), "coin", "Coin", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "registry",
          "GenericAsset",
          []
        ),
      ]),
    ]
  );
}

export function withdraw_generic_asset_custodian_(
  user_address: HexString,
  market_id: U64,
  amount: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  underwriter_capability_ref: Registry.UnderwriterCapability,
  $c: AptosDataCache
): void {
  return withdraw_generic_asset_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $.copy(amount),
    underwriter_capability_ref,
    $c
  );
}

export function withdraw_generic_asset_user_(
  user: HexString,
  market_id: U64,
  amount: U64,
  underwriter_capability_ref: Registry.UnderwriterCapability,
  $c: AptosDataCache
): void {
  return withdraw_generic_asset_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $.copy(amount),
    underwriter_capability_ref,
    $c
  );
}

export function withdraw_to_coinstore_(
  user: HexString,
  market_id: U64,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  if (
    !Stdlib.Coin.is_account_registered_(
      Stdlib.Signer.address_of_(user, $c),
      $c,
      [$p[0]]
    )
  ) {
    Stdlib.Coin.register_(user, $c, [$p[0]]);
  } else {
  }
  Stdlib.Coin.deposit_(
    Stdlib.Signer.address_of_(user, $c),
    withdraw_coins_user_(user, $.copy(market_id), $.copy(amount), $c, [$p[0]]),
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_withdraw_to_coinstore(
  market_id: U64,
  amount: U64,
  $p: TypeTag[] /* <CoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "user",
    "withdraw_to_coinstore",
    typeParamStrings,
    [market_id, amount],
    isJSON
  );
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::user::Collateral",
    Collateral.CollateralParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::user::MarketAccount",
    MarketAccount.MarketAccountParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::user::MarketAccounts",
    MarketAccounts.MarketAccountsParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::user::Order",
    Order.OrderParser
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
  get Collateral() {
    return Collateral;
  }
  async loadCollateral(
    owner: HexString,
    $p: TypeTag[] /* <CoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await Collateral.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get MarketAccount() {
    return MarketAccount;
  }
  get MarketAccounts() {
    return MarketAccounts;
  }
  async loadMarketAccounts(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await MarketAccounts.load(
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
  get Order() {
    return Order;
  }
  payload_deposit_from_coinstore(
    market_id: U64,
    custodian_id: U64,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_deposit_from_coinstore(
      market_id,
      custodian_id,
      amount,
      $p,
      isJSON
    );
  }
  async deposit_from_coinstore(
    _account: AptosAccount,
    market_id: U64,
    custodian_id: U64,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_deposit_from_coinstore(
      market_id,
      custodian_id,
      amount,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_register_market_account(
    market_id: U64,
    custodian_id: U64,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_register_market_account(
      market_id,
      custodian_id,
      $p,
      isJSON
    );
  }
  async register_market_account(
    _account: AptosAccount,
    market_id: U64,
    custodian_id: U64,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_register_market_account(
      market_id,
      custodian_id,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_register_market_account_generic_base(
    market_id: U64,
    custodian_id: U64,
    $p: TypeTag[] /* <QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_register_market_account_generic_base(
      market_id,
      custodian_id,
      $p,
      isJSON
    );
  }
  async register_market_account_generic_base(
    _account: AptosAccount,
    market_id: U64,
    custodian_id: U64,
    $p: TypeTag[] /* <QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_register_market_account_generic_base(
      market_id,
      custodian_id,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw_to_coinstore(
    market_id: U64,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw_to_coinstore(market_id, amount, $p, isJSON);
  }
  async withdraw_to_coinstore(
    _account: AptosAccount,
    market_id: U64,
    amount: U64,
    $p: TypeTag[] /* <CoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw_to_coinstore(
      market_id,
      amount,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  app_get_ASK() {
    return get_ASK_(this.cache);
  }
  app_get_BID() {
    return get_BID_(this.cache);
  }
  app_get_NO_CUSTODIAN() {
    return get_NO_CUSTODIAN_(this.cache);
  }
  app_get_all_market_account_ids_for_market_id(
    user: HexString,
    market_id: U64
  ) {
    return get_all_market_account_ids_for_market_id_(
      user,
      market_id,
      this.cache
    );
  }
  app_get_all_market_account_ids_for_user(user: HexString) {
    return get_all_market_account_ids_for_user_(user, this.cache);
  }
  app_get_asset_counts_custodian(
    user_address: HexString,
    market_id: U64,
    custodian_capability_ref: Registry.CustodianCapability
  ) {
    return get_asset_counts_custodian_(
      user_address,
      market_id,
      custodian_capability_ref,
      this.cache
    );
  }
  app_get_asset_counts_user(market_id: U64) {
    return get_asset_counts_user_(market_id, this.cache);
  }
  app_get_custodian_id(market_account_id: U128) {
    return get_custodian_id_(market_account_id, this.cache);
  }
  app_get_market_account_id(market_id: U64, custodian_id: U64) {
    return get_market_account_id_(market_id, custodian_id, this.cache);
  }
  app_get_market_account_market_info_custodian(
    user_address: HexString,
    market_id: U64,
    custodian_capability_ref: Registry.CustodianCapability
  ) {
    return get_market_account_market_info_custodian_(
      user_address,
      market_id,
      custodian_capability_ref,
      this.cache
    );
  }
  app_get_market_account_market_info_user(market_id: U64) {
    return get_market_account_market_info_user_(market_id, this.cache);
  }
  app_get_market_id(market_account_id: U128) {
    return get_market_id_(market_account_id, this.cache);
  }
  app_has_market_account_by_market_account_id(
    user: HexString,
    market_account_id: U128
  ) {
    return has_market_account_by_market_account_id_(
      user,
      market_account_id,
      this.cache
    );
  }
  app_has_market_account_by_market_id(user: HexString, market_id: U64) {
    return has_market_account_by_market_id_(user, market_id, this.cache);
  }
}
