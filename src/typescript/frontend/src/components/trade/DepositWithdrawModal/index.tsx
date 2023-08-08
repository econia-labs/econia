import { useQuery } from "@tanstack/react-query";
import React, { useMemo, useState } from "react";

import { API_URL } from "@/env";
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

export const DepositWithdrawModal: React.FC<{
  allMarketData: ApiMarket[];
  open: boolean;
  onClose: () => void;
}> = ({ allMarketData, open, onClose }) => {
  const [selectedMarketId, setSelectedMarketId] = useState<number>(
    allMarketData[0].market_id,
  );
  const selectedMarket = useMemo(() => {
    return allMarketData.find(
      ({ market_id }) => market_id === selectedMarketId,
    );
  }, [selectedMarketId, allMarketData]);

  const [step, setStep] = useState<Step>(Step.Initial);

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
          allMarketData={allMarketData}
          onSelectMarket={(marketId: number) => {
            // TODO clean up once ECO-327 is resolved
            setSelectedMarketId(marketId);
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
