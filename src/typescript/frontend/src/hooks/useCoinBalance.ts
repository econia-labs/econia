import { useAptos } from "@/contexts/AptosContext";
import { Address } from "@manahippo/aptos-wallet-adapter";
import { useQuery } from "@tanstack/react-query";
import { useCoinInfo } from "./useCoinInfo";
import { TypeTag } from "@/types/move";

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
      const coinStore = await aptosClient.getAccountResource(
        userAddr,
        `0x1::coin::CoinStore<${coinTypeTag.toString()}>`
      );
      return (
        (coinStore.data as CoinStore).coin.value / 10 ** coinInfo.data!.decimals
      );
    },
    {
      enabled: !!coinInfo.data,
    }
  );
};
