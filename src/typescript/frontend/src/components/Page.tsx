import type { PropsWithChildren } from "react";
import React from "react";

import { Header } from "./Header";

export const Page: React.FC<PropsWithChildren> = ({ children }) => {
  return (
    <div className="flex min-h-screen w-full flex-col bg-black">
      <Header />
      {children}
    </div>
  );
};
