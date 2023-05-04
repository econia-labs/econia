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
import * as State_storage from "./state_storage";
import * as System_addresses from "./system_addresses";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "storage_gas";

export const BASIS_POINT_DENOMINATION: U64 = u64("10000");
export const EINVALID_GAS_RANGE: U64 = u64("2");
export const EINVALID_MONOTONICALLY_NON_DECREASING_CURVE: U64 = u64("5");
export const EINVALID_POINT_RANGE: U64 = u64("6");
export const ESTORAGE_GAS: U64 = u64("1");
export const ESTORAGE_GAS_CONFIG: U64 = u64("0");
export const ETARGET_USAGE_TOO_BIG: U64 = u64("4");
export const EZERO_TARGET_USAGE: U64 = u64("3");
export const MAX_U64: U64 = u64("18446744073709551615");

export class GasCurve {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GasCurve";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "min_gas", typeTag: AtomicTypeTag.U64 },
    { name: "max_gas", typeTag: AtomicTypeTag.U64 },
    {
      name: "points",
      typeTag: new VectorTag(
        new StructTag(new HexString("0x1"), "storage_gas", "Point", [])
      ),
    },
  ];

  min_gas: U64;
  max_gas: U64;
  points: Point[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.min_gas = proto["min_gas"] as U64;
    this.max_gas = proto["max_gas"] as U64;
    this.points = proto["points"] as Point[];
  }

  static GasCurveParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GasCurve {
    const proto = $.parseStructProto(data, typeTag, repo, GasCurve);
    return new GasCurve(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GasCurve", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class Point {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Point";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "x", typeTag: AtomicTypeTag.U64 },
    { name: "y", typeTag: AtomicTypeTag.U64 },
  ];

  x: U64;
  y: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.x = proto["x"] as U64;
    this.y = proto["y"] as U64;
  }

  static PointParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Point {
    const proto = $.parseStructProto(data, typeTag, repo, Point);
    return new Point(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Point", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class StorageGas {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StorageGas";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "per_item_read", typeTag: AtomicTypeTag.U64 },
    { name: "per_item_create", typeTag: AtomicTypeTag.U64 },
    { name: "per_item_write", typeTag: AtomicTypeTag.U64 },
    { name: "per_byte_read", typeTag: AtomicTypeTag.U64 },
    { name: "per_byte_create", typeTag: AtomicTypeTag.U64 },
    { name: "per_byte_write", typeTag: AtomicTypeTag.U64 },
  ];

  per_item_read: U64;
  per_item_create: U64;
  per_item_write: U64;
  per_byte_read: U64;
  per_byte_create: U64;
  per_byte_write: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.per_item_read = proto["per_item_read"] as U64;
    this.per_item_create = proto["per_item_create"] as U64;
    this.per_item_write = proto["per_item_write"] as U64;
    this.per_byte_read = proto["per_byte_read"] as U64;
    this.per_byte_create = proto["per_byte_create"] as U64;
    this.per_byte_write = proto["per_byte_write"] as U64;
  }

  static StorageGasParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StorageGas {
    const proto = $.parseStructProto(data, typeTag, repo, StorageGas);
    return new StorageGas(proto, typeTag);
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
      StorageGas,
      typeParams
    );
    return result as unknown as StorageGas;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      StorageGas,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as StorageGas;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StorageGas", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class StorageGasConfig {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "StorageGasConfig";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "item_config",
      typeTag: new StructTag(
        new HexString("0x1"),
        "storage_gas",
        "UsageGasConfig",
        []
      ),
    },
    {
      name: "byte_config",
      typeTag: new StructTag(
        new HexString("0x1"),
        "storage_gas",
        "UsageGasConfig",
        []
      ),
    },
  ];

  item_config: UsageGasConfig;
  byte_config: UsageGasConfig;

  constructor(proto: any, public typeTag: TypeTag) {
    this.item_config = proto["item_config"] as UsageGasConfig;
    this.byte_config = proto["byte_config"] as UsageGasConfig;
  }

  static StorageGasConfigParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): StorageGasConfig {
    const proto = $.parseStructProto(data, typeTag, repo, StorageGasConfig);
    return new StorageGasConfig(proto, typeTag);
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
      StorageGasConfig,
      typeParams
    );
    return result as unknown as StorageGasConfig;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      StorageGasConfig,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as StorageGasConfig;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "StorageGasConfig", []);
  }
  async loadFullState(app: $.AppType) {
    await this.item_config.loadFullState(app);
    await this.byte_config.loadFullState(app);
    this.__app = app;
  }
}

export class UsageGasConfig {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UsageGasConfig";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "target_usage", typeTag: AtomicTypeTag.U64 },
    {
      name: "read_curve",
      typeTag: new StructTag(
        new HexString("0x1"),
        "storage_gas",
        "GasCurve",
        []
      ),
    },
    {
      name: "create_curve",
      typeTag: new StructTag(
        new HexString("0x1"),
        "storage_gas",
        "GasCurve",
        []
      ),
    },
    {
      name: "write_curve",
      typeTag: new StructTag(
        new HexString("0x1"),
        "storage_gas",
        "GasCurve",
        []
      ),
    },
  ];

  target_usage: U64;
  read_curve: GasCurve;
  create_curve: GasCurve;
  write_curve: GasCurve;

  constructor(proto: any, public typeTag: TypeTag) {
    this.target_usage = proto["target_usage"] as U64;
    this.read_curve = proto["read_curve"] as GasCurve;
    this.create_curve = proto["create_curve"] as GasCurve;
    this.write_curve = proto["write_curve"] as GasCurve;
  }

  static UsageGasConfigParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UsageGasConfig {
    const proto = $.parseStructProto(data, typeTag, repo, UsageGasConfig);
    return new UsageGasConfig(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UsageGasConfig", []);
  }
  async loadFullState(app: $.AppType) {
    await this.read_curve.loadFullState(app);
    await this.create_curve.loadFullState(app);
    await this.write_curve.loadFullState(app);
    this.__app = app;
  }
}
export function base_8192_exponential_curve_(
  min_gas: U64,
  max_gas: U64,
  $c: AptosDataCache
): GasCurve {
  return new_gas_curve_(
    $.copy(min_gas),
    $.copy(max_gas),
    [
      new_point_(u64("1000"), u64("2"), $c),
      new_point_(u64("2000"), u64("6"), $c),
      new_point_(u64("3000"), u64("17"), $c),
      new_point_(u64("4000"), u64("44"), $c),
      new_point_(u64("5000"), u64("109"), $c),
      new_point_(u64("6000"), u64("271"), $c),
      new_point_(u64("7000"), u64("669"), $c),
      new_point_(u64("8000"), u64("1648"), $c),
      new_point_(u64("9000"), u64("4061"), $c),
      new_point_(u64("9500"), u64("6372"), $c),
      new_point_(u64("9900"), u64("9138"), $c),
    ],
    $c
  );
}

export function calculate_create_gas_(
  config: UsageGasConfig,
  usage: U64,
  $c: AptosDataCache
): U64 {
  return calculate_gas_(
    $.copy(config.target_usage),
    $.copy(usage),
    config.create_curve,
    $c
  );
}

export function calculate_gas_(
  max_usage: U64,
  current_usage: U64,
  curve: GasCurve,
  $c: AptosDataCache
): U64 {
  let temp$1,
    temp$10,
    temp$11,
    temp$12,
    temp$13,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    capped_current_usage,
    current_usage_bps,
    i,
    j,
    left,
    mid,
    num_points,
    points,
    right,
    y_interpolated;
  if ($.copy(current_usage).gt($.copy(max_usage))) {
    temp$1 = $.copy(max_usage);
  } else {
    temp$1 = $.copy(current_usage);
  }
  capped_current_usage = temp$1;
  points = curve.points;
  num_points = Vector.length_(points, $c, [new SimpleStructTag(Point)]);
  current_usage_bps = $.copy(capped_current_usage)
    .mul($.copy(BASIS_POINT_DENOMINATION))
    .div($.copy(max_usage));
  if ($.copy(num_points).eq(u64("0"))) {
    temp$3 = new Point(
      { x: u64("0"), y: u64("0") },
      new SimpleStructTag(Point)
    );
    temp$4 = temp$3;
    temp$2 = new Point(
      {
        x: $.copy(BASIS_POINT_DENOMINATION),
        y: $.copy(BASIS_POINT_DENOMINATION),
      },
      new SimpleStructTag(Point)
    );
    [temp$12, temp$13] = [temp$4, temp$2];
  } else {
    if (
      $.copy(current_usage_bps).lt(
        $.copy(
          Vector.borrow_(points, u64("0"), $c, [new SimpleStructTag(Point)]).x
        )
      )
    ) {
      temp$5 = new Point(
        { x: u64("0"), y: u64("0") },
        new SimpleStructTag(Point)
      );
      [temp$10, temp$11] = [
        temp$5,
        Vector.borrow_(points, u64("0"), $c, [new SimpleStructTag(Point)]),
      ];
    } else {
      if (
        $.copy(
          Vector.borrow_(points, $.copy(num_points).sub(u64("1")), $c, [
            new SimpleStructTag(Point),
          ]).x
        ).le($.copy(current_usage_bps))
      ) {
        temp$7 = Vector.borrow_(points, $.copy(num_points).sub(u64("1")), $c, [
          new SimpleStructTag(Point),
        ]);
        temp$6 = new Point(
          {
            x: $.copy(BASIS_POINT_DENOMINATION),
            y: $.copy(BASIS_POINT_DENOMINATION),
          },
          new SimpleStructTag(Point)
        );
        [temp$8, temp$9] = [temp$7, temp$6];
      } else {
        [i, j] = [u64("0"), $.copy(num_points).sub(u64("2"))];
        while (true) {
          {
          }
          if (!$.copy(i).lt($.copy(j))) break;
          {
            mid = $.copy(j).sub($.copy(j).sub($.copy(i)).div(u64("2")));
            if (
              $.copy(current_usage_bps).lt(
                $.copy(
                  Vector.borrow_(points, $.copy(mid), $c, [
                    new SimpleStructTag(Point),
                  ]).x
                )
              )
            ) {
              j = $.copy(mid).sub(u64("1"));
            } else {
              i = $.copy(mid);
            }
          }
        }
        [temp$8, temp$9] = [
          Vector.borrow_(points, $.copy(i), $c, [new SimpleStructTag(Point)]),
          Vector.borrow_(points, $.copy(i).add(u64("1")), $c, [
            new SimpleStructTag(Point),
          ]),
        ];
      }
      [temp$10, temp$11] = [temp$8, temp$9];
    }
    [temp$12, temp$13] = [temp$10, temp$11];
  }
  [left, right] = [temp$12, temp$13];
  y_interpolated = interpolate_(
    $.copy(left.x),
    $.copy(right.x),
    $.copy(left.y),
    $.copy(right.y),
    $.copy(current_usage_bps),
    $c
  );
  return interpolate_(
    u64("0"),
    $.copy(BASIS_POINT_DENOMINATION),
    $.copy(curve.min_gas),
    $.copy(curve.max_gas),
    $.copy(y_interpolated),
    $c
  );
}

export function calculate_read_gas_(
  config: UsageGasConfig,
  usage: U64,
  $c: AptosDataCache
): U64 {
  return calculate_gas_(
    $.copy(config.target_usage),
    $.copy(usage),
    config.read_curve,
    $c
  );
}

export function calculate_write_gas_(
  config: UsageGasConfig,
  usage: U64,
  $c: AptosDataCache
): U64 {
  return calculate_gas_(
    $.copy(config.target_usage),
    $.copy(usage),
    config.write_curve,
    $c
  );
}

export function initialize_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  let byte_config, item_config, k, m;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  if ($c.exists(new SimpleStructTag(StorageGasConfig), new HexString("0x1"))) {
    throw $.abortCode(Error.already_exists_($.copy(ESTORAGE_GAS_CONFIG), $c));
  }
  k = u64("1000");
  m = u64("1000").mul(u64("1000"));
  item_config = new UsageGasConfig(
    {
      target_usage: u64("2").mul($.copy(k)).mul($.copy(m)),
      read_curve: base_8192_exponential_curve_(
        u64("300").mul($.copy(k)),
        u64("300").mul($.copy(k)).mul(u64("100")),
        $c
      ),
      create_curve: base_8192_exponential_curve_(
        u64("5").mul($.copy(m)),
        u64("5").mul($.copy(m)).mul(u64("100")),
        $c
      ),
      write_curve: base_8192_exponential_curve_(
        u64("300").mul($.copy(k)),
        u64("300").mul($.copy(k)).mul(u64("100")),
        $c
      ),
    },
    new SimpleStructTag(UsageGasConfig)
  );
  byte_config = new UsageGasConfig(
    {
      target_usage: u64("1").mul($.copy(m)).mul($.copy(m)),
      read_curve: base_8192_exponential_curve_(
        u64("300"),
        u64("300").mul(u64("100")),
        $c
      ),
      create_curve: base_8192_exponential_curve_(
        u64("5").mul($.copy(k)),
        u64("5").mul($.copy(k)).mul(u64("100")),
        $c
      ),
      write_curve: base_8192_exponential_curve_(
        u64("5").mul($.copy(k)),
        u64("5").mul($.copy(k)).mul(u64("100")),
        $c
      ),
    },
    new SimpleStructTag(UsageGasConfig)
  );
  $c.move_to(
    new SimpleStructTag(StorageGasConfig),
    aptos_framework,
    new StorageGasConfig(
      { item_config: $.copy(item_config), byte_config: $.copy(byte_config) },
      new SimpleStructTag(StorageGasConfig)
    )
  );
  if ($c.exists(new SimpleStructTag(StorageGas), new HexString("0x1"))) {
    throw $.abortCode(Error.already_exists_($.copy(ESTORAGE_GAS), $c));
  }
  $c.move_to(
    new SimpleStructTag(StorageGas),
    aptos_framework,
    new StorageGas(
      {
        per_item_read: u64("300").mul($.copy(k)),
        per_item_create: u64("5").mul($.copy(m)),
        per_item_write: u64("300").mul($.copy(k)),
        per_byte_read: u64("300"),
        per_byte_create: u64("5").mul($.copy(k)),
        per_byte_write: u64("5").mul($.copy(k)),
      },
      new SimpleStructTag(StorageGas)
    )
  );
  return;
}

export function interpolate_(
  x0: U64,
  x1: U64,
  y0: U64,
  y1: U64,
  x: U64,
  $c: AptosDataCache
): U64 {
  return $.copy(y0).add(
    $.copy(x)
      .sub($.copy(x0))
      .mul($.copy(y1).sub($.copy(y0)))
      .div($.copy(x1).sub($.copy(x0)))
  );
}

export function new_gas_curve_(
  min_gas: U64,
  max_gas: U64,
  points: Point[],
  $c: AptosDataCache
): GasCurve {
  if (!$.copy(max_gas).ge($.copy(min_gas))) {
    throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_GAS_RANGE), $c));
  }
  if (
    !$.copy(max_gas).le($.copy(MAX_U64).div($.copy(BASIS_POINT_DENOMINATION)))
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_GAS_RANGE), $c));
  }
  validate_points_(points, $c);
  return new GasCurve(
    {
      min_gas: $.copy(min_gas),
      max_gas: $.copy(max_gas),
      points: $.copy(points),
    },
    new SimpleStructTag(GasCurve)
  );
}

export function new_point_(x: U64, y: U64, $c: AptosDataCache): Point {
  let temp$1;
  if ($.copy(x).le($.copy(BASIS_POINT_DENOMINATION))) {
    temp$1 = $.copy(y).le($.copy(BASIS_POINT_DENOMINATION));
  } else {
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EINVALID_POINT_RANGE), $c)
    );
  }
  return new Point({ x: $.copy(x), y: $.copy(y) }, new SimpleStructTag(Point));
}

export function new_storage_gas_config_(
  item_config: UsageGasConfig,
  byte_config: UsageGasConfig,
  $c: AptosDataCache
): StorageGasConfig {
  return new StorageGasConfig(
    { item_config: $.copy(item_config), byte_config: $.copy(byte_config) },
    new SimpleStructTag(StorageGasConfig)
  );
}

export function new_usage_gas_config_(
  target_usage: U64,
  read_curve: GasCurve,
  create_curve: GasCurve,
  write_curve: GasCurve,
  $c: AptosDataCache
): UsageGasConfig {
  if (!$.copy(target_usage).gt(u64("0"))) {
    throw $.abortCode(Error.invalid_argument_($.copy(EZERO_TARGET_USAGE), $c));
  }
  if (
    !$.copy(target_usage).le(
      $.copy(MAX_U64).div($.copy(BASIS_POINT_DENOMINATION))
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ETARGET_USAGE_TOO_BIG), $c)
    );
  }
  return new UsageGasConfig(
    {
      target_usage: $.copy(target_usage),
      read_curve: $.copy(read_curve),
      create_curve: $.copy(create_curve),
      write_curve: $.copy(write_curve),
    },
    new SimpleStructTag(UsageGasConfig)
  );
}

export function on_reconfig_($c: AptosDataCache): void {
  let bytes, gas, gas_config, items;
  if (!$c.exists(new SimpleStructTag(StorageGasConfig), new HexString("0x1"))) {
    throw $.abortCode(Error.not_found_($.copy(ESTORAGE_GAS_CONFIG), $c));
  }
  if (!$c.exists(new SimpleStructTag(StorageGas), new HexString("0x1"))) {
    throw $.abortCode(Error.not_found_($.copy(ESTORAGE_GAS), $c));
  }
  [items, bytes] = State_storage.current_items_and_bytes_($c);
  gas_config = $c.borrow_global<StorageGasConfig>(
    new SimpleStructTag(StorageGasConfig),
    new HexString("0x1")
  );
  gas = $c.borrow_global_mut<StorageGas>(
    new SimpleStructTag(StorageGas),
    new HexString("0x1")
  );
  gas.per_item_read = calculate_read_gas_(
    gas_config.item_config,
    $.copy(items),
    $c
  );
  gas.per_item_create = calculate_create_gas_(
    gas_config.item_config,
    $.copy(items),
    $c
  );
  gas.per_item_write = calculate_write_gas_(
    gas_config.item_config,
    $.copy(items),
    $c
  );
  gas.per_byte_read = calculate_read_gas_(
    gas_config.byte_config,
    $.copy(bytes),
    $c
  );
  gas.per_byte_create = calculate_create_gas_(
    gas_config.byte_config,
    $.copy(bytes),
    $c
  );
  gas.per_byte_write = calculate_write_gas_(
    gas_config.byte_config,
    $.copy(bytes),
    $c
  );
  return;
}

export function set_config_(
  aptos_framework: HexString,
  config: StorageGasConfig,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $.set(
    $c.borrow_global_mut<StorageGasConfig>(
      new SimpleStructTag(StorageGasConfig),
      new HexString("0x1")
    ),
    $.copy(config)
  );
  return;
}

export function validate_points_(points: Point[], $c: AptosDataCache): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, cur, i, len, next;
  len = Vector.length_(points, $c, [new SimpleStructTag(Point)]);
  i = u64("0");
  while (true) {
    {
    }
    if (!$.copy(i).le($.copy(len))) break;
    {
      if ($.copy(i).eq(u64("0"))) {
        temp$1 = new Point(
          { x: u64("0"), y: u64("0") },
          new SimpleStructTag(Point)
        );
        temp$2 = temp$1;
      } else {
        temp$2 = Vector.borrow_(points, $.copy(i).sub(u64("1")), $c, [
          new SimpleStructTag(Point),
        ]);
      }
      cur = temp$2;
      if ($.copy(i).eq($.copy(len))) {
        temp$3 = new Point(
          {
            x: $.copy(BASIS_POINT_DENOMINATION),
            y: $.copy(BASIS_POINT_DENOMINATION),
          },
          new SimpleStructTag(Point)
        );
        temp$4 = temp$3;
      } else {
        temp$4 = Vector.borrow_(points, $.copy(i), $c, [
          new SimpleStructTag(Point),
        ]);
      }
      next = temp$4;
      if ($.copy(cur.x).lt($.copy(next.x))) {
        temp$5 = $.copy(cur.y).le($.copy(next.y));
      } else {
        temp$5 = false;
      }
      if (!temp$5) {
        throw $.abortCode(
          Error.invalid_argument_(
            $.copy(EINVALID_MONOTONICALLY_NON_DECREASING_CURVE),
            $c
          )
        );
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::storage_gas::GasCurve", GasCurve.GasCurveParser);
  repo.addParser("0x1::storage_gas::Point", Point.PointParser);
  repo.addParser("0x1::storage_gas::StorageGas", StorageGas.StorageGasParser);
  repo.addParser(
    "0x1::storage_gas::StorageGasConfig",
    StorageGasConfig.StorageGasConfigParser
  );
  repo.addParser(
    "0x1::storage_gas::UsageGasConfig",
    UsageGasConfig.UsageGasConfigParser
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
  get GasCurve() {
    return GasCurve;
  }
  get Point() {
    return Point;
  }
  get StorageGas() {
    return StorageGas;
  }
  async loadStorageGas(owner: HexString, loadFull = true, fillCache = true) {
    const val = await StorageGas.load(
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
  get StorageGasConfig() {
    return StorageGasConfig;
  }
  async loadStorageGasConfig(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await StorageGasConfig.load(
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
  get UsageGasConfig() {
    return UsageGasConfig;
  }
}
