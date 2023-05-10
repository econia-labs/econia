import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery, type UseQueryResult } from "@tanstack/react-query";
import { useState } from "react";

import { WalletSelector } from "./WalletSelector";

type MarketStats = {
  // selected market pair data
  lastPrice: string;
  lastPriceChange: string;
  change24h: string;
  change24hPercent: string;
  high24h: string;
  low24h: string;
  pairData: {
    baseAsset: string;
    quoteAsset: string;
    baseVolume: string;
    quoteVolume: string;
  };
};
// marketNames: ["APT-tUSDC", "tETH-tUSDC", "APT-tETH", "APT-PERP"],

type Props = {
  marketNames: string[];
};

export function StatsBar({ marketNames }: Props) {
  const [selectedMarket, setSelectedMarket] = useState<string>(marketNames[0]);
  const marketData = useMarketData(selectedMarket);
  const isLoaded = marketData.isFetched;

  return (
    <div className="flex border-b border-neutral-600 bg-black px-4 py-2">
      <div className="flex flex-1 items-center">
        <Listbox value={selectedMarket} onChange={setSelectedMarket}>
          <div className="relative w-[160px]">
            <Listbox.Button className="flex px-4 font-roboto-mono text-neutral-300">
              {selectedMarket}
              <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-neutral-500" />
            </Listbox.Button>
            <Listbox.Options className="absolute mt-2 w-full bg-black shadow ring-1 ring-neutral-500">
              {marketNames.map((marketName, i) => (
                <Listbox.Option
                  key={i}
                  value={marketName}
                  className="px-4 py-1 font-roboto-mono text-neutral-300 hover:bg-neutral-800"
                >
                  {marketName}
                </Listbox.Option>
              ))}
            </Listbox.Options>
          </div>
        </Listbox>
        {/* price */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            Last price
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {/* render left if it is defined
                  render right if left is undefined */}
              ${marketData.data?.lastPrice || "-"}
            </span>
            <span className="ml-8 text-green-500">
              {marketData.data?.lastPriceChange || "-"}
            </span>
          </p>
        </div>
        {/* 24 hr */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h change
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {marketData.data?.change24h || "-"}
            </span>
            <span className="ml-8 text-green-500">
              {marketData.data?.change24hPercent || "-"}%
            </span>
          </p>
        </div>
        {/* 24 hr high */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h high
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              ${marketData.data?.high24h || "-"}
            </span>
          </p>
        </div>
        {/* 24 hr low */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h low
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              ${marketData.data?.low24h || "-"}
            </span>
          </p>
        </div>
        {/* 24 hr main */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h volume ({marketData.data?.pairData.baseAsset || "-"})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              ${marketData.data?.pairData.baseVolume || "-"}
            </span>
          </p>
        </div>
        {/* 24 hr pair */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h volume ({marketData.data?.pairData.quoteAsset || "-"})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              ${marketData.data?.pairData.quoteVolume || "-"}
            </span>
          </p>
        </div>
      </div>
      <div className="my-auto">
        <WalletSelector />
      </div>
    </div>
  );
}

// MOCK FUNCTIONS + DATA
export const useMarketData = (market: string): UseQueryResult<MarketStats> => {
  return useQuery(
    ["marketStats", market],
    async () => {
      const {
        lastPrice,
        change24h,
        high24h,
        low24h,
        pairData,
        lastPriceChange,
        change24hPercent,
      } = STATS_BAR_MOCK_DATA;
      return {
        lastPrice: formatDecimal(lastPrice),
        lastPriceChange: formatDecimalWithPlusMinus(lastPriceChange, 4),
        change24h: formatDecimalWithPlusMinus(change24h, 4),
        change24hPercent: formatDecimalWithPlusMinus(change24hPercent),
        high24h: formatDecimal(high24h, 4),
        low24h: formatDecimal(low24h, 4),
        pairData: {
          baseAsset: pairData.baseAsset,
          quoteAsset: pairData.quoteAsset,
          baseVolume: formatDecimal(pairData.baseVolume),
          quoteVolume: formatDecimal(pairData.quoteVolume),
        },
      } as MarketStats;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false }
  );
};

const STATS_BAR_MOCK_DATA: MarketStats = {
  lastPrice: "10.17",
  lastPriceChange: "10.1738",
  change24h: "10.173",
  change24hPercent: "-8.38",
  high24h: "11.1681",
  low24h: "9.85",
  pairData: {
    baseAsset: "APT",
    quoteAsset: "USDC",
    baseVolume: "6531688.77",
    quoteVolume: "68026950.84",
  },
};

// UTIL FUNCTIONS

// format number to dollar
const formatDecimal = (num: string, digits = 2): string => {
  const roundedNum = Number(num).toFixed(digits);
  const parts = roundedNum.split(".");
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  return parts.join(".");
};

// formatDecimal but with + or - sign
const formatDecimalWithPlusMinus = (num: string, digits = 2): string => {
  const formattedNum = formatDecimal(num, digits);
  console.log(formattedNum);
  return Number(num) >= 0 ? `+${formattedNum}` : formattedNum;
};
