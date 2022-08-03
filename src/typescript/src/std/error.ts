import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "error";

export const ABORTED : U64 = u64("7");
export const ALREADY_EXISTS : U64 = u64("8");
export const CANCELLED : U64 = u64("10");
export const INTERNAL : U64 = u64("11");
export const INVALID_ARGUMENT : U64 = u64("1");
export const INVALID_STATE : U64 = u64("3");
export const NOT_FOUND : U64 = u64("6");
export const NOT_IMPLEMENTED : U64 = u64("12");
export const OUT_OF_RANGE : U64 = u64("2");
export const PERMISSION_DENIED : U64 = u64("5");
export const RESOURCE_EXHAUSTED : U64 = u64("9");
export const UNAUTHENTICATED : U64 = u64("4");
export const UNAVAILABLE : U64 = u64("13");

export function aborted_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(ABORTED, $.copy(r), $c);
}

export function already_exists_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(ALREADY_EXISTS, $.copy(r), $c);
}

export function canonical_ (
  category: U64,
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return (($.copy(category)).shl(u8("16"))).add($.copy(reason));
}

export function internal_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(INTERNAL, $.copy(r), $c);
}

export function invalid_argument_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(INVALID_ARGUMENT, $.copy(r), $c);
}

export function invalid_state_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(INVALID_STATE, $.copy(r), $c);
}

export function not_found_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(NOT_FOUND, $.copy(r), $c);
}

export function not_implemented_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(NOT_IMPLEMENTED, $.copy(r), $c);
}

export function out_of_range_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(OUT_OF_RANGE, $.copy(r), $c);
}

export function permission_denied_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(PERMISSION_DENIED, $.copy(r), $c);
}

export function resource_exhausted_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(RESOURCE_EXHAUSTED, $.copy(r), $c);
}

export function unauthenticated_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(UNAUTHENTICATED, $.copy(r), $c);
}

export function unavailable_ (
  r: U64,
  $c: AptosDataCache,
): U64 {
  return canonical_(UNAVAILABLE, $.copy(r), $c);
}

export function loadParsers(repo: AptosParserRepo) {
}

