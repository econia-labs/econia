import { Tab } from "@headlessui/react";
import { MagnifyingGlassIcon } from "@heroicons/react/20/solid";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  useReactTable,
} from "@tanstack/react-table";
import { useMemo, useState } from "react";

import { NotRecognizedIcon } from "@/components/icons/NotRecognizedIcon";
import { RecognizedIcon } from "@/components/icons/RecognizedIcon";
import { MarketIconPair } from "@/components/MarketIconPair";
import { useAptos } from "@/contexts/AptosContext";
import { type ApiMarket, type ApiStats } from "@/types/api";
import { formatNumber, plusMinus } from "@/utils/formatter";
import { TypeTag } from "@/utils/TypeTag";

import { useAllMarketStats } from ".";

const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";

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

const TABLE_SPACING = {
  margin: "-mx-6 -mb-6",
  paddingLeft: "pl-6",
  paddingRight: "pr-6",
};

export const SelectMarketContent: React.FC<{
  allMarketData: ApiMarket[];
}> = ({ allMarketData }) => {
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
        cell: (info) => {
          const { baseAssetIcon, quoteAssetIcon } = info.row.original;
          return (
            <div
              className={`flex items-center text-base ${TABLE_SPACING.paddingLeft}`}
            >
              <MarketIconPair
                quoteAssetIcon={quoteAssetIcon}
                baseAssetIcon={baseAssetIcon}
              />
              <div className={`ml-7 min-w-[12em]`}>{info.getValue()}</div>
            </div>
          );
        },
      }),
      columnHelper.accessor("price", {
        cell: (info) => {
          const price = info.getValue();
          const { quoteSymbol } = info.row.original;
          const formatter = Intl.NumberFormat("en", {
            notation: "compact",
            compactDisplay: "short",
            minimumFractionDigits: 1,
            maximumFractionDigits: 1,
          });
          return price != null ? (
            <div className="min-w-[8em] text-sm">
              {price >= 10_000 && formatter.format(price).replace("K", "k")}
              {price < 10_000 &&
                price.toLocaleString("en", {
                  minimumFractionDigits: 2,
                  maximumFractionDigits: 2,
                })}{" "}
              {quoteSymbol}
            </div>
          ) : (
            <div className="min-w-[8em] text-sm">-</div>
          );
        },
      }),
      columnHelper.accessor("baseVolume", {
        header: "volume",
        cell: (info) => {
          // TODO: add quote volume
          const volume = info.getValue();
          const { baseSymbol } = info.row.original;
          const formatter = Intl.NumberFormat("en", {
            notation: "compact",
            compactDisplay: "short",
            minimumFractionDigits: 1,
            maximumFractionDigits: 1,
          });
          return (
            <div className={`min-w-[8em] text-sm`}>
              {volume != null
                ? formatter.format(volume).replace("K", "k")
                : "-"}{" "}
              {baseSymbol}
            </div>
          );
        },
      }),
      columnHelper.accessor("twentyFourHourChange", {
        header: "24h change",
        cell: (info) => {
          const change = info.getValue();
          return change != null ? (
            <span
              className={`ml-1 inline-block min-w-[10em] text-center ${
                change < 0 ? "text-red" : "text-green"
              }`}
            >
              {plusMinus(change)}
              {formatNumber(change * 100, 2)}%
            </span>
          ) : (
            <span>-</span>
          );
        },
      }),
      columnHelper.accessor("recognized", {
        cell: (info) => {
          const isRecognized = info.getValue();
          return (
            <div
              className={`flex justify-center  ${TABLE_SPACING.paddingRight}`}
            >
              {isRecognized ? (
                <RecognizedIcon className="h-5 w-5" />
              ) : (
                <NotRecognizedIcon className="h-5 w-5" />
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
    <div className="flex w-full flex-col items-center">
      <Tab.Group
        onChange={(index) => {
          setSelectedTab(index);
        }}
      >
        <div className="w-full px-2 pt-2">
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
          <Tab.List className="mb-9 mt-4 w-full">
            <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 outline-none ui-selected:border-b-white ui-selected:text-white">
              Recognized
            </Tab>
            <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 outline-none ui-selected:border-b-white ui-selected:text-white">
              All Markets
            </Tab>
          </Tab.List>
        </div>
        <Tab.Panels className="w-full">
          <div
            className={`${TABLE_SPACING.margin} scrollbar-none w-[calc(100%+3em)] overflow-x-auto`}
          >
            <table className="w-full">
              <thead>
                {table.getHeaderGroups().map((headerGroup) => (
                  <tr
                    className="text-left font-roboto-mono text-sm uppercase text-neutral-500 [&>th]:font-light"
                    key={headerGroup.id}
                  >
                    {headerGroup.headers.map((header, i) => {
                      if (header.id === "name") {
                        if (
                          filter == "" &&
                          header.column.getFilterValue() != undefined
                        ) {
                          header.column.setFilterValue(undefined);
                        }
                        if (
                          filter != "" &&
                          header.column.getFilterValue() != filter
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
                          header.column.getFilterValue() == true
                        ) {
                          header.column.setFilterValue(undefined);
                        }
                      }
                      return (
                        <th
                          className={`${i === 0 ? "text-left" : ""} ${
                            header.id === "recognized" ||
                            (header.id === "24h_change" && "text-center")
                          }
                          ${i === 0 ? TABLE_SPACING.paddingLeft : ""}
                          ${
                            i === headerGroup.headers.length - 1
                              ? TABLE_SPACING.paddingRight
                              : ""
                          } `}
                          key={header.id}
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
                <tr>
                  <td colSpan={7} className="">
                    <div className="h-4"></div>
                  </td>
                </tr>
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
                      className="h-24 min-w-[780px] cursor-pointer px-6 text-left font-roboto-mono text-sm text-white hover:bg-neutral-700 [&>th]:font-light"
                      key={row.id}
                    >
                      {row.getVisibleCells().map((cell, i) => (
                        <td
                          className={
                            i === 0
                              ? "text-left text-white"
                              : i === 6
                              ? `${
                                  cell.getValue() === "open" ? "text-green" : ""
                                }`
                              : ""
                          }
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
          </div>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};

// row components
// const MarketNameCell = ({ name }: { name: ApiMarket }) => {
//   const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";

//   const { coinListClient } = useAptos();
//   const baseAssetIcon = name.base
//     ? coinListClient.getCoinInfoByFullName(
//         TypeTag.fromApiCoin(name.base).toString(),
//       )?.logo_url
//     : DEFAULT_TOKEN_ICON;
//   const quoteAssetIcon =
//     coinListClient.getCoinInfoByFullName(
//       TypeTag.fromApiCoin(name.quote).toString(),
//     )?.logo_url ?? DEFAULT_TOKEN_ICON;
//   return (
//     <div className={`flex items-center text-base ${TABLE_SPACING.paddingLeft}`}>
//       <MarketIconPair
//         quoteAssetIcon={quoteAssetIcon}
//         baseAssetIcon={baseAssetIcon}
//       />
//       <div className={`ml-7 min-w-[12em]`}>{name.name}</div>
//     </div>
//   );
// };

// const PriceCell = ({
//   price,
//   quoteAsset,
// }: {
//   price: number;
//   quoteAsset: string;
// }) => {
//   const formatter = Intl.NumberFormat("en", {
//     notation: "compact",
//     compactDisplay: "short",
//     minimumFractionDigits: 1,
//     maximumFractionDigits: 1,
//   });
//   return (
//     <div className="min-w-[8em] text-sm">
//       {price >= 10_000 && formatter.format(price).replace("K", "k")}
//       {price < 10_000 &&
//         price.toLocaleString("en", {
//           minimumFractionDigits: 2,
//           maximumFractionDigits: 2,
//         })}{" "}
//       {quoteAsset}
//     </div>
//   );
// };

// const VolumeCell = ({
//   volume,
//   baseAsset,
// }: {
//   volume: number;
//   baseAsset: string;
// }) => {
//   // is this ok? https://caniuse.com/mdn-javascript_builtins_intl_numberformat_numberformat_options_compactdisplay_parameter
//   // reference: https://stackoverflow.com/a/60988355
//   // also, people tend to use lower case 'k' but the formatter uses upper case 'K'
//   const formatter = Intl.NumberFormat("en", {
//     notation: "compact",
//     compactDisplay: "short",
//     minimumFractionDigits: 1,
//     maximumFractionDigits: 1,
//   });
//   return (
//     <div className="block">
//       <div className={`min-w-[8em] text-sm`}>
//         {formatter.format(volume).replace("K", "k")} {baseAsset}
//       </div>
//       <div className={`min-w-[6em] text-neutral-500`}>$1.5M</div>
//     </div>
//   );
// };

// const TwentyFourHourChangeCell = ({ change = 0 }: { change: number }) => {
//   return (
//     <span
//       className={`ml-1 inline-block min-w-[10em] text-center ${
//         change < 0 ? "text-red" : "text-green"
//       }`}
//     >
//       {plusMinus(change)}
//       {formatNumber(change * 100, 2)}%
//     </span>
//   );
// };

// const RecognizedCell = ({ isRecognized }: { isRecognized: boolean }) => {
//   return (
//     <div className={`flex justify-center  ${TABLE_SPACING.paddingRight}`}>
//       {isRecognized ? (
//         <RecognizedIcon className="h-5 w-5" />
//       ) : (
//         <NotRecognizedIcon className="h-5 w-5" />
//       )}
//     </div>
//   );
// };

// // util
// const getStatsByMarketId = (
//   marketId: number,
//   marketStats: ApiStats[] | undefined,
// ) => {
//   if (!marketStats) return undefined;
//   return marketStats.find((stats) => stats.market_id === marketId);
// };

// const getMarketByMarketId = (
//   marketId: number,
//   markets: ApiMarket[] | undefined,
// ) => {
//   if (!markets) return undefined;
//   return markets.find((market) => market.market_id === marketId);
// };
