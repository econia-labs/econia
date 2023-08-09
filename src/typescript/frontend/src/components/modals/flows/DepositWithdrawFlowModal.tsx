import { type ApiMarket } from "@/types/api";

import { BaseModal } from "../BaseModal";
import { DepositWithdrawContent } from "../content/DepositWithdrawContent";

type Props = {
  selectedMarket: ApiMarket;
  isOpen: boolean;
  onClose: () => void;
};

export const DepositWithdrawFlowModal: React.FC<Props> = ({
  selectedMarket,
  isOpen,
  onClose,
}) => {
  return (
    <BaseModal
      isOpen={isOpen}
      onClose={onClose}
      showCloseButton={true}
      showBackButton={false}
    >
      <DepositWithdrawContent
        selectedMarket={selectedMarket}
      ></DepositWithdrawContent>
    </BaseModal>
  );
};
