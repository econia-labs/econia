import { css } from "@emotion/react";
import React from "react";

import { Button } from "../components/Button";
import { useAptos } from "./useAptos";

export const ConnectWalletButton: React.FC<{
  size: "sm" | "md" | "lg";
  variant: "primary" | "secondary" | "outline";
  className?: string;
}> = ({ className, size, variant }) => {
  const { connect } = useAptos();
  return (
    <Button
      css={css`
        width: 156px;
        font-size: 14px;
      `}
      size={size}
      variant={variant}
      onClick={connect}
      className={className}
    >
      Connect Wallet
    </Button>
  );
};
