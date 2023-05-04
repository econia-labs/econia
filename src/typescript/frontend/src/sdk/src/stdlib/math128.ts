import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, U64, type U128 } from "@manahippo/move-to-ts";
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
export const moduleName = "math128";

export function average_(a: U128, b: U128, $c: AptosDataCache): U128 {
  let temp$1;
  if ($.copy(a).lt($.copy(b))) {
    temp$1 = $.copy(a).add($.copy(b).sub($.copy(a)).div(u128("2")));
  } else {
    temp$1 = $.copy(b).add($.copy(a).sub($.copy(b)).div(u128("2")));
  }
  return temp$1;
}

export function max_(a: U128, b: U128, $c: AptosDataCache): U128 {
  let temp$1;
  if ($.copy(a).ge($.copy(b))) {
    temp$1 = $.copy(a);
  } else {
    temp$1 = $.copy(b);
  }
  return temp$1;
}

export function min_(a: U128, b: U128, $c: AptosDataCache): U128 {
  let temp$1;
  if ($.copy(a).lt($.copy(b))) {
    temp$1 = $.copy(a);
  } else {
    temp$1 = $.copy(b);
  }
  return temp$1;
}

export function pow_(n: U128, e: U128, $c: AptosDataCache): U128 {
  let temp$1, p;
  if ($.copy(e).eq(u128("0"))) {
    temp$1 = u128("1");
  } else {
    p = u128("1");
    while ($.copy(e).gt(u128("1"))) {
      {
        if ($.copy(e).mod(u128("2")).eq(u128("1"))) {
          p = $.copy(p).mul($.copy(n));
        } else {
        }
        e = $.copy(e).div(u128("2"));
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
