import { type PropsWithChildren } from "react";

export const OrderEntryInputWrapper: React.FC<
  PropsWithChildren<{
    startAdornment?: string;
    endAdornment?: string;
    labelFor?: string;
  }>
> = ({ startAdornment, endAdornment, labelFor, children }) => {
  return (
    <div className="flex h-10 w-full items-baseline gap-2 border border-neutral-600 px-4 py-2">
      {/* start adornment */}
      <label
        htmlFor={labelFor}
        className="flex h-full min-w-[80px] items-center whitespace-nowrap font-roboto-mono text-xs text-white"
      >
        {startAdornment}
      </label>
      {children}
      {/* end adornment */}
      <span className="flex h-full min-w-[37px] items-center font-roboto-mono text-xs font-light text-neutral-400">
        {endAdornment}
      </span>
    </div>
  );
};
