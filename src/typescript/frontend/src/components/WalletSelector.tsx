import { Dialog, Transition } from "@headlessui/react";
import { Fragment, useState } from "react";

export function WalletSelector() {
  const [isOpen, setIsOpen] = useState<boolean>(true);
  return (
    <>
      <button
        className="bg-white px-4 py-1 font-roboto-mono text-sm font-semibold uppercase tracking-tight hover:bg-neutral-300"
        onClick={() => setIsOpen(true)}
      >
        Connect Wallet
      </button>
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

                  <Dialog.Description>Choose a wallet</Dialog.Description>

                  <div className="mt-4">
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
    </>
  );
}
