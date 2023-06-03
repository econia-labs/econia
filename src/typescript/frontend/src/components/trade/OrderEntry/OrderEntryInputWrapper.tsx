import {
  ReactElement,
  type PropsWithChildren,
  useRef,
  MutableRefObject,
  ReactNode,
} from "react";

export const OrderEntryInputWrapper: React.FC<
  PropsWithChildren<{
    startAdornment?: string;
    endAdornment?: string;
    labelFor?: string;
    inputWithRef?: (
      ref: MutableRefObject<null | HTMLInputElement>
    ) => ReactNode;
  }>
> = ({ startAdornment, endAdornment, labelFor, children, inputWithRef }) => {
  const ref = useRef<null | HTMLInputElement>(null);
  const handleFocus = () => {
    ref.current?.focus();
  };
  return (
    <div
      className="flex h-10 w-full items-baseline gap-2 border border-neutral-600 px-4 py-2"
      onClick={handleFocus}
    >
      {/* start adornment */}
      <label
        htmlFor={labelFor}
        className="flex h-full items-center whitespace-nowrap font-roboto-mono text-xs text-white"
      >
        {startAdornment}
      </label>
      {inputWithRef ? inputWithRef(ref) : children}
      {/* {children} */}
      {/* end adornment */}
      <span className="flex h-full items-center font-roboto-mono text-xs font-light text-neutral-400">
        {endAdornment}
      </span>
    </div>
  );
};
