export function StatsBar() {
  return (
    <div className="flex border-b border-neutral-600 px-8 py-2">
      <div className="flex flex-1 items-center">
        <div>
          <p className="font-roboto-mono text-neutral-300">APT-USDC</p>
        </div>
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
        <button className="bg-white px-4 py-1 font-roboto-mono text-sm font-semibold uppercase tracking-tight hover:bg-neutral-300">
          Connect Wallet
        </button>
      </div>
    </div>
  );
}
