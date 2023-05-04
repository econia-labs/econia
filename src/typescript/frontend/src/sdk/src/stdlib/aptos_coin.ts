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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Coin from "./coin";
import * as Error from "./error";
import * as Option from "./option";
import * as Signer from "./signer";
import * as String from "./string";
import * as System_addresses from "./system_addresses";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "aptos_coin";

export const EALREADY_DELEGATED: U64 = u64("2");
export const EDELEGATION_NOT_FOUND: U64 = u64("3");
export const ENO_CAPABILITIES: U64 = u64("1");

export class AptosCoin {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "AptosCoin";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static AptosCoinParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): AptosCoin {
    const proto = $.parseStructProto(data, typeTag, repo, AptosCoin);
    return new AptosCoin(proto, typeTag);
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
      AptosCoin,
      typeParams
    );
    return result as unknown as AptosCoin;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      AptosCoin,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as AptosCoin;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "AptosCoin", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class DelegatedMintCapability {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "DelegatedMintCapability";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "to", typeTag: AtomicTypeTag.Address },
  ];

  to: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.to = proto["to"] as HexString;
  }

  static DelegatedMintCapabilityParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): DelegatedMintCapability {
    const proto = $.parseStructProto(
      data,
      typeTag,
      repo,
      DelegatedMintCapability
    );
    return new DelegatedMintCapability(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(
      moduleAddress,
      moduleName,
      "DelegatedMintCapability",
      []
    );
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class Delegations {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Delegations";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "inner",
      typeTag: new VectorTag(
        new StructTag(
          new HexString("0x1"),
          "aptos_coin",
          "DelegatedMintCapability",
          []
        )
      ),
    },
  ];

  inner: DelegatedMintCapability[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.inner = proto["inner"] as DelegatedMintCapability[];
  }

  static DelegationsParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Delegations {
    const proto = $.parseStructProto(data, typeTag, repo, Delegations);
    return new Delegations(proto, typeTag);
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
      Delegations,
      typeParams
    );
    return result as unknown as Delegations;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Delegations,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Delegations;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Delegations", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class MintCapStore {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "MintCapStore";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "mint_cap",
      typeTag: new StructTag(new HexString("0x1"), "coin", "MintCapability", [
        new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
      ]),
    },
  ];

  mint_cap: Coin.MintCapability;

  constructor(proto: any, public typeTag: TypeTag) {
    this.mint_cap = proto["mint_cap"] as Coin.MintCapability;
  }

  static MintCapStoreParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): MintCapStore {
    const proto = $.parseStructProto(data, typeTag, repo, MintCapStore);
    return new MintCapStore(proto, typeTag);
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
      MintCapStore,
      typeParams
    );
    return result as unknown as MintCapStore;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      MintCapStore,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as MintCapStore;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "MintCapStore", []);
  }
  async loadFullState(app: $.AppType) {
    await this.mint_cap.loadFullState(app);
    this.__app = app;
  }
}
export function claim_mint_capability_(
  account: HexString,
  $c: AptosDataCache
): void {
  let delegations, idx, maybe_index, mint_cap;
  maybe_index = find_delegation_(Signer.address_of_(account, $c), $c);
  if (!Option.is_some_(maybe_index, $c, [AtomicTypeTag.U64])) {
    throw $.abortCode($.copy(EDELEGATION_NOT_FOUND));
  }
  idx = $.copy(Option.borrow_(maybe_index, $c, [AtomicTypeTag.U64]));
  delegations = $c.borrow_global_mut<Delegations>(
    new SimpleStructTag(Delegations),
    new HexString("0xa550c18")
  ).inner;
  Vector.swap_remove_(delegations, $.copy(idx), $c, [
    new SimpleStructTag(DelegatedMintCapability),
  ]);
  mint_cap = $.copy(
    $c.borrow_global<MintCapStore>(
      new SimpleStructTag(MintCapStore),
      new HexString("0xa550c18")
    ).mint_cap
  );
  $c.move_to(
    new SimpleStructTag(MintCapStore),
    account,
    new MintCapStore(
      { mint_cap: $.copy(mint_cap) },
      new SimpleStructTag(MintCapStore)
    )
  );
  return;
}

export function buildPayload_claim_mint_capability(
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_coin",
    "claim_mint_capability",
    typeParamStrings,
    [],
    isJSON
  );
}
export function configure_accounts_for_test_(
  aptos_framework: HexString,
  core_resources: HexString,
  mint_cap: Coin.MintCapability,
  $c: AptosDataCache
): void {
  let coins;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  Coin.register_(core_resources, $c, [new SimpleStructTag(AptosCoin)]);
  coins = Coin.mint_(u64("18446744073709551615"), mint_cap, $c, [
    new SimpleStructTag(AptosCoin),
  ]);
  Coin.deposit_(Signer.address_of_(core_resources, $c), coins, $c, [
    new SimpleStructTag(AptosCoin),
  ]);
  $c.move_to(
    new SimpleStructTag(MintCapStore),
    core_resources,
    new MintCapStore(
      { mint_cap: $.copy(mint_cap) },
      new SimpleStructTag(MintCapStore)
    )
  );
  $c.move_to(
    new SimpleStructTag(Delegations),
    core_resources,
    new Delegations(
      {
        inner: Vector.empty_($c, [
          new SimpleStructTag(DelegatedMintCapability),
        ]),
      },
      new SimpleStructTag(Delegations)
    )
  );
  return;
}

export function delegate_mint_capability_(
  account: HexString,
  to: HexString,
  $c: AptosDataCache
): void {
  let temp$1, temp$2, delegations, element, i;
  System_addresses.assert_core_resource_(account, $c);
  delegations = $c.borrow_global_mut<Delegations>(
    new SimpleStructTag(Delegations),
    new HexString("0xa550c18")
  ).inner;
  i = u64("0");
  while (
    $.copy(i).lt(
      Vector.length_(delegations, $c, [
        new SimpleStructTag(DelegatedMintCapability),
      ])
    )
  ) {
    {
      [temp$1, temp$2] = [delegations, $.copy(i)];
      element = Vector.borrow_(temp$1, temp$2, $c, [
        new SimpleStructTag(DelegatedMintCapability),
      ]);
      if (!($.copy(element.to).hex() !== $.copy(to).hex())) {
        throw $.abortCode(
          Error.invalid_argument_($.copy(EALREADY_DELEGATED), $c)
        );
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  Vector.push_back_(
    delegations,
    new DelegatedMintCapability(
      { to: $.copy(to) },
      new SimpleStructTag(DelegatedMintCapability)
    ),
    $c,
    [new SimpleStructTag(DelegatedMintCapability)]
  );
  return;
}

export function buildPayload_delegate_mint_capability(
  to: HexString,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_coin",
    "delegate_mint_capability",
    typeParamStrings,
    [to],
    isJSON
  );
}
export function destroy_mint_cap_(
  aptos_framework: HexString,
  $c: AptosDataCache
): void {
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  const { mint_cap: mint_cap } = $c.move_from<MintCapStore>(
    new SimpleStructTag(MintCapStore),
    new HexString("0x1")
  );
  Coin.destroy_mint_cap_($.copy(mint_cap), $c, [
    new SimpleStructTag(AptosCoin),
  ]);
  return;
}

export function find_delegation_(
  addr: HexString,
  $c: AptosDataCache
): Option.Option {
  let delegations, element, i, index, len;
  delegations = $c.borrow_global<Delegations>(
    new SimpleStructTag(Delegations),
    new HexString("0xa550c18")
  ).inner;
  i = u64("0");
  len = Vector.length_(delegations, $c, [
    new SimpleStructTag(DelegatedMintCapability),
  ]);
  index = Option.none_($c, [AtomicTypeTag.U64]);
  while ($.copy(i).lt($.copy(len))) {
    {
      element = Vector.borrow_(delegations, $.copy(i), $c, [
        new SimpleStructTag(DelegatedMintCapability),
      ]);
      if ($.copy(element.to).hex() === $.copy(addr).hex()) {
        index = Option.some_($.copy(i), $c, [AtomicTypeTag.U64]);
        break;
      } else {
      }
      i = $.copy(i).add(u64("1"));
    }
  }
  return $.copy(index);
}

export function has_mint_capability_(
  account: HexString,
  $c: AptosDataCache
): boolean {
  return $c.exists(
    new SimpleStructTag(MintCapStore),
    Signer.address_of_(account, $c)
  );
}

export function initialize_(
  aptos_framework: HexString,
  $c: AptosDataCache
): [Coin.BurnCapability, Coin.MintCapability] {
  let burn_cap, freeze_cap, mint_cap;
  System_addresses.assert_aptos_framework_(aptos_framework, $c);
  [burn_cap, freeze_cap, mint_cap] =
    Coin.initialize_with_parallelizable_supply_(
      aptos_framework,
      String.utf8_(
        [
          u8("65"),
          u8("112"),
          u8("116"),
          u8("111"),
          u8("115"),
          u8("32"),
          u8("67"),
          u8("111"),
          u8("105"),
          u8("110"),
        ],
        $c
      ),
      String.utf8_([u8("65"), u8("80"), u8("84")], $c),
      u8("8"),
      true,
      $c,
      [new SimpleStructTag(AptosCoin)]
    );
  $c.move_to(
    new SimpleStructTag(MintCapStore),
    aptos_framework,
    new MintCapStore(
      { mint_cap: $.copy(mint_cap) },
      new SimpleStructTag(MintCapStore)
    )
  );
  Coin.destroy_freeze_cap_($.copy(freeze_cap), $c, [
    new SimpleStructTag(AptosCoin),
  ]);
  return [$.copy(burn_cap), $.copy(mint_cap)];
}

export function mint_(
  account: HexString,
  dst_addr: HexString,
  amount: U64,
  $c: AptosDataCache
): void {
  let account_addr, coins_minted, mint_cap;
  account_addr = Signer.address_of_(account, $c);
  if (!$c.exists(new SimpleStructTag(MintCapStore), $.copy(account_addr))) {
    throw $.abortCode(Error.not_found_($.copy(ENO_CAPABILITIES), $c));
  }
  mint_cap = $c.borrow_global<MintCapStore>(
    new SimpleStructTag(MintCapStore),
    $.copy(account_addr)
  ).mint_cap;
  coins_minted = Coin.mint_($.copy(amount), mint_cap, $c, [
    new SimpleStructTag(AptosCoin),
  ]);
  Coin.deposit_($.copy(dst_addr), coins_minted, $c, [
    new SimpleStructTag(AptosCoin),
  ]);
  return;
}

export function buildPayload_mint(
  dst_addr: HexString,
  amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "aptos_coin",
    "mint",
    typeParamStrings,
    [dst_addr, amount],
    isJSON
  );
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::aptos_coin::AptosCoin", AptosCoin.AptosCoinParser);
  repo.addParser(
    "0x1::aptos_coin::DelegatedMintCapability",
    DelegatedMintCapability.DelegatedMintCapabilityParser
  );
  repo.addParser("0x1::aptos_coin::Delegations", Delegations.DelegationsParser);
  repo.addParser(
    "0x1::aptos_coin::MintCapStore",
    MintCapStore.MintCapStoreParser
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
  get AptosCoin() {
    return AptosCoin;
  }
  async loadAptosCoin(owner: HexString, loadFull = true, fillCache = true) {
    const val = await AptosCoin.load(
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
  get DelegatedMintCapability() {
    return DelegatedMintCapability;
  }
  get Delegations() {
    return Delegations;
  }
  async loadDelegations(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Delegations.load(
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
  get MintCapStore() {
    return MintCapStore;
  }
  async loadMintCapStore(owner: HexString, loadFull = true, fillCache = true) {
    const val = await MintCapStore.load(
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
  payload_claim_mint_capability(
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_claim_mint_capability(isJSON);
  }
  async claim_mint_capability(
    _account: AptosAccount,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_claim_mint_capability(_isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_delegate_mint_capability(
    to: HexString,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_delegate_mint_capability(to, isJSON);
  }
  async delegate_mint_capability(
    _account: AptosAccount,
    to: HexString,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_delegate_mint_capability(to, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_mint(
    dst_addr: HexString,
    amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_mint(dst_addr, amount, isJSON);
  }
  async mint(
    _account: AptosAccount,
    dst_addr: HexString,
    amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_mint(dst_addr, amount, _isJSON);
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
