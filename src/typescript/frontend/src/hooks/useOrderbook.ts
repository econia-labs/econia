import { useQuery, type UseQueryResult } from "@tanstack/react-query";

import { API_URL } from "@/env";
import { type OrderBook } from "@/types/global";
// TODO: precision not yet implemented in API yet, so does nothing as of now
export const useOrderBook = (
  market: number,
  precision = "0",
  depth = 60
): UseQueryResult<OrderBook> => {
  return useQuery(
    ["orderBook", market, precision],
    async () => {
      const response = await fetch(
        `${API_URL}/market/${market}/orderbook?depth=${depth}`
      );
      const data = await response.json();
      return data as OrderBook;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false }
  );
};
