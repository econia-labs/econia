
<a name="0xc0deb00c_test"></a>

# Module `0xc0deb00c::test`

Sample function calls for on-chain testing.


-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xc0deb00c_test_init_module)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="assets.md#0xc0deb00c_assets">0xc0deb00c::assets</a>;
<b>use</b> <a href="market.md#0xc0deb00c_market">0xc0deb00c::market</a>;
<b>use</b> <a href="registry.md#0xc0deb00c_registry">0xc0deb00c::registry</a>;
<b>use</b> <a href="user.md#0xc0deb00c_user">0xc0deb00c::user</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_test_ASK"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_ASK">ASK</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_test_ASK_PRICE"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_ASK_PRICE">ASK_PRICE</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_test_ASK_SIZE"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_ASK_SIZE">ASK_SIZE</a>: u64 = 100;
</code></pre>



<a name="0xc0deb00c_test_CUSTODIAN_ID"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_CUSTODIAN_ID">CUSTODIAN_ID</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_test_LOT_SIZE"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_LOT_SIZE">LOT_SIZE</a>: u64 = 10;
</code></pre>



<a name="0xc0deb00c_test_MARKET_ID"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_MARKET_ID">MARKET_ID</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_test_MINT_AMOUNT"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_MINT_AMOUNT">MINT_AMOUNT</a>: u64 = 1000000000;
</code></pre>



<a name="0xc0deb00c_test_TICK_SIZE"></a>



<pre><code><b>const</b> <a href="test.md#0xc0deb00c_test_TICK_SIZE">TICK_SIZE</a>: u64 = 25;
</code></pre>



<a name="0xc0deb00c_test_init_module"></a>

## Function `init_module`

Set up the registry, init coin types, register a market,
register a market account, deposit coins, and place a trade.


<pre><code><b>fun</b> <a href="test.md#0xc0deb00c_test_init_module">init_module</a>(econia: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="test.md#0xc0deb00c_test_init_module">init_module</a>(
    econia: &<a href="">signer</a>
) {

    <a href="registry.md#0xc0deb00c_registry_init_registry">registry::init_registry</a>(econia); // Initialize <a href="registry.md#0xc0deb00c_registry">registry</a>.
    <a href="assets.md#0xc0deb00c_assets_init_coin_types">assets::init_coin_types</a>(econia); // Initialize <a href="">coin</a> types.
    // Register a pure <a href="">coin</a> <a href="market.md#0xc0deb00c_market">market</a>.
    <a href="market.md#0xc0deb00c_market_register_market_pure_coin">market::register_market_pure_coin</a>&lt;BC, QC&gt;(econia, <a href="test.md#0xc0deb00c_test_LOT_SIZE">LOT_SIZE</a>, <a href="test.md#0xc0deb00c_test_TICK_SIZE">TICK_SIZE</a>);
    // Register a <a href="user.md#0xc0deb00c_user">user</a> <b>to</b> trade on the <a href="market.md#0xc0deb00c_market">market</a>.
    <a href="user.md#0xc0deb00c_user_register_market_account">user::register_market_account</a>&lt;BC, QC&gt;(econia, <a href="test.md#0xc0deb00c_test_MARKET_ID">MARKET_ID</a>, <a href="test.md#0xc0deb00c_test_CUSTODIAN_ID">CUSTODIAN_ID</a>);
    // Deposit quote coins <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
    <a href="user.md#0xc0deb00c_user_deposit_coins">user::deposit_coins</a>&lt;QC&gt;(@econia, <a href="test.md#0xc0deb00c_test_MARKET_ID">MARKET_ID</a>, <a href="test.md#0xc0deb00c_test_CUSTODIAN_ID">CUSTODIAN_ID</a>,
        <a href="assets.md#0xc0deb00c_assets_mint">assets::mint</a>(econia, <a href="test.md#0xc0deb00c_test_MINT_AMOUNT">MINT_AMOUNT</a>));
    // Deposit base coins <b>to</b> <a href="user.md#0xc0deb00c_user">user</a>'s <a href="market.md#0xc0deb00c_market">market</a> <a href="">account</a>.
    <a href="user.md#0xc0deb00c_user_deposit_coins">user::deposit_coins</a>&lt;BC&gt;(@econia, <a href="test.md#0xc0deb00c_test_MARKET_ID">MARKET_ID</a>, <a href="test.md#0xc0deb00c_test_CUSTODIAN_ID">CUSTODIAN_ID</a>,
        <a href="assets.md#0xc0deb00c_assets_mint">assets::mint</a>(econia, <a href="test.md#0xc0deb00c_test_MINT_AMOUNT">MINT_AMOUNT</a>));
    // Place an ask.
    <a href="market.md#0xc0deb00c_market_place_limit_order_user">market::place_limit_order_user</a>&lt;BC, QC&gt;(econia, @econia, <a href="test.md#0xc0deb00c_test_MARKET_ID">MARKET_ID</a>,
        <a href="test.md#0xc0deb00c_test_ASK">ASK</a>, <a href="test.md#0xc0deb00c_test_ASK_SIZE">ASK_SIZE</a>, <a href="test.md#0xc0deb00c_test_ASK_PRICE">ASK_PRICE</a>, <b>false</b>, <b>false</b>, <b>false</b>);
}
</code></pre>



</details>
