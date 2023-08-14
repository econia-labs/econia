import { useQuery } from "@tanstack/react-query";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from "@tanstack/react-table";
import React from "react";

import { type ApiMarket, type ApiOrder } from "@/types/api";
import Skeleton from "react-loading-skeleton";

const columnHelper = createColumnHelper<ApiOrder>();

export const TradeHistoryTable: React.FC<{
  className?: string;
  marketData: ApiMarket;
}> = ({ className, marketData }) => {
  const { data, isLoading } = useQuery<ApiOrder[]>(
    ["useTradeHistory", marketData.market_id],
    async () => {
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
      // TODO: Endpoint needs to return data
      // return await fetch(
      //   `${API_URL}/markets/${
      //     marketData.market_id
      //   }/fills?from=${0}&to=${Math.floor(Date.now() / 1000)}`
      // ).then((res) => res.json());
    },
  );
  const table = useReactTable({
    columns: [
      columnHelper.accessor("price", {
        cell: (info) => info.getValue(),
        header: () => "PRICE",
      }),
      columnHelper.accessor("size", {
        cell: (info) => info.getValue(),
        header: () => "AMOUNT",
      }),
      columnHelper.accessor("created_at", {
        cell: (info) =>
          new Date(info.getValue()).toLocaleString("en-US", {
            hour: "numeric",
            minute: "numeric",
            second: "numeric",
            hour12: true,
          }),
        header: () => "TIME",
      }),
    ],
    data: data || [],
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <table
      className={"w-full table-fixed" + (className ? ` ${className}` : "")}
    >
      <thead>
        {table.getHeaderGroups().map((headerGroup) => (
          <tr
            className="text-left font-roboto-mono text-sm text-neutral-500 [&>th]:font-light"
            key={headerGroup.id}
          >
            {headerGroup.headers.map((header, i) => (
              <th
                className={`text-xs ${
                  i === 0
                    ? "pl-4 text-left"
                    : i === 1
                    ? "text-left"
                    : "pr-4 text-right"
                } w-full`}
                key={header.id}
              >
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
        {isLoading || !data ? (
          <>
            {/* temporarily removing skeletong to help UX and reduce glitchyness. see: ECO-230 */}
            {/* <tr>
              {table.getAllColumns().map((column, i) => (
                <td
                  className={`text-xs ${
                    i === 0
                      ? "pl-4 text-left"
                      : i === 1
                      ? "text-left"
                      : "pr-4 text-right"
                  }`}
                  key={column.id}
                >
                  <div className={"px-1"}>
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
              className="text-left font-roboto-mono text-sm uppercase text-white [&>th]:font-light"
              key={row.id}
            >
              {row.getVisibleCells().map((cell, i) => (
                <td
                  className={`text-xs ${
                    i === 0
                      ? "pl-4 text-left"
                      : i === 1
                      ? "text-left"
                      : "pr-4 text-right"
                  }`}
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
  );
};
