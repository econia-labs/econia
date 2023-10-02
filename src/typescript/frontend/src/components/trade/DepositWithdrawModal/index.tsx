import { useQuery } from "@tanstack/react-query";

import { API_URL } from "@/env";
import { type ApiStats } from "@/types/api";
enum Step {
  Initial,
  SelectMarket,
  DepositWithdraw,
}

export const useAllMarketStats = () => {
  return useQuery<ApiStats[]>(["allMarketStats"], async () => {
    return fetch(new URL("stats?resolution=1d", API_URL).href).then((res) => {
      return res.json();
    });
  });
};
