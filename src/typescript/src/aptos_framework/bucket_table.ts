import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "bucket_table";

export const EALREADY_EXIST : U64 = u64("3");
export const ENOT_EMPTY : U64 = u64("2");
export const ENOT_FOUND : U64 = u64("0");
export const EZERO_CAPACITY : U64 = u64("1");
export const SPLIT_THRESHOLD : U64 = u64("75");
export const TARGET_LOAD_PER_BUCKET : U64 = u64("10");


export class BucketTable 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BucketTable";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "buckets", typeTag: new StructTag(new HexString("0x1"), "table_with_length", "TableWithLength", [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)]))]) },
  { name: "num_buckets", typeTag: AtomicTypeTag.U64 },
  { name: "level", typeTag: AtomicTypeTag.U8 },
  { name: "len", typeTag: AtomicTypeTag.U64 }];

  buckets: Aptos_std.Table_with_length.TableWithLength;
  num_buckets: U64;
  level: U8;
  len: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.buckets = proto['buckets'] as Aptos_std.Table_with_length.TableWithLength;
    this.num_buckets = proto['num_buckets'] as U64;
    this.level = proto['level'] as U8;
    this.len = proto['len'] as U64;
  }

  static BucketTableParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BucketTable {
    const proto = $.parseStructProto(data, typeTag, repo, BucketTable);
    return new BucketTable(proto, typeTag);
  }

}

export class Entry 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Entry";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "hash", typeTag: AtomicTypeTag.U64 },
  { name: "key", typeTag: new $.TypeParamIdx(0) },
  { name: "value", typeTag: new $.TypeParamIdx(1) }];

  hash: U64;
  key: any;
  value: any;

  constructor(proto: any, public typeTag: TypeTag) {
    this.hash = proto['hash'] as U64;
    this.key = proto['key'] as any;
    this.value = proto['value'] as any;
  }

  static EntryParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Entry {
    const proto = $.parseStructProto(data, typeTag, repo, Entry);
    return new Entry(proto, typeTag);
  }

}
export function add_ (
  map: BucketTable,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let temp$1, temp$2, bucket, entry, hash, i, index, len;
  hash = Std.Hash.sip_hash_(key, $c, [$p[0]]);
  index = bucket_index_($.copy(map.level), $.copy(map.num_buckets), $.copy(hash), $c);
  bucket = Aptos_std.Table_with_length.borrow_mut_(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  i = u64("0");
  len = Std.Vector.length_(bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [bucket, $.copy(i)];
      entry = Std.Vector.borrow_(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      if (!$.dyn_neq($p[0], entry.key, key)) {
        throw $.abortCode(Std.Error.invalid_argument_(EALREADY_EXIST, $c));
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }Std.Vector.push_back_(bucket, new Entry({ hash: $.copy(hash), key: key, value: value }, new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])), $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  map.len = ($.copy(map.len)).add(u64("1"));
  if ((load_factor_(map, $c, [$p[0], $p[1]])).gt(SPLIT_THRESHOLD)) {
    split_one_bucket_(map, $c, [$p[0], $p[1]]);
  }
  else{
  }
  return;
}

export function borrow_ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let temp$1, temp$2, bucket, entry, i, index, len;
  index = bucket_index_($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash_(key, $c, [$p[0]]), $c);
  bucket = Aptos_std.Table_with_length.borrow_mut_(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  i = u64("0");
  len = Std.Vector.length_(bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [bucket, $.copy(i)];
      entry = Std.Vector.borrow_(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        return entry.value;
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }throw $.abortCode(Std.Error.invalid_argument_(ENOT_FOUND, $c));
}

export function borrow_mut_ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let bucket, entry, i, index, len;
  index = bucket_index_($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash_(key, $c, [$p[0]]), $c);
  bucket = Aptos_std.Table_with_length.borrow_mut_(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  i = u64("0");
  len = Std.Vector.length_(bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      entry = Std.Vector.borrow_mut_(bucket, $.copy(i), $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        return entry.value;
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }throw $.abortCode(Std.Error.invalid_argument_(ENOT_FOUND, $c));
}

export function bucket_index_ (
  level: U8,
  num_buckets: U64,
  hash: U64,
  $c: AptosDataCache,
): U64 {
  let temp$1, index;
  index = ($.copy(hash)).mod((u64("1")).shl(($.copy(level)).add(u8("1"))));
  if (($.copy(index)).lt($.copy(num_buckets))) {
    temp$1 = $.copy(index);
  }
  else{
    temp$1 = ($.copy(index)).mod((u64("1")).shl($.copy(level)));
  }
  return temp$1;
}

export function contains_ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  let bucket, entry, i, index, len;
  index = bucket_index_($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash_(key, $c, [$p[0]]), $c);
  bucket = Aptos_std.Table_with_length.borrow_(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  i = u64("0");
  len = Std.Vector.length_(bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      entry = Std.Vector.borrow_(bucket, $.copy(i), $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        return true;
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }return false;
}

export function destroy_empty_ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let i;
  if (!($.copy(map.len)).eq((u64("0")))) {
    throw $.abortCode(Std.Error.invalid_argument_(ENOT_EMPTY, $c));
  }
  i = u64("0");
  while (($.copy(i)).lt($.copy(map.num_buckets))) {
    {
      Std.Vector.destroy_empty_(Aptos_std.Table_with_length.remove_(map.buckets, $.copy(i), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]), $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      i = ($.copy(i)).add(u64("1"));
    }

  }let { buckets: buckets } = map;
  Aptos_std.Table_with_length.destroy_empty_(buckets, $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  return;
}

export function length_ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return $.copy(map.len);
}

export function load_factor_ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return (($.copy(map.len)).mul(u64("100"))).div(($.copy(map.num_buckets)).mul(TARGET_LOAD_PER_BUCKET));
}

export function new___ (
  initial_buckets: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): BucketTable {
  let buckets, map;
  if (!($.copy(initial_buckets)).gt(u64("0"))) {
    throw $.abortCode(Std.Error.invalid_argument_(EZERO_CAPACITY, $c));
  }
  buckets = Aptos_std.Table_with_length.new___($c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  Aptos_std.Table_with_length.add_(buckets, u64("0"), Std.Vector.empty_($c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  map = new BucketTable({ buckets: buckets, num_buckets: u64("1"), level: u8("0"), len: u64("0") }, new StructTag(new HexString("0x1"), "bucket_table", "BucketTable", [$p[0], $p[1]]));
  split_(map, ($.copy(initial_buckets)).sub(u64("1")), $c, [$p[0], $p[1]]);
  return map;
}

export function remove_ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let temp$1, temp$2, bucket, entry, i, index, len;
  index = bucket_index_($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash_(key, $c, [$p[0]]), $c);
  bucket = Aptos_std.Table_with_length.borrow_mut_(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  i = u64("0");
  len = Std.Vector.length_(bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  while (($.copy(i)).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [bucket, $.copy(i)];
      entry = Std.Vector.borrow_(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        let { value: value } = Std.Vector.swap_remove_(bucket, $.copy(i), $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
        map.len = ($.copy(map.len)).sub(u64("1"));
        return value;
      }
      else{
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }throw $.abortCode(Std.Error.invalid_argument_(ENOT_FOUND, $c));
}

export function split_ (
  map: BucketTable,
  additional_buckets: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  while (($.copy(additional_buckets)).gt(u64("0"))) {
    {
      additional_buckets = ($.copy(additional_buckets)).sub(u64("1"));
      split_one_bucket_(map, $c, [$p[0], $p[1]]);
    }

  }return;
}

export function split_one_bucket_ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let temp$1, temp$2, entry, entry__3, i, index, j, len, new_bucket, new_bucket_index, old_bucket, to_split;
  new_bucket_index = $.copy(map.num_buckets);
  to_split = xor_($.copy(new_bucket_index), (u64("1")).shl($.copy(map.level)), $c);
  new_bucket = Std.Vector.empty_($c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  map.num_buckets = ($.copy(new_bucket_index)).add(u64("1"));
  if ((($.copy(to_split)).add(u64("1"))).eq(((u64("1")).shl($.copy(map.level))))) {
    map.level = ($.copy(map.level)).add(u8("1"));
  }
  else{
  }
  old_bucket = Aptos_std.Table_with_length.borrow_mut_(map.buckets, $.copy(to_split), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  i = u64("0");
  j = Std.Vector.length_(old_bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
  len = $.copy(j);
  while (($.copy(i)).lt($.copy(j))) {
    {
      [temp$1, temp$2] = [old_bucket, $.copy(i)];
      entry = Std.Vector.borrow_(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      index = bucket_index_($.copy(map.level), $.copy(map.num_buckets), $.copy(entry.hash), $c);
      if (($.copy(index)).eq(($.copy(new_bucket_index)))) {
        j = ($.copy(j)).sub(u64("1"));
        Std.Vector.swap_(old_bucket, $.copy(i), $.copy(j), $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      }
      else{
        i = ($.copy(i)).add(u64("1"));
      }
    }

  }while (($.copy(j)).lt($.copy(len))) {
    {
      entry__3 = Std.Vector.pop_back_(old_bucket, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      Std.Vector.push_back_(new_bucket, entry__3, $c, [new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]])]);
      len = ($.copy(len)).sub(u64("1"));
    }

  }Aptos_std.Table_with_length.add_(map.buckets, $.copy(new_bucket_index), new_bucket, $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "bucket_table", "Entry", [$p[0], $p[1]]))]);
  return;
}

export function xor_ (
  a: U64,
  b: U64,
  $c: AptosDataCache,
): U64 {
  return ($.copy(a)).xor($.copy(b));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::bucket_table::BucketTable", BucketTable.BucketTableParser);
  repo.addParser("0x1::bucket_table::Entry", Entry.EntryParser);
}

