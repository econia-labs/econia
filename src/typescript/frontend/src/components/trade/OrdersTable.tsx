import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useQuery } from "@tanstack/react-query";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from "@tanstack/react-table";
import React from "react";

import { type ApiMarket, type ApiOrder } from "@/types/api";

import { ConnectedButton } from "../ConnectedButton";
import Skeleton from "react-loading-skeleton";

const columnHelper = createColumnHelper<ApiOrder>();

export const OrdersTable: React.FC<{
  className?: string;
  allMarketData: ApiMarket[];
}> = ({ className, allMarketData }) => {
  const { connected, account } = useWallet();
  const { data, isLoading } = useQuery<ApiOrder[]>(
    ["useUserOrders", account?.address],
    async () => {
      if (!account) return [];
      return [
        {
          market_order_id: 0,
          market_id: 1,
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
          market_id: 1,
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
      //   `${API_URL}/account/${account.address.toString()}/open-orders`
      // ).then((res) => res.json());
    },
  );
  const marketById = React.useMemo(() => {
    const map = new Map<number, ApiMarket>();
    for (const market of allMarketData) map.set(market.market_id, market);
    return map;
  }, [allMarketData]);
  const table = useReactTable({
    columns: [
      columnHelper.accessor("created_at", {
        cell: (info) =>
          new Date(info.getValue()).toLocaleString("en-US", {
            month: "numeric",
            day: "2-digit",
            year: "2-digit",
            hour: "numeric",
            minute: "numeric",
            second: "numeric",
            hour12: true,
          }),
        header: "TIME PLACED",
      }),
      columnHelper.display({
        cell: () => "LIMIT",
        header: "TYPE",
      }),
      columnHelper.accessor("side", {
        cell: (info) => info.getValue().toUpperCase(),
        header: "SIDE",
      }),
      columnHelper.accessor("price", {
        cell: (info) =>
          `${info.getValue()} ${
            marketById.get(info.row.original.market_id)?.quote.symbol
          }`,
        header: "PRICE",
      }),
      columnHelper.accessor("size", {
        cell: (info) => {
          const marketId = info.row.original.market_id;
          return `${info.getValue()} ${
            marketById.get(marketId)?.base?.symbol ?? ""
          }`;
        },
        header: "AMOUNT",
      }),
      columnHelper.display({
        cell: (info) => {
          const { price, size, market_id } = info.row.original;
          return `${price * size} ${
            marketById.get(market_id)?.quote?.symbol ?? ""
          }`;
        },
        header: "TOTAL",
      }),
      columnHelper.accessor("order_state", {
        cell: (info) => info.getValue().toUpperCase(),
        header: "STATUS",
      }),
    ],
    data: data || [],
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="h-[200px]">
      <table className={"w-full" + (className ? ` ${className}` : "")}>
        <thead>
          {table.getHeaderGroups().map((headerGroup) => (
            <tr
              className="text-left font-roboto-mono text-sm text-neutral-500 [&>th]:font-light"
              key={headerGroup.id}
            >
              {headerGroup.headers.map((header, i) => (
                <th className={i === 0 ? "pl-4 text-left" : ""} key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext(),
                      )}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          <tr>
            <td colSpan={7} className="py-2">
              <div className="h-[1px] bg-neutral-600"></div>
            </td>
          </tr>
          {!connected ? (
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center">
                  <ConnectedButton />
                </div>
              </td>
            </tr>
          ) : isLoading || !data ? (
            <>
              {/* temporarily removing skeletong to help UX and reduce glitchyness. see: ECO-230 */}
              {/* <tr>
                {table.getAllColumns().map((column, i) => (
                  <td
                    className={`${
                      i === 0
                        ? "pl-4 text-left text-neutral-500"
                        : i === 6
                        ? ""
                        : ""
                    }`}
                    key={column.id}
                  >
                    <div className={"pr-3"}>
                      <Skeleton />
                    </div>
                  </td>
                ))}
              </tr> */}
            </>
          ) : data.length === 0 ? (
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center text-sm font-light uppercase text-neutral-500">
                  No orders to show
                </div>
              </td>
            </tr>
          ) : (
            table.getRowModel().rows.map((row) => (
              <tr
                className="text-left font-roboto-mono text-sm text-white [&>th]:font-light"
                key={row.id}
              >
                {row.getVisibleCells().map((cell, i) => (
                  <td
                    className={
                      i === 0
                        ? "pl-4 text-left text-neutral-500"
                        : i === 6
                        ? `${cell.getValue() === "open" ? "text-green" : ""}`
                        : ""
                    }
                    key={cell.id}
                  >
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};
