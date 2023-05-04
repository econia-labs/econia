import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, U128 } from "@manahippo/move-to-ts";
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
export const moduleName = "tablist";

export const E_DESTROY_NOT_EMPTY: U64 = u64("0");

export class Node {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Node";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    { name: "value", typeTag: new $.TypeParamIdx(1) },
    {
      name: "previous",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "next",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new $.TypeParamIdx(0),
      ]),
    },
  ];

  value: any;
  previous: Stdlib.Option.Option;
  next: Stdlib.Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.value = proto["value"] as any;
    this.previous = proto["previous"] as Stdlib.Option.Option;
    this.next = proto["next"] as Stdlib.Option.Option;
  }

  static NodeParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): Node {
    const proto = $.parseStructProto(data, typeTag, repo, Node);
    return new Node(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Node", $p);
  }
  async loadFullState(app: $.AppType) {
    if (this.value.typeTag instanceof StructTag) {
      await this.value.loadFullState(app);
    }
    await this.previous.loadFullState(app);
    await this.next.loadFullState(app);
    this.__app = app;
  }
}

export class Tablist {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Tablist";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: false },
    { name: "V", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    {
      name: "table",
      typeTag: new StructTag(
        new HexString("0x1"),
        "table_with_length",
        "TableWithLength",
        [
          new $.TypeParamIdx(0),
          new StructTag(
            new HexString(
              "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
            ),
            "tablist",
            "Node",
            [new $.TypeParamIdx(0), new $.TypeParamIdx(1)]
          ),
        ]
      ),
    },
    {
      name: "head",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new $.TypeParamIdx(0),
      ]),
    },
    {
      name: "tail",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new $.TypeParamIdx(0),
      ]),
    },
  ];

  table: Stdlib.Table_with_length.TableWithLength;
  head: Stdlib.Option.Option;
  tail: Stdlib.Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.table = proto["table"] as Stdlib.Table_with_length.TableWithLength;
    this.head = proto["head"] as Stdlib.Option.Option;
    this.tail = proto["tail"] as Stdlib.Option.Option;
  }

  static TablistParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Tablist {
    const proto = $.parseStructProto(data, typeTag, repo, Tablist);
    return new Tablist(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Tablist", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.table.loadFullState(app);
    await this.head.loadFullState(app);
    await this.tail.loadFullState(app);
    this.__app = app;
  }
}
export function add_(
  tablist_ref_mut: Tablist,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): void {
  let node, old_tail;
  node = new Node(
    {
      value: value,
      previous: $.copy(tablist_ref_mut.tail),
      next: Stdlib.Option.none_($c, [$p[0]]),
    },
    new SimpleStructTag(Node, [$p[0], $p[1]])
  );
  Stdlib.Table_with_length.add_(tablist_ref_mut.table, $.copy(key), node, $c, [
    $p[0],
    new SimpleStructTag(Node, [$p[0], $p[1]]),
  ]);
  if (Stdlib.Option.is_none_(tablist_ref_mut.head, $c, [$p[0]])) {
    tablist_ref_mut.head = Stdlib.Option.some_($.copy(key), $c, [$p[0]]);
  } else {
    old_tail = Stdlib.Option.borrow_(tablist_ref_mut.tail, $c, [$p[0]]);
    Stdlib.Table_with_length.borrow_mut_(
      tablist_ref_mut.table,
      $.copy(old_tail),
      $c,
      [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
    ).next = Stdlib.Option.some_($.copy(key), $c, [$p[0]]);
  }
  tablist_ref_mut.tail = Stdlib.Option.some_($.copy(key), $c, [$p[0]]);
  return;
}

export function borrow_(
  tablist_ref: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  return Stdlib.Table_with_length.borrow_(tablist_ref.table, $.copy(key), $c, [
    $p[0],
    new SimpleStructTag(Node, [$p[0], $p[1]]),
  ]).value;
}

export function borrow_iterable_(
  tablist_ref: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): [any, Stdlib.Option.Option, Stdlib.Option.Option] {
  let node_ref;
  node_ref = Stdlib.Table_with_length.borrow_(
    tablist_ref.table,
    $.copy(key),
    $c,
    [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
  );
  return [node_ref.value, $.copy(node_ref.previous), $.copy(node_ref.next)];
}

export function borrow_iterable_mut_(
  tablist_ref_mut: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): [any, Stdlib.Option.Option, Stdlib.Option.Option] {
  let node_ref_mut;
  node_ref_mut = Stdlib.Table_with_length.borrow_mut_(
    tablist_ref_mut.table,
    $.copy(key),
    $c,
    [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
  );
  return [
    node_ref_mut.value,
    $.copy(node_ref_mut.previous),
    $.copy(node_ref_mut.next),
  ];
}

export function borrow_mut_(
  tablist_ref_mut: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  return Stdlib.Table_with_length.borrow_mut_(
    tablist_ref_mut.table,
    $.copy(key),
    $c,
    [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
  ).value;
}

export function contains_(
  tablist_ref: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): boolean {
  return Stdlib.Table_with_length.contains_(
    tablist_ref.table,
    $.copy(key),
    $c,
    [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
  );
}

export function destroy_empty_(
  tablist: Tablist,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): void {
  if (!is_empty_(tablist, $c, [$p[0], $p[1]])) {
    throw $.abortCode($.copy(E_DESTROY_NOT_EMPTY));
  }
  const { table: table } = tablist;
  Stdlib.Table_with_length.destroy_empty_(table, $c, [
    $p[0],
    new SimpleStructTag(Node, [$p[0], $p[1]]),
  ]);
  return;
}

export function get_head_key_(
  tablist_ref: Tablist,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): Stdlib.Option.Option {
  return $.copy(tablist_ref.head);
}

export function get_tail_key_(
  tablist_ref: Tablist,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): Stdlib.Option.Option {
  return $.copy(tablist_ref.tail);
}

export function is_empty_(
  tablist_ref: Tablist,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): boolean {
  return Stdlib.Table_with_length.empty_(tablist_ref.table, $c, [
    $p[0],
    new SimpleStructTag(Node, [$p[0], $p[1]]),
  ]);
}

export function length_(
  tablist_ref: Tablist,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): U64 {
  return Stdlib.Table_with_length.length_(tablist_ref.table, $c, [
    $p[0],
    new SimpleStructTag(Node, [$p[0], $p[1]]),
  ]);
}

export function new___($c: AptosDataCache, $p: TypeTag[] /* <K, V>*/): Tablist {
  return new Tablist(
    {
      table: Stdlib.Table_with_length.new___($c, [
        $p[0],
        new SimpleStructTag(Node, [$p[0], $p[1]]),
      ]),
      head: Stdlib.Option.none_($c, [$p[0]]),
      tail: Stdlib.Option.none_($c, [$p[0]]),
    },
    new SimpleStructTag(Tablist, [$p[0], $p[1]])
  );
}

export function remove_(
  tablist_ref_mut: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  let value;
  [value, ,] = remove_iterable_(tablist_ref_mut, $.copy(key), $c, [
    $p[0],
    $p[1],
  ]);
  return value;
}

export function remove_iterable_(
  tablist_ref_mut: Tablist,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): [any, Stdlib.Option.Option, Stdlib.Option.Option] {
  const {
    value: value,
    previous: previous,
    next: next,
  } = Stdlib.Table_with_length.remove_(tablist_ref_mut.table, $.copy(key), $c, [
    $p[0],
    new SimpleStructTag(Node, [$p[0], $p[1]]),
  ]);
  if (Stdlib.Option.is_none_(previous, $c, [$p[0]])) {
    tablist_ref_mut.head = $.copy(next);
  } else {
    Stdlib.Table_with_length.borrow_mut_(
      tablist_ref_mut.table,
      $.copy(Stdlib.Option.borrow_(previous, $c, [$p[0]])),
      $c,
      [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
    ).next = $.copy(next);
  }
  if (Stdlib.Option.is_none_(next, $c, [$p[0]])) {
    tablist_ref_mut.tail = $.copy(previous);
  } else {
    Stdlib.Table_with_length.borrow_mut_(
      tablist_ref_mut.table,
      $.copy(Stdlib.Option.borrow_(next, $c, [$p[0]])),
      $c,
      [$p[0], new SimpleStructTag(Node, [$p[0], $p[1]])]
    ).previous = $.copy(previous);
  }
  return [value, $.copy(previous), $.copy(next)];
}

export function singleton_(
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): Tablist {
  let tablist;
  tablist = new___($c, [$p[0], $p[1]]);
  add_(tablist, $.copy(key), value, $c, [$p[0], $p[1]]);
  return tablist;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::tablist::Node",
    Node.NodeParser
  );
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::tablist::Tablist",
    Tablist.TablistParser
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
  get Node() {
    return Node;
  }
  get Tablist() {
    return Tablist;
  }
}
