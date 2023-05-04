import { css } from "@emotion/react";
import { Listbox } from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/20/solid";
import { useWallet } from "@manahippo/aptos-wallet-adapter";
import { HexString } from "aptos";
import { useState } from "react";

import { useOnClickawayRef } from "@/hooks/useOnClickawayRef";
import { shortenAddress } from "@/utils/address";

import { Button } from "./Button";
import { ConnectWalletButton } from "./ConnectWalletButton";
import { DropdownMenu } from "./DropdownMenu";
import { FlexRow } from "./FlexRow";

type Props = {
  marketNames: string[];
};

export function StatsBar({ marketNames }: Props) {
  const [selectedMarket, setSelectedMarket] = useState<string>(marketNames[0]);
  const { connected, account, disconnect } = useWallet();
  const [showDisconnectMenu, setShowDisconnectMenu] = useState(false);
  const disconnectMenuClickawayRef = useOnClickawayRef(() =>
    setShowDisconnectMenu(false)
  );

  return (
    <div className="flex border-b border-neutral-600 bg-black px-4 py-2">
      <div className="flex flex-1 items-center">
        <Listbox value={selectedMarket} onChange={setSelectedMarket}>
          <div className="relative w-[160px]">
            <Listbox.Button className="flex px-4 font-roboto-mono text-neutral-300">
              {selectedMarket}
              <ChevronDownIcon className="my-auto ml-1 h-5 w-5 text-neutral-500" />
            </Listbox.Button>
            <Listbox.Options className="absolute mt-2 w-full bg-black shadow ring-1 ring-neutral-500">
              {marketNames.map((marketName) => (
                <Listbox.Option
                  key={marketName}
                  value={marketName}
                  className="px-4 py-1 font-roboto-mono text-neutral-300 hover:bg-neutral-800"
                >
                  {marketName}
                </Listbox.Option>
              ))}
            </Listbox.Options>
          </div>
        </Listbox>
        <div className="mb-1 ml-8">
          <span className="font-roboto-mono text-xs font-light uppercase text-neutral-400">
            Last price
          </span>
          <p className="font-roboto-mono font-light">
            <span className="text-white">$0.00</span>
            <span className="ml-8 text-green-500">+0.00</span>
          </p>
        </div>
      </div>
      <div className="my-auto">
        <FlexRow
          css={css`
            flex: 1;
            justify-content: end;
          `}
        >
          {connected ? (
            <div ref={disconnectMenuClickawayRef}>
              <Button
                css={(theme) => css`
                  width: 156px;
                  :hover {
                    transform: none;
                    color: ${theme.colors.purple.primary};
                  }
                  font-size: 14px;
                `}
                size="sm"
                variant="outline"
                onClick={() => setShowDisconnectMenu(!showDisconnectMenu)}
              >
                {account?.address &&
                  shortenAddress(HexString.ensure(account.address))}
              </Button>
              <DropdownMenu show={showDisconnectMenu}>
                <div
                  className="menu-item"
                  css={(theme) => css`
                    text-align: center;
                    padding: 12px 0;
                    width: 156px;
                    outline: 1px solid ${theme.colors.grey[600]};
                    font-size: 14px;
                  `}
                  onClick={() =>
                    disconnect().then(() => setShowDisconnectMenu(false))
                  }
                >
                  Disconnect
                </div>
              </DropdownMenu>
            </div>
          ) : (
            <ConnectWalletButton size="sm" variant="primary" />
          )}
        </FlexRow>
      </div>
    </div>
  );
}
