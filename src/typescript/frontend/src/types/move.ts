type NumericString = `${
  | "0"
  | "1"
  | "2"
  | "3"
  | "4"
  | "5"
  | "6"
  | "7"
  | "8"
  | "9"}+`;
export type U64 = NumericString;
export type U128 = NumericString;

export type MoveOption<T> = [] | [T];
export type MovePrimitive = "u8" | "u64" | "u128" | "bool" | "address";
export type MoveEventHandle = {
  counter: U64;
  guid: {
    id: {
      addr: string;
      creation_num: U64;
    };
  };
};
export type MoveTableHandle = {
  handle: string;
};
export type MoveTypeInfo = {
  account_address: string;
  module_name: string;
  struct_name: string;
};
export type MoveCoin = {
  value: U64;
};
export type MoveTableWithLength = {
  handle: string;
  length: number;
};
