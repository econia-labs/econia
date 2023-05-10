import { ArrowRightIcon } from "@heroicons/react/20/solid";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { PropsWithChildren } from "react";

const NavItem: React.FC<
  PropsWithChildren<{ href: string; active?: boolean; external?: boolean }>
> = ({ href, active, external, children }) => {
  const extraLinkProps = external
    ? { target: "_blank", rel: "noopener noreferrer" }
    : {};

  return (
    <Link
      href={href}
      {...extraLinkProps}
      className={`cursor-pointer font-roboto-mono text-lg font-medium uppercase tracking-wide text-neutral-500 transition-all hover:text-purple ${
        active ? "text-neutral-100" : ``
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
  const router = useRouter();

  return (
    <header className="flex flex-col border-b border-neutral-600 bg-black">
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
        <div className="flex items-center gap-5">
          <NavItem href="/swap" active={router.pathname.startsWith("/swap")}>
            Swap
          </NavItem>
          <NavItemDivider />
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
          <NavItem href="https://econia.dev" external>
            Docs
            <ArrowRightIcon className="ml-1 inline-block h-3 w-3 -rotate-45" />
          </NavItem>
        </div>
        <div className="flex flex-1 justify-end">
          <p className="font-roboto-mono text-white">Socials</p>
        </div>
      </nav>
    </header>
  );
}
