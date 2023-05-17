import { type PropsWithChildren } from "react";

export const OrderEntryInputWrapper: React.FC<
  PropsWithChildren<{
    startAdornment?: string;
    endAdornment?: string;
  }>
> = ({ startAdornment, endAdornment, children }) => {
  return (
    <div className="flex h-12 w-full items-baseline gap-2 border border-neutral-600 p-4">
      {/* start adornment */}
      <span className="flex h-full items-center whitespace-nowrap font-roboto-mono text-white">
        {startAdornment}
      </span>
      {children}
      {/* end adornment */}
      <span className="flex h-full items-center font-roboto-mono font-light text-neutral-400">
        {endAdornment}
      </span>
    </div>
  );
};
