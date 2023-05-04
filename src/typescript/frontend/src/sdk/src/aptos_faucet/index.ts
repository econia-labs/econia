import {
  type AptosLocalCache,
  AptosParserRepo,
  AptosSyncedCache,
} from "@manahippo/move-to-ts";
import { type AptosClient } from "aptos";

import * as Test_coin from "./test_coin";
import * as Test_eth from "./test_eth";
import * as Test_usdc from "./test_usdc";

export * as Test_coin from "./test_coin";
export * as Test_eth from "./test_eth";
export * as Test_usdc from "./test_usdc";

export function loadParsers(repo: AptosParserRepo) {
  Test_coin.loadParsers(repo);
  Test_eth.loadParsers(repo);
  Test_usdc.loadParsers(repo);
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
  test_coin: Test_coin.App;
  test_eth: Test_eth.App;
  test_usdc: Test_usdc.App;
  constructor(
    public client: AptosClient,
    public repo: AptosParserRepo,
    public cache: AptosLocalCache
  ) {
    this.test_coin = new Test_coin.App(client, repo, cache);
    this.test_eth = new Test_eth.App(client, repo, cache);
    this.test_usdc = new Test_usdc.App(client, repo, cache);
  }
}
