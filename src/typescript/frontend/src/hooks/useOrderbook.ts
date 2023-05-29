import { useQuery, type UseQueryResult } from "@tanstack/react-query";

import { API_URL } from "@/env";
import { type OrderBook, type Precision } from "@/types/global";
// TODO: precision not yet implemented in API yet, so does nothing as of now
export const useOrderBook = (
  market_id: number,
  precision: Precision = "0.01",
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
