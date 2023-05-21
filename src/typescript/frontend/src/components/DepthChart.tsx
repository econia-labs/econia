import type AxisRendererProps from "@visx/axis/lib/axis/AxisRenderer";
import type Scale from "@visx/axis/lib/axis/AxisRenderer";
import type AxisScale from "@visx/axis/lib/types";
import { Axis as AxisLib, XYChart as XYChartLib } from "@visx/visx";
import { type ReactNode } from "react";

const data1 = [
  { x: 0, y: 50 },
  { x: 1, y: 10 },
  { x: 2, y: 30 },
];

// for (let i = 3; i < 103; i++) {
//   const newDataPoint = { x: i, y: Math.floor(Math.random() * 100) };
//   data1.push(newDataPoint);
// }
const data2 = [
  { x: 2, y: 30 },
  { x: 3, y: 40 },
  { x: 4, y: 80 },
];

// const data2 = [
//   { x: 103, y: 30 },
//   { x: 104, y: 40 },
//   { x: 105, y: 80 },
// ];
// for (let i = 105; i < 205; i++) {
//   const newDataPoint = { x: i, y: Math.floor(Math.random() * 100) };
//   data2.push(newDataPoint);
// }

const accessors = {
  xAccessor: (d: { x: number }) => d.x,
  yAccessor: (d: { y: number }) => d.y,
};
type xyDatum = { x: string; y: number };
type xDatum = { x: number };
type yDatum = { y: number };

export const DepthChart = () => {
  const {
    Axis,
    Grid,
    AreaSeries,
    Tooltip,
    XYChart,
    darkTheme,
    AreaStack,
    buildChartTheme,
  } = XYChartLib;
  const customTheme = buildChartTheme({
    // colors
    backgroundColor: "#000", // used by Tooltip, Annotation
    colors: ["rgba(110, 213, 163, 1)", "rgba(213, 110, 110, 1)"], // categorical colors, mapped to series via `dataKey`s
    tickLength: 4,
    svgLabelSmall: {
      fill: "white",
    },
    svgLabelBig: {
      fill: "white",
    },
    gridColor: "white",
    gridColorDark: "white",
    // labels
    // svgLabelBig?: SVGTextProps;
    // svgLabelSmall?: SVGTextProps;
    // htmlLabel?: HTMLTextStyles;

    // lines
    // xAxisLineStyles?: LineStyles;
    // yAxisLineStyles?: LineStyles;
    // xTickLineStyles?: LineStyles;
    // yTickLineStyles?: LineStyles;
    // tickLength: number;

    // grid
    // gridColor: string;
    // gridColorDark: string; // used for axis baseline if x/yxAxisLineStyles not set
    // gridStyles?: CSSProperties;
  });
  return (
    <XYChart
      height={300}
      xScale={{ type: "band" }}
      yScale={{ type: "linear" }}
      theme={customTheme}
    >
      <Axis orientation="bottom" hideTicks />
      <Axis orientation="right" hideTicks></Axis>
      {/* <Grid columns={false} numTicks={4} /> */}

      <AreaSeries
        dataKey="Line 1"
        data={data1}
        {...accessors}
        fillOpacity={0.4}
      />
      <AreaSeries
        dataKey="Line 2"
        data={data2}
        {...accessors}
        fillOpacity={0.4}
      />

      <Tooltip
        snapTooltipToDatumX
        snapTooltipToDatumY
        showVerticalCrosshair
        showHorizontalCrosshair
        verticalCrosshairStyle={{
          stroke: "#fff",
          strokeDasharray: "2,2",
        }}
        horizontalCrosshairStyle={{
          stroke: "#fff",
          strokeDasharray: "2,2",
        }}
        // applyPositionStyle
        // unstyled
        showSeriesGlyphs={false}
        renderTooltip={({ tooltipData, colorScale }) => {
          if (!tooltipData) return null;
          if (!tooltipData.nearestDatum) return null;
          if (!colorScale) return null;

          return (
            <div>
              {[tooltipData?.nearestDatum?.key]
                .filter((city) => city)
                .map((city) => {
                  return <div key={city}>test</div>;
                })}
              <div style={{ color: colorScale(tooltipData.nearestDatum.key) }}>
                {/* <div style={{ color: "Red" }}> */}
                {tooltipData.nearestDatum.key}
              </div>
              {accessors.xAccessor(tooltipData.nearestDatum.datum as xDatum)}
              {", "}
              {accessors.yAccessor(tooltipData.nearestDatum.datum as yDatum)}
            </div>
          );
        }}
      />
    </XYChart>
  );
};

/** wip for coinbase-like tooltip */

/**
 * 


 <XYChart
      height={300}
      xScale={{ type: "band" }}
      yScale={{ type: "linear" }}
      theme={darkTheme}
    >
      <Axis orientation="bottom" hideTicks />
      <Axis orientation="right" hideTicks>
        {({
          axisFromPoint,
          axisLineClassName,
          axisToPoint,
          hideAxisLine,
          hideTicks,
          horizontal,
          label = "",
          labelClassName,
          labelOffset = 14,
          labelProps = "defaultTextProps",
          orientation = Orientation.bottom,
          scale,
          stroke = "#222",
          strokeDasharray,
          strokeWidth = 1,
          tickClassName,
          tickComponent,
          tickLineProps,
          tickLabelProps,
          tickLength = 8,
          tickStroke = "#222",
          tickTransform,
          ticks,
          ticksComponent = Ticks,
        }: props) => {
          const tickLabelPropsDefault = {
            ...defaultTextProps,
            ...(typeof tickLabelProps === "object" ? tickLabelProps : null),
          };
          // compute the max tick label size to compute label offset
          const allTickLabelProps = ticks.map(({ value, index }) =>
            typeof tickLabelProps === "function"
              ? tickLabelProps(value, index, ticks)
              : tickLabelPropsDefault
          );
          const maxTickLabelFontSize = Math.max(
            10,
            ...allTickLabelProps.map((props) =>
              typeof props.fontSize === "number" ? props.fontSize : 0
            )
          );
          return (
            <>
              {ticksComponent({
                hideTicks,
                horizontal,
                orientation,
                scale,
                tickClassName,
                tickComponent,
                tickLabelProps: allTickLabelProps,
                tickStroke,
                tickTransform,
                ticks,
                strokeWidth,
                tickLineProps,
              })}

              {!hideAxisLine && (
                <Line
                  className={cx("visx-axis-line", axisLineClassName)}
                  from={axisFromPoint}
                  to={axisToPoint}
                  stroke={stroke}
                  strokeWidth={strokeWidth}
                  strokeDasharray={strokeDasharray}
                />
              )}

              {label && (
                <Text
                  className={cx("visx-axis-label", labelClassName)}
                  {...getLabelTransform({
                    labelOffset,
                    labelProps,
                    orientation,
                    range: scale.range(),
                    tickLabelFontSize: maxTickLabelFontSize,
                    tickLength,
                  })}
                  {...labelProps}
                >
                  {label}
                </Text>
              )}
            </>
          );
        }}
      </Axis>
      <Grid columns={false} numTicks={4} />
      <AreaSeries dataKey="Line 1" data={data1} {...accessors} />
      <Tooltip
        snapTooltipToDatumX
        snapTooltipToDatumY
        showVerticalCrosshair
        showHorizontalCrosshair
        applyPositionStyle
        // unstyled
        showSeriesGlyphs
        renderTooltip={({ tooltipData, colorScale }) => {
          if (!tooltipData) return null;
          if (!tooltipData.nearestDatum) return null;
          if (!colorScale) return null;
          return (
            <div>
              <div style={{ color: colorScale(tooltipData.nearestDatum.key) }}>
                {tooltipData.nearestDatum.key}
              </div>
              {accessors.xAccessor(tooltipData.nearestDatum.datum as xDatum)}
              {", "}
              {accessors.yAccessor(tooltipData.nearestDatum.datum as yDatum)}
            </div>
          );
        }}
      />
    </XYChart>


 */
