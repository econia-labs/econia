import { entryFunctions, type order } from "@econia-labs/sdk";
import { useEffect } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { useAptos } from "@/contexts/AptosContext";
import { useOrderEntry } from "@/contexts/OrderEntryContext";
import { ECONIA_ADDR } from "@/env";
import { useMarketAccountBalance } from "@/hooks/useMarketAccountBalance";
import { type ApiMarket } from "@/types/api";
import { type Side } from "@/types/global";
import { fromDecimalPrice, fromDecimalSize } from "@/utils/econia";
import { TypeTag } from "@/utils/TypeTag";

import { OrderEntryInfo } from "./OrderEntryInfo";
import { OrderEntryInputWrapper } from "./OrderEntryInputWrapper";
import { toast } from "react-toastify";
import { toRawCoinAmount } from "@/utils/coin";

type LimitFormValues = {
  price: string;
  size: string;
  totalSize: string;
};

export const LimitOrderEntry: React.FC<{
  marketData: ApiMarket;
  side: Side;
}> = ({ marketData, side }) => {
  const { price } = useOrderEntry();
  const { signAndSubmitTransaction, account } = useAptos();
  const {
    handleSubmit,
    register,
    formState: { errors },
    getValues,
    setValue,
  } = useForm<LimitFormValues>();

  useEffect(() => {
    setValue("price", price);
  }, [price, setValue]);

  const baseBalance = useMarketAccountBalance(
    account?.address,
    marketData.market_id,
    marketData.base,
  );
  const quoteBalance = useMarketAccountBalance(
    account?.address,
    marketData.market_id,
    marketData.quote,
  );

  const onSubmit = async (values: LimitFormValues) => {
    const orderSideMap: Record<Side, order.Side> = {
      buy: "bid",
      sell: "ask",
    };
    const orderSide = orderSideMap[side];

    // validation
    const rawValueSize = BigInt(
      toRawCoinAmount(values.size ?? 0, marketData?.base?.decimals ?? 0),
    );
    const rawBaseBalance = BigInt(
      toRawCoinAmount(
        baseBalance.data ?? 0, // assume if null, user has 0
        marketData?.base?.decimals ?? 0, // is this fine?
      ),
    );
    const rawQuoteBalance = BigInt(
      toRawCoinAmount(
        quoteBalance.data ?? 0, // assume if null, user has 0
        marketData?.quote?.decimals ?? 0, // is this fine?
      ),
    );
    const rawValuePrice = BigInt(
      toRawCoinAmount(values.price ?? 0, marketData?.quote?.decimals ?? 0),
    );

    // validate tick size
    if (rawValuePrice % BigInt(marketData.tick_size) != BigInt(0)) {
      toast.info("Invalid tick size");
      return;
    }

    // validate Lot size
    if (rawValueSize % BigInt(marketData.lot_size) != BigInt(0)) {
      toast.info("Invalid lot size");
      return;
    }
    // validate min size
    if (rawValueSize < BigInt(marketData.min_size)) {
      toast.info("Invalid min size");
      return;
    }

    // limit buy -- make sure user has enough quote balance
    if (orderSide === "bid") {
      const isValid =
        rawQuoteBalance >= BigInt(values.size) * BigInt(rawValuePrice); // how to get price? esp if market order
      if (!isValid) {
        toast.info("Insufficient quote balance");
        return;
      }
    }

    // limit sell -- make sure user has enough base balance
    if (orderSide === "ask") {
      const isValid = rawBaseBalance >= BigInt(rawValueSize); // is gte fine?
      if (!isValid) {
        toast.info("Insufficient base balance");
        return;
      }
    }

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
          }).toString(),
        ),
        BigInt(
          fromDecimalPrice({
            price: values.price,
            lotSize: marketData.lot_size,
            tickSize: marketData.tick_size,
            baseCoinDecimals: marketData.base.decimals,
            quoteCoinDecimals: marketData.quote.decimals,
          }).toString(),
        ),
        "immediateOrCancel", // TODO don't hardcode
        "abort", // don't hardcode this either
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
          startAdornment="Price"
          endAdornment={marketData.quote.symbol}
          labelFor="price"
          className="mb-4"
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
            className="z-30 w-full bg-transparent pb-3 pl-14 pr-14 pt-3 text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
        <div className="relative">
          <p className="absolute text-xs uppercase text-red">
            {errors.price != null && errors.price.message}
          </p>
        </div>
      </div>
      <hr className="border-neutral-600" />
      <div className="mx-4 mt-4">
        <OrderEntryInputWrapper
          startAdornment="Amount"
          endAdornment={marketData.base?.symbol}
          labelFor="size"
          className="mb-4"
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
            className="z-30 w-full bg-transparent pb-3 pl-14 pr-14 pt-3 text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
        <div className="relative">
          <p className="absolute text-xs uppercase text-red">
            {errors.size != null && errors.size.message}
          </p>
        </div>
        <OrderEntryInputWrapper
          startAdornment="Total"
          endAdornment={marketData.quote?.symbol}
        >
          <input
            type="number"
            step="any"
            placeholder="0.00"
            {...register("totalSize", { disabled: true })}
            className="z-30 w-full bg-transparent pb-3 pl-14 pr-14 pt-3 text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
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
            className="w-full text-[16px]/6"
          >
            {side === "buy" ? "Buy" : "Sell"} {marketData.base?.symbol}
          </Button>
        </ConnectedButton>
        <OrderEntryInfo
          label={`${marketData.base?.symbol} AVAILABLE`}
          value={`${baseBalance.data ?? "--"} ${marketData.base?.symbol}`}
          className="cursor-pointer"
          onClick={() => {
            setValue(
              "size",
              baseBalance.data ? baseBalance.data.toString() : "",
            );
          }}
        />
        <OrderEntryInfo
          label={`${marketData.quote?.symbol} AVAILABLE`}
          value={`${quoteBalance.data ?? "--"} ${marketData.quote?.symbol}`}
        />
      </div>
    </form>
  );
};
