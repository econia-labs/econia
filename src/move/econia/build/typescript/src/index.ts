
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as Econia from './Econia';
import * as aptos_framework from './aptos_framework';
import * as std from './std';

export * as Econia from './Econia';
export * as aptos_framework from './aptos_framework';
export * as std from './std';


export function getProjectRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  Econia.loadParsers(repo);
  aptos_framework.loadParsers(repo);
  std.loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
