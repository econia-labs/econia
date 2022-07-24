import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
export const packageName = "AptosFramework";
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
export function compare$ (
  left: any,
  right: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): Result {
  let left_bytes, right_bytes;
  left_bytes = std$_.bcs$_.to_bytes$(left, $c, [$p[0]] as TypeTag[]);
  right_bytes = std$_.bcs$_.to_bytes$(right, $c, [$p[0]] as TypeTag[]);
  return compare_u8_vector$($.copy(left_bytes), $.copy(right_bytes), $c);
}

export function compare_u8_vector$ (
  left: U8[],
  right: U8[],
  $c: AptosDataCache,
): Result {
  let temp$1, temp$2, temp$3, idx, left_byte, left_length, right_byte, right_length;
  left_length = std$_.vector$_.length$(left, $c, [AtomicTypeTag.U8] as TypeTag[]);
  right_length = std$_.vector$_.length$(right, $c, [AtomicTypeTag.U8] as TypeTag[]);
  idx = u64("0");
  while (true) {
    {
      if ($.copy(idx).lt($.copy(left_length))) {
        temp$1 = $.copy(idx).lt($.copy(right_length));
      }
      else{
        temp$1 = false;
      }
    }
    if (!(temp$1)) break;
    {
      left_byte = $.copy(std$_.vector$_.borrow$(left, $.copy(idx), $c, [AtomicTypeTag.U8] as TypeTag[]));
      right_byte = $.copy(std$_.vector$_.borrow$(right, $.copy(idx), $c, [AtomicTypeTag.U8] as TypeTag[]));
      if ($.copy(left_byte).lt($.copy(right_byte))) {
        return new Result({ inner: SMALLER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
      }
      else{
        if ($.copy(left_byte).gt($.copy(right_byte))) {
          return new Result({ inner: GREATER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
        }
        else{
        }
      }
      idx = $.copy(idx).add(u64("1"));
    }

  }if ($.copy(left_length).lt($.copy(right_length))) {
    temp$3 = new Result({ inner: SMALLER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
  }
  else{
    if ($.copy(left_length).gt($.copy(right_length))) {
      temp$2 = new Result({ inner: GREATER }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
    }
    else{
      temp$2 = new Result({ inner: EQUAL }, new StructTag(new HexString("0x1"), "comparator", "Result", []));
    }
    temp$3 = temp$2;
  }
  return temp$3;
}

export function is_equal$ (
  result: Result,
  $c: AptosDataCache,
): boolean {
  return $.copy(result.inner).eq(EQUAL);
}

export function is_greater_than$ (
  result: Result,
  $c: AptosDataCache,
): boolean {
  return $.copy(result.inner).eq(GREATER);
}

export function is_smaller_than$ (
  result: Result,
  $c: AptosDataCache,
): boolean {
  return $.copy(result.inner).eq(SMALLER);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::comparator::Result", Result.ResultParser);
}

