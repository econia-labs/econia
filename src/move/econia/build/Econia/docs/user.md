
<a name="0xc0deb00c_user"></a>

# Module `0xc0deb00c::user`

User-side book keeping and, optionally, collateral management.

For a given market, a user can register multiple <code>MarketAccount</code>s,
with each such market account having a different delegated custodian
ID and therefore a unique <code>MarketAccountInfo</code>: hence, each market
account has a particular "user-specific" custodian ID. For a given
<code>MarketAccount</code>, a user has entries in a <code>Collateral</code> map for each
asset that is a coin type.

For assets that are not a coin type, the "market-wide generic asset
transfer" custodian (<code><a href="registry.md#0xc0deb00c_registry_TradingPairInfo">registry::TradingPairInfo</a></code>) is required to
verify deposits and withdrawals. Hence a user-specific general
custodian overrides a market-wide generic asset transfer
custodian when placing or cancelling trades on an asset-agnostic
market, whereas the market-wide generic asset transfer custodian
overrides the user-specific general custodian ID when depositing or
withdrawing a non-coin asset.


-  [Function `return_0`](#0xc0deb00c_user_return_0)


<pre><code></code></pre>



<a name="0xc0deb00c_user_return_0"></a>

## Function `return_0`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user.md#0xc0deb00c_user_return_0">return_0</a>(): u8 {0}
</code></pre>



</details>
