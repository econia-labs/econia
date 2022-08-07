import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
import * as Table_with_length from "./table_with_length";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "big_vector";

export const EINDEX_OUT_OF_BOUNDS : U64 = u64("0");
export const ENOT_EMPTY : U64 = u64("2");
export const EOUT_OF_CAPACITY : U64 = u64("1");


export class BigVector 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BigVector";
  static typeParameters: TypeParamDeclType[] = [
    { name: "T", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "buckets", typeTag: new StructTag(new HexString("0x1"), "table_with_length", "TableWithLength", [AtomicTypeTag.U64, new VectorTag(new $.TypeParamIdx(0))]) },
  { name: "end_index", typeTag: new StructTag(new HexString("0x1"), "big_vector", "BigVectorIndex", []) },
  { name: "num_buckets", typeTag: AtomicTypeTag.U64 },
  { name: "bucket_size", typeTag: AtomicTypeTag.U64 }];

  buckets: Table_with_length.TableWithLength;
  end_index: BigVectorIndex;
  num_buckets: U64;
  bucket_size: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.buckets = proto['buckets'] as Table_with_length.TableWithLength;
    this.end_index = proto['end_index'] as BigVectorIndex;
    this.num_buckets = proto['num_buckets'] as U64;
    this.bucket_size = proto['bucket_size'] as U64;
  }

  static BigVectorParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BigVector {
    const proto = $.parseStructProto(data, typeTag, repo, BigVector);
    return new BigVector(proto, typeTag);
  }

}

export class BigVectorIndex 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BigVectorIndex";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "bucket_index", typeTag: AtomicTypeTag.U64 },
  { name: "vec_index", typeTag: AtomicTypeTag.U64 }];

  bucket_index: U64;
  vec_index: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.bucket_index = proto['bucket_index'] as U64;
    this.vec_index = proto['vec_index'] as U64;
  }

  static BigVectorIndexParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BigVectorIndex {
    const proto = $.parseStructProto(data, typeTag, repo, BigVectorIndex);
    return new BigVectorIndex(proto, typeTag);
  }

}
export function borrow_ (
  v: BigVector,
  index: BigVectorIndex,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): any {
  return Std.Vector.borrow_(Table_with_length.borrow_(v.buckets, $.copy(index.bucket_index), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]), $.copy(index.vec_index), $c, [$p[0]]);
}

export function borrow_mut_ (
  v: BigVector,
  index: BigVectorIndex,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): any {
  return Std.Vector.borrow_mut_(Table_with_length.borrow_mut_(v.buckets, $.copy(index.bucket_index), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]), $.copy(index.vec_index), $c, [$p[0]]);
}

export function bucket_index_ (
  v: BigVector,
  i: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): BigVectorIndex {
  if (!($.copy(i)).lt(length_(v, $c, [$p[0]]))) {
    throw $.abortCode(EINDEX_OUT_OF_BOUNDS);
  }
  return new BigVectorIndex({ bucket_index: ($.copy(i)).div($.copy(v.bucket_size)), vec_index: ($.copy(i)).mod($.copy(v.bucket_size)) }, new StructTag(new HexString("0x1"), "big_vector", "BigVectorIndex", []));
}

export function bucket_size_ (
  v: BigVector,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): U64 {
  return $.copy(v.bucket_size);
}

export function buckets_required_ (
  end_index: BigVectorIndex,
  $c: AptosDataCache,
): U64 {
  let temp$1, additional;
  if (($.copy(end_index.vec_index)).eq((u64("0")))) {
    temp$1 = u64("0");
  }
  else{
    temp$1 = u64("1");
  }
  additional = temp$1;
  return ($.copy(end_index.bucket_index)).add($.copy(additional));
}

export function contains_ (
  v: BigVector,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): boolean {
  let exist;
  [exist, ] = index_of_(v, val, $c, [$p[0]]);
  return exist;
}

export function decrement_index_ (
  index: BigVectorIndex,
  bucket_size: U64,
  $c: AptosDataCache,
): void {
  if (($.copy(index.vec_index)).eq((u64("0")))) {
    if (!($.copy(index.bucket_index)).gt(u64("0"))) {
      throw $.abortCode(EINDEX_OUT_OF_BOUNDS);
    }
    index.bucket_index = ($.copy(index.bucket_index)).sub(u64("1"));
    index.vec_index = ($.copy(bucket_size)).sub(u64("1"));
  }
  else{
    index.vec_index = ($.copy(index.vec_index)).sub(u64("1"));
  }
  return;
}

export function destroy_empty_ (
  v: BigVector,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  if (!is_empty_(v, $c, [$p[0]])) {
    throw $.abortCode(Std.Error.invalid_argument_(ENOT_EMPTY, $c));
  }
  shrink_to_fit_(v, $c, [$p[0]]);
  let { buckets: buckets } = v;
  Table_with_length.destroy_empty_(buckets, $c, [AtomicTypeTag.U64, new VectorTag($p[0])]);
  return;
}

export function increment_index_ (
  index: BigVectorIndex,
  bucket_size: U64,
  $c: AptosDataCache,
): void {
  if ((($.copy(index.vec_index)).add(u64("1"))).eq(($.copy(bucket_size)))) {
    index.bucket_index = ($.copy(index.bucket_index)).add(u64("1"));
    index.vec_index = u64("0");
  }
  else{
    index.vec_index = ($.copy(index.vec_index)).add(u64("1"));
  }
  return;
}

export function index_of_ (
  v: BigVector,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): [boolean, U64] {
  let i, index, len;
  i = u64("0");
  len = length_(v, $c, [$p[0]]);
  index = bucket_index_(v, u64("0"), $c, [$p[0]]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      if ($.dyn_eq($p[0], borrow_(v, index, $c, [$p[0]]), val)) {
        return [true, $.copy(i)];
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
      increment_index_(index, $.copy(v.bucket_size), $c);
    }

  }return [false, u64("0")];
}

export function is_empty_ (
  v: BigVector,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): boolean {
  return (length_(v, $c, [$p[0]])).eq((u64("0")));
}

export function length_ (
  v: BigVector,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): U64 {
  return (($.copy(v.end_index.bucket_index)).mul($.copy(v.bucket_size))).add($.copy(v.end_index.vec_index));
}

export function new___ (
  bucket_size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): BigVector {
  if (!($.copy(bucket_size)).gt(u64("0"))) {
    throw $.abortCode(u64("0"));
  }
  return new BigVector({ buckets: Table_with_length.new___($c, [AtomicTypeTag.U64, new VectorTag($p[0])]), end_index: new BigVectorIndex({ bucket_index: u64("0"), vec_index: u64("0") }, new StructTag(new HexString("0x1"), "big_vector", "BigVectorIndex", [])), num_buckets: u64("0"), bucket_size: $.copy(bucket_size) }, new StructTag(new HexString("0x1"), "big_vector", "BigVector", [$p[0]]));
}

export function new_with_capacity_ (
  bucket_size: U64,
  num_buckets: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): BigVector {
  let v;
  v = new___($.copy(bucket_size), $c, [$p[0]]);
  reserve_(v, $.copy(num_buckets), $c, [$p[0]]);
  return v;
}

export function pop_back_ (
  v: BigVector,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): any {
  let val;
  if (!!is_empty_(v, $c, [$p[0]])) {
    throw $.abortCode(Std.Error.invalid_argument_(EINDEX_OUT_OF_BOUNDS, $c));
  }
  decrement_index_(v.end_index, $.copy(v.bucket_size), $c);
  val = Std.Vector.pop_back_(Table_with_length.borrow_mut_(v.buckets, $.copy(v.end_index.bucket_index), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]), $c, [$p[0]]);
  return val;
}

export function push_back_ (
  v: BigVector,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  if (($.copy(v.end_index.bucket_index)).eq(($.copy(v.num_buckets)))) {
    Table_with_length.add_(v.buckets, $.copy(v.num_buckets), Std.Vector.empty_($c, [$p[0]]), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]);
    v.num_buckets = ($.copy(v.num_buckets)).add(u64("1"));
  }
  else{
  }
  Std.Vector.push_back_(Table_with_length.borrow_mut_(v.buckets, $.copy(v.end_index.bucket_index), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]), val, $c, [$p[0]]);
  increment_index_(v.end_index, $.copy(v.bucket_size), $c);
  return;
}

export function push_back_no_grow_ (
  v: BigVector,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  if (!($.copy(v.end_index.bucket_index)).lt($.copy(v.num_buckets))) {
    throw $.abortCode(Std.Error.invalid_argument_(EOUT_OF_CAPACITY, $c));
  }
  Std.Vector.push_back_(Table_with_length.borrow_mut_(v.buckets, $.copy(v.end_index.bucket_index), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]), val, $c, [$p[0]]);
  increment_index_(v.end_index, $.copy(v.bucket_size), $c);
  return;
}

export function reserve_ (
  v: BigVector,
  additional_buckets: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  while (($.copy(additional_buckets)).gt(u64("0"))) {
    {
      Table_with_length.add_(v.buckets, $.copy(v.num_buckets), Std.Vector.empty_($c, [$p[0]]), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]);
      v.num_buckets = ($.copy(v.num_buckets)).add(u64("1"));
      additional_buckets = ($.copy(additional_buckets)).sub(u64("1"));
    }

  }return;
}

export function shrink_to_fit_ (
  v: BigVector,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): void {
  let v__1;
  while (($.copy(v.num_buckets)).gt(buckets_required_(v.end_index, $c))) {
    {
      v.num_buckets = ($.copy(v.num_buckets)).sub(u64("1"));
      v__1 = Table_with_length.remove_(v.buckets, $.copy(v.num_buckets), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]);
      Std.Vector.destroy_empty_(v__1, $c, [$p[0]]);
    }

  }return;
}

export function swap_remove_ (
  v: BigVector,
  index: BigVectorIndex,
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): any {
  let temp$1, bucket, bucket_len, last_val, val;
  last_val = pop_back_(v, $c, [$p[0]]);
  if (($.copy(v.end_index.bucket_index)).eq(($.copy(index.bucket_index)))) {
    temp$1 = ($.copy(v.end_index.vec_index)).eq(($.copy(index.vec_index)));
  }
  else{
    temp$1 = false;
  }
  if (temp$1) {
    return last_val;
  }
  else{
  }
  bucket = Table_with_length.borrow_mut_(v.buckets, $.copy(index.bucket_index), $c, [AtomicTypeTag.U64, new VectorTag($p[0])]);
  bucket_len = Std.Vector.length_(bucket, $c, [$p[0]]);
  val = Std.Vector.swap_remove_(bucket, $.copy(index.vec_index), $c, [$p[0]]);
  Std.Vector.push_back_(bucket, last_val, $c, [$p[0]]);
  Std.Vector.swap_(bucket, $.copy(index.vec_index), ($.copy(bucket_len)).sub(u64("1")), $c, [$p[0]]);
  return val;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::big_vector::BigVector", BigVector.BigVectorParser);
  repo.addParser("0x1::big_vector::BigVectorIndex", BigVectorIndex.BigVectorIndexParser);
}

