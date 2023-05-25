import { ECONIA_ADDR } from "@/env";
import { type ApiCoin } from "./api";

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
type U64 = NumericString;

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

export type MoveTableWithLength = {
  handle: string;
  length: number;
};

export type TabList<K, _V = unknown> = {
  head: {
    vec: MoveOption<K>;
  };
  table: {
    inner: MoveTableWithLength;
  };
  tail: {
    vec: MoveOption<K>;
  };
};

export class TypeTag {
  constructor(
    public addr: string,
    public module: string,
    public name: string
  ) {}

  static fromApiCoin(apiCoin: ApiCoin) {
    return new TypeTag(
      apiCoin.account_address,
      apiCoin.module_name,
      apiCoin.struct_name
    );
  }

  static fromString(typeTag: string) {
    const [addr, module, name] = typeTag.split("::");
    return new TypeTag(addr, module, name);
  }

  toString() {
    return `${this.addr}::${this.module}::${this.name}`;
  }
}

export class TablistNode {
  constructor(public key: MovePrimitive, public value: string | TypeTag) {}

  toString() {
    return `${ECONIA_ADDR}::tablist::Node<${
      this.key
    },${this.value.toString()}>`;
  }
}

export class MarketAccountId {
  constructor(public marketId: number, public custodianId: number) {}

  toString() {
    const marketIdHex = BigInt(this.marketId).toString(16).padStart(16, "0");
    const custodianIdHex = BigInt(this.custodianId)
      .toString(16)
      .padStart(16, "0");
    return BigInt(`0x${marketIdHex}${custodianIdHex}`).toString();
  }
}
