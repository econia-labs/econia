import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import { FieldDeclType, TypeParamDeclType } from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";

import * as Bcs from "./bcs";
import * as Error from "./error";
import * as Features from "./features";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aptos_hash";

export const E_NATIVE_FUN_NOT_AVAILABLE: U64 = u64("1");

export function keccak256_(bytes: U8[], $c: AptosDataCache): U8[] {
  return $.aptos_std_aptos_hash_keccak256(bytes, $c);
}
export function ripemd160_(bytes: U8[], $c: AptosDataCache): U8[] {
  if (!Features.sha_512_and_ripemd_160_enabled_($c)) {
    throw $.abortCode(
      Error.invalid_state_($.copy(E_NATIVE_FUN_NOT_AVAILABLE), $c)
    );
  } else {
  }
  return ripemd160_internal_($.copy(bytes), $c);
}

export function ripemd160_internal_(bytes: U8[], $c: AptosDataCache): U8[] {
  return $.aptos_std_aptos_hash_ripemd160_internal(bytes, $c);
}
export function sha2_512_(bytes: U8[], $c: AptosDataCache): U8[] {
  if (!Features.sha_512_and_ripemd_160_enabled_($c)) {
    throw $.abortCode(
      Error.invalid_state_($.copy(E_NATIVE_FUN_NOT_AVAILABLE), $c)
    );
  } else {
  }
  return sha2_512_internal_($.copy(bytes), $c);
}

export function sha2_512_internal_(bytes: U8[], $c: AptosDataCache): U8[] {
  return $.aptos_std_aptos_hash_sha2_512_internal(bytes, $c);
}
export function sha3_512_(bytes: U8[], $c: AptosDataCache): U8[] {
  if (!Features.sha_512_and_ripemd_160_enabled_($c)) {
    throw $.abortCode(
      Error.invalid_state_($.copy(E_NATIVE_FUN_NOT_AVAILABLE), $c)
    );
  } else {
  }
  return sha3_512_internal_($.copy(bytes), $c);
}

export function sha3_512_internal_(bytes: U8[], $c: AptosDataCache): U8[] {
  return $.aptos_std_aptos_hash_sha3_512_internal(bytes, $c);
}
export function sip_hash_(bytes: U8[], $c: AptosDataCache): U64 {
  return $.aptos_std_aptos_hash_sip_hash(bytes, $c);
}
export function sip_hash_from_value_(
  v: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <MoveValue>*/
): U64 {
  let bytes;
  bytes = Bcs.to_bytes_(v, $c, [$p[0]]);
  return sip_hash_($.copy(bytes), $c);
}

export function loadParsers(repo: AptosParserRepo) {}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {}
  get moduleAddress() {
    {
      return moduleAddress;
    }
  }
  get moduleName() {
    {
      return moduleName;
    }
  }
}
