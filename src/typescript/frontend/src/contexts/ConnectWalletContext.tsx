import {
  createContext,
  type PropsWithChildren,
  useContext,
  Fragment,
  useState,
} from "react";

import { RPC_NODE_URL } from "@/env";
import { Transition, Dialog } from "@headlessui/react";
import { WalletReadyState, useWallet } from "@manahippo/aptos-wallet-adapter";

export type ConnectWalletContextState = {
  connectWallet: () => void;
};

export const ConnectWalletContext = createContext<
  ConnectWalletContextState | undefined
>(undefined);

export function ConnectWalletContextProvider({ children }: PropsWithChildren) {
  const { select, wallets } = useWallet();
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const value: ConnectWalletContextState = {
    connectWallet: () => setIsOpen(true),
  };

  return (
    <ConnectWalletContext.Provider value={value}>
      {children}
      <Transition appear show={isOpen} as={Fragment}>
        <Dialog
          as="div"
          className="relative z-10"
          open={isOpen}
          onClose={() => setIsOpen(false)}
        >
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div className="fixed inset-0 bg-black bg-opacity-60" />
          </Transition.Child>

          <div className="fixed inset-0 overflow-y-auto">
            <div className="flex min-h-full items-center justify-center p-4 text-center">
              <Transition.Child
                as={Fragment}
                enter="ease-out duration-300"
                enterFrom="opacity-0 scale-95"
                enterTo="opacity-100 scale-100"
                leave="ease-in duration-200"
                leaveFrom="opacity-100 scale-100"
                leaveTo="opacity-0 scale-95"
              >
                <Dialog.Panel className="w-full max-w-sm transform border border-neutral-500 bg-black p-6 align-middle shadow-xl transition-all">
                  <Dialog.Title className="" as="div">
                    <p className="text-neutral-400">Connect a Wallet</p>
                  </Dialog.Title>

                  <Dialog.Description
                    className="mx-auto mt-4 w-[180px]"
                    as="ul"
                  >
                    {wallets.map((wallet, i) => (
                      <li key={i} className="mt-2">
                        {wallet.readyState === WalletReadyState.NotDetected ? (
                          <a
                            href={wallet.adapter.url}
                            target="_blank"
                            rel="noreferrer noopener"
                            className="inline-flex w-full border border-neutral-400 px-2 py-1 text-neutral-400 outline-none hover:border-neutral-500 hover:text-neutral-500"
                          >
                            <span className="mx-auto">
                              {wallet.adapter.name}
                            </span>
                          </a>
                        ) : (
                          <button
                            className="w-full border border-neutral-400 px-2 py-1 text-neutral-400 outline-none hover:border-neutral-500 hover:text-neutral-500"
                            onClick={() => {
                              select(wallet.adapter.name);
                              setIsOpen(false);
                            }}
                          >
                            {wallet.adapter.name}
                          </button>
                        )}
                      </li>
                    ))}
                  </Dialog.Description>

                  <div className="mt-6">
                    <button
                      type="button"
                      className="border border-neutral-400 px-3 py-1 text-sm uppercase text-neutral-400 outline-none"
                      onClick={() => setIsOpen(false)}
                    >
                      Close
                    </button>
                  </div>
                </Dialog.Panel>
              </Transition.Child>
            </div>
          </div>
        </Dialog>
      </Transition>
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
