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

import * as Error from "./error";
import * as Option from "./option";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "ristretto255";

export const A_PLUS_B_POINT: U8[] = [
  u8("112"),
  u8("207"),
  u8("55"),
  u8("83"),
  u8("71"),
  u8("91"),
  u8("159"),
  u8("243"),
  u8("62"),
  u8("47"),
  u8("132"),
  u8("65"),
  u8("62"),
  u8("214"),
  u8("181"),
  u8("5"),
  u8("32"),
  u8("115"),
  u8("188"),
  u8("204"),
  u8("10"),
  u8("10"),
  u8("129"),
  u8("120"),
  u8("157"),
  u8("62"),
  u8("86"),
  u8("117"),
  u8("220"),
  u8("37"),
  u8("128"),
  u8("86"),
];
export const A_PLUS_B_SCALAR: U8[] = [
  u8("8"),
  u8("56"),
  u8("57"),
  u8("221"),
  u8("73"),
  u8("30"),
  u8("87"),
  u8("197"),
  u8("116"),
  u8("55"),
  u8("16"),
  u8("195"),
  u8("154"),
  u8("145"),
  u8("214"),
  u8("229"),
  u8("2"),
  u8("202"),
  u8("179"),
  u8("207"),
  u8("14"),
  u8("39"),
  u8("154"),
  u8("228"),
  u8("23"),
  u8("217"),
  u8("31"),
  u8("242"),
  u8("203"),
  u8("99"),
  u8("62"),
  u8("7"),
];
export const A_POINT: U8[] = [
  u8("232"),
  u8("127"),
  u8("237"),
  u8("161"),
  u8("153"),
  u8("215"),
  u8("43"),
  u8("131"),
  u8("222"),
  u8("79"),
  u8("91"),
  u8("45"),
  u8("69"),
  u8("211"),
  u8("72"),
  u8("5"),
  u8("197"),
  u8("112"),
  u8("25"),
  u8("198"),
  u8("197"),
  u8("156"),
  u8("66"),
  u8("203"),
  u8("112"),
  u8("238"),
  u8("61"),
  u8("25"),
  u8("170"),
  u8("153"),
  u8("111"),
  u8("117"),
];
export const A_SCALAR: U8[] = [
  u8("26"),
  u8("14"),
  u8("151"),
  u8("138"),
  u8("144"),
  u8("246"),
  u8("98"),
  u8("45"),
  u8("55"),
  u8("71"),
  u8("2"),
  u8("63"),
  u8("138"),
  u8("216"),
  u8("38"),
  u8("77"),
  u8("167"),
  u8("88"),
  u8("170"),
  u8("27"),
  u8("136"),
  u8("224"),
  u8("64"),
  u8("209"),
  u8("88"),
  u8("158"),
  u8("123"),
  u8("127"),
  u8("35"),
  u8("118"),
  u8("239"),
  u8("9"),
];
export const A_TIMES_BASE_POINT: U8[] = [
  u8("150"),
  u8("213"),
  u8("45"),
  u8("146"),
  u8("98"),
  u8("238"),
  u8("30"),
  u8("26"),
  u8("174"),
  u8("121"),
  u8("251"),
  u8("174"),
  u8("232"),
  u8("193"),
  u8("217"),
  u8("6"),
  u8("139"),
  u8("13"),
  u8("1"),
  u8("191"),
  u8("154"),
  u8("69"),
  u8("121"),
  u8("230"),
  u8("24"),
  u8("9"),
  u8("12"),
  u8("61"),
  u8("16"),
  u8("136"),
  u8("174"),
  u8("16"),
];
export const A_TIMES_B_SCALAR: U8[] = [
  u8("42"),
  u8("181"),
  u8("14"),
  u8("56"),
  u8("61"),
  u8("124"),
  u8("33"),
  u8("15"),
  u8("116"),
  u8("213"),
  u8("56"),
  u8("115"),
  u8("48"),
  u8("115"),
  u8("95"),
  u8("24"),
  u8("49"),
  u8("81"),
  u8("18"),
  u8("209"),
  u8("13"),
  u8("251"),
  u8("152"),
  u8("252"),
  u8("206"),
  u8("30"),
  u8("38"),
  u8("32"),
  u8("192"),
  u8("192"),
  u8("20"),
  u8("2"),
];
export const BASE_POINT: U8[] = [
  u8("226"),
  u8("242"),
  u8("174"),
  u8("10"),
  u8("106"),
  u8("188"),
  u8("78"),
  u8("113"),
  u8("168"),
  u8("132"),
  u8("169"),
  u8("97"),
  u8("197"),
  u8("0"),
  u8("81"),
  u8("95"),
  u8("88"),
  u8("227"),
  u8("11"),
  u8("106"),
  u8("165"),
  u8("130"),
  u8("221"),
  u8("141"),
  u8("182"),
  u8("166"),
  u8("89"),
  u8("69"),
  u8("224"),
  u8("141"),
  u8("45"),
  u8("118"),
];
export const B_POINT: U8[] = [
  u8("250"),
  u8("11"),
  u8("54"),
  u8("36"),
  u8("176"),
  u8("129"),
  u8("198"),
  u8("47"),
  u8("54"),
  u8("77"),
  u8("11"),
  u8("40"),
  u8("57"),
  u8("220"),
  u8("199"),
  u8("109"),
  u8("124"),
  u8("58"),
  u8("176"),
  u8("226"),
  u8("126"),
  u8("49"),
  u8("190"),
  u8("178"),
  u8("185"),
  u8("237"),
  u8("118"),
  u8("101"),
  u8("117"),
  u8("242"),
  u8("142"),
  u8("118"),
];
export const B_SCALAR: U8[] = [
  u8("219"),
  u8("253"),
  u8("151"),
  u8("175"),
  u8("211"),
  u8("138"),
  u8("6"),
  u8("240"),
  u8("19"),
  u8("141"),
  u8("5"),
  u8("39"),
  u8("239"),
  u8("178"),
  u8("142"),
  u8("173"),
  u8("91"),
  u8("113"),
  u8("9"),
  u8("180"),
  u8("134"),
  u8("70"),
  u8("89"),
  u8("19"),
  u8("191"),
  u8("58"),
  u8("164"),
  u8("114"),
  u8("168"),
  u8("237"),
  u8("78"),
  u8("13"),
];
export const E_DIFFERENT_NUM_POINTS_AND_SCALARS: U64 = u64("1");
export const E_ZERO_POINTS: U64 = u64("2");
export const E_ZERO_SCALARS: U64 = u64("3");
export const L_MINUS_ONE: U8[] = [
  u8("236"),
  u8("211"),
  u8("245"),
  u8("92"),
  u8("26"),
  u8("99"),
  u8("18"),
  u8("88"),
  u8("214"),
  u8("156"),
  u8("247"),
  u8("162"),
  u8("222"),
  u8("249"),
  u8("222"),
  u8("20"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("16"),
];
export const L_PLUS_ONE: U8[] = [
  u8("238"),
  u8("211"),
  u8("245"),
  u8("92"),
  u8("26"),
  u8("99"),
  u8("18"),
  u8("88"),
  u8("214"),
  u8("156"),
  u8("247"),
  u8("162"),
  u8("222"),
  u8("249"),
  u8("222"),
  u8("20"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("16"),
];
export const L_PLUS_TWO: U8[] = [
  u8("239"),
  u8("211"),
  u8("245"),
  u8("92"),
  u8("26"),
  u8("99"),
  u8("18"),
  u8("88"),
  u8("214"),
  u8("156"),
  u8("247"),
  u8("162"),
  u8("222"),
  u8("249"),
  u8("222"),
  u8("20"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("16"),
];
export const MAX_POINT_NUM_BYTES: U64 = u64("32");
export const MAX_SCALAR_NUM_BITS: U64 = u64("256");
export const MAX_SCALAR_NUM_BYTES: U64 = u64("32");
export const NON_CANONICAL_ALL_ONES: U8[] = [
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
];
export const ORDER_ELL: U8[] = [
  u8("237"),
  u8("211"),
  u8("245"),
  u8("92"),
  u8("26"),
  u8("99"),
  u8("18"),
  u8("88"),
  u8("214"),
  u8("156"),
  u8("247"),
  u8("162"),
  u8("222"),
  u8("249"),
  u8("222"),
  u8("20"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("16"),
];
export const REDUCED_2_256_MINUS_1_SCALAR: U8[] = [
  u8("28"),
  u8("149"),
  u8("152"),
  u8("141"),
  u8("116"),
  u8("49"),
  u8("236"),
  u8("214"),
  u8("112"),
  u8("207"),
  u8("125"),
  u8("115"),
  u8("244"),
  u8("91"),
  u8("239"),
  u8("198"),
  u8("254"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("255"),
  u8("15"),
];
export const REDUCED_X_PLUS_2_TO_256_TIMES_X_SCALAR: U8[] = [
  u8("216"),
  u8("154"),
  u8("179"),
  u8("139"),
  u8("210"),
  u8("121"),
  u8("2"),
  u8("71"),
  u8("69"),
  u8("99"),
  u8("158"),
  u8("216"),
  u8("23"),
  u8("173"),
  u8("63"),
  u8("100"),
  u8("204"),
  u8("0"),
  u8("91"),
  u8("50"),
  u8("219"),
  u8("153"),
  u8("57"),
  u8("249"),
  u8("28"),
  u8("82"),
  u8("31"),
  u8("197"),
  u8("100"),
  u8("165"),
  u8("192"),
  u8("8"),
];
export const TWO_SCALAR: U8[] = [
  u8("2"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
];
export const X_INV_SCALAR: U8[] = [
  u8("28"),
  u8("220"),
  u8("23"),
  u8("252"),
  u8("224"),
  u8("233"),
  u8("165"),
  u8("187"),
  u8("217"),
  u8("36"),
  u8("126"),
  u8("86"),
  u8("187"),
  u8("1"),
  u8("99"),
  u8("71"),
  u8("187"),
  u8("186"),
  u8("49"),
  u8("237"),
  u8("213"),
  u8("169"),
  u8("187"),
  u8("150"),
  u8("213"),
  u8("11"),
  u8("205"),
  u8("122"),
  u8("63"),
  u8("150"),
  u8("42"),
  u8("15"),
];
export const X_SCALAR: U8[] = [
  u8("78"),
  u8("90"),
  u8("180"),
  u8("52"),
  u8("93"),
  u8("71"),
  u8("8"),
  u8("132"),
  u8("89"),
  u8("19"),
  u8("180"),
  u8("100"),
  u8("27"),
  u8("194"),
  u8("125"),
  u8("82"),
  u8("82"),
  u8("165"),
  u8("133"),
  u8("16"),
  u8("27"),
  u8("204"),
  u8("66"),
  u8("68"),
  u8("212"),
  u8("73"),
  u8("244"),
  u8("168"),
  u8("121"),
  u8("217"),
  u8("242"),
  u8("4"),
];
export const X_TIMES_Y_SCALAR: U8[] = [
  u8("108"),
  u8("51"),
  u8("116"),
  u8("161"),
  u8("137"),
  u8("79"),
  u8("98"),
  u8("33"),
  u8("10"),
  u8("170"),
  u8("47"),
  u8("225"),
  u8("134"),
  u8("166"),
  u8("249"),
  u8("44"),
  u8("224"),
  u8("170"),
  u8("117"),
  u8("194"),
  u8("119"),
  u8("149"),
  u8("129"),
  u8("194"),
  u8("149"),
  u8("252"),
  u8("8"),
  u8("23"),
  u8("154"),
  u8("115"),
  u8("148"),
  u8("12"),
];
export const Y_SCALAR: U8[] = [
  u8("144"),
  u8("118"),
  u8("51"),
  u8("254"),
  u8("28"),
  u8("75"),
  u8("102"),
  u8("164"),
  u8("162"),
  u8("141"),
  u8("45"),
  u8("215"),
  u8("103"),
  u8("131"),
  u8("134"),
  u8("195"),
  u8("83"),
  u8("208"),
  u8("222"),
  u8("84"),
  u8("85"),
  u8("212"),
  u8("252"),
  u8("157"),
  u8("232"),
  u8("239"),
  u8("122"),
  u8("195"),
  u8("31"),
  u8("53"),
  u8("187"),
  u8("5"),
];

export class CompressedRistretto {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CompressedRistretto";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "data", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  data: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.data = proto["data"] as U8[];
  }

  static CompressedRistrettoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CompressedRistretto {
    const proto = $.parseStructProto(data, typeTag, repo, CompressedRistretto);
    return new CompressedRistretto(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "CompressedRistretto", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class RistrettoPoint {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RistrettoPoint";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "handle", typeTag: AtomicTypeTag.U64 },
  ];

  handle: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.handle = proto["handle"] as U64;
  }

  static RistrettoPointParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RistrettoPoint {
    const proto = $.parseStructProto(data, typeTag, repo, RistrettoPoint);
    return new RistrettoPoint(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RistrettoPoint", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class Scalar {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Scalar";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "data", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  data: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.data = proto["data"] as U8[];
  }

  static ScalarParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Scalar {
    const proto = $.parseStructProto(data, typeTag, repo, Scalar);
    return new Scalar(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Scalar", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function basepoint_($c: AptosDataCache): RistrettoPoint {
  let handle;
  [handle] = point_decompress_internal_($.copy(BASE_POINT), $c);
  return new RistrettoPoint(
    { handle: $.copy(handle) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function basepoint_compressed_($c: AptosDataCache): CompressedRistretto {
  return new CompressedRistretto(
    { data: $.copy(BASE_POINT) },
    new SimpleStructTag(CompressedRistretto)
  );
}

export function basepoint_double_mul_(
  a: Scalar,
  some_point: RistrettoPoint,
  b: Scalar,
  $c: AptosDataCache
): RistrettoPoint {
  return new RistrettoPoint(
    {
      handle: basepoint_double_mul_internal_(
        $.copy(a.data),
        some_point,
        $.copy(b.data),
        $c
      ),
    },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function basepoint_double_mul_internal_(
  a: U8[],
  some_point: RistrettoPoint,
  b: U8[],
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function basepoint_mul_(a: Scalar, $c: AptosDataCache): RistrettoPoint {
  return new RistrettoPoint(
    { handle: basepoint_mul_internal_($.copy(a.data), $c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function basepoint_mul_internal_(a: U8[], $c: AptosDataCache): U64 {
  throw "Not Implemented";
}
export function multi_scalar_mul_(
  points: RistrettoPoint[],
  scalars: Scalar[],
  $c: AptosDataCache
): RistrettoPoint {
  if (Vector.is_empty_(points, $c, [new SimpleStructTag(RistrettoPoint)])) {
    throw $.abortCode(Error.invalid_argument_($.copy(E_ZERO_POINTS), $c));
  }
  if (Vector.is_empty_(scalars, $c, [new SimpleStructTag(Scalar)])) {
    throw $.abortCode(Error.invalid_argument_($.copy(E_ZERO_SCALARS), $c));
  }
  if (
    !Vector.length_(points, $c, [new SimpleStructTag(RistrettoPoint)]).eq(
      Vector.length_(scalars, $c, [new SimpleStructTag(Scalar)])
    )
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(E_DIFFERENT_NUM_POINTS_AND_SCALARS), $c)
    );
  }
  return new RistrettoPoint(
    {
      handle: multi_scalar_mul_internal_(points, scalars, $c, [
        new SimpleStructTag(RistrettoPoint),
        new SimpleStructTag(Scalar),
      ]),
    },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function multi_scalar_mul_internal_(
  points: any[],
  scalars: any[],
  $c: AptosDataCache,
  $p: TypeTag[] /* <P, S>*/
): U64 {
  throw "Not Implemented";
}
export function new_compressed_point_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (point_is_canonical_internal_($.copy(bytes), $c)) {
    temp$1 = Option.some_(
      new CompressedRistretto(
        { data: $.copy(bytes) },
        new SimpleStructTag(CompressedRistretto)
      ),
      $c,
      [new SimpleStructTag(CompressedRistretto)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(CompressedRistretto)]);
  }
  return temp$1;
}

export function new_point_from_64_uniform_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (Vector.length_(bytes, $c, [AtomicTypeTag.U8]).eq(u64("64"))) {
    temp$1 = Option.some_(
      new RistrettoPoint(
        {
          handle: new_point_from_64_uniform_bytes_internal_($.copy(bytes), $c),
        },
        new SimpleStructTag(RistrettoPoint)
      ),
      $c,
      [new SimpleStructTag(RistrettoPoint)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(RistrettoPoint)]);
  }
  return temp$1;
}

export function new_point_from_64_uniform_bytes_internal_(
  bytes: U8[],
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function new_point_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1, handle, is_canonical;
  [handle, is_canonical] = point_decompress_internal_($.copy(bytes), $c);
  if (is_canonical) {
    temp$1 = Option.some_(
      new RistrettoPoint(
        { handle: $.copy(handle) },
        new SimpleStructTag(RistrettoPoint)
      ),
      $c,
      [new SimpleStructTag(RistrettoPoint)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(RistrettoPoint)]);
  }
  return temp$1;
}

export function new_point_from_sha512_(
  sha512: U8[],
  $c: AptosDataCache
): RistrettoPoint {
  return new RistrettoPoint(
    { handle: new_point_from_sha512_internal_($.copy(sha512), $c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function new_point_from_sha512_internal_(
  sha512: U8[],
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function new_scalar_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (scalar_is_canonical_internal_($.copy(bytes), $c)) {
    temp$1 = Option.some_(
      new Scalar({ data: $.copy(bytes) }, new SimpleStructTag(Scalar)),
      $c,
      [new SimpleStructTag(Scalar)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(Scalar)]);
  }
  return temp$1;
}

export function new_scalar_from_sha512_(
  sha512_input: U8[],
  $c: AptosDataCache
): Scalar {
  return new Scalar(
    { data: scalar_from_sha512_internal_($.copy(sha512_input), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function new_scalar_from_u128_(
  sixteen_bytes: U128,
  $c: AptosDataCache
): Scalar {
  return new Scalar(
    { data: scalar_from_u128_internal_($.copy(sixteen_bytes), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function new_scalar_from_u64_(
  eight_bytes: U64,
  $c: AptosDataCache
): Scalar {
  return new Scalar(
    { data: scalar_from_u64_internal_($.copy(eight_bytes), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function new_scalar_from_u8_(byte: U8, $c: AptosDataCache): Scalar {
  let byte_zero, s;
  s = scalar_zero_($c);
  byte_zero = Vector.borrow_mut_(s.data, u64("0"), $c, [AtomicTypeTag.U8]);
  $.set(byte_zero, $.copy(byte));
  return $.copy(s);
}

export function new_scalar_reduced_from_32_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (Vector.length_(bytes, $c, [AtomicTypeTag.U8]).eq(u64("32"))) {
    temp$1 = Option.some_(
      new Scalar(
        { data: scalar_reduced_from_32_bytes_internal_($.copy(bytes), $c) },
        new SimpleStructTag(Scalar)
      ),
      $c,
      [new SimpleStructTag(Scalar)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(Scalar)]);
  }
  return temp$1;
}

export function new_scalar_uniform_from_64_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (Vector.length_(bytes, $c, [AtomicTypeTag.U8]).eq(u64("64"))) {
    temp$1 = Option.some_(
      new Scalar(
        { data: scalar_uniform_from_64_bytes_internal_($.copy(bytes), $c) },
        new SimpleStructTag(Scalar)
      ),
      $c,
      [new SimpleStructTag(Scalar)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(Scalar)]);
  }
  return temp$1;
}

export function point_add_(
  a: RistrettoPoint,
  b: RistrettoPoint,
  $c: AptosDataCache
): RistrettoPoint {
  return new RistrettoPoint(
    { handle: point_add_internal_(a, b, false, $c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function point_add_assign_(
  a: RistrettoPoint,
  b: RistrettoPoint,
  $c: AptosDataCache
): RistrettoPoint {
  let temp$1, temp$2, temp$3;
  [temp$1, temp$2, temp$3] = [a, b, true];
  point_add_internal_(temp$1, temp$2, temp$3, $c);
  return a;
}

export function point_add_internal_(
  a: RistrettoPoint,
  b: RistrettoPoint,
  in_place: boolean,
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function point_compress_(
  point: RistrettoPoint,
  $c: AptosDataCache
): CompressedRistretto {
  return new CompressedRistretto(
    { data: point_compress_internal_(point, $c) },
    new SimpleStructTag(CompressedRistretto)
  );
}

export function point_compress_internal_(
  point: RistrettoPoint,
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function point_decompress_(
  point: CompressedRistretto,
  $c: AptosDataCache
): RistrettoPoint {
  let handle;
  [handle] = point_decompress_internal_($.copy(point.data), $c);
  return new RistrettoPoint(
    { handle: $.copy(handle) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function point_decompress_internal_(
  maybe_non_canonical_bytes: U8[],
  $c: AptosDataCache
): [U64, boolean] {
  throw "Not Implemented";
}
export function point_equals_(
  g: RistrettoPoint,
  h: RistrettoPoint,
  $c: AptosDataCache
): boolean {
  throw "Not Implemented";
}
export function point_identity_($c: AptosDataCache): RistrettoPoint {
  return new RistrettoPoint(
    { handle: point_identity_internal_($c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function point_identity_compressed_(
  $c: AptosDataCache
): CompressedRistretto {
  return new CompressedRistretto(
    {
      data: [
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
      ],
    },
    new SimpleStructTag(CompressedRistretto)
  );
}

export function point_identity_internal_($c: AptosDataCache): U64 {
  throw "Not Implemented";
}
export function point_is_canonical_internal_(
  bytes: U8[],
  $c: AptosDataCache
): boolean {
  throw "Not Implemented";
}
export function point_mul_(
  point: RistrettoPoint,
  a: Scalar,
  $c: AptosDataCache
): RistrettoPoint {
  return new RistrettoPoint(
    { handle: point_mul_internal_(point, $.copy(a.data), false, $c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function point_mul_assign_(
  point: RistrettoPoint,
  a: Scalar,
  $c: AptosDataCache
): RistrettoPoint {
  let temp$1, temp$2, temp$3;
  [temp$1, temp$2, temp$3] = [point, $.copy(a.data), true];
  point_mul_internal_(temp$1, temp$2, temp$3, $c);
  return point;
}

export function point_mul_internal_(
  point: RistrettoPoint,
  a: U8[],
  in_place: boolean,
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function point_neg_(
  a: RistrettoPoint,
  $c: AptosDataCache
): RistrettoPoint {
  return new RistrettoPoint(
    { handle: point_neg_internal_(a, false, $c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function point_neg_assign_(
  a: RistrettoPoint,
  $c: AptosDataCache
): RistrettoPoint {
  let temp$1, temp$2;
  [temp$1, temp$2] = [a, true];
  point_neg_internal_(temp$1, temp$2, $c);
  return a;
}

export function point_neg_internal_(
  a: RistrettoPoint,
  in_place: boolean,
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function point_sub_(
  a: RistrettoPoint,
  b: RistrettoPoint,
  $c: AptosDataCache
): RistrettoPoint {
  return new RistrettoPoint(
    { handle: point_sub_internal_(a, b, false, $c) },
    new SimpleStructTag(RistrettoPoint)
  );
}

export function point_sub_assign_(
  a: RistrettoPoint,
  b: RistrettoPoint,
  $c: AptosDataCache
): RistrettoPoint {
  let temp$1, temp$2, temp$3;
  [temp$1, temp$2, temp$3] = [a, b, true];
  point_sub_internal_(temp$1, temp$2, temp$3, $c);
  return a;
}

export function point_sub_internal_(
  a: RistrettoPoint,
  b: RistrettoPoint,
  in_place: boolean,
  $c: AptosDataCache
): U64 {
  throw "Not Implemented";
}
export function point_to_bytes_(
  point: CompressedRistretto,
  $c: AptosDataCache
): U8[] {
  return $.copy(point.data);
}

export function scalar_add_(a: Scalar, b: Scalar, $c: AptosDataCache): Scalar {
  return new Scalar(
    { data: scalar_add_internal_($.copy(a.data), $.copy(b.data), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function scalar_add_assign_(
  a: Scalar,
  b: Scalar,
  $c: AptosDataCache
): Scalar {
  let temp$1, temp$2, temp$3;
  [temp$1, temp$2] = [a, b];
  temp$3 = scalar_add_(temp$1, temp$2, $c);
  a.data = $.copy(temp$3.data);
  return a;
}

export function scalar_add_internal_(
  a_bytes: U8[],
  b_bytes: U8[],
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_equals_(
  lhs: Scalar,
  rhs: Scalar,
  $c: AptosDataCache
): boolean {
  return $.veq($.copy(lhs.data), $.copy(rhs.data));
}

export function scalar_from_sha512_internal_(
  sha512_input: U8[],
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_from_u128_internal_(
  num: U128,
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_from_u64_internal_(num: U64, $c: AptosDataCache): U8[] {
  throw "Not Implemented";
}
export function scalar_invert_(s: Scalar, $c: AptosDataCache): Option.Option {
  let temp$1;
  if (scalar_is_zero_(s, $c)) {
    temp$1 = Option.none_($c, [new SimpleStructTag(Scalar)]);
  } else {
    temp$1 = Option.some_(
      new Scalar(
        { data: scalar_invert_internal_($.copy(s.data), $c) },
        new SimpleStructTag(Scalar)
      ),
      $c,
      [new SimpleStructTag(Scalar)]
    );
  }
  return temp$1;
}

export function scalar_invert_internal_(bytes: U8[], $c: AptosDataCache): U8[] {
  throw "Not Implemented";
}
export function scalar_is_canonical_internal_(
  s: U8[],
  $c: AptosDataCache
): boolean {
  throw "Not Implemented";
}
export function scalar_is_one_(s: Scalar, $c: AptosDataCache): boolean {
  return $.veq($.copy(s.data), [
    u8("1"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
  ]);
}

export function scalar_is_zero_(s: Scalar, $c: AptosDataCache): boolean {
  return $.veq($.copy(s.data), [
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
    u8("0"),
  ]);
}

export function scalar_mul_(a: Scalar, b: Scalar, $c: AptosDataCache): Scalar {
  return new Scalar(
    { data: scalar_mul_internal_($.copy(a.data), $.copy(b.data), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function scalar_mul_assign_(
  a: Scalar,
  b: Scalar,
  $c: AptosDataCache
): Scalar {
  let temp$1, temp$2, temp$3;
  [temp$1, temp$2] = [a, b];
  temp$3 = scalar_mul_(temp$1, temp$2, $c);
  a.data = $.copy(temp$3.data);
  return a;
}

export function scalar_mul_internal_(
  a_bytes: U8[],
  b_bytes: U8[],
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_neg_(a: Scalar, $c: AptosDataCache): Scalar {
  return new Scalar(
    { data: scalar_neg_internal_($.copy(a.data), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function scalar_neg_assign_(a: Scalar, $c: AptosDataCache): Scalar {
  let temp$1;
  temp$1 = scalar_neg_(a, $c);
  a.data = $.copy(temp$1.data);
  return a;
}

export function scalar_neg_internal_(a_bytes: U8[], $c: AptosDataCache): U8[] {
  throw "Not Implemented";
}
export function scalar_one_($c: AptosDataCache): Scalar {
  return new Scalar(
    {
      data: [
        u8("1"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
      ],
    },
    new SimpleStructTag(Scalar)
  );
}

export function scalar_reduced_from_32_bytes_internal_(
  bytes: U8[],
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_sub_(a: Scalar, b: Scalar, $c: AptosDataCache): Scalar {
  return new Scalar(
    { data: scalar_sub_internal_($.copy(a.data), $.copy(b.data), $c) },
    new SimpleStructTag(Scalar)
  );
}

export function scalar_sub_assign_(
  a: Scalar,
  b: Scalar,
  $c: AptosDataCache
): Scalar {
  let temp$1, temp$2, temp$3;
  [temp$1, temp$2] = [a, b];
  temp$3 = scalar_sub_(temp$1, temp$2, $c);
  a.data = $.copy(temp$3.data);
  return a;
}

export function scalar_sub_internal_(
  a_bytes: U8[],
  b_bytes: U8[],
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_to_bytes_(s: Scalar, $c: AptosDataCache): U8[] {
  return $.copy(s.data);
}

export function scalar_uniform_from_64_bytes_internal_(
  bytes: U8[],
  $c: AptosDataCache
): U8[] {
  throw "Not Implemented";
}
export function scalar_zero_($c: AptosDataCache): Scalar {
  return new Scalar(
    {
      data: [
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
        u8("0"),
      ],
    },
    new SimpleStructTag(Scalar)
  );
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::ristretto255::CompressedRistretto",
    CompressedRistretto.CompressedRistrettoParser
  );
  repo.addParser(
    "0x1::ristretto255::RistrettoPoint",
    RistrettoPoint.RistrettoPointParser
  );
  repo.addParser("0x1::ristretto255::Scalar", Scalar.ScalarParser);
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
  get CompressedRistretto() {
    return CompressedRistretto;
  }
  get RistrettoPoint() {
    return RistrettoPoint;
  }
  get Scalar() {
    return Scalar;
  }
}
