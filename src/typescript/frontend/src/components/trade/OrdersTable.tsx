import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { ChevronDownIcon, ChevronUpIcon } from "@heroicons/react/20/solid";
import { useQuery } from "@tanstack/react-query";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  type SortDirection,
  type SortingState,
  useReactTable,
} from "@tanstack/react-table";
import { type ReactNode, useMemo, useState } from "react";
import Skeleton from "react-loading-skeleton";

import { type ApiMarket, type ApiOrder } from "@/types/api";

import bg from "../../../public/bg.png";
import { ConnectedButton } from "../ConnectedButton";

type TableOrder = ApiOrder & { total: number };

const columnHelper = createColumnHelper<TableOrder>();

export const OrdersTable: React.FC<{
  className?: string;
  allMarketData: ApiMarket[];
}> = ({ className, allMarketData }) => {
  const { connected, account } = useWallet();

  const [sorting, setSorting] = useState<SortingState>([]);

  const { data, isLoading } = useQuery<TableOrder[]>(
    ["useUserOrders", account?.address],
    async () => {
      if (!account) return [];
      const apiOrders: ApiOrder[] = [...Array(20).keys()].map((i) => ({
        market_order_id: i,
        market_id: 1,
        side: i % 2 === 0 ? "bid" : "ask",
        size: (i + 1) * 10,
        price: (i + 1) * 100,
        user_address: "0x1",
        custodian_id: null,
        order_state: "open",
        created_at: new Date(
          new Date("2023-05-01T12:34:56.789012Z").getTime() +
            (i + 1) * 86400000,
        ).toISOString(),
      }));
      const orders: TableOrder[] = apiOrders.map((order) => ({
        ...order,
        total: order.price * order.size,
      }));
      return orders;
      // TODO: Need working API
      // return await fetch(
      //   `${API_URL}/account/${account.address.toString()}/open-orders`
      // ).then((res) => res.json());
    },
  );

  const marketById = useMemo(() => {
    const map = new Map<number, ApiMarket>();
    for (const market of allMarketData) {
      map.set(market.market_id, market);
    }
    return map;
  }, [allMarketData]);

  const sortLabel = useMemo(() => {
    const map = new Map<SortDirection | false, ReactNode>();
    map.set(false, null);
    map.set(
      "asc",
      <ChevronUpIcon className="absolute top-0 ml-0.5 inline-block h-4 w-4 translate-y-1/2" />,
    );
    map.set(
      "desc",
      <ChevronDownIcon className="absolute top-0 ml-0.5 inline-block h-4 w-4 translate-y-1/2" />,
    );
    return map;
  }, []);

  const columns = useMemo(
    () => [
      columnHelper.accessor("created_at", {
        header: () => <span className="pl-4">Time Placed</span>,
        cell: (info) => (
          <span className="pl-4 text-neutral-500">
            {new Date(info.getValue()).toLocaleString("en-US", {
              month: "numeric",
              day: "2-digit",
              year: "2-digit",
              hour: "numeric",
              minute: "numeric",
              second: "numeric",
              hour12: true,
            })}
          </span>
        ),
      }),
      columnHelper.display({
        header: "Type",
        cell: () => "LIMIT",
      }),
      columnHelper.accessor("side", {
        cell: (info) => info.getValue().toUpperCase(),
      }),
      columnHelper.accessor("price", {
        cell: (info) =>
          `${info.getValue()} ${
            marketById.get(info.row.original.market_id)?.quote.symbol ?? ""
          }`,
      }),
      columnHelper.accessor("size", {
        cell: (info) =>
          `${info.getValue()} ${
            marketById.get(info.row.original.market_id)?.base?.symbol ?? ""
          }`,
      }),
      columnHelper.accessor("total", {
        cell: (info) => {
          const total = info.getValue();
          const { market_id } = info.row.original;
          return `${total} ${marketById.get(market_id)?.quote?.symbol ?? ""}`;
        },
      }),
      columnHelper.accessor("order_state", {
        header: "Status",
        cell: (info) => {
          const value = info.getValue();
          if (value === "open") {
            return <span className="text-green">{value.toUpperCase()}</span>;
          }
          // TODO colors for other order statuses?
          return value.toUpperCase();
        },
      }),
    ],
    [marketById],
  );

  const table = useReactTable({
    data: data || [],
    columns,
    state: {
      sorting,
    },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });

  return (
    <div className="scrollbar-none h-[200px] overflow-y-auto">
      <table
        className={"w-full table-auto" + (className ? ` ${className}` : "")}
      >
        <thead
          className="sticky top-0 h-8  bg-[#020202] shadow-[inset_0_-1px_0_theme(colors.neutral.600)]"
          style={{
            backgroundImage: `url(${bg.src})`,
          }}
        >
          <tr>
            {table.getFlatHeaders().map((header) => (
              <th
                className="cursor-pointer select-none py-0.5 text-left font-roboto-mono text-sm font-light uppercase text-neutral-500 shadow-[inset_0_-1px_0_theme(colors.neutral.600)]"
                key={header.id}
                onClick={header.column.getToggleSortingHandler()}
              >
                {header.isPlaceholder
                  ? null
                  : flexRender(
                      header.column.columnDef.header,
                      header.getContext(),
                    )}
                {sortLabel.get(header.column.getIsSorted())}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
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
              <tr key={row.id}>
                {row.getVisibleCells().map((cell) => (
                  <td
                    className="h-7 py-0.5 text-left font-roboto-mono text-sm font-light text-white"
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
