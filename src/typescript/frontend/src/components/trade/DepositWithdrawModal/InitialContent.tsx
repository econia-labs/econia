import { Button } from "@/components/Button";
import { NO_CUSTODIAN } from "@/constants";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { ApiMarket } from "@/types/api";
import {
  MarketAccountId,
  MoveTableHandle,
  MoveTypeInfo,
  TabList,
  TypeTag,
} from "@/types/move";
import { entryFunctions } from "@econia-labs/sdk";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useQuery } from "@tanstack/react-query";
import { U64 } from "aptos/src/generated";

type MarketAccounts = {
  map: MoveTableHandle;
  custodians: TabList<U64>;
};

type MarketAccount = {
  base_type: MoveTypeInfo;
  base_name_generic: string;
  quote_type: MoveTypeInfo;
  lot_size: U64;
  tick_size: U64;
  min_size: U64;
  underwriter_id: U64;
  asks: TabList<U64>;
  bids: TabList<U64>;
  asks_stack_top: U64;
  bids_stack_top: U64;
  base_total: U64;
  base_available: U64;
  base_ceiling: U64;
  quote_total: U64;
  quote_available: U64;
  quote_ceiling: U64;
};

export const InitialContent: React.FC<{
  selectedMarket?: ApiMarket;
  selectMarket: () => void;
  depositWithdraw: () => void;
}> = ({ selectedMarket, selectMarket, depositWithdraw }) => {
  const { aptosClient, signAndSubmitTransaction, account } = useAptos();
  const { data: marketAccounts } = useQuery(
    ["useMarketAccounts", account?.address],
    async () => {
      if (!account?.address) return null;
      try {
        const resource = await aptosClient.getAccountResource(
          account.address,
          `${ECONIA_ADDR}::user::MarketAccounts`
        );
        return resource.data as MarketAccounts;
      } catch (e) {
        console.log(e);
        return null;
      }
    }
  );
  const { data: marketAccount } = useQuery(
    ["useMarketAccount", account?.address, selectedMarket?.market_id],
    async () => {
      if (!account?.address || !selectedMarket) return null;
      try {
        const marketAccount = await aptosClient.getTableItem(
          marketAccounts!.map.handle,
          {
            key_type: "u128",
            value_type: `${ECONIA_ADDR}::user::MarketAccount`,
            key: new MarketAccountId(
              selectedMarket.market_id,
              NO_CUSTODIAN
            ).toString(),
          }
        );
        return marketAccount as MarketAccount;
      } catch (e) {
        console.log(e);
        return null;
      }
    },
    {
      enabled: !!marketAccounts,
    }
  );

  return (
    <div className="flex w-full flex-col items-center gap-6">
      <p className="font-jost text-3xl font-bold text-white">Select a Market</p>

      {selectedMarket && (
        <div
          className="flex cursor-pointer items-center gap-2"
          onClick={selectMarket}
        >
          <p className="whitespace-nowrap text-white">{selectedMarket.name}</p>
          <ChevronDownIcon className="h-[24px] w-[24px] fill-white" />
        </div>
      )}
      {!marketAccounts || !marketAccount ? (
        <Button
          onClick={async () => {
            if (!selectedMarket?.base) return;
            const payload = entryFunctions.registerMarketAccount(
              ECONIA_ADDR,
              TypeTag.fromApiCoin(selectedMarket.base).toString(),
              TypeTag.fromApiCoin(selectedMarket.quote).toString(),
              BigInt(selectedMarket.market_id),
              BigInt(NO_CUSTODIAN)
            );
            console.log({ type: "entry_function_payload", ...payload });
            await signAndSubmitTransaction({
              ...payload,
              type: "entry_function_payload",
            });
          }}
          variant="primary"
        >
          Create Account
        </Button>
      ) : (
        <Button variant="primary" onClick={depositWithdraw}>
          Deposit / Withdraw
        </Button>
      )}
    </div>
  );
};
