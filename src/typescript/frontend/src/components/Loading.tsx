import { css } from "@emotion/react";
import React from "react";

export const Loading = () => {
  return (
    <div
      css={css`
        width: 100%;
        text-align: center;
      `}
    >
      Loading...
    </div>
  );
};
