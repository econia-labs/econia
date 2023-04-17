// Order Side
export enum Side {
  Ask = 0,
  Bid = 1,
}

// Advance Style
export enum AdvanceStyle {
  Ticks = 0,
  Percent = 1,
}

// Self Match Behavior
export enum SelfMatchBehavior {
  Abort = 0,
  CancelBoth = 1,
  CancelMaker = 2,
  CancelTaker = 3,
}

// Restriction
export enum Restriction {
  NoRestriction = 0,
  FillOrAbort = 1,
  ImmediateOrCancel = 2,
}

// Order State
export enum OrderState {
  Open = 0,
  Filled = 1,
  Cancelled = 2,
  Evicted = 3,
}

// Order
export type Order = {
  market_order_id: bigint;
  market_id: bigint;
  side: Side;
  size: bigint;
  price: bigint;
  user_address: string;
  custodian_id?: bigint;
  order_state: OrderState;
  created_at: Date;
};

// Fill
export type Fill = {
  market_id: bigint;
  maker_order_id: bigint;
  maker: string;
  maker_side: Side;
  custodian_id?: bigint;
  size: bigint;
  price: bigint;
  time: Date;
};
