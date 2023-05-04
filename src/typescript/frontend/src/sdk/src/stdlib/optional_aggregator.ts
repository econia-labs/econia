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

import * as Aggregator from "./aggregator";
import * as Aggregator_factory from "./aggregator_factory";
import * as Error from "./error";
import * as Option from "./option";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "optional_aggregator";

export const EAGGREGATOR_OVERFLOW: U64 = u64("1");
export const EAGGREGATOR_UNDERFLOW: U64 = u64("2");

export class Integer {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "Integer";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    { name: "value", typeTag: AtomicTypeTag.U128 },
    { name: "limit", typeTag: AtomicTypeTag.U128 },
  ];

  value: U128;
  limit: U128;

  constructor(proto: any, public typeTag: TypeTag) {
    this.value = proto["value"] as U128;
    this.limit = proto["limit"] as U128;
  }

  static IntegerParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): Integer {
    const proto = $.parseStructProto(data, typeTag, repo, Integer);
    return new Integer(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "Integer", []);
  }
  async loadFullState(app: $.AppType) {
    this.__app = app;
  }
}

export class OptionalAggregator {
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  __app: $.AppType | null = null;
  static structName = "OptionalAggregator";
  static typeParameters: TypeParamDeclType[] = [];
  static fields: FieldDeclType[] = [
    {
      name: "aggregator",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
      ]),
    },
    {
      name: "integer",
      typeTag: new StructTag(new HexString("0x1"), "option", "Option", [
        new StructTag(
          new HexString("0x1"),
          "optional_aggregator",
          "Integer",
          []
        ),
      ]),
    },
  ];

  aggregator: Option.Option;
  integer: Option.Option;

  constructor(proto: any, public typeTag: TypeTag) {
    this.aggregator = proto["aggregator"] as Option.Option;
    this.integer = proto["integer"] as Option.Option;
  }

  static OptionalAggregatorParser(
    data: any,
    typeTag: TypeTag,
    repo: AptosParserRepo
  ): OptionalAggregator {
    const proto = $.parseStructProto(data, typeTag, repo, OptionalAggregator);
    return new OptionalAggregator(proto, typeTag);
  }

  static getTag(): StructTag {
    return new StructTag(moduleAddress, moduleName, "OptionalAggregator", []);
  }
  async loadFullState(app: $.AppType) {
    await this.aggregator.loadFullState(app);
    await this.integer.loadFullState(app);
    this.__app = app;
  }
}
export function add_(
  optional_aggregator: OptionalAggregator,
  value: U128,
  $c: AptosDataCache
): void {
  let aggregator, integer;
  if (
    Option.is_some_(optional_aggregator.aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ])
  ) {
    aggregator = Option.borrow_mut_(optional_aggregator.aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ]);
    Aggregator.add_(aggregator, $.copy(value), $c);
  } else {
    integer = Option.borrow_mut_(optional_aggregator.integer, $c, [
      new SimpleStructTag(Integer),
    ]);
    add_integer_(integer, $.copy(value), $c);
  }
  return;
}

export function add_integer_(
  integer: Integer,
  value: U128,
  $c: AptosDataCache
): void {
  if (!$.copy(value).le($.copy(integer.limit).sub($.copy(integer.value)))) {
    throw $.abortCode(Error.out_of_range_($.copy(EAGGREGATOR_OVERFLOW), $c));
  }
  integer.value = $.copy(integer.value).add($.copy(value));
  return;
}

export function destroy_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): void {
  if (is_parallelizable_(optional_aggregator, $c)) {
    destroy_optional_aggregator_(optional_aggregator, $c);
  } else {
    destroy_optional_integer_(optional_aggregator, $c);
  }
  return;
}

export function destroy_integer_(integer: Integer, $c: AptosDataCache): void {
  integer;
  return;
}

export function destroy_optional_aggregator_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): U128 {
  let limit;
  const { aggregator: aggregator, integer: integer } = optional_aggregator;
  limit = Aggregator.limit_(
    Option.borrow_(aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ]),
    $c
  );
  Aggregator.destroy_(
    Option.destroy_some_(aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ]),
    $c
  );
  Option.destroy_none_(integer, $c, [new SimpleStructTag(Integer)]);
  return $.copy(limit);
}

export function destroy_optional_integer_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): U128 {
  let limit;
  const { aggregator: aggregator, integer: integer } = optional_aggregator;
  limit = limit_(
    Option.borrow_(integer, $c, [new SimpleStructTag(Integer)]),
    $c
  );
  destroy_integer_(
    Option.destroy_some_(integer, $c, [new SimpleStructTag(Integer)]),
    $c
  );
  Option.destroy_none_(aggregator, $c, [
    new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
  ]);
  return $.copy(limit);
}

export function is_parallelizable_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): boolean {
  return Option.is_some_(optional_aggregator.aggregator, $c, [
    new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
  ]);
}

export function limit_(integer: Integer, $c: AptosDataCache): U128 {
  return $.copy(integer.limit);
}

export function new___(
  limit: U128,
  parallelizable: boolean,
  $c: AptosDataCache
): OptionalAggregator {
  let temp$1;
  if (parallelizable) {
    temp$1 = new OptionalAggregator(
      {
        aggregator: Option.some_(
          Aggregator_factory.create_aggregator_internal_($.copy(limit), $c),
          $c,
          [new StructTag(new HexString("0x1"), "aggregator", "Aggregator", [])]
        ),
        integer: Option.none_($c, [new SimpleStructTag(Integer)]),
      },
      new SimpleStructTag(OptionalAggregator)
    );
  } else {
    temp$1 = new OptionalAggregator(
      {
        aggregator: Option.none_($c, [
          new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
        ]),
        integer: Option.some_(new_integer_($.copy(limit), $c), $c, [
          new SimpleStructTag(Integer),
        ]),
      },
      new SimpleStructTag(OptionalAggregator)
    );
  }
  return temp$1;
}

export function new_integer_(limit: U128, $c: AptosDataCache): Integer {
  return new Integer(
    { value: u128("0"), limit: $.copy(limit) },
    new SimpleStructTag(Integer)
  );
}

export function read_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): U128 {
  let temp$1, aggregator, integer;
  if (
    Option.is_some_(optional_aggregator.aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ])
  ) {
    aggregator = Option.borrow_(optional_aggregator.aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ]);
    temp$1 = Aggregator.read_(aggregator, $c);
  } else {
    integer = Option.borrow_(optional_aggregator.integer, $c, [
      new SimpleStructTag(Integer),
    ]);
    temp$1 = read_integer_(integer, $c);
  }
  return temp$1;
}

export function read_integer_(integer: Integer, $c: AptosDataCache): U128 {
  return $.copy(integer.value);
}

export function sub_(
  optional_aggregator: OptionalAggregator,
  value: U128,
  $c: AptosDataCache
): void {
  let aggregator, integer;
  if (
    Option.is_some_(optional_aggregator.aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ])
  ) {
    aggregator = Option.borrow_mut_(optional_aggregator.aggregator, $c, [
      new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
    ]);
    Aggregator.sub_(aggregator, $.copy(value), $c);
  } else {
    integer = Option.borrow_mut_(optional_aggregator.integer, $c, [
      new SimpleStructTag(Integer),
    ]);
    sub_integer_(integer, $.copy(value), $c);
  }
  return;
}

export function sub_integer_(
  integer: Integer,
  value: U128,
  $c: AptosDataCache
): void {
  if (!$.copy(value).le($.copy(integer.value))) {
    throw $.abortCode(Error.out_of_range_($.copy(EAGGREGATOR_UNDERFLOW), $c));
  }
  integer.value = $.copy(integer.value).sub($.copy(value));
  return;
}

export function switch_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): void {
  let value;
  value = read_(optional_aggregator, $c);
  switch_and_zero_out_(optional_aggregator, $c);
  add_(optional_aggregator, $.copy(value), $c);
  return;
}

export function switch_and_zero_out_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): void {
  if (is_parallelizable_(optional_aggregator, $c)) {
    switch_to_integer_and_zero_out_(optional_aggregator, $c);
  } else {
    switch_to_aggregator_and_zero_out_(optional_aggregator, $c);
  }
  return;
}

export function switch_to_aggregator_and_zero_out_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): U128 {
  let aggregator, integer, limit;
  integer = Option.extract_(optional_aggregator.integer, $c, [
    new SimpleStructTag(Integer),
  ]);
  limit = limit_(integer, $c);
  destroy_integer_(integer, $c);
  aggregator = Aggregator_factory.create_aggregator_internal_(
    $.copy(limit),
    $c
  );
  Option.fill_(optional_aggregator.aggregator, aggregator, $c, [
    new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
  ]);
  return $.copy(limit);
}

export function switch_to_integer_and_zero_out_(
  optional_aggregator: OptionalAggregator,
  $c: AptosDataCache
): U128 {
  let aggregator, integer, limit;
  aggregator = Option.extract_(optional_aggregator.aggregator, $c, [
    new StructTag(new HexString("0x1"), "aggregator", "Aggregator", []),
  ]);
  limit = Aggregator.limit_(aggregator, $c);
  Aggregator.destroy_(aggregator, $c);
  integer = new_integer_($.copy(limit), $c);
  Option.fill_(optional_aggregator.integer, integer, $c, [
    new SimpleStructTag(Integer),
  ]);
  return $.copy(limit);
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::optional_aggregator::Integer", Integer.IntegerParser);
  repo.addParser(
    "0x1::optional_aggregator::OptionalAggregator",
    OptionalAggregator.OptionalAggregatorParser
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
  get Integer() {
    return Integer;
  }
  get OptionalAggregator() {
    return OptionalAggregator;
  }
}
