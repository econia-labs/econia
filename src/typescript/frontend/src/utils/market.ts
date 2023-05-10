import type { ApiMarket } from "@/types/api";

export const makeMarketName = (market: ApiMarket) => {
  return `${market.base.symbol}/${market.base.symbol}`;
};
