import { Tab } from "@headlessui/react";
import { useState } from "react";

import { type Side } from "@/types/global";

export function OrderEntry() {
  const [selectedSide, setSelectedSide] = useState<Side>("buy");
  return (
    <div className="mt-2">
      <div className="flex">
        <button
          onClick={() => setSelectedSide("buy")}
          className={`mx-1 w-full border py-1 font-jost ${
            selectedSide == "buy"
              ? "border-green-400 border-opacity-80 text-green-400"
              : "border-neutral-500 bg-neutral-900 text-neutral-500"
          }`}
        >
          Buy
        </button>
        <button
          onClick={() => setSelectedSide("sell")}
          className={`mx-1 w-full border font-jost ${
            selectedSide == "sell"
              ? "border-red-400 border-opacity-80 text-red-400"
              : "border-neutral-500 bg-neutral-900 text-neutral-500"
          }`}
        >
          Sell
        </button>
      </div>
      <Tab.Group>
        <Tab.List className="mt-3 flex">
          <Tab className="w-full font-roboto-mono text-sm font-light uppercase outline-none ui-selected:text-white ui-not-selected:text-neutral-500">
            Limit
          </Tab>
          <Tab className="w-full font-roboto-mono text-sm font-light uppercase outline-none ui-selected:text-white ui-not-selected:text-neutral-500">
            Market
          </Tab>
          <Tab className="w-full font-roboto-mono text-sm font-light uppercase outline-none ui-selected:text-white ui-not-selected:text-neutral-500">
            Stop Limit
          </Tab>
        </Tab.List>
        <Tab.Panels className="mt-2">
          <Tab.Panel className="px-2 font-jost text-white">
            Market Order Entry
          </Tab.Panel>
          <Tab.Panel className="px-2 font-jost text-white">
            Limit Order Entry
          </Tab.Panel>
          <Tab.Panel className="px-2 font-jost text-white">
            Stop Limit Order Entry
          </Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
}
