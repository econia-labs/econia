import { type StructTag } from "@manahippo/move-to-ts";
import { useEffect, useMemo, useState } from "react";

import { DEFAULT_MARKET_ID } from "../constants";
import { type CoinInfo, useCoinInfos } from "./useCoinInfos";
import { type RegisteredMarket } from "./useRegisteredMarkets";

export const useMarketCoins = (markets: RegisteredMarket[]) => {
  const coinTypes = useMemo(() => {
    const seen: Record<string, boolean> = {};
    const res = [];
    for (const m of markets) {
      const baseKey = m.baseType.getFullname();
      if (!seen[baseKey]) {
        res.push(m.baseType);
        seen[baseKey] = true;
      }
      const quoteKey = m.quoteType.getFullname();
      if (!seen[quoteKey]) {
        res.push(m.quoteType);
        seen[quoteKey] = true;
      }
    }
    return res;
  }, [markets]);
  const coinInfos = useCoinInfos(coinTypes).data ?? [];
  const coinTypeToInfo = useMemo(() => {
    if (coinInfos.length === 0) return new Map<string, CoinInfo>();
    const res = new Map<string, CoinInfo>();
    for (let i = 0; i < coinInfos.length; i++) {
      res.set(coinTypes[i].getFullname(), coinInfos[i]);
    }
    return res;
  }, [coinTypes, coinInfos]);
  return { coinTypes, coinInfos, coinTypeToInfo };
};

export const useMarketSelectByCoin = (markets: RegisteredMarket[]) => {
  // We sort by recognized first so that when matching a market based on coins,
  // we pair with recognized ones first.
  const sortedMarkets = markets.sort(
    (a, b) => (b.isRecognized ? 1 : -1) - (a.isRecognized ? 1 : -1)
  );
  const { coinTypes, coinInfos, coinTypeToInfo } =
    useMarketCoins(sortedMarkets);
  // Mapping of coin type to its corresponding markets
  const coinToMarkets = useMemo(() => {
    const coinToMarkets = new Map<string, RegisteredMarket[]>();
    for (const m of sortedMarkets) {
      const baseKey = m.baseType.getFullname();
      if (!coinToMarkets.has(baseKey)) {
        coinToMarkets.set(baseKey, []);
      }
      const quoteKey = m.quoteType.getFullname();
      if (!coinToMarkets.has(quoteKey)) {
        coinToMarkets.set(quoteKey, []);
      }
      coinToMarkets.get(baseKey)!.push(m);
      coinToMarkets.get(quoteKey)!.push(m);
    }
    return coinToMarkets;
  }, [sortedMarkets]);
  const [inputCoin, setInputCoin] = useState<StructTag | null>();
  const [outputCoin, setOutputCoin] = useState<StructTag | null>();
  useEffect(() => {
    if (!inputCoin && sortedMarkets.length > 0) {
      const defaultMarket = sortedMarkets.find(
        (m) => m.marketId === DEFAULT_MARKET_ID
      );
      if (defaultMarket) setInputCoin(defaultMarket.quoteType);
      else setInputCoin(sortedMarkets[0].quoteType);
    }
    if (!outputCoin && sortedMarkets.length > 0) {
      const defaultMarket = sortedMarkets.find(
        (m) => m.marketId === DEFAULT_MARKET_ID
      );
      if (defaultMarket) setOutputCoin(defaultMarket.baseType);
      else setOutputCoin(sortedMarkets[0].baseType);
    }
  }, [inputCoin, outputCoin, sortedMarkets]);

  // Given the input coin, we find all the coins that can be used as output
  const outputCoinInfos: CoinInfo[] = useMemo(() => {
    if (!inputCoin) return [];
    const res: CoinInfo[] = [];
    const matchingMarkets = inputCoin
      ? coinToMarkets.get(inputCoin.getFullname())!
      : [];
    for (const market of matchingMarkets) {
      const mBaseCoinInfo = coinTypeToInfo.get(market.baseType.getFullname());
      const mQuoteCoinInfo = coinTypeToInfo.get(market.quoteType.getFullname());
      if (
        mQuoteCoinInfo &&
        market.baseType.getFullname() === inputCoin.getFullname()
      ) {
        res.push(mQuoteCoinInfo);
      } else if (
        mBaseCoinInfo &&
        market.quoteType.getFullname() === inputCoin.getFullname()
      ) {
        res.push(mBaseCoinInfo);
      }
    }
    return res;
  }, [inputCoin, coinToMarkets, coinTypeToInfo]);

  // Given the input and output coins, we find the market that matches
  const market =
    inputCoin && outputCoin
      ? sortedMarkets.find(
          (m) =>
            (m.baseType.getFullname() === inputCoin.getFullname() &&
              m.quoteType.getFullname() === outputCoin.getFullname()) ||
            (m.baseType.getFullname() === outputCoin.getFullname() &&
              m.quoteType.getFullname() === inputCoin.getFullname())
        ) ?? null
      : null;

  return {
    inputCoin,
    setInputCoin: (coin: CoinInfo) => {
      // TODO: More efficient search
      for (let i = 0; i < coinInfos.length; i++) {
        if (coinInfos[i] === coin) {
          setInputCoin(coinTypes[i]);
          return;
        }
      }
    },
    outputCoin,
    setOutputCoin: (coin: CoinInfo) => {
      // TODO: More efficient search
      for (let i = 0; i < coinInfos.length; i++) {
        if (coinInfos[i] === coin) {
          setOutputCoin(coinTypes[i]);
          return;
        }
      }
    },
    coinInfos,
    outputCoinInfos,
    market,
  };
};
