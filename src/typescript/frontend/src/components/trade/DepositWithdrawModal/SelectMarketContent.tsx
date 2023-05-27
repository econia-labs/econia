import { Tab } from "@headlessui/react";
import { MagnifyingGlassIcon, StarIcon } from "@heroicons/react/20/solid";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  useReactTable,
} from "@tanstack/react-table";
import Image from "next/image";
import { useEffect, useMemo, useState } from "react";

import { type ApiMarket, type ApiStats } from "@/types/api";

import { useAllMarketData, useAllMarketPrices, useAllMarketStats } from ".";

const columnHelper = createColumnHelper<ApiMarket>();

const TABLE_SPACING = {
  margin: "-mx-6 -mb-6",
  paddingLeft: "pl-6",
  paddingRight: "pr-6",
};

export const SelectMarketContent: React.FC<{
  onSelectMarket: (market: ApiMarket) => void;
}> = ({ onSelectMarket }) => {
  const { data, isLoading } = useAllMarketData();
  const { data: marketStats } = useAllMarketStats();
  const { data: marketPrices } = useAllMarketPrices(data || []);
  const [filter, setFilter] = useState("");

  const [selectedTab, setSelectedTab] = useState(0);

  const columns = useMemo(() => {
    return [
      columnHelper.accessor("name", {
        cell: (info) => <MarketNameCell name={info.getValue()} />,
        header: "NAME",
        id: "name",
      }),
      columnHelper.accessor("market_id", {
        cell: (info) => (
          <PriceCell
            price={
              getPriceByMarketId(info.getValue(), marketPrices)?.price || 0
            }
          />
        ),
        header: "PRICE",
        id: "price",
      }),
      columnHelper.accessor("market_id", {
        cell: (info) => (
          <VolumeCell
            volume={
              getStatsByMarketId(info.getValue(), marketStats)?.volume || 0
            }
            baseAsset={
              getMarketByMarketId(info.getValue(), data)?.name.split("-")[0] ||
              "?"
            }
          />
        ),
        header: "VOLUME",
        id: "volume",
      }),
      columnHelper.accessor("market_id", {
        cell: (info) => (
          <TwentyFourHourChangeCell
            change={
              getStatsByMarketId(info.getValue(), marketStats)?.change || 0
            }
          />
        ),
        header: "24H CHANGE",
        id: "24h_change",
      }),
      columnHelper.accessor("recognized", {
        // TODO: add recognized cell
        cell: (info) => (
          <RecognizedCell isRecognized={info.getValue() || false} />
        ),
        header: "RECOGNIZED",
        id: "recognized",
      }),
    ];
  }, [data, marketStats, marketPrices]);

  const table = useReactTable({
    columns,
    data: data || [],
    getFilteredRowModel: getFilteredRowModel(),
    getCoreRowModel: getCoreRowModel(),
  });
  return (
    <div className="flex w-full flex-col items-center gap-6 ">
      <Tab.Group
        onChange={(index) => {
          setSelectedTab(index);
        }}
      >
        <h4 className="font-jost text-3xl font-bold text-white"></h4>
        <div className="relative w-full">
          <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
            <MagnifyingGlassIcon className={` h-5 w-5 text-neutral-500 `} />
          </div>
          <input
            type="text"
            id="voice-search"
            className=" block w-full border border-neutral-600  bg-transparent p-2.5  pl-10 font-roboto-mono text-sm text-neutral-500"
            placeholder="Search markets"
            required
            onChange={(e) => {
              setFilter(e.target.value);
            }}
            value={filter}
          />
        </div>
        <Tab.List className="mb-9 w-full">
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Recognized
          </Tab>
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            All Markets
          </Tab>
        </Tab.List>
        <Tab.Panels className="w-full">
          <div
            className={`${TABLE_SPACING.margin} scrollbar-none w-[calc(100%+3em)] overflow-x-auto`}
          >
            <table className={`w-full`}>
              <thead>
                {table.getHeaderGroups().map((headerGroup) => (
                  <tr
                    className="text-left font-roboto-mono text-sm text-neutral-500 [&>th]:font-light"
                    key={headerGroup.id}
                  >
                    {headerGroup.headers.map((header, i) => {
                      //  clearing filter
                      if (
                        header.id === "name" &&
                        // need these checks to prevent infinite loop
                        // table sets empty string as undefined so we need to check for both
                        filter == "" &&
                        header.column.getFilterValue() != undefined
                      ) {
                        header.column.setFilterValue(undefined);
                      }

                      // setting filter
                      if (
                        header.id === "name" &&
                        // need these checks to prevent infinite loop
                        // table sets empty string as undefined so we need to check for both
                        header.column.getFilterValue() != filter &&
                        filter != ""
                      ) {
                        header.column.setFilterValue(filter);
                      }
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
                                header.getContext()
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
                      className="h-24 min-w-[780px] cursor-pointer px-6 text-left font-roboto-mono text-sm text-white hover:outline hover:outline-1 hover:outline-neutral-600 [&>th]:font-light"
                      onClick={() => onSelectMarket(row.original)}
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
                            cell.getContext()
                          )}
                        </td>
                      ))}
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
          {/* <TableComponent table={table} /> */}
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};

// row components
const MarketNameCell = ({ name }: { name: string }) => {
  return (
    <div className={`flex items-center text-base ${TABLE_SPACING.paddingLeft}`}>
      <MarketIconPair
        quoteAssetIcon={`/tokenImages/${name.split("-")[1]}.png`}
        baseAssetIcon={`/tokenImages/${name.split("-")[0]}.png`}
      />
      <div className={`ml-7 min-w-[12em]`}>{name}</div>
    </div>
  );
};

const PriceCell = ({ price }: { price: number }) => {
  const formatter = Intl.NumberFormat("en", {
    notation: "compact",
    compactDisplay: "short",
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  });
  return (
    <div>
      <div className={`inline-block min-w-[8em] text-sm `}>
        ${price >= 10_000 && formatter.format(price).replace("K", "k")}{" "}
        {price < 10_000 &&
          price.toLocaleString("en", {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          })}
      </div>
      <div className={`inline-block min-w-[6em] text-neutral-500`}>$1.5M</div>
    </div>
  );
};

const VolumeCell = ({
  volume,
  baseAsset,
}: {
  volume: number;
  baseAsset: string;
}) => {
  // is this ok? https://caniuse.com/mdn-javascript_builtins_intl_numberformat_numberformat_options_compactdisplay_parameter
  // reference: https://stackoverflow.com/a/60988355
  // also, people tend to use lower case 'k' but the formatter uses upper case 'K'
  const formatter = Intl.NumberFormat("en", {
    notation: "compact",
    compactDisplay: "short",
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  });
  return (
    <div>
      <div className={`inline-block min-w-[8em] text-sm`}>
        {formatter.format(volume).replace("K", "k")} {baseAsset}
      </div>
      <div className={`inline-block min-w-[6em] text-neutral-500`}>$1.5M</div>
    </div>
  );
};

const TwentyFourHourChangeCell = ({ change = 0 }: { change: number }) => {
  return (
    <span
      className={`ml-1 inline-block min-w-[10em] text-center ${
        change < 0 ? "text-red" : "text-green"
      }`}
    >
      {plusMinus(change)}
      {formatNumber(change * 100, 2)}%
    </span>
  );
};

const RecognizedCell = ({ isRecognized }: { isRecognized: boolean }) => {
  return (
    <div className={`flex justify-center  ${TABLE_SPACING.paddingRight}`}>
      <StarIcon
        className={`my-auto ml-1 h-5 w-5 ${
          isRecognized ? "text-blue" : "text-neutral-600"
        }`}
      />
    </div>
  );
};

// util
const getStatsByMarketId = (
  marketId: number,
  marketStats: ApiStats[] | undefined
) => {
  if (!marketStats) return undefined;
  return marketStats.find((stats) => stats.market_id === marketId);
};

const getMarketByMarketId = (
  marketId: number,
  markets: ApiMarket[] | undefined
) => {
  if (!markets) return undefined;
  return markets.find((market) => market.market_id === marketId);
};

// very hacky type definition, need to think about where to put it
const getPriceByMarketId = (
  marketId: number,
  prices: { market_id: number; price: number }[] | undefined
) => {
  if (!prices) return undefined;
  return prices.find((price) => price.market_id === marketId);
};

// copy paste from statsbar, think about making a unified component later
const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";
type MarketIconPairProps = {
  baseAssetIcon?: string;
  quoteAssetIcon?: string;
};
const MarketIconPair = ({
  baseAssetIcon = DEFAULT_TOKEN_ICON,
  quoteAssetIcon = DEFAULT_TOKEN_ICON,
}: MarketIconPairProps) => {
  // TODO: add this so statsbar can use it too
  interface ImageWithFallbackProps {
    fallback?: string;
    alt: string;
    src: string;
    [key: string]: any; // allow any other props
  }

  const ImageWithFallback: React.FC<ImageWithFallbackProps> = ({
    fallback = "/tokenImages/default.png",
    alt,
    src,
    ...props
  }) => {
    const [error, setError] = useState<Error | null>(null);

    useEffect(() => {
      setError(null);
    }, [src]);

    return (
      <Image
        alt={alt}
        onError={() => setError(new Error("Failed to load image"))}
        src={error ? fallback : src}
        {...props}
      />
    );
  };

  return (
    <div className="relative flex">
      {/* height width props required */}
      <ImageWithFallback
        src={baseAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="z-20 aspect-square  w-[30px] min-w-[30px] md:min-w-[40px]"
      ></ImageWithFallback>
      <ImageWithFallback
        src={quoteAssetIcon}
        alt="market-icon-pair"
        width={40}
        height={40}
        className="absolute z-10 aspect-square w-[30px] min-w-[30px] translate-x-1/2 md:min-w-[40px]"
      ></ImageWithFallback>
    </div>
  );
};

const getLang = () => {
  return typeof window === "undefined"
    ? "en"
    : navigator.language || navigator.languages[0];
};

const formatNumber = (num: number | undefined, digits: number): string => {
  if (!num) return "-";
  return num.toLocaleString(getLang(), {
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
  });
};

const plusMinus = (num: number | undefined): string => {
  if (!num) return "";
  // no need to return - as numbers will already have that
  return num >= 0 ? `+` : ``;
};
//
export const DepositWithdrawContent: React.FC = () => {
  return (
    <div className="mt-12 flex w-full flex-col items-center gap-6">
      <Tab.Group>
        <Tab.List className="w-full">
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            Recognized
          </Tab>
          <Tab className="w-1/2 border-b border-b-neutral-600 py-4 text-center font-jost font-bold text-neutral-600 ui-selected:border-b-white ui-selected:text-white">
            All Markets
          </Tab>
        </Tab.List>
        <Tab.Panels className="w-full">
          <Tab.Panel>1</Tab.Panel>
          <Tab.Panel>2</Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
};
