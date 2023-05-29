export const makeMarketAccountId = (marketId: number, custodianId: number) => {
  const marketIdHex = BigInt(marketId).toString(16).padStart(16, "0");
  const custodianIdHex = BigInt(custodianId).toString(16).padStart(16, "0");
  return BigInt(`0x${marketIdHex}${custodianIdHex}`).toString();
};
