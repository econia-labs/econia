import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
export const packageName = "Econia";
export const moduleAddress = new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7");
export const moduleName = "critbit";

export const E_BIT_NOT_0_OR_1 : U64 = u64("0");
export const E_BORROW_EMPTY : U64 = u64("3");
export const E_DESTROY_NOT_EMPTY : U64 = u64("1");
export const E_HAS_KEY : U64 = u64("2");
export const E_INSERT_FULL : U64 = u64("5");
export const E_LOOKUP_EMPTY : U64 = u64("7");
export const E_NOT_HAS_KEY : U64 = u64("4");
export const E_POP_EMPTY : U64 = u64("6");
export const HI_128 : U128 = u128("340282366920938463463374607431768211455");
export const HI_64 : U64 = u64("18446744073709551615");
export const INNER : U64 = u64("0");
export const LEFT : boolean = true;
export const MSB_u128 : U8 = u8("127");
export const NODE_TYPE : U8 = u8("63");
export const OUTER : U64 = u64("1");
export const RIGHT : boolean = false;
export const ROOT : U64 = u64("18446744073709551615");


export class CritBitTree 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CritBitTree";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "root", typeTag: AtomicTypeTag.U64 },
  { name: "inner_nodes", typeTag: new VectorTag(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])) },
  { name: "outer_nodes", typeTag: new VectorTag(new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [new $.TypeParamIdx(0)])) }];

  root: U64;
  inner_nodes: InnerNode[];
  outer_nodes: OuterNode[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto['root'] as U64;
    this.inner_nodes = proto['inner_nodes'] as InnerNode[];
    this.outer_nodes = proto['outer_nodes'] as OuterNode[];
  }

  static CritBitTreeParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CritBitTree {
    const proto = $.parseStructProto(data, typeTag, repo, CritBitTree);
    return new CritBitTree(proto, typeTag);
  }

}

export class InnerNode 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "InnerNode";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "critical_bit", typeTag: AtomicTypeTag.U8 },
  { name: "parent_index", typeTag: AtomicTypeTag.U64 },
  { name: "left_child_index", typeTag: AtomicTypeTag.U64 },
  { name: "right_child_index", typeTag: AtomicTypeTag.U64 }];

  critical_bit: U8;
  parent_index: U64;
  left_child_index: U64;
  right_child_index: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.critical_bit = proto['critical_bit'] as U8;
    this.parent_index = proto['parent_index'] as U64;
    this.left_child_index = proto['left_child_index'] as U64;
    this.right_child_index = proto['right_child_index'] as U64;
  }

  static InnerNodeParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : InnerNode {
    const proto = $.parseStructProto(data, typeTag, repo, InnerNode);
    return new InnerNode(proto, typeTag);
  }

}

export class OuterNode 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "OuterNode";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "key", typeTag: AtomicTypeTag.U128 },
  { name: "value", typeTag: new $.TypeParamIdx(0) },
  { name: "parent_index", typeTag: AtomicTypeTag.U64 }];

  key: U128;
  value: any;
  parent_index: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.key = proto['key'] as U128;
    this.value = proto['value'] as any;
    this.parent_index = proto['parent_index'] as U64;
  }

  static OuterNodeParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : OuterNode {
    const proto = $.parseStructProto(data, typeTag, repo, OuterNode);
    return new OuterNode(proto, typeTag);
  }

}
export function borrow_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let closest_outer_node_ref;
  if (!!is_empty_(tree, $c, [$p[0]])) {
    throw $.abortCode(E_BORROW_EMPTY);
  }
  closest_outer_node_ref = borrow_closest_outer_node_(tree, $.copy(key), $c, [$p[0]]);
  if (!($.copy(closest_outer_node_ref.key)).eq(($.copy(key)))) {
    throw $.abortCode(E_NOT_HAS_KEY);
  }
  return closest_outer_node_ref.value;
}

export function borrow_closest_outer_node_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): OuterNode {
  let temp$1, child_index, node;
  if (is_outer_node_($.copy(tree.root), $c)) {
    return Std.Vector.borrow_(tree.outer_nodes, outer_node_vector_index_($.copy(tree.root), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  }
  else{
  }
  node = Std.Vector.borrow_(tree.inner_nodes, $.copy(tree.root), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  while (true) {
    if (is_set_($.copy(key), $.copy(node.critical_bit), $c)) {
      temp$1 = $.copy(node.right_child_index);
    }
    else{
      temp$1 = $.copy(node.left_child_index);
    }
    child_index = temp$1;
    if (is_outer_node_($.copy(child_index), $c)) {
      return Std.Vector.borrow_(tree.outer_nodes, outer_node_vector_index_($.copy(child_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
    }
    else{
    }
    node = Std.Vector.borrow_(tree.inner_nodes, $.copy(child_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  }
}

export function borrow_closest_outer_node_mut_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): OuterNode {
  let temp$1, child_index, node;
  if (is_outer_node_($.copy(tree.root), $c)) {
    return Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(tree.root), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  }
  else{
  }
  node = Std.Vector.borrow_(tree.inner_nodes, $.copy(tree.root), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  while (true) {
    if (is_set_($.copy(key), $.copy(node.critical_bit), $c)) {
      temp$1 = $.copy(node.right_child_index);
    }
    else{
      temp$1 = $.copy(node.left_child_index);
    }
    child_index = temp$1;
    if (is_outer_node_($.copy(child_index), $c)) {
      return Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(child_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
    }
    else{
    }
    node = Std.Vector.borrow_(tree.inner_nodes, $.copy(child_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  }
}

export function borrow_mut_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let closest_outer_node_ref_mut;
  if (!!is_empty_(tree, $c, [$p[0]])) {
    throw $.abortCode(E_BORROW_EMPTY);
  }
  closest_outer_node_ref_mut = borrow_closest_outer_node_mut_(tree, $.copy(key), $c, [$p[0]]);
  if (!($.copy(closest_outer_node_ref_mut.key)).eq(($.copy(key)))) {
    throw $.abortCode(E_NOT_HAS_KEY);
  }
  return closest_outer_node_ref_mut.value;
}

export function check_length_ (
  length: U64,
  $c: AptosDataCache,
): void {
  if (!($.copy(length)).lt((HI_64).xor((OUTER).shl(NODE_TYPE)))) {
    throw $.abortCode(E_INSERT_FULL);
  }
  return;
}

export function crit_bit_ (
  s1: U128,
  s2: U128,
  $c: AptosDataCache,
): U8 {
  let l, m, s, u, x;
  x = ($.copy(s1)).xor($.copy(s2));
  l = u8("0");
  u = MSB_u128;
  while (true) {
    m = (($.copy(l)).add($.copy(u))).div(u8("2"));
    s = ($.copy(x)).shr($.copy(m));
    if (($.copy(s)).eq((u128("1")))) {
      return $.copy(m);
    }
    else{
    }
    if (($.copy(s)).gt(u128("1"))) {
      l = ($.copy(m)).add(u8("1"));
    }
    else{
      u = ($.copy(m)).sub(u8("1"));
    }
  }
}

export function destroy_empty_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  if (!is_empty_(tree, $c, [$p[0]])) {
    throw $.abortCode(E_DESTROY_NOT_EMPTY);
  }
  let { inner_nodes: inner_nodes, outer_nodes: outer_nodes } = tree;
  Std.Vector.destroy_empty_(inner_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  Std.Vector.destroy_empty_(outer_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  return;
}

export function empty_ (
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): CritBitTree {
  return new CritBitTree({ root: u64("0"), inner_nodes: Std.Vector.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]), outer_nodes: Std.Vector.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "CritBitTree", [$p[0]]));
}

export function has_key_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): boolean {
  if (is_empty_(tree, $c, [$p[0]])) {
    return false;
  }
  else{
  }
  return ($.copy(borrow_closest_outer_node_(tree, $.copy(key), $c, [$p[0]]).key)).eq(($.copy(key)));
}

export function insert_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let length;
  length = length_(tree, $c, [$p[0]]);
  check_length_($.copy(length), $c);
  if (($.copy(length)).eq((u64("0")))) {
    insert_empty_(tree, $.copy(key), value, $c, [$p[0]]);
  }
  else{
    if (($.copy(length)).eq((u64("1")))) {
      insert_singleton_(tree, $.copy(key), value, $c, [$p[0]]);
    }
    else{
      insert_general_(tree, $.copy(key), value, $.copy(length), $c, [$p[0]]);
    }
  }
  return;
}

export function insert_above_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  n_outer_nodes: U64,
  n_inner_nodes: U64,
  search_parent_index: U64,
  critical_bit: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let node, node_index;
  node_index = $.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(search_parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).parent_index);
  while (true) {
    if (($.copy(node_index)).eq((ROOT))) {
      return insert_above_root_(tree, $.copy(key), value, $.copy(n_outer_nodes), $.copy(n_inner_nodes), $.copy(critical_bit), $c, [$p[0]]);
    }
    else{
      node = Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(node_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
      if (($.copy(critical_bit)).lt($.copy(node.critical_bit))) {
        return insert_below_walk_(tree, $.copy(key), value, $.copy(n_outer_nodes), $.copy(n_inner_nodes), $.copy(node_index), $.copy(critical_bit), $c, [$p[0]]);
      }
      else{
        node_index = $.copy(node.parent_index);
      }
    }
  }
}

export function insert_above_root_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  n_outer_nodes: U64,
  n_inner_nodes: U64,
  critical_bit: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let old_root_index;
  old_root_index = $.copy(tree.root);
  Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(old_root_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).parent_index = $.copy(n_inner_nodes);
  tree.root = $.copy(n_inner_nodes);
  push_back_insert_nodes_(tree, $.copy(key), value, $.copy(n_inner_nodes), $.copy(critical_bit), ROOT, is_set_($.copy(key), $.copy(critical_bit), $c), $.copy(old_root_index), outer_node_child_index_($.copy(n_outer_nodes), $c), $c, [$p[0]]);
  return;
}

export function insert_below_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  n_outer_nodes: U64,
  n_inner_nodes: U64,
  search_index: U64,
  search_child_side: boolean,
  search_key: U128,
  search_parent_index: U64,
  critical_bit: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let search_parent;
  search_parent = Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(search_parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  if ((search_child_side == LEFT)) {
    search_parent.left_child_index = $.copy(n_inner_nodes);
  }
  else{
    search_parent.right_child_index = $.copy(n_inner_nodes);
  }
  Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(search_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).parent_index = $.copy(n_inner_nodes);
  push_back_insert_nodes_(tree, $.copy(key), value, $.copy(n_inner_nodes), $.copy(critical_bit), $.copy(search_parent_index), ($.copy(key)).lt($.copy(search_key)), outer_node_child_index_($.copy(n_outer_nodes), $c), $.copy(search_index), $c, [$p[0]]);
  return;
}

export function insert_below_walk_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  n_outer_nodes: U64,
  n_inner_nodes: U64,
  review_node_index: U64,
  critical_bit: U8,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, temp$2, review_node, walked_child_index, walked_child_side;
  review_node = Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(review_node_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  if (is_set_($.copy(key), $.copy(review_node.critical_bit), $c)) {
    [temp$1, temp$2] = [RIGHT, $.copy(review_node.right_child_index)];
  }
  else{
    [temp$1, temp$2] = [LEFT, $.copy(review_node.left_child_index)];
  }
  [walked_child_side, walked_child_index] = [temp$1, temp$2];
  if ((walked_child_side == LEFT)) {
    review_node.left_child_index = $.copy(n_inner_nodes);
  }
  else{
    review_node.right_child_index = $.copy(n_inner_nodes);
  }
  Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(walked_child_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).parent_index = $.copy(n_inner_nodes);
  push_back_insert_nodes_(tree, $.copy(key), value, $.copy(n_inner_nodes), $.copy(critical_bit), $.copy(review_node_index), is_set_($.copy(key), $.copy(critical_bit), $c), $.copy(walked_child_index), outer_node_child_index_($.copy(n_outer_nodes), $c), $c, [$p[0]]);
  return;
}

export function insert_empty_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  Std.Vector.push_back_(tree.outer_nodes, new OuterNode({ key: $.copy(key), value: value, parent_index: ROOT }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  tree.root = (OUTER).shl(NODE_TYPE);
  return;
}

export function insert_general_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  n_outer_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, temp$2, critical_bit, n_inner_nodes, search_child_side, search_index, search_key, search_parent_critical_bit, search_parent_index;
  n_inner_nodes = Std.Vector.length_(tree.inner_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  [temp$1, temp$2] = [tree, $.copy(key)];
  [search_index, search_child_side, search_key, search_parent_index, search_parent_critical_bit] = search_outer_(temp$1, temp$2, $c, [$p[0]]);
  if (!($.copy(search_key)).neq($.copy(key))) {
    throw $.abortCode(E_HAS_KEY);
  }
  critical_bit = crit_bit_($.copy(search_key), $.copy(key), $c);
  if (($.copy(critical_bit)).lt($.copy(search_parent_critical_bit))) {
    insert_below_(tree, $.copy(key), value, $.copy(n_outer_nodes), $.copy(n_inner_nodes), $.copy(search_index), search_child_side, $.copy(search_key), $.copy(search_parent_index), $.copy(critical_bit), $c, [$p[0]]);
  }
  else{
    insert_above_(tree, $.copy(key), value, $.copy(n_outer_nodes), $.copy(n_inner_nodes), $.copy(search_parent_index), $.copy(critical_bit), $c, [$p[0]]);
  }
  return;
}

export function insert_singleton_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let critical_bit, outer_node;
  outer_node = Std.Vector.borrow_(tree.outer_nodes, u64("0"), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  if (!($.copy(key)).neq($.copy(outer_node.key))) {
    throw $.abortCode(E_HAS_KEY);
  }
  critical_bit = crit_bit_($.copy(outer_node.key), $.copy(key), $c);
  push_back_insert_nodes_(tree, $.copy(key), value, u64("0"), $.copy(critical_bit), ROOT, ($.copy(key)).gt($.copy(outer_node.key)), outer_node_child_index_(u64("0"), $c), outer_node_child_index_(u64("1"), $c), $c, [$p[0]]);
  tree.root = u64("0");
  Std.Vector.borrow_mut_(tree.outer_nodes, u64("0"), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).parent_index = u64("0");
  return;
}

export function is_empty_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): boolean {
  return Std.Vector.is_empty_(tree.outer_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
}

export function is_outer_node_ (
  child_field_index: U64,
  $c: AptosDataCache,
): boolean {
  return ((($.copy(child_field_index)).shr(NODE_TYPE)).and(OUTER)).eq((OUTER));
}

export function is_set_ (
  key: U128,
  bit_number: U8,
  $c: AptosDataCache,
): boolean {
  return ((($.copy(key)).shr($.copy(bit_number))).and(u128("1"))).eq((u128("1")));
}

export function length_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  return Std.Vector.length_(tree.outer_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
}

export function max_key_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U128 {
  if (!!is_empty_(tree, $c, [$p[0]])) {
    throw $.abortCode(E_LOOKUP_EMPTY);
  }
  return $.copy(Std.Vector.borrow_(tree.outer_nodes, outer_node_vector_index_(max_node_child_index_(tree, $c, [$p[0]]), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).key);
}

export function max_node_child_index_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  let child_field_index;
  child_field_index = $.copy(tree.root);
  while (true) {
    if (is_outer_node_($.copy(child_field_index), $c)) {
      return $.copy(child_field_index);
    }
    else{
    }
    child_field_index = $.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(child_field_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).right_child_index);
  }
}

export function min_key_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U128 {
  if (!!is_empty_(tree, $c, [$p[0]])) {
    throw $.abortCode(E_LOOKUP_EMPTY);
  }
  return $.copy(Std.Vector.borrow_(tree.outer_nodes, outer_node_vector_index_(min_node_child_index_(tree, $c, [$p[0]]), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).key);
}

export function min_node_child_index_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  let child_field_index;
  child_field_index = $.copy(tree.root);
  while (true) {
    if (is_outer_node_($.copy(child_field_index), $c)) {
      return $.copy(child_field_index);
    }
    else{
    }
    child_field_index = $.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(child_field_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).left_child_index);
  }
}

export function outer_node_child_index_ (
  vector_index: U64,
  $c: AptosDataCache,
): U64 {
  return ($.copy(vector_index)).or((OUTER).shl(NODE_TYPE));
}

export function outer_node_vector_index_ (
  child_field_index: U64,
  $c: AptosDataCache,
): U64 {
  return (($.copy(child_field_index)).and(HI_64)).xor((OUTER).shl(NODE_TYPE));
}

export function pop_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let temp$1, length;
  if (!!is_empty_(tree, $c, [$p[0]])) {
    throw $.abortCode(E_POP_EMPTY);
  }
  length = length_(tree, $c, [$p[0]]);
  if (($.copy(length)).eq((u64("1")))) {
    temp$1 = pop_singleton_(tree, $.copy(key), $c, [$p[0]]);
  }
  else{
    temp$1 = pop_general_(tree, $.copy(key), $.copy(length), $c, [$p[0]]);
  }
  return temp$1;
}

export function pop_destroy_nodes_ (
  tree: CritBitTree,
  inner_index: U64,
  outer_index: U64,
  n_outer_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let n_inner_nodes;
  n_inner_nodes = Std.Vector.length_(tree.inner_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  Std.Vector.swap_remove_(tree.inner_nodes, $.copy(inner_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  if (($.copy(inner_index)).lt(($.copy(n_inner_nodes)).sub(u64("1")))) {
    stitch_swap_remove_(tree, $.copy(inner_index), $.copy(n_inner_nodes), $c, [$p[0]]);
  }
  else{
  }
  let { value: value } = Std.Vector.swap_remove_(tree.outer_nodes, outer_node_vector_index_($.copy(outer_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  if ((outer_node_vector_index_($.copy(outer_index), $c)).lt(($.copy(n_outer_nodes)).sub(u64("1")))) {
    stitch_swap_remove_(tree, $.copy(outer_index), $.copy(n_outer_nodes), $c, [$p[0]]);
  }
  else{
  }
  return value;
}

export function pop_general_ (
  tree: CritBitTree,
  key: U128,
  n_outer_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let temp$1, temp$2, search_child_side, search_index, search_key, search_parent_index;
  [temp$1, temp$2] = [tree, $.copy(key)];
  [search_index, search_child_side, search_key, search_parent_index, ] = search_outer_(temp$1, temp$2, $c, [$p[0]]);
  if (!($.copy(search_key)).eq(($.copy(key)))) {
    throw $.abortCode(E_NOT_HAS_KEY);
  }
  pop_update_relationships_(tree, search_child_side, $.copy(search_parent_index), $c, [$p[0]]);
  return pop_destroy_nodes_(tree, $.copy(search_parent_index), $.copy(search_index), $.copy(n_outer_nodes), $c, [$p[0]]);
}

export function pop_singleton_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  if (!($.copy(Std.Vector.borrow_(tree.outer_nodes, u64("0"), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).key)).eq(($.copy(key)))) {
    throw $.abortCode(E_NOT_HAS_KEY);
  }
  tree.root = u64("0");
  let { value: value } = Std.Vector.pop_back_(tree.outer_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  return value;
}

export function pop_update_relationships_ (
  tree: CritBitTree,
  child_side: boolean,
  parent_index: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, grandparent, grandparent_index, parent, sibling_index;
  parent = Std.Vector.borrow_(tree.inner_nodes, $.copy(parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  if ((child_side == LEFT)) {
    temp$1 = $.copy(parent.right_child_index);
  }
  else{
    temp$1 = $.copy(parent.left_child_index);
  }
  sibling_index = temp$1;
  grandparent_index = $.copy(parent.parent_index);
  if (is_outer_node_($.copy(sibling_index), $c)) {
    Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(sibling_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).parent_index = $.copy(grandparent_index);
  }
  else{
    Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(sibling_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).parent_index = $.copy(grandparent_index);
  }
  if (($.copy(grandparent_index)).eq((ROOT))) {
    tree.root = $.copy(sibling_index);
  }
  else{
    grandparent = Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(grandparent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
    if (($.copy(grandparent.left_child_index)).eq(($.copy(parent_index)))) {
      grandparent.left_child_index = $.copy(sibling_index);
    }
    else{
      grandparent.right_child_index = $.copy(sibling_index);
    }
  }
  return;
}

export function push_back_insert_nodes_ (
  tree: CritBitTree,
  key: U128,
  value: any,
  inner_index: U64,
  critical_bit: U8,
  parent_index: U64,
  child_polarity: boolean,
  child_index_1: U64,
  child_index_2: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let temp$1, temp$2, left_child_index, right_child_index;
  if (child_polarity) {
    [temp$1, temp$2] = [$.copy(child_index_1), $.copy(child_index_2)];
  }
  else{
    [temp$1, temp$2] = [$.copy(child_index_2), $.copy(child_index_1)];
  }
  [left_child_index, right_child_index] = [temp$1, temp$2];
  Std.Vector.push_back_(tree.outer_nodes, new OuterNode({ key: $.copy(key), value: value, parent_index: $.copy(inner_index) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  Std.Vector.push_back_(tree.inner_nodes, new InnerNode({ critical_bit: $.copy(critical_bit), parent_index: $.copy(parent_index), left_child_index: $.copy(left_child_index), right_child_index: $.copy(right_child_index) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  return;
}

export function search_outer_ (
  tree: CritBitTree,
  key: U128,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U64, boolean, U128, U64, U8] {
  let temp$1, temp$2, index, node, parent, side;
  parent = Std.Vector.borrow_(tree.inner_nodes, $.copy(tree.root), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  while (true) {
    if (is_set_($.copy(key), $.copy(parent.critical_bit), $c)) {
      [temp$1, temp$2] = [$.copy(parent.right_child_index), RIGHT];
    }
    else{
      [temp$1, temp$2] = [$.copy(parent.left_child_index), LEFT];
    }
    [index, side] = [temp$1, temp$2];
    if (is_outer_node_($.copy(index), $c)) {
      node = Std.Vector.borrow_(tree.outer_nodes, outer_node_vector_index_($.copy(index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
      return [$.copy(index), side, $.copy(node.key), $.copy(node.parent_index), $.copy(parent.critical_bit)];
    }
    else{
    }
    parent = Std.Vector.borrow_(tree.inner_nodes, $.copy(index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  }
}

export function singleton_ (
  key: U128,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): CritBitTree {
  let tree;
  tree = new CritBitTree({ root: u64("0"), inner_nodes: Std.Vector.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]), outer_nodes: Std.Vector.empty_($c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]) }, new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "CritBitTree", [$p[0]]));
  insert_empty_(tree, $.copy(key), value, $c, [$p[0]]);
  return tree;
}

export function stitch_child_of_parent_ (
  tree: CritBitTree,
  new_index: U64,
  parent_index: U64,
  old_index: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let parent;
  parent = Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  if (($.copy(parent.left_child_index)).eq(($.copy(old_index)))) {
    parent.left_child_index = $.copy(new_index);
  }
  else{
    parent.right_child_index = $.copy(new_index);
  }
  return;
}

export function stitch_parent_of_child_ (
  tree: CritBitTree,
  new_index: U64,
  child_index: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  if (is_outer_node_($.copy(child_index), $c)) {
    Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(child_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).parent_index = $.copy(new_index);
  }
  else{
    Std.Vector.borrow_mut_(tree.inner_nodes, $.copy(child_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).parent_index = $.copy(new_index);
  }
  return;
}

export function stitch_swap_remove_ (
  tree: CritBitTree,
  node_index: U64,
  n_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): void {
  let left_child_index, node, parent_index, parent_index__1, right_child_index;
  if (is_outer_node_($.copy(node_index), $c)) {
    parent_index = $.copy(Std.Vector.borrow_(tree.outer_nodes, outer_node_vector_index_($.copy(node_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]).parent_index);
    if (($.copy(parent_index)).eq((ROOT))) {
      tree.root = $.copy(node_index);
      return;
    }
    else{
    }
    stitch_child_of_parent_(tree, $.copy(node_index), $.copy(parent_index), outer_node_child_index_(($.copy(n_nodes)).sub(u64("1")), $c), $c, [$p[0]]);
  }
  else{
    node = Std.Vector.borrow_(tree.inner_nodes, $.copy(node_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
    [parent_index__1, left_child_index, right_child_index] = [$.copy(node.parent_index), $.copy(node.left_child_index), $.copy(node.right_child_index)];
    stitch_parent_of_child_(tree, $.copy(node_index), $.copy(left_child_index), $c, [$p[0]]);
    stitch_parent_of_child_(tree, $.copy(node_index), $.copy(right_child_index), $c, [$p[0]]);
    if (($.copy(parent_index__1)).eq((ROOT))) {
      tree.root = $.copy(node_index);
      return;
    }
    else{
    }
    stitch_child_of_parent_(tree, $.copy(node_index), $.copy(parent_index__1), ($.copy(n_nodes)).sub(u64("1")), $c, [$p[0]]);
  }
  return;
}

export function traverse_end_pop_ (
  tree: CritBitTree,
  parent_index: U64,
  child_index: U64,
  n_outer_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): any {
  let temp$1, node_child_side;
  if (($.copy(n_outer_nodes)).eq((u64("1")))) {
    tree.root = u64("0");
    let { value: value } = Std.Vector.pop_back_(tree.outer_nodes, $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
    temp$1 = value;
  }
  else{
    node_child_side = ($.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).left_child_index)).eq(($.copy(child_index)));
    pop_update_relationships_(tree, node_child_side, $.copy(parent_index), $c, [$p[0]]);
    temp$1 = pop_destroy_nodes_(tree, $.copy(parent_index), $.copy(child_index), $.copy(n_outer_nodes), $c, [$p[0]]);
  }
  return temp$1;
}

export function traverse_init_mut_ (
  tree: CritBitTree,
  direction: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  let temp$1, child_field_index, node;
  if ((direction == LEFT)) {
    temp$1 = max_node_child_index_(tree, $c, [$p[0]]);
  }
  else{
    temp$1 = min_node_child_index_(tree, $c, [$p[0]]);
  }
  child_field_index = temp$1;
  node = Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(child_field_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  return [$.copy(node.key), node.value, $.copy(node.parent_index), $.copy(child_field_index)];
}

export function traverse_mut_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  direction: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  let temp$1, temp$2, temp$3, temp$4, node, target_child_index;
  [temp$1, temp$2, temp$3, temp$4] = [tree, $.copy(key), $.copy(parent_index), direction];
  target_child_index = traverse_target_child_index_(temp$1, temp$2, temp$3, temp$4, $c, [$p[0]]);
  node = Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(target_child_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  return [$.copy(node.key), node.value, $.copy(node.parent_index), $.copy(target_child_index)];
}

export function traverse_pop_mut_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  child_index: U64,
  n_outer_nodes: U64,
  direction: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64, any] {
  let temp$1, temp$2, temp$3, temp$4, start_child_side, start_value, target_child_index, target_node;
  start_child_side = ($.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).left_child_index)).eq(($.copy(child_index)));
  [temp$1, temp$2, temp$3, temp$4] = [tree, $.copy(key), $.copy(parent_index), direction];
  target_child_index = traverse_target_child_index_(temp$1, temp$2, temp$3, temp$4, $c, [$p[0]]);
  pop_update_relationships_(tree, start_child_side, $.copy(parent_index), $c, [$p[0]]);
  start_value = pop_destroy_nodes_(tree, $.copy(parent_index), $.copy(child_index), $.copy(n_outer_nodes), $c, [$p[0]]);
  if ((outer_node_vector_index_($.copy(target_child_index), $c)).eq((($.copy(n_outer_nodes)).sub(u64("1"))))) {
    target_child_index = $.copy(child_index);
  }
  else{
  }
  target_node = Std.Vector.borrow_mut_(tree.outer_nodes, outer_node_vector_index_($.copy(target_child_index), $c), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "OuterNode", [$p[0]])]);
  return [$.copy(target_node.key), target_node.value, $.copy(target_node.parent_index), $.copy(target_child_index), start_value];
}

export function traverse_predecessor_init_mut_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_init_mut_(tree, LEFT, $c, [$p[0]]);
}

export function traverse_predecessor_mut_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_mut_(tree, $.copy(key), $.copy(parent_index), LEFT, $c, [$p[0]]);
}

export function traverse_predecessor_pop_mut_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  child_index: U64,
  n_outer_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64, any] {
  return traverse_pop_mut_(tree, $.copy(key), $.copy(parent_index), $.copy(child_index), $.copy(n_outer_nodes), LEFT, $c, [$p[0]]);
}

export function traverse_successor_init_mut_ (
  tree: CritBitTree,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_init_mut_(tree, RIGHT, $c, [$p[0]]);
}

export function traverse_successor_mut_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64] {
  return traverse_mut_(tree, $.copy(key), $.copy(parent_index), RIGHT, $c, [$p[0]]);
}

export function traverse_successor_pop_mut_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  child_index: U64,
  n_outer_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): [U128, any, U64, U64, any] {
  return traverse_pop_mut_(tree, $.copy(key), $.copy(parent_index), $.copy(child_index), $.copy(n_outer_nodes), RIGHT, $c, [$p[0]]);
}

export function traverse_target_child_index_ (
  tree: CritBitTree,
  key: U128,
  parent_index: U64,
  direction: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <V>*/
): U64 {
  let temp$1, temp$2, child_index, parent;
  parent = Std.Vector.borrow_(tree.inner_nodes, $.copy(parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
  while ((direction != is_set_($.copy(key), $.copy(parent.critical_bit), $c))) {
    {
      parent = Std.Vector.borrow_(tree.inner_nodes, $.copy(parent.parent_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]);
    }

  }if ((direction == LEFT)) {
    temp$1 = $.copy(parent.left_child_index);
  }
  else{
    temp$1 = $.copy(parent.right_child_index);
  }
  child_index = temp$1;
  while (!is_outer_node_($.copy(child_index), $c)) {
    {
      if ((direction == LEFT)) {
        temp$2 = $.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(child_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).right_child_index);
      }
      else{
        temp$2 = $.copy(Std.Vector.borrow_(tree.inner_nodes, $.copy(child_index), $c, [new StructTag(new HexString("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7"), "critbit", "InnerNode", [])]).left_child_index);
      }
      child_index = temp$2;
    }

  }return $.copy(child_index);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::critbit::CritBitTree", CritBitTree.CritBitTreeParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::critbit::InnerNode", InnerNode.InnerNodeParser);
  repo.addParser("0xb1d4c0de8bc24468608637dfdbff975a0888f8935aa63338a44078eec5c7b6c7::critbit::OuterNode", OuterNode.OuterNodeParser);
}

