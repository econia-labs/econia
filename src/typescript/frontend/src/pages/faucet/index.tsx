import { type GetStaticProps } from "next";
import React from "react";

import { Button } from "@/components/Button";
import { Page } from "@/components/Page";
import { type ApiMarket } from "@/types/api";
import { ConnectedButton } from "@/components/ConnectedButton";

const FaucetCard: React.FC<{ symbol: string }> = ({ symbol }) => {
  return (
    <div className="flex h-48 w-96 flex-col items-center justify-center border p-8">
      <h1 className="font-jost text-xl font-bold text-white">{symbol}</h1>
      <p className="font-jost text-gray-400">Balance: -- {symbol}</p>
      <ConnectedButton className="mt-4 w-full">
        <Button variant="primary" className="mt-4 w-full">
          Get {symbol}
        </Button>
      </ConnectedButton>
    </div>
  );
};

export default function Faucet({ marketData: _ }: { marketData: ApiMarket[] }) {
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
