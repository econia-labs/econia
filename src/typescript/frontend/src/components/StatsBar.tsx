import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery } from "@tanstack/react-query";
import Image from "next/image";
import { useRouter } from "next/router";
import { useState } from "react";

import { API_URL } from "@/env";
import { type ApiMarket } from "@/types/api";

import { BaseModal } from "./BaseModal";
import { DiscordIcon } from "./icons/DiscordIcon";
import { MediumIcon } from "./icons/MediumIcon";
import { TwitterIcon } from "./icons/TwitterIcon";
import { SelectMarketContent } from "./trade/DepositWithdrawModal/SelectMarketContent";

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
  selectedMarket: ApiMarket;
};

export function StatsBar({ selectedMarket }: Props) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const router = useRouter();

  const { data } = useQuery(
    ["marketStasts", selectedMarket],
    async () => {
      // MOCK API CALL
      const response = fetch(
        `${API_URL}/market/${selectedMarket.market_id}/stats?resolution=1d`
      );

      const priceResponse = fetch(
        `${API_URL}/market/${selectedMarket.market_id}/orderbook?depth=1`
      );
      const awaitResponse = await response;
      const awaitPrice = await priceResponse;
      const res = await awaitResponse.json();
      const priceRes = await awaitPrice.json();

      const tokens = selectedMarket.name.split("-"); // split the string at the hyphen
      const baseIcon = `/tokenImages/${tokens[0]}.png`; // concatenate the first token with ".png"
      const quoteIcon = `/tokenImages/${tokens[1]}.png`;

      const { pairData, lastPriceChange } = STATS_BAR_MOCK_DATA;
      // END MOCK API CALL
      return {
        lastPrice: (priceRes.asks[0].price + priceRes.bids[0].price) / 2,
        lastPriceChange: lastPriceChange, //
        change24h: res.close, //
        change24hPercent: res.change * 100, //
        high24h: res.high,
        low24h: res.low,
        pairData: {
          baseAsset: tokens[0],
          quoteAsset: tokens[1],
          baseAssetIcon: baseIcon,
          quoteAssetIcon: quoteIcon,
          baseVolume: res.volume,
          quoteVolume: pairData.quoteVolume,
        },
      } as MarketStats;
    },
    {
      keepPreviousData: true,
      refetchOnWindowFocus: false,
      refetchInterval: 10 * 1000,
    }
  );

  return (
    <>
      <BaseModal
        open={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
        }}
        onBack={() => {
          setIsModalOpen(false);
        }}
      >
        <SelectMarketContent
          onSelectMarket={(market) => {
            router.push(`/trade/${market.name}`);
            setIsModalOpen(false);
          }}
        />
      </BaseModal>
      <div className="flex overflow-x-clip border-b border-neutral-600 bg-black px-9 py-4">
        <div className="flex flex-1 items-center whitespace-nowrap  [&>.mobile-stat]:block md:[&>.mobile-stat]:hidden [&>.stat]:mx-7 [&>.stat]:mb-1 [&>.stat]:hidden md:[&>.stat]:block ">
          <>
            <MarketIconPair
              baseAssetIcon={data?.pairData.baseAssetIcon}
              quoteAssetIcon={data?.pairData.quoteAssetIcon}
            />
            <div>
              <div className="relative ml-10 mr-7 min-w-[170px]">
                <button
                  className="flex font-roboto-mono text-xl text-neutral-300 md:text-2xl"
                  onClick={() => {
                    setIsModalOpen(true);
                  }}
                >
                  {selectedMarket.name.split("-")[0]} -{" "}
                  {selectedMarket.name.split("-")[1]}
                  <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-white" />
                </button>
              </div>
            </div>
          </>
          {/* mobile price */}
          <div className="mobile-stat block">
            <p className="font-roboto-mono font-light">
              <span className="inline-block min-w-[4em] text-xl text-white">
                ${formatNumber(data?.lastPrice, 2)}
              </span>
              <span
                className={`ml-1 inline-block min-w-[6em] text-base ${
                  (data?.lastPriceChange || 0) < 0 ? "text-red" : "text-green"
                }`}
              >
                {plusMinus(data?.lastPriceChange)}
                {formatNumber(data?.lastPriceChange, 4)}
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
                ${formatNumber(data?.lastPrice, 2)}
              </span>
              <span
                className={`ml-1 inline-block min-w-[6em] ${
                  (data?.lastPriceChange || 0) < 0 ? "text-red" : "text-green"
                }`}
              >
                {plusMinus(data?.lastPriceChange)}
                {formatNumber(data?.lastPriceChange, 4)}
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
                {formatNumber(data?.change24h, 4)}
              </span>
              <span
                className={`ml-1 inline-block min-w-[6em] ${
                  (data?.change24hPercent || 0) < 0 ? "text-red" : "text-green"
                }`}
              >
                {plusMinus(data?.change24hPercent)}
                {formatNumber(data?.change24hPercent, 4)}%
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
                {formatNumber(data?.high24h, 4)}
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
                {formatNumber(data?.low24h, 4)}
              </span>
            </p>
          </div>
          {/* 24 hr main */}
          <div className="stat">
            <span className="font-roboto-mono text-base font-light  text-neutral-400">
              24H VOLUME ({data?.pairData.baseAsset || "-"})
            </span>
            <p className="font-roboto-mono font-light">
              <span className="text-white">
                {formatNumber(data?.pairData.baseVolume, 4)}
              </span>
            </p>
          </div>
          {/* 24 hr pair */}
          <div className="stat">
            <span className="font-roboto-mono text-base font-light  text-neutral-400">
              24H VOLUME ({data?.pairData.quoteAsset || "-"})
            </span>
            <p className="font-roboto-mono font-light">
              <span className="text-white">
                {formatNumber(data?.pairData.quoteVolume, 4)}
              </span>
            </p>
          </div>
        </div>
        <div className="my-auto hidden md:block">
          <SocialMediaIcons />
        </div>
      </div>
    </>
  );
}

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
        className="mx-3 aspect-square h-[28px]  min-w-[28px]  cursor-pointer text-white hover:text-blue"
      >
        <TwitterIcon />
      </a>
      <a
        href="https://discord.com/invite/Z7gXcMgX8A"
        target="_blank"
        rel="noreferrer"
        className="mx-3 aspect-square h-[28px]  min-w-[28px]  cursor-pointer text-white hover:text-blue"
      >
        <DiscordIcon />
      </a>
      <a
        href="https://medium.com/econialabs"
        target="_blank"
        rel="noreferrer"
        className="mx-3 aspect-square h-[28px]  min-w-[28px]  cursor-pointer text-white hover:text-blue"
      >
        <MediumIcon />
      </a>
    </div>
  );
};
