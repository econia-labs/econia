import React from "react";

import { Button } from "@/components/Button";
import { useAptos } from "@/hooks/useAptos";

export const ConnectWalletButton: React.FC<{
  className?: string;
  variant: "primary" | "secondary" | "outline";
  size: "sm" | "md" | "lg";
}> = ({ className, size, variant }) => {
  const { connect } = useAptos();
  return (
    <Button
      variant={variant}
      size={size}
      onClick={connect}
      className={className}
    >
      Connect Wallet
    </Button>
  );
};
