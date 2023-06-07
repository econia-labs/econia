export type Side = "buy" | "sell";
export type Direction = "buy" | "sell";
export type PriceLevel = {
  price: number;
  size: number;
};

export type OrderBook = {
  bids: PriceLevel[];
  asks: PriceLevel[];
};

export type OrderBookWithUpdatedLevel = OrderBook & {
  updatedLevel?: PriceLevel;
};
export type Precision =
  | "0.01"
  | "0.05"
  | "0.1"
  | "0.5"
  | "1"
  | "2.5"
  | "5"
  | "10";

/**
 * putting down some thoughts here
 * initially thought itd be better to extend PriceLevel, but then realized that there's no good way to remove the didUpdate prop without really keeping track of the orderbook
 * thinking it might be better to extend orderbook to keep track of the most updated pricelevel
 * ---
 * issue is if the animation is 2s long in duration
 * and updates come in 1s within each other, then that means that the prev css class will be removed before it ends
 * but does this necessarily cancel the css animation?
 */
