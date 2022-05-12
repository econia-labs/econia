
<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST"></a>

# Module `0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178::AlnokiBST`

Hackathon BST demo


-  [Resource `AlnokiBST`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_AlnokiBST)
-  [Function `alnoki_publish`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_publish)
-  [Function `alnoki_insert`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_insert)
-  [Function `alnoki_min`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_min)
-  [Function `alnoki_max`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_max)
-  [Function `alnoki_get`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_get)
-  [Function `alnoki_has_key`](#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_has_key)


<pre><code><b>use</b> <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST">0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178::BST</a>;
</code></pre>



<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_AlnokiBST"></a>

## Resource `AlnokiBST`

Holder for BST in global storage, with query results


<pre><code><b>struct</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bst: <a href="BST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_BST_BST">BST::BST</a>&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>result: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_publish"></a>

## Function `alnoki_publish`

Publish a BST holder with an empty BST to signing account


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_publish">alnoki_publish</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_publish">alnoki_publish</a>(
    account: &signer
) {
    <b>move_to</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(account, <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>{bst: empty&lt;u64&gt;(), result: 0});
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_insert"></a>

## Function `alnoki_insert`

Insert key-value pair to BST


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_insert">alnoki_insert</a>(account: &signer, k: u64, v: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_insert">alnoki_insert</a>(
    account: &signer,
    k: u64,
    v: u64
) <b>acquires</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bst = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).bst;
    insert&lt;u64&gt;(bst, k, v);
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_min"></a>

## Function `alnoki_min`

Get min key in BST, store value in result


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_min">alnoki_min</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_min">alnoki_min</a>(
    account: &signer,
) <b>acquires</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bst = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).bst;
    <b>let</b> result = <b>min</b>&lt;u64&gt;(bst);
    <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).result = result;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_max"></a>

## Function `alnoki_max`

Get max key in BST, store value in result


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_max">alnoki_max</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_max">alnoki_max</a>(
    account: &signer,
) <b>acquires</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bst = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).bst;
    <b>let</b> result = max&lt;u64&gt;(bst);
    <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).result = result;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_get"></a>

## Function `alnoki_get`

Get value corresponding to provided key, store in result


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_get">alnoki_get</a>(account: &signer, k: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_get">alnoki_get</a>(
    account: &signer,
    k: u64
) <b>acquires</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bst = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).bst;
    <b>let</b> result = *get_ref&lt;u64&gt;(bst, k);
    <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).result = result;
}
</code></pre>



</details>

<a name="0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_has_key"></a>

## Function `alnoki_has_key`

Update result to 1 if BST has a node with the corresponding key


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_has_key">alnoki_has_key</a>(account: &signer, k: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST_alnoki_has_key">alnoki_has_key</a>(
    account: &signer,
    k: u64
) <b>acquires</b> <a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a> {
    <b>let</b> addr = <a href="../../../build/MoveStdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account);
    <b>let</b> bst = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).bst;
    <b>let</b> result = <b>if</b> (has_key&lt;u64&gt;(bst, k)) 1 <b>else</b> 0;
    <b>borrow_global_mut</b>&lt;<a href="AlnokiBST.md#0x2dc67de0657de53bf43a179eb5ccce8d7102501902dd533a0435f25adf3a1178_AlnokiBST">AlnokiBST</a>&gt;(addr).result = result;
}
</code></pre>



</details>
