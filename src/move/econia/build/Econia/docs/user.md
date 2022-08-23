
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side book keeping and, optionally, collateral management.


<a name="@Market_account_custodians_0"></a>

## Market account custodians


For any given market, designated by a unique market ID, a user can
register multiple <code>MarketAccount</code>s, distinguished from one another
by their corresponding "general custodian ID". The custodian
capability having this ID is required to approve all market
transactions within the market account with the exception of generic
asset transfers, which are approved by a market-wide "generic
asset transfer custodian" in the case of a market having at least
one non-coin asset. When a general custodian ID is marked
<code>NO_CUSTODIAN</code>, a signing user is required to approve general
transactions rather than a custodian capability.

For example: market 5 has a generic (non-coin) base asset, a coin
quote asset, and generic asset transfer custodian ID 6. A user
opens two market accounts for market 5, one having general
custodian ID 7, and one having general custodian ID <code>NO_CUSTODIAN</code>.
When a user wishes to deposit base assets to the first market
account, custodian 6 is required for authorization. Then when the
user wishes to submit an ask, custodian 7 must approve it. As for
the second account, a user can deposit and withdraw quote coins,
and place or cancel trades via a signature, but custodian 6 is
still required to verify base deposits and withdrawals.

In other words, the market-wide generic asset transfer custodian ID
overrides the user-specific general custodian ID only when
depositing or withdrawing generic assets, otherwise the
user-specific general custodian ID takes precedence. Notably, a user
can register a <code>MarketAccount</code> having the same general custodian ID
and generic asset transfer custodian ID, and here, no overriding
takes place. For example, if market 8 requires generic asset
transfer custodian ID 9, a user can still register a market account
having general custodian ID 9, and then custodian 9 will be required
to authorize all of a user's transactions for the given
<code>MarketAccount</code>


<a name="@Market_account_ID_1"></a>

## Market account ID


Since any of a user's <code>MarketAccount</code>s are specified by a
unique combination of market ID and general custodian ID, a user's
market account ID is thus defined as a 128-bit number, where the
most-significant ("first") 64 bits correspond to the market ID, and
the least-significant ("last") 64 bits correspond to the general
custodian ID.

For a market ID of <code>255</code> (<code>0b11111111</code>) and a general custodian ID
of <code>170</code> (<code>0b10101010</code>), for example, the corresponding market
account ID has the first 64 bits
<code>0000000000000000000000000000000000000000000000000000000011111111</code>
and the last 64 bits
<code>0000000000000000000000000000000000000000000000000000000010101010</code>,
corresponding to the base-10 integer <code>4703919738795935662250</code>. Note
that when a user opts to sign general transactions rather than
delegate to a general custodian, the market account ID uses a
general custodian ID of <code>NO_CUSTODIAN</code>, corresponding to <code>0</code>.


-  [Market account custodians](#@Market_account_custodians_0)
-  [Market account ID](#@Market_account_ID_1)
-  [Constants](#@Constants_2)
-  [Function `return_0`](#0xc0deb00c_user_return_0)
-  [Function `get_market_account_id`](#0xc0deb00c_user_get_market_account_id)
-  [Function `get_market_id`](#0xc0deb00c_user_get_market_id)
-  [Function `get_general_custodian_id`](#0xc0deb00c_user_get_general_custodian_id)


<pre><code></code></pre>



<a name="@Constants_2"></a>

## Constants


<a name="0xc0deb00c_user_FIRST_64"></a>

Positions to bitshift for operating on first 64 bits


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_FIRST_64">FIRST_64</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_user_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="user.md#0xc0deb00c_user_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_user_return_0"></a>

## Function `return_0`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8 {0}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_market_account_id"></a>

## Function `get_market_account_id`

Return market account ID for given <code>market_id</code> and
<code>general_custodian_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(market_id: u64, general_custodian_id: u64): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_account_id">get_market_account_id</a>(
    market_id: u64,
    general_custodian_id: u64
): u128 {
    (market_id <b>as</b> u128) &lt;&lt; <a href="user.md#0xc0deb00c_user_FIRST_64">FIRST_64</a> | (general_custodian_id <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_market_id"></a>

## Function `get_market_id`

Get market ID encoded in <code>market_account_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(market_account_id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_market_id">get_market_id</a>(
    market_account_id: u128
): u64 {
    (market_account_id &gt;&gt; <a href="user.md#0xc0deb00c_user_FIRST_64">FIRST_64</a> <b>as</b> u64)
}
</code></pre>



</details>

<a name="0xc0deb00c_user_get_general_custodian_id"></a>

## Function `get_general_custodian_id`

Get general custodian ID encoded in <code>market_account_id</code>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_general_custodian_id">get_general_custodian_id</a>(market_account_id: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user.md#0xc0deb00c_user_get_general_custodian_id">get_general_custodian_id</a>(
    market_account_id: u128
): u64 {
    (market_account_id & (<a href="user.md#0xc0deb00c_user_HI_64">HI_64</a> <b>as</b> u128) <b>as</b> u64)
}
</code></pre>



</details>
