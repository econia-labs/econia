import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Error from "./error";
import * as Signer from "./signer";
import * as Vector from "./vector";
export const packageName = "AptosStdlib";
export const moduleAddress = new HexString("0x1");
export const moduleName = "capability";

export const ECAP : U64 = u64("0");
export const EDELEGATE : U64 = u64("1");


export class Cap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Cap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "root", typeTag: AtomicTypeTag.Address }];

  root: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto['root'] as HexString;
  }

  static CapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Cap {
    const proto = $.parseStructProto(data, typeTag, repo, Cap);
    return new Cap(proto, typeTag);
  }

}

export class CapDelegateState 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CapDelegateState";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "root", typeTag: AtomicTypeTag.Address }];

  root: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto['root'] as HexString;
  }

  static CapDelegateStateParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CapDelegateState {
    const proto = $.parseStructProto(data, typeTag, repo, CapDelegateState);
    return new CapDelegateState(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, CapDelegateState, typeParams);
    return result as unknown as CapDelegateState;
  }
}

export class CapState 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CapState";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "delegates", typeTag: new VectorTag(AtomicTypeTag.Address) }];

  delegates: HexString[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.delegates = proto['delegates'] as HexString[];
  }

  static CapStateParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CapState {
    const proto = $.parseStructProto(data, typeTag, repo, CapState);
    return new CapState(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, CapState, typeParams);
    return result as unknown as CapState;
  }
}

export class LinearCap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "LinearCap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Feature", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "root", typeTag: AtomicTypeTag.Address }];

  root: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.root = proto['root'] as HexString;
  }

  static LinearCapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : LinearCap {
    const proto = $.parseStructProto(data, typeTag, repo, LinearCap);
    return new LinearCap(proto, typeTag);
  }

}
export function acquire_ (
  requester: HexString,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): Cap {
  return new Cap({ root: validate_acquire_(requester, $c, [$p[0]]) }, new StructTag(new HexString("0x1"), "capability", "Cap", [$p[0]]));
}

export function acquire_linear_ (
  requester: HexString,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): LinearCap {
  return new LinearCap({ root: validate_acquire_(requester, $c, [$p[0]]) }, new StructTag(new HexString("0x1"), "capability", "LinearCap", [$p[0]]));
}

export function add_element_ (
  v: any[],
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <E>*/
): void {
  let temp$1, temp$2;
  [temp$1, temp$2] = [v, x];
  if (!Vector.contains_(temp$1, temp$2, $c, [$p[0]])) {
    Vector.push_back_(v, x, $c, [$p[0]]);
  }
  else{
  }
  return;
}

export function create_ (
  owner: HexString,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): void {
  let addr;
  addr = Signer.address_of_(owner, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(Error.already_exists_(ECAP, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), owner, new CapState({ delegates: Vector.empty_($c, [AtomicTypeTag.Address]) }, new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]])));
  return;
}

export function delegate_ (
  cap: Cap,
  _feature_witness: any,
  to: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): void {
  let addr;
  addr = Signer.address_of_(to, $c);
  if ($c.exists(new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]]), $.copy(addr))) {
    return;
  }
  else{
  }
  $c.move_to(new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]]), to, new CapDelegateState({ root: $.copy(cap.root) }, new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]])));
  add_element_($c.borrow_global_mut<CapState>(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), $.copy(cap.root)).delegates, $.copy(addr), $c, [AtomicTypeTag.Address]);
  return;
}

export function linear_root_addr_ (
  cap: LinearCap,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): HexString {
  return $.copy(cap.root);
}

export function remove_element_ (
  v: any[],
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <E>*/
): void {
  let temp$1, temp$2, found, index;
  [temp$1, temp$2] = [v, x];
  [found, index] = Vector.index_of_(temp$1, temp$2, $c, [$p[0]]);
  if (found) {
    Vector.remove_(v, $.copy(index), $c, [$p[0]]);
  }
  else{
  }
  return;
}

export function revoke_ (
  cap: Cap,
  _feature_witness: any,
  from: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): void {
  if (!$c.exists(new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]]), $.copy(from))) {
    return;
  }
  else{
  }
  let { root: _root } = $c.move_from<CapDelegateState>(new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]]), $.copy(from));
  remove_element_($c.borrow_global_mut<CapState>(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), $.copy(cap.root)).delegates, from, $c, [AtomicTypeTag.Address]);
  return;
}

export function root_addr_ (
  cap: Cap,
  _feature_witness: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): HexString {
  return $.copy(cap.root);
}

export function validate_acquire_ (
  requester: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Feature>*/
): HexString {
  let temp$1, addr, root_addr;
  addr = Signer.address_of_(requester, $c);
  if ($c.exists(new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]]), $.copy(addr))) {
    root_addr = $.copy($c.borrow_global<CapDelegateState>(new StructTag(new HexString("0x1"), "capability", "CapDelegateState", [$p[0]]), $.copy(addr)).root);
    if (!$c.exists(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), $.copy(root_addr))) {
      throw $.abortCode(Error.invalid_state_(EDELEGATE, $c));
    }
    if (!Vector.contains_($c.borrow_global<CapState>(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), $.copy(root_addr)).delegates, addr, $c, [AtomicTypeTag.Address])) {
      throw $.abortCode(Error.invalid_state_(EDELEGATE, $c));
    }
    temp$1 = $.copy(root_addr);
  }
  else{
    if (!$c.exists(new StructTag(new HexString("0x1"), "capability", "CapState", [$p[0]]), $.copy(addr))) {
      throw $.abortCode(Error.not_found_(ECAP, $c));
    }
    temp$1 = $.copy(addr);
  }
  return temp$1;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::capability::Cap", Cap.CapParser);
  repo.addParser("0x1::capability::CapDelegateState", CapDelegateState.CapDelegateStateParser);
  repo.addParser("0x1::capability::CapState", CapState.CapStateParser);
  repo.addParser("0x1::capability::LinearCap", LinearCap.LinearCapParser);
}

