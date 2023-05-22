import { useQuery } from "@tanstack/react-query";
import BigNumber from "bignumber.js";
import {
  CategoryScale,
  Chart,
  Filler,
  Legend,
  LinearScale,
  LineController,
  LineElement,
  PointElement,
  Title,
  Tooltip,
} from "chart.js";
import { useMemo } from "react";
import { Line } from "react-chartjs-2";

import { type ApiMarket } from "@/types/api";

export const ZERO_BIGNUMBER = new BigNumber(0);

Chart.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend
);

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

  const { data, isFetching } = useQuery(
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
    console.log("inf loop?");
    const labels: number[] = [];
    const bidData: (number | undefined)[] = [];
    const askData: (number | undefined)[] = [];
    let minPrice = Infinity;
    let maxPrice = -Infinity;
    if (!isFetching && data) {
      // Get min and max price to set a range
      for (const order of data.bids.concat(data.asks)) {
        if (order.price < minPrice) {
          minPrice = order.price;
        }
        if (order.price > maxPrice) {
          maxPrice = order.price;
        }
      }

      // Append prices in ascending order to `labels`
      data.bids
        .slice()
        .concat(data.asks.slice())
        .sort((a, b) => a.price - b.price)
        .forEach((o) => {
          labels.push(o.price);
          bidData.push(undefined);
          askData.push(undefined);
        });

      const bidPriceToSize = new Map<number, number>();
      const askPriceToSize = new Map<number, number>();
      for (const { price, size } of data.bids) {
        const priceKey = price;
        if (!bidPriceToSize.has(priceKey)) {
          bidPriceToSize.set(priceKey, 0);
        }
        bidPriceToSize.set(priceKey, bidPriceToSize.get(priceKey)! + size);
      }
      for (const { price, size } of data.asks) {
        const priceKey = price;
        if (!askPriceToSize.has(priceKey)) {
          askPriceToSize.set(priceKey, 0);
        }
        askPriceToSize.set(priceKey, askPriceToSize.get(priceKey)! + size);
      }

      let askAcc = ZERO_BIGNUMBER;
      for (let i = 0; i < labels.length; i++) {
        const price = labels[i];
        if (askPriceToSize.has(price))
          askAcc = askAcc.plus(askPriceToSize.get(price)!);
        if (askAcc.gt(0))
          askData[i] = toDecimalSize({
            size: askAcc,
            lotSize: BigNumber(marketData.lot_size),
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
            lotSize: BigNumber(marketData.lot_size),
            baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
          }).toNumber();
      }

      labels.forEach((price, i) => {
        labels[i] = toDecimalPrice({
          price: new BigNumber(price),
          lotSize: BigNumber(marketData.lot_size),
          tickSize: BigNumber(marketData.tick_size),
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
        lotSize: BigNumber(marketData.lot_size),
        tickSize: BigNumber(marketData.tick_size),
        baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
        quoteCoinDecimals: BigNumber(quoteCoinInfo?.decimals || 0),
      }),
      maxPrice: toDecimalPrice({
        price: new BigNumber(maxPrice),
        lotSize: BigNumber(marketData.lot_size),
        tickSize: BigNumber(marketData.tick_size),
        baseCoinDecimals: BigNumber(baseCoinInfo?.decimals || 0),
        quoteCoinDecimals: BigNumber(quoteCoinInfo?.decimals || 0),
      }),
    };
  }, [marketData, baseCoinInfo, quoteCoinInfo, data, isFetching]);

  return (
    <div>
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
    </div>
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
