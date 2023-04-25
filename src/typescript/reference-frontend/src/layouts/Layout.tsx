import { type PropsWithChildren } from "react";

import { Header } from "@/components/Header";

export function Layout({ children }: PropsWithChildren) {
  return (
    <div className={`min-h-screen w-full bg-black`}>
      <Header />
      {children}
    </div>
  );
}
