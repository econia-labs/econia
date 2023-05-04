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
import * as Avl_queue from "./avl_queue";
import * as Incentives from "./incentives";
import * as Registry from "./registry";
import * as Resource_account from "./resource_account";
import * as Tablist from "./tablist";
import * as User from "./user";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "market";

export const ABORT: U8 = u8("0");
export const ASCENDING = true;
export const ASK = true;
export const BID = false;
export const BUY = false;
export const CANCEL: U8 = u8("0");
export const CANCEL_BOTH: U8 = u8("1");
export const CANCEL_MAKER: U8 = u8("2");
export const CANCEL_TAKER: U8 = u8("3");
export const CHANGE: U8 = u8("1");
export const CRITICAL_HEIGHT: U8 = u8("18");
export const DESCENDING = false;
export const EVICT: U8 = u8("2");
export const E_FILL_OR_ABORT_NOT_CROSS_SPREAD: U64 = u64("25");
export const E_HEAD_KEY_PRICE_MISMATCH: U64 = u64("26");
export const E_INVALID_BASE: U64 = u64("7");
export const E_INVALID_CUSTODIAN: U64 = u64("23");
export const E_INVALID_MARKET_ID: U64 = u64("6");
export const E_INVALID_MARKET_ORDER_ID: U64 = u64("22");
export const E_INVALID_PERCENT: U64 = u64("29");
export const E_INVALID_QUOTE: U64 = u64("8");
export const E_INVALID_RESTRICTION: U64 = u64("18");
export const E_INVALID_SELF_MATCH_BEHAVIOR: U64 = u64("28");
export const E_INVALID_UNDERWRITER: U64 = u64("21");
export const E_INVALID_USER: U64 = u64("24");
export const E_MAX_BASE_0: U64 = u64("0");
export const E_MAX_QUOTE_0: U64 = u64("1");
export const E_MIN_BASE_EXCEEDS_MAX: U64 = u64("2");
export const E_MIN_BASE_NOT_TRADED: U64 = u64("9");
export const E_MIN_QUOTE_EXCEEDS_MAX: U64 = u64("3");
export const E_MIN_QUOTE_NOT_TRADED: U64 = u64("10");
export const E_NOT_ENOUGH_ASSET_OUT: U64 = u64("5");
export const E_NOT_SIMULATION_ACCOUNT: U64 = u64("27");
export const E_OVERFLOW_ASSET_IN: U64 = u64("4");
export const E_POST_OR_ABORT_CROSSES_SPREAD: U64 = u64("13");
export const E_PRICE_0: U64 = u64("11");
export const E_PRICE_TIME_PRIORITY_TOO_LOW: U64 = u64("20");
export const E_PRICE_TOO_HIGH: U64 = u64("12");
export const E_SELF_MATCH: U64 = u64("19");
export const E_SIZE_BASE_OVERFLOW: U64 = u64("15");
export const E_SIZE_PRICE_QUOTE_OVERFLOW: U64 = u64("17");
export const E_SIZE_PRICE_TICKS_OVERFLOW: U64 = u64("16");
export const E_SIZE_TOO_SMALL: U64 = u64("14");
export const FILL_OR_ABORT: U8 = u8("1");
export const HI_64: U64 = u64("18446744073709551615");
export const HI_PRICE: U64 = u64("4294967295");
export const IMMEDIATE_OR_CANCEL: U8 = u8("2");
export const MAX_POSSIBLE: U64 = u64("18446744073709551615");
export const NIL: U64 = u64("0");
export const NO_CUSTODIAN: U64 = u64("0");
export const NO_MARKET_ACCOUNT: HexString = new HexString("0x0");
export const NO_RESTRICTION: U8 = u8("0");
export const NO_UNDERWRITER: U64 = u64("0");
export const N_RESTRICTIONS: U8 = u8("3");
export const PERCENT = true;
export const PERCENT_100: U64 = u64("100");
export const PLACE: U8 = u8("3");
export const POST_OR_ABORT: U8 = u8("3");
export const SELL = true;
export const SHIFT_COUNTER: U8 = u8("64");
export const TICKS = false;

export class MakerEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MakerEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "market_id", typeTag: AtomicTypeTag.U64 },
    { name: "side", typeTag: AtomicTypeTag.Bool },
    { name: "market_order_id", typeTag: AtomicTypeTag.U128 },
    { name: "user", typeTag: AtomicTypeTag.Address },
    { name: "custodian_id", typeTag: AtomicTypeTag.U64 },
    { name: "type", typeTag: AtomicTypeTag.U8 },
    { name: "size", typeTag: AtomicTypeTag.U64 },
    { name: "price", typeTag: AtomicTypeTag.U64 },
  ];

  market_id: U64;
  side: boolean;
  market_order_id: U128;
  user: HexString;
  custodian_id: U64;
  type: U8;
  size: U64;
  price: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_id = proto["market_id"] as U64;
    this.side = proto["side"] as boolean;
    this.market_order_id = proto["market_order_id"] as U128;
    this.user = proto["user"] as HexString;
    this.custodian_id = proto["custodian_id"] as U64;
    this.type = proto["type"] as U8;
    this.size = proto["size"] as U64;
    this.price = proto["price"] as U64;
  }

  static MakerEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MakerEvent {
    const proto = $.parseStructProto(data, typeTag, repo, MakerEvent);
    return new MakerEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "MakerEvent", []);
  }
  async loadFullState(app: $.AppType) {
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
    { name: "size", typeTag: AtomicTypeTag.U64 },
    { name: "price", typeTag: AtomicTypeTag.U64 },
    { name: "user", typeTag: AtomicTypeTag.Address },
    { name: "custodian_id", typeTag: AtomicTypeTag.U64 },
    { name: "order_access_key", typeTag: AtomicTypeTag.U64 },
  ];

  size: U64;
  price: U64;
  user: HexString;
  custodian_id: U64;
  order_access_key: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.size = proto["size"] as U64;
    this.price = proto["price"] as U64;
    this.user = proto["user"] as HexString;
    this.custodian_id = proto["custodian_id"] as U64;
    this.order_access_key = proto["order_access_key"] as U64;
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

export class OrderBook {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "OrderBook";
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
        "avl_queue",
        "AVLqueue",
        [
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "market",
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
        "avl_queue",
        "AVLqueue",
        [
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "market",
            "Order",
            []
          ),
        ]
      ),
    },
    { name: "counter", typeTag: AtomicTypeTag.U64 },
    {
      name: "maker_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "market",
          "MakerEvent",
          []
        ),
      ]),
    },
    {
      name: "taker_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "market",
          "TakerEvent",
          []
        ),
      ]),
    },
  ];

  base_type: Stdlib.Type_info.TypeInfo;
  base_name_generic: Stdlib.String.String;
  quote_type: Stdlib.Type_info.TypeInfo;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;
  asks: Avl_queue.AVLqueue;
  bids: Avl_queue.AVLqueue;
  counter: U64;
  maker_events: Stdlib.Event.EventHandle;
  taker_events: Stdlib.Event.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.base_type = proto["base_type"] as Stdlib.Type_info.TypeInfo;
    this.base_name_generic = proto["base_name_generic"] as Stdlib.String.String;
    this.quote_type = proto["quote_type"] as Stdlib.Type_info.TypeInfo;
    this.lot_size = proto["lot_size"] as U64;
    this.tick_size = proto["tick_size"] as U64;
    this.min_size = proto["min_size"] as U64;
    this.underwriter_id = proto["underwriter_id"] as U64;
    this.asks = proto["asks"] as Avl_queue.AVLqueue;
    this.bids = proto["bids"] as Avl_queue.AVLqueue;
    this.counter = proto["counter"] as U64;
    this.maker_events = proto["maker_events"] as Stdlib.Event.EventHandle;
    this.taker_events = proto["taker_events"] as Stdlib.Event.EventHandle;
  }

  static OrderBookParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): OrderBook {
    const proto = $.parseStructProto(data, typeTag, repo, OrderBook);
    return new OrderBook(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "OrderBook", []);
  }
  async loadFullState(app: $.AppType) {
    await this.base_type.loadFullState(app);
    await this.base_name_generic.loadFullState(app);
    await this.quote_type.loadFullState(app);
    await this.asks.loadFullState(app);
    await this.bids.loadFullState(app);
    await this.maker_events.loadFullState(app);
    await this.taker_events.loadFullState(app);
    this.__app = app;
  }
}

export class OrderBooks {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "OrderBooks";
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
          AtomicTypeTag.U64,
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "market",
            "OrderBook",
            []
          ),
        ]
      ),
    },
  ];

  map: Tablist.Tablist;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto["map"] as Tablist.Tablist;
  }

  static OrderBooksParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): OrderBooks {
    const proto = $.parseStructProto(data, typeTag, repo, OrderBooks);
    return new OrderBooks(proto, typeTag);
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
      OrderBooks,
      typeParams
    );
    return result as unknown as OrderBooks;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      OrderBooks,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as OrderBooks;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "OrderBooks", []);
  }
  async loadFullState(app: $.AppType) {
    await this.map.loadFullState(app);
    this.__app = app;
  }
}

export class Orders {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Orders";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "asks",
      typeTag: new VectorTag(
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "market",
          "Order",
          []
        )
      ),
    },
    {
      name: "bids",
      typeTag: new VectorTag(
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "market",
          "Order",
          []
        )
      ),
    },
  ];

  asks: Order[];
  bids: Order[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.asks = proto["asks"] as Order[];
    this.bids = proto["bids"] as Order[];
  }

  static OrdersParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Orders {
    const proto = $.parseStructProto(data, typeTag, repo, Orders);
    return new Orders(proto, typeTag);
  }

  static async load(
    repo: AptosParserRepo,
    client: AptosClient,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await repo.loadResource(client, address, Orders, typeParams);
    return result as unknown as Orders;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Orders,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Orders;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Orders", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class TakerEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "TakerEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "market_id", typeTag: AtomicTypeTag.U64 },
    { name: "side", typeTag: AtomicTypeTag.Bool },
    { name: "market_order_id", typeTag: AtomicTypeTag.U128 },
    { name: "maker", typeTag: AtomicTypeTag.Address },
    { name: "custodian_id", typeTag: AtomicTypeTag.U64 },
    { name: "size", typeTag: AtomicTypeTag.U64 },
    { name: "price", typeTag: AtomicTypeTag.U64 },
  ];

  market_id: U64;
  side: boolean;
  market_order_id: U128;
  maker: HexString;
  custodian_id: U64;
  size: U64;
  price: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.market_id = proto["market_id"] as U64;
    this.side = proto["side"] as boolean;
    this.market_order_id = proto["market_order_id"] as U128;
    this.maker = proto["maker"] as HexString;
    this.custodian_id = proto["custodian_id"] as U64;
    this.size = proto["size"] as U64;
    this.price = proto["price"] as U64;
  }

  static TakerEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): TakerEvent {
    const proto = $.parseStructProto(data, typeTag, repo, TakerEvent);
    return new TakerEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "TakerEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function cancel_all_orders_(
  user: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  $c: AptosDataCache
): void {
  let i, market_order_ids, n_orders;
  market_order_ids = User.get_active_market_order_ids_internal_(
    $.copy(user),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $c
  );
  [n_orders, i] = [
    Stdlib.Vector.length_(market_order_ids, $c, [AtomicTypeTag.U128]),
    u64("0"),
  ];
  while ($.copy(i).lt($.copy(n_orders))) {
    {
      cancel_order_(
        $.copy(user),
        $.copy(market_id),
        $.copy(custodian_id),
        side,
        $.copy(
          Stdlib.Vector.borrow_(market_order_ids, $.copy(i), $c, [
            AtomicTypeTag.U128,
          ])
        ),
        $c
      );
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function cancel_all_orders_custodian_(
  user_address: HexString,
  market_id: U64,
  side: boolean,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache
): void {
  cancel_all_orders_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    side,
    $c
  );
  return;
}

export function cancel_all_orders_user_(
  user: HexString,
  market_id: U64,
  side: boolean,
  $c: AptosDataCache
): void {
  cancel_all_orders_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    side,
    $c
  );
  return;
}

export function buildPayload_cancel_all_orders_user(
  market_id: U64,
  side: boolean,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "market",
    "cancel_all_orders_user",
    typeParamStrings,
    [market_id, side],
    isJSON
  );
}

export function cancel_order_(
  user: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  market_order_id: U128,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    avlq_access_key,
    order_book_ref_mut,
    order_books_map_ref_mut,
    orders_ref_mut,
    resource_address;
  if (!$.copy(market_order_id).neq(u128($.copy(NIL)))) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ORDER_ID));
  }
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  [temp$1, temp$2] = [order_books_map_ref_mut, $.copy(market_id)];
  if (
    !Tablist.contains_(temp$1, temp$2, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(OrderBook),
    ])
  ) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ID));
  }
  order_book_ref_mut = Tablist.borrow_mut_(
    order_books_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  if (side == $.copy(ASK)) {
    temp$3 = order_book_ref_mut.asks;
  } else {
    temp$3 = order_book_ref_mut.bids;
  }
  orders_ref_mut = temp$3;
  avlq_access_key = u64($.copy(market_order_id).and(u128($.copy(HI_64))));
  const {
    size: size,
    price: price,
    user: order_user,
    custodian_id: order_custodian_id,
    order_access_key: order_access_key,
  } = Avl_queue.remove_(orders_ref_mut, $.copy(avlq_access_key), $c, [
    new SimpleStructTag(Order),
  ]);
  if (!($.copy(user).hex() === $.copy(order_user).hex())) {
    throw $.abortCode($.copy(E_INVALID_USER));
  }
  if (!$.copy(custodian_id).eq($.copy(order_custodian_id))) {
    throw $.abortCode($.copy(E_INVALID_CUSTODIAN));
  }
  User.cancel_order_internal_(
    $.copy(user),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(order_access_key),
    $.copy(market_order_id),
    $c
  );
  Stdlib.Event.emit_event_(
    order_book_ref_mut.maker_events,
    new MakerEvent(
      {
        market_id: $.copy(market_id),
        side: side,
        market_order_id: $.copy(market_order_id),
        user: $.copy(user),
        custodian_id: $.copy(custodian_id),
        type: $.copy(CANCEL),
        size: $.copy(size),
        price: $.copy(price),
      },
      new SimpleStructTag(MakerEvent)
    ),
    $c,
    [new SimpleStructTag(MakerEvent)]
  );
  return;
}

export function cancel_order_custodian_(
  user_address: HexString,
  market_id: U64,
  side: boolean,
  market_order_id: U128,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache
): void {
  cancel_order_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    side,
    $.copy(market_order_id),
    $c
  );
  return;
}

export function cancel_order_user_(
  user: HexString,
  market_id: U64,
  side: boolean,
  market_order_id: U128,
  $c: AptosDataCache
): void {
  cancel_order_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    side,
    $.copy(market_order_id),
    $c
  );
  return;
}

export function buildPayload_cancel_order_user(
  market_id: U64,
  side: boolean,
  market_order_id: U128,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "market",
    "cancel_order_user",
    typeParamStrings,
    [market_id, side, market_order_id],
    isJSON
  );
}

export function change_order_size_(
  user: HexString,
  market_id: U64,
  custodian_id: U64,
  side: boolean,
  market_order_id: U128,
  new_size: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    avlq_access_key,
    order_book_ref_mut,
    order_books_map_ref_mut,
    order_ref_mut,
    orders_ref_mut,
    resource_address;
  if (!$.copy(market_order_id).neq(u128($.copy(NIL)))) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ORDER_ID));
  }
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  [temp$1, temp$2] = [order_books_map_ref_mut, $.copy(market_id)];
  if (
    !Tablist.contains_(temp$1, temp$2, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(OrderBook),
    ])
  ) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ID));
  }
  order_book_ref_mut = Tablist.borrow_mut_(
    order_books_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  if (side == $.copy(ASK)) {
    temp$3 = order_book_ref_mut.asks;
  } else {
    temp$3 = order_book_ref_mut.bids;
  }
  orders_ref_mut = temp$3;
  avlq_access_key = u64($.copy(market_order_id).and(u128($.copy(HI_64))));
  order_ref_mut = Avl_queue.borrow_mut_(
    orders_ref_mut,
    $.copy(avlq_access_key),
    $c,
    [new SimpleStructTag(Order)]
  );
  if (!($.copy(user).hex() === $.copy(order_ref_mut.user).hex())) {
    throw $.abortCode($.copy(E_INVALID_USER));
  }
  if (!$.copy(custodian_id).eq($.copy(order_ref_mut.custodian_id))) {
    throw $.abortCode($.copy(E_INVALID_CUSTODIAN));
  }
  User.change_order_size_internal_(
    $.copy(user),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $.copy(order_ref_mut.size),
    $.copy(new_size),
    $.copy(order_ref_mut.price),
    $.copy(order_ref_mut.order_access_key),
    $.copy(market_order_id),
    $c
  );
  order_ref_mut.size = $.copy(new_size);
  Stdlib.Event.emit_event_(
    order_book_ref_mut.maker_events,
    new MakerEvent(
      {
        market_id: $.copy(market_id),
        side: side,
        market_order_id: $.copy(market_order_id),
        user: $.copy(user),
        custodian_id: $.copy(custodian_id),
        type: $.copy(CHANGE),
        size: $.copy(order_ref_mut.size),
        price: $.copy(order_ref_mut.price),
      },
      new SimpleStructTag(MakerEvent)
    ),
    $c,
    [new SimpleStructTag(MakerEvent)]
  );
  return;
}

export function change_order_size_custodian_(
  user_address: HexString,
  market_id: U64,
  side: boolean,
  market_order_id: U128,
  new_size: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache
): void {
  change_order_size_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    side,
    $.copy(market_order_id),
    $.copy(new_size),
    $c
  );
  return;
}

export function change_order_size_user_(
  user: HexString,
  market_id: U64,
  side: boolean,
  market_order_id: U128,
  new_size: U64,
  $c: AptosDataCache
): void {
  change_order_size_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    side,
    $.copy(market_order_id),
    $.copy(new_size),
    $c
  );
  return;
}

export function buildPayload_change_order_size_user(
  market_id: U64,
  side: boolean,
  market_order_id: U128,
  new_size: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "market",
    "change_order_size_user",
    typeParamStrings,
    [market_id, side, market_order_id, new_size],
    isJSON
  );
}

export function get_ABORT_($c: AptosDataCache): U8 {
  return $.copy(ABORT);
}

export function get_ASK_($c: AptosDataCache): boolean {
  return $.copy(ASK);
}

export function get_BID_($c: AptosDataCache): boolean {
  return $.copy(BID);
}

export function get_BUY_($c: AptosDataCache): boolean {
  return $.copy(BUY);
}

export function get_CANCEL_BOTH_($c: AptosDataCache): U8 {
  return $.copy(CANCEL_BOTH);
}

export function get_CANCEL_MAKER_($c: AptosDataCache): U8 {
  return $.copy(CANCEL_MAKER);
}

export function get_CANCEL_TAKER_($c: AptosDataCache): U8 {
  return $.copy(CANCEL_TAKER);
}

export function get_FILL_OR_ABORT_($c: AptosDataCache): U8 {
  return $.copy(FILL_OR_ABORT);
}

export function get_HI_PRICE_($c: AptosDataCache): U64 {
  return $.copy(HI_PRICE);
}

export function get_IMMEDIATE_OR_CANCEL_($c: AptosDataCache): U8 {
  return $.copy(IMMEDIATE_OR_CANCEL);
}

export function get_MAX_POSSIBLE_($c: AptosDataCache): U64 {
  return $.copy(MAX_POSSIBLE);
}

export function get_NO_CUSTODIAN_($c: AptosDataCache): U64 {
  return $.copy(NO_CUSTODIAN);
}

export function get_NO_RESTRICTION_($c: AptosDataCache): U8 {
  return $.copy(NO_RESTRICTION);
}

export function get_NO_UNDERWRITER_($c: AptosDataCache): U64 {
  return $.copy(NO_UNDERWRITER);
}

export function get_PERCENT_($c: AptosDataCache): boolean {
  return $.copy(PERCENT);
}

export function get_POST_OR_ABORT_($c: AptosDataCache): U8 {
  return $.copy(POST_OR_ABORT);
}

export function get_SELL_($c: AptosDataCache): boolean {
  return $.copy(SELL);
}

export function get_TICKS_($c: AptosDataCache): boolean {
  return $.copy(TICKS);
}

export function get_market_order_id_counter_(
  market_order_id: U128,
  $c: AptosDataCache
): U64 {
  return u64(
    $.copy(market_order_id)
      .shr($.copy(SHIFT_COUNTER))
      .and(u128($.copy(HI_64)))
  );
}

export function get_market_order_id_price_(
  market_order_id: U128,
  $c: AptosDataCache
): U64 {
  return u64($.copy(market_order_id).and(u128($.copy(HI_PRICE))));
}

export function index_orders_sdk_(
  account: HexString,
  market_id: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    i,
    n_asks,
    n_bids,
    order_book_ref_mut,
    order_books_map_ref_mut,
    orders,
    orders__2,
    resource_address;
  if (
    !(
      Stdlib.Signer.address_of_(account, $c).hex() ===
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ).hex()
    )
  ) {
    throw $.abortCode($.copy(E_NOT_SIMULATION_ACCOUNT));
  }
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  order_book_ref_mut = Tablist.borrow_mut_(
    order_books_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  if (
    $c.exists(
      new SimpleStructTag(Orders),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    )
  ) {
    orders = $c.move_from<Orders>(
      new SimpleStructTag(Orders),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    );
    [n_asks, n_bids] = [
      Stdlib.Vector.length_(orders.asks, $c, [new SimpleStructTag(Order)]),
      Stdlib.Vector.length_(orders.bids, $c, [new SimpleStructTag(Order)]),
    ];
    i = u64("0");
    while ($.copy(i).lt($.copy(n_asks))) {
      {
        Stdlib.Vector.pop_back_(orders.asks, $c, [new SimpleStructTag(Order)]);
        i = $.copy(i).add(u64("1"));
      }
    }
    i = u64("0");
    while ($.copy(i).lt($.copy(n_bids))) {
      {
        Stdlib.Vector.pop_back_(orders.bids, $c, [new SimpleStructTag(Order)]);
        i = $.copy(i).add(u64("1"));
      }
    }
    temp$1 = orders;
  } else {
    temp$1 = new Orders(
      {
        asks: Stdlib.Vector.empty_($c, [new SimpleStructTag(Order)]),
        bids: Stdlib.Vector.empty_($c, [new SimpleStructTag(Order)]),
      },
      new SimpleStructTag(Orders)
    );
  }
  orders__2 = temp$1;
  while (
    !Avl_queue.is_empty_(order_book_ref_mut.asks, $c, [
      new SimpleStructTag(Order),
    ])
  ) {
    {
      Stdlib.Vector.push_back_(
        orders__2.asks,
        Avl_queue.pop_head_(order_book_ref_mut.asks, $c, [
          new SimpleStructTag(Order),
        ]),
        $c,
        [new SimpleStructTag(Order)]
      );
    }
  }
  while (
    !Avl_queue.is_empty_(order_book_ref_mut.bids, $c, [
      new SimpleStructTag(Order),
    ])
  ) {
    {
      Stdlib.Vector.push_back_(
        orders__2.bids,
        Avl_queue.pop_head_(order_book_ref_mut.bids, $c, [
          new SimpleStructTag(Order),
        ]),
        $c,
        [new SimpleStructTag(Order)]
      );
    }
  }
  return $c.move_to(new SimpleStructTag(Orders), account, orders__2);
}

export function buildPayload_index_orders_sdk(
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
    "market",
    "index_orders_sdk",
    typeParamStrings,
    [market_id],
    isJSON
  );
}

export async function query_index_orders_sdk(
  client: AptosClient,
  fetcher: $.SimulationKeys,
  repo: AptosParserRepo,
  market_id: U64,
  $p: TypeTag[],
  option?: OptionTransaction,
  _isJSON = false
) {
  const payload__ = buildPayload_index_orders_sdk(market_id, _isJSON);
  const outputTypeTag = new SimpleStructTag(Orders);
  const output = await $.simulatePayloadTx(client, fetcher, payload__, option);
  return $.takeSimulationValue<Orders>(output, outputTypeTag, repo);
}
export function init_module_(_econia: HexString, $c: AptosDataCache): void {
  let resource_account;
  resource_account = Resource_account.get_signer_($c);
  return $c.move_to(
    new SimpleStructTag(OrderBooks),
    resource_account,
    new OrderBooks(
      {
        map: Tablist.new___($c, [
          AtomicTypeTag.U64,
          new SimpleStructTag(OrderBook),
        ]),
      },
      new SimpleStructTag(OrderBooks)
    )
  );
}

export function match_(
  market_id: U64,
  order_book_ref_mut: OrderBook,
  taker: HexString,
  custodian_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behavior: U8,
  optional_base_coins: Stdlib.Option.Option,
  quote_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [Stdlib.Option.Option, Stdlib.Coin.Coin, U64, U64, U64, boolean] {
  let temp$1,
    temp$10,
    temp$13,
    temp$15,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    avlq_access_key,
    avlq_access_key__12,
    base_fill,
    cancel_maker_order,
    complete_fill,
    fees_paid,
    fill_size,
    lot_size,
    lots_until_max,
    maker,
    maker_custodian_id,
    maker_handle,
    market_order_id,
    market_order_id__11,
    max_fill_size,
    max_fill_size_ticks,
    max_lots,
    max_quote_match,
    max_ticks,
    order,
    order_ref_mut,
    orders_ref_mut,
    price,
    quote_coins__14,
    quote_fill,
    quote_traded,
    self_match,
    self_match_taker_cancel,
    side,
    taker_fee_divisor,
    taker_handle,
    tick_size,
    ticks_filled,
    ticks_until_max;
  if (!$.copy(limit_price).le($.copy(HI_PRICE))) {
    throw $.abortCode($.copy(E_PRICE_TOO_HIGH));
  }
  if (direction == $.copy(BUY)) {
    temp$1 = $.copy(ASK);
  } else {
    temp$1 = $.copy(BID);
  }
  side = temp$1;
  [lot_size, tick_size] = [
    $.copy(order_book_ref_mut.lot_size),
    $.copy(order_book_ref_mut.tick_size),
  ];
  taker_fee_divisor = Incentives.get_taker_fee_divisor_($c);
  max_quote_match = Incentives.calculate_max_quote_match_(
    direction,
    $.copy(taker_fee_divisor),
    $.copy(max_quote),
    $c
  );
  [max_lots, max_ticks] = [
    $.copy(max_base).div($.copy(lot_size)),
    $.copy(max_quote_match).div($.copy(tick_size)),
  ];
  [lots_until_max, ticks_until_max] = [$.copy(max_lots), $.copy(max_ticks)];
  if (side == $.copy(ASK)) {
    temp$2 = order_book_ref_mut.asks;
  } else {
    temp$2 = order_book_ref_mut.bids;
  }
  orders_ref_mut = temp$2;
  self_match_taker_cancel = false;
  while (
    !Avl_queue.is_empty_(orders_ref_mut, $c, [new SimpleStructTag(Order)])
  ) {
    {
      temp$3 = Avl_queue.get_head_key_(orders_ref_mut, $c, [
        new SimpleStructTag(Order),
      ]);
      price = $.copy(Stdlib.Option.borrow_(temp$3, $c, [AtomicTypeTag.U64]));
      if (direction == $.copy(BUY)) {
        temp$4 = $.copy(price).gt($.copy(limit_price));
      } else {
        temp$4 = false;
      }
      if (temp$4) {
        temp$6 = true;
      } else {
        if (direction == $.copy(SELL)) {
          temp$5 = $.copy(price).lt($.copy(limit_price));
        } else {
          temp$5 = false;
        }
        temp$6 = temp$5;
      }
      if (temp$6) {
        break;
      } else {
      }
      max_fill_size_ticks = $.copy(ticks_until_max).div($.copy(price));
      if ($.copy(max_fill_size_ticks).lt($.copy(lots_until_max))) {
        temp$7 = $.copy(max_fill_size_ticks);
      } else {
        temp$7 = $.copy(lots_until_max);
      }
      max_fill_size = temp$7;
      order_ref_mut = Avl_queue.borrow_head_mut_(orders_ref_mut, $c, [
        new SimpleStructTag(Order),
      ]);
      if (!$.copy(order_ref_mut.price).eq($.copy(price))) {
        throw $.abortCode($.copy(E_HEAD_KEY_PRICE_MISMATCH));
      }
      if ($.copy(max_fill_size).lt($.copy(order_ref_mut.size))) {
        [temp$8, temp$9] = [$.copy(max_fill_size), false];
      } else {
        [temp$8, temp$9] = [$.copy(order_ref_mut.size), true];
      }
      [fill_size, complete_fill] = [temp$8, temp$9];
      if ($.copy(fill_size).eq(u64("0"))) {
        break;
      } else {
      }
      [maker, maker_custodian_id] = [
        $.copy(order_ref_mut.user),
        $.copy(order_ref_mut.custodian_id),
      ];
      if ($.copy(taker).hex() === $.copy(maker).hex()) {
        temp$10 = $.copy(custodian_id).eq($.copy(maker_custodian_id));
      } else {
        temp$10 = false;
      }
      self_match = temp$10;
      if (self_match) {
        if (!$.copy(self_match_behavior).neq($.copy(ABORT))) {
          throw $.abortCode($.copy(E_SELF_MATCH));
        }
        cancel_maker_order = false;
        if ($.copy(self_match_behavior).eq($.copy(CANCEL_BOTH))) {
          [cancel_maker_order, self_match_taker_cancel] = [true, true];
        } else {
          if ($.copy(self_match_behavior).eq($.copy(CANCEL_MAKER))) {
            cancel_maker_order = true;
          } else {
            if ($.copy(self_match_behavior).eq($.copy(CANCEL_TAKER))) {
              self_match_taker_cancel = true;
            } else {
              throw $.abortCode($.copy(E_INVALID_SELF_MATCH_BEHAVIOR));
            }
          }
        }
        if (cancel_maker_order) {
          market_order_id = User.cancel_order_internal_(
            $.copy(maker),
            $.copy(market_id),
            $.copy(maker_custodian_id),
            side,
            $.copy(order_ref_mut.size),
            $.copy(price),
            $.copy(order_ref_mut.order_access_key),
            u128($.copy(NIL)),
            $c
          );
          avlq_access_key = u64(
            $.copy(market_order_id).and(u128($.copy(HI_64)))
          );
          const { size: size } = Avl_queue.remove_(
            orders_ref_mut,
            $.copy(avlq_access_key),
            $c,
            [new SimpleStructTag(Order)]
          );
          maker_handle = order_book_ref_mut.maker_events;
          Stdlib.Event.emit_event_(
            maker_handle,
            new MakerEvent(
              {
                market_id: $.copy(market_id),
                side: side,
                market_order_id: $.copy(market_order_id),
                user: $.copy(maker),
                custodian_id: $.copy(maker_custodian_id),
                type: $.copy(CANCEL),
                size: $.copy(size),
                price: $.copy(price),
              },
              new SimpleStructTag(MakerEvent)
            ),
            $c,
            [new SimpleStructTag(MakerEvent)]
          );
        } else {
        }
        if (self_match_taker_cancel) {
          break;
        } else {
        }
      } else {
        ticks_filled = $.copy(fill_size).mul($.copy(price));
        lots_until_max = $.copy(lots_until_max).sub($.copy(fill_size));
        ticks_until_max = $.copy(ticks_until_max).sub($.copy(ticks_filled));
        [optional_base_coins, quote_coins, market_order_id__11] =
          User.fill_order_internal_(
            $.copy(maker),
            $.copy(market_id),
            $.copy(maker_custodian_id),
            side,
            $.copy(order_ref_mut.order_access_key),
            $.copy(order_ref_mut.size),
            $.copy(fill_size),
            complete_fill,
            optional_base_coins,
            quote_coins,
            $.copy(fill_size).mul($.copy(lot_size)),
            $.copy(ticks_filled).mul($.copy(tick_size)),
            $c,
            [$p[0], $p[1]]
          );
        taker_handle = order_book_ref_mut.taker_events;
        Stdlib.Event.emit_event_(
          taker_handle,
          new TakerEvent(
            {
              market_id: $.copy(market_id),
              side: side,
              market_order_id: $.copy(market_order_id__11),
              maker: $.copy(maker),
              custodian_id: $.copy(maker_custodian_id),
              size: $.copy(fill_size),
              price: $.copy(price),
            },
            new SimpleStructTag(TakerEvent)
          ),
          $c,
          [new SimpleStructTag(TakerEvent)]
        );
        if (complete_fill) {
          avlq_access_key__12 = u64(
            $.copy(market_order_id__11).and(u128($.copy(HI_64)))
          );
          order = Avl_queue.remove_(
            orders_ref_mut,
            $.copy(avlq_access_key__12),
            $c,
            [new SimpleStructTag(Order)]
          );
          order;
          if ($.copy(lots_until_max).eq(u64("0"))) {
            temp$13 = true;
          } else {
            temp$13 = $.copy(ticks_until_max).eq(u64("0"));
          }
          if (temp$13) {
            break;
          } else {
          }
        } else {
          order_ref_mut.size = $.copy(order_ref_mut.size).sub(
            $.copy(fill_size)
          );
          break;
        }
      }
    }
  }
  [base_fill, quote_fill] = [
    $.copy(max_lots).sub($.copy(lots_until_max)).mul($.copy(lot_size)),
    $.copy(max_ticks).sub($.copy(ticks_until_max)).mul($.copy(tick_size)),
  ];
  [quote_coins__14, fees_paid] = Incentives.assess_taker_fees_(
    $.copy(market_id),
    $.copy(integrator),
    $.copy(taker_fee_divisor),
    $.copy(quote_fill),
    quote_coins,
    $c,
    [$p[1]]
  );
  if (direction == $.copy(BUY)) {
    temp$15 = $.copy(quote_fill).add($.copy(fees_paid));
  } else {
    temp$15 = $.copy(quote_fill).sub($.copy(fees_paid));
  }
  quote_traded = temp$15;
  if (!$.copy(base_fill).ge($.copy(min_base))) {
    throw $.abortCode($.copy(E_MIN_BASE_NOT_TRADED));
  }
  if (!$.copy(quote_traded).ge($.copy(min_quote))) {
    throw $.abortCode($.copy(E_MIN_QUOTE_NOT_TRADED));
  }
  return [
    optional_base_coins,
    quote_coins__14,
    $.copy(base_fill),
    $.copy(quote_traded),
    $.copy(fees_paid),
    self_match_taker_cancel,
  ];
}

export function place_limit_order_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behavior: U8,
  critical_height: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U128, U64, U64, U64] {
  let temp$1,
    temp$10,
    temp$11,
    temp$12,
    temp$13,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    avlq_access_key,
    base,
    base_available,
    base_ceiling,
    base_deposit,
    base_traded,
    base_withdraw,
    crosses_spread,
    direction,
    evictee_access_key,
    evictee_value,
    fees,
    market_order_id,
    market_order_id_cancel,
    max_base,
    max_quote,
    min_base,
    min_quote,
    optional_base_coins,
    order,
    order_access_key,
    order_book_ref_mut,
    order_books_map_ref_mut,
    orders_ref_mut,
    quote,
    quote_available,
    quote_ceiling,
    quote_coins,
    quote_traded,
    quote_withdraw,
    resource_address,
    self_match_cancel,
    still_crosses_spread,
    ticks,
    underwriter_id;
  if (!$.copy(restriction).le($.copy(N_RESTRICTIONS))) {
    throw $.abortCode($.copy(E_INVALID_RESTRICTION));
  }
  if (!$.copy(price).neq(u64("0"))) {
    throw $.abortCode($.copy(E_PRICE_0));
  }
  if (!$.copy(price).le($.copy(HI_PRICE))) {
    throw $.abortCode($.copy(E_PRICE_TOO_HIGH));
  }
  [, base_available, base_ceiling, , quote_available, quote_ceiling] =
    User.get_asset_counts_internal_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $c
    );
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  order_book_ref_mut = Tablist.borrow_mut_(
    order_books_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[0]]),
      $.copy(order_book_ref_mut.base_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_BASE));
  }
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[1]]),
      $.copy(order_book_ref_mut.quote_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_QUOTE));
  }
  if (!$.copy(size).ge($.copy(order_book_ref_mut.min_size))) {
    throw $.abortCode($.copy(E_SIZE_TOO_SMALL));
  }
  underwriter_id = $.copy(order_book_ref_mut.underwriter_id);
  if (side == $.copy(ASK)) {
    temp$1 = !Avl_queue.would_update_head_(
      order_book_ref_mut.bids,
      $.copy(price),
      $c,
      [new SimpleStructTag(Order)]
    );
  } else {
    temp$1 = !Avl_queue.would_update_head_(
      order_book_ref_mut.asks,
      $.copy(price),
      $c,
      [new SimpleStructTag(Order)]
    );
  }
  crosses_spread = temp$1;
  if ($.copy(restriction).eq($.copy(FILL_OR_ABORT))) {
    temp$2 = !crosses_spread;
  } else {
    temp$2 = false;
  }
  if (temp$2) {
    throw $.abortCode($.copy(E_FILL_OR_ABORT_NOT_CROSS_SPREAD));
  }
  if ($.copy(restriction).eq($.copy(POST_OR_ABORT)) && crosses_spread) {
    throw $.abortCode($.copy(E_POST_OR_ABORT_CROSSES_SPREAD));
  }
  base = u128($.copy(size)).mul(u128($.copy(order_book_ref_mut.lot_size)));
  if (!$.copy(base).le(u128($.copy(HI_64)))) {
    throw $.abortCode($.copy(E_SIZE_BASE_OVERFLOW));
  }
  ticks = u128($.copy(size)).mul(u128($.copy(price)));
  if (!$.copy(ticks).le(u128($.copy(HI_64)))) {
    throw $.abortCode($.copy(E_SIZE_PRICE_TICKS_OVERFLOW));
  }
  quote = $.copy(ticks).mul(u128($.copy(order_book_ref_mut.tick_size)));
  if (!$.copy(quote).le(u128($.copy(HI_64)))) {
    throw $.abortCode($.copy(E_SIZE_PRICE_QUOTE_OVERFLOW));
  }
  max_base = u64($.copy(base));
  if ($.copy(restriction).eq($.copy(FILL_OR_ABORT))) {
    temp$3 = $.copy(max_base);
  } else {
    temp$3 = u64("0");
  }
  min_base = temp$3;
  min_quote = u64("0");
  if (crosses_spread) {
    if (side == $.copy(ASK)) {
      temp$4 = $.copy(HI_64).sub($.copy(quote_ceiling));
    } else {
      temp$4 = $.copy(quote_available);
    }
    temp$5 = temp$4;
  } else {
    temp$5 = u64($.copy(quote));
  }
  max_quote = temp$5;
  if (side == $.copy(ASK)) {
    temp$6 = $.copy(SELL);
  } else {
    temp$6 = $.copy(BUY);
  }
  direction = temp$6;
  range_check_trade_(
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(base_available),
    $.copy(base_ceiling),
    $.copy(quote_available),
    $.copy(quote_ceiling),
    $c
  );
  [base_traded, quote_traded, fees] = [u64("0"), u64("0"), u64("0")];
  if (crosses_spread) {
    if (direction == $.copy(BUY)) {
      [temp$7, temp$8] = [u64("0"), $.copy(max_quote)];
    } else {
      [temp$7, temp$8] = [$.copy(max_base), u64("0")];
    }
    [base_withdraw, quote_withdraw] = [temp$7, temp$8];
    [optional_base_coins, quote_coins] = User.withdraw_assets_internal_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $.copy(base_withdraw),
      $.copy(quote_withdraw),
      $.copy(underwriter_id),
      $c,
      [$p[0], $p[1]]
    );
    [
      optional_base_coins,
      quote_coins,
      base_traded,
      quote_traded,
      fees,
      self_match_cancel,
    ] = match_(
      $.copy(market_id),
      order_book_ref_mut,
      $.copy(user_address),
      $.copy(custodian_id),
      $.copy(integrator),
      direction,
      $.copy(min_base),
      $.copy(max_base),
      $.copy(min_quote),
      $.copy(max_quote),
      $.copy(price),
      $.copy(self_match_behavior),
      optional_base_coins,
      quote_coins,
      $c,
      [$p[0], $p[1]]
    );
    if (direction == $.copy(BUY)) {
      temp$9 = $.copy(base_traded);
    } else {
      temp$9 = $.copy(base_withdraw).sub($.copy(base_traded));
    }
    base_deposit = temp$9;
    User.deposit_assets_internal_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $.copy(base_deposit),
      optional_base_coins,
      quote_coins,
      $.copy(underwriter_id),
      $c,
      [$p[0], $p[1]]
    );
    if (side == $.copy(ASK)) {
      temp$10 = !Avl_queue.would_update_head_(
        order_book_ref_mut.bids,
        $.copy(price),
        $c,
        [new SimpleStructTag(Order)]
      );
    } else {
      temp$10 = !Avl_queue.would_update_head_(
        order_book_ref_mut.asks,
        $.copy(price),
        $c,
        [new SimpleStructTag(Order)]
      );
    }
    still_crosses_spread = temp$10;
    if (still_crosses_spread || self_match_cancel) {
      temp$11 = u64("0");
    } else {
      temp$11 = $.copy(size).sub(
        $.copy(base_traded).div($.copy(order_book_ref_mut.lot_size))
      );
    }
    size = temp$11;
  } else {
  }
  if ($.copy(restriction).eq($.copy(IMMEDIATE_OR_CANCEL))) {
    temp$12 = true;
  } else {
    temp$12 = $.copy(size).lt($.copy(order_book_ref_mut.min_size));
  }
  if (temp$12) {
    return [
      u128($.copy(NIL)),
      $.copy(base_traded),
      $.copy(quote_traded),
      $.copy(fees),
    ];
  } else {
  }
  order_access_key = User.get_next_order_access_key_internal_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $c
  );
  if (side == $.copy(ASK)) {
    temp$13 = order_book_ref_mut.asks;
  } else {
    temp$13 = order_book_ref_mut.bids;
  }
  orders_ref_mut = temp$13;
  order = new Order(
    {
      size: $.copy(size),
      price: $.copy(price),
      user: $.copy(user_address),
      custodian_id: $.copy(custodian_id),
      order_access_key: $.copy(order_access_key),
    },
    new SimpleStructTag(Order)
  );
  [avlq_access_key, evictee_access_key, evictee_value] =
    Avl_queue.insert_check_eviction_(
      orders_ref_mut,
      $.copy(price),
      order,
      $.copy(critical_height),
      $c,
      [new SimpleStructTag(Order)]
    );
  if (!$.copy(avlq_access_key).neq($.copy(NIL))) {
    throw $.abortCode($.copy(E_PRICE_TIME_PRIORITY_TOO_LOW));
  }
  market_order_id = u128($.copy(avlq_access_key)).or(
    u128($.copy(order_book_ref_mut.counter)).shl($.copy(SHIFT_COUNTER))
  );
  order_book_ref_mut.counter = $.copy(order_book_ref_mut.counter).add(u64("1"));
  User.place_order_internal_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(market_order_id),
    $.copy(order_access_key),
    $c
  );
  Stdlib.Event.emit_event_(
    order_book_ref_mut.maker_events,
    new MakerEvent(
      {
        market_id: $.copy(market_id),
        side: side,
        market_order_id: $.copy(market_order_id),
        user: $.copy(user_address),
        custodian_id: $.copy(custodian_id),
        type: $.copy(PLACE),
        size: $.copy(size),
        price: $.copy(price),
      },
      new SimpleStructTag(MakerEvent)
    ),
    $c,
    [new SimpleStructTag(MakerEvent)]
  );
  if ($.copy(evictee_access_key).eq($.copy(NIL))) {
    Stdlib.Option.destroy_none_(evictee_value, $c, [
      new SimpleStructTag(Order),
    ]);
  } else {
    const {
      size: size__17,
      price: price__16,
      user: user,
      custodian_id: custodian_id__14,
      order_access_key: order_access_key__15,
    } = Stdlib.Option.destroy_some_(evictee_value, $c, [
      new SimpleStructTag(Order),
    ]);
    market_order_id_cancel = User.cancel_order_internal_(
      $.copy(user),
      $.copy(market_id),
      $.copy(custodian_id__14),
      side,
      $.copy(size__17),
      $.copy(price__16),
      $.copy(order_access_key__15),
      u128($.copy(NIL)),
      $c
    );
    Stdlib.Event.emit_event_(
      order_book_ref_mut.maker_events,
      new MakerEvent(
        {
          market_id: $.copy(market_id),
          side: side,
          market_order_id: $.copy(market_order_id_cancel),
          user: $.copy(user),
          custodian_id: $.copy(custodian_id__14),
          type: $.copy(EVICT),
          size: $.copy(size__17),
          price: $.copy(price__16),
        },
        new SimpleStructTag(MakerEvent)
      ),
      $c,
      [new SimpleStructTag(MakerEvent)]
    );
  }
  return [
    $.copy(market_order_id),
    $.copy(base_traded),
    $.copy(quote_traded),
    $.copy(fees),
  ];
}

export function place_limit_order_custodian_(
  user_address: HexString,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behavior: U8,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U128, U64, U64, U64] {
  return place_limit_order_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $.copy(integrator),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(restriction),
    $.copy(self_match_behavior),
    $.copy(CRITICAL_HEIGHT),
    $c,
    [$p[0], $p[1]]
  );
}

export function place_limit_order_passive_advance_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  advance_style: boolean,
  target_advance_amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): U128 {
  let temp$1,
    temp$10,
    temp$11,
    temp$12,
    temp$13,
    temp$14,
    temp$2,
    temp$3,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    advance,
    check_price,
    check_price__4,
    cross_price,
    cross_price_option,
    full_advance,
    full_advance_price,
    market_order_id,
    max_bid_price_option,
    min_ask_price_option,
    order_book_ref,
    order_books_map_ref,
    price,
    resource_address,
    start_price,
    start_price_option;
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref = $c.borrow_global<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  if (
    !Tablist.contains_(order_books_map_ref, $.copy(market_id), $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(OrderBook),
    ])
  ) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ID));
  }
  order_book_ref = Tablist.borrow_(order_books_map_ref, $.copy(market_id), $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(OrderBook),
  ]);
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[0]]),
      $.copy(order_book_ref.base_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_BASE));
  }
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[1]]),
      $.copy(order_book_ref.quote_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_QUOTE));
  }
  [max_bid_price_option, min_ask_price_option] = [
    Avl_queue.get_head_key_(order_book_ref.bids, $c, [
      new SimpleStructTag(Order),
    ]),
    Avl_queue.get_head_key_(order_book_ref.asks, $c, [
      new SimpleStructTag(Order),
    ]),
  ];
  if (side == $.copy(ASK)) {
    [temp$1, temp$2] = [
      $.copy(min_ask_price_option),
      $.copy(max_bid_price_option),
    ];
  } else {
    [temp$1, temp$2] = [
      $.copy(max_bid_price_option),
      $.copy(min_ask_price_option),
    ];
  }
  [start_price_option, cross_price_option] = [temp$1, temp$2];
  if (Stdlib.Option.is_none_(start_price_option, $c, [AtomicTypeTag.U64])) {
    return u128($.copy(NIL));
  } else {
  }
  start_price = $.copy(
    Stdlib.Option.borrow_(start_price_option, $c, [AtomicTypeTag.U64])
  );
  if ($.copy(target_advance_amount).eq(u64("0"))) {
    temp$14 = $.copy(start_price);
  } else {
    if (Stdlib.Option.is_none_(cross_price_option, $c, [AtomicTypeTag.U64])) {
      return u128($.copy(NIL));
    } else {
    }
    cross_price = $.copy(
      Stdlib.Option.borrow_(cross_price_option, $c, [AtomicTypeTag.U64])
    );
    if (side == $.copy(ASK)) {
      check_price = $.copy(cross_price).add(u64("1"));
      if ($.copy(check_price).le($.copy(start_price))) {
        temp$3 = $.copy(check_price);
      } else {
        temp$3 = $.copy(start_price);
      }
      temp$6 = temp$3;
    } else {
      check_price__4 = $.copy(cross_price).sub(u64("1"));
      if ($.copy(check_price__4).ge($.copy(start_price))) {
        temp$5 = $.copy(check_price__4);
      } else {
        temp$5 = $.copy(start_price);
      }
      temp$6 = temp$5;
    }
    full_advance_price = temp$6;
    if ($.copy(full_advance_price).eq($.copy(start_price))) {
      temp$13 = $.copy(start_price);
    } else {
      if (side == $.copy(ASK)) {
        temp$7 = $.copy(start_price).sub($.copy(full_advance_price));
      } else {
        temp$7 = $.copy(full_advance_price).sub($.copy(start_price));
      }
      full_advance = temp$7;
      if (advance_style == $.copy(PERCENT)) {
        if (!$.copy(target_advance_amount).le($.copy(PERCENT_100))) {
          throw $.abortCode($.copy(E_INVALID_PERCENT));
        }
        if ($.copy(target_advance_amount).eq($.copy(PERCENT_100))) {
          temp$9 = $.copy(full_advance_price);
        } else {
          advance = $.copy(full_advance)
            .mul($.copy(target_advance_amount))
            .div($.copy(PERCENT_100));
          if (side == $.copy(ASK)) {
            temp$8 = $.copy(start_price).sub($.copy(advance));
          } else {
            temp$8 = $.copy(start_price).add($.copy(advance));
          }
          temp$9 = temp$8;
        }
        temp$12 = temp$9;
      } else {
        if ($.copy(target_advance_amount).ge($.copy(full_advance))) {
          temp$11 = $.copy(full_advance_price);
        } else {
          if (side == $.copy(ASK)) {
            temp$10 = $.copy(start_price).sub($.copy(target_advance_amount));
          } else {
            temp$10 = $.copy(start_price).add($.copy(target_advance_amount));
          }
          temp$11 = temp$10;
        }
        temp$12 = temp$11;
      }
      temp$13 = temp$12;
    }
    temp$14 = temp$13;
  }
  price = temp$14;
  [market_order_id, , ,] = place_limit_order_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    $.copy(integrator),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(POST_OR_ABORT),
    $.copy(ABORT),
    $.copy(CRITICAL_HEIGHT),
    $c,
    [$p[0], $p[1]]
  );
  return $.copy(market_order_id);
}

export function place_limit_order_passive_advance_custodian_(
  user_address: HexString,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  advance_style: boolean,
  target_advance_amount: U64,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): U128 {
  return place_limit_order_passive_advance_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $.copy(integrator),
    side,
    $.copy(size),
    advance_style,
    $.copy(target_advance_amount),
    $c,
    [$p[0], $p[1]]
  );
}

export function place_limit_order_passive_advance_user_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  advance_style: boolean,
  target_advance_amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): U128 {
  return place_limit_order_passive_advance_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $.copy(integrator),
    side,
    $.copy(size),
    advance_style,
    $.copy(target_advance_amount),
    $c,
    [$p[0], $p[1]]
  );
}

export function place_limit_order_passive_advance_user_entry_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  advance_style: boolean,
  target_advance_amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  place_limit_order_passive_advance_user_(
    user,
    $.copy(market_id),
    $.copy(integrator),
    side,
    $.copy(size),
    advance_style,
    $.copy(target_advance_amount),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_place_limit_order_passive_advance_user_entry(
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  advance_style: boolean,
  target_advance_amount: U64,
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
    "market",
    "place_limit_order_passive_advance_user_entry",
    typeParamStrings,
    [market_id, integrator, side, size, advance_style, target_advance_amount],
    isJSON
  );
}

export function place_limit_order_user_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behavior: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U128, U64, U64, U64] {
  return place_limit_order_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $.copy(integrator),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(restriction),
    $.copy(self_match_behavior),
    $.copy(CRITICAL_HEIGHT),
    $c,
    [$p[0], $p[1]]
  );
}

export function place_limit_order_user_entry_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behavior: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  place_limit_order_user_(
    user,
    $.copy(market_id),
    $.copy(integrator),
    side,
    $.copy(size),
    $.copy(price),
    $.copy(restriction),
    $.copy(self_match_behavior),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_place_limit_order_user_entry(
  market_id: U64,
  integrator: HexString,
  side: boolean,
  size: U64,
  price: U64,
  restriction: U8,
  self_match_behavior: U8,
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
    "market",
    "place_limit_order_user_entry",
    typeParamStrings,
    [
      market_id,
      integrator,
      side,
      size,
      price,
      restriction,
      self_match_behavior,
    ],
    isJSON
  );
}

export function place_market_order_(
  user_address: HexString,
  market_id: U64,
  custodian_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behavior: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U64, U64, U64] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$7,
    base_available,
    base_ceiling,
    base_deposit,
    base_traded,
    base_withdraw,
    fees,
    optional_base_coins,
    optional_base_coins__5,
    order_book_ref_mut,
    order_books_map_ref_mut,
    quote_available,
    quote_ceiling,
    quote_coins,
    quote_coins__6,
    quote_traded,
    quote_withdraw,
    resource_address,
    underwriter_id;
  [, base_available, base_ceiling, , quote_available, quote_ceiling] =
    User.get_asset_counts_internal_(
      $.copy(user_address),
      $.copy(market_id),
      $.copy(custodian_id),
      $c
    );
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  order_book_ref_mut = Tablist.borrow_mut_(
    order_books_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[0]]),
      $.copy(order_book_ref_mut.base_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_BASE));
  }
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[1]]),
      $.copy(order_book_ref_mut.quote_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_QUOTE));
  }
  underwriter_id = $.copy(order_book_ref_mut.underwriter_id);
  if ($.copy(max_base).eq($.copy(MAX_POSSIBLE))) {
    if (direction == $.copy(BUY)) {
      temp$1 = $.copy(HI_64).sub($.copy(base_ceiling));
    } else {
      temp$1 = $.copy(base_available);
    }
    max_base = temp$1;
  } else {
  }
  if ($.copy(max_quote).eq($.copy(MAX_POSSIBLE))) {
    if (direction == $.copy(BUY)) {
      temp$2 = $.copy(quote_available);
    } else {
      temp$2 = $.copy(HI_64).sub($.copy(quote_ceiling));
    }
    max_quote = temp$2;
  } else {
  }
  range_check_trade_(
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(base_available),
    $.copy(base_ceiling),
    $.copy(quote_available),
    $.copy(quote_ceiling),
    $c
  );
  if (direction == $.copy(BUY)) {
    [temp$3, temp$4] = [u64("0"), $.copy(max_quote)];
  } else {
    [temp$3, temp$4] = [$.copy(max_base), u64("0")];
  }
  [base_withdraw, quote_withdraw] = [temp$3, temp$4];
  [optional_base_coins, quote_coins] = User.withdraw_assets_internal_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    $.copy(base_withdraw),
    $.copy(quote_withdraw),
    $.copy(underwriter_id),
    $c,
    [$p[0], $p[1]]
  );
  [optional_base_coins__5, quote_coins__6, base_traded, quote_traded, fees] =
    match_(
      $.copy(market_id),
      order_book_ref_mut,
      $.copy(user_address),
      $.copy(custodian_id),
      $.copy(integrator),
      direction,
      $.copy(min_base),
      $.copy(max_base),
      $.copy(min_quote),
      $.copy(max_quote),
      $.copy(limit_price),
      $.copy(self_match_behavior),
      optional_base_coins,
      quote_coins,
      $c,
      [$p[0], $p[1]]
    );
  if (direction == $.copy(BUY)) {
    temp$7 = $.copy(base_traded);
  } else {
    temp$7 = $.copy(base_withdraw).sub($.copy(base_traded));
  }
  base_deposit = temp$7;
  User.deposit_assets_internal_(
    $.copy(user_address),
    $.copy(market_id),
    $.copy(custodian_id),
    $.copy(base_deposit),
    optional_base_coins__5,
    quote_coins__6,
    $.copy(underwriter_id),
    $c,
    [$p[0], $p[1]]
  );
  return [$.copy(base_traded), $.copy(quote_traded), $.copy(fees)];
}

export function place_market_order_custodian_(
  user_address: HexString,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behavior: U8,
  custodian_capability_ref: Registry.CustodianCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U64, U64, U64] {
  return place_market_order_(
    $.copy(user_address),
    $.copy(market_id),
    Registry.get_custodian_id_(custodian_capability_ref, $c),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    $.copy(self_match_behavior),
    $c,
    [$p[0], $p[1]]
  );
}

export function place_market_order_user_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behavior: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U64, U64, U64] {
  return place_market_order_(
    Stdlib.Signer.address_of_(user, $c),
    $.copy(market_id),
    $.copy(NO_CUSTODIAN),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    $.copy(self_match_behavior),
    $c,
    [$p[0], $p[1]]
  );
}

export function place_market_order_user_entry_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behavior: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  place_market_order_user_(
    user,
    $.copy(market_id),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    $.copy(self_match_behavior),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_place_market_order_user_entry(
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  self_match_behavior: U8,
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
    "market",
    "place_market_order_user_entry",
    typeParamStrings,
    [
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      self_match_behavior,
    ],
    isJSON
  );
}

export function range_check_trade_(
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  base_available: U64,
  base_ceiling: U64,
  quote_available: U64,
  quote_ceiling: U64,
  $c: AptosDataCache
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    in_ceiling,
    in_ceiling_max,
    in_max,
    out_available,
    out_max;
  if (!$.copy(max_base).gt(u64("0"))) {
    throw $.abortCode($.copy(E_MAX_BASE_0));
  }
  if (!$.copy(max_quote).gt(u64("0"))) {
    throw $.abortCode($.copy(E_MAX_QUOTE_0));
  }
  if (!$.copy(min_base).le($.copy(max_base))) {
    throw $.abortCode($.copy(E_MIN_BASE_EXCEEDS_MAX));
  }
  if (!$.copy(min_quote).le($.copy(max_quote))) {
    throw $.abortCode($.copy(E_MIN_QUOTE_EXCEEDS_MAX));
  }
  if (direction == $.copy(BUY)) {
    [temp$1, temp$2, temp$3, temp$4] = [
      $.copy(base_ceiling),
      $.copy(max_base),
      $.copy(quote_available),
      $.copy(max_quote),
    ];
  } else {
    [temp$1, temp$2, temp$3, temp$4] = [
      $.copy(quote_ceiling),
      $.copy(max_quote),
      $.copy(base_available),
      $.copy(max_base),
    ];
  }
  [in_ceiling, in_max, out_available, out_max] = [
    temp$1,
    temp$2,
    temp$3,
    temp$4,
  ];
  in_ceiling_max = u128($.copy(in_ceiling)).add(u128($.copy(in_max)));
  if (!$.copy(in_ceiling_max).le(u128($.copy(HI_64)))) {
    throw $.abortCode($.copy(E_OVERFLOW_ASSET_IN));
  }
  if (!$.copy(out_max).le($.copy(out_available))) {
    throw $.abortCode($.copy(E_NOT_ENOUGH_ASSET_OUT));
  }
  return;
}

export function register_market_(
  market_id: U64,
  base_name_generic: Stdlib.String.String,
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  underwriter_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): U64 {
  let order_books_map_ref_mut, resource_account, resource_address;
  resource_account = Resource_account.get_signer_($c);
  resource_address = Stdlib.Signer.address_of_(resource_account, $c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  Tablist.add_(
    order_books_map_ref_mut,
    $.copy(market_id),
    new OrderBook(
      {
        base_type: Stdlib.Type_info.type_of_($c, [$p[0]]),
        base_name_generic: $.copy(base_name_generic),
        quote_type: Stdlib.Type_info.type_of_($c, [$p[1]]),
        lot_size: $.copy(lot_size),
        tick_size: $.copy(tick_size),
        min_size: $.copy(min_size),
        underwriter_id: $.copy(underwriter_id),
        asks: Avl_queue.new___($.copy(ASCENDING), u64("0"), u64("0"), $c, [
          new SimpleStructTag(Order),
        ]),
        bids: Avl_queue.new___($.copy(DESCENDING), u64("0"), u64("0"), $c, [
          new SimpleStructTag(Order),
        ]),
        counter: u64("0"),
        maker_events: Stdlib.Account.new_event_handle_(resource_account, $c, [
          new SimpleStructTag(MakerEvent),
        ]),
        taker_events: Stdlib.Account.new_event_handle_(resource_account, $c, [
          new SimpleStructTag(TakerEvent),
        ]),
      },
      new SimpleStructTag(OrderBook)
    ),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  Incentives.register_econia_fee_store_entry_($.copy(market_id), $c, [$p[1]]);
  return $.copy(market_id);
}

export function register_market_base_coin_(
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType, UtilityType>*/
): U64 {
  let market_id;
  market_id = Registry.register_market_base_coin_internal_(
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
    utility_coins,
    $c,
    [$p[0], $p[1], $p[2]]
  );
  return register_market_(
    $.copy(market_id),
    Stdlib.String.utf8_([], $c),
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
    $.copy(NO_UNDERWRITER),
    $c,
    [$p[0], $p[1]]
  );
}

export function register_market_base_coin_from_coinstore_(
  user: HexString,
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType, UtilityType>*/
): void {
  let fee;
  fee = Incentives.get_market_registration_fee_($c);
  register_market_base_coin_(
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
    Stdlib.Coin.withdraw_(user, $.copy(fee), $c, [$p[2]]),
    $c,
    [$p[0], $p[1], $p[2]]
  );
  return;
}

export function buildPayload_register_market_base_coin_from_coinstore(
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  $p: TypeTag[] /* <BaseType, QuoteType, UtilityType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "market",
    "register_market_base_coin_from_coinstore",
    typeParamStrings,
    [lot_size, tick_size, min_size],
    isJSON
  );
}

export function register_market_base_generic_(
  base_name_generic: Stdlib.String.String,
  lot_size: U64,
  tick_size: U64,
  min_size: U64,
  utility_coins: Stdlib.Coin.Coin,
  underwriter_capability_ref: Registry.UnderwriterCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteType, UtilityType>*/
): U64 {
  let market_id;
  market_id = Registry.register_market_base_generic_internal_(
    $.copy(base_name_generic),
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
    underwriter_capability_ref,
    utility_coins,
    $c,
    [$p[0], $p[1]]
  );
  return register_market_(
    $.copy(market_id),
    $.copy(base_name_generic),
    $.copy(lot_size),
    $.copy(tick_size),
    $.copy(min_size),
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
      $p[0],
    ]
  );
}

export function swap_(
  market_id: U64,
  underwriter_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  optional_base_coins: Stdlib.Option.Option,
  quote_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [Stdlib.Option.Option, Stdlib.Coin.Coin, U64, U64, U64] {
  let temp$1,
    temp$2,
    base_traded,
    fees,
    order_book_ref_mut,
    order_books_map_ref_mut,
    quote_traded,
    resource_address;
  resource_address = Resource_account.get_address_($c);
  order_books_map_ref_mut = $c.borrow_global_mut<OrderBooks>(
    new SimpleStructTag(OrderBooks),
    $.copy(resource_address)
  ).map;
  [temp$1, temp$2] = [order_books_map_ref_mut, $.copy(market_id)];
  if (
    !Tablist.contains_(temp$1, temp$2, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(OrderBook),
    ])
  ) {
    throw $.abortCode($.copy(E_INVALID_MARKET_ID));
  }
  order_book_ref_mut = Tablist.borrow_mut_(
    order_books_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(OrderBook)]
  );
  if ($.copy(underwriter_id).neq($.copy(NO_UNDERWRITER))) {
    if (!$.copy(underwriter_id).eq($.copy(order_book_ref_mut.underwriter_id))) {
      throw $.abortCode($.copy(E_INVALID_UNDERWRITER));
    }
  } else {
  }
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[0]]),
      $.copy(order_book_ref_mut.base_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_BASE));
  }
  if (
    !$.deep_eq(
      Stdlib.Type_info.type_of_($c, [$p[1]]),
      $.copy(order_book_ref_mut.quote_type)
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_QUOTE));
  }
  [optional_base_coins, quote_coins, base_traded, quote_traded, fees] = match_(
    $.copy(market_id),
    order_book_ref_mut,
    $.copy(NO_MARKET_ACCOUNT),
    $.copy(NO_CUSTODIAN),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    $.copy(ABORT),
    optional_base_coins,
    quote_coins,
    $c,
    [$p[0], $p[1]]
  );
  return [
    optional_base_coins,
    quote_coins,
    $.copy(base_traded),
    $.copy(quote_traded),
    $.copy(fees),
  ];
}

export function swap_between_coinstores_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [U64, U64, U64] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    base_traded,
    base_value,
    fees,
    optional_base_coins,
    optional_base_coins__5,
    quote_coins,
    quote_coins__6,
    quote_traded,
    quote_value,
    user_address;
  user_address = Stdlib.Signer.address_of_(user, $c);
  if (!Stdlib.Coin.is_account_registered_($.copy(user_address), $c, [$p[0]])) {
    Stdlib.Coin.register_(user, $c, [$p[0]]);
  } else {
  }
  if (!Stdlib.Coin.is_account_registered_($.copy(user_address), $c, [$p[1]])) {
    Stdlib.Coin.register_(user, $c, [$p[1]]);
  } else {
  }
  [base_value, quote_value] = [
    Stdlib.Coin.balance_($.copy(user_address), $c, [$p[0]]),
    Stdlib.Coin.balance_($.copy(user_address), $c, [$p[1]]),
  ];
  if ($.copy(max_base).eq($.copy(MAX_POSSIBLE))) {
    if (direction == $.copy(BUY)) {
      temp$1 = $.copy(HI_64).sub($.copy(base_value));
    } else {
      temp$1 = $.copy(base_value);
    }
    max_base = temp$1;
  } else {
  }
  if ($.copy(max_quote).eq($.copy(MAX_POSSIBLE))) {
    if (direction == $.copy(BUY)) {
      temp$2 = $.copy(quote_value);
    } else {
      temp$2 = $.copy(HI_64).sub($.copy(quote_value));
    }
    max_quote = temp$2;
  } else {
  }
  range_check_trade_(
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(base_value),
    $.copy(base_value),
    $.copy(quote_value),
    $.copy(quote_value),
    $c
  );
  if (direction == $.copy(BUY)) {
    [temp$3, temp$4] = [
      Stdlib.Option.some_(Stdlib.Coin.zero_($c, [$p[0]]), $c, [
        new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
      ]),
      Stdlib.Coin.withdraw_(user, $.copy(max_quote), $c, [$p[1]]),
    ];
  } else {
    [temp$3, temp$4] = [
      Stdlib.Option.some_(
        Stdlib.Coin.withdraw_(user, $.copy(max_base), $c, [$p[0]]),
        $c,
        [new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]])]
      ),
      Stdlib.Coin.zero_($c, [$p[1]]),
    ];
  }
  [optional_base_coins, quote_coins] = [temp$3, temp$4];
  [optional_base_coins__5, quote_coins__6, base_traded, quote_traded, fees] =
    swap_(
      $.copy(market_id),
      $.copy(NO_UNDERWRITER),
      $.copy(integrator),
      direction,
      $.copy(min_base),
      $.copy(max_base),
      $.copy(min_quote),
      $.copy(max_quote),
      $.copy(limit_price),
      optional_base_coins,
      quote_coins,
      $c,
      [$p[0], $p[1]]
    );
  Stdlib.Coin.deposit_(
    $.copy(user_address),
    Stdlib.Option.destroy_some_(optional_base_coins__5, $c, [
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
  Stdlib.Coin.deposit_($.copy(user_address), quote_coins__6, $c, [$p[1]]);
  return [$.copy(base_traded), $.copy(quote_traded), $.copy(fees)];
}

export function swap_between_coinstores_entry_(
  user: HexString,
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): void {
  swap_between_coinstores_(
    user,
    $.copy(market_id),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_swap_between_coinstores_entry(
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
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
    "market",
    "swap_between_coinstores_entry",
    typeParamStrings,
    [
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
    ],
    isJSON
  );
}

export function swap_coins_(
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  base_coins: Stdlib.Coin.Coin,
  quote_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <BaseType, QuoteType>*/
): [Stdlib.Coin.Coin, Stdlib.Coin.Coin, U64, U64, U64] {
  let temp$1,
    base_coins__3,
    base_traded,
    base_value,
    fees,
    optional_base_coins,
    optional_base_coins__2,
    quote_coins_matched,
    quote_coins_to_match,
    quote_traded,
    quote_value;
  [base_value, quote_value] = [
    Stdlib.Coin.value_(base_coins, $c, [$p[0]]),
    Stdlib.Coin.value_(quote_coins, $c, [$p[1]]),
  ];
  optional_base_coins = Stdlib.Option.some_(base_coins, $c, [
    new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
  ]);
  if (direction == $.copy(BUY)) {
    max_quote = $.copy(quote_value);
    if ($.copy(max_base).eq($.copy(MAX_POSSIBLE))) {
      max_base = $.copy(HI_64).sub($.copy(base_value));
    } else {
    }
    temp$1 = Stdlib.Coin.extract_(quote_coins, $.copy(max_quote), $c, [$p[1]]);
  } else {
    max_base = $.copy(base_value);
    if ($.copy(max_quote).eq($.copy(MAX_POSSIBLE))) {
      max_quote = $.copy(HI_64).sub($.copy(quote_value));
    } else {
    }
    temp$1 = Stdlib.Coin.zero_($c, [$p[1]]);
  }
  quote_coins_to_match = temp$1;
  range_check_trade_(
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(base_value),
    $.copy(base_value),
    $.copy(quote_value),
    $.copy(quote_value),
    $c
  );
  [
    optional_base_coins__2,
    quote_coins_matched,
    base_traded,
    quote_traded,
    fees,
  ] = swap_(
    $.copy(market_id),
    $.copy(NO_UNDERWRITER),
    $.copy(integrator),
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(limit_price),
    optional_base_coins,
    quote_coins_to_match,
    $c,
    [$p[0], $p[1]]
  );
  Stdlib.Coin.merge_(quote_coins, quote_coins_matched, $c, [$p[1]]);
  base_coins__3 = Stdlib.Option.destroy_some_(optional_base_coins__2, $c, [
    new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
  ]);
  return [
    base_coins__3,
    quote_coins,
    $.copy(base_traded),
    $.copy(quote_traded),
    $.copy(fees),
  ];
}

export function swap_generic_(
  market_id: U64,
  integrator: HexString,
  direction: boolean,
  min_base: U64,
  max_base: U64,
  min_quote: U64,
  max_quote: U64,
  limit_price: U64,
  quote_coins: Stdlib.Coin.Coin,
  underwriter_capability_ref: Registry.UnderwriterCapability,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteType>*/
): [Stdlib.Coin.Coin, U64, U64, U64] {
  let temp$1,
    temp$2,
    base_traded,
    base_value,
    fees,
    optional_base_coins,
    quote_coins_matched,
    quote_coins_to_match,
    quote_traded,
    quote_value,
    underwriter_id;
  underwriter_id = Registry.get_underwriter_id_(underwriter_capability_ref, $c);
  quote_value = Stdlib.Coin.value_(quote_coins, $c, [$p[0]]);
  if (direction == $.copy(BUY)) {
    max_quote = $.copy(quote_value);
    [temp$1, temp$2] = [
      u64("0"),
      Stdlib.Coin.extract_(quote_coins, $.copy(max_quote), $c, [$p[0]]),
    ];
  } else {
    if ($.copy(max_quote).eq($.copy(MAX_POSSIBLE))) {
      max_quote = $.copy(HI_64).sub($.copy(quote_value));
    } else {
    }
    [temp$1, temp$2] = [$.copy(max_base), Stdlib.Coin.zero_($c, [$p[0]])];
  }
  [base_value, quote_coins_to_match] = [temp$1, temp$2];
  range_check_trade_(
    direction,
    $.copy(min_base),
    $.copy(max_base),
    $.copy(min_quote),
    $.copy(max_quote),
    $.copy(base_value),
    $.copy(base_value),
    $.copy(quote_value),
    $.copy(quote_value),
    $c
  );
  [optional_base_coins, quote_coins_matched, base_traded, quote_traded, fees] =
    swap_(
      $.copy(market_id),
      $.copy(underwriter_id),
      $.copy(integrator),
      direction,
      $.copy(min_base),
      $.copy(max_base),
      $.copy(min_quote),
      $.copy(max_quote),
      $.copy(limit_price),
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
      quote_coins_to_match,
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
        $p[0],
      ]
    );
  Stdlib.Option.destroy_none_(optional_base_coins, $c, [
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
  ]);
  Stdlib.Coin.merge_(quote_coins, quote_coins_matched, $c, [$p[0]]);
  return [quote_coins, $.copy(base_traded), $.copy(quote_traded), $.copy(fees)];
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::market::MakerEvent",
    MakerEvent.MakerEventParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::market::Order",
    Order.OrderParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::market::OrderBook",
    OrderBook.OrderBookParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::market::OrderBooks",
    OrderBooks.OrderBooksParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::market::Orders",
    Orders.OrdersParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::market::TakerEvent",
    TakerEvent.TakerEventParser
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
  get MakerEvent() {
    return MakerEvent;
  }
  get Order() {
    return Order;
  }
  get OrderBook() {
    return OrderBook;
  }
  get OrderBooks() {
    return OrderBooks;
  }
  async loadOrderBooks(owner: HexString, loadFull = true, fillCache = true) {
    const val = await OrderBooks.load(
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
  get Orders() {
    return Orders;
  }
  async loadOrders(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Orders.load(
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
  get TakerEvent() {
    return TakerEvent;
  }
  payload_cancel_all_orders_user(
    market_id: U64,
    side: boolean,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_cancel_all_orders_user(market_id, side, isJSON);
  }
  async cancel_all_orders_user(
    _account: AptosAccount,
    market_id: U64,
    side: boolean,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_cancel_all_orders_user(
      market_id,
      side,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_cancel_order_user(
    market_id: U64,
    side: boolean,
    market_order_id: U128,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_cancel_order_user(
      market_id,
      side,
      market_order_id,
      isJSON
    );
  }
  async cancel_order_user(
    _account: AptosAccount,
    market_id: U64,
    side: boolean,
    market_order_id: U128,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_cancel_order_user(
      market_id,
      side,
      market_order_id,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_change_order_size_user(
    market_id: U64,
    side: boolean,
    market_order_id: U128,
    new_size: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_change_order_size_user(
      market_id,
      side,
      market_order_id,
      new_size,
      isJSON
    );
  }
  async change_order_size_user(
    _account: AptosAccount,
    market_id: U64,
    side: boolean,
    market_order_id: U128,
    new_size: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_change_order_size_user(
      market_id,
      side,
      market_order_id,
      new_size,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_index_orders_sdk(
    market_id: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_index_orders_sdk(market_id, isJSON);
  }
  async index_orders_sdk(
    _account: AptosAccount,
    market_id: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_index_orders_sdk(market_id, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  async query_index_orders_sdk(
    market_id: U64,
    $p: TypeTag[],
    option?: OptionTransaction,
    _isJSON = false,
    fetcher: $.SimulationKeys = $.SIM_KEYS
  ) {
    return query_index_orders_sdk(
      this.client,
      fetcher,
      this.repo,
      market_id,
      $p,
      option
    );
  }
  payload_place_limit_order_passive_advance_user_entry(
    market_id: U64,
    integrator: HexString,
    side: boolean,
    size: U64,
    advance_style: boolean,
    target_advance_amount: U64,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_place_limit_order_passive_advance_user_entry(
      market_id,
      integrator,
      side,
      size,
      advance_style,
      target_advance_amount,
      $p,
      isJSON
    );
  }
  async place_limit_order_passive_advance_user_entry(
    _account: AptosAccount,
    market_id: U64,
    integrator: HexString,
    side: boolean,
    size: U64,
    advance_style: boolean,
    target_advance_amount: U64,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_place_limit_order_passive_advance_user_entry(
      market_id,
      integrator,
      side,
      size,
      advance_style,
      target_advance_amount,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_place_limit_order_user_entry(
    market_id: U64,
    integrator: HexString,
    side: boolean,
    size: U64,
    price: U64,
    restriction: U8,
    self_match_behavior: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_place_limit_order_user_entry(
      market_id,
      integrator,
      side,
      size,
      price,
      restriction,
      self_match_behavior,
      $p,
      isJSON
    );
  }
  async place_limit_order_user_entry(
    _account: AptosAccount,
    market_id: U64,
    integrator: HexString,
    side: boolean,
    size: U64,
    price: U64,
    restriction: U8,
    self_match_behavior: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_place_limit_order_user_entry(
      market_id,
      integrator,
      side,
      size,
      price,
      restriction,
      self_match_behavior,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_place_market_order_user_entry(
    market_id: U64,
    integrator: HexString,
    direction: boolean,
    min_base: U64,
    max_base: U64,
    min_quote: U64,
    max_quote: U64,
    limit_price: U64,
    self_match_behavior: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_place_market_order_user_entry(
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      self_match_behavior,
      $p,
      isJSON
    );
  }
  async place_market_order_user_entry(
    _account: AptosAccount,
    market_id: U64,
    integrator: HexString,
    direction: boolean,
    min_base: U64,
    max_base: U64,
    min_quote: U64,
    max_quote: U64,
    limit_price: U64,
    self_match_behavior: U8,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_place_market_order_user_entry(
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      self_match_behavior,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_register_market_base_coin_from_coinstore(
    lot_size: U64,
    tick_size: U64,
    min_size: U64,
    $p: TypeTag[] /* <BaseType, QuoteType, UtilityType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_register_market_base_coin_from_coinstore(
      lot_size,
      tick_size,
      min_size,
      $p,
      isJSON
    );
  }
  async register_market_base_coin_from_coinstore(
    _account: AptosAccount,
    lot_size: U64,
    tick_size: U64,
    min_size: U64,
    $p: TypeTag[] /* <BaseType, QuoteType, UtilityType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_register_market_base_coin_from_coinstore(
      lot_size,
      tick_size,
      min_size,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_swap_between_coinstores_entry(
    market_id: U64,
    integrator: HexString,
    direction: boolean,
    min_base: U64,
    max_base: U64,
    min_quote: U64,
    max_quote: U64,
    limit_price: U64,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_swap_between_coinstores_entry(
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      $p,
      isJSON
    );
  }
  async swap_between_coinstores_entry(
    _account: AptosAccount,
    market_id: U64,
    integrator: HexString,
    direction: boolean,
    min_base: U64,
    max_base: U64,
    min_quote: U64,
    max_quote: U64,
    limit_price: U64,
    $p: TypeTag[] /* <BaseType, QuoteType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_swap_between_coinstores_entry(
      market_id,
      integrator,
      direction,
      min_base,
      max_base,
      min_quote,
      max_quote,
      limit_price,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  app_get_ABORT() {
    return get_ABORT_(this.cache);
  }
  app_get_ASK() {
    return get_ASK_(this.cache);
  }
  app_get_BID() {
    return get_BID_(this.cache);
  }
  app_get_BUY() {
    return get_BUY_(this.cache);
  }
  app_get_CANCEL_BOTH() {
    return get_CANCEL_BOTH_(this.cache);
  }
  app_get_CANCEL_MAKER() {
    return get_CANCEL_MAKER_(this.cache);
  }
  app_get_CANCEL_TAKER() {
    return get_CANCEL_TAKER_(this.cache);
  }
  app_get_FILL_OR_ABORT() {
    return get_FILL_OR_ABORT_(this.cache);
  }
  app_get_HI_PRICE() {
    return get_HI_PRICE_(this.cache);
  }
  app_get_IMMEDIATE_OR_CANCEL() {
    return get_IMMEDIATE_OR_CANCEL_(this.cache);
  }
  app_get_MAX_POSSIBLE() {
    return get_MAX_POSSIBLE_(this.cache);
  }
  app_get_NO_CUSTODIAN() {
    return get_NO_CUSTODIAN_(this.cache);
  }
  app_get_NO_RESTRICTION() {
    return get_NO_RESTRICTION_(this.cache);
  }
  app_get_NO_UNDERWRITER() {
    return get_NO_UNDERWRITER_(this.cache);
  }
  app_get_PERCENT() {
    return get_PERCENT_(this.cache);
  }
  app_get_POST_OR_ABORT() {
    return get_POST_OR_ABORT_(this.cache);
  }
  app_get_SELL() {
    return get_SELL_(this.cache);
  }
  app_get_TICKS() {
    return get_TICKS_(this.cache);
  }
  app_get_market_order_id_counter(market_order_id: U128) {
    return get_market_order_id_counter_(market_order_id, this.cache);
  }
  app_get_market_order_id_price(market_order_id: U128) {
    return get_market_order_id_price_(market_order_id, this.cache);
  }
}
