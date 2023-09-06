import { type Side } from "./global";

export type ApiCoin = {
  account_address: string;
  module_name: string;
  struct_name: string;
  symbol: string;
  name: string;
  decimals: number;
};

export type ApiMarket = {
  market_id: number;
  name: string;
  base: ApiCoin | null;
  base_name_generic: string | null;
  quote: ApiCoin;
  lot_size: number;
  tick_size: number;
  min_size: number;
  underwriter_id: number;
  created_at: string;
  recognized?: boolean;
};

export type ApiOrder = {
  market_order_id: number;
  market_id: number;
  side: "bid" | "ask";
  size: number;
  price: number;
  user_address: string;
  custodian_id: number | null;
  order_state: "open" | "filled" | "cancelled" | "evicted";
  created_at: string;
};

export type ApiBar = {
  start_time: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
};

export type ApiResolution =
  | "1m"
  | "5m"
  | "15m"
  | "30m"
  | "1h"
  | "4h"
  | "12h"
  | "1d";

export type ApiStats = {
  market_id: number;
  open: number;
  high: number;
  low: number;
  close: number;
  change: number;
  volume: number;
};

export type ApiPriceLevel = {
  market_id: number;
  side: Side;
  price: number;
  size: number;
};
