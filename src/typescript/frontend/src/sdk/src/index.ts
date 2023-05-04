import {
  AptosLocalCache,
  AptosParserRepo,
  AptosSyncedCache,
  u8,
  u64,
  u128,
} from "@manahippo/move-to-ts";
import { type AptosClient } from "aptos";

import * as econia from "./econia";
import * as stdlib from "./stdlib";

export * as econia from "./econia";
export * as stdlib from "./stdlib";

export { u8, u64, u128 };

export function getProjectRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  econia.loadParsers(repo);
  stdlib.loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}

export class App {
  parserRepo: AptosParserRepo;
  cache: AptosLocalCache;
  econia: econia.App;
  stdlib: stdlib.App;
  constructor(public client: AptosClient) {
    this.parserRepo = getProjectRepo();
    this.cache = new AptosLocalCache();
    this.econia = new econia.App(client, this.parserRepo, this.cache);
    this.stdlib = new stdlib.App(client, this.parserRepo, this.cache);
  }
}
