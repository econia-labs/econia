import { type StructTag } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";

import { ECONIA_ADDR } from "../constants";
import { type App } from "../sdk/src/econia";
import { RecognizedMarketInfo, TradingPair } from "../sdk/src/econia/registry";
import { Node } from "../sdk/src/econia/tablist";
import { useAptos } from "./useAptos";
import { useEconiaSDK } from "./useEconiaSDK";
import { type RegisteredMarket } from "./useRegisteredMarkets";

/** Example object
 * {
    "next": {
        "vec": []
    },
    "previous": {
        "vec": [
            {
                "base_name_generic": "",
                "base_type": {
                    "account_address": "0x1",
                    "module_name": "0x6170746f735f636f696e",
                    "struct_name": "0x4170746f73436f696e"
                },
                "quote_type": {
                    "account_address": "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
                    "module_name": "0x746573745f75736463",
                    "struct_name": "0x54657374555344436f696e"
                }
            }
        ]
    },
    "value": {
        "lot_size": "1000",
        "market_id": "7",
        "min_size": "1",
        "tick_size": "10",
        "underwriter_id": "0"
    }
}
 */

export const getIsRecognizedMarket = async (
  market: {
    marketId: number;
    baseNameGeneric: string;
    baseType: StructTag;
    quoteType: StructTag;
  },
  aptosClient: any,
  econia: App
) => {
  try {
    const recognizedMarkets = await econia.registry.loadRecognizedMarkets(
      ECONIA_ADDR,
      false
    );
    const { value } = await aptosClient.getTableItem(
      recognizedMarkets.map.table.inner.handle.toString(),
      {
        key: {
          base_type: {
            account_address: market.baseType.address.toString(),
            module_name: strToHex(market.baseType.module),
            struct_name: strToHex(market.baseType.name),
          },
          base_name_generic: market.baseNameGeneric,
          quote_type: {
            account_address: market.quoteType.address.toString(),
            module_name: strToHex(market.quoteType.module),
            struct_name: strToHex(market.quoteType.name),
          },
        },
        key_type: TradingPair.getTag().getFullname(),
        value_type: Node.makeTag([
          TradingPair.getTag(),
          RecognizedMarketInfo.getTag(),
        ]).getFullname(),
      }
    );
    return parseInt(value.market_id) === market.marketId;
  } catch (e) {
    return false;
  }
};

export const useIsRecognizedMarket = (market: RegisteredMarket) => {
  const { aptosClient } = useAptos();
  const { econia } = useEconiaSDK();

  return useQuery<boolean>(
    ["useIsRecognizedMarket", market.marketId],
    async () => {
      return await getIsRecognizedMarket(market, aptosClient, econia);
    }
  );
};

const strToHex = (str: string) => {
  let hex = "0x";
  for (let i = 0; i < str.length; i++) {
    hex += str.charCodeAt(i).toString(16);
  }
  return hex;
};
