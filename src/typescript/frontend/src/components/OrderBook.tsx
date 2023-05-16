import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery, type UseQueryResult } from "@tanstack/react-query";
import { useEffect, useMemo, useRef, useState } from "react";

import { type ApiMarket } from "@/types/api";

type PriceLevel = {
  price: number;
  size: number;
};

type OrderBook = {
  bids: PriceLevel[];
  asks: PriceLevel[];
};

const Row = ({
  order,
  type,
  highestSize,
}: {
  order: PriceLevel;
  type: string;
  highestSize: number;
}) => (
  <div
    className={`relative my-[1px] flex min-h-[25px] min-w-full items-center justify-between text-xs `}
  >
    <div
      className={`z-10 ml-4 text-right ${
        type === "sell" ? "text-red-400" : "text-green"
      }`}
    >
      {order.price}
    </div>
    <div className="z-10 mr-4 text-white">{order.size}</div>
    <div
      className={`absolute right-0 z-0 h-full opacity-30 ${
        type === "sell" ? "bg-red-400" : "bg-green"
      }`}
      // dynamic taillwind?
      style={{ width: `${(100 * order.size) / highestSize}%` }}
    ></div>
  </div>
);

const precisionOptions = ["0.01", "0.05", "0.1", "0.5", "1", "2.5", "5", "10"];

export function OrderBook({ marketData }: { marketData: ApiMarket }) {
  const [precision, setPrecision] = useState<string>(precisionOptions[0]);
  const { data, isLoading } = useQuery(
    ["orderBook", marketData.market_id, precision],
    async () => {
      const response = await fetch(
        `https://dev.api.econia.exchange/market/${marketData.market_id}/orderbook?depth=60`
      );
      const data = await response.json();
      return data as OrderBook;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false }
  );

  const centerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    centerRef.current?.scrollIntoView({ behavior: "smooth", block: "center" });
  }, [data]);

  const spread = useMemo(() => {
    if (data == null) {
      return undefined;
    }
    return {
      price: (data.asks[0].price + data.bids[0].price) / 2,
      size: 1,
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
    // TODO loading UI
    return null;
  }

  return (
    <div className="divider-solid flex grow flex-col divide-y divide-neutral-600">
      {/* title row */}
      <div className={"mx-4 my-[12px]"}>
        <div className={"flex justify-between"}>
          <p className={"font-jost text-white"}>Order Book</p>
          {/* select */}
          <Listbox value={precision} onChange={setPrecision}>
            <div className="relative z-30  min-h-[30px] border border-neutral-600 py-[8px] pl-[11px] pr-[8px]">
              <Listbox.Button className=" flex min-w-[4em] justify-between font-roboto-mono text-neutral-300">
                {precision}
                <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-neutral-500" />
              </Listbox.Button>
              <Listbox.Options className="absolute mt-2 w-full bg-black shadow ring-1 ring-neutral-500">
                {precisionOptions.map((precision, i) => (
                  <Listbox.Option
                    key={i}
                    value={precision}
                    className="weight-300 cursor-pointer px-4 py-1 font-roboto-mono text-xs text-neutral-300 hover:bg-neutral-800"
                  >
                    {precision}
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
      <div className={`scrollbar grow overflow-y-auto`}>
        {/* i don't understand why this suddenly solved my problem but it did lol */}
        {/* the problem i was having was that the rows were making a flex parent increase in size,
        which is not expected. the goal was to have the rows scrollable with a dynamically sized parent
        according to window size but not have the parent increase in size when the rows were added.
        */}
        {/* basically my understanding of what's going on is:
        since the rows are already overflowing the child they aren't affecting the size of this 'new' parent?
         */}
        <div className="max-h-0">
          {/* ASK */}
          <div>
            {data?.asks.map((order, index) => (
              <Row
                order={order}
                type={"sell"}
                key={"ask" + index}
                highestSize={highestSize}
              />
            ))}
          </div>
          {/* SPREAD */}
          <div
            className="flex min-h-[40px] items-center justify-between text-xs "
            ref={centerRef}
          >
            <div className={`z-10 ml-4 text-right text-white`}>
              {spread?.price || "-"}
            </div>
            <div className="z-10 mr-4 text-white">{spread?.size || "-"}</div>
          </div>
          {/* BID */}
          <div>
            {data?.bids.map((order, index) => (
              <Row
                order={order}
                type={"buy"}
                key={"buy" + index}
                highestSize={highestSize}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// refetch
// pause
