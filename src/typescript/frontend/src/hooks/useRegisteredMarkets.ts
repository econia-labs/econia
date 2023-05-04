import { StructTag } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";
import { HexString } from "aptos";
import BigNumber from "bignumber.js";

import { Registry } from "../sdk/src/econia/registry";
import { moduleAddress } from "../sdk/src/econia/registry";
import { hexToUtf8 } from "../utils/string";
import { useAptos } from "./useAptos";
import { useEconiaSDK } from "./useEconiaSDK";
import { getIsRecognizedMarket } from "./useIsRecognizedMarket";

export type RegisteredMarket = {
  baseNameGeneric: string;
  baseType: StructTag;
  lotSize: BigNumber;
  marketId: number;
  minSize: BigNumber;
  quoteType: StructTag;
  tickSize: BigNumber;
  underwriterId: number;
  isRecognized: boolean;
};

// TODO: Probably should use useOrderBooks
export const useRegisteredMarkets = () => {
  const { aptosClient } = useAptos();
  const { econia } = useEconiaSDK();

  return useQuery<RegisteredMarket[]>(["useRegisteredMarkets"], async () => {
    const events = await aptosClient.getEventsByEventHandle(
      moduleAddress,
      Registry.getTag().getFullname(),
      "market_registration_events"
    );
    const markets = [];
    for (const { data } of events) {
      const marketId = parseInt(data.market_id);
      const baseNameGeneric = data.base_name_generic;
      const baseType = new StructTag(
        new HexString(data.base_type.account_address),
        hexToUtf8(data.base_type.module_name),
        hexToUtf8(data.base_type.struct_name),
        []
      );
      const quoteType = new StructTag(
        new HexString(data.quote_type.account_address),
        hexToUtf8(data.quote_type.module_name),
        hexToUtf8(data.quote_type.struct_name),
        []
      );
      markets.push({
        baseNameGeneric,
        baseType,
        lotSize: new BigNumber(data.lot_size),
        marketId,
        minSize: new BigNumber(data.min_size),
        quoteType,
        tickSize: new BigNumber(data.tick_size),
        underwriterId: parseInt(data.underwriter_id),
        isRecognized: await getIsRecognizedMarket(
          { marketId, baseNameGeneric, baseType, quoteType },
          aptosClient,
          econia
        ),
      });
    }
    return markets.reverse();
  });
};
