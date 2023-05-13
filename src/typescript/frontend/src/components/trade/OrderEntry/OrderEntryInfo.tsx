export const OrderEntryInfo: React.FC<{
  label: string;
  value: string;
}> = ({ label, value }) => {
  return (
    <div className="flex justify-between font-roboto-mono font-light text-neutral-500">
      <p>{label}</p>
      <p>{value}</p>
    </div>
  );
};
