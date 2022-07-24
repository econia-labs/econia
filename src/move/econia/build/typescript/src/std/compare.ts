import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as vector$_ from "./vector";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "compare";

export const EQUAL : U8 = u8("0");
export const GREATER_THAN : U8 = u8("2");
export const LESS_THAN : U8 = u8("1");

export function cmp_bcs_bytes$ (
  v1: U8[],
  v2: U8[],
  $c: AptosDataCache,
): U8 {
  let temp$1, elem_cmp, i1, i2, len_cmp;
  i1 = vector$_.length$(v1, $c, [AtomicTypeTag.U8] as TypeTag[]);
  i2 = vector$_.length$(v2, $c, [AtomicTypeTag.U8] as TypeTag[]);
  len_cmp = cmp_u64$($.copy(i1), $.copy(i2), $c);
  while (true) {
    {
      if ($.copy(i1).gt(u64("0"))) {
        temp$1 = $.copy(i2).gt(u64("0"));
      }
      else{
        temp$1 = false;
      }
    }
    if (!(temp$1)) break;
    {
      i1 = $.copy(i1).sub(u64("1"));
      i2 = $.copy(i2).sub(u64("1"));
      elem_cmp = cmp_u8$($.copy(vector$_.borrow$(v1, $.copy(i1), $c, [AtomicTypeTag.U8] as TypeTag[])), $.copy(vector$_.borrow$(v2, $.copy(i2), $c, [AtomicTypeTag.U8] as TypeTag[])), $c);
      if ($.copy(elem_cmp).neq(u8("0"))) {
        return $.copy(elem_cmp);
      }
      else{
      }
    }

  }return $.copy(len_cmp);
}

export function cmp_u64$ (
  i1: U64,
  i2: U64,
  $c: AptosDataCache,
): U8 {
  let temp$1, temp$2;
  if ($.copy(i1).eq($.copy(i2))) {
    temp$2 = EQUAL;
  }
  else{
    if ($.copy(i1).lt($.copy(i2))) {
      temp$1 = LESS_THAN;
    }
    else{
      temp$1 = GREATER_THAN;
    }
    temp$2 = temp$1;
  }
  return temp$2;
}

export function cmp_u8$ (
  i1: U8,
  i2: U8,
  $c: AptosDataCache,
): U8 {
  let temp$1, temp$2;
  if ($.copy(i1).eq($.copy(i2))) {
    temp$2 = EQUAL;
  }
  else{
    if ($.copy(i1).lt($.copy(i2))) {
      temp$1 = LESS_THAN;
    }
    else{
      temp$1 = GREATER_THAN;
    }
    temp$2 = temp$1;
  }
  return temp$2;
}

export function loadParsers(repo: AptosParserRepo) {
}

