import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, U64, U128 } from "@manahippo/move-to-ts";
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
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "table";

export class Box {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Box";
  static typeParameters: TypeParamDeclType[] = [
    { name: "V", isPhantom: false },
  ];
  static fields: FieldDeclType[] = [
    { name: "val", typeTag: new $.TypeParamIdx(0) },
  ];

  val: any;

  constructor(proto: any, public typeTag: TypeTag) {
    this.val = proto["val"] as any;
  }

  static BoxParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): Box {
    const proto = $.parseStructProto(data, typeTag, repo, Box);
    return new Box(proto, typeTag);
  }

  static async load(
    repo: AptosParserRepo,
    client: AptosClient,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await repo.loadResource(client, address, Box, typeParams);
    return result as unknown as Box;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Box,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Box;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Box", $p);
  }
  async loadFullState(app: $.AppType) {
    if (this.val.typeTag instanceof StructTag) {
      await this.val.loadFullState(app);
    }
    this.__app = app;
  }
}

export class Table {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Table";
  static typeParameters: TypeParamDeclType[] = [
    { name: "K", isPhantom: true },
    { name: "V", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "handle", typeTag: AtomicTypeTag.Address },
  ];

  handle: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.handle = proto["handle"] as HexString;
  }

  static TableParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Table {
    const proto = $.parseStructProto(data, typeTag, repo, Table);
    return new Table(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Table", $p);
  }

  toTypedTable<K = any, V = any>() {
    return TypedTable.fromTable<K, V>(this);
  }

  async loadFullState(app: $.AppType) {
    throw new Error("Cannot enumertate full state of Table");
  }
}
export function add_(
  table: Table,
  key: any,
  val: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): void {
  return add_box_(
    table,
    $.copy(key),
    new Box({ val: val }, new SimpleStructTag(Box, [$p[1]])),
    $c,
    [$p[0], $p[1], new SimpleStructTag(Box, [$p[1]])]
  );
}

export function add_box_(
  table: Table,
  key: any,
  val: Box,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): void {
  return $.aptos_std_table_add_box(table, key, val, $c, [$p[0], $p[1], $p[2]]);
}
export function borrow_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  return borrow_box_(table, $.copy(key), $c, [
    $p[0],
    $p[1],
    new SimpleStructTag(Box, [$p[1]]),
  ]).val;
}

export function borrow_box_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): Box {
  return $.aptos_std_table_borrow_box(table, key, $c, [$p[0], $p[1], $p[2]]);
}
export function borrow_box_mut_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): Box {
  return $.aptos_std_table_borrow_box_mut(table, key, $c, [
    $p[0],
    $p[1],
    $p[2],
  ]);
}
export function borrow_mut_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  return borrow_box_mut_(table, $.copy(key), $c, [
    $p[0],
    $p[1],
    new SimpleStructTag(Box, [$p[1]]),
  ]).val;
}

export function borrow_mut_with_default_(
  table: Table,
  key: any,
  default__: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  let temp$1, temp$2;
  [temp$1, temp$2] = [table, $.copy(key)];
  if (!contains_(temp$1, temp$2, $c, [$p[0], $p[1]])) {
    add_(table, $.copy(key), default__, $c, [$p[0], $p[1]]);
  } else {
  }
  return borrow_mut_(table, $.copy(key), $c, [$p[0], $p[1]]);
}

export function contains_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): boolean {
  return contains_box_(table, $.copy(key), $c, [
    $p[0],
    $p[1],
    new SimpleStructTag(Box, [$p[1]]),
  ]);
}

export function contains_box_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): boolean {
  return $.aptos_std_table_contains_box(table, key, $c, [$p[0], $p[1], $p[2]]);
}
export function destroy_(
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): void {
  destroy_empty_box_(table, $c, [
    $p[0],
    $p[1],
    new SimpleStructTag(Box, [$p[1]]),
  ]);
  return drop_unchecked_box_(table, $c, [
    $p[0],
    $p[1],
    new SimpleStructTag(Box, [$p[1]]),
  ]);
}

export function destroy_empty_box_(
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): void {
  return $.aptos_std_table_destroy_empty_box(table, $c, [$p[0], $p[1], $p[2]]);
}
export function drop_unchecked_box_(
  table: Table,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): void {
  return $.aptos_std_table_drop_unchecked_box(table, $c, [$p[0], $p[1], $p[2]]);
}
export function new___($c: AptosDataCache, $p: TypeTag[] /* <K, V>*/): Table {
  return new Table(
    { handle: new_table_handle_($c, [$p[0], $p[1]]) },
    new SimpleStructTag(Table, [$p[0], $p[1]])
  );
}

export function new_table_handle_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): HexString {
  return $.aptos_std_table_new_table_handle($c, [$p[0], $p[1]]);
}
export function remove_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): any {
  const { val: val } = remove_box_(table, $.copy(key), $c, [
    $p[0],
    $p[1],
    new SimpleStructTag(Box, [$p[1]]),
  ]);
  return val;
}

export function remove_box_(
  table: Table,
  key: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V, B>*/
): Box {
  return $.aptos_std_table_remove_box(table, key, $c, [$p[0], $p[1], $p[2]]);
}
export function upsert_(
  table: Table,
  key: any,
  value: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <K, V>*/
): void {
  let temp$1, temp$2, ref;
  [temp$1, temp$2] = [table, $.copy(key)];
  if (!contains_(temp$1, temp$2, $c, [$p[0], $p[1]])) {
    add_(table, $.copy(key), value, $c, [$p[0], $p[1]]);
  } else {
    ref = borrow_mut_(table, $.copy(key), $c, [$p[0], $p[1]]);
    $.set(ref, value);
  }
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::table::Box", Box.BoxParser);
  repo.addParser("0x1::table::Table", Table.TableParser);
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
  get Box() {
    return Box;
  }
  async loadBox(
    owner: HexString,
    $p: TypeTag[] /* <V> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await Box.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get Table() {
    return Table;
  }
}

export class TypedTable<K = any, V = any> {
  static fromTable<K = any, V = any>(table: Table): TypedTable<K, V> {
    const tag = table.typeTag;
    if (!(tag instanceof StructTag)) {
      throw new Error();
    }
    if (tag.getParamlessName() !== "0x1::table::Table") {
      throw new Error();
    }
    if (tag.typeParams.length !== 2) {
      throw new Error();
    }
    const [keyTag, valueTag] = tag.typeParams;
    return new TypedTable<K, V>(table, keyTag, valueTag);
  }

  constructor(
    public table: Table,
    public keyTag: TypeTag,
    public valueTag: TypeTag
  ) {}

  async loadEntryRaw(client: AptosClient, key: K): Promise<any> {
    return await client.getTableItem(this.table.handle.toString(), {
      key_type: $.getTypeTagFullname(this.keyTag),
      value_type: $.getTypeTagFullname(this.valueTag),
      key: $.moveValueToOpenApiObject(key, this.keyTag),
    });
  }

  async loadEntry(
    client: AptosClient,
    repo: AptosParserRepo,
    key: K
  ): Promise<V> {
    const rawVal = await this.loadEntryRaw(client, key);
    return repo.parse(rawVal, this.valueTag);
  }
}
