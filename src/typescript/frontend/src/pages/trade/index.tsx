import { type GetStaticProps } from "next";
import { useRouter } from "next/router";

import { Page } from "@/components/Page";
import { API_URL } from "@/env";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { type ApiMarket } from "@/types/api";

type Props = {
  marketData: ApiMarket[];
};

export default function Trade({ marketData }: Props) {
  const router = useRouter();
  if (typeof window !== "undefined" && marketData.length > 0) {
    router.push(`/trade/${marketData[0].name}`);
  }

  // TODO: Better empty message
  return (
    <Page>
      <div>No markets found.</div>
    </Page>
  );
}

export const getStaticProps: GetStaticProps<Props> = async () => {
  // const res = await fetch(new URL("markets", API_URL).href);
  // const marketData: ApiMarket[] = await res.json();
  // TODO: Working API
  const marketData = MOCK_MARKETS;
  return {
    props: {
      marketData,
    },
  };
};
