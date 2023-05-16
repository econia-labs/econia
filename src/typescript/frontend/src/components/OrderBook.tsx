import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useEffect, useState } from "react";
import { ApiMarket } from "@/types/api";
import { set } from "react-hook-form";

type OrderPrice = {
  price: number;
  amount: number;
  depth: number;
};

const generateMockData = (): { asks: OrderPrice[]; bids: OrderPrice[] } => {
  const asks: OrderPrice[] = [];
  const bids: OrderPrice[] = [];

  for (let i = 0; i < 30; i++) {
    const price = Math.floor(Math.random() * 100);
    const amount = Math.floor(Math.random() * 10);
    const depth = Math.floor(Math.random() * 100);
    const order = { price, amount, depth };

    if (i % 2 === 0) {
      asks.push(order);
    } else {
      bids.push(order);
    }
  }

  return { asks, bids };
};

export function OrderBook({ marketData }: { marketData: ApiMarket }) {
  const [asks, setAsks] = useState<OrderPrice[]>([]);
  const [bids, setBids] = useState<OrderPrice[]>([]);
  const [spread, setSpread] = useState<OrderPrice>();

  const [selectedMarket, setSelectedMarket] = useState<string>("0.01");

  useEffect(() => {
    // use mock data if no market data is provided
    if (!asks.length && !bids.length) {
      const mockData = generateMockData();
      setAsks(mockData.asks);
      setBids(mockData.bids);
      setSpread({
        price: mockData.asks[0].price - mockData.bids[0].price,
        amount: 10,
        depth: 0,
      });
    }
  }, []);

  const Row = ({ order, type }: { order: OrderPrice; type: string }) => (
    <div
      // key={key}
      className={`relative my-[1px] flex min-h-[25px] min-w-full items-center justify-between text-xs `}
    >
      <div
        className={`z-10 ml-4 text-right ${
          type === "sell" ? "text-red-400" : "text-green"
        }`}
      >
        {order.price}
      </div>
      <div className="z-10 mr-4 text-white">{order.amount}</div>
      <div
        className={`absolute right-0 z-0 h-full opacity-30 ${
          type === "sell" ? "bg-red-400" : "bg-green"
        }`}
        // dynamic taillwind?
        style={{ width: `${order.depth}%` }}
      ></div>
    </div>
  );

  return (
    <div className="divider-solid divide-y divide-neutral-600">
      {/* title row */}
      <div className={"mx-4 my-[12px]"}>
        <div className={"flex justify-between"}>
          <p className={"font-jost text-white"}>Order Book</p>
          <Listbox value={selectedMarket} onChange={setSelectedMarket}>
            <div className="relative min-h-[30px]  border border-neutral-600 px-[11px] py-[8px]">
              <Listbox.Button className="flex  font-roboto-mono text-neutral-300">
                {selectedMarket}
                <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-neutral-500" />
              </Listbox.Button>
              <Listbox.Options className="absolute mt-2 w-full bg-black shadow ring-1 ring-neutral-500">
                {[].map((marketName, i) => (
                  <Listbox.Option
                    key={i}
                    value={marketName}
                    className="weight-300 px-4 py-1 font-roboto-mono text-xs text-neutral-300 hover:bg-neutral-800"
                  >
                    {marketName}
                  </Listbox.Option>
                ))}
              </Listbox.Options>
            </div>
          </Listbox>
        </div>
        <div
          className={`mt-[11px] flex justify-between text-xs text-neutral-500`}
        >
          <div className={``}>PRICE (USD)</div>
          <div>AMOUNT (APT)</div>
        </div>
      </div>
      {/* ASK */}
      <div>
        {asks.map((order, index) => (
          <Row order={order} type={"sell"} key={"ask" + index} />
        ))}
      </div>
      {/* SPREAD */}
      <div className="flex min-h-[40px] items-center justify-between text-xs ">
        <div className={`z-10 ml-4 text-right text-white`}>
          {spread?.price || "-"}
        </div>
        <div className="z-10 mr-4 text-white">{spread?.amount || "-"}</div>
      </div>
      {/* BID */}
      <div>
        {bids.map((order, index) => (
          <Row order={order} type={"buy"} key={"buy" + index} />
        ))}
      </div>
    </div>
  );
}
