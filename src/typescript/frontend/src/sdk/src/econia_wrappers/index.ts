import {
  type AptosLocalCache,
  AptosParserRepo,
  AptosSyncedCache,
} from "@manahippo/move-to-ts";
import { type AptosClient } from "aptos";

import * as Wrappers from "./wrappers";

export * as Wrappers from "./wrappers";

export function loadParsers(repo: AptosParserRepo) {
  Wrappers.loadParsers(repo);
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
  wrappers: Wrappers.App;
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {
    this.wrappers = new Wrappers.App(client, repo, cache);
  }
}
