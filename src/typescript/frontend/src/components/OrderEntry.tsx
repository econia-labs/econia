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
    </div>
  );
}
