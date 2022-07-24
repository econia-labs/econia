
<a name="0xc0deb00c_open_table"></a>

# Module `0xc0deb00c::open_table`

Extends the <code>aptos_framework::table</code> with a <code><a href="">vector</a></code> of contained
keys, enabling simple SDK indexing. Does not implement wrappers for
all functions.


-  [Struct `OpenTable`](#0xc0deb00c_open_table_OpenTable)
-  [Function `empty`](#0xc0deb00c_open_table_empty)
-  [Function `add`](#0xc0deb00c_open_table_add)
-  [Function `borrow`](#0xc0deb00c_open_table_borrow)


<pre><code><b>use</b> <a href="">0x1::table</a>;
</code></pre>



<a name="0xc0deb00c_open_table_OpenTable"></a>

## Struct `OpenTable`

Extended version of <code>aptos_framework::table</code> with vector of
contained keys


<pre><code><b>struct</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">OpenTable</a>&lt;K: <b>copy</b>, drop, V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_table: <a href="_Table">table::Table</a>&lt;K, V&gt;</code>
</dt>
<dd>
 Standard table type
</dd>
<dt>
<code>keys: <a href="">vector</a>&lt;K&gt;</code>
</dt>
<dd>
 Vector of keys contained in table
</dd>
</dl>


</details>

<a name="0xc0deb00c_open_table_empty"></a>

## Function `empty`

Return an empty <code><a href="open_table.md#0xc0deb00c_open_table_OpenTable">OpenTable</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="open_table.md#0xc0deb00c_open_table_empty">empty</a>&lt;K: <b>copy</b>, drop, V: store&gt;(): <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;K, V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="open_table.md#0xc0deb00c_open_table_empty">empty</a>&lt;K: <b>copy</b> + drop, V: store&gt;():
<a href="open_table.md#0xc0deb00c_open_table_OpenTable">OpenTable</a>&lt;K, V&gt; {
    <a href="open_table.md#0xc0deb00c_open_table_OpenTable">OpenTable</a>{base_table: <a href="_new">table::new</a>(), keys: <a href="_empty">vector::empty</a>()}
}
</code></pre>



</details>

<a name="0xc0deb00c_open_table_add"></a>

## Function `add`

Add <code>key</code> and <code>value</code> to <code><a href="open_table.md#0xc0deb00c_open_table">open_table</a></code>, aborting if <code>key</code> already
in <code><a href="open_table.md#0xc0deb00c_open_table">open_table</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="open_table.md#0xc0deb00c_open_table_add">add</a>&lt;K: <b>copy</b>, drop, V&gt;(<a href="open_table.md#0xc0deb00c_open_table">open_table</a>: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;K, V&gt;, key: K, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="open_table.md#0xc0deb00c_open_table_add">add</a>&lt;K: <b>copy</b> + drop, V&gt;(
    <a href="open_table.md#0xc0deb00c_open_table">open_table</a>: &<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table_OpenTable">OpenTable</a>&lt;K, V&gt;,
    key: K,
    value: V
) {
    // Add key-value pair <b>to</b> base <a href="">table</a> (aborts <b>if</b> already inside)
    <a href="_add">table::add</a>(&<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table">open_table</a>.base_table, key, value);
    // Add key <b>to</b> the list of keys
    <a href="_push_back">vector::push_back</a>(&<b>mut</b> <a href="open_table.md#0xc0deb00c_open_table">open_table</a>.keys, key);
}
</code></pre>



</details>

<a name="0xc0deb00c_open_table_borrow"></a>

## Function `borrow`

Return immutable reference to the value which <code>key</code> maps to,
aborting if no entry in <code><a href="open_table.md#0xc0deb00c_open_table">open_table</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="open_table.md#0xc0deb00c_open_table_borrow">borrow</a>&lt;K: <b>copy</b>, drop, V&gt;(<a href="open_table.md#0xc0deb00c_open_table">open_table</a>: &<a href="open_table.md#0xc0deb00c_open_table_OpenTable">open_table::OpenTable</a>&lt;K, V&gt;, key: K): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="open_table.md#0xc0deb00c_open_table_borrow">borrow</a>&lt;K: <b>copy</b> + drop, V&gt;(
    <a href="open_table.md#0xc0deb00c_open_table">open_table</a>: &<a href="open_table.md#0xc0deb00c_open_table_OpenTable">OpenTable</a>&lt;K, V&gt;,
    key: K
): &V {
    // Borrow corresponding reference (aborts <b>if</b> no such entry)
    <a href="_borrow">table::borrow</a>(&<a href="open_table.md#0xc0deb00c_open_table">open_table</a>.base_table, key)
}
</code></pre>



</details>
