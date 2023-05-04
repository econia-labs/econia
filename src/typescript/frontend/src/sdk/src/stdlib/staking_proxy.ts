import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, U64, U128 } from "@manahippo/move-to-ts";
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

import * as Signer from "./signer";
import * as Stake from "./stake";
import * as Staking_contract from "./staking_contract";
import * as Vector from "./vector";
import * as Vesting from "./vesting";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "staking_proxy";

export function set_operator_(
  owner: HexString,
  old_operator: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  set_vesting_contract_operator_(
    owner,
    $.copy(old_operator),
    $.copy(new_operator),
    $c
  );
  set_staking_contract_operator_(
    owner,
    $.copy(old_operator),
    $.copy(new_operator),
    $c
  );
  set_stake_pool_operator_(owner, $.copy(new_operator), $c);
  return;
}

export function buildPayload_set_operator(
  old_operator: HexString,
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_operator",
    typeParamStrings,
    [old_operator, new_operator],
    isJSON
  );
}
export function set_stake_pool_operator_(
  owner: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let owner_address;
  owner_address = Signer.address_of_(owner, $c);
  if (Stake.stake_pool_exists_($.copy(owner_address), $c)) {
    Stake.set_operator_(owner, $.copy(new_operator), $c);
  } else {
  }
  return;
}

export function buildPayload_set_stake_pool_operator(
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_stake_pool_operator",
    typeParamStrings,
    [new_operator],
    isJSON
  );
}
export function set_stake_pool_voter_(
  owner: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  if (Stake.stake_pool_exists_(Signer.address_of_(owner, $c), $c)) {
    Stake.set_delegated_voter_(owner, $.copy(new_voter), $c);
  } else {
  }
  return;
}

export function buildPayload_set_stake_pool_voter(
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_stake_pool_voter",
    typeParamStrings,
    [new_voter],
    isJSON
  );
}
export function set_staking_contract_operator_(
  owner: HexString,
  old_operator: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let current_commission_percentage, owner_address;
  owner_address = Signer.address_of_(owner, $c);
  if (
    Staking_contract.staking_contract_exists_(
      $.copy(owner_address),
      $.copy(old_operator),
      $c
    )
  ) {
    current_commission_percentage = Staking_contract.commission_percentage_(
      $.copy(owner_address),
      $.copy(old_operator),
      $c
    );
    Staking_contract.switch_operator_(
      owner,
      $.copy(old_operator),
      $.copy(new_operator),
      $.copy(current_commission_percentage),
      $c
    );
  } else {
  }
  return;
}

export function buildPayload_set_staking_contract_operator(
  old_operator: HexString,
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_staking_contract_operator",
    typeParamStrings,
    [old_operator, new_operator],
    isJSON
  );
}
export function set_staking_contract_voter_(
  owner: HexString,
  operator: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  let owner_address;
  owner_address = Signer.address_of_(owner, $c);
  if (
    Staking_contract.staking_contract_exists_(
      $.copy(owner_address),
      $.copy(operator),
      $c
    )
  ) {
    Staking_contract.update_voter_(
      owner,
      $.copy(operator),
      $.copy(new_voter),
      $c
    );
  } else {
  }
  return;
}

export function buildPayload_set_staking_contract_voter(
  operator: HexString,
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_staking_contract_voter",
    typeParamStrings,
    [operator, new_voter],
    isJSON
  );
}
export function set_vesting_contract_operator_(
  owner: HexString,
  old_operator: HexString,
  new_operator: HexString,
  $c: AptosDataCache
): void {
  let temp$1,
    current_commission_percentage,
    i,
    len,
    owner_address,
    vesting_contract,
    vesting_contracts;
  owner_address = Signer.address_of_(owner, $c);
  temp$1 = Vesting.vesting_contracts_($.copy(owner_address), $c);
  vesting_contracts = temp$1;
  i = u64("0");
  len = Vector.length_(vesting_contracts, $c, [AtomicTypeTag.Address]);
  while ($.copy(i).lt($.copy(len))) {
    {
      vesting_contract = $.copy(
        Vector.borrow_(vesting_contracts, $.copy(i), $c, [
          AtomicTypeTag.Address,
        ])
      );
      if (
        Vesting.operator_($.copy(vesting_contract), $c).hex() ===
        $.copy(old_operator).hex()
      ) {
        current_commission_percentage = Vesting.operator_commission_percentage_(
          $.copy(vesting_contract),
          $c
        );
        Vesting.update_operator_(
          owner,
          $.copy(vesting_contract),
          $.copy(new_operator),
          $.copy(current_commission_percentage),
          $c
        );
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function buildPayload_set_vesting_contract_operator(
  old_operator: HexString,
  new_operator: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_vesting_contract_operator",
    typeParamStrings,
    [old_operator, new_operator],
    isJSON
  );
}
export function set_vesting_contract_voter_(
  owner: HexString,
  operator: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  let temp$1, i, len, owner_address, vesting_contract, vesting_contracts;
  owner_address = Signer.address_of_(owner, $c);
  temp$1 = Vesting.vesting_contracts_($.copy(owner_address), $c);
  vesting_contracts = temp$1;
  i = u64("0");
  len = Vector.length_(vesting_contracts, $c, [AtomicTypeTag.Address]);
  while ($.copy(i).lt($.copy(len))) {
    {
      vesting_contract = $.copy(
        Vector.borrow_(vesting_contracts, $.copy(i), $c, [
          AtomicTypeTag.Address,
        ])
      );
      if (
        Vesting.operator_($.copy(vesting_contract), $c).hex() ===
        $.copy(operator).hex()
      ) {
        Vesting.update_voter_(
          owner,
          $.copy(vesting_contract),
          $.copy(new_voter),
          $c
        );
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function buildPayload_set_vesting_contract_voter(
  operator: HexString,
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_vesting_contract_voter",
    typeParamStrings,
    [operator, new_voter],
    isJSON
  );
}
export function set_voter_(
  owner: HexString,
  operator: HexString,
  new_voter: HexString,
  $c: AptosDataCache
): void {
  set_vesting_contract_voter_(owner, $.copy(operator), $.copy(new_voter), $c);
  set_staking_contract_voter_(owner, $.copy(operator), $.copy(new_voter), $c);
  set_stake_pool_voter_(owner, $.copy(new_voter), $c);
  return;
}

export function buildPayload_set_voter(
  operator: HexString,
  new_voter: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "staking_proxy",
    "set_voter",
    typeParamStrings,
    [operator, new_voter],
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
  payload_set_operator(
    old_operator: HexString,
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_operator(old_operator, new_operator, isJSON);
  }
  async set_operator(
    _account: AptosAccount,
    old_operator: HexString,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_operator(
      old_operator,
      new_operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_stake_pool_operator(
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_stake_pool_operator(new_operator, isJSON);
  }
  async set_stake_pool_operator(
    _account: AptosAccount,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_stake_pool_operator(
      new_operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_stake_pool_voter(
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_stake_pool_voter(new_voter, isJSON);
  }
  async set_stake_pool_voter(
    _account: AptosAccount,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_stake_pool_voter(new_voter, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_staking_contract_operator(
    old_operator: HexString,
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_staking_contract_operator(
      old_operator,
      new_operator,
      isJSON
    );
  }
  async set_staking_contract_operator(
    _account: AptosAccount,
    old_operator: HexString,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_staking_contract_operator(
      old_operator,
      new_operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_staking_contract_voter(
    operator: HexString,
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_staking_contract_voter(operator, new_voter, isJSON);
  }
  async set_staking_contract_voter(
    _account: AptosAccount,
    operator: HexString,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_staking_contract_voter(
      operator,
      new_voter,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_vesting_contract_operator(
    old_operator: HexString,
    new_operator: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_vesting_contract_operator(
      old_operator,
      new_operator,
      isJSON
    );
  }
  async set_vesting_contract_operator(
    _account: AptosAccount,
    old_operator: HexString,
    new_operator: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_vesting_contract_operator(
      old_operator,
      new_operator,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_vesting_contract_voter(
    operator: HexString,
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_vesting_contract_voter(operator, new_voter, isJSON);
  }
  async set_vesting_contract_voter(
    _account: AptosAccount,
    operator: HexString,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_vesting_contract_voter(
      operator,
      new_voter,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_set_voter(
    operator: HexString,
    new_voter: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_set_voter(operator, new_voter, isJSON);
  }
  async set_voter(
    _account: AptosAccount,
    operator: HexString,
    new_voter: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_set_voter(operator, new_voter, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
