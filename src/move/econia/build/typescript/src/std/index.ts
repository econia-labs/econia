
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as acl$_ from './acl';
import * as bcs$_ from './bcs';
import * as bit_vector$_ from './bit_vector';
import * as capability$_ from './capability';
import * as compare$_ from './compare';
import * as debug$_ from './debug';
import * as error$_ from './error';
import * as errors$_ from './errors';
import * as event$_ from './event';
import * as fixed_point32$_ from './fixed_point32';
import * as guid$_ from './guid';
import * as hash$_ from './hash';
import * as offer$_ from './offer';
import * as option$_ from './option';
import * as role$_ from './role';
import * as signer$_ from './signer';
import * as string$_ from './string';
import * as vault$_ from './vault';
import * as vector$_ from './vector';

export * as acl$_ from './acl';
export * as bcs$_ from './bcs';
export * as bit_vector$_ from './bit_vector';
export * as capability$_ from './capability';
export * as compare$_ from './compare';
export * as debug$_ from './debug';
export * as error$_ from './error';
export * as errors$_ from './errors';
export * as event$_ from './event';
export * as fixed_point32$_ from './fixed_point32';
export * as guid$_ from './guid';
export * as hash$_ from './hash';
export * as offer$_ from './offer';
export * as option$_ from './option';
export * as role$_ from './role';
export * as signer$_ from './signer';
export * as string$_ from './string';
export * as vault$_ from './vault';
export * as vector$_ from './vector';


export function loadParsers(repo: AptosParserRepo) {
  acl$_.loadParsers(repo);
  bcs$_.loadParsers(repo);
  bit_vector$_.loadParsers(repo);
  capability$_.loadParsers(repo);
  compare$_.loadParsers(repo);
  debug$_.loadParsers(repo);
  error$_.loadParsers(repo);
  errors$_.loadParsers(repo);
  event$_.loadParsers(repo);
  fixed_point32$_.loadParsers(repo);
  guid$_.loadParsers(repo);
  hash$_.loadParsers(repo);
  offer$_.loadParsers(repo);
  option$_.loadParsers(repo);
  role$_.loadParsers(repo);
  signer$_.loadParsers(repo);
  string$_.loadParsers(repo);
  vault$_.loadParsers(repo);
  vector$_.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
