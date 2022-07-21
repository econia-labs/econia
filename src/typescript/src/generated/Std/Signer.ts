import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Signer";


export function address_of$ (
  s: HexString,
  $c: AptosDataCache,
): HexString {
  return $.copy(borrow_address$(s, $c));
}

export function borrow_address$ (
  s: HexString,
  $c: AptosDataCache,
): HexString {
  return $.Std_Signer_borrow_address(s, $c);

}
export function loadParsers(repo: AptosParserRepo) {
}

