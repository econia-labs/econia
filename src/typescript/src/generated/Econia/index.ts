
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as Book from './Book';
import * as Caps from './Caps';
import * as Coins from './Coins';
import * as CritBit from './CritBit';
import * as ID from './ID';
import * as Init from './Init';
import * as Match from './Match';
import * as Orders from './Orders';
import * as Registry from './Registry';
import * as User from './User';
import * as Version from './Version';

export * as Book from './Book';
export * as Caps from './Caps';
export * as Coins from './Coins';
export * as CritBit from './CritBit';
export * as ID from './ID';
export * as Init from './Init';
export * as Match from './Match';
export * as Orders from './Orders';
export * as Registry from './Registry';
export * as User from './User';
export * as Version from './Version';


export function loadParsers(repo: AptosParserRepo) {
  Book.loadParsers(repo);
  Caps.loadParsers(repo);
  Coins.loadParsers(repo);
  CritBit.loadParsers(repo);
  ID.loadParsers(repo);
  Init.loadParsers(repo);
  Match.loadParsers(repo);
  Orders.loadParsers(repo);
  Registry.loadParsers(repo);
  User.loadParsers(repo);
  Version.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
