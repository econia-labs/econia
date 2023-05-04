import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, U128 } from "@manahippo/move-to-ts";
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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Stdlib from "../stdlib";
import * as Resource_account from "./resource_account";
import * as Tablist from "./tablist";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "incentives";

export const BUY = false;
export const CUSTODIAN_REGISTRATION_FEE: U64 = u64("250000");
export const E_ACTIVATION_FEE_TOO_SMALL: U64 = u64("9");
export const E_CUSTODIAN_REGISTRATION_FEE_LESS_THAN_MIN: U64 = u64("6");
export const E_ECONIA_FEE_STORE_OVERFLOW: U64 = u64("20");
export const E_EMPTY_FEE_STORE_TIERS: U64 = u64("2");
export const E_FEE_SHARE_DIVISOR_TOO_BIG: U64 = u64("3");
export const E_FEE_SHARE_DIVISOR_TOO_SMALL: U64 = u64("4");
export const E_FEWER_TIERS: U64 = u64("16");
export const E_FIRST_TIER_ACTIVATION_FEE_NONZERO: U64 = u64("17");
export const E_INTEGRATOR_FEE_STORE_OVERFLOW: U64 = u64("19");
export const E_INVALID_TIER: U64 = u64("22");
export const E_INVALID_UTILITY_COIN_TYPE: U64 = u64("12");
export const E_MARKET_REGISTRATION_FEE_LESS_THAN_MIN: U64 = u64("5");
export const E_NOT_AN_UPGRADE: U64 = u64("15");
export const E_NOT_COIN: U64 = u64("1");
export const E_NOT_ECONIA: U64 = u64("0");
export const E_NOT_ENOUGH_UTILITY_COINS: U64 = u64("13");
export const E_TAKER_DIVISOR_LESS_THAN_MIN: U64 = u64("7");
export const E_TIER_FIELDS_WRONG_LENGTH: U64 = u64("8");
export const E_TOO_MANY_TIERS: U64 = u64("14");
export const E_UNDERWRITER_REGISTRATION_FEE_LESS_THAN_MIN: U64 = u64("18");
export const E_UTILITY_COIN_STORE_OVERFLOW: U64 = u64("21");
export const E_WITHDRAWAL_FEE_TOO_BIG: U64 = u64("10");
export const E_WITHDRAWAL_FEE_TOO_SMALL: U64 = u64("11");
export const FEE_SHARE_DIVISOR_0: U64 = u64("10000");
export const FEE_SHARE_DIVISOR_1: U64 = u64("8333");
export const FEE_SHARE_DIVISOR_2: U64 = u64("7692");
export const FEE_SHARE_DIVISOR_3: U64 = u64("7143");
export const FEE_SHARE_DIVISOR_4: U64 = u64("6667");
export const FEE_SHARE_DIVISOR_5: U64 = u64("6250");
export const FEE_SHARE_DIVISOR_6: U64 = u64("5882");
export const FEE_SHARE_DIVISOR_INDEX: U64 = u64("0");
export const HI_64: U64 = u64("18446744073709551615");
export const MARKET_REGISTRATION_FEE: U64 = u64("625000000");
export const MAX_INTEGRATOR_FEE_STORE_TIERS: U64 = u64("255");
export const MIN_DIVISOR: U64 = u64("2");
export const MIN_FEE: U64 = u64("1");
export const N_TIER_FIELDS: U64 = u64("3");
export const SELL = true;
export const TAKER_FEE_DIVISOR: U64 = u64("2000");
export const TIER_ACTIVATION_FEE_0: U64 = u64("0");
export const TIER_ACTIVATION_FEE_1: U64 = u64("5000000");
export const TIER_ACTIVATION_FEE_2: U64 = u64("75000000");
export const TIER_ACTIVATION_FEE_3: U64 = u64("1000000000");
export const TIER_ACTIVATION_FEE_4: U64 = u64("12500000000");
export const TIER_ACTIVATION_FEE_5: U64 = u64("150000000000");
export const TIER_ACTIVATION_FEE_6: U64 = u64("1750000000000");
export const TIER_ACTIVATION_FEE_INDEX: U64 = u64("1");
export const UNDERWRITER_REGISTRATION_FEE: U64 = u64("250000");
export const WITHDRAWAL_FEE_0: U64 = u64("5000000");
export const WITHDRAWAL_FEE_1: U64 = u64("4750000");
export const WITHDRAWAL_FEE_2: U64 = u64("4500000");
export const WITHDRAWAL_FEE_3: U64 = u64("4250000");
export const WITHDRAWAL_FEE_4: U64 = u64("4000000");
export const WITHDRAWAL_FEE_5: U64 = u64("3750000");
export const WITHDRAWAL_FEE_6: U64 = u64("3500000");
export const WITHDRAWAL_FEE_INDEX: U64 = u64("2");

export class EconiaFeeStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "EconiaFeeStore";
  static typeParameters: TypeParamDeclType[] = [
    { name: "QuoteCoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "map",
      typeTag: new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "tablist",
        "Tablist",
        [
          AtomicTypeTag.U64,
          new StructTag(new HexString("0x1"), "coin", "Coin", [
            new $.TypeParamIdx(0),
          ]),
        ]
      ),
    },
  ];

  map: Tablist.Tablist;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto["map"] as Tablist.Tablist;
  }

  static EconiaFeeStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): EconiaFeeStore {
    const proto = $.parseStructProto(data, typeTag, repo, EconiaFeeStore);
    return new EconiaFeeStore(proto, typeTag);
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
      EconiaFeeStore,
      typeParams
    );
    return result as unknown as EconiaFeeStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      EconiaFeeStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as EconiaFeeStore;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "EconiaFeeStore", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.map.loadFullState(app);
    this.__app = app;
  }
}

export class IncentiveParameters {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "IncentiveParameters";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "utility_coin_type_info",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
    { name: "market_registration_fee", typeTag: AtomicTypeTag.U64 },
    { name: "underwriter_registration_fee", typeTag: AtomicTypeTag.U64 },
    { name: "custodian_registration_fee", typeTag: AtomicTypeTag.U64 },
    { name: "taker_fee_divisor", typeTag: AtomicTypeTag.U64 },
    {
      name: "integrator_fee_store_tiers",
      typeTag: new VectorTag(
        new StructTag(
          new HexString(
            "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
          ),
          "incentives",
          "IntegratorFeeStoreTierParameters",
          []
        )
      ),
    },
  ];

  utility_coin_type_info: Stdlib.Type_info.TypeInfo;
  market_registration_fee: U64;
  underwriter_registration_fee: U64;
  custodian_registration_fee: U64;
  taker_fee_divisor: U64;
  integrator_fee_store_tiers: IntegratorFeeStoreTierParameters[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.utility_coin_type_info = proto[
      "utility_coin_type_info"
    ] as Stdlib.Type_info.TypeInfo;
    this.market_registration_fee = proto["market_registration_fee"] as U64;
    this.underwriter_registration_fee = proto[
      "underwriter_registration_fee"
    ] as U64;
    this.custodian_registration_fee = proto[
      "custodian_registration_fee"
    ] as U64;
    this.taker_fee_divisor = proto["taker_fee_divisor"] as U64;
    this.integrator_fee_store_tiers = proto[
      "integrator_fee_store_tiers"
    ] as IntegratorFeeStoreTierParameters[];
  }

  static IncentiveParametersParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): IncentiveParameters {
    const proto = $.parseStructProto(data, typeTag, repo, IncentiveParameters);
    return new IncentiveParameters(proto, typeTag);
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
      IncentiveParameters,
      typeParams
    );
    return result as unknown as IncentiveParameters;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      IncentiveParameters,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as IncentiveParameters;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "IncentiveParameters", []);
  }
  async loadFullState(app: $.AppType) {
    await this.utility_coin_type_info.loadFullState(app);
    this.__app = app;
  }
}

export class IntegratorFeeStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "IntegratorFeeStore";
  static typeParameters: TypeParamDeclType[] = [
    { name: "QuoteCoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "tier", typeTag: AtomicTypeTag.U8 },
    {
      name: "coins",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new $.TypeParamIdx(0),
      ]),
    },
  ];

  tier: U8;
  coins: Stdlib.Coin.Coin;

  constructor(proto: any, public typeTag: TypeTag) {
    this.tier = proto["tier"] as U8;
    this.coins = proto["coins"] as Stdlib.Coin.Coin;
  }

  static IntegratorFeeStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): IntegratorFeeStore {
    const proto = $.parseStructProto(data, typeTag, repo, IntegratorFeeStore);
    return new IntegratorFeeStore(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "IntegratorFeeStore", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.coins.loadFullState(app);
    this.__app = app;
  }
}

export class IntegratorFeeStoreTierParameters {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "IntegratorFeeStoreTierParameters";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "fee_share_divisor", typeTag: AtomicTypeTag.U64 },
    { name: "tier_activation_fee", typeTag: AtomicTypeTag.U64 },
    { name: "withdrawal_fee", typeTag: AtomicTypeTag.U64 },
  ];

  fee_share_divisor: U64;
  tier_activation_fee: U64;
  withdrawal_fee: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.fee_share_divisor = proto["fee_share_divisor"] as U64;
    this.tier_activation_fee = proto["tier_activation_fee"] as U64;
    this.withdrawal_fee = proto["withdrawal_fee"] as U64;
  }

  static IntegratorFeeStoreTierParametersParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): IntegratorFeeStoreTierParameters {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      IntegratorFeeStoreTierParameters
    );
    return new IntegratorFeeStoreTierParameters(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "IntegratorFeeStoreTierParameters",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class IntegratorFeeStores {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "IntegratorFeeStores";
  static typeParameters: TypeParamDeclType[] = [
    { name: "QuoteCoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "map",
      typeTag: new StructTag(
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        ),
        "tablist",
        "Tablist",
        [
          AtomicTypeTag.U64,
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "incentives",
            "IntegratorFeeStore",
            [new $.TypeParamIdx(0)]
          ),
        ]
      ),
    },
  ];

  map: Tablist.Tablist;

  constructor(proto: any, public typeTag: TypeTag) {
    this.map = proto["map"] as Tablist.Tablist;
  }

  static IntegratorFeeStoresParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): IntegratorFeeStores {
    const proto = $.parseStructProto(data, typeTag, repo, IntegratorFeeStores);
    return new IntegratorFeeStores(proto, typeTag);
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
      IntegratorFeeStores,
      typeParams
    );
    return result as unknown as IntegratorFeeStores;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      IntegratorFeeStores,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as IntegratorFeeStores;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "IntegratorFeeStores", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.map.loadFullState(app);
    this.__app = app;
  }
}

export class UtilityCoinStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UtilityCoinStore";
  static typeParameters: TypeParamDeclType[] = [
    { name: "CoinType", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "coins",
      typeTag: new StructTag(new HexString("0x1"), "coin", "Coin", [
        new $.TypeParamIdx(0),
      ]),
    },
  ];

  coins: Stdlib.Coin.Coin;

  constructor(proto: any, public typeTag: TypeTag) {
    this.coins = proto["coins"] as Stdlib.Coin.Coin;
  }

  static UtilityCoinStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UtilityCoinStore {
    const proto = $.parseStructProto(data, typeTag, repo, UtilityCoinStore);
    return new UtilityCoinStore(proto, typeTag);
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
      UtilityCoinStore,
      typeParams
    );
    return result as unknown as UtilityCoinStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      UtilityCoinStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as UtilityCoinStore;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "UtilityCoinStore", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.coins.loadFullState(app);
    this.__app = app;
  }
}
export function assess_taker_fees_(
  market_id: U64,
  integrator_address: HexString,
  taker_fee_divisor: U64,
  quote_fill: U64,
  quote_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): [Stdlib.Coin.Coin, U64] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    contains_market_id_entry,
    econia_fee_share,
    econia_fee_store_coins_ref_mut,
    econia_fee_store_map_ref_mut,
    econia_fees,
    fee_account_address,
    fee_share_divisor,
    integrator_fee_share,
    integrator_fee_store_ref_mut,
    integrator_fee_stores_map_ref_mut,
    integrator_fees,
    total_fee;
  integrator_fee_share = u64("0");
  total_fee = $.copy(quote_fill).div($.copy(taker_fee_divisor));
  if (
    $c.exists(
      new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
      $.copy(integrator_address)
    )
  ) {
    integrator_fee_stores_map_ref_mut =
      $c.borrow_global_mut<IntegratorFeeStores>(
        new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
        $.copy(integrator_address)
      ).map;
    [temp$1, temp$2] = [integrator_fee_stores_map_ref_mut, $.copy(market_id)];
    contains_market_id_entry = Tablist.contains_(temp$1, temp$2, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(IntegratorFeeStore, [$p[0]]),
    ]);
    if (contains_market_id_entry) {
      integrator_fee_store_ref_mut = Tablist.borrow_mut_(
        integrator_fee_stores_map_ref_mut,
        $.copy(market_id),
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(IntegratorFeeStore, [$p[0]])]
      );
      fee_share_divisor = get_fee_share_divisor_(
        $.copy(integrator_fee_store_ref_mut.tier),
        $c
      );
      integrator_fee_share = $.copy(quote_fill).div($.copy(fee_share_divisor));
      range_check_coin_merge_(
        $.copy(integrator_fee_share),
        integrator_fee_store_ref_mut.coins,
        $.copy(E_INTEGRATOR_FEE_STORE_OVERFLOW),
        $c,
        [$p[0]]
      );
      integrator_fees = Stdlib.Coin.extract_(
        quote_coins,
        $.copy(integrator_fee_share),
        $c,
        [$p[0]]
      );
      Stdlib.Coin.merge_(
        integrator_fee_store_ref_mut.coins,
        integrator_fees,
        $c,
        [$p[0]]
      );
    } else {
    }
  } else {
  }
  econia_fee_share = $.copy(total_fee).sub($.copy(integrator_fee_share));
  econia_fees = Stdlib.Coin.extract_(
    quote_coins,
    $.copy(econia_fee_share),
    $c,
    [$p[0]]
  );
  fee_account_address = Resource_account.get_address_($c);
  econia_fee_store_map_ref_mut = $c.borrow_global_mut<EconiaFeeStore>(
    new SimpleStructTag(EconiaFeeStore, [$p[0]]),
    $.copy(fee_account_address)
  ).map;
  econia_fee_store_coins_ref_mut = Tablist.borrow_mut_(
    econia_fee_store_map_ref_mut,
    $.copy(market_id),
    $c,
    [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]
  );
  [temp$3, temp$4, temp$5] = [
    $.copy(econia_fee_share),
    econia_fee_store_coins_ref_mut,
    $.copy(E_ECONIA_FEE_STORE_OVERFLOW),
  ];
  range_check_coin_merge_(temp$3, temp$4, temp$5, $c, [$p[0]]);
  Stdlib.Coin.merge_(econia_fee_store_coins_ref_mut, econia_fees, $c, [$p[0]]);
  return [quote_coins, $.copy(total_fee)];
}

export function calculate_max_quote_match_(
  direction: boolean,
  taker_fee_divisor: U64,
  max_quote_delta_user: U64,
  $c: AptosDataCache
): U64 {
  let temp$1, temp$2, denominator, max_quote_match, numerator;
  numerator = u128($.copy(taker_fee_divisor)).mul(
    u128($.copy(max_quote_delta_user))
  );
  if (direction == $.copy(BUY)) {
    temp$1 = u128($.copy(taker_fee_divisor).add(u64("1")));
  } else {
    temp$1 = u128($.copy(taker_fee_divisor).sub(u64("1")));
  }
  denominator = temp$1;
  max_quote_match = $.copy(numerator).div($.copy(denominator));
  if ($.copy(max_quote_match).gt(u128($.copy(HI_64)))) {
    temp$2 = $.copy(HI_64);
  } else {
    temp$2 = u64($.copy(max_quote_match));
  }
  return temp$2;
}

export function deposit_custodian_registration_utility_coins_(
  coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  deposit_utility_coins_verified_(
    coins,
    get_custodian_registration_fee_($c),
    $c,
    [$p[0]]
  );
  return;
}

export function deposit_market_registration_utility_coins_(
  coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  deposit_utility_coins_verified_(coins, get_market_registration_fee_($c), $c, [
    $p[0],
  ]);
  return;
}

export function deposit_underwriter_registration_utility_coins_(
  coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  deposit_utility_coins_verified_(
    coins,
    get_underwriter_registration_fee_($c),
    $c,
    [$p[0]]
  );
  return;
}

export function deposit_utility_coins_(
  coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  let temp$1, temp$2, temp$3, fee_account_address, utility_coins_ref_mut;
  fee_account_address = Resource_account.get_address_($c);
  utility_coins_ref_mut = $c.borrow_global_mut<UtilityCoinStore>(
    new SimpleStructTag(UtilityCoinStore, [$p[0]]),
    $.copy(fee_account_address)
  ).coins;
  [temp$1, temp$2, temp$3] = [
    Stdlib.Coin.value_(coins, $c, [$p[0]]),
    utility_coins_ref_mut,
    $.copy(E_UTILITY_COIN_STORE_OVERFLOW),
  ];
  range_check_coin_merge_(temp$1, temp$2, temp$3, $c, [$p[0]]);
  Stdlib.Coin.merge_(utility_coins_ref_mut, coins, $c, [$p[0]]);
  return;
}

export function deposit_utility_coins_verified_(
  coins: Stdlib.Coin.Coin,
  min_amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  verify_utility_coin_type_($c, [$p[0]]);
  if (!Stdlib.Coin.value_(coins, $c, [$p[0]]).ge($.copy(min_amount))) {
    throw $.abortCode($.copy(E_NOT_ENOUGH_UTILITY_COINS));
  }
  deposit_utility_coins_(coins, $c, [$p[0]]);
  return;
}

export function get_cost_to_upgrade_integrator_fee_store_(
  integrator: HexString,
  market_id: U64,
  new_tier: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): U64 {
  let current_tier,
    integrator_address,
    integrator_fee_store_ref_mut,
    integrator_fee_stores_map_ref_mut;
  integrator_address = Stdlib.Signer.address_of_(integrator, $c);
  integrator_fee_stores_map_ref_mut = $c.borrow_global_mut<IntegratorFeeStores>(
    new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
    $.copy(integrator_address)
  ).map;
  integrator_fee_store_ref_mut = Tablist.borrow_mut_(
    integrator_fee_stores_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(IntegratorFeeStore, [$p[0]])]
  );
  current_tier = $.copy(integrator_fee_store_ref_mut.tier);
  if (!$.copy(new_tier).gt($.copy(current_tier))) {
    throw $.abortCode($.copy(E_NOT_AN_UPGRADE));
  }
  return get_tier_activation_fee_($.copy(new_tier), $c).sub(
    get_tier_activation_fee_($.copy(current_tier), $c)
  );
}

export function get_custodian_registration_fee_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<IncentiveParameters>(
      new SimpleStructTag(IncentiveParameters),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    ).custodian_registration_fee
  );
}

export function get_fee_share_divisor_(tier: U8, $c: AptosDataCache): U64 {
  let integrator_fee_store_tier_ref, integrator_fee_store_tiers_ref;
  integrator_fee_store_tiers_ref = $c.borrow_global<IncentiveParameters>(
    new SimpleStructTag(IncentiveParameters),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).integrator_fee_store_tiers;
  if (
    !u64($.copy(tier)).lt(
      Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
        new SimpleStructTag(IntegratorFeeStoreTierParameters),
      ])
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_TIER));
  }
  integrator_fee_store_tier_ref = Stdlib.Vector.borrow_(
    integrator_fee_store_tiers_ref,
    u64($.copy(tier)),
    $c,
    [new SimpleStructTag(IntegratorFeeStoreTierParameters)]
  );
  return $.copy(integrator_fee_store_tier_ref.fee_share_divisor);
}

export function get_integrator_withdrawal_fee_(
  integrator: HexString,
  market_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): U64 {
  let integrator_fee_store_ref, integrator_fee_stores_map_ref;
  integrator_fee_stores_map_ref = $c.borrow_global<IntegratorFeeStores>(
    new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
    Stdlib.Signer.address_of_(integrator, $c)
  ).map;
  integrator_fee_store_ref = Tablist.borrow_(
    integrator_fee_stores_map_ref,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(IntegratorFeeStore, [$p[0]])]
  );
  return get_tier_withdrawal_fee_($.copy(integrator_fee_store_ref.tier), $c);
}

export function get_market_registration_fee_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<IncentiveParameters>(
      new SimpleStructTag(IncentiveParameters),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    ).market_registration_fee
  );
}

export function get_n_fee_store_tiers_($c: AptosDataCache): U64 {
  let integrator_fee_store_tiers_ref;
  integrator_fee_store_tiers_ref = $c.borrow_global<IncentiveParameters>(
    new SimpleStructTag(IncentiveParameters),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).integrator_fee_store_tiers;
  return Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
    new SimpleStructTag(IntegratorFeeStoreTierParameters),
  ]);
}

export function get_taker_fee_divisor_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<IncentiveParameters>(
      new SimpleStructTag(IncentiveParameters),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    ).taker_fee_divisor
  );
}

export function get_tier_activation_fee_(tier: U8, $c: AptosDataCache): U64 {
  let integrator_fee_store_tier_ref, integrator_fee_store_tiers_ref;
  integrator_fee_store_tiers_ref = $c.borrow_global<IncentiveParameters>(
    new SimpleStructTag(IncentiveParameters),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).integrator_fee_store_tiers;
  if (
    !u64($.copy(tier)).lt(
      Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
        new SimpleStructTag(IntegratorFeeStoreTierParameters),
      ])
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_TIER));
  }
  integrator_fee_store_tier_ref = Stdlib.Vector.borrow_(
    integrator_fee_store_tiers_ref,
    u64($.copy(tier)),
    $c,
    [new SimpleStructTag(IntegratorFeeStoreTierParameters)]
  );
  return $.copy(integrator_fee_store_tier_ref.tier_activation_fee);
}

export function get_tier_withdrawal_fee_(tier: U8, $c: AptosDataCache): U64 {
  let integrator_fee_store_tier_ref, integrator_fee_store_tiers_ref;
  integrator_fee_store_tiers_ref = $c.borrow_global<IncentiveParameters>(
    new SimpleStructTag(IncentiveParameters),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).integrator_fee_store_tiers;
  if (
    !u64($.copy(tier)).lt(
      Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
        new SimpleStructTag(IntegratorFeeStoreTierParameters),
      ])
    )
  ) {
    throw $.abortCode($.copy(E_INVALID_TIER));
  }
  integrator_fee_store_tier_ref = Stdlib.Vector.borrow_(
    integrator_fee_store_tiers_ref,
    u64($.copy(tier)),
    $c,
    [new SimpleStructTag(IntegratorFeeStoreTierParameters)]
  );
  return $.copy(integrator_fee_store_tier_ref.withdrawal_fee);
}

export function get_underwriter_registration_fee_($c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<IncentiveParameters>(
      new SimpleStructTag(IncentiveParameters),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    ).underwriter_registration_fee
  );
}

export function init_module_(econia: HexString, $c: AptosDataCache): void {
  let integrator_fee_store_tiers;
  integrator_fee_store_tiers = [
    [
      $.copy(FEE_SHARE_DIVISOR_0),
      $.copy(TIER_ACTIVATION_FEE_0),
      $.copy(WITHDRAWAL_FEE_0),
    ],
    [
      $.copy(FEE_SHARE_DIVISOR_1),
      $.copy(TIER_ACTIVATION_FEE_1),
      $.copy(WITHDRAWAL_FEE_1),
    ],
    [
      $.copy(FEE_SHARE_DIVISOR_2),
      $.copy(TIER_ACTIVATION_FEE_2),
      $.copy(WITHDRAWAL_FEE_2),
    ],
    [
      $.copy(FEE_SHARE_DIVISOR_3),
      $.copy(TIER_ACTIVATION_FEE_3),
      $.copy(WITHDRAWAL_FEE_3),
    ],
    [
      $.copy(FEE_SHARE_DIVISOR_4),
      $.copy(TIER_ACTIVATION_FEE_4),
      $.copy(WITHDRAWAL_FEE_4),
    ],
    [
      $.copy(FEE_SHARE_DIVISOR_5),
      $.copy(TIER_ACTIVATION_FEE_5),
      $.copy(WITHDRAWAL_FEE_5),
    ],
    [
      $.copy(FEE_SHARE_DIVISOR_6),
      $.copy(TIER_ACTIVATION_FEE_6),
      $.copy(WITHDRAWAL_FEE_6),
    ],
  ];
  set_incentive_parameters_(
    econia,
    $.copy(MARKET_REGISTRATION_FEE),
    $.copy(UNDERWRITER_REGISTRATION_FEE),
    $.copy(CUSTODIAN_REGISTRATION_FEE),
    $.copy(TAKER_FEE_DIVISOR),
    integrator_fee_store_tiers,
    false,
    $c,
    [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
  );
  return;
}

export function init_utility_coin_store_(
  fee_account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  if (!Stdlib.Coin.is_coin_initialized_($c, [$p[0]])) {
    throw $.abortCode($.copy(E_NOT_COIN));
  }
  if (
    !$c.exists(
      new SimpleStructTag(UtilityCoinStore, [$p[0]]),
      Stdlib.Signer.address_of_(fee_account, $c)
    )
  ) {
    $c.move_to(
      new SimpleStructTag(UtilityCoinStore, [$p[0]]),
      fee_account,
      new UtilityCoinStore(
        { coins: Stdlib.Coin.zero_($c, [$p[0]]) },
        new SimpleStructTag(UtilityCoinStore, [$p[0]])
      )
    );
  } else {
  }
  return;
}

export function is_utility_coin_type_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): boolean {
  return $.deep_eq(
    Stdlib.Type_info.type_of_($c, [$p[0]]),
    $.copy(
      $c.borrow_global<IncentiveParameters>(
        new SimpleStructTag(IncentiveParameters),
        new HexString(
          "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
        )
      ).utility_coin_type_info
    )
  );
}

export function range_check_coin_merge_(
  amount: U64,
  target_coins: Stdlib.Coin.Coin,
  error_code: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let target_value;
  target_value = Stdlib.Coin.value_(target_coins, $c, [$p[0]]);
  if (
    !u128($.copy(amount))
      .add(u128($.copy(target_value)))
      .le(u128($.copy(HI_64)))
  ) {
    throw $.abortCode($.copy(error_code));
  }
  return;
}

export function register_econia_fee_store_entry_(
  market_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): void {
  let econia_fee_store_map_ref_mut,
    fee_account,
    fee_account_address,
    zero_coins;
  fee_account = Resource_account.get_signer_($c);
  fee_account_address = Stdlib.Signer.address_of_(fee_account, $c);
  if (
    !$c.exists(
      new SimpleStructTag(EconiaFeeStore, [$p[0]]),
      $.copy(fee_account_address)
    )
  ) {
    $c.move_to(
      new SimpleStructTag(EconiaFeeStore, [$p[0]]),
      fee_account,
      new EconiaFeeStore(
        {
          map: Tablist.new___($c, [
            AtomicTypeTag.U64,
            new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
          ]),
        },
        new SimpleStructTag(EconiaFeeStore, [$p[0]])
      )
    );
  } else {
  }
  econia_fee_store_map_ref_mut = $c.borrow_global_mut<EconiaFeeStore>(
    new SimpleStructTag(EconiaFeeStore, [$p[0]]),
    $.copy(fee_account_address)
  ).map;
  zero_coins = Stdlib.Coin.zero_($c, [$p[0]]);
  Tablist.add_(
    econia_fee_store_map_ref_mut,
    $.copy(market_id),
    zero_coins,
    $c,
    [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]
  );
  return;
}

export function register_integrator_fee_store_(
  integrator: HexString,
  market_id: U64,
  tier: U8,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  let integrator_address,
    integrator_fee_store,
    integrator_fee_stores_map_ref_mut,
    tier_activation_fee;
  tier_activation_fee = get_tier_activation_fee_($.copy(tier), $c);
  deposit_utility_coins_verified_(
    utility_coins,
    $.copy(tier_activation_fee),
    $c,
    [$p[1]]
  );
  integrator_address = Stdlib.Signer.address_of_(integrator, $c);
  if (
    !$c.exists(
      new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
      $.copy(integrator_address)
    )
  ) {
    $c.move_to(
      new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
      integrator,
      new IntegratorFeeStores(
        {
          map: Tablist.new___($c, [
            AtomicTypeTag.U64,
            new SimpleStructTag(IntegratorFeeStore, [$p[0]]),
          ]),
        },
        new SimpleStructTag(IntegratorFeeStores, [$p[0]])
      )
    );
  } else {
  }
  integrator_fee_store = new IntegratorFeeStore(
    { tier: $.copy(tier), coins: Stdlib.Coin.zero_($c, [$p[0]]) },
    new SimpleStructTag(IntegratorFeeStore, [$p[0]])
  );
  integrator_fee_stores_map_ref_mut = $c.borrow_global_mut<IntegratorFeeStores>(
    new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
    $.copy(integrator_address)
  ).map;
  Tablist.add_(
    integrator_fee_stores_map_ref_mut,
    $.copy(market_id),
    integrator_fee_store,
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(IntegratorFeeStore, [$p[0]])]
  );
  return;
}

export function set_incentive_parameters_(
  econia: HexString,
  market_registration_fee: U64,
  underwriter_registration_fee: U64,
  custodian_registration_fee: U64,
  taker_fee_divisor: U64,
  integrator_fee_store_tiers_ref: U64[][],
  updating: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  let fee_account,
    incentive_parameters_ref_mut,
    incentive_parameters_ref_mut__1,
    integrator_fee_store_tiers,
    n_new_tiers,
    n_old_tiers,
    utility_coin_type_info;
  set_incentive_parameters_range_check_inputs_(
    econia,
    $.copy(market_registration_fee),
    $.copy(underwriter_registration_fee),
    $.copy(custodian_registration_fee),
    $.copy(taker_fee_divisor),
    integrator_fee_store_tiers_ref,
    $c
  );
  fee_account = Resource_account.get_signer_($c);
  init_utility_coin_store_(fee_account, $c, [$p[0]]);
  if (updating) {
    n_old_tiers = get_n_fee_store_tiers_($c);
    n_new_tiers = Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
      new VectorTag(AtomicTypeTag.U64),
    ]);
    if (!$.copy(n_new_tiers).ge($.copy(n_old_tiers))) {
      throw $.abortCode($.copy(E_FEWER_TIERS));
    }
    incentive_parameters_ref_mut = $c.borrow_global_mut<IncentiveParameters>(
      new SimpleStructTag(IncentiveParameters),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    );
    incentive_parameters_ref_mut.integrator_fee_store_tiers =
      Stdlib.Vector.empty_($c, [
        new SimpleStructTag(IntegratorFeeStoreTierParameters),
      ]);
    $c.move_from<IncentiveParameters>(
      new SimpleStructTag(IncentiveParameters),
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      )
    );
  } else {
  }
  utility_coin_type_info = Stdlib.Type_info.type_of_($c, [$p[0]]);
  integrator_fee_store_tiers = Stdlib.Vector.empty_($c, [
    new SimpleStructTag(IntegratorFeeStoreTierParameters),
  ]);
  $c.move_to(
    new SimpleStructTag(IncentiveParameters),
    econia,
    new IncentiveParameters(
      {
        utility_coin_type_info: $.copy(utility_coin_type_info),
        market_registration_fee: $.copy(market_registration_fee),
        underwriter_registration_fee: $.copy(underwriter_registration_fee),
        custodian_registration_fee: $.copy(custodian_registration_fee),
        taker_fee_divisor: $.copy(taker_fee_divisor),
        integrator_fee_store_tiers: integrator_fee_store_tiers,
      },
      new SimpleStructTag(IncentiveParameters)
    )
  );
  incentive_parameters_ref_mut__1 = $c.borrow_global_mut<IncentiveParameters>(
    new SimpleStructTag(IncentiveParameters),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  );
  set_incentive_parameters_parse_tiers_vector_(
    $.copy(taker_fee_divisor),
    integrator_fee_store_tiers_ref,
    incentive_parameters_ref_mut__1.integrator_fee_store_tiers,
    $c
  );
  return;
}

export function set_incentive_parameters_parse_tiers_vector_(
  taker_fee_divisor: U64,
  integrator_fee_store_tiers_ref: U64[][],
  integrator_fee_store_tiers_target_ref_mut: IntegratorFeeStoreTierParameters[],
  $c: AptosDataCache
): void {
  let activation_fee_last,
    divisor_last,
    fee_share_divisor_ref,
    i,
    n_tiers,
    tier_activation_fee_ref,
    tier_fields_ref,
    withdrawal_fee_last,
    withdrawal_fee_ref;
  [divisor_last, activation_fee_last, withdrawal_fee_last] = [
    $.copy(HI_64),
    u64("0"),
    $.copy(HI_64),
  ];
  n_tiers = Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
    new VectorTag(AtomicTypeTag.U64),
  ]);
  i = u64("0");
  while ($.copy(i).lt($.copy(n_tiers))) {
    {
      tier_fields_ref = Stdlib.Vector.borrow_(
        integrator_fee_store_tiers_ref,
        $.copy(i),
        $c,
        [new VectorTag(AtomicTypeTag.U64)]
      );
      if (
        !Stdlib.Vector.length_(tier_fields_ref, $c, [AtomicTypeTag.U64]).eq(
          $.copy(N_TIER_FIELDS)
        )
      ) {
        throw $.abortCode($.copy(E_TIER_FIELDS_WRONG_LENGTH));
      }
      fee_share_divisor_ref = Stdlib.Vector.borrow_(
        tier_fields_ref,
        $.copy(FEE_SHARE_DIVISOR_INDEX),
        $c,
        [AtomicTypeTag.U64]
      );
      if (!$.copy(fee_share_divisor_ref).lt($.copy(divisor_last))) {
        throw $.abortCode($.copy(E_FEE_SHARE_DIVISOR_TOO_BIG));
      }
      if (!$.copy(fee_share_divisor_ref).ge($.copy(taker_fee_divisor))) {
        throw $.abortCode($.copy(E_FEE_SHARE_DIVISOR_TOO_SMALL));
      }
      tier_activation_fee_ref = Stdlib.Vector.borrow_(
        tier_fields_ref,
        $.copy(TIER_ACTIVATION_FEE_INDEX),
        $c,
        [AtomicTypeTag.U64]
      );
      if ($.copy(i).eq(u64("0"))) {
        if (!$.copy(tier_activation_fee_ref).eq(u64("0"))) {
          throw $.abortCode($.copy(E_FIRST_TIER_ACTIVATION_FEE_NONZERO));
        }
      } else {
        if (!$.copy(tier_activation_fee_ref).gt($.copy(activation_fee_last))) {
          throw $.abortCode($.copy(E_ACTIVATION_FEE_TOO_SMALL));
        }
      }
      withdrawal_fee_ref = Stdlib.Vector.borrow_(
        tier_fields_ref,
        $.copy(WITHDRAWAL_FEE_INDEX),
        $c,
        [AtomicTypeTag.U64]
      );
      if (!$.copy(withdrawal_fee_ref).lt($.copy(withdrawal_fee_last))) {
        throw $.abortCode($.copy(E_WITHDRAWAL_FEE_TOO_BIG));
      }
      if (!$.copy(withdrawal_fee_ref).ge($.copy(MIN_FEE))) {
        throw $.abortCode($.copy(E_WITHDRAWAL_FEE_TOO_SMALL));
      }
      Stdlib.Vector.push_back_(
        integrator_fee_store_tiers_target_ref_mut,
        new IntegratorFeeStoreTierParameters(
          {
            fee_share_divisor: $.copy(fee_share_divisor_ref),
            tier_activation_fee: $.copy(tier_activation_fee_ref),
            withdrawal_fee: $.copy(withdrawal_fee_ref),
          },
          new SimpleStructTag(IntegratorFeeStoreTierParameters)
        ),
        $c,
        [new SimpleStructTag(IntegratorFeeStoreTierParameters)]
      );
      divisor_last = $.copy(fee_share_divisor_ref);
      activation_fee_last = $.copy(tier_activation_fee_ref);
      withdrawal_fee_last = $.copy(withdrawal_fee_ref);
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function set_incentive_parameters_range_check_inputs_(
  econia: HexString,
  market_registration_fee: U64,
  underwriter_registration_fee: U64,
  custodian_registration_fee: U64,
  taker_fee_divisor: U64,
  integrator_fee_store_tiers_ref: U64[][],
  $c: AptosDataCache
): void {
  if (
    !(
      Stdlib.Signer.address_of_(econia, $c).hex() ===
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ).hex()
    )
  ) {
    throw $.abortCode($.copy(E_NOT_ECONIA));
  }
  if (!$.copy(market_registration_fee).ge($.copy(MIN_FEE))) {
    throw $.abortCode($.copy(E_MARKET_REGISTRATION_FEE_LESS_THAN_MIN));
  }
  if (!$.copy(underwriter_registration_fee).ge($.copy(MIN_FEE))) {
    throw $.abortCode($.copy(E_UNDERWRITER_REGISTRATION_FEE_LESS_THAN_MIN));
  }
  if (!$.copy(custodian_registration_fee).ge($.copy(MIN_FEE))) {
    throw $.abortCode($.copy(E_CUSTODIAN_REGISTRATION_FEE_LESS_THAN_MIN));
  }
  if (!$.copy(taker_fee_divisor).ge($.copy(MIN_DIVISOR))) {
    throw $.abortCode($.copy(E_TAKER_DIVISOR_LESS_THAN_MIN));
  }
  if (
    Stdlib.Vector.is_empty_(integrator_fee_store_tiers_ref, $c, [
      new VectorTag(AtomicTypeTag.U64),
    ])
  ) {
    throw $.abortCode($.copy(E_EMPTY_FEE_STORE_TIERS));
  }
  if (
    !Stdlib.Vector.length_(integrator_fee_store_tiers_ref, $c, [
      new VectorTag(AtomicTypeTag.U64),
    ]).le($.copy(MAX_INTEGRATOR_FEE_STORE_TIERS))
  ) {
    throw $.abortCode($.copy(E_TOO_MANY_TIERS));
  }
  return;
}

export function update_incentives_(
  econia: HexString,
  market_registration_fee: U64,
  underwriter_registration_fee: U64,
  custodian_registration_fee: U64,
  taker_fee_divisor: U64,
  integrator_fee_store_tiers: U64[][],
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  set_incentive_parameters_(
    econia,
    $.copy(market_registration_fee),
    $.copy(underwriter_registration_fee),
    $.copy(custodian_registration_fee),
    $.copy(taker_fee_divisor),
    integrator_fee_store_tiers,
    true,
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_update_incentives(
  market_registration_fee: U64,
  underwriter_registration_fee: U64,
  custodian_registration_fee: U64,
  taker_fee_divisor: U64,
  integrator_fee_store_tiers: U64[][],
  $p: TypeTag[] /* <UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "update_incentives",
    typeParamStrings,
    [
      market_registration_fee,
      underwriter_registration_fee,
      custodian_registration_fee,
      taker_fee_divisor,
      integrator_fee_store_tiers,
    ],
    isJSON
  );
}

export function upgrade_integrator_fee_store_(
  integrator: HexString,
  market_id: U64,
  new_tier: U8,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  let cost,
    integrator_address,
    integrator_fee_store_ref_mut,
    integrator_fee_stores_map_ref_mut;
  cost = get_cost_to_upgrade_integrator_fee_store_(
    integrator,
    $.copy(market_id),
    $.copy(new_tier),
    $c,
    [$p[0], $p[1]]
  );
  deposit_utility_coins_verified_(utility_coins, $.copy(cost), $c, [$p[1]]);
  integrator_address = Stdlib.Signer.address_of_(integrator, $c);
  integrator_fee_stores_map_ref_mut = $c.borrow_global_mut<IntegratorFeeStores>(
    new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
    $.copy(integrator_address)
  ).map;
  integrator_fee_store_ref_mut = Tablist.borrow_mut_(
    integrator_fee_stores_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(IntegratorFeeStore, [$p[0]])]
  );
  integrator_fee_store_ref_mut.tier = $.copy(new_tier);
  return;
}

export function upgrade_integrator_fee_store_via_coinstore_(
  integrator: HexString,
  market_id: U64,
  new_tier: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  let cost;
  cost = get_cost_to_upgrade_integrator_fee_store_(
    integrator,
    $.copy(market_id),
    $.copy(new_tier),
    $c,
    [$p[0], $p[1]]
  );
  upgrade_integrator_fee_store_(
    integrator,
    $.copy(market_id),
    $.copy(new_tier),
    Stdlib.Coin.withdraw_(integrator, $.copy(cost), $c, [$p[1]]),
    $c,
    [$p[0], $p[1]]
  );
  return;
}

export function buildPayload_upgrade_integrator_fee_store_via_coinstore(
  market_id: U64,
  new_tier: U8,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "upgrade_integrator_fee_store_via_coinstore",
    typeParamStrings,
    [market_id, new_tier],
    isJSON
  );
}

export function verify_utility_coin_type_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): void {
  if (!is_utility_coin_type_($c, [$p[0]])) {
    throw $.abortCode($.copy(E_INVALID_UTILITY_COIN_TYPE));
  }
  return;
}

export function withdraw_econia_fees_(
  econia: HexString,
  market_id: U64,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): Stdlib.Coin.Coin {
  return withdraw_econia_fees_internal_(
    econia,
    $.copy(market_id),
    false,
    $.copy(amount),
    $c,
    [$p[0]]
  );
}

export function withdraw_econia_fees_all_(
  econia: HexString,
  market_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): Stdlib.Coin.Coin {
  return withdraw_econia_fees_internal_(
    econia,
    $.copy(market_id),
    true,
    u64("0"),
    $c,
    [$p[0]]
  );
}

export function withdraw_econia_fees_all_to_coin_store_(
  econia: HexString,
  market_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): void {
  withdraw_econia_fees_to_coin_store_internal_(
    econia,
    $.copy(market_id),
    true,
    u64("0"),
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_withdraw_econia_fees_all_to_coin_store(
  market_id: U64,
  $p: TypeTag[] /* <QuoteCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "withdraw_econia_fees_all_to_coin_store",
    typeParamStrings,
    [market_id],
    isJSON
  );
}

export function withdraw_econia_fees_internal_(
  account: HexString,
  market_id: U64,
  all: boolean,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): Stdlib.Coin.Coin {
  let temp$1,
    econia_fee_store_map_ref_mut,
    fee_account_address,
    fee_coins_ref_mut;
  if (
    !(
      Stdlib.Signer.address_of_(account, $c).hex() ===
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ).hex()
    )
  ) {
    throw $.abortCode($.copy(E_NOT_ECONIA));
  }
  fee_account_address = Resource_account.get_address_($c);
  econia_fee_store_map_ref_mut = $c.borrow_global_mut<EconiaFeeStore>(
    new SimpleStructTag(EconiaFeeStore, [$p[0]]),
    $.copy(fee_account_address)
  ).map;
  fee_coins_ref_mut = Tablist.borrow_mut_(
    econia_fee_store_map_ref_mut,
    $.copy(market_id),
    $c,
    [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "coin", "Coin", [$p[0]]),
    ]
  );
  if (all) {
    temp$1 = Stdlib.Coin.extract_all_(fee_coins_ref_mut, $c, [$p[0]]);
  } else {
    temp$1 = Stdlib.Coin.extract_(fee_coins_ref_mut, $.copy(amount), $c, [
      $p[0],
    ]);
  }
  return temp$1;
}

export function withdraw_econia_fees_to_coin_store_(
  econia: HexString,
  market_id: U64,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): void {
  withdraw_econia_fees_to_coin_store_internal_(
    econia,
    $.copy(market_id),
    false,
    $.copy(amount),
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_withdraw_econia_fees_to_coin_store(
  market_id: U64,
  amount: U64,
  $p: TypeTag[] /* <QuoteCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "withdraw_econia_fees_to_coin_store",
    typeParamStrings,
    [market_id, amount],
    isJSON
  );
}

export function withdraw_econia_fees_to_coin_store_internal_(
  econia: HexString,
  market_id: U64,
  all: boolean,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType>*/
): void {
  let coins;
  coins = withdraw_econia_fees_internal_(
    econia,
    $.copy(market_id),
    all,
    $.copy(amount),
    $c,
    [$p[0]]
  );
  if (
    !Stdlib.Coin.is_account_registered_(
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ),
      $c,
      [$p[0]]
    )
  ) {
    Stdlib.Coin.register_(econia, $c, [$p[0]]);
  } else {
  }
  Stdlib.Coin.deposit_(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    coins,
    $c,
    [$p[0]]
  );
  return;
}

export function withdraw_integrator_fees_(
  integrator: HexString,
  market_id: U64,
  utility_coins: Stdlib.Coin.Coin,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): Stdlib.Coin.Coin {
  let integrator_fee_store_ref_mut,
    integrator_fee_stores_map_ref_mut,
    withdrawal_fee;
  integrator_fee_stores_map_ref_mut = $c.borrow_global_mut<IntegratorFeeStores>(
    new SimpleStructTag(IntegratorFeeStores, [$p[0]]),
    Stdlib.Signer.address_of_(integrator, $c)
  ).map;
  integrator_fee_store_ref_mut = Tablist.borrow_mut_(
    integrator_fee_stores_map_ref_mut,
    $.copy(market_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(IntegratorFeeStore, [$p[0]])]
  );
  withdrawal_fee = get_tier_withdrawal_fee_(
    $.copy(integrator_fee_store_ref_mut.tier),
    $c
  );
  deposit_utility_coins_verified_(utility_coins, $.copy(withdrawal_fee), $c, [
    $p[1],
  ]);
  return Stdlib.Coin.extract_all_(integrator_fee_store_ref_mut.coins, $c, [
    $p[0],
  ]);
}

export function withdraw_integrator_fees_via_coinstores_(
  integrator: HexString,
  market_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/
): void {
  let integrator_address, quote_coins, utility_coins, withdrawal_fee;
  withdrawal_fee = get_integrator_withdrawal_fee_(
    integrator,
    $.copy(market_id),
    $c,
    [$p[0]]
  );
  utility_coins = Stdlib.Coin.withdraw_(
    integrator,
    $.copy(withdrawal_fee),
    $c,
    [$p[1]]
  );
  quote_coins = withdraw_integrator_fees_(
    integrator,
    $.copy(market_id),
    utility_coins,
    $c,
    [$p[0], $p[1]]
  );
  integrator_address = Stdlib.Signer.address_of_(integrator, $c);
  if (
    !Stdlib.Coin.is_account_registered_($.copy(integrator_address), $c, [$p[0]])
  ) {
    Stdlib.Coin.register_(integrator, $c, [$p[0]]);
  } else {
  }
  Stdlib.Coin.deposit_(
    Stdlib.Signer.address_of_(integrator, $c),
    quote_coins,
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_withdraw_integrator_fees_via_coinstores(
  market_id: U64,
  $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "withdraw_integrator_fees_via_coinstores",
    typeParamStrings,
    [market_id],
    isJSON
  );
}

export function withdraw_utility_coins_(
  econia: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): Stdlib.Coin.Coin {
  return withdraw_utility_coins_internal_(econia, false, $.copy(amount), $c, [
    $p[0],
  ]);
}

export function withdraw_utility_coins_all_(
  econia: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): Stdlib.Coin.Coin {
  return withdraw_utility_coins_internal_(econia, true, u64("0"), $c, [$p[0]]);
}

export function withdraw_utility_coins_all_to_coin_store_(
  econia: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  withdraw_utility_coins_to_coin_store_internal_(econia, true, u64("0"), $c, [
    $p[0],
  ]);
  return;
}

export function buildPayload_withdraw_utility_coins_all_to_coin_store(
  $p: TypeTag[] /* <UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "withdraw_utility_coins_all_to_coin_store",
    typeParamStrings,
    [],
    isJSON
  );
}

export function withdraw_utility_coins_internal_(
  account: HexString,
  all: boolean,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): Stdlib.Coin.Coin {
  let temp$1, fee_account_address, utility_coins_ref_mut;
  if (
    !(
      Stdlib.Signer.address_of_(account, $c).hex() ===
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ).hex()
    )
  ) {
    throw $.abortCode($.copy(E_NOT_ECONIA));
  }
  fee_account_address = Resource_account.get_address_($c);
  utility_coins_ref_mut = $c.borrow_global_mut<UtilityCoinStore>(
    new SimpleStructTag(UtilityCoinStore, [$p[0]]),
    $.copy(fee_account_address)
  ).coins;
  if (all) {
    temp$1 = Stdlib.Coin.extract_all_(utility_coins_ref_mut, $c, [$p[0]]);
  } else {
    temp$1 = Stdlib.Coin.extract_(utility_coins_ref_mut, $.copy(amount), $c, [
      $p[0],
    ]);
  }
  return temp$1;
}

export function withdraw_utility_coins_to_coin_store_(
  econia: HexString,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  withdraw_utility_coins_to_coin_store_internal_(
    econia,
    false,
    $.copy(amount),
    $c,
    [$p[0]]
  );
  return;
}

export function buildPayload_withdraw_utility_coins_to_coin_store(
  amount: U64,
  $p: TypeTag[] /* <UtilityCoinType>*/,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = $p.map((t) => $.getTypeTagFullname(t));
  return $.buildPayload(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    "incentives",
    "withdraw_utility_coins_to_coin_store",
    typeParamStrings,
    [amount],
    isJSON
  );
}

export function withdraw_utility_coins_to_coin_store_internal_(
  econia: HexString,
  all: boolean,
  amount: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <UtilityCoinType>*/
): void {
  let coins;
  coins = withdraw_utility_coins_internal_(econia, all, $.copy(amount), $c, [
    $p[0],
  ]);
  if (
    !Stdlib.Coin.is_account_registered_(
      new HexString(
        "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
      ),
      $c,
      [$p[0]]
    )
  ) {
    Stdlib.Coin.register_(econia, $c, [$p[0]]);
  } else {
  }
  Stdlib.Coin.deposit_(
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    ),
    coins,
    $c,
    [$p[0]]
  );
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::incentives::EconiaFeeStore",
    EconiaFeeStore.EconiaFeeStoreParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::incentives::IncentiveParameters",
    IncentiveParameters.IncentiveParametersParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::incentives::IntegratorFeeStore",
    IntegratorFeeStore.IntegratorFeeStoreParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::incentives::IntegratorFeeStoreTierParameters",
    IntegratorFeeStoreTierParameters.IntegratorFeeStoreTierParametersParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::incentives::IntegratorFeeStores",
    IntegratorFeeStores.IntegratorFeeStoresParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::incentives::UtilityCoinStore",
    UtilityCoinStore.UtilityCoinStoreParser
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
  get EconiaFeeStore() {
    return EconiaFeeStore;
  }
  async loadEconiaFeeStore(
    owner: HexString,
    $p: TypeTag[] /* <QuoteCoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await EconiaFeeStore.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get IncentiveParameters() {
    return IncentiveParameters;
  }
  async loadIncentiveParameters(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await IncentiveParameters.load(
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
  get IntegratorFeeStore() {
    return IntegratorFeeStore;
  }
  get IntegratorFeeStoreTierParameters() {
    return IntegratorFeeStoreTierParameters;
  }
  get IntegratorFeeStores() {
    return IntegratorFeeStores;
  }
  async loadIntegratorFeeStores(
    owner: HexString,
    $p: TypeTag[] /* <QuoteCoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await IntegratorFeeStores.load(
      this.repo,
      this.client,
      owner,
      $p
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get UtilityCoinStore() {
    return UtilityCoinStore;
  }
  async loadUtilityCoinStore(
    owner: HexString,
    $p: TypeTag[] /* <CoinType> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await UtilityCoinStore.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  payload_update_incentives(
    market_registration_fee: U64,
    underwriter_registration_fee: U64,
    custodian_registration_fee: U64,
    taker_fee_divisor: U64,
    integrator_fee_store_tiers: U64[][],
    $p: TypeTag[] /* <UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_update_incentives(
      market_registration_fee,
      underwriter_registration_fee,
      custodian_registration_fee,
      taker_fee_divisor,
      integrator_fee_store_tiers,
      $p,
      isJSON
    );
  }
  async update_incentives(
    _account: AptosAccount,
    market_registration_fee: U64,
    underwriter_registration_fee: U64,
    custodian_registration_fee: U64,
    taker_fee_divisor: U64,
    integrator_fee_store_tiers: U64[][],
    $p: TypeTag[] /* <UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_update_incentives(
      market_registration_fee,
      underwriter_registration_fee,
      custodian_registration_fee,
      taker_fee_divisor,
      integrator_fee_store_tiers,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_upgrade_integrator_fee_store_via_coinstore(
    market_id: U64,
    new_tier: U8,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_upgrade_integrator_fee_store_via_coinstore(
      market_id,
      new_tier,
      $p,
      isJSON
    );
  }
  async upgrade_integrator_fee_store_via_coinstore(
    _account: AptosAccount,
    market_id: U64,
    new_tier: U8,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_upgrade_integrator_fee_store_via_coinstore(
      market_id,
      new_tier,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw_econia_fees_all_to_coin_store(
    market_id: U64,
    $p: TypeTag[] /* <QuoteCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw_econia_fees_all_to_coin_store(
      market_id,
      $p,
      isJSON
    );
  }
  async withdraw_econia_fees_all_to_coin_store(
    _account: AptosAccount,
    market_id: U64,
    $p: TypeTag[] /* <QuoteCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw_econia_fees_all_to_coin_store(
      market_id,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw_econia_fees_to_coin_store(
    market_id: U64,
    amount: U64,
    $p: TypeTag[] /* <QuoteCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw_econia_fees_to_coin_store(
      market_id,
      amount,
      $p,
      isJSON
    );
  }
  async withdraw_econia_fees_to_coin_store(
    _account: AptosAccount,
    market_id: U64,
    amount: U64,
    $p: TypeTag[] /* <QuoteCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw_econia_fees_to_coin_store(
      market_id,
      amount,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw_integrator_fees_via_coinstores(
    market_id: U64,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw_integrator_fees_via_coinstores(
      market_id,
      $p,
      isJSON
    );
  }
  async withdraw_integrator_fees_via_coinstores(
    _account: AptosAccount,
    market_id: U64,
    $p: TypeTag[] /* <QuoteCoinType, UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw_integrator_fees_via_coinstores(
      market_id,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw_utility_coins_all_to_coin_store(
    $p: TypeTag[] /* <UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw_utility_coins_all_to_coin_store($p, isJSON);
  }
  async withdraw_utility_coins_all_to_coin_store(
    _account: AptosAccount,
    $p: TypeTag[] /* <UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw_utility_coins_all_to_coin_store(
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_withdraw_utility_coins_to_coin_store(
    amount: U64,
    $p: TypeTag[] /* <UtilityCoinType>*/,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_withdraw_utility_coins_to_coin_store(
      amount,
      $p,
      isJSON
    );
  }
  async withdraw_utility_coins_to_coin_store(
    _account: AptosAccount,
    amount: U64,
    $p: TypeTag[] /* <UtilityCoinType>*/,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_withdraw_utility_coins_to_coin_store(
      amount,
      $p,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  app_get_cost_to_upgrade_integrator_fee_store(
    market_id: U64,
    new_tier: U8,
    $p: TypeTag[]
  ) {
    return get_cost_to_upgrade_integrator_fee_store_(
      market_id,
      new_tier,
      this.cache,
      $p
    );
  }
  app_get_custodian_registration_fee() {
    return get_custodian_registration_fee_(this.cache);
  }
  app_get_fee_share_divisor(tier: U8) {
    return get_fee_share_divisor_(tier, this.cache);
  }
  app_get_integrator_withdrawal_fee(market_id: U64, $p: TypeTag[]) {
    return get_integrator_withdrawal_fee_(market_id, this.cache, $p);
  }
  app_get_market_registration_fee() {
    return get_market_registration_fee_(this.cache);
  }
  app_get_n_fee_store_tiers() {
    return get_n_fee_store_tiers_(this.cache);
  }
  app_get_taker_fee_divisor() {
    return get_taker_fee_divisor_(this.cache);
  }
  app_get_tier_activation_fee(tier: U8) {
    return get_tier_activation_fee_(tier, this.cache);
  }
  app_get_tier_withdrawal_fee(tier: U8) {
    return get_tier_withdrawal_fee_(tier, this.cache);
  }
  app_get_underwriter_registration_fee() {
    return get_underwriter_registration_fee_(this.cache);
  }
  app_is_utility_coin_type($p: TypeTag[]) {
    return is_utility_coin_type_(this.cache, $p);
  }
  app_verify_utility_coin_type($p: TypeTag[]) {
    return verify_utility_coin_type_(this.cache, $p);
  }
}
