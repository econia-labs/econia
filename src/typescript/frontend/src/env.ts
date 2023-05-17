if (process.env.NEXT_PUBLIC_API_URL == null) {
  throw new Error("NEXT_PUBLIC_API_URL is not set");
} else if (process.env.NEXT_PUBLIC_RPC_NODE_URL == null) {
  throw new Error("NEXT_PUBLIC_RPC_NODE_URL is not set");
}

export const API_URL = process.env.NEXT_PUBLIC_API_URL;
export const RPC_NODE_URL = process.env.NEXT_PUBLIC_RPC_NODE_URL;
