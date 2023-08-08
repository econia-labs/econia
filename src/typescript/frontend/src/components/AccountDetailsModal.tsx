import React from "react";

import { Button } from "@/components/Button";
import { ECONIA_ADDR } from "@/env";
import { type ApiMarket } from "@/types/api";
import { ImageWithFallback } from "./MarketIconPair";
import { useWallet } from "@aptos-labs/wallet-adapter-react";

export const AccountDetailsModal: React.FC<{
  selectedMarket: ApiMarket;
}> = ({ selectedMarket }) => {
  const { disconnect } = useWallet();

  const copyToClipboard = () => {
    navigator.clipboard.writeText(ECONIA_ADDR);
  };
  return (
    <div className="relative flex w-full flex-col items-center gap-6">
      <div>
        <p className="font-jost text-3xl font-bold text-white">
          Account Details
        </p>
        <div>
          {/* card */}
          <div>
            <div className="border-[1px_solid_var(--neutral-colors-600, #565656)] text-white">
              dropdown copy button
            </div>
            <Button variant="primary" onClick={() => {}}>
              Disconnect
            </Button>{" "}
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
      </div>
      <div>
        <Button variant="primary" onClick={() => {}}>
          Add New Account
        </Button>
      </div>
    </div>
  );
};

const DepositWithdrawCard: React.FC = () => {
  return (
    <div>
      {/* card */}
      {/* left column */}
      <div>
        <div>dropdown</div>
        <Button variant="primary" onClick={() => {}}>
          Add New Account
        </Button>{" "}
      </div>
      {/* right column */}
      <div>
        {/* right column first row BASE balance */}
        <div>
          <div>
            <ImageWithFallback
              src={""}
              alt="market-icon-pair"
              width={28}
              height={28}
              className="z-20 aspect-square w-7"
            ></ImageWithFallback>
            APT BALANCE
          </div>
          <div>111.00</div>
        </div>
        {/* right column second row QUOTE balance*/}
        <div>
          <div>
            <ImageWithFallback
              src={""}
              alt="market-icon-pair"
              width={28}
              height={28}
              className="z-20 aspect-square w-7"
            ></ImageWithFallback>{" "}
            APT BALANCE
          </div>
          <div>111.00</div>
        </div>
      </div>
    </div>
  );
};
