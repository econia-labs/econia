import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "signature";


export function bls12381_validate_pubkey$ (
  public_key: U8[],
  proof_of_possesion: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_framework_signature_bls12381_validate_pubkey(public_key, proof_of_possesion, $c);

}
export function ed25519_validate_pubkey$ (
  public_key: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_framework_signature_ed25519_validate_pubkey(public_key, $c);

}
export function ed25519_verify$ (
  signature: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_framework_signature_ed25519_verify(signature, public_key, message, $c);

}
export function secp256k1_recover$ (
  message: U8[],
  recovery_id: U8,
  signature: U8[],
  $c: AptosDataCache,
): [U8[], boolean] {
  return $.aptos_framework_signature_secp256k1_recover(message, recovery_id, signature, $c);

}
export function loadParsers(repo: AptosParserRepo) {
}

