import { type U64, type U128 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { buildPayload_cancel_order_user } from "../sdk/src/econia/market";
import { useAptos } from "./useAptos";

export const useCancelOrder = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (marketId: U64, side: boolean, orderId: U128) => {
      const buyPayload = buildPayload_cancel_order_user(
        marketId,
        side,
        orderId,
        true
      );
      await sendTx(buyPayload);
    },
    [sendTx]
  );
};
