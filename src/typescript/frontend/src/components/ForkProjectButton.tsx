import { css } from "@emotion/react";
import React from "react";

import { CodeIcon } from "@/components/icons/CodeIcon";

import { Button } from "./Button";
import { ExternalLink } from "./ExternalLink";
import { FlexRow } from "./FlexRow";

export const ForkProjectButton: React.FC = () => {
  return (
    <div
      css={(theme) => css`
        position: fixed;
        bottom: 24px;
        right: 24px;
        :hover {
          * {
            fill: ${theme.colors.purple.primary};
          }
        }
      `}
    >
      <ExternalLink href="https://github.com/econia-labs/econia-reference-front-end">
        <Button variant="outline" size="sm">
          <FlexRow
            css={css`
              gap: 8px;
              align-items: center;
            `}
          >
            <CodeIcon width={20} height={20} />{" "}
            <p
              css={css`
                font-weight: 400;
              `}
            >
              Fork me on Github
            </p>
          </FlexRow>
        </Button>
      </ExternalLink>
    </div>
  );
};
