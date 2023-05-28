export type Side = "buy" | "sell";
export type PriceLevel = {
  price: number;
  size: number;
};

export type OrderBook = {
  bids: PriceLevel[];
  asks: PriceLevel[];
};
