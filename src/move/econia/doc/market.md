
<a name="0xc0deb00c_market"></a>

# Module `0xc0deb00c::market`

Market functionality for order book operations.

For each registered market, Econia has an order book stored under a
global resource account. When someone registers a market, a new
order book entry is added under the resource account at a new market
ID.

Once a market is registered, signing users and delegated custodians
can place limit orders on the book as makers, takers can place
market orders or swaps against the order book, and makers can cancel
or change the size of any outstanding orders they have on the book.

Econia implements an atomic matching engine for processing taker
fills against maker orders on the book, and emits events in response
to changes in order book state. Notably, Econia evicts the ask or
bid with the lowest price-time priority when inserting a limit order
to a binary search tree that exceeds a critical height.

Multiple API variants are supported for market registration and
order management function, to enable diagnostic function returns,
public entry calls, etc.


<a name="@General_overview_sections_0"></a>

## General overview sections


[Public function index](#public-function-index)

* [Market registration](#market-registration)
* [Limit orders](#limit-orders)
* [Market orders](#market-orders)
* [Swaps](#swaps)
* [Change order size](#change-order-size)
* [Cancel orders](#cancel-orders)

[Indexing](#indexing)

[Dependency charts](#dependency-charts)

* [Internal dependencies](#internal-dependencies)
* [External module dependencies](#external-module-dependencies)

[Order management testing](#order-management-testing)

* [Functions with aborts](#functions-with-aborts)
* [Return proxies](#return-proxies)
* [Invocation proxies](#invocation-proxies)
* [Branching functions](#branching-functions)

[Complete DocGen index](#complete-docgen-index)


<a name="@Public_function_index_1"></a>

## Public function index


See the [dependency charts](#dependency-charts) for a visual map of
associated function wrappers.


<a name="@Market_registration_2"></a>

### Market registration


* <code><a href="market.md#0xc0deb00c_market_register_market_base_coin">register_market_base_coin</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore">register_market_base_coin_from_coinstore</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_register_market_base_generic">register_market_base_generic</a>()</code>


<a name="@Limit_orders_3"></a>

### Limit orders


* <code><a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_place_limit_order_user_entry">place_limit_order_user_entry</a>()</code>


<a name="@Market_orders_4"></a>

### Market orders


* <code><a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_place_market_order_user_entry">place_market_order_user_entry</a>()</code>


<a name="@Swaps_5"></a>

### Swaps


* <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores_entry">swap_between_coinstores_entry</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code>


<a name="@Change_order_size_6"></a>

### Change order size


* <code><a href="market.md#0xc0deb00c_market_change_order_size_custodian">change_order_size_custodian</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_change_order_size_user">change_order_size_user</a>()</code>


<a name="@Cancel_orders_7"></a>

### Cancel orders


* <code><a href="market.md#0xc0deb00c_market_cancel_order_custodian">cancel_order_custodian</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_cancel_order_user">cancel_order_user</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_cancel_all_orders_custodian">cancel_all_orders_custodian</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_cancel_all_orders_user">cancel_all_orders_user</a>()</code>


<a name="@Indexing_8"></a>

## Indexing


An order book can be indexed off-chain via <code><a href="market.md#0xc0deb00c_market_index_orders">index_orders</a>()</code>, an
SDK-generative function for use as a <code><b>move</b>-<b>to</b>-ts</code> method attribute
on an <code><a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a></code>.

Once an order book has been indexed, the off-chain copy can be kept
current by monitoring <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a></code> and <code><a href="market.md#0xc0deb00c_market_TakerEvent">TakerEvent</a></code> emissions from
the following functions:

* <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>
* <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>


<a name="@Dependency_charts_9"></a>

## Dependency charts


The below dependency charts use <code>mermaid.js</code> syntax, which can be
automatically rendered into a diagram (depending on the browser)
when viewing the documentation file generated from source code. If
a browser renders the diagrams with coloring that makes it difficult
to read, try a different browser.


<a name="@Internal_dependencies_10"></a>

### Internal dependencies


These charts describe dependencies between <code><a href="market.md#0xc0deb00c_market">market</a></code> functions.

Market registration:

```mermaid

flowchart LR

register_market_base_coin --> register_market

register_market_base_generic --> register_market

register_market_base_coin_from_coinstore -->
register_market_base_coin

```

Placing orders:

```mermaid

flowchart LR

subgraph Limit orders

place_limit_order_user_entry --> place_limit_order_user

place_limit_order_user --> place_limit_order

place_limit_order_custodian --> place_limit_order

end

place_limit_order ---> match

place_limit_order --> range_check_trade

subgraph Market orders

place_market_order_user_entry --> place_market_order_user

place_market_order_user --> place_market_order

place_market_order_custodian --> place_market_order

end

place_market_order ---> match

place_market_order --> range_check_trade

swap_between_coinstores ---> range_check_trade

subgraph Swaps

swap_between_coinstores_entry --> swap_between_coinstores

swap_between_coinstores --> swap

swap_coins --> swap

swap_generic --> swap

end

swap_generic --> range_check_trade

swap_coins ---> range_check_trade

swap ---> match

```

Changing order size:

```mermaid

flowchart LR

change_order_size_custodian --> change_order_size

change_order_size_user --> change_order_size

```

Cancelling orders:

```mermaid

flowchart LR

cancel_all_orders_custodian --> cancel_all_orders

cancel_order_custodian --> cancel_order

cancel_all_orders_user --> cancel_all_orders

cancel_order_user --> cancel_order

cancel_all_orders --> cancel_order

```


<a name="@External_module_dependencies_11"></a>

### External module dependencies


These charts describe <code><a href="market.md#0xc0deb00c_market">market</a></code> function dependencies on functions
from other Econia modules, other than <code><a href="avl_queue.md#0xc0deb00c_avl_queue">avl_queue</a></code> and <code><a href="tablist.md#0xc0deb00c_tablist">tablist</a></code>,
which are essentially data structure libraries.

<code><a href="incentives.md#0xc0deb00c_incentives">incentives</a></code>:

``` mermaid

flowchart LR

register_market_base_coin_from_coinstore -->
incentives::get_market_registration_fee

register_market --> incentives::register_econia_fee_store_entry

match --> incentives::get_taker_fee_divisor
match --> incentives::calculate_max_quote_match
match --> incentives::assess_taker_fees

```

<code><a href="registry.md#0xc0deb00c_registry">registry</a></code>:

``` mermaid

flowchart LR

register_market_base_coin -->
registry::register_market_base_coin_internal

register_market_base_generic -->
registry::register_market_base_generic_internal
register_market_base_generic -->
registry::get_underwriter_id

place_limit_order_custodian --> registry::get_custodian_id

place_market_order_custodian --> registry::get_custodian_id

swap_generic --> registry::get_underwriter_id

change_order_size_custodian --> registry::get_custodian_id

cancel_order_custodian --> registry::get_custodian_id

cancel_all_orders_custodian --> registry::get_custodian_id

```

<code><a href="">resource_account</a></code>:

``` mermaid

flowchart LR

init_module --> resource_account::get_signer

register_market --> resource_account::get_signer

place_limit_order --> resource_account::get_address

place_market_order --> resource_account::get_address

swap --> resource_account::get_address

change_order_size --> resource_account::get_address

cancel_order --> resource_account::get_address

```

<code><a href="user.md#0xc0deb00c_user">user</a></code>:

``` mermaid

flowchart LR

place_limit_order --> user::get_asset_counts_internal
place_limit_order --> user::withdraw_assets_internal
place_limit_order --> user::deposit_assets_internal
place_limit_order --> user::get_next_order_access_key_internal
place_limit_order --> user::place_order_internal
place_limit_order --> user::cancel_order_internal

place_market_order --> user::get_asset_counts_internal
place_market_order --> user::withdraw_assets_internal
place_market_order --> user::deposit_assets_internal

match --> user::fill_order_internal

change_order_size --> user::change_order_size_internal

cancel_order --> user::cancel_order_internal

cancel_all_orders --> user::get_active_market_order_ids_internal

```


<a name="@Order_management_testing_12"></a>

## Order management testing


While market registration functions can be simply verified with
straightforward tests, order management functions are more
comprehensively tested through integrated tests that verify multiple
logical branches, returns, and state updates. Aborts are tested
individually for each function.


<a name="@Functions_with_aborts_13"></a>

### Functions with aborts


Function aborts to test:

* [x] <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap">swap</a>()</code>


<a name="@Return_proxies_14"></a>

### Return proxies


Various order management functions have returns, and verifying the
returns of some functions verifies the returns of associated inner
functions. For example, the collective verification of the returns
of <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code> and <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code> verifies the returns of both
<code><a href="market.md#0xc0deb00c_market_swap">swap</a>()</code> and <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, such that the combination of <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>
and <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code> can be considered a "return proxy" of both
<code><a href="market.md#0xc0deb00c_market_swap">swap</a>()</code> and of <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. Hence the most efficient test suite
involves return verification for the minimal return proxy set:

| Function                         | Return proxy                |
|----------------------------------|-----------------------------|
| <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>                   | <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>, <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code> |
| <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>            | <code><a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>()</code>  |
| <code><a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>()</code>  | None                        |
| <code><a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>()</code>       | None                        |
| <code><a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>()</code>           | <code><a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>()</code> |
| <code><a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>()</code> | None                        |
| <code><a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>()</code>      | None                        |
| <code><a href="market.md#0xc0deb00c_market_swap">swap</a>()</code>                    | <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>, <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code> |
| <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>()</code>      | None                        |
| <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>                   | None                        |
| <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code>                 | None                        |

Function returns to test:

* [x] <code><a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code>


<a name="@Invocation_proxies_15"></a>

### Invocation proxies


Similarly, verifying the invocation of some functions verifies the
invocation of associated inner functions. For example,
<code><a href="market.md#0xc0deb00c_market_cancel_all_orders_user">cancel_all_orders_user</a>()</code> can be considered an invocation proxy
of <code><a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>()</code> and of <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>. Here, to provide
100% invocation coverage, only functions at the top of the
dependency stack must be verified.

Function invocations to test:

* [x] <code><a href="market.md#0xc0deb00c_market_cancel_all_orders_custodian">cancel_all_orders_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_cancel_all_orders_user">cancel_all_orders_user</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_cancel_order_custodian">cancel_order_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_cancel_order_user">cancel_order_user</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_change_order_size_custodian">change_order_size_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_change_order_size_user">change_order_size_user</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_limit_order_user_entry">place_limit_order_user_entry</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_market_order_user_entry">place_market_order_user_entry</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores_entry">swap_between_coinstores_entry</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code>


<a name="@Branching_functions_16"></a>

### Branching functions


Functions with logical branches to test:

* [x] <code><a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code>
* [x] <code><a href="market.md#0xc0deb00c_market_swap">swap</a>()</code>

See each function for its logical branches.


<a name="@Complete_DocGen_index_17"></a>

## Complete DocGen index


The below index is automatically generated from source code:


-  [General overview sections](#@General_overview_sections_0)
-  [Public function index](#@Public_function_index_1)
    -  [Market registration](#@Market_registration_2)
    -  [Limit orders](#@Limit_orders_3)
    -  [Market orders](#@Market_orders_4)
    -  [Swaps](#@Swaps_5)
    -  [Change order size](#@Change_order_size_6)
    -  [Cancel orders](#@Cancel_orders_7)
-  [Indexing](#@Indexing_8)
-  [Dependency charts](#@Dependency_charts_9)
    -  [Internal dependencies](#@Internal_dependencies_10)
    -  [External module dependencies](#@External_module_dependencies_11)
-  [Order management testing](#@Order_management_testing_12)
    -  [Functions with aborts](#@Functions_with_aborts_13)
    -  [Return proxies](#@Return_proxies_14)
    -  [Invocation proxies](#@Invocation_proxies_15)
    -  [Branching functions](#@Branching_functions_16)
-  [Complete DocGen index](#@Complete_DocGen_index_17)
-  [Struct `MakerEvent`](#0xc0deb00c_market_MakerEvent)
-  [Struct `Order`](#0xc0deb00c_market_Order)
-  [Struct `OrderBook`](#0xc0deb00c_market_OrderBook)
-  [Resource `OrderBooks`](#0xc0deb00c_market_OrderBooks)
-  [Struct `TakerEvent`](#0xc0deb00c_market_TakerEvent)
-  [Struct `PricedOrder`](#0xc0deb00c_market_PricedOrder)
-  [Constants](#@Constants_18)
-  [Function `cancel_all_orders_custodian`](#0xc0deb00c_market_cancel_all_orders_custodian)
    -  [Invocation testing](#@Invocation_testing_19)
-  [Function `cancel_order_custodian`](#0xc0deb00c_market_cancel_order_custodian)
    -  [Invocation testing](#@Invocation_testing_20)
-  [Function `change_order_size_custodian`](#0xc0deb00c_market_change_order_size_custodian)
    -  [Invocation testing](#@Invocation_testing_21)
-  [Function `place_limit_order_custodian`](#0xc0deb00c_market_place_limit_order_custodian)
    -  [Invocation and return testing](#@Invocation_and_return_testing_22)
-  [Function `place_limit_order_user`](#0xc0deb00c_market_place_limit_order_user)
    -  [Invocation and return testing](#@Invocation_and_return_testing_23)
-  [Function `place_market_order_custodian`](#0xc0deb00c_market_place_market_order_custodian)
    -  [Invocation and return testing](#@Invocation_and_return_testing_24)
-  [Function `place_market_order_user`](#0xc0deb00c_market_place_market_order_user)
    -  [Invocation and return testing](#@Invocation_and_return_testing_25)
-  [Function `register_market_base_coin`](#0xc0deb00c_market_register_market_base_coin)
    -  [Type parameters](#@Type_parameters_26)
    -  [Parameters](#@Parameters_27)
    -  [Returns](#@Returns_28)
    -  [Testing](#@Testing_29)
-  [Function `register_market_base_generic`](#0xc0deb00c_market_register_market_base_generic)
    -  [Type parameters](#@Type_parameters_30)
    -  [Parameters](#@Parameters_31)
    -  [Returns](#@Returns_32)
    -  [Testing](#@Testing_33)
-  [Function `swap_between_coinstores`](#0xc0deb00c_market_swap_between_coinstores)
    -  [Type Parameters](#@Type_Parameters_34)
    -  [Parameters](#@Parameters_35)
    -  [Returns](#@Returns_36)
    -  [Testing](#@Testing_37)
-  [Function `swap_coins`](#0xc0deb00c_market_swap_coins)
    -  [Type Parameters](#@Type_Parameters_38)
    -  [Parameters](#@Parameters_39)
    -  [Returns](#@Returns_40)
    -  [Terminology](#@Terminology_41)
    -  [Testing](#@Testing_42)
-  [Function `swap_generic`](#0xc0deb00c_market_swap_generic)
    -  [Type Parameters](#@Type_Parameters_43)
    -  [Parameters](#@Parameters_44)
    -  [Returns](#@Returns_45)
    -  [Testing](#@Testing_46)
-  [Function `cancel_all_orders_user`](#0xc0deb00c_market_cancel_all_orders_user)
    -  [Invocation testing](#@Invocation_testing_47)
-  [Function `cancel_order_user`](#0xc0deb00c_market_cancel_order_user)
    -  [Invocation testing](#@Invocation_testing_48)
-  [Function `change_order_size_user`](#0xc0deb00c_market_change_order_size_user)
    -  [Invocation testing](#@Invocation_testing_49)
-  [Function `place_limit_order_user_entry`](#0xc0deb00c_market_place_limit_order_user_entry)
    -  [Invocation testing](#@Invocation_testing_50)
-  [Function `place_market_order_user_entry`](#0xc0deb00c_market_place_market_order_user_entry)
    -  [Invocation testing](#@Invocation_testing_51)
-  [Function `register_market_base_coin_from_coinstore`](#0xc0deb00c_market_register_market_base_coin_from_coinstore)
    -  [Testing](#@Testing_52)
-  [Function `swap_between_coinstores_entry`](#0xc0deb00c_market_swap_between_coinstores_entry)
    -  [Invocation testing](#@Invocation_testing_53)
-  [Function `cancel_all_orders`](#0xc0deb00c_market_cancel_all_orders)
    -  [Parameters](#@Parameters_54)
    -  [Expected value testing](#@Expected_value_testing_55)
-  [Function `cancel_order`](#0xc0deb00c_market_cancel_order)
    -  [Parameters](#@Parameters_56)
    -  [Aborts](#@Aborts_57)
    -  [Emits](#@Emits_58)
    -  [Expected value testing](#@Expected_value_testing_59)
    -  [Failure testing](#@Failure_testing_60)
-  [Function `change_order_size`](#0xc0deb00c_market_change_order_size)
    -  [Parameters](#@Parameters_61)
    -  [Aborts](#@Aborts_62)
    -  [Emits](#@Emits_63)
    -  [Expected value testing](#@Expected_value_testing_64)
    -  [Failure testing](#@Failure_testing_65)
-  [Function `init_module`](#0xc0deb00c_market_init_module)
-  [Function `match`](#0xc0deb00c_market_match)
    -  [Type Parameters](#@Type_Parameters_66)
    -  [Parameters](#@Parameters_67)
    -  [Returns](#@Returns_68)
    -  [Emits](#@Emits_69)
    -  [Aborts](#@Aborts_70)
    -  [Algorithm description](#@Algorithm_description_71)
    -  [Expected value testing](#@Expected_value_testing_72)
    -  [Failure testing](#@Failure_testing_73)
-  [Function `place_limit_order`](#0xc0deb00c_market_place_limit_order)
    -  [Type Parameters](#@Type_Parameters_74)
    -  [Parameters](#@Parameters_75)
    -  [Returns](#@Returns_76)
    -  [Aborts](#@Aborts_77)
    -  [Emits](#@Emits_78)
    -  [Restrictions](#@Restrictions_79)
    -  [Minimum size](#@Minimum_size_80)
    -  [Algorithm description](#@Algorithm_description_81)
    -  [Expected value testing](#@Expected_value_testing_82)
    -  [Failure testing](#@Failure_testing_83)
-  [Function `place_market_order`](#0xc0deb00c_market_place_market_order)
    -  [Type Parameters](#@Type_Parameters_84)
    -  [Parameters](#@Parameters_85)
    -  [Returns](#@Returns_86)
    -  [Algorithm description](#@Algorithm_description_87)
    -  [Expected value testing](#@Expected_value_testing_88)
-  [Function `range_check_trade`](#0xc0deb00c_market_range_check_trade)
    -  [Terminology](#@Terminology_89)
    -  [Parameters](#@Parameters_90)
    -  [Aborts](#@Aborts_91)
    -  [Failure testing](#@Failure_testing_92)
-  [Function `register_market`](#0xc0deb00c_market_register_market)
    -  [Type parameters](#@Type_parameters_93)
    -  [Parameters](#@Parameters_94)
    -  [Returns](#@Returns_95)
    -  [Testing](#@Testing_96)
-  [Function `swap`](#0xc0deb00c_market_swap)
    -  [Type Parameters](#@Type_Parameters_97)
    -  [Parameters](#@Parameters_98)
    -  [Returns](#@Returns_99)
    -  [Aborts](#@Aborts_100)
    -  [Expected value testing](#@Expected_value_testing_101)
    -  [Failure testing](#@Failure_testing_102)
-  [Function `index_orders`](#0xc0deb00c_market_index_orders)
    -  [Returns](#@Returns_103)
    -  [Testing](#@Testing_104)


<pre><code><b>use</b> <a href="">0x1::account</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="avl_queue.md#0xc0deb00c_avl_queue">0xc0deb00c::avl_queue</a>;
<b>use</b> <a href="incentives.md#0xc0deb00c_incentives">0xc0deb00c::incentives</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
<b>use</b> <a href="resource_account.md#0xc0deb00c_resource_account">0xc0deb00c::resource_account</a>;
<b>use</b> <a href="tablist.md#0xc0deb00c_tablist">0xc0deb00c::tablist</a>;
<b>use</b> <a href="user.md#0xc0deb00c_user">0xc0deb00c::user</a>;
</code></pre>



<a name="0xc0deb00c_market_MakerEvent"></a>

## Struct `MakerEvent`

Emitted when a maker order is placed, cancelled, evicted, or its
size is manually changed.


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>market_id: u64</code>
</dt>
<dd>
 Market ID of corresponding market.
</dd>
<dt>
<code>side: bool</code>
</dt>
<dd>
 <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>, the side of the maker order.
</dd>
<dt>
<code>market_order_id: u128</code>
</dt>
<dd>
 Market order ID, unique within given market.
</dd>
<dt>
<code><a href="user.md#0xc0deb00c_user">user</a>: <b>address</b></code>
</dt>
<dd>
 Address of user holding maker order.
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 For given maker, ID of custodian required to approve order
 operations and withdrawals on given market account.
</dd>
<dt>
<code>type: u8</code>
</dt>
<dd>
 <code><a href="market.md#0xc0deb00c_market_CANCEL">CANCEL</a></code>, <code><a href="market.md#0xc0deb00c_market_CHANGE">CHANGE</a></code>, <code><a href="market.md#0xc0deb00c_market_EVICT">EVICT</a></code>, or <code><a href="market.md#0xc0deb00c_market_PLACE">PLACE</a></code>, the event type.
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 The size, in lots, on the book after an order has been
 placed or its size has been manually changed. Else the size
 on the book before the order was cancelled or evicted.
</dd>
</dl>


<a name="0xc0deb00c_market_Order"></a>

## Struct `Order`

An order on the order book.


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_Order">Order</a> <b>has</b> store
</code></pre>



##### Fields


<dl>
<dt>
<code>size: u64</code>
</dt>
<dd>
 Number of lots to be filled.
</dd>
<dt>
<code><a href="user.md#0xc0deb00c_user">user</a>: <b>address</b></code>
</dt>
<dd>
 Address of user holding order.
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 For given user, ID of custodian required to approve order
 operations and withdrawals on given market account.
</dd>
<dt>
<code>order_access_key: u64</code>
</dt>
<dd>
 User-side access key for storage-optimized lookup.
</dd>
</dl>


<a name="0xc0deb00c_market_OrderBook"></a>

## Struct `OrderBook`

An order book for a given market. Contains
<code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a></code> field duplicates to reduce global storage
item queries against the registry.


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a> <b>has</b> store
</code></pre>



##### Fields


<dl>
<dt>
<code>base_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.base_type</code>.
</dd>
<dt>
<code>base_name_generic: <a href="_String">string::String</a></code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.base_name_generic</code>.
</dd>
<dt>
<code>quote_type: <a href="_TypeInfo">type_info::TypeInfo</a></code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.quote_type</code>.
</dd>
<dt>
<code>lot_size: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.lot_size</code>.
</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.tick_size</code>.
</dd>
<dt>
<code>min_size: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.min_size</code>.
</dd>
<dt>
<code>underwriter_id: u64</code>
</dt>
<dd>
 <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.underwriter_id</code>.
</dd>
<dt>
<code>asks: <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Asks AVL queue.
</dd>
<dt>
<code>bids: <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;<a href="market.md#0xc0deb00c_market_Order">market::Order</a>&gt;</code>
</dt>
<dd>
 Bids AVL queue.
</dd>
<dt>
<code>counter: u64</code>
</dt>
<dd>
 Cumulative number of maker orders placed on book.
</dd>
<dt>
<code>maker_events: <a href="_EventHandle">event::EventHandle</a>&lt;<a href="market.md#0xc0deb00c_market_MakerEvent">market::MakerEvent</a>&gt;</code>
</dt>
<dd>
 Event handle for maker events.
</dd>
<dt>
<code>taker_events: <a href="_EventHandle">event::EventHandle</a>&lt;<a href="market.md#0xc0deb00c_market_TakerEvent">market::TakerEvent</a>&gt;</code>
</dt>
<dd>
 Event handle for taker events.
</dd>
</dl>


<a name="0xc0deb00c_market_OrderBooks"></a>

## Resource `OrderBooks`

Order book map for all Econia order books.


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> <b>has</b> key
</code></pre>



##### Fields


<dl>
<dt>
<code>map: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;u64, <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>&gt;</code>
</dt>
<dd>
 Map from market ID to corresponding order book. Enables
 off-chain iterated indexing by market ID.
</dd>
</dl>


<a name="0xc0deb00c_market_TakerEvent"></a>

## Struct `TakerEvent`

Emitted when a taker order fills against a maker order. If a
taker order fills against multiple maker orders, a separate
event is emitted for each one.


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_TakerEvent">TakerEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>market_id: u64</code>
</dt>
<dd>
 Market ID of corresponding market.
</dd>
<dt>
<code>side: bool</code>
</dt>
<dd>
 <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>, the side of the maker order.
</dd>
<dt>
<code>market_order_id: u128</code>
</dt>
<dd>
 Order ID, unique within given market, of maker order just
 filled against.
</dd>
<dt>
<code>maker: <b>address</b></code>
</dt>
<dd>
 Address of user holding maker order.
</dd>
<dt>
<code>custodian_id: u64</code>
</dt>
<dd>
 For given maker, ID of custodian required to approve order
 operations and withdrawals on given market account.
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 The size filled, in lots.
</dd>
</dl>


<a name="0xc0deb00c_market_PricedOrder"></a>

## Struct `PricedOrder`

An order with price. Only for SDK generation.


<pre><code><b>struct</b> <a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a> <b>has</b> store
</code></pre>



##### Fields


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>
 Price of order from order book AVL queue.
</dd>
<dt>
<code>order: <a href="market.md#0xc0deb00c_market_Order">market::Order</a></code>
</dt>
<dd>
 Order from order book AVL queue.
</dd>
</dl>


<a name="@Constants_18"></a>

## Constants


<a name="0xc0deb00c_market_ASCENDING"></a>

Ascending AVL queue flag, for asks AVL queue.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_ASCENDING">ASCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_DESCENDING"></a>

Descending AVL queue flag, for bids AVL queue.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_DESCENDING">DESCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_HI_64"></a>

<code>u64</code> bitmask with all bits set, generated in Python via
<code>hex(int('1' * 64, 2))</code>.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_market_NIL"></a>

Flag for null value when null defined as 0.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NIL">NIL</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_BUY"></a>

Flag for buy direction.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BUY">BUY</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_SELL"></a>

Flag for sell direction.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_SELL">SELL</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_BASE"></a>

Base asset type is invalid.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_BASE">E_INVALID_BASE</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_MARKET_ID"></a>

No market with given ID.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_QUOTE"></a>

Quote asset type is invalid.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_QUOTE">E_INVALID_QUOTE</a>: u64 = 8;
</code></pre>



<a name="0xc0deb00c_market_NO_CUSTODIAN"></a>

Custodian ID flag for no custodian.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_NO_UNDERWRITER"></a>

Underwriter ID flag for no underwriter.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NO_UNDERWRITER">NO_UNDERWRITER</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_ASK"></a>

Flag for ask side.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_market_BID"></a>

Flag for bid side.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_BID">BID</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_MARKET_ORDER_ID"></a>

Market order ID invalid.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ORDER_ID">E_INVALID_MARKET_ORDER_ID</a>: u64 = 22;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_UNDERWRITER"></a>

Underwriter invalid for given market.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a>: u64 = 21;
</code></pre>



<a name="0xc0deb00c_market_E_NOT_ENOUGH_ASSET_OUT"></a>

Not enough asset to trade away.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_NOT_ENOUGH_ASSET_OUT">E_NOT_ENOUGH_ASSET_OUT</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_market_E_OVERFLOW_ASSET_IN"></a>

Filling order would overflow asset received from trade.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_OVERFLOW_ASSET_IN">E_OVERFLOW_ASSET_IN</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_market_E_PRICE_0"></a>

Order price specified as 0.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_PRICE_0">E_PRICE_0</a>: u64 = 11;
</code></pre>



<a name="0xc0deb00c_market_E_PRICE_TOO_HIGH"></a>

Order price exceeds maximum allowable price.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_PRICE_TOO_HIGH">E_PRICE_TOO_HIGH</a>: u64 = 12;
</code></pre>



<a name="0xc0deb00c_market_MAX_PRICE"></a>

Maximum possible price that can be encoded in 32 bits. Generated
in Python via <code>hex(int('1' * 32, 2))</code>.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MAX_PRICE">MAX_PRICE</a>: u64 = 4294967295;
</code></pre>



<a name="0xc0deb00c_market_CANCEL"></a>

Flag for <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>.type</code> when order is cancelled.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_CANCEL">CANCEL</a>: u8 = 0;
</code></pre>



<a name="0xc0deb00c_market_CHANGE"></a>

Flag for <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>.type</code> when order size is changed.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_CHANGE">CHANGE</a>: u8 = 1;
</code></pre>



<a name="0xc0deb00c_market_CRITICAL_HEIGHT"></a>

Critical tree height above which evictions may take place.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_CRITICAL_HEIGHT">CRITICAL_HEIGHT</a>: u8 = 10;
</code></pre>



<a name="0xc0deb00c_market_EVICT"></a>

Flag for <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>.type</code> when order is evicted.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_EVICT">EVICT</a>: u8 = 2;
</code></pre>



<a name="0xc0deb00c_market_E_FILL_OR_ABORT_NOT_CROSS_SPREAD"></a>

Fill-or-abort price does not cross the spread.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_FILL_OR_ABORT_NOT_CROSS_SPREAD">E_FILL_OR_ABORT_NOT_CROSS_SPREAD</a>: u64 = 25;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_CUSTODIAN"></a>

Custodian not authorized for operation.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>: u64 = 23;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_RESTRICTION"></a>

Invalid restriction flag.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_RESTRICTION">E_INVALID_RESTRICTION</a>: u64 = 18;
</code></pre>



<a name="0xc0deb00c_market_E_INVALID_USER"></a>

Invalid user indicated for operation.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>: u64 = 24;
</code></pre>



<a name="0xc0deb00c_market_E_MAX_BASE_0"></a>

Maximum base trade amount specified as 0.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MAX_BASE_0">E_MAX_BASE_0</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_market_E_MAX_QUOTE_0"></a>

Maximum quote trade amount specified as 0.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MAX_QUOTE_0">E_MAX_QUOTE_0</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX"></a>

Minimum base trade amount exceeds maximum base trade amount.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX">E_MIN_BASE_EXCEEDS_MAX</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_BASE_NOT_TRADED"></a>

Minimum base asset trade amount requirement not met.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_BASE_NOT_TRADED">E_MIN_BASE_NOT_TRADED</a>: u64 = 9;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX"></a>

Minimum quote trade amount exceeds maximum quote trade amount.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX">E_MIN_QUOTE_EXCEEDS_MAX</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_market_E_MIN_QUOTE_NOT_TRADED"></a>

Minimum quote coin trade amount requirement not met.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_NOT_TRADED">E_MIN_QUOTE_NOT_TRADED</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_market_E_POST_OR_ABORT_CROSSES_SPREAD"></a>

Post-or-abort limit order price crosses spread.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSES_SPREAD">E_POST_OR_ABORT_CROSSES_SPREAD</a>: u64 = 13;
</code></pre>



<a name="0xc0deb00c_market_E_PRICE_TIME_PRIORITY_TOO_LOW"></a>

No room to insert order with such low price-time priority.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_PRICE_TIME_PRIORITY_TOO_LOW">E_PRICE_TIME_PRIORITY_TOO_LOW</a>: u64 = 20;
</code></pre>



<a name="0xc0deb00c_market_E_SELF_MATCH"></a>

Taker and maker have same address.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SELF_MATCH">E_SELF_MATCH</a>: u64 = 19;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_BASE_OVERFLOW"></a>

Limit order size results in base asset amount overflow.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_BASE_OVERFLOW">E_SIZE_BASE_OVERFLOW</a>: u64 = 15;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_PRICE_QUOTE_OVERFLOW"></a>

Limit order size and price results in quote amount overflow.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_PRICE_QUOTE_OVERFLOW">E_SIZE_PRICE_QUOTE_OVERFLOW</a>: u64 = 17;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_PRICE_TICKS_OVERFLOW"></a>

Limit order size and price results in ticks amount overflow.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_PRICE_TICKS_OVERFLOW">E_SIZE_PRICE_TICKS_OVERFLOW</a>: u64 = 16;
</code></pre>



<a name="0xc0deb00c_market_E_SIZE_TOO_SMALL"></a>

Limit order size does not meet minimum size for market.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_E_SIZE_TOO_SMALL">E_SIZE_TOO_SMALL</a>: u64 = 14;
</code></pre>



<a name="0xc0deb00c_market_FILL_OR_ABORT"></a>

Flag for fill-or-abort order restriction.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_FILL_OR_ABORT">FILL_OR_ABORT</a>: u8 = 1;
</code></pre>



<a name="0xc0deb00c_market_HI_PRICE"></a>

All bits set in integer of width required to encode price.
Generated in Python via <code>hex(int('1' * 32, 2))</code>.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_HI_PRICE">HI_PRICE</a>: u64 = 4294967295;
</code></pre>



<a name="0xc0deb00c_market_IMMEDIATE_OR_CANCEL"></a>

Flag for immediate-or-cancel order restriction.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_IMMEDIATE_OR_CANCEL">IMMEDIATE_OR_CANCEL</a>: u8 = 2;
</code></pre>



<a name="0xc0deb00c_market_MAX_POSSIBLE"></a>

Flag to trade max possible asset amount: <code>u64</code> bitmask with all
bits set, generated in Python via <code>hex(int('1' * 64, 2))</code>.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_market_NO_RESTRICTION"></a>

Flag for no order restriction.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_NO_RESTRICTION">NO_RESTRICTION</a>: u8 = 0;
</code></pre>



<a name="0xc0deb00c_market_N_RESTRICTIONS"></a>

Number of restriction flags.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_N_RESTRICTIONS">N_RESTRICTIONS</a>: u8 = 3;
</code></pre>



<a name="0xc0deb00c_market_PLACE"></a>

Flag for <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>.type</code> when order is placed.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_PLACE">PLACE</a>: u8 = 3;
</code></pre>



<a name="0xc0deb00c_market_POST_OR_ABORT"></a>

Flag for post-or-abort order restriction.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_POST_OR_ABORT">POST_OR_ABORT</a>: u8 = 3;
</code></pre>



<a name="0xc0deb00c_market_SHIFT_COUNTER"></a>

Number of bits maker order counter is shifted in a market order
ID.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_SHIFT_COUNTER">SHIFT_COUNTER</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_market_UNKNOWN_TAKER"></a>

Taker address flag for when taker is unknown.


<pre><code><b>const</b> <a href="market.md#0xc0deb00c_market_UNKNOWN_TAKER">UNKNOWN_TAKER</a>: <b>address</b> = 0;
</code></pre>



<a name="0xc0deb00c_market_cancel_all_orders_custodian"></a>

## Function `cancel_all_orders_custodian`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>()</code> for cancelling
orders under authority of delegated custodian.


<a name="@Invocation_testing_19"></a>

### Invocation testing


* <code>test_cancel_all_orders_ask_custodian()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_orders_custodian">cancel_all_orders_custodian</a>(user_address: <b>address</b>, market_id: u64, side: bool, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_orders_custodian">cancel_all_orders_custodian</a>(
    user_address: <b>address</b>,
    market_id: u64,
    side: bool,
    custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        side);
}
</code></pre>



<a name="0xc0deb00c_market_cancel_order_custodian"></a>

## Function `cancel_order_custodian`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code> for cancelling
order under authority of delegated custodian.


<a name="@Invocation_testing_20"></a>

### Invocation testing


* <code>test_cancel_order_ask_custodian()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_order_custodian">cancel_order_custodian</a>(user_address: <b>address</b>, market_id: u64, side: bool, market_order_id: u128, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_order_custodian">cancel_order_custodian</a>(
    user_address: <b>address</b>,
    market_id: u64,
    side: bool,
    market_order_id: u128,
    custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        side,
        market_order_id);
}
</code></pre>



<a name="0xc0deb00c_market_change_order_size_custodian"></a>

## Function `change_order_size_custodian`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>()</code> for changing
order size under authority of delegated custodian.


<a name="@Invocation_testing_21"></a>

### Invocation testing


* <code>test_change_order_size_ask_custodian()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_change_order_size_custodian">change_order_size_custodian</a>(user_address: <b>address</b>, market_id: u64, side: bool, market_order_id: u128, new_size: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_change_order_size_custodian">change_order_size_custodian</a>(
    user_address: <b>address</b>,
    market_id: u64,
    side: bool,
    market_order_id: u128,
    new_size: u64,
    custodian_capability_ref: &CustodianCapability
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        side,
        market_order_id,
        new_size);
}
</code></pre>



<a name="0xc0deb00c_market_place_limit_order_custodian"></a>

## Function `place_limit_order_custodian`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code> for placing
order under authority of delegated custodian.


<a name="@Invocation_and_return_testing_22"></a>

### Invocation and return testing


* <code>test_place_limit_order_no_cross_bid_custodian()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>&lt;BaseType, QuoteType&gt;(user_address: <b>address</b>, market_id: u64, integrator: <b>address</b>, side: bool, size: u64, price: u64, restriction: u8, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): (u128, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_custodian">place_limit_order_custodian</a>&lt;
    BaseType,
    QuoteType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    integrator: <b>address</b>,
    side: bool,
    size: u64,
    price: u64,
    restriction: u8,
    custodian_capability_ref: &CustodianCapability
): (
    u128,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;
        BaseType,
        QuoteType
    &gt;(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        integrator,
        side,
        size,
        price,
        restriction,
        <a href="market.md#0xc0deb00c_market_CRITICAL_HEIGHT">CRITICAL_HEIGHT</a>)
}
</code></pre>



<a name="0xc0deb00c_market_place_limit_order_user"></a>

## Function `place_limit_order_user`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>()</code> for placing
order under authority of signing user.


<a name="@Invocation_and_return_testing_23"></a>

### Invocation and return testing


* <code>test_place_limit_order_crosses_ask_exact()</code>
* <code>test_place_limit_order_crosses_ask_partial()</code>
* <code>test_place_limit_order_crosses_ask_partial_cancel()</code>
* <code>test_place_limit_order_crosses_bid_exact()</code>
* <code>test_place_limit_order_crosses_bid_partial()</code>
* <code>test_place_limit_order_evict()</code>
* <code>test_place_limit_order_no_cross_ask_user()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, integrator: <b>address</b>, side: bool, size: u64, price: u64, restriction: u8): (u128, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    integrator: <b>address</b>,
    side: bool,
    size: u64,
    price: u64,
    restriction: u8,
): (
    u128,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;
        BaseType,
        QuoteType
    &gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        integrator,
        side,
        size,
        price,
        restriction,
        <a href="market.md#0xc0deb00c_market_CRITICAL_HEIGHT">CRITICAL_HEIGHT</a>)
}
</code></pre>



<a name="0xc0deb00c_market_place_market_order_custodian"></a>

## Function `place_market_order_custodian`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>()</code> for placing
order under authority of delegated custodian.


<a name="@Invocation_and_return_testing_24"></a>

### Invocation and return testing


* <code>test_place_market_order_max_base_sell_custodian()</code>
* <code>test_place_market_order_max_quote_buy_custodian()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>&lt;BaseType, QuoteType&gt;(user_address: <b>address</b>, market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, custodian_capability_ref: &<a href="registry.md#0xc0deb00c_registry_CustodianCapability">registry::CustodianCapability</a>): (u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_custodian">place_market_order_custodian</a>&lt;
    BaseType,
    QuoteType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    custodian_capability_ref: &CustodianCapability
): (
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;BaseType, QuoteType&gt;(
        user_address,
        market_id,
        <a href="registry.md#0xc0deb00c_registry_get_custodian_id">registry::get_custodian_id</a>(custodian_capability_ref),
        integrator,
        direction,
        min_base,
        max_base,
        min_quote,
        max_quote,
        limit_price)
}
</code></pre>



<a name="0xc0deb00c_market_place_market_order_user"></a>

## Function `place_market_order_user`

Public function wrapper for <code><a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>()</code> for placing
order under authority of signing user.


<a name="@Invocation_and_return_testing_25"></a>

### Invocation and return testing


* <code>test_place_market_order_max_base_buy_user()</code>
* <code>test_place_market_order_max_quote_sell_user()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64): (u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
): (
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;BaseType, QuoteType&gt;(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        integrator,
        direction,
        min_base,
        max_base,
        min_quote,
        max_quote,
        limit_price)
}
</code></pre>



<a name="0xc0deb00c_market_register_market_base_coin"></a>

## Function `register_market_base_coin`

Register pure coin market, return resultant market ID.

See inner function <code><a href="market.md#0xc0deb00c_market_register_market">register_market</a>()</code>.


<a name="@Type_parameters_26"></a>

### Type parameters


* <code>BaseType</code>: Base coin type for market.
* <code>QuoteType</code>: Quote coin type for market.
* <code>UtilityType</code>: Utility coin type, specified at
<code><a href="incentives.md#0xc0deb00c_incentives_IncentiveParameters">incentives::IncentiveParameters</a>.utility_coin_type_info</code>.


<a name="@Parameters_27"></a>

### Parameters


* <code>lot_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.lot_size</code> for market.
* <code>tick_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.tick_size</code> for market.
* <code>min_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.min_size</code> for market.
* <code>utility_coins</code>: Utility coins paid to register a market. See
<code><a href="incentives.md#0xc0deb00c_incentives_IncentiveParameters">incentives::IncentiveParameters</a>.market_registration_fee</code>.


<a name="@Returns_28"></a>

### Returns


* <code>u64</code>: Market ID for new market.


<a name="@Testing_29"></a>

### Testing


* <code>test_register_markets()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_base_coin">register_market_base_coin</a>&lt;BaseType, QuoteType, UtilityType&gt;(lot_size: u64, tick_size: u64, min_size: u64, utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityType&gt;): u64
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_base_coin">register_market_base_coin</a>&lt;
    BaseType,
    QuoteType,
    UtilityType
&gt;(
    lot_size: u64,
    tick_size: u64,
    min_size: u64,
    utility_coins: Coin&lt;UtilityType&gt;
): u64
<b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Register <a href="market.md#0xc0deb00c_market">market</a> in <b>global</b> <a href="registry.md#0xc0deb00c_registry">registry</a>, storing <a href="market.md#0xc0deb00c_market">market</a> ID.
    <b>let</b> market_id = <a href="registry.md#0xc0deb00c_registry_register_market_base_coin_internal">registry::register_market_base_coin_internal</a>&lt;
        BaseType, QuoteType, UtilityType&gt;(lot_size, tick_size, min_size,
        utility_coins);
    // Register order book and quote <a href="">coin</a> fee store, <b>return</b> <a href="market.md#0xc0deb00c_market">market</a>
    // ID.
    <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseType, QuoteType&gt;(
        market_id, <a href="_utf8">string::utf8</a>(b""), lot_size, tick_size, min_size,
        <a href="market.md#0xc0deb00c_market_NO_UNDERWRITER">NO_UNDERWRITER</a>)
}
</code></pre>



<a name="0xc0deb00c_market_register_market_base_generic"></a>

## Function `register_market_base_generic`

Register generic market, return resultant market ID.

See inner function <code><a href="market.md#0xc0deb00c_market_register_market">register_market</a>()</code>.

Generic base name restrictions described at
<code><a href="registry.md#0xc0deb00c_registry_register_market_base_generic_internal">registry::register_market_base_generic_internal</a>()</code>.


<a name="@Type_parameters_30"></a>

### Type parameters


* <code>QuoteType</code>: Quote coin type for market.
* <code>UtilityType</code>: Utility coin type, specified at
<code><a href="incentives.md#0xc0deb00c_incentives_IncentiveParameters">incentives::IncentiveParameters</a>.utility_coin_type_info</code>.


<a name="@Parameters_31"></a>

### Parameters


* <code>base_name_generic</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.base_name_generic</code>
for market.
* <code>lot_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.lot_size</code> for market.
* <code>tick_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.tick_size</code> for market.
* <code>min_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.min_size</code> for market.
* <code>utility_coins</code>: Utility coins paid to register a market. See
<code><a href="incentives.md#0xc0deb00c_incentives_IncentiveParameters">incentives::IncentiveParameters</a>.market_registration_fee</code>.
* <code>underwriter_capability_ref</code>: Immutable reference to market
underwriter capability.


<a name="@Returns_32"></a>

### Returns


* <code>u64</code>: Market ID for new market.


<a name="@Testing_33"></a>

### Testing


* <code>test_register_markets()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_base_generic">register_market_base_generic</a>&lt;QuoteType, UtilityType&gt;(base_name_generic: <a href="_String">string::String</a>, lot_size: u64, tick_size: u64, min_size: u64, utility_coins: <a href="_Coin">coin::Coin</a>&lt;UtilityType&gt;, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>): u64
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_base_generic">register_market_base_generic</a>&lt;
    QuoteType,
    UtilityType
&gt;(
    base_name_generic: String,
    lot_size: u64,
    tick_size: u64,
    min_size: u64,
    utility_coins: Coin&lt;UtilityType&gt;,
    underwriter_capability_ref: &UnderwriterCapability
): u64
<b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Register <a href="market.md#0xc0deb00c_market">market</a> in <b>global</b> <a href="registry.md#0xc0deb00c_registry">registry</a>, storing <a href="market.md#0xc0deb00c_market">market</a> ID.
    <b>let</b> market_id = <a href="registry.md#0xc0deb00c_registry_register_market_base_generic_internal">registry::register_market_base_generic_internal</a>&lt;
        QuoteType, UtilityType&gt;(base_name_generic, lot_size, tick_size,
        min_size, underwriter_capability_ref, utility_coins);
    // Register order book and quote <a href="">coin</a> fee store, <b>return</b> <a href="market.md#0xc0deb00c_market">market</a>
    // ID.
    <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;GenericAsset, QuoteType&gt;(
        market_id, base_name_generic, lot_size, tick_size, min_size,
        <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">registry::get_underwriter_id</a>(underwriter_capability_ref))
}
</code></pre>



<a name="0xc0deb00c_market_swap_between_coinstores"></a>

## Function `swap_between_coinstores`

Swap against the order book between a user's coin stores.

Initializes an <code>aptos_framework::coin::CoinStore</code> for each coin
type that does not yet have one.


<a name="@Type_Parameters_34"></a>

### Type Parameters


* <code>BaseType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>QuoteType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Parameters_35"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Account of swapping user.
* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>integrator</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>direction</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. If passed as <code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code>
will attempt to trade maximum possible amount for coin store.
* <code>min_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. If passed as
<code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code> will attempt to trade maximum possible amount
for coin store.
* <code>limit_price</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Returns_36"></a>

### Returns


* <code>u64</code>: Base asset trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin fees paid, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Testing_37"></a>

### Testing


* <code>test_swap_between_coinstores_max_possible_base_buy()</code>
* <code>test_swap_between_coinstores_max_possible_base_sell()</code>
* <code>test_swap_between_coinstores_max_possible_quote_buy()</code>
* <code>test_swap_between_coinstores_max_possible_quote_sell()</code>
* <code>test_swap_between_coinstores_register_base_store()</code>
* <code>test_swap_between_coinstores_register_quote_store()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64): (u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64
): (
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> user_address = address_of(<a href="user.md#0xc0deb00c_user">user</a>); // Get <a href="user.md#0xc0deb00c_user">user</a> <b>address</b>.
    // Register base <a href="">coin</a> store <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> does not have one.
    <b>if</b> (!<a href="_is_account_registered">coin::is_account_registered</a>&lt;BaseType&gt;(user_address))
        <a href="_register">coin::register</a>&lt;BaseType&gt;(<a href="user.md#0xc0deb00c_user">user</a>);
    // Register quote <a href="">coin</a> store <b>if</b> <a href="user.md#0xc0deb00c_user">user</a> does not have one.
    <b>if</b> (!<a href="_is_account_registered">coin::is_account_registered</a>&lt;QuoteType&gt;(user_address))
        <a href="_register">coin::register</a>&lt;QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>);
    <b>let</b> (base_value, quote_value) = // Get <a href="">coin</a> value amounts.
        (<a href="_balance">coin::balance</a>&lt;BaseType&gt;(user_address),
         <a href="_balance">coin::balance</a>&lt;QuoteType&gt;(user_address));
    // If max base <b>to</b> trade flagged <b>as</b> max possible, <b>update</b> it:
    <b>if</b> (max_base == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_base = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        // If a buy, max <b>to</b> trade is amount that can fit in
        // <a href="">coin</a> store, <b>else</b> is the amount in the <a href="">coin</a> store.
        (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - base_value) <b>else</b> base_value;
    // If max quote <b>to</b> trade flagged <b>as</b> max possible, <b>update</b> it:
    <b>if</b> (max_quote == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_quote = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        // If a buy, max <b>to</b> trade is amount in <a href="">coin</a> store, <b>else</b> is
        // the amount that could fit in the <a href="">coin</a> store.
        quote_value <b>else</b> (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - quote_value);
    <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>( // Range check trade amounts.
        direction, min_base, max_base, min_quote, max_quote,
        base_value, base_value, quote_value, quote_value);
    // Get <a href="">option</a>-wrapped base coins and quote coins for matching:
    <b>let</b> (optional_base_coins, quote_coins) = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        // If a buy, need no base but need max quote.
        (<a href="_some">option::some</a>(<a href="_zero">coin::zero</a>&lt;BaseType&gt;()),
         <a href="_withdraw">coin::withdraw</a>&lt;QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, max_quote)) <b>else</b>
        // If a sell, need max base but not quote.
        (<a href="_some">option::some</a>(<a href="_withdraw">coin::withdraw</a>&lt;BaseType&gt;(<a href="user.md#0xc0deb00c_user">user</a>, max_base)),
         <a href="_zero">coin::zero</a>&lt;QuoteType&gt;());
    // Swap against order book, storing modified <a href="">coin</a> inputs, base
    // and quote trade amounts, and quote fees paid.
    <b>let</b> (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
        = <a href="market.md#0xc0deb00c_market_swap">swap</a>(market_id, <a href="market.md#0xc0deb00c_market_NO_UNDERWRITER">NO_UNDERWRITER</a>, user_address, integrator,
               direction, min_base, max_base, min_quote, max_quote,
               limit_price, optional_base_coins, quote_coins);
    // Deposit base coins back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="">coin</a> store.
    <a href="_deposit">coin::deposit</a>(user_address, <a href="_destroy_some">option::destroy_some</a>(optional_base_coins));
    // Deposit quote coins back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="">coin</a> store.
    <a href="_deposit">coin::deposit</a>(user_address, quote_coins);
    (base_traded, quote_traded, fees) // Return match results.
}
</code></pre>



<a name="0xc0deb00c_market_swap_coins"></a>

## Function `swap_coins`

Swap standalone coins against the order book.

If a buy, attempts to spend all quote coins. If a sell, attempts
to sell all base coins.

Passes all base coins to matching engine if a buy or a sell, and
passes all quote coins to matching engine if a buy. If a sell,
does not pass any quote coins to matching engine, to avoid
intermediate quote match overflow that could occur prior to fee
assessment.


<a name="@Type_Parameters_38"></a>

### Type Parameters


* <code>BaseType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>QuoteType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Parameters_39"></a>

### Parameters


* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>integrator</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>direction</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. Ignored if a sell. Else if
passed as <code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code> will attempt to trade maximum
possible amount for passed coin holdings.
* <code>min_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. Ignored if a buy. Else if
passed as <code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code> will attempt to trade maximum
possible amount for passed coin holdings.
* <code>limit_price</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>base_coins</code>: Same as <code>optional_base_coins</code> for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, but
unpacked.
* <code>quote_coins</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Returns_40"></a>

### Returns


* <code>Coin&lt;BaseType&gt;</code>: Updated base coin holdings, same as for
<code><a href="market.md#0xc0deb00c_market_match">match</a>()</code> but unpacked.
* <code>Coin&lt;QuoteType&gt;</code>: Updated quote coin holdings, same as for
<code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Base coin trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin fees paid, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Terminology_41"></a>

### Terminology


* The "inbound" asset is the asset received from a trade: base
coins in the case of a buy, quote coins in the case of a sell.
* The "outbound" asset is the asset traded away: quote coins in
the case of a buy, base coins in the case of a sell.


<a name="@Testing_42"></a>

### Testing


* <code>test_swap_coins_buy_max_base_limiting()</code>
* <code>test_swap_coins_buy_no_max_quote_limiting()</code>
* <code>test_swap_coins_buy_no_max_base_limiting()</code>
* <code>test_swap_coins_sell_max_quote_limiting()</code>
* <code>test_swap_coins_sell_no_max_base_limiting()</code>
* <code>test_swap_coins_sell_no_max_quote_limiting()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>&lt;BaseType, QuoteType&gt;(market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, base_coins: <a href="_Coin">coin::Coin</a>&lt;BaseType&gt;, quote_coins: <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;): (<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;, <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    base_coins: Coin&lt;BaseType&gt;,
    quote_coins: Coin&lt;QuoteType&gt;
): (
    Coin&lt;BaseType&gt;,
    Coin&lt;QuoteType&gt;,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> (base_value, quote_value) = // Get <a href="">coin</a> value amounts.
        (<a href="_value">coin::value</a>(&base_coins), <a href="_value">coin::value</a>(&quote_coins));
    // Get <a href="">option</a> wrapped base coins.
    <b>let</b> optional_base_coins = <a href="_some">option::some</a>(base_coins);
    // Get quote coins <b>to</b> route through matching engine and <b>update</b>
    // max match amounts based on side. If a swap buy:
    <b>let</b> quote_coins_to_match = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) {
        // Max quote <b>to</b> trade is amount passed in.
        max_quote = quote_value;
        // If max base amount <b>to</b> trade is max possible flag, <b>update</b>
        // <b>to</b> max amount that can be received.
        <b>if</b> (max_base == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_base = (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - base_value);
        // Pass all quote coins <b>to</b> matching engine.
        <a href="_extract">coin::extract</a>(&<b>mut</b> quote_coins, max_quote)
    } <b>else</b> { // If a swap sell:
        // Max base <b>to</b> trade is amount passed in.
        max_base = base_value;
        // If max quote amount <b>to</b> trade is max possible flag, <b>update</b>
        // <b>to</b> max amount that can be received.
        <b>if</b> (max_quote == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_quote = (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - quote_value);
        // Do not pass <a href="">any</a> quote coins <b>to</b> matching engine.
        <a href="_zero">coin::zero</a>()
    };
    <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>( // Range check trade amounts.
        direction, min_base, max_base, min_quote, max_quote,
        base_value, base_value, quote_value, quote_value);
    // Swap against order book, storing modified <a href="">coin</a> inputs, base
    // and quote trade amounts, and quote fees paid.
    <b>let</b> (optional_base_coins, quote_coins_matched, base_traded,
         quote_traded, fees) = <a href="market.md#0xc0deb00c_market_swap">swap</a>(
            market_id, <a href="market.md#0xc0deb00c_market_NO_UNDERWRITER">NO_UNDERWRITER</a>, <a href="market.md#0xc0deb00c_market_UNKNOWN_TAKER">UNKNOWN_TAKER</a>, integrator,
            direction, min_base, max_base, min_quote, max_quote,
            limit_price, optional_base_coins, quote_coins_to_match);
    // Merge matched quote coins back into holdings.
    <a href="_merge">coin::merge</a>(&<b>mut</b> quote_coins, quote_coins_matched);
    // Get base coins from <a href="">option</a>.
    <b>let</b> base_coins = <a href="_destroy_some">option::destroy_some</a>(optional_base_coins);
    // Return all coins.
    (base_coins, quote_coins, base_traded, quote_traded, fees)
}
</code></pre>



<a name="0xc0deb00c_market_swap_generic"></a>

## Function `swap_generic`

Swap against the order book for a generic market, under
authority of market underwriter.

Passes all quote coins to matching engine if a buy. If a sell,
does not pass any quote coins to matching engine, to avoid
intermediate quote match overflow that could occur prior to fee
assessment.


<a name="@Type_Parameters_43"></a>

### Type Parameters


* <code>QuoteType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Parameters_44"></a>

### Parameters


* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>integrator</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>direction</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. Ignored if a buy. Else if
passed as <code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code> will attempt to trade maximum
possible amount for passed coin holdings.
* <code>limit_price</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>quote_coins</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>underwriter_capability_ref</code>: Immutable reference to
underwriter capability for given market.


<a name="@Returns_45"></a>

### Returns


* <code>Coin&lt;QuoteType&gt;</code>: Updated quote coin holdings, same as for
<code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Base asset trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin fees paid, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Testing_46"></a>

### Testing


* <code>test_swap_generic_buy_base_limiting()</code>
* <code>test_swap_generic_buy_quote_limiting()</code>
* <code>test_swap_generic_sell_max_quote_limiting()</code>
* <code>test_swap_generic_sell_no_max_base_limiting()</code>
* <code>test_swap_generic_sell_no_max_quote_limiting()</code>


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>&lt;QuoteType&gt;(market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, quote_coins: <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;, underwriter_capability_ref: &<a href="registry.md#0xc0deb00c_registry_UnderwriterCapability">registry::UnderwriterCapability</a>): (<a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>&lt;
    QuoteType
&gt;(
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    quote_coins: Coin&lt;QuoteType&gt;,
    underwriter_capability_ref: &UnderwriterCapability
): (
    Coin&lt;QuoteType&gt;,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <b>let</b> underwriter_id = // Get underwriter ID.
        <a href="registry.md#0xc0deb00c_registry_get_underwriter_id">registry::get_underwriter_id</a>(underwriter_capability_ref);
    // Get quote <a href="">coin</a> value.
    <b>let</b> quote_value = <a href="_value">coin::value</a>(&quote_coins);
    // Get base asset value holdings and quote coins <b>to</b> route
    // through matching engine, and <b>update</b> max match amounts based
    // on side. If a swap buy:
    <b>let</b> (base_value, quote_coins_to_match) = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) {
        // Max quote <b>to</b> trade is amount passed in.
        max_quote = quote_value;
        // Do not pass in base asset, and pass all quote coins <b>to</b>
        // matching engine.
        (0, <a href="_extract">coin::extract</a>(&<b>mut</b> quote_coins, max_quote))
    } <b>else</b> { // If a swap sell:
        // If max quote amount <b>to</b> trade is max possible flag, <b>update</b>
        // <b>to</b> max amount that can be received.
        <b>if</b> (max_quote == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_quote = (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - quote_value);
        // Effective base asset holdings are max trade amount, do
        // not pass and quote coins <b>to</b> matching engine.
        (max_base, <a href="_zero">coin::zero</a>())
    };
    <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>( // Range check trade amounts.
        direction, min_base, max_base, min_quote, max_quote,
        base_value, base_value, quote_value, quote_value);
    // Swap against order book, storing modified quote <a href="">coin</a> input,
    // base and quote trade amounts, and quote fees paid.
    <b>let</b> (optional_base_coins, quote_coins_matched, base_traded,
         quote_traded, fees) = <a href="market.md#0xc0deb00c_market_swap">swap</a>(
            market_id, underwriter_id, <a href="market.md#0xc0deb00c_market_UNKNOWN_TAKER">UNKNOWN_TAKER</a>, integrator,
            direction, min_base, max_base, min_quote, max_quote,
            limit_price, <a href="_none">option::none</a>(), quote_coins_to_match);
    // Destroy empty base <a href="">coin</a> <a href="">option</a>.
    <a href="_destroy_none">option::destroy_none</a>&lt;Coin&lt;GenericAsset&gt;&gt;(optional_base_coins);
    // Merge matched quote coins back into holdings.
    <a href="_merge">coin::merge</a>(&<b>mut</b> quote_coins, quote_coins_matched);
    // Return quote coins, amount of base traded, amount of quote
    // traded, and quote fees paid.
    (quote_coins, base_traded, quote_traded, fees)
}
</code></pre>



<a name="0xc0deb00c_market_cancel_all_orders_user"></a>

## Function `cancel_all_orders_user`

Public entry function wrapper for <code><a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>()</code> for
cancelling orders under authority of signing user.


<a name="@Invocation_testing_47"></a>

### Invocation testing


* <code>test_cancel_all_orders_bid_user()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_orders_user">cancel_all_orders_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, side: bool)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_orders_user">cancel_all_orders_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    side: bool,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side);
}
</code></pre>



<a name="0xc0deb00c_market_cancel_order_user"></a>

## Function `cancel_order_user`

Public entry function wrapper for <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code> for
cancelling order under authority of signing user.


<a name="@Invocation_testing_48"></a>

### Invocation testing


* <code>test_cancel_order_bid_user()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_order_user">cancel_order_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, side: bool, market_order_id: u128)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_order_user">cancel_order_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    side: bool,
    market_order_id: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
        market_order_id);
}
</code></pre>



<a name="0xc0deb00c_market_change_order_size_user"></a>

## Function `change_order_size_user`

Public entry function wrapper for <code><a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>()</code> for
changing order size under authority of signing user.


<a name="@Invocation_testing_49"></a>

### Invocation testing


* <code>test_change_order_size_bid_user()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_change_order_size_user">change_order_size_user</a>(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, side: bool, market_order_id: u128, new_size: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_change_order_size_user">change_order_size_user</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    side: bool,
    market_order_id: u128,
    new_size: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>(
        address_of(<a href="user.md#0xc0deb00c_user">user</a>),
        market_id,
        <a href="market.md#0xc0deb00c_market_NO_CUSTODIAN">NO_CUSTODIAN</a>,
        side,
        market_order_id,
        new_size);
}
</code></pre>



<a name="0xc0deb00c_market_place_limit_order_user_entry"></a>

## Function `place_limit_order_user_entry`

Public entry function wrapper for <code><a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>()</code>.


<a name="@Invocation_testing_50"></a>

### Invocation testing


* <code>test_place_limit_order_user_entry()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user_entry">place_limit_order_user_entry</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, integrator: <b>address</b>, side: bool, size: u64, price: u64, restriction: u8)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order_user_entry">place_limit_order_user_entry</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    integrator: <b>address</b>,
    side: bool,
    size: u64,
    price: u64,
    restriction: u8,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_limit_order_user">place_limit_order_user</a>&lt;BaseType, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, integrator, side, size, price, restriction);
}
</code></pre>



<a name="0xc0deb00c_market_place_market_order_user_entry"></a>

## Function `place_market_order_user_entry`

Public entry function wrapper for <code><a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>()</code>.


<a name="@Invocation_testing_51"></a>

### Invocation testing


* <code>test_place_market_order_user_entry()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_user_entry">place_market_order_user_entry</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order_user_entry">place_market_order_user_entry</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_place_market_order_user">place_market_order_user</a>&lt;BaseType, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, integrator, direction, min_base, max_base,
        min_quote, max_quote, limit_price);
}
</code></pre>



<a name="0xc0deb00c_market_register_market_base_coin_from_coinstore"></a>

## Function `register_market_base_coin_from_coinstore`

Wrapped call to <code><a href="market.md#0xc0deb00c_market_register_market_base_coin">register_market_base_coin</a>()</code> for paying utility
coins from an <code>aptos_framework::coin::CoinStore</code>.


<a name="@Testing_52"></a>

### Testing


* <code>test_register_markets()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore">register_market_base_coin_from_coinstore</a>&lt;BaseType, QuoteType, UtilityType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, lot_size: u64, tick_size: u64, min_size: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_register_market_base_coin_from_coinstore">register_market_base_coin_from_coinstore</a>&lt;
    BaseType,
    QuoteType,
    UtilityType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    lot_size: u64,
    tick_size: u64,
    min_size: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Get <a href="market.md#0xc0deb00c_market">market</a> registration fee, denominated in utility coins.
    <b>let</b> fee = <a href="incentives.md#0xc0deb00c_incentives_get_market_registration_fee">incentives::get_market_registration_fee</a>();
    // Register <a href="market.md#0xc0deb00c_market">market</a> <b>with</b> base <a href="">coin</a>, paying fees from <a href="">coin</a> store.
    <a href="market.md#0xc0deb00c_market_register_market_base_coin">register_market_base_coin</a>&lt;BaseType, QuoteType, UtilityType&gt;(
        lot_size, tick_size, min_size, <a href="_withdraw">coin::withdraw</a>(<a href="user.md#0xc0deb00c_user">user</a>, fee));
}
</code></pre>



<a name="0xc0deb00c_market_swap_between_coinstores_entry"></a>

## Function `swap_between_coinstores_entry`

Public entry function wrapper for <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>()</code>.


<a name="@Invocation_testing_53"></a>

### Invocation testing


* <code>test_swap_between_coinstores_register_base_store()</code>
* <code>test_swap_between_coinstores_register_quote_store()</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_between_coinstores_entry">swap_between_coinstores_entry</a>&lt;BaseType, QuoteType&gt;(<a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>, market_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="market.md#0xc0deb00c_market_swap_between_coinstores_entry">swap_between_coinstores_entry</a>&lt;
    BaseType,
    QuoteType
&gt;(
    <a href="user.md#0xc0deb00c_user">user</a>: &<a href="">signer</a>,
    market_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    <a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>&lt;BaseType, QuoteType&gt;(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, integrator, direction, min_base, max_base,
        min_quote, max_quote, limit_price);
}
</code></pre>



<a name="0xc0deb00c_market_cancel_all_orders"></a>

## Function `cancel_all_orders`

Cancel all of a user's open maker orders.


<a name="@Parameters_54"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Same as for <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>.
* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>.
* <code>custodian_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>.
* <code>side</code>: Same as for <code><a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>()</code>.


<a name="@Expected_value_testing_55"></a>

### Expected value testing


* <code>test_cancel_all_orders_ask_custodian()</code>
* <code>test_cancel_all_orders_bid_user()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, custodian_id: u64, side: bool)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_all_orders">cancel_all_orders</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    side: bool
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Get <a href="user.md#0xc0deb00c_user">user</a>'s active <a href="market.md#0xc0deb00c_market">market</a> order IDs.
    <b>let</b> market_order_ids = <a href="user.md#0xc0deb00c_user_get_active_market_order_ids_internal">user::get_active_market_order_ids_internal</a>(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, custodian_id, side);
    // Get number of <a href="market.md#0xc0deb00c_market">market</a> order IDs, init <b>loop</b> index variable.
    <b>let</b> (n_orders, i) = (<a href="_length">vector::length</a>(&market_order_ids), 0);
    <b>while</b> (i &lt; n_orders) { // Loop over all active orders.
        // Cancel <a href="market.md#0xc0deb00c_market">market</a> order for current iteration.
        <a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_id, custodian_id, side,
                     *<a href="_borrow">vector::borrow</a>(&market_order_ids, i));
        i = i + 1; // Increment <b>loop</b> counter.
    }
}
</code></pre>



<a name="0xc0deb00c_market_cancel_order"></a>

## Function `cancel_order`

Cancel maker order on order book and in user's market account.


<a name="@Parameters_56"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user holding maker order.
* <code>market_id</code>: Market ID of market.
* <code>custodian_id</code>: Market account custodian ID.
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>, the maker order side.
* <code>market_order_id</code>: Market order ID of order on order book.


<a name="@Aborts_57"></a>

### Aborts


* <code><a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ORDER_ID">E_INVALID_MARKET_ORDER_ID</a></code>: Market order ID passed as <code><a href="market.md#0xc0deb00c_market_NIL">NIL</a></code>.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a></code>: No market with given ID.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a></code>: Mismatch between <code><a href="user.md#0xc0deb00c_user">user</a></code> and user for order
on book having given market order ID.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a></code>: Mismatch between <code>custodian_id</code> and
custodian ID of order on order book having market order ID.


<a name="@Emits_58"></a>

### Emits


* <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a></code>: Information about the maker order cancelled.


<a name="@Expected_value_testing_59"></a>

### Expected value testing


* <code>test_cancel_order_ask_custodian()</code>
* <code>test_cancel_order_bid_user()</code>


<a name="@Failure_testing_60"></a>

### Failure testing


* <code>test_cancel_order_invalid_custodian()</code>
* <code>test_cancel_order_invalid_market_id()</code>
* <code>test_cancel_order_invalid_market_order_id()</code>
* <code>test_cancel_order_invalid_user()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, custodian_id: u64, side: bool, market_order_id: u128)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_cancel_order">cancel_order</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    side: bool,
    market_order_id: u128
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Assert <a href="market.md#0xc0deb00c_market">market</a> order ID not passed <b>as</b> reserved null flag.
    <b>assert</b>!(market_order_id != (<a href="market.md#0xc0deb00c_market_NIL">NIL</a> <b>as</b> u128), <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ORDER_ID">E_INVALID_MARKET_ORDER_ID</a>);
    // Get <b>address</b> of resource <a href="">account</a> <b>where</b> order books are stored.
    <b>let</b> resource_address = resource_account::get_address();
    <b>let</b> order_books_map_ref_mut = // Mutably borrow order books map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(resource_address).map;
    // Assert order books map <b>has</b> order book <b>with</b> given <a href="market.md#0xc0deb00c_market">market</a> ID.
    <b>assert</b>!(<a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(order_books_map_ref_mut, market_id),
            <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a>);
    <b>let</b> order_book_ref_mut = // Mutably borrow <a href="market.md#0xc0deb00c_market">market</a> order book.
        <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Mutably borrow corresponding orders AVL queue.
    <b>let</b> orders_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks
        <b>else</b> &<b>mut</b> order_book_ref_mut.bids;
    // Get AVL queue access key from <a href="market.md#0xc0deb00c_market">market</a> order ID.
    <b>let</b> avlq_access_key = ((market_order_id & (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)) <b>as</b> u64);
    // Remove order from AVL queue, storing its fields.
    <b>let</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>{size, <a href="user.md#0xc0deb00c_user">user</a>: order_user, custodian_id: order_custodian_id,
              order_access_key} = <a href="avl_queue.md#0xc0deb00c_avl_queue_remove">avl_queue::remove</a>(orders_ref_mut,
                                                    avlq_access_key);
    // Assert passed maker <b>address</b> is <a href="user.md#0xc0deb00c_user">user</a> holding order.
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user">user</a> == order_user, <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>);
    // Assert passed custodian ID matches that from order.
    <b>assert</b>!(custodian_id == order_custodian_id, <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    <b>let</b> price = avlq_access_key & <a href="market.md#0xc0deb00c_market_HI_PRICE">HI_PRICE</a>; // Get order price.
    // Cancel order <a href="user.md#0xc0deb00c_user">user</a>-side, thus verifying <a href="market.md#0xc0deb00c_market">market</a> order ID.
    <a href="user.md#0xc0deb00c_user_cancel_order_internal">user::cancel_order_internal</a>(<a href="user.md#0xc0deb00c_user">user</a>, market_id, custodian_id, side,
                                price, order_access_key, market_order_id);
    <b>let</b> type = <a href="market.md#0xc0deb00c_market_CANCEL">CANCEL</a>; // Declare maker <a href="">event</a> type.
    // Emit a maker cancel <a href="">event</a>.
    <a href="_emit_event">event::emit_event</a>(&<b>mut</b> order_book_ref_mut.maker_events, <a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>{
        market_id, side, market_order_id, <a href="user.md#0xc0deb00c_user">user</a>, custodian_id, type, size});
}
</code></pre>



<a name="0xc0deb00c_market_change_order_size"></a>

## Function `change_order_size`

Change maker order size on book and in user's market account.


<a name="@Parameters_61"></a>

### Parameters


* <code><a href="user.md#0xc0deb00c_user">user</a></code>: Address of user holding maker order.
* <code>market_id</code>: Market ID of market.
* <code>custodian_id</code>: Market account custodian ID.
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>, the maker order side.
* <code>market_order_id</code>: Market order ID of order on order book.
* <code>new_size</code>: The new order size to change to.


<a name="@Aborts_62"></a>

### Aborts


* <code><a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ORDER_ID">E_INVALID_MARKET_ORDER_ID</a></code>: Market order ID passed as <code><a href="market.md#0xc0deb00c_market_NIL">NIL</a></code>.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a></code>: No market with given ID.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a></code>: Mismatch between <code><a href="user.md#0xc0deb00c_user">user</a></code> and user for order
on book having given market order ID.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a></code>: Mismatch between <code>custodian_id</code> and
custodian ID of order on order book having market order ID.


<a name="@Emits_63"></a>

### Emits


* <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a></code>: Information about the changed maker order.


<a name="@Expected_value_testing_64"></a>

### Expected value testing


* <code>test_change_order_size_ask_custodian()</code>
* <code>test_change_order_size_bid_user()</code>


<a name="@Failure_testing_65"></a>

### Failure testing


* <code>test_change_order_size_invalid_custodian()</code>
* <code>test_change_order_size_invalid_market_id()</code>
* <code>test_change_order_size_invalid_market_order_id()</code>
* <code>test_change_order_size_invalid_user()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>(<a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>, market_id: u64, custodian_id: u64, side: bool, market_order_id: u128, new_size: u64)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_change_order_size">change_order_size</a>(
    <a href="user.md#0xc0deb00c_user">user</a>: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    side: bool,
    market_order_id: u128,
    new_size: u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Assert <a href="market.md#0xc0deb00c_market">market</a> order ID not passed <b>as</b> reserved null flag.
    <b>assert</b>!(market_order_id != (<a href="market.md#0xc0deb00c_market_NIL">NIL</a> <b>as</b> u128), <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ORDER_ID">E_INVALID_MARKET_ORDER_ID</a>);
    // Get <b>address</b> of resource <a href="">account</a> <b>where</b> order books are stored.
    <b>let</b> resource_address = resource_account::get_address();
    <b>let</b> order_books_map_ref_mut = // Mutably borrow order books map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(resource_address).map;
    // Assert order books map <b>has</b> order book <b>with</b> given <a href="market.md#0xc0deb00c_market">market</a> ID.
    <b>assert</b>!(<a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(order_books_map_ref_mut, market_id),
            <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a>);
    <b>let</b> order_book_ref_mut = // Mutably borrow <a href="market.md#0xc0deb00c_market">market</a> order book.
        <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Mutably borrow corresponding orders AVL queue.
    <b>let</b> orders_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks
        <b>else</b> &<b>mut</b> order_book_ref_mut.bids;
    // Get AVL queue access key from <a href="market.md#0xc0deb00c_market">market</a> order ID.
    <b>let</b> avlq_access_key = ((market_order_id & (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)) <b>as</b> u64);
    <b>let</b> order_ref_mut = // Mutably borrow order on order book.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_borrow_mut">avl_queue::borrow_mut</a>(orders_ref_mut, avlq_access_key);
    // Assert passed <a href="user.md#0xc0deb00c_user">user</a> <b>address</b> is <a href="user.md#0xc0deb00c_user">user</a> holding order.
    <b>assert</b>!(<a href="user.md#0xc0deb00c_user">user</a> == order_ref_mut.<a href="user.md#0xc0deb00c_user">user</a>, <a href="market.md#0xc0deb00c_market_E_INVALID_USER">E_INVALID_USER</a>);
    // Assert passed custodian ID matches that from order.
    <b>assert</b>!(custodian_id == order_ref_mut.custodian_id,
            <a href="market.md#0xc0deb00c_market_E_INVALID_CUSTODIAN">E_INVALID_CUSTODIAN</a>);
    <b>let</b> price = avlq_access_key & <a href="market.md#0xc0deb00c_market_HI_PRICE">HI_PRICE</a>; // Get order price.
    // Change order size <a href="user.md#0xc0deb00c_user">user</a>-side, thus verifying <a href="market.md#0xc0deb00c_market">market</a> order ID
    // and new size.
    <a href="user.md#0xc0deb00c_user_change_order_size_internal">user::change_order_size_internal</a>(
        <a href="user.md#0xc0deb00c_user">user</a>, market_id, custodian_id, side, new_size, price,
        order_ref_mut.order_access_key, market_order_id);
    // Update order on book <b>with</b> new size.
    order_ref_mut.size = new_size;
    // Declare order size, maker <a href="">event</a> type.
    <b>let</b> (size, type) = (order_ref_mut.size, <a href="market.md#0xc0deb00c_market_CHANGE">CHANGE</a>);
    // Emit a maker change <a href="">event</a>.
    <a href="_emit_event">event::emit_event</a>(&<b>mut</b> order_book_ref_mut.maker_events, <a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>{
        market_id, side, market_order_id, <a href="user.md#0xc0deb00c_user">user</a>, custodian_id, type, size});
}
</code></pre>



<a name="0xc0deb00c_market_init_module"></a>

## Function `init_module`

Initialize the order books map upon module publication.


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_init_module">init_module</a>(_econia: &<a href="">signer</a>)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_init_module">init_module</a>(
    _econia: &<a href="">signer</a>
) {
    // Get Econia resource <a href="">account</a> <a href="">signer</a>.
    <b>let</b> <a href="">resource_account</a> = resource_account::get_signer();
    // Initialize order books map under resource <a href="">account</a>.
    <b>move_to</b>(&<a href="">resource_account</a>, <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>{map: <a href="tablist.md#0xc0deb00c_tablist_new">tablist::new</a>()})
}
</code></pre>



<a name="0xc0deb00c_market_match"></a>

## Function `match`

Match a taker order against the order book.


<a name="@Type_Parameters_66"></a>

### Type Parameters


* <code>BaseType</code>: Base asset type for market.
<code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code> if a generic market.
* <code>QuoteType</code>: Quote coin type for market.


<a name="@Parameters_67"></a>

### Parameters


* <code>market_id</code>: Market ID of market.
* <code>order_book_ref_mut</code>: Mutable reference to market order book.
* <code>taker</code>: Address of taker whose order is matched. May be
passed as <code><a href="market.md#0xc0deb00c_market_UNKNOWN_TAKER">UNKNOWN_TAKER</a></code> when taker order originates from
a standalone coin swap or a generic swap.
* <code>integrator</code>: The integrator for the taker order, who collects
a portion of taker fees at their
<code><a href="incentives.md#0xc0deb00c_incentives_IntegratorFeeStore">incentives::IntegratorFeeStore</a></code> for the given market. May be
passed as an address known not to be an integrator, for
example <code>@0x0</code> or <code>@econia</code>, in the service of diverting all
fees to Econia.
* <code>direction</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>, from the taker's perspective. If
a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, fills against asks, else against bids.
* <code>min_base</code>: Minimum base asset units to be traded by taker,
either received or traded away.
* <code>max_base</code>: Maximum base asset units to be traded by taker,
either received or traded away.
* <code>min_quote</code>: Minimum quote asset units to be traded by taker,
either received or traded away. Exclusive of fees: refers to
the net change in taker's quote holdings after the match.
* <code>max_quote</code>: Maximum quote asset units to be traded by taker,
either received or traded away. Exclusive of fees: refers to
the net change in taker's quote holdings after the match.
* <code>limit_price</code>: If direction is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>, the price above which
matching should halt. If direction is <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>, the price below
which matching should halt. Can be passed as <code><a href="market.md#0xc0deb00c_market_HI_PRICE">HI_PRICE</a></code> if a
<code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code>0</code> if a <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code> to approve matching at any price.
* <code>optional_base_coins</code>: None if <code>BaseType</code> is
<code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code> (market is generic), else base coin
holdings for pure coin market, which are incremented if
<code>direction</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> and decremented if <code>direction</code> is <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>.
* <code>quote_coins</code>: Quote coin holdings for market, which are
decremented if <code>direction</code> is <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> and incremented if
<code>direction</code> is <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>.


<a name="@Returns_68"></a>

### Returns


* <code>Option&lt;Coin&lt;BaseType&gt;&gt;</code>: None if <code>BaseType</code> is
<code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>, else updated <code>optional_base_coins</code>
holdings after matching.
* <code>Coin&lt;QuoteType&gt;</code>: Updated <code>quote_coins</code> holdings after
matching.
* <code>u64</code>: Base asset amount traded by taker: net change in
taker's base holdings.
* <code>u64</code>: Quote coin amount traded by taker, inclusive of fees:
net change in taker's quote coin holdings.
* <code>u64</code>: Amount of quote coin fees paid.


<a name="@Emits_69"></a>

### Emits


* <code><a href="market.md#0xc0deb00c_market_TakerEvent">TakerEvent</a></code>: Information about a fill against a maker order,
emitted for each separate maker order that is filled against.


<a name="@Aborts_70"></a>

### Aborts


* <code><a href="market.md#0xc0deb00c_market_E_PRICE_TOO_HIGH">E_PRICE_TOO_HIGH</a></code>: Order price exceeds maximum allowable
price.
* <code><a href="market.md#0xc0deb00c_market_E_SELF_MATCH">E_SELF_MATCH</a></code>: Taker and a matched maker have same address.
* <code><a href="market.md#0xc0deb00c_market_E_MIN_BASE_NOT_TRADED">E_MIN_BASE_NOT_TRADED</a></code>: Minimum base asset trade amount
requirement not met.
* <code><a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_NOT_TRADED">E_MIN_QUOTE_NOT_TRADED</a></code>: Minimum quote asset trade amount
requirement not met.


<a name="@Algorithm_description_71"></a>

### Algorithm description


After checking price, lot size, and tick size, the taker fee
divisor is used to calculate the max quote coin match amount
for the given direction. Max lot and tick fill amounts are
calculated, and counters are initiated for the number of lots
and ticks to fill until reaching the max permitted amount. The
corresponding AVL queue is borrowed, and loopwise matching
executes against the head of the queue as long as it is empty:

The price of the order at the head of the AVL queue is compared
against the limit price, and the loop breaks if the limit price
condition is not met. Then the max fill size is calculated based
on the number of ticks left to fill until max and the price for
the given order, and compared against the number of lots to fill
until max. The lesser of the two is taken as the max fill size,
and compared against the order size to determine the fill size
and if a complete fill takes place. If no size can be filled the
loop breaks, otherwise the number of ticks is calculated, and
lots and ticks until max counters are updated. The self-match
condition is checked, then the order is filled user side and a
taker event is emitted. If there was a complete fill, the maker
order is removed from the head of the AVL queue and the loop
breaks if there are not lots or ticks left to fill. If the
order was not completely filled, the order size on the order
book is updated, and the loop breaks.

After loopwise matching, base and quote fill amounts are
calculated, then taker fees are assessed. If a buy, the traded
quote amount is calculated as the quote fill amount plus fees
paid, and if a sell, the traded quote amount is calculated as
the quote fill amount minus fees paid. Min base and quote trade
conditions are then checked.


<a name="@Expected_value_testing_72"></a>

### Expected value testing


* <code>test_match_complete_fill_no_lots_buy()</code>
* <code>test_match_complete_fill_no_ticks_sell()</code>
* <code>test_match_empty()</code>
* <code>test_match_fill_size_0()</code>
* <code>test_match_loop_twice()</code>
* <code>test_match_partial_fill_lot_limited_sell()</code>
* <code>test_match_partial_fill_tick_limited_buy()</code>
* <code>test_match_price_break_buy()</code>
* <code>test_match_price_break_sell()</code>


<a name="@Failure_testing_73"></a>

### Failure testing


* <code>test_match_min_base_not_traded()</code>
* <code>test_match_min_quote_not_traded()</code>
* <code>test_match_price_too_high()</code>
* <code>test_match_self_match()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match">match</a>&lt;BaseType, QuoteType&gt;(market_id: u64, order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>, taker: <b>address</b>, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, optional_base_coins: <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, quote_coins: <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;): (<a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_match">match</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id: u64,
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>,
    taker: <b>address</b>,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    optional_base_coins: Option&lt;Coin&lt;BaseType&gt;&gt;,
    quote_coins: Coin&lt;QuoteType&gt;,
): (
    Option&lt;Coin&lt;BaseType&gt;&gt;,
    Coin&lt;QuoteType&gt;,
    u64,
    u64,
    u64
) {
    // Assert price is not too high.
    <b>assert</b>!(limit_price &lt;= <a href="market.md#0xc0deb00c_market_MAX_PRICE">MAX_PRICE</a>, <a href="market.md#0xc0deb00c_market_E_PRICE_TOO_HIGH">E_PRICE_TOO_HIGH</a>);
    // Taker buy fills against asks, sell against bids.
    <b>let</b> side = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) <a href="market.md#0xc0deb00c_market_ASK">ASK</a> <b>else</b> <a href="market.md#0xc0deb00c_market_BID">BID</a>;
    <b>let</b> (lot_size, tick_size) = (order_book_ref_mut.lot_size,
        order_book_ref_mut.tick_size); // Get lot and tick sizes.
    // Get taker fee divisor.
    <b>let</b> taker_fee_divisor = <a href="incentives.md#0xc0deb00c_incentives_get_taker_fee_divisor">incentives::get_taker_fee_divisor</a>();
    // Get max quote coins <b>to</b> match.
    <b>let</b> max_quote_match = <a href="incentives.md#0xc0deb00c_incentives_calculate_max_quote_match">incentives::calculate_max_quote_match</a>(
        direction, taker_fee_divisor, max_quote);
    // Calculate max amounts of lots and ticks <b>to</b> fill.
    <b>let</b> (max_lots, max_ticks) =
        (max_base / lot_size, max_quote_match / tick_size);
    // Initialize counters for number of lots and ticks <b>to</b> fill.
    <b>let</b> (lots_until_max, ticks_until_max) = (max_lots, max_ticks);
    // Mutably borrow corresponding orders AVL queue.
    <b>let</b> orders_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks
        <b>else</b> &<b>mut</b> order_book_ref_mut.bids;
    // While there are orders <b>to</b> match against:
    <b>while</b> (!<a href="avl_queue.md#0xc0deb00c_avl_queue_is_empty">avl_queue::is_empty</a>(orders_ref_mut)) {
        <b>let</b> price = // Get price of order at head of AVL queue.
            *<a href="_borrow">option::borrow</a>(&<a href="avl_queue.md#0xc0deb00c_avl_queue_get_head_key">avl_queue::get_head_key</a>(orders_ref_mut));
        // Break <b>if</b> price too high <b>to</b> buy at or too low <b>to</b> sell at.
        <b>if</b> (((direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a> ) && (price &gt; limit_price)) ||
            ((direction == <a href="market.md#0xc0deb00c_market_SELL">SELL</a>) && (price &lt; limit_price))) <b>break</b>;
        // Calculate max number of lots that could be filled
        // at order price, limited by ticks left <b>to</b> fill until max.
        <b>let</b> max_fill_size_ticks = ticks_until_max / price;
        // Max fill size is lesser of tick-limited fill size and
        // lot-limited fill size.
        <b>let</b> max_fill_size = <b>if</b> (max_fill_size_ticks &lt; lots_until_max)
            max_fill_size_ticks <b>else</b> lots_until_max;
        // Mutably borrow order at head of AVL queue.
        <b>let</b> order_ref_mut = <a href="avl_queue.md#0xc0deb00c_avl_queue_borrow_head_mut">avl_queue::borrow_head_mut</a>(orders_ref_mut);
        // Get fill size and <b>if</b> a complete fill against book.
        <b>let</b> (fill_size, complete_fill) =
            // If max fill size is less than order size, fill size
            // is max fill size and is an incomplete fill. Else
            // order gets completely filled.
            <b>if</b> (max_fill_size &lt; order_ref_mut.size)
               (max_fill_size, <b>false</b>) <b>else</b> (order_ref_mut.size, <b>true</b>);
        <b>if</b> (fill_size == 0) <b>break</b>; // Break <b>if</b> no lots <b>to</b> fill.
        <b>let</b> ticks_filled = fill_size * price; // Get ticks filled.
        // Decrement counter for lots <b>to</b> fill until max reached.
        lots_until_max = lots_until_max - fill_size;
        // Decrement counter for ticks <b>to</b> fill until max reached.
        ticks_until_max = ticks_until_max - ticks_filled;
        // Get order maker, maker's custodian ID, and <a href="">event</a> size.
        <b>let</b> (maker, custodian_id, size) =
            (order_ref_mut.<a href="user.md#0xc0deb00c_user">user</a>, order_ref_mut.custodian_id, fill_size);
        // Assert no self match.
        <b>assert</b>!(maker != taker, <a href="market.md#0xc0deb00c_market_E_SELF_MATCH">E_SELF_MATCH</a>);
        <b>let</b> market_order_id; // Declare <b>return</b> assignment variable.
        // Fill matched order <a href="user.md#0xc0deb00c_user">user</a> side, storing <a href="market.md#0xc0deb00c_market">market</a> order ID.
        (optional_base_coins, quote_coins, market_order_id) =
            <a href="user.md#0xc0deb00c_user_fill_order_internal">user::fill_order_internal</a>&lt;BaseType, QuoteType&gt;(
                maker, market_id, custodian_id, side,
                order_ref_mut.order_access_key, fill_size,
                complete_fill, optional_base_coins, quote_coins,
                fill_size * lot_size, ticks_filled * tick_size);
        // Emit corresponding taker <a href="">event</a>.
        <a href="_emit_event">event::emit_event</a>(&<b>mut</b> order_book_ref_mut.taker_events, <a href="market.md#0xc0deb00c_market_TakerEvent">TakerEvent</a>{
            market_id, side, market_order_id, maker, custodian_id, size});
        <b>if</b> (complete_fill) { // If order on book completely filled:
            <b>let</b> avlq_access_key = // Get AVL queue access key.
                ((market_order_id & (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128)) <b>as</b> u64);
            // Remove order from AVL queue.
            <b>let</b> order = <a href="avl_queue.md#0xc0deb00c_avl_queue_remove">avl_queue::remove</a>(orders_ref_mut, avlq_access_key);
            <b>let</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>{size: _, <a href="user.md#0xc0deb00c_user">user</a>: _, custodian_id: _,
                      order_access_key: _} = order; // Unpack order.
            // Break out of <b>loop</b> <b>if</b> no more lots or ticks <b>to</b> fill.
            <b>if</b> ((lots_until_max == 0) || (ticks_until_max == 0)) <b>break</b>
        } <b>else</b> { // If order on book not completely filled:
            // Decrement order size by amount filled.
            order_ref_mut.size = order_ref_mut.size - fill_size;
            <b>break</b> // Stop matching.
        }
    }; // Done looping over head of AVL queue for given side.
    <b>let</b> (base_fill, quote_fill) = // Calculate base and quote fills.
        (((max_lots  - lots_until_max ) * lot_size),
         ((max_ticks - ticks_until_max) * tick_size));
    // Assess taker fees, storing taker fees paid.
    <b>let</b> (quote_coins, fees_paid) = <a href="incentives.md#0xc0deb00c_incentives_assess_taker_fees">incentives::assess_taker_fees</a>&lt;
        QuoteType&gt;(market_id, integrator, taker_fee_divisor, quote_fill,
        quote_coins);
    // If a buy, taker pays quote required for fills, and additional
    // fee assessed after matching. If a sell, taker receives quote
    // from fills, then <b>has</b> a portion assessed <b>as</b> fees.
    <b>let</b> quote_traded = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) (quote_fill + fees_paid)
        <b>else</b> (quote_fill - fees_paid);
    // Assert minimum base asset trade amount met.
    <b>assert</b>!(base_fill &gt;= min_base, <a href="market.md#0xc0deb00c_market_E_MIN_BASE_NOT_TRADED">E_MIN_BASE_NOT_TRADED</a>);
    // Assert minimum quote <a href="">coin</a> trade amount met.
    <b>assert</b>!(quote_traded &gt;= min_quote, <a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_NOT_TRADED">E_MIN_QUOTE_NOT_TRADED</a>);
    // Return optional base <a href="">coin</a>, quote coins, trade amounts.
    (optional_base_coins, quote_coins, base_fill, quote_traded, fees_paid)
}
</code></pre>



<a name="0xc0deb00c_market_place_limit_order"></a>

## Function `place_limit_order`

Place limit order against order book from user market account.


<a name="@Type_Parameters_74"></a>

### Type Parameters


* <code>BaseType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. Ignored unless order fills
across the spread as a taker.
* <code>QuoteType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. Ignored unless order fills
across the spread as a taker.


<a name="@Parameters_75"></a>

### Parameters


* <code>user_address</code>: User address for market account.
* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>custodian_id</code>: Custodian ID for market account.
* <code>integrator</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, only receives fees if
order fills across the spread.
* <code>side</code>: <code><a href="market.md#0xc0deb00c_market_ASK">ASK</a></code> or <code><a href="market.md#0xc0deb00c_market_BID">BID</a></code>, the side on which to place an order as
a maker.
* <code>size</code>: The size, in lots, to fill.
* <code>price</code>: The limit order price, in ticks per lot.
* <code>restriction</code>: <code><a href="market.md#0xc0deb00c_market_FILL_OR_ABORT">FILL_OR_ABORT</a></code>, <code><a href="market.md#0xc0deb00c_market_IMMEDIATE_OR_CANCEL">IMMEDIATE_OR_CANCEL</a></code>,
<code><a href="market.md#0xc0deb00c_market_POST_OR_ABORT">POST_OR_ABORT</a></code>, or <code><a href="market.md#0xc0deb00c_market_NO_RESTRICTION">NO_RESTRICTION</a></code>.
* <code>critical_height</code>: The AVL queue height above which evictions
may take place. Should only be passed as <code><a href="market.md#0xc0deb00c_market_CRITICAL_HEIGHT">CRITICAL_HEIGHT</a></code>.
Accepted as an argument to simplify testing.


<a name="@Returns_76"></a>

### Returns


* <code>u128</code>: Market order ID of limit order placed on book, if one
was placed. Else <code><a href="market.md#0xc0deb00c_market_NIL">NIL</a></code>.
* <code>u64</code>: Base asset trade amount as a taker, same as for
<code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, if order fills across the spread.
* <code>u64</code>: Quote asset trade amount as a taker, same as for
<code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, if order fills across the spread.
* <code>u64</code>: Quote coin fees paid as a taker, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>,
if order fills across the spread.


<a name="@Aborts_77"></a>

### Aborts


* <code><a href="market.md#0xc0deb00c_market_E_INVALID_RESTRICTION">E_INVALID_RESTRICTION</a></code>: Invalid restriction flag.
* <code><a href="market.md#0xc0deb00c_market_E_PRICE_0">E_PRICE_0</a></code>: Order price specified as 0.
* <code><a href="market.md#0xc0deb00c_market_E_PRICE_TOO_HIGH">E_PRICE_TOO_HIGH</a></code>: Order price exceeds maximum allowed
price.
* <code><a href="market.md#0xc0deb00c_market_E_SIZE_TOO_SMALL">E_SIZE_TOO_SMALL</a></code>: Limit order size does not meet minimum
size for market.
* <code><a href="market.md#0xc0deb00c_market_E_FILL_OR_ABORT_NOT_CROSS_SPREAD">E_FILL_OR_ABORT_NOT_CROSS_SPREAD</a></code>: Fill-or-abort price does
not cross the spread.
* <code><a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSES_SPREAD">E_POST_OR_ABORT_CROSSES_SPREAD</a></code>: Post-or-abort price crosses
the spread.
* <code><a href="market.md#0xc0deb00c_market_E_SIZE_BASE_OVERFLOW">E_SIZE_BASE_OVERFLOW</a></code>: The product of order size and market
lot size results in a base asset unit overflow.
* <code><a href="market.md#0xc0deb00c_market_E_SIZE_PRICE_TICKS_OVERFLOW">E_SIZE_PRICE_TICKS_OVERFLOW</a></code>: The product of order size and
price results in a tick amount overflow.
* <code><a href="market.md#0xc0deb00c_market_E_SIZE_PRICE_QUOTE_OVERFLOW">E_SIZE_PRICE_QUOTE_OVERFLOW</a></code>: The product of order size,
price, and market tick size results in a quote asset unit
overflow.
* <code><a href="market.md#0xc0deb00c_market_E_PRICE_TIME_PRIORITY_TOO_LOW">E_PRICE_TIME_PRIORITY_TOO_LOW</a></code>: Order would result in lowest
price-time priority if inserted to AVL queue, but AVL queue
does not have room for any more orders.


<a name="@Emits_78"></a>

### Emits


* <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a></code>: Information about the user's maker order placed
on the order book, if one was placed.
* <code><a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a></code>: Information about the maker order evicted from
the order book, if required to fit user's maker order on the
book.


<a name="@Restrictions_79"></a>

### Restrictions


* A post-or-abort order aborts if its price crosses the spread.
* A fill-or-abort order aborts if it is not completely filled
as a taker order. Here, a corresponding minimum base trade
amount is passed to <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>, which aborts if the minimum
amount is not filled.
* An immediate-or-cancel order fills as a taker if possible,
then returns.


<a name="@Minimum_size_80"></a>

### Minimum size


* If order partially fills as a taker and there is still size
left as a maker, minimum order size condition must be met
again for the maker portion.


<a name="@Algorithm_description_81"></a>

### Algorithm description


Order restriction and price are checked, then user's available
and ceiling asset counts are checked, verifying that the given
market exists. The corresponding order book is borrowed, the
order size is checked against the min size for the market, and
the market underwriter ID is checked. The price is checked for
the given order side to determine if the spread is crossed, and
if not, order aborts if restriction is fill-or-abort. If spread
is not crossed, order aborts if restriction is post-or-abort.

The amount of base units, ticks, and quote units required to
fill the order size are checked for overflow conditions, and
corresponding trade amounts are calculated for range checking.
If the order crosses the spread, base and quote assets are
withdrawn from the user's market account and passed through the
matching engine, deposited back to the user's market account,
and remaining order size to fill is updated. If restriction is
immediate-or-cancel or if no size left to fill after optional
matching as a taker, returns without placing a maker order.

The user's next order access key is checked, and a corresponding
order is inserted to the order book. If the order's price time
priority is too low to fit on the book, the order aborts. Else
a market order ID is constructed from the AVL queue access key
just generated upon insertion, and the order book counter is
updated. An order is placed user-side, and a taker event is
emitted for the new order on the book.

If insertion did not result in an eviction, the empty optional
evictee value is destroyed. Otherwise, the evicted order is
unpacked and its price is extracted, then it is cancelled from
the corresponding user's market account, and its market order
ID is emitted in a maker evict event.


<a name="@Expected_value_testing_82"></a>

### Expected value testing


* <code>test_place_limit_order_crosses_ask_exact()</code>
* <code>test_place_limit_order_crosses_ask_partial()</code>
* <code>test_place_limit_order_crosses_ask_partial_cancel()</code>
* <code>test_place_limit_order_crosses_bid_exact()</code>
* <code>test_place_limit_order_crosses_bid_partial()</code>
* <code>test_place_limit_order_evict()</code>
* <code>test_place_limit_order_no_cross_ask_user()</code>
* <code>test_place_limit_order_no_cross_bid_custodian()</code>


<a name="@Failure_testing_83"></a>

### Failure testing


* <code>test_place_limit_order_base_overflow()</code>
* <code>test_place_limit_order_fill_or_abort_not_cross()</code>
* <code>test_place_limit_order_fill_or_abort_partial()</code>
* <code>test_place_limit_order_invalid_restriction()</code>
* <code>test_place_limit_order_no_price()</code>
* <code>test_place_limit_order_post_or_abort_crosses()</code>
* <code>test_place_limit_order_price_hi()</code>
* <code>test_place_limit_order_price_time_priority_low()</code>
* <code>test_place_limit_order_quote_overflow()</code>
* <code>test_place_limit_order_size_lo()</code>
* <code>test_place_limit_order_ticks_overflow()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;BaseType, QuoteType&gt;(user_address: <b>address</b>, market_id: u64, custodian_id: u64, integrator: <b>address</b>, side: bool, size: u64, price: u64, restriction: u8, critical_height: u8): (u128, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_limit_order">place_limit_order</a>&lt;
    BaseType,
    QuoteType,
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    integrator: <b>address</b>,
    side: bool,
    size: u64,
    price: u64,
    restriction: u8,
    critical_height: u8
): (
    u128,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Assert valid order restriction flag.
    <b>assert</b>!(restriction &lt;= <a href="market.md#0xc0deb00c_market_N_RESTRICTIONS">N_RESTRICTIONS</a>, <a href="market.md#0xc0deb00c_market_E_INVALID_RESTRICTION">E_INVALID_RESTRICTION</a>);
    <b>assert</b>!(price != 0, <a href="market.md#0xc0deb00c_market_E_PRICE_0">E_PRICE_0</a>); // Assert nonzero price.
    // Assert price is not too high.
    <b>assert</b>!(price &lt;= <a href="market.md#0xc0deb00c_market_MAX_PRICE">MAX_PRICE</a>, <a href="market.md#0xc0deb00c_market_E_PRICE_TOO_HIGH">E_PRICE_TOO_HIGH</a>);
    // Get <a href="user.md#0xc0deb00c_user">user</a>'s available and ceiling asset counts.
    <b>let</b> (_, base_available, base_ceiling, _, quote_available,
         quote_ceiling) = <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">user::get_asset_counts_internal</a>(
            user_address, market_id, custodian_id);
    // If asset count check does not <b>abort</b>, then <a href="market.md#0xc0deb00c_market">market</a> <b>exists</b>, so
    // get <b>address</b> of resource <a href="">account</a> for borrowing order book.
    <b>let</b> resource_address = resource_account::get_address();
    <b>let</b> order_books_map_ref_mut = // Mutably borrow order books map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(resource_address).map;
    <b>let</b> order_book_ref_mut = // Mutably borrow <a href="market.md#0xc0deb00c_market">market</a> order book.
        <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Assert order size is at least minimum size for <a href="market.md#0xc0deb00c_market">market</a>.
    <b>assert</b>!(size &gt;= order_book_ref_mut.min_size, <a href="market.md#0xc0deb00c_market_E_SIZE_TOO_SMALL">E_SIZE_TOO_SMALL</a>);
    // Get <a href="market.md#0xc0deb00c_market">market</a> underwriter ID.
    <b>let</b> underwriter_id = order_book_ref_mut.underwriter_id;
    // <a href="market.md#0xc0deb00c_market_Order">Order</a> crosses spread <b>if</b> an ask and would trail behind bids
    // AVL queue head, or <b>if</b> a bid and would trail behind asks AVL
    // queue head.
    <b>let</b> crosses_spread = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>)
        !<a href="avl_queue.md#0xc0deb00c_avl_queue_would_update_head">avl_queue::would_update_head</a>(&order_book_ref_mut.bids, price) <b>else</b>
        !<a href="avl_queue.md#0xc0deb00c_avl_queue_would_update_head">avl_queue::would_update_head</a>(&order_book_ref_mut.asks, price);
    // Assert order crosses spread <b>if</b> fill-or-<b>abort</b>.
    <b>assert</b>!(!((restriction == <a href="market.md#0xc0deb00c_market_FILL_OR_ABORT">FILL_OR_ABORT</a>) && !crosses_spread),
            <a href="market.md#0xc0deb00c_market_E_FILL_OR_ABORT_NOT_CROSS_SPREAD">E_FILL_OR_ABORT_NOT_CROSS_SPREAD</a>);
    // Assert order does not cross spread <b>if</b> <b>post</b>-or-<b>abort</b>.
    <b>assert</b>!(!((restriction == <a href="market.md#0xc0deb00c_market_POST_OR_ABORT">POST_OR_ABORT</a>) && crosses_spread),
            <a href="market.md#0xc0deb00c_market_E_POST_OR_ABORT_CROSSES_SPREAD">E_POST_OR_ABORT_CROSSES_SPREAD</a>);
    // Calculate base asset amount corresponding <b>to</b> size in lots.
    <b>let</b> base = (size <b>as</b> u128) * (order_book_ref_mut.lot_size <b>as</b> u128);
    // Assert corresponding base asset amount fits in a u64.
    <b>assert</b>!(base &lt;= (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128), <a href="market.md#0xc0deb00c_market_E_SIZE_BASE_OVERFLOW">E_SIZE_BASE_OVERFLOW</a>);
    // Calculate tick amount corresponding <b>to</b> size in lots.
    <b>let</b> ticks = (size <b>as</b> u128) * (price <b>as</b> u128);
    // Assert corresponding tick amount fits in a u64.
    <b>assert</b>!(ticks &lt;= (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128), <a href="market.md#0xc0deb00c_market_E_SIZE_PRICE_TICKS_OVERFLOW">E_SIZE_PRICE_TICKS_OVERFLOW</a>);
    // Calculate amount of quote required <b>to</b> fill size at price.
    <b>let</b> quote = ticks * (order_book_ref_mut.tick_size <b>as</b> u128);
    // Assert corresponding quote amount fits in a u64.
    <b>assert</b>!(quote &lt;= (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128), <a href="market.md#0xc0deb00c_market_E_SIZE_PRICE_QUOTE_OVERFLOW">E_SIZE_PRICE_QUOTE_OVERFLOW</a>);
    // Max base <b>to</b> trade is amount calculated from size, lot size.
    <b>let</b> max_base = (base <b>as</b> u64);
    // If a fill-or-<b>abort</b> order, must fill <b>as</b> a taker order <b>with</b>
    // a minimum trade amount equal <b>to</b> max base. Else no <b>min</b>.
    <b>let</b> min_base = <b>if</b> (restriction == <a href="market.md#0xc0deb00c_market_FILL_OR_ABORT">FILL_OR_ABORT</a>) max_base <b>else</b> 0;
    // No need <b>to</b> specify <b>min</b> quote <b>if</b> filling <b>as</b> a taker order
    // since <b>min</b> base is specified.
    <b>let</b> min_quote = 0;
    // Get max quote <b>to</b> trade. If price crosses spread:
    <b>let</b> max_quote = <b>if</b> (crosses_spread) { // If fills <b>as</b> taker:
        <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) { // If an ask, filling <b>as</b> taker sell:
            // <a href="market.md#0xc0deb00c_market_Order">Order</a> will fill at prices that are at least <b>as</b> high
            // <b>as</b> specified order price, and <a href="user.md#0xc0deb00c_user">user</a> will receive more
            // quote than calculated from order size and price.
            // Hence max quote <b>to</b> trade is amount that will fit in
            // <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
            (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - quote_ceiling)
        // If a bid, filling <b>as</b> a taker buy, will have <b>to</b> pay at
        // least <b>as</b> much <b>as</b> from order size and price, plus fees.
        } <b>else</b> {
            // Get taker fee divisor
            <b>let</b> taker_fee_divisor = <a href="incentives.md#0xc0deb00c_incentives_get_taker_fee_divisor">incentives::get_taker_fee_divisor</a>();
            // Max quote is amount from size and price, <b>with</b> fees.
            ((quote <b>as</b> u64) + ((quote <b>as</b> u64) / taker_fee_divisor))
        }
    } <b>else</b> { // If no portion of order fills <b>as</b> a taker:
        (quote <b>as</b> u64) // Max quote is amount from size and price.
    };
    // If an ask, trade direction <b>to</b> range check is sell, <b>else</b> buy.
    <b>let</b> direction = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) <a href="market.md#0xc0deb00c_market_SELL">SELL</a> <b>else</b> <a href="market.md#0xc0deb00c_market_BUY">BUY</a>;
    <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>( // Range check trade amounts.
        direction, min_base, max_base, min_quote, max_quote,
        base_available, base_ceiling, quote_available, quote_ceiling);
    // Assume no <a href="assets.md#0xc0deb00c_assets">assets</a> traded <b>as</b> a taker.
    <b>let</b> (base_traded, quote_traded, fees) = (0, 0, 0);
    <b>if</b> (crosses_spread) { // If order price crosses spread:
        // Calculate max base and quote <b>to</b> withdraw. If a buy:
        <b>let</b> (base_withdraw, quote_withdraw) = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
            // Withdraw quote <b>to</b> buy base, <b>else</b> sell base for quote.
            (0, max_quote) <b>else</b> (max_base, 0);
        // Withdraw optional base coins and quote coins for match,
        // verifying base type and quote type for <a href="market.md#0xc0deb00c_market">market</a>.
        <b>let</b> (optional_base_coins, quote_coins) =
            <a href="user.md#0xc0deb00c_user_withdraw_assets_internal">user::withdraw_assets_internal</a>&lt;BaseType, QuoteType&gt;(
                user_address, market_id, custodian_id, base_withdraw,
                quote_withdraw, underwriter_id);
        // Match against order book, storing modified asset inputs,
        // base and quote trade amounts, and quote fees paid.
        (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
            = <a href="market.md#0xc0deb00c_market_match">match</a>(market_id, order_book_ref_mut, user_address,
                    integrator, direction, min_base, max_base, min_quote,
                    max_quote, price, optional_base_coins, quote_coins);
        // Calculate amount of base deposited back <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
        <b>let</b> base_deposit = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) base_traded <b>else</b>
            base_withdraw - base_traded;
        // Deposit <a href="assets.md#0xc0deb00c_assets">assets</a> back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
        <a href="user.md#0xc0deb00c_user_deposit_assets_internal">user::deposit_assets_internal</a>&lt;BaseType, QuoteType&gt;(
            user_address, market_id, custodian_id, base_deposit,
            optional_base_coins, quote_coins, underwriter_id);
        // Update size <b>to</b> amount left <b>to</b> fill after taker match.
        size = size - (base_traded / order_book_ref_mut.lot_size);
    }; // Done <b>with</b> optional matching <b>as</b> a taker across the spread.
    // Return without <a href="market.md#0xc0deb00c_market">market</a> order ID <b>if</b> no size left <b>to</b> fill.
    <b>if</b> ((restriction == <a href="market.md#0xc0deb00c_market_IMMEDIATE_OR_CANCEL">IMMEDIATE_OR_CANCEL</a>) || (size == 0))
        <b>return</b> ((<a href="market.md#0xc0deb00c_market_NIL">NIL</a> <b>as</b> u128), base_traded, quote_traded, fees);
    // Get next order access key for <a href="user.md#0xc0deb00c_user">user</a>-side order placement.
    <b>let</b> order_access_key = <a href="user.md#0xc0deb00c_user_get_next_order_access_key_internal">user::get_next_order_access_key_internal</a>(
        user_address, market_id, custodian_id, side);
    // Get orders AVL queue for maker side.
    <b>let</b> orders_ref_mut = <b>if</b> (side == <a href="market.md#0xc0deb00c_market_ASK">ASK</a>) &<b>mut</b> order_book_ref_mut.asks <b>else</b>
        &<b>mut</b> order_book_ref_mut.bids;
    // Declare order <b>to</b> insert <b>to</b> book.
    <b>let</b> order = <a href="market.md#0xc0deb00c_market_Order">Order</a>{size, <a href="user.md#0xc0deb00c_user">user</a>: user_address, custodian_id,
                      order_access_key};
    // Get new AVL queue access key, evictee access key, and evictee
    // value by attempting <b>to</b> insert for given critical height.
    <b>let</b> (avlq_access_key, evictee_access_key, evictee_value) =
        <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_check_eviction">avl_queue::insert_check_eviction</a>(
            orders_ref_mut, price, order, critical_height);
    // Assert that order could be inserted <b>to</b> AVL queue.
    <b>assert</b>!(avlq_access_key != <a href="market.md#0xc0deb00c_market_NIL">NIL</a>, <a href="market.md#0xc0deb00c_market_E_PRICE_TIME_PRIORITY_TOO_LOW">E_PRICE_TIME_PRIORITY_TOO_LOW</a>);
    // Get <a href="market.md#0xc0deb00c_market">market</a> order ID from AVL queue access key, counter.
    <b>let</b> market_order_id = (avlq_access_key <b>as</b> u128) |
        ((order_book_ref_mut.counter <b>as</b> u128) &lt;&lt; <a href="market.md#0xc0deb00c_market_SHIFT_COUNTER">SHIFT_COUNTER</a>);
    // Increment maker counter.
    order_book_ref_mut.counter = order_book_ref_mut.counter + 1;
    <a href="user.md#0xc0deb00c_user_place_order_internal">user::place_order_internal</a>( // Place order <a href="user.md#0xc0deb00c_user">user</a>-side.
        user_address, market_id, custodian_id, side, size, price,
        market_order_id);
    // Emit a maker place <a href="">event</a>.
    <a href="_emit_event">event::emit_event</a>(&<b>mut</b> order_book_ref_mut.maker_events, <a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>{
        market_id, side, market_order_id, <a href="user.md#0xc0deb00c_user">user</a>: user_address,
        custodian_id, type: <a href="market.md#0xc0deb00c_market_PLACE">PLACE</a>, size});
    <b>if</b> (evictee_access_key == <a href="market.md#0xc0deb00c_market_NIL">NIL</a>) { // If no eviction required:
        // Destroy empty evictee value <a href="">option</a>.
        <a href="_destroy_none">option::destroy_none</a>(evictee_value);
    } <b>else</b> { // If had <b>to</b> evict order at AVL queue tail:
        // Unpack evicted order, storing fields for <a href="">event</a>.
        <b>let</b> <a href="market.md#0xc0deb00c_market_Order">Order</a>{size, <a href="user.md#0xc0deb00c_user">user</a>, custodian_id, order_access_key} =
            <a href="_destroy_some">option::destroy_some</a>(evictee_value);
        // Get price of cancelled order.
        <b>let</b> price_cancel = evictee_access_key & <a href="market.md#0xc0deb00c_market_HI_PRICE">HI_PRICE</a>;
        // Cancel order <a href="user.md#0xc0deb00c_user">user</a>-side, storing its <a href="market.md#0xc0deb00c_market">market</a> order ID.
        <b>let</b> market_order_id_cancel = <a href="user.md#0xc0deb00c_user_cancel_order_internal">user::cancel_order_internal</a>(
            <a href="user.md#0xc0deb00c_user">user</a>, market_id, custodian_id, side, price_cancel,
            order_access_key, (<a href="market.md#0xc0deb00c_market_NIL">NIL</a> <b>as</b> u128));
        // Emit a maker evict <a href="">event</a>.
        <a href="_emit_event">event::emit_event</a>(&<b>mut</b> order_book_ref_mut.maker_events, <a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>{
            market_id, side, market_order_id: market_order_id_cancel, <a href="user.md#0xc0deb00c_user">user</a>,
            custodian_id, type: <a href="market.md#0xc0deb00c_market_EVICT">EVICT</a>, size});
    };
    // Return <a href="market.md#0xc0deb00c_market">market</a> order ID and taker trade amounts.
    <b>return</b> (market_order_id, base_traded, quote_traded, fees)
}
</code></pre>



<a name="0xc0deb00c_market_place_market_order"></a>

## Function `place_market_order`

Place market order against order book from user market account.


<a name="@Type_Parameters_84"></a>

### Type Parameters


* <code>BaseType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>QuoteType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Parameters_85"></a>

### Parameters


* <code>user_address</code>: User address for market account.
* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>custodian_id</code>: Custodian ID for market account.
* <code>integrator</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>direction</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. If passed as <code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code>
will attempt to trade maximum possible amount for market
account.
* <code>min_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>. If passed as
<code><a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a></code> will attempt to trade maximum possible amount
for market account.
* <code>limit_price</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Returns_86"></a>

### Returns


* <code>u64</code>: Base asset trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin fees paid, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Algorithm_description_87"></a>

### Algorithm description


Checks user's available and ceiling asset counts, thus verifying
that market exists for given market ID. Mutably borrows order
book for market and gets underwriter ID, then checks max base
and quote trade amount inputs. If flagged as max possible, max
base is updated to max amount possible for market account state,
as for max quote. Trade amounts are range checked, and withdraw
amounts are calculated based on the direction: if a buy, max
quote is withdrawn but no base, and if a sell, max base but no
quote is withdrawn from user's market account.

Assets are withdrawn from the user's market account, thus
verifying the base and quote type for the market. The amount of
base asset to deposit back to the user's market account is
calculated, then base and quote assets are deposited back to the
user's market account.


<a name="@Expected_value_testing_88"></a>

### Expected value testing


* <code>test_place_market_order_max_base_buy_user()</code>
* <code>test_place_market_order_max_base_sell_custodian()</code>
* <code>test_place_market_order_max_quote_buy_custodian()</code>
* <code>test_place_market_order_max_quote_sell_user()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;BaseType, QuoteType&gt;(user_address: <b>address</b>, market_id: u64, custodian_id: u64, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64): (u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_place_market_order">place_market_order</a>&lt;
    BaseType,
    QuoteType
&gt;(
    user_address: <b>address</b>,
    market_id: u64,
    custodian_id: u64,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
): (
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Get <a href="user.md#0xc0deb00c_user">user</a>'s available and ceiling asset counts.
    <b>let</b> (_, base_available, base_ceiling, _, quote_available,
         quote_ceiling) = <a href="user.md#0xc0deb00c_user_get_asset_counts_internal">user::get_asset_counts_internal</a>(
            user_address, market_id, custodian_id);
    // If asset count check does not <b>abort</b>, then <a href="market.md#0xc0deb00c_market">market</a> <b>exists</b>, so
    // get <b>address</b> of resource <a href="">account</a> for borrowing order book.
    <b>let</b> resource_address = resource_account::get_address();
    <b>let</b> order_books_map_ref_mut = // Mutably borrow order books map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(resource_address).map;
    <b>let</b> order_book_ref_mut = // Mutably borrow <a href="market.md#0xc0deb00c_market">market</a> order book.
        <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // Get <a href="market.md#0xc0deb00c_market">market</a> underwriter ID.
    <b>let</b> underwriter_id = order_book_ref_mut.underwriter_id;
    // If max base <b>to</b> trade flagged <b>as</b> max possible and a buy,
    // <b>update</b> <b>to</b> max amount that can be bought. If a sell, <b>update</b>
    // <b>to</b> all available <b>to</b> sell.
    <b>if</b> (max_base == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_base = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - base_ceiling) <b>else</b> base_available;
    // If max quote <b>to</b> trade flagged <b>as</b> max possible and a buy,
    // <b>update</b> <b>to</b> max amount that can spend. If a sell, <b>update</b>
    // <b>to</b> max amount that can receive when selling.
    <b>if</b> (max_quote == <a href="market.md#0xc0deb00c_market_MAX_POSSIBLE">MAX_POSSIBLE</a>) max_quote = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        quote_available <b>else</b> (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> - quote_ceiling);
    <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>( // Range check trade amounts.
        direction, min_base, max_base, min_quote, max_quote,
        base_available, base_ceiling, quote_available, quote_ceiling);
    // Calculate max base and quote <b>to</b> withdraw. If a buy:
    <b>let</b> (base_withdraw, quote_withdraw) = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>)
        // Withdraw quote <b>to</b> buy base, <b>else</b> sell base for quote.
        (0, max_quote) <b>else</b> (max_base, 0);
    // Withdraw optional base coins and quote coins for match,
    // verifying base type and quote type for <a href="market.md#0xc0deb00c_market">market</a>.
    <b>let</b> (optional_base_coins, quote_coins) =
        <a href="user.md#0xc0deb00c_user_withdraw_assets_internal">user::withdraw_assets_internal</a>&lt;BaseType, QuoteType&gt;(
            user_address, market_id, custodian_id, base_withdraw,
            quote_withdraw, underwriter_id);
    // Match against order book, storing modified asset inputs,
    // base and quote trade amounts, and quote fees paid.
    <b>let</b> (optional_base_coins, quote_coins, base_traded, quote_traded, fees)
        = <a href="market.md#0xc0deb00c_market_match">match</a>(market_id, order_book_ref_mut, user_address, integrator,
                direction, min_base, max_base, min_quote, max_quote,
                limit_price, optional_base_coins, quote_coins);
    // Calculate amount of base deposited back <b>to</b> <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
    <b>let</b> base_deposit = <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) base_traded <b>else</b>
        (base_withdraw - base_traded);
    // Deposit <a href="assets.md#0xc0deb00c_assets">assets</a> back <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
    <a href="user.md#0xc0deb00c_user_deposit_assets_internal">user::deposit_assets_internal</a>&lt;BaseType, QuoteType&gt;(
        user_address, market_id, custodian_id, base_deposit,
        optional_base_coins, quote_coins, underwriter_id);
    // Return base and quote traded by <a href="user.md#0xc0deb00c_user">user</a>, fees paid.
    (base_traded, quote_traded, fees)
}
</code></pre>



<a name="0xc0deb00c_market_range_check_trade"></a>

## Function `range_check_trade`

Range check minimum and maximum asset trade amounts.

Should be called before <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Terminology_89"></a>

### Terminology


* "Inbound asset" is asset received by user.
* "Outbound asset" is asset traded away by by user.
* "Available asset" is the the user's holdings for either base
or quote. When trading from a user's market account,
corresponds to either <code><a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>.base_available</code> or
<code><a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>.quote_available</code>. When trading from a
user's <code>aptos_framework::coin::CoinStore</code> or from standalone
coins, corresponds to coin value.
* "Asset ceiling" is the amount that the available asset amount
could increase to beyond its present amount, even if the
indicated trade were not executed. When trading from a user's
market account, corresponds to either
<code><a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>.base_ceiling</code> or
<code><a href="user.md#0xc0deb00c_user_MarketAccount">user::MarketAccount</a>.quote_ceiling</code>. When trading from a
user's <code>aptos_framework::coin::CoinStore</code> or from standalone
coins, is the same as available amount.


<a name="@Parameters_90"></a>

### Parameters


* <code>direction</code>: <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code> or <code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>.
* <code>min_base</code>: Minimum amount of change in base holdings after
trade.
* <code>max_base</code>: Maximum amount of change in base holdings after
trade.
* <code>min_quote</code>: Minimum amount of change in quote holdings after
trade.
* <code>max_quote</code>: Maximum amount of change in quote holdings after
trade.
* <code>base_available</code>: Available base asset amount.
* <code>base_ceiling</code>: Base asset ceiling, only checked when a <code><a href="market.md#0xc0deb00c_market_BUY">BUY</a></code>.
* <code>quote_available</code>: Available quote asset amount.
* <code>quote_ceiling</code>: Quote asset ceiling, only checked when a
<code><a href="market.md#0xc0deb00c_market_SELL">SELL</a></code>.


<a name="@Aborts_91"></a>

### Aborts


* <code><a href="market.md#0xc0deb00c_market_E_MAX_BASE_0">E_MAX_BASE_0</a></code>: Maximum base trade amount specified as 0.
* <code><a href="market.md#0xc0deb00c_market_E_MAX_QUOTE_0">E_MAX_QUOTE_0</a></code>: Maximum quote trade amount specified as 0.
* <code><a href="market.md#0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX">E_MIN_BASE_EXCEEDS_MAX</a></code>: Minimum base trade amount is larger
than maximum base trade amount.
* <code><a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX">E_MIN_QUOTE_EXCEEDS_MAX</a></code>: Minimum quote trade amount is
larger than maximum quote trade amount.
* <code><a href="market.md#0xc0deb00c_market_E_OVERFLOW_ASSET_IN">E_OVERFLOW_ASSET_IN</a></code>: Filling order would overflow asset
received from trade.
* <code><a href="market.md#0xc0deb00c_market_E_NOT_ENOUGH_ASSET_OUT">E_NOT_ENOUGH_ASSET_OUT</a></code>: Not enough asset to trade away.


<a name="@Failure_testing_92"></a>

### Failure testing


* <code>test_range_check_trade_asset_in_buy()</code>
* <code>test_range_check_trade_asset_in_sell()</code>
* <code>test_range_check_trade_asset_out_buy()</code>
* <code>test_range_check_trade_asset_out_sell()</code>
* <code>test_range_check_trade_base_0()</code>
* <code>test_range_check_trade_min_base_exceeds_max()</code>
* <code>test_range_check_trade_min_quote_exceeds_max()</code>
* <code>test_range_check_trade_quote_0()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>(direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, base_available: u64, base_ceiling: u64, quote_available: u64, quote_ceiling: u64)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_range_check_trade">range_check_trade</a>(
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    base_available: u64,
    base_ceiling: u64,
    quote_available: u64,
    quote_ceiling: u64
) {
    // Assert nonzero max base trade amount.
    <b>assert</b>!(max_base &gt; 0, <a href="market.md#0xc0deb00c_market_E_MAX_BASE_0">E_MAX_BASE_0</a>);
    // Assert nonzero max quote trade amount.
    <b>assert</b>!(max_quote &gt; 0, <a href="market.md#0xc0deb00c_market_E_MAX_QUOTE_0">E_MAX_QUOTE_0</a>);
    // Assert minimum base less than or equal <b>to</b> maximum.
    <b>assert</b>!(min_base &lt;= max_base, <a href="market.md#0xc0deb00c_market_E_MIN_BASE_EXCEEDS_MAX">E_MIN_BASE_EXCEEDS_MAX</a>);
    // Assert minimum quote less than or equal <b>to</b> maximum.
    <b>assert</b>!(min_quote &lt;= max_quote, <a href="market.md#0xc0deb00c_market_E_MIN_QUOTE_EXCEEDS_MAX">E_MIN_QUOTE_EXCEEDS_MAX</a>);
    // Get inbound asset ceiling and max trade amount, outbound
    // asset available and max trade amount.
    <b>let</b> (in_ceiling, in_max, out_available, out_max) =
        <b>if</b> (direction == <a href="market.md#0xc0deb00c_market_BUY">BUY</a>) // If trade is in buy direction:
            // Getting base and trading away quote.
            (base_ceiling, max_base, quote_available, max_quote) <b>else</b>
            // Else a sell, so getting quote and trading away base.
            (quote_ceiling, max_quote, base_available, max_base);
    // Calculate maximum possible inbound asset ceiling <b>post</b>-match.
    <b>let</b> in_ceiling_max = (in_ceiling <b>as</b> u128) + (in_max <b>as</b> u128);
    // Assert max possible inbound asset ceiling does not overflow.
    <b>assert</b>!(in_ceiling_max &lt;= (<a href="market.md#0xc0deb00c_market_HI_64">HI_64</a> <b>as</b> u128), <a href="market.md#0xc0deb00c_market_E_OVERFLOW_ASSET_IN">E_OVERFLOW_ASSET_IN</a>);
    // Assert enough outbound asset <b>to</b> cover max trade amount.
    <b>assert</b>!(out_max &lt;= out_available, <a href="market.md#0xc0deb00c_market_E_NOT_ENOUGH_ASSET_OUT">E_NOT_ENOUGH_ASSET_OUT</a>);
}
</code></pre>



<a name="0xc0deb00c_market_register_market"></a>

## Function `register_market`

Register order book, fee store under Econia resource account.

Should only be called by <code><a href="market.md#0xc0deb00c_market_register_market_base_coin">register_market_base_coin</a>()</code> or
<code><a href="market.md#0xc0deb00c_market_register_market_base_generic">register_market_base_generic</a>()</code>.

See <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a></code> for commentary on lot size, tick
size, minimum size, and 32-bit prices.


<a name="@Type_parameters_93"></a>

### Type parameters


* <code>BaseType</code>: Base type for market.
* <code>QuoteType</code>: Quote coin type for market.


<a name="@Parameters_94"></a>

### Parameters


* <code>market_id</code>: Market ID for new market.
* <code>base_name_generic</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.base_name_generic</code>
for market.
* <code>lot_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.lot_size</code> for market.
* <code>tick_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.tick_size</code> for market.
* <code>min_size</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.min_size</code> for market.
* <code>underwriter_id</code>: <code><a href="registry.md#0xc0deb00c_registry_MarketInfo">registry::MarketInfo</a>.min_size</code> for market.


<a name="@Returns_95"></a>

### Returns


* <code>u64</code>: Market ID for new market.


<a name="@Testing_96"></a>

### Testing


* <code>test_register_markets()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;BaseType, QuoteType&gt;(market_id: u64, base_name_generic: <a href="_String">string::String</a>, lot_size: u64, tick_size: u64, min_size: u64, underwriter_id: u64): u64
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_register_market">register_market</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id: u64,
    base_name_generic: String,
    lot_size: u64,
    tick_size: u64,
    min_size: u64,
    underwriter_id: u64
): u64
<b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Get Econia resource <a href="">account</a> <a href="">signer</a>.
    <b>let</b> <a href="">resource_account</a> = resource_account::get_signer();
    // Get resource <a href="">account</a> <b>address</b>.
    <b>let</b> resource_address = address_of(&<a href="">resource_account</a>);
    <b>let</b> order_books_map_ref_mut = // Mutably borrow order books map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(resource_address).map;
    // Add order book entry <b>to</b> order books map.
    <a href="tablist.md#0xc0deb00c_tablist_add">tablist::add</a>(order_books_map_ref_mut, market_id, <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>{
        base_type: <a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;(),
        base_name_generic,
        quote_type: <a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;(),
        lot_size,
        tick_size,
        min_size,
        underwriter_id,
        asks: <a href="avl_queue.md#0xc0deb00c_avl_queue_new">avl_queue::new</a>&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;(<a href="market.md#0xc0deb00c_market_ASCENDING">ASCENDING</a>, 0, 0),
        bids: <a href="avl_queue.md#0xc0deb00c_avl_queue_new">avl_queue::new</a>&lt;<a href="market.md#0xc0deb00c_market_Order">Order</a>&gt;(<a href="market.md#0xc0deb00c_market_DESCENDING">DESCENDING</a>, 0, 0),
        counter: 0,
        maker_events:
            <a href="_new_event_handle">account::new_event_handle</a>&lt;<a href="market.md#0xc0deb00c_market_MakerEvent">MakerEvent</a>&gt;(&<a href="">resource_account</a>),
        taker_events:
            <a href="_new_event_handle">account::new_event_handle</a>&lt;<a href="market.md#0xc0deb00c_market_TakerEvent">TakerEvent</a>&gt;(&<a href="">resource_account</a>)});
    // Register an Econia fee store entry for <a href="market.md#0xc0deb00c_market">market</a> quote <a href="">coin</a>.
    <a href="incentives.md#0xc0deb00c_incentives_register_econia_fee_store_entry">incentives::register_econia_fee_store_entry</a>&lt;QuoteType&gt;(market_id);
    market_id // Return <a href="market.md#0xc0deb00c_market">market</a> ID.
}
</code></pre>



<a name="0xc0deb00c_market_swap"></a>

## Function `swap`

Match a taker's swap order against order book for given market.


<a name="@Type_Parameters_97"></a>

### Type Parameters


* <code>BaseType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>QuoteType</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Parameters_98"></a>

### Parameters


* <code>market_id</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>underwriter_id</code>: ID of underwriter to verify if <code>BaseType</code>
is <code><a href="registry.md#0xc0deb00c_registry_GenericAsset">registry::GenericAsset</a></code>, else may be passed as
<code><a href="market.md#0xc0deb00c_market_NO_UNDERWRITER">NO_UNDERWRITER</a></code>.
* <code>taker</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>integrator</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>direction</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_base</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>min_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>max_quote</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>limit_price</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>optional_base_coins</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>quote_coins</code>: Same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Returns_99"></a>

### Returns


* <code>Option&lt;Coin&lt;BaseType&gt;&gt;</code>: Optional updated base coin holdings,
same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>Coin&lt;QuoteType&gt;</code>: Updated quote coin holdings, same as for
<code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Base asset trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin trade amount, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.
* <code>u64</code>: Quote coin fees paid, same as for <code><a href="market.md#0xc0deb00c_market_match">match</a>()</code>.


<a name="@Aborts_100"></a>

### Aborts


* <code><a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a></code>: No market with given ID.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a></code>: Underwriter invalid for given market.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_BASE">E_INVALID_BASE</a></code>: Base asset type is invalid.
* <code><a href="market.md#0xc0deb00c_market_E_INVALID_QUOTE">E_INVALID_QUOTE</a></code>: Quote asset type is invalid.


<a name="@Expected_value_testing_101"></a>

### Expected value testing


* Covered by <code><a href="market.md#0xc0deb00c_market_swap_between_coinstores">swap_between_coinstores</a>()</code>, <code><a href="market.md#0xc0deb00c_market_swap_coins">swap_coins</a>()</code>, and
<code><a href="market.md#0xc0deb00c_market_swap_generic">swap_generic</a>()</code> testing.


<a name="@Failure_testing_102"></a>

### Failure testing


* <code>test_swap_invalid_base()</code>
* <code>test_swap_invalid_market_id()</code>
* <code>test_swap_invalid_quote()</code>
* <code>test_swap_invalid_underwriter()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;BaseType, QuoteType&gt;(market_id: u64, underwriter_id: u64, taker: <b>address</b>, integrator: <b>address</b>, direction: bool, min_base: u64, max_base: u64, min_quote: u64, max_quote: u64, limit_price: u64, optional_base_coins: <a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, quote_coins: <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;): (<a href="_Option">option::Option</a>&lt;<a href="_Coin">coin::Coin</a>&lt;BaseType&gt;&gt;, <a href="_Coin">coin::Coin</a>&lt;QuoteType&gt;, u64, u64, u64)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_swap">swap</a>&lt;
    BaseType,
    QuoteType
&gt;(
    market_id: u64,
    underwriter_id: u64,
    taker: <b>address</b>,
    integrator: <b>address</b>,
    direction: bool,
    min_base: u64,
    max_base: u64,
    min_quote: u64,
    max_quote: u64,
    limit_price: u64,
    optional_base_coins: Option&lt;Coin&lt;BaseType&gt;&gt;,
    quote_coins: Coin&lt;QuoteType&gt;
): (
    Option&lt;Coin&lt;BaseType&gt;&gt;,
    Coin&lt;QuoteType&gt;,
    u64,
    u64,
    u64
) <b>acquires</b> <a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a> {
    // Get <b>address</b> of resource <a href="">account</a> <b>where</b> order books are stored.
    <b>let</b> resource_address = resource_account::get_address();
    <b>let</b> order_books_map_ref_mut = // Mutably borrow order books map.
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="market.md#0xc0deb00c_market_OrderBooks">OrderBooks</a>&gt;(resource_address).map;
    // Assert order books map <b>has</b> order book <b>with</b> given <a href="market.md#0xc0deb00c_market">market</a> ID.
    <b>assert</b>!(<a href="tablist.md#0xc0deb00c_tablist_contains">tablist::contains</a>(order_books_map_ref_mut, market_id),
            <a href="market.md#0xc0deb00c_market_E_INVALID_MARKET_ID">E_INVALID_MARKET_ID</a>);
    <b>let</b> order_book_ref_mut = // Mutably borrow <a href="market.md#0xc0deb00c_market">market</a> order book.
        <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">tablist::borrow_mut</a>(order_books_map_ref_mut, market_id);
    // If passed an underwriter ID, verify it matches <a href="market.md#0xc0deb00c_market">market</a>.
    <b>if</b> (underwriter_id != <a href="market.md#0xc0deb00c_market_NO_UNDERWRITER">NO_UNDERWRITER</a>)
        <b>assert</b>!(underwriter_id == order_book_ref_mut.underwriter_id,
                <a href="market.md#0xc0deb00c_market_E_INVALID_UNDERWRITER">E_INVALID_UNDERWRITER</a>);
    <b>assert</b>!(<a href="_type_of">type_info::type_of</a>&lt;BaseType&gt;() // Assert base type.
            == order_book_ref_mut.base_type, <a href="market.md#0xc0deb00c_market_E_INVALID_BASE">E_INVALID_BASE</a>);
    <b>assert</b>!(<a href="_type_of">type_info::type_of</a>&lt;QuoteType&gt;() // Assert quote type.
            == order_book_ref_mut.quote_type, <a href="market.md#0xc0deb00c_market_E_INVALID_QUOTE">E_INVALID_QUOTE</a>);
    <a href="market.md#0xc0deb00c_market_match">match</a>&lt;BaseType, QuoteType&gt;( // Match against order book.
        market_id, order_book_ref_mut, taker, integrator, direction,
        min_base, max_base, min_quote, max_quote, limit_price,
        optional_base_coins, quote_coins)
}
</code></pre>



<a name="0xc0deb00c_market_index_orders"></a>

## Function `index_orders`

Index order book into ask and bids vectors.

Only for SDK generation.


<a name="@Returns_103"></a>

### Returns


* <code><a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a>&gt;</code>: Asks, sorted by ascending price.
* <code><a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a>&gt;</code>: Bids, sorted by descending price.


<a name="@Testing_104"></a>

### Testing


* <code>test_index_orders()</code>


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_index_orders">index_orders</a>(order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">market::OrderBook</a>): (<a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PricedOrder">market::PricedOrder</a>&gt;, <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PricedOrder">market::PricedOrder</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>fun</b> <a href="market.md#0xc0deb00c_market_index_orders">index_orders</a>(
    order_book_ref_mut: &<b>mut</b> <a href="market.md#0xc0deb00c_market_OrderBook">OrderBook</a>
): (
    <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a>&gt;,
    <a href="">vector</a>&lt;<a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a>&gt;
) {
    // Initialize asks and bids vectors.
    <b>let</b> (asks, bids) = (<a href="">vector</a>[], <a href="">vector</a>[]);
    // Mutably borrow asks AVL queue.
    <b>let</b> orders_ref_mut = &<b>mut</b> order_book_ref_mut.asks;
    // While asks <b>to</b> process:
    <b>while</b>(!<a href="avl_queue.md#0xc0deb00c_avl_queue_is_empty">avl_queue::is_empty</a>(orders_ref_mut)) {
        <b>let</b> price = // Get price of minimum ask in AVL queue.
            *<a href="_borrow">option::borrow</a>(&<a href="avl_queue.md#0xc0deb00c_avl_queue_get_head_key">avl_queue::get_head_key</a>(orders_ref_mut));
        // Remove order from AVL queue.
        <b>let</b> order = <a href="avl_queue.md#0xc0deb00c_avl_queue_pop_head">avl_queue::pop_head</a>(orders_ref_mut);
        // Push back priced order onto asks <a href="">vector</a>.
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> asks, <a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a>{price, order});
    };
    // Mutably borrow bids AVL queue.
    <b>let</b> orders_ref_mut = &<b>mut</b> order_book_ref_mut.bids;
    // While bids <b>to</b> process:
    <b>while</b>(!<a href="avl_queue.md#0xc0deb00c_avl_queue_is_empty">avl_queue::is_empty</a>(orders_ref_mut)) {
        <b>let</b> price = // Get price of maximum bid in AVL queue.
            *<a href="_borrow">option::borrow</a>(&<a href="avl_queue.md#0xc0deb00c_avl_queue_get_head_key">avl_queue::get_head_key</a>(orders_ref_mut));
        // Remove order from AVL queue.
        <b>let</b> order = <a href="avl_queue.md#0xc0deb00c_avl_queue_pop_head">avl_queue::pop_head</a>(orders_ref_mut);
        // Push back priced order onto bids <a href="">vector</a>.
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> bids, <a href="market.md#0xc0deb00c_market_PricedOrder">PricedOrder</a>{price, order});
    };
    (asks, bids) // Return indexed asks and bids.
}
</code></pre>
