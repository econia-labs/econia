if (process.env.NEXT_PUBLIC_API_URL == null) {
  throw new Error("NEXT_PUBLIC_API_URL is not set");
} else if (process.env.NEXT_PUBLIC_RPC_URL == null) {
  throw new Error("NEXT_PUBLIC_RPC_URL is not defined");
} else if (process.env.NEXT_PUBLIC_NETWORK_NAME == null) {
  throw new Error("NEXT_PUBLIC_NETWORK_NAME is not defined");
} else if (
  process.env.NEXT_PUBLIC_NETWORK_NAME !== "mainnet" &&
  process.env.NEXT_PUBLIC_NETWORK_NAME !== "testnet"
) {
  throw new Error("NEXT_PUBLIC_NETWORK_NAME must be mainnet or testnet");
}

export const API_URL = process.env.NEXT_PUBLIC_API_URL;
export const RPC_URL = process.env.NEXT_PUBLIC_RPC_URL;
export const NETWORK_NAME = process.env.NEXT_PUBLIC_NETWORK_NAME;
