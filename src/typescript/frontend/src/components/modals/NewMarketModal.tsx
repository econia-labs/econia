import { css, useTheme } from "@emotion/react";
import { parseTypeTagOrThrow, u64 } from "@manahippo/move-to-ts";
import React from "react";
import { toast } from "react-toastify";

import { useRegisterMarket } from "../../hooks/useRegisterMarket";
import { Button } from "../Button";
import { ExternalLink } from "../ExternalLink";
import { FlexCol } from "../FlexCol";
import { Input } from "../Input";
import { Label } from "../Label";
import { BaseModal } from "./BaseModal";

export const NewMarketModal: React.FC<{
  showModal: boolean;
  closeModal: () => void;
}> = ({ showModal, closeModal }) => {
  const registerMarket = useRegisterMarket();
  const baseCoinRef = React.useRef<HTMLInputElement>(null);
  const quoteCoinRef = React.useRef<HTMLInputElement>(null);
  const lotSizeRef = React.useRef<HTMLInputElement>(null);
  const tickSizeRef = React.useRef<HTMLInputElement>(null);
  const minSizeRef = React.useRef<HTMLInputElement>(null);

  return (
    <BaseModal isOpen={showModal} onRequestClose={closeModal}>
      <h4
        css={css`
          margin-top: 52px;
        `}
      >
        Register Market
      </h4>
      <p
        css={css`
          font-size: 14px;
          margin-bottom: 16px;
        `}
      >
        Register a new market with the Econia protocol.{" "}
        <ExternalLink
          css={css`
            text-decoration: underline;
          `}
          href="https://econia.dev/overview/orders"
        >
          See the docs
        </ExternalLink>{" "}
        for parameterization tips.
      </p>
      <FlexCol
        css={css`
          label {
            margin-bottom: 4px;
          }
          input {
            margin-bottom: 16px;
          }
        `}
      >
        <Label>Base adddress</Label>
        <Input ref={baseCoinRef} placeholder="0x1::aptos_coin::AptosCoin" />
        <Label>Quote adddress</Label>
        <Input ref={quoteCoinRef} placeholder="0x2::usd_coin::USDCoin" />
        <Label>Lot size</Label>
        <Input ref={lotSizeRef} type="number" />
        <Label>Tick size</Label>
        <Input ref={tickSizeRef} type="number" />
        <Label>Min size</Label>
        <Input ref={minSizeRef} type="number" />
        <Button
          css={css`
            margin-bottom: 52px;
          `}
          variant="primary"
          size="sm"
          onClick={async () => {
            try {
              await registerMarket(
                u64(parseInt(lotSizeRef.current?.value || "0")),
                u64(parseInt(tickSizeRef.current?.value || "0")),
                u64(parseInt(minSizeRef.current?.value || "0")),
                parseTypeTagOrThrow(baseCoinRef.current?.value || ""),
                parseTypeTagOrThrow(quoteCoinRef.current?.value || "")
              );
              // TODO: no any
            } catch (e: any) {
              toast.error(e.message);
            }
          }}
        >
          Register
        </Button>
      </FlexCol>
    </BaseModal>
  );
};
