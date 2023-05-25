import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import Link from "next/link";

type Props = {
  marketNames: string[];
  selectedMarket: string;
};

export function StatsBar({ marketNames, selectedMarket }: Props) {
  return (
    <div className="flex border-b border-neutral-600 bg-black px-4 py-2">
      <div className="flex flex-1 items-center">
        <Listbox value={selectedMarket}>
          <div className="relative w-[160px]">
            <Listbox.Button className="flex px-4 font-roboto-mono text-neutral-300">
              {selectedMarket}
              <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-neutral-500" />
            </Listbox.Button>
            <Listbox.Options className="absolute mt-2 w-full bg-black shadow ring-1 ring-neutral-500">
              {marketNames.map((marketName, i) => (
                <Link href={`/trade/${marketName}`} key={i}>
                  <Listbox.Option
                    value={marketName}
                    className="px-4 py-1 font-roboto-mono text-neutral-300 hover:bg-neutral-800"
                  >
                    {marketName}
                  </Listbox.Option>
                </Link>
              ))}
            </Listbox.Options>
          </div>
        </Listbox>
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            Last price
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">$0.00</span>
            <span className="text-green-500 ml-8">+0.00</span>
          </p>
        </div>
      </div>
      <div className="my-auto">
        <div className="flex flex-1 justify-end">
          <p className="font-roboto-mono text-white">Socials</p>
        </div>
      </div>
    </div>
  );
}
