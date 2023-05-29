import {
  useWallet,
  type WalletContextState,
} from "@manahippo/aptos-wallet-adapter";
import {
  CoinListClient,
  PERMISSIONED_LIST,
  type NetworkType,
  DEFAULT_TESTNET_LIST,
} from "@manahippo/coin-list";
import { AptosClient, type Types } from "aptos";
import {
  createContext,
  type PropsWithChildren,
  useCallback,
  useContext,
  useMemo,
} from "react";
import { toast } from "react-toastify";

import { NETWORK, RPC_NODE_URL } from "@/env";
import { ECONIA_MAINNET_TOKEN_LIST } from "@/constants";

export type AptosContextState = {
  aptosClient: AptosClient;
  signAndSubmitTransaction: WalletContextState["signAndSubmitTransaction"];
  account: WalletContextState["account"];
  coinListClient: CoinListClient;
};

export const AptosContext = createContext<AptosContextState | undefined>(
  undefined
);

// Type guard for EntryFunctionPayload
const isEntryFunctionPayload = (
  transaction: Types.TransactionPayload
): transaction is Types.TransactionPayload_EntryFunctionPayload => {
  return transaction.type === "entry_function_payload";
};

export function AptosContextProvider({ children }: PropsWithChildren) {
  const { signAndSubmitTransaction: hippoSignAndSubmitTransaction, account } =
    useWallet();
  const aptosClient = useMemo(() => new AptosClient(RPC_NODE_URL), []);
  const signAndSubmitTransaction = useCallback(
    async (
      ...args: Parameters<WalletContextState["signAndSubmitTransaction"]>
    ) => {
      let transaction = args[0];
      const options = args[1];
      if (isEntryFunctionPayload(transaction)) {
        transaction = {
          ...transaction,
          arguments: transaction.arguments.map((arg) => {
            if (typeof arg === "bigint") {
              return arg.toString();
            }
            return arg;
          }),
        };
      }
      const res = await hippoSignAndSubmitTransaction(transaction, options);
      await aptosClient.waitForTransaction(res.hash, { checkSuccess: true });
      toast.success("Transaction confirmed");
      return res;
    },
    [hippoSignAndSubmitTransaction, aptosClient]
  );
  const coinListClient = useMemo(() => {
    const list =
      NETWORK === "mainnet" ? PERMISSIONED_LIST : DEFAULT_TESTNET_LIST;

    return new CoinListClient(
      true,
      (NETWORK as NetworkType) || "testnet",
      list.concat(
        NETWORK === "mainnet"
          ? ECONIA_MAINNET_TOKEN_LIST
          : ECONIA_MAINNET_TOKEN_LIST
      )
    );
  }, []);

  const value: AptosContextState = {
    aptosClient,
    account,
    signAndSubmitTransaction,
    coinListClient,
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
