import * as $ from "@manahippo/move-to-ts";
import {AptosDataCache, AptosParserRepo} from "@manahippo/move-to-ts";
import {U8, U64, U128} from "@manahippo/move-to-ts";
import {u8, u64, u128} from "@manahippo/move-to-ts";
import {TypeParamDeclType, FieldDeclType} from "@manahippo/move-to-ts";
import {AtomicTypeTag, StructTag, TypeTag, VectorTag} from "@manahippo/move-to-ts";
import {HexString, AptosClient} from "aptos";
import * as aptos_framework$_ from "../aptos_framework";
import * as std$_ from "../std";
import * as Book$_ from "./Book";
import * as Caps$_ from "./Caps";
import * as ID$_ from "./ID";
import * as Orders$_ from "./Orders";
import * as User$_ from "./User";
export const packageName = "Econia";
export const moduleAddress = new HexString("0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9");
export const moduleName = "Match";

export const ASK : boolean = true;
export const BID : boolean = false;
export const BUY : boolean = true;
export const E_NOT_ENOUGH_COLLATERAL : U64 = u64("2");
export const E_NO_MARKET : U64 = u64("0");
export const E_NO_O_C : U64 = u64("1");
export const E_QUOTE_SPEND_0 : U64 = u64("4");
export const E_SIZE_0 : U64 = u64("3");
export const SELL : boolean = false;

export function fill_market_order$ (
  host: HexString,
  addr: HexString,
  side: boolean,
  requested_size: U64,
  quote_available: U64,
  book_cap: Book$_.FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): [U64, U64] {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6, base_parcels_filled, complete, exact, filled, insufficient_quote, n_positions, partial_target_fill, quote_coins_filled, quote_coins_just_filled, scale_factor, target_addr, target_c_i, target_id, target_p_f;
  if ((side == ASK)) {
    temp$1 = Book$_.n_asks$($.copy(host), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  else{
    temp$1 = Book$_.n_bids$($.copy(host), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  n_positions = temp$1;
  if ($.copy(n_positions).eq(u64("0"))) {
    return [u64("0"), u64("0")];
  }
  else{
  }
  scale_factor = Book$_.scale_factor$($.copy(host), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  [base_parcels_filled, quote_coins_filled] = [u64("0"), u64("0")];
  [target_id, target_addr, target_p_f, target_c_i, filled, exact, insufficient_quote] = Book$_.traverse_init_fill$($.copy(host), $.copy(addr), side, $.copy(requested_size), $.copy(quote_available), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  while (true) {
    base_parcels_filled = $.copy(base_parcels_filled).add($.copy(filled));
    quote_coins_just_filled = ID$_.price$($.copy(target_id), $c).mul($.copy(filled));
    quote_coins_filled = $.copy(quote_coins_filled).add($.copy(quote_coins_just_filled));
    if ((side == ASK)) {
      quote_available = $.copy(quote_available).sub($.copy(quote_coins_just_filled));
    }
    else{
    }
    requested_size = $.copy(requested_size).sub($.copy(filled));
    if (exact) {
      temp$2 = true;
    }
    else{
      temp$2 = $.copy(requested_size).gt(u64("0"));
    }
    if (temp$2) {
      temp$3 = !insufficient_quote;
    }
    else{
      temp$3 = false;
    }
    complete = temp$3;
    User$_.process_fill$($.copy(target_addr), $.copy(addr), side, $.copy(target_id), $.copy(filled), $.copy(scale_factor), complete, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    if ($.copy(requested_size).gt(u64("0"))) {
      temp$4 = $.copy(n_positions).gt(u64("1"));
    }
    else{
      temp$4 = false;
    }
    if (temp$4) {
      temp$5 = !insufficient_quote;
    }
    else{
      temp$5 = false;
    }
    if (temp$5) {
      [target_id, target_addr, target_p_f, target_c_i, filled, exact, insufficient_quote] = Book$_.traverse_pop_fill$($.copy(host), $.copy(addr), side, $.copy(requested_size), $.copy(quote_available), $.copy(n_positions), $.copy(target_id), $.copy(target_p_f), $.copy(target_c_i), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
      n_positions = $.copy(n_positions).sub(u64("1"));
    }
    else{
      if ($.copy(requested_size).eq(u64("0"))) {
        temp$6 = !exact;
      }
      else{
        temp$6 = false;
      }
      partial_target_fill = (temp$6 || insufficient_quote);
      if (!partial_target_fill) {
        Book$_.cancel_position$($.copy(host), side, $.copy(target_id), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
      }
      else{
      }
      Book$_.refresh_extreme_order_id$($.copy(host), side, book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
      break;
    }
  }
  return [$.copy(base_parcels_filled).mul($.copy(scale_factor)), $.copy(quote_coins_filled)];
}

export function submit_market_buy$ (
  user: HexString,
  host: HexString,
  requested_size: U64,
  max_quote_to_spend: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2;
  submit_market_order$(user, $.copy(host), BUY, $.copy(requested_size), $.copy(max_quote_to_spend), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  temp$2 = user;
  temp$1 = Caps$_.orders_f_c$($c);
  User$_.update_s_c$(temp$2, temp$1, $c);
  return;
}


export function buildPayload_submit_market_buy (
  host: HexString,
  requested_size: U64,
  max_quote_to_spend: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Match::submit_market_buy",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(requested_size),
      $.payloadArg(max_quote_to_spend),
    ]
  );

}

export function submit_market_order$ (
  user: HexString,
  host: HexString,
  side: boolean,
  requested_size: U64,
  max_quote_to_spend: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$10, temp$11, temp$12, temp$13, temp$14, temp$2, temp$3, temp$4, temp$5, temp$6, temp$7, temp$8, temp$9, base_available, base_coins_required, base_coins_sold, book_cap, orders_cap, quote_available, quote_coins_spent, user_address;
  if (!$.copy(requested_size).gt(u64("0"))) {
    throw $.abortCode(E_SIZE_0);
  }
  if ((side == BUY)) {
    if (!$.copy(max_quote_to_spend).gt(u64("0"))) {
      throw $.abortCode(E_QUOTE_SPEND_0);
    }
  }
  else{
  }
  [book_cap, orders_cap] = [Caps$_.book_f_c$($c), Caps$_.orders_f_c$($c)];
  if (!Book$_.exists_book$($.copy(host), book_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_MARKET);
  }
  user_address = std$_.signer$_.address_of$(user, $c);
  if (!User$_.exists_o_c$($.copy(user_address), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    throw $.abortCode(E_NO_O_C);
  }
  [base_available, quote_available] = User$_.get_available_collateral$($.copy(user_address), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  if ((side == BUY)) {
    if (!$.copy(quote_available).ge($.copy(max_quote_to_spend))) {
      throw $.abortCode(E_NOT_ENOUGH_COLLATERAL);
    }
    temp$6 = $.copy(host);
    temp$5 = $.copy(user_address);
    temp$4 = ASK;
    temp$3 = $.copy(requested_size);
    temp$2 = $.copy(max_quote_to_spend);
    temp$1 = Caps$_.book_f_c$($c);
    [, quote_coins_spent] = fill_market_order$(temp$6, temp$5, temp$4, temp$3, temp$2, temp$1, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    User$_.dec_available_collateral$($.copy(user_address), u64("0"), $.copy(quote_coins_spent), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  else{
    temp$8 = $.copy(user_address);
    temp$7 = Caps$_.orders_f_c$($c);
    base_coins_required = $.copy(requested_size).mul(Orders$_.scale_factor$(temp$8, temp$7, $c, [$p[0], $p[1], $p[2]] as TypeTag[]));
    if (!$.copy(base_available).ge($.copy(base_coins_required))) {
      throw $.abortCode(E_NOT_ENOUGH_COLLATERAL);
    }
    temp$14 = $.copy(host);
    temp$13 = $.copy(user_address);
    temp$12 = BID;
    temp$11 = $.copy(requested_size);
    temp$10 = u64("0");
    temp$9 = Caps$_.book_f_c$($c);
    [base_coins_sold, ] = fill_market_order$(temp$14, temp$13, temp$12, temp$11, temp$10, temp$9, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
    User$_.dec_available_collateral$($.copy(user_address), $.copy(base_coins_sold), u64("0"), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  return;
}

export function submit_market_sell$ (
  user: HexString,
  host: HexString,
  requested_size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2;
  submit_market_order$(user, $.copy(host), SELL, $.copy(requested_size), u64("0"), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  temp$2 = user;
  temp$1 = Caps$_.orders_f_c$($c);
  User$_.update_s_c$(temp$2, temp$1, $c);
  return;
}


export function buildPayload_submit_market_sell (
  host: HexString,
  requested_size: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Match::submit_market_sell",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(requested_size),
    ]
  );

}

export function swap$ (
  user: HexString,
  host: HexString,
  side: boolean,
  requested_size: U64,
  max_quote_to_spend: U64,
  orders_cap: Orders$_.FriendCap,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let base_coins_needed, base_collateral, quote_collateral, user_addr;
  user_addr = std$_.signer$_.address_of$(user, $c);
  if (!User$_.exists_sequence_counter$($.copy(user_addr), orders_cap, $c)) {
    User$_.init_user$(user, $c);
  }
  else{
  }
  if (!User$_.exists_o_c$($.copy(user_addr), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[])) {
    User$_.init_containers$(user, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  else{
  }
  if (!aptos_framework$_.coin$_.is_account_registered$($.copy(user_addr), $c, [$p[0]] as TypeTag[])) {
    aptos_framework$_.coin$_.register$(user, $c, [$p[0]] as TypeTag[]);
  }
  else{
  }
  if (!aptos_framework$_.coin$_.is_account_registered$($.copy(user_addr), $c, [$p[1]] as TypeTag[])) {
    aptos_framework$_.coin$_.register$(user, $c, [$p[1]] as TypeTag[]);
  }
  else{
  }
  if ((side == BUY)) {
    User$_.deposit_internal$(user, u64("0"), $.copy(max_quote_to_spend), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  else{
    base_coins_needed = $.copy(requested_size).mul(Orders$_.scale_factor$($.copy(user_addr), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]));
    User$_.deposit_internal$(user, $.copy(base_coins_needed), u64("0"), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  }
  submit_market_order$(user, $.copy(host), side, $.copy(requested_size), $.copy(max_quote_to_spend), $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  [base_collateral, quote_collateral] = User$_.get_available_collateral$($.copy(user_addr), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  User$_.withdraw_internal$(user, $.copy(base_collateral), $.copy(quote_collateral), orders_cap, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
  return;
}

export function swap_buy$ (
  user: HexString,
  host: HexString,
  requested_size: U64,
  max_quote_to_spend: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6;
  temp$6 = user;
  temp$5 = $.copy(host);
  temp$4 = BUY;
  temp$3 = $.copy(requested_size);
  temp$2 = $.copy(max_quote_to_spend);
  temp$1 = Caps$_.orders_f_c$($c);
  return swap$(temp$6, temp$5, temp$4, temp$3, temp$2, temp$1, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}


export function buildPayload_swap_buy (
  host: HexString,
  requested_size: U64,
  max_quote_to_spend: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Match::swap_buy",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(requested_size),
      $.payloadArg(max_quote_to_spend),
    ]
  );

}

export function swap_sell$ (
  user: HexString,
  host: HexString,
  requested_size: U64,
  $c: AptosDataCache,
  $p: TypeTag[], /* <B, Q, E>*/
): void {
  let temp$1, temp$2, temp$3, temp$4, temp$5, temp$6;
  temp$6 = user;
  temp$5 = $.copy(host);
  temp$4 = SELL;
  temp$3 = $.copy(requested_size);
  temp$2 = u64("0");
  temp$1 = Caps$_.orders_f_c$($c);
  return swap$(temp$6, temp$5, temp$4, temp$3, temp$2, temp$1, $c, [$p[0], $p[1], $p[2]] as TypeTag[]);
}


export function buildPayload_swap_sell (
  host: HexString,
  requested_size: U64,
  $p: TypeTag[], /* <B, Q, E>*/
) {
  const typeParamStrings = $p.map(t=>$.getTypeTagFullname(t));
  return $.buildPayload(
    "0x366d989b43410749faf89a28742f43935bd91c65070db5b840bc7777be9201f9::Match::swap_sell",
    typeParamStrings,
    [
      $.payloadArg(host),
      $.payloadArg(requested_size),
    ]
  );

}

export function loadParsers(repo: AptosParserRepo) {
}

