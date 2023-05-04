import { css } from "@emotion/react";
import styled from "@emotion/styled";
import BigNumber from "bignumber.js";
import React from "react";
import { useState } from "react";

import { useAptos } from "../hooks/useAptos";
import { useCoinInfo } from "../hooks/useCoinInfo";
import { useIsRecognizedMarket } from "../hooks/useIsRecognizedMarket";
import { useOnClickawayRef } from "../hooks/useOnClickawayRef";
import { type RegisteredMarket } from "../hooks/useRegisteredMarkets";
import { toDecimalQuote, toDecimalSize } from "../utils/units";
import { DropdownMenu } from "./DropdownMenu";
import { FlexRow } from "./FlexRow";
import { NewMarketModal } from "./modals/NewMarketModal";

export const MarketDropdown: React.FC<{
  className?: string;
  markets: RegisteredMarket[];
  setSelectedMarket: (market: RegisteredMarket) => void;
  dropdownLabel: string;
  allowMarketRegistration?: boolean;
}> = ({
  className,
  markets,
  setSelectedMarket,
  dropdownLabel,
  allowMarketRegistration,
}) => {
  const { account } = useAptos();
  const [showMarketMenu, setShowMarketMenu] = useState(false);
  const marketMenuClickawayRef = useOnClickawayRef(() =>
    setShowMarketMenu(false)
  );
  const [showNewMarketModal, setShowNewMarketModal] = useState(false);

  return (
    <div className={className} ref={marketMenuClickawayRef}>
      <NewMarketModal
        showModal={showNewMarketModal}
        closeModal={() => setShowNewMarketModal(false)}
      />
      <MarketSelector onClick={() => setShowMarketMenu(!showMarketMenu)}>
        {dropdownLabel}
      </MarketSelector>
      <DropdownMenu
        css={css`
          margin-top: 4px;
        `}
        show={showMarketMenu}
      >
        <FlexRow
          css={(theme) => css`
            padding: 4px 8px;
            justify-content: space-between;
            background-color: ${theme.colors.grey[800]};
          `}
        >
          <span
            css={css`
              font-weight: 600;
            `}
          >
            Market Name
          </span>
          <span>lot-tick-min-recognized</span>
        </FlexRow>
        {markets.map((market, i) => (
          <MarketMenuItem
            onClick={() => {
              setSelectedMarket(market);
              setShowMarketMenu(false);
            }}
            market={market}
            key={i}
          />
        ))}
        {account !== null && allowMarketRegistration && (
          <MenuItem
            onClick={() => {
              setShowNewMarketModal(true);
              setShowMarketMenu(false);
            }}
          >
            <div
              className="menu-item"
              css={css`
                padding: 8px;
              `}
            >
              New market
            </div>
          </MenuItem>
        )}
      </DropdownMenu>
    </div>
  );
};

const MarketMenuItem: React.FC<{
  market: RegisteredMarket;
  onClick: () => void;
}> = ({ market, onClick }) => {
  const baseCoinInfo = useCoinInfo(market.baseType);
  const quoteCoinInfo = useCoinInfo(market.quoteType);
  useIsRecognizedMarket(market);
  if (
    baseCoinInfo.isLoading ||
    quoteCoinInfo.isLoading ||
    !baseCoinInfo.data ||
    !quoteCoinInfo.data
  ) {
    return null;
  }
  const lotSize = toDecimalSize({
    size: new BigNumber(1),
    lotSize: market.lotSize,
    baseCoinDecimals: baseCoinInfo.data.decimals,
  });
  const tickSize = toDecimalQuote({
    ticks: new BigNumber(1),
    tickSize: market.tickSize,
    quoteCoinDecimals: quoteCoinInfo.data.decimals,
  });
  const minSize = lotSize.multipliedBy(market.minSize);
  return (
    <MenuItem className="menu-item" onClick={onClick}>
      <FlexRow
        css={css`
          justify-content: space-between;
          padding: 8px;
        `}
      >
        <p>
          {baseCoinInfo.data.symbol}-{quoteCoinInfo.data.symbol}
        </p>
        <p>
          {lotSize.toNumber()}-{tickSize.toNumber()}-{minSize.toNumber()}-
          {market.isRecognized ? "✅" : "❌"}
        </p>
      </FlexRow>
    </MenuItem>
  );
};

const MarketSelector = styled.span`
  color: ${({ theme }) => theme.colors.grey[100]};
  padding: 4px 8px;
  cursor: pointer;
  :hover {
    background-color: ${({ theme }) => theme.colors.grey[600]};
  }
`;

const MenuItem = styled.div`
  width: 400px;
  white-space: nowrap;
  :hover {
    background-color: ${({ theme }) => theme.colors.grey[600]};
  }
`;
