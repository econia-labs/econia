import { css } from "@emotion/react";
import React from "react";

import { AddIcon } from "./AddIcon";

export const XIcon: React.FC<{
  className?: string;
  width?: number;
  height?: number;
  fill?: string;
}> = ({ className, width, height }) => {
  return (
    <AddIcon
      css={css`
        svg {
          transform: rotate(-45deg);
        }
      `}
      className={className}
      width={width}
      height={height}
    />
  );
};
