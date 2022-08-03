import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Market from "./market";
import * as Registry from "./registry";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "init";

export const E_NOT_ECONIA : U64 = u64("0");

export function init_econia_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  if (!((Std.Signer.address_of_(account, $c)).hex() === (new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7")).hex())) {
    throw $.abortCode(E_NOT_ECONIA);
  }
  Registry.init_registry_(account, $c);
  Market.init_econia_capability_store_(account, $c);
  return;
}


export function buildPayload_init_econia (
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::init::init_econia",
    typeParamStrings,
    []
  );

}

export function loadParsers(repo: AptosParserRepo) {
}

