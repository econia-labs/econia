import React, { type PropsWithChildren } from "react";

import { useAptos } from "../hooks/useAptos";
import { ExternalLink } from "./ExternalLink";

export const TxLink: React.FC<
  PropsWithChildren & {
    className?: string;
    txId: string | number;
  }
> = ({ className, txId, children }) => {
  const { createTxLink } = useAptos();
  return (
    <ExternalLink className={className} href={createTxLink(txId)}>
      {children ? children : txId}
    </ExternalLink>
  );
};
