import { Menu, Tab } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import React, { useMemo } from "react";

import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { useCoinBalance } from "@/hooks/useCoinBalance";
import { type ApiCoin, type ApiMarket } from "@/types/api";
import { MoveCoin, U128 } from "@/types/move";
import { useQuery } from "@tanstack/react-query";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { NO_CUSTODIAN } from "@/constants";
import { makeMarketAccountId } from "@/utils/econia";
import { Collateral, TabListNode } from "@/types/econia";
import { TypeTag } from "@/utils/TypeTag";
import { entryFunctions } from "@econia-labs/sdk";
import { fromRawCoinAmount, toRawCoinAmount } from "@/utils/coin";

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
        <Menu.Items
          className={`
          absolute
          right-0
          top-0
          rounded-md
          bg-neutral-800
          shadow-lg
          ring-1
          ring-black
          ring-opacity-5
          focus:outline-none
          `}
        >
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
}> = ({ selectedMarket, mode }) => {
  const { account, aptosClient, signAndSubmitTransaction } = useAptos();
  const [selectedCoin, setSelectedCoin] = React.useState<ApiCoin>(
    selectedMarket.base ?? selectedMarket.quote
  );
  const { data: marketAccountBalance } = useQuery(
    [
      "useMarketAccountBalance",
      account?.address,
      selectedMarket?.market_id,
      selectedCoin,
    ],
    async () => {
      if (!account?.address || !selectedMarket) return null;
      const selectedCoinTypeTag = TypeTag.fromApiCoin(selectedCoin).toString();
      const collateral = await aptosClient
        .getAccountResource(
          account.address,
          `${ECONIA_ADDR}::user::Collateral<${selectedCoinTypeTag}>`
        )
        .then(({ data }) => data as Collateral);
      return await aptosClient
        .getTableItem(collateral.map.table.inner.handle, {
          key_type: "u128",
          value_type: TypeTag.fromTablistNode({
            key: "u128",
            value: `0x1::coin::Coin<${selectedCoinTypeTag}>`,
          }).toString(),
          key: makeMarketAccountId(selectedMarket.market_id, NO_CUSTODIAN),
        })
        .then((node: TabListNode<U128, MoveCoin>) =>
          fromRawCoinAmount(node.value.value, selectedCoin.decimals)
        );
    }
  );

  const [amount, setAmount] = React.useState<string>("");
  const { data: balance } = useCoinBalance(
    TypeTag.fromApiCoin(selectedCoin),
    account?.address
  );

  const disabledReason =
    balance == null || marketAccountBalance == null
      ? "Loading balance..."
      : (mode === "deposit" && parseFloat(amount) > balance) ||
        (mode === "withdraw" && parseFloat(amount) > marketAccountBalance)
      ? "Not enough coins"
      : null;

  return (
    <div className="flex flex-col gap-4">
      <SelectCoinInput
        coins={[
          ...(selectedMarket?.base ? [selectedMarket.base] : []),
          ...(selectedMarket?.quote ? [selectedMarket.quote] : []),
        ]}
        selectedCoin={selectedCoin}
        onSelectCoin={setSelectedCoin}
        startAdornment={mode === "deposit" ? "DEPOSIT COIN" : "WITHDRAW COIN"}
      />
      <Input
        value={amount}
        onChange={setAmount}
        placeholder="0.00"
        startAdornment="AMOUNT"
        type="number"
      />
      <div className="flex w-full justify-between">
        <p className="font-roboto-mono uppercase text-neutral-500">
          Available in market account
        </p>
        <p className="font-roboto-mono text-neutral-500">
          {marketAccountBalance ?? "--"} {selectedCoin.symbol}
        </p>
      </div>
      <div className="flex w-full justify-between">
        <p className="font-roboto-mono uppercase text-neutral-500">In Wallet</p>
        <p className="font-roboto-mono text-neutral-500">
          {balance ?? "--"} {selectedCoin.symbol}
        </p>
      </div>
      <Button
        variant="primary"
        onClick={async () => {
          let payload;
          if (mode === "deposit") {
            payload = entryFunctions.depositFromCoinstore(
              ECONIA_ADDR,
              TypeTag.fromApiCoin(selectedCoin).toString(),
              BigInt(selectedMarket.market_id),
              BigInt(NO_CUSTODIAN),
              BigInt(toRawCoinAmount(amount, selectedCoin.decimals))
            );
          } else {
            payload = entryFunctions.withdrawToCoinstore(
              ECONIA_ADDR,
              TypeTag.fromApiCoin(selectedCoin).toString(),
              BigInt(selectedMarket.market_id),
              BigInt(toRawCoinAmount(amount, selectedCoin.decimals))
            );
          }
          await signAndSubmitTransaction({
            type: "entry_function_payload",
            ...payload,
          });
        }}
        disabledReason={disabledReason}
      >
        {mode === "deposit" ? "Deposit" : "Withdraw"}
      </Button>
    </div>
  );
};

export const DepositWithdrawContent: React.FC<{
  selectedMarket: ApiMarket;
}> = ({ selectedMarket }) => {
  return (
    <div className="mt-12 flex w-full flex-col items-center gap-6">
      <Tab.Group>
        <Tab.List className="w-full">
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Deposit
          </Tab>
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Withdraw
          </Tab>
        </Tab.List>
        <Tab.Panels className="w-full">
          <Tab.Panel>
            <DepositWithdrawForm
              selectedMarket={selectedMarket}
              mode="deposit"
            />
          </Tab.Panel>
          <Tab.Panel>
            <DepositWithdrawForm
              selectedMarket={selectedMarket}
              mode="withdraw"
            />
          </Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};
