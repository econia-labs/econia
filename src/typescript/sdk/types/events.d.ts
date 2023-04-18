import { type Side } from "./order";

export enum MakerEventType {
  Cancel = 0,
  Change = 1,
  Evict = 2,
  Place = 3,
}

export type MakerEvent = {
  market_id: bigint;
  side: Side;
  market_order_id: bigint;
  user_address: string;
  custodian_id?: bigint;
  event_type: MakerEventType;
  size: bigint;
  price: bigint;
  time: Date;
};

export type TakerEvent = {
  market_id: bigint;
  side: Side;
  market_order_id: bigint;
  maker: string;
  custodian_id?: bigint;
  size: bigint;
  price: bigint;
  time: Date;
};

export type MarketRegistrationEvent = {
  market_id: bigint;
  base_account_address?: string;
  base_module_name?: string;
  base_struct_name?: string;
  base_name_generic?: string;
  quote_account_address: string;
  quote_module_name: string;
  quote_struct_name: string;
  lot_size: bigint;
  tick_size: bigint;
  min_size: bigint;
  underwriter_id: bigint;
  time: Date;
};

export type RecognizedMarketInfo = {
  market_id: bigint;
  lot_size: bigint;
  tick_size: bigint;
  min_size: bigint;
  underwriter_id: bigint;
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
