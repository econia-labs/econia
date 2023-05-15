import { API_URL } from "@/env";
import { ApiOrder } from "@/types/api";
import { Address } from "@manahippo/aptos-wallet-adapter";
import { useQuery } from "@tanstack/react-query";

export const useUserOrderHistory = (accountId?: Address | null) => {
  return useQuery<ApiOrder[]>(["useUserOrderHistory", accountId], async () => {
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
        order_state: "filled",
        created_at: "2023-04-30T12:34:56.789012Z",
      },
    ] as ApiOrder[];
    // TODO: Need working API
    // return await fetch(
    //   `${API_URL}/account/${accountId.toString()}/order-history`
    // ).then((res) => res.json());
  });
};
