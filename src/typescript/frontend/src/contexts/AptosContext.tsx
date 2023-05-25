import { AptosClient } from "aptos";
import {
  createContext,
  type PropsWithChildren,
  useContext,
  useMemo,
  useCallback,
} from "react";

import { RPC_NODE_URL } from "@/env";
import { WalletContextState, useWallet } from "@manahippo/aptos-wallet-adapter";
import { toast } from "react-toastify";

export type AptosContextState = {
  aptosClient: AptosClient;
  signAndSubmitTransaction: WalletContextState["signAndSubmitTransaction"];
  account: WalletContextState["account"];
};

export const AptosContext = createContext<AptosContextState | undefined>(
  undefined
);

export function AptosContextProvider({ children }: PropsWithChildren) {
  const { signAndSubmitTransaction: hippoSignAndSubmitTransaction, account } =
    useWallet();
  const aptosClient = useMemo(() => new AptosClient(RPC_NODE_URL), []);
  const signAndSubmitTransaction = useCallback(
    async (
      ...args: Parameters<WalletContextState["signAndSubmitTransaction"]>
    ) => {
      const res = await hippoSignAndSubmitTransaction(...args);
      await aptosClient.waitForTransaction(res.hash, { checkSuccess: true });
      toast.success("Transaction confirmed");
      return res;
    },
    [hippoSignAndSubmitTransaction, aptosClient]
  );
  const value: AptosContextState = {
    aptosClient,
    account,
    signAndSubmitTransaction,
  };

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
