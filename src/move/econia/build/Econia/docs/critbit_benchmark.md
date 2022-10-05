
<a name="0xc0deb00c_critbit_benchmark"></a>

# Module `0xc0deb00c::critbit_benchmark`

Wrappers for on-chain <code>CritBitTree</code> benchmarking.


-  [Resource `TreeStore`](#0xc0deb00c_critbit_benchmark_TreeStore)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xc0deb00c_critbit_benchmark_init_module)
-  [Function `borrow`](#0xc0deb00c_critbit_benchmark_borrow)
-  [Function `insert`](#0xc0deb00c_critbit_benchmark_insert)
-  [Function `pop`](#0xc0deb00c_critbit_benchmark_pop)
-  [Function `pop_twice`](#0xc0deb00c_critbit_benchmark_pop_twice)
-  [Function `reset`](#0xc0deb00c_critbit_benchmark_reset)
-  [Function `clear`](#0xc0deb00c_critbit_benchmark_clear)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
<b>use</b> <a href="critbit.md#0xc0deb00c_critbit">0xc0deb00c::critbit</a>;
</code></pre>



<a name="0xc0deb00c_critbit_benchmark_TreeStore"></a>

## Resource `TreeStore`

Stores a <code>CritBitTree</code> in a table, so it can be effectively
emptied and reset.


<pre><code><b>struct</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;<b>address</b>&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_critbit_benchmark_E_NOT_ECONIA"></a>

When not called by Econia.


<pre><code><b>const</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_critbit_benchmark_init_module"></a>

## Function `init_module`

Initialize a <code><a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a></code> under <code>econia</code> account.


<pre><code><b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_init_module">init_module</a>(econia: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_init_module">init_module</a>(
    econia: &<a href="">signer</a>
) {
    <b>let</b> tree = <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(); // Get tree
    <b>let</b> map = <a href="_new">table_with_length::new</a>();  // Get store map.
    // Add tree <b>to</b> map.
    <a href="_add">table_with_length::add</a>(&<b>mut</b> map, 1, tree);
    // Get tree store
    <b>let</b> tree_store = <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>{map};
    // Move tree store <b>to</b> Econia <a href="">account</a>.
    <b>move_to</b>&lt;<a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>&gt;(econia, tree_store);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_benchmark_borrow"></a>

## Function `borrow`

Immutably borrow from the tree.


<pre><code><b>public</b> <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_borrow">borrow</a>(<a href="">account</a>: &<a href="">signer</a>, key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_borrow">borrow</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    key: u128
) <b>acquires</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Immutably borrow tree store map.
    <b>let</b> tree_store_map_ref = &<b>borrow_global</b>&lt;<a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>&gt;(@econia).map;
    <b>let</b> reset_count = <a href="_length">table_with_length::length</a>(
        tree_store_map_ref); // Get reset count.
    // Immutably borrow corresponding tree.
    <b>let</b> tree_ref = <a href="_borrow">table_with_length::borrow</a>(
        tree_store_map_ref, reset_count);
    // Borrow <b>address</b> corresponding <b>to</b> given key.
    <b>let</b> address_ref = <a href="critbit.md#0xc0deb00c_critbit_borrow">critbit::borrow</a>(tree_ref, key);
    // Assert <b>address</b> is Econia.
    <b>assert</b>!(*address_ref == @econia, <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_benchmark_insert"></a>

## Function `insert`

Insert the given key.


<pre><code><b>public</b> <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_insert">insert</a>(<a href="">account</a>: &<a href="">signer</a>, key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_insert">insert</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    key: u128
) <b>acquires</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow tree store map.
    <b>let</b> tree_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>&gt;(@econia).map;
    <b>let</b> reset_count = <a href="_length">table_with_length::length</a>(
        tree_store_map_ref_mut); // Get reset count.
    // Mutably borrow corresponding tree.
    <b>let</b> tree_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
        tree_store_map_ref_mut, reset_count);
    // Insert key and bogus <b>address</b>.
    <a href="critbit.md#0xc0deb00c_critbit_insert">critbit::insert</a>(tree_ref_mut, key, @econia);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_benchmark_pop"></a>

## Function `pop`

Pop key and discard value.


<pre><code><b>public</b> <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_pop">pop</a>(<a href="">account</a>: &<a href="">signer</a>, key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_pop">pop</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    key: u128
) <b>acquires</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow tree store map.
    <b>let</b> tree_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>&gt;(@econia).map;
    <b>let</b> reset_count = <a href="_length">table_with_length::length</a>(
        tree_store_map_ref_mut); // Get reset count.
    // Mutably borrow corresponding tree.
    <b>let</b> tree_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
        tree_store_map_ref_mut, reset_count);
    // Remove key and discard value.
    <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, key);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_benchmark_pop_twice"></a>

## Function `pop_twice`

Pop both keys and discard values.


<pre><code><b>public</b> <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_pop_twice">pop_twice</a>(<a href="">account</a>: &<a href="">signer</a>, key_1: u128, key_2: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_pop_twice">pop_twice</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    key_1: u128,
    key_2: u128,
) <b>acquires</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> {
    <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_pop">pop</a>(<a href="">account</a>, key_1);
    <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_pop">pop</a>(<a href="">account</a>, key_2);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_benchmark_reset"></a>

## Function `reset`

Reset with a new tree.


<pre><code><b>public</b> <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_reset">reset</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_reset">reset</a>(
    <a href="">account</a>: &<a href="">signer</a>
) <b>acquires</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow tree store map.
    <b>let</b> tree_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>&gt;(@econia).map;
    <b>let</b> reset_count = <a href="_length">table_with_length::length</a>(
        tree_store_map_ref_mut); // Get reset count.
    <b>let</b> tree = <a href="critbit.md#0xc0deb00c_critbit_empty">critbit::empty</a>(); // Get new tree.
    // Add new tree <b>to</b> store map.
    <a href="_add">table_with_length::add</a>(tree_store_map_ref_mut, reset_count + 1, tree);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_benchmark_clear"></a>

## Function `clear`

Clear tree out.


<pre><code><b>public</b> <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_clear">clear</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_clear">clear</a>(
    <a href="">account</a>: &<a href="">signer</a>
) <b>acquires</b> <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow tree store map.
    <b>let</b> tree_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critbit_benchmark.md#0xc0deb00c_critbit_benchmark_TreeStore">TreeStore</a>&gt;(@econia).map;
    <b>let</b> reset_count = <a href="_length">table_with_length::length</a>(
        tree_store_map_ref_mut); // Get reset count.
    // Mutably borrow corresponding tree.
    <b>let</b> tree_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
        tree_store_map_ref_mut, reset_count);
    // While tree is not empty:
    <b>while</b> (!<a href="critbit.md#0xc0deb00c_critbit_is_empty">critbit::is_empty</a>(tree_ref_mut)) {
        // Get max key.
        <b>let</b> max_key = <a href="critbit.md#0xc0deb00c_critbit_max_key">critbit::max_key</a>(tree_ref_mut);
        // Pop it.
        <a href="critbit.md#0xc0deb00c_critbit_pop">critbit::pop</a>(tree_ref_mut, max_key);
    };
}
</code></pre>



</details>
