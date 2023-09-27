import { useQuery } from "@tanstack/react-query";

import { useAptos } from "@/contexts/AptosContext";
import { type TypeTag } from "@/utils/TypeTag";

export type CoinInfo = {
  decimals: number;
  name: string;
  symbol: string;
};

export const useCoinInfo = (coinTypeTag?: TypeTag | null) => {
  const { aptosClient } = useAptos();
  return useQuery(["useCoinInfo", coinTypeTag?.toString()], async () => {
    if (!coinTypeTag) return null;
    const coinInfo = await aptosClient.getAccountResource(
      coinTypeTag.addr,
      `0x1::coin::CoinInfo<${coinTypeTag.toString()}>`,
    );
    return coinInfo.data as CoinInfo;
  });
};
