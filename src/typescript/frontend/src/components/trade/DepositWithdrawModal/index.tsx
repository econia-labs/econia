import { useQuery } from "@tanstack/react-query";
import React, { useEffect } from "react";

import { API_URL } from "@/env";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { type ApiMarket, type ApiStats } from "@/types/api";

import { BaseModal } from "../../BaseModal";
import { DepositWithdrawContent } from "./DepositWithdrawContent";
import { InitialContent } from "./InitialContent";
import { SelectMarketContent } from "./SelectMarketContent";

enum Step {
  Initial,
  SelectMarket,
  DepositWithdraw,
}

export const useAllMarketStats = () => {
  return useQuery<ApiStats[]>(["allMarketStats"], async () => {
    return fetch(new URL("stats?resolution=1d", API_URL).href).then((res) => {
      return res.json();
    });
  });
};
// TODO: remove before PR
export const useAllMarketData = () => {
  return useQuery<ApiMarket[]>(["allMarketData"], async () => {
    return fetch(new URL("markets", API_URL).href).then(async (res) => {
      // const d = await res.json();
      // TODO: Remove once real data exists
      const d = MOCK_MARKETS;
      return d.map((m: ApiMarket, i: number) => {
        m.recognized = i % 2 === 0 ? true : false;
        return m;
      });
    });
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
  }, [allMarketData.data, selectedMarket]);
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
      showBackButton={step === Step.DepositWithdraw}
      showCloseButton={step !== Step.SelectMarket}
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
