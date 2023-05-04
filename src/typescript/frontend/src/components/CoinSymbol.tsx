import React from "react";

export const CoinSymbol: React.FC<{
  className?: string;
  symbol: string | null | undefined;
}> = ({ className, symbol }) => {
  return <div className={className}>{symbol ? symbol : "-"}</div>;
};
