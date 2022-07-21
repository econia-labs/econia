import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Table from "./Table";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "BucketTable";

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
  { name: "buckets", typeTag: new StructTag(new HexString("0x1"), "Table", "Table", [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [new $.TypeParamIdx(0), new $.TypeParamIdx(1)]))]) },
  { name: "num_buckets", typeTag: AtomicTypeTag.U64 },
  { name: "level", typeTag: AtomicTypeTag.U8 },
  { name: "len", typeTag: AtomicTypeTag.U64 }];

  buckets: Table.Table;
  num_buckets: U64;
  level: U8;
  len: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.buckets = proto['buckets'] as Table.Table;
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
export function add$ (
  map: BucketTable,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let temp$1, temp$2, bucket, entry, hash, i, index, len;
  hash = Std.Hash.sip_hash$(key, $c, [$p[0]] as TypeTag[]);
  index = bucket_index$($.copy(map.level), $.copy(map.num_buckets), $.copy(hash), $c);
  bucket = Table.borrow_mut$(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  i = u64("0");
  len = Std.Vector.length$(bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [bucket, $.copy(i)];
      entry = Std.Vector.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      if (!$.dyn_neq($p[0], entry.key, key)) {
        throw $.abortCode(Std.Errors.invalid_argument$(EALREADY_EXIST, $c));
      }
      i = $.copy(i).add(u64("1"));
    }

  }Std.Vector.push_back$(bucket, new Entry({ hash: $.copy(hash), key: key, value: value }, new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])), $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  map.len = $.copy(map.len).add(u64("1"));
  if (load_factor$(map, $c, [$p[0], $p[1]] as TypeTag[]).gt(SPLIT_THRESHOLD)) {
    split_one_bucket$(map, $c, [$p[0], $p[1]] as TypeTag[]);
  }
  else{
  }
  return;
}

export function borrow$ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let temp$1, temp$2, bucket, entry, i, index, len;
  index = bucket_index$($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash$(key, $c, [$p[0]] as TypeTag[]), $c);
  bucket = Table.borrow_mut$(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  i = u64("0");
  len = Std.Vector.length$(bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [bucket, $.copy(i)];
      entry = Std.Vector.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        return entry.value;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }throw $.abortCode(Std.Errors.invalid_argument$(ENOT_FOUND, $c));
}

export function borrow_mut$ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let bucket, entry, i, index, len;
  index = bucket_index$($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash$(key, $c, [$p[0]] as TypeTag[]), $c);
  bucket = Table.borrow_mut$(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  i = u64("0");
  len = Std.Vector.length$(bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      entry = Std.Vector.borrow_mut$(bucket, $.copy(i), $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        return entry.value;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }throw $.abortCode(Std.Errors.invalid_argument$(ENOT_FOUND, $c));
}

export function bucket_index$ (
  level: U8,
  num_buckets: U64,
  hash: U64,
  $c: AptosDataCache,
): U64 {
  let temp$1, index;
  index = $.copy(hash).mod(u64("1").shl($.copy(level).add(u8("1"))));
  if ($.copy(index).lt($.copy(num_buckets))) {
    temp$1 = $.copy(index);
  }
  else{
    temp$1 = $.copy(index).mod(u64("1").shl($.copy(level)));
  }
  return temp$1;
}

export function contains$ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): boolean {
  let bucket, entry, i, index, len;
  index = bucket_index$($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash$(key, $c, [$p[0]] as TypeTag[]), $c);
  bucket = Table.borrow$(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  i = u64("0");
  len = Std.Vector.length$(bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      entry = Std.Vector.borrow$(bucket, $.copy(i), $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        return true;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }return false;
}

export function destroy_empty$ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let i;
  if (!$.copy(map.len).eq(u64("0"))) {
    throw $.abortCode(Std.Errors.invalid_argument$(ENOT_EMPTY, $c));
  }
  i = u64("0");
  while ($.copy(i).lt($.copy(map.num_buckets))) {
    {
      Std.Vector.destroy_empty$(Table.remove$(map.buckets, $.copy(i), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]), $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      i = $.copy(i).add(u64("1"));
    }

  }let { buckets: buckets } = map;
  Table.destroy_empty$(buckets, $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  return;
}

export function length$ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return $.copy(map.len);
}

export function load_factor$ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): U64 {
  return $.copy(map.len).mul(u64("100")).div($.copy(map.num_buckets).mul(TARGET_LOAD_PER_BUCKET));
}

export function new__$ (
  initial_buckets: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): BucketTable {
  let buckets, map;
  if (!$.copy(initial_buckets).gt(u64("0"))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EZERO_CAPACITY, $c));
  }
  buckets = Table.new__$($c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  Table.add$(buckets, u64("0"), Std.Vector.empty$($c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  map = new BucketTable({ buckets: buckets, num_buckets: u64("1"), level: u8("0"), len: u64("0") }, new StructTag(new HexString("0x1"), "BucketTable", "BucketTable", [$p[0], $p[1]]));
  split$(map, $.copy(initial_buckets).sub(u64("1")), $c, [$p[0], $p[1]] as TypeTag[]);
  return map;
}

export function remove$ (
  map: BucketTable,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): any {
  let temp$1, temp$2, bucket, entry, i, index, len;
  index = bucket_index$($.copy(map.level), $.copy(map.num_buckets), Std.Hash.sip_hash$(key, $c, [$p[0]] as TypeTag[]), $c);
  bucket = Table.borrow_mut$(map.buckets, $.copy(index), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  i = u64("0");
  len = Std.Vector.length$(bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  while ($.copy(i).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [bucket, $.copy(i)];
      entry = Std.Vector.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      if ($.dyn_eq($p[0], entry.key, key)) {
        let { value: value } = Std.Vector.swap_remove$(bucket, $.copy(i), $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
        map.len = $.copy(map.len).sub(u64("1"));
        return value;
      }
      else{
      }
      i = $.copy(i).add(u64("1"));
    }

  }throw $.abortCode(Std.Errors.invalid_argument$(ENOT_FOUND, $c));
}

export function split$ (
  map: BucketTable,
  additional_buckets: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  while ($.copy(additional_buckets).gt(u64("0"))) {
    {
      additional_buckets = $.copy(additional_buckets).sub(u64("1"));
      split_one_bucket$(map, $c, [$p[0], $p[1]] as TypeTag[]);
    }

  }return;
}

export function split_one_bucket$ (
  map: BucketTable,
  $c: AptosDataCache,
  $p: TypeTag[], /* <K, V>*/
): void {
  let temp$1, temp$2, entry, entry__3, i, index, j, len, new_bucket, new_bucket_index, old_bucket, to_split;
  new_bucket_index = $.copy(map.num_buckets);
  to_split = $.copy(new_bucket_index).xor(u64("1").shl($.copy(map.level)));
  new_bucket = Std.Vector.empty$($c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  map.num_buckets = $.copy(new_bucket_index).add(u64("1"));
  if ($.copy(to_split).add(u64("1")).eq(u64("1").shl($.copy(map.level)))) {
    map.level = $.copy(map.level).add(u8("1"));
  }
  else{
  }
  old_bucket = Table.borrow_mut$(map.buckets, $.copy(to_split), $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  i = u64("0");
  j = Std.Vector.length$(old_bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
  len = $.copy(j);
  while ($.copy(i).lt($.copy(j))) {
    {
      [temp$1, temp$2] = [old_bucket, $.copy(i)];
      entry = Std.Vector.borrow$(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      index = bucket_index$($.copy(map.level), $.copy(map.num_buckets), $.copy(entry.hash), $c);
      if ($.copy(index).eq($.copy(new_bucket_index))) {
        j = $.copy(j).sub(u64("1"));
        Std.Vector.swap$(old_bucket, $.copy(i), $.copy(j), $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      }
      else{
        i = $.copy(i).add(u64("1"));
      }
    }

  }while ($.copy(j).lt($.copy(len))) {
    {
      entry__3 = Std.Vector.pop_back$(old_bucket, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      Std.Vector.push_back$(new_bucket, entry__3, $c, [new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]])] as TypeTag[]);
      len = $.copy(len).sub(u64("1"));
    }

  }Table.add$(map.buckets, $.copy(new_bucket_index), new_bucket, $c, [AtomicTypeTag.U64, new VectorTag(new StructTag(new HexString("0x1"), "BucketTable", "Entry", [$p[0], $p[1]]))] as TypeTag[]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::BucketTable::BucketTable", BucketTable.BucketTableParser);
  repo.addParser("0x1::BucketTable::Entry", Entry.EntryParser);
}

