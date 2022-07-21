
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as AptosFramework from './AptosFramework';
import * as Econia from './Econia';
import * as Std from './Std';

export * as AptosFramework from './AptosFramework';
export * as Econia from './Econia';
export * as Std from './Std';


export function getProjectRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  AptosFramework.loadParsers(repo);
  Econia.loadParsers(repo);
  Std.loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
