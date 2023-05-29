import { Listbox } from "@headlessui/react";
import { CheckIcon, ChevronDownIcon } from "@heroicons/react/20/solid";
import { useEffect, useMemo, useRef, useState } from "react";

import { useOrderBook } from "@/hooks/useOrderbook";
import { type ApiMarket } from "@/types/api";
import { type Precision } from "@/types/global";
import { type OrderBook, type PriceLevel } from "@/types/global";

const precisionOptions: Precision[] = [
  "0.01",
  "0.05",
  "0.1",
  "0.5",
  "1",
  "2.5",
  "5",
  "10",
];

const Row: React.FC<{
  order: PriceLevel;
  type: "bid" | "ask";
  highestSize: number;
}> = ({ order, type, highestSize }) => (
  <div className="relative my-[1px] flex min-h-[25px] min-w-full items-center justify-between text-xs">
    <div
      className={`z-10 ml-4 text-right ${
        type === "ask" ? "text-red" : "text-green"
      }`}
    >
      {order.price}
    </div>
    <div className="z-10 mr-4 text-white">{order.size}</div>
    <div
      className={`absolute right-0 z-0 h-full opacity-30 ${
        type === "ask" ? "bg-red" : "bg-green"
      }`}
      // dynamic taillwind?

      style={{ width: `${(100 * order.size) / highestSize}%` }}
    ></div>
  </div>
);

export function OrderBook({ marketData }: { marketData: ApiMarket }) {
  const [precision, setPrecision] = useState<Precision>(precisionOptions[0]);
  const { data, isFetching, isLoading } = useOrderBook(
    marketData.market_id,
    precision
  );

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
    // if there are bids but no asks
    if ((!data.asks || data.asks.length === 0) && data.bids.length > 0) {
      return {
        price: data.bids[0].price,
        size: data.bids[0].size,
      };
    }
    // if there are asks but no bids
    if ((!data.bids || data.bids.length === 0) && data.asks.length > 0) {
      return {
        price: data.asks[0].price,
        size: data.asks[0].size,
      };
    }
    return {
      price: (data.asks[0].price + data.bids[0].price) / 2,
      size: 0,
    };
  }, [data]);

  const highestSize = useMemo(() => {
    if (data == null) {
      return 0;
    }
    return Math.max(
      ...data.asks.map((order) => order.size),
      ...data.bids.map((order) => order.size)
    );
  }, [data]);

  if (isLoading) {
    return (
      <div className="flex h-full flex-col items-center justify-center text-sm font-light uppercase text-neutral-500">
        Loading...
      </div>
    );
  }

  return (
    <div className="flex grow flex-col divide-y divide-solid divide-neutral-600">
      {/* title row */}
      <div className={"mx-4 my-[12px]"}>
        <div className={"flex justify-between"}>
          <p className={"font-jost font-bold text-white"}>Order Book</p>
          {/* select */}
          <Listbox value={precision} onChange={setPrecision}>
            <div className="relative z-30 min-h-[30px] border border-neutral-600 py-[8px] pl-[11px] pr-[8px]">
              <Listbox.Button className="flex min-w-[4em] justify-between font-roboto-mono text-neutral-300">
                {precision}
                <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-neutral-500" />
              </Listbox.Button>
              <Listbox.Options className="absolute left-0 top-11 mt-2 w-full bg-black shadow ring-1 ring-neutral-600">
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
          </Listbox>
        </div>
        <div
          className={`mt-[11px] flex justify-between text-xs text-neutral-500`}
        >
          <div className={``}>PRICE ({marketData.quote.symbol})</div>
          <div>Size ({marketData.base?.symbol})</div>
        </div>
      </div>
      {/* bids ask spread scrollable container */}
      <div className="scrollbar-none relative grow overflow-y-auto ">
        <div className="absolute w-full ">
          {/* ASK */}
          {data?.asks.map((order) => (
            <Row
              order={order}
              type={"ask"}
              key={`ask-${order.price}-${order.size}`}
              highestSize={highestSize}
            />
          ))}
          {/* SPREAD */}
          <div
            className="flex min-h-[40px] items-center justify-between border border-neutral-600 text-xs"
            ref={centerRef}
          >
            <div className={`z-10 ml-4 text-right text-white`}>
              {midPrice?.price || "-"}
            </div>
            <div className="z-10 mr-4 text-white">{midPrice?.size || "-"}</div>
          </div>
          {/* BID */}
          {data?.bids.map((order) => (
            <Row
              order={order}
              type={"bid"}
              key={`bid-${order.price}-${order.size}`}
              highestSize={highestSize}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
