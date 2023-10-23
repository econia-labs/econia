if (process.env.NEXT_PUBLIC_API_URL == null) {
  throw new Error("NEXT_PUBLIC_API_URL is not set");
} else if (process.env.NEXT_PUBLIC_WS_URL == null) {
  throw new Error("NEXT_PUBLIC_WS_URL is not set");
} else if (process.env.NEXT_PUBLIC_RPC_NODE_URL == null) {
  throw new Error("NEXT_PUBLIC_RPC_NODE_URL is not set");
} else if (process.env.NEXT_PUBLIC_ECONIA_ADDR == null) {
  throw new Error("NEXT_PUBLIC_ECONIA_ADDR is not set");
} else if (process.env.NEXT_PUBLIC_FAUCET_ADDR == null) {
  throw new Error("NEXT_PUBLIC_FAUCET_ADDR is not set");
} else if (process.env.NEXT_PUBLIC_NETWORK_NAME == null) {
  throw new Error("NEXT_PUBLIC_NETWORK_NAME is not set");
}

export const API_URL = process.env.NEXT_PUBLIC_API_URL;
export const WS_URL = process.env.NEXT_PUBLIC_WS_URL;
export const RPC_NODE_URL = process.env.NEXT_PUBLIC_RPC_NODE_URL;
export const ECONIA_ADDR = process.env.NEXT_PUBLIC_ECONIA_ADDR;
export const FAUCET_ADDR = process.env.NEXT_PUBLIC_FAUCET_ADDR;
export const NETWORK_NAME = process.env.NEXT_PUBLIC_NETWORK_NAME;

// todo: remove this when audit comes back
export const AUDIT_ADDR = process.env.NEXT_PUBLIC_AUDIT_ONLY_ADDR;
