import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import { FieldDeclType, TypeParamDeclType } from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  TypeTag,
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

import * as Error from "./error";
import * as Signer from "./signer";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "system_addresses";

export const ENOT_APTOS_FRAMEWORK_ADDRESS: U64 = u64("3");
export const ENOT_CORE_RESOURCE_ADDRESS: U64 = u64("1");
export const ENOT_FRAMEWORK_RESERVED_ADDRESS: U64 = u64("4");
export const EVM: U64 = u64("2");

export function assert_aptos_framework_(
  account: HexString,
  $c: AptosDataCache
): void {
  if (!is_aptos_framework_address_(Signer.address_of_(account, $c), $c)) {
    throw $.abortCode(
      Error.permission_denied_($.copy(ENOT_APTOS_FRAMEWORK_ADDRESS), $c)
    );
  }
  return;
}

export function assert_core_resource_(
  account: HexString,
  $c: AptosDataCache
): void {
  return assert_core_resource_address_(Signer.address_of_(account, $c), $c);
}

export function assert_core_resource_address_(
  addr: HexString,
  $c: AptosDataCache
): void {
  if (!is_core_resource_address_($.copy(addr), $c)) {
    throw $.abortCode(
      Error.permission_denied_($.copy(ENOT_CORE_RESOURCE_ADDRESS), $c)
    );
  }
  return;
}

export function assert_framework_reserved_address_(
  account: HexString,
  $c: AptosDataCache
): void {
  if (!is_framework_reserved_address_(Signer.address_of_(account, $c), $c)) {
    throw $.abortCode(
      Error.permission_denied_($.copy(ENOT_FRAMEWORK_RESERVED_ADDRESS), $c)
    );
  }
  return;
}

export function assert_vm_(account: HexString, $c: AptosDataCache): void {
  if (!is_vm_(account, $c)) {
    throw $.abortCode(Error.permission_denied_($.copy(EVM), $c));
  }
  return;
}

export function is_aptos_framework_address_(
  addr: HexString,
  $c: AptosDataCache
): boolean {
  return $.copy(addr).hex() === new HexString("0x1").hex();
}

export function is_core_resource_address_(
  addr: HexString,
  $c: AptosDataCache
): boolean {
  return $.copy(addr).hex() === new HexString("0xa550c18").hex();
}

export function is_framework_reserved_address_(
  addr: HexString,
  $c: AptosDataCache
): boolean {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9;
  if (is_aptos_framework_address_($.copy(addr), $c)) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(addr).hex() === new HexString("0x2").hex();
  }
  if (temp$1) {
    temp$2 = true;
  } else {
    temp$2 = $.copy(addr).hex() === new HexString("0x3").hex();
  }
  if (temp$2) {
    temp$3 = true;
  } else {
    temp$3 = $.copy(addr).hex() === new HexString("0x4").hex();
  }
  if (temp$3) {
    temp$4 = true;
  } else {
    temp$4 = $.copy(addr).hex() === new HexString("0x5").hex();
  }
  if (temp$4) {
    temp$5 = true;
  } else {
    temp$5 = $.copy(addr).hex() === new HexString("0x6").hex();
  }
  if (temp$5) {
    temp$6 = true;
  } else {
    temp$6 = $.copy(addr).hex() === new HexString("0x7").hex();
  }
  if (temp$6) {
    temp$7 = true;
  } else {
    temp$7 = $.copy(addr).hex() === new HexString("0x8").hex();
  }
  if (temp$7) {
    temp$8 = true;
  } else {
    temp$8 = $.copy(addr).hex() === new HexString("0x9").hex();
  }
  if (temp$8) {
    temp$9 = true;
  } else {
    temp$9 = $.copy(addr).hex() === new HexString("0xa").hex();
  }
  return temp$9;
}

export function is_reserved_address_(
  addr: HexString,
  $c: AptosDataCache
): boolean {
  let temp$1;
  if (is_aptos_framework_address_($.copy(addr), $c)) {
    temp$1 = true;
  } else {
    temp$1 = is_vm_address_($.copy(addr), $c);
  }
  return temp$1;
}

export function is_vm_(account: HexString, $c: AptosDataCache): boolean {
  return is_vm_address_(Signer.address_of_(account, $c), $c);
}

export function is_vm_address_(addr: HexString, $c: AptosDataCache): boolean {
  return $.copy(addr).hex() === new HexString("0x0").hex();
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
