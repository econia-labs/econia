import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useState } from "react";

import { WalletSelector } from "./WalletSelector";

type MarketStats = {
  marketNames: string[];
  // selected market pair data
  lastPrice: number;
  lastPriceChange: number;
  change24h: number;
  change24hPercent: number;
  high24h: number;
  low24h: number;
  pairData: {
    baseAsset: string;
    quoteAsset: string;
    baseVolume: number;
    quoteVolume: number;
  };
};

export function StatsBar({
  marketNames,
  lastPrice,
  lastPriceChange,
  change24h,
  change24hPercent,
  high24h,
  low24h,
  pairData,
}: MarketStats) {
  const [selectedMarket, setSelectedMarket] = useState<string>(marketNames[0]);

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
            <span className="text-white">${lastPrice}</span>
            <span className="ml-8 text-green-500">{lastPriceChange}</span>
          </p>
        </div>
        {/* 24 hr */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h change
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">${change24h}</span>
            <span className="ml-8 text-green-500">{change24hPercent}%</span>
          </p>
        </div>
        {/* 24 hr high */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h high
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">${high24h}</span>
          </p>
        </div>
        {/* 24 hr low */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h low
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">${low24h}</span>
          </p>
        </div>
        {/* 24 hr main */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h volume ({pairData.baseAsset})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">${pairData.baseVolume}</span>
          </p>
        </div>
        {/* 24 hr pair */}
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            24h volume ({pairData.quoteAsset})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">${pairData.quoteVolume}</span>
          </p>
        </div>
        {/* end stats */}
      </div>
      <div className="my-auto">
        <WalletSelector />
      </div>
    </div>
  );
}

const STATS_BAR_MOCK_DATA: MarketStats = {
  marketNames: ["APT-tUSDC", "tETH-tUSDC", "APT-tETH", "APT-PERP"],
  lastPrice: 10.17,
  change24h: 10.173,
  high24h: 11.1681,
  low24h: 9.85,
  pairData: {
    baseAsset: "APT",
    quoteAsset: "USDC",
    baseVolume: 1000000,
    quoteVolume: 1000000,
  },
  lastPriceChange: 0,
  change24hPercent: 0,
};
