import { useWallet } from "@manahippo/aptos-wallet-adapter";
import { useEffect } from "react";
import { toast } from "react-toastify";

export const useOrderStatusNotif = ({ market_id }: { market_id: string }) => {
  const { account } = useWallet();

  useEffect(() => {
    // todo update env here, api url in env has https:// prefix
    const websocket = new WebSocket(`wss://dev.api.econia.exchange/ws`);

    websocket.onopen = () => {
      websocket.send(
        JSON.stringify({
          method: "subscribe",
          channel: "orders",
          params: {
            market_id: market_id,
            user_address: account?.address,
          },
        })
      );
    };

    websocket.onmessage = (event) => {
      const data = JSON.parse(event.data).data;

      if (data.order_state === "evicted") {
        toast.success("Order evicted");
      }
      if (data.order_state === "cancelled") {
        toast.success("Order cancelled");
      }

      console.log("order of x for y is updated", data);
    };

    // cleanup
    return () => {
      websocket.close();
    };
  }, [account?.address, market_id]);
};
