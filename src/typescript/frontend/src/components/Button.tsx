export const Button: React.FC<React.ButtonHTMLAttributes<HTMLButtonElement>> = (
  props
) => {
  return (
    <button
      {...props}
      className="w-full bg-white p-3 text-left text-center text-lg font-semibold uppercase text-black"
    />
  );
};
