import React, { type ButtonHTMLAttributes } from "react";

import { ConnectWalletButton } from "../hooks/ConnectWalletButton";
import { useAptos } from "../hooks/useAptos";
import { Button } from "./Button";

/// This button will default to `Connect Wallet` if the user has not yet
/// connected their wallet.
export const TxButton: React.FC<
  ButtonHTMLAttributes<HTMLButtonElement> & {
    size: "sm" | "md" | "lg";
    variant: "primary" | "secondary" | "outline";
  }
> = ({ children, onClick, disabled, ...rest }) => {
  const [loading, setLoading] = React.useState(false);
  const { connected } = useAptos();
  if (!connected) {
    return (
      <ConnectWalletButton
        className={rest.className}
        size={rest.size}
        variant="primary"
      />
    );
  }
  return (
    <Button
      {...rest}
      onClick={async (e) => {
        if (onClick) {
          try {
            setLoading(true);
            await onClick(e);
          } finally {
            setLoading(false);
          }
        }
      }}
      disabled={disabled || loading}
    >
      {loading ? "Loading..." : children}
    </Button>
  );
};
