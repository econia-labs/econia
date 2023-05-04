import { type TypeTag, type U64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { INTEGRATOR_ADDR } from "../constants";
import {
  buildPayload_place_market_order_user_entry,
  CANCEL_TAKER,
} from "../sdk/src/econia_wrappers/wrappers";
import { useAptos } from "./useAptos";

export const usePlaceMarketOrder = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (
      depositAmount: U64,
      marketId: U64,
      direction: boolean,
      min_base: U64,
      max_base: U64,
      min_quote: U64,
      max_quote: U64,
      limit_price: U64,
      baseCoin: TypeTag,
      quoteCoin: TypeTag
    ) => {
      const payload = buildPayload_place_market_order_user_entry(
        depositAmount,
        marketId,
        INTEGRATOR_ADDR,
        direction,
        min_base,
        max_base,
        min_quote,
        max_quote,
        limit_price,
        CANCEL_TAKER, // TODO: Self match behavior
        [baseCoin, quoteCoin],
        true
      );
      await sendTx(payload);
    },
    [sendTx]
  );
};
