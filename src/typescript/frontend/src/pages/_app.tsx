import "@/styles/globals.css";

import { css, Global, type Theme, ThemeProvider } from "@emotion/react";
import {
  AptosWalletAdapter,
  FewchaWalletAdapter,
  MartianWalletAdapter,
  PontemWalletAdapter,
  RiseWalletAdapter,
  WalletProvider,
} from "@manahippo/aptos-wallet-adapter";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { AppProps } from "next/app";
import { Jost, Roboto_Mono } from "next/font/google";
import ReactModal from "react-modal";

import { AptosContext, AptosContextProvider } from "@/hooks/useAptos";

const jost = Jost({
  subsets: ["latin"],
  variable: "--font-jost",
});

const robotoMono = Roboto_Mono({
  subsets: ["latin"],
  variable: "--font-roboto-mono",
});

const theme: Theme = {
  colors: {
    red: {
      primary: "#D56E6E",
    },
    purple: {
      primary: "#8C3DD8",
    },
    blue: {
      primary: "#62C6F8",
    },
    green: {
      primary: "#6ED5A3",
    },
    yellow: {
      primary: "#EEF081",
    },
    grey: {
      primary: "#DADADA",
      100: "#FFFFFF",
      200: "#F9F9F9",
      300: "#F1F1F1",
      400: "#DADADA",
      500: "#AAAAAA",
      600: "#565656",
      700: "#161616",
      800: "#020202",
    },
  },
};

const WALLETS = [
  new AptosWalletAdapter(),
  new PontemWalletAdapter(),
  new MartianWalletAdapter(),
  new RiseWalletAdapter(),
  new FewchaWalletAdapter(),
];

const queryClient = new QueryClient();

ReactModal.setAppElement("#__next");

export default function App({ Component, pageProps }: AppProps) {
  return (
    <div className={`${jost.variable} ${robotoMono.variable}`}>
      <ThemeProvider theme={theme}>
        <Global styles={GlobalStyles} />
        <QueryClientProvider client={queryClient}>
          <WalletProvider wallets={WALLETS}>
            <AptosContextProvider>
              <Component {...pageProps} />
            </AptosContextProvider>
          </WalletProvider>
        </QueryClientProvider>
      </ThemeProvider>
    </div>
  );
}

const GlobalStyles = (theme: Theme) => css`
  html,
  body {
    min-width: 990px;
  }
  body {
    font-family: Roboto Mono, sans-serif;
    margin: 0;

    font-size: 16px;
    font-weight: 400;
    max-width: 100%;
    min-height: 100vh;
    color: #ffffff;
    #approot {
      overflow-x: hidden;
    }
    background-color: ${theme.colors.grey[800]};
    background-image: url("https://global-uploads.webflow.com/62fce47e1be865a7155ff71c/633467a79910d8300a274060_bg-noise.png");
  }

  a {
    text-decoration: none;
    color: #ffffff;
  }

  h1,
  h2,
  h3,
  h4,
  h5 {
    font-family: Jost, sans-serif;
    margin: 0px;
  }

  h1 {
    font-size: 100px;
    line-height: 110px;
  }

  h2 {
    font-size: 48px;
    line-height: 58px;
  }

  h3 {
    font-size: 36px;
    line-height: 46px;
  }

  h4 {
    font-size: 28px;
    line-height: 38px;
  }

  h5 {
    font-size: 24px;
    line-height: 34px;
  }

  td {
    padding-bottom: 0;
  }

  p {
    margin: 0;
  }

  // Hide arrows
  /* Chrome, Safari, Edge, Opera */
  input::-webkit-outer-spin-button,
  input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  /* Firefox */
  input[type="number"] {
    -moz-appearance: textfield;
  }

  // react-toastify
  :root {
    --toastify-color: ${theme.colors.grey[800]};
    --toastify-color-info: ${theme.colors.blue.primary};
    --toastify-color-success: ${theme.colors.green.primary};
    --toastify-color-error: ${theme.colors.red.primary};
    --toastify-color-warning: ${theme.colors.yellow.primary};

    --toastify-icon-color-info: ${theme.colors.blue.primary};
    --toastify-icon-color-success: ${theme.colors.green.primary};
    --toastify-icon-color-error: ${theme.colors.red.primary};
    --toastify-icon-color-warning: ${theme.colors.yellow.primary};

    --toastify-font-family: Roboto Mono, sans-serif;
    --toastify-color-dark: ${theme.colors.grey[800]};
    --toastify-toast-background: ${theme.colors.grey[800]};
  }
  .Toastify__toast {
    border: 1px solid ${theme.colors.grey[600]};
    border-radius: 0px;
  }
`;
