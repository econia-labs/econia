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
export const moduleName = "consensus_config";

export const ECONFIG : U64 = u64("0");


export class ConsensusConfig 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ConsensusConfig";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "config", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  config: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.config = proto['config'] as U8[];
  }

  static ConsensusConfigParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ConsensusConfig {
    const proto = $.parseStructProto(data, typeTag, repo, ConsensusConfig);
    return new ConsensusConfig(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, ConsensusConfig, typeParams);
    return result as unknown as ConsensusConfig;
  }
}
export function initialize$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  timestamp$_.assert_genesis$($c);
  system_addresses$_.assert_aptos_framework$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "consensus_config", "ConsensusConfig", []), new HexString("0x1"))) {
    throw $.abortCode(std$_.errors$_.already_published$(ECONFIG, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "consensus_config", "ConsensusConfig", []), account, new ConsensusConfig({ config: std$_.vector$_.empty$($c, [AtomicTypeTag.U8] as TypeTag[]) }, new StructTag(new HexString("0x1"), "consensus_config", "ConsensusConfig", [])));
  return;
}

export function set$ (
  account: HexString,
  config: U8[],
  $c: AptosDataCache,
): void {
  let config_ref;
  system_addresses$_.assert_aptos_framework$(account, $c);
  config_ref = $c.borrow_global_mut<ConsensusConfig>(new StructTag(new HexString("0x1"), "consensus_config", "ConsensusConfig", []), new HexString("0x1")).config;
  $.set(config_ref, $.copy(config));
  reconfiguration$_.reconfigure$($c);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::consensus_config::ConsensusConfig", ConsensusConfig.ConsensusConfigParser);
}

