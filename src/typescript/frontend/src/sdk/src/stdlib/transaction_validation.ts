import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, type U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import {
  type FieldDeclType,
  type TypeParamDeclType,
} from "@manahippo/move-to-ts";
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

import * as Account from "./account";
import * as Chain_id from "./chain_id";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Signer from "./signer";
import * as System_addresses from "./system_addresses";
import * as Timestamp from "./timestamp";
import * as Transaction_fee from "./transaction_fee";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "transaction_validation";

export const EOUT_OF_GAS: U64 = u64("6");
export const MAX_U64: U128 = u128("18446744073709551615");
export const PROLOGUE_EACCOUNT_DOES_NOT_EXIST: U64 = u64("1004");
export const PROLOGUE_EBAD_CHAIN_ID: U64 = u64("1007");
export const PROLOGUE_ECANT_PAY_GAS_DEPOSIT: U64 = u64("1005");
export const PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY: U64 = u64("1001");
export const PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH: U64 =
  u64("1009");
export const PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG: U64 = u64("1008");
export const PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW: U64 = u64("1003");
export const PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD: U64 = u64("1002");
export const PROLOGUE_ETRANSACTION_EXPIRED: U64 = u64("1006");

export class TransactionValidation {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "TransactionValidation";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "module_addr", typeTag: AtomicTypeTag.Address },
    { name: "module_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "script_prologue_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "module_prologue_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
    {
      name: "multi_agent_prologue_name",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
    { name: "user_epilogue_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  module_addr: HexString;
  module_name: U8[];
  script_prologue_name: U8[];
  module_prologue_name: U8[];
  multi_agent_prologue_name: U8[];
  user_epilogue_name: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.module_addr = proto["module_addr"] as HexString;
    this.module_name = proto["module_name"] as U8[];
    this.script_prologue_name = proto["script_prologue_name"] as U8[];
    this.module_prologue_name = proto["module_prologue_name"] as U8[];
    this.multi_agent_prologue_name = proto["multi_agent_prologue_name"] as U8[];
    this.user_epilogue_name = proto["user_epilogue_name"] as U8[];
  }

  static TransactionValidationParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): TransactionValidation {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      TransactionValidation
    );
    return new TransactionValidation(proto, typeTag);
  }

  static async load(
    repo: AptosParserRepo,
    client: AptosClient,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await repo.loadResource(
      client,
      address,
      TransactionValidation,
      typeParams
    );
    return result as unknown as TransactionValidation;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      TransactionValidation,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as TransactionValidation;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "TransactionValidation",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function epilogue_(
  account: HexString,
  _txn_sequence_number: U64,
  txn_gas_price: U64,
  txn_max_gas_units: U64,
  gas_units_remaining: U64,
  $c: AptosDataCache
): void {
  let addr, gas_used, transaction_fee_amount;
  if (!$.copy(txn_max_gas_units).ge($.copy(gas_units_remaining))) {
    throw $.abortCode(Error.invalid_argument_($.copy(EOUT_OF_GAS), $c));
  }
  gas_used = $.copy(txn_max_gas_units).sub($.copy(gas_units_remaining));
  if (
    !u128($.copy(txn_gas_price))
      .mul(u128($.copy(gas_used)))
      .le($.copy(MAX_U64))
  ) {
    throw $.abortCode(Error.out_of_range_($.copy(EOUT_OF_GAS), $c));
  }
  transaction_fee_amount = $.copy(txn_gas_price).mul($.copy(gas_used));
  addr = Signer.address_of_(account, $c);
  if (
    !Coin.balance_($.copy(addr), $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]).ge($.copy(transaction_fee_amount))
  ) {
    throw $.abortCode(
      Error.out_of_range_($.copy(PROLOGUE_ECANT_PAY_GAS_DEPOSIT), $c)
    );
  }
  Transaction_fee.burn_fee_($.copy(addr), $.copy(transaction_fee_amount), $c);
  Account.increment_sequence_number_($.copy(addr), $c);
  return;
}

export function initialize_(
  aptos_framework: HexString,
  script_prologue_name: U8[],
  module_prologue_name: U8[],
  multi_agent_prologue_name: U8[],
  user_epilogue_name: U8[],
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $c.move_to(
    new SimpleStructTag(TransactionValidation),
    aptos_framework,
    new TransactionValidation(
      {
        module_addr: new HexString("0x1"),
        module_name: [
          u8("116"),
          u8("114"),
          u8("97"),
          u8("110"),
          u8("115"),
          u8("97"),
          u8("99"),
          u8("116"),
          u8("105"),
          u8("111"),
          u8("110"),
          u8("95"),
          u8("118"),
          u8("97"),
          u8("108"),
          u8("105"),
          u8("100"),
          u8("97"),
          u8("116"),
          u8("105"),
          u8("111"),
          u8("110"),
        ],
        script_prologue_name: $.copy(script_prologue_name),
        module_prologue_name: $.copy(module_prologue_name),
        multi_agent_prologue_name: $.copy(multi_agent_prologue_name),
        user_epilogue_name: $.copy(user_epilogue_name),
      },
      new SimpleStructTag(TransactionValidation)
    )
  );
  return;
}

export function module_prologue_(
  sender: HexString,
  txn_sequence_number: U64,
  txn_public_key: U8[],
  txn_gas_price: U64,
  txn_max_gas_units: U64,
  txn_expiration_time: U64,
  chain_id: U8,
  $c: AptosDataCache
): void {
  return prologue_common_(
    sender,
    $.copy(txn_sequence_number),
    $.copy(txn_public_key),
    $.copy(txn_gas_price),
    $.copy(txn_max_gas_units),
    $.copy(txn_expiration_time),
    $.copy(chain_id),
    $c
  );
}

export function multi_agent_script_prologue_(
  sender: HexString,
  txn_sequence_number: U64,
  txn_sender_public_key: U8[],
  secondary_signer_addresses: HexString[],
  secondary_signer_public_key_hashes: U8[][],
  txn_gas_price: U64,
  txn_max_gas_units: U64,
  txn_expiration_time: U64,
  chain_id: U8,
  $c: AptosDataCache
): void {
  let i, num_secondary_signers, secondary_address, signer_public_key_hash;
  prologue_common_(
    sender,
    $.copy(txn_sequence_number),
    $.copy(txn_sender_public_key),
    $.copy(txn_gas_price),
    $.copy(txn_max_gas_units),
    $.copy(txn_expiration_time),
    $.copy(chain_id),
    $c
  );
  num_secondary_signers = Vector.length_(secondary_signer_addresses, $c, [
    AtomicTypeTag.Address,
  ]);
  if (
    !Vector.length_(secondary_signer_public_key_hashes, $c, [
      new VectorTag(AtomicTypeTag.U8),
    ]).eq($.copy(num_secondary_signers))
  ) {
    throw $.abortCode(
      Error.invalid_argument_(
        $.copy(PROLOGUE_ESECONDARY_KEYS_ADDRESSES_COUNT_MISMATCH),
        $c
      )
    );
  }
  i = u64("0");
  while ($.copy(i).lt($.copy(num_secondary_signers))) {
    {
      secondary_address = $.copy(
        Vector.borrow_(secondary_signer_addresses, $.copy(i), $c, [
          AtomicTypeTag.Address,
        ])
      );
      if (!Account.exists_at_($.copy(secondary_address), $c)) {
        throw $.abortCode(
          Error.invalid_argument_($.copy(PROLOGUE_EACCOUNT_DOES_NOT_EXIST), $c)
        );
      }
      signer_public_key_hash = $.copy(
        Vector.borrow_(secondary_signer_public_key_hashes, $.copy(i), $c, [
          new VectorTag(AtomicTypeTag.U8),
        ])
      );
      if (
        !$.veq(
          $.copy(signer_public_key_hash),
          Account.get_authentication_key_($.copy(secondary_address), $c)
        )
      ) {
        throw $.abortCode(
          Error.invalid_argument_(
            $.copy(PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY),
            $c
          )
        );
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function prologue_common_(
  sender: HexString,
  txn_sequence_number: U64,
  txn_authentication_key: U8[],
  txn_gas_price: U64,
  txn_max_gas_units: U64,
  txn_expiration_time: U64,
  chain_id: U8,
  $c: AptosDataCache
): void {
  let account_sequence_number, balance, max_transaction_fee, transaction_sender;
  if (!Timestamp.now_seconds_($c).lt($.copy(txn_expiration_time))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_ETRANSACTION_EXPIRED), $c)
    );
  }
  if (!Chain_id.get_($c).eq($.copy(chain_id))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_EBAD_CHAIN_ID), $c)
    );
  }
  transaction_sender = Signer.address_of_(sender, $c);
  if (!Account.exists_at_($.copy(transaction_sender), $c)) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_EACCOUNT_DOES_NOT_EXIST), $c)
    );
  }
  if (
    !$.veq(
      $.copy(txn_authentication_key),
      Account.get_authentication_key_($.copy(transaction_sender), $c)
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_EINVALID_ACCOUNT_AUTH_KEY), $c)
    );
  }
  if (!u128($.copy(txn_sequence_number)).lt($.copy(MAX_U64))) {
    throw $.abortCode(
      Error.out_of_range_($.copy(PROLOGUE_ESEQUENCE_NUMBER_TOO_BIG), $c)
    );
  }
  account_sequence_number = Account.get_sequence_number_(
    $.copy(transaction_sender),
    $c
  );
  if (!$.copy(txn_sequence_number).ge($.copy(account_sequence_number))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_ESEQUENCE_NUMBER_TOO_OLD), $c)
    );
  }
  if (!$.copy(txn_sequence_number).eq($.copy(account_sequence_number))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_ESEQUENCE_NUMBER_TOO_NEW), $c)
    );
  }
  max_transaction_fee = $.copy(txn_gas_price).mul($.copy(txn_max_gas_units));
  if (
    !Coin.is_account_registered_($.copy(transaction_sender), $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ])
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_ECANT_PAY_GAS_DEPOSIT), $c)
    );
  }
  balance = Coin.balance_($.copy(transaction_sender), $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  if (!$.copy(balance).ge($.copy(max_transaction_fee))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(PROLOGUE_ECANT_PAY_GAS_DEPOSIT), $c)
    );
  }
  return;
}

export function script_prologue_(
  sender: HexString,
  txn_sequence_number: U64,
  txn_public_key: U8[],
  txn_gas_price: U64,
  txn_max_gas_units: U64,
  txn_expiration_time: U64,
  chain_id: U8,
  _script_hash: U8[],
  $c: AptosDataCache
): void {
  return prologue_common_(
    sender,
    $.copy(txn_sequence_number),
    $.copy(txn_public_key),
    $.copy(txn_gas_price),
    $.copy(txn_max_gas_units),
    $.copy(txn_expiration_time),
    $.copy(chain_id),
    $c
  );
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::transaction_validation::TransactionValidation",
    TransactionValidation.TransactionValidationParser
  );
}
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
  get TransactionValidation() {
    return TransactionValidation;
  }
  async loadTransactionValidation(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await TransactionValidation.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
}
