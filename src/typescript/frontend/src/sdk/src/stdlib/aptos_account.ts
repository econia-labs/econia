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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Account from "./account";
import * as Coin from "./coin";
import * as Error from "./error";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aptos_account";

export const EACCOUNT_NOT_FOUND: U64 = u64("1");
export const EACCOUNT_NOT_REGISTERED_FOR_APT: U64 = u64("2");

export function assert_account_exists_(
  addr: HexString,
  $c: AptosDataCache
): void {
  if (!Account.exists_at_($.copy(addr), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EACCOUNT_NOT_FOUND), $c));
  }
  return;
}

export function assert_account_is_registered_for_apt_(
  addr: HexString,
  $c: AptosDataCache
): void {
  assert_account_exists_($.copy(addr), $c);
  if (
    !Coin.is_account_registered_($.copy(addr), $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ])
  ) {
    throw $.abortCode(
      Error.not_found_($.copy(EACCOUNT_NOT_REGISTERED_FOR_APT), $c)
    );
  }
  return;
}

export function create_account_(auth_key: HexString, $c: AptosDataCache): void {
  let signer;
  signer = Account.create_account_($.copy(auth_key), $c);
  Coin.register_(signer, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  return;
}

export function buildPayload_create_account(
  auth_key: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_account",
    "create_account",
    typeParamStrings,
    [auth_key],
    isJSON
  );
}
export function transfer_(
  source: HexString,
  to: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  if (!Account.exists_at_($.copy(to), $c)) {
    create_account_($.copy(to), $c);
  } else {
  }
  return Coin.transfer_(source, $.copy(to), $.copy(amount), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
}

export function buildPayload_transfer(
  to: HexString,
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_account",
    "transfer",
    typeParamStrings,
    [to, amount],
    isJSON
  );
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
  payload_create_account(
    auth_key: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_create_account(auth_key, isJSON);
  }
  async create_account(
    _account: AptosAccount,
    auth_key: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_create_account(auth_key, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_transfer(
    to: HexString,
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_transfer(to, amount, isJSON);
  }
  async transfer(
    _account: AptosAccount,
    to: HexString,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_transfer(to, amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
