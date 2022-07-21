import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Errors from "./Errors";
import * as Vector from "./Vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Option";

export const EOPTION_IS_SET : U64 = u64("0");
export const EOPTION_NOT_SET : U64 = u64("1");


export class Option 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Option";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Element", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "vec", typeTag: new VectorTag(new $.TypeParamIdx(0)) }];

  vec: any[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.vec = proto['vec'] as any[];
  }

  static OptionParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Option {
    const proto = $.parseStructProto(data, typeTag, repo, Option);
    return new Option(proto, typeTag);
  }

}
export function borrow$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EOPTION_NOT_SET, $c));
  }
  return Vector.borrow$(t.vec, u64("0"), $c, [$p[0]] as TypeTag[]);
}

export function borrow_mut$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EOPTION_NOT_SET, $c));
  }
  return Vector.borrow_mut$(t.vec, u64("0"), $c, [$p[0]] as TypeTag[]);
}

export function borrow_with_default$ (
  t: Option,
  default_ref: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    temp$1 = default_ref;
  }
  else{
    temp$1 = Vector.borrow$(vec_ref, u64("0"), $c, [$p[0]] as TypeTag[]);
  }
  return temp$1;
}

export function contains$ (
  t: Option,
  e_ref: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return Vector.contains$(t.vec, e_ref, $c, [$p[0]] as TypeTag[]);
}

export function destroy_none$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  if (!is_none$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EOPTION_IS_SET, $c));
  }
  let { vec: vec } = t;
  return Vector.destroy_empty$(vec, $c, [$p[0]] as TypeTag[]);
}

export function destroy_some$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let elem;
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EOPTION_NOT_SET, $c));
  }
  let { vec: vec } = t;
  elem = Vector.pop_back$(vec, $c, [$p[0]] as TypeTag[]);
  Vector.destroy_empty$(vec, $c, [$p[0]] as TypeTag[]);
  return elem;
}

export function destroy_with_default$ (
  t: Option,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1;
  let { vec: vec } = t;
  if (Vector.is_empty$(vec, $c, [$p[0]] as TypeTag[])) {
    temp$1 = default__;
  }
  else{
    temp$1 = Vector.pop_back$(vec, $c, [$p[0]] as TypeTag[]);
  }
  return temp$1;
}

export function extract$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EOPTION_NOT_SET, $c));
  }
  return Vector.pop_back$(t.vec, $c, [$p[0]] as TypeTag[]);
}

export function fill$ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  let vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    Vector.push_back$(vec_ref, e, $c, [$p[0]] as TypeTag[]);
  }
  else{
    throw $.abortCode(Errors.invalid_argument$(EOPTION_IS_SET, $c));
  }
  return;
}

export function get_with_default$ (
  t: Option,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    temp$1 = $.copy(default__);
  }
  else{
    temp$1 = $.copy(Vector.borrow$(vec_ref, u64("0"), $c, [$p[0]] as TypeTag[]));
  }
  return temp$1;
}

export function is_none$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return Vector.is_empty$(t.vec, $c, [$p[0]] as TypeTag[]);
}

export function is_some$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return !Vector.is_empty$(t.vec, $c, [$p[0]] as TypeTag[]);
}

export function none$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  return new Option({ vec: Vector.empty$($c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "Option", "Option", [$p[0]]));
}

export function some$ (
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  return new Option({ vec: Vector.singleton$(e, $c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "Option", "Option", [$p[0]]));
}

export function swap$ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let old_value, vec_ref;
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EOPTION_NOT_SET, $c));
  }
  vec_ref = t.vec;
  old_value = Vector.pop_back$(vec_ref, $c, [$p[0]] as TypeTag[]);
  Vector.push_back$(vec_ref, e, $c, [$p[0]] as TypeTag[]);
  return old_value;
}

export function swap_or_fill$ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  let temp$1, old_value, vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    temp$1 = none$($c, [$p[0]] as TypeTag[]);
  }
  else{
    temp$1 = some$(Vector.pop_back$(vec_ref, $c, [$p[0]] as TypeTag[]), $c, [$p[0]] as TypeTag[]);
  }
  old_value = temp$1;
  Vector.push_back$(vec_ref, e, $c, [$p[0]] as TypeTag[]);
  return old_value;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::Option::Option", Option.OptionParser);
}

