import Head from "next/head";
import type { PropsWithChildren } from "react";
import React from "react";

import { Header } from "./Header";

export const Page: React.FC<PropsWithChildren<{ title?: string }>> = ({
  title,
  children,
}) => {
  return (
    <>
      <Head>
        <title>{title ?? "Econia"}</title>
      </Head>
      <div className="flex min-h-screen w-full flex-col bg-black font-roboto-mono">
        <Header />
        {children}
      </div>
    </>
  );
};
