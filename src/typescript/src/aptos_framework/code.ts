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
export const moduleName = "code";

export const EMODULE_NAME_CLASH : U64 = u64("1");
export const EUPGRADE_IMMUTABLE : U64 = u64("2");
export const EUPGRADE_WEAKER_POLICY : U64 = u64("3");


export class ModuleMetadata 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "ModuleMetadata";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "name", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "source", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "source_map", typeTag: new VectorTag(AtomicTypeTag.U8) },
  { name: "abi", typeTag: new VectorTag(AtomicTypeTag.U8) }];

  name: Std.String.String;
  source: Std.String.String;
  source_map: U8[];
  abi: U8[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.name = proto['name'] as Std.String.String;
    this.source = proto['source'] as Std.String.String;
    this.source_map = proto['source_map'] as U8[];
    this.abi = proto['abi'] as U8[];
  }

  static ModuleMetadataParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : ModuleMetadata {
    const proto = $.parseStructProto(data, typeTag, repo, ModuleMetadata);
    return new ModuleMetadata(proto, typeTag);
  }

}

export class PackageMetadata 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "PackageMetadata";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "name", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "upgrade_policy", typeTag: new StructTag(new HexString("0x1"), "code", "UpgradePolicy", []) },
  { name: "manifest", typeTag: new StructTag(new HexString("0x1"), "string", "String", []) },
  { name: "modules", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "code", "ModuleMetadata", [])) }];

  name: Std.String.String;
  upgrade_policy: UpgradePolicy;
  manifest: Std.String.String;
  modules: ModuleMetadata[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.name = proto['name'] as Std.String.String;
    this.upgrade_policy = proto['upgrade_policy'] as UpgradePolicy;
    this.manifest = proto['manifest'] as Std.String.String;
    this.modules = proto['modules'] as ModuleMetadata[];
  }

  static PackageMetadataParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PackageMetadata {
    const proto = $.parseStructProto(data, typeTag, repo, PackageMetadata);
    return new PackageMetadata(proto, typeTag);
  }

}

export class PackageRegistry 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "PackageRegistry";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "packages", typeTag: new VectorTag(new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])) }];

  packages: PackageMetadata[];

  constructor(proto: any, public typeTag: TypeTag) {
    this.packages = proto['packages'] as PackageMetadata[];
  }

  static PackageRegistryParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : PackageRegistry {
    const proto = $.parseStructProto(data, typeTag, repo, PackageRegistry);
    return new PackageRegistry(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, PackageRegistry, typeParams);
    return result as unknown as PackageRegistry;
  }
}

export class UpgradePolicy 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "UpgradePolicy";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "policy", typeTag: AtomicTypeTag.U8 }];

  policy: U8;

  constructor(proto: any, public typeTag: TypeTag) {
    this.policy = proto['policy'] as U8;
  }

  static UpgradePolicyParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : UpgradePolicy {
    const proto = $.parseStructProto(data, typeTag, repo, UpgradePolicy);
    return new UpgradePolicy(proto, typeTag);
  }

}
export function can_change_upgrade_policy_to_ (
  from: UpgradePolicy,
  to: UpgradePolicy,
  $c: AptosDataCache,
): boolean {
  return ($.copy(from.policy)).le($.copy(to.policy));
}

export function check_coexistence_ (
  old_pack: PackageMetadata,
  new_modules: Std.String.String[],
  $c: AptosDataCache,
): void {
  let i, j, name, old_mod;
  i = u64("0");
  while (($.copy(i)).lt(Std.Vector.length_(old_pack.modules, $c, [new StructTag(new HexString("0x1"), "code", "ModuleMetadata", [])]))) {
    {
      old_mod = Std.Vector.borrow_(old_pack.modules, $.copy(i), $c, [new StructTag(new HexString("0x1"), "code", "ModuleMetadata", [])]);
      j = u64("0");
      while (($.copy(j)).lt(Std.Vector.length_(new_modules, $c, [new StructTag(new HexString("0x1"), "string", "String", [])]))) {
        {
          name = Std.Vector.borrow_(new_modules, $.copy(j), $c, [new StructTag(new HexString("0x1"), "string", "String", [])]);
          if (!$.deep_eq(old_mod.name, name)) {
            throw $.abortCode(Std.Error.already_exists_(EMODULE_NAME_CLASH, $c));
          }
        }

      }}

  }return;
}

export function check_upgradability_ (
  old_pack: PackageMetadata,
  new_pack: PackageMetadata,
  $c: AptosDataCache,
): void {
  let temp$1;
  temp$1 = upgrade_policy_immutable_($c);
  if (!($.copy(old_pack.upgrade_policy.policy)).lt($.copy(temp$1.policy))) {
    throw $.abortCode(Std.Error.invalid_argument_(EUPGRADE_IMMUTABLE, $c));
  }
  if (!can_change_upgrade_policy_to_($.copy(old_pack.upgrade_policy), $.copy(new_pack.upgrade_policy), $c)) {
    throw $.abortCode(Std.Error.invalid_argument_(EUPGRADE_WEAKER_POLICY, $c));
  }
  return;
}

export function from_bytes_ (
  bytes: U8[],
  $c: AptosDataCache,
  $p: TypeTag[], /* <T>*/
): PackageMetadata {
  return $.aptos_framework_code_from_bytes(bytes, $c, [$p[0]]);

}
export function get_module_names_ (
  pack: PackageMetadata,
  $c: AptosDataCache,
): Std.String.String[] {
  let i, module_names;
  module_names = Std.Vector.empty_($c, [new StructTag(new HexString("0x1"), "string", "String", [])]);
  i = u64("0");
  while (($.copy(i)).lt(Std.Vector.length_(pack.modules, $c, [new StructTag(new HexString("0x1"), "code", "ModuleMetadata", [])]))) {
    {
      Std.Vector.push_back_(module_names, $.copy(Std.Vector.borrow_(pack.modules, $.copy(i), $c, [new StructTag(new HexString("0x1"), "code", "ModuleMetadata", [])]).name), $c, [new StructTag(new HexString("0x1"), "string", "String", [])]);
      i = ($.copy(i)).add(u64("1"));
    }

  }return $.copy(module_names);
}

export function publish_package_ (
  owner: HexString,
  pack: PackageMetadata,
  code: U8[][],
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, addr, i, index, len, module_names, old, packages;
  addr = Std.Signer.address_of_(owner, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "code", "PackageRegistry", []), $.copy(addr))) {
    $c.move_to(new StructTag(new HexString("0x1"), "code", "PackageRegistry", []), owner, new PackageRegistry({ packages: Std.Vector.empty_($c, [new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])]) }, new StructTag(new HexString("0x1"), "code", "PackageRegistry", [])));
  }
  else{
  }
  module_names = get_module_names_(pack, $c);
  packages = $c.borrow_global_mut<PackageRegistry>(new StructTag(new HexString("0x1"), "code", "PackageRegistry", []), $.copy(addr)).packages;
  len = Std.Vector.length_(packages, $c, [new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])]);
  index = $.copy(len);
  i = u64("0");
  while (($.copy(i)).lt($.copy(len))) {
    {
      [temp$1, temp$2] = [packages, $.copy(i)];
      old = Std.Vector.borrow_(temp$1, temp$2, $c, [new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])]);
      if ($.deep_eq($.copy(old.name), $.copy(pack.name))) {
        check_upgradability_(old, pack, $c);
        index = $.copy(i);
      }
      else{
        check_coexistence_(old, module_names, $c);
      }
      i = ($.copy(i)).add(u64("1"));
    }

  }if (($.copy(index)).lt($.copy(len))) {
    $.set(Std.Vector.borrow_mut_(packages, $.copy(index), $c, [new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])]), $.copy(pack));
  }
  else{
    Std.Vector.push_back_(packages, $.copy(pack), $c, [new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])]);
  }
  return request_publish_($.copy(addr), $.copy(module_names), $.copy(code), $.copy(pack.upgrade_policy.policy), $c);
}

export function publish_package_txn_ (
  owner: HexString,
  pack_serialized: U8[],
  code: U8[][],
  $c: AptosDataCache,
): void {
  return publish_package_(owner, from_bytes_($.copy(pack_serialized), $c, [new StructTag(new HexString("0x1"), "code", "PackageMetadata", [])]), $.copy(code), $c);
}


export function buildPayload_publish_package_txn (
  pack_serialized: U8[],
  code: U8[][],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::code::publish_package_txn",
    typeParamStrings,
    [
      $.u8ArrayArg(pack_serialized),
      code.map(array => $.u8ArrayArg(array)),
    ]
  );

}
export function request_publish_ (
  owner: HexString,
  expected_modules: Std.String.String[],
  bundle: U8[][],
  policy: U8,
  $c: AptosDataCache,
): void {
  return $.aptos_framework_code_request_publish(owner, expected_modules, bundle, policy, $c);

}
export function upgrade_policy_compat_ (
  $c: AptosDataCache,
): UpgradePolicy {
  return new UpgradePolicy({ policy: u8("1") }, new StructTag(new HexString("0x1"), "code", "UpgradePolicy", []));
}

export function upgrade_policy_immutable_ (
  $c: AptosDataCache,
): UpgradePolicy {
  return new UpgradePolicy({ policy: u8("2") }, new StructTag(new HexString("0x1"), "code", "UpgradePolicy", []));
}

export function upgrade_policy_no_compat_ (
  $c: AptosDataCache,
): UpgradePolicy {
  return new UpgradePolicy({ policy: u8("0") }, new StructTag(new HexString("0x1"), "code", "UpgradePolicy", []));
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::code::ModuleMetadata", ModuleMetadata.ModuleMetadataParser);
  repo.addParser("0x1::code::PackageMetadata", PackageMetadata.PackageMetadataParser);
  repo.addParser("0x1::code::PackageRegistry", PackageRegistry.PackageRegistryParser);
  repo.addParser("0x1::code::UpgradePolicy", UpgradePolicy.UpgradePolicyParser);
}

