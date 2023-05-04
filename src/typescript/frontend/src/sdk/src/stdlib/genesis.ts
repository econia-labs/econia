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
import * as Aggregator_factory from "./aggregator_factory";
import * as Aptos_coin from "./aptos_coin";
import * as Aptos_governance from "./aptos_governance";
import * as Block from "./block";
import * as Chain_id from "./chain_id";
import * as Chain_status from "./chain_status";
import * as Coin from "./coin";
import * as Consensus_config from "./consensus_config";
import * as Error from "./error";
import * as Fixed_point32 from "./fixed_point32";
import * as Gas_schedule from "./gas_schedule";
import * as Reconfiguration from "./reconfiguration";
import * as Simple_map from "./simple_map";
import * as Stake from "./stake";
import * as Staking_config from "./staking_config";
import * as Staking_contract from "./staking_contract";
import * as State_storage from "./state_storage";
import * as Storage_gas from "./storage_gas";
import * as Timestamp from "./timestamp";
import * as Transaction_fee from "./transaction_fee";
import * as Transaction_validation from "./transaction_validation";
import * as Vector from "./vector";
import * as Version from "./version";
import * as Vesting from "./vesting";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "genesis";

export const EACCOUNT_DOES_NOT_EXIST: U64 = u64("2");
export const EDUPLICATE_ACCOUNT: U64 = u64("1");

export class AccountMap {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AccountMap";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "account_address", typeTag: AtomicTypeTag.Address },
    { name: "balance", typeTag: AtomicTypeTag.U64 },
  ];

  account_address: HexString;
  balance: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.account_address = proto["account_address"] as HexString;
    this.balance = proto["balance"] as U64;
  }

  static AccountMapParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AccountMap {
    const proto = $.parseStructProto(data, typeTag, repo, AccountMap);
    return new AccountMap(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AccountMap", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class EmployeeAccountMap {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "EmployeeAccountMap";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "accounts", typeTag: new VectorTag(AtomicTypeTag.Address) },
    {
      name: "validator",
      typeTag: new StructTag(
        new HexString("0x1"),
        "genesis",
        "ValidatorConfigurationWithCommission",
        []
      ),
    },
    {
      name: "vesting_schedule_numerator",
      typeTag: new VectorTag(AtomicTypeTag.U64),
    },
    { name: "vesting_schedule_denominator", typeTag: AtomicTypeTag.U64 },
    { name: "beneficiary_resetter", typeTag: AtomicTypeTag.Address },
  ];

  accounts: HexString[];
  validator: ValidatorConfigurationWithCommission;
  vesting_schedule_numerator: U64[];
  vesting_schedule_denominator: U64;
  beneficiary_resetter: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.accounts = proto["accounts"] as HexString[];
    this.validator = proto["validator"] as ValidatorConfigurationWithCommission;
    this.vesting_schedule_numerator = proto[
      "vesting_schedule_numerator"
    ] as U64[];
    this.vesting_schedule_denominator = proto[
      "vesting_schedule_denominator"
    ] as U64;
    this.beneficiary_resetter = proto["beneficiary_resetter"] as HexString;
  }

  static EmployeeAccountMapParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): EmployeeAccountMap {
    const proto = $.parseStructProto(data, typeTag, repo, EmployeeAccountMap);
    return new EmployeeAccountMap(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "EmployeeAccountMap", []);
  }
  async loadFullState(app: $.AppType) {
    await this.validator.loadFullState(app);
    this.__app = app;
  }
}

export class ValidatorConfiguration {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatorConfiguration";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "owner_address", typeTag: AtomicTypeTag.Address },
    { name: "operator_address", typeTag: AtomicTypeTag.Address },
    { name: "voter_address", typeTag: AtomicTypeTag.Address },
    { name: "stake_amount", typeTag: AtomicTypeTag.U64 },
    { name: "consensus_pubkey", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "proof_of_possession", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "network_addresses", typeTag: new VectorTag(AtomicTypeTag.U8) },
    {
      name: "full_node_network_addresses",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
  ];

  owner_address: HexString;
  operator_address: HexString;
  voter_address: HexString;
  stake_amount: U64;
  consensus_pubkey: U8[];
  proof_of_possession: U8[];
  network_addresses: U8[];
  full_node_network_addresses: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.owner_address = proto["owner_address"] as HexString;
    this.operator_address = proto["operator_address"] as HexString;
    this.voter_address = proto["voter_address"] as HexString;
    this.stake_amount = proto["stake_amount"] as U64;
    this.consensus_pubkey = proto["consensus_pubkey"] as U8[];
    this.proof_of_possession = proto["proof_of_possession"] as U8[];
    this.network_addresses = proto["network_addresses"] as U8[];
    this.full_node_network_addresses = proto[
      "full_node_network_addresses"
    ] as U8[];
  }

  static ValidatorConfigurationParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatorConfiguration {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      ValidatorConfiguration
    );
    return new ValidatorConfiguration(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "ValidatorConfiguration",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ValidatorConfigurationWithCommission {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatorConfigurationWithCommission";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "validator_config",
      typeTag: new StructTag(
        new HexString("0x1"),
        "genesis",
        "ValidatorConfiguration",
        []
      ),
    },
    { name: "commission_percentage", typeTag: AtomicTypeTag.U64 },
    { name: "join_during_genesis", typeTag: AtomicTypeTag.Bool },
  ];

  validator_config: ValidatorConfiguration;
  commission_percentage: U64;
  join_during_genesis: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.validator_config = proto["validator_config"] as ValidatorConfiguration;
    this.commission_percentage = proto["commission_percentage"] as U64;
    this.join_during_genesis = proto["join_during_genesis"] as boolean;
  }

  static ValidatorConfigurationWithCommissionParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatorConfigurationWithCommission {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      ValidatorConfigurationWithCommission
    );
    return new ValidatorConfigurationWithCommission(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "ValidatorConfigurationWithCommission",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.validator_config.loadFullState(app);
    this.__app = app;
  }
}
export function create_account_(
  aptos_framework: HexString,
  account_address: HexString,
  balance: U64,
  $c: AptosDataCache
): HexString {
  let temp$1, account;
  if (Account.exists_at_($.copy(account_address), $c)) {
    temp$1 = create_signer_($.copy(account_address), $c);
  } else {
    account = Account.create_account_($.copy(account_address), $c);
    Coin.register_(account, $c, [
      new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
    ]);
    Aptos_coin.mint_(
      aptos_framework,
      $.copy(account_address),
      $.copy(balance),
      $c
    );
    temp$1 = account;
  }
  return temp$1;
}

export function create_accounts_(
  aptos_framework: HexString,
  accounts: AccountMap[],
  $c: AptosDataCache
): void {
  let account_map, i, num_accounts, unique_accounts;
  i = u64("0");
  num_accounts = Vector.length_(accounts, $c, [
    new SimpleStructTag(AccountMap),
  ]);
  unique_accounts = Vector.empty_($c, [AtomicTypeTag.Address]);
  while ($.copy(i).lt($.copy(num_accounts))) {
    {
      account_map = Vector.borrow_(accounts, $.copy(i), $c, [
        new SimpleStructTag(AccountMap),
      ]);
      if (
        Vector.contains_(unique_accounts, account_map.account_address, $c, [
          AtomicTypeTag.Address,
        ])
      ) {
        throw $.abortCode(
          Error.already_exists_($.copy(EDUPLICATE_ACCOUNT), $c)
        );
      }
      Vector.push_back_(
        unique_accounts,
        $.copy(account_map.account_address),
        $c,
        [AtomicTypeTag.Address]
      );
      create_account_(
        aptos_framework,
        $.copy(account_map.account_address),
        $.copy(account_map.balance),
        $c
      );
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function create_employee_validators_(
  employee_vesting_start: U64,
  employee_vesting_period_duration: U64,
  employees: EmployeeAccountMap[],
  $c: AptosDataCache
): void {
  let temp$2,
    account,
    admin,
    admin_signer,
    buy_ins,
    coins,
    contract_address,
    employee,
    employee_group,
    event,
    i,
    j,
    j__1,
    num_employee_groups,
    num_employees_in_group,
    num_vesting_events,
    numerator,
    pool_address,
    schedule,
    total,
    unique_accounts,
    validator,
    vesting_schedule;
  i = u64("0");
  num_employee_groups = Vector.length_(employees, $c, [
    new SimpleStructTag(EmployeeAccountMap),
  ]);
  unique_accounts = Vector.empty_($c, [AtomicTypeTag.Address]);
  while ($.copy(i).lt($.copy(num_employee_groups))) {
    {
      j = u64("0");
      employee_group = Vector.borrow_(employees, $.copy(i), $c, [
        new SimpleStructTag(EmployeeAccountMap),
      ]);
      num_employees_in_group = Vector.length_(employee_group.accounts, $c, [
        AtomicTypeTag.Address,
      ]);
      buy_ins = Simple_map.create_($c, [
        AtomicTypeTag.Address,
        new StructTag(new HexString("0x1"), "coin", "Coin", [
          new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
        ]),
      ]);
      while ($.copy(j).lt($.copy(num_employees_in_group))) {
        {
          account = Vector.borrow_(employee_group.accounts, $.copy(j), $c, [
            AtomicTypeTag.Address,
          ]);
          if (
            Vector.contains_(unique_accounts, account, $c, [
              AtomicTypeTag.Address,
            ])
          ) {
            throw $.abortCode(
              Error.already_exists_($.copy(EDUPLICATE_ACCOUNT), $c)
            );
          }
          Vector.push_back_(unique_accounts, $.copy(account), $c, [
            AtomicTypeTag.Address,
          ]);
          employee = create_signer_($.copy(account), $c);
          total = Coin.balance_($.copy(account), $c, [
            new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
          ]);
          coins = Coin.withdraw_(employee, $.copy(total), $c, [
            new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
          ]);
          Simple_map.add_(buy_ins, $.copy(account), coins, $c, [
            AtomicTypeTag.Address,
            new StructTag(new HexString("0x1"), "coin", "Coin", [
              new StructTag(
                new HexString("0x1"),
                "aptos_coin",
                "AptosCoin",
                []
              ),
            ]),
          ]);
          j = $.copy(j).add(u64("1"));
        }
      }
      j__1 = u64("0");
      num_vesting_events = Vector.length_(
        employee_group.vesting_schedule_numerator,
        $c,
        [AtomicTypeTag.U64]
      );
      schedule = Vector.empty_($c, [
        new StructTag(
          new HexString("0x1"),
          "fixed_point32",
          "FixedPoint32",
          []
        ),
      ]);
      while ($.copy(j__1).lt($.copy(num_vesting_events))) {
        {
          numerator = Vector.borrow_(
            employee_group.vesting_schedule_numerator,
            $.copy(j__1),
            $c,
            [AtomicTypeTag.U64]
          );
          event = Fixed_point32.create_from_rational_(
            $.copy(numerator),
            $.copy(employee_group.vesting_schedule_denominator),
            $c
          );
          Vector.push_back_(schedule, $.copy(event), $c, [
            new StructTag(
              new HexString("0x1"),
              "fixed_point32",
              "FixedPoint32",
              []
            ),
          ]);
          j__1 = $.copy(j__1).add(u64("1"));
        }
      }
      vesting_schedule = Vesting.create_vesting_schedule_(
        $.copy(schedule),
        $.copy(employee_vesting_start),
        $.copy(employee_vesting_period_duration),
        $c
      );
      admin = $.copy(employee_group.validator.validator_config.owner_address);
      temp$2 = create_signer_($.copy(admin), $c);
      admin_signer = temp$2;
      contract_address = Vesting.create_vesting_contract_(
        admin_signer,
        employee_group.accounts,
        buy_ins,
        $.copy(vesting_schedule),
        $.copy(admin),
        $.copy(employee_group.validator.validator_config.operator_address),
        $.copy(employee_group.validator.validator_config.voter_address),
        $.copy(employee_group.validator.commission_percentage),
        [],
        $c
      );
      pool_address = Vesting.stake_pool_address_($.copy(contract_address), $c);
      if (
        $.copy(employee_group.beneficiary_resetter).hex() !==
        new HexString("0x0").hex()
      ) {
        Vesting.set_beneficiary_resetter_(
          admin_signer,
          $.copy(contract_address),
          $.copy(employee_group.beneficiary_resetter),
          $c
        );
      } else {
      }
      validator = employee_group.validator.validator_config;
      if (!Account.exists_at_($.copy(validator.owner_address), $c)) {
        throw $.abortCode(
          Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c)
        );
      }
      if (!Account.exists_at_($.copy(validator.operator_address), $c)) {
        throw $.abortCode(
          Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c)
        );
      }
      if (!Account.exists_at_($.copy(validator.voter_address), $c)) {
        throw $.abortCode(
          Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c)
        );
      }
      if ($.copy(employee_group.validator.join_during_genesis)) {
        initialize_validator_($.copy(pool_address), validator, $c);
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function create_initialize_validator_(
  aptos_framework: HexString,
  commission_config: ValidatorConfigurationWithCommission,
  use_staking_contract: boolean,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, owner, pool_address, validator;
  validator = commission_config.validator_config;
  temp$1 = create_account_(
    aptos_framework,
    $.copy(validator.owner_address),
    $.copy(validator.stake_amount),
    $c
  );
  owner = temp$1;
  create_account_(
    aptos_framework,
    $.copy(validator.operator_address),
    u64("0"),
    $c
  );
  create_account_(
    aptos_framework,
    $.copy(validator.voter_address),
    u64("0"),
    $c
  );
  if (use_staking_contract) {
    Staking_contract.create_staking_contract_(
      owner,
      $.copy(validator.operator_address),
      $.copy(validator.voter_address),
      $.copy(validator.stake_amount),
      $.copy(commission_config.commission_percentage),
      [],
      $c
    );
    temp$2 = Staking_contract.stake_pool_address_(
      $.copy(validator.owner_address),
      $.copy(validator.operator_address),
      $c
    );
  } else {
    Stake.initialize_stake_owner_(
      owner,
      $.copy(validator.stake_amount),
      $.copy(validator.operator_address),
      $.copy(validator.voter_address),
      $c
    );
    temp$2 = $.copy(validator.owner_address);
  }
  pool_address = temp$2;
  if ($.copy(commission_config.join_during_genesis)) {
    initialize_validator_($.copy(pool_address), validator, $c);
  } else {
  }
  return;
}

export function create_initialize_validators_(
  aptos_framework: HexString,
  validators: ValidatorConfiguration[],
  $c: AptosDataCache
): void {
  let i, num_validators, validator_with_commission, validators_with_commission;
  i = u64("0");
  num_validators = Vector.length_(validators, $c, [
    new SimpleStructTag(ValidatorConfiguration),
  ]);
  validators_with_commission = Vector.empty_($c, [
    new SimpleStructTag(ValidatorConfigurationWithCommission),
  ]);
  while ($.copy(i).lt($.copy(num_validators))) {
    {
      validator_with_commission = new ValidatorConfigurationWithCommission(
        {
          validator_config: Vector.pop_back_(validators, $c, [
            new SimpleStructTag(ValidatorConfiguration),
          ]),
          commission_percentage: u64("0"),
          join_during_genesis: true,
        },
        new SimpleStructTag(ValidatorConfigurationWithCommission)
      );
      Vector.push_back_(
        validators_with_commission,
        $.copy(validator_with_commission),
        $c,
        [new SimpleStructTag(ValidatorConfigurationWithCommission)]
      );
      i = $.copy(i).add(u64("1"));
    }
  }
  create_initialize_validators_with_commission_(
    aptos_framework,
    false,
    $.copy(validators_with_commission),
    $c
  );
  return;
}

export function create_initialize_validators_with_commission_(
  aptos_framework: HexString,
  use_staking_contract: boolean,
  validators: ValidatorConfigurationWithCommission[],
  $c: AptosDataCache
): void {
  let i, num_validators, validator;
  i = u64("0");
  num_validators = Vector.length_(validators, $c, [
    new SimpleStructTag(ValidatorConfigurationWithCommission),
  ]);
  while ($.copy(i).lt($.copy(num_validators))) {
    {
      validator = Vector.borrow_(validators, $.copy(i), $c, [
        new SimpleStructTag(ValidatorConfigurationWithCommission),
      ]);
      create_initialize_validator_(
        aptos_framework,
        validator,
        use_staking_contract,
        $c
      );
      i = $.copy(i).add(u64("1"));
    }
  }
  Aptos_coin.destroy_mint_cap_(aptos_framework, $c);
  Stake.on_new_epoch_($c);
  return;
}

export function create_signer_(addr: HexString, $c: AptosDataCache): HexString {
  return $.aptos_framework_genesis_create_signer(addr, $c);
}
export function initialize_(
  gas_schedule: U8[],
  chain_id: U8,
  initial_version: U64,
  consensus_config: U8[],
  epoch_interval_microsecs: U64,
  minimum_stake: U64,
  maximum_stake: U64,
  recurring_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  voting_power_increase_limit: U64,
  $c: AptosDataCache
): void {
  let address,
    aptos_account,
    aptos_framework_account,
    aptos_framework_signer_cap,
    framework_reserved_addresses,
    framework_signer_cap;
  [aptos_framework_account, aptos_framework_signer_cap] =
    Account.create_framework_reserved_account_(new HexString("0x1"), $c);
  Account.initialize_(aptos_framework_account, $c);
  Transaction_validation.initialize_(
    aptos_framework_account,
    [
      u8("115"),
      u8("99"),
      u8("114"),
      u8("105"),
      u8("112"),
      u8("116"),
      u8("95"),
      u8("112"),
      u8("114"),
      u8("111"),
      u8("108"),
      u8("111"),
      u8("103"),
      u8("117"),
      u8("101"),
    ],
    [
      u8("109"),
      u8("111"),
      u8("100"),
      u8("117"),
      u8("108"),
      u8("101"),
      u8("95"),
      u8("112"),
      u8("114"),
      u8("111"),
      u8("108"),
      u8("111"),
      u8("103"),
      u8("117"),
      u8("101"),
    ],
    [
      u8("109"),
      u8("117"),
      u8("108"),
      u8("116"),
      u8("105"),
      u8("95"),
      u8("97"),
      u8("103"),
      u8("101"),
      u8("110"),
      u8("116"),
      u8("95"),
      u8("115"),
      u8("99"),
      u8("114"),
      u8("105"),
      u8("112"),
      u8("116"),
      u8("95"),
      u8("112"),
      u8("114"),
      u8("111"),
      u8("108"),
      u8("111"),
      u8("103"),
      u8("117"),
      u8("101"),
    ],
    [
      u8("101"),
      u8("112"),
      u8("105"),
      u8("108"),
      u8("111"),
      u8("103"),
      u8("117"),
      u8("101"),
    ],
    $c
  );
  Aptos_governance.store_signer_cap_(
    aptos_framework_account,
    new HexString("0x1"),
    aptos_framework_signer_cap,
    $c
  );
  framework_reserved_addresses = [
    new HexString("0x2"),
    new HexString("0x3"),
    new HexString("0x4"),
    new HexString("0x5"),
    new HexString("0x6"),
    new HexString("0x7"),
    new HexString("0x8"),
    new HexString("0x9"),
    new HexString("0xa"),
  ];
  while (
    !Vector.is_empty_(framework_reserved_addresses, $c, [AtomicTypeTag.Address])
  ) {
    {
      address = Vector.pop_back_(framework_reserved_addresses, $c, [
        AtomicTypeTag.Address,
      ]);
      [aptos_account, framework_signer_cap] =
        Account.create_framework_reserved_account_($.copy(address), $c);
      Aptos_governance.store_signer_cap_(
        aptos_account,
        $.copy(address),
        framework_signer_cap,
        $c
      );
    }
  }
  Consensus_config.initialize_(
    aptos_framework_account,
    $.copy(consensus_config),
    $c
  );
  Version.initialize_(aptos_framework_account, $.copy(initial_version), $c);
  Stake.initialize_(aptos_framework_account, $c);
  Staking_config.initialize_(
    aptos_framework_account,
    $.copy(minimum_stake),
    $.copy(maximum_stake),
    $.copy(recurring_lockup_duration_secs),
    allow_validator_set_change,
    $.copy(rewards_rate),
    $.copy(rewards_rate_denominator),
    $.copy(voting_power_increase_limit),
    $c
  );
  Storage_gas.initialize_(aptos_framework_account, $c);
  Gas_schedule.initialize_(aptos_framework_account, $.copy(gas_schedule), $c);
  Aggregator_factory.initialize_aggregator_factory_(
    aptos_framework_account,
    $c
  );
  Coin.initialize_supply_config_(aptos_framework_account, $c);
  Chain_id.initialize_(aptos_framework_account, $.copy(chain_id), $c);
  Reconfiguration.initialize_(aptos_framework_account, $c);
  Block.initialize_(
    aptos_framework_account,
    $.copy(epoch_interval_microsecs),
    $c
  );
  State_storage.initialize_(aptos_framework_account, $c);
  Timestamp.set_time_has_started_(aptos_framework_account, $c);
  return;
}

export function initialize_aptos_coin_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  let burn_cap, mint_cap;
  [burn_cap, mint_cap] = Aptos_coin.initialize_(aptos_framework, $c);
  Stake.store_aptos_coin_mint_cap_(aptos_framework, $.copy(mint_cap), $c);
  Transaction_fee.store_aptos_coin_burn_cap_(
    aptos_framework,
    $.copy(burn_cap),
    $c
  );
  return;
}

export function initialize_core_resources_and_aptos_coin_(
  aptos_framework: HexString,
  core_resources_auth_key: U8[],
  $c: AptosDataCache
): void {
  let burn_cap, core_resources, mint_cap;
  [burn_cap, mint_cap] = Aptos_coin.initialize_(aptos_framework, $c);
  Stake.store_aptos_coin_mint_cap_(aptos_framework, $.copy(mint_cap), $c);
  Transaction_fee.store_aptos_coin_burn_cap_(
    aptos_framework,
    $.copy(burn_cap),
    $c
  );
  core_resources = Account.create_account_(new HexString("0xa550c18"), $c);
  Account.rotate_authentication_key_internal_(
    core_resources,
    $.copy(core_resources_auth_key),
    $c
  );
  Aptos_coin.configure_accounts_for_test_(
    aptos_framework,
    core_resources,
    $.copy(mint_cap),
    $c
  );
  return;
}

export function initialize_for_verification_(
  gas_schedule: U8[],
  chain_id: U8,
  initial_version: U64,
  consensus_config: U8[],
  epoch_interval_microsecs: U64,
  minimum_stake: U64,
  maximum_stake: U64,
  recurring_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  voting_power_increase_limit: U64,
  aptos_framework: HexString,
  validators: ValidatorConfiguration[],
  min_voting_threshold: U128,
  required_proposer_stake: U64,
  voting_duration_secs: U64,
  $c: AptosDataCache
): void {
  initialize_(
    $.copy(gas_schedule),
    $.copy(chain_id),
    $.copy(initial_version),
    $.copy(consensus_config),
    $.copy(epoch_interval_microsecs),
    $.copy(minimum_stake),
    $.copy(maximum_stake),
    $.copy(recurring_lockup_duration_secs),
    allow_validator_set_change,
    $.copy(rewards_rate),
    $.copy(rewards_rate_denominator),
    $.copy(voting_power_increase_limit),
    $c
  );
  initialize_aptos_coin_(aptos_framework, $c);
  Aptos_governance.initialize_for_verification_(
    aptos_framework,
    $.copy(min_voting_threshold),
    $.copy(required_proposer_stake),
    $.copy(voting_duration_secs),
    $c
  );
  create_initialize_validators_(aptos_framework, $.copy(validators), $c);
  set_genesis_end_(aptos_framework, $c);
  return;
}

export function initialize_validator_(
  pool_address: HexString,
  validator: ValidatorConfiguration,
  $c: AptosDataCache
): void {
  let temp$1, operator;
  temp$1 = create_signer_($.copy(validator.operator_address), $c);
  operator = temp$1;
  Stake.rotate_consensus_key_(
    operator,
    $.copy(pool_address),
    $.copy(validator.consensus_pubkey),
    $.copy(validator.proof_of_possession),
    $c
  );
  Stake.update_network_and_fullnode_addresses_(
    operator,
    $.copy(pool_address),
    $.copy(validator.network_addresses),
    $.copy(validator.full_node_network_addresses),
    $c
  );
  Stake.join_validator_set_internal_(operator, $.copy(pool_address), $c);
  return;
}

export function set_genesis_end_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  Chain_status.set_genesis_end_(aptos_framework, $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::genesis::AccountMap", AccountMap.AccountMapParser);
  repo.addParser(
    "0x1::genesis::EmployeeAccountMap",
    EmployeeAccountMap.EmployeeAccountMapParser
  );
  repo.addParser(
    "0x1::genesis::ValidatorConfiguration",
    ValidatorConfiguration.ValidatorConfigurationParser
  );
  repo.addParser(
    "0x1::genesis::ValidatorConfigurationWithCommission",
    ValidatorConfigurationWithCommission.ValidatorConfigurationWithCommissionParser
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
  get AccountMap() {
    return AccountMap;
  }
  get EmployeeAccountMap() {
    return EmployeeAccountMap;
  }
  get ValidatorConfiguration() {
    return ValidatorConfiguration;
  }
  get ValidatorConfigurationWithCommission() {
    return ValidatorConfigurationWithCommission;
  }
}
