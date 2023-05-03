import { type GetStaticProps } from "next";

import { Header } from "@/components/Header";
import { Page } from "@/components/Page";
import { StatsBar } from "@/components/StatsBar";
import { type ApiMarket } from "@/types/api";

export default function Trade({ marketData }: { marketData: ApiMarket[] }) {
  const marketNames: string[] = marketData
    .sort((a, b) => a.market_id - b.market_id)
    .map((market) => `${market.base.symbol}-${market.quote.symbol}`);
  // TODO: mock data
  marketNames.push("APT-USDC", "ETH-USDC");

  return (
    <Page>
      <StatsBar marketNames={marketNames} />
      <main className="flex flex-1">
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

export const getStaticProps: GetStaticProps = () => {
  return {
    props: {
      marketData: [],
    },
  };
};
