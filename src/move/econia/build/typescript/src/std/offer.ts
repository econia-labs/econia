import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo, DummyCache} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as error$_ from "./error";
import * as signer$_ from "./signer";
export const packageName = "MoveNursery";
export const moduleAddress = new HexString("0x1");
export const moduleName = "offer";

export const EOFFER_ALREADY_CREATED : U64 = u64("1");
export const EOFFER_DNE_FOR_ACCOUNT : U64 = u64("0");
export const EOFFER_DOES_NOT_EXIST : U64 = u64("2");


export class Offer 
{
  static moduleAddress = moduleAddress;
  static moduleName = moduleName;
  static structName: string = "Offer";
  static typeParameters: TypeParamDeclType[] = [
    { name: "Offered", isPhantom: false }
  ];
  static fields: FieldDeclType[] = [
  { name: "offered", typeTag: new $.TypeParamIdx(0) },
  { name: "for__", typeTag: AtomicTypeTag.Address }];

  offered: any;
  for__: HexString;

  constructor(proto: any, public typeTag: TypeTag) {
    this.offered = proto['offered'] as any;
    this.for__ = proto['for__'] as HexString;
  }

  static OfferParser(data:any, typeTag: TypeTag, repo: AptosParserRepo) : Offer {
    const proto = $.parseStructProto(data, typeTag, repo, Offer);
    return new Offer(proto, typeTag);
  }

  static async load(repo: AptosParserRepo, client: AptosClient, address: HexString, typeParams: TypeTag[]) {
    const result = await repo.loadResource(client, address, Offer, typeParams);
    return result as unknown as Offer;
  }
}
export function address_of$ (
  offer_address: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Offered>*/
): HexString {
  if (!$c.exists(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), $.copy(offer_address))) {
    throw $.abortCode(error$_.not_found$(EOFFER_DOES_NOT_EXIST, $c));
  }
  return $.copy($c.borrow_global<Offer>(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), $.copy(offer_address)).for__);
}

export function create$ (
  account: HexString,
  offered: any,
  for__: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Offered>*/
): void {
  if (!!$c.exists(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), signer$_.address_of$(account, $c))) {
    throw $.abortCode(error$_.already_exists$(EOFFER_ALREADY_CREATED, $c));
  }
  $c.move_to(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), account, new Offer({ offered: offered, for: $.copy(for__) }, new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]])));
  return;
}

export function exists_at$ (
  offer_address: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Offered>*/
): boolean {
  return $c.exists(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), $.copy(offer_address));
}

export function redeem$ (
  account: HexString,
  offer_address: HexString,
  $c: AptosDataCache,
  $p: TypeTag[], /* <Offered>*/
): any {
  let temp$1, sender;
  if (!$c.exists(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), $.copy(offer_address))) {
    throw $.abortCode(error$_.not_found$(EOFFER_DOES_NOT_EXIST, $c));
  }
  let { offered: offered, for__: for__ } = $c.move_from<Offer>(new StructTag(new HexString("0x1"), "offer", "Offer", [$p[0]]), $.copy(offer_address));
  sender = signer$_.address_of$(account, $c);
  if (($.copy(sender).hex() === $.copy(for__).hex())) {
    temp$1 = true;
  }
  else{
    temp$1 = ($.copy(sender).hex() === $.copy(offer_address).hex());
  }
  if (!temp$1) {
    throw $.abortCode(error$_.invalid_argument$(EOFFER_DNE_FOR_ACCOUNT, $c));
  }
  return offered;
}

export function loadParsers(repo: AptosParserRepo) {
  repo.addParser("0x1::offer::Offer", Offer.OfferParser);
}

