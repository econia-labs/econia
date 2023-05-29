import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery } from "@tanstack/react-query";
import Image from "next/image";
import { useRouter } from "next/router";
import React, { useState } from "react";

import { useAptos } from "@/contexts/AptosContext";
import { API_URL } from "@/env";
import { type ApiMarket } from "@/types/api";
import { TypeTag } from "@/utils/TypeTag";

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

const MarketIconPair: React.FC<{
  baseAssetIcon?: string;
  quoteAssetIcon?: string;
}> = ({
  baseAssetIcon = DEFAULT_TOKEN_ICON,
  quoteAssetIcon = DEFAULT_TOKEN_ICON,
}) => {
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

const SocialMediaIcons: React.FC<{ className?: string }> = ({ className }) => {
  return (
    <div className={className}>
      <div className="flex">
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
    </div>
  );
};

export const StatsBar: React.FC<{
  selectedMarket: ApiMarket;
}> = ({ selectedMarket }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const router = useRouter();
  const { coinListClient } = useAptos();

  const { data } = useQuery(
    ["marketStats", selectedMarket],
    async () => {
      // TODO: MOCK API CALL
      const resProm = fetch(
        `${API_URL}/market/${selectedMarket.market_id}/stats?resolution=1d`
      ).then((res) => res.json());
      const priceProm = fetch(
        `${API_URL}/market/${selectedMarket.market_id}/orderbook?depth=1`
      ).then((res) => res.json());
      const res = await resProm;
      const priceRes = await priceProm;

      const baseAssetIcon = selectedMarket.base
        ? coinListClient.getCoinInfoByFullName(
            TypeTag.fromApiCoin(selectedMarket.base).toString()
          )?.logo_url
        : DEFAULT_TOKEN_ICON;
      const quoteAssetIcon =
        coinListClient.getCoinInfoByFullName(
          TypeTag.fromApiCoin(selectedMarket.quote).toString()
        )?.logo_url ?? DEFAULT_TOKEN_ICON;

      // END MOCK API CALL
      return {
        lastPrice: averageOrOther(
          priceRes.asks[0].price,
          priceRes.bids[0].price
        ),
        lastPriceChange: 10.1738, // TODO: Mock data
        change24h: res.close,
        change24hPercent: res.change * 100,
        high24h: res.high,
        low24h: res.low,
        pairData: {
          baseAsset: selectedMarket.base
            ? selectedMarket.base.symbol
            : selectedMarket.name.split("-")[0],
          quoteAsset: selectedMarket.quote.symbol,
          baseAssetIcon,
          quoteAssetIcon,
          baseVolume: res.volume,
          quoteVolume: 68026950.84, // TODO: Mock data
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
          false;
        }}
        showCloseButton={false}
      >
        <SelectMarketContent
          onSelectMarket={(market) => {
            setIsModalOpen(false);
            false;
            router.push(`/trade/${market.name}`);
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
                {formatNumber(data?.lastPriceChange, 4, "always")}
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
                {formatNumber(data?.lastPriceChange, 4, "always")}
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
                {formatNumber(data?.change24hPercent, 4, "always")}%
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

        <SocialMediaIcons className={"my-auto hidden md:block"} />
      </div>
    </>
  );
};

const formatNumber = (
  num: number | undefined,
  digits: number,
  signDisplay: Intl.NumberFormatOptions["signDisplay"] = "never"
): string => {
  if (!num) return "-";
  const lang =
    typeof window === "undefined"
      ? "en"
      : navigator.language || navigator.languages[0];
  return num.toLocaleString(lang, {
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
    signDisplay,
  });
};

const averageOrOther = (
  price1: number | undefined,
  price2: number | undefined
): number | undefined => {
  if (price1 !== undefined && price2 !== undefined) {
    return (price1 + price2) / 2;
  }
  if (price2 == undefined) {
    return price1;
  }
  if (price1 == undefined) {
    return price2;
  }
  // no prices (orderbook empty) maybe should get the last sale price then?
  return 0;
};
