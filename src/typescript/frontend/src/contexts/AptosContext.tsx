import { AptosClient } from "aptos";
import { createContext, type PropsWithChildren, useContext } from "react";

export type AptosContextState = {
  aptosClient: AptosClient;
};

export const AptosContext = createContext<AptosContextState | undefined>(
  undefined
);

export function AptosContextProvider({ children }: PropsWithChildren) {
  if (process.env.NEXT_PUBLIC_RPC_NODE_URL == null) {
    throw new Error("NEXT_PUBLIC_RPC_NODE_URL not set.");
  }

  const aptosClient = new AptosClient(process.env.NEXT_PUBLIC_RPC_NODE_URL);
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
