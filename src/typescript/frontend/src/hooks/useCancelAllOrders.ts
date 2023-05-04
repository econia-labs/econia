import { type U64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

// import { buildPayload_cancel_all_orders_user } from "../sdk/src/econia/market";
import { useAptos } from "./useAptos";

export const useCancelAllOrders = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (marketId: U64) => {
      // TODO: SDK
      // const buyPayload = buildPayload_cancel_all_orders_user(marketId, false);
      // await sendTx(buyPayload);
      // const sellPayload = buildPayload_cancel_all_orders_user(marketId, true);
      // await sendTx(sellPayload);
    },
    [sendTx]
  );
};
