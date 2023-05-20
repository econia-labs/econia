import { API_URL } from "@/env";
import { ApiMarket } from "@/types/api";
import { useQuery } from "@tanstack/react-query";
import React, { useEffect } from "react";
import { BaseModal } from "../BaseModal";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { Button } from "../Button";
import { Tab } from "@headlessui/react";
import { Input } from "../Input";

enum Step {
  Initial,
  SelectMarket,
  DepositWithdraw,
}

const useAllMarketData = () => {
  return useQuery<ApiMarket[]>(["allMarketData"], async () => {
    return fetch(new URL("markets", API_URL).href).then((res) => res.json());
  });
};

const InitialContent: React.FC<{
  selectedMarket?: ApiMarket;
  selectMarket: () => void;
  depositWithdraw: () => void;
}> = ({ selectedMarket, selectMarket, depositWithdraw }) => {
  return (
    <div className="flex w-full flex-col items-center gap-6">
      <h4 className="font-jost text-3xl font-bold text-white">
        Select a Market
      </h4>

      {selectedMarket && (
        <div
          className="flex cursor-pointer items-center gap-2"
          onClick={selectMarket}
        >
          <p className="whitespace-nowrap text-white">{selectedMarket.name}</p>
          <ChevronDownIcon className="h-[24px] w-[24px] fill-white" />
        </div>
      )}

      {/* TODO */}
      {/* <Button variant="primary">Create Account</Button> */}
      <Button variant="primary" onClick={depositWithdraw}>
        Deposit / Withdraw
      </Button>
    </div>
  );
};

const SelectMarketContent: React.FC<{
  onSelectMarket: (market: ApiMarket) => void;
}> = ({ onSelectMarket }) => {
  const allMarketData = useAllMarketData();
  return (
    <div className="flex w-full flex-col items-center gap-6">
      <h4 className="font-jost text-3xl font-bold text-white">
        Select a Market
      </h4>

      <div className="max-h-50 flex flex-col gap-2 overflow-y-scroll">
        {allMarketData.data?.map((market) => (
          <div
            key={market.market_id}
            className="flex cursor-pointer items-center gap-2 border border-white p-4"
            onClick={() => onSelectMarket(market)}
          >
            <p className="whitespace-nowrap text-white">{market.name}</p>
          </div>
        ))}
      </div>
    </div>
  );
};

const DepositWithdrawContent: React.FC<{
  selectedMarket?: ApiMarket;
}> = ({ selectedMarket }) => {
  return (
    <div className="mt-12 flex w-full flex-col items-center gap-6">
      <Tab.Group>
        <Tab.List className="w-full">
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Deposit
          </Tab>
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Withdraw
          </Tab>
        </Tab.List>
        <Tab.Panels className="w-full">
          <Tab.Panel className="flex flex-col gap-4">
            <Input />
            <Input placeholder="0.00" />
            <div className="flex w-full justify-between">
              <p className="font-roboto-mono uppercase text-neutral-500">
                Available in market account
              </p>
              <p className="font-roboto-mono uppercase text-neutral-500">
                1111.22 APT
              </p>
            </div>
            <div className="flex w-full justify-between">
              <p className="font-roboto-mono uppercase text-neutral-500">
                In Wallet
              </p>
              <p className="font-roboto-mono uppercase text-neutral-500">
                111.22 APT
              </p>
            </div>
            <Button variant="primary">Deposit</Button>
          </Tab.Panel>
          <Tab.Panel className="flex flex-col gap-4">
            <Input />
            <Input placeholder="0.00" />
            <div className="flex w-full justify-between">
              <p className="font-roboto-mono uppercase text-neutral-500">
                Available in market account
              </p>
              <p className="font-roboto-mono uppercase text-neutral-500">
                1111.22 APT
              </p>
            </div>
            <div className="flex w-full justify-between">
              <p className="font-roboto-mono uppercase text-neutral-500">
                In Wallet
              </p>
              <p className="font-roboto-mono uppercase text-neutral-500">
                111.22 APT
              </p>
            </div>
            <Button variant="primary">Withdraw</Button>
          </Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};

export const DepositWithdrawModal: React.FC<{
  open: boolean;
  onClose: () => void;
}> = ({ open, onClose }) => {
  const [selectedMarket, setSelectedMarket] = React.useState<ApiMarket>();
  const [step, setStep] = React.useState<Step>(Step.Initial);
  const allMarketData = useAllMarketData();
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
    <BaseModal
      open={open}
      onClose={onClose}
      onBack={
        step === Step.SelectMarket
          ? () => setStep(Step.Initial)
          : step === Step.DepositWithdraw
          ? () => setStep(Step.Initial)
          : undefined
      }
    >
      {step === Step.Initial && (
        <InitialContent
          selectedMarket={selectedMarket}
          selectMarket={() => setStep(Step.SelectMarket)}
          depositWithdraw={() => setStep(Step.DepositWithdraw)}
        />
      )}
      {step === Step.SelectMarket && (
        <SelectMarketContent
          onSelectMarket={(market) => {
            setSelectedMarket(market);
            setStep(Step.Initial);
          }}
        />
      )}
      {step === Step.DepositWithdraw && (
        <DepositWithdrawContent selectedMarket={selectedMarket} />
      )}
    </BaseModal>
  );
};
