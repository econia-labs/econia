
<a name="0xc0deb00c_market"></a>

# Module `0xc0deb00c::market`

Market-level book keeping functionality, with matching engine.
Allows for self-matched trades since preventing them is practically
impossible in a permissionless market: all a user has to do is
open two wallets and trade them against each other.

End-to-end matching engine testing begins with a call to
<code>register_end_to_end_users_test()</code>, which places a limit order order
on the book for <code>USER_1</code> (<code>@user_1</code>) <code>USER_2</code>, and <code>USER_3</code>, with
<code>USER_1</code>'s order nearest the spread and <code>USER_3</code>'s order furthest
away. Then a call to the matching engine is invoked, and post-match
state is verified via <code>verify_end_to_end_state_test()</code>. See tests
of form <code>test_end_to_end....()</code>.

Dependency charts for both matching engine functions and end-to-end
testing functions are at
[<code>dependencies.md</code>](../../../dependencies.md).

---


-  [Struct `Order`](#0xc0deb00c_market_Order)
-  [Struct `OrderBook`](#0xc0deb00c_market_OrderBook)
-  [Resource `OrderBooks`](#0xc0deb00c_market_OrderBooks)
-  [Constants](#@Constants_0)
-  [Function `cancel_all_limit_orders_custodian`](#0xc0deb00c_market_cancel_all_limit_orders_custodian)
-  [Function `cancel_limit_order_custodian`](#0xc0deb00c_market_cancel_limit_order_custodian)
-  [Function `place_limit_order_custodian`](#0xc0deb00c_market_place_limit_order_custodian)
-  [Function `place_market_order_custodian`](#0xc0deb00c_market_place_market_order_custodian)
-  [Function `swap_coins`](#0xc0deb00c_market_swap_coins)
    -  [Type parameters](#@Type_parameters_1)
    -  [Parameters](#@Parameters_2)
    -  [Returns](#@Returns_3)
    -  [Abort conditions](#@Abort_conditions_4)
        -  [If a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>](#@If_a_<code><a_href="market.md#0xc0deb00c_market_BUY">BUY</a></code>_5)
        -  [If a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>](#@If_a_<code><a_href="market.md#0xc0deb00c_market_SELL">SELL</a></code>_6)
-  [Function `swap_generic`](#0xc0deb00c_market_swap_generic)
    -  [Type parameters](#@Type_parameters_7)
    -  [Parameters](#@Parameters_8)
    -  [Returns](#@Returns_9)
    -  [Abort conditions](#@Abort_conditions_10)
-  [Function `cancel_all_limit_orders_user`](#0xc0deb00c_market_cancel_all_limit_orders_user)
-  [Function `cancel_limit_order_user`](#0xc0deb00c_market_cancel_limit_order_user)
-  [Function `place_limit_order_user`](#0xc0deb00c_market_place_limit_order_user)
-  [Function `place_market_order_user`](#0xc0deb00c_market_place_market_order_user)
-  [Function `register_market_generic`](#0xc0deb00c_market_register_market_generic)
-  [Function `register_market_pure_coin`](#0xc0deb00c_market_register_market_pure_coin)
-  [Function `swap_between_coinstores`](#0xc0deb00c_market_swap_between_coinstores)
-  [Function `cancel_all_limit_orders`](#0xc0deb00c_market_cancel_all_limit_orders)
    -  [Parameters](#@Parameters_11)
    -  [Assumes](#@Assumes_12)
-  [Function `cancel_limit_order`](#0xc0deb00c_market_cancel_limit_order)
    -  [Parameters](#@Parameters_13)
    -  [Abort conditions](#@Abort_conditions_14)
-  [Function `get_counter`](#0xc0deb00c_market_get_counter)
-  [Function `match`](#0xc0deb00c_market_match)
    -  [Type parameters](#@Type_parameters_15)
    -  [Parameters](#@Parameters_16)
    -  [Assumes](#@Assumes_17)
    -  [Checks not performed](#@Checks_not_performed_18)
-  [Function `match_from_market_account`](#0xc0deb00c_market_match_from_market_account)
    -  [Type parameters](#@Type_parameters_19)
    -  [Parameters](#@Parameters_20)
-  [Function `match_init`](#0xc0deb00c_market_match_init)
    -  [Type parameters](#@Type_parameters_21)
    -  [Parameters](#@Parameters_22)
    -  [Returns](#@Returns_23)
    -  [Abort conditions](#@Abort_conditions_24)
-  [Function `match_loop`](#0xc0deb00c_market_match_loop)
    -  [Type parameters](#@Type_parameters_25)
    -  [Parameters](#@Parameters_26)
    -  [Passing considerations](#@Passing_considerations_27)
-  [Function `match_loop_break`](#0xc0deb00c_market_match_loop_break)
    -  [Parameters](#@Parameters_28)
-  [Function `match_loop_init`](#0xc0deb00c_market_match_loop_init)
    -  [Parameters](#@Parameters_29)
    -  [Returns](#@Returns_30)
    -  [Passing considerations](#@Passing_considerations_31)
-  [Function `match_loop_order`](#0xc0deb00c_market_match_loop_order)
    -  [Type parameters](#@Type_parameters_32)
    -  [Parameters](#@Parameters_33)
-  [Function `match_loop_order_fill_size`](#0xc0deb00c_market_match_loop_order_fill_size)
    -  [Parameters](#@Parameters_34)
-  [Function `match_loop_order_follow_up`](#0xc0deb00c_market_match_loop_order_follow_up)
    -  [Parameters](#@Parameters_35)
    -  [Returns](#@Returns_36)
    -  [Passing considerations](#@Passing_considerations_37)
    -  [Target order reference rationale](#@Target_order_reference_rationale_38)
-  [Function `match_range_check_fills`](#0xc0deb00c_market_match_range_check_fills)
    -  [Terminology](#@Terminology_39)
    -  [Parameters](#@Parameters_40)
    -  [Abort conditions](#@Abort_conditions_41)
    -  [Checks not performed](#@Checks_not_performed_42)
-  [Function `match_verify_fills`](#0xc0deb00c_market_match_verify_fills)
    -  [Parameters](#@Parameters_43)
    -  [Abort conditions](#@Abort_conditions_44)
-  [Function `place_limit_order`](#0xc0deb00c_market_place_limit_order)
    -  [Type parameters](#@Type_parameters_45)
    -  [Parameters](#@Parameters_46)
    -  [Abort conditions](#@Abort_conditions_47)
    -  [Assumes](#@Assumes_48)
-  [Function `place_limit_order_post_match`](#0xc0deb00c_market_place_limit_order_post_match)
    -  [Parameters](#@Parameters_49)
    -  [Assumes](#@Assumes_50)
-  [Function `place_limit_order_pre_match`](#0xc0deb00c_market_place_limit_order_pre_match)
    -  [Match fill amounts](#@Match_fill_amounts_51)
    -  [Parameters](#@Parameters_52)
    -  [Abort conditions](#@Abort_conditions_53)
-  [Function `place_market_order`](#0xc0deb00c_market_place_market_order)
    -  [Extra parameters](#@Extra_parameters_54)
-  [Function `register_market`](#0xc0deb00c_market_register_market)
    -  [Type parameters](#@Type_parameters_55)
    -  [Parameters](#@Parameters_56)
-  [Function `register_order_book`](#0xc0deb00c_market_register_order_book)
    -  [Type parameters](#@Type_parameters_57)
    -  [Parameters](#@Parameters_58)
-  [Function `swap`](#0xc0deb00c_market_swap)
    -  [Type parameters](#@Type_parameters_59)
    -  [Parameters](#@Parameters_60)
    -  [Assumes](#@Assumes_61)
    -  [Abort conditions](#@Abort_conditions_62)
-  [Function `verify_order_book_exists`](#0xc0deb00c_market_verify_order_book_exists)
    -  [Abort conditions](#@Abort_conditions_63)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
<b>use</b> <a href="open_table.md#0xc0deb00c_open_table">0xc0deb00c::open_table</a>;
<b>use</b> <a href="order_id.md#0xc0deb00c_order_id">0xc0deb00c::order_id</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
<b>use</b> <a href="user.md#0xc0deb00c_user">0xc0deb00c::user</a>;
</code></pre>



<a name="0xc0deb00c_market_Order"></a>

## Struct `Order`

An order on the order book


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_Order">Order</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Number of lots to be filled
</dd>
<dt>
<code><a href="user.md#0xc0deb00c_user">user</a>: <b>address</b></code>
</dt>
<dd>
 Address of corresponding user
</dd>
<dt>
<code>general_custodian_id: u64</code>
</dt>
<dd>
 For given user, the ID of the custodian required to approve
 transactions other than generic asset transfers
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_OrderBook"></a>

## Struct `OrderBook`

An order book for a given market


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Base asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to
 <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>, or a non-coin asset indicated by
 the market host.
</dd>
<dt>
<code>quote_type_info: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 Quote asset type info. When trading an
 <code>aptos_framework::coin::Coin</code>, corresponds to the phantom
 <code>CoinType</code>, for instance <code>MyCoin</code> rather than
 <code>Coin&lt;MyCoin&gt;</code>. Otherwise corresponds to
 <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>, or a non-coin asset indicated by
 the market host.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 Number of base units exchanged per lot
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 Number of quote units exchanged per tick
</dd>
<dt>
<code>generic_asset_transfer_custodian_id: u64</code>
</dt>
<dd>
 ID of custodian capability required to verify deposits,
 swaps, and withdrawals of assets that are not coins. A
 "market-wide asset transfer custodian ID" that only applies
 to markets having at least one non-coin asset. For a market
 having one coin asset and one generic asset, only applies to
 the generic asset. Marked <code><a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when base and
 quote types are both coins.
</dd>
<dt>
<code>asks: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Asks tree
</dd>
<dt>
<code>bids: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Bids tree
</dd>
<dt>
<code>min_ask: u128</code>
</dt>
<dd>
 Order ID of minimum ask, per price-time priority. The ask
 side "spread maker".
</dd>
<dt>
<code>max_bid: u128</code>
</dt>
<dd>
 Order ID of maximum bid, per price-time priority. The bid
 side "spread maker".
</dd>
<dt>
<code>counter: u64</code>
</dt>
<dd>
 Number of maker orders placed on book
</dd>
</dl>


</details>

<a name="0xc0deb00c_market_OrderBooks"></a>

## Resource `OrderBooks`

Order book map for all of a user's <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>s


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;u64, <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&gt;</code>
</dt>
<dd>
 Map from market ID to <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>. Separated into different
 table entries to reduce transaction collisions across
 markets
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_market_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_market_LEFT"></a>

Left traversal direction, denoting predecessor traversal


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_RIGHT"></a>

Right traversal direction, denoting successor traversal


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_CUSTODIAN"></a>

When invalid custodian attempts to manage an order


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_market_NO_CUSTODIAN"></a>

Custodian ID flag for no delegated custodian


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_PURE_COIN_PAIR"></a>

When both base and quote assets are coins


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_ASK"></a>

Ask flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_BID"></a>

Bid flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_BUY"></a>

Buy direction flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BUY">BUY</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_E_BOTH_COINS"></a>

When both assets are coins but at least one should be generic


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_BOTH_COINS">E_BOTH_COINS</a>: u64 = 18;
</code></pre>



<a name="0xc0deb00c_market_E_INBOUND_ASSET_OVERFLOW"></a>

When matching overflows the asset received from trading


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INBOUND_ASSET_OVERFLOW">E_INBOUND_ASSET_OVERFLOW</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_BASE"></a>

When invalid base type indicated


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_BASE">E_INVALID_BASE</a>: u64 = 14;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_OPTION_BASE"></a>

When a base asset is improperly option-wrapped for generic swap


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_OPTION_BASE">E_INVALID_OPTION_BASE</a>: u64 = 16;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_OPTION_QUOTE"></a>

When a quote asset is improperly option-wrapped for generic swap


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_OPTION_QUOTE">E_INVALID_OPTION_QUOTE</a>: u64 = 17;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_QUOTE"></a>

When invalid quote type indicated


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_QUOTE">E_INVALID_QUOTE</a>: u64 = 15;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_USER"></a>

When invalid user attempts to manage an order


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_market_E_LIMIT_PRICE_0"></a>

When indicated limit price is 0


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_LIMIT_PRICE_0">E_LIMIT_PRICE_0</a>: u64 = 13;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX"></a>

When minimum indicated base units to match exceeds maximum


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX">E_MIN_BASE_EXCEEDS_MAX</a>: u64 = 11;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_LOTS_NOT_FILLED"></a>

When minimum number of lots are not filled by matching engine


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_LOTS_NOT_FILLED">E_MIN_LOTS_NOT_FILLED</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX"></a>

When minimum indicated quote units to match exceeds maximum


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX">E_MIN_QUOTE_EXCEEDS_MAX</a>: u64 = 12;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_TICKS_NOT_FILLED"></a>

When minimum number of ticks are not filled by matching engine


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_TICKS_NOT_FILLED">E_MIN_TICKS_NOT_FILLED</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_market_E_NOT_ENOUGH_OUTBOUND_ASSET"></a>

When not enough asset to trade away for indicated match values


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NOT_ENOUGH_OUTBOUND_ASSET">E_NOT_ENOUGH_OUTBOUND_ASSET</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER"></a>

When order not found in book


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER">E_NO_ORDER</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER_BOOK"></a>

When indicated <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> does not exist


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_market_E_NO_ORDER_BOOKS"></a>

When a host does not have an <code><a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a></code>


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOKS">E_NO_ORDER_BOOKS</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_market_E_ORDER_BOOK_EXISTS"></a>

When an order book already exists at given address


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_ORDER_BOOK_EXISTS">E_ORDER_BOOK_EXISTS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_E_POST_OR_ABORT_CROSSED_SPREAD"></a>

When a post-or-abort limit order crosses the spread


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSED_SPREAD">E_POST_OR_ABORT_CROSSED_SPREAD</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_BASE_OVERFLOW"></a>

When limit order size max base fill overflows a <code>u64</code>


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_BASE_OVERFLOW">E_SIZE_BASE_OVERFLOW</a>: u64 = 20;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_QUOTE_OVERFLOW"></a>

When limit order size max quote fill overflows a <code>u64</code>


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_QUOTE_OVERFLOW">E_SIZE_QUOTE_OVERFLOW</a>: u64 = 22;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_TICKS_OVERFLOW"></a>

When limit order size max ticks fill overflows a <code>u64</code>


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_TICKS_OVERFLOW">E_SIZE_TICKS_OVERFLOW</a>: u64 = 21;
</code></pre>



<a name="0xc0deb00c_market_E_TOO_MANY_ORDER_FLAGS"></a>

When a limit order has too many flags


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_TOO_MANY_ORDER_FLAGS">E_TOO_MANY_ORDER_FLAGS</a>: u64 = 19;
</code></pre>



<a name="0xc0deb00c_market_MAX_BID_DEFAULT"></a>

Default value for maximum bid order ID


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_market_MIN_ASK_DEFAULT"></a>

Default value for minimum ask order ID


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_market_SELL"></a>

Sell direction flag


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_SELL">SELL</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_cancel_all_limit_orders_custodian"></a>

## Function `cancel_all_limit_orders_custodian`

Cancel all limit order on behalf of user, via
<code>general_custodian_capability_ref</code>.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_custodian">cancel_all_limit_orders_custodian</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, side: bool, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_custodian">cancel_all_limit_orders_custodian</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(
        <a href="user.md#0xc0deb00c_user">user</a>,
        host,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        side
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order_custodian"></a>

## Function `cancel_limit_order_custodian`

Cancel a limit order on behalf of user, via
<code>general_custodian_capability_ref</code>.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_custodian">cancel_limit_order_custodian</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_custodian">cancel_limit_order_custodian</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(
        <a href="user.md#0xc0deb00c_user">user</a>,
        host,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_custodian"></a>

## Function `place_limit_order_custodian`

Place a limit order on behalf of user, via
<code>general_custodian_capability_ref</code>.

See wrapped function <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, side: bool, size: u64, price: u64, post_or_abort: bool, fill_or_abort: bool, immediate_or_cancel: bool, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    size: u64,
    price: u64,
    post_or_abort: bool,
    fill_or_abort: bool,
    immediate_or_cancel: bool,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;
        BaseType,
        QuoteType
    &gt;(
        &<a href="user.md#0xc0deb00c_user">user</a>,
        &host,
        &market_id,
        &<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        &side,
        &size,
        &price,
        &post_or_abort,
        &fill_or_abort,
        &immediate_or_cancel
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_market_order_custodian"></a>

## Function `place_market_order_custodian`

Place a market order from a market account, on behalf of a user,
via <code>general_custodian_capability_ref</code>.

See wrapped function <code>place_market_order_order()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, general_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    general_custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;
        BaseType,
        QuoteType
    &gt;(
        &<a href="user.md#0xc0deb00c_user">user</a>,
        &host,
        &market_id,
        &<a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(general_custodian_capability_ref),
        &direction,
        &min_base,
        &max_base,
        &min_quote,
        &max_quote,
        &limit_price
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_swap_coins"></a>

## Function `swap_coins`

Swap between coins of <code>BaseCoinType</code> and <code>QuoteCoinType</code>.


<a name="@Type_parameters_1"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_2"></a>

### Parameters

* <code>host</code>: Market host
* <code>market_id</code>: Market ID
* <code>direction</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_base</code>: Minimum number of base coins to fill
* <code>max_base</code>: Maximum number of base coins to fill
* <code>min_quote</code>: Minimum number of quote coins to fill
* <code>max_quote</code>: Maximum number of quote coins to fill
* <code>limit_price</code>: Maximum price to match against if <code>direction</code>
is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and minimum price to match against if <code>direction</code> is
<code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>. If passed as <code><a href="market.md#0xc0deb00c_market_HI_64">HI_64</a></code> in the case of a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>0</code> in
the case of a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>, will match at any price. Price for a
given market is the number of ticks per lot.
* <code>base_coins_ref_mut</code>: Mutable reference to base coins on hand
before swap. Incremented if a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and decremented if a
<code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>.
* <code>quote_coins_ref_mut</code>: Mutable reference to quote coins on
hand before swap. Incremented if a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>, and decremented if
a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>.


<a name="@Returns_3"></a>

### Returns

* <code>u64</code>: Base coins filled
* <code>u64</code>: Quote coins filled


<a name="@Abort_conditions_4"></a>

### Abort conditions



<a name="@If_a_<code><a_href="market.md#0xc0deb00c_market_BUY">BUY</a></code>_5"></a>

#### If a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>

* If quote coins on hand is less than <code>max_quote</code>
* If filling <code>max_base</code> would overflow base coins on hand


<a name="@If_a_<code><a_href="market.md#0xc0deb00c_market_SELL">SELL</a></code>_6"></a>

#### If a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>

* If base coins on hand is less than <code>max_base</code>
* If filling <code>max_quote</code> would overflow quote coins on hand


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>&lt;BaseCoinType, QuoteCoinType&gt;(host: <b>address</b>, market_id: u64, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;BaseCoinType&gt;, quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;QuoteCoinType&gt;): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>&lt;
    BaseCoinType,
    QuoteCoinType
&gt;(
    host: <b>address</b>,
    market_id: u64,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    base_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;BaseCoinType&gt;,
    quote_coins_ref_mut: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;QuoteCoinType&gt;
): (
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Get value of base coins on hand
    <b>let</b> base_value = <a href="_value">coin::value</a>(base_coins_ref_mut);
    // Get value of quote coins on hand
    <b>let</b> quote_value = <a href="_value">coin::value</a>(quote_coins_ref_mut);
    // Range check fill amounts
    <a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>(&direction, &min_base, &max_base, &min_quote,
        &max_quote, &base_value, &base_value, &quote_value, &quote_value);
    // Get <a href="">option</a>-wrapped base and quote coins for matching engine
    <b>let</b> (optional_base_coins, optional_quote_coins) =
        <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) ( // If buying base <b>with</b> quote
            // Start <b>with</b> 0 base coins
            <a href="_some">option::some</a>(<a href="_zero">coin::zero</a>&lt;BaseCoinType&gt;()),
            // Start <b>with</b> max quote coins needed for trade
            <a href="_some">option::some</a>(<a href="_extract">coin::extract</a>(quote_coins_ref_mut, max_quote))
        ) <b>else</b> ( // If selling base for quote
            // Start <b>with</b> max base coins needed for trade
            <a href="_some">option::some</a>(<a href="_extract">coin::extract</a>(base_coins_ref_mut, max_base)),
            // Start <b>with</b> 0 quote coins
            <a href="_some">option::some</a>(<a href="_zero">coin::zero</a>&lt;QuoteCoinType&gt;())
        );
    // Declare tracker variables for amount of base and quote filled
    <b>let</b> (base_filled, quote_filled) = (0, 0);
    // Swap against order book
    <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;BaseCoinType, QuoteCoinType&gt;(&host, &market_id, &direction,
        &min_base, &max_base, &min_quote, &max_quote, &limit_price,
        &<b>mut</b> optional_base_coins, &<b>mut</b> optional_quote_coins,
        &<b>mut</b> base_filled, &<b>mut</b> quote_filled, &<a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>);
    <a href="_merge">coin::merge</a>( // Merge <b>post</b>-match base coins into coins on hand
        base_coins_ref_mut, <a href="_destroy_some">option::destroy_some</a>(optional_base_coins));
    <a href="_merge">coin::merge</a>( // Merge <b>post</b>-match quote coins into coins on hand
        quote_coins_ref_mut, <a href="_destroy_some">option::destroy_some</a>(optional_quote_coins));
    // Return count for base coins and quote coins filled
    (base_filled, quote_filled)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_swap_generic"></a>

## Function `swap_generic`

Swap between assets where at least one is not a coin type.


<a name="@Type_parameters_7"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_8"></a>

### Parameters

* <code>host</code>: Market host
* <code>market_id</code>: Market ID
* <code>direction</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_base</code>: Minimum number of base coins to fill
* <code>max_base</code>: Maximum number of base coins to fill
* <code>min_quote</code>: Minimum number of quote coins to fill
* <code>max_quote</code>: Maximum number of quote coins to fill
* <code>limit_price</code>: Maximum price to match against if <code>direction</code>
is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and minimum price to match against if <code>direction</code> is
<code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>. If passed as <code><a href="market.md#0xc0deb00c_market_HI_64">HI_64</a></code> in the case of a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>0</code> in
the case of a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>, will match at any price. Price for a
given market is the number of ticks per lot.
* <code>optional_base_coins_ref_mut</code>: If base is a coin type, coins
wrapped in an option, else an empty option
* <code>optional_quote_coins_ref_mut</code>: If quote is a coin type, coins
wrapped in an option, else an empty option
* <code>generic_asset_transfer_custodian_capability_ref</code>: Immutable
reference to generic asset transfer <code>CustodianCapability</code> for
given market


<a name="@Returns_9"></a>

### Returns

* <code>u64</code>: Base assets filled
* <code>u64</code>: Quote assets filled


<a name="@Abort_conditions_10"></a>

### Abort conditions

* If base and quote assets are both coin types
* If base is a coin type but base coin option is none, or if
base is not a coin type but base coin option is some (the
second condition should be impossible, since a coin resource
cannot be generated from a non-coin coin type)
* If quote is a coin type but quote coin option is none, or if
quote is not a coin type but quote coin option is some (the
second condition should be impossible, since a coin resource
cannot be generated from a non-coin coin type)
* If <code>generic_asset_transfer_custodian_capability_ref</code> does not
indicate generic asset transfer custodian for given market,
per inner function <code><a href="market.md#0xc0deb00c_market_swap">swap</a>()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>&lt;BaseType, QuoteType&gt;(host: <b>address</b>, market_id: u64, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;, generic_asset_transfer_custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: <b>address</b>,
    market_id: u64,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;,
    generic_asset_transfer_custodian_capability_ref: &CustodianCapability
): (
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Determine <b>if</b> base is <a href="">coin</a> type
    <b>let</b> base_is_coin = <a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;BaseType&gt;();
    // Determine <b>if</b> quote is <a href="">coin</a> type
    <b>let</b> quote_is_coin = <a href="_is_coin_initialized">coin::is_coin_initialized</a>&lt;QuoteType&gt;();
    // Assert that base and quote <a href="assets.md#0xc0deb00c_assets">assets</a> are not both coins
    <b>assert</b>!(!(base_is_coin && quote_is_coin), <a href="market.md#0xc0deb00c_market_E_BOTH_COINS">E_BOTH_COINS</a>);
    // Assert that <b>if</b> base is <a href="">coin</a> then <a href="">option</a> is some, and that <b>if</b>
    // base is not <a href="">coin</a> then <a href="">option</a> is none
    <b>assert</b>!(base_is_coin == <a href="_is_some">option::is_some</a>(optional_base_coins_ref_mut),
        <a href="market.md#0xc0deb00c_market_E_INVALID_OPTION_BASE">E_INVALID_OPTION_BASE</a>);
    // Assert that <b>if</b> quote is <a href="">coin</a> then <a href="">option</a> is some, and that <b>if</b>
    // quote is not <a href="">coin</a> then <a href="">option</a> is none
    <b>assert</b>!(quote_is_coin == <a href="_is_some">option::is_some</a>(optional_quote_coins_ref_mut),
        <a href="market.md#0xc0deb00c_market_E_INVALID_OPTION_QUOTE">E_INVALID_OPTION_QUOTE</a>);
    <b>let</b> base_value = <b>if</b> (base_is_coin) // If base is a <a href="">coin</a>
        // Base value is the value of <a href="">option</a>-wrapped coins
        <a href="_value">coin::value</a>(<a href="_borrow">option::borrow</a>(optional_base_coins_ref_mut)) <b>else</b>
        // Else base value is 0 for a buy and max amount for sell
        <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) 0 <b>else</b> max_base;
    <b>let</b> quote_value = <b>if</b> (quote_is_coin) // If quote is a <a href="">coin</a>
        // Quote value is the value of <a href="">option</a>-wrapped coins
        <a href="_value">coin::value</a>(<a href="_borrow">option::borrow</a>(optional_quote_coins_ref_mut)) <b>else</b>
        // Else quote value is max for a buy and 0 for sell
        <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) max_quote <b>else</b> 0;
    // Range check fill amounts
    <a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>(&direction, &min_base, &max_base, &min_quote,
        &max_quote, &base_value, &base_value, &quote_value, &quote_value);
    // Declare tracker variables for amount of base and quote filled
    <b>let</b> (base_filled, quote_filled) = (0, 0);
    // Get generic asset transfer custodian ID
    <b>let</b> generic_asset_transfer_custodian_id = <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(
        generic_asset_transfer_custodian_capability_ref);
    // Swap against order book
    <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;BaseType, QuoteType&gt;(&host, &market_id, &direction, &min_base,
        &max_base, &min_quote, &max_quote, &limit_price,
        optional_base_coins_ref_mut, optional_quote_coins_ref_mut,
        &<b>mut</b> base_filled, &<b>mut</b> quote_filled,
        &generic_asset_transfer_custodian_id);
    // Return count for base coins and quote coins filled
    (base_filled, quote_filled)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_all_limit_orders_user"></a>

## Function `cancel_all_limit_orders_user`

Cancel all limit orders as a signing user.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_user">cancel_all_limit_orders_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, side: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders_user">cancel_all_limit_orders_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        host,
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order_user"></a>

## Function `cancel_limit_order_user`

Cancel a limit order as a signing user.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_user">cancel_limit_order_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order_user">cancel_limit_order_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        host,
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
        <a href="order_id.md#0xc0deb00c_order_id">order_id</a>
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_user"></a>

## Function `place_limit_order_user`

Place a limit order as a signing user.

See wrapped function <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, side: bool, size: u64, price: u64, post_or_abort: bool, fill_or_abort: bool, immediate_or_cancel: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    side: bool,
    size: u64,
    price: u64,
    post_or_abort: bool,
    fill_or_abort: bool,
    immediate_or_cancel: bool
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;
        BaseType,
        QuoteType
    &gt;(
        &address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        &host,
        &market_id,
        &<a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        &side,
        &size,
        &price,
        &post_or_abort,
        &fill_or_abort,
        &immediate_or_cancel
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_market_order_user"></a>

## Function `place_market_order_user`

Place a market order from a market account, as a signing user.

See wrapped function <code>place_market_order_order()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;
        BaseType,
        QuoteType
    &gt;(
        &address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        &host,
        &market_id,
        &<a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        &direction,
        &min_base,
        &max_base,
        &min_quote,
        &max_quote,
        &limit_price
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market_generic"></a>

## Function `register_market_generic`

Register a market having at least one asset that is not a coin
type, which requires the authority of custodian indicated by
<code>generic_asset_transfer_custodian_id_ref</code> to verify deposits
and withdrawals of non-coin assets.

See wrapped function <code><a href="market.md#0xc0deb00c_market_register_market">register_market</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_generic">register_market_generic</a>&lt;BaseType, QuoteType&gt;(host: &<a href="">signer</a>, lot_size: u64, tick_size: u64, generic_asset_transfer_custodian_id_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_generic">register_market_generic</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
    generic_asset_transfer_custodian_id_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseType, QuoteType&gt;(
        host,
        lot_size,
        tick_size,
        <a href="registry.md#0xc0deb00c_registry_custodian_id">registry::custodian_id</a>(generic_asset_transfer_custodian_id_ref)
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market_pure_coin"></a>

## Function `register_market_pure_coin`

Register a market for both base and quote assets as coin types.

See wrapped function <code><a href="market.md#0xc0deb00c_market_register_market">register_market</a>()</code>.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_pure_coin">register_market_pure_coin</a>&lt;BaseCoinType, QuoteCoinType&gt;(host: &<a href="">signer</a>, lot_size: u64, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_pure_coin">register_market_pure_coin</a>&lt;
    BaseCoinType,
    QuoteCoinType
&gt;(
    host: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseCoinType, QuoteCoinType&gt;(
        host,
        lot_size,
        tick_size,
        <a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_market_swap_between_coinstores"></a>

## Function `swap_between_coinstores`

Swap between a <code><a href="user.md#0xc0deb00c_user">user</a></code>'s <code>aptos_framework::coin::CoinStore</code>s.

Initialize a <code>CoinStore</code> is a user does not already have one.


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>&lt;BaseCoinType, QuoteCoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, host: <b>address</b>, market_id: u64, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>&lt;
    BaseCoinType,
    QuoteCoinType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    host: <b>address</b>,
    market_id: u64,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a> <b>address</b>
    // Register base <a href="">coin</a> store <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> does not have one
    <b>if</b> (!<a href="_is_account_registered">coin::is_account_registered</a>&lt;BaseCoinType&gt;(user_address))
        <a href="_register">coin::register</a>&lt;BaseCoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>);
    // Register quote <a href="">coin</a> store <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> does not have one
    <b>if</b> (!<a href="_is_account_registered">coin::is_account_registered</a>&lt;QuoteCoinType&gt;(user_address))
        <a href="_register">coin::register</a>&lt;QuoteCoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>);
    // Get value of base coins on hand
    <b>let</b> base_value = <a href="_balance">coin::balance</a>&lt;BaseCoinType&gt;(user_address);
    // Get value of quote coins on hand
    <b>let</b> quote_value = <a href="_balance">coin::balance</a>&lt;QuoteCoinType&gt;(user_address);
    // Range check fill amounts
    <a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>(&direction, &min_base, &max_base, &min_quote,
        &max_quote, &base_value, &base_value, &quote_value, &quote_value);
    // Get <a href="">option</a>-wrapped base and quote coins for matching engine
    <b>let</b> (optional_base_coins, optional_quote_coins) =
        <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) ( // If buying base <b>with</b> quote
            // Start <b>with</b> 0 base coins
            <a href="_some">option::some</a>(<a href="_zero">coin::zero</a>&lt;BaseCoinType&gt;()),
            // Start <b>with</b> max quote coins needed for trade
            <a href="_some">option::some</a>(<a href="_withdraw">coin::withdraw</a>&lt;QuoteCoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, max_quote))
        ) <b>else</b> ( // If selling base for quote
            // Start <b>with</b> max base coins needed for trade
            <a href="_some">option::some</a>(<a href="_withdraw">coin::withdraw</a>&lt;BaseCoinType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, max_base)),
            // Start <b>with</b> 0 quote coins
            <a href="_some">option::some</a>(<a href="_zero">coin::zero</a>&lt;QuoteCoinType&gt;())
        );
    // Declare tracker variables for amount of base and quote
    // filled, needed for function call but dropped later
    <b>let</b> (base_filled_drop, quote_filled_drop) = (0, 0);
    // Swap against order book
    <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;BaseCoinType, QuoteCoinType&gt;(&host, &market_id, &direction,
        &min_base, &max_base, &min_quote, &max_quote, &limit_price,
        &<b>mut</b> optional_base_coins, &<b>mut</b> optional_quote_coins,
        &<b>mut</b> base_filled_drop, &<b>mut</b> quote_filled_drop, &<a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a>);
    <a href="_deposit">coin::deposit</a>( // Deposit base coins back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="">coin</a> store
        user_address, <a href="_destroy_some">option::destroy_some</a>(optional_base_coins));
    <a href="_deposit">coin::deposit</a>( // Deposit quote coins back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="">coin</a> store
        user_address, <a href="_destroy_some">option::destroy_some</a>(optional_quote_coins));
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_all_limit_orders"></a>

## Function `cancel_all_limit_orders`

Cancel all of a user's limit orders on the book, and remove from
their market account, silently returning if they have no open
orders.

See wrapped function <code><a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>()</code>.


<a name="@Parameters_11"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user cancelling order
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>market_id</code>: Market ID
* <code>general_custodian_id</code>: General custodian ID for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>


<a name="@Assumes_12"></a>

### Assumes

* That <code>get_n_orders_internal()</code> aborts if no corresponding user
orders tree available to cancel from


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, general_custodian_id: u64, side: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_limit_orders">cancel_all_limit_orders</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    side: bool,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(market_id,
        general_custodian_id); // Get <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> n_orders = // Get number of orders on given side
        <a href="user.md#0xc0deb00c_user_get_n_orders_internal">user::get_n_orders_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, side);
    <b>while</b> (n_orders &gt; 0) { // While <a href="user.md#0xc0deb00c_user">user</a> <b>has</b> open orders
        // Get order ID of order nearest the spread
        <b>let</b> order_id_nearest_spread =
            <a href="user.md#0xc0deb00c_user_get_order_id_nearest_spread_internal">user::get_order_id_nearest_spread_internal</a>(
                <a href="user.md#0xc0deb00c_user">user</a>, market_account_id, side);
        // Cancel the order
        <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(<a href="user.md#0xc0deb00c_user">user</a>, host, market_id, general_custodian_id,
            side, order_id_nearest_spread);
        n_orders = n_orders - 1; // Decrement order count
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_market_cancel_limit_order"></a>

## Function `cancel_limit_order`

Cancel limit order on book, remove from user's market account.


<a name="@Parameters_13"></a>

### Parameters

* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user cancelling order
* <code>host</code>: Where corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> is hosted
* <code>market_id</code>: Market ID
* <code>general_custodian_id</code>: General custodian ID for <code><a href="user.md#0xc0deb00c_user">user</a></code>'s
market account
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>


<a name="@Abort_conditions_14"></a>

### Abort conditions

* If the specified <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code> is not on given <code>side</code> for
corresponding <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* If <code><a href="user.md#0xc0deb00c_user">user</a></code> is not the user who placed the order with the
corresponding <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>
* If <code>custodian_id</code> is not the same as that indicated on order
with the corresponding <code><a href="order_id.md#0xc0deb00c_order_id">order_id</a></code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, host: <b>address</b>, market_id: u64, general_custodian_id: u64, side: bool, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_limit_order">cancel_limit_order</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    host: <b>address</b>,
    market_id: u64,
    general_custodian_id: u64,
    side: bool,
    <a href="order_id.md#0xc0deb00c_order_id">order_id</a>: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Verify order book <b>exists</b>
    <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(host, market_id);
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host).map;
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Get mutable reference <b>to</b> orders tree for corresponding side
    <b>let</b> tree_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks <b>else</b>
        &<b>mut</b> order_book_ref_mut.bids;
    // Assert order is on book
    <b>assert</b>!(<a href="critbit.md#0xc0deb00c_critbit_has_key">critbit::has_key</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>), <a href="market.md#0xc0deb00c_market_E_NO_ORDER">E_NO_ORDER</a>);
    <b>let</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>{ // Pop and unpack order from book,
        size: _, // Drop size count
        <a href="user.md#0xc0deb00c_user">user</a>: order_user, // Save indicated <a href="user.md#0xc0deb00c_user">user</a> for checking later
        // Save indicated general custodian ID for checking later
        general_custodian_id: order_general_custodian_id
    } = <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
    // Assert <a href="user.md#0xc0deb00c_user">user</a> attempting <b>to</b> cancel is <a href="user.md#0xc0deb00c_user">user</a> on order
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user">user</a> == order_user, <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>);
    // Assert custodian attempting <b>to</b> cancel is custodian on order
    <b>assert</b>!(general_custodian_id == order_general_custodian_id,
        <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    // If cancelling an ask that was previously the spread maker
    <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a> && <a href="order_id.md#0xc0deb00c_order_id">order_id</a> == order_book_ref_mut.min_ask) {
        // Update minimum ask <b>to</b> default value <b>if</b> tree is empty
        order_book_ref_mut.min_ask = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref_mut))
            // Else <b>to</b> the minimum ask on the book
            <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b> <a href="critbit.md#0xc0deb00c_critbit_min_key">critbit::min_key</a>(tree_ref_mut);
    // Else <b>if</b> cancelling a bid that was previously the spread maker
    } <b>else</b> <b>if</b> (side == <a href="market.md#0xc0deb00c_market_BID">BID</a> && <a href="order_id.md#0xc0deb00c_order_id">order_id</a> == order_book_ref_mut.max_bid) {
        // Update maximum bid <b>to</b> default value <b>if</b> tree is empty
        order_book_ref_mut.max_bid = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref_mut))
            // Else <b>to</b> the maximum bid on the book
            <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a> <b>else</b> <a href="critbit.md#0xc0deb00c_critbit_max_key">critbit::max_key</a>(tree_ref_mut);
    };
    // Get <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID, lot size, and tick size for order
    <b>let</b> (market_account_id, lot_size, tick_size) = (
        <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(market_id, general_custodian_id),
        order_book_ref_mut.lot_size,
        order_book_ref_mut.tick_size);
    // Remove order from corresponding <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_remove_order_internal">user::remove_order_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_account_id, lot_size,
        tick_size, side, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_get_counter"></a>

## Function `get_counter`

Increment counter for number of orders placed on <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>,
returning the original value.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_counter">get_counter</a>(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_get_counter">get_counter</a>(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>
): u64 {
    // Borrow mutable reference <b>to</b> order book serial counter
    <b>let</b> counter_ref_mut = &<b>mut</b> order_book_ref_mut.counter;
    <b>let</b> count = *counter_ref_mut; // Get count
    *counter_ref_mut = count + 1; // Set new count
    count // Return original count
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match"></a>

## Function `match`

Match an incoming order against the order book.

Range check arguments, initialize local variables, verify that
loopwise matching can proceed, then match against the orders
tree in a loopwise traversal. Verify fill amounts afterwards.

Silently returns if no fills possible.

Institutes pass-by-reference for enhanced efficiency.


<a name="@Type_parameters_15"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_16"></a>

### Parameters

* <code>market_id_ref</code>: Immutable reference to market ID
* <code>order_book_ref_mut</code>: Mutable reference to corresponding
<code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_lots_ref</code>: Immutable reference to minimum number of lots
to fill
* <code>max_lots_ref</code>: Immutable reference to maximum number of lots
to fill
* <code>min_ticks_ref</code>: Immutable reference to minimum number of
ticks to fill
* <code>max_ticks_ref</code>: Immutable reference to maximum number of
ticks to fill
* <code>limit_price_ref</code>: Immutable reference to maximum price to
match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and minimum price
to match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine, gradually
incremented in the case of <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and gradually decremented
in the case of <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine, gradually
decremented in the case of <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and gradually incremented
in the case of <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>lots_filled_ref_mut</code>: Mutable reference to counter for number
of lots filled by matching engine
* <code>ticks_filled_ref_mut</code>: Mutable reference to counter for
number of ticks filled by matching engine


<a name="@Assumes_17"></a>

### Assumes

* That if optional coins are passed, they contain sufficient
amounts for matching in accordance with other specified values
* That <code>lot_size_ref</code> and <code>tick_size_ref</code> indicate the same
lot and tick size as <code>order_book_ref_mut</code>
* That min/max fill amounts have been checked via
<code><a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>()</code>


<a name="@Checks_not_performed_18"></a>

### Checks not performed

* Does not enforce that limit price is nonzero, as a limit price
of zero is effectively a flag to sell at any price.
* Does not enforce that max fill amounts are nonzero, as the
matching engine simply returns silently before overfilling


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match">match</a>&lt;BaseType, QuoteType&gt;(market_id_ref: &u64, order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, lot_size_ref: &u64, tick_size_ref: &u64, direction_ref: &bool, min_lots_ref: &u64, max_lots_ref: &u64, min_ticks_ref: &u64, max_ticks_ref: &u64, limit_price_ref: &u64, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;, lots_filled_ref_mut: &<b>mut</b> u64, ticks_filled_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match">match</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id_ref: &u64,
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    direction_ref: &bool,
    min_lots_ref: &u64,
    max_lots_ref: &u64,
    min_ticks_ref: &u64,
    max_ticks_ref: &u64,
    limit_price_ref: &u64,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;,
    lots_filled_ref_mut: &<b>mut</b> u64,
    ticks_filled_ref_mut: &<b>mut</b> u64
) {
    // Initialize variables, check types
    <b>let</b> (lots_until_max, ticks_until_max, side, tree_ref_mut,
         spread_maker_ref_mut, n_orders, traversal_direction) =
            <a href="market.md#0xc0deb00c_market_match_init">match_init</a>&lt;BaseType, QuoteType&gt;(order_book_ref_mut,
                direction_ref, max_lots_ref, max_ticks_ref);
    <b>if</b> (n_orders != 0) { // If orders tree <b>has</b> orders <b>to</b> match
        // Match them via loopwise iterated traversal
        <a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>&lt;BaseType, QuoteType&gt;(market_id_ref, tree_ref_mut,
            &side, lot_size_ref, tick_size_ref, &<b>mut</b> lots_until_max,
            &<b>mut</b> ticks_until_max, limit_price_ref, &<b>mut</b> n_orders,
            spread_maker_ref_mut, &traversal_direction,
            optional_base_coins_ref_mut, optional_quote_coins_ref_mut);
    };
    // Verify fill amounts, compute final threshold allowance counts
    <a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>(min_lots_ref, max_lots_ref, min_ticks_ref,
        max_ticks_ref, &lots_until_max, &ticks_until_max,
        lots_filled_ref_mut, ticks_filled_ref_mut);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_from_market_account"></a>

## Function `match_from_market_account`

Match against the book from a user's market account.

Verify user has sufficient assets in their market account,
withdraw enough to meet range-checked min/max fill requirements,
match against the book, then deposit back to user's market
account.

Institutes pass-by-reference for enhanced efficiency.


<a name="@Type_parameters_19"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_20"></a>

### Parameters

* <code>user_ref</code>: Immutable reference to user's address
* <code>market_account_id_ref</code>: Immutable reference to user's
corresponding market account ID
* <code>market_id_ref</code>: Immutable reference to market ID
* <code>order_book_ref_mut</code>: Mutable reference to corresponding
<code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_base_ref</code>: Immutable reference to minimum number of base
units to fill
* <code>max_base_ref</code>: Immutable reference to maximum number of base
units to fill
* <code>min_quote_ref</code>: Immutable reference to minimum number of
quote units to fill
* <code>max_quote_ref</code>: Immutable reference to maximum number of
quote units to fill
* <code>limit_price_ref</code>: Immutable reference to maximum price to
match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and minimum price
to match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>. If passed as
<code><a href="market.md#0xc0deb00c_market_HI_64">HI_64</a></code> in the case of a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>0</code> in the case of a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>,
will match at any price. Price for a given market is the
number of ticks per lot.
* <code>lots_filled_ref_mut</code>: Mutable reference to number of lots
matched against book


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>&lt;BaseType, QuoteType&gt;(user_ref: &<b>address</b>, market_account_id_ref: &u128, market_id_ref: &u64, order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, direction_ref: &bool, min_base_ref: &u64, max_base_ref: &u64, min_quote_ref: &u64, max_quote_ref: &u64, limit_price_ref: &u64, lots_filled_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>&lt;
    BaseType,
    QuoteType
&gt;(
    user_ref: &<b>address</b>,
    market_account_id_ref: &u128,
    market_id_ref: &u64,
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    direction_ref: &bool,
    min_base_ref: &u64,
    max_base_ref: &u64,
    min_quote_ref: &u64,
    max_quote_ref: &u64,
    limit_price_ref: &u64,
    lots_filled_ref_mut: &<b>mut</b> u64
) {
    <b>let</b> lot_size = order_book_ref_mut.lot_size; // Get lot size
    <b>let</b> tick_size = order_book_ref_mut.tick_size; // Get tick size
    // Get <a href="user.md#0xc0deb00c_user">user</a>'s available and ceiling asset counts
    <b>let</b> (_, base_available, base_ceiling, _, quote_available,
         quote_ceiling) = <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">user::get_asset_counts_internal</a>(*user_ref,
            *market_account_id_ref);
    // Range check fill amounts
    <a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>(direction_ref, min_base_ref, max_base_ref,
        min_quote_ref, max_quote_ref, &base_available, &base_ceiling,
        &quote_available, &quote_ceiling);
    // Calculate base and quote <b>to</b> withdraw from <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <b>let</b> (base_to_withdraw, quote_to_withdraw) = <b>if</b> (*direction_ref == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        // If a buy, buy base <b>with</b> quote, so need max quote on hand
        // If a sell, sell base for quote, so need max base on hand
        (0, *max_quote_ref) <b>else</b> (*max_base_ref, 0);
    // Withdraw base and quote <a href="assets.md#0xc0deb00c_assets">assets</a> from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    // <b>as</b> optional coins
    <b>let</b> (optional_base_coins, optional_quote_coins) =
        <a href="user.md#0xc0deb00c_user_withdraw_assets_as_option_internal">user::withdraw_assets_as_option_internal</a>&lt;BaseType, QuoteType&gt;(
            *user_ref, *market_account_id_ref, base_to_withdraw,
            quote_to_withdraw, order_book_ref_mut.
            generic_asset_transfer_custodian_id);
    <b>let</b> ticks_filled = 0; // Declare tracker for ticks filled
    // Match against order book
    <a href="market.md#0xc0deb00c_market_match">match</a>&lt;BaseType, QuoteType&gt;(market_id_ref, order_book_ref_mut,
        &lot_size, &tick_size, direction_ref,
        &(*min_base_ref / lot_size), &(*max_base_ref / lot_size),
        &(*min_quote_ref / tick_size), &(*max_quote_ref / tick_size),
        limit_price_ref, &<b>mut</b> optional_base_coins,
        &<b>mut</b> optional_quote_coins, lots_filled_ref_mut, &<b>mut</b> ticks_filled);
    // Calculate <b>post</b>-match base and quote <a href="assets.md#0xc0deb00c_assets">assets</a> on hand
    <b>let</b> (base_on_hand, quote_on_hand) = <b>if</b> (*direction_ref == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) (
        *lots_filled_ref_mut * lot_size, // If a buy, lots received
        // Ticks traded away
        *max_quote_ref - (ticks_filled * tick_size)
    ) <b>else</b> ( // If a sell
        // Lots traded away
        *max_base_ref - (*lots_filled_ref_mut * lot_size),
        ticks_filled * tick_size // Ticks received
    );
    // Deposit <a href="assets.md#0xc0deb00c_assets">assets</a> on hand back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_deposit_assets_as_option_internal">user::deposit_assets_as_option_internal</a>&lt;BaseType, QuoteType&gt;(
        *user_ref, *market_account_id_ref, base_on_hand, quote_on_hand,
        optional_base_coins, optional_quote_coins, order_book_ref_mut.
        generic_asset_transfer_custodian_id);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_init"></a>

## Function `match_init`

Initialize local variables for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, verify types.

Must determine orders tree based on a conditional check on
<code>direction_ref</code> in order for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code> to check that there are
even orders to fill against, hence evaluates other side-wise
variables in ternary operator (even though some of these could
be evaluated later on in <code><a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>()</code>) such that matching
initialization only requires one side-wise conditional check.

Additionally, lots and ticks until max counters are additionally
initialized here rather than in <code><a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>()</code> so they can
be passed by reference and then verified within the local scope
of <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, via <code><a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>()</code>.


<a name="@Type_parameters_21"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_22"></a>

### Parameters

* <code>order_book_ref_mut</code>: Mutable reference to corresponding
<code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>max_lots_ref</code>: Immutable reference to maximum number of lots
to fill
* <code>min_lots_ref</code>: Immutable reference to maximum number of ticks
to fill


<a name="@Returns_23"></a>

### Returns

* <code>u64</code>: Counter for remaining lots that can be filled before
exceeding maximum allowed
* <code>u64</code>: Counter for remaining ticks that can be filled before
exceeding maximum allowed
* <code>bool</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code> corresponding to <code>direction_ref</code>
* <code>&<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>: Mutable reference to orders tree to
fill against
* <code>&<b>mut</b> u128</code>: Mutable reference to spread maker field for given
side
* <code>u64</code>: Number of orders in corresponding tree
* <code>bool</code>: <code><a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code><a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code> (traversal direction) corresponding
to <code>direction_ref</code>


<a name="@Abort_conditions_24"></a>

### Abort conditions

* If <code>BaseType</code>, is not base type for market
* If <code>QuoteType</code> is not quote type for market


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_init">match_init</a>&lt;BaseType, QuoteType&gt;(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, direction_ref: &bool, max_lots_ref: &u64, max_ticks_ref: &u64): (u64, u64, bool, &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, &<b>mut</b> u128, u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_init">match_init</a>&lt;
    BaseType,
    QuoteType
&gt;(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    direction_ref: &bool,
    max_lots_ref: &u64,
    max_ticks_ref: &u64,
): (
    u64,
    u64,
    bool,
    &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    &<b>mut</b> u128,
    u64,
    bool,
) {
    // Assert base type corresponds <b>to</b> that of <a href="market.md#0xc0deb00c_market">market</a>
    <b>assert</b>!(<a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;() ==
        order_book_ref_mut.base_type_info, <a href="market.md#0xc0deb00c_market_E_INVALID_BASE">E_INVALID_BASE</a>);
    // Assert quote type corresponds <b>to</b> that of <a href="market.md#0xc0deb00c_market">market</a>
    <b>assert</b>!(<a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;() ==
        order_book_ref_mut.quote_type_info, <a href="market.md#0xc0deb00c_market_E_INVALID_QUOTE">E_INVALID_QUOTE</a>);
    // Get side that order fills against, mutable reference <b>to</b>
    // orders tree <b>to</b> fill against, mutable reference <b>to</b> the spread
    // maker for given side, and traversal direction
    <b>let</b> (side, tree_ref_mut, spread_maker_ref_mut, traversal_direction) =
        <b>if</b> (*direction_ref == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) (
        <a href="market.md#0xc0deb00c_market_ASK">ASK</a>, // If a buy, fills against asks
        &<b>mut</b> order_book_ref_mut.asks, // Fill against asks tree
        &<b>mut</b> order_book_ref_mut.min_ask, // Asks spread maker
        <a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a> // Successor iteration
    ) <b>else</b> ( // If a sell
        <a href="market.md#0xc0deb00c_market_BID">BID</a>, // Fills against bids, <b>requires</b> base coins
        &<b>mut</b> order_book_ref_mut.bids, // Fill against bids tree
        &<b>mut</b> order_book_ref_mut.max_bid, // Bids spread maker
        <a href="market.md#0xc0deb00c_market_LEFT">LEFT</a> // Predecessor iteration
    );
    // Get number of orders in corresponding tree
    <b>let</b> n_orders = <a href="critbit.md#0xc0deb00c_critbit_length">critbit::length</a>(tree_ref_mut);
    (
        *max_lots_ref,
        *max_ticks_ref,
        side,
        tree_ref_mut,
        spread_maker_ref_mut,
        n_orders,
        traversal_direction
    )
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop"></a>

## Function `match_loop`

Match an order against the book via loopwise tree traversal.

Inner function for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.

During iterated traversal, the "incoming user" matches against
a "target order" on the book at each iteration.


<a name="@Type_parameters_25"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_26"></a>

### Parameters

* <code>market_id_ref</code>: Immutable reference to market ID
* <code>tree_ref_mut</code>: Mutable reference to orders tree
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>lots_until_max_ref_mut</code>: Mutable reference to counter for
number of lots that can be filled before exceeding max
allowed for incoming user
* <code>ticks_until_max_ref_mut</code>: Mutable reference to counter
for number of ticks that can be filled before exceeding max
allowed for incoming user
* <code>limit_price_ref</code>: Immutable reference to max price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>, and min price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>n_orders_ref_mut</code>: Mutable reference to counter for number of
orders in tree
* <code>spread_maker_ref_mut</code>: Mutable reference to the spread maker
field for corresponding side
* <code>traversal_direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code>, or <code>&<a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine


<a name="@Passing_considerations_27"></a>

### Passing considerations

* Pass-by-reference instituted for improved efficiency
* See <code><a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>()</code> for a discussion on its
return schema


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>&lt;BaseType, QuoteType&gt;(market_id_ref: &u64, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, side_ref: &bool, lot_size_ref: &u64, tick_size_ref: &u64, lots_until_max_ref_mut: &<b>mut</b> u64, ticks_until_max_ref_mut: &<b>mut</b> u64, limit_price_ref: &u64, n_orders_ref_mut: &<b>mut</b> u64, spread_maker_ref_mut: &<b>mut</b> u128, traversal_direction_ref: &bool, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id_ref: &u64,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    side_ref: &bool,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    lots_until_max_ref_mut: &<b>mut</b> u64,
    ticks_until_max_ref_mut: &<b>mut</b> u64,
    limit_price_ref: &u64,
    n_orders_ref_mut: &<b>mut</b> u64,
    spread_maker_ref_mut: &<b>mut</b> u128,
    traversal_direction_ref: &bool,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;
) {
    // Initialize <b>local</b> variables
    <b>let</b> (target_order_id, target_order_ref_mut, target_parent_index,
         target_child_index, complete_target_fill, should_pop_last,
         new_spread_maker) = <a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>(
            tree_ref_mut, traversal_direction_ref);
    // Declare locally-scoped <b>return</b> variable for below <b>loop</b>, which
    // can not be declared without a value in the above function,
    // and which raises a warning <b>if</b> it is assigned a value within
    // the present scope. It could be declared within the <b>loop</b>
    // scope, but this would involve a re-declaration for each
    // iteration. Hence it is declared here, such that the statement
    // in which it is assigned does not locally re-bind the other
    // variables in the function <b>return</b> tuple, which would occur <b>if</b>
    // they were <b>to</b> be assigned via a `<b>let</b>` expression.
    <b>let</b> should_break;
    <b>loop</b> { // Begin loopwise matching
        // Process the order for current iteration, storing flag for
        // <b>if</b> the target order was completely filled
        <a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>&lt;BaseType, QuoteType&gt;(market_id_ref, side_ref,
            lot_size_ref, tick_size_ref, lots_until_max_ref_mut,
            ticks_until_max_ref_mut, limit_price_ref, &target_order_id,
            target_order_ref_mut, &<b>mut</b> complete_target_fill,
            optional_base_coins_ref_mut, optional_quote_coins_ref_mut);
        // Follow up on order processing, assigning variable returns
        // that cannot be reassigned via pass-by-reference
        (target_order_id, target_order_ref_mut, should_break) =
            <a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>(tree_ref_mut, side_ref,
                traversal_direction_ref, n_orders_ref_mut,
                &complete_target_fill, &<b>mut</b> should_pop_last,
                target_order_id, &<b>mut</b> target_parent_index,
                &<b>mut</b> target_child_index, &<b>mut</b> new_spread_maker);
        <b>if</b> (should_break) { // If should <b>break</b> out of <b>loop</b>
            // Clean up <b>as</b> needed before breaking out of <b>loop</b>
            <a href="market.md#0xc0deb00c_market_match_loop_break">match_loop_break</a>(spread_maker_ref_mut, &new_spread_maker,
                &should_pop_last, tree_ref_mut, &target_order_id);
            <b>break</b> // Break out of <b>loop</b>
        }
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_break"></a>

## Function `match_loop_break`

Execute break cleanup after loopwise matching.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Parameters_28"></a>

### Parameters

* <code>spread_maker_ref_mut</code>: Mutable reference to the spread maker
field for order tree just filled against
* <code>new_spread_maker_ref</code>: Immutable reference to new spread
maker value to assign
* <code>should_pop_last_ref</code>: <code>&<b>true</b></code> if loopwise matching ends on a
complete fill against the last order on the book, which should
be popped off
* <code>tree_ref_mut</code>: Mutable reference to orders tree just matched
against
* <code>final_order_id_ref</code>: If <code>should_pop_last_ref</code> indicates
<code><b>true</b></code>, an immutable reference to the order ID of the last
order in the book, which should be popped


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_break">match_loop_break</a>(spread_maker_ref_mut: &<b>mut</b> u128, new_spread_maker_ref: &u128, should_pop_last_ref: &bool, tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, final_order_id_ref: &u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_break">match_loop_break</a>(
    spread_maker_ref_mut: &<b>mut</b> u128,
    new_spread_maker_ref: &u128,
    should_pop_last_ref: &bool,
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    final_order_id_ref: &u128
) {
    // Update spread maker field
    *spread_maker_ref_mut = *new_spread_maker_ref;
    // Pop and unpack last order on book <b>if</b> flagged <b>to</b> do so
    <b>if</b> (*should_pop_last_ref)
        <a href="market.md#0xc0deb00c_market_Order">Order</a>{size: _, <a href="user.md#0xc0deb00c_user">user</a>: _, general_custodian_id: _} =
            <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, *final_order_id_ref);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_init"></a>

## Function `match_loop_init`

Initialize variables for loopwise matching.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Parameters_29"></a>

### Parameters

* <code>tree_ref_mut</code>: Mutable reference to orders tree to start
match against
* <code>traversal_direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code>, or <code>&<a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>


<a name="@Returns_30"></a>

### Returns

* <code>u128</code>: Order ID of first target order to process
* <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code>: Mutable reference to first target order
* <code>u64</code>: Parent index loop variable for iterated traversal along
outer nodes of a <code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>u64</code>: Child index loop variable for iterated traversal along
outer nodes of a <code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>bool</code>: Flag for if target order is completely filled
* <code>bool</code>: Flag for if loopwise matching ends on a complete fill
against the last order on the book, which should be popped
* <code>u128</code>: Tracker for new spread maker value to assign


<a name="@Passing_considerations_31"></a>

### Passing considerations

* Initialized variables are passed by reference within
<code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>, and as such must be assigned before use
* Variables that are only assigned meaningful values after
pass-by-reference are effectively initialized to null values


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>(tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, traversal_direction_ref: &bool): (u128, &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, u64, u64, bool, bool, u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_init">match_loop_init</a>(
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    traversal_direction_ref: &bool,
): (
    u128,
    &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    u64,
    u64,
    bool,
    bool,
    u128
) {
    // Initialize iterated traversal, storing order ID of target
    // order, mutable reference <b>to</b> target order, the parent field
    // of the target node, and child field index of target node
    <b>let</b> (target_order_id, target_order_ref_mut, target_parent_index,
         target_child_index) = <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">critbit::traverse_init_mut</a>(
            tree_ref_mut, *traversal_direction_ref);
    // Return initialized traversal variables, and flags/tracker
    // that are reassigned later
    (target_order_id, target_order_ref_mut, target_parent_index,
     target_child_index, <b>false</b>, <b>false</b>, 0)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_order"></a>

## Function `match_loop_order`

Fill order from "incoming user" against "target order" on the
book.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Type_parameters_32"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_33"></a>

### Parameters

* <code>market_id_ref</code>: Immutable reference to market ID
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>lots_until_max_ref_mut</code>: Mutable reference to counter for
number of lots that can be filled before exceeding max
allowed for incoming user
* <code>ticks_until_max_ref_mut</code>: Mutable reference to counter
for number of ticks that can be filled before exceeding max
allowed for incoming user
* <code>limit_price_ref</code>: Immutable reference to max price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code>, and min price to match
against if <code>side_ref</code> indicates <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>target_order_id_ref</code>: Immutable reference to target order ID
* <code>target_order_ref_mut</code>: Mutable reference to target order
* <code>complete_target_fill_ref_mut</code>: Mutable reference to flag for
if target order is completely filled
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>&lt;BaseType, QuoteType&gt;(market_id_ref: &u64, side_ref: &bool, lot_size_ref: &u64, tick_size_ref: &u64, lots_until_max_ref_mut: &<b>mut</b> u64, ticks_until_max_ref_mut: &<b>mut</b> u64, limit_price_ref: &u64, target_order_id_ref: &u128, target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, complete_target_fill_ref_mut: &<b>mut</b> bool, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id_ref: &u64,
    side_ref: &bool,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    lots_until_max_ref_mut: &<b>mut</b> u64,
    ticks_until_max_ref_mut: &<b>mut</b> u64,
    limit_price_ref: &u64,
    target_order_id_ref: &u128,
    target_order_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    complete_target_fill_ref_mut: &<b>mut</b> bool,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;
) {
    // Calculate target order price
    <b>let</b> target_order_price = <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(*target_order_id_ref);
    // If ask price is higher than limit price
    <b>if</b> ((*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a> && target_order_price &gt; *limit_price_ref) ||
        // Or <b>if</b> bid price is lower than limit price
        (*side_ref == <a href="market.md#0xc0deb00c_market_BID">BID</a> && target_order_price &lt; *limit_price_ref)) {
            // Flag that there was not a complete target fill
            *complete_target_fill_ref_mut = <b>false</b>;
            <b>return</b> // Do not attempt <b>to</b> fill
        };
    // Declare null fill size for pass-by-reference reassignment
    <b>let</b> fill_size = 0;
    // Calculate size filled and determine <b>if</b> a complete fill
    // against target order
    <a href="market.md#0xc0deb00c_market_match_loop_order_fill_size">match_loop_order_fill_size</a>(lots_until_max_ref_mut,
        ticks_until_max_ref_mut, &target_order_price, target_order_ref_mut,
        &<b>mut</b> fill_size, complete_target_fill_ref_mut);
    <b>if</b> (fill_size == 0) { // If no lots <b>to</b> fill
        // Flag that there was not a complete target fill
        *complete_target_fill_ref_mut = <b>false</b>;
        <b>return</b> // Do not attempt <b>to</b> fill
    };
    // Calculate number of ticks filled
    <b>let</b> ticks_filled = fill_size * target_order_price;
    // Decrement counter for lots until max
    *lots_until_max_ref_mut = *lots_until_max_ref_mut - fill_size;
    // Decrement counter for ticks until max
    *ticks_until_max_ref_mut = *ticks_until_max_ref_mut - ticks_filled;
    // Calculate base and quote units <b>to</b> route
    <b>let</b> (base_to_route, quote_to_route) = (
        fill_size * *lot_size_ref, ticks_filled * *tick_size_ref);
    // Get the target order <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> target_order_market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(
        *market_id_ref, target_order_ref_mut.general_custodian_id);
    // Fill the target order <a href="user.md#0xc0deb00c_user">user</a>-side
    <a href="user.md#0xc0deb00c_user_fill_order_internal">user::fill_order_internal</a>&lt;BaseType, QuoteType&gt;(
        target_order_ref_mut.<a href="user.md#0xc0deb00c_user">user</a>, target_order_market_account_id,
        *side_ref, *target_order_id_ref, *complete_target_fill_ref_mut,
        fill_size, optional_base_coins_ref_mut,
        optional_quote_coins_ref_mut, base_to_route, quote_to_route);
    // Decrement target order size by size filled (should be popped
    // later <b>if</b> completely filled, and so this step is redundant in
    // the case of a complete fill, but adding an extra <b>if</b> statement
    // <b>to</b> check whether or not <b>to</b> decrement would add computational
    // overhead in the case of an incomplete fill)
    target_order_ref_mut.size = target_order_ref_mut.size - fill_size;
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_order_fill_size"></a>

## Function `match_loop_order_fill_size`

Calculate fill size and whether an order on the book is
completely filled during a match. The "incoming user" fills
against the "target order" on the book.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code>.


<a name="@Parameters_34"></a>

### Parameters

* <code>lots_until_max_ref</code>: Immutable reference to counter for
number of lots that can be filled before exceeding max allowed
for incoming user
* <code>ticks_until_max_ref</code>: Immutable reference to counter for
number of ticks that can be filled before exceeding max
allowed for incoming user
* <code>target_order_price_ref</code>: Immutable reference to target order
price
* <code>target_order_ref</code>: Immutable reference to target order
* <code>fill_size_ref_mut</code>: Mutable reference to fill size, in lots
* <code>complete_target_fill_ref_mut</code>: Mutable reference to flag
marked <code><b>true</b></code> if target order is completely filled


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_fill_size">match_loop_order_fill_size</a>(lots_until_max_ref: &u64, ticks_until_max_ref: &u64, target_order_price_ref: &u64, target_order_ref: &<a href="market.md#0xc0deb00c_market_Order">market::Order</a>, fill_size_ref_mut: &<b>mut</b> u64, complete_target_fill_ref_mut: &<b>mut</b> bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_fill_size">match_loop_order_fill_size</a>(
    lots_until_max_ref: &u64,
    ticks_until_max_ref: &u64,
    target_order_price_ref: &u64,
    target_order_ref: &<a href="market.md#0xc0deb00c_market_Order">Order</a>,
    fill_size_ref_mut: &<b>mut</b> u64,
    complete_target_fill_ref_mut: &<b>mut</b> bool
) {
    // Calculate max number of lots that could be filled without
    // exceeding the maximum number of filled ticks: number of lots
    // that incoming <a href="user.md#0xc0deb00c_user">user</a> can afford <b>to</b> buy at target price in the
    // case of a buy, <b>else</b> number of lots that <a href="user.md#0xc0deb00c_user">user</a> could sell at
    // target order price without receiving too many ticks
    <b>let</b> fill_size_tick_limited =
        *ticks_until_max_ref / *target_order_price_ref;
    // Max-limited fill size is the lesser of tick-limited fill size
    // and lot-limited fill size
    <b>let</b> fill_size_max_limited =
        <b>if</b> (fill_size_tick_limited &lt; *lots_until_max_ref)
            fill_size_tick_limited <b>else</b> *lots_until_max_ref;
    // Get fill size and <b>if</b> target order is completely filled
    <b>let</b> (fill_size, complete_target_fill) =
        // If max-limited fill size is less than target order size
        <b>if</b> (fill_size_max_limited &lt; target_order_ref.size)
            // Fill size is max-limited fill size, target order is
            // not completely filled
            (fill_size_max_limited, <b>false</b>) <b>else</b>
            // Otherwise fill size is target order size, and target
            // order is completely filled
            (target_order_ref.size, <b>true</b>);
    // Reassign <b>to</b> passed in references, since cannot reassign
    // <b>to</b> references within ternary operation result tuple above
    *fill_size_ref_mut = fill_size;
    *complete_target_fill_ref_mut = complete_target_fill;
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_loop_order_follow_up"></a>

## Function `match_loop_order_follow_up`

Follow up after processing a fill against an order on the book.

Checks if traversal is still possible, computes new spread maker
value as needed, and determines if loop has hit break condition,
following up on an "incoming user" filling against a "target
order" on the book.

Inner function for <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code>.


<a name="@Parameters_35"></a>

### Parameters

* <code>tree_ref_mut</code>: Mutable reference to orders tree
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>traversal_direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_LEFT">LEFT</a></code> or <code>&<a href="market.md#0xc0deb00c_market_RIGHT">RIGHT</a></code>
* <code>n_orders_ref_mut</code>: Mutable reference to counter for number of
orders in tree, including the target order that was just
processed
* <code>complete_target_fill_ref</code>: <code>&<b>true</b></code> if the target order was
completely filled
* <code>should_pop_last_ref_mut</code>: Reassigned to <code>&<b>true</b></code> if just
processed a complete fill against the last order on the book,
which should be popped
* <code>target_order_id</code>: Order ID of target order just processed
* <code>target_parent_index_ref_mut</code>: Mutable reference to parent
loop variable for iterated traversal along outer nodes of a
<code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>target_child_index_ref_mut</code>: Mutable reference to child loop
variable for iterated traversal along outer nodes of a
<code>CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>
* <code>new_spread_maker_ref_mut</code>: Mutable reference to the value
that should be assigned to the spread maker field for the
side indicated by <code>side_ref</code>, if one should be set


<a name="@Returns_36"></a>

### Returns

* <code>u128</code>: Target order ID, updated from <code>target_order_id</code> if
traversal proceeds to the next order on the book
* <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code>: Mutable reference to next order on the book to
process, only reassigned when iterated traversal proceeds
* <code>bool</code>: <code><b>true</b></code> if should break out of loop after follow up


<a name="@Passing_considerations_37"></a>

### Passing considerations

* Returns local <code>target_order_id</code> and <code>should_break</code> variables
as values rather than reassigning to passed in references,
because the calling function <code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code> accesses
these variables elsewhere in a loop, such that passing
references to them constitutes an invalid borrow within the
loop context
* Accepts <code>target_order_id</code> as pass-by-value even though
pass-by-reference would be valid, because if it were to be
passed by reference, the underlying value would still have to
be copied into a local variable anyways in order to return
by value as described above


<a name="@Target_order_reference_rationale_38"></a>

### Target order reference rationale


In the case where there are still orders left on the book and
the target order is completely filled, the calling function
<code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> requires a mutable reference to the next target
order to fill against, which is operated on during the next
loopwise iteration. Ideally, <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> would pass in a
mutable reference to an <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code>, which would be reassigned to
the next target order to fill against, only in the case where
there are still orders on the book and the order just processed
in <code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code> was completely filled.

But this would be invalid, because a reassignment to a mutable
reference requires that the underlying value have the <code>drop</code>
capability, which <code><a href="market.md#0xc0deb00c_market_Order">Order</a></code> does not.  Hence a mutable reference
to the next target order must be optionally returned in the case
where traversal proceeds, and ideally this would entail
returning an <code><a href="_Option">option::Option</a>&lt;&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code>. But mutable
references can not be stored in structs, at least as of the time
of this writing, including structs that have the <code>drop</code> ability,
which an <code><a href="_Option">option::Option</a>&lt;&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;</code> would have, since mutable
references have the <code>drop</code> ability.

Thus a <code>&<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a></code> must be returned in all cases, even though
<code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> only meaningfully operates on this return in the
case where traversal proceeds to the next target order on the
book. Hence for the base case where traversal halts, a mutable
reference to the target order just processed in
<code><a href="market.md#0xc0deb00c_market_match_loop_order">match_loop_order</a>()</code> is returned, even though there are no
future iterations where it is operated on.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>(tree_ref_mut: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;, side_ref: &bool, traversal_direction_ref: &bool, n_orders_ref_mut: &<b>mut</b> u64, complete_target_fill_ref: &bool, should_pop_last_ref_mut: &<b>mut</b> bool, target_order_id: u128, target_parent_index_ref_mut: &<b>mut</b> u64, target_child_index_ref_mut: &<b>mut</b> u64, new_spread_maker_ref_mut: &<b>mut</b> u128): (u128, &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">market::Order</a>, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_loop_order_follow_up">match_loop_order_follow_up</a>(
    tree_ref_mut: &<b>mut</b> CritBitTree&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;,
    side_ref: &bool,
    traversal_direction_ref: &bool,
    n_orders_ref_mut: &<b>mut</b> u64,
    complete_target_fill_ref: &bool,
    should_pop_last_ref_mut: &<b>mut</b> bool,
    target_order_id: u128,
    target_parent_index_ref_mut: &<b>mut</b> u64,
    target_child_index_ref_mut: &<b>mut</b> u64,
    new_spread_maker_ref_mut: &<b>mut</b> u128
):  (
    u128,
    &<b>mut</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>,
    bool
) {
    // Assume traversal halts, so <b>return</b> mutable reference <b>to</b>
    // target order just processed, which will not be operated on
    <b>let</b> target_order_ref_mut =
        <a href="critbit.md#0xc0deb00c_critbit_borrow_mut">critbit::borrow_mut</a>(tree_ref_mut, target_order_id);
    // Assume should set new spread maker field <b>to</b> target order ID
    *new_spread_maker_ref_mut = target_order_id;
    // Assume should not pop last order off book after followup
    *should_pop_last_ref_mut = <b>false</b>;
    // Assume should <b>break</b> out of <b>loop</b> after follow up
    <b>let</b> should_break = <b>true</b>;
    <b>if</b> (*n_orders_ref_mut == 1) { // If no orders left on book
        // If target order completely filled
        <b>if</b> (*complete_target_fill_ref) {
            // Market that should pop last order on book
            *should_pop_last_ref_mut = <b>true</b>;
            // Set new spread maker value <b>to</b> default value for side
            *new_spread_maker_ref_mut = <b>if</b> (*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)
                <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a> <b>else</b> <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>;
        }; // If not complete target order fill, <b>use</b> defaults
    } <b>else</b> { // If orders still left on book
        // If target order completely filled
        <b>if</b> (*complete_target_fill_ref) {
            // Declare locally-scoped temporary <b>return</b> variables
            <b>let</b> (target_parent_index, target_child_index, empty_order);
            // Traverse pop <b>to</b> next order on book, reassigning <b>to</b>
            // temporary variables and those from calling scope
            (target_order_id, target_order_ref_mut, target_parent_index,
             target_child_index, empty_order) = <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">critbit::traverse_pop_mut</a>(
                tree_ref_mut, target_order_id,
                *target_parent_index_ref_mut, *target_child_index_ref_mut,
                *n_orders_ref_mut, *traversal_direction_ref);
            // Reassign temporary traverse returns <b>to</b> variables from
            // calling scope, since reassignment is not permitted
            // inside of the above function <b>return</b> tuple
            *target_parent_index_ref_mut = target_parent_index;
            *target_child_index_ref_mut  = target_child_index;
            // Unpack popped empty order and discard
            <a href="market.md#0xc0deb00c_market_Order">Order</a>{size: _, <a href="user.md#0xc0deb00c_user">user</a>: _, general_custodian_id: _} = empty_order;
            should_break = <b>false</b>; // Flag not <b>to</b> <b>break</b> out of <b>loop</b>
            // Decrement count of orders on book for given side
            *n_orders_ref_mut = *n_orders_ref_mut - 1;
        }; // If not complete target order fill, <b>use</b> defaults
    };
    (target_order_id, target_order_ref_mut, should_break)
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_range_check_fills"></a>

## Function `match_range_check_fills`

Range check asset fill amounts to prepare for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Terminology_39"></a>

### Terminology

* "Inbound asset" is asset received by user: <code>BaseType</code> for
<code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and <code>QuoteType</code> for <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* "Outbound asset" is asset traded away by user: <code>BaseType</code> for
<code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>, and <code>QuoteType</code> for <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>
* "Available asset" is the amount one has on hand already
* "Asset ceiling" is the value that an available asset count
could increase to beyond its indicated value even without
executing the current match operation, if the available asset
count is taken from a user's market account, where outstanding
limit orders can fill into. If the available asset count is
not derived from a market account, and is instead derived
from standalone coins or from a coin store, the corresponding
asset ceiling should just be passed as the same value as the
available amount.


<a name="@Parameters_40"></a>

### Parameters

* <code>order_book_ref</code>: Immutable reference to market <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_base_ref</code>: Immutable reference to minimum number of base
units to fill
* <code>max_base_ref</code>: Immutable reference to maximum number of base
units to fill
* <code>min_quote_ref</code>: Immutable reference to minimum number of
quote units to fill
* <code>max_quote_ref</code>: Immutable reference to maximum number of
quote units to fill
* <code>base_available_ref</code>: Immutable reference to amount of
available base asset, only checked for a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>base_ceiling_ref</code>: Immutable reference to base asset ceiling,
only checked for a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>
* <code>quote_available_ref</code>: Immutable reference to amount of
available quote asset, only checked for a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>
* <code>quote_ceiling_ref</code>: Immutable reference to quote asset
ceiling, only checked for a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>


<a name="@Abort_conditions_41"></a>

### Abort conditions

* If maximum base to match is indicated as 0
* If maximum quote to match is indicated as 0
* If minimum base to match is indicated as greater than max
* If minimum quote to match is indicated as greater than max
* If filling the inbound asset to the maximum indicated amount
results in an inbound asset ceiling overflow
* If there is not enough available outbound asset to cover the
corresponding max fill amount


<a name="@Checks_not_performed_42"></a>

### Checks not performed

* Does not enforce that max fill amounts are nonzero, as the
matching engine simply returns silently before overfilling


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>(direction_ref: &bool, min_base_ref: &u64, max_base_ref: &u64, min_quote_ref: &u64, max_quote_ref: &u64, base_available_ref: &u64, base_ceiling_ref: &u64, quote_available_ref: &u64, quote_ceiling_ref: &u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>(
    direction_ref: &bool,
    min_base_ref: &u64,
    max_base_ref: &u64,
    min_quote_ref: &u64,
    max_quote_ref: &u64,
    base_available_ref: &u64,
    base_ceiling_ref: &u64,
    quote_available_ref: &u64,
    quote_ceiling_ref: &u64
) {
    // Assert minimum base allowance does not exceed maximum
    <b>assert</b>!(!(*min_base_ref &gt; *max_base_ref), <a href="market.md#0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX">E_MIN_BASE_EXCEEDS_MAX</a>);
    // Assert minimum quote allowance does not exceed maximum
    <b>assert</b>!(!(*min_quote_ref &gt; *max_quote_ref), <a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX">E_MIN_QUOTE_EXCEEDS_MAX</a>);
    // Get ceiling for inbound asset type, max inbound asset fill
    // amount, available outbound asset type, and max outbound asset
    // fill amount, based on side
    <b>let</b> (in_ceiling, max_in, out_available, max_out) =
        // If a buy, get base and trade away quote
        <b>if</b> (*direction_ref == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) (
            *base_ceiling_ref,    *max_base_ref,
            *quote_available_ref, *max_quote_ref,
        ) <b>else</b> ( // If a sell, get quote, give base
            *quote_ceiling_ref,   *max_quote_ref,
            *base_available_ref,  *max_base_ref,
        );
    // Calculate maximum ceiling for inbound asset type, <b>post</b>-match
    <b>let</b> in_ceiling_max = (in_ceiling <b>as</b> u128) + (max_in <b>as</b> u128);
    // Assert max inbound asset ceiling does not overflow a u64
    <b>assert</b>!(!(in_ceiling_max &gt; (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)), <a href="market.md#0xc0deb00c_market_E_INBOUND_ASSET_OVERFLOW">E_INBOUND_ASSET_OVERFLOW</a>);
    // Assert enough outbound asset <b>to</b> cover max fill amount
    <b>assert</b>!(!(out_available &lt; max_out), <a href="market.md#0xc0deb00c_market_E_NOT_ENOUGH_OUTBOUND_ASSET">E_NOT_ENOUGH_OUTBOUND_ASSET</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_match_verify_fills"></a>

## Function `match_verify_fills`

Calculate number of lots and ticks filled, verify minimum
thresholds met.

Inner function for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.

Called by matching engine after <code><a href="market.md#0xc0deb00c_market_match_loop">match_loop</a>()</code> executes, which
will not match in excess of values indicated by <code>max_lots_ref</code>
and <code>max_ticks_ref</code>, but which may terminate before filling at
least the corresponding minimum value thresholds.


<a name="@Parameters_43"></a>

### Parameters

* <code>min_lots_ref</code>: Immutable reference to minimum number of lots
to have been filled by matching engine
* <code>max_lots_ref</code>: Immutable reference to maximum number of lots
to have been filled by matching engine
* <code>min_ticks_ref</code>: Immutable reference to minimum number of
ticks to have been filled by matching engine
* <code>max_ticks_ref</code>: Immutable reference to maximum number of
ticks to have been filled by matching engine
* <code>lots_until_max_ref</code>: Immutable reference to counter for
number of lots that matching engine could have filled before
exceeding maximum threshold
* <code>ticks_until_max_ref</code>: Immutable reference to counter for
number of ticks that matching engine could have filled before
exceeding maximum threshold
* <code>lots_filled_ref_mut</code>: Mutable reference to counter for number
of lots filled by matching engine
* <code>ticks_filled_ref_mut</code>: Mutable reference to counter for
number of ticks filled by matching engine


<a name="@Abort_conditions_44"></a>

### Abort conditions

* If minimum lot fill threshold not met
* If minimum tick fill threshold not met


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>(min_lots_ref: &u64, max_lots_ref: &u64, min_ticks_ref: &u64, max_ticks_ref: &u64, lots_until_max_ref: &u64, ticks_until_max_ref: &u64, lots_filled_ref_mut: &<b>mut</b> u64, ticks_filled_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>(
    min_lots_ref: &u64,
    max_lots_ref: &u64,
    min_ticks_ref: &u64,
    max_ticks_ref: &u64,
    lots_until_max_ref: &u64,
    ticks_until_max_ref: &u64,
    lots_filled_ref_mut: &<b>mut</b> u64,
    ticks_filled_ref_mut: &<b>mut</b> u64
) {
    // Calculate number of lots filled
    *lots_filled_ref_mut = *max_lots_ref - *lots_until_max_ref;
    // Calculate number of ticks filled
    *ticks_filled_ref_mut = *max_ticks_ref - *ticks_until_max_ref;
    <b>assert</b>!( // Assert minimum lots filled requirement met
        !(*lots_filled_ref_mut &lt; *min_lots_ref), <a href="market.md#0xc0deb00c_market_E_MIN_LOTS_NOT_FILLED">E_MIN_LOTS_NOT_FILLED</a>);
    <b>assert</b>!( // Assert minimum ticks filled requirement met
        !(*ticks_filled_ref_mut &lt; *min_ticks_ref), <a href="market.md#0xc0deb00c_market_E_MIN_TICKS_NOT_FILLED">E_MIN_TICKS_NOT_FILLED</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order"></a>

## Function `place_limit_order`

Place limit order against book and optionally register in user's
market account, depending on the order type.

Silently returns if <code>size_ref</code> is <code>&0</code>.

If <code>post_or_abort_ref</code> is <code>&<b>false</b></code> and order crosses the spread,
it will match as a taker order against all orders it crosses,
then the remaining size will be placed as a maker order
(assuming <code>fill_or_abort_ref</code> and <code>immediate_or_cancel_ref</code>
are both <code>&<b>false</b></code>). If <code>post_or_abort_ref</code> is <code>&<b>true</b></code> and the
order crosses the spread, it aborts if size is nonzero, and
silently returns otherwise.

If <code>fill_or_abort_ref</code> is <code>&<b>true</b></code> and the order does not
completely fill across the spread, it aborts.

If <code>immediate_or_cancel_ref</code> is <code>&<b>true</b></code>, only the portion of the
order that crosses the spread is filled, and the remaining
portion is silently cancelled.

Only one of <code>post_or_abort_ref</code>, <code>fill_or_abort_ref</code>, and
<code>immediate_or_cancel_ref</code> may be marked <code>&<b>true</b></code> for a given
order.

Call to <code><a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>()</code> is necessary to check
fill amounts relative to user's asset counts, even in the case
that cross-spread matching does not take place. See
<code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code> for discussion on calculating minimum and
maximum fill values for both base and quote.


<a name="@Type_parameters_45"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_46"></a>

### Parameters

* <code>user_ref</code>: Immutable reference to address of user submitting
order
* <code>host_ref</code>: Immutable reference to market host
* <code>market_id_ref</code>: Immutable reference to market ID
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>general_custodian_id_ref</code>: Immutable reference to general
custodian ID for user's market account
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>size_ref</code>: Immutable reference to number of lots the order is
for
* <code>price_ref</code>: Immutable reference to order price, in ticks per
lot
* <code>post_or_abort_ref</code>: If <code>&<b>true</b></code>, abort for orders that cross
the spread, else fill across the spread when applicable
* <code>fill_or_abort_ref</code>: If <code>&<b>true</b></code>, abort if the limit order is
not completely filled as a taker order across the spread
* <code>immediate_or_cancel_ref</code>: If <code>&<b>true</b></code>, fill as much as
possible across the spread, then silently return


<a name="@Abort_conditions_47"></a>

### Abort conditions

* If <code>price_ref</code> is <code>&0</code>
* If more than one of <code>post_or_abort_ref&</code>, <code>fill_or_abort_ref</code>,
or <code>immediate_or_cancel_ref</code> is marked <code>&<b>true</b></code> per
<code><a href="market.md#0xc0deb00c_market_place_limit_order_pre_match">place_limit_order_pre_match</a>()</code>
* If <code>post_or_abort_ref</code> is <code>&<b>true</b></code> and order crosses the spread
per <code><a href="market.md#0xc0deb00c_market_place_limit_order_pre_match">place_limit_order_pre_match</a>()</code>
* If <code>fill_or_abort_ref</code> is <code>&<b>true</b></code> and the order does not
completely fill across the spread: minimum base and quote
match amounts are assigned via <code><a href="market.md#0xc0deb00c_market_place_limit_order_pre_match">place_limit_order_pre_match</a>()</code>
such that the abort condition is evaluated in
<code><a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>()</code>


<a name="@Assumes_48"></a>

### Assumes

* That user-side maker order registration will abort for invalid
arguments: if order fills across the spread, asset ceiling
is range checked again when registering an order user-side
per <code><a href="market.md#0xc0deb00c_market_place_limit_order_post_match">place_limit_order_post_match</a>()</code>, since filling a
limit order as a taker may result in a better price than as a
maker.
* That matching against the book will abort for invalid
arguments, per <code><a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>()</code> and inner
functions


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;BaseType, QuoteType&gt;(user_ref: &<b>address</b>, host_ref: &<b>address</b>, market_id_ref: &u64, general_custodian_id_ref: &u64, side_ref: &bool, size_ref: &u64, price_ref: &u64, post_or_abort_ref: &bool, fill_or_abort_ref: &bool, immediate_or_cancel_ref: &bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;
    BaseType,
    QuoteType
&gt;(
    user_ref: &<b>address</b>,
    host_ref: &<b>address</b>,
    market_id_ref: &u64,
    general_custodian_id_ref: &u64,
    side_ref: &bool,
    size_ref: &u64,
    price_ref: &u64,
    post_or_abort_ref: &bool,
    fill_or_abort_ref: &bool,
    immediate_or_cancel_ref: &bool
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>assert</b>!(*price_ref != 0, <a href="market.md#0xc0deb00c_market_E_LIMIT_PRICE_0">E_LIMIT_PRICE_0</a>); // Assert price not 0
    <b>if</b> (*size_ref == 0) <b>return</b>; // Silently <b>return</b> <b>if</b> no order size
    // Verify order book <b>exists</b>
    <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(*host_ref, *market_id_ref);
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(*host_ref).map;
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(order_books_map_ref_mut, *market_id_ref);
    // Declare variables <b>to</b> reassign via pass-by-reference
    <b>let</b> (market_account_id, lot_size, tick_size, direction, min_base,
        max_base, max_quote, lots_filled) =
        (0, 0, 0, <b>false</b>, 0, 0, 0, 0);
    // Prepare <b>to</b> match against the book
    <a href="market.md#0xc0deb00c_market_place_limit_order_pre_match">place_limit_order_pre_match</a>(user_ref, order_book_ref_mut,
        market_id_ref, general_custodian_id_ref, side_ref, size_ref,
        price_ref, post_or_abort_ref, fill_or_abort_ref,
        immediate_or_cancel_ref, &<b>mut</b> market_account_id, &<b>mut</b> lot_size,
        &<b>mut</b> tick_size, &<b>mut</b> direction, &<b>mut</b> min_base, &<b>mut</b> max_base,
        &<b>mut</b> max_quote);
    // Optionally match against order book <b>as</b> a taker
    <a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>&lt;BaseType, QuoteType&gt;(user_ref,
        &market_account_id, market_id_ref, order_book_ref_mut,
        &direction, &min_base, &max_base, &0, &max_quote, price_ref,
        &<b>mut</b> lots_filled);
    // Optionally place maker order on the book and in <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a>
    // <a href="">account</a>
    <a href="market.md#0xc0deb00c_market_place_limit_order_post_match">place_limit_order_post_match</a>(user_ref, order_book_ref_mut,
        &market_account_id, general_custodian_id_ref, &lot_size,
        &tick_size, side_ref, size_ref, price_ref, &lots_filled,
        immediate_or_cancel_ref);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_post_match"></a>

## Function `place_limit_order_post_match`

Optionally place a maker order on the book and in a user's
market account.

Inner function for <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.

Silently returns if no size left to fill as a maker.


<a name="@Parameters_49"></a>

### Parameters

* <code>user_ref</code>: Immutable reference to address of user submitting
order
* <code>order_book_ref_mut</code>: Mutable reference to market <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>market_account_id_ref</code>: Immutable reference to user's
corresponding market account ID
* <code>general_custodian_id_ref</code>: Immutable reference to general
custodian ID for user's market account
* <code>lot_size_ref</code>: Immutable reference to lot size for market
* <code>tick_size_ref</code>: Immutable reference to tick size for market
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>size_ref</code>: Immutable reference to number of lots the order is
for
* <code>price_ref</code>: Immutable reference to order price, in ticks per
lot
* <code>lots_filled_ref</code>: Immutable reference to number of lots
filled against the book as a taker order, if any
* <code>immediate_or_cancel_ref</code>: If <code>&<b>true</b></code>, silently return


<a name="@Assumes_50"></a>

### Assumes

* That user-side maker order registration will abort for invalid
arguments: if order fills across the spread, asset ceiling
is range checked again when registering an order user-side,
since filling a limit order as a taker may result in a better
price than as a maker.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_post_match">place_limit_order_post_match</a>(user_ref: &<b>address</b>, order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, market_account_id_ref: &u128, general_custodian_id_ref: &u64, lot_size_ref: &u64, tick_size_ref: &u64, side_ref: &bool, size_ref: &u64, price_ref: &u64, lots_filled_ref: &u64, immediate_or_cancel_ref: &bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_post_match">place_limit_order_post_match</a>(
    user_ref: &<b>address</b>,
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    market_account_id_ref: &u128,
    general_custodian_id_ref: &u64,
    lot_size_ref: &u64,
    tick_size_ref: &u64,
    side_ref: &bool,
    size_ref: &u64,
    price_ref: &u64,
    lots_filled_ref: &u64,
    immediate_or_cancel_ref: &bool
) {
    // Silently <b>return</b> <b>if</b> no size left <b>to</b> fill <b>as</b> maker
    <b>if</b> (*immediate_or_cancel_ref || *lots_filled_ref == *size_ref) <b>return</b>;
    // Calculate size left <b>to</b> fill
    <b>let</b> size_to_fill = *size_ref - *lots_filled_ref;
    // Get new order ID based on book counter/side
    <b>let</b> <a href="order_id.md#0xc0deb00c_order_id">order_id</a> = <a href="order_id.md#0xc0deb00c_order_id_order_id">order_id::order_id</a>(
        *price_ref, <a href="market.md#0xc0deb00c_market_get_counter">get_counter</a>(order_book_ref_mut), *side_ref);
    // Add order <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="user.md#0xc0deb00c_user_register_order_internal">user::register_order_internal</a>(*user_ref, *market_account_id_ref,
        *side_ref, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>, size_to_fill, *price_ref, *lot_size_ref,
        *tick_size_ref);
    // Get mutable reference <b>to</b> orders tree for given side,
    // determine <b>if</b> order is new spread maker, and get mutable
    // reference <b>to</b> spread maker for given side
    <b>let</b> (tree_ref_mut, new_spread_maker, spread_maker_ref_mut) =
        <b>if</b> (*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) (
            &<b>mut</b> order_book_ref_mut.asks,
            (<a href="order_id.md#0xc0deb00c_order_id">order_id</a> &lt; order_book_ref_mut.min_ask),
            &<b>mut</b> order_book_ref_mut.min_ask
        ) <b>else</b> ( // If order is a bid
            &<b>mut</b> order_book_ref_mut.bids,
            (<a href="order_id.md#0xc0deb00c_order_id">order_id</a> &gt; order_book_ref_mut.max_bid),
            &<b>mut</b> order_book_ref_mut.max_bid
        );
    // If a new spread maker, mark <b>as</b> such on book
    <b>if</b> (new_spread_maker) *spread_maker_ref_mut = <a href="order_id.md#0xc0deb00c_order_id">order_id</a>;
    // Insert order <b>to</b> corresponding tree
    <a href="critbit.md#0xc0deb00c_critbit_insert">critbit::insert</a>(tree_ref_mut, <a href="order_id.md#0xc0deb00c_order_id">order_id</a>,
        <a href="market.md#0xc0deb00c_market_Order">Order</a>{size: size_to_fill, <a href="user.md#0xc0deb00c_user">user</a>: *user_ref,
            general_custodian_id: *general_custodian_id_ref});
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_limit_order_pre_match"></a>

## Function `place_limit_order_pre_match`

Prepare for matching a limit order across the spread.

Inner function for <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.

Verify valid inputs, initialize variables local to
<code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>, evaluate post-or-abort condition, and
range check fill amounts.


<a name="@Match_fill_amounts_51"></a>

### Match fill amounts


While limit orders specify a size to fill, the matching engine
evaluates fills based on minimum and maximum fill amounts for
both base and quote. Thus it is necessary to calculate
"size-correspondent" amounts for these values based on the limit
price and lot/tick size, with such amounts then passed to the
matching engine for optional cross-spread matching. Here,
cross-spread matching refers to a limit order ask that crosses
the spread and fills as a taker buy (filling against bids on
the book), or a limit order bid that crosses the spread and
fills as a taker sell (filling against asks on the book).

Assuming an order is not post-or-abort, the maximum base to fill
is thus the size-correspondent amount.

In the case of a fill-or-abort order, where only cross-spread
matching is to take place, the minimum base to fill is also the
size-correspondent amount. Else the minimum base to fill is set
to 0, since cross-spread matching is only optional in the
general case.

With the minimum base match amount specified as such, it is thus
unnecessary to specify a minimum quote match amount in the case
of a fill-or-abort order, since the matching engine already
verifies that the minimum limit order size will be filled, by
checking the minimum base fill amount at the end of matching.
Thus the minimum quote variable is simply passed as 0 to
<code><a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>()</code> in <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>.

As for the maximum quote amount, however, if a limit ask crosses
the spread it fills as a taker sell against bids on the book,
and here it is impossible to calculate a priori a maximum quote
amount because all fills will execute at a price higher than
that indicated in the ask. This provides the limit ask placer
with more quote than the size-correspondent amount calculated
initially, and in the limit, the limit ask placer receives the
maximum quote that their market account can take in before
overflowing its quote ceiling. Hence for cross-spread sells, the
maximum quote amount is calculated as max amount the user could
gain without overflowing their quote ceiling.

If a cross-spread buy, matching at a better price means simply
paying less than the size-correspondent quote amount, so here
it is appropriate to set the maximum quote match value to the
size-correspondent amount, since that the matching engine will
already return once the maximum base amount has been matched. As
for an order with no cross-spread matching whatsoever, the
maximum quote amount is also specified as the size-correspondent
quote amount, to ensure valid inputs for range checking
performed in <code><a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>()</code>. Note that this does
not constitute an evasion of error-checking, as asset count
range checks are still performed for the maker order per
<code><a href="market.md#0xc0deb00c_market_place_limit_order_post_match">place_limit_order_post_match</a>()</code>.


<a name="@Parameters_52"></a>

### Parameters

* <code>user_ref</code>: Immutable reference to address of user submitting
order
* <code>order_book_ref</code>: Immutable reference to market <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>
* <code>market_id_ref</code>: Immutable reference to market ID
* <code>general_custodian_id_ref</code>: Immutable reference to general
custodian ID for user's market account
* <code>side_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code>&<a href="market.md#0xc0deb00c_market_BID">BID</a></code>
* <code>size_ref</code>: Immutable reference to number of lots the order is
for
* <code>price_ref</code>: Immutable reference to order price, in ticks per
lot
* <code>post_or_abort_ref</code>: If <code>&<b>true</b></code>, abort for orders that cross
the spread, else fill across the spread when applicable
* <code>fill_or_abort_ref</code>: If <code>&<b>true</b></code>, abort if the limit order is
not completely filled as a taker order across the spread
* <code>immediate_or_cancel_ref</code>: If <code>&<b>true</b></code>, fill as much as
possible across the spread, then silently return
* <code>lot_size_ref_mut</code>: Mutable reference to lot size for market
* <code>tick_size_ref_mut</code>: Mutable reference to tick size for market
* <code>direction_ref_mut</code>: Mutable reference to direction for
matching across the spread, <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_base_ref_mut</code>: Mutable reference to minimum number of
base units to match across the spread for a post-or-abort
order
* <code>max_base_ref_mut</code>: Mutable reference to maximum number of
base units to match across the spread in general case
* <code>max_quote_ref_mut</code>: Mutable reference to maximum number of
quote units to match per above


<a name="@Abort_conditions_53"></a>

### Abort conditions

* If more than one of <code>post_or_abort_ref</code>, <code>fill_or_abort_ref</code>,
or <code>immediate_or_cancel_ref</code> is marked <code>&<b>true</b></code>
* If <code>post_or_abort_ref</code> is <code>&<b>true</b></code> and order crosses the spread
* If size-correspondent base amount overflows a <code>u64</code>
* If size-correspondent tick amount overflows a <code>u64</code>
* If size-correspondent quote amount overflows a <code>u64</code>
* If <code>fill_or_abort_ref</code> is <code>&<b>true</b></code> and the order does not
completely fill across the spread: minimum base match amount
is assigned per above such that the abort condition is
evaluated in <code><a href="market.md#0xc0deb00c_market_match_verify_fills">match_verify_fills</a>()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_pre_match">place_limit_order_pre_match</a>(user_ref: &<b>address</b>, order_book_ref: &<a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, market_id_ref: &u64, general_custodian_id_ref: &u64, side_ref: &bool, size_ref: &u64, price_ref: &u64, post_or_abort_ref: &bool, fill_or_abort_ref: &bool, immediate_or_cancel_ref: &bool, market_account_id_ref_mut: &<b>mut</b> u128, lot_size_ref_mut: &<b>mut</b> u64, tick_size_ref_mut: &<b>mut</b> u64, direction_ref_mut: &<b>mut</b> bool, min_base_ref_mut: &<b>mut</b> u64, max_base_ref_mut: &<b>mut</b> u64, max_quote_ref_mut: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_pre_match">place_limit_order_pre_match</a>(
    user_ref: &<b>address</b>,
    order_book_ref: &<a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    market_id_ref: &u64,
    general_custodian_id_ref: &u64,
    side_ref: &bool,
    size_ref: &u64,
    price_ref: &u64,
    post_or_abort_ref: &bool,
    fill_or_abort_ref: &bool,
    immediate_or_cancel_ref: &bool,
    market_account_id_ref_mut: &<b>mut</b> u128,
    lot_size_ref_mut: &<b>mut</b> u64,
    tick_size_ref_mut: &<b>mut</b> u64,
    direction_ref_mut: &<b>mut</b> bool,
    min_base_ref_mut: &<b>mut</b> u64,
    max_base_ref_mut: &<b>mut</b> u64,
    max_quote_ref_mut: &<b>mut</b> u64
) {
    // Assert that no more than one order type is flagged
    <b>assert</b>!(<b>if</b> (*post_or_abort_ref)
        !(*fill_or_abort_ref || *immediate_or_cancel_ref) <b>else</b>
        !(*fill_or_abort_ref && *immediate_or_cancel_ref), <a href="market.md#0xc0deb00c_market_E_TOO_MANY_ORDER_FLAGS">E_TOO_MANY_ORDER_FLAGS</a>);
    // Determine <b>if</b> spread crossed
    <b>let</b> crossed_spread = <b>if</b> (*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)
        (*price_ref &lt;= <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(order_book_ref.max_bid)) <b>else</b>
        (*price_ref &gt;= <a href="order_id.md#0xc0deb00c_order_id_price">order_id::price</a>(order_book_ref.min_ask));
    // Assert no cross-spread fills <b>if</b> a <b>post</b>-or-<b>abort</b> order
    <b>assert</b>!(!(*post_or_abort_ref && crossed_spread),
        <a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSED_SPREAD">E_POST_OR_ABORT_CROSSED_SPREAD</a>);
    // Get <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    *market_account_id_ref_mut = user::
        get_market_account_id(*market_id_ref, *general_custodian_id_ref);
    // Calculate direction of matching for crossed spread
    *direction_ref_mut = <b>if</b> (*side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) <a href="market.md#0xc0deb00c_market_SELL">SELL</a> <b>else</b> <a href="market.md#0xc0deb00c_market_BUY">BUY</a>;
    *lot_size_ref_mut = order_book_ref.lot_size; // Get lot size
    *tick_size_ref_mut = order_book_ref.tick_size; // Get tick size
    // Calculate size-correspondent base amount
    <b>let</b> base = (*size_ref <b>as</b> u128) * (*lot_size_ref_mut <b>as</b> u128);
    // Assert size-correspondent base amount fits in a u64
    <b>assert</b>!(!(base &gt; (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)), <a href="market.md#0xc0deb00c_market_E_SIZE_BASE_OVERFLOW">E_SIZE_BASE_OVERFLOW</a>);
    // Calculate size-correspondent tick amount
    <b>let</b> ticks = (*size_ref <b>as</b> u128) * (*price_ref <b>as</b> u128);
    // Assert size-correspondent ticks amount fits in a u64
    <b>assert</b>!(!(ticks &gt; (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)), <a href="market.md#0xc0deb00c_market_E_SIZE_TICKS_OVERFLOW">E_SIZE_TICKS_OVERFLOW</a>);
    // Calculate size-correspondent quote amount
    <b>let</b> quote = ticks * (*tick_size_ref_mut <b>as</b> u128);
    // Assert size-correspondent quote amount fits in a u64
    <b>assert</b>!(!(quote &gt; (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)), <a href="market.md#0xc0deb00c_market_E_SIZE_QUOTE_OVERFLOW">E_SIZE_QUOTE_OVERFLOW</a>);
    // Max base <b>to</b> match is size-correspondent amount
    *max_base_ref_mut = (base <b>as</b> u64);
    // If a fill-or-<b>abort</b> order, minimum base <b>to</b> fill is
    // size-correspondent amount, otherwise there is no minimum
    *min_base_ref_mut = <b>if</b> (*fill_or_abort_ref) (base <b>as</b> u64) <b>else</b> 0;
    // If limit ask crosses the spread and fills <b>as</b> a taker sell
    <b>if</b> (crossed_spread && *side_ref == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) {
        // Get <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> quote ceiling
        <b>let</b> (_, _, _, _, _, quote_ceiling) =
            <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">user::get_asset_counts_internal</a>(
                *user_ref, *market_account_id_ref_mut);
        // Max quote <b>to</b> match is max that can fit in <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
        *max_quote_ref_mut = <a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - quote_ceiling;
    // Else <b>if</b> a cross-spread buy or no cross-spread matching at all
    } <b>else</b> {
        // Max quote <b>to</b> match is size-correspondent amount
        *max_quote_ref_mut = (quote <b>as</b> u64);
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_market_place_market_order"></a>

## Function `place_market_order`

Place a market order from a user's market account.

See wrapped function <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>, which has the same
parameters except for the below exceptions.


<a name="@Extra_parameters_54"></a>

### Extra parameters

* <code>host_ref</code>: Immutable reference to market host
* <code>general_custodian_id_ref</code>: Immutable reference to general
custodian ID for user's market account


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;BaseType, QuoteType&gt;(user_ref: &<b>address</b>, host_ref: &<b>address</b>, market_id_ref: &u64, general_custodian_id_ref: &u64, direction_ref: &bool, min_base_ref: &u64, max_base_ref: &u64, min_quote_ref: &u64, max_quote_ref: &u64, limit_price_ref: &u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;
    BaseType,
    QuoteType
&gt;(
    user_ref: &<b>address</b>,
    host_ref: &<b>address</b>,
    market_id_ref: &u64,
    general_custodian_id_ref: &u64,
    direction_ref: &bool,
    min_base_ref: &u64,
    max_base_ref: &u64,
    min_quote_ref: &u64,
    max_quote_ref: &u64,
    limit_price_ref: &u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Verify order book <b>exists</b>
    <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(*host_ref, *market_id_ref);
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(*host_ref).map;
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(order_books_map_ref_mut, *market_id_ref);
    // Get <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>let</b> market_account_id = <a href="user.md#0xc0deb00c_user_get_market_account_id">user::get_market_account_id</a>(*market_id_ref,
        *general_custodian_id_ref);
    // Declare tracker for lots filled, which is not used but which
    // is necessary for the general matching function signature
    <b>let</b> lots_filled = 0;
    // Match against the order book, from <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>
    <a href="market.md#0xc0deb00c_market_match_from_market_account">match_from_market_account</a>&lt;BaseType, QuoteType&gt;(user_ref,
        &market_account_id, market_id_ref, order_book_ref_mut,
        direction_ref, min_base_ref, max_base_ref, min_quote_ref,
        max_quote_ref, limit_price_ref, &<b>mut</b> lots_filled);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_market"></a>

## Function `register_market`

Register new market under signing host.


<a name="@Type_parameters_55"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_56"></a>

### Parameters

* <code>host</code>: Account where order book should be stored
* <code>lot_size</code>: Number of base units exchanged per lot
* <code>tick_size</code>: Number of quote units exchanged per tick
* <code>generic_asset_transfer_custodian_id</code>: ID of custodian
capability required to approve deposits, swaps, and
withdrawals of non-coin assets


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseType, QuoteType&gt;(host: &<a href="">signer</a>, lot_size: u64, tick_size: u64, generic_asset_transfer_custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
    generic_asset_transfer_custodian_id: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Register the <a href="market.md#0xc0deb00c_market">market</a> in the <b>global</b> <a href="registry.md#0xc0deb00c_registry">registry</a>, storing <a href="market.md#0xc0deb00c_market">market</a> ID
    <b>let</b> market_id =
        <a href="registry.md#0xc0deb00c_registry_register_market_internal">registry::register_market_internal</a>&lt;BaseType, QuoteType&gt;(
            address_of(host), lot_size, tick_size,
            generic_asset_transfer_custodian_id);
    // Register an under book under host's <a href="">account</a>
    <a href="market.md#0xc0deb00c_market_register_order_book">register_order_book</a>&lt;BaseType, QuoteType&gt;(host, market_id,
        lot_size, tick_size, generic_asset_transfer_custodian_id);
}
</code></pre>



</details>

<a name="0xc0deb00c_market_register_order_book"></a>

## Function `register_order_book`

Register host with an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>, initializing their
<code><a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a></code> if they do not already have one


<a name="@Type_parameters_57"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_58"></a>

### Parameters

* <code>host</code>: Account where order book should be stored
* <code>market_id</code>: Market ID
* <code>lot_size</code>: Number of base units exchanged per lot
* <code>tick_size</code>: Number of quote units exchanged per tick
* <code>generic_asset_transfer_custodian_id</code>: ID of custodian
capability required to approve deposits, swaps, and
withdrawals of non-coin assets


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_order_book">register_order_book</a>&lt;BaseType, QuoteType&gt;(host: &<a href="">signer</a>, market_id: u64, lot_size: u64, tick_size: u64, generic_asset_transfer_custodian_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_order_book">register_order_book</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host: &<a href="">signer</a>,
    market_id: u64,
    lot_size: u64,
    tick_size: u64,
    generic_asset_transfer_custodian_id: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> host_address = address_of(host); // Get host <b>address</b>
    // If host does not have an order books map
    <b>if</b> (!<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host_address))
        // Move one <b>to</b> their <a href="">account</a>
        <b>move_to</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host, <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>{map: <a href="open_table.md#0xc0deb00c_open_table_empty">open_table::empty</a>()});
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host_address).map;
    // Assert order book does not already exist under host <a href="">account</a>
    <b>assert</b>!(!<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(order_books_map_ref_mut, market_id),
        <a href="market.md#0xc0deb00c_market_E_ORDER_BOOK_EXISTS">E_ORDER_BOOK_EXISTS</a>);
    <a href="open_table.md#0xc0deb00c_open_table_add">open_table::add</a>(order_books_map_ref_mut, market_id, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>{
        base_type_info: <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(),
        quote_type_info: <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;(),
        lot_size,
        tick_size,
        generic_asset_transfer_custodian_id,
        asks: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        bids: <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(),
        min_ask: <a href="market.md#0xc0deb00c_market_MIN_ASK_DEFAULT">MIN_ASK_DEFAULT</a>,
        max_bid: <a href="market.md#0xc0deb00c_market_MAX_BID_DEFAULT">MAX_BID_DEFAULT</a>,
        counter: 0
    });
}
</code></pre>



</details>

<a name="0xc0deb00c_market_swap"></a>

## Function `swap`

Swap against book, via wrapped call to <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.

Institutes pass-by-reference for enhanced efficiency.


<a name="@Type_parameters_59"></a>

### Type parameters

* <code>BaseType</code>: Base type for market
* <code>QuoteType</code>: Quote type for market


<a name="@Parameters_60"></a>

### Parameters

* <code>host_ref</code>: Immutable reference to market host
* <code>market_id_ref</code>: Immutable reference to market ID
* <code>direction_ref</code>: <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>min_base_ref</code>: Immutable reference to minimum number of base
units to fill
* <code>max_base_ref</code>: Immutable reference to maximum number of base
units to fill
* <code>min_quote_ref</code>: Immutable reference to minimum number of
quote units to fill
* <code>max_quote_ref</code>: Immutable reference to maximum number of
quote units to fill
* <code>limit_price_ref</code>: Immutable reference to maximum price to
match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and minimum price
to match against if <code>direction_ref</code> is <code>&<a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>. If passed as
<code><a href="market.md#0xc0deb00c_market_HI_64">HI_64</a></code> in the case of a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>0</code> in the case of a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>,
will match at any price. Price for a given market is the
number of ticks per lot.
* <code>optional_base_coins_ref_mut</code>: Mutable reference to optional
base coins passing through the matching engine, gradually
incremented in the case of <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and gradually decremented
in the case of <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>optional_quote_coins_ref_mut</code>: Mutable reference to optional
quote coins passing through the matching engine, gradually
decremented in the case of <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, and gradually incremented
in the case of <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>
* <code>base_filled_ref_mut</code>: Mutable reference to counter for number
of base units filled by matching engine
* <code>quote_filled_ref_mut</code>: Mutable reference to counter for
number of quote units filled by matching engine
* <code>generic_asset_transfer_custodian_id_ref</code>: Immutable reference
to ID of generic asset transfer custodian attempting to place
swap, marked <code><a href="market.md#0xc0deb00c_market_PURE_COIN_PAIR">PURE_COIN_PAIR</a></code> when no custodian placing swap


<a name="@Assumes_61"></a>

### Assumes

* That min/max fill amounts have been checked via
<code><a href="market.md#0xc0deb00c_market_match_range_check_fills">match_range_check_fills</a>()</code>


<a name="@Abort_conditions_62"></a>

### Abort conditions

* If <code>generic_asset_transfer_custodian_id_ref</code> does not indicate
generic asset transfer custodian for given market


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;BaseType, QuoteType&gt;(host_ref: &<b>address</b>, market_id_ref: &u64, direction_ref: &bool, min_base_ref: &u64, max_base_ref: &u64, min_quote_ref: &u64, max_quote_ref: &u64, limit_price_ref: &u64, optional_base_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, optional_quote_coins_ref_mut: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;, base_filled_ref_mut: &<b>mut</b> u64, quote_filled_ref_mut: &<b>mut</b> u64, generic_asset_transfer_custodian_id_ref: &u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;
    BaseType,
    QuoteType
&gt;(
    host_ref: &<b>address</b>,
    market_id_ref: &u64,
    direction_ref: &bool,
    min_base_ref: &u64,
    max_base_ref: &u64,
    min_quote_ref: &u64,
    max_quote_ref: &u64,
    limit_price_ref: &u64,
    optional_base_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;,
    optional_quote_coins_ref_mut:
        &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;&gt;,
    base_filled_ref_mut: &<b>mut</b> u64,
    quote_filled_ref_mut: &<b>mut</b> u64,
    generic_asset_transfer_custodian_id_ref: &u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Verify order book <b>exists</b>
    <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(*host_ref, *market_id_ref);
    // Borrow mutable reference <b>to</b> order books map
    <b>let</b> order_books_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(*host_ref).map;
    // Borrow mutable reference <b>to</b> order book
    <b>let</b> order_book_ref_mut =
        <a href="open_table.md#0xc0deb00c_open_table_borrow_mut">open_table::borrow_mut</a>(order_books_map_ref_mut, *market_id_ref);
    // Assert correct generic asset transfer custodian ID for <a href="market.md#0xc0deb00c_market">market</a>
    <b>assert</b>!(*generic_asset_transfer_custodian_id_ref == order_book_ref_mut.
        generic_asset_transfer_custodian_id, <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    <b>let</b> lot_size = order_book_ref_mut.lot_size; // Get lot size
    <b>let</b> tick_size = order_book_ref_mut.tick_size; // Get tick size
    // Declare variables <b>to</b> track lots and ticks filled
    <b>let</b> (lots_filled, ticks_filled) = (0, 0);
    // Match against order book
    <a href="market.md#0xc0deb00c_market_match">match</a>&lt;BaseType, QuoteType&gt;(market_id_ref, order_book_ref_mut,
        &lot_size, &tick_size, direction_ref,
        &(*min_base_ref / lot_size), &(*max_base_ref / lot_size),
        &(*min_quote_ref / tick_size), &(*max_quote_ref / tick_size),
        limit_price_ref, optional_base_coins_ref_mut,
        optional_quote_coins_ref_mut, &<b>mut</b> lots_filled, &<b>mut</b> ticks_filled);
    // Calculate base units filled
    *base_filled_ref_mut = lots_filled * lot_size;
    // Calculate quote units filled
    *quote_filled_ref_mut = ticks_filled * tick_size;
}
</code></pre>



</details>

<a name="0xc0deb00c_market_verify_order_book_exists"></a>

## Function `verify_order_book_exists`

Verify <code>host</code> has an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> with <code>market_id</code>


<a name="@Abort_conditions_63"></a>

### Abort conditions

* If user does not have an <code><a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a></code>
* If user does not have an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code> for given <code>market_id</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(host: <b>address</b>, market_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_verify_order_book_exists">verify_order_book_exists</a>(
    host: <b>address</b>,
    market_id: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Assert host <b>has</b> an order books map
    <b>assert</b>!(<b>exists</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host), <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOKS">E_NO_ORDER_BOOKS</a>);
    // Borrow immutable reference <b>to</b> order books map
    // Borrow immutable reference <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> accounts map
    <b>let</b> order_books_map_ref = &<b>borrow_global</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(host).map;
    // Assert host <b>has</b> an entry in map for <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a> ID
    <b>assert</b>!(<a href="open_table.md#0xc0deb00c_open_table_contains">open_table::contains</a>(order_books_map_ref, market_id),
        <a href="market.md#0xc0deb00c_market_E_NO_ORDER_BOOK">E_NO_ORDER_BOOK</a>);
}
</code></pre>



</details>
