import { Transition, Dialog } from "@headlessui/react";
import React, { Fragment, PropsWithChildren } from "react";
import { XIcon } from "./icons/XIcon";

export const BaseModal: React.FC<
  PropsWithChildren<{
    open: boolean;
    onClose: () => void;
  }>
> = ({ open, onClose, children }) => {
  return (
    <Transition appear show={open} as={Fragment}>
      <Dialog as="div" className="relative z-10" open={open} onClose={onClose}>
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
            <Dialog.Panel className="w-full max-w-lg transform border border-neutral-500 bg-black p-6 align-middle shadow-xl transition-all">
              <Dialog.Title className="" as="div">
                <div className="absolute right-0 top-0 flex h-[72px] w-[72px] cursor-pointer items-center justify-center border-b border-l border-b-neutral-600 border-l-neutral-600 transition-all [&>svg>path]:stroke-neutral-500 [&>svg>path]:transition-all [&>svg>path]:hover:stroke-neutral-100">
                  <XIcon />
                </div>
              </Dialog.Title>
              {children}
            </Dialog.Panel>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};
