import { useQuery, type UseQueryResult } from "@tanstack/react-query";

// TODO: precision not yet implemented in API yet, so does nothing as of now
export const useOrderBook = (
  market: string,
  precision = "0",
  depth = 60
): UseQueryResult<OrderBook> => {
  return useQuery(
    ["orderBook", market, precision],
    async () => {
      const response = await fetch(
        `https://dev.api.econia.exchange/market/${market}/orderbook?depth=${depth}`
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
