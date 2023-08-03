import { entryFunctions, order } from "@econia-labs/sdk";
import { useForm } from "react-hook-form";
import { toast } from "react-toastify";

import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { useMarketAccountBalance } from "@/hooks/useMarketAccountBalance";
import { type ApiMarket } from "@/types/api";
import { type Side } from "@/types/global";
import { toRawCoinAmount } from "@/utils/coin";
import { fromDecimalSize } from "@/utils/econia";
import { TypeTag } from "@/utils/TypeTag";

import { OrderEntryInfo } from "./OrderEntryInfo";
import { OrderEntryInputWrapper } from "./OrderEntryInputWrapper";
import { canBeBigInt } from "@/utils/formatter";

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
    setError,
    formState: { errors },
  } = useForm<MarketFormValues>();
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

  const onSubmit = async (values: MarketFormValues) => {
    const orderSideMap: Record<Side, order.Side> = {
      buy: "bid",
      sell: "ask",
    };
    const orderSide = orderSideMap[side];

    // validation
    const _rawValueSize = toRawCoinAmount(
      values.size ?? 0,
      marketData?.base?.decimals ?? 0,
    );
    const rawValueSize = canBeBigInt(_rawValueSize) // if after conversion is still a decimal, then it's too small anyways
      ? BigInt(_rawValueSize)
      : BigInt(0);

    const rawBaseBalance = BigInt(
      toRawCoinAmount(
        baseBalance.data ?? 0, // assume if null, user has 0
        marketData?.base?.decimals ?? 0, // is this fine?
      ),
    );

    // validate Lot size
    if (rawValueSize % BigInt(marketData.lot_size) != BigInt(0)) {
      setError("size", { message: "INVALID LOT SIZE" });
      return;
    }
    // validate min size
    if (rawValueSize < BigInt(marketData.min_size)) {
      setError("size", { message: "INVALID MIN SIZE" });
      return;
    }

    // market sell -- make sure user has enough base balance
    if (orderSide === "ask") {
      const isValid = rawBaseBalance >= rawValueSize; // is gte fine?
      if (!isValid) {
        setError("size", { message: "INSUFFICIENT BASE BALANCE" });
        return;
      }
    }

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
          }).toString(),
        ),
        "abort", // TODO don't hardcode this either
      );

      await signAndSubmitTransaction({
        type: "entry_function_payload",
        ...payload,
      });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="mx-4 flex flex-col">
        <OrderEntryInputWrapper
          startAdornment="Amount"
          endAdornment={marketData.base?.symbol}
        >
          <input
            type="number"
            step="any"
            placeholder="0.00"
            {...register("size", {
              required: "REQUIRED",
              min: 0,
            })}
            className="z-30 w-full bg-transparent pb-3 pl-14 pr-14 pt-3 text-right font-roboto-mono text-xs font-light text-neutral-400 outline-none"
          />
        </OrderEntryInputWrapper>
        <div className="relative mb-4">
          <p className="absolute text-xs text-red">
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
