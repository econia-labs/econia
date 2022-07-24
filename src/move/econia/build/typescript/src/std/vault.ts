import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as error$_ from "./error";
import * as event$_ from "./event";
import * as option$_ from "./option";
import * as signer$_ from "./signer";
import * as vector$_ from "./vector";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "vault";

export const EACCESSOR_INCONSISTENCY : U64 = u64("3");
export const EACCESSOR_IN_USE : U64 = u64("2");
export const EDELEGATE : U64 = u64("1");
export const EDELEGATE_TO_SELF : U64 = u64("4");
export const EDELEGATION_NOT_ENABLED : U64 = u64("5");
export const EEVENT : U64 = u64("6");
export const EVAULT : U64 = u64("0");


export class CapType 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "CapType";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "code", typeTag: AtomicTypeTag.U8 }];

  code: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.code = proto['code'] as U8;
  }

  static CapTypeParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : CapType {
    const proto = $.parseStructProto(data, typeTag, repo, CapType);
    return new CapType(proto, typeTag);
  }

}

export class DelegateCap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "DelegateCap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "authority", typeTag: AtomicTypeTag.Address }];

  vault_address: HexString;
  authority: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.vault_address = proto['vault_address'] as HexString;
    this.authority = proto['authority'] as HexString;
  }

  static DelegateCapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : DelegateCap {
    const proto = $.parseStructProto(data, typeTag, repo, DelegateCap);
    return new DelegateCap(proto, typeTag);
  }

}

export class ModifyAccessor 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ModifyAccessor";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "content", typeTag: new $.TypeParamIdx(0) },
  { name: "vault_address", typeTag: AtomicTypeTag.Address }];

  content: any;
  vault_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.content = proto['content'] as any;
    this.vault_address = proto['vault_address'] as HexString;
  }

  static ModifyAccessorParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ModifyAccessor {
    const proto = $.parseStructProto(data, typeTag, repo, ModifyAccessor);
    return new ModifyAccessor(proto, typeTag);
  }

}

export class ModifyCap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ModifyCap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "authority", typeTag: AtomicTypeTag.Address }];

  vault_address: HexString;
  authority: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.vault_address = proto['vault_address'] as HexString;
    this.authority = proto['authority'] as HexString;
  }

  static ModifyCapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ModifyCap {
    const proto = $.parseStructProto(data, typeTag, repo, ModifyCap);
    return new ModifyCap(proto, typeTag);
  }

}

export class ReadAccessor 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ReadAccessor";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "content", typeTag: new $.TypeParamIdx(0) },
  { name: "vault_address", typeTag: AtomicTypeTag.Address }];

  content: any;
  vault_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.content = proto['content'] as any;
    this.vault_address = proto['vault_address'] as HexString;
  }

  static ReadAccessorParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ReadAccessor {
    const proto = $.parseStructProto(data, typeTag, repo, ReadAccessor);
    return new ReadAccessor(proto, typeTag);
  }

}

export class ReadCap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ReadCap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "authority", typeTag: AtomicTypeTag.Address }];

  vault_address: HexString;
  authority: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.vault_address = proto['vault_address'] as HexString;
    this.authority = proto['authority'] as HexString;
  }

  static ReadCapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ReadCap {
    const proto = $.parseStructProto(data, typeTag, repo, ReadCap);
    return new ReadCap(proto, typeTag);
  }

}

export class TransferCap 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TransferCap";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "authority", typeTag: AtomicTypeTag.Address }];

  vault_address: HexString;
  authority: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.vault_address = proto['vault_address'] as HexString;
    this.authority = proto['authority'] as HexString;
  }

  static TransferCapParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TransferCap {
    const proto = $.parseStructProto(data, typeTag, repo, TransferCap);
    return new TransferCap(proto, typeTag);
  }

}

export class Vault 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Vault";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "content", typeTag: new StructTag(new HexString("0x1"), "option", "Option", [new $.TypeParamIdx(0)]) }];

  content: option$_.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.content = proto['content'] as option$_.Option;
  }

  static VaultParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Vault {
    const proto = $.parseStructProto(data, typeTag, repo, Vault);
    return new Vault(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Vault, typeParams);
    return result as unknown as Vault;
  }
}

export class VaultDelegate 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VaultDelegate";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "granted_caps", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "vault", "CapType", [])) }];

  vault_address: HexString;
  granted_caps: CapType[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.vault_address = proto['vault_address'] as HexString;
    this.granted_caps = proto['granted_caps'] as CapType[];
  }

  static VaultDelegateParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VaultDelegate {
    const proto = $.parseStructProto(data, typeTag, repo, VaultDelegate);
    return new VaultDelegate(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, VaultDelegate, typeParams);
    return result as unknown as VaultDelegate;
  }
}

export class VaultDelegateEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VaultDelegateEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "metadata", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "authority", typeTag: AtomicTypeTag.Address },
  { name: "delegate", typeTag: AtomicTypeTag.Address },
  { name: "cap", typeTag: new StructTag(new HexString("0x1"), "vault", "CapType", []) },
  { name: "is_revoked", typeTag: AtomicTypeTag.Bool }];

  metadata: U8[];
  vault_address: HexString;
  authority: HexString;
  delegate: HexString;
  cap: CapType;
  is_revoked: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.metadata = proto['metadata'] as U8[];
    this.vault_address = proto['vault_address'] as HexString;
    this.authority = proto['authority'] as HexString;
    this.delegate = proto['delegate'] as HexString;
    this.cap = proto['cap'] as CapType;
    this.is_revoked = proto['is_revoked'] as boolean;
  }

  static VaultDelegateEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VaultDelegateEvent {
    const proto = $.parseStructProto(data, typeTag, repo, VaultDelegateEvent);
    return new VaultDelegateEvent(proto, typeTag);
  }

}

export class VaultDelegates 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VaultDelegates";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "delegates", typeTag: new VectorTag(AtomicTypeTag.Address) }];

  delegates: HexString[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.delegates = proto['delegates'] as HexString[];
  }

  static VaultDelegatesParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VaultDelegates {
    const proto = $.parseStructProto(data, typeTag, repo, VaultDelegates);
    return new VaultDelegates(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, VaultDelegates, typeParams);
    return result as unknown as VaultDelegates;
  }
}

export class VaultEvents 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VaultEvents";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Content", isPhantom: true }
  ];
  static fields: FieldDeclType[] = [
  { name: "metadata", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "delegate_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "vault", "VaultDelegateEvent", [])]) },
  { name: "transfer_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "vault", "VaultTransferEvent", [])]) }];

  metadata: U8[];
  delegate_events: event$_.EventHandle;
  transfer_events: event$_.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.metadata = proto['metadata'] as U8[];
    this.delegate_events = proto['delegate_events'] as event$_.EventHandle;
    this.transfer_events = proto['transfer_events'] as event$_.EventHandle;
  }

  static VaultEventsParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VaultEvents {
    const proto = $.parseStructProto(data, typeTag, repo, VaultEvents);
    return new VaultEvents(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, VaultEvents, typeParams);
    return result as unknown as VaultEvents;
  }
}

export class VaultTransferEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "VaultTransferEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "metadata", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "vault_address", typeTag: AtomicTypeTag.Address },
  { name: "authority", typeTag: AtomicTypeTag.Address },
  { name: "new_vault_address", typeTag: AtomicTypeTag.Address }];

  metadata: U8[];
  vault_address: HexString;
  authority: HexString;
  new_vault_address: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.metadata = proto['metadata'] as U8[];
    this.vault_address = proto['vault_address'] as HexString;
    this.authority = proto['authority'] as HexString;
    this.new_vault_address = proto['new_vault_address'] as HexString;
  }

  static VaultTransferEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : VaultTransferEvent {
    const proto = $.parseStructProto(data, typeTag, repo, VaultTransferEvent);
    return new VaultTransferEvent(proto, typeTag);
  }

}
export function acquire_delegate_cap$ (
  requester: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): DelegateCap {
  let authority, vault_address;
  [vault_address, authority] = validate_cap$(requester, delegate_cap_type$($c), $c, [$p[0]] as TypeTag[]);
  return new DelegateCap({ vault_address: $.copy(vault_address), authority: $.copy(authority) }, new StructTag(new HexString("0x1"), "vault", "DelegateCap", [$p[0]]));
}

export function acquire_modify_cap$ (
  requester: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): ModifyCap {
  let authority, vault_address;
  [vault_address, authority] = validate_cap$(requester, modify_cap_type$($c), $c, [$p[0]] as TypeTag[]);
  return new ModifyCap({ vault_address: $.copy(vault_address), authority: $.copy(authority) }, new StructTag(new HexString("0x1"), "vault", "ModifyCap", [$p[0]]));
}

export function acquire_read_cap$ (
  requester: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): ReadCap {
  let authority, vault_address;
  [vault_address, authority] = validate_cap$(requester, read_cap_type$($c), $c, [$p[0]] as TypeTag[]);
  return new ReadCap({ vault_address: $.copy(vault_address), authority: $.copy(authority) }, new StructTag(new HexString("0x1"), "vault", "ReadCap", [$p[0]]));
}

export function acquire_transfer_cap$ (
  requester: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): TransferCap {
  let authority, vault_address;
  [vault_address, authority] = validate_cap$(requester, transfer_cap_type$($c), $c, [$p[0]] as TypeTag[]);
  return new TransferCap({ vault_address: $.copy(vault_address), authority: $.copy(authority) }, new StructTag(new HexString("0x1"), "vault", "TransferCap", [$p[0]]));
}

export function add_element$ (
  v: any[],
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <E>*/
): void {
  let temp$1, temp$2;
  [temp$1, temp$2] = [v, x];
  if (!vector$_.contains$(temp$1, temp$2, $c, [$p[0]] as TypeTag[])) {
    vector$_.push_back$(v, x, $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  return;
}

export function borrow$ (
  accessor: ReadAccessor,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): any {
  return accessor.content;
}

export function borrow_mut$ (
  accessor: ModifyAccessor,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): any {
  return accessor.content;
}

export function delegate$ (
  cap: DelegateCap,
  to_signer: HexString,
  cap_type: CapType,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let addr, delegate, vault_delegates;
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address))) {
    throw $.abortCode(error$_.invalid_state$(EDELEGATION_NOT_ENABLED, $c));
  }
  addr = signer$_.address_of$(to_signer, $c);
  if (!($.copy(addr).hex() !== $.copy(cap.vault_address).hex())) {
    throw $.abortCode(error$_.invalid_argument$(EDELEGATE_TO_SELF, $c));
  }
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr))) {
    $c.move_to(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), to_signer, new VaultDelegate({ vault_address: $.copy(cap.vault_address), granted_caps: vector$_.empty$($c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]])));
    vault_delegates = $c.borrow_global_mut<VaultDelegates>(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address));
    add_element$(vault_delegates.delegates, $.copy(addr), $c, [AtomicTypeTag.Address] as TypeTag[]);
  }
  else{
  }
  delegate = $c.borrow_global_mut<VaultDelegate>(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr));
  add_element$(delegate.granted_caps, $.copy(cap_type), $c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[]);
  emit_delegate_event$(cap, $.copy(cap_type), $.copy(addr), false, $c, [$p[0]] as TypeTag[]);
  return;
}

export function delegate_cap_type$ (
  $c: AptosDataCache,
): CapType {
  return new CapType({ code: u8("2") }, new StructTag(new HexString("0x1"), "vault", "CapType", []));
}

export function emit_delegate_event$ (
  cap: DelegateCap,
  cap_type: CapType,
  delegate: HexString,
  is_revoked: boolean,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let event;
  if ($c.exists(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(cap.vault_address))) {
    event = new VaultDelegateEvent({ metadata: $.copy($c.borrow_global<VaultEvents>(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(cap.vault_address)).metadata), vault_address: $.copy(cap.vault_address), authority: $.copy(cap.authority), delegate: $.copy(delegate), cap: $.copy(cap_type), is_revoked: is_revoked }, new StructTag(new HexString("0x1"), "vault", "VaultDelegateEvent", []));
    event$_.emit_event$($c.borrow_global_mut<VaultEvents>(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(cap.vault_address)).delegate_events, event, $c, [new StructTag(new HexString("0x1"), "vault", "VaultDelegateEvent", [])] as TypeTag[]);
  }
  else{
  }
  return;
}

export function enable_delegation$ (
  owner: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  if (!!is_delegation_enabled$(owner, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.already_exists$(EDELEGATE, $c));
  }
  return $c.move_to(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), owner, new VaultDelegates({ delegates: vector$_.empty$($c, [AtomicTypeTag.Address] as TypeTag[]) }, new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]])));
}

export function enable_events$ (
  owner: HexString,
  metadata: U8[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let addr;
  addr = signer$_.address_of$(owner, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(error$_.not_found$(EVAULT, $c));
  }
  if (!!$c.exists(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(error$_.already_exists$(EEVENT, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), owner, new VaultEvents({ metadata: $.copy(metadata), delegate_events: event$_.new_event_handle$(owner, $c, [new StructTag(new HexString("0x1"), "vault", "VaultDelegateEvent", [])] as TypeTag[]), transfer_events: event$_.new_event_handle$(owner, $c, [new StructTag(new HexString("0x1"), "vault", "VaultTransferEvent", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]])));
  return;
}

export function is_delegation_enabled$ (
  owner: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): boolean {
  let addr;
  addr = signer$_.address_of$(owner, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(error$_.not_found$(EVAULT, $c));
  }
  return $c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(addr));
}

export function modify_accessor$ (
  cap: ModifyCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): ModifyAccessor {
  let temp$1, temp$2, content;
  content = $c.borrow_global_mut<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(cap.vault_address)).content;
  if (!option$_.is_some$(content, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.invalid_state$(EACCESSOR_IN_USE, $c));
  }
  temp$1 = $.copy(cap.vault_address);
  temp$2 = option$_.extract$(content, $c, [$p[0]] as TypeTag[]);
  return new ModifyAccessor({ content: temp$2, vault_address: temp$1 }, new StructTag(new HexString("0x1"), "vault", "ModifyAccessor", [$p[0]]));
}

export function modify_cap_type$ (
  $c: AptosDataCache,
): CapType {
  return new CapType({ code: u8("1") }, new StructTag(new HexString("0x1"), "vault", "CapType", []));
}

export function new__$ (
  owner: HexString,
  initial_content: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let addr;
  addr = signer$_.address_of$(owner, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(error$_.already_exists$(EVAULT, $c));
  }
  return $c.move_to(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), owner, new Vault({ content: option$_.some$(initial_content, $c, [$p[0]] as TypeTag[]) }, new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]])));
}

export function read_accessor$ (
  cap: ReadCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): ReadAccessor {
  let temp$1, temp$2, content;
  content = $c.borrow_global_mut<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(cap.vault_address)).content;
  if (!option$_.is_some$(content, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.invalid_state$(EACCESSOR_IN_USE, $c));
  }
  temp$1 = $.copy(cap.vault_address);
  temp$2 = option$_.extract$(content, $c, [$p[0]] as TypeTag[]);
  return new ReadAccessor({ content: temp$2, vault_address: temp$1 }, new StructTag(new HexString("0x1"), "vault", "ReadAccessor", [$p[0]]));
}

export function read_cap_type$ (
  $c: AptosDataCache,
): CapType {
  return new CapType({ code: u8("0") }, new StructTag(new HexString("0x1"), "vault", "CapType", []));
}

export function release_modify_accessor$ (
  accessor: ModifyAccessor,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let content;
  let { content: new_content, vault_address: vault_address } = accessor;
  content = $c.borrow_global_mut<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(vault_address)).content;
  if (!option$_.is_none$(content, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.internal$(EACCESSOR_INCONSISTENCY, $c));
  }
  option$_.fill$(content, new_content, $c, [$p[0]] as TypeTag[]);
  return;
}

export function release_read_accessor$ (
  accessor: ReadAccessor,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let content;
  let { content: new_content, vault_address: vault_address } = accessor;
  content = $c.borrow_global_mut<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(vault_address)).content;
  if (!option$_.is_none$(content, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.internal$(EACCESSOR_INCONSISTENCY, $c));
  }
  option$_.fill$(content, new_content, $c, [$p[0]] as TypeTag[]);
  return;
}

export function remove_element$ (
  v: any[],
  x: any,
  $c: AptosDataCache,
  $p: TypeTag[], /* <E>*/
): void {
  let temp$1, temp$2, found, index;
  [temp$1, temp$2] = [v, x];
  [found, index] = vector$_.index_of$(temp$1, temp$2, $c, [$p[0]] as TypeTag[]);
  if (found) {
    vector$_.remove$(v, $.copy(index), $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  return;
}

export function remove_vault$ (
  owner: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): any {
  let addr, delegate_cap;
  addr = signer$_.address_of$(owner, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(error$_.not_found$(EVAULT, $c));
  }
  let { content: content } = $c.move_from<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(addr));
  if (!option$_.is_some$(content, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.invalid_state$(EACCESSOR_IN_USE, $c));
  }
  if ($c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(addr))) {
    delegate_cap = new DelegateCap({ vault_address: $.copy(addr), authority: $.copy(addr) }, new StructTag(new HexString("0x1"), "vault", "DelegateCap", [$p[0]]));
    revoke_all$(delegate_cap, $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  if ($c.exists(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(addr))) {
    let { metadata: _metadata, delegate_events: delegate_events, transfer_events: transfer_events } = $c.move_from<VaultEvents>(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(addr));
    event$_.destroy_handle$(delegate_events, $c, [new StructTag(new HexString("0x1"), "vault", "VaultDelegateEvent", [])] as TypeTag[]);
    event$_.destroy_handle$(transfer_events, $c, [new StructTag(new HexString("0x1"), "vault", "VaultTransferEvent", [])] as TypeTag[]);
  }
  else{
  }
  return option$_.extract$(content, $c, [$p[0]] as TypeTag[]);
}

export function revoke$ (
  cap: DelegateCap,
  addr: HexString,
  cap_type: CapType,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let delegate, vault_delegates;
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address))) {
    throw $.abortCode(error$_.invalid_state$(EDELEGATION_NOT_ENABLED, $c));
  }
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr))) {
    throw $.abortCode(error$_.not_found$(EDELEGATE, $c));
  }
  delegate = $c.borrow_global_mut<VaultDelegate>(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr));
  remove_element$(delegate.granted_caps, cap_type, $c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[]);
  if (vector$_.is_empty$(delegate.granted_caps, $c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[])) {
    let { vault_address: _owner, granted_caps: _granted_caps } = $c.move_from<VaultDelegate>(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr));
    vault_delegates = $c.borrow_global_mut<VaultDelegates>(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address));
    remove_element$(vault_delegates.delegates, addr, $c, [AtomicTypeTag.Address] as TypeTag[]);
  }
  else{
  }
  emit_delegate_event$(cap, $.copy(cap_type), $.copy(addr), true, $c, [$p[0]] as TypeTag[]);
  return;
}

export function revoke_all$ (
  cap: DelegateCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let addr, cap_type, delegates;
  if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address))) {
    throw $.abortCode(error$_.invalid_state$(EDELEGATION_NOT_ENABLED, $c));
  }
  delegates = $c.borrow_global_mut<VaultDelegates>(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address)).delegates;
  while (!vector$_.is_empty$(delegates, $c, [AtomicTypeTag.Address] as TypeTag[])) {
    {
      addr = vector$_.pop_back$(delegates, $c, [AtomicTypeTag.Address] as TypeTag[]);
      let { vault_address: _vault_address, granted_caps: granted_caps } = $c.move_from<VaultDelegate>(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(cap.vault_address));
      while (!vector$_.is_empty$(granted_caps, $c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[])) {
        {
          cap_type = vector$_.pop_back$(granted_caps, $c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[]);
          emit_delegate_event$(cap, $.copy(cap_type), $.copy(addr), true, $c, [$p[0]] as TypeTag[]);
        }

      }}

  }return;
}

export function transfer$ (
  cap: TransferCap,
  to_owner: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): void {
  let delegate_cap, event, new_addr;
  new_addr = signer$_.address_of$(to_owner, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(new_addr))) {
    throw $.abortCode(error$_.already_exists$(EVAULT, $c));
  }
  if (!option$_.is_some$($c.borrow_global<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(cap.vault_address)).content, $c, [$p[0]] as TypeTag[])) {
    throw $.abortCode(error$_.invalid_state$(EACCESSOR_IN_USE, $c));
  }
  if ($c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegates", [$p[0]]), $.copy(cap.vault_address))) {
    delegate_cap = new DelegateCap({ vault_address: $.copy(cap.vault_address), authority: $.copy(cap.authority) }, new StructTag(new HexString("0x1"), "vault", "DelegateCap", [$p[0]]));
    revoke_all$(delegate_cap, $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  if ($c.exists(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(cap.vault_address))) {
    event = new VaultTransferEvent({ metadata: $.copy($c.borrow_global<VaultEvents>(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(cap.vault_address)).metadata), vault_address: $.copy(cap.vault_address), authority: $.copy(cap.authority), new_vault_address: $.copy(new_addr) }, new StructTag(new HexString("0x1"), "vault", "VaultTransferEvent", []));
    event$_.emit_event$($c.borrow_global_mut<VaultEvents>(new StructTag(new HexString("0x1"), "vault", "VaultEvents", [$p[0]]), $.copy(cap.vault_address)).transfer_events, event, $c, [new StructTag(new HexString("0x1"), "vault", "VaultTransferEvent", [])] as TypeTag[]);
  }
  else{
  }
  $c.move_to(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), to_owner, $c.move_from<Vault>(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(cap.vault_address)));
  return;
}

export function transfer_cap_type$ (
  $c: AptosDataCache,
): CapType {
  return new CapType({ code: u8("3") }, new StructTag(new HexString("0x1"), "vault", "CapType", []));
}

export function validate_cap$ (
  requester: HexString,
  cap: CapType,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Content>*/
): [HexString, HexString] {
  let temp$1, temp$2, addr, delegate;
  addr = signer$_.address_of$(requester, $c);
  if ($c.exists(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr))) {
    delegate = $c.borrow_global<VaultDelegate>(new StructTag(new HexString("0x1"), "vault", "VaultDelegate", [$p[0]]), $.copy(addr));
    if (!vector$_.contains$(delegate.granted_caps, cap, $c, [new StructTag(new HexString("0x1"), "vault", "CapType", [])] as TypeTag[])) {
      throw $.abortCode(error$_.permission_denied$(EDELEGATE, $c));
    }
    [temp$1, temp$2] = [$.copy(delegate.vault_address), $.copy(addr)];
  }
  else{
    if (!$c.exists(new StructTag(new HexString("0x1"), "vault", "Vault", [$p[0]]), $.copy(addr))) {
      throw $.abortCode(error$_.not_found$(EVAULT, $c));
    }
    [temp$1, temp$2] = [$.copy(addr), $.copy(addr)];
  }
  return [temp$1, temp$2];
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::vault::CapType", CapType.CapTypeParser);
  repo.addParser("0x1::vault::DelegateCap", DelegateCap.DelegateCapParser);
  repo.addParser("0x1::vault::ModifyAccessor", ModifyAccessor.ModifyAccessorParser);
  repo.addParser("0x1::vault::ModifyCap", ModifyCap.ModifyCapParser);
  repo.addParser("0x1::vault::ReadAccessor", ReadAccessor.ReadAccessorParser);
  repo.addParser("0x1::vault::ReadCap", ReadCap.ReadCapParser);
  repo.addParser("0x1::vault::TransferCap", TransferCap.TransferCapParser);
  repo.addParser("0x1::vault::Vault", Vault.VaultParser);
  repo.addParser("0x1::vault::VaultDelegate", VaultDelegate.VaultDelegateParser);
  repo.addParser("0x1::vault::VaultDelegateEvent", VaultDelegateEvent.VaultDelegateEventParser);
  repo.addParser("0x1::vault::VaultDelegates", VaultDelegates.VaultDelegatesParser);
  repo.addParser("0x1::vault::VaultEvents", VaultEvents.VaultEventsParser);
  repo.addParser("0x1::vault::VaultTransferEvent", VaultTransferEvent.VaultTransferEventParser);
}

