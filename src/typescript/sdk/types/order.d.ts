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
