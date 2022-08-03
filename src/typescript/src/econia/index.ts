
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as Capability from './capability';
import * as Coins from './coins';
import * as Critbit from './critbit';
import * as Init from './init';
import * as Market from './market';
import * as Open_table from './open_table';
import * as Order_id from './order_id';
import * as Registry from './registry';
import * as User from './user';

export * as Capability from './capability';
export * as Coins from './coins';
export * as Critbit from './critbit';
export * as Init from './init';
export * as Market from './market';
export * as Open_table from './open_table';
export * as Order_id from './order_id';
export * as Registry from './registry';
export * as User from './user';


export function loadParsers(repo: AptosParserRepo) {
  Capability.loadParsers(repo);
  Coins.loadParsers(repo);
  Critbit.loadParsers(repo);
  Init.loadParsers(repo);
  Market.loadParsers(repo);
  Open_table.loadParsers(repo);
  Order_id.loadParsers(repo);
  Registry.loadParsers(repo);
  User.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
