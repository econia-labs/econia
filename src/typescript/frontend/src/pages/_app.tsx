import "@/styles/globals.css";

import {
  AptosWalletAdapter,
  PontemWalletAdapter,
  WalletProvider,
} from "@manahippo/aptos-wallet-adapter";
import type { AppProps } from "next/app";
import { Jost, Roboto_Mono } from "next/font/google";
import { useMemo } from "react";

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
    <div className={`${jost.variable} ${robotoMono.variable}`}>
      <WalletProvider wallets={wallets}>
        <Component {...pageProps} />
      </WalletProvider>
    </div>
  );
}
