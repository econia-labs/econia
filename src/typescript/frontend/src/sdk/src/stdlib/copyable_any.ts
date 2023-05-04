import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, U128 } from "@manahippo/move-to-ts";
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

import * as Bcs from "./bcs";
import * as Error from "./error";
import * as From_bcs from "./from_bcs";
import type * as String from "./string";
import * as Type_info from "./type_info";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "copyable_any";

export const ETYPE_MISMATCH: U64 = u64("0");

export class Any {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Any";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "type_name",
      typeTag: new StructTag(new HexString("0x1"), "string", "String", []),
    },
    { name: "data", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  type_name: String.String;
  data: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.type_name = proto["type_name"] as String.String;
    this.data = proto["data"] as U8[];
  }

  static AnyParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): Any {
    const proto = $.parseStructProto(data, typeTag, repo, Any);
    return new Any(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Any", []);
  }
  async loadFullState(app: $.AppType) {
    await this.type_name.loadFullState(app);
    this.__app = app;
  }
}
export function pack_(x: any, $c: AptosDataCache, $p: TypeTag[] /* <T>*/): Any {
  return new Any(
    {
      type_name: Type_info.type_name_($c, [$p[0]]),
      data: Bcs.to_bytes_(x, $c, [$p[0]]),
    },
    new SimpleStructTag(Any)
  );
}

export function type_name_(x: Any, $c: AptosDataCache): String.String {
  return x.type_name;
}

export function unpack_(
  x: Any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): any {
  if (!$.deep_eq(Type_info.type_name_($c, [$p[0]]), $.copy(x.type_name))) {
    throw $.abortCode(Error.invalid_argument_($.copy(ETYPE_MISMATCH), $c));
  }
  return From_bcs.from_bytes_($.copy(x.data), $c, [$p[0]]);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::copyable_any::Any", Any.AnyParser);
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
  get Any() {
    return Any;
  }
}
