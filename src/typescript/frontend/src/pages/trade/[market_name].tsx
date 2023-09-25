import { useQuery, useQueryClient } from "@tanstack/react-query";
import { type MaybeHexString } from "aptos";
import type { GetStaticPaths, GetStaticProps } from "next";
import dynamic from "next/dynamic";
import Head from "next/head";
import Script from "next/script";
import { useEffect, useMemo, useRef, useState } from "react";
import { toast } from "react-toastify";

import { DepthChart } from "@/components/DepthChart";
import { Header } from "@/components/Header";
import { DepositWithdrawFlowModal } from "@/components/modals/flows/DepositWithdrawFlowModal";
import { WalletButtonFlowModal } from "@/components/modals/flows/WalletButtonFlowModal";
import { OrderbookTable } from "@/components/OrderbookTable";
import { StatsBar } from "@/components/StatsBar";
import { OrderEntry } from "@/components/trade/OrderEntry";
import { OrdersTable } from "@/components/trade/OrdersTable";
import { TradeHistoryTable } from "@/components/trade/TradeHistoryTable";
import { useAptos } from "@/contexts/AptosContext";
import { OrderEntryContextProvider } from "@/contexts/OrderEntryContext";
import { API_URL, WS_URL } from "@/env";
import { MOCK_MARKETS } from "@/mockdata/markets";
import type { ApiMarket, ApiOrder, ApiPriceLevel } from "@/types/api";
import { type Orderbook } from "@/types/global";

import {
  type ResolutionString,
  type ThemeName,
} from "../../../public/static/charting_library";

const ORDERBOOK_DEPTH = 60;

const TVChartContainer = dynamic(
  () =>
    import("@/components/trade/TVChartContainer").then(
      (mod) => mod.TVChartContainer,
    ),
  { ssr: false },
);

type Props = {
  marketData: ApiMarket | undefined;
  allMarketData: ApiMarket[];
};

type PathParams = {
  market_name: string;
};

export default function Market({ allMarketData, marketData }: Props) {
  const { account } = useAptos();
  const queryClient = useQueryClient();
  const ws = useRef<WebSocket | undefined>(undefined);
  const prevAddress = useRef<MaybeHexString | undefined>(undefined);

  const [depositWithdrawModalOpen, setDepositWithdrawModalOpen] =
    useState<boolean>(false);
  const [walletButtonModalOpen, setWalletButtonModalOpen] =
    useState<boolean>(false);

  const [isScriptReady, setIsScriptReady] = useState(false);

  // Set up WebSocket API connection
  useEffect(() => {
    ws.current = new WebSocket(WS_URL);
    ws.current.onopen = () => {
      // because useEffects can fire more than once and onopen is an async function, we still want to check readystate when we send a message
      if (
        marketData?.market_id == null ||
        ws.current == null ||
        ws.current.readyState !== WebSocket.OPEN
      ) {
        return;
      }

      // Subscribe to orderbook price level updates
      ws.current.send(
        JSON.stringify({
          method: "subscribe",
          channel: "price_levels",
          params: {
            market_id: marketData.market_id,
          },
        }),
      );
    };

    // Close WebSocket connection on page close
    return () => {
      if (ws.current != null) {
        ws.current.close();
      }
    };
  }, [marketData?.market_id]);

  // Handle wallet connect and disconnect
  useEffect(() => {
    if (
      marketData?.market_id == null ||
      ws.current == null ||
      ws.current.readyState !== WebSocket.OPEN
    ) {
      return;
    }
    if (account?.address != null) {
      //  commenting this out because it doesn't seem to be doing what it's supposed to
      //  maybe if we made it synchronous it would work?

      // If the WebSocket connection is not ready,
      // wait for the WebSocket connection to be opened.
      // if (ws.current.readyState === WebSocket.CONNECTING) {
      //   const interval = setInterval(() => {
      //     if (ws.current?.readyState === WebSocket.OPEN) {
      //       clearInterval(interval);
      //     }
      //   }, 500);
      // }

      // Subscribe to orders by account channel
      ws.current.send(
        JSON.stringify({
          method: "subscribe",
          channel: "orders",
          params: {
            market_id: marketData.market_id,
            user_address: account.address,
          },
        }),
      );

      // Subscribe to fills by account channel
      ws.current.send(
        JSON.stringify({
          method: "subscribe",
          channel: "fills",
          params: {
            market_id: marketData.market_id,
            user_address: account.address,
          },
        }),
      );

      // Store address for unsubscribing when wallet is disconnected.
      prevAddress.current = account.address;
    } else {
      if (prevAddress.current != null) {
        // Unsubscribe to orders by account channel
        ws.current.send(
          JSON.stringify({
            method: "unsubscribe",
            channel: "orders",
            params: {
              market_id: marketData.market_id,
              user_address: prevAddress.current,
            },
          }),
        );

        // Unsubscribe to fills by account channel
        ws.current.send(
          JSON.stringify({
            method: "unsubscribe",
            channel: "fills",
            params: {
              market_id: marketData.market_id,
              user_address: prevAddress.current,
            },
          }),
        );

        // Clear saved address
        prevAddress.current = undefined;
      }
    }
  }, [marketData?.market_id, account?.address]);

  // Handle incoming WebSocket messages
  useEffect(() => {
    if (marketData?.market_id == null || ws.current == null) {
      return;
    }

    ws.current.onmessage = (message) => {
      const msg = JSON.parse(message.data);

      if (msg.event === "update") {
        if (msg.channel === "orders") {
          const { order_state, market_order_id }: ApiOrder = msg.data;
          switch (order_state) {
            // TODO further discuss what toast text should be
            case "open":
              toast.success(
                `Order with order ID ${market_order_id} placed successfully.`,
              );
              break;
            case "filled":
              toast.success(`Order with order ID ${market_order_id} filled.`);
              break;
            case "cancelled":
              toast.warn(`Order with order ID ${market_order_id} cancelled.`);
              break;
            case "evicted":
              toast.warn(`Order with order ID ${market_order_id} evicted.`);
              break;
          }
        } else if (msg.channel === "price_levels") {
          const priceLevel: ApiPriceLevel = msg.data;
          queryClient.setQueriesData(
            ["orderbook", marketData.market_id],
            (prevData: Orderbook | undefined) => {
              if (prevData == null) {
                return undefined;
              }
              if (priceLevel.side === "buy") {
                for (const [i, lvl] of prevData.bids.entries()) {
                  if (priceLevel.price === lvl.price) {
                    return {
                      bids: [
                        ...prevData.bids.slice(0, i),
                        { price: priceLevel.price, size: priceLevel.size },
                        ...prevData.bids.slice(i + 1),
                      ],
                      asks: prevData.asks,
                      updatedLevel: { ...priceLevel },
                    };
                  } else if (priceLevel.price > lvl.price) {
                    return {
                      bids: [
                        ...prevData.bids.slice(0, i),
                        { price: priceLevel.price, size: priceLevel.size },
                        ...prevData.bids.slice(i),
                      ],
                      asks: prevData.asks,
                      updatedLevel: { ...priceLevel },
                    };
                  }
                }
                return {
                  bids: [
                    ...prevData.bids,
                    { price: priceLevel.price, size: priceLevel.size },
                  ],
                  asks: prevData.asks,
                  updatedLevel: { ...priceLevel },
                };
              } else {
                for (const [i, lvl] of prevData.asks.entries()) {
                  if (priceLevel.price === lvl.price) {
                    return {
                      bids: prevData.bids,
                      asks: [
                        ...prevData.asks.slice(0, i),
                        { price: priceLevel.price, size: priceLevel.size },
                        ...prevData.asks.slice(i + 1),
                      ],
                      updatedLevel: { ...priceLevel },
                    };
                  } else if (priceLevel.price < lvl.price) {
                    return {
                      bids: prevData.bids,
                      asks: [
                        ...prevData.asks.slice(0, i),
                        { price: priceLevel.price, size: priceLevel.size },
                        ...prevData.asks.slice(i),
                      ],
                      updatedLevel: { ...priceLevel },
                    };
                  }
                }
                return {
                  bids: prevData.bids,
                  asks: [
                    ...prevData.asks,
                    { price: priceLevel.price, size: priceLevel.size },
                  ],
                  updatedLevel: { ...priceLevel },
                };
              }
            },
          );
        } else {
          // TODO
        }
      } else {
        // TODO
      }
    };
  }, [marketData, account?.address, queryClient]);

  // TODO update to include precision when backend is updated (ECO-199)
  const {
    data: orderbookData,
    isFetching: orderbookIsFetching,
    isLoading: orderbookIsLoading,
  } = useQuery(
    ["orderbook", marketData?.market_id],
    async () => {
      const res = await fetch(
        `${API_URL}/markets/${marketData?.market_id}/orderbook?depth=${ORDERBOOK_DEPTH}`,
      );
      const data: Orderbook = await res.json();
      return data;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false },
  );

  const defaultTVChartProps = useMemo(() => {
    return {
      symbol: marketData?.name ?? "",
      interval: "1" as ResolutionString,
      datafeedUrl: "https://dev.api.econia.exchange",
      libraryPath: "/static/charting_library/",
      clientId: "econia.exchange",
      userId: "public_user_id",
      fullscreen: false,
      autosize: true,
      studiesOverrides: {},
      theme: "Dark" as ThemeName,
      // antipattern if we render market not found? need ! for typescript purposes
      selectedMarket: marketData!,
      allMarketData,
    };
  }, [marketData, allMarketData]);

  if (!marketData)
    return (
      <>
        <Head>
          <title>Not Found</title>
        </Head>
        <div className="flex min-h-screen flex-col">
          <Header logoHref={`${allMarketData[0].name}`} />
          Market not found.
        </div>
      </>
    );

  return (
    <OrderEntryContextProvider>
      <Head>
        <title>{`${marketData.name} | Econia`}</title>
      </Head>
      <div className="flex min-h-screen flex-col">
        <Header
          logoHref={`${allMarketData[0].name}`}
          onDepositWithdrawClick={() => setDepositWithdrawModalOpen(true)}
          onWalletButtonClick={() => setWalletButtonModalOpen(true)}
        />
        <StatsBar allMarketData={allMarketData} selectedMarket={marketData} />
        <main className="flex h-full min-h-[680px] w-full grow">
          <div className="flex grow flex-col p-3">
            <div className="mb-3 flex grow flex-col border border-neutral-600">
              <div className="flex h-full">
                {isScriptReady && <TVChartContainer {...defaultTVChartProps} />}
              </div>

              <div className="hidden h-[140px] tall:block">
                <DepthChart marketData={marketData} />
              </div>
            </div>
            <div className="border border-neutral-600">
              <div className="bg-transparent py-3 pl-4">
                <p className="font-jost font-bold text-white">Orders</p>
              </div>

              <OrdersTable allMarketData={allMarketData} />
            </div>
          </div>
          <div className="flex min-w-[268px] py-3 pr-3">
            <div className="flex w-full flex-col border border-neutral-600">
              <OrderbookTable
                marketData={marketData}
                data={orderbookData}
                isFetching={orderbookIsFetching}
                isLoading={orderbookIsLoading}
              />
            </div>
          </div>
          <div className="flex min-w-[296px] max-w-[296px] flex-col py-3 pr-3">
            <div className="border border-neutral-600">
              <OrderEntry marketData={marketData} />
            </div>
            <div className="mt-3 h-full min-h-[160px] border border-neutral-600">
              <p className="my-3 ml-4 font-jost font-bold text-white">
                Trade History
              </p>
              <TradeHistoryTable marketData={marketData} />
            </div>
          </div>
        </main>
      </div>
      {/* temp */}
      <DepositWithdrawFlowModal
        selectedMarket={marketData}
        isOpen={depositWithdrawModalOpen}
        onClose={() => {
          setDepositWithdrawModalOpen(false);
        }}
        allMarketData={allMarketData}
      />
      <WalletButtonFlowModal
        selectedMarket={marketData}
        isOpen={walletButtonModalOpen}
        onClose={() => {
          setWalletButtonModalOpen(false);
        }}
        allMarketData={allMarketData}
      />
      <Script
        src="/static/datafeeds/udf/dist/bundle.js"
        strategy="lazyOnload"
        onReady={() => {
          setIsScriptReady(true);
        }}
      />
    </OrderEntryContextProvider>
  );
}

export const getStaticPaths: GetStaticPaths<PathParams> = async () => {
  // const res = await fetch(new URL("markets", API_URL).href);
  // const allMarketData: ApiMarket[] = await res.json();
  // TODO: Working API
  const allMarketData = MOCK_MARKETS;
  const paths = allMarketData.map((market) => ({
    params: { market_name: market.name },
  }));
  return { paths, fallback: false };
};

export const getStaticProps: GetStaticProps<Props, PathParams> = async ({
  params,
}) => {
  if (!params) throw new Error("No params");
  // const allMarketData: ApiMarket[] = await fetch(
  //   new URL("markets", API_URL).href
  // ).then((res) => res.json());
  // TODO: Working API
  const allMarketData = MOCK_MARKETS;
  const marketData = allMarketData.find(
    (market) => market.name === params.market_name,
  );

  return {
    props: {
      marketData,
      allMarketData,
    },
    revalidate: 600, // 10 minutes
  };
};
