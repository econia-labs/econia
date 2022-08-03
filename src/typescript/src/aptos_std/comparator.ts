import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "comparator";

export const EQUAL : U8 = u8("0");
export const GREATER : U8 = u8("2");
export const SMALLER : U8 = u8("1");


export class Result 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Result";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "inner", typeTag: AtomicTypeTag.U8 }];

  inner: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto['inner'] as U8;
  }

  static ResultParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Result {
    const proto = $.parseStructProto(data, typeTag, repo, Result);
    return new Result(proto, typeTag);
  }

}
export function compare_ (
  left: any,
  right: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): Result {
  let left_bytes, right_bytes;
  left_bytes = Std.Bcs.to_bytes_(left, $c, [$p[0]]);
  right_bytes = Std.Bcs.to_bytes_(right, $c, [$p[0]]);
  return compare_u8_vector_($.copy(left_bytes), $.copy(right_bytes), $c);
}

export function compare_u8_vector_ (
  left: U8[],
  right: U8[],
  $c: AptosDataCache,
): Result {
  let temp$1, temp$2, temp$3, idx, left_byte, left_length, right_byte, right_length;
  left_length = Std.Vector.length_(left, $c, [AtomicTypeTag.U8]);
  right_length = Std.Vector.length_(right, $c, [AtomicTypeTag.U8]);
  idx = u64("0");
  while (true) {
    {
      if (($.copy(idx)).lt($.copy(left_length))) {
        temp$1 = ($.copy(idx)).lt($.copy(right_length));
      }
      else{
        temp$1 = false;
      }
    }
    if (!(temp$1)) break;
    {
      left_byte = $.copy(Std.Vector.borrow_(left, $.copy(idx), $c, [AtomicTypeTag.U8]));
      right_byte = $.copy(Std.Vector.borrow_(right, $.copy(idx), $c, [AtomicTypeTag.U8]));
      if (($.copy(left_byte)).lt($.copy(right_byte))) {
        return new Result({ inner: SMALLER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
      }
      else{
        if (($.copy(left_byte)).gt($.copy(right_byte))) {
          return new Result({ inner: GREATER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
        }
        else{
        }
      }
      idx = ($.copy(idx)).add(u64("1"));
    }

  }if (($.copy(left_length)).lt($.copy(right_length))) {
    temp$3 = new Result({ inner: SMALLER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
  }
  else{
    if (($.copy(left_length)).gt($.copy(right_length))) {
      temp$2 = new Result({ inner: GREATER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
    }
    else{
      temp$2 = new Result({ inner: EQUAL }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
    }
    temp$3 = temp$2;
  }
  return temp$3;
}

export function is_equal_ (
  result: Result,
  $c: AptosDataCache,
): boolean {
  return ($.copy(result.inner)).eq((EQUAL));
}

export function is_greater_than_ (
  result: Result,
  $c: AptosDataCache,
): boolean {
  return ($.copy(result.inner)).eq((GREATER));
}

export function is_smaller_than_ (
  result: Result,
  $c: AptosDataCache,
): boolean {
  return ($.copy(result.inner)).eq((SMALLER));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::comparator::Result", Result.ResultParser);
}

