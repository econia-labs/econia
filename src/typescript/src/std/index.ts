
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as Acl from './acl';
import * as Bcs from './bcs';
import * as Bit_vector from './bit_vector';
import * as Capability from './capability';
import * as Debug from './debug';
import * as Error from './error';
import * as Fixed_point32 from './fixed_point32';
import * as Guid from './guid';
import * as Hash from './hash';
import * as Option from './option';
import * as Signer from './signer';
import * as String from './string';
import * as Vector from './vector';

export * as Acl from './acl';
export * as Bcs from './bcs';
export * as Bit_vector from './bit_vector';
export * as Capability from './capability';
export * as Debug from './debug';
export * as Error from './error';
export * as Fixed_point32 from './fixed_point32';
export * as Guid from './guid';
export * as Hash from './hash';
export * as Option from './option';
export * as Signer from './signer';
export * as String from './string';
export * as Vector from './vector';


export function loadParsers(repo: AptosParserRepo) {
  Acl.loadParsers(repo);
  Bcs.loadParsers(repo);
  Bit_vector.loadParsers(repo);
  Capability.loadParsers(repo);
  Debug.loadParsers(repo);
  Error.loadParsers(repo);
  Fixed_point32.loadParsers(repo);
  Guid.loadParsers(repo);
  Hash.loadParsers(repo);
  Option.loadParsers(repo);
  Signer.loadParsers(repo);
  String.loadParsers(repo);
  Vector.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
