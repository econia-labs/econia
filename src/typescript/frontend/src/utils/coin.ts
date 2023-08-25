import BigNumber from "bignumber.js";

export const toRawCoinAmount = (
  amount: BigNumber.Value,
  decimals: BigNumber.Value,
): BigNumber => {
  return new BigNumber(amount).times(new BigNumber(10).pow(decimals));
};

export const fromRawCoinAmount = (
  amount: BigNumber.Value,
  decimals: BigNumber.Value,
) => {
  return new BigNumber(amount)
    .dividedBy(new BigNumber(10).pow(decimals))
    .toNumber();
};
