import { type GetStaticProps } from "next";
import Head from "next/head";
import { useRouter } from "next/router";

import { Header } from "@/components/Header";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { type ApiMarket } from "@/types/api";

type Props = {
  allMarketData: ApiMarket[];
};

export default function Trade({ allMarketData }: Props) {
  const router = useRouter();
  if (typeof window !== "undefined" && allMarketData.length > 0) {
    router.push(`/trade/${allMarketData[0].name}`);
  }

  // TODO: Better empty message
  return (
    <>
      <Head>
        <title>Trade | Econia</title>
      </Head>
      <div className="flex min-h-screen flex-col">
        <Header logoHref={`${allMarketData[0].name}`} />
        Market not found.
      </div>
    </>
  );
}

export const getStaticProps: GetStaticProps<Props> = async () => {
  // const res = await fetch(new URL("markets", API_URL).href);
  // const marketData: ApiMarket[] = await res.json();
  // TODO: Working API
  const allMarketData = MOCK_MARKETS;
  return {
    props: {
      allMarketData,
    },
  };
};
