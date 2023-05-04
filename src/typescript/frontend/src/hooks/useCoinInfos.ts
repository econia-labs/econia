import { type StructTag } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";
import BigNumber from "bignumber.js";

import { useEconiaSDK } from "./useEconiaSDK";

export type CoinInfo = {
  name: string;
  symbol: string;
  decimals: BigNumber;
  typeTag: StructTag;
};

export const useCoinInfos = (coinTypeTags: StructTag[]) => {
  const { stdlib } = useEconiaSDK();

  return useQuery<CoinInfo[]>(["useCoinInfos", ...coinTypeTags], async () => {
    const coins = [];
    for (const coinTypeTag of coinTypeTags) {
      const coin = await stdlib.coin.loadCoinInfo(coinTypeTag.address, [
        coinTypeTag,
      ]);
      coins.push({
        name: coin.name.str(),
        symbol: coin.symbol.str(),
        decimals: new BigNumber(coin.decimals.toJsNumber()),
        typeTag: coinTypeTag,
      });
    }
    return coins;
  });
};
