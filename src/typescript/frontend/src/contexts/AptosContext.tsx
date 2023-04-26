import { AptosClient } from "aptos";
import { createContext, type PropsWithChildren, useContext } from "react";

export type AptosContextState = {
  aptosClient: AptosClient;
};

export const AptosContext = createContext<AptosContextState | undefined>(
  undefined
);

export function AptosContextProvider({ children }: PropsWithChildren) {
  const { NEXT_PUBLIC_RPC_URL } = process.env;
  if (NEXT_PUBLIC_RPC_URL == null) {
    throw new Error("NEXT_PUBLIC_RPC_URL not set.");
  }

  const aptosClient = new AptosClient(NEXT_PUBLIC_RPC_URL);
  const value: AptosContextState = { aptosClient };

  return (
    <AptosContext.Provider value={value}>{children}</AptosContext.Provider>
  );
}

export const useAptos = (): AptosContextState => {
  const context = useContext(AptosContext);
  if (context == null) {
    throw new Error(
      "useAccountContext must be used within a AccountContextProvider."
    );
  }
  return context;
};
