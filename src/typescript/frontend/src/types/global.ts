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
export type Precision =
  | "0.01"
  | "0.05"
  | "0.1"
  | "0.5"
  | "1"
  | "2.5"
  | "5"
  | "10";
