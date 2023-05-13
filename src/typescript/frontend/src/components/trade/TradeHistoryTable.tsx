import { useWallet } from "@manahippo/aptos-wallet-adapter";
import React from "react";
import { ConnectedButton } from "../ConnectedButton";
import { ApiMarket } from "@/types/api";
import { useUserOrderHistory } from "@/hooks/useUserOrderHistory";

export const TradeHistoryTable: React.FC<{
  className?: string;
  marketData: ApiMarket;
}> = ({ className, marketData }) => {
  const { connected, account } = useWallet();
  const { data, isLoading } = useUserOrderHistory(account?.address);

  return (
    <div className="h-[200px]">
      <table className={"w-full" + (className ? ` ${className}` : "")}>
        <thead>
          <tr className="text-left font-roboto-mono text-sm uppercase text-neutral-500 [&>th]:font-light">
            <th className="pl-4 text-left">
              Price ({marketData.quote.symbol})
            </th>
            {/* TODO: Handle cases like APT-PERP */}
            <th className="text-center">Amount ({marketData.base?.symbol})</th>
            <th className="pr-4 text-right">Time</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td colSpan={7} className="py-2">
              <div className="h-[1px] bg-neutral-600"></div>
            </td>
          </tr>
          {isLoading || !data ? (
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center text-sm font-light uppercase text-neutral-500">
                  Loading...
                </div>
              </td>
            </tr>
          ) : !connected ? (
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center">
                  <ConnectedButton />
                </div>
              </td>
            </tr>
          ) : data.length === 0 ? (
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center text-sm font-light uppercase text-neutral-500">
                  No orders to show
                </div>
              </td>
            </tr>
          ) : (
            data.map((order) => {
              return (
                <tr
                  key={`${order.market_id}-${order.market_order_id}`}
                  className="text-left font-roboto-mono text-sm uppercase text-white [&>th]:font-light"
                >
                  <td className="pl-4 text-left">{order.price}</td>
                  <td className="text-center">{order.size}</td>
                  <td className="pr-4 text-right text-neutral-500">
                    {new Date(order.created_at).toLocaleString("en-US", {
                      hour: "numeric",
                      minute: "numeric",
                      second: "numeric",
                      hour12: true,
                    })}
                  </td>
                </tr>
              );
            })
          )}
        </tbody>
      </table>
    </div>
  );
};
