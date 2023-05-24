import "@/styles/globals.css";

import {
  AptosWalletAdapter,
  PontemWalletAdapter,
  WalletProvider,
} from "@manahippo/aptos-wallet-adapter";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { type AppProps } from "next/app";
import { Jost, Roboto_Mono } from "next/font/google";
import { useMemo } from "react";

import { AptosContextProvider } from "@/contexts/AptosContext";
import { ConnectWalletContextProvider } from "@/contexts/ConnectWalletContext";

const jost = Jost({
  subsets: ["latin"],
  variable: "--font-jost",
});

const robotoMono = Roboto_Mono({
  subsets: ["latin"],
  variable: "--font-roboto-mono",
});

const queryClient = new QueryClient();

export default function App({ Component, pageProps }: AppProps) {
  const wallets = useMemo(
    () => [new AptosWalletAdapter(), new PontemWalletAdapter()],
    []
  );
  return (
    <QueryClientProvider client={queryClient}>
      <WalletProvider wallets={wallets} autoConnect>
        <AptosContextProvider>
          <ConnectWalletContextProvider>
            <style jsx global>{`
              :root {
                --font-jost: ${jost.style.fontFamily};
                --font-roboto-mono: ${robotoMono.style.fontFamily};
              }
            `}</style>
            <div>
              <Component {...pageProps} />
            </div>
          </ConnectWalletContextProvider>
        </AptosContextProvider>
      </WalletProvider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
