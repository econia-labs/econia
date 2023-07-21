import { useQueryClient } from "@tanstack/react-query";
import { type GetStaticProps } from "next";
import React, { useCallback, useState } from "react";

import { Button } from "@/components/Button";
import { ConnectedButton } from "@/components/ConnectedButton";
import { Page } from "@/components/Page";
import { useAptos } from "@/contexts/AptosContext";
import { CoinBalanceQueryKey, useCoinBalance } from "@/hooks/useCoinBalance";
import { useCoinInfo } from "@/hooks/useCoinInfo";
import { type ApiMarket } from "@/types/api";
import { TypeTag } from "@/utils/TypeTag";

const FAUCET_ADDR =
  "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942";

const FaucetCard: React.FC<{ coinTypeTag: TypeTag; amount: number }> = ({
  coinTypeTag,
  amount,
}) => {
  const coinInfo = useCoinInfo(coinTypeTag);
  const queryClient = useQueryClient();
  const { account, signAndSubmitTransaction } = useAptos();
  const coinBalance = useCoinBalance(coinTypeTag, account?.address);
  const [loading, setLoading] = useState(false);
  const faucetFunds = useCallback(async () => {
    if (!account || !coinInfo.data) return;
    await signAndSubmitTransaction({
      type: "entry_function_payload",
      function: `${FAUCET_ADDR}::test_coin::mint`,
      type_arguments: [coinTypeTag.toString()],
      arguments: [Math.floor(amount * 10 ** coinInfo.data.decimals)],
    });
  }, [account, signAndSubmitTransaction]);

  return (
    <div className="m-3 flex h-60 w-96 flex-col items-center  justify-center border border-neutral-600 p-8">
      <h1 className="font-jost text-6xl font-bold text-white">
        {coinInfo.data?.symbol}
      </h1>
      <p className="mt-2 font-roboto-mono uppercase text-gray-400">
        Balance: {coinBalance.data || "-"} {coinInfo.data?.symbol}
      </p>
      <ConnectedButton className="mt-5 w-full">
        <Button
          variant="primary"
          className="mt-4 w-full"
          onClick={async () => {
            setLoading(true);
            try {
              await faucetFunds();
              await queryClient.invalidateQueries(
                CoinBalanceQueryKey(coinTypeTag, account?.address),
              );
            } catch (e) {
              console.log(e);
            } finally {
              setLoading(false);
            }
          }}
          disabled={loading}
        >
          {loading ? "Loading..." : `Get ${coinInfo.data?.symbol}`}
        </Button>
      </ConnectedButton>
    </div>
  );
};

export default function Faucet({ marketData: _ }: { marketData: ApiMarket[] }) {
  return (
    <Page>
      <main className="flex h-full items-center justify-center gap-8">
        <FaucetCard
          coinTypeTag={TypeTag.fromString(
            "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_eth::TestETHCoin",
          )}
          amount={0.1}
        />
        <FaucetCard
          coinTypeTag={TypeTag.fromString(
            "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_usdc::TestUSDCoin",
          )}
          amount={1000}
        />
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
