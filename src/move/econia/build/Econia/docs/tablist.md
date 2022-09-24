
<a name="0xc0deb00c_table_list"></a>

# Module `0xc0deb00c::table_list`

A hybrid between a table and a doubly linked list.

Modeled off of what was previously <code>aptos_std::iterable_table.<b>move</b></code>,
which had been removed from <code>aptos_std</code> as of the time of this
writing.

Accepts key-value pairs having key type <code>K</code> and value type <code>V</code>.

See <code>test_iterate()</code> and <code>test_iterate_remove()</code> for iteration
syntax.

---


-  [Struct `Node`](#0xc0deb00c_table_list_Node)
-  [Struct `TableList`](#0xc0deb00c_table_list_TableList)
-  [Constants](#@Constants_0)
-  [Function `add`](#0xc0deb00c_table_list_add)
-  [Function `borrow`](#0xc0deb00c_table_list_borrow)
-  [Function `borrow_iterable`](#0xc0deb00c_table_list_borrow_iterable)
-  [Function `borrow_iterable_mut`](#0xc0deb00c_table_list_borrow_iterable_mut)
-  [Function `borrow_mut`](#0xc0deb00c_table_list_borrow_mut)
-  [Function `contains`](#0xc0deb00c_table_list_contains)
-  [Function `destroy_empty`](#0xc0deb00c_table_list_destroy_empty)
-  [Function `get_head_key`](#0xc0deb00c_table_list_get_head_key)
-  [Function `get_tail_key`](#0xc0deb00c_table_list_get_tail_key)
-  [Function `length`](#0xc0deb00c_table_list_length)
-  [Function `new`](#0xc0deb00c_table_list_new)
-  [Function `is_empty`](#0xc0deb00c_table_list_is_empty)
-  [Function `remove`](#0xc0deb00c_table_list_remove)
-  [Function `remove_iterable`](#0xc0deb00c_table_list_remove_iterable)
-  [Function `singleton`](#0xc0deb00c_table_list_singleton)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
</code></pre>



<a name="0xc0deb00c_table_list_Node"></a>

## Struct `Node`

A node in the doubly linked list, pointing to the previous and
next keys, if there are any.


<pre><code><b>struct</b> <a href="tablist.md#0xc0deb00c_table_list_Node">Node</a>&lt;K: <b>copy</b>, drop, store, V: store&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: V</code>
</dt>
<dd>
 Value in a key-value pair.
</dd>
<dt>
<code>previous: <a href="_Option">option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 Previous key in linked list, if any.
</dd>
<dt>
<code>next: <a href="_Option">option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 Next key in linked list, if any.
</dd>
</dl>


</details>

<a name="0xc0deb00c_table_list_TableList"></a>

## Struct `TableList`

A doubly linked list based on a hash table.


<pre><code><b>struct</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K: <b>copy</b>, drop, store, V: store&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>inner_table: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;K, <a href="tablist.md#0xc0deb00c_table_list_Node">table_list::Node</a>&lt;K, V&gt;&gt;</code>
</dt>
<dd>
 All <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code>s in the list.
</dd>
<dt>
<code>head: <a href="_Option">option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 Key of first <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the list, if any.
</dd>
<dt>
<code>tail: <a href="_Option">option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 Key of final <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the list, if any.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc0deb00c_table_list_E_DESTROY_NOT_EMPTY"></a>

When attempting to destroy a table that is not empty.


<pre><code><b>const</b> <a href="tablist.md#0xc0deb00c_table_list_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_table_list_add"></a>

## Function `add`

Add <code>key</code>-<code>value</code> pair to <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> indicated by
<code>table_list_ref_mut</code>, aborting if <code>key</code> already present.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_add">add</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_add">add</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K,
    value: V
) {
    <b>let</b> node = <a href="tablist.md#0xc0deb00c_table_list_Node">Node</a>{value, previous: table_list_ref_mut.tail,
        next: <a href="_none">option::none</a>()}; // Wrap value in a node.
    // Add node <b>to</b> the inner <a href="">table</a>.
    <a href="_add">table_with_length::add</a>(&<b>mut</b> table_list_ref_mut.inner_table, key, node);
    // If adding the first node in the <a href="">table</a>:
    <b>if</b> (<a href="_is_none">option::is_none</a>(&table_list_ref_mut.head)) {
        // Mark key <b>as</b> the new head.
        table_list_ref_mut.head = <a href="_some">option::some</a>(key);
    } <b>else</b> { // If adding node that is not first in the <a href="">table</a>:
        // Get the <b>old</b> tail node key.
        <b>let</b> old_tail = <a href="_borrow">option::borrow</a>(&table_list_ref_mut.tail);
        // Update the <b>old</b> tail node <b>to</b> have the new key <b>as</b> next.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            &<b>mut</b> table_list_ref_mut.inner_table, *old_tail).next =
                <a href="_some">option::some</a>(key);
    };
    // Update the <a href="">table</a> tail <b>to</b> the new key.
    table_list_ref_mut.tail = <a href="_some">option::some</a>(key);
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_borrow"></a>

## Function `borrow`

Return immutable reference to the value that <code>key</code> maps to,
aborting if <code>key</code> is not in <code>table_list_ref_mut</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow">borrow</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow">borrow</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K,
): &V {
    &<a href="_borrow">table_with_length::borrow</a>(&table_list_ref.inner_table, key).value
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_borrow_iterable"></a>

## Function `borrow_iterable`

Borrow the <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code> having
<code>key</code>, then return:
* Immutable reference to corresponding value.
* Optional key of previous <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code>, if any.
* Optional key of next <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code>, if any.

Aborts if there is no entry for <code>key</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow_iterable">borrow_iterable</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): (&V, <a href="_Option">option::Option</a>&lt;K&gt;, <a href="_Option">option::Option</a>&lt;K&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow_iterable">borrow_iterable</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K,
): (
    &V,
    Option&lt;K&gt;,
    Option&lt;K&gt;
) {
    <b>let</b> node_ref = // Borrow immutable reference <b>to</b> node having key.
        <a href="_borrow">table_with_length::borrow</a>(&table_list_ref.inner_table, key);
    // Return corresponding fields.
    (&node_ref.value, node_ref.previous, node_ref.next)
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_borrow_iterable_mut"></a>

## Function `borrow_iterable_mut`

Mutably borrow the <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code>
having <code>key</code>, then return:
* Mutable reference to corresponding value.
* Optional key of previous <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code>, if any.
* Optional key of next <code><a href="tablist.md#0xc0deb00c_table_list_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code>, if any.

Aborts if there is no entry for <code>key</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow_iterable_mut">borrow_iterable_mut</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): (&<b>mut</b> V, <a href="_Option">option::Option</a>&lt;K&gt;, <a href="_Option">option::Option</a>&lt;K&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow_iterable_mut">borrow_iterable_mut</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K,
): (
    &<b>mut</b> V,
    Option&lt;K&gt;,
    Option&lt;K&gt;
) {
    // Borrow mutable reference <b>to</b> node having key.
    <b>let</b> node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
        &<b>mut</b> table_list_ref_mut.inner_table, key);
    // Return corresponding fields.
    (&<b>mut</b> node_ref_mut.value, node_ref_mut.previous, node_ref_mut.next)
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_borrow_mut"></a>

## Function `borrow_mut`

Return mutable reference to the value that <code>key</code> maps to,
aborting if <code>key</code> is not in <code>table_list_ref_mut</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow_mut">borrow_mut</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): &<b>mut</b> V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_borrow_mut">borrow_mut</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K,
): &<b>mut</b> V {
    &<b>mut</b> table_with_length::
        borrow_mut(&<b>mut</b> table_list_ref_mut.inner_table, key).value
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_contains"></a>

## Function `contains`

Return <code><b>true</b></code> if <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code> contains <code>key</code>,
else <code><b>false</b></code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_contains">contains</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_contains">contains</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K,
): bool {
    <a href="_contains">table_with_length::contains</a>(&table_list_ref.inner_table, key)
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_destroy_empty"></a>

## Function `destroy_empty`

Destroy an empty <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code>, aborting if not empty.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_destroy_empty">destroy_empty</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(<a href="tablist.md#0xc0deb00c_table_list">table_list</a>: <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_destroy_empty">destroy_empty</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    <a href="tablist.md#0xc0deb00c_table_list">table_list</a>: <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;
) {
    // Assert <a href="">table</a> list is empty before attempting <b>to</b> unpack.
    <b>assert</b>!(<a href="tablist.md#0xc0deb00c_table_list_is_empty">is_empty</a>(&<a href="tablist.md#0xc0deb00c_table_list">table_list</a>), <a href="tablist.md#0xc0deb00c_table_list_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>);
    // Unpack, destroying head and tail fields.
    <b>let</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>{inner_table, head: _, tail: _} = <a href="tablist.md#0xc0deb00c_table_list">table_list</a>;
    // Destroy empty inner <a href="">table</a>.
    <a href="_destroy_empty">table_with_length::destroy_empty</a>(inner_table);
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_get_head_key"></a>

## Function `get_head_key`

Return optional head key from <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_get_head_key">get_head_key</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;): <a href="_Option">option::Option</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_get_head_key">get_head_key</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;
): Option&lt;K&gt; {
    table_list_ref.head
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_get_tail_key"></a>

## Function `get_tail_key`

Return optional tail key from <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_get_tail_key">get_tail_key</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;): <a href="_Option">option::Option</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_get_tail_key">get_tail_key</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;
): Option&lt;K&gt; {
    table_list_ref.tail
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_length"></a>

## Function `length`

Return number of elements in <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_length">length</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_length">length</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;
): u64 {
    <a href="_length">table_with_length::length</a>(&table_list_ref.inner_table)
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_new"></a>

## Function `new`

Return an empty <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_new">new</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(): <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_new">new</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(): <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt; {
    <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>{
        inner_table: <a href="_new">table_with_length::new</a>(),
        head: <a href="_none">option::none</a>(),
        tail: <a href="_none">option::none</a>()
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref</code> is empty, else
<code><b>false</b></code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_is_empty">is_empty</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_is_empty">is_empty</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref: &<a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;
): bool {
    <a href="_empty">table_with_length::empty</a>(&table_list_ref.inner_table)
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_remove"></a>

## Function `remove`

Remove <code>key</code> from <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref_mut</code>, returning
the value <code>key</code> mapped to.

See wrapped function <code><a href="tablist.md#0xc0deb00c_table_list_remove_iterable">remove_iterable</a>()</code>.

Aborts if there is no entry for <code>key</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_remove">remove</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_remove">remove</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K
): V {
    // Get value iterable removal.
    <b>let</b> (value, _, _) = <a href="tablist.md#0xc0deb00c_table_list_remove_iterable">remove_iterable</a>(table_list_ref_mut, key);
    value // Return value.
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_remove_iterable"></a>

## Function `remove_iterable`

Remove <code>key</code> from <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> at <code>table_list_ref_mut</code>, returning
the value <code>key</code> mapped to, the previous key it mapped to (if
any), and the next key it mapped to (if any).

Aborts if there is no entry for <code>key</code>.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_remove_iterable">remove_iterable</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;, key: K): (V, <a href="_Option">option::Option</a>&lt;K&gt;, <a href="_Option">option::Option</a>&lt;K&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_remove_iterable">remove_iterable</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    table_list_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt;,
    key: K
): (
    V,
    Option&lt;K&gt;,
    Option&lt;K&gt;
) {
    // Unpack from inner <a href="">table</a> the node <b>with</b> the given key.
    <b>let</b> <a href="tablist.md#0xc0deb00c_table_list_Node">Node</a>{value, previous, next} = <a href="_remove">table_with_length::remove</a>(
        &<b>mut</b> table_list_ref_mut.inner_table, key);
    // If the node was the head of the list:
    <b>if</b> (<a href="_is_none">option::is_none</a>(&previous)) { // If no previous node:
        // Set <b>as</b> the list head the node's next field.
        table_list_ref_mut.head = next;
    } <b>else</b> { // If node was not head of list:
        // Update the node having the previous key <b>to</b> have <b>as</b> its
        // next field the next field of the removed node.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(&<b>mut</b> table_list_ref_mut.inner_table,
            *<a href="_borrow">option::borrow</a>(&previous)).next = next;
    };
    // If the node was the tail of the list:
    <b>if</b> (<a href="_is_none">option::is_none</a>(&next)) { // If no next node:
        // Set <b>as</b> the list tail the node's previous field.
        table_list_ref_mut.tail = previous;
    } <b>else</b> { // If node was not tail of list:
        // Update the node having the next key <b>to</b> have <b>as</b> its
        // previous field the previous field of the removed node.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(&<b>mut</b> table_list_ref_mut.inner_table,
            *<a href="_borrow">option::borrow</a>(&next)).previous = previous;
    };
    // Return node value, previous field, and next field.
    (value, previous, next)
}
</code></pre>



</details>

<a name="0xc0deb00c_table_list_singleton"></a>

## Function `singleton`

Return a new <code><a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a></code> containing given <code>key</code>-<code>value</code> pair.


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_singleton">singleton</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(key: K, value: V): <a href="tablist.md#0xc0deb00c_table_list_TableList">table_list::TableList</a>&lt;K, V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_table_list_singleton">singleton</a>&lt;
    K: <b>copy</b> + drop + store,
    V: store
&gt;(
    key: K,
    value: V
): <a href="tablist.md#0xc0deb00c_table_list_TableList">TableList</a>&lt;K, V&gt; {
    <b>let</b> <a href="tablist.md#0xc0deb00c_table_list">table_list</a> = <a href="tablist.md#0xc0deb00c_table_list_new">new</a>&lt;K, V&gt;(); // Declare empty <a href="">table</a> list.
    <a href="tablist.md#0xc0deb00c_table_list_add">add</a>(&<b>mut</b> <a href="tablist.md#0xc0deb00c_table_list">table_list</a>, key, value); // Insert key-value pair.
    <a href="tablist.md#0xc0deb00c_table_list">table_list</a> // Return <a href="">table</a> list.
}
</code></pre>



</details>
