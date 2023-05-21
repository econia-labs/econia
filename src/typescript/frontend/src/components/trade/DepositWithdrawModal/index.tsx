import { API_URL } from "@/env";
import { ApiMarket } from "@/types/api";
import { useQuery } from "@tanstack/react-query";
import React, { useEffect } from "react";
import { BaseModal } from "../../BaseModal";
import { DepositWithdrawContent } from "./DepositWithdrawContent";
import { InitialContent } from "./InitialContent";
import { SelectMarketContent } from "./SelectMarketContent";

enum Step {
  Initial,
  SelectMarket,
  DepositWithdraw,
}

export const useAllMarketData = () => {
  return useQuery<ApiMarket[]>(["allMarketData"], async () => {
    return fetch(new URL("markets", API_URL).href).then((res) => res.json());
  });
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
      {step === Step.DepositWithdraw &&
        (selectedMarket !== undefined ? (
          <DepositWithdrawContent selectedMarket={selectedMarket} />
        ) : (
          <div>Unexpected error: no market selected</div>
        ))}
    </BaseModal>
  );
};
