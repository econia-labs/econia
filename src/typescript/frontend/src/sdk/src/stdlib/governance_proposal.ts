import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, U64, U128 } from "@manahippo/move-to-ts";
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
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "governance_proposal";

export class GovernanceProposal {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "GovernanceProposal";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [];

  constructor(proto: any, public typeTag: TypeTag) {}

  static GovernanceProposalParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): GovernanceProposal {
    const proto = $.parseStructProto(data, typeTag, repo, GovernanceProposal);
    return new GovernanceProposal(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "GovernanceProposal", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function create_empty_proposal_($c: AptosDataCache): GovernanceProposal {
  return create_proposal_($c);
}

export function create_proposal_($c: AptosDataCache): GovernanceProposal {
  return new GovernanceProposal({}, new SimpleStructTag(GovernanceProposal));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser(
    "0x1::governance_proposal::GovernanceProposal",
    GovernanceProposal.GovernanceProposalParser
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
  get GovernanceProposal() {
    return GovernanceProposal;
  }
}
