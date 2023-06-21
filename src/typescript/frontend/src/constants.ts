import {
  DEFAULT_TESTNET_LIST,
  PERMISSIONED_LIST,
  type RawCoinInfo,
} from "@manahippo/coin-list";

export const NO_CUSTODIAN = 0;

export const TESTNET_TOKEN_LIST: RawCoinInfo[] = [
  ...DEFAULT_TESTNET_LIST.map((coin) => {
    // Overrides
    if (coin.symbol === "APT") {
      coin.logo_url = "/tokenImages/APT.png";
    }
    return coin;
  }),
  // Additions
  {
    name: "Test ETH",
    symbol: "tETH",
    official_symbol: "tETH",
    coingecko_id: "",
    decimals: 8,
    logo_url: "/tokenImages/tETH.png",
    project_url: "",
    token_type: {
      type: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_eth::TestETHCoin",
      account_address:
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
      module_name: "test_eth",
      struct_name: "TestETHCoin",
    },
    extensions: {
      data: [],
    },
    unique_index: DEFAULT_TESTNET_LIST.length + 1,
  },
  {
    name: "Test USDC",
    symbol: "tUSDC",
    official_symbol: "tUSDC",
    coingecko_id: "",
    decimals: 6,
    logo_url: "/tokenImages/tUSDC.png",
    project_url: "",
    token_type: {
      type: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942::test_usdc::TestUSDCoin",
      account_address:
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
      module_name: "test_usdc",
      struct_name: "TestUSDCoin",
    },
    extensions: {
      data: [],
    },
    unique_index: DEFAULT_TESTNET_LIST.length + 2,
  },
];

export const MAINNET_TOKEN_LIST: RawCoinInfo[] = [
  ...PERMISSIONED_LIST.map((coin) => {
    // Overrides
    if (coin.symbol === "APT") {
      coin.logo_url = "/tokenImages/APT.png";
    }
    return coin;
  }),
  // Additions
];
