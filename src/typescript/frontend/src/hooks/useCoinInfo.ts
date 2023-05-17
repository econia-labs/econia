import { useAptos } from "@/contexts/AptosContext";
import { TypeTag } from "@/types/move";
import { Address } from "@manahippo/aptos-wallet-adapter";
import { useQuery } from "@tanstack/react-query";

type CoinInfo = {
  decimals: 6;
  name: string;
  symbol: string;
};

export const useCoinInfo = (coinTypeTag?: TypeTag | null) => {
  const { aptosClient } = useAptos();
  return useQuery(["useCoinInfo", coinTypeTag?.toString()], async () => {
    if (!coinTypeTag) return null;
    const coinInfo = await aptosClient.getAccountResource(
      coinTypeTag.addr,
      `0x1::coin::CoinInfo<${coinTypeTag.toString()}>`
    );
    return coinInfo.data as CoinInfo;
  });
};
