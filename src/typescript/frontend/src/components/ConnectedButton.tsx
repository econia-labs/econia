import { useWallet } from "@aptos-labs/wallet-adapter-react";
import React, { type PropsWithChildren } from "react";

import { useConnectWallet } from "@/contexts/ConnectWalletContext";

import { Button } from "./Button";

export const ConnectedButton: React.FC<
  PropsWithChildren<{ className?: string }>
> = ({ className, children }) => {
  const { connected } = useWallet();
  const { connectWallet } = useConnectWallet();

  return (
    <>
      {!connected ? (
        <Button
          className={`whitespace-nowrap text-[16px]/6 ${className}`}
          variant="primary"
          onClick={(e) => {
            e.preventDefault();
            connectWallet();
          }}
        >
          Connect Wallet
        </Button>
      ) : (
        children
      )}
    </>
  );
};
