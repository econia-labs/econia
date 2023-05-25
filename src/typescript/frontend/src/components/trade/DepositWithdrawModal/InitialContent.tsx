import { ChevronDownIcon } from "@heroicons/react/20/solid";

import { Button } from "@/components/Button";
import { type ApiMarket } from "@/types/api";

export const InitialContent: React.FC<{
  selectedMarket?: ApiMarket;
  selectMarket: () => void;
  depositWithdraw: () => void;
}> = ({ selectedMarket, selectMarket, depositWithdraw }) => {
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

      {/* TODO */}
      {/* <Button variant="primary">Create Account</Button> */}
      <Button variant="primary" onClick={depositWithdraw}>
        Deposit / Withdraw
      </Button>
    </div>
  );
};
