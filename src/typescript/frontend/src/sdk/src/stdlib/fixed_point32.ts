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
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "fixed_point32";

export const EDENOMINATOR: U64 = u64("65537");
export const EDIVISION: U64 = u64("131074");
export const EDIVISION_BY_ZERO: U64 = u64("65540");
export const EMULTIPLICATION: U64 = u64("131075");
export const ERATIO_OUT_OF_RANGE: U64 = u64("131077");
export const MAX_U64: U128 = u128("18446744073709551615");

export class FixedPoint32 {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "FixedPoint32";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "value", typeTag: AtomicTypeTag.U64 },
  ];

  value: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.value = proto["value"] as U64;
  }

  static FixedPoint32Parser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): FixedPoint32 {
    const proto = $.parseStructProto(data, typeTag, repo, FixedPoint32);
    return new FixedPoint32(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "FixedPoint32", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function create_from_rational_(
  numerator: U64,
  denominator: U64,
  $c: AptosDataCache
): FixedPoint32 {
  let temp$1, quotient, scaled_denominator, scaled_numerator;
  scaled_numerator = u128($.copy(numerator)).shl(u8("64"));
  scaled_denominator = u128($.copy(denominator)).shl(u8("32"));
  if (!$.copy(scaled_denominator).neq(u128("0"))) {
    throw $.abortCode($.copy(EDENOMINATOR));
  }
  quotient = $.copy(scaled_numerator).div($.copy(scaled_denominator));
  if ($.copy(quotient).neq(u128("0"))) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(numerator).eq(u64("0"));
  }
  if (!temp$1) {
    throw $.abortCode($.copy(ERATIO_OUT_OF_RANGE));
  }
  if (!$.copy(quotient).le($.copy(MAX_U64))) {
    throw $.abortCode($.copy(ERATIO_OUT_OF_RANGE));
  }
  return new FixedPoint32(
    { value: u64($.copy(quotient)) },
    new SimpleStructTag(FixedPoint32)
  );
}

export function create_from_raw_value_(
  value: U64,
  $c: AptosDataCache
): FixedPoint32 {
  return new FixedPoint32(
    { value: $.copy(value) },
    new SimpleStructTag(FixedPoint32)
  );
}

export function divide_u64_(
  val: U64,
  divisor: FixedPoint32,
  $c: AptosDataCache
): U64 {
  let quotient, scaled_value;
  if (!$.copy(divisor.value).neq(u64("0"))) {
    throw $.abortCode($.copy(EDIVISION_BY_ZERO));
  }
  scaled_value = u128($.copy(val)).shl(u8("32"));
  quotient = $.copy(scaled_value).div(u128($.copy(divisor.value)));
  if (!$.copy(quotient).le($.copy(MAX_U64))) {
    throw $.abortCode($.copy(EDIVISION));
  }
  return u64($.copy(quotient));
}

export function get_raw_value_(num: FixedPoint32, $c: AptosDataCache): U64 {
  return $.copy(num.value);
}

export function is_zero_(num: FixedPoint32, $c: AptosDataCache): boolean {
  return $.copy(num.value).eq(u64("0"));
}

export function multiply_u64_(
  val: U64,
  multiplier: FixedPoint32,
  $c: AptosDataCache
): U64 {
  let product, unscaled_product;
  unscaled_product = u128($.copy(val)).mul(u128($.copy(multiplier.value)));
  product = $.copy(unscaled_product).shr(u8("32"));
  if (!$.copy(product).le($.copy(MAX_U64))) {
    throw $.abortCode($.copy(EMULTIPLICATION));
  }
  return u64($.copy(product));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::fixed_point32::FixedPoint32",
    FixedPoint32.FixedPoint32Parser
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
  get FixedPoint32() {
    return FixedPoint32;
  }
}
