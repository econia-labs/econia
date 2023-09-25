import { type ApiMarket } from "@/types/api";

import { BaseModal } from "../BaseModal";
import { DepositWithdrawContent } from "../content/DepositWithdrawContent";
import { AccountDetailsContent } from "../content/AccountDetailsContent";
import { useEffect, useMemo, useState } from "react";
import { RegisterAccountContent } from "../content/RegisterAccountContent";
import { SelectMarketContent } from "@/components/trade/DepositWithdrawModal/SelectMarketContent";
import { useQuery } from "@tanstack/react-query";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { set } from "react-hook-form";
import { toast } from "react-toastify";

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
