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
import * as Signer from "./signer";
import * as Vector from "./vector";
export const packageName = "MoveStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "features";

export const APTOS_STD_CHAIN_ID_NATIVES: U64 = u64("4");
export const CODE_DEPENDENCY_CHECK: U64 = u64("1");
export const EFRAMEWORK_SIGNER_NEEDED: U64 = u64("1");
export const SHA_512_AND_RIPEMD_160_NATIVES: U64 = u64("3");
export const TREAT_FRIEND_AS_PRIVATE: U64 = u64("2");

export class Features {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Features";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "features", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  features: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.features = proto["features"] as U8[];
  }

  static FeaturesParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Features {
    const proto = $.parseStructProto(data, typeTag, repo, Features);
    return new Features(proto, typeTag);
  }

  static async load(
    repo: AptosParserRepo,
    client: AptosClient,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await repo.loadResource(
      client,
      address,
      Features,
      typeParams
    );
    return result as unknown as Features;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Features,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Features;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Features", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function aptos_stdlib_chain_id_enabled_($c: AptosDataCache): boolean {
  return is_enabled_($.copy(APTOS_STD_CHAIN_ID_NATIVES), $c);
}

export function change_feature_flags_(
  framework: HexString,
  enable: U64[],
  disable: U64[],
  $c: AptosDataCache
): void {
  let features, i, i__1, n, n__2;
  if (
    !(Signer.address_of_(framework, $c).hex() === new HexString("0x1").hex())
  ) {
    throw $.abortCode(
      Error.permission_denied_($.copy(EFRAMEWORK_SIGNER_NEEDED), $c)
    );
  }
  if (!$c.exists(new SimpleStructTag(Features), new HexString("0x1"))) {
    $c.move_to(
      new SimpleStructTag(Features),
      framework,
      new Features({ features: [] as U8[] }, new SimpleStructTag(Features))
    );
  } else {
  }
  features = $c.borrow_global_mut<Features>(
    new SimpleStructTag(Features),
    new HexString("0x1")
  ).features;
  i = u64("0");
  n = Vector.length_(enable, $c, [AtomicTypeTag.U64]);
  while ($.copy(i).lt($.copy(n))) {
    {
      set_(
        features,
        $.copy(Vector.borrow_(enable, $.copy(i), $c, [AtomicTypeTag.U64])),
        true,
        $c
      );
      i = $.copy(i).add(u64("1"));
    }
  }
  i__1 = u64("0");
  n__2 = Vector.length_(disable, $c, [AtomicTypeTag.U64]);
  while ($.copy(i__1).lt($.copy(n__2))) {
    {
      set_(
        features,
        $.copy(Vector.borrow_(disable, $.copy(i__1), $c, [AtomicTypeTag.U64])),
        false,
        $c
      );
      i__1 = $.copy(i__1).add(u64("1"));
    }
  }
  return;
}

export function code_dependency_check_enabled_($c: AptosDataCache): boolean {
  return is_enabled_($.copy(CODE_DEPENDENCY_CHECK), $c);
}

export function contains_(
  features: U8[],
  feature: U64,
  $c: AptosDataCache
): boolean {
  let temp$1, bit_mask, byte_index;
  byte_index = $.copy(feature).div(u64("8"));
  bit_mask = u8("1").shl(u8($.copy(feature).mod(u64("8"))));
  if ($.copy(byte_index).lt(Vector.length_(features, $c, [AtomicTypeTag.U8]))) {
    temp$1 = $.copy(
      Vector.borrow_(features, $.copy(byte_index), $c, [AtomicTypeTag.U8])
    )
      .and($.copy(bit_mask))
      .neq(u8("0"));
  } else {
    temp$1 = false;
  }
  return temp$1;
}

export function get_aptos_stdlib_chain_id_feature_($c: AptosDataCache): U64 {
  return $.copy(APTOS_STD_CHAIN_ID_NATIVES);
}

export function get_sha_512_and_ripemd_160_feature_($c: AptosDataCache): U64 {
  return $.copy(SHA_512_AND_RIPEMD_160_NATIVES);
}

export function is_enabled_(feature: U64, $c: AptosDataCache): boolean {
  let temp$1;
  if ($c.exists(new SimpleStructTag(Features), new HexString("0x1"))) {
    temp$1 = contains_(
      $c.borrow_global<Features>(
        new SimpleStructTag(Features),
        new HexString("0x1")
      ).features,
      $.copy(feature),
      $c
    );
  } else {
    temp$1 = false;
  }
  return temp$1;
}

export function set_(
  features: U8[],
  feature: U64,
  include: boolean,
  $c: AptosDataCache
): void {
  let bit_mask, byte_index, entry;
  byte_index = $.copy(feature).div(u64("8"));
  bit_mask = u8("1").shl(u8($.copy(feature).mod(u64("8"))));
  while (
    Vector.length_(features, $c, [AtomicTypeTag.U8]).le($.copy(byte_index))
  ) {
    {
      Vector.push_back_(features, u8("0"), $c, [AtomicTypeTag.U8]);
    }
  }
  entry = Vector.borrow_mut_(features, $.copy(byte_index), $c, [
    AtomicTypeTag.U8,
  ]);
  if (include) {
    $.set(entry, $.copy(entry).or($.copy(bit_mask)));
  } else {
    $.set(entry, $.copy(entry).and(u8("255").xor($.copy(bit_mask))));
  }
  return;
}

export function sha_512_and_ripemd_160_enabled_($c: AptosDataCache): boolean {
  return is_enabled_($.copy(SHA_512_AND_RIPEMD_160_NATIVES), $c);
}

export function treat_friend_as_private_($c: AptosDataCache): boolean {
  return is_enabled_($.copy(TREAT_FRIEND_AS_PRIVATE), $c);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::features::Features", Features.FeaturesParser);
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
  get Features() {
    return Features;
  }
  async loadFeatures(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Features.load(
      this.repo,
      this.client,
      owner,
      [] as TypeTag[]
    );
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
}
