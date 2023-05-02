import Image from "next/image";

export function Header() {
  return (
    <header className="flex flex-col border-b border-neutral-600 bg-black">
      <nav className="flex items-center justify-between px-8 py-6">
        <div className="my-auto flex-1 items-center">
          <Image
            className=""
            alt="Econia Logo"
            src="/econia.svg"
            width={120}
            height={20}
            priority
          />
        </div>
        <div className="flex space-x-3">
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-white hover:text-neutral-400">
            Swap
          </p>
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-neutral-600">
            /
          </p>
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-white hover:text-neutral-400">
            Trade
          </p>
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-neutral-600">
            /
          </p>
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-white hover:text-neutral-400">
            Faucet
          </p>
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-neutral-600">
            /
          </p>
          <p className="font-lg font-roboto-mono font-light uppercase tracking-wide text-white hover:text-neutral-400">
            Docs
          </p>
        </div>
        <div className="flex flex-1 justify-end">
          <p className="font-roboto-mono text-white">Socials</p>
        </div>
      </nav>
    </header>
  );
}
