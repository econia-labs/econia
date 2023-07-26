import { useState } from "react";

export const Button: React.FC<
  React.ButtonHTMLAttributes<HTMLButtonElement> & {
    variant: "primary" | "outlined" | "secondary" | "green" | "red";
    disabledReason?: string | null;
  }
> = ({ variant, disabled, disabledReason, children, onClick, ...props }) => {
  const variantStyle =
    variant === "primary"
      ? "bg-neutral-100 text-neutral-800"
      : variant === "green"
      ? "bg-green text-neutral-800"
      : variant === "red"
      ? "bg-red text-neutral-800"
      : variant === "outlined"
      ? "bg-neutral-800 text-neutral-100 ring-1 ring-neutral-100"
      : "bg-neutral-700 text-neutral-100"; // secondary
  const [loading, setLoading] = useState(false);

  return (
    <button
      {...props}
      className={[
        "px-4 py-2 text-center font-jost text-lg font-semibold disabled:cursor-not-allowed",
        variantStyle,
        props.className,
      ].join(" ")}
      onClick={async (e) => {
        setLoading(true);
        try {
          await onClick?.(e);
          // eslint-disable-next-line no-useless-catch
        } catch (e) {
          throw e;
        } finally {
          setLoading(false);
        }
      }}
      disabled={disabled || !!disabledReason || loading}
    >
      {disabledReason ? disabledReason : loading ? "Loading..." : children}
    </button>
  );
};
