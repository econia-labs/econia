import { type Address } from "@manahippo/aptos-wallet-adapter";
import { useQuery } from "@tanstack/react-query";

import { useAptos } from "@/contexts/AptosContext";
import { type TypeTag } from "@/utils/TypeTag";

import { useCoinInfo } from "./useCoinInfo";
import { fromRawCoinAmount } from "@/utils/coin";

type CoinStore = {
  coin: {
    value: number;
  };
};

export const CoinBalanceQueryKey = (
  coinTypeTag?: TypeTag | null,
  userAddr?: Address | null
) => ["useCoinBalance", coinTypeTag?.toString(), userAddr];

export const useCoinBalance = (
  coinTypeTag?: TypeTag | null,
  userAddr?: Address | null
) => {
  const { aptosClient } = useAptos();
  const coinInfo = useCoinInfo(coinTypeTag);
  return useQuery(
    CoinBalanceQueryKey(coinTypeTag, userAddr),
    async () => {
      if (!userAddr || !coinTypeTag) return null;
      const coinStore = await aptosClient
        .getAccountResource(
          userAddr,
          `0x1::coin::CoinStore<${coinTypeTag.toString()}>`
        )
        .then(({ data }) => data as CoinStore);
      return fromRawCoinAmount(coinStore.coin.value, coinInfo.data!.decimals);
    },
    {
      enabled: !!coinInfo.data,
    }
  );
};
