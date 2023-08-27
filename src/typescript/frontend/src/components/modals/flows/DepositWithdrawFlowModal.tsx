import { type ApiMarket } from "@/types/api";

import { BaseModal } from "../BaseModal";
import { DepositWithdrawContent } from "../content/DepositWithdrawContent";
import { AccountDetailsContent } from "../content/AccountDetailsContent";
import { useEffect, useState } from "react";
import { RegisterAccountContent } from "../content/RegisterAccountContent";

type Props = {
  selectedMarket: ApiMarket;
  isOpen: boolean;
  onClose: () => void;
};

/**
 * Modal flows:
 * 1. Account Details -> Deposit/Withdraw
 * 2. Account Details -> Register Account -> Select Market -> Account Details // wait for on chain registration / loader
 */
enum FlowStep {
  AccountDetails,
  DepositWithdraw,
  RegisterAccount,
  MarketSelect,
  Closed,
}

export const DepositWithdrawFlowModal: React.FC<Props> = ({
  selectedMarket,
  isOpen,
  onClose,
}) => {
  const [market, setMarket] = useState(selectedMarket);
  const [flowStep, setFlowStep] = useState(FlowStep.Closed);

  const onDepositWithdrawClick = (selected: ApiMarket) => {
    setMarket(selected);
    // assumes that market selected is valid
    setFlowStep(FlowStep.DepositWithdraw);
  };
  const onRegisterAccountClick = () => {
    setFlowStep(FlowStep.RegisterAccount);
  };

  useEffect(() => {
    if (isOpen && flowStep === FlowStep.Closed) {
      setFlowStep(FlowStep.AccountDetails);
    }

    // if the modal is closed, we want to reset the flow step and trigger the onClose callback
    if (!isOpen) {
      onClose();
      setFlowStep(FlowStep.Closed);
    }
  }, [isOpen, flowStep, onClose]);

  return (
    <>
      {flowStep === FlowStep.AccountDetails && (
        <BaseModal
          isOpen={isOpen}
          onClose={onClose}
          showCloseButton={true}
          showBackButton={false}
        >
          <AccountDetailsContent
            onClose={onClose}
            onDepositWithdrawClick={onDepositWithdrawClick}
            onRegisterAccountClick={onRegisterAccountClick}
          />
        </BaseModal>
      )}
      {flowStep === FlowStep.DepositWithdraw && (
        <BaseModal
          isOpen={flowStep === FlowStep.DepositWithdraw}
          onClose={onClose}
          // custom step, so we don't want to close the modal when the user clicks the close button
          // rather we go back to the account details step
          onBack={() => {
            setFlowStep(FlowStep.AccountDetails);
          }}
          showCloseButton={true}
          showBackButton={true}
        >
          <DepositWithdrawContent
            selectedMarket={market}
          ></DepositWithdrawContent>
        </BaseModal>
      )}
      {/* todo */}
      {flowStep === FlowStep.RegisterAccount && (
        <BaseModal isOpen={isOpen} onClose={onClose} showCloseButton={true}>
          <RegisterAccountContent
            selectedMarket={selectedMarket}
            selectMarket={() => {
              console.error("TODO");
            }}
          />
        </BaseModal>
      )}
      {/* todo */}
      {flowStep === FlowStep.MarketSelect && (
        <BaseModal isOpen={isOpen} onClose={onClose} showCloseButton={true}>
          <RegisterAccountContent
            selectedMarket={selectedMarket}
            selectMarket={onRegisterAccountClick}
          />
        </BaseModal>
      )}
    </>
  );
};
