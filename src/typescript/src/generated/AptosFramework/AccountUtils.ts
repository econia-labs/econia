import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Account from "./Account";
import * as Coin from "./Coin";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "AccountUtils";


export function create_and_fund_account$ (
  funder: HexString,
  account: HexString,
  amount: U64,
  $c: AptosDataCache,
): void {
  Account.create_account$($.copy(account), $c);
  Coin.transfer$(funder, $.copy(account), $.copy(amount), $c, [new StructTag(new HexString("0x1"), "TestCoin", "TestCoin", [])] as TypeTag[]);
  return;
}


export function buildPayload_create_and_fund_account (
  account: HexString,
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::AccountUtils::create_and_fund_account",
    typeParamStrings,
    [
      $.payloadArg(account),
      $.payloadArg(amount),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
}

