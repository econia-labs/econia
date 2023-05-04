/// See: https://econia.dev/off-chain
export const getMakerEventsCreationNumber = (marketId: number) => {
  return marketId * 2;
};

/// See: https://econia.dev/off-chain
export const getTakerEventsCreationNumber = (marketId: number) => {
  return marketId * 2 + 1;
};
