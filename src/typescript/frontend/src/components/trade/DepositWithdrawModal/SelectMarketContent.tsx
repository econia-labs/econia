import { ApiMarket } from "@/types/api";
import { useAllMarketData } from ".";

export const SelectMarketContent: React.FC<{
  onSelectMarket: (market: ApiMarket) => void;
}> = ({ onSelectMarket }) => {
  const allMarketData = useAllMarketData();
  return (
    <div className="flex w-full flex-col items-center gap-6">
      <h4 className="font-jost text-3xl font-bold text-white">
        Select a Market
      </h4>

      <div className="max-h-50 flex flex-col gap-2 overflow-y-scroll">
        {allMarketData.data?.map((market) => (
          <div
            key={market.market_id}
            className="flex cursor-pointer items-center gap-2 border border-white p-4"
            onClick={() => onSelectMarket(market)}
          >
            <p className="whitespace-nowrap text-white">{market.name}</p>
          </div>
        ))}
      </div>
    </div>
  );
};
