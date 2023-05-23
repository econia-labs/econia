import { type BCS } from "aptos";

import { type Side } from "./order";

export type MakerEventType = "cancel" | "change" | "evict" | "place";

export type MakerEvent = {
  market_id: BCS.Uint64;
  side: Side;
  market_order_id: BCS.Uint64;
  user_address: string;
  custodian_id?: BCS.Uint64;
  event_type: MakerEventType;
  size: BCS.Uint64;
  price: BCS.Uint64;
  time: Date;
};

export type TakerEvent = {
  market_id: BCS.Uint64;
  side: Side;
  market_order_id: BCS.Uint64;
  maker: string;
  custodian_id?: BCS.Uint64;
  size: BCS.Uint64;
  price: BCS.Uint64;
  time: Date;
};

export type MarketRegistrationEvent = {
  market_id: BCS.Uint64;
  base_account_address?: string;
  base_module_name?: string;
  base_struct_name?: string;
  base_name_generic?: string;
  quote_account_address: string;
  quote_module_name: string;
  quote_struct_name: string;
  lot_size: BCS.Uint64;
  tick_size: BCS.Uint64;
  min_size: BCS.Uint64;
  underwriter_id: BCS.Uint64;
  time: Date;
};

export type RecognizedMarketInfo = {
  market_id: BCS.Uint64;
  lot_size: BCS.Uint64;
  tick_size: BCS.Uint64;
  min_size: BCS.Uint64;
  underwriter_id: BCS.Uint64;
};

export type RecognizedMarketEvent = {
  base_account_address?: string;
  base_module_name?: string;
  base_struct_name?: string;
  base_name_generic?: string;
  quote_account_address: string;
  quote_module_name: string;
  quote_struct_name: string;
  recognized_market_info?: RecognizedMarketInfo;
  time: Date;
};

export type EconiaEvent =
  | MakerEvent
  | TakerEvent
  | MarketRegistrationEvent
  | RecognizedMarketEvent;
