import { useMemo, useState } from "react";

import { type ApiMarket } from "@/types/api";

import { BaseModal } from "../BaseModal";
import { AccountDetailsContent } from "../content/AccountDetailsContent";
import { RegisterAccountContent } from "../content/RegisterAccountContent";

type Props = {
  allMarketData: ApiMarket[];
  isOpen: boolean;
  onClose: () => void;
};

type WalletButtonModalState =
  | "accountDetails"
  | "registerAccount"
  | "selectMarket"
  | "depositWithdraw";

export const WalletButtonFlowModal: React.FC<Props> = ({
  allMarketData,
  isOpen,
  onClose,
}) => {
  const [state, setState] = useState<WalletButtonModalState>("accountDetails");
  const [selectedMarketId, setSelectedMarketId] = useState<number>(
    allMarketData[0].market_id,
  );
  const selectedMarket = useMemo(
    () => allMarketData.find(({ market_id }) => market_id === selectedMarketId),
    [allMarketData, selectedMarketId],
  );

  return (
    <>
      {state === "accountDetails" && (
        <BaseModal
          isOpen={isOpen}
          onClose={onClose}
          showBackButton={false}
          showCloseButton={true}
        >
          <AccountDetailsContent />
        </BaseModal>
      )}
      {state === "registerAccount" && (
        <BaseModal
          isOpen={isOpen}
          onBack={() => setState("accountDetails")}
          onClose={onClose}
          showBackButton={true}
          showCloseButton={true}
        >
          <RegisterAccountContent
            selectedMarket={selectedMarket}
            selectMarket={() => {
              console.error("TODO");
            }}
          />
        </BaseModal>
      )}
    </>
  );
};
