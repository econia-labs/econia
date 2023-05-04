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
export const moduleName = "bls12381";

export const EWRONG_SIZE: U64 = u64("2");
export const EZERO_PUBKEYS: U64 = u64("1");
export const PUBLIC_KEY_NUM_BYTES: U64 = u64("48");
export const RANDOM_PK: U8[] = [
  u8("138"),
  u8("83"),
  u8("231"),
  u8("174"),
  u8("82"),
  u8("112"),
  u8("227"),
  u8("231"),
  u8("101"),
  u8("205"),
  u8("138"),
  u8("64"),
  u8("50"),
  u8("194"),
  u8("231"),
  u8("124"),
  u8("111"),
  u8("126"),
  u8("135"),
  u8("164"),
  u8("78"),
  u8("187"),
  u8("133"),
  u8("191"),
  u8("40"),
  u8("164"),
  u8("215"),
  u8("134"),
  u8("85"),
  u8("101"),
  u8("105"),
  u8("143"),
  u8("151"),
  u8("83"),
  u8("70"),
  u8("113"),
  u8("66"),
  u8("98"),
  u8("249"),
  u8("228"),
  u8("124"),
  u8("111"),
  u8("62"),
  u8("13"),
  u8("93"),
  u8("149"),
  u8("22"),
  u8("96"),
];
export const RANDOM_SIGNATURE: U8[] = [
  u8("160"),
  u8("26"),
  u8("101"),
  u8("133"),
  u8("79"),
  u8("152"),
  u8("125"),
  u8("52"),
  u8("52"),
  u8("20"),
  u8("155"),
  u8("127"),
  u8("8"),
  u8("247"),
  u8("7"),
  u8("48"),
  u8("227"),
  u8("11"),
  u8("36"),
  u8("25"),
  u8("132"),
  u8("232"),
  u8("113"),
  u8("43"),
  u8("194"),
  u8("172"),
  u8("168"),
  u8("133"),
  u8("214"),
  u8("50"),
  u8("170"),
  u8("252"),
  u8("237"),
  u8("76"),
  u8("63"),
  u8("102"),
  u8("18"),
  u8("9"),
  u8("222"),
  u8("187"),
  u8("107"),
  u8("28"),
  u8("134"),
  u8("1"),
  u8("50"),
  u8("102"),
  u8("35"),
  u8("204"),
  u8("22"),
  u8("202"),
  u8("47"),
  u8("108"),
  u8("158"),
  u8("220"),
  u8("83"),
  u8("183"),
  u8("184"),
  u8("139"),
  u8("116"),
  u8("53"),
  u8("251"),
  u8("107"),
  u8("5"),
  u8("221"),
  u8("236"),
  u8("228"),
  u8("24"),
  u8("210"),
  u8("195"),
  u8("77"),
  u8("198"),
  u8("172"),
  u8("162"),
  u8("245"),
  u8("161"),
  u8("26"),
  u8("121"),
  u8("230"),
  u8("119"),
  u8("116"),
  u8("88"),
  u8("44"),
  u8("20"),
  u8("8"),
  u8("74"),
  u8("1"),
  u8("220"),
  u8("183"),
  u8("130"),
  u8("14"),
  u8("76"),
  u8("180"),
  u8("186"),
  u8("208"),
  u8("234"),
  u8("141"),
];
export const SIGNATURE_SIZE: U64 = u64("96");

export class AggrOrMultiSignature {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AggrOrMultiSignature";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static AggrOrMultiSignatureParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AggrOrMultiSignature {
    const proto = $.parseStructProto(data, typeTag, repo, AggrOrMultiSignature);
    return new AggrOrMultiSignature(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AggrOrMultiSignature", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class AggrPublicKeysWithPoP {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AggrPublicKeysWithPoP";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static AggrPublicKeysWithPoPParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AggrPublicKeysWithPoP {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      AggrPublicKeysWithPoP
    );
    return new AggrPublicKeysWithPoP(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "AggrPublicKeysWithPoP",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class ProofOfPossession {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "ProofOfPossession";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static ProofOfPossessionParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): ProofOfPossession {
    const proto = $.parseStructProto(data, typeTag, repo, ProofOfPossession);
    return new ProofOfPossession(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "ProofOfPossession", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class PublicKey {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "PublicKey";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static PublicKeyParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): PublicKey {
    const proto = $.parseStructProto(data, typeTag, repo, PublicKey);
    return new PublicKey(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "PublicKey", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class PublicKeyWithPoP {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "PublicKeyWithPoP";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "bytes", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  bytes: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.bytes = proto["bytes"] as U8[];
  }

  static PublicKeyWithPoPParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): PublicKeyWithPoP {
    const proto = $.parseStructProto(data, typeTag, repo, PublicKeyWithPoP);
    return new PublicKeyWithPoP(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "PublicKeyWithPoP", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

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
export function aggr_or_multi_signature_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): AggrOrMultiSignature {
  if (
    !Vector.length_(bytes, $c, [AtomicTypeTag.U8]).eq($.copy(SIGNATURE_SIZE))
  ) {
    throw $.abortCode(Error.invalid_argument_($.copy(EWRONG_SIZE), $c));
  }
  return new AggrOrMultiSignature(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(AggrOrMultiSignature)
  );
}

export function aggr_or_multi_signature_subgroup_check_(
  signature: AggrOrMultiSignature,
  $c: AptosDataCache
): boolean {
  return signature_subgroup_check_internal_($.copy(signature.bytes), $c);
}

export function aggr_or_multi_signature_to_bytes_(
  sig: AggrOrMultiSignature,
  $c: AptosDataCache
): U8[] {
  return $.copy(sig.bytes);
}

export function aggregate_pubkey_to_bytes_(
  apk: AggrPublicKeysWithPoP,
  $c: AptosDataCache
): U8[] {
  return $.copy(apk.bytes);
}

export function aggregate_pubkeys_(
  public_keys: PublicKeyWithPoP[],
  $c: AptosDataCache
): AggrPublicKeysWithPoP {
  let bytes, success;
  [bytes, success] = aggregate_pubkeys_internal_($.copy(public_keys), $c);
  if (!success) {
    throw $.abortCode(Error.invalid_argument_($.copy(EZERO_PUBKEYS), $c));
  }
  return new AggrPublicKeysWithPoP(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(AggrPublicKeysWithPoP)
  );
}

export function aggregate_pubkeys_internal_(
  public_keys: PublicKeyWithPoP[],
  $c: AptosDataCache
): [U8[], boolean] {
  return $.aptos_std_bls12381_aggregate_pubkeys_internal(public_keys, $c);
}
export function aggregate_signatures_(
  signatures: Signature[],
  $c: AptosDataCache
): Option.Option {
  let temp$1, bytes, success;
  [bytes, success] = aggregate_signatures_internal_($.copy(signatures), $c);
  if (success) {
    temp$1 = Option.some_(
      new AggrOrMultiSignature(
        { bytes: $.copy(bytes) },
        new SimpleStructTag(AggrOrMultiSignature)
      ),
      $c,
      [new SimpleStructTag(AggrOrMultiSignature)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(AggrOrMultiSignature)]);
  }
  return temp$1;
}

export function aggregate_signatures_internal_(
  signatures: Signature[],
  $c: AptosDataCache
): [U8[], boolean] {
  return $.aptos_std_bls12381_aggregate_signatures_internal(signatures, $c);
}
export function proof_of_possession_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): ProofOfPossession {
  return new ProofOfPossession(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(ProofOfPossession)
  );
}

export function proof_of_possession_to_bytes_(
  pop: ProofOfPossession,
  $c: AptosDataCache
): U8[] {
  return $.copy(pop.bytes);
}

export function public_key_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (validate_pubkey_internal_($.copy(bytes), $c)) {
    temp$1 = Option.some_(
      new PublicKey({ bytes: $.copy(bytes) }, new SimpleStructTag(PublicKey)),
      $c,
      [new SimpleStructTag(PublicKey)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(PublicKey)]);
  }
  return temp$1;
}

export function public_key_from_bytes_with_pop_(
  pk_bytes: U8[],
  pop: ProofOfPossession,
  $c: AptosDataCache
): Option.Option {
  let temp$1;
  if (
    verify_proof_of_possession_internal_(
      $.copy(pk_bytes),
      $.copy(pop.bytes),
      $c
    )
  ) {
    temp$1 = Option.some_(
      new PublicKeyWithPoP(
        { bytes: $.copy(pk_bytes) },
        new SimpleStructTag(PublicKeyWithPoP)
      ),
      $c,
      [new SimpleStructTag(PublicKeyWithPoP)]
    );
  } else {
    temp$1 = Option.none_($c, [new SimpleStructTag(PublicKeyWithPoP)]);
  }
  return temp$1;
}

export function public_key_to_bytes_(pk: PublicKey, $c: AptosDataCache): U8[] {
  return $.copy(pk.bytes);
}

export function public_key_with_pop_to_bytes_(
  pk: PublicKeyWithPoP,
  $c: AptosDataCache
): U8[] {
  return $.copy(pk.bytes);
}

export function signature_from_bytes_(
  bytes: U8[],
  $c: AptosDataCache
): Signature {
  return new Signature(
    { bytes: $.copy(bytes) },
    new SimpleStructTag(Signature)
  );
}

export function signature_subgroup_check_(
  signature: Signature,
  $c: AptosDataCache
): boolean {
  return signature_subgroup_check_internal_($.copy(signature.bytes), $c);
}

export function signature_subgroup_check_internal_(
  signature: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_signature_subgroup_check_internal(signature, $c);
}
export function signature_to_bytes_(sig: Signature, $c: AptosDataCache): U8[] {
  return $.copy(sig.bytes);
}

export function validate_pubkey_internal_(
  public_key: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_validate_pubkey_internal(public_key, $c);
}
export function verify_aggregate_signature_(
  aggr_sig: AggrOrMultiSignature,
  public_keys: PublicKeyWithPoP[],
  messages: U8[][],
  $c: AptosDataCache
): boolean {
  return verify_aggregate_signature_internal_(
    $.copy(aggr_sig.bytes),
    $.copy(public_keys),
    $.copy(messages),
    $c
  );
}

export function verify_aggregate_signature_internal_(
  aggsig: U8[],
  public_keys: PublicKeyWithPoP[],
  messages: U8[][],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_verify_aggregate_signature_internal(
    aggsig,
    public_keys,
    messages,
    $c
  );
}
export function verify_multisignature_(
  multisig: AggrOrMultiSignature,
  aggr_public_key: AggrPublicKeysWithPoP,
  message: U8[],
  $c: AptosDataCache
): boolean {
  return verify_multisignature_internal_(
    $.copy(multisig.bytes),
    $.copy(aggr_public_key.bytes),
    $.copy(message),
    $c
  );
}

export function verify_multisignature_internal_(
  multisignature: U8[],
  agg_public_key: U8[],
  message: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_verify_multisignature_internal(
    multisignature,
    agg_public_key,
    message,
    $c
  );
}
export function verify_normal_signature_(
  signature: Signature,
  public_key: PublicKey,
  message: U8[],
  $c: AptosDataCache
): boolean {
  return verify_normal_signature_internal_(
    $.copy(signature.bytes),
    $.copy(public_key.bytes),
    $.copy(message),
    $c
  );
}

export function verify_normal_signature_internal_(
  signature: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_verify_normal_signature_internal(
    signature,
    public_key,
    message,
    $c
  );
}
export function verify_proof_of_possession_internal_(
  public_key: U8[],
  proof_of_possesion: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_verify_proof_of_possession_internal(
    public_key,
    proof_of_possesion,
    $c
  );
}
export function verify_signature_share_(
  signature_share: Signature,
  public_key: PublicKeyWithPoP,
  message: U8[],
  $c: AptosDataCache
): boolean {
  return verify_signature_share_internal_(
    $.copy(signature_share.bytes),
    $.copy(public_key.bytes),
    $.copy(message),
    $c
  );
}

export function verify_signature_share_internal_(
  signature_share: U8[],
  public_key: U8[],
  message: U8[],
  $c: AptosDataCache
): boolean {
  return $.aptos_std_bls12381_verify_signature_share_internal(
    signature_share,
    public_key,
    message,
    $c
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::bls12381::AggrOrMultiSignature",
    AggrOrMultiSignature.AggrOrMultiSignatureParser
  );
  repo.addParser(
    "0x1::bls12381::AggrPublicKeysWithPoP",
    AggrPublicKeysWithPoP.AggrPublicKeysWithPoPParser
  );
  repo.addParser(
    "0x1::bls12381::ProofOfPossession",
    ProofOfPossession.ProofOfPossessionParser
  );
  repo.addParser("0x1::bls12381::PublicKey", PublicKey.PublicKeyParser);
  repo.addParser(
    "0x1::bls12381::PublicKeyWithPoP",
    PublicKeyWithPoP.PublicKeyWithPoPParser
  );
  repo.addParser("0x1::bls12381::Signature", Signature.SignatureParser);
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
  get AggrOrMultiSignature() {
    return AggrOrMultiSignature;
  }
  get AggrPublicKeysWithPoP() {
    return AggrPublicKeysWithPoP;
  }
  get ProofOfPossession() {
    return ProofOfPossession;
  }
  get PublicKey() {
    return PublicKey;
  }
  get PublicKeyWithPoP() {
    return PublicKeyWithPoP;
  }
  get Signature() {
    return Signature;
  }
}
