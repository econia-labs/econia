import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import { FieldDeclType, TypeParamDeclType } from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "math64";

export function average_(a: U64, b: U64, $c: AptosDataCache): U64 {
  let temp$1;
  if ($.copy(a).lt($.copy(b))) {
    temp$1 = $.copy(a).add($.copy(b).sub($.copy(a)).div(u64("2")));
  } else {
    temp$1 = $.copy(b).add($.copy(a).sub($.copy(b)).div(u64("2")));
  }
  return temp$1;
}

export function max_(a: U64, b: U64, $c: AptosDataCache): U64 {
  let temp$1;
  if ($.copy(a).ge($.copy(b))) {
    temp$1 = $.copy(a);
  } else {
    temp$1 = $.copy(b);
  }
  return temp$1;
}

export function min_(a: U64, b: U64, $c: AptosDataCache): U64 {
  let temp$1;
  if ($.copy(a).lt($.copy(b))) {
    temp$1 = $.copy(a);
  } else {
    temp$1 = $.copy(b);
  }
  return temp$1;
}

export function pow_(n: U64, e: U64, $c: AptosDataCache): U64 {
  let temp$1, p;
  if ($.copy(e).eq(u64("0"))) {
    temp$1 = u64("1");
  } else {
    p = u64("1");
    while ($.copy(e).gt(u64("1"))) {
      {
        if ($.copy(e).mod(u64("2")).eq(u64("1"))) {
          p = $.copy(p).mul($.copy(n));
        } else {
        }
        e = $.copy(e).div(u64("2"));
        n = $.copy(n).mul($.copy(n));
      }
    }
    temp$1 = $.copy(p).mul($.copy(n));
  }
  return temp$1;
}

export function loadParsers(repo: AptosParserRepo) {}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {}
  get moduleAddress() {
    {
      return moduleAddress;
    }
  }
  get moduleName() {
    {
      return moduleName;
    }
  }
}
