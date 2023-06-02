import { entryFunctions, type order } from "@econia-labs/sdk";
import { useForm } from "react-hook-form";

import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { type ApiMarket } from "@/types/api";
import { type Side } from "@/types/global";

import { OrderEntryInfo } from "./OrderEntryInfo";
import { OrderEntryInputWrapper } from "./OrderEntryInputWrapper";
import { TypeTag } from "@/utils/TypeTag";
import { useMarketAccountBalance } from "@/hooks/useMarketAccountBalance";
import { fromDecimalPrice, fromDecimalSize } from "@/utils/econia";

type LimitFormValues = {
  price: string;
  size: string;
  totalSize: string;
};

export const LimitOrderEntry: React.FC<{
  marketData: ApiMarket;
  side: Side;
}> = ({ marketData, side }) => {
  const { signAndSubmitTransaction, account } = useAptos();
  const {
    handleSubmit,
    register,
    formState: { errors },
    getValues,
    setValue,
  } = useForm<LimitFormValues>();
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

  const onSubmit = async (values: LimitFormValues) => {
    const orderSideMap: Record<Side, order.Side> = {
      buy: "bid",
      sell: "ask",
    };
    const orderSide = orderSideMap[side];

    if (marketData.base == null) {
      // TODO: handle generic markets
    } else {
      const payload = entryFunctions.placeLimitOrderUserEntry(
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
        BigInt(
          fromDecimalPrice({
            price: values.price,
            lotSize: marketData.lot_size,
            tickSize: marketData.tick_size,
            baseCoinDecimals: marketData.base.decimals,
            quoteCoinDecimals: marketData.quote.decimals,
          }).toString()
        ),
        "immediateOrCancel", // TODO don't hardcode
        "abort" // don't hardcode this either
      );

      await signAndSubmitTransaction({
        type: "entry_function_payload",
        ...payload,
      });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="mx-4">
        <OrderEntryInputWrapper
          startAdornment="LIMIT PRICE"
          endAdornment={marketData.quote.symbol}
        >
          <input
            type="number"
            step="any"
            placeholder="0.00"
            {...register("price", {
              required: "required",
              min: 0,
              // TODO: check that amount * size does not exceed quote currency
              // balance for bids
              onChange: (e) => {
                const size = Number(getValues("size"));
                if (!isNaN(size) && !isNaN(e.target.value)) {
                  const totalSize = (size * e.target.value).toFixed(4);
                  setValue("totalSize", totalSize);
                } else {
                  setValue("totalSize", "");
                }
              },
            })}
            className="h-full w-[100px] flex-1 bg-transparent text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
        <p className="text-red">
          {errors.price != null && errors.price.message}
        </p>
      </div>
      <hr className="my-4 border-neutral-600" />
      <div className="mx-4 flex flex-col gap-4">
        <OrderEntryInputWrapper
          startAdornment="AMOUNT"
          endAdornment={marketData.base?.symbol}
        >
          <input
            type="number"
            step="any"
            placeholder="0.00"
            {...register("size", {
              required: "required",
              min: 0,
              // TODO: check that size does not exceed base currency balance for asks
              onChange: (e) => {
                const price = Number(getValues("price"));
                if (!isNaN(price) && !isNaN(e.target.value)) {
                  const totalSize = (price * e.target.value).toFixed(4);
                  setValue("totalSize", totalSize);
                } else {
                  setValue("totalSize", "");
                }
              },
            })}
            className="h-full w-[100px] flex-1 bg-transparent text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
        <p className="text-red">{errors.size != null && errors.size.message}</p>
        <OrderEntryInputWrapper
          startAdornment="TOTAL"
          endAdornment={marketData.quote?.symbol}
        >
          <input
            type="number"
            step="any"
            placeholder="0.00"
            {...register("totalSize", { disabled: true })}
            className="h-full w-[100px] flex-1 bg-transparent text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
      </div>
      <hr className="my-4 border-neutral-600" />
      <div className="mx-4 mb-4 flex flex-col gap-4">
        <OrderEntryInfo label="EST. FEE" value="--" />
        <ConnectedButton className="w-full">
          <Button
            type="submit"
            variant={side === "buy" ? "green" : "red"}
            className={`w-full`}
          >
            {side === "buy" ? "Buy" : "Sell"} {marketData.base?.symbol}
          </Button>
        </ConnectedButton>
        <OrderEntryInfo
          label={`${marketData.base?.symbol} AVAIABLE`}
          value={`${baseBalance.data ?? "--"} ${marketData.base?.symbol}`}
        />
        <OrderEntryInfo
          label={`${marketData.quote?.symbol} AVAIABLE`}
          value={`${quoteBalance.data ?? "--"} ${marketData.quote?.symbol}`}
        />
      </div>
    </form>
  );
};
