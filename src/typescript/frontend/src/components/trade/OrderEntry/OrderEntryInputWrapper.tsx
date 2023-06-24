import { type PropsWithChildren } from "react";

export const OrderEntryInputWrapper: React.FC<
  PropsWithChildren<{
    startAdornment?: string;
    endAdornment?: string;
    labelFor?: string;
    className?: string;
  }>
> = ({ startAdornment, endAdornment, labelFor, className, children }) => {
  return (
    <div
      className={`relative flex h-10 w-full items-center border border-neutral-600 ${className}`}
    >
      <label
        htmlFor={labelFor}
        className="absolute left-3 z-20 font-roboto-mono text-xs uppercase text-white"
      >
        {startAdornment}
      </label>
      <span className="absolute right-3 z-20 font-roboto-mono text-xs font-light text-neutral-400">
        {endAdornment}
      </span>
      {children}
    </div>
  );
};
