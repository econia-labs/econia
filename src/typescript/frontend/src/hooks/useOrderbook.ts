import {
  useMutation,
  useQuery,
  useQueryClient,
  type UseQueryResult,
} from "@tanstack/react-query";
import { useEffect } from "react";

import { API_URL } from "@/env";
import { type OrderBook, type Precision } from "@/types/global";
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
      websocket.send(
        JSON.stringify({
          method: "subscribe",
          channel: "price_level",
          params: {
            market_id: market_id,
          },
        })
      );
    };

    websocket.onmessage = (event) => {
      const data: PriceLevel = JSON.parse(event.data).data;
      // updateOrderBook(data);
      console.log("websocket message", data);
      // queryClient.invalidateQueries({ queryKey });
    };

    const updateOrderBook = (event: PriceLevel) => {
      queryClient.setQueryData(QUERY_KEY, (oldData: OrderBook | undefined) => {
        if (oldData) {
          const newData: OrderBook = {
            bids: [...oldData.bids],
            asks: [...oldData.asks],
          };
          // TODO
          newData.bids[0] = { ...newData.bids[0], size: 100 };
          return newData;
        }
        return oldData;
      });
    };

    // testing
    setTimeout(() => {
      console.log("sending message");
      queryClient.setQueryData(QUERY_KEY, (oldData: OrderBook | undefined) => {
        if (oldData) {
          const newData: OrderBook = {
            bids: [...oldData.bids],
            asks: [...oldData.asks],
          };
          newData.bids[0] = { ...newData.bids[0], size: 100 };
          return newData;
        }
        return oldData;
      });
    }, 5000);

    // we wanna test
    /**
     * 1. update animation
     * 2. same level getting updated twice
     * 3. levels getting updated in quick succession before animation ends
     * 4. same level getting updated in quick succession before animation ends
     */
    //  TODO: Remove after RR
    // 1
    setTimeout(() => {
      console.log("sending message");
      queryClient.setQueryData(QUERY_KEY, (oldData: OrderBook | undefined) => {
        if (oldData) {
          const newData: OrderBook = {
            bids: [...oldData.bids],
            asks: [...oldData.asks],
          };
          newData.bids[0] = { ...newData.bids[0], size: 100, didUpdate: true };
          return newData;
        }
        return oldData;
      });
    }, 5000);

    // 2

    // cleanup
    return () => {
      websocket.close();
    };
  }, [QUERY_KEY, queryClient, market_id]);

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
    {
      keepPreviousData: true,
      refetchOnWindowFocus: false,
      cacheTime: Infinity,
      staleTime: Infinity,
    }
  );
};
