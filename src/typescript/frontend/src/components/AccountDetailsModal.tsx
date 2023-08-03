import { entryFunctions } from "@econia-labs/sdk";
import { Menu, Tab } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import React, { useState } from "react";

import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { NO_CUSTODIAN } from "@/constants";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { useCoinBalance } from "@/hooks/useCoinBalance";
import { useMarketAccountBalance } from "@/hooks/useMarketAccountBalance";
import { type ApiCoin, type ApiMarket } from "@/types/api";
import { toRawCoinAmount } from "@/utils/coin";
import { TypeTag } from "@/utils/TypeTag";

export const AccountDetailsModal: React.FC<{
  selectedMarket: ApiMarket;
}> = ({ selectedMarket }) => {
  return (
    <div className="mt-12 flex w-full flex-col items-center gap-6">
      <Tab.Group>
        <Tab.List className="w-full">
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Deposit
          </Tab>
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Withdraw
          </Tab>
        </Tab.List>
        <Tab.Panels className="w-full">
          <Tab.Panel>
            <div>test</div>
          </Tab.Panel>
          <Tab.Panel>
            <div>test2</div>
          </Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};
