import {
  useQuery,
  useQueryClient,
  type UseQueryResult,
} from "@tanstack/react-query";

import { API_URL } from "@/env";
import { type OrderBook, type Precision } from "@/types/global";
import { useEffect } from "react";
import { PriceLevel } from "@/types/global";
// TODO: precision not yet implemented in API yet, so does nothing as of now
export const useOrderBook = (
  market_id: number,
  precision: Precision = "0.01",
  depth = 60
): UseQueryResult<OrderBook> => {
  const QUERY_KEY = ["orderBook", market_id, precision];

  /**
   * assumption made is there is always 60 entries in the orderbook visible at any time.
   * things to account for:
   *
   *
   * 1. if price level size is 0, then remove it from the orderbook. need to think about how to update range to account for this.
   * 2. if price level does not exist, and lies between the range, then add it to the orderbook. remove out of range price levels and update range
   * 3. account for precision???
   */

  //  websocket
  const queryClient = useQueryClient();
  useEffect(() => {
    // const websocket = new WebSocket(`wss://${API_URL}/ws`);
    const websocket = new WebSocket(`wss://dev.api.econia.exchange/ws`);

    websocket.onopen = () => {
      console.log("websocket connected");
    };

    websocket.onmessage = (event) => {
      const data: PriceLevel = JSON.parse(event.data);
      queryClient.setQueryData(QUERY_KEY, (oldData: OrderBook | undefined) => {
        return oldData;
      });
      console.log("websocket message", data);
      // queryClient.invalidateQueries({ queryKey });
    };

    // cleanup
    return () => {
      websocket.close();
    };
  }, []);

  //  initial fetch
  return useQuery(
    QUERY_KEY,
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

const useReactQuerySubscription = () => {
  const queryClient = useQueryClient();
  useEffect(() => {
    const websocket = new WebSocket(`wss://${API_URL}/ws`);
    websocket.onopen = () => {
      console.log("connected");
    };

    websocket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      const queryKey = [...data.entity, data.id].filter(Boolean);
      queryClient.invalidateQueries({ queryKey });
    };

    return () => {
      websocket.close();
    };
  }, []);
};
