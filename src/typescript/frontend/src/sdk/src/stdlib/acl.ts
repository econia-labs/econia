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

import * as Error from "./error";
import * as Vector from "./vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "acl";

export const ECONTAIN: U64 = u64("0");
export const ENOT_CONTAIN: U64 = u64("1");

export class ACL {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ACL";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "list", typeTag: new VectorTag(AtomicTypeTag.Address) },
  ];

  list: HexString[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.list = proto["list"] as HexString[];
  }

  static ACLParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): ACL {
    const proto = $.parseStructProto(data, typeTag, repo, ACL);
    return new ACL(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ACL", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function add_(acl: ACL, addr: HexString, $c: AptosDataCache): void {
  let temp$1, temp$2;
  [temp$1, temp$2] = [acl.list, addr];
  if (Vector.contains_(temp$1, temp$2, $c, [AtomicTypeTag.Address])) {
    throw $.abortCode(Error.invalid_argument_($.copy(ECONTAIN), $c));
  }
  Vector.push_back_(acl.list, $.copy(addr), $c, [AtomicTypeTag.Address]);
  return;
}

export function assert_contains_(
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache
): void {
  if (!contains_(acl, $.copy(addr), $c)) {
    throw $.abortCode(Error.invalid_argument_($.copy(ENOT_CONTAIN), $c));
  }
  return;
}

export function contains_(
  acl: ACL,
  addr: HexString,
  $c: AptosDataCache
): boolean {
  return Vector.contains_(acl.list, addr, $c, [AtomicTypeTag.Address]);
}

export function empty_($c: AptosDataCache): ACL {
  return new ACL(
    { list: Vector.empty_($c, [AtomicTypeTag.Address]) },
    new SimpleStructTag(ACL)
  );
}

export function remove_(acl: ACL, addr: HexString, $c: AptosDataCache): void {
  let temp$1, temp$2, found, index;
  [temp$1, temp$2] = [acl.list, addr];
  [found, index] = Vector.index_of_(temp$1, temp$2, $c, [
    AtomicTypeTag.Address,
  ]);
  if (!found) {
    throw $.abortCode(Error.invalid_argument_($.copy(ENOT_CONTAIN), $c));
  }
  Vector.remove_(acl.list, $.copy(index), $c, [AtomicTypeTag.Address]);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::acl::ACL", ACL.ACLParser);
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
  get ACL() {
    return ACL;
  }
}
