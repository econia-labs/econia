import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as option$_ from "./option";
import * as vector$_ from "./vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "string";

export const EINVALID_INDEX : U64 = u64("2");
export const EINVALID_UTF8 : U64 = u64("1");


export class String 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "String";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto['bytes'] as U8[];
  }

  static StringParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : String {
    const proto = $.parseStructProto(data, typeTag, repo, String);
    return new String(proto, typeTag);
  }
  str(): string { return $.u8str(this.bytes); }

}
export function append$ (
  s: String,
  r: String,
  $c: AptosDataCache,
): void {
  return vector$_.append$(s.bytes, $.copy(r.bytes), $c, [AtomicTypeTag.U8] as TypeTag[]);
}

export function append_utf8$ (
  s: String,
  bytes: U8[],
  $c: AptosDataCache,
): void {
  return append$(s, utf8$($.copy(bytes), $c), $c);
}

export function bytes$ (
  s: String,
  $c: AptosDataCache,
): U8[] {
  return s.bytes;
}

export function index_of$ (
  s: String,
  r: String,
  $c: AptosDataCache,
): U64 {
  return internal_index_of$(s.bytes, r.bytes, $c);
}

export function insert$ (
  s: String,
  at: U64,
  o: String,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, bytes, end, front, l;
  bytes = s.bytes;
  if ($.copy(at).le(vector$_.length$(bytes, $c, [AtomicTypeTag.U8] as TypeTag[]))) {
    temp$1 = internal_is_char_boundary$(bytes, $.copy(at), $c);
  }
  else{
    temp$1 = false;
  }
  if (!temp$1) {
    throw $.abortCode(EINVALID_INDEX);
  }
  l = length$(s, $c);
  [temp$2, temp$3, temp$4] = [s, u64("0"), $.copy(at)];
  front = sub_string$(temp$2, temp$3, temp$4, $c);
  [temp$5, temp$6, temp$7] = [s, $.copy(at), $.copy(l)];
  end = sub_string$(temp$5, temp$6, temp$7, $c);
  append$(front, $.copy(o), $c);
  append$(front, $.copy(end), $c);
  $.set(s, $.copy(front));
  return;
}

export function internal_check_utf8$ (
  v: U8[],
  $c: AptosDataCache,
): boolean {
  return $.std_string_internal_check_utf8(v, $c);

}
export function internal_index_of$ (
  v: U8[],
  r: U8[],
  $c: AptosDataCache,
): U64 {
  return $.std_string_internal_index_of(v, r, $c);

}
export function internal_is_char_boundary$ (
  v: U8[],
  i: U64,
  $c: AptosDataCache,
): boolean {
  return $.std_string_internal_is_char_boundary(v, i, $c);

}
export function internal_sub_string$ (
  v: U8[],
  i: U64,
  j: U64,
  $c: AptosDataCache,
): U8[] {
  return $.std_string_internal_sub_string(v, i, j, $c);

}
export function is_empty$ (
  s: String,
  $c: AptosDataCache,
): boolean {
  return vector$_.is_empty$(s.bytes, $c, [AtomicTypeTag.U8] as TypeTag[]);
}

export function length$ (
  s: String,
  $c: AptosDataCache,
): U64 {
  return vector$_.length$(s.bytes, $c, [AtomicTypeTag.U8] as TypeTag[]);
}

export function sub_string$ (
  s: String,
  i: U64,
  j: U64,
  $c: AptosDataCache,
): String {
  let temp$1, temp$2, temp$3, bytes, l;
  bytes = s.bytes;
  l = vector$_.length$(bytes, $c, [AtomicTypeTag.U8] as TypeTag[]);
  if ($.copy(j).le($.copy(l))) {
    temp$1 = $.copy(i).le($.copy(j));
  }
  else{
    temp$1 = false;
  }
  if (temp$1) {
    temp$2 = internal_is_char_boundary$(bytes, $.copy(i), $c);
  }
  else{
    temp$2 = false;
  }
  if (temp$2) {
    temp$3 = internal_is_char_boundary$(bytes, $.copy(j), $c);
  }
  else{
    temp$3 = false;
  }
  if (!temp$3) {
    throw $.abortCode(EINVALID_INDEX);
  }
  return new String({ bytes: internal_sub_string$(bytes, $.copy(i), $.copy(j), $c) }, new StructTag(new HexString("0x1"), "string", "String", []));
}

export function try_utf8$ (
  bytes: U8[],
  $c: AptosDataCache,
): option$_.Option {
  let temp$1;
  if (internal_check_utf8$(bytes, $c)) {
    temp$1 = option$_.some$(new String({ bytes: $.copy(bytes) }, new StructTag(new HexString("0x1"), "string", "String", [])), $c, [new StructTag(new HexString("0x1"), "string", "String", [])] as TypeTag[]);
  }
  else{
    temp$1 = option$_.none$($c, [new StructTag(new HexString("0x1"), "string", "String", [])] as TypeTag[]);
  }
  return temp$1;
}

export function utf8$ (
  bytes: U8[],
  $c: AptosDataCache,
): String {
  if (!internal_check_utf8$(bytes, $c)) {
    throw $.abortCode(EINVALID_UTF8);
  }
  return new String({ bytes: $.copy(bytes) }, new StructTag(new HexString("0x1"), "string", "String", []));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::string::String", String.StringParser);
}

