import React from "react";

export const OrderEntryInput: React.FC<{
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  startAdornment?: string;
  endAdornment?: string;
  disabled?: boolean;
  type: "text" | "number";
}> = ({
  value,
  onChange,
  placeholder,
  startAdornment,
  endAdornment,
  disabled,
  type,
}) => {
  return (
    <div className="flex h-12 w-full items-baseline gap-2 border border-neutral-600 p-4">
      {/* start adornment */}
      <span className="flex h-full items-center whitespace-nowrap font-roboto-mono text-white">
        {startAdornment}
      </span>
      <input
        className="h-full w-[100px] flex-1 bg-transparent text-right font-roboto-mono font-light text-neutral-400 outline-none"
        value={value}
        placeholder={placeholder}
        onChange={(e) => {
          if (!onChange) return;
          if (type == "number") {
            if (isNaN(Number(e.target.value))) return;
          }
          onChange(e.target.value);
        }}
        disabled={disabled}
      />
      {/* end adornment */}
      <span className="flex h-full items-center font-roboto-mono font-light text-neutral-400">
        {endAdornment}
      </span>
    </div>
  );
};
