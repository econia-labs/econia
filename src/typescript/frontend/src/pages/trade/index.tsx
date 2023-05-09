import { type GetStaticProps } from "next";

import { type ApiMarket } from "@/types/api";
import { API_URL } from "@/env";
import { useRouter } from "next/router";
import { Page } from "@/components/Page";

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
  console.log(API_URL);
  const res = await fetch(new URL("markets", API_URL).href);
  const marketData: ApiMarket[] = await res.json();
  return {
    props: {
      marketData,
    },
  };
};
