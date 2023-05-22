import { ApiMarket } from "@/types/api";
import BigNumber from "bignumber.js";
import { useMemo } from "react";
import { Line } from "react-chartjs-2";

export const ZERO_BIGNUMBER = new BigNumber(0);

type PriceLevel = {
  price: number;
  size: number;
};

type OrderBook = {
  bids: PriceLevel[];
  asks: PriceLevel[];
};

export const DepthChart: React.FC<{
  marketData: ApiMarket;
}> = ({ marketData }) => {
  const baseCoinInfo = marketData?.base;
  const quoteCoinInfo = marketData?.quote;

  const { data, isLoading } = useQuery(
    ["orderBook", marketData.market_id],
    async () => {
      const response = await fetch(
        `https://dev.api.econia.exchange/market/${marketData.market_id}/orderbook?depth=60`
      );
      const data = await response.json();
      return data as OrderBook;
    },
    { keepPreviousData: true, refetchOnWindowFocus: false }
  );
  const { labels, bidData, askData, minPrice, maxPrice } = useMemo(() => {
    const labels: number[] = [];
    const bidData: (number | undefined)[] = [];
    const askData: (number | undefined)[] = [];
    let minPrice = Infinity;
    let maxPrice = -Infinity;
    if (orderBook.data) {
      // Get min and max price to set a range
      for (const order of orderBook.data.bids.concat(orderBook.data.asks)) {
        if (order.price.toJsNumber() < minPrice) {
          minPrice = order.price.toJsNumber();
        }
        if (order.price.toJsNumber() > maxPrice) {
          maxPrice = order.price.toJsNumber();
        }
      }

      // Append prices in ascending order to `labels`
      orderBook.data.bids
        .slice()
        .concat(orderBook.data.asks.slice())
        .sort(
          (
            a: { price: { toJsNumber: () => number } },
            b: { price: { toJsNumber: () => number } }
          ) => a.price.toJsNumber() - b.price.toJsNumber()
        )
        .forEach((o: { price: { toJsNumber: () => number } }) => {
          labels.push(o.price.toJsNumber());
          bidData.push(undefined);
          askData.push(undefined);
        });

      const bidPriceToSize = new Map<number, number>();
      const askPriceToSize = new Map<number, number>();
      for (const { price, size } of orderBook.data.bids) {
        const priceKey = price.toJsNumber();
        if (!bidPriceToSize.has(priceKey)) {
          bidPriceToSize.set(priceKey, 0);
        }
        bidPriceToSize.set(
          priceKey,
          bidPriceToSize.get(priceKey)! + size.toJsNumber()
        );
      }
      for (const { price, size } of orderBook.data.asks) {
        const priceKey = price.toJsNumber();
        if (!askPriceToSize.has(priceKey)) {
          askPriceToSize.set(priceKey, 0);
        }
        askPriceToSize.set(
          priceKey,
          askPriceToSize.get(priceKey)! + size.toJsNumber()
        );
      }

      let askAcc = ZERO_BIGNUMBER;
      for (let i = 0; i < labels.length; i++) {
        const price = labels[i];
        if (askPriceToSize.has(price))
          askAcc = askAcc.plus(askPriceToSize.get(price)!);
        if (askAcc.gt(0))
          askData[i] = toDecimalSize({
            size: askAcc,
            lotSize: market.lotSize,
            baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
          }).toNumber();
      }

      // We go in reverse order to get the accumulated bid size
      let bidAcc = ZERO_BIGNUMBER;
      for (let i = labels.length - 1; i >= 0; i--) {
        const price = labels[i];
        if (bidPriceToSize.has(price))
          bidAcc = bidAcc.plus(bidPriceToSize.get(price)!);
        if (bidAcc.gt(0))
          bidData[i] = toDecimalSize({
            size: bidAcc,
            lotSize: market.lotSize,
            baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
          }).toNumber();
      }

      labels.forEach((price, i) => {
        labels[i] = toDecimalPrice({
          price: new BigNumber(price),
          lotSize: market.lotSize,
          tickSize: market.tickSize,
          baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
          quoteCoinDecimals: BigNumber(quoteCoinInfo?.decimals || 0),
        }).toNumber();
      });
    }
    return {
      labels,
      bidData,
      askData,
      minPrice: toDecimalPrice({
        price: new BigNumber(minPrice),
        lotSize: market.lotSize,
        tickSize: market.tickSize,
        baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
        quoteCoinDecimals: BigNumber(quoteCoinInfo?.decimals || 0),
      }),
      maxPrice: toDecimalPrice({
        price: new BigNumber(maxPrice),
        lotSize: market.lotSize,
        tickSize: market.tickSize,
        baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
        quoteCoinDecimals: BigNumber(quoteCoinInfo?.decimals || 0),
      }),
    };
  }, [market, baseCoinInfo, quoteCoinInfo, orderBook.data]);

  return (
    <Line
      options={{
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
        },
        plugins: {
          legend: {
            display: false,
          },
          tooltip: {
            // style tooltip to match the theme
            callbacks: {
              label: (item: { label: any; raw: any }) => {
                return [
                  `Price: ${item.label} ${quoteCoinInfo?.symbol}`,
                  `Total Size: ${item.raw} ${baseCoinInfo?.symbol}`,
                ];
              },
              title: () => "",
            },
            displayColors: false,
            bodyAlign: "right",
          },
        },
        scales: {
          x: {
            grid: {
              display: true,
              color: "gray",
              // color: theme.colors.grey[700],
            },
            // We don't use linear for now because it doesn't ensure that the graph fits nicely in tick sizes
            // type: "linear",
            // ticks: {
            //   stepSize,
            // },
          },
          y: {
            grid: {
              display: true,
              color: "gray",
            },
            beginAtZero: true,
          },
        },
      }}
      data={{
        labels,
        datasets: [
          {
            fill: true,
            label: "Size",
            data: bidData,
            borderColor: "green",
            backgroundColor: "green" + "44",
            stepped: true,
          },
          {
            fill: true,
            label: "Size",
            data: askData,
            borderColor: "red",
            backgroundColor: "red" + "44",
            stepped: true,
          },
        ],
      }}
    />
  );
};

const TEN = new BigNumber(10);
export const toDecimalPrice = ({
  price,
  lotSize,
  tickSize,
  baseCoinDecimals,
  quoteCoinDecimals,
}: {
  price: BigNumber;
  lotSize: BigNumber;
  tickSize: BigNumber;
  baseCoinDecimals: BigNumber;
  quoteCoinDecimals: BigNumber;
}) => {
  const lotsPerUnit = TEN.exponentiatedBy(baseCoinDecimals).div(lotSize);
  const pricePerLot = price
    .multipliedBy(tickSize)
    .div(TEN.exponentiatedBy(quoteCoinDecimals));
  return pricePerLot.multipliedBy(lotsPerUnit);
};

export const toDecimalSize = ({
  size,
  lotSize,
  baseCoinDecimals,
}: {
  size: BigNumber;
  lotSize: BigNumber;
  baseCoinDecimals: BigNumber;
}) => {
  return size.multipliedBy(lotSize).div(TEN.exponentiatedBy(baseCoinDecimals));
};
function useQuery(
  arg0: (string | number)[],
  arg1: () => Promise<OrderBook>,
  arg2: { keepPreviousData: boolean; refetchOnWindowFocus: boolean }
): { data: any; isLoading: any } {
  throw new Error("Function not implemented.");
}
