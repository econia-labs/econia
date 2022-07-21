import { StructTag, u64, u8str, DummyCache, parseTypeTagOrThrow } from "@manahippo/move-to-ts";
import { HexString } from "aptos";
import { Command } from "commander";
import { typeTagToTypeInfo } from "./utils";
import { readConfig, sendPayloadTx } from "./utils";
import { EconiaClient } from "./EconiaClient";
import { MI } from "./generated/Econia/Registry";
import { get_price_levels$ } from "./generated/Econia/Book";

const ECONIA_ADDR_DEV = new HexString("0xf538533414430323ccd2d8f8d7ce33819653cac5a7634a80cd2429ab904b6659");

const listMarkets = async () => {
  const {client} = readConfig(program);
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const markets = await econia.getMarkets();
  console.log(`Number of markets: ${markets.length}`);
  for (const entry of markets) {
    const [key, value] = entry;
    console.log(`MARKET###############`);
    console.log(`BASE: ${u8str(key.b.struct_name)}`);
    console.log(`QUOTE: ${u8str(key.q.struct_name)}`);
    console.log(`EXP: ${u8str(key.e.struct_name)}`);
    console.log(`owner: ${value}`);
  }
}

const listOrders = async (owner: string, base: string, quote: string) => {
  const {client} = readConfig(program);
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const markets = await econia.getMarkets();
  for(const entry of markets) {
    const [mi, ownerHex] = entry;
    if (ownerHex.hex() === owner && u8str(mi.b.struct_name) === base && u8str(mi.q.struct_name) === quote ) {
      const asks = await econia.getOrders(ownerHex, true, mi);
      const bids = await econia.getOrders(ownerHex, false, mi);
      console.log(`Num asks: ${asks.length}`);
      for(const ask of asks.slice(0, 10).reverse()) {
        console.log(ask);
      }
      console.log(`Num bids: ${bids.length}`);
      for(const bid of bids.slice(0, 10)) {
        console.log(bid);
      }
      return;
    }
  }
  console.log(`Did not find the market for ${base}-${quote} owned by ${owner}`);
}

const listLevels = async (owner: string, base: string, quote: string) => {
  const {client} = readConfig(program);
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const markets = await econia.getMarkets();
  const cache = new DummyCache();
  for(const entry of markets) {
    const [mi, ownerHex] = entry;
    if (ownerHex.hex() === owner && u8str(mi.b.struct_name) === base && u8str(mi.q.struct_name) === quote ) {
      const asks = await econia.getOrders(ownerHex, true, mi);
      const bids = await econia.getOrders(ownerHex, false, mi);
      const askLevels = get_price_levels$(asks, cache);
      const bidLevels = get_price_levels$(bids, cache);
      for(const askLevel of askLevels.reverse()) {
        console.log(`ASK: ${askLevel.price.toJsNumber()}  | ${askLevel.size.toJsNumber()}`);
      }
      for(const bidLevel of bidLevels) {
        console.log(`BID: ${bidLevel.price.toJsNumber()}  | ${bidLevel.size.toJsNumber()}`);
      }
      return;
    }
  }
  console.log(`Did not find the market for ${base}-${quote} owned by ${owner}`);
}

function getTags(base: string, quote: string, exp: string) {
  const baseTag = parseTypeTagOrThrow(base);
  const quoteTag = parseTypeTagOrThrow(quote);
  const expTag = parseTypeTagOrThrow(exp);
  return [baseTag, quoteTag, expTag];
}

function getMi(base: string, quote: string, exp: string) {
  const tags = getTags(base, quote, exp);
  if (!tags) {
    return null;
  }
  const [baseTag, quoteTag, expTag] = tags;
  const mi = new MI({
    b: typeTagToTypeInfo(baseTag),
    q: typeTagToTypeInfo(quoteTag),
    e: typeTagToTypeInfo(expTag),
  }, new StructTag(MI.moduleAddress, MI.moduleName, MI.structName, []))
  return mi;
}

const registerMarket = async (base: string, quote: string, exp: string) => {
  const {client, account} = readConfig(program);
  const tags = getTags(base, quote, exp);
  if(!tags){
    return;
  }
  const [baseTag, quoteTag, expTag] = tags;
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const payload = econia.buildPayloadRegisterMarket(baseTag, quoteTag, expTag);
  await sendPayloadTx(client, account, payload);
}

const submitBid = async (owner: string, base: string, quote: string, exp: string, price: string, size: string) => {
  const {client, account} = readConfig(program);
  const mi = getMi(base, quote, exp);
  if(!mi){
    return;
  }
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const ownerHex = new HexString(owner);
  const p = u64(price);
  const s = u64(size);
  const payload = econia.buildPayloadSubmitBid(ownerHex, p, s, mi);
  console.log(JSON.stringify(payload, null, 2));
  await sendPayloadTx(client, account, payload);
}

const submitAsk = async (owner: string, base: string, quote: string, exp: string, price: string, size: string) => {
  const {client, account} = readConfig(program);
  const mi = getMi(base, quote, exp);
  if(!mi){
    return;
  }
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const ownerHex = new HexString(owner);
  const p = u64(price);
  const s = u64(size);
  const payload = econia.buildPayloadSubmitAsk(ownerHex, p, s, mi);
  await sendPayloadTx(client, account, payload);
}

const initUser = async () => {
  const {client, account} = readConfig(program);
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const payload = econia.buildPayloadInitUser();
  await sendPayloadTx(client, account, payload);
}

const deposit = async (base: string, quote: string, exp: string, baseAmt: string, quoteAmt: string) => {
  const {client, account} = readConfig(program);
  const mi = getMi(base, quote, exp);
  if(!mi){
    return;
  }
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const payload = econia.buildPayloadDeposit(u64(baseAmt), u64(quoteAmt), mi);
  await sendPayloadTx(client, account, payload);
}

const withdraw = async (base: string, quote: string, exp: string, baseAmt: string, quoteAmt: string) => {
  const {client, account} = readConfig(program);
  const mi = getMi(base, quote, exp);
  if(!mi){
    return;
  }
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const payload = econia.buildPayloadWithdraw(u64(baseAmt), u64(quoteAmt), mi);
  await sendPayloadTx(client, account, payload);
}

const initContainers = async (base: string, quote: string, exp: string) => {
  const {client, account } = readConfig(program);
  const mi = getMi(base, quote, exp);
  if(!mi){
    return;
  }
  const econia = new EconiaClient(client, ECONIA_ADDR_DEV);
  const payload = econia.buildPayloadInitContainers(mi);
  await sendPayloadTx(client, account, payload);
}


const program = new Command();

program
  .name('econia-cli')
  .description('Econia TS SDK cli tool.')
  .requiredOption('-c, --config <path>', 'path to your aptos config.yml (generated with "aptos init")')
  .option('-p, --profile <PROFILE>', 'aptos config profile to use', 'default')

program
  .command("list-markets")
  .action(listMarkets)

program
  .command("list-orders")
  .argument("<OWNER_ADDRESS>")
  .argument("<BASE_SYMBOL>")
  .argument("<QUOTE_SYMBOL>")
  .action(listOrders)

program
  .command("list-levels")
  .argument("<OWNER_ADDRESS>")
  .argument("<BASE_SYMBOL>")
  .argument("<QUOTE_SYMBOL>")
  .action(listLevels)

program
  .command("register-market")
  .argument("<BASE_SYMBOL_TYPE>")
  .argument("<QUOTE_SYMBOL_TYPE>")
  .argument("<EXP_TYPE>")
  .action(registerMarket)

program
  .command("submit-bid")
  .argument("<OWNER_ADDRESS>")
  .argument("<BASE_SYMBOL_TYPE>")
  .argument("<QUOTE_SYMBOL_TYPE>")
  .argument("<EXP_TYPE>")
  .argument("<price>")
  .argument("<size>")
  .action(submitBid)

program
  .command("submit-ask")
  .argument("<OWNER_ADDRESS>")
  .argument("<BASE_SYMBOL_TYPE>")
  .argument("<QUOTE_SYMBOL_TYPE>")
  .argument("<EXP_TYPE>")
  .argument("<price>")
  .argument("<size>")
  .action(submitAsk)

program
  .command("deposit")
  .argument("<BASE_SYMBOL_TYPE>")
  .argument("<QUOTE_SYMBOL_TYPE>")
  .argument("<EXP_TYPE>")
  .argument("<base-amt>")
  .argument("<quote-qmt>")
  .action(deposit)

program
  .command("withdraw")
  .argument("<BASE_SYMBOL_TYPE>")
  .argument("<QUOTE_SYMBOL_TYPE>")
  .argument("<EXP_TYPE>")
  .argument("<base-amt>")
  .argument("<quote-qmt>")
  .action(withdraw)

program
  .command("init-containers")
  .argument("<BASE_SYMBOL_TYPE>")
  .argument("<QUOTE_SYMBOL_TYPE>")
  .argument("<EXP_TYPE>")
  .action(initContainers)

program
  .command("init-user")
  .action(initUser)

program.parse();
