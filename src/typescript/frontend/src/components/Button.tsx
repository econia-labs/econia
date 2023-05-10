export const Button: React.FC<
  React.ButtonHTMLAttributes<HTMLButtonElement> & {
    variant: "primary" | "outlined";
  }
> = ({ variant, ...props }) => {
  const variantStyle =
    variant === "primary"
      ? "bg-neutral-100 text-neutral-800"
      : "bg-neutral-800 text-neutral-100 border border-neutral-100";
  return (
    <button
      {...props}
      className={[
        "px-4 py-2 text-center font-jost text-lg font-semibold",
        variantStyle,
        props.className,
      ].join(" ")}
    />
  );
};
