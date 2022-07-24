import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as governance_proposal$_ from "./governance_proposal";
import * as reconfiguration$_ from "./reconfiguration";
import * as stake$_ from "./stake";
import * as system_addresses$_ from "./system_addresses";
import * as timestamp$_ from "./timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "block";

export const EBLOCK_METADATA : U64 = u64("0");
export const EVM_OR_VALIDATOR : U64 = u64("1");


export class BlockMetadata 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "BlockMetadata";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "height", typeTag: AtomicTypeTag.U64 },
  { name: "epoch_internal", typeTag: AtomicTypeTag.U64 },
  { name: "new_block_events", typeTag: new StructTag(new HexString("0x1"), "event", "EventHandle", [new StructTag(new HexString("0x1"), "block", "NewBlockEvent", [])]) }];

  height: U64;
  epoch_internal: U64;
  new_block_events: std$_.event$_.EventHandle;

  constructor(proto: any, public typeTag: TypeTag) {
    this.height = proto['height'] as U64;
    this.epoch_internal = proto['epoch_internal'] as U64;
    this.new_block_events = proto['new_block_events'] as std$_.event$_.EventHandle;
  }

  static BlockMetadataParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : BlockMetadata {
    const proto = $.parseStructProto(data, typeTag, repo, BlockMetadata);
    return new BlockMetadata(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, BlockMetadata, typeParams);
    return result as unknown as BlockMetadata;
  }
}

export class NewBlockEvent 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "NewBlockEvent";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "epoch", typeTag: AtomicTypeTag.U64 },
  { name: "round", typeTag: AtomicTypeTag.U64 },
  { name: "previous_block_votes", typeTag: new VectorTag(AtomicTypeTag.Bool) },
  { name: "proposer", typeTag: AtomicTypeTag.Address },
  { name: "failed_proposer_indices", typeTag: new VectorTag(AtomicTypeTag.U64) },
  { name: "time_microseconds", typeTag: AtomicTypeTag.U64 }];

  epoch: U64;
  round: U64;
  previous_block_votes: boolean[];
  proposer: HexString;
  failed_proposer_indices: U64[];
  time_microseconds: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.epoch = proto['epoch'] as U64;
    this.round = proto['round'] as U64;
    this.previous_block_votes = proto['previous_block_votes'] as boolean[];
    this.proposer = proto['proposer'] as HexString;
    this.failed_proposer_indices = proto['failed_proposer_indices'] as U64[];
    this.time_microseconds = proto['time_microseconds'] as U64;
  }

  static NewBlockEventParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : NewBlockEvent {
    const proto = $.parseStructProto(data, typeTag, repo, NewBlockEvent);
    return new NewBlockEvent(proto, typeTag);
  }

}
export function block_prologue$ (
  vm: HexString,
  epoch: U64,
  round: U64,
  previous_block_votes: boolean[],
  missed_votes: U64[],
  proposer: HexString,
  failed_proposer_indices: U64[],
  timestamp: U64,
  $c: AptosDataCache,
): void {
  let temp$1, block_metadata_ref;
  timestamp$_.assert_operating$($c);
  system_addresses$_.assert_vm$(vm, $c);
  if (($.copy(proposer).hex() === new HexString("0x0").hex())) {
    temp$1 = true;
  }
  else{
    temp$1 = stake$_.is_current_epoch_validator$($.copy(proposer), $c);
  }
  if (!temp$1) {
    throw $.abortCode(std$_.errors$_.requires_address$(EVM_OR_VALIDATOR, $c));
  }
  block_metadata_ref = $c.borrow_global_mut<BlockMetadata>(new StructTag(new HexString("0x1"), "block", "BlockMetadata", []), new HexString("0x1"));
  timestamp$_.update_global_time$(vm, $.copy(proposer), $.copy(timestamp), $c);
  block_metadata_ref.height = $.copy(block_metadata_ref.height).add(u64("1"));
  std$_.event$_.emit_event$(block_metadata_ref.new_block_events, new NewBlockEvent({ epoch: $.copy(epoch), round: $.copy(round), previous_block_votes: $.copy(previous_block_votes), proposer: $.copy(proposer), failed_proposer_indices: $.copy(failed_proposer_indices), time_microseconds: $.copy(timestamp) }, new StructTag(new HexString("0x1"), "block", "NewBlockEvent", [])), $c, [new StructTag(new HexString("0x1"), "block", "NewBlockEvent", [])] as TypeTag[]);
  stake$_.update_performance_statistics$($.copy(missed_votes), $c);
  if ($.copy(timestamp).sub(reconfiguration$_.last_reconfiguration_time$($c)).gt($.copy(block_metadata_ref.epoch_internal))) {
    reconfiguration$_.reconfigure$($c);
  }
  else{
  }
  return;
}

export function get_current_block_height$ (
  $c: AptosDataCache,
): U64 {
  if (!is_initialized$($c)) {
    throw $.abortCode(std$_.errors$_.not_published$(EBLOCK_METADATA, $c));
  }
  return $.copy($c.borrow_global<BlockMetadata>(new StructTag(new HexString("0x1"), "block", "BlockMetadata", []), new HexString("0x1")).height);
}

export function initialize_block_metadata$ (
  account: HexString,
  epoch_internal: U64,
  $c: AptosDataCache,
): void {
  timestamp$_.assert_genesis$($c);
  system_addresses$_.assert_aptos_framework$(account, $c);
  if (!!is_initialized$($c)) {
    throw $.abortCode(std$_.errors$_.already_published$(EBLOCK_METADATA, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "block", "BlockMetadata", []), account, new BlockMetadata({ height: u64("0"), epoch_internal: $.copy(epoch_internal), new_block_events: std$_.event$_.new_event_handle$(account, $c, [new StructTag(new HexString("0x1"), "block", "NewBlockEvent", [])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "block", "BlockMetadata", [])));
  return;
}

export function is_initialized$ (
  $c: AptosDataCache,
): boolean {
  return $c.exists(new StructTag(new HexString("0x1"), "block", "BlockMetadata", []), new HexString("0x1"));
}

export function update_epoch_interval$ (
  _gov_proposal: governance_proposal$_.GovernanceProposal,
  new_epoch_interval: U64,
  $c: AptosDataCache,
): void {
  let block_metadata;
  block_metadata = $c.borrow_global_mut<BlockMetadata>(new StructTag(new HexString("0x1"), "block", "BlockMetadata", []), new HexString("0x1"));
  block_metadata.epoch_internal = $.copy(new_epoch_interval);
  return;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::block::BlockMetadata", BlockMetadata.BlockMetadataParser);
  repo.addParser("0x1::block::NewBlockEvent", NewBlockEvent.NewBlockEventParser);
}

