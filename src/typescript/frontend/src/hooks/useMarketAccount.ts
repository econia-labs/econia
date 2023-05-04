import { AtomicTypeTag, u64, u128 } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";
import { type AptosClient, HexString, type MaybeHexString } from "aptos";
import BigNumber from "bignumber.js";

import {
  get_market_order_id_counter_,
  get_market_order_id_price_,
} from "../sdk/src/econia/market";
import { Node } from "../sdk/src/econia/tablist";
import {
  get_market_account_id_,
  MarketAccount,
  NO_CUSTODIAN,
  Order,
} from "../sdk/src/econia/user";
import { useAptos } from "./useAptos";
import { useEconiaSDK } from "./useEconiaSDK";

export const useMarketAccount = (
  marketId: number,
  ownerAddr: MaybeHexString | null | undefined
) => {
  const { aptosClient } = useAptos();
  const { econia } = useEconiaSDK();

  return useQuery(["useMarketAccount", marketId, ownerAddr], async () => {
    if (!ownerAddr) return null;

    try {
      const marketAccounts = await econia.user.loadMarketAccounts(
        HexString.ensure(ownerAddr),
        false
      );
      const marketAccountId = get_market_account_id_(
        u64(marketId),
        NO_CUSTODIAN,
        undefined!
      );
      const marketAccount = await aptosClient.getTableItem(
        marketAccounts.map.handle.toString(),
        {
          key_type: "u128",
          value_type: MarketAccount.getTag().getFullname(),
          key: marketAccountId.toBigInt().toString(),
        }
      );
      const asks = await fetchMarketAccountOrders({
        aptosClient,
        tableLength: parseInt(marketAccount.asks.table.length),
        tableHandle: marketAccount.asks.table.inner.handle.toString(),
      });
      const bids = await fetchMarketAccountOrders({
        aptosClient,
        tableLength: parseInt(marketAccount.bids.table.length),
        tableHandle: marketAccount.bids.table.inner.handle.toString(),
      });
      return {
        asks,
        asksStackTop: parseInt(marketAccount.asks_stack_top),
        baseAvailable: new BigNumber(marketAccount.base_available),
        baseCeiling: new BigNumber(marketAccount.base_ceiling),
        baseNameGeneric: marketAccount.base_name_generic,
        baseTotal: new BigNumber(marketAccount.base_total),
        baseType: marketAccount.base_type,
        bids,
        bidsStackTop: parseInt(marketAccount.bids_stack_top),
        lotSize: new BigNumber(marketAccount.lot_size),
        minSize: new BigNumber(marketAccount.min_size),
        quoteAvailable: new BigNumber(marketAccount.quote_available),
        quoteCeiling: new BigNumber(marketAccount.quote_ceiling),
        quoteTotal: new BigNumber(marketAccount.quote_total),
        quoteType: marketAccount.quote_type,
        tickSize: new BigNumber(marketAccount.tick_size),
        underwriterId: parseInt(marketAccount.underwriter_id),
      };
    } catch (e) {
      console.error(e);
      return null;
    }
  });
};

// TODO: parallelizable
const fetchMarketAccountOrders = async ({
  aptosClient,
  tableLength,
  tableHandle,
}: {
  aptosClient: AptosClient;
  tableLength: number;
  tableHandle: string;
}) => {
  const orders = [];
  for (let i = 1; i <= tableLength; i++) {
    const order = await aptosClient.getTableItem(tableHandle, {
      key_type: "u64",
      value_type: Node.makeTag([
        AtomicTypeTag.U64,
        Order.getTag(),
      ]).getFullname(),
      key: i.toString(),
    });
    const counter = new BigNumber(
      get_market_order_id_counter_(
        u128(order.value.market_order_id),
        undefined!
      ).toJsNumber()
    );
    const price = new BigNumber(
      get_market_order_id_price_(
        u128(order.value.market_order_id),
        undefined!
      ).toJsNumber()
    );
    orders.push({
      marketOrderId: u128(order.value.market_order_id),
      price,
      counter,
      size: new BigNumber(order.value.size),
    });
  }
  return orders;
};
