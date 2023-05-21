import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { useCoinBalance } from "@/hooks/useCoinBalance";
import { ApiCoin, ApiMarket } from "@/types/api";
import { TypeTag } from "@/types/move";
import { Menu, Tab } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useWallet } from "@manahippo/aptos-wallet-adapter";
import React from "react";

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
  const [selectedCoin, setSelectedCoin] = React.useState<ApiCoin>(
    selectedMarket.base ?? selectedMarket.quote
  );
  const [amount, setAmount] = React.useState<string>("");
  const { account } = useWallet();
  const balance = useCoinBalance(
    TypeTag.fromApiCoin(selectedCoin),
    account?.address
  );
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
        <p className="font-roboto-mono uppercase text-neutral-500">
          {balance.data ?? "--"} {selectedCoin.symbol}
        </p>
      </div>
      <div className="flex w-full justify-between">
        <p className="font-roboto-mono uppercase text-neutral-500">In Wallet</p>
        <p className="font-roboto-mono uppercase text-neutral-500">
          {/* TODO: Get wallet balance */}
          {balance.data ?? "--"} {selectedCoin.symbol}
        </p>
      </div>
      <Button variant="primary">
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
