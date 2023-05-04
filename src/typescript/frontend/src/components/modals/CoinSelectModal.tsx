import { css } from "@emotion/react";
import styled from "@emotion/styled";
import React, { useMemo, useState } from "react";

import { AptosIcon } from "@/components/icons/AptosIcon";
import { UnknownCoinIcon } from "@/components/icons/UnknownCoinIcon";

import { useAptos } from "../../hooks/useAptos";
import { type CoinInfo } from "../../hooks/useCoinInfos";
import { useCoinStore } from "../../hooks/useCoinStore";
import { FlexCol } from "../FlexCol";
import { FlexRow } from "../FlexRow";
import { SearchInput } from "../SearchInput";
import { BaseModal } from "./BaseModal";

// Precondition: coins is not empty
export const CoinSelectModal: React.FC<{
  showModal: boolean;
  closeModal: () => void;
  coins: CoinInfo[];
  onCoinSelected: (c: CoinInfo) => void;
}> = ({ showModal, closeModal, coins, onCoinSelected }) => {
  const [search, setSearch] = useState("");
  const filteredCoins = useMemo(
    () =>
      coins.filter((c) => c.name.toLowerCase().includes(search.toLowerCase())),
    [coins, search]
  );
  return (
    <BaseModal isOpen={showModal} onRequestClose={closeModal}>
      <FlexCol
        css={css`
          align-items: center;
        `}
      >
        <h4
          css={css`
            margin-top: 52px;
            margin-bottom: 42px;
          `}
        >
          Select a coin
        </h4>
        <SearchInput
          css={css`
            width: 100%;
            margin-bottom: 48px;
          `}
          value={search}
          onChange={(e) => setSearch(e.currentTarget.value)}
        />
        <FlexCol
          css={css`
            align-items: center;
            margin-bottom: 52px;
            width: 100%;
            button {
              text-align: left;
              margin-bottom: 16px;
            }
          `}
        >
          {filteredCoins.map((coin, i) => (
            <CoinRow
              coin={coin}
              key={i}
              onClick={() => {
                onCoinSelected(coin);
                closeModal();
              }}
            />
          ))}
        </FlexCol>
      </FlexCol>
    </BaseModal>
  );
};

const CoinRow: React.FC<{ coin: CoinInfo; onClick: () => void }> = ({
  coin,
  onClick,
}) => {
  const { coinListClient, account } = useAptos();
  const hippoCoinInfo = coinListClient.getCoinInfoByFullName(
    coin.typeTag.getFullname()
  );
  const balance = useCoinStore(coin.typeTag, account?.address);
  return (
    <FlexRow
      onClick={onClick}
      css={(theme) => css`
        width: 100%;
        cursor: pointer;
        padding: 8px 16px;
        justify-content: space-between;
        align-items: center;
        :hover {
          outline: 1px solid ${theme.colors.purple.primary};
        }
      `}
    >
      <FlexRow
        css={css`
          gap: 16px;
          align-items: center;
        `}
      >
        {hippoCoinInfo ? (
          // Override the default Aptos icon
          hippoCoinInfo.symbol === "APT" ? (
            <AptosIcon width={32} height={32} />
          ) : (
            <img
              css={css`
                width: 32px;
                height: 32px;
              `}
              src={hippoCoinInfo.logo_url}
            />
          )
        ) : (
          <UnknownCoinIcon />
        )}
        <p
          css={css`
            font-size: 18px;
          `}
        >
          {coin.symbol}
        </p>
      </FlexRow>
      <Balance>
        {balance.data ? balance.data.balance.toString() : "0.00"}
      </Balance>
    </FlexRow>
  );
};

const Balance = styled.p`
  color: ${({ theme }) => theme.colors.grey[600]};
  font-size: 16px;
`;
