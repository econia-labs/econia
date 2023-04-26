import "@/styles/globals.css";

import {
  AptosWalletAdapter,
  PontemWalletAdapter,
  WalletProvider,
} from "@manahippo/aptos-wallet-adapter";
import type { AppProps } from "next/app";
import { Jost, Roboto_Mono } from "next/font/google";
import { useMemo } from "react";

import { AptosContextProvider } from "@/contexts/AptosContext";

const jost = Jost({
  subsets: ["latin"],
  variable: "--font-jost",
});

const robotoMono = Roboto_Mono({
  subsets: ["latin"],
  variable: "--font-roboto-mono",
});

export default function App({ Component, pageProps }: AppProps) {
  const wallets = useMemo(
    () => [new AptosWalletAdapter(), new PontemWalletAdapter()],
    []
  );
  return (
    <WalletProvider wallets={wallets}>
      <AptosContextProvider>
        <div className={`${jost.variable} ${robotoMono.variable}`}>
          <Component {...pageProps} />
        </div>
      </AptosContextProvider>
    </WalletProvider>
  );
}
