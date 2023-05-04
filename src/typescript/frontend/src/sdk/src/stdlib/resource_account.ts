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
import { type OptionTransaction } from "@manahippo/move-to-ts";
import {
  type AptosAccount,
  type AptosClient,
  HexString,
  type TxnBuilderTypes,
  type Types,
} from "aptos";

import * as Account from "./account";
import * as Code from "./code";
import * as Coin from "./coin";
import * as Error from "./error";
import * as Signer from "./signer";
import * as Simple_map from "./simple_map";
import * as Vector from "./vector";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "resource_account";

export const ECONTAINER_NOT_PUBLISHED: U64 = u64("1");
export const EUNAUTHORIZED_NOT_OWNER: U64 = u64("2");
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

export class Container {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Container";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "store",
      typeTag: new StructTag(new HexString("0x1"), "simple_map", "SimpleMap", [
        AtomicTypeTag.Address,
        new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
      ]),
    },
  ];

  store: Simple_map.SimpleMap;

  constructor(proto: any, public typeTag: TypeTag) {
    this.store = proto["store"] as Simple_map.SimpleMap;
  }

  static ContainerParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Container {
    const proto = $.parseStructProto(data, typeTag, repo, Container);
    return new Container(proto, typeTag);
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
      Container,
      typeParams
    );
    return result as unknown as Container;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      Container,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as Container;
  }
  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Container", []);
  }
  async loadFullState(app: $.AppType) {
    await this.store.loadFullState(app);
    this.__app = app;
  }
}
export function create_resource_account_(
  origin: HexString,
  seed: U8[],
  optional_auth_key: U8[],
  $c: AptosDataCache
): void {
  let resource, resource_signer_cap;
  [resource, resource_signer_cap] = Account.create_resource_account_(
    origin,
    $.copy(seed),
    $c
  );
  rotate_account_authentication_key_and_store_capability_(
    origin,
    resource,
    resource_signer_cap,
    $.copy(optional_auth_key),
    $c
  );
  return;
}

export function buildPayload_create_resource_account(
  seed: U8[],
  optional_auth_key: U8[],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "resource_account",
    "create_resource_account",
    typeParamStrings,
    [seed, optional_auth_key],
    isJSON
  );
}
export function create_resource_account_and_fund_(
  origin: HexString,
  seed: U8[],
  optional_auth_key: U8[],
  fund_amount: U64,
  $c: AptosDataCache
): void {
  let resource, resource_signer_cap;
  [resource, resource_signer_cap] = Account.create_resource_account_(
    origin,
    $.copy(seed),
    $c
  );
  Coin.register_(resource, $c, [
    new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", []),
  ]);
  Coin.transfer_(
    origin,
    Signer.address_of_(resource, $c),
    $.copy(fund_amount),
    $c,
    [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]
  );
  rotate_account_authentication_key_and_store_capability_(
    origin,
    resource,
    resource_signer_cap,
    $.copy(optional_auth_key),
    $c
  );
  return;
}

export function buildPayload_create_resource_account_and_fund(
  seed: U8[],
  optional_auth_key: U8[],
  fund_amount: U64,
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "resource_account",
    "create_resource_account_and_fund",
    typeParamStrings,
    [seed, optional_auth_key, fund_amount],
    isJSON
  );
}
export function create_resource_account_and_publish_package_(
  origin: HexString,
  seed: U8[],
  metadata_serialized: U8[],
  code: U8[][],
  $c: AptosDataCache
): void {
  let resource, resource_signer_cap;
  [resource, resource_signer_cap] = Account.create_resource_account_(
    origin,
    $.copy(seed),
    $c
  );
  Code.publish_package_txn_(
    resource,
    $.copy(metadata_serialized),
    $.copy(code),
    $c
  );
  rotate_account_authentication_key_and_store_capability_(
    origin,
    resource,
    resource_signer_cap,
    $.copy(ZERO_AUTH_KEY),
    $c
  );
  return;
}

export function buildPayload_create_resource_account_and_publish_package(
  seed: U8[],
  metadata_serialized: U8[],
  code: U8[][],
  isJSON = false
):
  | TxnBuilderTypes.TransactionPayloadEntryFunction
  | Types.TransactionPayload_EntryFunctionPayload {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    new HexString("0x1"),
    "resource_account",
    "create_resource_account_and_publish_package",
    typeParamStrings,
    [seed, metadata_serialized, code],
    isJSON
  );
}
export function retrieve_resource_account_cap_(
  resource: HexString,
  source_addr: HexString,
  $c: AptosDataCache
): Account.SignerCapability {
  let _resource_addr,
    container,
    container__1,
    empty_container,
    resource__2,
    resource_addr,
    resource_signer_cap,
    signer_cap;
  if (!$c.exists(new SimpleStructTag(Container), $.copy(source_addr))) {
    throw $.abortCode(Error.not_found_($.copy(ECONTAINER_NOT_PUBLISHED), $c));
  }
  resource_addr = Signer.address_of_(resource, $c);
  container = $c.borrow_global_mut<Container>(
    new SimpleStructTag(Container),
    $.copy(source_addr)
  );
  if (
    !Simple_map.contains_key_(container.store, resource_addr, $c, [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
    ])
  ) {
    throw $.abortCode(
      Error.invalid_argument_($.copy(EUNAUTHORIZED_NOT_OWNER), $c)
    );
  }
  [_resource_addr, signer_cap] = Simple_map.remove_(
    container.store,
    resource_addr,
    $c,
    [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
    ]
  );
  [resource_signer_cap, empty_container] = [
    signer_cap,
    Simple_map.length_(container.store, $c, [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
    ]).eq(u64("0")),
  ];
  if (empty_container) {
    container__1 = $c.move_from<Container>(
      new SimpleStructTag(Container),
      $.copy(source_addr)
    );
    const { store: store } = container__1;
    Simple_map.destroy_empty_(store, $c, [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
    ]);
  } else {
  }
  resource__2 = Account.create_signer_with_capability_(resource_signer_cap, $c);
  Account.rotate_authentication_key_internal_(
    resource__2,
    $.copy(ZERO_AUTH_KEY),
    $c
  );
  return resource_signer_cap;
}

export function rotate_account_authentication_key_and_store_capability_(
  origin: HexString,
  resource: HexString,
  resource_signer_cap: Account.SignerCapability,
  optional_auth_key: U8[],
  $c: AptosDataCache
): void {
  let temp$1, auth_key, container, origin_addr, resource_addr;
  origin_addr = Signer.address_of_(origin, $c);
  if (!$c.exists(new SimpleStructTag(Container), $.copy(origin_addr))) {
    $c.move_to(
      new SimpleStructTag(Container),
      origin,
      new Container(
        {
          store: Simple_map.create_($c, [
            AtomicTypeTag.Address,
            new StructTag(
              new HexString("0x1"),
              "account",
              "SignerCapability",
              []
            ),
          ]),
        },
        new SimpleStructTag(Container)
      )
    );
  } else {
  }
  container = $c.borrow_global_mut<Container>(
    new SimpleStructTag(Container),
    $.copy(origin_addr)
  );
  resource_addr = Signer.address_of_(resource, $c);
  Simple_map.add_(
    container.store,
    $.copy(resource_addr),
    resource_signer_cap,
    $c,
    [
      AtomicTypeTag.Address,
      new StructTag(new HexString("0x1"), "account", "SignerCapability", []),
    ]
  );
  if (Vector.is_empty_(optional_auth_key, $c, [AtomicTypeTag.U8])) {
    temp$1 = Account.get_authentication_key_($.copy(origin_addr), $c);
  } else {
    temp$1 = $.copy(optional_auth_key);
  }
  auth_key = temp$1;
  Account.rotate_authentication_key_internal_(resource, $.copy(auth_key), $c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::resource_account::Container", Container.ContainerParser);
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
  get Container() {
    return Container;
  }
  async loadContainer(owner: HexString, loadFull = true, fillCache = true) {
    const val = await Container.load(
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
  payload_create_resource_account(
    seed: U8[],
    optional_auth_key: U8[],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_create_resource_account(
      seed,
      optional_auth_key,
      isJSON
    );
  }
  async create_resource_account(
    _account: AptosAccount,
    seed: U8[],
    optional_auth_key: U8[],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_create_resource_account(
      seed,
      optional_auth_key,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_create_resource_account_and_fund(
    seed: U8[],
    optional_auth_key: U8[],
    fund_amount: U64,
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_create_resource_account_and_fund(
      seed,
      optional_auth_key,
      fund_amount,
      isJSON
    );
  }
  async create_resource_account_and_fund(
    _account: AptosAccount,
    seed: U8[],
    optional_auth_key: U8[],
    fund_amount: U64,
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_create_resource_account_and_fund(
      seed,
      optional_auth_key,
      fund_amount,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
  payload_create_resource_account_and_publish_package(
    seed: U8[],
    metadata_serialized: U8[],
    code: U8[][],
    isJSON = false
  ):
    | TxnBuilderTypes.TransactionPayloadEntryFunction
    | Types.TransactionPayload_EntryFunctionPayload {
    return buildPayload_create_resource_account_and_publish_package(
      seed,
      metadata_serialized,
      code,
      isJSON
    );
  }
  async create_resource_account_and_publish_package(
    _account: AptosAccount,
    seed: U8[],
    metadata_serialized: U8[],
    code: U8[][],
    option?: OptionTransaction,
    _isJSON = false
  ) {
    const payload__ = buildPayload_create_resource_account_and_publish_package(
      seed,
      metadata_serialized,
      code,
      _isJSON
    );
    return $.sendPayloadTx(this.client, _account, payload__, option);
  }
}
