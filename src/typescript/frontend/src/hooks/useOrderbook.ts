import { useQuery, type UseQueryResult } from "@tanstack/react-query";

import { API_URL } from "@/env";
import { type Orderbook, type Precision } from "@/types/global";
// TODO: precision not yet implemented in API yet, so does nothing as of now
export const useOrderBook = (
  market_id: number,
  precision: Precision = "0.01",
  depth = 60,
): UseQueryResult<Orderbook> => {
  return useQuery(
    ["orderBook", market_id, precision],
    async () => {
      const response = await fetch(
        `${API_URL}/markets/${market_id}/orderbook?depth=${depth}`,
      );
      const data = await response.json();
      return data as Orderbook;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false },
  );
};
