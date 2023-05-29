import type { GetStaticPaths, GetStaticProps } from "next";
import dynamic from "next/dynamic";
import Script from "next/script";
import { type PropsWithChildren, useState } from "react";

import { DepthChart } from "@/components/DepthChart";
import { OrderBook } from "@/components/OrderBook";
import { Page } from "@/components/Page";
import { StatsBar } from "@/components/StatsBar";
import { OrderEntry } from "@/components/trade/OrderEntry";
import { OrdersTable } from "@/components/trade/OrdersTable";
import { TradeHistoryTable } from "@/components/trade/TradeHistoryTable";
import { API_URL } from "@/env";
import type { ApiMarket } from "@/types/api";

import {
  type ResolutionString,
  type ThemeName,
} from "../../../public/static/charting_library";

const TVChartContainer = dynamic(
  () =>
    import("@/components/trade/TVChartContainer").then(
      (mod) => mod.TVChartContainer
    ),
  { ssr: false }
);

type Props = {
  marketData: ApiMarket | undefined;
  allMarketData: ApiMarket[];
};

type PathParams = {
  market_name: string;
};

const ChartCard: React.FC<PropsWithChildren<{ className?: string }>> = ({
  className,
  children,
}) => (
  <div
    className={"border border-neutral-600" + (className ? ` ${className}` : "")}
  >
    {children}
  </div>
);

const ChartName: React.FC<PropsWithChildren<{ className?: string }>> = ({
  className,
  children,
}) => (
  <p
    className={
      "ml-4 mt-2 font-jost text-white" + (className ? ` ${className}` : "")
    }
  >
    {children}
  </p>
);

export default function Market({ allMarketData, marketData }: Props) {
  const [isScriptReady, setIsScriptReady] = useState(false);

  if (!marketData) return <Page>Market not found.</Page>;

  const defaultTVChartProps = {
    symbol: marketData.name,
    interval: "1" as ResolutionString,
    datafeedUrl: "https://dev.api.econia.exchange",
    libraryPath: "/static/charting_library/",
    clientId: "econia.exchange",
    userId: "public_user_id",
    fullscreen: false,
    autosize: true,
    studiesOverrides: {},
    theme: "Dark" as ThemeName,
    selectedMarket: marketData,
    allMarketData,
  };

  return (
    <Page>
      <StatsBar selectedMarket={marketData} />
      <main className="flex flex-1 gap-4 px-4 py-2">
        <div className="flex flex-1 flex-col gap-4">
          <ChartCard className="flex flex-1 flex-col">
            {isScriptReady && <TVChartContainer {...defaultTVChartProps} />}
            <DepthChart marketData={marketData} />
          </ChartCard>
          <ChartCard>
            <ChartName className="mb-4">Orders</ChartName>
            <OrdersTable allMarketData={allMarketData} />
          </ChartCard>
        </div>
        <div className="flex w-[360px] flex-initial flex-col gap-4 border-neutral-600">
          <ChartCard className="flex flex-1 flex-col">
            <OrderBook marketData={marketData} />
          </ChartCard>
        </div>
        <div className="flex w-[360px] flex-initial flex-col gap-4 border-neutral-600">
          <div className="flex flex-1 flex-col gap-4">
            <ChartCard className="flex-1">
              <OrderEntry marketData={marketData} />
            </ChartCard>
            <ChartCard>
              <ChartName className="mb-4">Trade History</ChartName>
              <TradeHistoryTable marketData={marketData} />
            </ChartCard>
          </div>
        </div>
      </main>
      <Script
        src="/static/datafeeds/udf/dist/bundle.js"
        strategy="lazyOnload"
        onReady={() => {
          setIsScriptReady(true);
        }}
      />
    </Page>
  );
}

export const getStaticPaths: GetStaticPaths<PathParams> = async () => {
  const res = await fetch(new URL("markets", API_URL).href);
  const allMarketData: ApiMarket[] = await res.json();
  const paths = allMarketData.map((market) => ({
    params: { market_name: market.name },
  }));
  return { paths, fallback: false };
};

export const getStaticProps: GetStaticProps<Props, PathParams> = async ({
  params,
}) => {
  if (!params) throw new Error("No params");
  const allMarketData: ApiMarket[] = await fetch(
    new URL("markets", API_URL).href
  ).then((res) => res.json());
  const marketData = allMarketData.find(
    (market) => market.name === params.market_name
  );

  return {
    props: {
      marketData,
      allMarketData,
    },
    revalidate: 600, // 10 minutes
  };
};
