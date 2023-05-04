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

import * as Stdlib from "../stdlib";
export const packageName = "Econia";
export const moduleAddress = new HexString(
  "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
);
export const moduleName = "resource_account";

export class SignerCapabilityStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "SignerCapabilityStore";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "signer_capability",
      typeTag: new StructTag(
        new HexString("0x1"),
        "account",
        "SignerCapability",
        []
      ),
    },
  ];

  signer_capability: Stdlib.Account.SignerCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.signer_capability = proto[
      "signer_capability"
    ] as Stdlib.Account.SignerCapability;
  }

  static SignerCapabilityStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): SignerCapabilityStore {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      SignerCapabilityStore
    );
    return new SignerCapabilityStore(proto, typeTag);
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
      SignerCapabilityStore,
      typeParams
    );
    return result as unknown as SignerCapabilityStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      SignerCapabilityStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as SignerCapabilityStore;
  }
  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "SignerCapabilityStore",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    await this.signer_capability.loadFullState(app);
    this.__app = app;
  }
}
export function get_address_($c: AptosDataCache): HexString {
  let signer_capability_ref;
  signer_capability_ref = $c.borrow_global<SignerCapabilityStore>(
    new SimpleStructTag(SignerCapabilityStore),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).signer_capability;
  return Stdlib.Account.get_signer_capability_address_(
    signer_capability_ref,
    $c
  );
}

export function get_signer_($c: AptosDataCache): HexString {
  let signer_capability_ref;
  signer_capability_ref = $c.borrow_global<SignerCapabilityStore>(
    new SimpleStructTag(SignerCapabilityStore),
    new HexString(
      "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200"
    )
  ).signer_capability;
  return Stdlib.Account.create_signer_with_capability_(
    signer_capability_ref,
    $c
  );
}

export function init_module_(econia: HexString, $c: AptosDataCache): void {
  let temp$1, signer_capability, time_seed;
  temp$1 = Stdlib.Timestamp.now_microseconds_($c);
  time_seed = Stdlib.Bcs.to_bytes_(temp$1, $c, [AtomicTypeTag.U64]);
  [, signer_capability] = Stdlib.Account.create_resource_account_(
    econia,
    $.copy(time_seed),
    $c
  );
  $c.move_to(
    new SimpleStructTag(SignerCapabilityStore),
    econia,
    new SignerCapabilityStore(
      { signer_capability: signer_capability },
      new SimpleStructTag(SignerCapabilityStore)
    )
  );
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x3c04538036604862c67261221a6167fa4ae5121d3649e29b330fa8c248b66200::resource_account::SignerCapabilityStore",
    SignerCapabilityStore.SignerCapabilityStoreParser
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
  get SignerCapabilityStore() {
    return SignerCapabilityStore;
  }
  async loadSignerCapabilityStore(
    owner: HexString,
    loadFull = true,
    fillCache = true
  ) {
    const val = await SignerCapabilityStore.load(
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
