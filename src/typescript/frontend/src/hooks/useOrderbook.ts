import { useQuery, type UseQueryResult } from "@tanstack/react-query";
import { API_URL } from "@/env";
// TODO: precision not yet implemented in API yet, so does nothing as of now
export const useOrderBook = (
  market_id: number,
  precision = "0",
  depth = 60
): UseQueryResult<OrderBook> => {
  return useQuery(
    ["orderBook", market_id, precision],
    async () => {
      const response = await fetch(
        `${API_URL}/market/${market_id}/orderbook?depth=${depth}`
      );
      const data = await response.json();
      return data as OrderBook;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false }
  );
};

type PriceLevel = {
  price: number;
  size: number;
};

type OrderBook = {
  bids: PriceLevel[];
  asks: PriceLevel[];
};
