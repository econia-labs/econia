import { entryFunctions, type order } from "@econia-labs/sdk";
import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { Input } from "@/components/Input";
import { type ApiMarket } from "@/types/api";
import { type Side } from "@/types/global";

import { OrderEntryInfo } from "./OrderEntryInfo";
import { useMarketAccountBalance } from "@/hooks/useMarketAccountBalance";
import { useAptos } from "@/contexts/AptosContext";
import { useForm } from "react-hook-form";
import { ECONIA_ADDR } from "@/env";
import { TypeTag } from "@/utils/TypeTag";
import { fromDecimalSize, fromDecimalPrice } from "@/utils/econia";
import { OrderEntryInputWrapper } from "./OrderEntryInputWrapper";

type MarketFormValues = {
  size: string;
};

export const MarketOrderEntry: React.FC<{
  marketData: ApiMarket;
  side: Side;
}> = ({ marketData, side }) => {
  const { signAndSubmitTransaction, account } = useAptos();
  const {
    handleSubmit,
    register,
    setValue,
    formState: { errors },
  } = useForm<MarketFormValues>();
  const baseBalance = useMarketAccountBalance(
    account?.address,
    marketData.market_id,
    marketData.base
  );
  const quoteBalance = useMarketAccountBalance(
    account?.address,
    marketData.market_id,
    marketData.quote
  );

  const onSubmit = async (values: MarketFormValues) => {
    const orderSideMap: Record<Side, order.Side> = {
      buy: "bid",
      sell: "ask",
    };
    const orderSide = orderSideMap[side];

    if (marketData.base == null) {
      // TODO: handle generic markets
    } else {
      const payload = entryFunctions.placeMarketOrderUserEntry(
        ECONIA_ADDR,
        TypeTag.fromApiCoin(marketData.base).toString(),
        TypeTag.fromApiCoin(marketData.quote).toString(),
        BigInt(marketData.market_id), // market id
        "0x1", // TODO get integrator ID
        orderSide,
        BigInt(
          fromDecimalSize({
            size: values.size,
            lotSize: marketData.lot_size,
            baseCoinDecimals: marketData.base.decimals,
          }).toString()
        ),
        "abort" // TODO don't hardcode this either
      );

      await signAndSubmitTransaction({
        type: "entry_function_payload",
        ...payload,
      });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="mx-4 flex flex-col gap-4">
        <OrderEntryInputWrapper
          startAdornment="Amount"
          endAdornment={marketData.base?.symbol}
        >
          <input
            type="number"
            step="any"
            placeholder="0.00"
            {...register("size", {
              required: "required",
              min: 0,
            })}
            className="z-30 w-full bg-transparent pb-3 pl-14 pr-14 pt-3 text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
        <div className="relative">
          <p className="absolute text-xs uppercase text-red">
            {errors.size != null && errors.size.message}
          </p>
        </div>
      </div>
      <hr className="my-4 border-neutral-600" />
      <div className="mx-4 mb-4 flex flex-col gap-4">
        <OrderEntryInfo label="EST. FEE" value="--" />
        <ConnectedButton className="w-full">
          <Button
            variant={side === "buy" ? "green" : "red"}
            className={`w-full`}
          >
            {side === "buy" ? "Buy" : "Sell"} {marketData.base?.symbol}
          </Button>
        </ConnectedButton>
        <OrderEntryInfo
          label={`${marketData.base?.symbol} AVAIABLE`}
          value={`${baseBalance.data ?? "--"} ${marketData.base?.symbol}`}
          className="cursor-pointer"
          onClick={() => {
            setValue(
              "size",
              baseBalance.data ? baseBalance.data.toString() : ""
            );
          }}
        />
        <OrderEntryInfo
          label={`${marketData.quote?.symbol} AVAIABLE`}
          value={`${quoteBalance.data ?? "--"} ${marketData.quote?.symbol}`}
        />
      </div>
    </form>
  );
};
