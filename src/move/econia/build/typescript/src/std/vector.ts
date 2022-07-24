import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "vector";

export const EINDEX_OUT_OF_BOUNDS : U64 = u64("131072");

export function append$ (
  lhs: any[],
  other: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  reverse$(other, $c, [$p[0]] as TypeTag[]);
  while (!is_empty$(other, $c, [$p[0]] as TypeTag[])) {
    {
      push_back$(lhs, pop_back$(other, $c, [$p[0]] as TypeTag[]), $c, [$p[0]] as TypeTag[]);
    }

  }destroy_empty$(other, $c, [$p[0]] as TypeTag[]);
  return;
}

export function borrow$ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  return $.std_vector_borrow(v, i, $c, [$p[0]]);

}
export function borrow_mut$ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  return $.std_vector_borrow_mut(v, i, $c, [$p[0]]);

}
export function contains$ (
  v: any[],
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  let i, len;
  i = u64("0");
  len = length$(v, $c, [$p[0]] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      if ($.dyn_eq($p[0], borrow$(v, $.copy(i), $c, [$p[0]] as TypeTag[]), e)) {
        return true;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }return false;
}

export function destroy_empty$ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  return $.std_vector_destroy_empty(v, $c, [$p[0]]);

}
export function empty$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any[] {
  return $.std_vector_empty($c, [$p[0]]);

}
export function index_of$ (
  v: any[],
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): [boolean, U64] {
  let i, len;
  i = u64("0");
  len = length$(v, $c, [$p[0]] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      if ($.dyn_eq($p[0], borrow$(v, $.copy(i), $c, [$p[0]] as TypeTag[]), e)) {
        return [true, $.copy(i)];
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }return [false, u64("0")];
}

export function is_empty$ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return length$(v, $c, [$p[0]] as TypeTag[]).eq(u64("0"));
}

export function length$ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): U64 {
  return $.std_vector_length(v, $c, [$p[0]]);

}
export function pop_back$ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  return $.std_vector_pop_back(v, $c, [$p[0]]);

}
export function push_back$ (
  v: any[],
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  return $.std_vector_push_back(v, e, $c, [$p[0]]);

}
export function remove$ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, temp$2, len;
  len = length$(v, $c, [$p[0]] as TypeTag[]);
  if ($.copy(i).ge($.copy(len))) {
    throw $.abortCode(EINDEX_OUT_OF_BOUNDS);
  }
  else{
  }
  len = $.copy(len).sub(u64("1"));
  while ($.copy(i).lt($.copy(len))) {
    {
      temp$2 = v;
      temp$1 = $.copy(i);
      i = $.copy(i).add(u64("1"));
      swap$(temp$2, temp$1, $.copy(i), $c, [$p[0]] as TypeTag[]);
    }

  }return pop_back$(v, $c, [$p[0]] as TypeTag[]);
}

export function reverse$ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  let back_index, front_index, len;
  len = length$(v, $c, [$p[0]] as TypeTag[]);
  if ($.copy(len).eq(u64("0"))) {
    return;
  }
  else{
  }
  front_index = u64("0");
  back_index = $.copy(len).sub(u64("1"));
  while ($.copy(front_index).lt($.copy(back_index))) {
    {
      swap$(v, $.copy(front_index), $.copy(back_index), $c, [$p[0]] as TypeTag[]);
      front_index = $.copy(front_index).add(u64("1"));
      back_index = $.copy(back_index).sub(u64("1"));
    }

  }return;
}

export function singleton$ (
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any[] {
  let v;
  v = empty$($c, [$p[0]] as TypeTag[]);
  push_back$(v, e, $c, [$p[0]] as TypeTag[]);
  return v;
}

export function swap$ (
  v: any[],
  i: U64,
  j: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  return $.std_vector_swap(v, i, j, $c, [$p[0]]);

}
export function swap_remove$ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let last_idx;
  if (!!is_empty$(v, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EINDEX_OUT_OF_BOUNDS);
  }
  last_idx = length$(v, $c, [$p[0]] as TypeTag[]).sub(u64("1"));
  swap$(v, $.copy(i), $.copy(last_idx), $c, [$p[0]] as TypeTag[]);
  return pop_back$(v, $c, [$p[0]] as TypeTag[]);
}

export function loadParsers(repo: AptosParserRepo) {
}

