import { AptosClient, HexString } from "aptos";
import { AptosLocalCache, AptosParserRepo, TypeTag, DummyCache, U64, U128 } from "@manahippo/move-to-ts";
import { buildPayload_register_market, MI, MR } from "./generated/Econia/Registry";
import { getProjectRepo } from "./generated";
import { TypedIterableTable } from "./generated/AptosFramework/IterableTable";
import { get_orders$, get_price_levels$, OB, Order, PriceLevel } from "./generated/Econia/Book";
import { buildPayload_cancel_ask, buildPayload_cancel_bid, buildPayload_deposit, buildPayload_init_containers, buildPayload_init_user, buildPayload_submit_ask, buildPayload_submit_bid, buildPayload_withdraw } from "./generated/Econia/User";
import { buildPayload_submit_market_buy, buildPayload_submit_market_sell } from "./generated/Econia/Match";
import { typeInfoToTypeTag } from "./utils";

function getMiTags(mi: MI): TypeTag[] {
  return [
    typeInfoToTypeTag(mi.b),
    typeInfoToTypeTag(mi.q),
    typeInfoToTypeTag(mi.e),
  ]
}


export class EconiaClient {
  public repo: AptosParserRepo;
  constructor(
    public aptosClient: AptosClient,
    public registryOwner: HexString,
  ) {
    this.repo = getProjectRepo();
  }

  async getMarkets(): Promise<[MI, HexString][]> {
    const registry = await MR.load(this.repo, this.aptosClient, this.registryOwner, []);
    const iterTableField = MR.fields.filter(f => f.name === 't')[0];
    const typedIterTable = TypedIterableTable.buildFromField<MI, HexString>(registry.t, iterTableField);
    const entries = await typedIterTable.fetchAll(this.aptosClient, this.repo);
    return entries;
  }

  // side: true: ASK, false: BID
  async getOrders(hostAddress: HexString, side: boolean, mi: MI): Promise<Order[]> {
    const book = await OB.load(this.repo, this.aptosClient, hostAddress, getMiTags(mi));
    const cache = new AptosLocalCache();
    cache.move_to(book.typeTag, hostAddress, book);
    return get_orders$(hostAddress, side, cache, getMiTags(mi));
  }

  ordersToPriceLevels(orders: Order[]): PriceLevel[] {
    return get_price_levels$(orders, new DummyCache());
  }

  // add limit orders
  buildPayloadSubmitAsk(host: HexString, price: U64, size: U64, mi: MI) {
    return buildPayload_submit_ask(host, price, size, getMiTags(mi));
  }

  buildPayloadSubmitBid(host: HexString, price: U64, size: U64, mi: MI) {
    return buildPayload_submit_bid(host, price, size, getMiTags(mi));
  }

  // cancel limit orders
  buildPayloadCancelAsk(host: HexString, id: U128, mi: MI) {
    return buildPayload_cancel_ask(host, id, getMiTags(mi));
  }

  buildPayloadCanceltBid(host: HexString, id: U128, mi: MI) {
    return buildPayload_cancel_bid(host, id, getMiTags(mi));
  }

  // market orders
  buildPayloadSubmitMarketBuy(host: HexString, requestedSize: U64, maxQuoteToSpend: U64, mi: MI) {
    return buildPayload_submit_market_buy(host, requestedSize, maxQuoteToSpend, getMiTags(mi));
  }

  buildPayloadSubmitMarketSell(host: HexString, requestedSize: U64, mi: MI) {
    return buildPayload_submit_market_sell(host, requestedSize, getMiTags(mi));
  }

  // funding
  buildPayloadDeposit(baseAmt: U64, quoteAmt: U64, mi: MI) {
    const payload = buildPayload_deposit(baseAmt, quoteAmt, getMiTags(mi));
    return payload;
  }

  buildPayloadWithdraw(baseAmt: U64, quoteAmt: U64, mi: MI) {
    const payload = buildPayload_withdraw(baseAmt, quoteAmt, getMiTags(mi));
    return payload;
  }

  // meta-ops
  buildPayloadRegisterMarket(baseTag: TypeTag, quoteTag: TypeTag, expTag: TypeTag) {
    const payload = buildPayload_register_market([baseTag, quoteTag, expTag]);
    return payload;
  }

  buildPayloadInitUser() {
    const payload = buildPayload_init_user();
    return payload;
  }

  buildPayloadInitContainers(mi: MI) {
    const payload = buildPayload_init_containers(getMiTags(mi));
    return payload;
  }
}
