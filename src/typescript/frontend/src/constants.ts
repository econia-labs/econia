import { type SimulationKeys, u64 } from "@manahippo/move-to-ts";
import { HexString } from "aptos";
import BigNumber from "bignumber.js";

import { moduleAddress as econiaAddr } from "./sdk/src/econia/registry";

// NOTE: This is the resource account of `@econia`. This must be changed if
// @econia changes.
export const ORDER_BOOKS_ADDR = new HexString(
  "0x1f4e6edbb26c78bdf8dbd771a54445f221c47af340457bf5a1bff34cd9f419bb"
);

export const ECONIA_ADDR = econiaAddr;

export const ECONIA_SIMULATION_KEYS: SimulationKeys = {
  pubkey: new HexString(
    "0x86a82c05d5d89b65e684db85cfb77e8475d99b97ef31de5ae8bdf6152b2f3974"
  ),
  address: econiaAddr,
};

// NOTE: Change this address to receive fees
export const INTEGRATOR_ADDR = new HexString(
  "0x2e51979739db25dc987bd24e1a968e45cca0e0daea7cae9121f68af93e8884c9"
);

export const ASK = true;
export const BID = false;
export const SELL = true;
export const BUY = false;

export const ZERO_U64 = u64(0);
export const ZERO_BIGNUMBER = new BigNumber(0);

export const MOBILE_MAX_WIDTH = 800;

export const DEFAULT_MARKET_ID = 4;
