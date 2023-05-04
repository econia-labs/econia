import { type TypeTag, type U64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { buildPayload_withdraw_to_coinstore } from "../sdk/src/econia/user";
import { useAptos } from "./useAptos";

export const useWithdrawFromMarketAccount = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (marketId: U64, amount: U64, coinType: TypeTag) => {
      const payload = buildPayload_withdraw_to_coinstore(marketId, amount, [
        coinType,
      ]);
      await sendTx(payload);
    },
    [sendTx]
  );
};
