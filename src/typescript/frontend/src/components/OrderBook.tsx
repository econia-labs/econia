import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useState } from "react";
import { ApiMarket } from "@/types/api";

type Props = {
  marketNames: string[];
};

export function OrderBook({ marketData }: { marketData: ApiMarket }) {
  // const [selectedMarket, setSelectedMarket] = useState<string>(marketNames[0]);

  return (
    <div>
      <p className={"ml-4 mt-2 font-jost text-white"}>Order Book</p>
    </div>
  );
}
