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
import * as Option from "./option";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "secp256k1";

export const E_DESERIALIZE: U64 = u64("1");
export const RAW_PUBLIC_KEY_NUM_BYTES: U64 = u64("64");
export const SIGNATURE_NUM_BYTES: U64 = u64("64");

export class ECDSARawPublicKey {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ECDSARawPublicKey";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static ECDSARawPublicKeyParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ECDSARawPublicKey {
    const proto = $.parseStructProto(data, typeTag, repo, ECDSARawPublicKey);
    return new ECDSARawPublicKey(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ECDSARawPublicKey", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ECDSASignature {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ECDSASignature";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static ECDSASignatureParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ECDSASignature {
    const proto = $.parseStructProto(data, typeTag, repo, ECDSASignature);
    return new ECDSASignature(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ECDSASignature", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function ecdsa_raw_public_key_from_64_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): ECDSARawPublicKey {
  if (
    !Vector.length_(bytes, $c, [AtomicTypeTag.U8]).eq(
      $.copy(RAW_PUBLIC_KEY_NUM_BYTES)
    )
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(E_DESERIALIZE), $c));
  }
  return new ECDSARawPublicKey(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(ECDSARawPublicKey)
  );
}

export function ecdsa_raw_public_key_to_bytes_(
  pk: ECDSARawPublicKey,
  $c: AptosDataCache
): U8[] {
  return $.copy(pk.bytes);
}

export function ecdsa_recover_(
  message: U8[],
  recovery_id: U8,
  signature: ECDSASignature,
  $c: AptosDataCache
): Option.Option {
  let temp$1, pk, success;
  [pk, success] = ecdsa_recover_internal_(
    $.copy(message),
    $.copy(recovery_id),
    $.copy(signature.bytes),
    $c
  );
  if (success) {
    temp$1 = Option.some_(
      ecdsa_raw_public_key_from_64_bytes_($.copy(pk), $c),
      $c,
      [new SimpleStructTag(ECDSARawPublicKey)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(ECDSARawPublicKey)]);
  }
  return temp$1;
}

export function ecdsa_recover_internal_(
  message: U8[],
  recovery_id: U8,
  signature: U8[],
  $c: AptosDataCache
): [U8[], boolean] {
  return $.aptos_std_secp256k1_ecdsa_recover_internal(
    message,
    recovery_id,
    signature,
    $c
  );
}
export function ecdsa_signature_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): ECDSASignature {
  if (
    !Vector.length_(bytes, $c, [AtomicTypeTag.U8]).eq(
      $.copy(SIGNATURE_NUM_BYTES)
    )
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(E_DESERIALIZE), $c));
  }
  return new ECDSASignature(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(ECDSASignature)
  );
}

export function ecdsa_signature_to_bytes_(
  sig: ECDSASignature,
  $c: AptosDataCache
): U8[] {
  return $.copy(sig.bytes);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::secp256k1::ECDSARawPublicKey",
    ECDSARawPublicKey.ECDSARawPublicKeyParser
  );
  repo.addParser(
    "0x1::secp256k1::ECDSASignature",
    ECDSASignature.ECDSASignatureParser
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
  get ECDSARawPublicKey() {
    return ECDSARawPublicKey;
  }
  get ECDSASignature() {
    return ECDSASignature;
  }
}
