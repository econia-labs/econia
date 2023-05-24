import { useWallet, WalletReadyState } from "@manahippo/aptos-wallet-adapter";
import {
  createContext,
  type PropsWithChildren,
  useContext,
  useState,
} from "react";

import { BaseModal } from "@/components/BaseModal";

export type ConnectWalletContextState = {
  connectWallet: () => void;
};

export const ConnectWalletContext = createContext<
  ConnectWalletContextState | undefined
>(undefined);

export function ConnectWalletContextProvider({ children }: PropsWithChildren) {
  const { select, wallets } = useWallet();
  const [open, setOpen] = useState<boolean>(false);
  const value: ConnectWalletContextState = {
    connectWallet: () => setOpen(true),
  };

  return (
    <ConnectWalletContext.Provider value={value}>
      {children}
      <BaseModal
        open={open}
        onClose={() => setOpen(false)}
        onBack={() => setOpen(false)}
      >
        <h2 className="mt-4 text-center font-jost text-3xl font-bold text-white">
          Connect a Wallet
        </h2>
        <p className="mt-4 text-center font-roboto-mono text-sm font-light text-white">
          In order to use this site you must connect a wallet and allow the site
          to access your account.
        </p>
        <div className="mt-8 flex flex-col gap-4">
          {wallets.map((wallet) => (
            <div
              key={wallet.adapter.name}
              className="flex w-full cursor-pointer items-center gap-2 border border-neutral-600 p-4 font-jost text-lg font-medium text-neutral-500 hover:text-white"
              onClick={() => {
                select(wallet.adapter.name);
                setOpen(false);
              }}
            >
              <img
                src={wallet.adapter.icon}
                height={36}
                width={36}
                className=""
              />
              <p>
                {wallet.readyState === WalletReadyState.NotDetected
                  ? `Install ${wallet.adapter.name} Wallet`
                  : `${wallet.adapter.name} Wallet`}
              </p>
            </div>
          ))}
        </div>
      </BaseModal>
    </ConnectWalletContext.Provider>
  );
}

export const useConnectWallet = (): ConnectWalletContextState => {
  const context = useContext(ConnectWalletContext);
  if (context == null) {
    throw new Error(
      "useAccountContext must be used within a AccountContextProvider."
    );
  }
  return context;
};
