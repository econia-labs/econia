
<a name="0xc0deb00c_critqueue_benchmark"></a>

# Module `0xc0deb00c::critqueue_benchmark`

Wrappers for on-chain <code>CritQueue</code> benchmarking.


-  [Resource `CritQueueStore`](#0xc0deb00c_critqueue_benchmark_CritQueueStore)
-  [Constants](#@Constants_0)
-  [Function `init_module`](#0xc0deb00c_critqueue_benchmark_init_module)
-  [Function `insert`](#0xc0deb00c_critqueue_benchmark_insert)
-  [Function `remove`](#0xc0deb00c_critqueue_benchmark_remove)
-  [Function `dequeue`](#0xc0deb00c_critqueue_benchmark_dequeue)
-  [Function `empty`](#0xc0deb00c_critqueue_benchmark_empty)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="critqueue.md#0xc0deb00c_critqueue">0xc0deb00c::critqueue</a>;
</code></pre>



<a name="0xc0deb00c_critqueue_benchmark_CritQueueStore"></a>

## Resource `CritQueueStore`

Stores a <code>CritQueue</code>.


<pre><code><b>struct</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>: <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;u64&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_critqueue_benchmark_E_NOT_ECONIA"></a>

When not called by Econia.


<pre><code><b>const</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_critqueue_benchmark_ASCENDING"></a>

Ascending crit-queue flag.


<pre><code><b>const</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_ASCENDING">ASCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_benchmark_E_UNEXPECTED_VALUE"></a>

When value is not as expected.


<pre><code><b>const</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_UNEXPECTED_VALUE">E_UNEXPECTED_VALUE</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_critqueue_benchmark_init_module"></a>

## Function `init_module`

Initialize a <code><a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a></code> under <code>econia</code> account.


<pre><code><b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_init_module">init_module</a>(econia: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_init_module">init_module</a>(
    econia: &<a href="">signer</a>
) {
    // Get crit-queue.
    <b>let</b> <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a> = <a href="critqueue.md#0xc0deb00c_critqueue_new">critqueue::new</a>(<a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_ASCENDING">ASCENDING</a>);
    // Get crit-queue store.
    <b>let</b> critqueue_store = <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a>{<a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>};
    // Move crit-queue store <b>to</b> Econia <a href="">account</a>.
    <b>move_to</b>&lt;<a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a>&gt;(econia, critqueue_store);
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_benchmark_insert"></a>

## Function `insert`

Insert a key-value insertion pair.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_insert">insert</a>(<a href="">account</a>: &<a href="">signer</a>, insertion_key: u64, insertion_value: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_insert">insert</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    insertion_key: u64,
    insertion_value: u64
) <b>acquires</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow crit-queue.
    <b>let</b> critqueue_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a>&gt;(@econia).<a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>;
    // Insert key-value insertion pair.
    <a href="critqueue.md#0xc0deb00c_critqueue_insert">critqueue::insert</a>(critqueue_ref_mut, insertion_key, insertion_value);
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_benchmark_remove"></a>

## Function `remove`

Remove insertion value corresponding to <code>access_key</code>,
asserting it is equal to <code>insertion_value_expected</code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_remove">remove</a>(<a href="">account</a>: &<a href="">signer</a>, access_key: u128, insertion_value_expected: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_remove">remove</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    access_key: u128,
    insertion_value_expected: u64
) <b>acquires</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow crit-queue.
    <b>let</b> critqueue_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a>&gt;(@econia).<a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>;
    <b>assert</b>!( // Assert removed insertion value is <b>as</b> expected.
        <a href="critqueue.md#0xc0deb00c_critqueue_remove">critqueue::remove</a>(critqueue_ref_mut, access_key) ==
        insertion_value_expected, <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_UNEXPECTED_VALUE">E_UNEXPECTED_VALUE</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_benchmark_dequeue"></a>

## Function `dequeue`

Dequeue insertion value at crit-queue head, asserting it is
equal to <code>insertion_value_expected</code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_dequeue">dequeue</a>(<a href="">account</a>: &<a href="">signer</a>, insertion_value_expected: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_dequeue">dequeue</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    insertion_value_expected: u64
) <b>acquires</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow crit-queue.
    <b>let</b> critqueue_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a>&gt;(@econia).<a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>;
    <b>assert</b>!( // Assert dequeued insertion value is <b>as</b> expected.
        <a href="critqueue.md#0xc0deb00c_critqueue_dequeue">critqueue::dequeue</a>(critqueue_ref_mut) ==
        insertion_value_expected, <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_UNEXPECTED_VALUE">E_UNEXPECTED_VALUE</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_benchmark_empty"></a>

## Function `empty`

Dequeue all values in given crit-queue.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_empty">empty</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_empty">empty</a>(
    <a href="">account</a>: &<a href="">signer</a>,
) <b>acquires</b> <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a> {
    // Assert caller is Econia.
    <b>assert</b>!(address_of(<a href="">account</a>) == @econia, <a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_E_NOT_ECONIA">E_NOT_ECONIA</a>);
    // Mutably borrow crit-queue.
    <b>let</b> critqueue_ref_mut =
        &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="critqueue_benchmark.md#0xc0deb00c_critqueue_benchmark_CritQueueStore">CritQueueStore</a>&gt;(@econia).<a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>;
    // While crit-queue is not empty:
    <b>while</b> (!<a href="critqueue.md#0xc0deb00c_critqueue_is_empty">critqueue::is_empty</a>(critqueue_ref_mut)) {
        // De-queue the head.
        <a href="critqueue.md#0xc0deb00c_critqueue_dequeue">critqueue::dequeue</a>(critqueue_ref_mut);
    };
}
</code></pre>



</details>
