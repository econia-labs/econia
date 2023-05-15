import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useEffect, useState } from "react";
import { ApiMarket } from "@/types/api";

type OrderPrice = {
  price: number;
  amount: number;
  volume: number;
};

const generateMockData = (): { asks: OrderPrice[]; bids: OrderPrice[] } => {
  const asks: OrderPrice[] = [];
  const bids: OrderPrice[] = [];

  for (let i = 0; i < 10; i++) {
    const price = Math.floor(Math.random() * 100);
    const amount = Math.floor(Math.random() * 10);
    const volume = Math.floor(Math.random() * 100);
    const order = { price, amount, volume };

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

  useEffect(() => {
    // use mock data if no market data is provided
    if (!asks.length && !bids.length) {
      const mockData = generateMockData();
      setAsks(mockData.asks);
      setBids(mockData.bids);
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
        style={{ width: `${order.volume}%` }}
      ></div>
    </div>
  );

  return (
    <div>
      {/* title row */}
      <div>
        <p className={"ml-4 mt-2 font-jost text-white"}>Order Book</p>
        <p>granularity dropdown</p>
      </div>
      {/* ASK */}
      <div>
        {asks.map((order, index) => (
          <Row order={order} type={"sell"} key={"ask" + index} />
        ))}
      </div>
      {/* equilibrium */}
      <div className="flex items-center justify-center bg-gray-300 text-sm font-bold">
        Equilibrium
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
