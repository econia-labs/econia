import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery, type UseQueryResult } from "@tanstack/react-query";
import Image from "next/image";
import { useState } from "react";

const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";

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
    baseAssetIcon: string;
    quoteAssetIcon: string;
    baseVolume: string;
    quoteVolume: string;
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
    <div className="flex border-b border-neutral-600 bg-black px-9 py-4">
      <div className="flex flex-1 items-center [&>.stat]:mx-7 [&>.stat]:mb-1">
        <>
          <MarketIconPair
            baseAssetIcon={marketData.data?.pairData.baseAssetIcon}
            quoteAssetIcon={marketData.data?.pairData.quoteAssetIcon}
          />
          <Listbox value={selectedMarket} onChange={setSelectedMarket}>
            <div className="relative ml-10 mr-7 min-w-[170px]">
              <Listbox.Button className="flex  font-roboto-mono text-2xl text-neutral-300">
                {/* BANDAGE FIX,  */}
                {/* TODO: FIGURE OUT WHAT API PASSES MARKET AS */}
                {/* {selectedMarket} */}
                {selectedMarket.split("-")[0]} - {selectedMarket.split("-")[1]}
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
        </>
        {/* price */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            Last price
          </span>
          <p className="font-roboto-mono font-light">
            <span className="inline-block w-[6em] text-white">
              {/* render left if it is defined
                  render right if left is undefined */}
              ${marketData.data?.lastPrice || "-"}
            </span>
            <span
              className={`inline-block w-[6em] ${colorBasedOnNumber(
                marketData.data?.lastPriceChange
              )}`}
            >
              {marketData.data?.lastPriceChange || "-"}
            </span>
          </p>
        </div>
        {/* 24 hr */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h change
          </span>
          <p className="font-roboto-mono font-light">
            <span className="inline-block w-[6em] text-white">
              {marketData.data?.change24h || "-"}
            </span>
            <span
              className={`inline-block w-[4em] ${colorBasedOnNumber(
                marketData.data?.change24hPercent
              )}`}
            >
              {marketData.data?.change24hPercent || "-"}%
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
              {marketData.data?.high24h || "-"}
            </span>
          </p>
        </div>
        {/* 24 hr low */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h low
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">{marketData.data?.low24h || "-"}</span>
          </p>
        </div>
        {/* 24 hr main */}
        <div className="stat">
          <span className="font-roboto-mono text-base font-light uppercase text-neutral-400">
            24h volume ({marketData.data?.pairData.baseAsset || "-"})
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">
              {marketData.data?.pairData.baseVolume || "-"}
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
              {marketData.data?.pairData.quoteVolume || "-"}
            </span>
          </p>
        </div>
      </div>
      <div className="my-auto">
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
        lastPrice: formatDecimal(lastPrice),
        lastPriceChange: formatDecimalWithPlusMinus(lastPriceChange, 4),
        change24h: formatDecimalWithPlusMinus(change24h, 4),
        change24hPercent: formatDecimalWithPlusMinus(change24hPercent),
        high24h: formatDecimal(high24h, 4),
        low24h: formatDecimal(low24h, 4),
        pairData: {
          baseAsset: baseAsset,
          quoteAsset: quoteAsset,
          baseAssetIcon: pairData.baseAssetIcon,
          quoteAssetIcon: pairData.quoteAssetIcon,
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
  change24h: "-.9305",
  change24hPercent: "-8.38",
  high24h: "11.1681",
  low24h: "9.85",
  pairData: {
    // asset names here don't matter for testing purposes
    baseAsset: "doesn't",
    quoteAsset: "matter",
    baseAssetIcon: "/tokenImages/APT.png",
    quoteAssetIcon: "/tokenImages/USD.png",
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
  return Number(num) >= 0 ? `+${formattedNum}` : formattedNum;
};

// color based on number, green if positive, red if negative
const colorBasedOnNumber = (num: string | undefined): string => {
  if (!num) return "text-green-500";

  if (num[0] === "+") return "text-green-500";
  if (num[0] === "-") return "text-red-500";

  return Number(num) < 0 ? "text-red-500" : "text-green-500";
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
        className="z-[2] aspect-square"
      ></Image>
      <Image
        src={quoteAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="absolute z-[1] aspect-square translate-x-1/2"
      ></Image>
    </div>
  );
};

// icons hardcoded for now
const SocialMediaIcons = () => {
  return (
    <div className="flex">
      <a href="https://twitter.com" target="_blank">
        <Image
          src={"/socialIcons/Twitter.png"}
          alt="twitter-icon"
          width={28}
          height={28}
          className="mx-3 aspect-square cursor-pointer"
        ></Image>
      </a>

      <a href="https://discord.com" target="_blank">
        <Image
          src={"/socialIcons/Discord.png"}
          alt="discord-icon"
          width={28}
          height={28}
          className="mx-3 aspect-square cursor-pointer"
        ></Image>
      </a>

      <a href="https://medium.com" target="_blank">
        <Image
          src={"/socialIcons/Medium.png"}
          alt="medium-icon"
          width={28}
          height={28}
          className="mx-3 aspect-square cursor-pointer"
        ></Image>
      </a>
    </div>
  );
};
