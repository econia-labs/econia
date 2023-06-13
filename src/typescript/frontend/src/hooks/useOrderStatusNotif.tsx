import { API_URL } from "@/env";
import { ApiMarket } from "@/types/api";
import { TypeTag } from "@/utils/TypeTag";
import { toDecimalPrice } from "@/utils/econia";
import { averageOrOther } from "@/utils/formatter";
import { useWallet } from "@manahippo/aptos-wallet-adapter";
import { useQuery } from "@tanstack/react-query";
import BigNumber from "bignumber.js";
import { useEffect } from "react";
import { toast } from "react-toastify";

export const useOrderStatusNotif = (selectedMarket: ApiMarket | undefined) => {
  const { account } = useWallet();

  const price = useQuery(
    ["marketStats", selectedMarket],
    async () => {
      if (!selectedMarket) return;
      const priceProm = fetch(
        `${API_URL}/market/${selectedMarket.market_id}/orderbook?depth=1`
      ).then((res) => res.json());
      const priceRes = await priceProm;

      return toDecimalPrice({
        price: new BigNumber(
          averageOrOther(priceRes.asks[0].price, priceRes.bids[0].price) || 0
        ),
        lotSize: BigNumber(selectedMarket.lot_size),
        tickSize: BigNumber(selectedMarket.tick_size),
        baseCoinDecimals: BigNumber(selectedMarket.base?.decimals || 0),
        quoteCoinDecimals: BigNumber(selectedMarket.quote?.decimals || 0),
      }).toNumber();
    },
    {
      keepPreviousData: true,
      refetchOnWindowFocus: false,
      refetchInterval: 10 * 1000,
    }
  );

  useEffect(() => {
    // todo update env here, api url in env has https:// prefix
    const websocket = new WebSocket(`wss://dev.api.econia.exchange/ws`);

    websocket.onopen = () => {
      websocket.send(
        JSON.stringify({
          method: "subscribe",
          channel: "orders",
          params: {
            market_id: selectedMarket?.market_id,
            user_address: account?.address,
          },
        })
      );
    };

    websocket.onmessage = (event) => {
      const data = JSON.parse(event.data).data;

      if (!data) return;

      // transaction hash here?
      if (data.order_state === "evicted") {
        toast.info(
          `Order of ${data.order_size} ${selectedMarket?.base?.name} for ${price.data} ${selectedMarket?.quote.name} is evicted`
        );
      }
      if (data.order_state === "cancelled") {
        toast.info(
          `Order of ${data.order_size} ${selectedMarket?.base?.name} for ${price.data} ${selectedMarket?.quote.name} is cancelled`
        );
      }
    };

    // cleanup
    return () => {
      websocket.close();
    };
  }, [
    account?.address,
    price.data,
    selectedMarket?.base?.name,
    selectedMarket?.market_id,
    selectedMarket?.quote.name,
  ]);
};
