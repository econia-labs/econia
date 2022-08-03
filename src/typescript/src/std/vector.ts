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

export function append_ (
  lhs: any[],
  other: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  reverse_(other, $c, [$p[0]]);
  while (!is_empty_(other, $c, [$p[0]])) {
    {
      push_back_(lhs, pop_back_(other, $c, [$p[0]]), $c, [$p[0]]);
    }

  }destroy_empty_(other, $c, [$p[0]]);
  return;
}

export function borrow_ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  return $.std_vector_borrow(v, i, $c, [$p[0]]);

}
export function borrow_mut_ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  return $.std_vector_borrow_mut(v, i, $c, [$p[0]]);

}
export function contains_ (
  v: any[],
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  let i, len;
  i = u64("0");
  len = length_(v, $c, [$p[0]]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      if ($.dyn_eq($p[0], borrow_(v, $.copy(i), $c, [$p[0]]), e)) {
        return true;
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }return false;
}

export function destroy_empty_ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  return $.std_vector_destroy_empty(v, $c, [$p[0]]);

}
export function empty_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any[] {
  return $.std_vector_empty($c, [$p[0]]);

}
export function index_of_ (
  v: any[],
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): [boolean, U64] {
  let i, len;
  i = u64("0");
  len = length_(v, $c, [$p[0]]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      if ($.dyn_eq($p[0], borrow_(v, $.copy(i), $c, [$p[0]]), e)) {
        return [true, $.copy(i)];
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }return [false, u64("0")];
}

export function is_empty_ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return (length_(v, $c, [$p[0]])).eq((u64("0")));
}

export function length_ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): U64 {
  return $.std_vector_length(v, $c, [$p[0]]);

}
export function pop_back_ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  return $.std_vector_pop_back(v, $c, [$p[0]]);

}
export function push_back_ (
  v: any[],
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  return $.std_vector_push_back(v, e, $c, [$p[0]]);

}
export function remove_ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, temp$2, len;
  len = length_(v, $c, [$p[0]]);
  if (($.copy(i)).ge($.copy(len))) {
    throw $.abortCode(EINDEX_OUT_OF_BOUNDS);
  }
  else{
  }
  len = ($.copy(len)).sub(u64("1"));
  while (($.copy(i)).lt($.copy(len))) {
    {
      temp$2 = v;
      temp$1 = $.copy(i);
      i = ($.copy(i)).add(u64("1"));
      swap_(temp$2, temp$1, $.copy(i), $c, [$p[0]]);
    }

  }return pop_back_(v, $c, [$p[0]]);
}

export function reverse_ (
  v: any[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  let back_index, front_index, len;
  len = length_(v, $c, [$p[0]]);
  if (($.copy(len)).eq((u64("0")))) {
    return;
  }
  else{
  }
  front_index = u64("0");
  back_index = ($.copy(len)).sub(u64("1"));
  while (($.copy(front_index)).lt($.copy(back_index))) {
    {
      swap_(v, $.copy(front_index), $.copy(back_index), $c, [$p[0]]);
      front_index = ($.copy(front_index)).add(u64("1"));
      back_index = ($.copy(back_index)).sub(u64("1"));
    }

  }return;
}

export function singleton_ (
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any[] {
  let v;
  v = empty_($c, [$p[0]]);
  push_back_(v, e, $c, [$p[0]]);
  return v;
}

export function swap_ (
  v: any[],
  i: U64,
  j: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  return $.std_vector_swap(v, i, j, $c, [$p[0]]);

}
export function swap_remove_ (
  v: any[],
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let last_idx;
  if (!!is_empty_(v, $c, [$p[0]])) {
    throw $.abortCode(EINDEX_OUT_OF_BOUNDS);
  }
  last_idx = (length_(v, $c, [$p[0]])).sub(u64("1"));
  swap_(v, $.copy(i), $.copy(last_idx), $c, [$p[0]]);
  return pop_back_(v, $c, [$p[0]]);
}

export function loadParsers(repo: AptosParserRepo) {
}

