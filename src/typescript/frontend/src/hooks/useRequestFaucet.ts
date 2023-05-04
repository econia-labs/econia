import { type TypeTag, type U64 } from "@manahippo/move-to-ts";
import { useCallback } from "react";

import { buildPayload_mint } from "../sdk/src/aptos_faucet/test_coin";
import { useAptos } from "./useAptos";

export const useRequestFaucet = () => {
  const { sendTx } = useAptos();
  return useCallback(
    async (coinType: TypeTag, amount: U64) => {
      const payload = buildPayload_mint(amount, [coinType]);
      await sendTx(payload);
    },
    [sendTx]
  );
};
