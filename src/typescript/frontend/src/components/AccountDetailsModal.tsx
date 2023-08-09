import { useWallet } from "@aptos-labs/wallet-adapter-react";
import {
  ArrowRightOnRectangleIcon,
  ChevronDownIcon,
} from "@heroicons/react/20/solid";
import React from "react";

import { Button } from "@/components/Button";
import { ECONIA_ADDR } from "@/env";
import { type ApiMarket } from "@/types/api";

import { MarketIconPair } from "./MarketIconPair";
import { CopyIcon } from "./icons/CopyIcon";
import { toast } from "react-toastify";

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
        <p className="font-jost text-3xl font-bold text-white">
          Account Details
        </p>
        {/* card */}
        <div className={"flex"}>
          <div>
            {/* input copy row */}
            <div className="flex items-center">
              <div className="flex-1 border-[1px] border-neutral-600 px-3 py-2 uppercase text-white">
                {/* invisible character,  */}
                {shorten(account?.address) || "‎"}
              </div>
              <CopyIcon
                className={"ml-4 h-5 w-5 cursor-pointer"}
                onClick={() => {
                  copyToClipboard();
                }}
              />
            </div>
            <Button
              variant="secondary"
              onClick={() => {}}
              className={"flex items-center"}
            >
              Disconnect
              <ArrowRightOnRectangleIcon className="ml-2 inline-block h-4 w-4 text-center" />
            </Button>
          </div>
          <div>
            <div className="ml-8 text-left md:block">
              <span className="font-roboto-mono text-xs font-light text-neutral-500">
                24H CHANGE
              </span>
              <p className="font-roboto-mono text-xs font-light text-white">
                <span className="inline-block text-white">000.1.2</span>
              </p>
            </div>
            <div className="ml-8 text-left md:block">
              <span className="font-roboto-mono text-xs font-light text-neutral-500">
                24H CHANGE
              </span>
              <p className="font-roboto-mono text-xs font-light text-white">
                <span className="inline-block text-white">000.1.2</span>
              </p>
            </div>
          </div>
        </div>
        <p className="font-jost text-3xl font-bold text-white">
          Market Accounts
        </p>
        <DepositWithdrawCard />
      </div>
      <div>
        <Button variant="secondary" onClick={() => {}}>
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
    <div className="flex text-white">
      {/* card */}
      {/* left column */}
      <div>
        <div>
          <MarketIconPair /> APT/USDC <span>verified icon</span>
        </div>
        <div className="text-neutral-500">
          LAYERZERO
          <ChevronDownIcon className="inline-block h-4 w-4 text-center" />
        </div>
        <Button variant="secondary" onClick={() => {}}>
          Deposit / Withdraw
        </Button>{" "}
      </div>
      {/* right column */}
      <div>
        {/* right column first row BASE balance */}
        <div>
          <div className="font-roboto-mono text-xs font-light text-neutral-500">
            APT BALANCE
          </div>
          <div className="inline-block text-white">111.00</div>
        </div>
        {/* right column second row QUOTE balance*/}
        <div>
          <div className="font-roboto-mono text-xs font-light text-neutral-500">
            APT BALANCE
          </div>
          <div className="inline-block text-white">111.00</div>
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
