import Head from "next/head";

import { StatsBar } from "@/components/StatsBar";
import { Layout } from "@/layouts/Layout";
import { type ApiMarket } from "@/types/api";

export default function Home({ marketData }: { marketData: ApiMarket[] }) {
  const marketNames: string[] = marketData
    .sort((a, b) => a.market_id - b.market_id)
    .map((market) => `${market.base.symbol}-${market.quote.symbol}`);
  return (
    <>
      <Head>
        <title>Econia</title>
      </Head>
      <Layout>
        <StatsBar />
        <main>
          <p className="font-roboto-mono text-white">
            {JSON.stringify(marketNames)}
          </p>
        </main>
      </Layout>
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
    // Next.js will attempt to re-generate the page:
    // - When a request comes in
    // - At most once every 10 seconds
    revalidate: 10, // In seconds
  };
}
