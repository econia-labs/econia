import { Jost } from "next/font/google";
import Image from "next/image";
import React, { type PropsWithChildren } from "react";

const jost = Jost({ subsets: ["latin"] });

export const Layout: React.FC<PropsWithChildren> = ({ children }) => {
  return (
    <div className={`h-screen bg-black ${jost.className}`}>{children}</div>
  );
};
