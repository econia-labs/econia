import { type GetStaticProps } from "next";
import Head from "next/head";
import { useState } from "react";

import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { Header } from "@/components/Header";
import { SyncIcon } from "@/components/icons/SyncIcon";
import { Input } from "@/components/Input";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { type ApiMarket } from "@/types/api";

type Props = {
  allMarketData: ApiMarket[];
};

export default function Swap({ allMarketData }: Props) {
  const [inputAmount, setInputAmount] = useState<string>("");
  const [outputAmount, setOutputAmount] = useState<string>("");
  return (
    <>
      <Head>
        <title>Swap | Econia</title>
      </Head>
      <div className="flex h-screen w-full flex-col font-roboto-mono">
        <Header logoHref={`/trade/${allMarketData[0].name}`} />
        <div className="flex flex-col items-center">
          <div className="mt-8 w-1/4">
            <div className="border p-3 text-center font-roboto-mono text-xs text-gray-300">
              This is a testnet interface. All coins are used for testing
              purposes and have no real value. If you are connecting a wallet,
              make sure it is connected to Aptos testnet.
            </div>
            <div className="mt-8 flex flex-col items-center gap-4 border p-8 text-center text-sm text-white">
              <Input
                startAdornment="INPUT"
                value={inputAmount}
                onChange={setInputAmount}
                placeholder="0.0000"
                type="number"
              />
              <div className="[&>svg>path]:hover:fill-purple-700 cursor-pointer">
                <SyncIcon className="fill-current" />
              </div>
              <Input
                startAdornment="OUTPUT"
                value={outputAmount}
                onChange={setOutputAmount}
                placeholder="0.0000"
                type="number"
              />
              <div className="mt-4 flex w-full flex-col gap-1 font-roboto-mono">
                <div className="flex w-full justify-between">
                  <p>Balance</p>
                  <p>0.0 tUSDC</p>
                </div>
                <div className="flex w-full justify-between">
                  <p>Est. Price</p>
                  <p>- tUSDC</p>
                </div>
                <div className="flex w-full justify-between">
                  <p>Est. Fill</p>
                  <p>- tETH</p>
                </div>
              </div>
              <ConnectedButton className="mt-4 w-full">
                <Button variant="primary" className="mt-4 w-full">
                  Enter an amount
                </Button>
              </ConnectedButton>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export const getStaticProps: GetStaticProps<Props> = async () => {
  // const allMarketData: ApiMarket[] = await fetch(
  //   new URL("markets", API_URL).href
  // ).then((res) => res.json());
  // TODO
  const allMarketData = MOCK_MARKETS;

  return {
    props: {
      allMarketData,
    },
    revalidate: 600, // 10 minutes
  };
};
