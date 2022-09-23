
<a name="0xc0deb00c_registry"></a>

# Module `0xc0deb00c::registry`



-  [Function `use_friend`](#0xc0deb00c_registry_use_friend)


<pre><code><b>use</b> <a href="incentives.md#0xc0deb00c_incentives">0xc0deb00c::incentives</a>;
</code></pre>



<a name="0xc0deb00c_registry_use_friend"></a>

## Function `use_friend`



<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_use_friend">use_friend</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="registry.md#0xc0deb00c_registry_use_friend">use_friend</a>() {<a href="incentives.md#0xc0deb00c_incentives_calculate_max_quote_match">incentives::calculate_max_quote_match</a>(<b>false</b>, 0, 0);}
</code></pre>



</details>
