import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Account from "./account";
import * as Coin from "./coin";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "account_utils";


export function create_and_fund_account_ (
  funder: HexString,
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  Account.create_account_($.copy(account), $c);
  Coin.transfer_(funder, $.copy(account), $.copy(amount), $c, [new StructTag(new HexString("0x1"), "aptos_coin", "AptosCoin", [])]);
  return;
}


export function buildPayload_create_and_fund_account (
  account: HexString,
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::account_utils::create_and_fund_account",
    typeParamStrings,
    [
      $.payloadArg(account),
      $.payloadArg(amount),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
}

