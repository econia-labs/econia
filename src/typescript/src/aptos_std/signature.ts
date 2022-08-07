import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "signature";


export function bls12381_aggregate_pop_verified_pubkeys_ (
  public_keys: U8[][],
  $c: AptosDataCache,
): Std.Option.Option {
  return $.aptos_std_signature_bls12381_aggregate_pop_verified_pubkeys(public_keys, $c);

}
export function bls12381_validate_pubkey_ (
  public_key: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_std_signature_bls12381_validate_pubkey(public_key, $c);

}
export function bls12381_verify_proof_of_possession_ (
  public_key: U8[],
  proof_of_possesion: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_std_signature_bls12381_verify_proof_of_possession(public_key, proof_of_possesion, $c);

}
export function bls12381_verify_signature_ (
  signature: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_std_signature_bls12381_verify_signature(signature, public_key, message, $c);

}
export function ed25519_validate_pubkey_ (
  public_key: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_std_signature_ed25519_validate_pubkey(public_key, $c);

}
export function ed25519_verify_ (
  signature: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache,
): boolean {
  return $.aptos_std_signature_ed25519_verify(signature, public_key, message, $c);

}
export function secp256k1_ecdsa_recover_ (
  message: U8[],
  recovery_id: U8,
  signature: U8[],
  $c: AptosDataCache,
): [U8[], boolean] {
  return $.aptos_std_signature_secp256k1_ecdsa_recover(message, recovery_id, signature, $c);

}
export function loadParsers(repo: AptosParserRepo) {
}

