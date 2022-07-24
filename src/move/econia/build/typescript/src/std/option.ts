import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as vector$_ from "./vector";
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
export function borrow$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  return vector$_.borrow$(t.vec, u64("0"), $c, [$p[0]] as TypeTag[]);
}

export function borrow_mut$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  return vector$_.borrow_mut$(t.vec, u64("0"), $c, [$p[0]] as TypeTag[]);
}

export function borrow_with_default$ (
  t: Option,
  default_ref: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let temp$1, vec_ref;
  vec_ref = t.vec;
  if (vector$_.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    temp$1 = default_ref;
  }
  else{
    temp$1 = vector$_.borrow$(vec_ref, u64("0"), $c, [$p[0]] as TypeTag[]);
  }
  return temp$1;
}

export function contains$ (
  t: Option,
  e_ref: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return vector$_.contains$(t.vec, e_ref, $c, [$p[0]] as TypeTag[]);
}

export function destroy_none$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  if (!is_none$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EOPTION_IS_SET);
  }
  let { vec: vec } = t;
  return vector$_.destroy_empty$(vec, $c, [$p[0]] as TypeTag[]);
}

export function destroy_some$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let elem;
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  let { vec: vec } = t;
  elem = vector$_.pop_back$(vec, $c, [$p[0]] as TypeTag[]);
  vector$_.destroy_empty$(vec, $c, [$p[0]] as TypeTag[]);
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
  if (vector$_.is_empty$(vec, $c, [$p[0]] as TypeTag[])) {
    temp$1 = default__;
  }
  else{
    temp$1 = vector$_.pop_back$(vec, $c, [$p[0]] as TypeTag[]);
  }
  return temp$1;
}

export function extract$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  return vector$_.pop_back$(t.vec, $c, [$p[0]] as TypeTag[]);
}

export function fill$ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): void {
  let vec_ref;
  vec_ref = t.vec;
  if (vector$_.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    vector$_.push_back$(vec_ref, e, $c, [$p[0]] as TypeTag[]);
  }
  else{
    throw $.abortCode(EOPTION_IS_SET);
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
  if (vector$_.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    temp$1 = $.copy(default__);
  }
  else{
    temp$1 = $.copy(vector$_.borrow$(vec_ref, u64("0"), $c, [$p[0]] as TypeTag[]));
  }
  return temp$1;
}

export function is_none$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return vector$_.is_empty$(t.vec, $c, [$p[0]] as TypeTag[]);
}

export function is_some$ (
  t: Option,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): boolean {
  return !vector$_.is_empty$(t.vec, $c, [$p[0]] as TypeTag[]);
}

export function none$ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  return new Option({ vec: vector$_.empty$($c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]));
}

export function some$ (
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): Option {
  return new Option({ vec: vector$_.singleton$(e, $c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]));
}

export function swap$ (
  t: Option,
  e: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Element>*/
): any {
  let old_value, vec_ref;
  if (!is_some$(t, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(EOPTION_NOT_SET);
  }
  vec_ref = t.vec;
  old_value = vector$_.pop_back$(vec_ref, $c, [$p[0]] as TypeTag[]);
  vector$_.push_back$(vec_ref, e, $c, [$p[0]] as TypeTag[]);
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
  if (vector$_.is_empty$(vec_ref, $c, [$p[0]] as TypeTag[])) {
    temp$1 = none$($c, [$p[0]] as TypeTag[]);
  }
  else{
    temp$1 = some$(vector$_.pop_back$(vec_ref, $c, [$p[0]] as TypeTag[]), $c, [$p[0]] as TypeTag[]);
  }
  old_value = temp$1;
  vector$_.push_back$(vec_ref, e, $c, [$p[0]] as TypeTag[]);
  return old_value;
}

export function to_vec$ (
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

