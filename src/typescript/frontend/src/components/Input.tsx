export const Input: React.FC<React.InputHTMLAttributes<HTMLInputElement>> = (
  props
) => {
  return (
    <input
      {...props}
      className={
        "w-full border bg-black p-3 text-left font-roboto-mono text-lg font-light text-gray-400" +
        " " +
        props.className
      }
    />
  );
};
