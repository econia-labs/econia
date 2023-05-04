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
import * as Ed25519 from "./ed25519";
import * as Error from "./error";
import * as Hash from "./hash";
import * as Option from "./option";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "multi_ed25519";

export const BITMAP_NUM_OF_BYTES: U64 = u64("4");
export const E_INVALID_THRESHOLD_OR_NUMBER_OF_SIGNERS: U64 = u64("3");
export const E_WRONG_PUBKEY_SIZE: U64 = u64("1");
export const E_WRONG_SIGNATURE_SIZE: U64 = u64("2");
export const INDIVIDUAL_PUBLIC_KEY_NUM_BYTES: U64 = u64("32");
export const INDIVIDUAL_SIGNATURE_NUM_BYTES: U64 = u64("64");
export const MAX_NUMBER_OF_PUBLIC_KEYS: U64 = u64("32");
export const SIGNATURE_SCHEME_ID: U8 = u8("1");
export const THRESHOLD_SIZE_BYTES: U64 = u64("1");

export class Signature {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Signature";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static SignatureParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Signature {
    const proto = $.parseStructProto(data, typeTag, repo, Signature);
    return new Signature(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Signature", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class UnvalidatedPublicKey {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "UnvalidatedPublicKey";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static UnvalidatedPublicKeyParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): UnvalidatedPublicKey {
    const proto = $.parseStructProto(data, typeTag, repo, UnvalidatedPublicKey);
    return new UnvalidatedPublicKey(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "UnvalidatedPublicKey", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ValidatedPublicKey {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ValidatedPublicKey";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static ValidatedPublicKeyParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ValidatedPublicKey {
    const proto = $.parseStructProto(data, typeTag, repo, ValidatedPublicKey);
    return new ValidatedPublicKey(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ValidatedPublicKey", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function new_signature_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Signature {
  if (
    !Vector.length_(bytes, $c, [AtomicTypeTag.U8])
      .mod($.copy(INDIVIDUAL_SIGNATURE_NUM_BYTES))
      .eq($.copy(BITMAP_NUM_OF_BYTES))
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(E_WRONG_SIGNATURE_SIZE), $c)
    );
  }
  return new Signature(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(Signature)
  );
}

export function new_unvalidated_public_key_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): UnvalidatedPublicKey {
  if (
    !Vector.length_(bytes, $c, [AtomicTypeTag.U8])
      .div($.copy(INDIVIDUAL_PUBLIC_KEY_NUM_BYTES))
      .le($.copy(MAX_NUMBER_OF_PUBLIC_KEYS))
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(E_WRONG_PUBKEY_SIZE), $c));
  }
  if (
    !Vector.length_(bytes, $c, [AtomicTypeTag.U8])
      .mod($.copy(INDIVIDUAL_PUBLIC_KEY_NUM_BYTES))
      .eq($.copy(THRESHOLD_SIZE_BYTES))
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(E_WRONG_PUBKEY_SIZE), $c));
  }
  return new UnvalidatedPublicKey(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(UnvalidatedPublicKey)
  );
}

export function new_validated_public_key_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1, temp$2;
  if (
    Vector.length_(bytes, $c, [AtomicTypeTag.U8])
      .mod($.copy(INDIVIDUAL_PUBLIC_KEY_NUM_BYTES))
      .eq($.copy(THRESHOLD_SIZE_BYTES))
  ) {
    temp$1 = public_key_validate_internal_($.copy(bytes), $c);
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    temp$2 = Option.some_(
      new ValidatedPublicKey(
        { bytes: $.copy(bytes) },
        new SimpleStructTag(ValidatedPublicKey)
      ),
      $c,
      [new SimpleStructTag(ValidatedPublicKey)]
    );
  } else {
    temp$2 = Option.none_($c, [new SimpleStructTag(ValidatedPublicKey)]);
  }
  return temp$2;
}

export function public_key_bytes_to_authentication_key_(
  pk_bytes: U8[],
  $c: AptosDataCache
): U8[] {
  Vector.push_back_(pk_bytes, $.copy(SIGNATURE_SCHEME_ID), $c, [
    AtomicTypeTag.U8,
  ]);
  return Hash.sha3_256_($.copy(pk_bytes), $c);
}

export function public_key_into_unvalidated_(
  pk: ValidatedPublicKey,
  $c: AptosDataCache
): UnvalidatedPublicKey {
  return new UnvalidatedPublicKey(
    { bytes: $.copy(pk.bytes) },
    new SimpleStructTag(UnvalidatedPublicKey)
  );
}

export function public_key_to_unvalidated_(
  pk: ValidatedPublicKey,
  $c: AptosDataCache
): UnvalidatedPublicKey {
  return new UnvalidatedPublicKey(
    { bytes: $.copy(pk.bytes) },
    new SimpleStructTag(UnvalidatedPublicKey)
  );
}

export function public_key_validate_(
  pk: UnvalidatedPublicKey,
  $c: AptosDataCache
): Option.Option {
  return new_validated_public_key_from_bytes_($.copy(pk.bytes), $c);
}

export function public_key_validate_internal_(
  bytes: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_multi_ed25519_public_key_validate_internal(bytes, $c);
}
export function signature_to_bytes_(sig: Signature, $c: AptosDataCache): U8[] {
  return $.copy(sig.bytes);
}

export function signature_verify_strict_(
  multisignature: Signature,
  public_key: UnvalidatedPublicKey,
  message: U8[],
  $c: AptosDataCache
): boolean {
  return signature_verify_strict_internal_(
    $.copy(multisignature.bytes),
    $.copy(public_key.bytes),
    $.copy(message),
    $c
  );
}

export function signature_verify_strict_internal_(
  multisignature: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_multi_ed25519_signature_verify_strict_internal(
    multisignature,
    public_key,
    message,
    $c
  );
}
export function signature_verify_strict_t_(
  multisignature: Signature,
  public_key: UnvalidatedPublicKey,
  data: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): boolean {
  let encoded;
  encoded = Ed25519.new_signed_message_(data, $c, [$p[0]]);
  return signature_verify_strict_internal_(
    $.copy(multisignature.bytes),
    $.copy(public_key.bytes),
    Bcs.to_bytes_(encoded, $c, [
      new StructTag(new HexString("0x1"), "ed25519", "SignedMessage", [$p[0]]),
    ]),
    $c
  );
}

export function unvalidated_public_key_to_authentication_key_(
  pk: UnvalidatedPublicKey,
  $c: AptosDataCache
): U8[] {
  return public_key_bytes_to_authentication_key_($.copy(pk.bytes), $c);
}

export function unvalidated_public_key_to_bytes_(
  pk: UnvalidatedPublicKey,
  $c: AptosDataCache
): U8[] {
  return $.copy(pk.bytes);
}

export function validated_public_key_to_authentication_key_(
  pk: ValidatedPublicKey,
  $c: AptosDataCache
): U8[] {
  return public_key_bytes_to_authentication_key_($.copy(pk.bytes), $c);
}

export function validated_public_key_to_bytes_(
  pk: ValidatedPublicKey,
  $c: AptosDataCache
): U8[] {
  return $.copy(pk.bytes);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::multi_ed25519::Signature", Signature.SignatureParser);
  repo.addParser(
    "0x1::multi_ed25519::UnvalidatedPublicKey",
    UnvalidatedPublicKey.UnvalidatedPublicKeyParser
  );
  repo.addParser(
    "0x1::multi_ed25519::ValidatedPublicKey",
    ValidatedPublicKey.ValidatedPublicKeyParser
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
  get Signature() {
    return Signature;
  }
  get UnvalidatedPublicKey() {
    return UnvalidatedPublicKey;
  }
  get ValidatedPublicKey() {
    return ValidatedPublicKey;
  }
}
