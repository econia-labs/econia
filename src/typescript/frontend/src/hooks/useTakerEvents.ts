import { useQuery } from "@tanstack/react-query";
import { HexString } from "aptos";
import BigNumber from "bignumber.js";

import { ORDER_BOOKS_ADDR } from "../constants";
import { getTakerEventsCreationNumber } from "../utils/events";
import { useAptos } from "./useAptos";

export const useTakerEvents = (marketId: string | number) => {
  const { aptosClient } = useAptos();
  return useQuery({
    queryKey: ["useTakerEvents", marketId],
    queryFn: async () => {
      try {
        const events = await aptosClient
          .getEventsByCreationNumber(
            ORDER_BOOKS_ADDR,
            getTakerEventsCreationNumber(Number(marketId))
          )
          .then((events) => {
            return events.map((event) => {
              const { sequence_number, data } = event;
              // version does exist, just not in the typing
              const version = (event as any).version;
              return {
                version: parseInt(version),
                sequenceNumber: parseInt(sequence_number),
                custodianId: parseInt(data.custodian_id),
                maker: new HexString(data.maker),
                marketId: parseInt(data.market_id),
                marketOrderId: data.market_order_id.toString(),
                price: new BigNumber(parseInt(data.price)),
                side: data.side as boolean,
                size: new BigNumber(parseInt(data.size)),
              };
            });
          });
        return events;
      } catch (e) {
        // If the vault doesn't exist, return undefined
        console.error(e);
        return null;
      }
    },
  });
};
