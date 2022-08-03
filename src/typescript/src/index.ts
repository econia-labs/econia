
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as aptos_framework from './aptos_framework';
import * as aptos_std from './aptos_std';
import * as econia from './econia';
import * as std from './std';

export * as aptos_framework from './aptos_framework';
export * as aptos_std from './aptos_std';
export * as econia from './econia';
export * as std from './std';


export function getProjectRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  aptos_framework.loadParsers(repo);
  aptos_std.loadParsers(repo);
  econia.loadParsers(repo);
  std.loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
