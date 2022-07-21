
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as ACL from './ACL';
import * as ASCII from './ASCII';
import * as BCS from './BCS';
import * as BitVector from './BitVector';
import * as Capability from './Capability';
import * as Errors from './Errors';
import * as Event from './Event';
import * as FixedPoint32 from './FixedPoint32';
import * as GUID from './GUID';
import * as Hash from './Hash';
import * as Offer from './Offer';
import * as Option from './Option';
import * as Signer from './Signer';
import * as Vector from './Vector';

export * as ACL from './ACL';
export * as ASCII from './ASCII';
export * as BCS from './BCS';
export * as BitVector from './BitVector';
export * as Capability from './Capability';
export * as Errors from './Errors';
export * as Event from './Event';
export * as FixedPoint32 from './FixedPoint32';
export * as GUID from './GUID';
export * as Hash from './Hash';
export * as Offer from './Offer';
export * as Option from './Option';
export * as Signer from './Signer';
export * as Vector from './Vector';


export function loadParsers(repo: AptosParserRepo) {
  ACL.loadParsers(repo);
  ASCII.loadParsers(repo);
  BCS.loadParsers(repo);
  BitVector.loadParsers(repo);
  Capability.loadParsers(repo);
  Errors.loadParsers(repo);
  Event.loadParsers(repo);
  FixedPoint32.loadParsers(repo);
  GUID.loadParsers(repo);
  Hash.loadParsers(repo);
  Offer.loadParsers(repo);
  Option.loadParsers(repo);
  Signer.loadParsers(repo);
  Vector.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
