import { type ApiMarket } from "@/types/api";

import { BaseModal } from "../BaseModal";
import { DepositWithdrawContent } from "../content/DepositWithdrawContent";
import { useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MOCK_MARKETS } from "@/mockdata/markets";

type Props = {
  selectedMarket: ApiMarket;
  allMarketData: ApiMarket[];
  isOpen: boolean;
  onClose: () => void;
};

/**
 * Modal states:
 * 1. Market Account is registered, able to interact and data is available
 * 2. Market account is not registered, unable to interact and data is not available until account is created
 */

export const DepositWithdrawFlowModal: React.FC<Props> = ({
  selectedMarket,
  isOpen,
  onClose,
  allMarketData,
}) => {
  const { account } = useWallet();

  // TODO: change this after merge with ECO-319
  const { data: registeredMarkets } = useQuery(
    ["userMarketAccounts", account?.address],
    () => {
      // TODO pull registered markets from SDK (ECO-355)
      return MOCK_MARKETS;
    },
  );

  const isRegistered = useMemo(
    () =>
      !!registeredMarkets &&
      registeredMarkets.some(
        (market) => market.market_id === selectedMarket.market_id,
      ),
    [registeredMarkets, selectedMarket],
  );

  return (
    <>
      <BaseModal
        isOpen={isOpen}
        onClose={onClose}
        showCloseButton={true}
        showBackButton={false}
      >
        <DepositWithdrawContent
          isRegistered={isRegistered}
          selectedMarket={selectedMarket}
        />
      </BaseModal>
    </>
  );
};
