import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Signature";


export function bls12381_validate_pubkey$ (
  public_key: U8[],
  proof_of_possesion: U8[],
  $c: AptosDataCache,
): boolean {
  return $.AptosFramework_Signature_bls12381_validate_pubkey(public_key, proof_of_possesion, $c);

}
export function ed25519_validate_pubkey$ (
  public_key: U8[],
  $c: AptosDataCache,
): boolean {
  return $.AptosFramework_Signature_ed25519_validate_pubkey(public_key, $c);

}
export function ed25519_verify$ (
  signature: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache,
): boolean {
  return $.AptosFramework_Signature_ed25519_verify(signature, public_key, message, $c);

}
export function loadParsers(repo: AptosParserRepo) {
}

