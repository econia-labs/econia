import { type TypeTag, type U64, u64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { buildPayload_register_market_base_coin_from_coinstore } from "../sdk/src/econia/market";
import { AptosCoin } from "../sdk/src/stdlib/aptos_coin";
import { useAptos } from "./useAptos";

const DEFAULT_UTILITY_COIN_TYPE = AptosCoin.getTag();

export const useRegisterMarket = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (
      lotSize: U64,
      tickSize: U64,
      minSize: U64,
      baseCoin: TypeTag,
      quoteCoin: TypeTag
    ) => {
      const payload = buildPayload_register_market_base_coin_from_coinstore(
        lotSize,
        tickSize,
        minSize,
        [baseCoin, quoteCoin, DEFAULT_UTILITY_COIN_TYPE]
      );
      await sendTx(payload);
    },
    [sendTx]
  );
};
