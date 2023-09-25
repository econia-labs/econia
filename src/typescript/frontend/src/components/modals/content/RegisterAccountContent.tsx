import { entryFunctions } from "@econia-labs/sdk";
import { ChevronDownIcon } from "@heroicons/react/20/solid";

import { Button } from "@/components/Button";
import { NO_CUSTODIAN } from "@/constants";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { type ApiMarket } from "@/types/api";
import { TypeTag } from "@/utils/TypeTag";
import { toast } from "react-toastify";

type RegisterAccountContentProps = {
  selectedMarket?: ApiMarket;
  selectMarket: () => void;
  onAccountCreated?: (status: boolean) => void;
};

export const RegisterAccountContent: React.FC<RegisterAccountContentProps> = ({
  selectedMarket,
  selectMarket,
  onAccountCreated,
}) => {
  const { signAndSubmitTransaction } = useAptos();
  return (
    <div className="flex w-full flex-col items-center gap-6 py-8">
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
      <Button
        onClick={async () => {
          if (selectedMarket?.base == null) {
            toast.error("Generic markets not supported");
            console.log("Generic markets not supported");
            return;
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

          if (onAccountCreated) {
            onAccountCreated(res);
          }
        }}
        variant="primary"
      >
        Create Account
      </Button>
    </div>
  );
};
