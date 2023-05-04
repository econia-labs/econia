import { css } from "@emotion/react";
import React, { useCallback, useState } from "react";

import { Button } from "../Button";
import { FlexCol } from "../FlexCol";
import { BaseModal } from "./BaseModal";

const LOCAL_STORAGE_KEY = "testnetDismissal";
export const TestnetModal: React.FC = () => {
  const [show, setShow] = useState(
    localStorage.getItem(LOCAL_STORAGE_KEY) === null
  );
  const dismiss = useCallback(() => {
    localStorage.setItem(LOCAL_STORAGE_KEY, "true");
    setShow(false);
  }, []);
  return (
    <BaseModal isOpen={show} onRequestClose={dismiss}>
      <FlexCol
        css={css`
          align-items: center;
          padding: 100px;
        `}
      >
        <h4
          css={css`
            margin-top: 52px;
            margin-bottom: 42px;
          `}
        >
          Notice
        </h4>
        <p
          css={css`
            margin-bottom: 42px;
            text-align: center;
          `}
        >
          This site is a work in progress for the Aptos testnet. If loading
          slows down, then you may have gotten rate limited by the Aptos node
          API. If this happens, give it 5 minutes or so before trying again.
        </p>
      </FlexCol>
    </BaseModal>
  );
};
