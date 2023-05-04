import * as $ from "@manahippo/move-to-ts";
import {
  type AptosDataCache,
  type AptosLocalCache,
  type AptosParserRepo,
  DummyCache,
} from "@manahippo/move-to-ts";
import { U8, type U64, type U128 } from "@manahippo/move-to-ts";
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
export const moduleName = "aggregator";

export const EAGGREGATOR_OVERFLOW: U64 = u64("1");
export const EAGGREGATOR_UNDERFLOW: U64 = u64("2");
export const ENOT_SUPPORTED: U64 = u64("3");

export class Aggregator {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Aggregator";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "handle", typeTag: AtomicTypeTag.Address },
    { name: "key", typeTag: AtomicTypeTag.Address },
    { name: "limit", typeTag: AtomicTypeTag.U128 },
  ];

  handle: HexString;
  key: HexString;
  limit: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.handle = proto["handle"] as HexString;
    this.key = proto["key"] as HexString;
    this.limit = proto["limit"] as U128;
  }

  static AggregatorParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Aggregator {
    const proto = $.parseStructProto(data, typeTag, repo, Aggregator);
    return new Aggregator(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Aggregator", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}
export function add_(
  aggregator: Aggregator,
  value: U128,
  $c: AptosDataCache
): void {
  return $.aptos_framework_aggregator_add(aggregator, value, $c);
}
export function destroy_(aggregator: Aggregator, $c: AptosDataCache): void {
  return $.aptos_framework_aggregator_destroy(aggregator, $c);
}
export function limit_(aggregator: Aggregator, $c: AptosDataCache): U128 {
  return $.copy(aggregator.limit);
}

export function read_(aggregator: Aggregator, $c: AptosDataCache): U128 {
  return $.aptos_framework_aggregator_read(aggregator, $c);
}
export function sub_(
  aggregator: Aggregator,
  value: U128,
  $c: AptosDataCache
): void {
  return $.aptos_framework_aggregator_sub(aggregator, value, $c);
}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::aggregator::Aggregator", Aggregator.AggregatorParser);
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
  get Aggregator() {
    return Aggregator;
  }
}
