import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as reconfiguration$_ from "./reconfiguration";
import * as system_addresses$_ from "./system_addresses";
import * as timestamp$_ from "./timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "transaction_publishing_option";

export const ECONFIG : U64 = u64("1");


export class TransactionPublishingOption 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TransactionPublishingOption";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "script_allow_list", typeTag: new VectorTag(new VectorTag(AtomicTypeTag.U8)) },
  { name: "module_publishing_allowed", typeTag: AtomicTypeTag.Bool }];

  script_allow_list: U8[][];
  module_publishing_allowed: boolean;

  constructor(proto: any, public typeTag: TypeTag) {
    this.script_allow_list = proto['script_allow_list'] as U8[][];
    this.module_publishing_allowed = proto['module_publishing_allowed'] as boolean;
  }

  static TransactionPublishingOptionParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TransactionPublishingOption {
    const proto = $.parseStructProto(data, typeTag, repo, TransactionPublishingOption);
    return new TransactionPublishingOption(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, TransactionPublishingOption, typeParams);
    return result as unknown as TransactionPublishingOption;
  }
}
export function initialize$ (
  account: HexString,
  script_allow_list: U8[][],
  module_publishing_allowed: boolean,
  $c: AptosDataCache,
): void {
  timestamp$_.assert_genesis$($c);
  system_addresses$_.assert_aptos_framework$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "transaction_publishing_option", "TransactionPublishingOption", []), new HexString("0x1"))) {
    throw $.abortCode(std$_.errors$_.already_published$(ECONFIG, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "transaction_publishing_option", "TransactionPublishingOption", []), account, new TransactionPublishingOption({ script_allow_list: $.copy(script_allow_list), module_publishing_allowed: module_publishing_allowed }, new StructTag(new HexString("0x1"), "transaction_publishing_option", "TransactionPublishingOption", [])));
  return;
}

export function is_module_allowed$ (
  $c: AptosDataCache,
): boolean {
  let publish_option;
  publish_option = $c.borrow_global<TransactionPublishingOption>(new StructTag(new HexString("0x1"), "transaction_publishing_option", "TransactionPublishingOption", []), new HexString("0x1"));
  return $.copy(publish_option.module_publishing_allowed);
}

export function is_script_allowed$ (
  script_hash: U8[],
  $c: AptosDataCache,
): boolean {
  let temp$1, publish_option;
  if (std$_.vector$_.is_empty$(script_hash, $c, [AtomicTypeTag.U8] as TypeTag[])) {
    return true;
  }
  else{
  }
  publish_option = $c.borrow_global<TransactionPublishingOption>(new StructTag(new HexString("0x1"), "transaction_publishing_option", "TransactionPublishingOption", []), new HexString("0x1"));
  if (std$_.vector$_.is_empty$(publish_option.script_allow_list, $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[])) {
    temp$1 = true;
  }
  else{
    temp$1 = std$_.vector$_.contains$(publish_option.script_allow_list, script_hash, $c, [new VectorTag(AtomicTypeTag.U8)] as TypeTag[]);
  }
  return temp$1;
}

export function set_module_publishing_allowed$ (
  account: HexString,
  is_allowed: boolean,
  $c: AptosDataCache,
): void {
  let publish_option;
  system_addresses$_.assert_core_resource$(account, $c);
  publish_option = $c.borrow_global_mut<TransactionPublishingOption>(new StructTag(new HexString("0x1"), "transaction_publishing_option", "TransactionPublishingOption", []), new HexString("0x1"));
  publish_option.module_publishing_allowed = is_allowed;
  reconfiguration$_.reconfigure$($c);
  return;
}


export function buildPayload_set_module_publishing_allowed (
  is_allowed: boolean,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::transaction_publishing_option::set_module_publishing_allowed",
    typeParamStrings,
    [
      $.payloadArg(is_allowed),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::transaction_publishing_option::TransactionPublishingOption", TransactionPublishingOption.TransactionPublishingOptionParser);
}

