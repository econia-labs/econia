import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../std";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "governance_proposal";

export const ETOO_LONG : U64 = u64("1");


export class GovernanceProposal 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GovernanceProposal";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "metadata_location", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "metadata_hash", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) }];

  metadata_location: Std.String.String;
  metadata_hash: Std.String.String;

  constructor(proto: any, public typeTag: TypeTag) {
    this.metadata_location = proto['metadata_location'] as Std.String.String;
    this.metadata_hash = proto['metadata_hash'] as Std.String.String;
  }

  static GovernanceProposalParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GovernanceProposal {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceProposal);
    return new GovernanceProposal(proto, typeTag);
  }

}
export function create_empty_proposal_ (
  $c: AptosDataCache,
): GovernanceProposal {
  return create_proposal_(Std.String.utf8_([], $c), Std.String.utf8_([], $c), $c);
}

export function create_proposal_ (
  metadata_location: Std.String.String,
  metadata_hash: Std.String.String,
  $c: AptosDataCache,
): GovernanceProposal {
  if (!(Std.String.length_(metadata_location, $c)).le(u64("256"))) {
    throw $.abortCode(Std.Error.invalid_argument_(ETOO_LONG, $c));
  }
  if (!(Std.String.length_(metadata_hash, $c)).le(u64("256"))) {
    throw $.abortCode(Std.Error.invalid_argument_(ETOO_LONG, $c));
  }
  return new GovernanceProposal({ metadata_location: $.copy(metadata_location), metadata_hash: $.copy(metadata_hash) }, new StructTag(new HexString("0x1"), "governance_proposal", "GovernanceProposal", []));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::governance_proposal::GovernanceProposal", GovernanceProposal.GovernanceProposalParser);
}

