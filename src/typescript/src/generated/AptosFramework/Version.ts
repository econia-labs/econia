import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Std from "../Std";
import * as Reconfiguration from "./Reconfiguration";
import * as SystemAddresses from "./SystemAddresses";
import * as Timestamp from "./Timestamp";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "Version";

export const ECONFIG : U64 = u64("0");
export const EINVALID_MAJOR_VERSION_NUMBER : U64 = u64("1");


export class Version 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Version";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "major", typeTag: AtomicTypeTag.U64 }];

  major: U64;

  constructor(proto: any, public typeTag: TypeTag) {
    this.major = proto['major'] as U64;
  }

  static VersionParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Version {
    const proto = $.parseStructProto(data, typeTag, repo, Version);
    return new Version(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Version, typeParams);
    return result as unknown as Version;
  }
}
export function initialize$ (
  account: HexString,
  initial_version: U64,
  $c: AptosDataCache,
): void {
  Timestamp.assert_genesis$($c);
  SystemAddresses.assert_core_resource$(account, $c);
  if (!!$c.exists(new StructTag(new HexString("0x1"), "Version", "Version", []), new HexString("0xa550c18"))) {
    throw $.abortCode(Std.Errors.already_published$(ECONFIG, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "Version", "Version", []), account, new Version({ major: $.copy(initial_version) }, new StructTag(new HexString("0x1"), "Version", "Version", [])));
  return;
}

export function set_version$ (
  account: HexString,
  major: U64,
  $c: AptosDataCache,
): void {
  let config, old_major;
  SystemAddresses.assert_core_resource$(account, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "Version", "Version", []), new HexString("0xa550c18"))) {
    throw $.abortCode(Std.Errors.not_published$(ECONFIG, $c));
  }
  old_major = $.copy($c.borrow_global<Version>(new StructTag(new HexString("0x1"), "Version", "Version", []), new HexString("0xa550c18")).major);
  if (!$.copy(old_major).lt($.copy(major))) {
    throw $.abortCode(Std.Errors.invalid_argument$(EINVALID_MAJOR_VERSION_NUMBER, $c));
  }
  config = $c.borrow_global_mut<Version>(new StructTag(new HexString("0x1"), "Version", "Version", []), new HexString("0xa550c18"));
  config.major = $.copy(major);
  Reconfiguration.reconfigure$($c);
  return;
}


export function buildPayload_set_version (
  major: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::Version::set_version",
    typeParamStrings,
    [
      $.payloadArg(major),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::Version::Version", Version.VersionParser);
}

