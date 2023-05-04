import { u64 } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";

import { ECONIA_SIMULATION_KEYS } from "../constants";
import { query_index_orders_sdk } from "../sdk/src/econia/market";
import { useAptos } from "./useAptos";
import { useEconiaSDK } from "./useEconiaSDK";

export const useOrderBook = (marketId?: number) => {
  const { aptosClient } = useAptos();
  const { econia } = useEconiaSDK();

  return useQuery({
    queryKey: ["useOrderBook", marketId],
    queryFn: async () => {
      if (marketId === undefined) return null;
      return await query_index_orders_sdk(
        aptosClient,
        ECONIA_SIMULATION_KEYS,
        econia.repo,
        u64(marketId),
        []
      );
    },
  });
};
