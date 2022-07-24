import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "errors";

export const ALREADY_PUBLISHED : U8 = u8("6");
export const CUSTOM : U8 = u8("255");
export const INTERNAL : U8 = u8("10");
export const INVALID_ARGUMENT : U8 = u8("7");
export const INVALID_STATE : U8 = u8("1");
export const LIMIT_EXCEEDED : U8 = u8("8");
export const NOT_PUBLISHED : U8 = u8("5");
export const REQUIRES_ADDRESS : U8 = u8("2");
export const REQUIRES_CAPABILITY : U8 = u8("4");
export const REQUIRES_ROLE : U8 = u8("3");

export function already_published$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(ALREADY_PUBLISHED, $.copy(reason), $c);
}

export function custom$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(CUSTOM, $.copy(reason), $c);
}

export function internal$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(INTERNAL, $.copy(reason), $c);
}

export function invalid_argument$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(INVALID_ARGUMENT, $.copy(reason), $c);
}

export function invalid_state$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(INVALID_STATE, $.copy(reason), $c);
}

export function limit_exceeded$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(LIMIT_EXCEEDED, $.copy(reason), $c);
}

export function make$ (
  category: U8,
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return u64($.copy(category)).add($.copy(reason).shl(u8("8")));
}

export function not_published$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(NOT_PUBLISHED, $.copy(reason), $c);
}

export function requires_address$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(REQUIRES_ADDRESS, $.copy(reason), $c);
}

export function requires_capability$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(REQUIRES_CAPABILITY, $.copy(reason), $c);
}

export function requires_role$ (
  reason: U64,
  $c: AptosDataCache,
): U64 {
  return make$(REQUIRES_ROLE, $.copy(reason), $c);
}

export function loadParsers(repo: AptosParserRepo) {
}

