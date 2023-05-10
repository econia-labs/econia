import type { GetStaticPaths, GetStaticProps } from "next";

import { Page } from "@/components/Page";
import { StatsBar } from "@/components/StatsBar";
import { API_URL } from "@/env";
import type { ApiMarket } from "@/types/api";

type Props = {
  marketData: ApiMarket | undefined;
  allMarketData: ApiMarket[];
};

type PathParams = {
  market_name: string;
};

export default function Market({ allMarketData, marketData }: Props) {
  if (!marketData) return <Page>Market not found.</Page>;

  const marketNames: string[] = allMarketData
    .sort((a, b) => a.name.localeCompare(b.name))
    .map((market) => `${market.name}`);
  return (
    <Page>
      <StatsBar marketNames={marketNames} />
      <main className="flex flex-1">
        <div>Market {marketData.name}</div>
        <div className="flex-1 border-r border-neutral-600 px-4 py-2">
          <p className="font-jost text-white">Price Chart</p>
        </div>
        <div className="w-[320px] flex-initial border-r border-neutral-600 px-4 py-2">
          <p className="font-jost text-white">Orderbook</p>
        </div>
        <div className="w-[320px] flex-initial px-4 py-2">
          <p className="font-jost text-white">Order Entry</p>
        </div>
      </main>
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
