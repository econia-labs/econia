
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as Book$_ from './Book';
import * as Caps$_ from './Caps';
import * as Coins$_ from './Coins';
import * as CritBit$_ from './CritBit';
import * as ID$_ from './ID';
import * as Init$_ from './Init';
import * as Match$_ from './Match';
import * as Orders$_ from './Orders';
import * as Registry$_ from './Registry';
import * as User$_ from './User';
import * as Version$_ from './Version';

export * as Book$_ from './Book';
export * as Caps$_ from './Caps';
export * as Coins$_ from './Coins';
export * as CritBit$_ from './CritBit';
export * as ID$_ from './ID';
export * as Init$_ from './Init';
export * as Match$_ from './Match';
export * as Orders$_ from './Orders';
export * as Registry$_ from './Registry';
export * as User$_ from './User';
export * as Version$_ from './Version';


export function loadParsers(repo: AptosParserRepo) {
  Book$_.loadParsers(repo);
  Caps$_.loadParsers(repo);
  Coins$_.loadParsers(repo);
  CritBit$_.loadParsers(repo);
  ID$_.loadParsers(repo);
  Init$_.loadParsers(repo);
  Match$_.loadParsers(repo);
  Orders$_.loadParsers(repo);
  Registry$_.loadParsers(repo);
  User$_.loadParsers(repo);
  Version$_.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
