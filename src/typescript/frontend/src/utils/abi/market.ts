export const MARKET_ABI = {
  address: "0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74",
  name: "market",
  friends: [],
  exposed_functions: [
    {
      name: "cancel_all_orders_custodian",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [],
      params: [
        "address",
        "u64",
        "bool",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::CustodianCapability",
      ],
      return: [],
    },
    {
      name: "cancel_all_orders_user",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: ["&signer", "u64", "bool"],
      return: [],
    },
    {
      name: "cancel_order_custodian",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [],
      params: [
        "address",
        "u64",
        "bool",
        "u128",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::CustodianCapability",
      ],
      return: [],
    },
    {
      name: "cancel_order_user",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: ["&signer", "u64", "bool", "u128"],
      return: [],
    },
    {
      name: "change_order_size_custodian",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [],
      params: [
        "address",
        "u64",
        "bool",
        "u128",
        "u64",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::CustodianCapability",
      ],
      return: [],
    },
    {
      name: "change_order_size_user",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: ["&signer", "u64", "bool", "u128", "u64"],
      return: [],
    },
    {
      name: "did_order_post",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["u128"],
      return: ["bool"],
    },
    {
      name: "get_ABORT",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_ASK",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["bool"],
    },
    {
      name: "get_BID",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["bool"],
    },
    {
      name: "get_BUY",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["bool"],
    },
    {
      name: "get_CANCEL_BOTH",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_CANCEL_MAKER",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_CANCEL_TAKER",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_FILL_OR_ABORT",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_HI_PRICE",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u64"],
    },
    {
      name: "get_IMMEDIATE_OR_CANCEL",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_MAX_POSSIBLE",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u64"],
    },
    {
      name: "get_NO_CUSTODIAN",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u64"],
    },
    {
      name: "get_NO_RESTRICTION",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_NO_UNDERWRITER",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u64"],
    },
    {
      name: "get_PERCENT",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["bool"],
    },
    {
      name: "get_POST_OR_ABORT",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["u8"],
    },
    {
      name: "get_SELL",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["bool"],
    },
    {
      name: "get_TICKS",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["bool"],
    },
    {
      name: "get_market_order_id_counter",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["u128"],
      return: ["u64"],
    },
    {
      name: "get_market_order_id_price",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["u128"],
      return: ["u64"],
    },
    {
      name: "get_market_order_id_side",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["u128"],
      return: ["bool"],
    },
    {
      name: "index_orders_sdk",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: ["&signer", "u64"],
      return: [],
    },
    {
      name: "place_limit_order_custodian",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "address",
        "u64",
        "address",
        "bool",
        "u64",
        "u64",
        "u8",
        "u8",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::CustodianCapability",
      ],
      return: ["u128", "u64", "u64", "u64"],
    },
    {
      name: "place_limit_order_passive_advance_custodian",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "address",
        "u64",
        "address",
        "bool",
        "u64",
        "bool",
        "u64",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::CustodianCapability",
      ],
      return: ["u128"],
    },
    {
      name: "place_limit_order_passive_advance_user",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "address", "bool", "u64", "bool", "u64"],
      return: ["u128"],
    },
    {
      name: "place_limit_order_passive_advance_user_entry",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "address", "bool", "u64", "bool", "u64"],
      return: [],
    },
    {
      name: "place_limit_order_user",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "address", "bool", "u64", "u64", "u8", "u8"],
      return: ["u128", "u64", "u64", "u64"],
    },
    {
      name: "place_limit_order_user_entry",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "address", "bool", "u64", "u64", "u8", "u8"],
      return: [],
    },
    {
      name: "place_market_order_custodian",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "address",
        "u64",
        "address",
        "bool",
        "u64",
        "u8",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::CustodianCapability",
      ],
      return: ["u64", "u64", "u64"],
    },
    {
      name: "place_market_order_user",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "address", "bool", "u64", "u8"],
      return: ["u64", "u64", "u64"],
    },
    {
      name: "place_market_order_user_entry",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "address", "bool", "u64", "u8"],
      return: [],
    },
    {
      name: "register_market_base_coin",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["u64", "u64", "u64", "0x1::coin::Coin<T2>"],
      return: ["u64"],
    },
    {
      name: "register_market_base_coin_from_coinstore",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: ["&signer", "u64", "u64", "u64"],
      return: [],
    },
    {
      name: "register_market_base_generic",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "0x1::string::String",
        "u64",
        "u64",
        "u64",
        "0x1::coin::Coin<T1>",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::UnderwriterCapability",
      ],
      return: ["u64"],
    },
    {
      name: "swap_between_coinstores",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "&signer",
        "u64",
        "address",
        "bool",
        "u64",
        "u64",
        "u64",
        "u64",
        "u64",
      ],
      return: ["u64", "u64", "u64"],
    },
    {
      name: "swap_between_coinstores_entry",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "&signer",
        "u64",
        "address",
        "bool",
        "u64",
        "u64",
        "u64",
        "u64",
        "u64",
      ],
      return: [],
    },
    {
      name: "swap_coins",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
        {
          constraints: [],
        },
      ],
      params: [
        "u64",
        "address",
        "bool",
        "u64",
        "u64",
        "u64",
        "u64",
        "u64",
        "0x1::coin::Coin<T0>",
        "0x1::coin::Coin<T1>",
      ],
      return: [
        "0x1::coin::Coin<T0>",
        "0x1::coin::Coin<T1>",
        "u64",
        "u64",
        "u64",
      ],
    },
    {
      name: "swap_generic",
      visibility: "public",
      is_entry: false,
      is_view: false,
      generic_type_params: [
        {
          constraints: [],
        },
      ],
      params: [
        "u64",
        "address",
        "bool",
        "u64",
        "u64",
        "u64",
        "u64",
        "u64",
        "0x1::coin::Coin<T0>",
        "&0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::registry::UnderwriterCapability",
      ],
      return: ["0x1::coin::Coin<T0>", "u64", "u64", "u64"],
    },
  ],
  structs: [
    {
      name: "MakerEvent",
      is_native: false,
      abilities: ["drop", "store"],
      generic_type_params: [],
      fields: [
        {
          name: "market_id",
          type: "u64",
        },
        {
          name: "side",
          type: "bool",
        },
        {
          name: "market_order_id",
          type: "u128",
        },
        {
          name: "user",
          type: "address",
        },
        {
          name: "custodian_id",
          type: "u64",
        },
        {
          name: "type",
          type: "u8",
        },
        {
          name: "size",
          type: "u64",
        },
        {
          name: "price",
          type: "u64",
        },
      ],
    },
    {
      name: "MarketEventHandles",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        {
          name: "place_swap_order_events",
          type: "0x1::table::Table<u64, 0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::PlaceSwapOrderEvent>>",
        },
        {
          name: "cancel_order_events",
          type: "0x1::table::Table<u64, 0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::user::CancelOrderEvent>>",
        },
      ],
    },
    {
      name: "Order",
      is_native: false,
      abilities: ["store"],
      generic_type_params: [],
      fields: [
        {
          name: "size",
          type: "u64",
        },
        {
          name: "price",
          type: "u64",
        },
        {
          name: "user",
          type: "address",
        },
        {
          name: "custodian_id",
          type: "u64",
        },
        {
          name: "order_access_key",
          type: "u64",
        },
      ],
    },
    {
      name: "OrderBook",
      is_native: false,
      abilities: ["store"],
      generic_type_params: [],
      fields: [
        {
          name: "base_type",
          type: "0x1::type_info::TypeInfo",
        },
        {
          name: "base_name_generic",
          type: "0x1::string::String",
        },
        {
          name: "quote_type",
          type: "0x1::type_info::TypeInfo",
        },
        {
          name: "lot_size",
          type: "u64",
        },
        {
          name: "tick_size",
          type: "u64",
        },
        {
          name: "min_size",
          type: "u64",
        },
        {
          name: "underwriter_id",
          type: "u64",
        },
        {
          name: "asks",
          type: "0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::avl_queue::AVLqueue<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::Order>",
        },
        {
          name: "bids",
          type: "0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::avl_queue::AVLqueue<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::Order>",
        },
        {
          name: "counter",
          type: "u64",
        },
        {
          name: "maker_events",
          type: "0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::MakerEvent>",
        },
        {
          name: "taker_events",
          type: "0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::TakerEvent>",
        },
      ],
    },
    {
      name: "OrderBooks",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        {
          name: "map",
          type: "0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::tablist::Tablist<u64, 0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::OrderBook>",
        },
      ],
    },
    {
      name: "OrderView",
      is_native: false,
      abilities: ["copy", "drop"],
      generic_type_params: [],
      fields: [
        {
          name: "market_id",
          type: "u64",
        },
        {
          name: "side",
          type: "bool",
        },
        {
          name: "market_order_id",
          type: "u128",
        },
        {
          name: "size",
          type: "u64",
        },
        {
          name: "price",
          type: "u64",
        },
        {
          name: "user",
          type: "address",
        },
        {
          name: "custodian_id",
          type: "u64",
        },
      ],
    },
    {
      name: "Orders",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        {
          name: "asks",
          type: "vector<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::Order>",
        },
        {
          name: "bids",
          type: "vector<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::Order>",
        },
      ],
    },
    {
      name: "OrdersView",
      is_native: false,
      abilities: ["copy", "drop"],
      generic_type_params: [],
      fields: [
        {
          name: "asks",
          type: "vector<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::OrderView>",
        },
        {
          name: "bids",
          type: "vector<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::OrderView>",
        },
      ],
    },
    {
      name: "PlaceSwapOrderEvent",
      is_native: false,
      abilities: ["copy", "drop", "store"],
      generic_type_params: [],
      fields: [
        {
          name: "market_id",
          type: "u64",
        },
        {
          name: "signing_account",
          type: "address",
        },
        {
          name: "integrator",
          type: "address",
        },
        {
          name: "direction",
          type: "bool",
        },
        {
          name: "min_base",
          type: "u64",
        },
        {
          name: "max_base",
          type: "u64",
        },
        {
          name: "min_quote",
          type: "u64",
        },
        {
          name: "max_quote",
          type: "u64",
        },
        {
          name: "limit_price",
          type: "u64",
        },
        {
          name: "order_id",
          type: "u128",
        },
      ],
    },
    {
      name: "PriceLevel",
      is_native: false,
      abilities: ["copy", "drop"],
      generic_type_params: [],
      fields: [
        {
          name: "price",
          type: "u64",
        },
        {
          name: "size",
          type: "u128",
        },
      ],
    },
    {
      name: "PriceLevels",
      is_native: false,
      abilities: ["copy", "drop"],
      generic_type_params: [],
      fields: [
        {
          name: "market_id",
          type: "u64",
        },
        {
          name: "asks",
          type: "vector<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::PriceLevel>",
        },
        {
          name: "bids",
          type: "vector<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::PriceLevel>",
        },
      ],
    },
    {
      name: "SwapperEventHandles",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        {
          name: "cancel_order_events",
          type: "0x1::table::Table<u64, 0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::user::CancelOrderEvent>>",
        },
        {
          name: "fill_events",
          type: "0x1::table::Table<u64, 0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::user::FillEvent>>",
        },
        {
          name: "place_swap_order_events",
          type: "0x1::table::Table<u64, 0x1::event::EventHandle<0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74::market::PlaceSwapOrderEvent>>",
        },
      ],
    },
    {
      name: "TakerEvent",
      is_native: false,
      abilities: ["drop", "store"],
      generic_type_params: [],
      fields: [
        {
          name: "market_id",
          type: "u64",
        },
        {
          name: "side",
          type: "bool",
        },
        {
          name: "market_order_id",
          type: "u128",
        },
        {
          name: "maker",
          type: "address",
        },
        {
          name: "custodian_id",
          type: "u64",
        },
        {
          name: "size",
          type: "u64",
        },
        {
          name: "price",
          type: "u64",
        },
      ],
    },
  ],
} as const;
