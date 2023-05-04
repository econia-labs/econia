import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, U128 } from "@manahippo/move-to-ts";
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

import * as Error from "./error";
import * as System_addresses from "./system_addresses";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "staking_config";

export const EINVALID_REWARDS_RATE: U64 = u64("5");
export const EINVALID_STAKE_RANGE: U64 = u64("3");
export const EINVALID_VOTING_POWER_INCREASE_LIMIT: U64 = u64("4");
export const EZERO_LOCKUP_DURATION: U64 = u64("1");
export const EZERO_REWARDS_RATE_DENOMINATOR: U64 = u64("2");
export const MAX_REWARDS_RATE: U64 = u64("1000000");

export class StakingConfig {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StakingConfig";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "minimum_stake", typeTag: AtomicTypeTag.U64 },
    { name: "maximum_stake", typeTag: AtomicTypeTag.U64 },
    { name: "recurring_lockup_duration_secs", typeTag: AtomicTypeTag.U64 },
    { name: "allow_validator_set_change", typeTag: AtomicTypeTag.Bool },
    { name: "rewards_rate", typeTag: AtomicTypeTag.U64 },
    { name: "rewards_rate_denominator", typeTag: AtomicTypeTag.U64 },
    { name: "voting_power_increase_limit", typeTag: AtomicTypeTag.U64 },
  ];

  minimum_stake: U64;
  maximum_stake: U64;
  recurring_lockup_duration_secs: U64;
  allow_validator_set_change: boolean;
  rewards_rate: U64;
  rewards_rate_denominator: U64;
  voting_power_increase_limit: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.minimum_stake = proto["minimum_stake"] as U64;
    this.maximum_stake = proto["maximum_stake"] as U64;
    this.recurring_lockup_duration_secs = proto[
      "recurring_lockup_duration_secs"
    ] as U64;
    this.allow_validator_set_change = proto[
      "allow_validator_set_change"
    ] as boolean;
    this.rewards_rate = proto["rewards_rate"] as U64;
    this.rewards_rate_denominator = proto["rewards_rate_denominator"] as U64;
    this.voting_power_increase_limit = proto[
      "voting_power_increase_limit"
    ] as U64;
  }

  static StakingConfigParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StakingConfig {
    const proto = $.parseStructProto(data, typeTag, repo, StakingConfig);
    return new StakingConfig(proto, typeTag);
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
      StakingConfig,
      typeParams
    );
    return result as unknown as StakingConfig;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      StakingConfig,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as StakingConfig;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StakingConfig", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function get_($c: AptosDataCache): StakingConfig {
  return $.copy(
    $c.borrow_global<StakingConfig>(
      new SimpleStructTag(StakingConfig),
      new HexString("0x1")
    )
  );
}

export function get_allow_validator_set_change_(
  config: StakingConfig,
  $c: AptosDataCache
): boolean {
  return $.copy(config.allow_validator_set_change);
}

export function get_recurring_lockup_duration_(
  config: StakingConfig,
  $c: AptosDataCache
): U64 {
  return $.copy(config.recurring_lockup_duration_secs);
}

export function get_required_stake_(
  config: StakingConfig,
  $c: AptosDataCache
): [U64, U64] {
  return [$.copy(config.minimum_stake), $.copy(config.maximum_stake)];
}

export function get_reward_rate_(
  config: StakingConfig,
  $c: AptosDataCache
): [U64, U64] {
  return [$.copy(config.rewards_rate), $.copy(config.rewards_rate_denominator)];
}

export function get_voting_power_increase_limit_(
  config: StakingConfig,
  $c: AptosDataCache
): U64 {
  return $.copy(config.voting_power_increase_limit);
}

export function initialize_(
  aptos_framework: HexString,
  minimum_stake: U64,
  maximum_stake: U64,
  recurring_lockup_duration_secs: U64,
  allow_validator_set_change: boolean,
  rewards_rate: U64,
  rewards_rate_denominator: U64,
  voting_power_increase_limit: U64,
  $c: AptosDataCache
): void {
  let temp$1;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  validate_required_stake_($.copy(minimum_stake), $.copy(maximum_stake), $c);
  if (!$.copy(recurring_lockup_duration_secs).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_LOCKUP_DURATION), $c)
    );
  }
  if (!$.copy(rewards_rate_denominator).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_REWARDS_RATE_DENOMINATOR), $c)
    );
  }
  if ($.copy(voting_power_increase_limit).gt(u64("0"))) {
    temp$1 = $.copy(voting_power_increase_limit).le(u64("50"));
  } else {
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_VOTING_POWER_INCREASE_LIMIT), $c)
    );
  }
  if (!$.copy(rewards_rate).le($.copy(MAX_REWARDS_RATE))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_REWARDS_RATE), $c)
    );
  }
  if (!$.copy(rewards_rate).le($.copy(rewards_rate_denominator))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_REWARDS_RATE), $c)
    );
  }
  $c.move_to(
    new SimpleStructTag(StakingConfig),
    aptos_framework,
    new StakingConfig(
      {
        minimum_stake: $.copy(minimum_stake),
        maximum_stake: $.copy(maximum_stake),
        recurring_lockup_duration_secs: $.copy(recurring_lockup_duration_secs),
        allow_validator_set_change: allow_validator_set_change,
        rewards_rate: $.copy(rewards_rate),
        rewards_rate_denominator: $.copy(rewards_rate_denominator),
        voting_power_increase_limit: $.copy(voting_power_increase_limit),
      },
      new SimpleStructTag(StakingConfig)
    )
  );
  return;
}

export function update_recurring_lockup_duration_secs_(
  aptos_framework: HexString,
  new_recurring_lockup_duration_secs: U64,
  $c: AptosDataCache
): void {
  let staking_config;
  if (!$.copy(new_recurring_lockup_duration_secs).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_LOCKUP_DURATION), $c)
    );
  }
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  staking_config = $c.borrow_global_mut<StakingConfig>(
    new SimpleStructTag(StakingConfig),
    new HexString("0x1")
  );
  staking_config.recurring_lockup_duration_secs = $.copy(
    new_recurring_lockup_duration_secs
  );
  return;
}

export function update_required_stake_(
  aptos_framework: HexString,
  minimum_stake: U64,
  maximum_stake: U64,
  $c: AptosDataCache
): void {
  let staking_config;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  validate_required_stake_($.copy(minimum_stake), $.copy(maximum_stake), $c);
  staking_config = $c.borrow_global_mut<StakingConfig>(
    new SimpleStructTag(StakingConfig),
    new HexString("0x1")
  );
  staking_config.minimum_stake = $.copy(minimum_stake);
  staking_config.maximum_stake = $.copy(maximum_stake);
  return;
}

export function update_rewards_rate_(
  aptos_framework: HexString,
  new_rewards_rate: U64,
  new_rewards_rate_denominator: U64,
  $c: AptosDataCache
): void {
  let staking_config;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if (!$.copy(new_rewards_rate_denominator).gt(u64("0"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EZERO_REWARDS_RATE_DENOMINATOR), $c)
    );
  }
  if (!$.copy(new_rewards_rate).le($.copy(MAX_REWARDS_RATE))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_REWARDS_RATE), $c)
    );
  }
  if (!$.copy(new_rewards_rate).le($.copy(new_rewards_rate_denominator))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_REWARDS_RATE), $c)
    );
  }
  staking_config = $c.borrow_global_mut<StakingConfig>(
    new SimpleStructTag(StakingConfig),
    new HexString("0x1")
  );
  staking_config.rewards_rate = $.copy(new_rewards_rate);
  staking_config.rewards_rate_denominator = $.copy(
    new_rewards_rate_denominator
  );
  return;
}

export function update_voting_power_increase_limit_(
  aptos_framework: HexString,
  new_voting_power_increase_limit: U64,
  $c: AptosDataCache
): void {
  let temp$1, staking_config;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if ($.copy(new_voting_power_increase_limit).gt(u64("0"))) {
    temp$1 = $.copy(new_voting_power_increase_limit).le(u64("50"));
  } else {
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_VOTING_POWER_INCREASE_LIMIT), $c)
    );
  }
  staking_config = $c.borrow_global_mut<StakingConfig>(
    new SimpleStructTag(StakingConfig),
    new HexString("0x1")
  );
  staking_config.voting_power_increase_limit = $.copy(
    new_voting_power_increase_limit
  );
  return;
}

export function validate_required_stake_(
  minimum_stake: U64,
  maximum_stake: U64,
  $c: AptosDataCache
): void {
  let temp$1;
  if ($.copy(minimum_stake).le($.copy(maximum_stake))) {
    temp$1 = $.copy(maximum_stake).gt(u64("0"));
  } else {
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_STAKE_RANGE), $c)
    );
  }
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::staking_config::StakingConfig",
    StakingConfig.StakingConfigParser
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
  get StakingConfig() {
    return StakingConfig;
  }
  async loadStakingConfig(owner: HexString, loadFull = true, fillCache = true) {
    const val = await StakingConfig.load(
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
