import { API_URL } from "@/env";
import { ApiMarket } from "@/types/api";
import { useQuery } from "@tanstack/react-query";
import React, { useEffect } from "react";
import { BaseModal } from "../BaseModal";
import { Menu } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { Button } from "../Button";

export const DepositWithdrawModal: React.FC<{
  open: boolean;
  onClose: () => void;
}> = ({ open, onClose }) => {
  const allMarketData = useQuery<ApiMarket[]>(["allMarketData"], async () => {
    return fetch(new URL("markets", API_URL).href).then((res) => res.json());
  });
  const [selectedMarket, setSelectedMarket] = React.useState<ApiMarket>();
  useEffect(() => {
    if (
      allMarketData.data &&
      allMarketData.data.length > 0 &&
      selectedMarket === undefined
    ) {
      setSelectedMarket(allMarketData.data?.[0]);
    }
  }, [allMarketData.data]);
  return (
    <BaseModal open={open} onClose={onClose}>
      <div className="flex w-full flex-col items-center gap-6">
        <h4 className="font-jost text-3xl font-bold text-white">
          Select a Market
        </h4>

        {selectedMarket && (
          <div className="flex items-center gap-2">
            <p className="whitespace-nowrap text-white">
              {selectedMarket.name}
            </p>
            <ChevronDownIcon className="h-[24px] w-[24px] fill-white" />
          </div>
        )}

        <Button variant="primary">Create Account</Button>
      </div>
    </BaseModal>
  );
};
