import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import React from "react";
import { toast } from "react-toastify";

import { Button } from "@/components/Button";
import { type ApiMarket } from "@/types/api";

import { CopyIcon } from "./icons/CopyIcon";
import { ExitIcon } from "./icons/ExitIcon";
import { MarketIconPair } from "./MarketIconPair";
import { RecognizedIcon } from "./icons/RecognizedIcon";

export const AccountDetailsModal: React.FC<{
  selectedMarket: ApiMarket;
}> = ({ selectedMarket }) => {
  const { account } = useWallet();

  const copyToClipboard = () => {
    toast.success("Copied to clipboard");
    console.log("copying to clipboard");
    navigator.clipboard.writeText(account?.address || "");
  };
  return (
    <div className="relative flex w-full flex-col items-center gap-6 font-roboto-mono">
      <div>
        <p className="mb-4 font-jost text-xl font-bold text-white">
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
                {shorten(account?.address) || "‎"}
              </div>
              <CopyIcon
                className={"ml-4 h-4 w-4 cursor-pointer"}
                onClick={() => {
                  copyToClipboard();
                }}
              />
            </div>
            {/* row 2 */}
            <Button
              variant="secondary"
              onClick={() => {}}
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
                  000.1.2
                </span>
              </p>
            </div>
            <div className="ml-8 text-left">
              <span className="font-roboto-mono text-[10px] font-light text-neutral-500">
                TOTAL IN ECONIA
              </span>
              <p className="font-roboto-mono text-xs font-light text-white">
                <span className="inline-block text-white">000.1.2</span>
              </p>
            </div>
          </div>
        </div>
        <p className="mb-3 font-jost text-sm font-bold text-white">
          Market Accounts
        </p>
        <DepositWithdrawCard />
        <DepositWithdrawCard />
      </div>
      {/* spacer to compensate for sticky bottom row */}
      {/* note, has to be same height as the sticky row -- iirc no way to do this dynamically as absolutely positioned elements take up 0 space */}
      <div className="h-[56px]" />
      {/* sticky bottom row */}
      {/* todo, height 80px but negative margin due to modal padding */}
      <div className="absolute bottom-0 mx-[-234px] mb-[-24px] flex h-[56px] w-full items-center justify-center border-[1px] border-neutral-600">
        <Button
          variant="secondary"
          onClick={() => {}}
          className={
            "flex items-center !px-3 !py-1 !text-[10px] !leading-[18px]"
          }
        >
          Add New Account
        </Button>
      </div>
    </div>
  );
};

const DepositWithdrawCard: React.FC = () => {
  const [expanded, setExpanded] = React.useState(false);
  const toggleExpanded = () => setExpanded(!expanded);
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
              <MarketIconPair size={16} />
              APT/USDC
              <RecognizedIcon className="ml-1 inline-block h-[9px] w-[9px] text-center" />
            </div>
            {/* row2 within row1 */}
            <div>
              <div
                className="ml-[27.42px] cursor-pointer text-left text-[10px] text-neutral-500"
                onClick={toggleExpanded}
              >
                LAYERZERO
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
                  <div>MARKET ID: 2</div>
                  <div>LOT SIZE: </div>
                  <div>TICK SIZE: </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        {/* row 2 */}
        <Button
          variant="secondary"
          onClick={() => {}}
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
            WALLET BALANCE
          </span>
          <p className="font-roboto-mono text-xs font-light text-white">
            <span className="inline-block align-text-top text-white">
              000.1.2
            </span>
          </p>
        </div>
        <div className="ml-8 text-left">
          <span className="font-roboto-mono text-[10px] font-light text-neutral-500">
            TOTAL IN ECONIA
          </span>
          <p className="font-roboto-mono text-xs font-light text-white">
            <span className="inline-block text-white">000.1.2</span>
          </p>
        </div>
      </div>
    </div>
  );
};

// generated
function shorten(str: string | undefined, maxLen = 10, separator = "") {
  if (str == undefined) return "";
  if (str.length <= maxLen) return str;
  return str.substr(0, str.lastIndexOf(separator, maxLen)) + "..";
}
