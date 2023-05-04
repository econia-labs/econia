import { AtomicTypeTag } from "@manahippo/move-to-ts";
import { useQuery } from "@tanstack/react-query";
import { HexString } from "aptos";

import { ORDER_BOOKS_ADDR } from "../constants";
import { OrderBook } from "../sdk/src/econia/market";
import { Node } from "../sdk/src/econia/tablist";
import { useAptos } from "./useAptos";
import { useEconiaSDK } from "./useEconiaSDK";

type EventHandle = {
  counter: number;
  guid: {
    id: {
      addr: HexString;
      creationNum: number;
    };
  };
};

const fromRawEventHandle = (eventHandle: {
  counter: string;
  guid: {
    id: {
      addr: string;
      creation_num: string;
    };
  };
}): EventHandle => ({
  counter: parseInt(eventHandle.counter),
  guid: {
    id: {
      addr: new HexString(eventHandle.guid.id.addr),
      creationNum: parseInt(eventHandle.guid.id.creation_num),
    },
  },
});

export const useOrderBooks = () => {
  const { econia } = useEconiaSDK();
  const { aptosClient } = useAptos();

  return useQuery<
    {
      makerEvents: EventHandle;
      takerEvents: EventHandle;
    }[]
  >(["useOrderBooks"], async () => {
    const orderBooks = await econia.market.loadOrderBooks(
      ORDER_BOOKS_ADDR,
      false
    );
    const tableLength = orderBooks.map.table.length.toJsNumber();
    const res = [];
    for (let i = 1; i <= tableLength; i++) {
      const orderBook = await aptosClient
        .getTableItem(orderBooks.map.table.inner.handle.toString(), {
          key_type: "u64",
          value_type: Node.makeTag([
            AtomicTypeTag.U64,
            OrderBook.getTag(),
          ]).getFullname(),
          key: i.toString(),
        })
        .then(({ value }) => value);
      // TODO: Add and transform more fields
      res.push({
        makerEvents: fromRawEventHandle(orderBook.maker_events),
        takerEvents: fromRawEventHandle(orderBook.taker_events),
      });
    }
    return res;
  });
};
