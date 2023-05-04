import { type HexString } from "aptos";

export const shortenAddress = (addr: HexString, first = 6, last = 4) => {
  return `${addr.toString().slice(0, first)}...${addr
    .toString()
    .slice(addr.toString().length - last)}`;
};
