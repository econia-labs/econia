import { Tab } from "@headlessui/react";
import { MagnifyingGlassIcon } from "@heroicons/react/20/solid";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  useReactTable,
} from "@tanstack/react-table";
import { useRouter } from "next/router";
import { useMemo, useState } from "react";

import { NotRecognizedIcon } from "@/components/icons/NotRecognizedIcon";
import { RecognizedIcon } from "@/components/icons/RecognizedIcon";
import { MarketIconPair } from "@/components/MarketIconPair";
import { useAptos } from "@/contexts/AptosContext";
import { type ApiMarket } from "@/types/api";
import {
  formatNumber,
  plusMinus,
  priceFormatter,
  volFormatter,
} from "@/utils/formatter";
import { TypeTag } from "@/utils/TypeTag";
import Skeleton from "react-loading-skeleton";

import { useAllMarketStats } from ".";

const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";
const colWidths = [260, undefined, undefined, 120, 130] as const;

type MarketWithStats = {
  marketId: number;
  baseSymbol?: string;
  quoteSymbol: string;
  baseAssetIcon: string;
  quoteAssetIcon: string;
  name: string;
  price?: number;
  baseVolume?: number;
  quoteVolume?: number;
  twentyFourHourChange?: number;
  recognized?: boolean;
};

const columnHelper = createColumnHelper<MarketWithStats>();

/**
 * @param onSelectMarket - if provided, will call this function instead of routing to the market page
 */
export const SelectMarketContent: React.FC<{
  allMarketData: ApiMarket[];
  onSelectMarket?: (marketId: number, name?: string) => void;
}> = ({ allMarketData, onSelectMarket }) => {
  const router = useRouter();
  const { data: marketStats } = useAllMarketStats();
  const [filter, setFilter] = useState("");
  const { coinListClient } = useAptos();

  const [selectedTab, setSelectedTab] = useState(0);

  const marketDataWithStats: MarketWithStats[] = useMemo(() => {
    const marketsWithNoStats = allMarketData.map((market): MarketWithStats => {
      const baseAssetIcon = market.base
        ? coinListClient.getCoinInfoByFullName(
            TypeTag.fromApiCoin(market.base).toString(),
          )?.logo_url ?? DEFAULT_TOKEN_ICON
        : DEFAULT_TOKEN_ICON;
      const quoteAssetIcon =
        coinListClient.getCoinInfoByFullName(
          TypeTag.fromApiCoin(market.quote).toString(),
        )?.logo_url ?? DEFAULT_TOKEN_ICON;

      const baseSymbol =
        market.base != null
          ? market.base.symbol
          : market.base_name_generic ?? undefined;

      return {
        marketId: market.market_id,
        baseSymbol,
        quoteSymbol: market.quote.symbol,
        baseAssetIcon,
        quoteAssetIcon,
        name: market.name,
        price: undefined,
        baseVolume: undefined,
        quoteVolume: undefined,
        twentyFourHourChange: undefined,
        recognized: market.recognized,
      };
    });
    if (marketStats == null) {
      return marketsWithNoStats;
    }
    return marketsWithNoStats.map((market): MarketWithStats => {
      const stats = marketStats.find(
        ({ market_id }) => market_id === market.marketId,
      );
      if (stats == null) {
        return market;
      }
      return {
        ...market,
        price: stats.close,
        baseVolume: stats.volume,
        quoteVolume: undefined, // TODO
        twentyFourHourChange: stats.change,
      };
    });
  }, [allMarketData, coinListClient, marketStats]);

  const columns = useMemo(
    () => [
      columnHelper.accessor("name", {
        header: () => <div className="pl-8">Name</div>,
        cell: (info) => {
          const { baseAssetIcon, quoteAssetIcon } = info.row.original;
          return (
            <div className="flex pl-8">
              <MarketIconPair
                zIndex={1}
                quoteAssetIcon={quoteAssetIcon}
                baseAssetIcon={baseAssetIcon}
              />
              <p className="my-auto ml-2">{info.getValue()}</p>
            </div>
          );
        },
      }),
      columnHelper.accessor("price", {
        cell: (info) => {
          const price = info.getValue();
          if (price == null) {
            return "-";
          }

          const priceStr =
            price < 10_000
              ? price.toLocaleString("en", {
                  minimumFractionDigits: 2,
                  maximumFractionDigits: 2,
                })
              : priceFormatter.format(price).replace("K", "k");
          const { quoteSymbol } = info.row.original;

          return `${priceStr} ${quoteSymbol}`;
        },
      }),
      columnHelper.accessor("baseVolume", {
        header: "volume",
        cell: (info) => {
          // TODO: add quote volume
          const volume = info.getValue();
          const { baseSymbol } = info.row.original;
          return `${
            volume != null ? volFormatter.format(volume).replace("K", "k") : "-"
          } ${baseSymbol}`;
        },
      }),
      columnHelper.accessor("twentyFourHourChange", {
        header: "24h change",
        cell: (info) => {
          const change = info.getValue();
          if (change == null) {
            return "-";
          }
          return (
            <p className={change < 0 ? "text-red" : "text-green"}>
              {plusMinus(change)}
              {formatNumber(change * 100, 2)}%
            </p>
          );
        },
      }),
      columnHelper.accessor("recognized", {
        header: () => <div className="pr-8 text-right">Recognized</div>,
        cell: (info) => {
          const isRecognized = info.getValue();
          return (
            <div className="flex pr-8">
              {isRecognized ? (
                <RecognizedIcon className="m-auto h-5 w-5" />
              ) : (
                <NotRecognizedIcon className="m-auto h-5 w-5" />
              )}
            </div>
          );
        },
      }),
    ],
    [],
  );

  const table = useReactTable({
    columns,
    data: marketDataWithStats || [],
    getFilteredRowModel: getFilteredRowModel(),
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="flex max-h-[560px] min-h-[560px] w-full flex-col items-center overflow-y-hidden">
      <Tab.Group
        onChange={(index) => {
          setSelectedTab(index);
        }}
      >
        <div className="w-full px-8 pt-8">
          <div className="relative w-full">
            <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <MagnifyingGlassIcon className="h-5 w-5 text-neutral-500" />
            </div>
            <input
              type="text"
              id="voice-search"
              className="block w-full border border-neutral-600 bg-transparent p-2.5 pl-10 font-roboto-mono text-sm text-neutral-500 outline-none"
              placeholder="Search markets"
              required
              onChange={(e) => {
                setFilter(e.target.value);
              }}
              value={filter}
            />
          </div>
          <Tab.List className="mt-4 w-full">
            <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 outline-none ui-selected:border-b-white ui-selected:text-white">
              Recognized
            </Tab>
            <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 outline-none ui-selected:border-b-white ui-selected:text-white">
              All Markets
            </Tab>
          </Tab.List>
        </div>

        <Tab.Panels className="scrollbar-none w-full overflow-y-scroll">
          <table className="mt-4 w-full table-fixed">
            <thead className="sticky top-0 z-10 h-12 bg-[#020202] pt-4">
              {table.getHeaderGroups().map((headerGroup) => (
                <tr className="h-8 pt-4" key={headerGroup.id}>
                  {headerGroup.headers.map((header, i) => {
                    if (header.id === "name") {
                      if (
                        filter === "" &&
                        header.column.getFilterValue() != undefined
                      ) {
                        header.column.setFilterValue(undefined);
                      }
                      if (
                        filter !== "" &&
                        header.column.getFilterValue() !== filter
                      ) {
                        header.column.setFilterValue(filter);
                      }
                    }

                    // recognized
                    if (header.id === "recognized") {
                      if (
                        selectedTab === 0 &&
                        header.column.getFilterValue() == undefined
                      ) {
                        header.column.setFilterValue(true);
                      }
                      if (
                        selectedTab === 1 &&
                        header.column.getFilterValue() === true
                      ) {
                        header.column.setFilterValue(undefined);
                      }
                    }
                    return (
                      <th
                        className={`pt-4 text-left font-roboto-mono text-sm font-light uppercase text-neutral-500`}
                        key={header.id}
                        style={{ width: colWidths[i] }}
                      >
                        {header.isPlaceholder
                          ? null
                          : flexRender(
                              header.column.columnDef.header,
                              header.getContext(),
                            )}
                      </th>
                    );
                  })}
                </tr>
              ))}
            </thead>
            <tbody>
              {allMarketData.length === 0 ? (
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
                    className="h-24 cursor-pointer hover:bg-neutral-700"
                    key={row.id}
                    onClick={() => {
                      if (onSelectMarket != null) {
                        const marketId = row.original.marketId;
                        onSelectMarket(marketId, row.getValue("name"));
                      }
                      router.push(`/trade/${row.getValue("name")}`);
                    }}
                  >
                    {row.getVisibleCells().map((cell) => (
                      <td
                        className="text-left font-roboto-mono text-sm font-light text-white"
                        key={cell.id}
                      >
                        {flexRender(
                          cell.column.columnDef.cell,
                          cell.getContext(),
                        )}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};
