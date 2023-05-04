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
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "guid";

export const EGUID_GENERATOR_NOT_PUBLISHED: U64 = u64("0");

export class GUID {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GUID";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "id",
      typeTag: new StructTag(new HexString("0x1"), "guid", "ID", []),
    },
  ];

  id: ID;

  constructor(proto: any, public typeTag: TypeTag) {
    this.id = proto["id"] as ID;
  }

  static GUIDParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): GUID {
    const proto = $.parseStructProto(data, typeTag, repo, GUID);
    return new GUID(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GUID", []);
  }
  async loadFullState(app: $.AppType) {
    await this.id.loadFullState(app);
    this.__app = app;
  }
}

export class ID {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ID";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "creation_num", typeTag: AtomicTypeTag.U64 },
    { name: "addr", typeTag: AtomicTypeTag.Address },
  ];

  creation_num: U64;
  addr: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.creation_num = proto["creation_num"] as U64;
    this.addr = proto["addr"] as HexString;
  }

  static IDParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): ID {
    const proto = $.parseStructProto(data, typeTag, repo, ID);
    return new ID(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ID", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function create_(
  addr: HexString,
  creation_num_ref: U64,
  $c: AptosDataCache
): GUID {
  let creation_num;
  creation_num = $.copy(creation_num_ref);
  $.set(creation_num_ref, $.copy(creation_num).add(u64("1")));
  return new GUID(
    {
      id: new ID(
        { creation_num: $.copy(creation_num), addr: $.copy(addr) },
        new SimpleStructTag(ID)
      ),
    },
    new SimpleStructTag(GUID)
  );
}

export function create_id_(
  addr: HexString,
  creation_num: U64,
  $c: AptosDataCache
): ID {
  return new ID(
    { creation_num: $.copy(creation_num), addr: $.copy(addr) },
    new SimpleStructTag(ID)
  );
}

export function creation_num_(guid: GUID, $c: AptosDataCache): U64 {
  return $.copy(guid.id.creation_num);
}

export function creator_address_(guid: GUID, $c: AptosDataCache): HexString {
  return $.copy(guid.id.addr);
}

export function eq_id_(guid: GUID, id: ID, $c: AptosDataCache): boolean {
  return $.deep_eq(guid.id, id);
}

export function id_(guid: GUID, $c: AptosDataCache): ID {
  return $.copy(guid.id);
}

export function id_creation_num_(id: ID, $c: AptosDataCache): U64 {
  return $.copy(id.creation_num);
}

export function id_creator_address_(id: ID, $c: AptosDataCache): HexString {
  return $.copy(id.addr);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::guid::GUID", GUID.GUIDParser);
  repo.addParser("0x1::guid::ID", ID.IDParser);
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
  get GUID() {
    return GUID;
  }
  get ID() {
    return ID;
  }
}
