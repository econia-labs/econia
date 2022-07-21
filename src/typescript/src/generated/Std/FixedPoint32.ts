import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Errors from "./Errors";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "FixedPoint32";

export const EDENOMINATOR : U64 = u64("0");
export const EDIVISION : U64 = u64("1");
export const EDIVISION_BY_ZERO : U64 = u64("3");
export const EMULTIPLICATION : U64 = u64("2");
export const ERATIO_OUT_OF_RANGE : U64 = u64("4");
export const MAX_U64 : U128 = u128("18446744073709551615");


export class FixedPoint32 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "FixedPoint32";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "value", typeTag: AtomicTypeTag.U64 }];

  value: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.value = proto['value'] as U64;
  }

  static FixedPoint32Parser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : FixedPoint32 {
    const proto = $.parseStructProto(data, typeTag, repo, FixedPoint32);
    return new FixedPoint32(proto, typeTag);
  }

}
export function create_from_rational$ (
  numerator: U64,
  denominator: U64,
  $c: AptosDataCache,
): FixedPoint32 {
  let temp$1, quotient, scaled_denominator, scaled_numerator;
  scaled_numerator = u128($.copy(numerator)).shl(u8("64"));
  scaled_denominator = u128($.copy(denominator)).shl(u8("32"));
  if (!$.copy(scaled_denominator).neq(u128("0"))) {
    throw $.abortCode(Errors.invalid_argument$(EDENOMINATOR, $c));
  }
  quotient = $.copy(scaled_numerator).div($.copy(scaled_denominator));
  if ($.copy(quotient).neq(u128("0"))) {
    temp$1 = true;
  }
  else{
    temp$1 = $.copy(numerator).eq(u64("0"));
  }
  if (!temp$1) {
    throw $.abortCode(Errors.invalid_argument$(ERATIO_OUT_OF_RANGE, $c));
  }
  if (!$.copy(quotient).le(MAX_U64)) {
    throw $.abortCode(Errors.limit_exceeded$(ERATIO_OUT_OF_RANGE, $c));
  }
  return new FixedPoint32({ value: u64($.copy(quotient)) }, new StructTag(new HexString("0x1"), "FixedPoint32", "FixedPoint32", []));
}

export function create_from_raw_value$ (
  value: U64,
  $c: AptosDataCache,
): FixedPoint32 {
  return new FixedPoint32({ value: $.copy(value) }, new StructTag(new HexString("0x1"), "FixedPoint32", "FixedPoint32", []));
}

export function divide_u64$ (
  val: U64,
  divisor: FixedPoint32,
  $c: AptosDataCache,
): U64 {
  let quotient, scaled_value;
  if (!$.copy(divisor.value).neq(u64("0"))) {
    throw $.abortCode(Errors.invalid_argument$(EDIVISION_BY_ZERO, $c));
  }
  scaled_value = u128($.copy(val)).shl(u8("32"));
  quotient = $.copy(scaled_value).div(u128($.copy(divisor.value)));
  if (!$.copy(quotient).le(MAX_U64)) {
    throw $.abortCode(Errors.limit_exceeded$(EDIVISION, $c));
  }
  return u64($.copy(quotient));
}

export function get_raw_value$ (
  num: FixedPoint32,
  $c: AptosDataCache,
): U64 {
  return $.copy(num.value);
}

export function is_zero$ (
  num: FixedPoint32,
  $c: AptosDataCache,
): boolean {
  return $.copy(num.value).eq(u64("0"));
}

export function multiply_u64$ (
  val: U64,
  multiplier: FixedPoint32,
  $c: AptosDataCache,
): U64 {
  let product, unscaled_product;
  unscaled_product = u128($.copy(val)).mul(u128($.copy(multiplier.value)));
  product = $.copy(unscaled_product).shr(u8("32"));
  if (!$.copy(product).le(MAX_U64)) {
    throw $.abortCode(Errors.limit_exceeded$(EMULTIPLICATION, $c));
  }
  return u64($.copy(product));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::FixedPoint32::FixedPoint32", FixedPoint32.FixedPoint32Parser);
}

