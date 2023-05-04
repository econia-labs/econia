import { css } from "@emotion/react";
import styled from "@emotion/styled";
import React from "react";

import { Button } from "./Button";
import { FlexRow } from "./FlexRow";

export const RadioGroup: React.FC<{
  className?: string;
  options: string[];
  value: string;
  onChange: (value: string) => void;
}> = ({ className, options, value, onChange }) => {
  return (
    <FlexRow
      css={css`
        width: fit-content;
      `}
      className={className}
    >
      {options.map((option, i) => (
        <div
          css={css`
            flex-grow: 1;
            padding: 4px;
          `}
          key={i}
        >
          <RadioButton
            selected={option === value}
            onClick={() => onChange(option)}
            size="sm"
            variant="secondary"
          >
            {option}
          </RadioButton>
        </div>
      ))}
    </FlexRow>
  );
};

const RadioButton = styled(Button)<{ selected: boolean }>`
  width: 100%;
  background-color: ${({ selected, theme }) =>
    selected ? theme.colors.grey[800] : theme.colors.grey[700]};
  color: ${({ selected, theme }) =>
    selected ? theme.colors.grey[100] : theme.colors.grey[600]};
  border: 1px solid
    ${({ selected, theme }) =>
      selected ? theme.colors.grey[600] : theme.colors.grey[600]};
  transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
  :hover {
    transform: none;
    background-color: ${({ selected, theme }) =>
      !selected && theme.colors.grey[400]};
  }
`;
