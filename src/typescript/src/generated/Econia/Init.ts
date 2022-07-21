import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Caps from "./Caps";
import * as Registry from "./Registry";
import * as Version from "./Version";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");
export const moduleName = "Init";

export const E_NOT_ECONIA : U64 = u64("0");

export function init_econia$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  if (!(Std.Signer.address_of$(account, $c).hex() === new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659").hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  Caps.init_caps$(account, $c);
  Registry.init_registry$(account, $c);
  Version.init_mock_version_number$(account, $c);
  return;
}


export function buildPayload_init_econia (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659::Init::init_econia",
    typeParamStrings,
    []
  );

}
export function loadParsers(repo: AptosParserRepo) {
}

