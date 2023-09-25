import { useWallet } from "@aptos-labs/wallet-adapter-react";
import {
  ArrowRightOnRectangleIcon,
  Square2StackIcon,
} from "@heroicons/react/24/outline";
import { useQuery } from "@tanstack/react-query";

import { Button } from "@/components/Button";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { type ApiMarket } from "@/types/api";

const MarketCard = ({
  market,
  onDepositWithdrawClick,
}: {
  market: ApiMarket;
  onDepositWithdrawClick: (selected: ApiMarket) => void;
}) => {
  return (
    <div className="mt-4 border border-neutral-600 px-6 py-4">
      <h4 className="font-jost font-bold text-white">
        {market.name.replace("-", "/")}
      </h4>
      <Button
        variant="secondary"
        className={"flex items-center !px-3 !py-1 !text-[10px] !leading-[18px]"}
        onClick={() => {
          onDepositWithdrawClick(market);
        }}
      >
        Deposit / Withdraw
      </Button>
    </div>
  );
};

type AccountDetailsContentProps = {
  onClose: () => void;
  onDepositWithdrawClick: (selected: ApiMarket) => void;
  onRegisterAccountClick: () => void;
};

export const AccountDetailsContent: React.FC<AccountDetailsContentProps> = ({
  onClose,
  onDepositWithdrawClick,
  onRegisterAccountClick,
}) => {
  const { account, disconnect } = useWallet();
  const { data: registeredMarkets } = useQuery(
    ["userMarketAccounts", account?.address],
    () => {
      // TODO pull registered markets from SDK (ECO-355)
      return MOCK_MARKETS;
    },
  );
  return (
    <div className="w-full px-12 pb-10 pt-8">
      <h2 className="font-jost text-3xl font-bold text-white">
        Account Details
      </h2>
      <p className="mt-4 font-roboto-mono text-sm text-white">
        TODO: everything else here
      </p>
      <div className="mt-8 w-full border border-neutral-600 px-6 py-4">
        <div className="flex">
          <div className="w-[200px] border border-neutral-600 px-3 py-1.5">
            <p className="truncate font-roboto-mono uppercase text-white">
              {account?.address}
            </p>
          </div>
          {/* TODO address copy indicator (ECO-356) */}
          <button
            className="ml-2"
            onClick={() => {
              if (account?.address != null) {
                navigator.clipboard.writeText(account.address);
              }
            }}
          >
            <Square2StackIcon className="h-7 w-7 text-neutral-600" />
          </button>
        </div>
        <div className="mt-4 text-left">
          <Button
            variant="secondary"
            className="flex align-middle text-[15px]/6"
            onClick={() => {
              disconnect();
              onClose();
            }}
          >
            Disconnect
            <ArrowRightOnRectangleIcon className="my-auto ml-2 h-6 w-6 text-neutral-600" />
          </Button>
        </div>
      </div>
      <h3 className="mt-8 font-jost text-xl font-bold text-white">
        Market Accounts
      </h3>
      <div>
        {registeredMarkets != null ? (
          registeredMarkets.map((market) => (
            <MarketCard
              market={market}
              key={market.market_id}
              onDepositWithdrawClick={onDepositWithdrawClick}
            />
          ))
        ) : (
          <p className="font-roboto-mono text-white">Loading...</p>
        )}
      </div>
      <Button
        variant="secondary"
        className="flex align-middle text-[15px]/6"
        onClick={onRegisterAccountClick}
      >
        Register Account
        <ArrowRightOnRectangleIcon className="my-auto ml-2 h-6 w-6 text-neutral-600" />
      </Button>
    </div>
  );
};
