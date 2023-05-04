import { type TypeTag, type U64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { INTEGRATOR_ADDR } from "../constants";
import { buildPayload_swap_between_coinstores_entry } from "../sdk/src/econia/market";
import { useAptos } from "./useAptos";

export const usePlaceSwap = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (
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
      const payload = buildPayload_swap_between_coinstores_entry(
        marketId,
        INTEGRATOR_ADDR,
        direction,
        min_base,
        max_base,
        min_quote,
        max_quote,
        limit_price,
        [baseCoin, quoteCoin],
        true
      );
      await sendTx(payload);
    },
    [sendTx]
  );
};
