import { entryFunctions } from "@econia-labs/sdk";
import { Menu, Tab } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import React, { useMemo, useState } from "react";

import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { NO_CUSTODIAN } from "@/constants";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { useCoinBalance } from "@/hooks/useCoinBalance";
import { useMarketAccountBalance } from "@/hooks/useMarketAccountBalance";
import { type ApiCoin, type ApiMarket } from "@/types/api";
import { toRawCoinAmount } from "@/utils/coin";
import { TypeTag } from "@/utils/TypeTag";
import { useQueryClient } from "@tanstack/react-query";

const SelectCoinInput: React.FC<{
  coins: ApiCoin[];
  startAdornment?: string;
  selectedCoin?: ApiCoin;
  onSelectCoin: (coin: ApiCoin) => void;
}> = ({ coins, startAdornment, selectedCoin, onSelectCoin }) => {
  return (
    <div className="flex h-12 w-full items-center justify-between border border-neutral-600 p-4">
      <p className="font-roboto-mono font-medium uppercase text-white">
        {startAdornment}
      </p>
      <Menu as="div" className="relative inline-block text-left">
        <Menu.Button>
          <div className="flex cursor-pointer items-center gap-2">
            <p className="whitespace-nowrap font-roboto-mono text-white">
              {selectedCoin?.symbol}
            </p>
            <ChevronDownIcon className="h-[24px] w-[24px] fill-white" />
          </div>
        </Menu.Button>
        <Menu.Items className="absolute right-0 top-0 rounded-md bg-neutral-800 ring-1 ring-black ring-opacity-5 focus:outline-none">
          {coins.map((coin) => (
            <Menu.Item
              as="div"
              key={coin.account_address}
              onClick={() => onSelectCoin(coin)}
              className="cursor-pointer items-center border border-white p-4 text-left font-roboto-mono hover:bg-neutral-600"
            >
              <p className="whitespace-nowrap text-white">{coin.symbol}</p>
            </Menu.Item>
          ))}
        </Menu.Items>
      </Menu>
    </div>
  );
};

const DepositWithdrawForm: React.FC<{
  selectedMarket: ApiMarket;
  mode: "deposit" | "withdraw";
  isRegistered: boolean;
}> = ({ selectedMarket, mode, isRegistered }) => {
  const { account, signAndSubmitTransaction } = useAptos();
  const queryClient = useQueryClient();
  const [selectedCoin, setSelectedCoin] = useState<ApiCoin>(
    selectedMarket.base ?? selectedMarket.quote,
  );
  const { data: marketAccountBalance } = useMarketAccountBalance(
    account?.address,
    selectedMarket.market_id,
    selectedCoin,
  );

  // TODO add form validation (ECO-353)
  const [amount, setAmount] = useState<string>("");
  const { data: balance } = useCoinBalance(
    TypeTag.fromApiCoin(selectedCoin),
    account?.address,
  );

  const disabledReason = useMemo(
    () =>
      balance == null || marketAccountBalance == null
        ? "Loading balance..."
        : (mode === "deposit" && parseFloat(amount) > balance) ||
          (mode === "withdraw" && parseFloat(amount) > marketAccountBalance)
        ? "Not enough coins"
        : null,
    [amount, balance, marketAccountBalance, mode],
  );
  return (
    <>
      {!isRegistered && (
        <div className="fixed inset-0 z-40 bg-black bg-opacity-60 backdrop-blur-sm" />
      )}

      <div className="w-full">
        <SelectCoinInput
          coins={[
            ...(selectedMarket?.base ? [selectedMarket.base] : []),
            ...(selectedMarket?.quote ? [selectedMarket.quote] : []),
          ]}
          selectedCoin={selectedCoin}
          onSelectCoin={setSelectedCoin}
          startAdornment={mode === "deposit" ? "DEPOSIT COIN" : "WITHDRAW COIN"}
        />
        <div className="mt-6">
          <Input
            value={amount}
            onChange={setAmount}
            placeholder="0.00"
            startAdornment="AMOUNT"
            type="number"
          />
        </div>
        <div className="mt-10 flex w-full justify-between">
          <p className="font-roboto-mono uppercase text-neutral-500">
            Available in market account
          </p>
          <p className="font-roboto-mono text-neutral-500">
            {marketAccountBalance ?? "--"} {selectedCoin.symbol}
          </p>
        </div>
        <div className="mt-4 flex w-full justify-between">
          <p className="font-roboto-mono uppercase text-neutral-500">
            In Wallet
          </p>
          <p className="font-roboto-mono text-neutral-500">
            {balance ?? "--"} {selectedCoin.symbol}
          </p>
        </div>
        {isRegistered ? (
          <Button
            variant="primary"
            onClick={async () => {
              const payload =
                mode === "deposit"
                  ? entryFunctions.depositFromCoinstore(
                      ECONIA_ADDR,
                      TypeTag.fromApiCoin(selectedCoin).toString(),
                      BigInt(selectedMarket.market_id),
                      BigInt(NO_CUSTODIAN),
                      BigInt(
                        toRawCoinAmount(
                          amount,
                          selectedCoin.decimals,
                        ).toString(),
                      ),
                    )
                  : entryFunctions.withdrawToCoinstore(
                      ECONIA_ADDR,
                      TypeTag.fromApiCoin(selectedCoin).toString(),
                      BigInt(selectedMarket.market_id),
                      BigInt(
                        toRawCoinAmount(
                          amount,
                          selectedCoin.decimals,
                        ).toString(),
                      ),
                    );
              await signAndSubmitTransaction({
                type: "entry_function_payload",
                ...payload,
              });
            }}
            disabledReason={disabledReason}
            className="mt-8 w-full"
          >
            {mode === "deposit" ? "Deposit" : "Withdraw"}
          </Button>
        ) : (
          // TODO: copied over from RegsiterAccountContext, make this a util function?
          <Button
            variant="primary"
            onClick={async () => {
              if (selectedMarket?.base == null) {
                throw new Error("Generic markets not supported");
              }
              const payload = entryFunctions.registerMarketAccount(
                ECONIA_ADDR,
                TypeTag.fromApiCoin(selectedMarket.base).toString(),
                TypeTag.fromApiCoin(selectedMarket.quote).toString(),
                BigInt(selectedMarket.market_id),
                BigInt(NO_CUSTODIAN),
              );
              const res = await signAndSubmitTransaction({
                ...payload,
                type: "entry_function_payload",
              });
              if (res) {
                // refetch user market accounts
                await queryClient.invalidateQueries({
                  queryKey: ["userMarketAccounts"],
                });
              }
            }}
            className="relative z-50 mt-8 w-full"
          >
            Create Account
          </Button>
        )}
      </div>
    </>
  );
};

export const DepositWithdrawContent: React.FC<{
  selectedMarket: ApiMarket;
  isRegistered: boolean;
}> = ({ selectedMarket, isRegistered }) => {
  return (
    <div className="w-full px-12 pb-10 pt-8">
      <h2 className="font-jost text-3xl font-bold text-white">
        {selectedMarket.name.replace("-", " / ")}
      </h2>
      <Tab.Group>
        <Tab.List className="mt-8 w-full">
          <Tab className="w-1/2 border-b border-b-neutral-600 py-6 font-jost font-bold text-neutral-600 outline-none ui-selected:border-b-white ui-selected:text-white">
            Deposit
          </Tab>
          <Tab className="w-1/2 border-b border-b-neutral-600 py-6 font-jost font-bold text-neutral-600 outline-none ui-selected:border-b-white ui-selected:text-white">
            Withdraw
          </Tab>
        </Tab.List>
        <Tab.Panels className="mt-12 w-full">
          <Tab.Panel>
            <DepositWithdrawForm
              selectedMarket={selectedMarket}
              mode="deposit"
              isRegistered={isRegistered}
            />
          </Tab.Panel>
          <Tab.Panel>
            <DepositWithdrawForm
              selectedMarket={selectedMarket}
              mode="withdraw"
              isRegistered={isRegistered}
            />
          </Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};
