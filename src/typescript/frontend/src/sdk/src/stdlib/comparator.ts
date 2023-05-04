import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import {
  type FieldDeclType,
  type TypeParamDeclType,
} from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
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

import * as Bcs from "./bcs";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "comparator";

export const EQUAL: U8 = u8("0");
export const GREATER: U8 = u8("2");
export const SMALLER: U8 = u8("1");

export class Result {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Result";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "inner", typeTag: AtomicTypeTag.U8 },
  ];

  inner: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto["inner"] as U8;
  }

  static ResultParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Result {
    const proto = $.parseStructProto(data, typeTag, repo, Result);
    return new Result(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Result", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function compare_(
  left: any,
  right: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): Result {
  let left_bytes, right_bytes;
  left_bytes = Bcs.to_bytes_(left, $c, [$p[0]]);
  right_bytes = Bcs.to_bytes_(right, $c, [$p[0]]);
  return compare_u8_vector_($.copy(left_bytes), $.copy(right_bytes), $c);
}

export function compare_u8_vector_(
  left: U8[],
  right: U8[],
  $c: AptosDataCache
): Result {
  let temp$1,
    temp$2,
    temp$3,
    idx,
    left_byte,
    left_length,
    right_byte,
    right_length;
  left_length = Vector.length_(left, $c, [AtomicTypeTag.U8]);
  right_length = Vector.length_(right, $c, [AtomicTypeTag.U8]);
  idx = u64("0");
  while (true) {
    {
      if ($.copy(idx).lt($.copy(left_length))) {
        temp$1 = $.copy(idx).lt($.copy(right_length));
      } else {
        temp$1 = false;
      }
    }
    if (!temp$1) break;
    {
      left_byte = $.copy(
        Vector.borrow_(left, $.copy(idx), $c, [AtomicTypeTag.U8])
      );
      right_byte = $.copy(
        Vector.borrow_(right, $.copy(idx), $c, [AtomicTypeTag.U8])
      );
      if ($.copy(left_byte).lt($.copy(right_byte))) {
        return new Result(
          { inner: $.copy(SMALLER) },
          new SimpleStructTag(Result)
        );
      } else {
        if ($.copy(left_byte).gt($.copy(right_byte))) {
          return new Result(
            { inner: $.copy(GREATER) },
            new SimpleStructTag(Result)
          );
        } else {
        }
      }
      idx = $.copy(idx).add(u64("1"));
    }
  }
  if ($.copy(left_length).lt($.copy(right_length))) {
    temp$3 = new Result(
      { inner: $.copy(SMALLER) },
      new SimpleStructTag(Result)
    );
  } else {
    if ($.copy(left_length).gt($.copy(right_length))) {
      temp$2 = new Result(
        { inner: $.copy(GREATER) },
        new SimpleStructTag(Result)
      );
    } else {
      temp$2 = new Result(
        { inner: $.copy(EQUAL) },
        new SimpleStructTag(Result)
      );
    }
    temp$3 = temp$2;
  }
  return temp$3;
}

export function is_equal_(result: Result, $c: AptosDataCache): boolean {
  return $.copy(result.inner).eq($.copy(EQUAL));
}

export function is_greater_than_(result: Result, $c: AptosDataCache): boolean {
  return $.copy(result.inner).eq($.copy(GREATER));
}

export function is_smaller_than_(result: Result, $c: AptosDataCache): boolean {
  return $.copy(result.inner).eq($.copy(SMALLER));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::comparator::Result", Result.ResultParser);
}
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
  get Result() {
    return Result;
  }
}
