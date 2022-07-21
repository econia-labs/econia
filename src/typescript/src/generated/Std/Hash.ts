import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Hash";


export function sha2_256$ (
  data: U8[],
  $c: AptosDataCache,
): U8[] {
  return $.Std_Hash_sha2_256(data, $c);

}
export function sha3_256$ (
  data: U8[],
  $c: AptosDataCache,
): U8[] {
  return $.Std_Hash_sha3_256(data, $c);

}
export function sip_hash$ (
  v: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <MoveValue>*/
): U64 {
  return $.Std_Hash_sip_hash(v, $c, [$p[0]]);

}
export function loadParsers(repo: AptosParserRepo) {
}

