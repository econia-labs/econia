import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Errors from "./Errors";
import * as Option from "./Option";
import * as Vector from "./Vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "ASCII";

export const EINVALID_ASCII_CHARACTER : U64 = u64("0");


export class Char 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Char";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "byte", typeTag: AtomicTypeTag.U8 }];

  byte: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.byte = proto['byte'] as U8;
  }

  static CharParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Char {
    const proto = $.parseStructProto(data, typeTag, repo, Char);
    return new Char(proto, typeTag);
  }

}

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
export function all_characters_printable$ (
  string: String,
  $c: AptosDataCache,
): boolean {
  let byte, i, len;
  len = Vector.length$(string.bytes, $c, [AtomicTypeTag.U8] as TypeTag[]);
  i = u64("0");
  while (true) {
    {
      ;
    }
    if (!($.copy(i).lt($.copy(len)))) break;
    {
      byte = $.copy(Vector.borrow$(string.bytes, $.copy(i), $c, [AtomicTypeTag.U8] as TypeTag[]));
      if (!is_printable_char$($.copy(byte), $c)) {
        return false;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  };
  return true;
}

export function as_bytes$ (
  string: String,
  $c: AptosDataCache,
): U8[] {
  return string.bytes;
}

export function byte$ (
  char: Char,
  $c: AptosDataCache,
): U8 {
  let { byte: byte } = $.copy(char);
  return $.copy(byte);
}

export function char$ (
  byte: U8,
  $c: AptosDataCache,
): Char {
  if (!is_valid_char$($.copy(byte), $c)) {
    throw $.abortCode(Errors.invalid_argument$(EINVALID_ASCII_CHARACTER, $c));
  }
  return new Char({ byte: $.copy(byte) }, new StructTag(new HexString("0x1"), "ASCII", "Char", []));
}

export function into_bytes$ (
  string: String,
  $c: AptosDataCache,
): U8[] {
  let { bytes: bytes } = $.copy(string);
  return $.copy(bytes);
}

export function is_printable_char$ (
  byte: U8,
  $c: AptosDataCache,
): boolean {
  let temp$1;
  if ($.copy(byte).ge(u8("32"))) {
    temp$1 = $.copy(byte).le(u8("126"));
  }
  else{
    temp$1 = false;
  }
  return temp$1;
}

export function is_valid_char$ (
  byte: U8,
  $c: AptosDataCache,
): boolean {
  return $.copy(byte).le(u8("127"));
}

export function length$ (
  string: String,
  $c: AptosDataCache,
): U64 {
  return Vector.length$(as_bytes$(string, $c), $c, [AtomicTypeTag.U8] as TypeTag[]);
}

export function pop_char$ (
  string: String,
  $c: AptosDataCache,
): Char {
  return new Char({ byte: Vector.pop_back$(string.bytes, $c, [AtomicTypeTag.U8] as TypeTag[]) }, new StructTag(new HexString("0x1"), "ASCII", "Char", []));
}

export function push_char$ (
  string: String,
  char: Char,
  $c: AptosDataCache,
): void {
  Vector.push_back$(string.bytes, $.copy(char.byte), $c, [AtomicTypeTag.U8] as TypeTag[]);
  return;
}

export function string$ (
  bytes: U8[],
  $c: AptosDataCache,
): String {
  let x;
  x = try_string$($.copy(bytes), $c);
  if (!Option.is_some$(x, $c, [new StructTag(new HexString("0x1"), "ASCII", "String", [])] as TypeTag[])) {
    throw $.abortCode(Errors.invalid_argument$(EINVALID_ASCII_CHARACTER, $c));
  }
  return Option.destroy_some$($.copy(x), $c, [new StructTag(new HexString("0x1"), "ASCII", "String", [])] as TypeTag[]);
}

export function try_string$ (
  bytes: U8[],
  $c: AptosDataCache,
): Option.Option {
  let i, len, possible_byte;
  len = Vector.length$(bytes, $c, [AtomicTypeTag.U8] as TypeTag[]);
  i = u64("0");
  while (true) {
    {
      ;
    }
    if (!($.copy(i).lt($.copy(len)))) break;
    {
      possible_byte = $.copy(Vector.borrow$(bytes, $.copy(i), $c, [AtomicTypeTag.U8] as TypeTag[]));
      if (!is_valid_char$($.copy(possible_byte), $c)) {
        return Option.none$($c, [new StructTag(new HexString("0x1"), "ASCII", "String", [])] as TypeTag[]);
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  };
  return Option.some$(new String({ bytes: $.copy(bytes) }, new StructTag(new HexString("0x1"), "ASCII", "String", [])), $c, [new StructTag(new HexString("0x1"), "ASCII", "String", [])] as TypeTag[]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::ASCII::Char", Char.CharParser);
  repo.addParser("0x1::ASCII::String", String.StringParser);
}

