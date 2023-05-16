import Head from "next/head";

import { Header } from "@/components/Header";
import { OrderEntry } from "@/components/trade/OrderEntry";
import { StatsBar } from "@/components/StatsBar";
import { type ApiMarket } from "@/types/api";

export default function Home({ marketData }: { marketData: ApiMarket[] }) {
  const marketNames: string[] = marketData
    .sort((a, b) => a.market_id - b.market_id)
    .map((market) => market.name);

  return (
    <>
      <Head>
        <title>Econia</title>
      </Head>
      <div className="flex min-h-screen w-full flex-col bg-black">
        <Header />
        <StatsBar marketNames={marketNames} />
        <main className="flex flex-1">
          <div className="flex-1 border-r border-neutral-600 px-4 py-2">
            <p className="font-jost text-white">Price Chart</p>
          </div>
          <div className="w-[320px] flex-initial border-r border-neutral-600 px-4 py-2">
            <p className="font-jost text-white">Orderbook</p>
          </div>
        </main>
      </div>
    </>
  );
}

export async function getStaticProps() {
  if (process.env.NEXT_PUBLIC_API_URL == null) {
    throw new Error("NEXT_PUBLIC_API_URL not set");
  }
  const res = await fetch(
    new URL("markets", process.env.NEXT_PUBLIC_API_URL).href
  );
  const marketData: ApiMarket[] = await res.json();

  return {
    props: {
      marketData,
    },
    revalidate: 600, // 10 minutes
  };
}
