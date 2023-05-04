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

import * as Error from "./error";
import * as Features from "./features";
import type * as String from "./string";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "type_info";

export const E_NATIVE_FUN_NOT_AVAILABLE: U64 = u64("1");

export class TypeInfo {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "TypeInfo";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "account_address", typeTag: AtomicTypeTag.Address },
    { name: "module_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "struct_name", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  account_address: HexString;
  module_name: U8[];
  struct_name: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.account_address = proto["account_address"] as HexString;
    this.module_name = proto["module_name"] as U8[];
    this.struct_name = proto["struct_name"] as U8[];
  }

  static TypeInfoParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): TypeInfo {
    const proto = $.parseStructProto(data, typeTag, repo, TypeInfo);
    return new TypeInfo(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "TypeInfo", []);
  }
  typeFullname(): string {
    return `${this.account_address.toShortString()}::${$.u8str(
      this.module_name
    )}::${$.u8str(this.struct_name)}`;
  }
  toTypeTag() {
    return $.parseTypeTagOrThrow(this.typeFullname());
  }
  moduleName() {
    return (this.toTypeTag() as $.StructTag).module;
  }
  structName() {
    return (this.toTypeTag() as $.StructTag).name;
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function account_address_(
  type_info: TypeInfo,
  $c: AptosDataCache
): HexString {
  return $.copy(type_info.account_address);
}

export function chain_id_($c: AptosDataCache): U8 {
  if (!Features.aptos_stdlib_chain_id_enabled_($c)) {
    throw $.abortCode(
      Error.invalid_state_($.copy(E_NATIVE_FUN_NOT_AVAILABLE), $c)
    );
  } else {
  }
  return chain_id_internal_($c);
}

export function chain_id_internal_($c: AptosDataCache): U8 {
  return $.aptos_std_type_info_chain_id_internal($c);
}
export function module_name_(type_info: TypeInfo, $c: AptosDataCache): U8[] {
  return $.copy(type_info.module_name);
}

export function struct_name_(type_info: TypeInfo, $c: AptosDataCache): U8[] {
  return $.copy(type_info.struct_name);
}

export function type_name_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): String.String {
  return $.aptos_std_type_info_type_name($c, [$p[0]]);
}
export function type_of_($c: AptosDataCache, $p: TypeTag[] /* <T>*/): TypeInfo {
  return $.aptos_std_type_info_type_of($c, [$p[0]]);
}
export function verify_type_of_($c: AptosDataCache): void {
  let account_address, module_name, struct_name, type_info;
  type_info = type_of_($c, [new SimpleStructTag(TypeInfo)]);
  account_address = account_address_(type_info, $c);
  module_name = module_name_(type_info, $c);
  struct_name = struct_name_(type_info, $c);
  return;
}

export function verify_type_of_generic_(
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): void {
  let account_address, module_name, struct_name, type_info;
  type_info = type_of_($c, [$p[0]]);
  account_address = account_address_(type_info, $c);
  module_name = module_name_(type_info, $c);
  struct_name = struct_name_(type_info, $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::type_info::TypeInfo", TypeInfo.TypeInfoParser);
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
  get TypeInfo() {
    return TypeInfo;
  }
}
