
<a name="0xc0deb00c_avl_queue_benchmark"></a>

# Module `0xc0deb00c::avl_queue_benchmark`

Wrappers for on-chain <code>AVLqueue</code> benchmarking.


-  [Struct `Value`](#0xc0deb00c_avl_queue_benchmark_Value)
-  [Resource `AVLqueueStore`](#0xc0deb00c_avl_queue_benchmark_AVLqueueStore)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xc0deb00c_avl_queue_benchmark_init_module)
-  [Function `borrow`](#0xc0deb00c_avl_queue_benchmark_borrow)
-  [Function `insert`](#0xc0deb00c_avl_queue_benchmark_insert)
-  [Function `insert_evict_tail`](#0xc0deb00c_avl_queue_benchmark_insert_evict_tail)
-  [Function `remove`](#0xc0deb00c_avl_queue_benchmark_remove)
-  [Function `clear`](#0xc0deb00c_avl_queue_benchmark_clear)
-  [Function `reset`](#0xc0deb00c_avl_queue_benchmark_reset)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
<b>use</b> <a href="avl_queue.md#0xc0deb00c_avl_queue">0xc0deb00c::avl_queue</a>;
</code></pre>



<a name="0xc0deb00c_avl_queue_benchmark_Value"></a>

## Struct `Value`

Mock insertion value type.


<pre><code><b>struct</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">Value</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>bits: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_avl_queue_benchmark_AVLqueueStore"></a>

## Resource `AVLqueueStore`

Stores an AVL queue in a table, so it can be effectively
emptied and reset.


<pre><code><b>struct</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>map: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">avl_queue_benchmark::Value</a>&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_avl_queue_benchmark_ASCENDING"></a>

Ascending AVL queue flag.


<pre><code><b>const</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_ASCENDING">ASCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_benchmark_init_module"></a>

## Function `init_module`

Initialize an AVL queue under the Econia account.


<pre><code><b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_init_module">init_module</a>(econia: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_init_module">init_module</a>(
    econia: &<a href="">signer</a>
) {
    // Init AVL queue.
    <b>let</b> avlq = <a href="avl_queue.md#0xc0deb00c_avl_queue_new">avl_queue::new</a>(<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_ASCENDING">ASCENDING</a>, 0, 0);
    <b>let</b> map = <a href="_new">table_with_length::new</a>();  // Get store map.
    // Add AVL queue <b>to</b> map.
    <a href="_add">table_with_length::add</a>(&<b>mut</b> map, 1, avlq);
    // Get AVL queue store.
    <b>let</b> avlq_store = <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>{map};
    // Move store <b>to</b> Econia <a href="">account</a>.
    <b>move_to</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(econia, avlq_store);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_benchmark_borrow"></a>

## Function `borrow`

Immutably borrow from the AVL queue and assert value.


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_borrow">borrow</a>(<a href="">account</a>: &<a href="">signer</a>, access_key: u64, expected_bits: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_borrow">borrow</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    access_key: u64,
    expected_bits: u128
) <b>acquires</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> {
    <b>let</b> addr = address_of(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>.
    // Immutably borrow AVL queue store map.
    <b>let</b> avlq_store_map_ref = &<b>borrow_global</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(addr).map;
    <b>let</b> reset_count = // Get reset count.
        <a href="_length">table_with_length::length</a>(avlq_store_map_ref);
    <b>let</b> avlq_ref = // Immutably borrow corresponding AVL queue.
        <a href="_borrow">table_with_length::borrow</a>(avlq_store_map_ref, reset_count);
    // Borrow <b>address</b> corresponding <b>to</b> given key.
    <b>let</b> value_ref = <a href="avl_queue.md#0xc0deb00c_avl_queue_borrow">avl_queue::borrow</a>(avlq_ref, access_key);
    // Assert expected bits.
    <b>assert</b>!(value_ref.bits == expected_bits, 0);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_benchmark_insert"></a>

## Function `insert`

Insert given key-value pair, assert expected access key.


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_insert">insert</a>(<a href="">account</a>: &<a href="">signer</a>, key: u64, bits: u128, access_key_expected: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_insert">insert</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    key: u64,
    bits: u128,
    access_key_expected: u64
) <b>acquires</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> {
    <b>let</b> addr = address_of(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>.
    // Mutably borrow AVL queue store map.
    <b>let</b> avlq_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(addr).map;
    <b>let</b> reset_count = // Get reset count.
        <a href="_length">table_with_length::length</a>(avlq_store_map_ref_mut);
    <b>let</b> avlq_ref_mut = // Mutably borrow corresponding AVL queue.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(avlq_store_map_ref_mut, reset_count);
    <b>let</b> access_key = <a href="avl_queue.md#0xc0deb00c_avl_queue_insert">avl_queue::insert</a>(avlq_ref_mut, key, <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">Value</a>{
        addr, bits}); // Insert key-value pair, storing access key.
    // Assert access key is <b>as</b> expected.
    <b>assert</b>!(access_key == access_key_expected, 0);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_benchmark_insert_evict_tail"></a>

## Function `insert_evict_tail`

Insert given key-value pair, assert expected access key, evictee
access key, and evictee value bits.


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_insert_evict_tail">insert_evict_tail</a>(<a href="">account</a>: &<a href="">signer</a>, key: u64, bits: u128, access_key_expected: u64, evictee_access_key_expected: u64, evictee_value_bits_expected: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_insert_evict_tail">insert_evict_tail</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    key: u64,
    bits: u128,
    access_key_expected: u64,
    evictee_access_key_expected: u64,
    evictee_value_bits_expected: u128
) <b>acquires</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> {
    <b>let</b> addr = address_of(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>.
    // Mutably borrow AVL queue store map.
    <b>let</b> avlq_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(addr).map;
    <b>let</b> reset_count = // Get reset count.
        <a href="_length">table_with_length::length</a>(avlq_store_map_ref_mut);
    <b>let</b> avlq_ref_mut = // Mutably borrow corresponding AVL queue.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(avlq_store_map_ref_mut, reset_count);
    <b>let</b> value = <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">Value</a>{addr, bits}; // Declare insertion value.
    // Insert key-value pair and evict tail, storing returns.
    <b>let</b> (access_key, evictee_access_key, <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">Value</a>{addr: _, bits}) =
        <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_evict_tail">avl_queue::insert_evict_tail</a>(avlq_ref_mut, key, value);
    // Assert returns
    <b>assert</b>!(access_key == access_key_expected, 0);
    <b>assert</b>!(evictee_access_key == evictee_access_key_expected, 0);
    <b>assert</b>!(bits == evictee_value_bits_expected, 0);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_benchmark_remove"></a>

## Function `remove`

Remove given key-value pair, assert expected value bits.


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_remove">remove</a>(<a href="">account</a>: &<a href="">signer</a>, access_key: u64, bits_expected: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_remove">remove</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    access_key: u64,
    bits_expected: u128
) <b>acquires</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> {
    <b>let</b> addr = address_of(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>.
    // Mutably borrow AVL queue store map.
    <b>let</b> avlq_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(addr).map;
    <b>let</b> reset_count = // Get reset count.
        <a href="_length">table_with_length::length</a>(avlq_store_map_ref_mut);
    <b>let</b> avlq_ref_mut = // Mutably borrow corresponding AVL queue.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(avlq_store_map_ref_mut, reset_count);
    // Remove key-value pair, storing value bits.
    <b>let</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">Value</a>{addr: _, bits} = <a href="avl_queue.md#0xc0deb00c_avl_queue_remove">avl_queue::remove</a>(avlq_ref_mut, access_key);
    // Assert value bits <b>as</b> expected.
    <b>assert</b>!(bits == bits_expected, 0);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_benchmark_clear"></a>

## Function `clear`

Clear AVL queue out.


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_clear">clear</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_clear">clear</a>(
    <a href="">account</a>: &<a href="">signer</a>
) <b>acquires</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> {
    <b>let</b> addr = address_of(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>.
    // Mutably borrow AVL queue store map.
    <b>let</b> avlq_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(addr).map;
    <b>let</b> reset_count = // Get reset count.
        <a href="_length">table_with_length::length</a>(avlq_store_map_ref_mut);
    <b>let</b> avlq_ref_mut = // Mutably borrow corresponding AVL queue.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(avlq_store_map_ref_mut, reset_count);
    // While AVL queue is not empty:
    <b>while</b> (!<a href="avl_queue.md#0xc0deb00c_avl_queue_is_empty">avl_queue::is_empty</a>(avlq_ref_mut)) {
        // Pop head, unpack and discard value.
        <b>let</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_Value">Value</a>{addr: _, bits: _} = <a href="avl_queue.md#0xc0deb00c_avl_queue_pop_head">avl_queue::pop_head</a>(avlq_ref_mut);
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_benchmark_reset"></a>

## Function `reset`

Reset with a new AVL queue.


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_reset">reset</a>(<a href="">account</a>: &<a href="">signer</a>, n_inactive_tree_nodes: u64, n_inactive_list_nodes: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_reset">reset</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    n_inactive_tree_nodes: u64,
    n_inactive_list_nodes: u64
) <b>acquires</b> <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a> {
    <b>let</b> addr = address_of(<a href="">account</a>); // Get <a href="">account</a> <b>address</b>.
    // Mutably borrow AVL queue store map.
    <b>let</b> avlq_store_map_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_AVLqueueStore">AVLqueueStore</a>&gt;(addr).map;
    <b>let</b> reset_count = // Get reset count.
        <a href="_length">table_with_length::length</a>(avlq_store_map_ref_mut);
    <a href="_add">table_with_length::add</a>( // Add new AVL queue <b>to</b> store map.
        avlq_store_map_ref_mut, reset_count + 1, <a href="avl_queue.md#0xc0deb00c_avl_queue_new">avl_queue::new</a>(
            <a href="avl_queue_benchmark.md#0xc0deb00c_avl_queue_benchmark_ASCENDING">ASCENDING</a>, n_inactive_tree_nodes, n_inactive_list_nodes));
}
</code></pre>



</details>
