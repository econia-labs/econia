import { type ApiMarket } from "@/types/api";

export const MOCK_MARKETS: ApiMarket[] = [
  {
    market_id: 1,
    name: "tETH-tUSDC",
    base: {
      account_address:
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
      module_name: "test_eth",
      struct_name: "TestETHCoin",
      symbol: "tETH",
      name: "TestETHCoin",
      decimals: 8,
    },
    base_name_generic: "",
    quote: {
      account_address:
        "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
      module_name: "test_usdc",
      struct_name: "TestUSDCoin",
      symbol: "tUSDC",
      name: "TestUSDCoin",
      decimals: 6,
    },
    lot_size: 1,
    tick_size: 1,
    min_size: 1,
    underwriter_id: 0,
    created_at: "2023-05-18T17:22:48.971737Z",
    recognized: true,
  },
  {
    market_id: 2,
    name: "EVGEN-DANI",
    base_name_generic: "",
    base: {
      account_address:
        "0xb3bed2571add05161c6a9a1e1c0d76a62e1d7beef62b6ea5eb58503f1ba283be",
      module_name: "evgen_coin",
      struct_name: "EvgenCoin",
      symbol: "EVGEN",
      name: "EvgenCoin",
      decimals: 6,
    },
    quote: {
      account_address:
        "0x6d8052a72fcf636d7661745ff1ae6d37b7e8cff53db6c285369be5e240d5c014",
      module_name: "danich_coin",
      struct_name: "DanichCoin",
      symbol: "DANI",
      name: "DanichCoin",
      decimals: 6,
    },
    lot_size: 1,
    min_size: 1,
    tick_size: 1,
    underwriter_id: 0,
    created_at: "2023-05-18T17:22:48.971737Z",
    recognized: false,
  },
];
