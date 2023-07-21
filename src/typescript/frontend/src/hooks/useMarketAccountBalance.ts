import { useQuery } from "@tanstack/react-query";
import { type MaybeHexString } from "aptos";
import { type U128 } from "aptos/src/generated";

import { NO_CUSTODIAN } from "@/constants";
import { useAptos } from "@/contexts/AptosContext";
import { ECONIA_ADDR } from "@/env";
import { type ApiCoin } from "@/types/api";
import { type Collateral, type TabListNode } from "@/types/econia";
import { type MoveCoin } from "@/types/move";
import { fromRawCoinAmount } from "@/utils/coin";
import { makeMarketAccountId } from "@/utils/econia";
import { TypeTag } from "@/utils/TypeTag";

export const useMarketAccountBalance = (
  addr: MaybeHexString | undefined | null,
  marketId: number | undefined | null,
  coin: ApiCoin | undefined | null,
) => {
  const { aptosClient } = useAptos();
  return useQuery(
    ["useMarketAccountBalance", addr, marketId, coin],
    async () => {
      if (addr == null || marketId == null || coin == null) return null;
      const selectedCoinTypeTag = TypeTag.fromApiCoin(coin).toString();
      const collateral = await aptosClient
        .getAccountResource(
          addr,
          `${ECONIA_ADDR}::user::Collateral<${selectedCoinTypeTag}>`,
        )
        .then(({ data }) => data as Collateral);
      return await aptosClient
        .getTableItem(collateral.map.table.inner.handle, {
          key_type: "u128",
          value_type: TypeTag.fromTablistNode({
            key: "u128",
            value: `0x1::coin::Coin<${selectedCoinTypeTag}>`,
          }).toString(),
          key: makeMarketAccountId(marketId, NO_CUSTODIAN),
        })
        .then((node: TabListNode<U128, MoveCoin>) =>
          fromRawCoinAmount(node.value.value, coin.decimals),
        );
    },
  );
};
