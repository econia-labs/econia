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
export const moduleName = "BitVector";

export const EINDEX : U64 = u64("0");
export const ELENGTH : U64 = u64("1");
export const MAX_SIZE : U64 = u64("1024");
export const WORD_SIZE : U64 = u64("1");


export class BitVector 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BitVector";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "length", typeTag: AtomicTypeTag.U64 },
  { name: "bit_field", typeTag: new VectorTag(AtomicTypeTag.Bool) }];

  length: U64;
  bit_field: boolean[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.length = proto['length'] as U64;
    this.bit_field = proto['bit_field'] as boolean[];
  }

  static BitVectorParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BitVector {
    const proto = $.parseStructProto(data, typeTag, repo, BitVector);
    return new BitVector(proto, typeTag);
  }

}
export function is_index_set$ (
  bitvector: BitVector,
  bit_index: U64,
  $c: AptosDataCache,
): boolean {
  if (!$.copy(bit_index).lt(Vector.length$(bitvector.bit_field, $c, [AtomicTypeTag.Bool] as TypeTag[]))) {
    throw $.abortCode(Errors.invalid_argument$(EINDEX, $c));
  }
  return $.copy(Vector.borrow$(bitvector.bit_field, $.copy(bit_index), $c, [AtomicTypeTag.Bool] as TypeTag[]));
}

export function length$ (
  bitvector: BitVector,
  $c: AptosDataCache,
): U64 {
  return Vector.length$(bitvector.bit_field, $c, [AtomicTypeTag.Bool] as TypeTag[]);
}

export function longest_set_sequence_starting_at$ (
  bitvector: BitVector,
  start_index: U64,
  $c: AptosDataCache,
): U64 {
  let index;
  if (!$.copy(start_index).lt($.copy(bitvector.length))) {
    throw $.abortCode(Errors.invalid_argument$(EINDEX, $c));
  }
  index = $.copy(start_index);
  while ($.copy(index).lt($.copy(bitvector.length))) {
    {
      if (!is_index_set$(bitvector, $.copy(index), $c)) {
        break;
      }
      else{
      }
      index = $.copy(index).add(u64("1"));
    }

  }return $.copy(index).sub($.copy(start_index));
}

export function new__$ (
  length: U64,
  $c: AptosDataCache,
): BitVector {
  let bit_field, counter;
  if (!$.copy(length).gt(u64("0"))) {
    throw $.abortCode(Errors.invalid_argument$(ELENGTH, $c));
  }
  if (!$.copy(length).lt(MAX_SIZE)) {
    throw $.abortCode(Errors.invalid_argument$(ELENGTH, $c));
  }
  counter = u64("0");
  bit_field = Vector.empty$($c, [AtomicTypeTag.Bool] as TypeTag[]);
  while (true) {
    {
      ;
    }
    if (!($.copy(counter).lt($.copy(length)))) break;
    {
      Vector.push_back$(bit_field, false, $c, [AtomicTypeTag.Bool] as TypeTag[]);
      counter = $.copy(counter).add(u64("1"));
    }

  };
  return new BitVector({ length: $.copy(length), bit_field: $.copy(bit_field) }, new StructTag(new HexString("0x1"), "BitVector", "BitVector", []));
}

export function set$ (
  bitvector: BitVector,
  bit_index: U64,
  $c: AptosDataCache,
): void {
  let x;
  if (!$.copy(bit_index).lt(Vector.length$(bitvector.bit_field, $c, [AtomicTypeTag.Bool] as TypeTag[]))) {
    throw $.abortCode(Errors.invalid_argument$(EINDEX, $c));
  }
  x = Vector.borrow_mut$(bitvector.bit_field, $.copy(bit_index), $c, [AtomicTypeTag.Bool] as TypeTag[]);
  $.set(x, true);
  return;
}

export function shift_left$ (
  bitvector: BitVector,
  amount: U64,
  $c: AptosDataCache,
): void {
  let temp$2, temp$3, elem, i, i__1, len;
  if ($.copy(amount).ge($.copy(bitvector.length))) {
    len = Vector.length$(bitvector.bit_field, $c, [AtomicTypeTag.Bool] as TypeTag[]);
    i = u64("0");
    while ($.copy(i).lt($.copy(len))) {
      {
        elem = Vector.borrow_mut$(bitvector.bit_field, $.copy(i), $c, [AtomicTypeTag.Bool] as TypeTag[]);
        $.set(elem, false);
        i = $.copy(i).add(u64("1"));
      }

    }}
  else{
    i__1 = $.copy(amount);
    while ($.copy(i__1).lt($.copy(bitvector.length))) {
      {
        [temp$2, temp$3] = [bitvector, $.copy(i__1)];
        if (is_index_set$(temp$2, temp$3, $c)) {
          set$(bitvector, $.copy(i__1).sub($.copy(amount)), $c);
        }
        else{
          unset$(bitvector, $.copy(i__1).sub($.copy(amount)), $c);
        }
        i__1 = $.copy(i__1).add(u64("1"));
      }

    }i__1 = $.copy(bitvector.length).sub($.copy(amount));
    while ($.copy(i__1).lt($.copy(bitvector.length))) {
      {
        unset$(bitvector, $.copy(i__1), $c);
        i__1 = $.copy(i__1).add(u64("1"));
      }

    }}
  return;
}

export function unset$ (
  bitvector: BitVector,
  bit_index: U64,
  $c: AptosDataCache,
): void {
  let x;
  if (!$.copy(bit_index).lt(Vector.length$(bitvector.bit_field, $c, [AtomicTypeTag.Bool] as TypeTag[]))) {
    throw $.abortCode(Errors.invalid_argument$(EINDEX, $c));
  }
  x = Vector.borrow_mut$(bitvector.bit_field, $.copy(bit_index), $c, [AtomicTypeTag.Bool] as TypeTag[]);
  $.set(x, false);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::BitVector::BitVector", BitVector.BitVectorParser);
}

