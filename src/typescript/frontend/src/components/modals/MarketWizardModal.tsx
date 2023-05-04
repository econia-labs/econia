import { css } from "@emotion/react";
import styled from "@emotion/styled";
import { parseTypeTagOrThrow, u64 } from "@manahippo/move-to-ts";
import BigNumber from "bignumber.js";
import React, { useMemo, useState } from "react";
import { toast } from "react-toastify";

import { CheckIcon } from "@/components/icons/CheckIcon";

import { useCoinInfo } from "../../hooks/useCoinInfo";
import { useIsRecognizedMarket } from "../../hooks/useIsRecognizedMarket";
import { type RegisteredMarket } from "../../hooks/useRegisteredMarkets";
import { useRegisterMarket } from "../../hooks/useRegisterMarket";
import { toDecimalQuote, toDecimalSize } from "../../utils/units";
import { Button } from "../Button";
import { ExternalLink } from "../ExternalLink";
import { FlexCol } from "../FlexCol";
import { FlexRow } from "../FlexRow";
import { Input } from "../Input";
import { Label } from "../Label";
import { SearchInput } from "../SearchInput";
import { BaseModal } from "./BaseModal";

enum Mode {
  SelectMarket,
  RegisterMarket,
}

export const MarketWizardModal: React.FC<{
  showModal: boolean;
  closeModal: () => void;
  markets: RegisteredMarket[];
  setMarket: (market: RegisteredMarket) => void;
}> = ({ showModal, closeModal, markets, setMarket }) => {
  const [mode, setMode] = useState(Mode.SelectMarket);
  return (
    <BaseModal isOpen={showModal} onRequestClose={closeModal}>
      {mode === Mode.SelectMarket ? (
        <SelectMarketView
          markets={markets}
          setMarket={(market) => {
            setMarket(market);
            closeModal();
          }}
          onRegisterMarket={() => setMode(Mode.RegisterMarket)}
        />
      ) : (
        <RegisterMarketView onSelectMarket={() => setMode(Mode.SelectMarket)} />
      )}
    </BaseModal>
  );
};

const SelectMarketView: React.FC<{
  markets: RegisteredMarket[];
  setMarket: (market: RegisteredMarket) => void;
  onRegisterMarket: () => void;
}> = ({ markets, setMarket, onRegisterMarket }) => {
  const [search, setSearch] = useState("");
  const filteredMarkets = useMemo(
    () =>
      markets.filter((c) => {
        const name = `${c.baseType.getFullname().toLowerCase()}-${c.quoteType
          .getFullname()
          .toLowerCase()}`;
        return name.includes(search.toLowerCase());
      }),
    [markets, search]
  );
  return (
    <>
      <h4
        css={css`
          margin: 36px 0px;
          text-align: center;
        `}
      >
        Select a market
      </h4>
      <SearchInput
        css={css`
          width: 100%;
          margin-bottom: 24px;
        `}
        value={search}
        onChange={(e) => setSearch(e.currentTarget.value)}
      />
      <table
        css={(theme) => css`
          width: 100%;
          text-align: left;
          th {
            font-size: 12px;
            color: ${theme.colors.grey[500]};
            font-weight: 400;
            padding-bottom: 8px;
          }
        `}
      >
        <thead>
          <tr>
            <th>MARKET</th>
            <th>LOT SIZE</th>
            <th>TICK SIZE</th>
            <th>MIN SIZE</th>
            <th
              css={css`
                text-align: center;
              `}
            >
              RECOGNIZED
            </th>
          </tr>
        </thead>
        <tbody>
          {filteredMarkets.map((market, i) => (
            <MarketRow
              onClick={() => {
                setMarket(market);
              }}
              market={market}
              key={i}
            />
          ))}
        </tbody>
      </table>
      <div
        css={css`
          text-align: center;
          font-size: 12px;
          margin-top: 32px;
          margin-bottom: 52px;
        `}
      >
        <span>Don&apos;t see the market you&apos;re looking for?</span>{" "}
        <span
          css={(theme) => css`
            color: ${theme.colors.purple.primary};
            cursor: pointer;
            :hover {
              text-decoration: underline;
            }
          `}
          onClick={onRegisterMarket}
        >
          Register a new market
        </span>
      </div>
    </>
  );
};

const MarketRow: React.FC<{
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
    <tr
      onClick={onClick}
      css={(theme) => css`
        cursor: pointer;
        // Fixes a Safari bug where outline gets cropped on sides
        outline: 1px solid transparent;
        td {
          padding: 8px 0px;
        }
        td:first-child {
          padding-left: 16px;
        }
        :hover {
          outline: 1px solid ${theme.colors.purple.primary};
        }
      `}
    >
      <td
        css={css`
          text-align: left;
          font-weight: 500;
          font-size: 20px;
        `}
      >
        {baseCoinInfo.data.symbol}-{quoteCoinInfo.data.symbol}
      </td>
      <NumberTd>{lotSize.toNumber()}</NumberTd>
      <NumberTd>{tickSize.toNumber()} </NumberTd>
      <NumberTd>{minSize.toNumber()} </NumberTd>
      <td
        css={css`
          text-align: center;
        `}
      >
        {market.isRecognized && <CheckIcon />}
      </td>
    </tr>
  );
};

const RegisterMarketView: React.FC<{ onSelectMarket: () => void }> = ({
  onSelectMarket,
}) => {
  const registerMarket = useRegisterMarket();
  const baseCoinRef = React.useRef<HTMLInputElement>(null);
  const quoteCoinRef = React.useRef<HTMLInputElement>(null);
  const lotSizeRef = React.useRef<HTMLInputElement>(null);
  const tickSizeRef = React.useRef<HTMLInputElement>(null);
  const minSizeRef = React.useRef<HTMLInputElement>(null);

  return (
    <>
      <div
        css={(theme) => css`
          position: absolute;
          width: fit-content;
          font-size: 12px;
          cursor: pointer;
          padding: 4px 4px;
          top: 52px;
          :hover {
            color: ${theme.colors.purple.primary};
          }
        `}
        onClick={onSelectMarket}
      >
        {"<<"} BACK
      </div>
      <h4
        css={css`
          margin: 52px 0px;
          text-align: center;
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
    </>
  );
};

const NumberTd = styled.td`
  text-align: left;
  font-weight: 300;
  font-size: 16px;
`;
