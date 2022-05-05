
<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin"></a>

# Module `0x1d157846c6d7ac69cbbc60590c325683::Coin`

APT and USD coin functionality w/ custom token standard


-  [Struct `APT`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT)
-  [Struct `USD`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD)
-  [Struct `Coin`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin)
-  [Resource `Balance`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance)
-  [Constants](#@Constants_0)
-  [Function `airdrop`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_airdrop)
-  [Function `balance_of`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_balance_of)
-  [Function `burn`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_burn)
-  [Function `deposit`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit)
-  [Function `deposit_coins`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit_coins)
-  [Function `get_empty_coin`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_get_empty_coin)
-  [Function `mint`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_mint)
-  [Function `merge_coins`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coins)
-  [Function `merge_coin_to_target`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coin_to_target)
-  [Function `publish_balance`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balance)
-  [Function `publish_balances`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balances)
-  [Function `report_subunits`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_report_subunits)
-  [Function `split_coin`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin)
-  [Function `split_coin_from_target`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin_from_target)
-  [Function `transfer`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer)
-  [Function `transfer_both_coins`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer_both_coins)
-  [Function `withdraw`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw)
-  [Function `withdraw_coins`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw_coins)
-  [Function `yield_coin`](#0x1d157846c6d7ac69cbbc60590c325683_Coin_yield_coin)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_APT"></a>

## Struct `APT`



<pre><code><b>struct</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_USD"></a>

## Struct `USD`



<pre><code><b>struct</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin"></a>

## Struct `Coin`

Generic coin type


<pre><code><b>struct</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>subunits: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance"></a>

## Resource `Balance`

Represents balance of given Coin Type


<pre><code><b>struct</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_APT_SCALE"></a>

Scale for converting subunits to decimal (base-10 exponent).
With a scale of 3, for example, 1 subunit = 0.001 base unit


<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT_SCALE">APT_SCALE</a>: u8 = 6;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_ALREADY_HAS_BALANCE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_ALREADY_HAS_BALANCE">E_ALREADY_HAS_BALANCE</a>: u64 = 0;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_APT_AIRDROP_VAL"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_APT_AIRDROP_VAL">E_APT_AIRDROP_VAL</a>: u64 = 4;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_APT_NOT_PUBLISH_0"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_APT_NOT_PUBLISH_0">E_APT_NOT_PUBLISH_0</a>: u64 = 2;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_COIN_MERGE_FAILURE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_COIN_MERGE_FAILURE">E_COIN_MERGE_FAILURE</a>: u64 = 13;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_DEPOSIT_COINS_FAILURE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_DEPOSIT_COINS_FAILURE">E_DEPOSIT_COINS_FAILURE</a>: u64 = 19;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_FAILED_TRANSFER"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_FAILED_TRANSFER">E_FAILED_TRANSFER</a>: u64 = 7;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INSUFFICIENT_BALANCE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INSUFFICIENT_BALANCE">E_INSUFFICIENT_BALANCE</a>: u64 = 6;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_AIRDROP"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_AIRDROP">E_INVALID_AIRDROP</a>: u64 = 1;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_BURN"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_BURN">E_INVALID_BURN</a>: u64 = 22;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_REPORT"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_REPORT">E_INVALID_REPORT</a>: u64 = 9;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_MERGE_TO_TARGET_FAILURE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_MERGE_TO_TARGET_FAILURE">E_MERGE_TO_TARGET_FAILURE</a>: u64 = 16;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_MODIFIED_VALUE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_MODIFIED_VALUE">E_MODIFIED_VALUE</a>: u64 = 10;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_NOT_EMPTY"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_NOT_EMPTY">E_NOT_EMPTY</a>: u64 = 8;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_NOT_ENOUGH_TO_SPLIT"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_NOT_ENOUGH_TO_SPLIT">E_NOT_ENOUGH_TO_SPLIT</a>: u64 = 14;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_AMOUNT_TOO_HIGH"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_AMOUNT_TOO_HIGH">E_SPLIT_AMOUNT_TOO_HIGH</a>: u64 = 17;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_FAILURE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_FAILURE">E_SPLIT_FAILURE</a>: u64 = 15;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_FROM_TARGET_FAILURE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_FROM_TARGET_FAILURE">E_SPLIT_FROM_TARGET_FAILURE</a>: u64 = 18;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_USD_AIRDROP_VAL"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_USD_AIRDROP_VAL">E_USD_AIRDROP_VAL</a>: u64 = 5;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_USD_NOT_PUBLISH_0"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_USD_NOT_PUBLISH_0">E_USD_NOT_PUBLISH_0</a>: u64 = 3;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_WITHDRAW_NOT_YIELD"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_WITHDRAW_NOT_YIELD">E_WITHDRAW_NOT_YIELD</a>: u64 = 11;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_WITHDRAW_WRONG_BALANCE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_WITHDRAW_WRONG_BALANCE">E_WITHDRAW_WRONG_BALANCE</a>: u64 = 12;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_WRONG_YIELD_VALUE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_WRONG_YIELD_VALUE">E_WRONG_YIELD_VALUE</a>: u64 = 21;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_E_YIELD_INVALID"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_YIELD_INVALID">E_YIELD_INVALID</a>: u64 = 20;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_USD_SCALE"></a>



<pre><code><b>const</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD_SCALE">USD_SCALE</a>: u8 = 12;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_airdrop"></a>

## Function `airdrop`

Mint APT and USD to a given address. May only be invoked by
Ultima account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_airdrop">airdrop</a>(authority: &signer, addr: <b>address</b>, apt_subunits: u64, usd_subunits: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_airdrop">airdrop</a>(
    authority: &signer,
    addr: <b>address</b>,
    apt_subunits: u64,
    usd_subunits: u64
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <b>assert</b>!(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(authority) == @Ultima, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_AIRDROP">E_INVALID_AIRDROP</a>);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_mint">mint</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>&gt;(addr, apt_subunits);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_mint">mint</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>&gt;(addr, usd_subunits);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_balance_of"></a>

## Function `balance_of`

Get balance of given coin type, in subunits, at an address


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_balance_of">balance_of</a>&lt;CoinType&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_balance_of">balance_of</a>&lt;CoinType&gt;(
    addr: <b>address</b>
): u64
<b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <b>borrow_global</b>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.subunits
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_burn"></a>

## Function `burn`

Burn passed coin, can only be invoked by Ultima account


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_burn">burn</a>&lt;CoinType&gt;(account: &signer, coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_burn">burn</a>&lt;CoinType&gt;(
    account: &signer,
    coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
) {
    <b>assert</b>!(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @Ultima, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INVALID_BURN">E_INVALID_BURN</a>);
    <b>let</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: _} = coin;
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit"></a>

## Function `deposit`

Deposit moved coin amount to a given address


<pre><code><b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit">deposit</a>&lt;CoinType&gt;(addr: <b>address</b>, coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit">deposit</a>&lt;CoinType&gt;(
    addr: <b>address</b>,
    coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <b>let</b> balance_ref =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.subunits;
    // Destruct moved coin amount
    <b>let</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>{subunits} = coin;
    *balance_ref = *balance_ref + subunits;
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit_coins"></a>

## Function `deposit_coins`

Deposit coins into balance


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit_coins">deposit_coins</a>(addr: <b>address</b>, apt: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">Coin::APT</a>&gt;, usd: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">Coin::USD</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit_coins">deposit_coins</a>(
    addr: <b>address</b>,
    apt: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>&gt;,
    usd: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>&gt;,
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit">deposit</a>(addr, apt);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit">deposit</a>(addr, usd);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_get_empty_coin"></a>

## Function `get_empty_coin`

Return coin with 0 subunits, useful for initialization elsewhere


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_get_empty_coin">get_empty_coin</a>&lt;CoinType&gt;(): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_get_empty_coin">get_empty_coin</a>&lt;CoinType&gt;():
<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt; {
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: 0}
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_mint"></a>

## Function `mint`

Mint amount of given coin, in subunits, to address


<pre><code><b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_mint">mint</a>&lt;CoinType&gt;(addr: <b>address</b>, subunits: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_mint">mint</a>&lt;CoinType&gt;(
    addr: <b>address</b>,
    subunits: u64
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit">deposit</a>&lt;CoinType&gt;(addr, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits});
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coins"></a>

## Function `merge_coins`

Merge two coin resources into one with appropriate balance


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coins">merge_coins</a>&lt;CoinType&gt;(c1: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;, c2: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coins">merge_coins</a>&lt;CoinType&gt;(
    c1: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;,
    c2: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt; {
    <b>let</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: subs1} = c1;
    <b>let</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: subs2} = c2;
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: subs1 + subs2}
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coin_to_target"></a>

## Function `merge_coin_to_target`

Merge inbound coin to a target coin at a mutable reference


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coin_to_target">merge_coin_to_target</a>&lt;CoinType&gt;(inbound: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;, target_coin_ref: &<b>mut</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_merge_coin_to_target">merge_coin_to_target</a>&lt;CoinType&gt;(
    inbound: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;, // Inbound coin
    // Mutable reference <b>to</b> target coin
    target_coin_ref: &<b>mut</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
): (
    u64, // Inbound subunits
    u64, // Subunits in target coin pre-merge
    u64, // Subunits in target coin <b>post</b>-merge
) {
    <b>let</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: in} = inbound;
    <b>let</b> subunits_ref = &<b>mut</b> target_coin_ref.subunits;
    <b>let</b> pre = *subunits_ref;
    *subunits_ref = pre + in;
    (in, pre, *subunits_ref)
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balance"></a>

## Function `publish_balance`

Publish empty balance resource under signer's account. Must
be called before minting/transferring to the account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balance">publish_balance</a>&lt;CoinType&gt;(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balance">publish_balance</a>&lt;CoinType&gt;(
    account: &signer
) {
    <b>let</b> empty_coin = <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: 0};
    <b>assert</b>!(
        !<b>exists</b>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a>&lt;CoinType&gt;&gt;(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account)),
        <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_ALREADY_HAS_BALANCE">E_ALREADY_HAS_BALANCE</a>
    );
    <b>move_to</b>(account, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a>&lt;CoinType&gt;{coin: empty_coin});
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balances"></a>

## Function `publish_balances`

Publish both APT and USD balances under the signer's account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balances">publish_balances</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balances">publish_balances</a>(
    account: &signer
) {
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balance">publish_balance</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>&gt;(account);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_publish_balance">publish_balance</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>&gt;(account);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_report_subunits"></a>

## Function `report_subunits`

Report number of subunits inside a coin


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_report_subunits">report_subunits</a>&lt;CoinType&gt;(coin_ref: &<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_report_subunits">report_subunits</a>&lt;CoinType&gt;(
    coin_ref: &<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
): u64 {
    coin_ref.subunits
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin"></a>

## Function `split_coin`

Split a coin resource into two, conserving total subunit count


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin">split_coin</a>&lt;CoinType&gt;(coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;, amount: u64): (<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin">split_coin</a>&lt;CoinType&gt;(
    coin: <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;,
    amount: u64,
): (
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;, // Requested amount
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;, // Remainder
) {
    <b>let</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: available} = coin;
    <b>assert</b>!(amount &lt;= available, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_NOT_ENOUGH_TO_SPLIT">E_NOT_ENOUGH_TO_SPLIT</a>);
    <b>let</b> remainder = available - amount;
    (<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: amount}, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: remainder})
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin_from_target"></a>

## Function `split_coin_from_target`

Split off coin resource from target coin at a mutable reference


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin_from_target">split_coin_from_target</a>&lt;CoinType&gt;(amount: u64, target_coin_ref: &<b>mut</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;): (<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_split_coin_from_target">split_coin_from_target</a>&lt;CoinType&gt;(
    amount: u64, // Amount <b>to</b> split off
    target_coin_ref: &<b>mut</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
): (
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;, // New coin resource containing requested amount
    u64, // Subunits in target coin pre-merge
    u64, // Subunits in target coin <b>post</b>-merge
) {
    <b>let</b> subunits_ref = &<b>mut</b> target_coin_ref.subunits;
    <b>let</b> pre = *subunits_ref;
    <b>assert</b>!(amount &lt;= pre, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_SPLIT_AMOUNT_TOO_HIGH">E_SPLIT_AMOUNT_TOO_HIGH</a>);
    <b>let</b> <b>post</b> = pre - amount;
    *subunits_ref = <b>post</b>;
    (
        <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: amount},
        pre,
        <b>post</b>
    )
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer"></a>

## Function `transfer`

Transfer specified amount from sender to recipient


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer">transfer</a>&lt;CoinType&gt;(sender: &signer, recipient: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer">transfer</a>&lt;CoinType&gt;(
    sender: &signer,
    recipient: <b>address</b>,
    amount: u64
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_deposit">deposit</a>&lt;CoinType&gt;(
        recipient,
        <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw">withdraw</a>&lt;CoinType&gt;(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), amount)
    );
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer_both_coins"></a>

## Function `transfer_both_coins`

Wrapper to send both coin types in one transaction


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer_both_coins">transfer_both_coins</a>(sender: &signer, recipient: <b>address</b>, apt_subunits: u64, usd_subunits: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer_both_coins">transfer_both_coins</a>(
    sender: &signer,
    recipient: <b>address</b>,
    apt_subunits: u64,
    usd_subunits: u64,
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer">transfer</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>&gt;(sender, recipient, apt_subunits);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_transfer">transfer</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>&gt;(sender, recipient, usd_subunits);
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw"></a>

## Function `withdraw`

Withdraw specified subunits of given coin from address balance


<pre><code><b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw">withdraw</a>&lt;CoinType&gt;(addr: <b>address</b>, amount: u64): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw">withdraw</a>&lt;CoinType&gt;(
    addr: <b>address</b>,
    amount: u64
): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;
<b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <b>let</b> balance = <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_balance_of">balance_of</a>&lt;CoinType&gt;(addr);
    <b>assert</b>!(amount &lt;= balance, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_INSUFFICIENT_BALANCE">E_INSUFFICIENT_BALANCE</a>);
    <b>let</b> balance_ref =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.subunits;
    *balance_ref = balance - amount;
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits: amount}
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw_coins"></a>

## Function `withdraw_coins`

Return coins withdrawn from balance


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw_coins">withdraw_coins</a>(account: &signer, apt_subunits: u64, usd_subunits: u64): (<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">Coin::APT</a>&gt;, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">Coin::USD</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw_coins">withdraw_coins</a>(
    account: &signer,
    apt_subunits: u64,
    usd_subunits: u64
): (
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>&gt;,
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>&gt;
) <b>acquires</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Balance">Balance</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    (<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw">withdraw</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_APT">APT</a>&gt;(addr, apt_subunits), <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_withdraw">withdraw</a>&lt;<a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_USD">USD</a>&gt;(addr, usd_subunits))
}
</code></pre>



</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_Coin_yield_coin"></a>

## Function `yield_coin`

Return a coin of specified type, with given subunits. Can only
be invoked by Ultima account


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_yield_coin">yield_coin</a>&lt;CoinType&gt;(account: &signer, subunits: u64): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_Coin">Coin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_yield_coin">yield_coin</a>&lt;CoinType&gt;(
    account: &signer,
    subunits: u64
): <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt; {
    <b>assert</b>!(<a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == @Ultima, <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin_E_YIELD_INVALID">E_YIELD_INVALID</a>);
    <a href="Coin.md#0x1d157846c6d7ac69cbbc60590c325683_Coin">Coin</a>&lt;CoinType&gt;{subunits}
}
</code></pre>



</details>
