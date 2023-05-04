import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, type U128 } from "@manahippo/move-to-ts";
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
import * as Simple_map from "./simple_map";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "pool_u64";

export const EINSUFFICIENT_SHARES: U64 = u64("4");
export const EPOOL_IS_NOT_EMPTY: U64 = u64("3");
export const EPOOL_TOTAL_COINS_OVERFLOW: U64 = u64("6");
export const EPOOL_TOTAL_SHARES_OVERFLOW: U64 = u64("7");
export const ESHAREHOLDER_NOT_FOUND: U64 = u64("1");
export const ESHAREHOLDER_SHARES_OVERFLOW: U64 = u64("5");
export const ETOO_MANY_SHAREHOLDERS: U64 = u64("2");
export const MAX_U64: U64 = u64("18446744073709551615");

export class Pool {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Pool";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "shareholders_limit", typeTag: AtomicTypeTag.U64 },
    { name: "total_coins", typeTag: AtomicTypeTag.U64 },
    { name: "total_shares", typeTag: AtomicTypeTag.U64 },
    {
      name: "shares",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        AtomicTypeTag.Address,
        AtomicTypeTag.U64,
      ]),
    },
    { name: "shareholders", typeTag: new VectorTag(AtomicTypeTag.Address) },
    { name: "scaling_factor", typeTag: AtomicTypeTag.U64 },
  ];

  shareholders_limit: U64;
  total_coins: U64;
  total_shares: U64;
  shares: Simple_map.SimpleMap;
  shareholders: HexString[];
  scaling_factor: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.shareholders_limit = proto["shareholders_limit"] as U64;
    this.total_coins = proto["total_coins"] as U64;
    this.total_shares = proto["total_shares"] as U64;
    this.shares = proto["shares"] as Simple_map.SimpleMap;
    this.shareholders = proto["shareholders"] as HexString[];
    this.scaling_factor = proto["scaling_factor"] as U64;
  }

  static PoolParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): Pool {
    const proto = $.parseStructProto(data, typeTag, repo, Pool);
    return new Pool(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Pool", []);
  }
  async loadFullState(app: $.AppType) {
    await this.shares.loadFullState(app);
    this.__app = app;
  }
}
export function add_shares_(
  pool: Pool,
  shareholder: HexString,
  new_shares: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2, temp$3, temp$4, current_shares, existing_shares;
  [temp$1, temp$2] = [pool, $.copy(shareholder)];
  if (contains_(temp$1, temp$2, $c)) {
    existing_shares = Simple_map.borrow_mut_(pool.shares, shareholder, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.U64,
    ]);
    current_shares = $.copy(existing_shares);
    if (!$.copy(MAX_U64).sub($.copy(current_shares)).ge($.copy(new_shares))) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(ESHAREHOLDER_SHARES_OVERFLOW), $c)
      );
    }
    $.set(existing_shares, $.copy(current_shares).add($.copy(new_shares)));
    temp$4 = $.copy(existing_shares);
  } else {
    if ($.copy(new_shares).gt(u64("0"))) {
      if (
        !Vector.length_(pool.shareholders, $c, [AtomicTypeTag.Address]).lt(
          $.copy(pool.shareholders_limit)
        )
      ) {
        throw $.abortCode(
          Error.invalid_state_($.copy(ETOO_MANY_SHAREHOLDERS), $c)
        );
      }
      Vector.push_back_(pool.shareholders, $.copy(shareholder), $c, [
        AtomicTypeTag.Address,
      ]);
      Simple_map.add_(
        pool.shares,
        $.copy(shareholder),
        $.copy(new_shares),
        $c,
        [AtomicTypeTag.Address, AtomicTypeTag.U64]
      );
      temp$3 = $.copy(new_shares);
    } else {
      temp$3 = $.copy(new_shares);
    }
    temp$4 = temp$3;
  }
  return temp$4;
}

export function amount_to_shares_(
  pool: Pool,
  coins_amount: U64,
  $c: AptosDataCache
): U64 {
  return amount_to_shares_with_total_coins_(
    pool,
    $.copy(coins_amount),
    $.copy(pool.total_coins),
    $c
  );
}

export function amount_to_shares_with_total_coins_(
  pool: Pool,
  coins_amount: U64,
  total_coins: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2;
  if ($.copy(pool.total_coins).eq(u64("0"))) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(pool.total_shares).eq(u64("0"));
  }
  if (temp$1) {
    temp$2 = $.copy(coins_amount).mul($.copy(pool.scaling_factor));
  } else {
    temp$2 = multiply_then_divide_(
      pool,
      $.copy(coins_amount),
      $.copy(pool.total_shares),
      $.copy(total_coins),
      $c
    );
  }
  return temp$2;
}

export function balance_(
  pool: Pool,
  shareholder: HexString,
  $c: AptosDataCache
): U64 {
  let num_shares;
  num_shares = shares_(pool, $.copy(shareholder), $c);
  return shares_to_amount_(pool, $.copy(num_shares), $c);
}

export function buy_in_(
  pool: Pool,
  shareholder: HexString,
  coins_amount: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2, new_shares;
  if ($.copy(coins_amount).eq(u64("0"))) {
    return u64("0");
  } else {
  }
  [temp$1, temp$2] = [pool, $.copy(coins_amount)];
  new_shares = amount_to_shares_(temp$1, temp$2, $c);
  if (!$.copy(MAX_U64).sub($.copy(pool.total_coins)).ge($.copy(coins_amount))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EPOOL_TOTAL_COINS_OVERFLOW), $c)
    );
  }
  if (!$.copy(MAX_U64).sub($.copy(pool.total_shares)).ge($.copy(new_shares))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EPOOL_TOTAL_COINS_OVERFLOW), $c)
    );
  }
  pool.total_coins = $.copy(pool.total_coins).add($.copy(coins_amount));
  pool.total_shares = $.copy(pool.total_shares).add($.copy(new_shares));
  add_shares_(pool, $.copy(shareholder), $.copy(new_shares), $c);
  return $.copy(new_shares);
}

export function contains_(
  pool: Pool,
  shareholder: HexString,
  $c: AptosDataCache
): boolean {
  return Simple_map.contains_key_(pool.shares, shareholder, $c, [
    AtomicTypeTag.Address,
    AtomicTypeTag.U64,
  ]);
}

export function create_(shareholders_limit: U64, $c: AptosDataCache): Pool {
  return create_with_scaling_factor_($.copy(shareholders_limit), u64("1"), $c);
}

export function create_with_scaling_factor_(
  shareholders_limit: U64,
  scaling_factor: U64,
  $c: AptosDataCache
): Pool {
  return new Pool(
    {
      shareholders_limit: $.copy(shareholders_limit),
      total_coins: u64("0"),
      total_shares: u64("0"),
      shares: Simple_map.create_($c, [
        AtomicTypeTag.Address,
        AtomicTypeTag.U64,
      ]),
      shareholders: Vector.empty_($c, [AtomicTypeTag.Address]),
      scaling_factor: $.copy(scaling_factor),
    },
    new SimpleStructTag(Pool)
  );
}

export function deduct_shares_(
  pool: Pool,
  shareholder: HexString,
  num_shares: U64,
  $c: AptosDataCache
): U64 {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    existing_shares,
    remaining_shares,
    shareholder_index;
  [temp$1, temp$2] = [pool, $.copy(shareholder)];
  if (!contains_(temp$1, temp$2, $c)) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ESHAREHOLDER_NOT_FOUND), $c)
    );
  }
  [temp$3, temp$4] = [pool, $.copy(shareholder)];
  if (!shares_(temp$3, temp$4, $c).ge($.copy(num_shares))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_SHARES), $c)
    );
  }
  existing_shares = Simple_map.borrow_mut_(pool.shares, shareholder, $c, [
    AtomicTypeTag.Address,
    AtomicTypeTag.U64,
  ]);
  $.set(existing_shares, $.copy(existing_shares).sub($.copy(num_shares)));
  remaining_shares = $.copy(existing_shares);
  if ($.copy(remaining_shares).eq(u64("0"))) {
    [, shareholder_index] = Vector.index_of_(
      pool.shareholders,
      shareholder,
      $c,
      [AtomicTypeTag.Address]
    );
    Vector.remove_(pool.shareholders, $.copy(shareholder_index), $c, [
      AtomicTypeTag.Address,
    ]);
    Simple_map.remove_(pool.shares, shareholder, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.U64,
    ]);
  } else {
  }
  return $.copy(remaining_shares);
}

export function destroy_empty_(pool: Pool, $c: AptosDataCache): void {
  if (!$.copy(pool.total_coins).eq(u64("0"))) {
    throw $.abortCode(Error.invalid_state_($.copy(EPOOL_IS_NOT_EMPTY), $c));
  }
  pool;
  return;
}

export function multiply_then_divide_(
  _pool: Pool,
  x: U64,
  y: U64,
  z: U64,
  $c: AptosDataCache
): U64 {
  let result;
  result = to_u128_($.copy(x), $c)
    .mul(to_u128_($.copy(y), $c))
    .div(to_u128_($.copy(z), $c));
  return u64($.copy(result));
}

export function redeem_shares_(
  pool: Pool,
  shareholder: HexString,
  shares_to_redeem: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, redeemed_coins;
  [temp$1, temp$2] = [pool, $.copy(shareholder)];
  if (!contains_(temp$1, temp$2, $c)) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ESHAREHOLDER_NOT_FOUND), $c)
    );
  }
  [temp$3, temp$4] = [pool, $.copy(shareholder)];
  if (!shares_(temp$3, temp$4, $c).ge($.copy(shares_to_redeem))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_SHARES), $c)
    );
  }
  if ($.copy(shares_to_redeem).eq(u64("0"))) {
    return u64("0");
  } else {
  }
  [temp$5, temp$6] = [pool, $.copy(shares_to_redeem)];
  redeemed_coins = shares_to_amount_(temp$5, temp$6, $c);
  pool.total_coins = $.copy(pool.total_coins).sub($.copy(redeemed_coins));
  pool.total_shares = $.copy(pool.total_shares).sub($.copy(shares_to_redeem));
  deduct_shares_(pool, $.copy(shareholder), $.copy(shares_to_redeem), $c);
  return $.copy(redeemed_coins);
}

export function shareholders_(pool: Pool, $c: AptosDataCache): HexString[] {
  return $.copy(pool.shareholders);
}

export function shareholders_count_(pool: Pool, $c: AptosDataCache): U64 {
  return Vector.length_(pool.shareholders, $c, [AtomicTypeTag.Address]);
}

export function shares_(
  pool: Pool,
  shareholder: HexString,
  $c: AptosDataCache
): U64 {
  let temp$1;
  if (contains_(pool, $.copy(shareholder), $c)) {
    temp$1 = $.copy(
      Simple_map.borrow_(pool.shares, shareholder, $c, [
        AtomicTypeTag.Address,
        AtomicTypeTag.U64,
      ])
    );
  } else {
    temp$1 = u64("0");
  }
  return temp$1;
}

export function shares_to_amount_(
  pool: Pool,
  shares: U64,
  $c: AptosDataCache
): U64 {
  return shares_to_amount_with_total_coins_(
    pool,
    $.copy(shares),
    $.copy(pool.total_coins),
    $c
  );
}

export function shares_to_amount_with_total_coins_(
  pool: Pool,
  shares: U64,
  total_coins: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2;
  if ($.copy(pool.total_coins).eq(u64("0"))) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(pool.total_shares).eq(u64("0"));
  }
  if (temp$1) {
    temp$2 = u64("0");
  } else {
    temp$2 = multiply_then_divide_(
      pool,
      $.copy(shares),
      $.copy(total_coins),
      $.copy(pool.total_shares),
      $c
    );
  }
  return temp$2;
}

export function to_u128_(num: U64, $c: AptosDataCache): U128 {
  return u128($.copy(num));
}

export function total_coins_(pool: Pool, $c: AptosDataCache): U64 {
  return $.copy(pool.total_coins);
}

export function total_shares_(pool: Pool, $c: AptosDataCache): U64 {
  return $.copy(pool.total_shares);
}

export function transfer_shares_(
  pool: Pool,
  shareholder_1: HexString,
  shareholder_2: HexString,
  shares_to_transfer: U64,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, temp$3, temp$4;
  [temp$1, temp$2] = [pool, $.copy(shareholder_1)];
  if (!contains_(temp$1, temp$2, $c)) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ESHAREHOLDER_NOT_FOUND), $c)
    );
  }
  [temp$3, temp$4] = [pool, $.copy(shareholder_1)];
  if (!shares_(temp$3, temp$4, $c).ge($.copy(shares_to_transfer))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINSUFFICIENT_SHARES), $c)
    );
  }
  if ($.copy(shares_to_transfer).eq(u64("0"))) {
    return;
  } else {
  }
  deduct_shares_(pool, $.copy(shareholder_1), $.copy(shares_to_transfer), $c);
  add_shares_(pool, $.copy(shareholder_2), $.copy(shares_to_transfer), $c);
  return;
}

export function update_total_coins_(
  pool: Pool,
  new_total_coins: U64,
  $c: AptosDataCache
): void {
  pool.total_coins = $.copy(new_total_coins);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::pool_u64::Pool", Pool.PoolParser);
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
  get Pool() {
    return Pool;
  }
}
