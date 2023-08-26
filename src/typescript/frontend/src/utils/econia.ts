import BigNumber from "bignumber.js";

const TEN = new BigNumber(10);

export const fromDecimalPrice = ({
  price,
  lotSize,
  tickSize,
  baseCoinDecimals,
  quoteCoinDecimals,
}: {
  price: BigNumber.Value;
  lotSize: BigNumber.Value;
  tickSize: BigNumber.Value;
  baseCoinDecimals: BigNumber.Value;
  quoteCoinDecimals: BigNumber.Value;
}) => {
  const ticksPerUnit = new BigNumber(price)
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
  size: BigNumber.Value;
  lotSize: BigNumber.Value;
  baseCoinDecimals: BigNumber.Value;
}) => {
  return new BigNumber(size)
    .multipliedBy(TEN.exponentiatedBy(baseCoinDecimals))
    .div(lotSize)
    .decimalPlaces(0, BigNumber.ROUND_DOWN);
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
        .toNumber(),
    ),
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

export const makeMarketAccountId = (marketId: number, custodianId: number) => {
  const marketIdHex = BigInt(marketId).toString(16).padStart(16, "0");
  const custodianIdHex = BigInt(custodianId).toString(16).padStart(16, "0");
  return BigInt(`0x${marketIdHex}${custodianIdHex}`).toString();
};
