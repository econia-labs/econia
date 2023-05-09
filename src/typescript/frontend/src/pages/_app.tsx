import "@/styles/globals.css";

import type { AppProps } from "next/app";
import { Jost, Roboto_Mono } from "next/font/google";

const jost = Jost({
  subsets: ["latin"],
  variable: "--font-jost",
});

const robotoMono = Roboto_Mono({
  subsets: ["latin"],
  variable: "--font-roboto-mono",
});

export default function App({ Component, pageProps }: AppProps) {
  return (
    <div className={`${jost.variable} ${robotoMono.variable}`}>
      <Component {...pageProps} />
    </div>
  );
}
