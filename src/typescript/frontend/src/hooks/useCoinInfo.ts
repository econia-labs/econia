import { type StructTag } from "@manahippo/move-to-ts";

import { useCoinInfos } from "./useCoinInfos";

export const useCoinInfo = (coinTypeTag?: StructTag) => {
  const query = useCoinInfos(coinTypeTag ? [coinTypeTag] : []);
  return {
    ...query,
    data: query.data?.[0] ?? null,
  };
};
