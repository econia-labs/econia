import { type TypeTag, type U64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { INTEGRATOR_ADDR } from "../constants";
import { CANCEL_TAKER, NO_RESTRICTION } from "../sdk/src/econia/market";
import { buildPayload_place_limit_order_user_entry } from "../sdk/src/econia_wrappers/wrappers";
import { useAptos } from "./useAptos";

export const usePlaceLimitOrder = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (
      depositAmount: U64,
      marketId: U64,
      side: boolean,
      size: U64,
      price: U64,
      baseCoin: TypeTag,
      quoteCoin: TypeTag
    ) => {
      const payload = buildPayload_place_limit_order_user_entry(
        depositAmount,
        marketId,
        INTEGRATOR_ADDR,
        side,
        size,
        price,
        NO_RESTRICTION, // TODO: Restrictions
        CANCEL_TAKER, // TODO: Self match behavior
        [baseCoin, quoteCoin]
      );
      await sendTx(payload);
    },
    [sendTx]
  );
};
