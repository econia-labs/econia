import { useQueries, useQueryClient } from "@tanstack/react-query";
import { AptosClient } from "aptos";
import { type GetStaticProps } from "next";
import Head from "next/head";
import { useCallback, useEffect, useState } from "react";
import { toast } from "react-toastify";

import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { Header } from "@/components/Header";
import { useAptos } from "@/contexts/AptosContext";
import { FAUCET_ADDR, RPC_NODE_URL } from "@/env";
import { type CoinStore } from "@/hooks/useCoinBalance";
import { type CoinInfo } from "@/hooks/useCoinInfo";
import { MOCK_MARKETS } from "@/mockdata/markets";
import { type ApiMarket } from "@/types/api";
import { fromRawCoinAmount } from "@/utils/coin";
import { TypeTag } from "@/utils/TypeTag";

const TYPE_TAGS = [
  new TypeTag(FAUCET_ADDR, "test_eth", "TestETHCoin"),
  new TypeTag(FAUCET_ADDR, "test_usdc", "TestUSDCoin"),
] as const;
const AMOUNTS = [0.1, 1000];

export default function Faucet({
  allMarketData,
  coinInfoList,
}: {
  allMarketData: ApiMarket[];
  coinInfoList: CoinInfo[];
}) {
  const { account, aptosClient, signAndSubmitTransaction } = useAptos();
  const queryClient = useQueryClient();
  const [isLoadingArray, setIsLoadingArray] = useState<boolean[]>(
    TYPE_TAGS.map((_) => false),
  );

  const balanceQueries = useQueries({
    queries: coinInfoList.map((coinInfo, i) => ({
      queryKey: ["balance", account?.address, coinInfo.name],
      queryFn: async () => {
        if (account?.address == null) {
          throw new Error("Query should not be enabled.");
        }
        const resource = await aptosClient.getAccountResource(
          account.address,
          `0x1::coin::CoinStore<${TYPE_TAGS[i].toString()}>`,
        );
        const coinStore = resource.data as CoinStore;
        return fromRawCoinAmount(coinStore.coin.value, coinInfo.decimals);
      },
      enabled: account?.address != null && TYPE_TAGS[i] != null,
    })),
  });

  useEffect(() => {
    queryClient.invalidateQueries(["balance", account?.address]);
  }, [account?.address, queryClient]);

  const mintCoin = useCallback(
    async (typeTag: TypeTag, i: number) => {
      setIsLoadingArray((isLoadingArray) => [
        ...isLoadingArray.slice(0, i),
        true,
        ...isLoadingArray.slice(i + 1),
      ]);
      try {
        await signAndSubmitTransaction({
          type: "entry_function_payload",
          function: `${FAUCET_ADDR}::test_coin::mint`,
          type_arguments: [typeTag.toString()],
          arguments: [Math.floor(AMOUNTS[i] * 10 ** coinInfoList[i].decimals)],
        });
        await queryClient.invalidateQueries([
          "balance",
          coinInfoList[i].name,
          account?.address,
        ]);
      } catch (e) {
        if (e instanceof Error) {
          toast.error(e.message);
        } else {
          console.error(e);
        }
      } finally {
        setIsLoadingArray((isLoadingArray) => [
          ...isLoadingArray.slice(0, i),
          false,
          ...isLoadingArray.slice(i + 1),
        ]);
      }
    },
    [account?.address, coinInfoList, queryClient, signAndSubmitTransaction],
  );

  return (
    <>
      <Head>
        <title>Faucet | Econia</title>
      </Head>
      <div className="flex h-screen flex-col">
        <Header logoHref={`/trade/${allMarketData[0].name}`} />
        <main className="flex h-full w-full">
          <div className="m-auto flex flex-wrap justify-center gap-8">
            {TYPE_TAGS.map((typeTag, i) => (
              <div
                className="mx-3 flex h-60 w-96 flex-col items-center justify-center border border-neutral-600 p-8"
                key={i}
              >
                <h2 className="font-jost text-6xl font-bold text-white">
                  {coinInfoList[i].symbol}
                </h2>
                <p className="mt-2 font-roboto-mono text-gray-400">
                  Balance: {balanceQueries[i].data ?? "-"}{" "}
                  {coinInfoList[i].symbol}
                </p>
                <ConnectedButton className="mt-5 w-full">
                  <Button
                    variant="primary"
                    className="mt-5 w-full"
                    onClick={async () => await mintCoin(typeTag, i)}
                    disabled={isLoadingArray[i]}
                  >
                    {isLoadingArray[i]
                      ? "Loading..."
                      : `Get ${coinInfoList[i].symbol}`}
                  </Button>
                </ConnectedButton>
              </div>
            ))}
          </div>
        </main>
      </div>
    </>
  );
}

export const getStaticProps: GetStaticProps = async () => {
  const aptosClient = new AptosClient(RPC_NODE_URL);

  const coinInfoList = await Promise.all(
    TYPE_TAGS.map(async (typeTag) => {
      const res = await aptosClient.getAccountResource(
        typeTag.addr,
        `0x1::coin::CoinInfo<${typeTag.toString()}>`,
      );
      return res.data as CoinInfo;
    }),
  );

  const allMarketData = MOCK_MARKETS;

  return {
    props: {
      allMarketData,
      coinInfoList,
    },
    revalidate: 600, // 10 minutes
  };
};
