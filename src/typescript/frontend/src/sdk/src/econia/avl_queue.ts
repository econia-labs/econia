import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, type U128 } from "@manahippo/move-to-ts";
import { u8, u64, u128 } from "@manahippo/move-to-ts";
import {
  type FieldDeclType,
  type TypeParamDeclType,
} from "@manahippo/move-to-ts";
import {
  AtomicTypeTag,
  SimpleStructTag,
  StructTag,
  type TypeTag,
  VectorTag,
} from "@manahippo/move-to-ts";
import { OptionTransaction } from "@manahippo/move-to-ts";
import {
  AptosAccount,
  type AptosClient,
  HexString,
  TxnBuilderTypes,
  Types,
} from "aptos";

import * as Stdlib from "../stdlib";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "avl_queue";

export const ASCENDING = true;
export const BITS_PER_BYTE: U8 = u8("8");
export const BIT_FLAG_ASCENDING: U8 = u8("1");
export const BIT_FLAG_TREE_NODE: U8 = u8("1");
export const DECREMENT = false;
export const DESCENDING = false;
export const E_EVICT_EMPTY: U64 = u64("3");
export const E_EVICT_NEW_TAIL: U64 = u64("4");
export const E_INSERTION_KEY_TOO_LARGE: U64 = u64("2");
export const E_INVALID_HEIGHT: U64 = u64("5");
export const E_TOO_MANY_LIST_NODES: U64 = u64("1");
export const E_TOO_MANY_TREE_NODES: U64 = u64("0");
export const HI_128: U128 = u128("340282366920938463463374607431768211455");
export const HI_64: U64 = u64("18446744073709551615");
export const HI_BIT: U8 = u8("1");
export const HI_BYTE: U64 = u64("255");
export const HI_HEIGHT: U8 = u8("31");
export const HI_INSERTION_KEY: U64 = u64("4294967295");
export const HI_NODE_ID: U64 = u64("16383");
export const INCREMENT = true;
export const LEFT = true;
export const MAX_HEIGHT: U8 = u8("18");
export const NIL: U8 = u8("0");
export const N_NODES_MAX: U64 = u64("16383");
export const PREDECESSOR = true;
export const RIGHT = false;
export const SHIFT_ACCESS_LIST_NODE_ID: U8 = u8("33");
export const SHIFT_ACCESS_SORT_ORDER: U8 = u8("32");
export const SHIFT_ACCESS_TREE_NODE_ID: U8 = u8("47");
export const SHIFT_CHILD_LEFT: U8 = u8("56");
export const SHIFT_CHILD_RIGHT: U8 = u8("42");
export const SHIFT_HEAD_KEY: U8 = u8("52");
export const SHIFT_HEAD_NODE_ID: U8 = u8("84");
export const SHIFT_HEIGHT_LEFT: U8 = u8("89");
export const SHIFT_HEIGHT_RIGHT: U8 = u8("84");
export const SHIFT_INSERTION_KEY: U8 = u8("94");
export const SHIFT_LIST_HEAD: U8 = u8("28");
export const SHIFT_LIST_STACK_TOP: U8 = u8("98");
export const SHIFT_LIST_TAIL: U8 = u8("14");
export const SHIFT_NODE_TYPE: U8 = u8("14");
export const SHIFT_PARENT: U8 = u8("70");
export const SHIFT_SORT_ORDER: U8 = u8("126");
export const SHIFT_TAIL_KEY: U8 = u8("6");
export const SHIFT_TAIL_NODE_ID: U8 = u8("38");
export const SHIFT_TREE_STACK_TOP: U8 = u8("112");
export const SUCCESSOR = false;

export class AVLqueue {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AVLqueue";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    { name: "bits", typeTag: AtomicTypeTag.U128 },
    { name: "root_lsbs", typeTag: AtomicTypeTag.U8 },
    {
      name: "tree_nodes",
      typeTag: new StructTag(
        new HexString("0x1"),
        "table_with_length",
        "TableWithLength",
        [
          AtomicTypeTag.U64,
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "avl_queue",
            "TreeNode",
            []
          ),
        ]
      ),
    },
    {
      name: "list_nodes",
      typeTag: new StructTag(
        new HexString("0x1"),
        "table_with_length",
        "TableWithLength",
        [
          AtomicTypeTag.U64,
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "avl_queue",
            "ListNode",
            []
          ),
        ]
      ),
    },
    {
      name: "values",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        AtomicTypeTag.U64,
        new StructTag(new HexString("0x1"), "option", "Option", [
          new $.TypeParamIdx(0),
        ]),
      ]),
    },
  ];

  bits: U128;
  root_lsbs: U8;
  tree_nodes: Stdlib.Table_with_length.TableWithLength;
  list_nodes: Stdlib.Table_with_length.TableWithLength;
  values: Stdlib.Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.bits = proto["bits"] as U128;
    this.root_lsbs = proto["root_lsbs"] as U8;
    this.tree_nodes = proto[
      "tree_nodes"
    ] as Stdlib.Table_with_length.TableWithLength;
    this.list_nodes = proto[
      "list_nodes"
    ] as Stdlib.Table_with_length.TableWithLength;
    this.values = proto["values"] as Stdlib.Table.Table;
  }

  static AVLqueueParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AVLqueue {
    const proto = $.parseStructProto(data, typeTag, repo, AVLqueue);
    return new AVLqueue(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "AVLqueue", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.tree_nodes.loadFullState(app);
    await this.list_nodes.loadFullState(app);
    await this.values.loadFullState(app);
    this.__app = app;
  }
}

export class ListNode {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ListNode";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "last_msbs", typeTag: AtomicTypeTag.U8 },
    { name: "last_lsbs", typeTag: AtomicTypeTag.U8 },
    { name: "next_msbs", typeTag: AtomicTypeTag.U8 },
    { name: "next_lsbs", typeTag: AtomicTypeTag.U8 },
  ];

  last_msbs: U8;
  last_lsbs: U8;
  next_msbs: U8;
  next_lsbs: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.last_msbs = proto["last_msbs"] as U8;
    this.last_lsbs = proto["last_lsbs"] as U8;
    this.next_msbs = proto["next_msbs"] as U8;
    this.next_lsbs = proto["next_lsbs"] as U8;
  }

  static ListNodeParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ListNode {
    const proto = $.parseStructProto(data, typeTag, repo, ListNode);
    return new ListNode(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ListNode", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class TreeNode {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "TreeNode";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bits", typeTag: AtomicTypeTag.U128 },
  ];

  bits: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.bits = proto["bits"] as U128;
  }

  static TreeNodeParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): TreeNode {
    const proto = $.parseStructProto(data, typeTag, repo, TreeNode);
    return new TreeNode(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "TreeNode", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function borrow_(
  avlq_ref: AVLqueue,
  access_key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let list_node_id;
  list_node_id = $.copy(access_key)
    .shr($.copy(SHIFT_ACCESS_LIST_NODE_ID))
    .and($.copy(HI_NODE_ID));
  return Stdlib.Option.borrow_(
    Stdlib.Table.borrow_(avlq_ref.values, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
}

export function borrow_head_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let list_node_id;
  list_node_id = u64(
    $.copy(avlq_ref.bits)
      .shr($.copy(SHIFT_HEAD_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  return Stdlib.Option.borrow_(
    Stdlib.Table.borrow_(avlq_ref.values, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
}

export function borrow_head_mut_(
  avlq_ref_mut: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let list_node_id;
  list_node_id = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_HEAD_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  return Stdlib.Option.borrow_mut_(
    Stdlib.Table.borrow_mut_(avlq_ref_mut.values, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
}

export function borrow_mut_(
  avlq_ref_mut: AVLqueue,
  access_key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let list_node_id;
  list_node_id = $.copy(access_key)
    .shr($.copy(SHIFT_ACCESS_LIST_NODE_ID))
    .and($.copy(HI_NODE_ID));
  return Stdlib.Option.borrow_mut_(
    Stdlib.Table.borrow_mut_(avlq_ref_mut.values, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
}

export function borrow_tail_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let list_node_id;
  list_node_id = u64(
    $.copy(avlq_ref.bits)
      .shr($.copy(SHIFT_TAIL_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  return Stdlib.Option.borrow_(
    Stdlib.Table.borrow_(avlq_ref.values, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
}

export function borrow_tail_mut_(
  avlq_ref_mut: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let list_node_id;
  list_node_id = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_TAIL_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  return Stdlib.Option.borrow_mut_(
    Stdlib.Table.borrow_mut_(avlq_ref_mut.values, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
}

export function get_access_key_insertion_key_(
  access_key: U64,
  $c: AptosDataCache
): U64 {
  return $.copy(access_key).and($.copy(HI_INSERTION_KEY));
}

export function get_head_key_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): Stdlib.Option.Option {
  let temp$1, avlq_head_insertion_key, avlq_head_node_id, bits;
  bits = $.copy(avlq_ref.bits);
  [avlq_head_node_id, avlq_head_insertion_key] = [
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_HEAD_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_HEAD_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
  ];
  if ($.copy(avlq_head_node_id).eq(u64($.copy(NIL)))) {
    temp$1 = Stdlib.Option.none_($c, [AtomicTypeTag.U64]);
  } else {
    temp$1 = Stdlib.Option.some_($.copy(avlq_head_insertion_key), $c, [
      AtomicTypeTag.U64,
    ]);
  }
  return temp$1;
}

export function get_height_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): Stdlib.Option.Option {
  let temp$1, bits, height, height_left, height_right, msbs, root, root_ref;
  msbs = $.copy(avlq_ref.bits).and(
    u128($.copy(HI_NODE_ID)).shr($.copy(BITS_PER_BYTE))
  );
  root = u64($.copy(msbs).shl($.copy(BITS_PER_BYTE))).or(
    u64($.copy(avlq_ref.root_lsbs))
  );
  if ($.copy(root).eq(u64($.copy(NIL)))) {
    return Stdlib.Option.none_($c, [AtomicTypeTag.U8]);
  } else {
  }
  root_ref = Stdlib.Table_with_length.borrow_(
    avlq_ref.tree_nodes,
    $.copy(root),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  bits = $.copy(root_ref.bits);
  [height_left, height_right] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
  ];
  if ($.copy(height_left).ge($.copy(height_right))) {
    temp$1 = $.copy(height_left);
  } else {
    temp$1 = $.copy(height_right);
  }
  height = temp$1;
  return Stdlib.Option.some_($.copy(height), $c, [AtomicTypeTag.U8]);
}

export function get_tail_key_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): Stdlib.Option.Option {
  let temp$1, avlq_tail_insertion_key, avlq_tail_node_id, bits;
  bits = $.copy(avlq_ref.bits);
  [avlq_tail_node_id, avlq_tail_insertion_key] = [
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
  ];
  if ($.copy(avlq_tail_node_id).eq(u64($.copy(NIL)))) {
    temp$1 = Stdlib.Option.none_($c, [AtomicTypeTag.U64]);
  } else {
    temp$1 = Stdlib.Option.some_($.copy(avlq_tail_insertion_key), $c, [
      AtomicTypeTag.U64,
    ]);
  }
  return temp$1;
}

export function has_key_(
  avlq_ref: AVLqueue,
  key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): boolean {
  let temp$1, temp$2, nil_if_empty, none_if_found_or_empty;
  if (!$.copy(key).le($.copy(HI_INSERTION_KEY))) {
    throw $.abortCode($.copy(E_INSERTION_KEY_TOO_LARGE));
  }
  [nil_if_empty, none_if_found_or_empty] = search_(avlq_ref, $.copy(key), $c, [
    $p[0],
  ]);
  if ($.copy(nil_if_empty).neq(u64($.copy(NIL)))) {
    temp$1 = Stdlib.Option.is_none_(none_if_found_or_empty, $c, [
      AtomicTypeTag.Bool,
    ]);
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    temp$2 = true;
  } else {
    temp$2 = false;
  }
  return temp$2;
}

export function insert_(
  avlq_ref_mut: AVLqueue,
  key: U64,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): U64 {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    anchor_tree_node_id,
    list_node_id,
    match_node_id,
    new_leaf_side,
    order_bit,
    solo,
    tree_node_id;
  if (!$.copy(key).le($.copy(HI_INSERTION_KEY))) {
    throw $.abortCode($.copy(E_INSERTION_KEY_TOO_LARGE));
  }
  [temp$1, temp$2] = [avlq_ref_mut, $.copy(key)];
  [match_node_id, new_leaf_side] = search_(temp$1, temp$2, $c, [$p[0]]);
  if ($.copy(match_node_id).eq(u64($.copy(NIL)))) {
    temp$3 = true;
  } else {
    temp$3 = Stdlib.Option.is_some_(new_leaf_side, $c, [AtomicTypeTag.Bool]);
  }
  solo = temp$3;
  if (solo) {
    temp$4 = u64($.copy(NIL));
  } else {
    temp$4 = $.copy(match_node_id);
  }
  anchor_tree_node_id = temp$4;
  list_node_id = insert_list_node_(
    avlq_ref_mut,
    $.copy(anchor_tree_node_id),
    value,
    $c,
    [$p[0]]
  );
  if (solo) {
    temp$5 = insert_tree_node_(
      avlq_ref_mut,
      $.copy(key),
      $.copy(match_node_id),
      $.copy(list_node_id),
      $.copy(new_leaf_side),
      $c,
      [$p[0]]
    );
  } else {
    temp$5 = $.copy(match_node_id);
  }
  tree_node_id = temp$5;
  if (solo) {
    temp$6 = $.copy(match_node_id).neq(u64($.copy(NIL)));
  } else {
    temp$6 = false;
  }
  if (temp$6) {
    retrace_(
      avlq_ref_mut,
      $.copy(match_node_id),
      $.copy(INCREMENT),
      $.copy(Stdlib.Option.borrow_(new_leaf_side, $c, [AtomicTypeTag.Bool])),
      $c,
      [$p[0]]
    );
  } else {
  }
  insert_check_head_tail_(avlq_ref_mut, $.copy(key), $.copy(list_node_id), $c, [
    $p[0],
  ]);
  order_bit = $.copy(avlq_ref_mut.bits)
    .shr($.copy(SHIFT_SORT_ORDER))
    .and(u128($.copy(HI_BIT)));
  return $.copy(key)
    .or(u64($.copy(order_bit)).shl($.copy(SHIFT_ACCESS_SORT_ORDER)))
    .or($.copy(list_node_id).shl($.copy(SHIFT_ACCESS_LIST_NODE_ID)))
    .or($.copy(tree_node_id).shl($.copy(SHIFT_ACCESS_TREE_NODE_ID)));
}

export function insert_check_eviction_(
  avlq_ref_mut: AVLqueue,
  key: U64,
  value: any,
  critical_height: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U64, Stdlib.Option.Option] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    ascending,
    bits,
    height,
    height_left,
    height_right,
    list_top,
    max_list_nodes_active,
    n_list_nodes,
    next,
    order_bit,
    r_bits,
    root,
    root_msbs,
    root_ref,
    tail_access_key,
    tail_key,
    tail_list_node_id,
    tail_list_node_ref,
    tail_tree_node_id,
    tail_value,
    too_tall;
  if (!$.copy(critical_height).le($.copy(MAX_HEIGHT))) {
    throw $.abortCode($.copy(E_INVALID_HEIGHT));
  }
  bits = $.copy(avlq_ref_mut.bits);
  tail_list_node_id = u64(
    $.copy(bits)
      .shr($.copy(SHIFT_TAIL_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  if ($.copy(tail_list_node_id).eq(u64($.copy(NIL)))) {
    return [
      insert_(avlq_ref_mut, $.copy(key), value, $c, [$p[0]]),
      u64($.copy(NIL)),
      Stdlib.Option.none_($c, [$p[0]]),
    ];
  } else {
  }
  [list_top, root_msbs] = [
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_LIST_STACK_TOP))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    $.copy(bits).and(u128($.copy(HI_NODE_ID)).shr($.copy(BITS_PER_BYTE))),
  ];
  root = u64($.copy(root_msbs).shl($.copy(BITS_PER_BYTE))).or(
    u64($.copy(avlq_ref_mut.root_lsbs))
  );
  root_ref = Stdlib.Table_with_length.borrow_(
    avlq_ref_mut.tree_nodes,
    $.copy(root),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  r_bits = $.copy(root_ref.bits);
  [height_left, height_right] = [
    u8(
      $.copy(r_bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(r_bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
  ];
  if ($.copy(height_left).ge($.copy(height_right))) {
    temp$1 = $.copy(height_left);
  } else {
    temp$1 = $.copy(height_right);
  }
  height = temp$1;
  too_tall = $.copy(height).gt($.copy(critical_height));
  n_list_nodes = Stdlib.Table_with_length.length_(avlq_ref_mut.list_nodes, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(ListNode),
  ]);
  if ($.copy(n_list_nodes).eq($.copy(N_NODES_MAX))) {
    temp$2 = $.copy(list_top).eq(u64($.copy(NIL)));
  } else {
    temp$2 = false;
  }
  max_list_nodes_active = temp$2;
  if (too_tall || max_list_nodes_active) {
    order_bit = u8(
      $.copy(bits)
        .shr($.copy(SHIFT_SORT_ORDER))
        .and(u128($.copy(HI_BIT)))
    );
    ascending = $.copy(order_bit).eq($.copy(BIT_FLAG_ASCENDING));
    tail_key = u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    );
    if (ascending) {
      temp$3 = $.copy(key).ge($.copy(tail_key));
    } else {
      temp$3 = false;
    }
    if (temp$3) {
      temp$5 = true;
    } else {
      if (!ascending) {
        temp$4 = $.copy(key).le($.copy(tail_key));
      } else {
        temp$4 = false;
      }
      temp$5 = temp$4;
    }
    if (temp$5) {
      return [
        u64($.copy(NIL)),
        u64($.copy(NIL)),
        Stdlib.Option.some_(value, $c, [$p[0]]),
      ];
    } else {
    }
    tail_list_node_ref = Stdlib.Table_with_length.borrow_(
      avlq_ref_mut.list_nodes,
      $.copy(tail_list_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
    );
    next = u64($.copy(tail_list_node_ref.next_msbs))
      .shl($.copy(BITS_PER_BYTE))
      .or(u64($.copy(tail_list_node_ref.next_lsbs)));
    tail_tree_node_id = $.copy(next).and(u64($.copy(HI_NODE_ID)));
    tail_access_key = $.copy(tail_key)
      .or(u64($.copy(order_bit)).shl($.copy(SHIFT_ACCESS_SORT_ORDER)))
      .or($.copy(tail_list_node_id).shl($.copy(SHIFT_ACCESS_LIST_NODE_ID)))
      .or($.copy(tail_tree_node_id).shl($.copy(SHIFT_ACCESS_TREE_NODE_ID)));
    tail_value = Stdlib.Option.some_(
      remove_(avlq_ref_mut, $.copy(tail_access_key), $c, [$p[0]]),
      $c,
      [$p[0]]
    );
  } else {
    [tail_access_key, tail_value] = [
      u64($.copy(NIL)),
      Stdlib.Option.none_($c, [$p[0]]),
    ];
  }
  return [
    insert_(avlq_ref_mut, $.copy(key), value, $c, [$p[0]]),
    $.copy(tail_access_key),
    tail_value,
  ];
}

export function insert_check_head_tail_(
  avlq_ref_mut: AVLqueue,
  key: U64,
  list_node_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    ascending,
    bits,
    head_key,
    head_node_id,
    order_bit,
    reassign_head,
    reassign_tail,
    tail_key,
    tail_node_id;
  bits = $.copy(avlq_ref_mut.bits);
  [order_bit, head_node_id, head_key, tail_node_id, tail_key] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_SORT_ORDER))
        .and(u128($.copy(HI_BIT)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_HEAD_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_HEAD_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
  ];
  ascending = $.copy(order_bit).eq($.copy(BIT_FLAG_ASCENDING));
  reassign_head = false;
  if ($.copy(head_node_id).eq(u64($.copy(NIL)))) {
    reassign_head = true;
  } else {
    if (ascending) {
      temp$1 = $.copy(key).lt($.copy(head_key));
    } else {
      temp$1 = false;
    }
    if (temp$1) {
      temp$3 = true;
    } else {
      if (!ascending) {
        temp$2 = $.copy(key).gt($.copy(head_key));
      } else {
        temp$2 = false;
      }
      temp$3 = temp$2;
    }
    if (temp$3) {
      reassign_head = true;
    } else {
    }
  }
  if (reassign_head) {
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID))
            .shl($.copy(SHIFT_HEAD_NODE_ID))
            .or(u128($.copy(HI_INSERTION_KEY)).shl($.copy(SHIFT_HEAD_KEY)))
        )
      )
      .or(u128($.copy(list_node_id)).shl($.copy(SHIFT_HEAD_NODE_ID)))
      .or(u128($.copy(key)).shl($.copy(SHIFT_HEAD_KEY)));
  } else {
  }
  reassign_tail = false;
  if ($.copy(tail_node_id).eq(u64($.copy(NIL)))) {
    reassign_tail = true;
  } else {
    if (ascending) {
      temp$4 = $.copy(key).ge($.copy(tail_key));
    } else {
      temp$4 = false;
    }
    if (temp$4) {
      temp$6 = true;
    } else {
      if (!ascending) {
        temp$5 = $.copy(key).le($.copy(tail_key));
      } else {
        temp$5 = false;
      }
      temp$6 = temp$5;
    }
    if (temp$6) {
      reassign_tail = true;
    } else {
    }
  }
  if (reassign_tail) {
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID))
            .shl($.copy(SHIFT_TAIL_NODE_ID))
            .or(u128($.copy(HI_INSERTION_KEY)).shl($.copy(SHIFT_TAIL_KEY)))
        )
      )
      .or(u128($.copy(list_node_id)).shl($.copy(SHIFT_TAIL_NODE_ID)))
      .or(u128($.copy(key)).shl($.copy(SHIFT_TAIL_KEY)));
  } else {
  }
  return;
}

export function insert_evict_tail_(
  avlq_ref_mut: AVLqueue,
  key: U64,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U64, any] {
  let temp$1,
    temp$2,
    temp$3,
    ascending,
    bits,
    new_access_key,
    next,
    order_bit,
    tail_access_key,
    tail_key,
    tail_list_node_id,
    tail_list_node_ref,
    tail_tree_node_id,
    tail_value;
  bits = $.copy(avlq_ref_mut.bits);
  [order_bit, tail_list_node_id, tail_key] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_SORT_ORDER))
        .and(u128($.copy(HI_BIT)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
  ];
  if (!$.copy(tail_list_node_id).neq(u64($.copy(NIL)))) {
    throw $.abortCode($.copy(E_EVICT_EMPTY));
  }
  ascending = $.copy(order_bit).eq($.copy(BIT_FLAG_ASCENDING));
  if (ascending) {
    temp$1 = $.copy(key).lt($.copy(tail_key));
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    temp$3 = true;
  } else {
    if (!ascending) {
      temp$2 = $.copy(key).gt($.copy(tail_key));
    } else {
      temp$2 = false;
    }
    temp$3 = temp$2;
  }
  if (!temp$3) {
    throw $.abortCode($.copy(E_EVICT_NEW_TAIL));
  }
  tail_list_node_ref = Stdlib.Table_with_length.borrow_(
    avlq_ref_mut.list_nodes,
    $.copy(tail_list_node_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
  );
  next = u64($.copy(tail_list_node_ref.next_msbs))
    .shl($.copy(BITS_PER_BYTE))
    .or(u64($.copy(tail_list_node_ref.next_lsbs)));
  tail_tree_node_id = $.copy(next).and(u64($.copy(HI_NODE_ID)));
  tail_access_key = $.copy(tail_key)
    .or(u64($.copy(order_bit)).shl($.copy(SHIFT_ACCESS_SORT_ORDER)))
    .or($.copy(tail_list_node_id).shl($.copy(SHIFT_ACCESS_LIST_NODE_ID)))
    .or($.copy(tail_tree_node_id).shl($.copy(SHIFT_ACCESS_TREE_NODE_ID)));
  new_access_key = insert_(avlq_ref_mut, $.copy(key), value, $c, [$p[0]]);
  tail_value = remove_(avlq_ref_mut, $.copy(tail_access_key), $c, [$p[0]]);
  return [$.copy(new_access_key), $.copy(tail_access_key), tail_value];
}

export function insert_list_node_(
  avlq_ref_mut: AVLqueue,
  anchor_tree_node_id: U64,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): U64 {
  let temp$1,
    temp$2,
    anchor_node_ref_mut,
    last,
    last_node_ref_mut,
    list_node_id,
    list_nodes_ref_mut,
    next,
    tree_nodes_ref_mut;
  [temp$1, temp$2] = [avlq_ref_mut, $.copy(anchor_tree_node_id)];
  [last, next] = insert_list_node_get_last_next_(temp$1, temp$2, $c, [$p[0]]);
  list_node_id = insert_list_node_assign_fields_(
    avlq_ref_mut,
    $.copy(last),
    $.copy(next),
    value,
    $c,
    [$p[0]]
  );
  if ($.copy(anchor_tree_node_id).neq(u64($.copy(NIL)))) {
    tree_nodes_ref_mut = avlq_ref_mut.tree_nodes;
    list_nodes_ref_mut = avlq_ref_mut.list_nodes;
    last_node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      list_nodes_ref_mut,
      $.copy(last),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
    );
    last_node_ref_mut.next_msbs = u8(
      $.copy(list_node_id).shr($.copy(BITS_PER_BYTE))
    );
    last_node_ref_mut.next_lsbs = u8($.copy(list_node_id).and($.copy(HI_BYTE)));
    anchor_node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      tree_nodes_ref_mut,
      $.copy(anchor_tree_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    anchor_node_ref_mut.bits = $.copy(anchor_node_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_LIST_TAIL))
        )
      )
      .or(u128($.copy(list_node_id)).shl($.copy(SHIFT_LIST_TAIL)));
  } else {
  }
  return $.copy(list_node_id);
}

export function insert_list_node_assign_fields_(
  avlq_ref_mut: AVLqueue,
  last: U64,
  next: U64,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): U64 {
  let last_lsbs,
    last_msbs,
    list_node_id,
    list_nodes_ref_mut,
    new_list_stack_top,
    next_lsbs,
    next_msbs,
    node_ref_mut,
    value_option_ref_mut,
    values_ref_mut;
  list_nodes_ref_mut = avlq_ref_mut.list_nodes;
  values_ref_mut = avlq_ref_mut.values;
  [last_msbs, last_lsbs, next_msbs, next_lsbs] = [
    u8($.copy(last).shr($.copy(BITS_PER_BYTE))),
    u8($.copy(last).and($.copy(HI_BYTE))),
    u8($.copy(next).shr($.copy(BITS_PER_BYTE))),
    u8($.copy(next).and($.copy(HI_BYTE))),
  ];
  list_node_id = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_LIST_STACK_TOP))
      .and(u128($.copy(HI_NODE_ID)))
  );
  if ($.copy(list_node_id).eq(u64($.copy(NIL)))) {
    list_node_id = Stdlib.Table_with_length.length_(list_nodes_ref_mut, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(ListNode),
    ]).add(u64("1"));
    if (!$.copy(list_node_id).le($.copy(N_NODES_MAX))) {
      throw $.abortCode($.copy(E_TOO_MANY_LIST_NODES));
    }
    Stdlib.Table_with_length.add_(
      list_nodes_ref_mut,
      $.copy(list_node_id),
      new ListNode(
        {
          last_msbs: $.copy(last_msbs),
          last_lsbs: $.copy(last_lsbs),
          next_msbs: $.copy(next_msbs),
          next_lsbs: $.copy(next_lsbs),
        },
        new SimpleStructTag(ListNode)
      ),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
    );
    Stdlib.Table.add_(
      values_ref_mut,
      $.copy(list_node_id),
      Stdlib.Option.some_(value, $c, [$p[0]]),
      $c,
      [
        AtomicTypeTag.U64,
        new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
      ]
    );
  } else {
    node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      list_nodes_ref_mut,
      $.copy(list_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
    );
    new_list_stack_top = u128($.copy(node_ref_mut.next_msbs))
      .shl($.copy(BITS_PER_BYTE))
      .or(u128($.copy(node_ref_mut.next_lsbs)));
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_LIST_STACK_TOP))
        )
      )
      .or($.copy(new_list_stack_top).shl($.copy(SHIFT_LIST_STACK_TOP)));
    node_ref_mut.last_msbs = $.copy(last_msbs);
    node_ref_mut.last_lsbs = $.copy(last_lsbs);
    node_ref_mut.next_msbs = $.copy(next_msbs);
    node_ref_mut.next_lsbs = $.copy(next_lsbs);
    value_option_ref_mut = Stdlib.Table.borrow_mut_(
      values_ref_mut,
      $.copy(list_node_id),
      $c,
      [
        AtomicTypeTag.U64,
        new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
      ]
    );
    Stdlib.Option.fill_(value_option_ref_mut, value, $c, [$p[0]]);
  }
  return $.copy(list_node_id);
}

export function insert_list_node_get_last_next_(
  avlq_ref: AVLqueue,
  anchor_tree_node_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U64] {
  let anchor_node_ref, is_tree_node, last, tree_nodes_ref;
  is_tree_node = u64($.copy(BIT_FLAG_TREE_NODE)).shl($.copy(SHIFT_NODE_TYPE));
  tree_nodes_ref = avlq_ref.tree_nodes;
  if ($.copy(anchor_tree_node_id).eq(u64($.copy(NIL)))) {
    anchor_tree_node_id = u64(
      $.copy(avlq_ref.bits)
        .shr($.copy(SHIFT_TREE_STACK_TOP))
        .and(u128($.copy(HI_NODE_ID)))
    );
    if ($.copy(anchor_tree_node_id).eq(u64($.copy(NIL)))) {
      anchor_tree_node_id = Stdlib.Table_with_length.length_(
        tree_nodes_ref,
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
      ).add(u64("1"));
    } else {
    }
    last = $.copy(anchor_tree_node_id).or($.copy(is_tree_node));
  } else {
    anchor_node_ref = Stdlib.Table_with_length.borrow_(
      tree_nodes_ref,
      $.copy(anchor_tree_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    last = u64(
      $.copy(anchor_node_ref.bits)
        .shr($.copy(SHIFT_LIST_TAIL))
        .and(u128($.copy(HI_NODE_ID)))
    );
  }
  return [$.copy(last), $.copy(anchor_tree_node_id).or($.copy(is_tree_node))];
}

export function insert_tree_node_(
  avlq_ref_mut: AVLqueue,
  key: U64,
  parent: U64,
  solo_node_id: U64,
  new_leaf_side: Stdlib.Option.Option,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): U64 {
  let bits, new_tree_stack_top, node_ref_mut, tree_node_id, tree_nodes_ref_mut;
  bits = u128($.copy(key))
    .shl($.copy(SHIFT_INSERTION_KEY))
    .or(u128($.copy(parent)).shl($.copy(SHIFT_PARENT)))
    .or(u128($.copy(solo_node_id)).shl($.copy(SHIFT_LIST_HEAD)))
    .or(u128($.copy(solo_node_id)).shl($.copy(SHIFT_LIST_TAIL)));
  tree_node_id = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_TREE_STACK_TOP))
      .and(u128($.copy(HI_NODE_ID)))
  );
  tree_nodes_ref_mut = avlq_ref_mut.tree_nodes;
  if ($.copy(tree_node_id).eq(u64($.copy(NIL)))) {
    tree_node_id = Stdlib.Table_with_length.length_(tree_nodes_ref_mut, $c, [
      AtomicTypeTag.U64,
      new SimpleStructTag(TreeNode),
    ]).add(u64("1"));
    Stdlib.Table_with_length.add_(
      tree_nodes_ref_mut,
      $.copy(tree_node_id),
      new TreeNode({ bits: $.copy(bits) }, new SimpleStructTag(TreeNode)),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
  } else {
    node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      tree_nodes_ref_mut,
      $.copy(tree_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    new_tree_stack_top = $.copy(node_ref_mut.bits).and(
      u128($.copy(HI_NODE_ID))
    );
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_TREE_STACK_TOP))
        )
      )
      .or($.copy(new_tree_stack_top).shl($.copy(SHIFT_TREE_STACK_TOP)));
    node_ref_mut.bits = $.copy(bits);
  }
  insert_tree_node_update_parent_edge_(
    avlq_ref_mut,
    $.copy(tree_node_id),
    $.copy(parent),
    $.copy(new_leaf_side),
    $c,
    [$p[0]]
  );
  return $.copy(tree_node_id);
}

export function insert_tree_node_update_parent_edge_(
  avlq_ref_mut: AVLqueue,
  tree_node_id: U64,
  parent: U64,
  new_leaf_side: Stdlib.Option.Option,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1, child_shift, left_child, parent_ref_mut, tree_nodes_ref_mut;
  if (Stdlib.Option.is_none_(new_leaf_side, $c, [AtomicTypeTag.Bool])) {
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID).shr($.copy(BITS_PER_BYTE))))
      )
      .or(u128($.copy(tree_node_id)).shr($.copy(BITS_PER_BYTE)));
    avlq_ref_mut.root_lsbs = u8($.copy(tree_node_id).and($.copy(HI_BYTE)));
  } else {
    tree_nodes_ref_mut = avlq_ref_mut.tree_nodes;
    parent_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      tree_nodes_ref_mut,
      $.copy(parent),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    left_child =
      $.copy(Stdlib.Option.borrow_(new_leaf_side, $c, [AtomicTypeTag.Bool])) ==
      $.copy(LEFT);
    if (left_child) {
      temp$1 = $.copy(SHIFT_CHILD_LEFT);
    } else {
      temp$1 = $.copy(SHIFT_CHILD_RIGHT);
    }
    child_shift = temp$1;
    parent_ref_mut.bits = $.copy(parent_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(child_shift)))
      )
      .or(u128($.copy(tree_node_id)).shl($.copy(child_shift)));
  }
  return;
}

export function is_ascending_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): boolean {
  return $.copy(avlq_ref.bits)
    .shr($.copy(SHIFT_SORT_ORDER))
    .and(u128($.copy(BIT_FLAG_ASCENDING)))
    .eq(u128($.copy(BIT_FLAG_ASCENDING)));
}

export function is_ascending_access_key_(
  access_key: U64,
  $c: AptosDataCache
): boolean {
  return u8(
    $.copy(access_key)
      .shr($.copy(SHIFT_ACCESS_SORT_ORDER))
      .and(u64($.copy(HI_BIT)))
  ).eq($.copy(BIT_FLAG_ASCENDING));
}

export function is_empty_(
  avlq_ref: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): boolean {
  return $.copy(avlq_ref.bits)
    .shr($.copy(SHIFT_HEAD_NODE_ID))
    .and(u128($.copy(HI_NODE_ID)))
    .eq(u128($.copy(NIL)));
}

export function new___(
  sort_order: boolean,
  n_inactive_tree_nodes: U64,
  n_inactive_list_nodes: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): AVLqueue {
  let temp$1, avlq, bits, i, i__2;
  if (!$.copy(n_inactive_tree_nodes).le($.copy(N_NODES_MAX))) {
    throw $.abortCode($.copy(E_TOO_MANY_TREE_NODES));
  }
  if (!$.copy(n_inactive_list_nodes).le($.copy(N_NODES_MAX))) {
    throw $.abortCode($.copy(E_TOO_MANY_LIST_NODES));
  }
  if (sort_order == $.copy(DESCENDING)) {
    temp$1 = u128($.copy(NIL));
  } else {
    temp$1 = u128($.copy(BIT_FLAG_ASCENDING)).shl($.copy(SHIFT_SORT_ORDER));
  }
  bits = temp$1;
  bits = $.copy(bits)
    .or(u128($.copy(n_inactive_tree_nodes)).shl($.copy(SHIFT_TREE_STACK_TOP)))
    .or(u128($.copy(n_inactive_list_nodes)).shl($.copy(SHIFT_LIST_STACK_TOP)));
  avlq = new AVLqueue(
    {
      bits: $.copy(bits),
      root_lsbs: $.copy(NIL),
      tree_nodes: Stdlib.Table_with_length.new___($c, [
        AtomicTypeTag.U64,
        new SimpleStructTag(TreeNode),
      ]),
      list_nodes: Stdlib.Table_with_length.new___($c, [
        AtomicTypeTag.U64,
        new SimpleStructTag(ListNode),
      ]),
      values: Stdlib.Table.new___($c, [
        AtomicTypeTag.U64,
        new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
      ]),
    },
    new SimpleStructTag(AVLqueue, [$p[0]])
  );
  if ($.copy(n_inactive_tree_nodes).gt(u64("0"))) {
    i = u64("0");
    while ($.copy(i).lt($.copy(n_inactive_tree_nodes))) {
      {
        Stdlib.Table_with_length.add_(
          avlq.tree_nodes,
          $.copy(i).add(u64("1")),
          new TreeNode(
            { bits: u128($.copy(i)) },
            new SimpleStructTag(TreeNode)
          ),
          $c,
          [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
        );
        i = $.copy(i).add(u64("1"));
      }
    }
  } else {
  }
  if ($.copy(n_inactive_list_nodes).gt(u64("0"))) {
    i__2 = u64("0");
    while ($.copy(i__2).lt($.copy(n_inactive_list_nodes))) {
      {
        Stdlib.Table_with_length.add_(
          avlq.list_nodes,
          $.copy(i__2).add(u64("1")),
          new ListNode(
            {
              last_msbs: u8("0"),
              last_lsbs: u8("0"),
              next_msbs: u8($.copy(i__2).shr($.copy(BITS_PER_BYTE))),
              next_lsbs: u8($.copy(i__2).and($.copy(HI_BYTE))),
            },
            new SimpleStructTag(ListNode)
          ),
          $c,
          [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
        );
        Stdlib.Table.add_(
          avlq.values,
          $.copy(i__2).add(u64("1")),
          Stdlib.Option.none_($c, [$p[0]]),
          $c,
          [
            AtomicTypeTag.U64,
            new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
          ]
        );
        i__2 = $.copy(i__2).add(u64("1"));
      }
    }
  } else {
  }
  return avlq;
}

export function pop_head_(
  avlq_ref_mut: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let temp$1,
    temp$2,
    access_key,
    last,
    list_node_id,
    list_node_ref,
    tree_node_id;
  list_node_id = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_HEAD_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  [temp$1, temp$2] = [avlq_ref_mut.list_nodes, $.copy(list_node_id)];
  list_node_ref = Stdlib.Table_with_length.borrow_(temp$1, temp$2, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(ListNode),
  ]);
  last = u64($.copy(list_node_ref.last_msbs))
    .shl($.copy(BITS_PER_BYTE))
    .or(u64($.copy(list_node_ref.last_lsbs)));
  tree_node_id = $.copy(last).and(u64($.copy(HI_NODE_ID)));
  access_key = $.copy(list_node_id)
    .shl($.copy(SHIFT_ACCESS_LIST_NODE_ID))
    .or($.copy(tree_node_id).shl($.copy(SHIFT_ACCESS_TREE_NODE_ID)));
  return remove_(avlq_ref_mut, $.copy(access_key), $c, [$p[0]]);
}

export function pop_tail_(
  avlq_ref_mut: AVLqueue,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let temp$1,
    temp$2,
    access_key,
    list_node_id,
    list_node_ref,
    next,
    tree_node_id;
  list_node_id = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_TAIL_NODE_ID))
      .and(u128($.copy(HI_NODE_ID)))
  );
  [temp$1, temp$2] = [avlq_ref_mut.list_nodes, $.copy(list_node_id)];
  list_node_ref = Stdlib.Table_with_length.borrow_(temp$1, temp$2, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(ListNode),
  ]);
  next = u64($.copy(list_node_ref.next_msbs))
    .shl($.copy(BITS_PER_BYTE))
    .or(u64($.copy(list_node_ref.next_lsbs)));
  tree_node_id = $.copy(next).and(u64($.copy(HI_NODE_ID)));
  access_key = $.copy(list_node_id)
    .shl($.copy(SHIFT_ACCESS_LIST_NODE_ID))
    .or($.copy(tree_node_id).shl($.copy(SHIFT_ACCESS_TREE_NODE_ID)));
  return remove_(avlq_ref_mut, $.copy(access_key), $c, [$p[0]]);
}

export function remove_(
  avlq_ref_mut: AVLqueue,
  access_key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): any {
  let ascending,
    avlq_head_modified,
    avlq_head_node_id,
    avlq_tail_modified,
    avlq_tail_node_id,
    bits,
    list_head_modified,
    list_node_id,
    list_tail_modified,
    new_list_head_option,
    new_list_tail_option,
    order_bit,
    tree_node_id,
    value;
  list_node_id = $.copy(access_key)
    .shr($.copy(SHIFT_ACCESS_LIST_NODE_ID))
    .and($.copy(HI_NODE_ID));
  [value, new_list_head_option, new_list_tail_option] = remove_list_node_(
    avlq_ref_mut,
    $.copy(list_node_id),
    $c,
    [$p[0]]
  );
  list_head_modified = Stdlib.Option.is_some_(new_list_head_option, $c, [
    AtomicTypeTag.U64,
  ]);
  list_tail_modified = Stdlib.Option.is_some_(new_list_tail_option, $c, [
    AtomicTypeTag.U64,
  ]);
  if (list_head_modified || list_tail_modified) {
    bits = $.copy(avlq_ref_mut.bits);
    [avlq_head_node_id, avlq_tail_node_id, order_bit] = [
      u64(
        $.copy(bits)
          .shr($.copy(SHIFT_HEAD_NODE_ID))
          .and(u128($.copy(HI_NODE_ID)))
      ),
      u64(
        $.copy(bits)
          .shr($.copy(SHIFT_TAIL_NODE_ID))
          .and(u128($.copy(HI_NODE_ID)))
      ),
      u8(
        $.copy(bits)
          .shr($.copy(SHIFT_SORT_ORDER))
          .and(u128($.copy(HI_BIT)))
      ),
    ];
    [avlq_head_modified, avlq_tail_modified] = [
      $.copy(avlq_head_node_id).eq($.copy(list_node_id)),
      $.copy(avlq_tail_node_id).eq($.copy(list_node_id)),
    ];
    ascending = $.copy(order_bit).eq($.copy(BIT_FLAG_ASCENDING));
    tree_node_id = $.copy(access_key)
      .shr($.copy(SHIFT_ACCESS_TREE_NODE_ID))
      .and($.copy(HI_NODE_ID));
    if (avlq_head_modified) {
      remove_update_head_(
        avlq_ref_mut,
        $.copy(
          Stdlib.Option.borrow_(new_list_head_option, $c, [AtomicTypeTag.U64])
        ),
        ascending,
        $.copy(tree_node_id),
        $c,
        [$p[0]]
      );
    } else {
    }
    if (avlq_tail_modified) {
      remove_update_tail_(
        avlq_ref_mut,
        $.copy(
          Stdlib.Option.borrow_(new_list_tail_option, $c, [AtomicTypeTag.U64])
        ),
        ascending,
        $.copy(tree_node_id),
        $c,
        [$p[0]]
      );
    } else {
    }
    if (list_head_modified && list_tail_modified) {
      remove_tree_node_(avlq_ref_mut, $.copy(tree_node_id), $c, [$p[0]]);
    } else {
    }
  } else {
  }
  return value;
}

export function remove_list_node_(
  avlq_ref_mut: AVLqueue,
  list_node_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [any, Stdlib.Option.Option, Stdlib.Option.Option] {
  let last,
    last_is_tree,
    last_node_id,
    list_node_ref_mut,
    list_nodes_ref_mut,
    list_top,
    new_head,
    new_tail,
    next,
    next_is_tree,
    next_node_id,
    value,
    values_ref_mut;
  list_nodes_ref_mut = avlq_ref_mut.list_nodes;
  list_node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    list_nodes_ref_mut,
    $.copy(list_node_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
  );
  last = u64($.copy(list_node_ref_mut.last_msbs))
    .shl($.copy(BITS_PER_BYTE))
    .or(u64($.copy(list_node_ref_mut.last_lsbs)));
  next = u64($.copy(list_node_ref_mut.next_msbs))
    .shl($.copy(BITS_PER_BYTE))
    .or(u64($.copy(list_node_ref_mut.next_lsbs)));
  last_is_tree = $.copy(last)
    .shr($.copy(SHIFT_NODE_TYPE))
    .and(u64($.copy(BIT_FLAG_TREE_NODE)))
    .eq(u64($.copy(BIT_FLAG_TREE_NODE)));
  next_is_tree = $.copy(next)
    .shr($.copy(SHIFT_NODE_TYPE))
    .and(u64($.copy(BIT_FLAG_TREE_NODE)))
    .eq(u64($.copy(BIT_FLAG_TREE_NODE)));
  last_node_id = $.copy(last).and($.copy(HI_NODE_ID));
  next_node_id = $.copy(next).and($.copy(HI_NODE_ID));
  list_top = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_LIST_STACK_TOP))
      .and(u128($.copy(HI_NODE_ID)))
  );
  list_node_ref_mut.last_msbs = u8("0");
  list_node_ref_mut.last_lsbs = u8("0");
  list_node_ref_mut.next_msbs = u8($.copy(list_top).shr($.copy(BITS_PER_BYTE)));
  list_node_ref_mut.next_lsbs = u8($.copy(list_top).and(u64($.copy(HI_BYTE))));
  avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_LIST_STACK_TOP))
      )
    )
    .or(u128($.copy(list_node_id)).shl($.copy(SHIFT_LIST_STACK_TOP)));
  [new_head, new_tail] = remove_list_node_update_edges_(
    avlq_ref_mut,
    $.copy(last),
    $.copy(next),
    last_is_tree,
    next_is_tree,
    $.copy(last_node_id),
    $.copy(next_node_id),
    $c,
    [$p[0]]
  );
  values_ref_mut = avlq_ref_mut.values;
  value = Stdlib.Option.extract_(
    Stdlib.Table.borrow_mut_(values_ref_mut, $.copy(list_node_id), $c, [
      AtomicTypeTag.U64,
      new StructTag(new HexString("0x1"), "option", "Option", [$p[0]]),
    ]),
    $c,
    [$p[0]]
  );
  return [value, $.copy(new_head), $.copy(new_tail)];
}

export function remove_list_node_update_edges_(
  avlq_ref_mut: AVLqueue,
  last: U64,
  next: U64,
  last_is_tree: boolean,
  next_is_tree: boolean,
  last_node_id: U64,
  next_node_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [Stdlib.Option.Option, Stdlib.Option.Option] {
  let list_node_ref_mut,
    list_node_ref_mut__2,
    list_nodes_ref_mut,
    new_head,
    new_tail,
    tree_node_ref_mut,
    tree_node_ref_mut__1,
    tree_nodes_ref_mut;
  if (last_is_tree && next_is_tree) {
    return [
      Stdlib.Option.some_(u64($.copy(NIL)), $c, [AtomicTypeTag.U64]),
      Stdlib.Option.some_(u64($.copy(NIL)), $c, [AtomicTypeTag.U64]),
    ];
  } else {
  }
  [new_head, new_tail] = [
    Stdlib.Option.none_($c, [AtomicTypeTag.U64]),
    Stdlib.Option.none_($c, [AtomicTypeTag.U64]),
  ];
  tree_nodes_ref_mut = avlq_ref_mut.tree_nodes;
  list_nodes_ref_mut = avlq_ref_mut.list_nodes;
  if (last_is_tree) {
    tree_node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      tree_nodes_ref_mut,
      $.copy(last_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_node_ref_mut.bits = $.copy(tree_node_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_LIST_HEAD))
        )
      )
      .or(u128($.copy(next_node_id)).shl($.copy(SHIFT_LIST_HEAD)));
    new_head = Stdlib.Option.some_($.copy(next_node_id), $c, [
      AtomicTypeTag.U64,
    ]);
  } else {
    list_node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      list_nodes_ref_mut,
      $.copy(last_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
    );
    list_node_ref_mut.next_msbs = u8($.copy(next).shr($.copy(BITS_PER_BYTE)));
    list_node_ref_mut.next_lsbs = u8($.copy(next).and(u64($.copy(HI_BYTE))));
  }
  if (next_is_tree) {
    tree_node_ref_mut__1 = Stdlib.Table_with_length.borrow_mut_(
      tree_nodes_ref_mut,
      $.copy(next_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_node_ref_mut__1.bits = $.copy(tree_node_ref_mut__1.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_LIST_TAIL))
        )
      )
      .or(u128($.copy(last_node_id)).shl($.copy(SHIFT_LIST_TAIL)));
    new_tail = Stdlib.Option.some_($.copy(last_node_id), $c, [
      AtomicTypeTag.U64,
    ]);
  } else {
    list_node_ref_mut__2 = Stdlib.Table_with_length.borrow_mut_(
      list_nodes_ref_mut,
      $.copy(next_node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(ListNode)]
    );
    list_node_ref_mut__2.last_msbs = u8(
      $.copy(last).shr($.copy(BITS_PER_BYTE))
    );
    list_node_ref_mut__2.last_lsbs = u8($.copy(last).and(u64($.copy(HI_BYTE))));
  }
  return [$.copy(new_head), $.copy(new_tail)];
}

export function remove_tree_node_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    bits,
    child_ref_mut,
    has_child_left,
    has_child_right,
    new_subtree_root,
    node_x_child_left,
    node_x_child_right,
    node_x_height_left,
    node_x_height_right,
    node_x_parent,
    node_x_ref,
    retrace_node_id,
    retrace_side;
  [temp$1, temp$2] = [avlq_ref_mut.tree_nodes, $.copy(node_x_id)];
  node_x_ref = Stdlib.Table_with_length.borrow_(temp$1, temp$2, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(TreeNode),
  ]);
  bits = $.copy(node_x_ref.bits);
  [
    node_x_height_left,
    node_x_height_right,
    node_x_parent,
    node_x_child_left,
    node_x_child_right,
  ] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_PARENT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_CHILD_LEFT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_CHILD_RIGHT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
  ];
  has_child_left = $.copy(node_x_child_left).neq(u64($.copy(NIL)));
  has_child_right = $.copy(node_x_child_right).neq(u64($.copy(NIL)));
  [new_subtree_root, retrace_node_id, retrace_side] = [
    u64($.copy(NIL)),
    $.copy(node_x_parent),
    false,
  ];
  if (has_child_left) {
    temp$3 = !has_child_right;
  } else {
    temp$3 = false;
  }
  if (temp$3) {
    temp$4 = true;
  } else {
    temp$4 = !has_child_left && has_child_right;
  }
  if (temp$4) {
    if (has_child_left) {
      temp$5 = $.copy(node_x_child_left);
    } else {
      temp$5 = $.copy(node_x_child_right);
    }
    new_subtree_root = temp$5;
    child_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      avlq_ref_mut.tree_nodes,
      $.copy(new_subtree_root),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    child_ref_mut.bits = $.copy(child_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  if (has_child_left && has_child_right) {
    [new_subtree_root, retrace_node_id, retrace_side] =
      remove_tree_node_with_children_(
        avlq_ref_mut,
        $.copy(node_x_height_left),
        $.copy(node_x_height_right),
        $.copy(node_x_parent),
        $.copy(node_x_child_left),
        $.copy(node_x_child_right),
        $c,
        [$p[0]]
      );
  } else {
  }
  remove_tree_node_follow_up_(
    avlq_ref_mut,
    $.copy(node_x_id),
    $.copy(node_x_parent),
    $.copy(new_subtree_root),
    $.copy(retrace_node_id),
    retrace_side,
    $c,
    [$p[0]]
  );
  return;
}

export function remove_tree_node_follow_up_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  node_x_parent: U64,
  new_subtree_root: U64,
  retrace_node_id: U64,
  retrace_side: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1,
    temp$2,
    child_shift,
    node_x_ref_mut,
    parent_left_child,
    parent_ref_mut,
    tree_top;
  if ($.copy(node_x_parent).eq(u64($.copy(NIL)))) {
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shr($.copy(BITS_PER_BYTE)))
      )
      .or(u128($.copy(new_subtree_root)).shr($.copy(BITS_PER_BYTE)));
    avlq_ref_mut.root_lsbs = u8($.copy(new_subtree_root).and($.copy(HI_BYTE)));
  } else {
    parent_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      avlq_ref_mut.tree_nodes,
      $.copy(node_x_parent),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    parent_left_child = u64(
      $.copy(parent_ref_mut.bits)
        .shr($.copy(SHIFT_CHILD_LEFT))
        .and(u128($.copy(HI_NODE_ID)))
    );
    if ($.copy(parent_left_child).eq($.copy(node_x_id))) {
      temp$1 = $.copy(SHIFT_CHILD_LEFT);
    } else {
      temp$1 = $.copy(SHIFT_CHILD_RIGHT);
    }
    child_shift = temp$1;
    parent_ref_mut.bits = $.copy(parent_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(child_shift)))
      )
      .or(u128($.copy(new_subtree_root)).shl($.copy(child_shift)));
    if ($.copy(retrace_node_id).eq($.copy(node_x_parent))) {
      if ($.copy(parent_left_child).eq($.copy(node_x_id))) {
        temp$2 = $.copy(LEFT);
      } else {
        temp$2 = $.copy(RIGHT);
      }
      retrace_side = temp$2;
    } else {
    }
  }
  if ($.copy(retrace_node_id).neq(u64($.copy(NIL)))) {
    retrace_(
      avlq_ref_mut,
      $.copy(retrace_node_id),
      $.copy(DECREMENT),
      retrace_side,
      $c,
      [$p[0]]
    );
  } else {
  }
  tree_top = u64(
    $.copy(avlq_ref_mut.bits)
      .shr($.copy(SHIFT_TREE_STACK_TOP))
      .and(u128($.copy(HI_NODE_ID)))
  );
  node_x_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    avlq_ref_mut.tree_nodes,
    $.copy(node_x_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_x_ref_mut.bits = u128($.copy(tree_top));
  avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_TREE_STACK_TOP))
      )
    )
    .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_TREE_STACK_TOP)));
  return;
}

export function remove_tree_node_with_children_(
  avlq_ref_mut: AVLqueue,
  node_x_height_left: U8,
  node_x_height_right: U8,
  node_x_parent: U64,
  node_l_id: U64,
  node_r_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U64, boolean] {
  let temp$2,
    bits,
    bits__1,
    child_right,
    new_subtree_root,
    node_l_child_right,
    node_l_ref_mut,
    node_r_ref_mut,
    node_y_id,
    node_y_parent_id,
    node_y_parent_ref_mut,
    node_y_ref_mut,
    retrace_node_id,
    retrace_side,
    tree_nodes_ref_mut,
    tree_y_id,
    tree_y_ref_mut;
  tree_nodes_ref_mut = avlq_ref_mut.tree_nodes;
  node_l_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    tree_nodes_ref_mut,
    $.copy(node_l_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  bits = $.copy(node_l_ref_mut.bits);
  node_l_child_right = u64(
    $.copy(bits)
      .shr($.copy(SHIFT_CHILD_RIGHT))
      .and(u128($.copy(HI_NODE_ID)))
  );
  if ($.copy(node_l_child_right).eq(u64($.copy(NIL)))) {
    node_l_ref_mut.bits = $.copy(node_l_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_HEIGHT))
            .shl($.copy(SHIFT_HEIGHT_LEFT))
            .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
            .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
            .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_CHILD_RIGHT)))
        )
      )
      .or(u128($.copy(node_x_height_left)).shl($.copy(SHIFT_HEIGHT_LEFT)))
      .or(u128($.copy(node_x_height_right)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
      .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)))
      .or(u128($.copy(node_r_id)).shl($.copy(SHIFT_CHILD_RIGHT)));
    [new_subtree_root, retrace_node_id, retrace_side] = [
      $.copy(node_l_id),
      $.copy(node_l_id),
      $.copy(LEFT),
    ];
  } else {
    node_y_id = $.copy(node_l_child_right);
    while (true) {
      node_y_ref_mut = Stdlib.Table_with_length.borrow_mut_(
        tree_nodes_ref_mut,
        $.copy(node_y_id),
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
      );
      child_right = u64(
        $.copy(node_y_ref_mut.bits)
          .shr($.copy(SHIFT_CHILD_RIGHT))
          .and(u128($.copy(HI_NODE_ID)))
      );
      if ($.copy(child_right).eq(u64($.copy(NIL)))) {
        break;
      } else {
      }
      node_y_id = $.copy(child_right);
    }
    bits__1 = $.copy(node_y_ref_mut.bits);
    [node_y_parent_id, tree_y_id] = [
      u64(
        $.copy(bits__1)
          .shr($.copy(SHIFT_PARENT))
          .and(u128($.copy(HI_NODE_ID)))
      ),
      u64(
        $.copy(bits__1)
          .shr($.copy(SHIFT_CHILD_LEFT))
          .and(u128($.copy(HI_NODE_ID)))
      ),
    ];
    node_y_ref_mut.bits = $.copy(bits__1)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_HEIGHT))
            .shl($.copy(SHIFT_HEIGHT_LEFT))
            .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
            .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
            .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_CHILD_LEFT)))
            .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_CHILD_RIGHT)))
        )
      )
      .or(u128($.copy(node_x_height_left)).shl($.copy(SHIFT_HEIGHT_LEFT)))
      .or(u128($.copy(node_x_height_right)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
      .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)))
      .or(u128($.copy(node_l_id)).shl($.copy(SHIFT_CHILD_LEFT)))
      .or(u128($.copy(node_r_id)).shl($.copy(SHIFT_CHILD_RIGHT)));
    node_y_parent_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      tree_nodes_ref_mut,
      $.copy(node_y_parent_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    node_y_parent_ref_mut.bits = $.copy(node_y_parent_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_CHILD_RIGHT))
        )
      )
      .or(u128($.copy(tree_y_id)).shl($.copy(SHIFT_CHILD_RIGHT)));
    if ($.copy(node_y_parent_id).eq($.copy(node_l_id))) {
      temp$2 = node_y_parent_ref_mut;
    } else {
      temp$2 = Stdlib.Table_with_length.borrow_mut_(
        tree_nodes_ref_mut,
        $.copy(node_l_id),
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
      );
    }
    node_l_ref_mut = temp$2;
    node_l_ref_mut.bits = $.copy(node_l_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_y_id)).shl($.copy(SHIFT_PARENT)));
    if ($.copy(tree_y_id).neq(u64($.copy(NIL)))) {
      tree_y_ref_mut = Stdlib.Table_with_length.borrow_mut_(
        tree_nodes_ref_mut,
        $.copy(tree_y_id),
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
      );
      tree_y_ref_mut.bits = $.copy(tree_y_ref_mut.bits)
        .and(
          $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
        )
        .or(u128($.copy(node_y_parent_id)).shl($.copy(SHIFT_PARENT)));
    } else {
    }
    [new_subtree_root, retrace_node_id, retrace_side] = [
      $.copy(node_y_id),
      $.copy(node_y_parent_id),
      $.copy(RIGHT),
    ];
  }
  node_r_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    tree_nodes_ref_mut,
    $.copy(node_r_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_r_ref_mut.bits = $.copy(node_r_ref_mut.bits)
    .and($.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT))))
    .or(u128($.copy(new_subtree_root)).shl($.copy(SHIFT_PARENT)));
  return [$.copy(new_subtree_root), $.copy(retrace_node_id), retrace_side];
}

export function remove_update_head_(
  avlq_ref_mut: AVLqueue,
  new_list_head: U64,
  ascending: boolean,
  tree_node_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    new_avlq_head_insertion_key,
    new_avlq_head_node_id,
    target;
  if ($.copy(new_list_head).neq(u64($.copy(NIL)))) {
    new_avlq_head_node_id = $.copy(new_list_head);
  } else {
    if (ascending) {
      temp$1 = $.copy(SUCCESSOR);
    } else {
      temp$1 = $.copy(PREDECESSOR);
    }
    target = temp$1;
    [temp$2, temp$3, temp$4] = [avlq_ref_mut, $.copy(tree_node_id), target];
    [new_avlq_head_insertion_key, new_avlq_head_node_id] = traverse_(
      temp$2,
      temp$3,
      temp$4,
      $c,
      [$p[0]]
    );
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_INSERTION_KEY)).shl($.copy(SHIFT_HEAD_KEY))
        )
      )
      .or(
        u128($.copy(new_avlq_head_insertion_key)).shl($.copy(SHIFT_HEAD_KEY))
      );
  }
  avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_HEAD_NODE_ID))
      )
    )
    .or(u128($.copy(new_avlq_head_node_id)).shl($.copy(SHIFT_HEAD_NODE_ID)));
  return;
}

export function remove_update_tail_(
  avlq_ref_mut: AVLqueue,
  new_list_tail: U64,
  ascending: boolean,
  tree_node_id: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    new_avlq_tail_insertion_key,
    new_avlq_tail_node_id,
    target;
  if ($.copy(new_list_tail).neq(u64($.copy(NIL)))) {
    new_avlq_tail_node_id = $.copy(new_list_tail);
  } else {
    if (ascending) {
      temp$1 = $.copy(PREDECESSOR);
    } else {
      temp$1 = $.copy(SUCCESSOR);
    }
    target = temp$1;
    [temp$2, temp$3, temp$4] = [avlq_ref_mut, $.copy(tree_node_id), target];
    [new_avlq_tail_insertion_key, , new_avlq_tail_node_id] = traverse_(
      temp$2,
      temp$3,
      temp$4,
      $c,
      [$p[0]]
    );
    avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(
          u128($.copy(HI_INSERTION_KEY)).shl($.copy(SHIFT_TAIL_KEY))
        )
      )
      .or(
        u128($.copy(new_avlq_tail_insertion_key)).shl($.copy(SHIFT_TAIL_KEY))
      );
  }
  avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_TAIL_NODE_ID))
      )
    )
    .or(u128($.copy(new_avlq_tail_node_id)).shl($.copy(SHIFT_TAIL_NODE_ID)));
  return;
}

export function retrace_(
  avlq_ref_mut: AVLqueue,
  node_id: U64,
  operation: boolean,
  side: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): void {
  let temp$1,
    temp$2,
    temp$3,
    child_id,
    child_shift,
    delta,
    height,
    height_left,
    height_old,
    height_right,
    imbalance,
    left_heavy,
    new_subtree_root,
    node_ref_mut,
    nodes_ref_mut,
    parent;
  delta = u8("1");
  nodes_ref_mut = avlq_ref_mut.tree_nodes;
  node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  while (true) {
    parent = u64(
      $.copy(node_ref_mut.bits)
        .shr($.copy(SHIFT_PARENT))
        .and(u128($.copy(HI_NODE_ID)))
    );
    [height_left, height_right, height, height_old] = retrace_update_heights_(
      node_ref_mut,
      side,
      operation,
      $.copy(delta),
      $c
    );
    new_subtree_root = u64($.copy(NIL));
    if ($.copy(height_left).neq($.copy(height_right))) {
      if ($.copy(height_left).gt($.copy(height_right))) {
        [temp$1, temp$2] = [
          true,
          $.copy(height_left).sub($.copy(height_right)),
        ];
      } else {
        [temp$1, temp$2] = [
          false,
          $.copy(height_right).sub($.copy(height_left)),
        ];
      }
      [left_heavy, imbalance] = [temp$1, temp$2];
      if ($.copy(imbalance).gt(u8("1"))) {
        if (left_heavy) {
          temp$3 = $.copy(SHIFT_CHILD_LEFT);
        } else {
          temp$3 = $.copy(SHIFT_CHILD_RIGHT);
        }
        child_shift = temp$3;
        child_id = u64(
          $.copy(node_ref_mut.bits)
            .shr($.copy(child_shift))
            .and(u128($.copy(HI_NODE_ID)))
        );
        [new_subtree_root, height] = retrace_rebalance_(
          avlq_ref_mut,
          $.copy(node_id),
          $.copy(child_id),
          left_heavy,
          $c,
          [$p[0]]
        );
      } else {
      }
    } else {
    }
    if ($.copy(parent).eq(u64($.copy(NIL)))) {
      if ($.copy(new_subtree_root).neq(u64($.copy(NIL)))) {
        avlq_ref_mut.bits = $.copy(avlq_ref_mut.bits)
          .and(
            $.copy(HI_128).xor(
              u128($.copy(HI_NODE_ID)).shr($.copy(BITS_PER_BYTE))
            )
          )
          .or(u128($.copy(new_subtree_root)).shr($.copy(BITS_PER_BYTE)));
        avlq_ref_mut.root_lsbs = u8(
          $.copy(new_subtree_root).and($.copy(HI_BYTE))
        );
      } else {
      }
      return;
    } else {
      [node_ref_mut, operation, side, delta] = retrace_prep_iterate_(
        avlq_ref_mut,
        $.copy(parent),
        $.copy(node_id),
        $.copy(new_subtree_root),
        $.copy(height),
        $.copy(height_old),
        $c,
        [$p[0]]
      );
      if ($.copy(delta).eq(u8("0"))) {
        return;
      } else {
      }
      node_id = $.copy(parent);
    }
  }
}

export function retrace_prep_iterate_(
  avlq_ref_mut: AVLqueue,
  parent_id: U64,
  node_id: U64,
  new_subtree_root: U64,
  height: U8,
  height_old: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [TreeNode, boolean, boolean, U8] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    child_shift,
    delta,
    left_child,
    node_ref_mut,
    nodes_ref_mut,
    operation,
    side;
  nodes_ref_mut = avlq_ref_mut.tree_nodes;
  node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(parent_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  left_child = u64(
    $.copy(node_ref_mut.bits)
      .shr($.copy(SHIFT_CHILD_LEFT))
      .and(u128($.copy(HI_NODE_ID)))
  );
  if ($.copy(left_child).eq($.copy(node_id))) {
    temp$1 = $.copy(LEFT);
  } else {
    temp$1 = $.copy(RIGHT);
  }
  side = temp$1;
  if ($.copy(new_subtree_root).neq(u64($.copy(NIL)))) {
    if (side == $.copy(LEFT)) {
      temp$2 = $.copy(SHIFT_CHILD_LEFT);
    } else {
      temp$2 = $.copy(SHIFT_CHILD_RIGHT);
    }
    child_shift = temp$2;
    node_ref_mut.bits = $.copy(node_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(child_shift)))
      )
      .or(u128($.copy(new_subtree_root)).shl($.copy(child_shift)));
  } else {
  }
  if ($.copy(height).gt($.copy(height_old))) {
    [temp$3, temp$4] = [
      $.copy(INCREMENT),
      $.copy(height).sub($.copy(height_old)),
    ];
  } else {
    [temp$3, temp$4] = [
      $.copy(DECREMENT),
      $.copy(height_old).sub($.copy(height)),
    ];
  }
  [operation, delta] = [temp$3, temp$4];
  return [node_ref_mut, operation, side, $.copy(delta)];
}

export function retrace_rebalance_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  node_z_id: U64,
  node_x_left_heavy: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U8] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    bits,
    node_z_child_left,
    node_z_child_right,
    node_z_height_left,
    node_z_height_right,
    node_z_ref;
  node_z_ref = Stdlib.Table_with_length.borrow_(
    avlq_ref_mut.tree_nodes,
    $.copy(node_z_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  bits = $.copy(node_z_ref.bits);
  [
    node_z_height_left,
    node_z_height_right,
    node_z_child_left,
    node_z_child_right,
  ] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_CHILD_LEFT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_CHILD_RIGHT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
  ];
  if (node_x_left_heavy) {
    if ($.copy(node_z_height_right).gt($.copy(node_z_height_left))) {
      [temp$1, temp$2] = retrace_rebalance_rotate_left_right_(
        avlq_ref_mut,
        $.copy(node_x_id),
        $.copy(node_z_id),
        $.copy(node_z_child_right),
        $.copy(node_z_height_left),
        $c,
        [$p[0]]
      );
    } else {
      [temp$1, temp$2] = retrace_rebalance_rotate_right_(
        avlq_ref_mut,
        $.copy(node_x_id),
        $.copy(node_z_id),
        $.copy(node_z_child_right),
        $.copy(node_z_height_right),
        $c,
        [$p[0]]
      );
    }
    [temp$5, temp$6] = [temp$1, temp$2];
  } else {
    if ($.copy(node_z_height_left).gt($.copy(node_z_height_right))) {
      [temp$3, temp$4] = retrace_rebalance_rotate_right_left_(
        avlq_ref_mut,
        $.copy(node_x_id),
        $.copy(node_z_id),
        $.copy(node_z_child_left),
        $.copy(node_z_height_right),
        $c,
        [$p[0]]
      );
    } else {
      [temp$3, temp$4] = retrace_rebalance_rotate_left_(
        avlq_ref_mut,
        $.copy(node_x_id),
        $.copy(node_z_id),
        $.copy(node_z_child_left),
        $.copy(node_z_height_left),
        $c,
        [$p[0]]
      );
    }
    [temp$5, temp$6] = [temp$3, temp$4];
  }
  return [temp$5, temp$6];
}

export function retrace_rebalance_rotate_left_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  node_z_id: U64,
  tree_2_id: U64,
  node_z_height_left: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U8] {
  let temp$1,
    temp$3,
    node_x_height,
    node_x_height_left,
    node_x_height_right,
    node_x_parent,
    node_x_ref_mut,
    node_z_height,
    node_z_height_left__2,
    node_z_height_right,
    node_z_ref_mut,
    nodes_ref_mut,
    tree_2_ref_mut;
  nodes_ref_mut = avlq_ref_mut.tree_nodes;
  if ($.copy(tree_2_id).neq(u64($.copy(NIL)))) {
    tree_2_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      nodes_ref_mut,
      $.copy(tree_2_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_2_ref_mut.bits = $.copy(tree_2_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  node_x_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_x_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_x_height_left = u8(
    $.copy(node_x_ref_mut.bits)
      .shr($.copy(SHIFT_HEIGHT_LEFT))
      .and(u128($.copy(HI_HEIGHT)))
  );
  node_x_height_right = $.copy(node_z_height_left);
  node_x_parent = u64(
    $.copy(node_x_ref_mut.bits)
      .shr($.copy(SHIFT_PARENT))
      .and(u128($.copy(HI_NODE_ID)))
  );
  node_x_ref_mut.bits = $.copy(node_x_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_RIGHT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(tree_2_id)).shl($.copy(SHIFT_CHILD_RIGHT)))
    .or(u128($.copy(node_x_height_right)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
    .or(u128($.copy(node_z_id)).shl($.copy(SHIFT_PARENT)));
  if ($.copy(node_x_height_left).ge($.copy(node_x_height_right))) {
    temp$1 = $.copy(node_x_height_left);
  } else {
    temp$1 = $.copy(node_x_height_right);
  }
  node_x_height = temp$1;
  node_z_height_left__2 = $.copy(node_x_height).add(u8("1"));
  node_z_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_z_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_z_ref_mut.bits = $.copy(node_z_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_LEFT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_LEFT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_CHILD_LEFT)))
    .or(u128($.copy(node_z_height_left__2)).shl($.copy(SHIFT_HEIGHT_LEFT)))
    .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)));
  node_z_height_right = u8(
    $.copy(node_z_ref_mut.bits)
      .shr($.copy(SHIFT_HEIGHT_RIGHT))
      .and(u128($.copy(HI_HEIGHT)))
  );
  if ($.copy(node_z_height_right).ge($.copy(node_z_height_left__2))) {
    temp$3 = $.copy(node_z_height_right);
  } else {
    temp$3 = $.copy(node_z_height_left__2);
  }
  node_z_height = temp$3;
  return [$.copy(node_z_id), $.copy(node_z_height)];
}

export function retrace_rebalance_rotate_left_right_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  node_z_id: U64,
  node_y_id: U64,
  node_z_height_left: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U8] {
  let temp$1,
    temp$2,
    temp$3,
    node_x_height_left,
    node_x_parent,
    node_x_ref_mut,
    node_y_height,
    node_y_height_left,
    node_y_height_right,
    node_y_ref,
    node_y_ref_mut,
    node_z_height,
    node_z_height_right,
    node_z_ref_mut,
    nodes_ref_mut,
    tree_2_id,
    tree_2_ref_mut,
    tree_3_id,
    tree_3_ref_mut,
    y_bits;
  nodes_ref_mut = avlq_ref_mut.tree_nodes;
  [temp$1, temp$2] = [nodes_ref_mut, $.copy(node_y_id)];
  node_y_ref = Stdlib.Table_with_length.borrow_(temp$1, temp$2, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(TreeNode),
  ]);
  y_bits = $.copy(node_y_ref.bits);
  [node_y_height_left, node_y_height_right, tree_2_id, tree_3_id] = [
    u8(
      $.copy(y_bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(y_bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u64(
      $.copy(y_bits)
        .shr($.copy(SHIFT_CHILD_LEFT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(y_bits)
        .shr($.copy(SHIFT_CHILD_RIGHT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
  ];
  if ($.copy(tree_2_id).neq(u64($.copy(NIL)))) {
    tree_2_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      nodes_ref_mut,
      $.copy(tree_2_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_2_ref_mut.bits = $.copy(tree_2_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_z_id)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  if ($.copy(tree_3_id).neq(u64($.copy(NIL)))) {
    tree_3_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      nodes_ref_mut,
      $.copy(tree_3_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_3_ref_mut.bits = $.copy(tree_3_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  node_x_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_x_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_x_height_left = $.copy(node_y_height_right);
  node_x_parent = u64(
    $.copy(node_x_ref_mut.bits)
      .shr($.copy(SHIFT_PARENT))
      .and(u128($.copy(HI_NODE_ID)))
  );
  node_x_ref_mut.bits = $.copy(node_x_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_LEFT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_LEFT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(tree_3_id)).shl($.copy(SHIFT_CHILD_LEFT)))
    .or(u128($.copy(node_x_height_left)).shl($.copy(SHIFT_HEIGHT_LEFT)))
    .or(u128($.copy(node_y_id)).shl($.copy(SHIFT_PARENT)));
  node_z_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_z_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_z_height_right = $.copy(node_y_height_left);
  node_z_ref_mut.bits = $.copy(node_z_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_RIGHT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(tree_2_id)).shl($.copy(SHIFT_CHILD_RIGHT)))
    .or(u128($.copy(node_z_height_right)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
    .or(u128($.copy(node_y_id)).shl($.copy(SHIFT_PARENT)));
  if ($.copy(node_z_height_right).ge($.copy(node_z_height_left))) {
    temp$3 = $.copy(node_z_height_right);
  } else {
    temp$3 = $.copy(node_z_height_left);
  }
  node_z_height = temp$3;
  node_y_height = $.copy(node_z_height).add(u8("1"));
  node_y_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_y_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_y_ref_mut.bits = $.copy(node_y_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_LEFT))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_CHILD_RIGHT)))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_LEFT)))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(node_z_id)).shl($.copy(SHIFT_CHILD_LEFT)))
    .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_CHILD_RIGHT)))
    .or(u128($.copy(node_y_height)).shl($.copy(SHIFT_HEIGHT_LEFT)))
    .or(u128($.copy(node_y_height)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
    .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)));
  return [$.copy(node_y_id), $.copy(node_y_height)];
}

export function retrace_rebalance_rotate_right_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  node_z_id: U64,
  tree_2_id: U64,
  node_z_height_right: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U8] {
  let temp$1,
    temp$3,
    node_x_height,
    node_x_height_left,
    node_x_height_right,
    node_x_parent,
    node_x_ref_mut,
    node_z_height,
    node_z_height_left,
    node_z_height_right__2,
    node_z_ref_mut,
    nodes_ref_mut,
    tree_2_ref_mut;
  nodes_ref_mut = avlq_ref_mut.tree_nodes;
  if ($.copy(tree_2_id).neq(u64($.copy(NIL)))) {
    tree_2_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      nodes_ref_mut,
      $.copy(tree_2_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_2_ref_mut.bits = $.copy(tree_2_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  node_x_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_x_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_x_height_right = u8(
    $.copy(node_x_ref_mut.bits)
      .shr($.copy(SHIFT_HEIGHT_RIGHT))
      .and(u128($.copy(HI_HEIGHT)))
  );
  node_x_height_left = $.copy(node_z_height_right);
  node_x_parent = u64(
    $.copy(node_x_ref_mut.bits)
      .shr($.copy(SHIFT_PARENT))
      .and(u128($.copy(HI_NODE_ID)))
  );
  node_x_ref_mut.bits = $.copy(node_x_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_LEFT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_LEFT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(tree_2_id)).shl($.copy(SHIFT_CHILD_LEFT)))
    .or(u128($.copy(node_x_height_left)).shl($.copy(SHIFT_HEIGHT_LEFT)))
    .or(u128($.copy(node_z_id)).shl($.copy(SHIFT_PARENT)));
  if ($.copy(node_x_height_right).ge($.copy(node_x_height_left))) {
    temp$1 = $.copy(node_x_height_right);
  } else {
    temp$1 = $.copy(node_x_height_left);
  }
  node_x_height = temp$1;
  node_z_height_right__2 = $.copy(node_x_height).add(u8("1"));
  node_z_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_z_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_z_ref_mut.bits = $.copy(node_z_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_RIGHT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_CHILD_RIGHT)))
    .or(u128($.copy(node_z_height_right__2)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
    .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)));
  node_z_height_left = u8(
    $.copy(node_z_ref_mut.bits)
      .shr($.copy(SHIFT_HEIGHT_LEFT))
      .and(u128($.copy(HI_HEIGHT)))
  );
  if ($.copy(node_z_height_left).ge($.copy(node_z_height_right__2))) {
    temp$3 = $.copy(node_z_height_left);
  } else {
    temp$3 = $.copy(node_z_height_right__2);
  }
  node_z_height = temp$3;
  return [$.copy(node_z_id), $.copy(node_z_height)];
}

export function retrace_rebalance_rotate_right_left_(
  avlq_ref_mut: AVLqueue,
  node_x_id: U64,
  node_z_id: U64,
  node_y_id: U64,
  node_z_height_right: U8,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U8] {
  let temp$1,
    temp$2,
    temp$3,
    node_x_height_right,
    node_x_parent,
    node_x_ref_mut,
    node_y_height,
    node_y_height_left,
    node_y_height_right,
    node_y_ref,
    node_y_ref_mut,
    node_z_height,
    node_z_height_left,
    node_z_ref_mut,
    nodes_ref_mut,
    tree_2_id,
    tree_2_ref_mut,
    tree_3_id,
    tree_3_ref_mut,
    y_bits;
  nodes_ref_mut = avlq_ref_mut.tree_nodes;
  [temp$1, temp$2] = [nodes_ref_mut, $.copy(node_y_id)];
  node_y_ref = Stdlib.Table_with_length.borrow_(temp$1, temp$2, $c, [
    AtomicTypeTag.U64,
    new SimpleStructTag(TreeNode),
  ]);
  y_bits = $.copy(node_y_ref.bits);
  [node_y_height_left, node_y_height_right, tree_2_id, tree_3_id] = [
    u8(
      $.copy(y_bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(y_bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u64(
      $.copy(y_bits)
        .shr($.copy(SHIFT_CHILD_LEFT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(y_bits)
        .shr($.copy(SHIFT_CHILD_RIGHT))
        .and(u128($.copy(HI_NODE_ID)))
    ),
  ];
  if ($.copy(tree_2_id).neq(u64($.copy(NIL)))) {
    tree_2_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      nodes_ref_mut,
      $.copy(tree_2_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_2_ref_mut.bits = $.copy(tree_2_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  if ($.copy(tree_3_id).neq(u64($.copy(NIL)))) {
    tree_3_ref_mut = Stdlib.Table_with_length.borrow_mut_(
      nodes_ref_mut,
      $.copy(tree_3_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    tree_3_ref_mut.bits = $.copy(tree_3_ref_mut.bits)
      .and(
        $.copy(HI_128).xor(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
      .or(u128($.copy(node_z_id)).shl($.copy(SHIFT_PARENT)));
  } else {
  }
  node_x_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_x_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_x_height_right = $.copy(node_y_height_left);
  node_x_parent = u64(
    $.copy(node_x_ref_mut.bits)
      .shr($.copy(SHIFT_PARENT))
      .and(u128($.copy(HI_NODE_ID)))
  );
  node_x_ref_mut.bits = $.copy(node_x_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_RIGHT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(tree_2_id)).shl($.copy(SHIFT_CHILD_RIGHT)))
    .or(u128($.copy(node_x_height_right)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
    .or(u128($.copy(node_y_id)).shl($.copy(SHIFT_PARENT)));
  node_z_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_z_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_z_height_left = $.copy(node_y_height_right);
  node_z_ref_mut.bits = $.copy(node_z_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_LEFT))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_LEFT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(tree_3_id)).shl($.copy(SHIFT_CHILD_LEFT)))
    .or(u128($.copy(node_z_height_left)).shl($.copy(SHIFT_HEIGHT_LEFT)))
    .or(u128($.copy(node_y_id)).shl($.copy(SHIFT_PARENT)));
  if ($.copy(node_z_height_left).ge($.copy(node_z_height_right))) {
    temp$3 = $.copy(node_z_height_left);
  } else {
    temp$3 = $.copy(node_z_height_right);
  }
  node_z_height = temp$3;
  node_y_height = $.copy(node_z_height).add(u8("1"));
  node_y_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    nodes_ref_mut,
    $.copy(node_y_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  node_y_ref_mut.bits = $.copy(node_y_ref_mut.bits)
    .and(
      $.copy(HI_128).xor(
        u128($.copy(HI_NODE_ID))
          .shl($.copy(SHIFT_CHILD_LEFT))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_CHILD_RIGHT)))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_LEFT)))
          .or(u128($.copy(HI_HEIGHT)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
          .or(u128($.copy(HI_NODE_ID)).shl($.copy(SHIFT_PARENT)))
      )
    )
    .or(u128($.copy(node_x_id)).shl($.copy(SHIFT_CHILD_LEFT)))
    .or(u128($.copy(node_z_id)).shl($.copy(SHIFT_CHILD_RIGHT)))
    .or(u128($.copy(node_y_height)).shl($.copy(SHIFT_HEIGHT_LEFT)))
    .or(u128($.copy(node_y_height)).shl($.copy(SHIFT_HEIGHT_RIGHT)))
    .or(u128($.copy(node_x_parent)).shl($.copy(SHIFT_PARENT)));
  return [$.copy(node_y_id), $.copy(node_y_height)];
}

export function retrace_update_heights_(
  node_ref_mut: TreeNode,
  side: boolean,
  operation: boolean,
  delta: U8,
  $c: AptosDataCache
): [U8, U8, U8, U8] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$6,
    bits,
    height,
    height_field,
    height_field__5,
    height_left,
    height_old,
    height_right,
    height_shift;
  bits = $.copy(node_ref_mut.bits);
  [height_left, height_right] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_LEFT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_HEIGHT_RIGHT))
        .and(u128($.copy(HI_HEIGHT)))
    ),
  ];
  if ($.copy(height_left).ge($.copy(height_right))) {
    temp$1 = $.copy(height_left);
  } else {
    temp$1 = $.copy(height_right);
  }
  height_old = temp$1;
  if (side == $.copy(LEFT)) {
    [temp$2, temp$3] = [$.copy(height_left), $.copy(SHIFT_HEIGHT_LEFT)];
  } else {
    [temp$2, temp$3] = [$.copy(height_right), $.copy(SHIFT_HEIGHT_RIGHT)];
  }
  [height_field, height_shift] = [temp$2, temp$3];
  if (operation == $.copy(INCREMENT)) {
    temp$4 = $.copy(height_field).add($.copy(delta));
  } else {
    temp$4 = $.copy(height_field).sub($.copy(delta));
  }
  height_field__5 = temp$4;
  node_ref_mut.bits = $.copy(bits)
    .and($.copy(HI_128).xor(u128($.copy(HI_HEIGHT)).shl($.copy(height_shift))))
    .or(u128($.copy(height_field__5)).shl($.copy(height_shift)));
  if (side == $.copy(LEFT)) {
    height_left = $.copy(height_field__5);
  } else {
    height_right = $.copy(height_field__5);
  }
  if ($.copy(height_left).ge($.copy(height_right))) {
    temp$6 = $.copy(height_left);
  } else {
    temp$6 = $.copy(height_right);
  }
  height = temp$6;
  return [
    $.copy(height_left),
    $.copy(height_right),
    $.copy(height),
    $.copy(height_old),
  ];
}

export function search_(
  avlq_ref: AVLqueue,
  seed_key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, Stdlib.Option.Option] {
  let temp$1,
    temp$2,
    child_id,
    child_shift,
    child_side,
    node_id,
    node_key,
    node_ref,
    nodes_ref,
    root_msbs;
  root_msbs = u64(
    $.copy(avlq_ref.bits).and(
      u128($.copy(HI_NODE_ID)).shr($.copy(BITS_PER_BYTE))
    )
  );
  node_id = $.copy(root_msbs)
    .shl($.copy(BITS_PER_BYTE))
    .or(u64($.copy(avlq_ref.root_lsbs)));
  if ($.copy(node_id).eq(u64($.copy(NIL)))) {
    return [$.copy(node_id), Stdlib.Option.none_($c, [AtomicTypeTag.Bool])];
  } else {
  }
  nodes_ref = avlq_ref.tree_nodes;
  while (true) {
    node_ref = Stdlib.Table_with_length.borrow_(
      nodes_ref,
      $.copy(node_id),
      $c,
      [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
    );
    node_key = u64(
      $.copy(node_ref.bits)
        .shr($.copy(SHIFT_INSERTION_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    );
    if ($.copy(seed_key).eq($.copy(node_key))) {
      return [$.copy(node_id), Stdlib.Option.none_($c, [AtomicTypeTag.Bool])];
    } else {
    }
    if ($.copy(seed_key).lt($.copy(node_key))) {
      [temp$1, temp$2] = [$.copy(SHIFT_CHILD_LEFT), $.copy(LEFT)];
    } else {
      [temp$1, temp$2] = [$.copy(SHIFT_CHILD_RIGHT), $.copy(RIGHT)];
    }
    [child_shift, child_side] = [temp$1, temp$2];
    child_id = u64(
      $.copy(node_ref.bits)
        .shr($.copy(child_shift))
        .and(u128($.copy(HI_NODE_ID)))
    );
    if ($.copy(child_id).eq(u64($.copy(NIL)))) {
      return [
        $.copy(node_id),
        Stdlib.Option.some_(child_side, $c, [AtomicTypeTag.Bool]),
      ];
    } else {
    }
    node_id = $.copy(child_id);
  }
}

export function traverse_(
  avlq_ref: AVLqueue,
  start_node_id: U64,
  target: boolean,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): [U64, U64, U64] {
  let temp$1,
    temp$2,
    bits,
    bits__3,
    child,
    child_shift,
    node_ref,
    nodes_ref,
    parent,
    subtree,
    subtree_shift;
  nodes_ref = avlq_ref.tree_nodes;
  node_ref = Stdlib.Table_with_length.borrow_(
    nodes_ref,
    $.copy(start_node_id),
    $c,
    [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
  );
  if (target == $.copy(PREDECESSOR)) {
    [temp$1, temp$2] = [$.copy(SHIFT_CHILD_LEFT), $.copy(SHIFT_CHILD_RIGHT)];
  } else {
    [temp$1, temp$2] = [$.copy(SHIFT_CHILD_RIGHT), $.copy(SHIFT_CHILD_LEFT)];
  }
  [child_shift, subtree_shift] = [temp$1, temp$2];
  bits = $.copy(node_ref.bits);
  child = u64(
    $.copy(bits)
      .shr($.copy(child_shift))
      .and(u128($.copy(HI_NODE_ID)))
  );
  if ($.copy(child).eq(u64($.copy(NIL)))) {
    child = $.copy(start_node_id);
    while (true) {
      parent = u64(
        $.copy(bits)
          .shr($.copy(SHIFT_PARENT))
          .and(u128($.copy(HI_NODE_ID)))
      );
      if ($.copy(parent).eq(u64($.copy(NIL)))) {
        return [u64($.copy(NIL)), u64($.copy(NIL)), u64($.copy(NIL))];
      } else {
      }
      node_ref = Stdlib.Table_with_length.borrow_(
        nodes_ref,
        $.copy(parent),
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
      );
      bits = $.copy(node_ref.bits);
      subtree = u64(
        $.copy(bits)
          .shr($.copy(subtree_shift))
          .and(u128($.copy(HI_NODE_ID)))
      );
      if ($.copy(subtree).eq($.copy(child))) {
        break;
      } else {
      }
      child = $.copy(parent);
    }
  } else {
    while (true) {
      node_ref = Stdlib.Table_with_length.borrow_(
        nodes_ref,
        $.copy(child),
        $c,
        [AtomicTypeTag.U64, new SimpleStructTag(TreeNode)]
      );
      bits = $.copy(node_ref.bits);
      child = u64(
        $.copy(bits)
          .shr($.copy(subtree_shift))
          .and(u128($.copy(HI_NODE_ID)))
      );
      if ($.copy(child).eq(u64($.copy(NIL)))) {
        break;
      } else {
      }
    }
  }
  bits__3 = $.copy(node_ref.bits);
  return [
    u64(
      $.copy(bits__3)
        .shr($.copy(SHIFT_INSERTION_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
    u64(
      $.copy(bits__3)
        .shr($.copy(SHIFT_LIST_HEAD))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits__3)
        .shr($.copy(SHIFT_LIST_TAIL))
        .and(u128($.copy(HI_NODE_ID)))
    ),
  ];
}

export function would_update_head_(
  avlq_ref: AVLqueue,
  key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): boolean {
  let temp$1,
    temp$2,
    temp$3,
    ascending,
    bits,
    head_key,
    head_node_id,
    order_bit;
  if (!$.copy(key).le($.copy(HI_INSERTION_KEY))) {
    throw $.abortCode($.copy(E_INSERTION_KEY_TOO_LARGE));
  }
  bits = $.copy(avlq_ref.bits);
  [order_bit, head_node_id, head_key] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_SORT_ORDER))
        .and(u128($.copy(HI_BIT)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_HEAD_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_HEAD_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
  ];
  ascending = $.copy(order_bit).eq($.copy(BIT_FLAG_ASCENDING));
  if ($.copy(head_node_id).eq(u64($.copy(NIL)))) {
    return true;
  } else {
  }
  if (ascending) {
    temp$1 = $.copy(key).lt($.copy(head_key));
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    temp$3 = true;
  } else {
    if (!ascending) {
      temp$2 = $.copy(key).gt($.copy(head_key));
    } else {
      temp$2 = false;
    }
    temp$3 = temp$2;
  }
  return temp$3;
}

export function would_update_tail_(
  avlq_ref: AVLqueue,
  key: U64,
  $c: AptosDataCache,
  $p: TypeTag[] /* <V>*/
): boolean {
  let temp$1,
    temp$2,
    temp$3,
    ascending,
    bits,
    order_bit,
    tail_key,
    tail_node_id;
  if (!$.copy(key).le($.copy(HI_INSERTION_KEY))) {
    throw $.abortCode($.copy(E_INSERTION_KEY_TOO_LARGE));
  }
  bits = $.copy(avlq_ref.bits);
  [order_bit, tail_node_id, tail_key] = [
    u8(
      $.copy(bits)
        .shr($.copy(SHIFT_SORT_ORDER))
        .and(u128($.copy(HI_BIT)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_NODE_ID))
        .and(u128($.copy(HI_NODE_ID)))
    ),
    u64(
      $.copy(bits)
        .shr($.copy(SHIFT_TAIL_KEY))
        .and(u128($.copy(HI_INSERTION_KEY)))
    ),
  ];
  ascending = $.copy(order_bit).eq($.copy(BIT_FLAG_ASCENDING));
  if ($.copy(tail_node_id).eq(u64($.copy(NIL)))) {
    return true;
  } else {
  }
  if (ascending) {
    temp$1 = $.copy(key).ge($.copy(tail_key));
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    temp$3 = true;
  } else {
    if (!ascending) {
      temp$2 = $.copy(key).le($.copy(tail_key));
    } else {
      temp$2 = false;
    }
    temp$3 = temp$2;
  }
  return temp$3;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::avl_queue::AVLqueue",
    AVLqueue.AVLqueueParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::avl_queue::ListNode",
    ListNode.ListNodeParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::avl_queue::TreeNode",
    TreeNode.TreeNodeParser
  );
}
export class App {
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {}
  get moduleAddress() {
    {
      return moduleAddress;
    }
  }
  get moduleName() {
    {
      return moduleName;
    }
  }
  get AVLqueue() {
    return AVLqueue;
  }
  get ListNode() {
    return ListNode;
  }
  get TreeNode() {
    return TreeNode;
  }
}
