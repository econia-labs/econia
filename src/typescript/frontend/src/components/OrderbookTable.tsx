import BigNumber from "bignumber.js";
import { useEffect, useMemo, useRef, useState } from "react";

import { useOrderEntry } from "@/contexts/OrderEntryContext";
import { type ApiMarket } from "@/types/api";
import { type Orderbook, type PriceLevel } from "@/types/global";
import { toDecimalPrice, toDecimalSize } from "@/utils/econia";
import { averageOrOtherPriceLevel } from "@/utils/formatter";
import Skeleton from "react-loading-skeleton";

// const precisionOptions: Precision[] = [
//   "0.01",
//   "0.05",
//   "0.1",
//   "0.5",
//   "1",
//   "2.5",
//   "5",
//   "10",
// ];

const Row: React.FC<{
  level: PriceLevel;
  type: "bid" | "ask";
  highestSize: number;
  marketData: ApiMarket;
  updatedLevel: PriceLevel | undefined;
}> = ({ level, type, highestSize, marketData, updatedLevel }) => {
  const { setPrice } = useOrderEntry();
  const [flash, setFlash] = useState<"flash-red" | "flash-green" | "">("");

  useEffect(() => {
    if (updatedLevel == undefined) {
      return;
    }
    if (updatedLevel.price == level.price) {
      setFlash(type === "ask" ? "flash-red" : "flash-green");
      setTimeout(() => {
        setFlash("");
      }, 100);
    }
  }, [type, updatedLevel, level.price]);

  const price = toDecimalPrice({
    price: new BigNumber(level.price),
    lotSize: BigNumber(marketData.lot_size),
    tickSize: BigNumber(marketData.tick_size),
    baseCoinDecimals: BigNumber(marketData.base?.decimals || 0),
    quoteCoinDecimals: BigNumber(marketData.quote?.decimals || 0),
  }).toNumber();

  const size = toDecimalSize({
    size: new BigNumber(level.size),
    lotSize: BigNumber(marketData.lot_size),
    baseCoinDecimals: BigNumber(marketData.base?.decimals || 0),
  });

  const barPercentage = (level.size * 100) / highestSize;
  const barColor =
    type === "bid" ? "rgba(110, 213, 163, 30%)" : "rgba(213, 110, 110, 30%)";

  return (
    <div
      className={`flash-bg-once ${flash} relative flex h-6 cursor-pointer items-center justify-between py-[1px] hover:ring-1 hover:ring-neutral-600`}
      onClick={() => {
        setPrice(price.toString());
      }}
      // https://github.com/econia-labs/econia/pull/371
      // commenting out this change because it overrides orderbook flash
      // style={{
      //   background: `linear-gradient(
      //     to left,
      //     ${barColor},
      //     ${barColor} ${barPercentage}%,
      //     transparent ${barPercentage}%
      //   )`,
      // }}
    >
      <div
        className={`z-10 ml-4 text-right font-roboto-mono text-xs ${
          type === "ask" ? "text-red" : "text-green"
        }`}
      >
        {price}
      </div>
      <div className="z-10 mr-4 py-0.5 font-roboto-mono text-xs text-white">
        {size.toPrecision(4)}
      </div>
      <div
        className={`absolute right-0 z-0 h-full ${
          type === "ask" ? "bg-red/30" : "bg-green/30"
        }`}
        // dynamic taillwind?

        style={{ width: `${(100 * level.size) / highestSize}%` }}
      ></div>
    </div>
  );
};

export function OrderbookTable({
  marketData,
  data,
  isFetching,
  isLoading,
}: {
  marketData: ApiMarket;
  data: Orderbook | undefined;
  isFetching: boolean;
  isLoading: boolean;
}) {
  // const [precision, setPrecision] = useState<Precision>(precisionOptions[0]);

  const centerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    centerRef.current?.scrollIntoView({
      behavior: "smooth",
      block: "center",
    });
  }, [isFetching]);

  const midPrice: PriceLevel | undefined = useMemo(() => {
    if (data == null) {
      return undefined;
    }
    return averageOrOtherPriceLevel(
      data.asks ? data.asks[0] : undefined,
      data.bids ? data.bids[0] : undefined,
    );
  }, [data]);

  const highestSize = useMemo(() => {
    if (data == null) {
      return 0;
    }
    return Math.max(
      ...data.asks.map((order) => order.size),
      ...data.bids.map((order) => order.size),
    );
  }, [data]);

  return (
    <div className="flex grow flex-col">
      {/* title row */}
      <div className="border-b border-neutral-600 px-4 py-3">
        <div className="flex justify-between">
          <p className="font-jost text-base font-bold text-white">Order Book</p>
          {/* select */}
          {/* TODO: SHOW WHEN API IS UP */}
          {/* <Listbox value={precision} onChange={setPrecision}>
            <div className="relative z-30 min-h-[30px] border border-neutral-600 py-[4px] pl-[8px] pr-[4px] text-[8px]/[18px]">
              <Listbox.Button className="flex min-w-[48px] justify-between font-roboto-mono text-neutral-300">
                {precision}
                <ChevronDownIcon className="my-auto ml-1 h-[10px] w-[10px] text-neutral-500" />
              </Listbox.Button>
              <Listbox.Options className="absolute left-0 top-[20px] mt-2 w-full bg-black shadow ring-1 ring-neutral-600">
                {precisionOptions.map((precisionOption) => (
                  <Listbox.Option
                    key={precisionOption}
                    value={precisionOption}
                    className={`weight-300  box-border flex min-h-[30px] cursor-pointer justify-between py-2 pl-[11px] font-roboto-mono text-neutral-300 hover:bg-neutral-800  hover:outline hover:outline-1 hover:outline-neutral-600`}
                  >
                    {precisionOption}
                    {precision === precisionOption && (
                      <CheckIcon className="my-auto ml-1 mr-2 h-4 w-4 text-white" />
                    )}
                  </Listbox.Option>
                ))}
              </Listbox.Options>
            </div>
          </Listbox> */}
        </div>
        <div className="mt-3 flex justify-between">
          <p className="font-roboto-mono text-xs text-neutral-500">
            PRICE ({marketData.quote.symbol})
          </p>
          <p className="font-roboto-mono text-xs text-neutral-500">
            SIZE ({marketData.base?.symbol})
          </p>
        </div>
      </div>
      {/* bids ask spread scrollable container */}
      <div className="scrollbar-none relative grow overflow-y-auto">
        {isLoading ? (
          <div className="absolute w-full">
            {Array.from({ length: 60 }, (_, i) => (
              <div
                className="relative flex h-6 w-full cursor-pointer items-center justify-between py-[1px] hover:ring-1 hover:ring-neutral-600"
                key={"skeleton-" + i}
              >
                <Skeleton
                  containerClassName={`z-10 ml-2 font-roboto-mono text-xs text-left`}
                  style={{
                    width: `${i % 2 == 0 ? 90 : 70}px`,
                  }}
                />
                <Skeleton
                  containerClassName="z-10 mr-2 py-0.5 font-roboto-mono text-xs text-white text-right"
                  style={{
                    width: `${i % 2 == 0 ? 90 : 70}px`,
                  }}
                />

                <div className={`absolute right-0 z-0 h-full opacity-30`}></div>
              </div>
            ))}
          </div>
        ) : (
          <div className="absolute w-full">
            {/* ASK */}
            {data?.asks
              .slice()
              .reverse()
              .map((level) => (
                <Row
                  level={level}
                  type={"ask"}
                  key={`ask-${level.price}-${level.size}`}
                  highestSize={highestSize}
                  marketData={marketData}
                  updatedLevel={data.updatedLevel}
                />
              ))}
            {/* SPREAD */}
            <div
              className="flex items-center justify-between border-y border-neutral-600"
              ref={centerRef}
            >
              <div className="z-10 ml-4 text-right font-roboto-mono text-xs text-white">
                {toDecimalPrice({
                  price: new BigNumber(midPrice?.price || 0),
                  lotSize: BigNumber(marketData.lot_size),
                  tickSize: BigNumber(marketData.tick_size),
                  baseCoinDecimals: BigNumber(marketData.base?.decimals || 0),
                  quoteCoinDecimals: BigNumber(marketData.quote?.decimals || 0),
                }).toNumber()}
              </div>
              <div className="mr-4 font-roboto-mono text-white">
                {midPrice?.size || "-"}
              </div>
            </div>
            {/* BID */}
            {data?.bids.map((level) => (
              <Row
                level={level}
                type={"bid"}
                key={`bid-${level.price}-${level.size}`}
                highestSize={highestSize}
                marketData={marketData}
                updatedLevel={data.updatedLevel}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
