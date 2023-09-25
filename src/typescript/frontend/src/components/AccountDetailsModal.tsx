import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import React, { useCallback, useState } from "react";

import { Button } from "@/components/Button";
import { type ApiMarket } from "@/types/api";

import { CopyIcon } from "./icons/CopyIcon";
import { ExitIcon } from "./icons/ExitIcon";
import { RecognizedIcon } from "./icons/RecognizedIcon";
import { MarketIconPair } from "./MarketIconPair";
import { shorten } from "@/utils/formatter";
import { useQuery } from "@tanstack/react-query";
import { API_URL, AUDIT_ADDR, ECONIA_ADDR } from "@/env";
import { toast } from "react-toastify";
import { MarketAccount, MarketAccounts } from "@/types/econia";
import { useAptos } from "@/contexts/AptosContext";
import { makeMarketAccountId } from "@/utils/econia";
import { NO_CUSTODIAN } from "@/constants";
import { TypeTag } from "@/utils/TypeTag";
import { fromRawCoinAmount } from "@/utils/coin";

// get_all_market_account_ids_for_user

export const AccountDetailsModal: React.FC<{
  selectedMarket?: ApiMarket;
  onClose: () => void;
  onDepositWithdrawClick: (selected: ApiMarket) => void;
  onRegisterAccountClick: () => void;
}> = ({ onClose, onDepositWithdrawClick, onRegisterAccountClick }) => {
  const { aptosClient, signAndSubmitTransaction } = useAptos();
  const { account, disconnect } = useWallet();

  const [showCopiedNotif, setShowCopiedNotif] = useState<boolean>(false);

  const { data } = useQuery(
    ["userMarketIdsForUser", account?.address],
    async () => {
      if (!account?.address) return null;
      try {
        const test = await aptosClient.view({
          // TODO: change with real when audit comes back
          function: `${AUDIT_ADDR}::user::get_all_market_account_ids_for_user`,
          arguments: [account?.address],
          type_arguments: [],
        });
        return test;
      } catch (e) {
        if (e instanceof Error) {
          // toast.error(e.message);
          console.log(e.message);
        } else {
          console.error(e);
        }
        return null;
      }
    },
  );

  const copyToClipboard = useCallback(() => {
    setShowCopiedNotif(true);
    // remove notif after 1 second
    setTimeout(() => {
      setShowCopiedNotif(false);
    }, 1000);

    navigator.clipboard.writeText(account?.address || "");
  }, [account?.address]);

  const disconnectWallet = () => {
    onClose();
    disconnect();
  };
  return (
    <div className="relative flex flex-col items-center gap-6 font-roboto-mono">
      <div className="scrollbar-none mt-[-24px] max-h-[524px] min-h-[524px] overflow-auto">
        <p className="mb-8 mt-[36px] font-jost text-xl font-bold text-white">
          Account Details
        </p>
        {/* card */}
        <div
          className={
            "mb-4 flex h-[105px] w-[378px] justify-between border-[1px] border-neutral-600 px-[21px] py-[18px]"
          }
        >
          {/* left side */}
          <div className="flex-1">
            {/* input copy row 1 */}
            <div className="mb-[15px] flex w-full items-center">
              <div className="flex-1 border-[1px] border-neutral-600 px-2 py-1 text-xs uppercase tracking-[0.24px] text-white">
                {/* invisible character,  */}
                {showCopiedNotif ? "COPIED!" : shorten(account?.address) || "‎"}
              </div>
              <CopyIcon
                className={"ml-4 h-4 w-4 cursor-pointer"}
                onClick={copyToClipboard}
              />
            </div>
            {/* row 2 */}
            <Button
              variant="secondary"
              onClick={disconnectWallet}
              className={
                "flex items-center !px-3 !py-1 !text-[10px] !leading-[18px]"
              }
            >
              Disconnect
              <ExitIcon className="ml-2 inline-block h-4 w-4 text-center" />
            </Button>
          </div>
          {/* right side */}
          <div className="ml-[39px] flex-1">
            <div className="ml-8 flex flex-col text-left">
              <span className="align-text-top font-roboto-mono text-[10px] font-light text-neutral-500">
                WALLET BALANCE
              </span>
              <p className="font-roboto-mono text-xs font-light text-white">
                <span className="inline-block align-text-top text-white">
                  {/* TODO wallet value */}
                  $35.03
                </span>
              </p>
            </div>
            <div className="ml-8 text-left">
              <span className="font-roboto-mono text-[10px] font-light text-neutral-500">
                TOTAL IN ECONIA
              </span>
              <p className="font-roboto-mono text-xs font-light text-white">
                <span className="inline-block text-white">
                  {/* TODO wallet value */}
                  $222,222.00
                </span>
              </p>
            </div>
          </div>
        </div>
        <p className="mb-3 font-jost text-sm font-bold text-white">
          Market Accounts
        </p>
        {/* market accounts */}
        {data?.map((id) => (
          <DepositWithdrawCard
            // marketID={Number(id.toString())}
            // TODO: when audit comes back update hardcode
            marketID={2}
            key={id.toString() + "deposit card"}
            onDepositWithdrawClick={onDepositWithdrawClick}
          />
        ))}
      </div>
      {/* spacer to compensate for sticky bottom row */}
      {/* note, has to be same height as the sticky row -- iirc no way to do this dynamically as absolutely positioned elements take up 0 space */}
      <div className="h-[36px]" />
      {/* sticky bottom row */}
      {/* todo, height 80px but negative margin due to modal padding */}
      <div className="absolute bottom-0 left-[50%] mb-[-24px] flex h-[84px] w-full min-w-[500px] translate-x-[-50%] items-center justify-center border-[1px] border-neutral-600 text-center">
        <Button
          variant="secondary"
          onClick={() => {
            onRegisterAccountClick();
          }}
          className={
            "flex h-[35px] w-[144px] items-center justify-center !px-3 !py-1 text-center !text-xs"
          }
        >
          Add New Account
        </Button>
      </div>

      {/* sticky fade out header */}
      <div className="absolute left-[50%] top-[-24px] mb-[-24px] flex h-[48px] w-full min-w-[500px] translate-x-[-50%] border-[1px] border-b-0 border-neutral-600 bg-gradient-to-t from-transparent to-black"></div>
    </div>
  );
};

const DepositWithdrawCard: React.FC<{
  marketID: number;
  onDepositWithdrawClick: (selected: ApiMarket) => void;
}> = ({ marketID, onDepositWithdrawClick }) => {
  const [expanded, setExpanded] = React.useState(false);
  const toggleExpanded = () => setExpanded(!expanded);
  const { account } = useWallet();
  const { aptosClient, coinListClient } = useAptos();

  // move into parent, this is inefficient
  const { data: marketAccounts } = useQuery(
    ["useMarketAccounts", account?.address],
    async () => {
      if (!account?.address) return null;
      try {
        const resource = await aptosClient.getAccountResource(
          account.address,
          `${ECONIA_ADDR}::user::MarketAccounts`,
        );
        return resource.data as MarketAccounts;
      } catch (e) {
        if (e instanceof Error) {
          toast.error(e.message);
        } else {
          console.error(e);
        }
        return null;
      }
    },
  );

  const { data: marketAccount } = useQuery(
    ["useMarketAccount", account?.address, marketID],
    async () => {
      if (!account?.address) return null;
      try {
        const marketAccount = await aptosClient.getTableItem(
          marketAccounts!.map.handle,
          {
            key_type: "u128",
            value_type: `${ECONIA_ADDR}::user::MarketAccount`,
            key: makeMarketAccountId(marketID - 1, NO_CUSTODIAN),
          },
        );
        console.log(marketAccount);
        return marketAccount as MarketAccount;
      } catch (e) {
        if (e instanceof Error) {
          toast.error(e.message);
        } else {
          console.error(e);
        }
        return null;
      }
    },
    {
      enabled: !!marketAccounts,
    },
  );

  const { data: marketPair } = useQuery(
    ["market", marketID],
    async () => {
      const resProm = fetch(`${API_URL}/markets/${marketID}`).then((res) =>
        res.json(),
      );

      const res = await resProm;
      return res as ApiMarket;
    },
    {
      keepPreviousData: true,
      refetchOnWindowFocus: false,
      refetchInterval: 10 * 1000,
    },
  );
  const DEFAULT_TOKEN_ICON = "/tokenImages/default.png";

  // could refactor
  const baseAssetIcon = marketAccount
    ? coinListClient.getCoinInfoByFullName(
        TypeTag.fromMoveTypeInfo(marketAccount.base_type).toString(),
      )?.logo_url
    : DEFAULT_TOKEN_ICON;
  const quoteAssetIcon = marketAccount
    ? coinListClient.getCoinInfoByFullName(
        TypeTag.fromMoveTypeInfo(marketAccount.quote_type).toString(),
      )?.logo_url
    : DEFAULT_TOKEN_ICON;

  return (
    <div
      className={
        "mb-4 flex min-h-[105px] w-[378px] justify-between  border-[1px] border-neutral-600 px-[21px] py-[18px]"
      }
    >
      {/* left side */}
      <div className="flex-1">
        {/* input copy row 1 */}
        <div className="mb-[9px] flex items-center">
          <div className="text-white">
            <div className="flex items-center text-sm font-bold">
              <MarketIconPair
                size={16}
                baseAssetIcon={baseAssetIcon}
                quoteAssetIcon={quoteAssetIcon}
              />
              {!marketPair?.base ? "GENERIC" : marketPair?.base?.symbol}/
              {marketPair?.quote.symbol}
              <RecognizedIcon className="ml-1 inline-block h-[9px] w-[9px] text-center" />
            </div>
            {/* row2 within row1 */}
            <div>
              <div
                className="ml-[27.42px] cursor-pointer text-left text-[10px] text-neutral-500"
                onClick={toggleExpanded}
              >
                LAYERZERO {/** TODO */}
                <ChevronDownIcon
                  className={`inline-block h-4 w-4 text-center duration-150 ${
                    expanded && "rotate-180"
                  }`}
                />
              </div>
              {/* expand container */}
              <div className="relative overflow-hidden">
                <div
                  className={`reveal-container ml-[27.42px] ${
                    expanded && "revealed"
                  } line-clamp-[10px] text-left text-[8px] text-neutral-500`}
                >
                  <div>MARKET ID: {marketID}</div>
                  <div>LOT SIZE: {marketAccount?.lot_size}</div>
                  <div>TICK SIZE: {marketAccount?.tick_size}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
        {/* row 2 */}
        <Button
          variant="secondary"
          onClick={() => {
            onDepositWithdrawClick(marketPair!);
          }}
          className={
            "flex items-center !px-3 !py-1 !text-[10px] !leading-[18px]"
          }
        >
          Deposit / Withdraw
        </Button>
      </div>
      {/* right side */}
      <div className="ml-[39px] flex-1">
        <div className="ml-8 flex flex-col text-left">
          <span className="align-text-top font-roboto-mono text-[10px] font-light text-neutral-500">
            {!marketPair?.base ? "GENERIC ASSET" : marketPair?.base?.symbol}{" "}
            BALANCE
          </span>
          <p className="font-roboto-mono text-xs font-light text-white">
            <span className="inline-block align-text-top text-white">
              {fromRawCoinAmount(
                marketAccount?.base_total || 0,
                !marketPair?.base ? 0 : marketPair?.base.decimals || 0,
              )}

              {/* {marketAccount?.base_total} */}
            </span>
          </p>
        </div>
        <div className="ml-8 text-left">
          <span className="font-roboto-mono text-[10px] font-light text-neutral-500">
            {marketPair?.quote.symbol} BALANCE
          </span>
          <p className="font-roboto-mono text-xs font-light text-white">
            <span className="inline-block text-white">
              {fromRawCoinAmount(
                marketAccount?.quote_total || 0,
                marketPair?.quote.decimals || 0,
              )}
            </span>
          </p>
        </div>
      </div>
    </div>
  );
};
