import { useWallet } from "@manahippo/aptos-wallet-adapter";
import React from "react";

import { useUserOrders } from "@/hooks/useUserOrders";
import { type ApiMarket } from "@/types/api";

import { ConnectedButton } from "../ConnectedButton";

export const OrdersTable: React.FC<{
  className?: string;
  allMarketData: ApiMarket[];
}> = ({ className, allMarketData }) => {
  const { connected, account } = useWallet();
  const { data, isLoading } = useUserOrders(account?.address);
  const marketById = React.useMemo(() => {
    const map = new Map<number, ApiMarket>();
    for (const market of allMarketData) map.set(market.market_id, market);
    return map;
  }, [allMarketData]);

  return (
    <div className="h-[200px]">
      <table className={"w-full" + (className ? ` ${className}` : "")}>
        <thead>
          <tr className="text-left font-roboto-mono text-sm uppercase text-neutral-500 [&>th]:font-light">
            <th className="pl-4">Time Placed</th>
            <th>Type</th>
            <th>Side</th>
            <th>Price</th>
            <th>Amount</th>
            <th>Total</th>
            <th>Status</th>
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
              const market = marketById.get(order.market_id);
              return (
                <tr
                  key={`${order.market_id}-${order.market_order_id}`}
                  className="text-left font-roboto-mono text-sm uppercase text-white [&>th]:font-light"
                >
                  <td className="pl-4 text-neutral-500">
                    {new Date(order.created_at).toLocaleString("en-US", {
                      month: "numeric",
                      day: "2-digit",
                      year: "2-digit",
                      hour: "numeric",
                      minute: "numeric",
                      second: "numeric",
                      hour12: true,
                    })}
                  </td>
                  <td>LIMIT</td>
                  <td>{order.side.toUpperCase()}</td>
                  <td>
                    {order.price} {market?.quote.symbol}
                  </td>
                  <td>
                    {order.size} {market?.base?.symbol}
                  </td>
                  <td>
                    {order.size * order.price} {market?.quote.symbol}
                  </td>
                  <td
                    className={`${
                      order.order_state === "open"
                        ? "text-green"
                        : "text-neutral-500"
                    }`}
                  >
                    {order.order_state}
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
