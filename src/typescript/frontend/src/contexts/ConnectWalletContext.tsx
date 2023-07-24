import { useWallet, WalletReadyState } from "@aptos-labs/wallet-adapter-react";
import Image from "next/image";
import {
  createContext,
  type PropsWithChildren,
  useContext,
  useState,
} from "react";
import { toast } from "react-toastify";

import { BaseModal } from "@/components/BaseModal";
import { ArrowIcon } from "@/components/icons/ArrowIcon";

export type ConnectWalletContextState = {
  connectWallet: () => void;
};

export const ConnectWalletContext = createContext<
  ConnectWalletContextState | undefined
>(undefined);

export function ConnectWalletContextProvider({ children }: PropsWithChildren) {
  const { connect, wallets } = useWallet();
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
              key={wallet.name}
              className="relative flex w-full cursor-pointer items-center border border-neutral-600 p-4 transition-all hover:border-blue [&:hover>.arrow-wrapper]:border-blue [&:hover>.arrow-wrapper]:bg-blue [&:hover>div>.arrow]:rotate-[-45deg]"
              onClick={() => {
                try {
                  connect(wallet.name);
                } catch (e) {
                  if (e instanceof Error) {
                    toast.error(e.message);
                  }
                } finally {
                  setOpen(false);
                }
              }}
            >
              <Image
                src={wallet.icon}
                height={36}
                width={36}
                alt={`${wallet.name} Icon`}
              />
              <p className="ml-4 font-jost text-lg font-medium text-neutral-500">
                {wallet.readyState === WalletReadyState.NotDetected
                  ? `Install ${wallet.name} Wallet`
                  : `${wallet.name} Wallet`}
              </p>
              <div
                className={
                  "arrow-wrapper absolute bottom-[-1px] right-[-1px] border border-neutral-600 p-[7px] transition-all"
                }
              >
                <ArrowIcon className="arrow transition-all" />
              </div>
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
      "useAccountContext must be used within a AccountContextProvider.",
    );
  }
  return context;
};
