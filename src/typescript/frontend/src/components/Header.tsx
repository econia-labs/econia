import { ArrowRightIcon } from "@heroicons/react/20/solid";
import { useWallet } from "@manahippo/aptos-wallet-adapter";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { type PropsWithChildren, useState } from "react";

import { Button } from "./Button";
import { ConnectedButton } from "./ConnectedButton";
import { DepositWithdrawModal } from "./trade/DepositWithdrawModal";

const NavItem: React.FC<
  PropsWithChildren<{
    className?: string;
    href: string;
    active?: boolean;
    external?: boolean;
  }>
> = ({ className, href, active, external, children }) => {
  if (external) {
    return (
      <a
        href={href}
        target="_blank"
        rel="noreferrer"
        className={`cursor-pointer font-roboto-mono text-lg font-medium uppercase tracking-wide transition-all ${
          active ? "text-neutral-100" : "text-neutral-500 hover:text-purple"
        } ${className ? className : ""}`}
      >
        {children}
      </a>
    );
  }

  return (
    <Link
      href={href}
      className={`cursor-pointer font-roboto-mono text-lg font-medium uppercase tracking-wide transition-all ${
        active ? "text-neutral-100" : "text-neutral-500 hover:text-purple"
      }`}
    >
      {children}
    </Link>
  );
};

const NavItemDivider: React.FC = () => {
  return (
    <p className="interact cursor-default font-roboto-mono text-xl font-medium uppercase tracking-wide text-neutral-600">
      /
    </p>
  );
};

export function Header() {
  const { disconnect } = useWallet();
  const router = useRouter();
  const [depositWithdrawOpen, setDepositWithdrawOpen] = useState(false);

  return (
    <header className="flex flex-col border-b border-neutral-600">
      <nav className="flex items-center justify-between px-8 py-6">
        <div className="my-auto flex-1 items-center">
          <Link href="/">
            <Image
              className=""
              alt="Econia Logo"
              src="/econia.svg"
              width={120}
              height={20}
              priority
            />
          </Link>
        </div>
        <div className="flex flex-1 items-center justify-center gap-5">
          {/* TODO: Enable swap */}
          {/* <NavItem href="/swap" active={router.pathname.startsWith("/swap")}>
            Swap
          </NavItem>
          <NavItemDivider /> */}
          <NavItem href="/trade" active={router.pathname.startsWith("/trade")}>
            Trade
          </NavItem>
          <NavItemDivider />
          <NavItem
            href="/faucet"
            active={router.pathname.startsWith("/faucet")}
          >
            Faucet
          </NavItem>
          <NavItemDivider />
          <NavItem
            className="flex items-center gap-1"
            href="https://econia.dev"
            external
          >
            <p>Docs</p>
            <ArrowRightIcon className="inline-block h-3 w-3 -rotate-45" />
          </NavItem>
        </div>
        <div className="flex flex-1 justify-end">
          <ConnectedButton>
            <div className="flex items-center gap-4">
              <Button
                variant="secondary"
                onClick={() => setDepositWithdrawOpen(true)}
                className="whitespace-nowrap"
              >
                Deposit / Withdraw
              </Button>
              <Button variant="outlined" onClick={() => disconnect()}>
                Disconnect
              </Button>
            </div>
          </ConnectedButton>
        </div>
      </nav>
      <DepositWithdrawModal
        open={depositWithdrawOpen}
        onClose={() => setDepositWithdrawOpen(false)}
      />
    </header>
  );
}
