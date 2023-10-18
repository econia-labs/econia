import "@/styles/globals.css";
import "react-toastify/dist/ReactToastify.css";
import "react-loading-skeleton/dist/skeleton.css";

import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { PontemWallet } from "@pontem/wallet-adapter-plugin";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import {
  CategoryScale,
  Chart,
  Filler,
  Legend,
  LinearScale,
  LineElement,
  PointElement,
  Title,
  Tooltip,
} from "chart.js";
import { type AppProps } from "next/app";
import { Jost, Roboto_Mono } from "next/font/google";
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { useMemo } from "react";
import { SkeletonTheme } from "react-loading-skeleton";
import { ToastContainer } from "react-toastify";

import { AptosContextProvider } from "@/contexts/AptosContext";
import { ConnectWalletContextProvider } from "@/contexts/ConnectWalletContext";

import bg from "../../public/bg.png";

Chart.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend,
);

Chart.defaults.font.family = "Roboto Mono";
Chart.defaults.animation = false;

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
  const wallets = useMemo(() => [new PetraWallet(), new PontemWallet()], []);
  return (
    <SkeletonTheme baseColor="#202020" highlightColor="#444">
      <QueryClientProvider client={queryClient}>
        <AptosWalletAdapterProvider plugins={wallets} autoConnect>
          <AptosContextProvider>
            <ConnectWalletContextProvider>
              <style jsx global>{`
                body {
                  background-color: #020202;
                  background-image: url(${bg.src});
                }
                :root {
                  --font-jost: ${jost.style.fontFamily};
                  --font-roboto-mono: ${robotoMono.style.fontFamily};
                  --toastify-color: #020202;
                  --toastify-color-info: #62c6f8;
                  --toastify-color-success: #6ed5a3;
                  --toastify-color-error: #d56e6e;
                  --toastify-color-warning: #eef081;
                  --toastify-icon-color-info: #62c6f8;
                  --toastify-icon-color-success: #6ed5a3;
                  --toastify-icon-color-error: #d56e6e;
                  --toastify-icon-color-warning: #eef081;
                  --toastify-font-family: ${robotoMono.style.fontFamily};
                  --toastify-color-dark: #020202;
                  --toastify-toast-background: #020202;
                }
                .Toastify__toast {
                  border: 1px solid #565656;
                  border-radius: 0px;
                }
              `}</style>
              <div>
                <Component {...pageProps} />
              </div>
            </ConnectWalletContextProvider>
          </AptosContextProvider>
        </AptosWalletAdapterProvider>
        <ReactQueryDevtools initialIsOpen={false} />
        <ToastContainer theme="dark" />
      </QueryClientProvider>
    </SkeletonTheme>
  );
}
