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
      <div className="flex h-screen min-h-screen w-full flex-col font-roboto-mono">
        <Header logoHref="/" />
        {children}
      </div>
    </>
  );
};
