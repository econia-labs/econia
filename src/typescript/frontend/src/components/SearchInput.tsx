import { css } from "@emotion/react";
import styled from "@emotion/styled";
import React, { type InputHTMLAttributes } from "react";

import { SearchIcon } from "@/components/icons/SearchIcon";

import { FlexRow } from "./FlexRow";
import { Input } from "./Input";

export const SearchInput: React.FC<InputHTMLAttributes<HTMLInputElement>> = ({
  className,
  ...props
}) => {
  return (
    <FlexRow
      className={className}
      css={css`
        position: relative;
      `}
    >
      <SearchIcon
        css={css`
          position: absolute;
          top: 17px;
          left: 8px;
        `}
      />
      <PaddedInput {...props} type="text" placeholder="SEARCH" />
    </FlexRow>
  );
};

const PaddedInput = styled(Input)`
  padding: 16px 0px 16px 32px;
  width: 100%;
`;
