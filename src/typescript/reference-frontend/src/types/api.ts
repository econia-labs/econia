export type ApiCoin = {
  account_address: string;
  module_name: string;
  struct_name: string;
  symbol: string;
  name: string;
  decimals: number;
};

export type ApiMarket = {
  market_id: number;
  base: ApiCoin;
  base_name_generic: string | null;
  quote: ApiCoin;
  lot_size: number;
  tick_size: number;
  min_size: number;
  underwriter_id: number;
  created_at: string;
};
