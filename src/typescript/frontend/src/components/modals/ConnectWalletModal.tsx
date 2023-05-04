import { css } from "@emotion/react";
import styled from "@emotion/styled";
import { useWallet } from "@manahippo/aptos-wallet-adapter";
import React from "react";

import { ArrowRightIcon } from "@/components/icons/ArrowRightIcon";

import { FlexCol } from "../FlexCol";
import { FlexRow } from "../FlexRow";
import { BaseModal } from "./BaseModal";

export const ConnectWalletModal: React.FC<{
  showModal: boolean;
  closeModal: () => void;
}> = ({ showModal, closeModal }) => {
  const { connect: connectToWallet, wallets } = useWallet();

  return (
    <BaseModal isOpen={showModal} onRequestClose={closeModal}>
      <div
        css={css`
          text-align: center;
        `}
      >
        <h3
          css={css`
            margin-top: 52px;
          `}
        >
          Connect a Wallet
        </h3>
        <p
          css={css`
            font-weight: 300;
            margin: 14px 0px 52px 0px;
          `}
        >
          In order to use this site you must connect a wallet and allow the site
          to access your account.
        </p>
        <FlexCol
          css={css`
            align-items: center;
            margin-bottom: 52px;
            button {
              text-align: left;
              margin-bottom: 16px;
            }
          `}
        >
          {wallets.map((wallet, i) => (
            <FlexRow
              css={(theme) =>
                css`
                  align-items: center;
                  border: 1px solid ${theme.colors.grey[600]};
                  font-family: "Jost", sans-serif;
                  font-size: 24px;
                  font-weight: 500;
                  margin-bottom: 16px;
                  padding: 12px 0px;
                  width: 100%;
                  justify-content: space-between;
                  cursor: pointer;
                  transition: all 300ms;
                  :hover {
                    border: 1px solid ${theme.colors.purple.primary};
                    color: ${theme.colors.purple.primary};
                    .arrow {
                      border-left: 1px solid ${theme.colors.purple.primary};
                      border-top: 1px solid ${theme.colors.purple.primary};
                      background: ${theme.colors.purple.primary};
                      svg {
                        transform: rotate(-45deg);
                      }
                    }
                  }
                `
              }
              onClick={() =>
                connectToWallet(wallet.adapter.name).then(closeModal)
              }
              key={i}
            >
              <FlexRow
                css={css`
                  gap: 16px;
                  margin-left: 16px;
                `}
              >
                <img
                  css={css`
                    height: 36px;
                    width: 36px;
                  `}
                  src={wallet.adapter.icon}
                />
                <p>{wallet.adapter.name} Wallet</p>
              </FlexRow>
              <div
                css={css`
                  position: relative;
                  align-self: end;
                `}
              >
                <ArrowContainer className="arrow">
                  <ArrowRightIcon
                    css={css`
                      position: absolute;
                      top: 8px;
                      left: 8px;
                    `}
                  />
                </ArrowContainer>
              </div>
            </FlexRow>
          ))}
        </FlexCol>
      </div>
    </BaseModal>
  );
};

const ArrowContainer = styled.div`
  position: absolute;
  bottom: -12px;
  right: 0;
  width: 36px;
  height: 36px;
  border-left: 1px solid ${({ theme }) => theme.colors.grey[600]};
  border-top: 1px solid ${({ theme }) => theme.colors.grey[600]};
  svg {
    transition: all 300ms;
  }
`;
