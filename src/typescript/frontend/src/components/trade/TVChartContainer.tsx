import { useEffect, useMemo, useRef } from "react";

import { API_URL } from "@/env";
import { type ApiBar, type ApiMarket, type ApiResolution } from "@/types/api";
import { TypeTag } from "@/utils/TypeTag";

import {
  type Bar,
  type ChartingLibraryWidgetOptions,
  type DatafeedConfiguration,
  type IBasicDataFeed,
  type IChartingLibraryWidget,
  type LibrarySymbolInfo,
  type ResolutionString,
  type SearchSymbolResultItem,
  type Timezone,
  widget,
} from "../../../public/static/charting_library";

export interface ChartContainerProps {
  symbol: ChartingLibraryWidgetOptions["symbol"];
  interval: ChartingLibraryWidgetOptions["interval"];

  datafeedUrl: string;
  libraryPath: ChartingLibraryWidgetOptions["library_path"];
  clientId: ChartingLibraryWidgetOptions["client_id"];
  userId: ChartingLibraryWidgetOptions["user_id"];
  fullscreen: ChartingLibraryWidgetOptions["fullscreen"];
  autosize: ChartingLibraryWidgetOptions["autosize"];
  studiesOverrides: ChartingLibraryWidgetOptions["studies_overrides"];
  container: ChartingLibraryWidgetOptions["container"];
  theme: ChartingLibraryWidgetOptions["theme"];
}

const GREEN = "rgba(110, 213, 163, 1.0)";
const RED = "rgba(240, 129, 129, 1.0)";

const GREEN_OPACITY_HALF = "rgba(110, 213, 163, 0.5)";
const RED_OPACITY_HALF = "rgba(240, 129, 129, 0.5)";

const resolutions = [
  "1",
  "5",
  "15",
  "30",
  "60",
  // "4H", // TODO: enable on backend
  // "12H",
  // "1D",
] as ResolutionString[];

const resolutionMap: Record<string, ApiResolution> = {
  "1": "1m",
  "5": "5m",
  "15": "15m",
  "30": "30m",
  "60": "1h",
  "4H": "4h",
  "12H": "12h",
  "1D": "1d",
};

const configurationData: DatafeedConfiguration = {
  supported_resolutions: resolutions,
  exchanges: [
    {
      value: "Econia",
      name: "Econia",
      desc: "econia",
    },
  ],
  symbols_types: [
    {
      name: "crypto",
      value: "crypto",
    },
  ],
};

const getSymbolInfo = (marketInfo: ApiMarket): LibrarySymbolInfo => {
  if (marketInfo.base != null) {
    return {
      name: marketInfo.name,
      full_name: marketInfo.name,
      description: marketInfo.name,
      base_name: [marketInfo.base.name],
      pricescale: marketInfo.tick_size,
      type: "crypto",
      session: "24x7",
      exchange: "Econia",
      listed_exchange: "Econia",
      timezone: "Etc/UTC",
      has_intraday: true,
      minmov: 10,
      format: "price",
      supported_resolutions: resolutions,
    };
  } else if (marketInfo.base_name_generic != null) {
    return {
      name: marketInfo.name,
      full_name: marketInfo.name,
      description: marketInfo.name,
      base_name: [marketInfo.base_name_generic],
      pricescale: marketInfo.tick_size,
      type: "crypto",
      session: "24x7",
      exchange: "Econia",
      listed_exchange: "Econia",
      timezone: "Etc/UTC",
      has_intraday: true,
      minmov: 10,
      format: "price",
      supported_resolutions: resolutions,
    };
  } else {
    throw new Error("Neither base nor base_name_generic are defined.");
  }
};

const getSearchItem = ({
  name,
  base,
  quote,
  base_name_generic,
}: ApiMarket): SearchSymbolResultItem => {
  if (base != null) {
    const fullBase = TypeTag.fromApiCoin(base).toString();
    const fullQuote = TypeTag.fromApiCoin(quote).toString();

    return {
      symbol: name,
      ticker: name,
      full_name: `${fullBase}/${fullQuote}`,
      description: name,
      exchange: "Econia",
      type: "crypto",
    };
  } else if (base_name_generic != null) {
    return {
      symbol: name,
      ticker: name,
      full_name: base_name_generic,
      description: name,
      exchange: "Econia",
      type: "crypto",
    };
  } else {
    throw new Error("Neither base nor base_name_generic are defined.");
  }
};

type TVChartContainerProps = {
  selectedMarket: ApiMarket;
  allMarketData: ApiMarket[];
};

export const TVChartContainer: React.FC<
  Partial<ChartContainerProps> & TVChartContainerProps
> = (props) => {
  const tvWidget = useRef<IChartingLibraryWidget>();
  const ref = useRef<HTMLDivElement>(null);

  const datafeed: IBasicDataFeed = useMemo(
    () => ({
      onReady: (callback) => {
        setTimeout(() => {
          callback(configurationData);
        }, 0);
      },
      searchSymbols: async (
        userInput,
        exchange,
        symbolType,
        onResultReadyCallback,
      ) => {
        if (exchange !== "Econia" || symbolType !== "crypto") {
          throw new Error("Parameters not supported.");
        }

        const symbols: SearchSymbolResultItem[] =
          props.allMarketData.map(getSearchItem);

        const searchResults = symbols.filter(
          (symbol) =>
            symbol.full_name.toLowerCase().indexOf(userInput.toLowerCase()) !==
              -1 ||
            symbol.symbol.toLowerCase().indexOf(userInput.toLowerCase()) !== -1,
        );
        onResultReadyCallback(searchResults);
      },
      resolveSymbol: async (
        symbolName,
        onSymbolResolvedCallback,
        onResolveErrorCallback,
      ) => {
        const marketInfo: ApiMarket | undefined = props.allMarketData.find(
          ({ name }) => name === symbolName,
        );

        if (marketInfo != null) {
          const symbolInfo = getSymbolInfo(marketInfo);
          setTimeout(() => {
            onSymbolResolvedCallback(symbolInfo);
          }, 0);
        } else {
          setTimeout(() => {
            onResolveErrorCallback(`Market "${symbolName}" not found.`);
          }, 0);
        }
      },
      getBars: async (
        symbolInfo,
        resolution,
        periodParams,
        onHistoryCallback,
        onErrorCallback,
      ) => {
        // TODO find a better way to pass market ID
        const market = props.allMarketData.find(
          ({ name }) => name === symbolInfo.name,
        );
        if (market == null) {
          throw new Error("market not found.");
        }
        const { from, to } = periodParams;

        try {
          const res = await fetch(
            new URL(
              `/markets/${market.market_id}/history?${new URLSearchParams({
                resolution: resolutionMap[resolution],
                from: from.toString(),
                to: to.toString(),
              })}`,
              API_URL,
            ).href,
          );
          const data = await res.json();

          const bars = data.map(
            (bar: ApiBar): Bar => ({
              time: new Date(bar.start_time).getTime(),
              ...bar,
            }),
          );

          onHistoryCallback(bars, { noData: bars.length === 0 });
        } catch (e) {
          if (e instanceof Error) {
            onErrorCallback(e.message);
          }
        }
      },
      subscribeBars: async (
        _symbolInfo,
        _resolution,
        _onRealtimeCallback,
        _subscribeUID,
        _onResetCacheNeededCallback,
      ) => {
        // TODO
      },
      unsubscribeBars: async (_subscriberUID) => {
        // TODO
      },
    }),
    [props.allMarketData],
  );

  useEffect(() => {
    if (!ref.current) {
      return;
    }

    const widgetOptions: ChartingLibraryWidgetOptions = {
      symbol: props.symbol as string,
      datafeed,
      interval: "1" as ResolutionString,
      container: ref.current,
      library_path: props.libraryPath as string,
      theme: props.theme,
      locale: "en",
      custom_css_url: "/styles/tradingview.css",
      timezone:
        (Intl.DateTimeFormat().resolvedOptions().timeZone as Timezone) ??
        "Etc/UTC",
      disabled_features: [
        "use_localstorage_for_settings",
        "left_toolbar",
        "control_bar",
        "study_templates",
        "snapshot_trading_drawings",
      ],
      client_id: props.clientId,
      user_id: props.userId,
      fullscreen: props.fullscreen,
      autosize: props.autosize,
      loading_screen: { backgroundColor: "#000000" },
      overrides: {
        "paneProperties.backgroundType": "solid",
        "paneProperties.background": "#000000",
        "scalesProperties.backgroundColor": "#000000",
        "mainSeriesProperties.barStyle.upColor": GREEN,
        "mainSeriesProperties.barStyle.downColor": RED,
        "mainSeriesProperties.candleStyle.upColor": GREEN,
        "mainSeriesProperties.candleStyle.downColor": RED,
        "mainSeriesProperties.candleStyle.borderUpColor": GREEN,
        "mainSeriesProperties.candleStyle.borderDownColor": RED,
        "mainSeriesProperties.candleStyle.wickUpColor": GREEN,
        "mainSeriesProperties.candleStyle.wickDownColor": RED,
        "mainSeriesProperties.columnStyle.upColor": GREEN_OPACITY_HALF,
        "mainSeriesProperties.columnStyle.downColor": RED_OPACITY_HALF,
        "mainSeriesProperties.hollowCandleStyle.upColor": GREEN,
        "mainSeriesProperties.hollowCandleStyle.downColor": RED,
        "mainSeriesProperties.rangeStyle.upColor": GREEN,
        "mainSeriesProperties.rangeStyle.downColor": RED,
        "paneProperties.legendProperties.showVolume": true,
      },
      studies_overrides: {
        ...props.studiesOverrides,
        "volume.volume.color.0": RED_OPACITY_HALF,
        "volume.volume.color.1": GREEN_OPACITY_HALF,
      },
      time_frames: [
        // defaults
        {
          text: "1D",
          resolution: "1" as ResolutionString,
        },
        {
          text: "5D",
          resolution: "5" as ResolutionString,
        },
        {
          text: "1M",
          resolution: "30" as ResolutionString,
        },
        {
          text: "3M",
          resolution: "60" as ResolutionString,
        },
        {
          text: "6M",
          resolution: "120" as ResolutionString,
        },
        {
          text: "1y",
          resolution: "D" as ResolutionString,
        },
        {
          text: "5y",
          resolution: "W" as ResolutionString,
        },
        {
          text: "1000y", // custom ALL timeframe
          resolution: "60" as ResolutionString, // may want to specify a different resolution here for server load purposes
          description: "All",
          title: "All",
        },
      ],
    };

    tvWidget.current = new widget(widgetOptions);

    return () => {
      if (tvWidget.current != null) {
        tvWidget.current.remove();
        tvWidget.current = undefined;
      }
    };
  }, [
    datafeed,
    props.symbol,
    props.clientId,
    props.userId,
    props.fullscreen,
    props.autosize,
    props.studiesOverrides,
    props.theme,
    props.libraryPath,
  ]);

  return <div ref={ref} className="w-full" />;
};
