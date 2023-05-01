export const Input: React.FC<React.InputHTMLAttributes<HTMLInputElement>> = (
  props
) => {
  return (
    <input
      {...props}
      className="w-full border bg-black p-3 text-left text-lg text-gray-400"
    />
  );
};
