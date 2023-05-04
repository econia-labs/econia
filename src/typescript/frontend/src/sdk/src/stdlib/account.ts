import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { type U8, type U64, type U128 } from "@manahippo/move-to-ts";
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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Bcs from "./bcs";
import * as Ed25519 from "./ed25519";
import * as Error from "./error";
import * as Event from "./event";
import * as From_bcs from "./from_bcs";
import * as Guid from "./guid";
import * as Hash from "./hash";
import * as Multi_ed25519 from "./multi_ed25519";
import * as Option from "./option";
import * as Signer from "./signer";
import * as System_addresses from "./system_addresses";
import * as Table from "./table";
import * as Type_info from "./type_info";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "account";

export const DERIVE_RESOURCE_ACCOUNT_SCHEME: U8 = u8("255");
export const EACCOUNT_ALREADY_EXISTS: U64 = u64("1");
export const EACCOUNT_ALREADY_USED: U64 = u64("16");
export const EACCOUNT_DOES_NOT_EXIST: U64 = u64("2");
export const ECANNOT_RESERVED_ADDRESS: U64 = u64("5");
export const ED25519_SCHEME: U8 = u8("0");
export const EINVALID_ACCEPT_ROTATION_CAPABILITY: U64 = u64("10");
export const EINVALID_ORIGINATING_ADDRESS: U64 = u64("13");
export const EINVALID_PROOF_OF_KNOWLEDGE: U64 = u64("8");
export const EINVALID_SCHEME: U64 = u64("12");
export const EMALFORMED_AUTHENTICATION_KEY: U64 = u64("4");
export const ENO_CAPABILITY: U64 = u64("9");
export const ENO_SUCH_SIGNER_CAPABILITY: U64 = u64("14");
export const ENO_VALID_FRAMEWORK_RESERVED_ADDRESS: U64 = u64("11");
export const EOUT_OF_GAS: U64 = u64("6");
export const ERESOURCE_ACCCOUNT_EXISTS: U64 = u64("15");
export const ESEQUENCE_NUMBER_TOO_BIG: U64 = u64("3");
export const EWRONG_CURRENT_PUBLIC_KEY: U64 = u64("7");
export const MAX_U64: U128 = u128("18446744073709551615");
export const MULTI_ED25519_SCHEME: U8 = u8("1");
export const ZERO_AUTH_KEY: U8[] = [
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
  u8("0"),
];

export class Account {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Account";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "authentication_key", typeTag: new VectorTag(AtomicTypeTag.U8) },
    { name: "sequence_number", typeTag: AtomicTypeTag.U64 },
    { name: "guid_creation_num", typeTag: AtomicTypeTag.U64 },
    {
      name: "coin_register_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "account", "CoinRegisterEvent", []),
      ]),
    },
    {
      name: "key_rotation_events",
      typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [
        new StructTag(new HexString("0x1"), "account", "KeyRotationEvent", []),
      ]),
    },
    {
      name: "rotation_capability_offer",
      typeTag: new StructTag(
        new HexString("0x1"),
        "account",
        "CapabilityOffer",
        [
          new StructTag(
            new HexString("0x1"),
            "account",
            "RotationCapability",
            []
          ),
        ]
      ),
    },
    {
      name: "signer_capability_offer",
      typeTag: new StructTag(
        new HexString("0x1"),
        "account",
        "CapabilityOffer",
        [new StructTag(new HexString("0x1"), "account", "SignerCapability", [])]
      ),
    },
  ];

  authentication_key: U8[];
  sequence_number: U64;
  guid_creation_num: U64;
  coin_register_events: Event.EventHandle;
  key_rotation_events: Event.EventHandle;
  rotation_capability_offer: CapabilityOffer;
  signer_capability_offer: CapabilityOffer;

  constructor(proto: any, public typeTag: TypeTag) {
    this.authentication_key = proto["authentication_key"] as U8[];
    this.sequence_number = proto["sequence_number"] as U64;
    this.guid_creation_num = proto["guid_creation_num"] as U64;
    this.coin_register_events = proto[
      "coin_register_events"
    ] as Event.EventHandle;
    this.key_rotation_events = proto[
      "key_rotation_events"
    ] as Event.EventHandle;
    this.rotation_capability_offer = proto[
      "rotation_capability_offer"
    ] as CapabilityOffer;
    this.signer_capability_offer = proto[
      "signer_capability_offer"
    ] as CapabilityOffer;
  }

  static AccountParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Account {
    const proto = $.parseStructProto(data, typeTag, repo, Account);
    return new Account(proto, typeTag);
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
      Account,
      typeParams
    );
    return result as unknown as Account;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Account,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Account;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Account", []);
  }
  async loadFullState(app: $.AppType) {
    await this.coin_register_events.loadFullState(app);
    await this.key_rotation_events.loadFullState(app);
    await this.rotation_capability_offer.loadFullState(app);
    await this.signer_capability_offer.loadFullState(app);
    this.__app = app;
  }
}

export class CapabilityOffer {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CapabilityOffer";
  static typeParameters: TypeParamDeclType[] = [{ name: "T", isPhantom: true }];
  static fields: FieldDeclType[] = [
    {
      name: "for__",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        AtomicTypeTag.Address,
      ]),
    },
  ];

  for__: Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.for__ = proto["for__"] as Option.Option;
  }

  static CapabilityOfferParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CapabilityOffer {
    const proto = $.parseStructProto(data, typeTag, repo, CapabilityOffer);
    return new CapabilityOffer(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CapabilityOffer", $p);
  }
  async loadFullState(app: $.AppType) {
    await this.for__.loadFullState(app);
    this.__app = app;
  }
}

export class CoinRegisterEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CoinRegisterEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "type_info",
      typeTag: new StructTag(new HexString("0x1"), "type_info", "TypeInfo", []),
    },
  ];

  type_info: Type_info.TypeInfo;

  constructor(proto: any, public typeTag: TypeTag) {
    this.type_info = proto["type_info"] as Type_info.TypeInfo;
  }

  static CoinRegisterEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CoinRegisterEvent {
    const proto = $.parseStructProto(data, typeTag, repo, CoinRegisterEvent);
    return new CoinRegisterEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "CoinRegisterEvent", []);
  }
  async loadFullState(app: $.AppType) {
    await this.type_info.loadFullState(app);
    this.__app = app;
  }
}

export class KeyRotationEvent {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "KeyRotationEvent";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "old_authentication_key",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
    {
      name: "new_authentication_key",
      typeTag: new VectorTag(AtomicTypeTag.U8),
    },
  ];

  old_authentication_key: U8[];
  new_authentication_key: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.old_authentication_key = proto["old_authentication_key"] as U8[];
    this.new_authentication_key = proto["new_authentication_key"] as U8[];
  }

  static KeyRotationEventParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): KeyRotationEvent {
    const proto = $.parseStructProto(data, typeTag, repo, KeyRotationEvent);
    return new KeyRotationEvent(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "KeyRotationEvent", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class OriginatingAddress {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "OriginatingAddress";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "address_map",
      typeTag: new StructTag(new HexString("0x1"), "table", "Table", [
        AtomicTypeTag.Address,
        AtomicTypeTag.Address,
      ]),
    },
  ];

  address_map: Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.address_map = proto["address_map"] as Table.Table;
  }

  static OriginatingAddressParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): OriginatingAddress {
    const proto = $.parseStructProto(data, typeTag, repo, OriginatingAddress);
    return new OriginatingAddress(proto, typeTag);
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
      OriginatingAddress,
      typeParams
    );
    return result as unknown as OriginatingAddress;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      OriginatingAddress,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as OriginatingAddress;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "OriginatingAddress", []);
  }
  async loadFullState(app: $.AppType) {
    await this.address_map.loadFullState(app);
    this.__app = app;
  }
}

export class RotationCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RotationCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "account", typeTag: AtomicTypeTag.Address },
  ];

  account: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.account = proto["account"] as HexString;
  }

  static RotationCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RotationCapability {
    const proto = $.parseStructProto(data, typeTag, repo, RotationCapability);
    return new RotationCapability(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "RotationCapability", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class RotationCapabilityOfferProofChallenge {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RotationCapabilityOfferProofChallenge";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "sequence_number", typeTag: AtomicTypeTag.U64 },
    { name: "recipient_address", typeTag: AtomicTypeTag.Address },
  ];

  sequence_number: U64;
  recipient_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.sequence_number = proto["sequence_number"] as U64;
    this.recipient_address = proto["recipient_address"] as HexString;
  }

  static RotationCapabilityOfferProofChallengeParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RotationCapabilityOfferProofChallenge {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      RotationCapabilityOfferProofChallenge
    );
    return new RotationCapabilityOfferProofChallenge(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "RotationCapabilityOfferProofChallenge",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class RotationProofChallenge {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "RotationProofChallenge";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "sequence_number", typeTag: AtomicTypeTag.U64 },
    { name: "originator", typeTag: AtomicTypeTag.Address },
    { name: "current_auth_key", typeTag: AtomicTypeTag.Address },
    { name: "new_public_key", typeTag: new VectorTag(AtomicTypeTag.U8) },
  ];

  sequence_number: U64;
  originator: HexString;
  current_auth_key: HexString;
  new_public_key: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.sequence_number = proto["sequence_number"] as U64;
    this.originator = proto["originator"] as HexString;
    this.current_auth_key = proto["current_auth_key"] as HexString;
    this.new_public_key = proto["new_public_key"] as U8[];
  }

  static RotationProofChallengeParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): RotationProofChallenge {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      RotationProofChallenge
    );
    return new RotationProofChallenge(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "RotationProofChallenge",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class SignerCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SignerCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "account", typeTag: AtomicTypeTag.Address },
  ];

  account: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.account = proto["account"] as HexString;
  }

  static SignerCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SignerCapability {
    const proto = $.parseStructProto(data, typeTag, repo, SignerCapability);
    return new SignerCapability(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "SignerCapability", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class SignerCapabilityOfferProofChallenge {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SignerCapabilityOfferProofChallenge";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "sequence_number", typeTag: AtomicTypeTag.U64 },
    { name: "recipient_address", typeTag: AtomicTypeTag.Address },
  ];

  sequence_number: U64;
  recipient_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.sequence_number = proto["sequence_number"] as U64;
    this.recipient_address = proto["recipient_address"] as HexString;
  }

  static SignerCapabilityOfferProofChallengeParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SignerCapabilityOfferProofChallenge {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      SignerCapabilityOfferProofChallenge
    );
    return new SignerCapabilityOfferProofChallenge(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "SignerCapabilityOfferProofChallenge",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class SignerCapabilityOfferProofChallengeV2 {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SignerCapabilityOfferProofChallengeV2";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "sequence_number", typeTag: AtomicTypeTag.U64 },
    { name: "source_address", typeTag: AtomicTypeTag.Address },
    { name: "recipient_address", typeTag: AtomicTypeTag.Address },
  ];

  sequence_number: U64;
  source_address: HexString;
  recipient_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.sequence_number = proto["sequence_number"] as U64;
    this.source_address = proto["source_address"] as HexString;
    this.recipient_address = proto["recipient_address"] as HexString;
  }

  static SignerCapabilityOfferProofChallengeV2Parser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SignerCapabilityOfferProofChallengeV2 {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      SignerCapabilityOfferProofChallengeV2
    );
    return new SignerCapabilityOfferProofChallengeV2(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "SignerCapabilityOfferProofChallengeV2",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function assert_valid_signature_and_get_auth_key_(
  scheme: U8,
  public_key_bytes: U8[],
  signature: U8[],
  challenge: RotationProofChallenge,
  $c: AptosDataCache
): U8[] {
  let temp$3, temp$4, pk, pk__1, sig, sig__2;
  if ($.copy(scheme).eq($.copy(ED25519_SCHEME))) {
    pk = Ed25519.new_unvalidated_public_key_from_bytes_(
      $.copy(public_key_bytes),
      $c
    );
    sig = Ed25519.new_signature_from_bytes_($.copy(signature), $c);
    if (
      !Ed25519.signature_verify_strict_t_(sig, pk, $.copy(challenge), $c, [
        new SimpleStructTag(RotationProofChallenge),
      ])
    ) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EINVALID_PROOF_OF_KNOWLEDGE), $c)
      );
    }
    temp$4 = Ed25519.unvalidated_public_key_to_authentication_key_(pk, $c);
  } else {
    if ($.copy(scheme).eq($.copy(MULTI_ED25519_SCHEME))) {
      pk__1 = Multi_ed25519.new_unvalidated_public_key_from_bytes_(
        $.copy(public_key_bytes),
        $c
      );
      sig__2 = Multi_ed25519.new_signature_from_bytes_($.copy(signature), $c);
      if (
        !Multi_ed25519.signature_verify_strict_t_(
          sig__2,
          pk__1,
          $.copy(challenge),
          $c,
          [new SimpleStructTag(RotationProofChallenge)]
        )
      ) {
        throw $.abortCode(
          Error.invalid_argument_($.copy(EINVALID_PROOF_OF_KNOWLEDGE), $c)
        );
      }
      temp$3 = Multi_ed25519.unvalidated_public_key_to_authentication_key_(
        pk__1,
        $c
      );
    } else {
      throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_SCHEME), $c));
    }
    temp$4 = temp$3;
  }
  return temp$4;
}

export function create_account_(
  new_address: HexString,
  $c: AptosDataCache
): HexString {
  let temp$1, temp$2;
  if ($c.exists(new SimpleStructTag(Account), $.copy(new_address))) {
    throw $.abortCode(
      Error.already_exists_($.copy(EACCOUNT_ALREADY_EXISTS), $c)
    );
  }
  if ($.copy(new_address).hex() !== new HexString("0x0").hex()) {
    temp$1 = $.copy(new_address).hex() !== new HexString("0x1").hex();
  } else {
    temp$1 = false;
  }
  if (temp$1) {
    temp$2 = $.copy(new_address).hex() !== new HexString("0x3").hex();
  } else {
    temp$2 = false;
  }
  if (!temp$2) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(ECANNOT_RESERVED_ADDRESS), $c)
    );
  }
  return create_account_unchecked_($.copy(new_address), $c);
}

export function create_account_unchecked_(
  new_address: HexString,
  $c: AptosDataCache
): HexString {
  let authentication_key,
    coin_register_events,
    guid_creation_num,
    guid_for_coin,
    guid_for_rotation,
    key_rotation_events,
    new_account;
  new_account = create_signer_($.copy(new_address), $c);
  authentication_key = Bcs.to_bytes_(new_address, $c, [AtomicTypeTag.Address]);
  if (
    !Vector.length_(authentication_key, $c, [AtomicTypeTag.U8]).eq(u64("32"))
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EMALFORMED_AUTHENTICATION_KEY), $c)
    );
  }
  guid_creation_num = u64("0");
  guid_for_coin = Guid.create_($.copy(new_address), guid_creation_num, $c);
  coin_register_events = Event.new_event_handle_(guid_for_coin, $c, [
    new SimpleStructTag(CoinRegisterEvent),
  ]);
  guid_for_rotation = Guid.create_($.copy(new_address), guid_creation_num, $c);
  key_rotation_events = Event.new_event_handle_(guid_for_rotation, $c, [
    new SimpleStructTag(KeyRotationEvent),
  ]);
  $c.move_to(
    new SimpleStructTag(Account),
    new_account,
    new Account(
      {
        authentication_key: $.copy(authentication_key),
        sequence_number: u64("0"),
        guid_creation_num: $.copy(guid_creation_num),
        coin_register_events: coin_register_events,
        key_rotation_events: key_rotation_events,
        rotation_capability_offer: new CapabilityOffer(
          { for: Option.none_($c, [AtomicTypeTag.Address]) },
          new SimpleStructTag(CapabilityOffer, [
            new SimpleStructTag(RotationCapability),
          ])
        ),
        signer_capability_offer: new CapabilityOffer(
          { for: Option.none_($c, [AtomicTypeTag.Address]) },
          new SimpleStructTag(CapabilityOffer, [
            new SimpleStructTag(SignerCapability),
          ])
        ),
      },
      new SimpleStructTag(Account)
    )
  );
  return new_account;
}

export function create_authorized_signer_(
  account: HexString,
  offerer_address: HexString,
  $c: AptosDataCache
): HexString {
  let account_resource, addr;
  if (!exists_at_($.copy(offerer_address), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c));
  }
  account_resource = $c.borrow_global<Account>(
    new SimpleStructTag(Account),
    $.copy(offerer_address)
  );
  addr = Signer.address_of_(account, $c);
  if (
    !Option.contains_(
      account_resource.signer_capability_offer.for__,
      addr,
      $c,
      [AtomicTypeTag.Address]
    )
  ) {
    throw $.abortCode(Error.not_found_($.copy(ENO_SUCH_SIGNER_CAPABILITY), $c));
  }
  return create_signer_($.copy(offerer_address), $c);
}

export function create_framework_reserved_account_(
  addr: HexString,
  $c: AptosDataCache
): [HexString, SignerCapability] {
  let temp$1,
    temp$2,
    temp$3,
    temp$4,
    temp$5,
    temp$6,
    temp$7,
    temp$8,
    temp$9,
    signer,
    signer_cap;
  if ($.copy(addr).hex() === new HexString("0x1").hex()) {
    temp$1 = true;
  } else {
    temp$1 = $.copy(addr).hex() === new HexString("0x2").hex();
  }
  if (temp$1) {
    temp$2 = true;
  } else {
    temp$2 = $.copy(addr).hex() === new HexString("0x3").hex();
  }
  if (temp$2) {
    temp$3 = true;
  } else {
    temp$3 = $.copy(addr).hex() === new HexString("0x4").hex();
  }
  if (temp$3) {
    temp$4 = true;
  } else {
    temp$4 = $.copy(addr).hex() === new HexString("0x5").hex();
  }
  if (temp$4) {
    temp$5 = true;
  } else {
    temp$5 = $.copy(addr).hex() === new HexString("0x6").hex();
  }
  if (temp$5) {
    temp$6 = true;
  } else {
    temp$6 = $.copy(addr).hex() === new HexString("0x7").hex();
  }
  if (temp$6) {
    temp$7 = true;
  } else {
    temp$7 = $.copy(addr).hex() === new HexString("0x8").hex();
  }
  if (temp$7) {
    temp$8 = true;
  } else {
    temp$8 = $.copy(addr).hex() === new HexString("0x9").hex();
  }
  if (temp$8) {
    temp$9 = true;
  } else {
    temp$9 = $.copy(addr).hex() === new HexString("0xa").hex();
  }
  if (!temp$9) {
    throw $.abortCode(
      Error.permission_denied_($.copy(ENO_VALID_FRAMEWORK_RESERVED_ADDRESS), $c)
    );
  }
  signer = create_account_unchecked_($.copy(addr), $c);
  signer_cap = new SignerCapability(
    { account: $.copy(addr) },
    new SimpleStructTag(SignerCapability)
  );
  return [signer, signer_cap];
}

export function create_guid_(
  account_signer: HexString,
  $c: AptosDataCache
): Guid.GUID {
  let account, addr;
  addr = Signer.address_of_(account_signer, $c);
  account = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(addr)
  );
  return Guid.create_($.copy(addr), account.guid_creation_num, $c);
}

export function create_resource_account_(
  source: HexString,
  seed: U8[],
  $c: AptosDataCache
): [HexString, SignerCapability] {
  let temp$1, temp$2, account, account__3, resource, resource_addr, signer_cap;
  temp$1 = Signer.address_of_(source, $c);
  resource_addr = create_resource_address_(temp$1, $.copy(seed), $c);
  if (exists_at_($.copy(resource_addr), $c)) {
    account = $c.borrow_global<Account>(
      new SimpleStructTag(Account),
      $.copy(resource_addr)
    );
    if (
      !Option.is_none_(account.signer_capability_offer.for__, $c, [
        AtomicTypeTag.Address,
      ])
    ) {
      throw $.abortCode(
        Error.already_exists_($.copy(ERESOURCE_ACCCOUNT_EXISTS), $c)
      );
    }
    if (!$.copy(account.sequence_number).eq(u64("0"))) {
      throw $.abortCode(
        Error.invalid_state_($.copy(EACCOUNT_ALREADY_USED), $c)
      );
    }
    temp$2 = create_signer_($.copy(resource_addr), $c);
  } else {
    temp$2 = create_account_unchecked_($.copy(resource_addr), $c);
  }
  resource = temp$2;
  rotate_authentication_key_internal_(resource, $.copy(ZERO_AUTH_KEY), $c);
  account__3 = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(resource_addr)
  );
  account__3.signer_capability_offer.for__ = Option.some_(
    $.copy(resource_addr),
    $c,
    [AtomicTypeTag.Address]
  );
  signer_cap = new SignerCapability(
    { account: $.copy(resource_addr) },
    new SimpleStructTag(SignerCapability)
  );
  return [resource, signer_cap];
}

export function create_resource_address_(
  source: HexString,
  seed: U8[],
  $c: AptosDataCache
): HexString {
  let bytes;
  bytes = Bcs.to_bytes_(source, $c, [AtomicTypeTag.Address]);
  Vector.append_(bytes, $.copy(seed), $c, [AtomicTypeTag.U8]);
  Vector.push_back_(bytes, $.copy(DERIVE_RESOURCE_ACCOUNT_SCHEME), $c, [
    AtomicTypeTag.U8,
  ]);
  return From_bcs.to_address_(Hash.sha3_256_($.copy(bytes), $c), $c);
}

export function create_signer_(addr: HexString, $c: AptosDataCache): HexString {
  return $.aptos_framework_account_create_signer(addr, $c);
}
export function create_signer_with_capability_(
  capability: SignerCapability,
  $c: AptosDataCache
): HexString {
  let addr;
  addr = capability.account;
  return create_signer_($.copy(addr), $c);
}

export function exists_at_(addr: HexString, $c: AptosDataCache): boolean {
  return $c.exists(new SimpleStructTag(Account), $.copy(addr));
}

export function get_authentication_key_(
  addr: HexString,
  $c: AptosDataCache
): U8[] {
  return $.copy(
    $c.borrow_global<Account>(new SimpleStructTag(Account), $.copy(addr))
      .authentication_key
  );
}

export function get_guid_next_creation_num_(
  addr: HexString,
  $c: AptosDataCache
): U64 {
  return $.copy(
    $c.borrow_global<Account>(new SimpleStructTag(Account), $.copy(addr))
      .guid_creation_num
  );
}

export function get_sequence_number_(addr: HexString, $c: AptosDataCache): U64 {
  return $.copy(
    $c.borrow_global<Account>(new SimpleStructTag(Account), $.copy(addr))
      .sequence_number
  );
}

export function get_signer_capability_address_(
  capability: SignerCapability,
  $c: AptosDataCache
): HexString {
  return $.copy(capability.account);
}

export function increment_sequence_number_(
  addr: HexString,
  $c: AptosDataCache
): void {
  let sequence_number;
  sequence_number = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(addr)
  ).sequence_number;
  if (!u128($.copy(sequence_number)).lt($.copy(MAX_U64))) {
    throw $.abortCode(
      Error.out_of_range_($.copy(ESEQUENCE_NUMBER_TOO_BIG), $c)
    );
  }
  $.set(sequence_number, $.copy(sequence_number).add(u64("1")));
  return;
}

export function initialize_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  $c.move_to(
    new SimpleStructTag(OriginatingAddress),
    aptos_framework,
    new OriginatingAddress(
      {
        address_map: Table.new___($c, [
          AtomicTypeTag.Address,
          AtomicTypeTag.Address,
        ]),
      },
      new SimpleStructTag(OriginatingAddress)
    )
  );
  return;
}

export function new_event_handle_(
  account: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <T>*/
): Event.EventHandle {
  return Event.new_event_handle_(create_guid_(account, $c), $c, [$p[0]]);
}

export function offer_signer_capability_(
  account: HexString,
  signer_capability_sig_bytes: U8[],
  account_scheme: U8,
  account_public_key_bytes: U8[],
  recipient_address: HexString,
  $c: AptosDataCache
): void {
  let account_resource,
    expected_auth_key,
    expected_auth_key__2,
    proof_challenge,
    pubkey,
    pubkey__1,
    signer_capability_sig,
    signer_capability_sig__3,
    source_address;
  source_address = Signer.address_of_(account, $c);
  if (!exists_at_($.copy(recipient_address), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c));
  }
  account_resource = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(source_address)
  );
  proof_challenge = new SignerCapabilityOfferProofChallengeV2(
    {
      sequence_number: $.copy(account_resource.sequence_number),
      source_address: $.copy(source_address),
      recipient_address: $.copy(recipient_address),
    },
    new SimpleStructTag(SignerCapabilityOfferProofChallengeV2)
  );
  if ($.copy(account_scheme).eq($.copy(ED25519_SCHEME))) {
    pubkey = Ed25519.new_unvalidated_public_key_from_bytes_(
      $.copy(account_public_key_bytes),
      $c
    );
    expected_auth_key = Ed25519.unvalidated_public_key_to_authentication_key_(
      pubkey,
      $c
    );
    if (
      !$.veq(
        $.copy(account_resource.authentication_key),
        $.copy(expected_auth_key)
      )
    ) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EWRONG_CURRENT_PUBLIC_KEY), $c)
      );
    }
    signer_capability_sig = Ed25519.new_signature_from_bytes_(
      $.copy(signer_capability_sig_bytes),
      $c
    );
    if (
      !Ed25519.signature_verify_strict_t_(
        signer_capability_sig,
        pubkey,
        $.copy(proof_challenge),
        $c,
        [new SimpleStructTag(SignerCapabilityOfferProofChallengeV2)]
      )
    ) {
      throw $.abortCode(
        Error.invalid_argument_($.copy(EINVALID_PROOF_OF_KNOWLEDGE), $c)
      );
    }
  } else {
    if ($.copy(account_scheme).eq($.copy(MULTI_ED25519_SCHEME))) {
      pubkey__1 = Multi_ed25519.new_unvalidated_public_key_from_bytes_(
        $.copy(account_public_key_bytes),
        $c
      );
      expected_auth_key__2 =
        Multi_ed25519.unvalidated_public_key_to_authentication_key_(
          pubkey__1,
          $c
        );
      if (
        !$.veq(
          $.copy(account_resource.authentication_key),
          $.copy(expected_auth_key__2)
        )
      ) {
        throw $.abortCode(
          Error.invalid_argument_($.copy(EWRONG_CURRENT_PUBLIC_KEY), $c)
        );
      }
      signer_capability_sig__3 = Multi_ed25519.new_signature_from_bytes_(
        $.copy(signer_capability_sig_bytes),
        $c
      );
      if (
        !Multi_ed25519.signature_verify_strict_t_(
          signer_capability_sig__3,
          pubkey__1,
          $.copy(proof_challenge),
          $c,
          [new SimpleStructTag(SignerCapabilityOfferProofChallengeV2)]
        )
      ) {
        throw $.abortCode(
          Error.invalid_argument_($.copy(EINVALID_PROOF_OF_KNOWLEDGE), $c)
        );
      }
    } else {
      throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_SCHEME), $c));
    }
  }
  Option.swap_or_fill_(
    account_resource.signer_capability_offer.for__,
    $.copy(recipient_address),
    $c,
    [AtomicTypeTag.Address]
  );
  return;
}

export function buildPayload_offer_signer_capability(
  signer_capability_sig_bytes: U8[],
  account_scheme: U8,
  account_public_key_bytes: U8[],
  recipient_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "account",
    "offer_signer_capability",
    typeParamStrings,
    [
      signer_capability_sig_bytes,
      account_scheme,
      account_public_key_bytes,
      recipient_address,
    ],
    isJSON
  );
}
export function register_coin_(
  account_addr: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <CoinType>*/
): void {
  let account;
  account = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(account_addr)
  );
  Event.emit_event_(
    account.coin_register_events,
    new CoinRegisterEvent(
      { type_info: Type_info.type_of_($c, [$p[0]]) },
      new SimpleStructTag(CoinRegisterEvent)
    ),
    $c,
    [new SimpleStructTag(CoinRegisterEvent)]
  );
  return;
}

export function revoke_signer_capability_(
  account: HexString,
  to_be_revoked_address: HexString,
  $c: AptosDataCache
): void {
  let account_resource, addr;
  if (!exists_at_($.copy(to_be_revoked_address), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c));
  }
  addr = Signer.address_of_(account, $c);
  account_resource = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(addr)
  );
  if (
    !Option.contains_(
      account_resource.signer_capability_offer.for__,
      to_be_revoked_address,
      $c,
      [AtomicTypeTag.Address]
    )
  ) {
    throw $.abortCode(Error.not_found_($.copy(ENO_SUCH_SIGNER_CAPABILITY), $c));
  }
  Option.extract_(account_resource.signer_capability_offer.for__, $c, [
    AtomicTypeTag.Address,
  ]);
  return;
}

export function buildPayload_revoke_signer_capability(
  to_be_revoked_address: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "account",
    "revoke_signer_capability",
    typeParamStrings,
    [to_be_revoked_address],
    isJSON
  );
}
export function rotate_authentication_key_(
  account: HexString,
  from_scheme: U8,
  from_public_key_bytes: U8[],
  to_scheme: U8,
  to_public_key_bytes: U8[],
  cap_rotate_key: U8[],
  cap_update_table: U8[],
  $c: AptosDataCache
): void {
  let temp$3,
    temp$4,
    account_resource,
    addr,
    address_map,
    challenge,
    curr_auth_key,
    curr_auth_key_as_address,
    from_auth_key,
    from_auth_key__2,
    from_pk,
    from_pk__1,
    new_auth_key,
    new_auth_key_as_address;
  addr = Signer.address_of_(account, $c);
  if (!exists_at_($.copy(addr), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c));
  }
  account_resource = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(addr)
  );
  if ($.copy(from_scheme).eq($.copy(ED25519_SCHEME))) {
    from_pk = Ed25519.new_unvalidated_public_key_from_bytes_(
      $.copy(from_public_key_bytes),
      $c
    );
    from_auth_key = Ed25519.unvalidated_public_key_to_authentication_key_(
      from_pk,
      $c
    );
    if (
      !$.veq($.copy(account_resource.authentication_key), $.copy(from_auth_key))
    ) {
      throw $.abortCode(
        Error.unauthenticated_($.copy(EWRONG_CURRENT_PUBLIC_KEY), $c)
      );
    }
  } else {
    if ($.copy(from_scheme).eq($.copy(MULTI_ED25519_SCHEME))) {
      from_pk__1 = Multi_ed25519.new_unvalidated_public_key_from_bytes_(
        $.copy(from_public_key_bytes),
        $c
      );
      from_auth_key__2 =
        Multi_ed25519.unvalidated_public_key_to_authentication_key_(
          from_pk__1,
          $c
        );
      if (
        !$.veq(
          $.copy(account_resource.authentication_key),
          $.copy(from_auth_key__2)
        )
      ) {
        throw $.abortCode(
          Error.unauthenticated_($.copy(EWRONG_CURRENT_PUBLIC_KEY), $c)
        );
      }
    } else {
      throw $.abortCode(Error.invalid_argument_($.copy(EINVALID_SCHEME), $c));
    }
  }
  curr_auth_key_as_address = From_bcs.to_address_(
    $.copy(account_resource.authentication_key),
    $c
  );
  challenge = new RotationProofChallenge(
    {
      sequence_number: $.copy(account_resource.sequence_number),
      originator: $.copy(addr),
      current_auth_key: $.copy(curr_auth_key_as_address),
      new_public_key: $.copy(to_public_key_bytes),
    },
    new SimpleStructTag(RotationProofChallenge)
  );
  curr_auth_key = assert_valid_signature_and_get_auth_key_(
    $.copy(from_scheme),
    $.copy(from_public_key_bytes),
    $.copy(cap_rotate_key),
    challenge,
    $c
  );
  new_auth_key = assert_valid_signature_and_get_auth_key_(
    $.copy(to_scheme),
    $.copy(to_public_key_bytes),
    $.copy(cap_update_table),
    challenge,
    $c
  );
  address_map = $c.borrow_global_mut<OriginatingAddress>(
    new SimpleStructTag(OriginatingAddress),
    new HexString("0x1")
  ).address_map;
  new_auth_key_as_address = From_bcs.to_address_($.copy(new_auth_key), $c);
  [temp$3, temp$4] = [address_map, $.copy(curr_auth_key_as_address)];
  if (
    Table.contains_(temp$3, temp$4, $c, [
      AtomicTypeTag.Address,
      AtomicTypeTag.Address,
    ])
  ) {
    if (
      !(
        $.copy(addr).hex() ===
        Table.remove_(address_map, $.copy(curr_auth_key_as_address), $c, [
          AtomicTypeTag.Address,
          AtomicTypeTag.Address,
        ]).hex()
      )
    ) {
      throw $.abortCode(
        Error.not_found_($.copy(EINVALID_ORIGINATING_ADDRESS), $c)
      );
    }
  } else {
  }
  Table.add_(address_map, $.copy(new_auth_key_as_address), $.copy(addr), $c, [
    AtomicTypeTag.Address,
    AtomicTypeTag.Address,
  ]);
  Event.emit_event_(
    account_resource.key_rotation_events,
    new KeyRotationEvent(
      {
        old_authentication_key: $.copy(curr_auth_key),
        new_authentication_key: $.copy(new_auth_key),
      },
      new SimpleStructTag(KeyRotationEvent)
    ),
    $c,
    [new SimpleStructTag(KeyRotationEvent)]
  );
  account_resource.authentication_key = $.copy(new_auth_key);
  return;
}

export function buildPayload_rotate_authentication_key(
  from_scheme: U8,
  from_public_key_bytes: U8[],
  to_scheme: U8,
  to_public_key_bytes: U8[],
  cap_rotate_key: U8[],
  cap_update_table: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "account",
    "rotate_authentication_key",
    typeParamStrings,
    [
      from_scheme,
      from_public_key_bytes,
      to_scheme,
      to_public_key_bytes,
      cap_rotate_key,
      cap_update_table,
    ],
    isJSON
  );
}
export function rotate_authentication_key_internal_(
  account: HexString,
  new_auth_key: U8[],
  $c: AptosDataCache
): void {
  let account_resource, addr;
  addr = Signer.address_of_(account, $c);
  if (!exists_at_($.copy(addr), $c)) {
    throw $.abortCode(Error.not_found_($.copy(EACCOUNT_DOES_NOT_EXIST), $c));
  }
  if (!Vector.length_(new_auth_key, $c, [AtomicTypeTag.U8]).eq(u64("32"))) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EMALFORMED_AUTHENTICATION_KEY), $c)
    );
  }
  account_resource = $c.borrow_global_mut<Account>(
    new SimpleStructTag(Account),
    $.copy(addr)
  );
  account_resource.authentication_key = $.copy(new_auth_key);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::account::Account", Account.AccountParser);
  repo.addParser(
    "0x1::account::CapabilityOffer",
    CapabilityOffer.CapabilityOfferParser
  );
  repo.addParser(
    "0x1::account::CoinRegisterEvent",
    CoinRegisterEvent.CoinRegisterEventParser
  );
  repo.addParser(
    "0x1::account::KeyRotationEvent",
    KeyRotationEvent.KeyRotationEventParser
  );
  repo.addParser(
    "0x1::account::OriginatingAddress",
    OriginatingAddress.OriginatingAddressParser
  );
  repo.addParser(
    "0x1::account::RotationCapability",
    RotationCapability.RotationCapabilityParser
  );
  repo.addParser(
    "0x1::account::RotationCapabilityOfferProofChallenge",
    RotationCapabilityOfferProofChallenge.RotationCapabilityOfferProofChallengeParser
  );
  repo.addParser(
    "0x1::account::RotationProofChallenge",
    RotationProofChallenge.RotationProofChallengeParser
  );
  repo.addParser(
    "0x1::account::SignerCapability",
    SignerCapability.SignerCapabilityParser
  );
  repo.addParser(
    "0x1::account::SignerCapabilityOfferProofChallenge",
    SignerCapabilityOfferProofChallenge.SignerCapabilityOfferProofChallengeParser
  );
  repo.addParser(
    "0x1::account::SignerCapabilityOfferProofChallengeV2",
    SignerCapabilityOfferProofChallengeV2.SignerCapabilityOfferProofChallengeV2Parser
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
  get Account() {
    return Account;
  }
  async loadAccount(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Account.load(
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
  get CapabilityOffer() {
    return CapabilityOffer;
  }
  get CoinRegisterEvent() {
    return CoinRegisterEvent;
  }
  get KeyRotationEvent() {
    return KeyRotationEvent;
  }
  get OriginatingAddress() {
    return OriginatingAddress;
  }
  async loadOriginatingAddress(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await OriginatingAddress.load(
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
  get RotationCapability() {
    return RotationCapability;
  }
  get RotationCapabilityOfferProofChallenge() {
    return RotationCapabilityOfferProofChallenge;
  }
  get RotationProofChallenge() {
    return RotationProofChallenge;
  }
  get SignerCapability() {
    return SignerCapability;
  }
  get SignerCapabilityOfferProofChallenge() {
    return SignerCapabilityOfferProofChallenge;
  }
  get SignerCapabilityOfferProofChallengeV2() {
    return SignerCapabilityOfferProofChallengeV2;
  }
  payload_offer_signer_capability(
    signer_capability_sig_bytes: U8[],
    account_scheme: U8,
    account_public_key_bytes: U8[],
    recipient_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_offer_signer_capability(
      signer_capability_sig_bytes,
      account_scheme,
      account_public_key_bytes,
      recipient_address,
      isJSON
    );
  }
  async offer_signer_capability(
    _account: AptosAccount,
    signer_capability_sig_bytes: U8[],
    account_scheme: U8,
    account_public_key_bytes: U8[],
    recipient_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_offer_signer_capability(
      signer_capability_sig_bytes,
      account_scheme,
      account_public_key_bytes,
      recipient_address,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_revoke_signer_capability(
    to_be_revoked_address: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_revoke_signer_capability(to_be_revoked_address, isJSON);
  }
  async revoke_signer_capability(
    _account: AptosAccount,
    to_be_revoked_address: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_revoke_signer_capability(
      to_be_revoked_address,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_rotate_authentication_key(
    from_scheme: U8,
    from_public_key_bytes: U8[],
    to_scheme: U8,
    to_public_key_bytes: U8[],
    cap_rotate_key: U8[],
    cap_update_table: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_rotate_authentication_key(
      from_scheme,
      from_public_key_bytes,
      to_scheme,
      to_public_key_bytes,
      cap_rotate_key,
      cap_update_table,
      isJSON
    );
  }
  async rotate_authentication_key(
    _account: AptosAccount,
    from_scheme: U8,
    from_public_key_bytes: U8[],
    to_scheme: U8,
    to_public_key_bytes: U8[],
    cap_rotate_key: U8[],
    cap_update_table: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_rotate_authentication_key(
      from_scheme,
      from_public_key_bytes,
      to_scheme,
      to_public_key_bytes,
      cap_rotate_key,
      cap_update_table,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
