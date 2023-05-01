import { API_URL } from "@/env";
import type { ApiMarket } from "@/types/api";

export default function Market({ marketData }: { marketData: ApiMarket }) {
  return <div>Market {marketData.market_id}</div>;
}

type PathParams = {
  params: {
    market_id: string;
  };
};

export async function getStaticPaths() {
  const res = await fetch(new URL("markets", API_URL).href);
  const marketData: ApiMarket[] = await res.json();
  const paths: PathParams[] = marketData.map((market) => ({
    params: { market_id: market.market_id.toString() },
  }));
  return { paths, fallback: false };
}

export async function getStaticProps({ params }: PathParams) {
  const res = await fetch(new URL(`market/${params.market_id}`, API_URL).href);
  const marketData: ApiMarket = await res.json();

  return {
    props: {
      marketData,
    },
    revalidate: 600, // 10 minutes
  };
}
