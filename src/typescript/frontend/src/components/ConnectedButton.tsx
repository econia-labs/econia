import { useWallet } from "@manahippo/aptos-wallet-adapter";
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
          className={`py-1.5 text-[14px] ${className}`}
          variant="primary"
          onClick={connectWallet}
        >
          Connect Wallet
        </Button>
      ) : (
        children
      )}
    </>
  );
};
