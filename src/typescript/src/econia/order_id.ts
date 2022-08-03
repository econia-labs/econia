import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "order_id";

export const ASK : boolean = true;
export const BID : boolean = false;
export const FIRST_64 : U8 = u8("64");
export const HI_64 : U64 = u64("18446744073709551615");

export function order_id_ (
  price: U64,
  serial_id: U64,
  side: boolean,
  $c: AptosDataCache,
): U128 {
  let temp$1;
  if ((side == ASK)) {
    temp$1 = order_id_ask_($.copy(price), $.copy(serial_id), $c);
  }
  else{
    temp$1 = order_id_bid_($.copy(price), $.copy(serial_id), $c);
  }
  return temp$1;
}

export function order_id_ask_ (
  price: U64,
  serial_id: U64,
  $c: AptosDataCache,
): U128 {
  return ((u128($.copy(price))).shl(FIRST_64)).or(u128($.copy(serial_id)));
}

export function order_id_bid_ (
  price: U64,
  serial_id: U64,
  $c: AptosDataCache,
): U128 {
  return ((u128($.copy(price))).shl(FIRST_64)).or(u128(($.copy(serial_id)).xor(HI_64)));
}

export function price_ (
  order_id: U128,
  $c: AptosDataCache,
): U64 {
  return u64(($.copy(order_id)).shr(FIRST_64));
}

export function serial_id_ask_ (
  order_id: U128,
  $c: AptosDataCache,
): U64 {
  return u64(($.copy(order_id)).and(u128(HI_64)));
}

export function serial_id_bid_ (
  order_id: U128,
  $c: AptosDataCache,
): U64 {
  return (u64(($.copy(order_id)).and(u128(HI_64)))).xor(HI_64);
}

export function loadParsers(repo: AptosParserRepo) {
}

