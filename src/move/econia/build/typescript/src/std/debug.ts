import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "debug";


export function print$ (
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  return $.std_debug_print(x, $c, [$p[0]]);

}
export function print_stack_trace$ (
  $c: AptosDataCache,
): void {
  return $.std_debug_print_stack_trace($c);

}
export function loadParsers(repo: AptosParserRepo) {
}

