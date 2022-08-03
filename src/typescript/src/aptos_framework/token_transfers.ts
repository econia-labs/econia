import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as Aptos_std from "../aptos_std";
import * as Std from "../std";
import * as Token from "./token";
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

  pending_claims: Aptos_std.Table.Table;

  constructor(proto: any, public typeTag: TypeTag) {
    this.pending_claims = proto['pending_claims'] as Aptos_std.Table.Table;
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
export function cancel_offer_ (
  sender: HexString,
  receiver: HexString,
  token_id: Token.TokenId,
  $c: AptosDataCache,
): void {
  let pending_claims, pending_tokens, real_pending_claims, sender_addr, token;
  sender_addr = Std.Signer.address_of_(sender, $c);
  pending_claims = $c.borrow_global_mut<TokenTransfers>(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender_addr)).pending_claims;
  pending_tokens = Aptos_std.Table.borrow_mut_(pending_claims, $.copy(receiver), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]);
  token = Aptos_std.Table.remove_(pending_tokens, $.copy(token_id), $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]);
  if ((Aptos_std.Table.length_(pending_tokens, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])).eq((u64("0")))) {
    real_pending_claims = Aptos_std.Table.remove_(pending_claims, $.copy(receiver), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]);
    Aptos_std.Table.destroy_empty_(real_pending_claims, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]);
  }
  else{
  }
  return Token.deposit_token_(sender, token, $c);
}

export function cancel_offer_script_ (
  sender: HexString,
  receiver: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  $c: AptosDataCache,
): void {
  let token_id;
  token_id = Token.create_token_id_raw_($.copy(creator), $.copy(collection), $.copy(name), $c);
  cancel_offer_(sender, $.copy(receiver), $.copy(token_id), $c);
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
export function claim_ (
  receiver: HexString,
  sender: HexString,
  token_id: Token.TokenId,
  $c: AptosDataCache,
): void {
  let pending_claims, pending_tokens, real_pending_claims, receiver_addr, token;
  receiver_addr = Std.Signer.address_of_(receiver, $c);
  pending_claims = $c.borrow_global_mut<TokenTransfers>(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender)).pending_claims;
  pending_tokens = Aptos_std.Table.borrow_mut_(pending_claims, $.copy(receiver_addr), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]);
  token = Aptos_std.Table.remove_(pending_tokens, $.copy(token_id), $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]);
  if ((Aptos_std.Table.length_(pending_tokens, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])).eq((u64("0")))) {
    real_pending_claims = Aptos_std.Table.remove_(pending_claims, $.copy(receiver_addr), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]);
    Aptos_std.Table.destroy_empty_(real_pending_claims, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]);
  }
  else{
  }
  return Token.deposit_token_(receiver, token, $c);
}

export function claim_script_ (
  receiver: HexString,
  sender: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  $c: AptosDataCache,
): void {
  let token_id;
  token_id = Token.create_token_id_raw_($.copy(creator), $.copy(collection), $.copy(name), $c);
  claim_(receiver, $.copy(sender), $.copy(token_id), $c);
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
export function create_token_ (
  creator: HexString,
  amount: U64,
  $c: AptosDataCache,
): Token.TokenId {
  let collection_name;
  collection_name = Std.String.utf8_([u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("87"), u8("111"), u8("114"), u8("108"), u8("100")], $c);
  Token.create_collection_(creator, $.copy(collection_name), Std.String.utf8_([u8("67"), u8("111"), u8("108"), u8("108"), u8("101"), u8("99"), u8("116"), u8("105"), u8("111"), u8("110"), u8("58"), u8("32"), u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("87"), u8("111"), u8("114"), u8("108"), u8("100")], $c), Std.String.utf8_([u8("104"), u8("116"), u8("116"), u8("112"), u8("115"), u8("58"), u8("47"), u8("47"), u8("97"), u8("112"), u8("116"), u8("111"), u8("115"), u8("46"), u8("100"), u8("101"), u8("118")], $c), Std.Option.some_(u64("1"), $c, [AtomicTypeTag.U64]), $c);
  return Token.create_token_(creator, $.copy(collection_name), Std.String.utf8_([u8("84"), u8("111"), u8("107"), u8("101"), u8("110"), u8("58"), u8("32"), u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("84"), u8("111"), u8("107"), u8("101"), u8("110")], $c), Std.String.utf8_([u8("72"), u8("101"), u8("108"), u8("108"), u8("111"), u8("44"), u8("32"), u8("84"), u8("111"), u8("107"), u8("101"), u8("110")], $c), false, $.copy(amount), Std.Option.none_($c, [AtomicTypeTag.U64]), Std.String.utf8_([u8("104"), u8("116"), u8("116"), u8("112"), u8("115"), u8("58"), u8("47"), u8("47"), u8("97"), u8("112"), u8("116"), u8("111"), u8("115"), u8("46"), u8("100"), u8("101"), u8("118")], $c), u64("0"), $c);
}

export function initialize_token_transfers_ (
  account: HexString,
  $c: AptosDataCache,
): void {
  return $c.move_to(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), account, new TokenTransfers({ pending_claims: Aptos_std.Table.new___($c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]) }, new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", [])));
}

export function offer_ (
  sender: HexString,
  receiver: HexString,
  token_id: Token.TokenId,
  amount: U64,
  $c: AptosDataCache,
): void {
  let temp$1, temp$2, temp$4, temp$5, addr_pending_claims, dst_token, pending_claims, sender_addr, token, token_id__3;
  sender_addr = Std.Signer.address_of_(sender, $c);
  if (!$c.exists(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender_addr))) {
    initialize_token_transfers_(sender, $c);
  }
  else{
  }
  pending_claims = $c.borrow_global_mut<TokenTransfers>(new StructTag(new HexString("0x1"), "token_transfers", "TokenTransfers", []), $.copy(sender_addr)).pending_claims;
  [temp$1, temp$2] = [pending_claims, $.copy(receiver)];
  if (!Aptos_std.Table.contains_(temp$1, temp$2, $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])])) {
    Aptos_std.Table.add_(pending_claims, $.copy(receiver), Aptos_std.Table.new___($c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]);
  }
  else{
  }
  addr_pending_claims = Aptos_std.Table.borrow_mut_(pending_claims, $.copy(receiver), $c, [AtomicTypeTag.Address, new StructTag(new HexString("0x1"), "table", "Table", [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])]);
  token = Token.withdraw_token_(sender, $.copy(token_id), $.copy(amount), $c);
  token_id__3 = $.copy(Token.token_id_(token, $c));
  [temp$4, temp$5] = [addr_pending_claims, $.copy(token_id__3)];
  if (Aptos_std.Table.contains_(temp$4, temp$5, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])])) {
    dst_token = Aptos_std.Table.borrow_mut_(addr_pending_claims, $.copy(token_id__3), $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]);
    Token.merge_(dst_token, token, $c);
  }
  else{
    Aptos_std.Table.add_(addr_pending_claims, $.copy(token_id__3), token, $c, [new StructTag(new HexString("0x1"), "token", "TokenId", []), new StructTag(new HexString("0x1"), "token", "Token", [])]);
  }
  return;
}

export function offer_script_ (
  sender: HexString,
  receiver: HexString,
  creator: HexString,
  collection: U8[],
  name: U8[],
  amount: U64,
  $c: AptosDataCache,
): void {
  let token_id;
  token_id = Token.create_token_id_raw_($.copy(creator), $.copy(collection), $.copy(name), $c);
  offer_(sender, $.copy(receiver), $.copy(token_id), $.copy(amount), $c);
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

