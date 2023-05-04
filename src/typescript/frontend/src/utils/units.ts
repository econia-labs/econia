import BigNumber from "bignumber.js";

const TEN = new BigNumber(10);

export const fromDecimalPrice = ({
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
  const ticksPerUnit = price
    .multipliedBy(TEN.exponentiatedBy(quoteCoinDecimals))
    .div(tickSize);
  const lotsPerUnit = TEN.exponentiatedBy(baseCoinDecimals).div(lotSize);
  return ticksPerUnit.div(lotsPerUnit).decimalPlaces(0, BigNumber.ROUND_UP);
};

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

export const fromDecimalSize = ({
  size,
  lotSize,
  baseCoinDecimals,
}: {
  size: BigNumber;
  lotSize: BigNumber;
  baseCoinDecimals: BigNumber;
}) => {
  return new BigNumber(
    Math.floor(
      size
        .multipliedBy(TEN.exponentiatedBy(baseCoinDecimals))
        .div(lotSize)
        .toNumber()
    )
  );
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

export const toDecimalQuote = ({
  ticks,
  tickSize,
  quoteCoinDecimals,
}: {
  ticks: BigNumber;
  tickSize: BigNumber;
  quoteCoinDecimals: BigNumber;
}) => {
  return ticks
    .multipliedBy(tickSize)
    .div(TEN.exponentiatedBy(quoteCoinDecimals));
};

export const fromDecimalQuote = ({
  quote,
  tickSize,
  quoteCoinDecimals,
}: {
  quote: BigNumber;
  tickSize: BigNumber;
  quoteCoinDecimals: BigNumber;
}) => {
  return new BigNumber(
    Math.floor(
      quote
        .multipliedBy(TEN.exponentiatedBy(quoteCoinDecimals))
        .div(tickSize)
        .toNumber()
    )
  );
};

export const toDecimalCoin = ({
  amount,
  decimals,
}: {
  amount: BigNumber;
  decimals: BigNumber;
}) => {
  return amount.div(TEN.exponentiatedBy(decimals));
};

export const fromDecimalCoin = ({
  amount,
  decimals,
}: {
  amount: BigNumber;
  decimals: BigNumber;
}) => {
  return amount.multipliedBy(TEN.exponentiatedBy(decimals));
};
