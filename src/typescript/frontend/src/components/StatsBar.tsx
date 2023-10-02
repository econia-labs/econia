import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery } from "@tanstack/react-query";
import BigNumber from "bignumber.js";
import { useRouter } from "next/router";
import React, { useState } from "react";
import Skeleton from "react-loading-skeleton";

import { useAptos } from "@/contexts/AptosContext";
import { API_URL } from "@/env";
import { type ApiMarket } from "@/types/api";
import { toDecimalPrice } from "@/utils/econia";
import { averageOrOther, formatNumber } from "@/utils/formatter";
import { TypeTag } from "@/utils/TypeTag";

import { BaseModal } from "./modals/BaseModal";
import { DiscordIcon } from "./icons/DiscordIcon";
import { MediumIcon } from "./icons/MediumIcon";
import { TwitterIcon } from "./icons/TwitterIcon";
import { MarketIconPair } from "./MarketIconPair";
import { SelectMarketContent } from "./trade/DepositWithdrawModal/SelectMarketContent";
import { toast } from "react-toastify";

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
    baseVolume: number;
    quoteVolume: number;
  };
};

const SocialMediaIcons: React.FC<{ className?: string }> = ({ className }) => {
  return (
    <div className={className}>
      <div className="flex">
        <a
          href="https://twitter.com/EconiaLabs"
          target="_blank"
          rel="noreferrer"
          className="mx-3 aspect-square h-[18px] w-[18px] cursor-pointer text-white hover:text-blue"
        >
          <TwitterIcon />
        </a>
        <a
          href="https://discord.com/invite/Z7gXcMgX8A"
          target="_blank"
          rel="noreferrer"
          className="mx-3 aspect-square h-[18px] w-[18px] cursor-pointer text-white hover:text-blue"
        >
          <DiscordIcon />
        </a>
        <a
          href="https://medium.com/econialabs"
          target="_blank"
          rel="noreferrer"
          className="mx-3 aspect-square h-[18px] w-[18px] cursor-pointer text-white hover:text-blue"
        >
          <MediumIcon />
        </a>
      </div>
    </div>
  );
};

export const StatsBar: React.FC<{
  allMarketData: ApiMarket[];
  selectedMarket: ApiMarket;
}> = ({ allMarketData, selectedMarket }) => {
  const router = useRouter();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { coinListClient } = useAptos();

  const { data: iconData } = useQuery(
    ["iconData", selectedMarket],
    async () => {
      const baseAssetIcon = selectedMarket.base
        ? coinListClient.getCoinInfoByFullName(
            TypeTag.fromApiCoin(selectedMarket.base).toString(),
          )?.logo_url
        : DEFAULT_TOKEN_ICON;
      const quoteAssetIcon =
        coinListClient.getCoinInfoByFullName(
          TypeTag.fromApiCoin(selectedMarket.quote).toString(),
        )?.logo_url ?? DEFAULT_TOKEN_ICON;

      return { baseAssetIcon, quoteAssetIcon };
    },
  );

  const { data } = useQuery(
    ["marketStats", selectedMarket],
    async () => {
      const resProm = fetch(
        `${API_URL}/markets/${selectedMarket.market_id}/stats?resolution=1d`,
      ).then((res) => res.json());
      const priceProm = fetch(
        `${API_URL}/markets/${selectedMarket.market_id}/orderbook?depth=1`,
      ).then((res) => res.json());
      const res = await resProm;
      const priceRes = await priceProm;

      return {
        lastPrice: toDecimalPrice({
          price: new BigNumber(
            averageOrOther(priceRes.asks[0].price, priceRes.bids[0].price) || 0,
          ),
          lotSize: BigNumber(selectedMarket.lot_size),
          tickSize: BigNumber(selectedMarket.tick_size),
          baseCoinDecimals: BigNumber(selectedMarket.base?.decimals || 0),
          quoteCoinDecimals: BigNumber(selectedMarket.quote?.decimals || 0),
        }).toNumber(),
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
          baseVolume: res.volume,
          quoteVolume: 68026950.84, // TODO: Mock data
        },
      } as MarketStats;
    },
    {
      keepPreviousData: true,
      refetchOnWindowFocus: false,
      refetchInterval: 10 * 1000,
    },
  );

  return (
    <>
      <BaseModal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
        }}
        showCloseButton={false}
        className={"pl-0 pr-0"}
      >
        <SelectMarketContent
          allMarketData={allMarketData}
          onSelectMarket={(id, name) => {
            setIsModalOpen(false);
            if (name == undefined) {
              // selected an undefined market
              toast.error("Selected market is undefined, please try again.");
              return;
            }
            router.push(`/trade/${name}`);
          }}
        />
      </BaseModal>
      <div className="flex justify-between border-b border-neutral-600 px-9 py-3">
        <div className="flex overflow-x-clip whitespace-nowrap">
          <div className="flex items-center">
            <MarketIconPair
              baseAssetIcon={iconData?.baseAssetIcon}
              quoteAssetIcon={iconData?.quoteAssetIcon}
            />
            <div className="min-w-[160px]">
              <button
                className="flex font-roboto-mono text-base font-medium text-neutral-300"
                onClick={() => {
                  setIsModalOpen(true);
                }}
              >
                {selectedMarket.name}
                <ChevronDownIcon className="my-auto ml-1 h-[18px] w-[18px] text-white" />
              </button>
            </div>
          </div>
          {/* mobile price */}
          <div className="block md:hidden">
            <p className="font-roboto-mono font-light">
              <span className="inline-block min-w-[4em] text-xl text-white">
                {data?.lastPrice && "$"}
                {formatNumber(data?.lastPrice, 2) ?? <Skeleton />}
              </span>
              <span
                className={`ml-1 inline-block min-w-[6em] text-base ${
                  (data?.lastPriceChange || 0) < 0 ? "text-red" : "text-green"
                }`}
              >
                {formatNumber(data?.lastPriceChange, 2, "always") ?? (
                  <Skeleton />
                )}
              </span>
            </p>
          </div>
          {/* price */}
          <div className="hidden md:block">
            <span className="font-roboto-mono text-xs font-light text-neutral-500">
              LAST PRICE
            </span>
            <p className="font-roboto-mono text-xs font-light text-white">
              {data?.lastPrice && "$"}
              {formatNumber(data?.lastPrice, 2) ?? <Skeleton />}
            </p>
          </div>
          {/* 24 hr */}
          <div className="ml-8 hidden md:block">
            <span className="font-roboto-mono text-xs font-light text-neutral-500">
              24H CHANGE
            </span>
            <p className="font-roboto-mono text-xs font-light text-white">
              <span className="inline-block min-w-[70px] text-white">
                {formatNumber(data?.change24h, 2) ?? <Skeleton />}
              </span>
              {data?.change24hPercent && (
                <span
                  className={`ml-2 ${
                    (data?.change24hPercent || 0) < 0
                      ? "text-red"
                      : "text-green"
                  }`}
                >
                  {formatNumber(data?.change24hPercent, 2, "always") ?? (
                    <Skeleton />
                  )}
                  %
                </span>
              )}
            </p>
          </div>
          {/* 24 hr high */}
          <div className="ml-8 hidden md:block">
            <span className="font-roboto-mono text-xs font-light uppercase text-neutral-500">
              24h high
            </span>
            <p className="font-roboto-mono text-xs font-light text-white">
              {formatNumber(data?.high24h, 2) ?? <Skeleton />}
            </p>
          </div>
          {/* 24 hr low */}
          <div className="ml-8 hidden md:block">
            <span className="font-roboto-mono text-xs font-light uppercase text-neutral-500">
              24h low
            </span>
            <p className="font-roboto-mono text-xs font-light text-white">
              {formatNumber(data?.low24h, 2) ?? <Skeleton />}
            </p>
          </div>
          {/* 24 hr main */}
          <div className="ml-8 hidden md:block">
            <span className="font-roboto-mono text-xs font-light text-neutral-500">
              24H VOLUME ({data?.pairData.baseAsset || "-"})
            </span>
            <p className="font-roboto-mono text-xs font-light text-white">
              {formatNumber(data?.pairData.baseVolume, 2) ?? <Skeleton />}
            </p>
          </div>
          {/* 24 hr pair */}
          <div className="ml-8 hidden md:block">
            <span className="font-roboto-mono text-xs font-light text-neutral-500">
              24H VOLUME ({data?.pairData.quoteAsset || "-"})
            </span>
            <p className="font-roboto-mono text-xs font-light text-white">
              {formatNumber(data?.pairData.quoteVolume, 2) ?? <Skeleton />}
            </p>
          </div>
        </div>

        <SocialMediaIcons className={"my-auto hidden md:block"} />
      </div>
    </>
  );
};
