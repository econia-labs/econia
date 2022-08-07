
import { AptosParserRepo } from "@manahippo/move-to-ts";
import * as Big_vector from './big_vector';
import * as Comparator from './comparator';
import * as Event from './event';
import * as Iterable_table from './iterable_table';
import * as Signature from './signature';
import * as Simple_map from './simple_map';
import * as Table from './table';
import * as Table_with_length from './table_with_length';
import * as Type_info from './type_info';

export * as Big_vector from './big_vector';
export * as Comparator from './comparator';
export * as Event from './event';
export * as Iterable_table from './iterable_table';
export * as Signature from './signature';
export * as Simple_map from './simple_map';
export * as Table from './table';
export * as Table_with_length from './table_with_length';
export * as Type_info from './type_info';


export function loadParsers(repo: AptosParserRepo) {
  Big_vector.loadParsers(repo);
  Comparator.loadParsers(repo);
  Event.loadParsers(repo);
  Iterable_table.loadParsers(repo);
  Signature.loadParsers(repo);
  Simple_map.loadParsers(repo);
  Table.loadParsers(repo);
  Table_with_length.loadParsers(repo);
  Type_info.loadParsers(repo);
}

export function getPackageRepo(): AptosParserRepo {
  const repo = new AptosParserRepo();
  loadParsers(repo);
  repo.addDefaultParsers();
  return repo;
}
