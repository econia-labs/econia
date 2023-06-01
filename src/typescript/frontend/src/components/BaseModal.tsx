import { Dialog, Transition } from "@headlessui/react";
import { ChevronLeftIcon } from "@heroicons/react/20/solid";
import React, { Fragment, type PropsWithChildren } from "react";

import { XIcon } from "./icons/XIcon";

export const BaseModal: React.FC<
  PropsWithChildren<{
    open: boolean;
    onClose: () => void;
    onBack?: () => void;
    showCloseButton?: boolean;
    showBackButton?: boolean;
  }>
> = ({ open, onClose, onBack, showBackButton, showCloseButton, children }) => {
  return (
    <Transition appear show={open} as={Fragment}>
      <Dialog as="div" className="relative z-50" open={open} onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-150"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-100"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black/20 backdrop-blur-sm" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4 text-center">
            <Dialog.Panel className="w-full max-w-xl transform border border-neutral-600 bg-black px-10 py-8 align-middle shadow-xl transition-all">
              <Dialog.Title as="div">
                {showBackButton && (
                  <div
                    className="absolute left-[24px] top-[24px] flex cursor-pointer items-center justify-center font-roboto-mono text-neutral-500 transition-all hover:text-white"
                    onClick={onBack}
                  >
                    <ChevronLeftIcon width={24} height={24} />
                    Back
                  </div>
                )}
                {showCloseButton && (
                  <div
                    className="absolute right-0 top-0 flex h-[72px] w-[72px] cursor-pointer items-center justify-center border-b border-l border-b-neutral-600 border-l-neutral-600 transition-all [&>svg>path]:stroke-neutral-500 [&>svg>path]:transition-all [&>svg>path]:hover:stroke-neutral-100"
                    onClick={onClose}
                  >
                    <XIcon />
                  </div>
                )}
              </Dialog.Title>
              {children}
            </Dialog.Panel>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};
