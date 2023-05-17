import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery, type UseQueryResult } from "@tanstack/react-query";
import Image from "next/image";
import { useState } from "react";
import { DiscordIcon } from "./icons/DiscordIcon";
import { TwitterIcon } from "./icons/TwitterIcon";
import { MediumIcon } from "./icons/MediumIcon";

const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";

type MarketStats = {
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
    baseAssetIcon: string;
    quoteAssetIcon: string;
    baseVolume: number;
    quoteVolume: number;
  };
};

type Props = {
  marketNames: string[];
};

export function StatsBar({ marketNames }: Props) {
  const [selectedMarket, setSelectedMarket] = useState<string>(marketNames[0]);
  const marketData = useMarketData(selectedMarket);
  const isLoaded = marketData.isFetched;

  return (
    <div className="flex overflow-x-clip border-b border-neutral-600 bg-black px-9 py-4">
      <div className="flex flex-1 items-center whitespace-nowrap  [&>.mobile-stat]:block md:[&>.mobile-stat]:hidden [&>.stat]:mx-7 [&>.stat]:mb-1 [&>.stat]:hidden md:[&>.stat]:block ">
        <>
          <MarketIconPair
            baseAssetIcon={marketData.data?.pairData.baseAssetIcon}
            quoteAssetIcon={marketData.data?.pairData.quoteAssetIcon}
          />
          <Listbox value={selectedMarket} onChange={setSelectedMarket}>
            <div className="relative ml-10 mr-7 min-w-[170px]">
              <Listbox.Button className="flex font-roboto-mono text-xl text-neutral-300 md:text-2xl">
                {/* BANDAGE FIX,  */}
                {/* TODO: FIGURE OUT WHAT API PASSES MARKET AS */}
                {/* {selectedMarket} */}
                {selectedMarket.split("-")[0]} - {selectedMarket.split("-")[1]}
                <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-white" />
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
        </>
        {/* mobile price */}
        <div className="mobile-stat block">
          <p className="font-roboto-mono font-light">
            <span className="inline-block min-w-[4em] text-xl text-white">
              {formatNumber(marketData.data?.lastPrice, 2)}
            </span>
            <span
              className={`ml-1 inline-block min-w-[6em] text-base ${
                (marketData.data?.lastPriceChange || 0) < 0
                  ? "text-red-500"
                  : "text-green-500"
              }`}
            >
              {plusMinus(marketData.data?.lastPriceChange)}
              {formatNumber(marketData.data?.lastPriceChange, 4)}
            </span>
          </p>
        </div>
        {/* price */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            Last price
          </span>
          <p className="font-roboto-mono font-light">
            <span className="inline-block min-w-[6em] text-white">
              {/* render left if it is defined
                  render right if left is undefined */}
              ${formatNumber(marketData.data?.lastPrice, 2)}
            </span>
            <span
              className={`ml-1 inline-block min-w-[6em] ${
                (marketData.data?.lastPriceChange || 0) < 0
                  ? "text-red-500"
                  : "text-green-500"
              }`}
            >
              {plusMinus(marketData.data?.lastPriceChange)}
              {formatNumber(marketData.data?.lastPriceChange, 4)}
            </span>
          </p>
        </div>
        {/* 24 hr */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h change
          </span>
          <p className="font-roboto-mono font-light">
            <span className="inline-block min-w-[6em] text-white">
              {plusMinus(marketData.data?.change24h)}

              {formatNumber(marketData.data?.change24h, 4)}
            </span>
            <span
              className={`ml-1 inline-block min-w-[6em] ${
                (marketData.data?.change24hPercent || 0) < 0
                  ? "text-red-500"
                  : "text-green-500"
              }`}
            >
              {plusMinus(marketData.data?.change24hPercent)}
              {formatNumber(marketData.data?.change24hPercent, 4)}%
            </span>
          </p>
        </div>
        {/* 24 hr high */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h high
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {formatNumber(marketData.data?.high24h, 4)}
            </span>
          </p>
        </div>
        {/* 24 hr low */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h low
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {formatNumber(marketData.data?.low24h, 4)}
            </span>
          </p>
        </div>
        {/* 24 hr main */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h volume ({marketData.data?.pairData.baseAsset || "-"})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {formatNumber(marketData.data?.pairData.baseVolume, 4)}
            </span>
          </p>
        </div>
        {/* 24 hr pair */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h volume ({marketData.data?.pairData.quoteAsset || "-"})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {formatNumber(marketData.data?.pairData.quoteVolume, 4)}
            </span>
          </p>
        </div>
      </div>
      <div className="my-auto hidden md:block">
        <SocialMediaIcons />
      </div>
    </div>
  );
}

// MOCK FUNCTIONS + DATA
export const useMarketData = (market: string): UseQueryResult<MarketStats> => {
  return useQuery(
    ["marketStats", market],
    async () => {
      // MOCK API CALL
      const baseAsset = market.split("-")[0];
      const quoteAsset = market.split("-")[1];
      function timeout(ms: number | undefined) {
        return new Promise((resolve) => setTimeout(resolve, ms));
      }
      await timeout(1000);
      const {
        lastPrice,
        change24h,
        high24h,
        low24h,
        pairData,
        lastPriceChange,
        change24hPercent,
      } = STATS_BAR_MOCK_DATA;
      // END MOCK API CALL
      return {
        lastPrice: lastPrice,
        lastPriceChange: lastPriceChange, //
        change24h: change24h, //
        change24hPercent: change24hPercent, //
        high24h: high24h,
        low24h: low24h,
        pairData: {
          baseAsset: baseAsset,
          quoteAsset: quoteAsset,
          baseAssetIcon: pairData.baseAssetIcon,
          quoteAssetIcon: pairData.quoteAssetIcon,
          baseVolume: pairData.baseVolume,
          quoteVolume: pairData.quoteVolume,
        },
      } as MarketStats;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false }
  );
};

const STATS_BAR_MOCK_DATA: MarketStats = {
  lastPrice: 10.17,
  lastPriceChange: 10.1738,
  change24h: -0.9305,
  change24hPercent: -8.38,
  high24h: 11.1681,
  low24h: 9.85,
  pairData: {
    // asset names here don't matter for testing purposes
    baseAsset: "doesn't",
    quoteAsset: "matter",
    baseAssetIcon: "/tokenImages/APT.png",
    quoteAssetIcon: "/tokenImages/USD.png",
    baseVolume: 6531688.77,
    quoteVolume: 68026950.84,
  },
};

// UTIL FUNCTIONS
const getLang = () => {
  return typeof window === "undefined"
    ? "en"
    : navigator.language || navigator.languages[0];
};

const formatNumber = (num: number | undefined, digits: number): string => {
  if (!num) return "-";
  return num.toLocaleString(getLang(), {
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
  });
};

const plusMinus = (num: number | undefined): string => {
  if (!num) return "";
  // no need to return - as numbers will already have that
  return num >= 0 ? `+` : ``;
};

// COMPONENTS
// leaving here until i learn more about how this project is structured
type MarketIconPairProps = {
  baseAssetIcon?: string;
  quoteAssetIcon?: string;
};
const MarketIconPair = ({
  baseAssetIcon = DEFAULT_TOKEN_ICON,
  quoteAssetIcon = DEFAULT_TOKEN_ICON,
}: MarketIconPairProps) => {
  return (
    <div className="relative flex">
      {/* height width props required */}
      <Image
        src={baseAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="z-20 aspect-square  w-[30px] min-w-[30px] md:min-w-[40px]"
      ></Image>
      <Image
        src={quoteAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="absolute z-10 aspect-square w-[30px] min-w-[30px] translate-x-1/2 md:min-w-[40px]"
      ></Image>
    </div>
  );
};

// icons hardcoded for now
const SocialMediaIcons = () => {
  return (
    <div className="flex ">
      <a
        href="https://twitter.com/EconiaLabs"
        target="_blank"
        rel="noreferrer"
        className="hover:text-blue-400 mx-3 aspect-square  h-[28px]  min-w-[28px] cursor-pointer text-white"
      >
        <TwitterIcon />
      </a>
      <a
        href="https://discord.com/invite/Z7gXcMgX8A"
        target="_blank"
        rel="noreferrer"
        className="hover:text-blue-400 mx-3 aspect-square  h-[28px]  min-w-[28px] cursor-pointer text-white"
      >
        <DiscordIcon />
      </a>
      <a
        href="https://medium.com/econialabs"
        target="_blank"
        rel="noreferrer"
        className="hover:text-blue-400 mx-3 aspect-square  h-[28px]  min-w-[28px] cursor-pointer text-white"
      >
        <MediumIcon />
      </a>
    </div>
  );
};
