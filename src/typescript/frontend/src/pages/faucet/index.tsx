import { type GetStaticProps } from "next";

import { type ApiMarket } from "@/types/api";
import { Page } from "@/components/Page";
import { Button } from "@/components/Button";
import React from "react";

const FaucetCard: React.FC<{ symbol: string }> = ({ symbol }) => {
  return (
    <div className="flex h-48 w-96 flex-col items-center justify-center border p-8">
      <h1 className="font-jost text-xl font-bold text-white">{symbol}</h1>
      <p className="font-jost text-gray-400">Balance: -- {symbol}</p>
      <Button className="mt-4">Get {symbol}</Button>
    </div>
  );
};

export default function Faucet({ marketData }: { marketData: ApiMarket[] }) {
  return (
    <Page>
      <main className="mt-96 flex items-center justify-center gap-8">
        <FaucetCard symbol="tETH" />
        <FaucetCard symbol="tUSDC" />
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
