import { useWallet } from "@manahippo/aptos-wallet-adapter";
import Image from "next/image";
import {
  createContext,
  type PropsWithChildren,
  useContext,
  useState,
} from "react";

import { BaseModal } from "@/components/BaseModal";
import { RightArrowIcon } from "@/components/icons/RightArrowIcon";

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
        <div className="mt-4">
          {wallets.map((wallet) => (
            <button
              key={wallet.adapter.name}
              className="relative mt-4 flex w-full items-center border border-neutral-500 p-4 text-neutral-500 hover:border-blue hover:text-blue [&>*>.arrow-icon]:hover:-rotate-45 [&>*>.arrow-icon]:hover:text-white [&>*>.button-text]:hover:text-blue [&>.arrow-wrapper]:hover:border-blue  [&>.arrow-wrapper]:hover:bg-blue"
              onClick={() => {
                select(wallet.adapter.name);
                setOpen(false);
              }}
            >
              <div className="flex items-center">
                <Image
                  src={wallet.adapter.icon}
                  alt={`${wallet.adapter.name} Icon`}
                  height={36}
                  width={36}
                />
                <p className="button-text ml-3 font-jost text-lg font-medium text-white">
                  {`${wallet.adapter.name} Wallet`}
                </p>
              </div>
              <div className="arrow-wrapper absolute bottom-0 right-0 mb-0 mt-auto flex h-10 w-10 flex-col border-l-2 border-t-2 border-neutral-500 p-0.5">
                <RightArrowIcon className="arrow-icon m-auto h-7 w-7 text-neutral-500 transition-all duration-150" />
              </div>
            </button>
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
