import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "governance_proposal";

export const ECODE_LOCATION_TOO_LONG : U64 = u64("1");
export const EDESCRIPTION_TOO_LONG : U64 = u64("3");
export const ETITLE_TOO_LONG : U64 = u64("2");


export class GovernanceProposal 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "GovernanceProposal";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "code_location", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "title", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "description", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) }];

  code_location: std$_.string$_.String;
  title: std$_.string$_.String;
  description: std$_.string$_.String;

  constructor(proto: any, public typeTag: TypeTag) {
    this.code_location = proto['code_location'] as std$_.string$_.String;
    this.title = proto['title'] as std$_.string$_.String;
    this.description = proto['description'] as std$_.string$_.String;
  }

  static GovernanceProposalParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : GovernanceProposal {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceProposal);
    return new GovernanceProposal(proto, typeTag);
  }

}
export function create_empty_proposal$ (
  $c: AptosDataCache,
): GovernanceProposal {
  return create_proposal$(std$_.string$_.utf8$([], $c), std$_.string$_.utf8$([], $c), std$_.string$_.utf8$([], $c), $c);
}

export function create_proposal$ (
  code_location: std$_.string$_.String,
  title: std$_.string$_.String,
  description: std$_.string$_.String,
  $c: AptosDataCache,
): GovernanceProposal {
  if (!std$_.string$_.length$(code_location, $c).le(u64("256"))) {
    throw $.abortCode(std$_.error$_.invalid_argument$(ECODE_LOCATION_TOO_LONG, $c));
  }
  if (!std$_.string$_.length$(title, $c).le(u64("256"))) {
    throw $.abortCode(std$_.error$_.invalid_argument$(ETITLE_TOO_LONG, $c));
  }
  if (!std$_.string$_.length$(description, $c).le(u64("256"))) {
    throw $.abortCode(std$_.error$_.invalid_argument$(EDESCRIPTION_TOO_LONG, $c));
  }
  return new GovernanceProposal({ code_location: $.copy(code_location), title: $.copy(title), description: $.copy(description) }, new StructTag(new HexString("0x1"), "governance_proposal", "GovernanceProposal", []));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::governance_proposal::GovernanceProposal", GovernanceProposal.GovernanceProposalParser);
}

