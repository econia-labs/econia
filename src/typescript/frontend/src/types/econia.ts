import {
  type MoveOption,
  type MoveTableHandle,
  type MoveTableWithLength,
  type MoveTypeInfo,
  type U64,
  type U128,
} from "@/types/move";

// econia::tablist

export type TabList<K, _V = unknown> = {
  head: {
    vec: MoveOption<K>;
  };
  table: {
    inner: MoveTableWithLength;
  };
  tail: {
    vec: MoveOption<K>;
  };
};

export type TabListNode<K, V> = {
  head: {
    vec: MoveOption<K>;
  };
  value: V;
  tail: {
    vec: MoveOption<K>;
  };
};

// econia::user

export type Collateral = {
  map: TabList<U128>;
};

export type MarketAccounts = {
  map: MoveTableHandle;
  custodians: TabList<U64>;
};

export type MarketAccount = {
  base_type: MoveTypeInfo;
  base_name_generic: string;
  quote_type: MoveTypeInfo;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;
  asks: TabList<U64>;
  bids: TabList<U64>;
  asks_stack_top: U64;
  bids_stack_top: U64;
  base_total: U64;
  base_available: U64;
  base_ceiling: U64;
  quote_total: U64;
  quote_available: U64;
  quote_ceiling: U64;
};
