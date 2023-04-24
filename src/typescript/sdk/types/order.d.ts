import { type BCS } from "aptos";

// Order Side
export type Side = "Bid" | "Ask";

// Advance Style
export type AdvanceStyle = "Ticks" | "Percent";

// Self Match Behavior
export type SelfMatchBehavior =
  | "Abort"
  | "CancelBoth"
  | "CancelMaker"
  | "CancelTaker";

// Restriction
export type Restriction = "NoRestriction" | "FillOrAbort" | "ImmediateOrCancel";

// Order State
export type OrderState = "Open" | "Filled" | "Cancelled" | "Evicted";

// Order
export type Order = {
  market_order_id: BCS.Uint64;
  market_id: BCS.Uint64;
  side: Side;
  size: BCS.Uint64;
  price: BCS.Uint64;
  user_address: string;
  custodian_id?: BCS.Uint64;
  order_state: OrderState;
  created_at: Date;
};

// Fill
export type Fill = {
  market_id: BCS.Uint64;
  maker_order_id: BCS.Uint64;
  maker: string;
  maker_side: Side;
  custodian_id?: BCS.Uint64;
  size: BCS.Uint64;
  price: BCS.Uint64;
  time: Date;
};
