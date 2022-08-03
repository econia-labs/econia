import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Vector from "./vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "option";

export const EOPTION_IS_SET : U64 = u64("262144");
export const EOPTION_NOT_SET : U64 = u64("262145");


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
export function borrow_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some_(t, $c, [$p[0]])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  return Vector.borrow_(t.vec, u64("0"), $c, [$p[0]]);
}

export function borrow_mut_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some_(t, $c, [$p[0]])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  return Vector.borrow_mut_(t.vec, u64("0"), $c, [$p[0]]);
}

export function borrow_with_default_ (
  t: Option,
  default_ref: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty_(vec_ref, $c, [$p[0]])) {
    temp$1 = default_ref;
  }
  else{
    temp$1 = Vector.borrow_(vec_ref, u64("0"), $c, [$p[0]]);
  }
  return temp$1;
}

export function contains_ (
  t: Option,
  e_ref: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return Vector.contains_(t.vec, e_ref, $c, [$p[0]]);
}

export function destroy_none_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  if (!is_none_(t, $c, [$p[0]])) {
    throw $.abortCode(EOPTION_IS_SET);
  }
  let { vec: vec } = t;
  return Vector.destroy_empty_(vec, $c, [$p[0]]);
}

export function destroy_some_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let elem;
  if (!is_some_(t, $c, [$p[0]])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  let { vec: vec } = t;
  elem = Vector.pop_back_(vec, $c, [$p[0]]);
  Vector.destroy_empty_(vec, $c, [$p[0]]);
  return elem;
}

export function destroy_with_default_ (
  t: Option,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1;
  let { vec: vec } = t;
  if (Vector.is_empty_(vec, $c, [$p[0]])) {
    temp$1 = default__;
  }
  else{
    temp$1 = Vector.pop_back_(vec, $c, [$p[0]]);
  }
  return temp$1;
}

export function extract_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some_(t, $c, [$p[0]])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  return Vector.pop_back_(t.vec, $c, [$p[0]]);
}

export function fill_ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  let vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty_(vec_ref, $c, [$p[0]])) {
    Vector.push_back_(vec_ref, e, $c, [$p[0]]);
  }
  else{
    throw $.abortCode(EOPTION_IS_SET);
  }
  return;
}

export function get_with_default_ (
  t: Option,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty_(vec_ref, $c, [$p[0]])) {
    temp$1 = $.copy(default__);
  }
  else{
    temp$1 = $.copy(Vector.borrow_(vec_ref, u64("0"), $c, [$p[0]]));
  }
  return temp$1;
}

export function is_none_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return Vector.is_empty_(t.vec, $c, [$p[0]]);
}

export function is_some_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return !Vector.is_empty_(t.vec, $c, [$p[0]]);
}

export function none_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  return new Option({ vec: Vector.empty_($c, [$p[0]]) }, new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]));
}

export function some_ (
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  return new Option({ vec: Vector.singleton_(e, $c, [$p[0]]) }, new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]));
}

export function swap_ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let old_value, vec_ref;
  if (!is_some_(t, $c, [$p[0]])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  vec_ref = t.vec;
  old_value = Vector.pop_back_(vec_ref, $c, [$p[0]]);
  Vector.push_back_(vec_ref, e, $c, [$p[0]]);
  return old_value;
}

export function swap_or_fill_ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  let temp$1, old_value, vec_ref;
  vec_ref = t.vec;
  if (Vector.is_empty_(vec_ref, $c, [$p[0]])) {
    temp$1 = none_($c, [$p[0]]);
  }
  else{
    temp$1 = some_(Vector.pop_back_(vec_ref, $c, [$p[0]]), $c, [$p[0]]);
  }
  old_value = temp$1;
  Vector.push_back_(vec_ref, e, $c, [$p[0]]);
  return old_value;
}

export function to_vec_ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any[] {
  let { vec: vec } = t;
  return vec;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::option::Option", Option.OptionParser);
}

