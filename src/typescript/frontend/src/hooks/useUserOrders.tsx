import { type Address } from "@manahippo/aptos-wallet-adapter";
import { useQuery } from "@tanstack/react-query";

import { API_URL } from "@/env";
import { type ApiOrder } from "@/types/api";

export const useUserOrders = (accountId?: Address | null) => {
  return useQuery<ApiOrder[]>(["useUserOrders", accountId], async () => {
    if (!accountId) return [];
    return [
      {
        market_order_id: 0,
        market_id: 0,
        side: "bid",
        size: 1000,
        price: 1000,
        user_address: "0x1",
        custodian_id: null,
        order_state: "open",
        created_at: "2023-05-01T12:34:56.789012Z",
      },
      {
        market_order_id: 1,
        market_id: 0,
        side: "ask",
        size: 1000,
        price: 2000,
        user_address: "0x1",
        custodian_id: null,
        order_state: "open",
        created_at: "2023-05-01T12:34:56.789012Z",
      },
    ] as ApiOrder[];
    // TODO: Need working API
    // return await fetch(
    //   `${API_URL}/account/${accountId.toString()}/open-orders`
    // ).then((res) => res.json());
  });
};
