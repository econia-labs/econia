import {
  type AptosLocalCache,
  AptosParserRepo,
  AptosSyncedCache,
} from "@manahippo/move-to-ts";
import { type AptosClient } from "aptos";

import * as Assets from "./assets";
import * as Avl_queue from "./avl_queue";
import * as Incentives from "./incentives";
import * as Market from "./market";
import * as Registry from "./registry";
import * as Resource_account from "./resource_account";
import * as Tablist from "./tablist";
import * as User from "./user";

export * as Assets from "./assets";
export * as Avl_queue from "./avl_queue";
export * as Incentives from "./incentives";
export * as Market from "./market";
export * as Registry from "./registry";
export * as Resource_account from "./resource_account";
export * as Tablist from "./tablist";
export * as User from "./user";

export function loadParsers(repo: AptosParserRepo) {
  Assets.loadParsers(repo);
  Avl_queue.loadParsers(repo);
  Incentives.loadParsers(repo);
  Market.loadParsers(repo);
  Registry.loadParsers(repo);
  Resource_account.loadParsers(repo);
  Tablist.loadParsers(repo);
  User.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}

export type AppType = {
  client: AptosClient;
  repo: AptosParserRepo;
  cache: AptosLocalCache;
};

export class App {
  assets: Assets.App;
  avl_queue: Avl_queue.App;
  incentives: Incentives.App;
  market: Market.App;
  registry: Registry.App;
  resource_account: Resource_account.App;
  tablist: Tablist.App;
  user: User.App;
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {
    this.assets = new Assets.App(client, repo, cache);
    this.avl_queue = new Avl_queue.App(client, repo, cache);
    this.incentives = new Incentives.App(client, repo, cache);
    this.market = new Market.App(client, repo, cache);
    this.registry = new Registry.App(client, repo, cache);
    this.resource_account = new Resource_account.App(client, repo, cache);
    this.tablist = new Tablist.App(client, repo, cache);
    this.user = new User.App(client, repo, cache);
  }
}
