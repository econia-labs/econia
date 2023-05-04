import { css } from "@emotion/react";
import type BigNumber from "bignumber.js";
import React from "react";

import { CoinSymbol } from "./CoinSymbol";

export const CoinAmount: React.FC<{
  className?: string;
  amount: BigNumber | null | undefined;
  symbol?: string | null;
}> = ({ className, amount, symbol }) => {
  return (
    <div>
      <div
        className={className}
        css={css`
          display: inline-block;
        `}
      >
        {amount?.toNumber() ?? "-"}
      </div>
      {symbol && (
        <>
          {" "}
          <CoinSymbol
            css={css`
              display: inline-block;
            `}
            symbol={symbol}
          />
        </>
      )}
    </div>
  );
};
