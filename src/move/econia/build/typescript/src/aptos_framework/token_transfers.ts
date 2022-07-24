import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as std$_ from "../std";
import * as table$_ from "./table";
import * as token$_ from "./token";
export const packageName = "AptosFramework";
export const moduleAddress = new HexString("0x1");
export const moduleName = "token_transfers";



export class TokenTransfers 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "TokenTransfers";
  static typeParameters: TypeParamDeclType[] = [

  ];
  static fields: FieldDeclType[] = [
  { name: "pending_claims", typeTag: new StructTag(new HexString("0x1"), "table", "Table", [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]) }];

  pending_claims: table$_.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pending_claims = proto['pending_claims'] as table$_.Table;
  }

  static TokenTransfersParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : TokenTransfers {
    const proto = $.parseStructProto(data, typeTag, repo, TokenTransfers);
    return new TokenTransfers(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, TokenTransfers, typeParams);
    return result as unknown as TokenTransfers;
  }
}
export function cancel_offer$ (
  sender: HexString,
  receiver: HexString,
  token_id: token$_.TokenId,
  $c: AptosDataCache,
): void {
  let pending_claims, pending_tokens, real_pending_claims, sender_addr, token;
  sender_addr = std$_.signer$_.address_of$(sender, $c);
  pending_claims = $c.borrow_global_mut<TokenTransfers>(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender_addr)).pending_claims;
  pending_tokens = table$_.borrow_mut$(pending_claims, $.copy(receiver), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]);
  token = table$_.remove$(pending_tokens, $.copy(token_id), $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]);
  if (table$_.length$(pending_tokens, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]).eq(u64("0"))) {
    real_pending_claims = table$_.remove$(pending_claims, $.copy(receiver), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]);
    table$_.destroy_empty$(real_pending_claims, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]);
  }
  else{
  }
  return token$_.deposit_token$(sender, token, $c);
}

export function cancel_offer_script$ (
  sender: HexString,
  receiver: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  $c: AptosDataCache,
): void {
  let token_id;
  token_id = token$_.create_token_id_raw$($.copy(creator), $.copy(collection), $.copy(name), $c);
  cancel_offer$(sender, $.copy(receiver), $.copy(token_id), $c);
  return;
}


export function buildPayload_cancel_offer_script (
  receiver: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::token_transfers::cancel_offer_script",
    typeParamStrings,
    [
      $.payloadArg(receiver),
      $.payloadArg(creator),
      $.u8ArrayArg(collection),
      $.u8ArrayArg(name),
    ]
  );

}
export function claim$ (
  receiver: HexString,
  sender: HexString,
  token_id: token$_.TokenId,
  $c: AptosDataCache,
): void {
  let pending_claims, pending_tokens, real_pending_claims, receiver_addr, token;
  receiver_addr = std$_.signer$_.address_of$(receiver, $c);
  pending_claims = $c.borrow_global_mut<TokenTransfers>(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender)).pending_claims;
  pending_tokens = table$_.borrow_mut$(pending_claims, $.copy(receiver_addr), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]);
  token = table$_.remove$(pending_tokens, $.copy(token_id), $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]);
  if (table$_.length$(pending_tokens, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]).eq(u64("0"))) {
    real_pending_claims = table$_.remove$(pending_claims, $.copy(receiver_addr), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]);
    table$_.destroy_empty$(real_pending_claims, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]);
  }
  else{
  }
  return token$_.deposit_token$(receiver, token, $c);
}

export function claim_script$ (
  receiver: HexString,
  sender: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  $c: AptosDataCache,
): void {
  let token_id;
  token_id = token$_.create_token_id_raw$($.copy(creator), $.copy(collection), $.copy(name), $c);
  claim$(receiver, $.copy(sender), $.copy(token_id), $c);
  return;
}


export function buildPayload_claim_script (
  sender: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::token_transfers::claim_script",
    typeParamStrings,
    [
      $.payloadArg(sender),
      $.payloadArg(creator),
      $.u8ArrayArg(collection),
      $.u8ArrayArg(name),
    ]
  );

}
export function create_token$ (
  creator: HexString,
  amount: U64,
  $c: AptosDataCache,
): token$_.TokenId {
  let collection_name;
  collection_name = std$_.string$_.utf8$([u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("87"), u8("111"), u8("114"), u8("108"), u8("100")], $c);
  token$_.create_collection$(creator, $.copy(collection_name), std$_.string$_.utf8$([u8("67"), u8("111"), u8("108"), u8("108"), u8("101"), u8("99"), u8("116"), u8("105"), u8("111"), u8("110"), u8("58"), u8("32"), u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("87"), u8("111"), u8("114"), u8("108"), u8("100")], $c), std$_.string$_.utf8$([u8("104"), u8("116"), u8("116"), u8("112"), u8("115"), u8("58"), u8("47"), u8("47"), u8("97"), u8("112"), u8("116"), u8("111"), u8("115"), u8("46"), u8("100"), u8("101"), u8("118")], $c), std$_.option$_.some$(u64("1"), $c, [AtomicTypeTag.U64] as TypeTag[]), $c);
  return token$_.create_token$(creator, $.copy(collection_name), std$_.string$_.utf8$([u8("84"), u8("111"), u8("107"), u8("101"), u8("110"), u8("58"), u8("32"), u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("84"), u8("111"), u8("107"), u8("101"), u8("110")], $c), std$_.string$_.utf8$([u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("84"), u8("111"), u8("107"), u8("101"), u8("110")], $c), false, $.copy(amount), std$_.option$_.none$($c, [AtomicTypeTag.U64] as TypeTag[]), std$_.string$_.utf8$([u8("104"), u8("116"), u8("116"), u8("112"), u8("115"), u8("58"), u8("47"), u8("47"), u8("97"), u8("112"), u8("116"), u8("111"), u8("115"), u8("46"), u8("100"), u8("101"), u8("118")], $c), u64("0"), $c);
}

export function initialize_token_transfers$ (
  account: HexString,
  $c: AptosDataCache,
): void {
  return $c.move_to(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), account, new TokenTransfers({ pending_claims: table$_.new__$($c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]) }, new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", [])));
}

export function offer$ (
  sender: HexString,
  receiver: HexString,
  token_id: token$_.TokenId,
  amount: U64,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$4, temp$5, addr_pending_claims, dst_token, pending_claims, sender_addr, token, token_id__3;
  sender_addr = std$_.signer$_.address_of$(sender, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender_addr))) {
    initialize_token_transfers$(sender, $c);
  }
  else{
  }
  pending_claims = $c.borrow_global_mut<TokenTransfers>(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender_addr)).pending_claims;
  [temp$1, temp$2] = [pending_claims, $.copy(receiver)];
  if (!table$_.contains$(temp$1, temp$2, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[])) {
    table$_.add$(pending_claims, $.copy(receiver), table$_.new__$($c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]);
  }
  else{
  }
  addr_pending_claims = table$_.borrow_mut$(pending_claims, $.copy(receiver), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])] as TypeTag[]);
  token = token$_.withdraw_token$(sender, $.copy(token_id), $.copy(amount), $c);
  token_id__3 = $.copy(token$_.token_id$(token, $c));
  [temp$4, temp$5] = [addr_pending_claims, $.copy(token_id__3)];
  if (table$_.contains$(temp$4, temp$5, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[])) {
    dst_token = table$_.borrow_mut$(addr_pending_claims, $.copy(token_id__3), $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]);
    token$_.merge$(dst_token, token, $c);
  }
  else{
    table$_.add$(addr_pending_claims, $.copy(token_id__3), token, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])] as TypeTag[]);
  }
  return;
}

export function offer_script$ (
  sender: HexString,
  receiver: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  amount: U64,
  $c: AptosDataCache,
): void {
  let token_id;
  token_id = token$_.create_token_id_raw$($.copy(creator), $.copy(collection), $.copy(name), $c);
  offer$(sender, $.copy(receiver), $.copy(token_id), $.copy(amount), $c);
  return;
}


export function buildPayload_offer_script (
  receiver: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  amount: U64,
) {
  const typeParamStrings = [] as string[];
  return $.buildPayload(
    "0x1::token_transfers::offer_script",
    typeParamStrings,
    [
      $.payloadArg(receiver),
      $.payloadArg(creator),
      $.u8ArrayArg(collection),
      $.u8ArrayArg(name),
      $.payloadArg(amount),
    ]
  );

}
export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::token_transfers::TokenTransfers", TokenTransfers.TokenTransfersParser);
}

