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
import * as Signer from "./signer";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "capability";

export const ECAPABILITY_ALREADY_EXISTS: U64 = u64("1");
export const ECAPABILITY_NOT_FOUND: U64 = u64("2");
export const EDELEGATE: U64 = u64("3");

export class Cap {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Cap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "root", typeTag: AtomicTypeTag.Address },
  ];

  root: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto["root"] as HexString;
  }

  static CapParser(data: any, typeTag: TypeTag, repo: AptosParserRepo): Cap {
    const proto = $.parseStructProto(data, typeTag, repo, Cap);
    return new Cap(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "Cap", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class CapDelegateState {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CapDelegateState";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "root", typeTag: AtomicTypeTag.Address },
  ];

  root: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto["root"] as HexString;
  }

  static CapDelegateStateParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CapDelegateState {
    const proto = $.parseStructProto(data, typeTag, repo, CapDelegateState);
    return new CapDelegateState(proto, typeTag);
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
      CapDelegateState,
      typeParams
    );
    return result as unknown as CapDelegateState;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CapDelegateState,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CapDelegateState;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CapDelegateState", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class CapState {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "CapState";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "delegates", typeTag: new VectorTag(AtomicTypeTag.Address) },
  ];

  delegates: HexString[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.delegates = proto["delegates"] as HexString[];
  }

  static CapStateParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): CapState {
    const proto = $.parseStructProto(data, typeTag, repo, CapState);
    return new CapState(proto, typeTag);
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
      CapState,
      typeParams
    );
    return result as unknown as CapState;
  }
  static async loadByApp(
    app: $.AppType,
    address: HexString,
    typeParams: TypeTag[]
  ) {
    const result = await app.repo.loadResource(
      app.client,
      address,
      CapState,
      typeParams
    );
    await result.loadFullState(app);
    return result as unknown as CapState;
  }
  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "CapState", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class LinearCap {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "LinearCap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true },
  ];
  static fields: FieldDeclType[] = [
    { name: "root", typeTag: AtomicTypeTag.Address },
  ];

  root: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto["root"] as HexString;
  }

  static LinearCapParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): LinearCap {
    const proto = $.parseStructProto(data, typeTag, repo, LinearCap);
    return new LinearCap(proto, typeTag);
  }

  static makeTag($p: TypeTag[]): StructTag {
    return new StructTag(moduleAddress, moduleName, "LinearCap", $p);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function acquire_(
  requester: HexString,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): Cap {
  return new Cap(
    { root: validate_acquire_(requester, $c, [$p[0]]) },
    new SimpleStructTag(Cap, [$p[0]])
  );
}

export function acquire_linear_(
  requester: HexString,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): LinearCap {
  return new LinearCap(
    { root: validate_acquire_(requester, $c, [$p[0]]) },
    new SimpleStructTag(LinearCap, [$p[0]])
  );
}

export function add_element_(
  v: any[],
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <E>*/
): void {
  let temp$1, temp$2;
  [temp$1, temp$2] = [v, x];
  if (!Vector.contains_(temp$1, temp$2, $c, [$p[0]])) {
    Vector.push_back_(v, x, $c, [$p[0]]);
  } else {
  }
  return;
}

export function create_(
  owner: HexString,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): void {
  let addr;
  addr = Signer.address_of_(owner, $c);
  if ($c.exists(new SimpleStructTag(CapState, [$p[0]]), $.copy(addr))) {
    throw $.abortCode(
      Error.already_exists_($.copy(ECAPABILITY_ALREADY_EXISTS), $c)
    );
  }
  $c.move_to(
    new SimpleStructTag(CapState, [$p[0]]),
    owner,
    new CapState(
      { delegates: Vector.empty_($c, [AtomicTypeTag.Address]) },
      new SimpleStructTag(CapState, [$p[0]])
    )
  );
  return;
}

export function delegate_(
  cap: Cap,
  _feature_witness: any,
  to: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): void {
  let addr;
  addr = Signer.address_of_(to, $c);
  if ($c.exists(new SimpleStructTag(CapDelegateState, [$p[0]]), $.copy(addr))) {
    return;
  } else {
  }
  $c.move_to(
    new SimpleStructTag(CapDelegateState, [$p[0]]),
    to,
    new CapDelegateState(
      { root: $.copy(cap.root) },
      new SimpleStructTag(CapDelegateState, [$p[0]])
    )
  );
  add_element_(
    $c.borrow_global_mut<CapState>(
      new SimpleStructTag(CapState, [$p[0]]),
      $.copy(cap.root)
    ).delegates,
    $.copy(addr),
    $c,
    [AtomicTypeTag.Address]
  );
  return;
}

export function linear_root_addr_(
  cap: LinearCap,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): HexString {
  return $.copy(cap.root);
}

export function remove_element_(
  v: any[],
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <E>*/
): void {
  let temp$1, temp$2, found, index;
  [temp$1, temp$2] = [v, x];
  [found, index] = Vector.index_of_(temp$1, temp$2, $c, [$p[0]]);
  if (found) {
    Vector.remove_(v, $.copy(index), $c, [$p[0]]);
  } else {
  }
  return;
}

export function revoke_(
  cap: Cap,
  _feature_witness: any,
  from: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): void {
  if (
    !$c.exists(new SimpleStructTag(CapDelegateState, [$p[0]]), $.copy(from))
  ) {
    return;
  } else {
  }
  const { root: _root } = $c.move_from<CapDelegateState>(
    new SimpleStructTag(CapDelegateState, [$p[0]]),
    $.copy(from)
  );
  remove_element_(
    $c.borrow_global_mut<CapState>(
      new SimpleStructTag(CapState, [$p[0]]),
      $.copy(cap.root)
    ).delegates,
    from,
    $c,
    [AtomicTypeTag.Address]
  );
  return;
}

export function root_addr_(
  cap: Cap,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): HexString {
  return $.copy(cap.root);
}

export function validate_acquire_(
  requester: HexString,
  $c: AptosDataCache,
  $p: TypeTag[] /* <Feature>*/
): HexString {
  let temp$1, addr, root_addr;
  addr = Signer.address_of_(requester, $c);
  if ($c.exists(new SimpleStructTag(CapDelegateState, [$p[0]]), $.copy(addr))) {
    root_addr = $.copy(
      $c.borrow_global<CapDelegateState>(
        new SimpleStructTag(CapDelegateState, [$p[0]]),
        $.copy(addr)
      ).root
    );
    if (!$c.exists(new SimpleStructTag(CapState, [$p[0]]), $.copy(root_addr))) {
      throw $.abortCode(Error.invalid_state_($.copy(EDELEGATE), $c));
    }
    if (
      !Vector.contains_(
        $c.borrow_global<CapState>(
          new SimpleStructTag(CapState, [$p[0]]),
          $.copy(root_addr)
        ).delegates,
        addr,
        $c,
        [AtomicTypeTag.Address]
      )
    ) {
      throw $.abortCode(Error.invalid_state_($.copy(EDELEGATE), $c));
    }
    temp$1 = $.copy(root_addr);
  } else {
    if (!$c.exists(new SimpleStructTag(CapState, [$p[0]]), $.copy(addr))) {
      throw $.abortCode(Error.not_found_($.copy(ECAPABILITY_NOT_FOUND), $c));
    }
    temp$1 = $.copy(addr);
  }
  return temp$1;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::capability::Cap", Cap.CapParser);
  repo.addParser(
    "0x1::capability::CapDelegateState",
    CapDelegateState.CapDelegateStateParser
  );
  repo.addParser("0x1::capability::CapState", CapState.CapStateParser);
  repo.addParser("0x1::capability::LinearCap", LinearCap.LinearCapParser);
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
  get Cap() {
    return Cap;
  }
  get CapDelegateState() {
    return CapDelegateState;
  }
  async loadCapDelegateState(
    owner: HexString,
    $p: TypeTag[] /* <Feature> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CapDelegateState.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get CapState() {
    return CapState;
  }
  async loadCapState(
    owner: HexString,
    $p: TypeTag[] /* <Feature> */,
    loadFull = true,
    fillCache = true
  ) {
    const val = await CapState.load(this.repo, this.client, owner, $p);
    if (loadFull) {
      await val.loadFullState(this);
    }
    if (fillCache) {
      this.cache.set(val.typeTag, owner, val);
    }
    return val;
  }
  get LinearCap() {
    return LinearCap;
  }
}
