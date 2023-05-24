import { ApiMarket } from "@/types/api";
import { useAllMarketData } from ".";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from "@tanstack/react-table";

const columnHelper = createColumnHelper<ApiMarket>();

export const SelectMarketContent: React.FC<{
  onSelectMarket: (market: ApiMarket) => void;
}> = ({ onSelectMarket }) => {
  const { data, isLoading } = useAllMarketData();
  const table = useReactTable({
    columns: [
      columnHelper.accessor("name", {
        cell: (info) => info.getValue(),
        header: "NAME",
      }),
      columnHelper.accessor("lot_size", {
        cell: (info) => info.getValue(),
        header: "LOT SIZE",
      }),
      columnHelper.accessor("tick_size", {
        cell: (info) => info.getValue(),
        header: "TICK SIZE",
      }),
      columnHelper.accessor("min_size", {
        cell: (info) => info.getValue(),
        header: "MIN SIZE",
      }),
    ],
    data: data || [],
    getCoreRowModel: getCoreRowModel(),
  });
  return (
    <div className="flex w-full flex-col items-center gap-6">
      <h4 className="font-jost text-3xl font-bold text-white">
        Select a Market
      </h4>

      <table className={"w-full"}>
        <thead>
          {table.getHeaderGroups().map((headerGroup) => (
            <tr
              className="text-left font-roboto-mono text-sm text-neutral-500 [&>th]:font-light"
              key={headerGroup.id}
            >
              {headerGroup.headers.map((header, i) => (
                <th className={i === 0 ? "text-left" : ""} key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
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
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center text-sm font-light uppercase text-neutral-500">
                  Loading...
                </div>
              </td>
            </tr>
          ) : data.length === 0 ? (
            <tr>
              <td colSpan={7}>
                <div className="flex h-[150px] flex-col items-center justify-center text-sm font-light uppercase text-neutral-500">
                  No markets to show
                </div>
              </td>
            </tr>
          ) : (
            table.getRowModel().rows.map((row) => (
              <tr
                className="cursor-pointer text-left font-roboto-mono text-sm text-white hover:bg-neutral-600 [&>th]:font-light"
                onClick={() => onSelectMarket(row.original)}
                key={row.id}
              >
                {row.getVisibleCells().map((cell, i) => (
                  <td
                    className={
                      i === 0
                        ? "text-left text-white"
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
