import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, type U128 } from "@manahippo/move-to-ts";
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

import * as String from "./string";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "from_bcs";

export const EINVALID_UTF8: U64 = u64("1");

export function from_bytes_(
  bytes: U8[],
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): any {
  return $.aptos_std_from_bcs_from_bytes(bytes, $c, [$p[0]]);
}
export function to_address_(v: U8[], $c: AptosDataCache): HexString {
  return from_bytes_($.copy(v), $c, [AtomicTypeTag.Address]);
}

export function to_bool_(v: U8[], $c: AptosDataCache): boolean {
  return from_bytes_($.copy(v), $c, [AtomicTypeTag.Bool]);
}

export function to_string_(v: U8[], $c: AptosDataCache): String.String {
  let s;
  s = from_bytes_($.copy(v), $c, [
    new StructTag(new HexString("0x1"), "string", "String", []),
  ]);
  if (!String.internal_check_utf8_(String.bytes_(s, $c), $c)) {
    throw $.abortCode($.copy(EINVALID_UTF8));
  }
  return $.copy(s);
}

export function to_u128_(v: U8[], $c: AptosDataCache): U128 {
  return from_bytes_($.copy(v), $c, [AtomicTypeTag.U128]);
}

export function to_u64_(v: U8[], $c: AptosDataCache): U64 {
  return from_bytes_($.copy(v), $c, [AtomicTypeTag.U64]);
}

export function to_u8_(v: U8[], $c: AptosDataCache): U8 {
  return from_bytes_($.copy(v), $c, [AtomicTypeTag.U8]);
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
