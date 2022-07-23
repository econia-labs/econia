import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "Econia";
export const moduleAddress = new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9");
export const moduleName = "ID";

export const FIRST_64 : U8 = u8("64");
export const HI_64 : U64 = u64("18446744073709551615");

export function id_a$ (
  p: U64,
  v: U64,
  $c: AptosDataCache,
): U128 {
  return u128($.copy(p)).shl(FIRST_64).or(u128($.copy(v)));
}

export function id_b$ (
  p: U64,
  v: U64,
  $c: AptosDataCache,
): U128 {
  return u128($.copy(p)).shl(FIRST_64).or(u128($.copy(v).xor(HI_64)));
}

export function price$ (
  id: U128,
  $c: AptosDataCache,
): U64 {
  return u64($.copy(id).shr(FIRST_64));
}

export function v_n_a$ (
  id: U128,
  $c: AptosDataCache,
): U64 {
  return u64($.copy(id).and(u128(HI_64)));
}

export function v_n_b$ (
  id: U128,
  $c: AptosDataCache,
): U64 {
  return u64($.copy(id).and(u128(HI_64))).xor(HI_64);
}

export function loadParsers(repo: AptosParserRepo) {
}

