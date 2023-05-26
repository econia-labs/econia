import { useQuery } from "@tanstack/react-query";
import BigNumber from "bignumber.js";
import {
  CategoryScale,
  Chart,
  Filler,
  Legend,
  LinearScale,
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

Chart.defaults.font.family = "Roboto Mono";
Chart.defaults.animation = false;

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
    console.log(labels, data);
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
    <div className="relative h-1/5 flex-[1_1_0%]">
      <p className={"absolute ml-4 mt-2 font-jost text-white"}>Depth</p>
      <Line
        options={{
          responsive: true,

          elements: {
            line: { stepped: true, borderWidth: 1 },
            point: {
              hoverRadius: 3,
              radius: 0,
              hoverBorderColor: "white",
              hoverBackgroundColor: "none",
              borderWidth: 5,
            },
          },
          maintainAspectRatio: false,
          interaction: {
            intersect: false,
          },
          plugins: {
            // needed to add this because crosshair is not a native plugin
            // one way to fix this is to extend the chart.js types
            // eslint-disable-next-line @typescript-eslint/ban-ts-comment
            // @ts-ignore
            crosshair: {
              color: "white",
            },
            title: {
              display: true,
              text: `MID MARKET $${labels[labels.length / 2]}`,
              color: "white",
            },
            animation: {
              duration: 0,
            },
            responsiveAnimationDuration: 0,
            showLine: false,
            legend: {
              display: false,
            },
            tooltip: {
              // style tooltip to match the theme
              // enabled: false,
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
              ticks: {
                maxRotation: 0,
                color: "white",
                autoSkip: false,
                minRotation: 0,
                callback: function (value, index, values) {
                  // show 1/3 and 2/3 of the way through
                  if (
                    index === Math.floor(values.length / 4) ||
                    index === Math.floor((3 * values.length) / 4)
                  ) {
                    return labels[index];
                  } else {
                    return "";
                  }
                },
              },
            },
            y: {
              position: "right",
              max: Math.max(bidData[0] || 0, askData[askData.length - 1] || 0),
              ticks: {
                color: "white",
                maxTicksLimit: 2,
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
              borderColor: "rgba(110, 213, 163, 1)",
              backgroundColor: "rgba(110, 213, 163, 0.3)",
              stepped: true,
            },
            {
              fill: true,
              label: "Size",
              data: askData,
              borderColor: "rgba(213, 110, 110, 1)",
              backgroundColor: "rgba(213, 110, 110, 0.3)",
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

interface CorsairPluginOptions {
  width: number;
  color: string;
  dash: number[];
}

const plugin = {
  id: "crosshair",
  defaults: {
    width: 1,
    color: "#FF4949",
    dash: [2, 2],
  },
  afterInit: (
    chart: { corsair: { x: number; y: number } },
    args: any,
    opts: any
  ) => {
    chart.corsair = {
      x: 0,
      y: 0,
    };
  },
  afterEvent: (
    chart: { corsair: { x: any; y: any; draw: any }; draw: () => void },
    args: { event?: any; inChartArea?: any }
  ) => {
    const { inChartArea } = args;
    const { type, x, y } = args.event;

    chart.corsair = { x, y, draw: inChartArea };
    chart.draw();
  },
  beforeDatasetsDraw: (
    chart: {
      _active: any;
      chartArea?: any;
      corsair?: any;
      ctx?: any;
    },
    args: any,
    opts: { width: any; color: any; dash: any }
  ) => {
    const { ctx } = chart;
    const { top, bottom, left, right } = chart.chartArea;
    let { x, y } = chart.corsair;
    const { draw } = chart.corsair;

    if (chart._active.length) {
      x = chart._active[0].element.x;
      y = chart._active[0].element.y;
    }
    if (!draw) return;

    ctx.save();

    ctx.beginPath();
    ctx.lineWidth = opts.width;
    ctx.strokeStyle = opts.color;
    ctx.setLineDash(opts.dash);
    ctx.moveTo(x, bottom);
    ctx.lineTo(x, top);
    ctx.moveTo(left, y);
    ctx.lineTo(right, y);
    ctx.stroke();

    ctx.restore();
  },
};
Chart.register(plugin);
