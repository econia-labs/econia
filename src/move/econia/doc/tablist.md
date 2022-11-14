
<a name="0xc0deb00c_tablist"></a>

# Module `0xc0deb00c::tablist`

Tablist: a hybrid between a table and a doubly linked list.

Modeled off of what was previously <code>aptos_std::iterable_table.<b>move</b></code>,
which had been removed from <code>aptos_std</code> as of the time of this
writing.

Accepts key-value pairs having key type <code>K</code> and value type <code>V</code>.

See <code>test_iterate()</code> and <code>test_iterate_remove()</code> for iteration
syntax.


<a name="@Complete_docgen_index_0"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [Complete docgen index](#@Complete_docgen_index_0)
-  [Struct `Node`](#0xc0deb00c_tablist_Node)
-  [Struct `Tablist`](#0xc0deb00c_tablist_Tablist)
-  [Constants](#@Constants_1)
-  [Function `add`](#0xc0deb00c_tablist_add)
    -  [Testing](#@Testing_2)
-  [Function `borrow`](#0xc0deb00c_tablist_borrow)
    -  [Testing](#@Testing_3)
-  [Function `borrow_iterable`](#0xc0deb00c_tablist_borrow_iterable)
    -  [Testing](#@Testing_4)
-  [Function `borrow_iterable_mut`](#0xc0deb00c_tablist_borrow_iterable_mut)
    -  [Testing](#@Testing_5)
-  [Function `borrow_mut`](#0xc0deb00c_tablist_borrow_mut)
    -  [Testing](#@Testing_6)
-  [Function `contains`](#0xc0deb00c_tablist_contains)
    -  [Testing](#@Testing_7)
-  [Function `destroy_empty`](#0xc0deb00c_tablist_destroy_empty)
    -  [Aborts](#@Aborts_8)
    -  [Testing](#@Testing_9)
-  [Function `get_head_key`](#0xc0deb00c_tablist_get_head_key)
    -  [Testing](#@Testing_10)
-  [Function `get_tail_key`](#0xc0deb00c_tablist_get_tail_key)
    -  [Testing](#@Testing_11)
-  [Function `length`](#0xc0deb00c_tablist_length)
    -  [Testing](#@Testing_12)
-  [Function `new`](#0xc0deb00c_tablist_new)
    -  [Testing](#@Testing_13)
-  [Function `is_empty`](#0xc0deb00c_tablist_is_empty)
    -  [Testing](#@Testing_14)
-  [Function `remove`](#0xc0deb00c_tablist_remove)
    -  [Testing](#@Testing_15)
-  [Function `remove_iterable`](#0xc0deb00c_tablist_remove_iterable)
    -  [Testing](#@Testing_16)
-  [Function `singleton`](#0xc0deb00c_tablist_singleton)
    -  [Testing](#@Testing_17)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
</code></pre>



<a name="0xc0deb00c_tablist_Node"></a>

## Struct `Node`

A tablist node, pointing to the previous and next nodes, if any.


<pre><code><b>struct</b> <a href="tablist.md#0xc0deb00c_tablist_Node">Node</a>&lt;K: <b>copy</b>, drop, store, V: store&gt; <b>has</b> store
</code></pre>



<a name="0xc0deb00c_tablist_Tablist"></a>

## Struct `Tablist`

A hybrid between a table and a doubly linked list.


<pre><code><b>struct</b> <a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a>&lt;K: <b>copy</b>, drop, store, V: store&gt; <b>has</b> store
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="0xc0deb00c_tablist_E_DESTROY_NOT_EMPTY"></a>

Attempting to destroy a tablist that is not empty.


<pre><code><b>const</b> <a href="tablist.md#0xc0deb00c_tablist_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_tablist_add"></a>

## Function `add`

Add <code>key</code>-<code>value</code> pair to given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, aborting if <code>key</code>
already present.


<a name="@Testing_2"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_add">add</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K, value: V)
</code></pre>



<a name="0xc0deb00c_tablist_borrow"></a>

## Function `borrow`

Return immutable reference to the value that <code>key</code> maps to,
aborting if <code>key</code> is not in given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>.


<a name="@Testing_3"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_borrow">borrow</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): &V
</code></pre>



<a name="0xc0deb00c_tablist_borrow_iterable"></a>

## Function `borrow_iterable`

Borrow the <code><a href="tablist.md#0xc0deb00c_tablist_Node">Node</a></code> in the given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code> having key, returning:

* Immutable reference to corresponding value.
* Key of previous <code><a href="tablist.md#0xc0deb00c_tablist_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, if any.
* Key of next <code><a href="tablist.md#0xc0deb00c_tablist_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, if any.

Aborts if there is no entry for <code>key</code>.


<a name="@Testing_4"></a>

### Testing


* <code>test_iterate()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_borrow_iterable">borrow_iterable</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): (&V, <a href="_Option">option::Option</a>&lt;K&gt;, <a href="_Option">option::Option</a>&lt;K&gt;)
</code></pre>



<a name="0xc0deb00c_tablist_borrow_iterable_mut"></a>

## Function `borrow_iterable_mut`

Mutably borrow the <code><a href="tablist.md#0xc0deb00c_tablist_Node">Node</a></code> in given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code> having <code>key</code>,
returning:

* Mutable reference to corresponding value.
* Key of previous <code><a href="tablist.md#0xc0deb00c_tablist_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, if any.
* Key of next <code><a href="tablist.md#0xc0deb00c_tablist_Node">Node</a></code> in the <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, if any.

Aborts if there is no entry for <code>key</code>.


<a name="@Testing_5"></a>

### Testing


* <code>test_iterate()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_borrow_iterable_mut">borrow_iterable_mut</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): (&<b>mut</b> V, <a href="_Option">option::Option</a>&lt;K&gt;, <a href="_Option">option::Option</a>&lt;K&gt;)
</code></pre>



<a name="0xc0deb00c_tablist_borrow_mut"></a>

## Function `borrow_mut`

Return mutable reference to the value that <code>key</code> maps to,
aborting if <code>key</code> is not in given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>.

Aborts if there is no entry for <code>key</code>.


<a name="@Testing_6"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_borrow_mut">borrow_mut</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): &<b>mut</b> V
</code></pre>



<a name="0xc0deb00c_tablist_contains"></a>

## Function `contains`

Return <code><b>true</b></code> if given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code> contains <code>key</code>, else <code><b>false</b></code>.


<a name="@Testing_7"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_contains">contains</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): bool
</code></pre>



<a name="0xc0deb00c_tablist_destroy_empty"></a>

## Function `destroy_empty`

Destroy an empty <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, aborting if not empty.


<a name="@Aborts_8"></a>

### Aborts


* <code><a href="tablist.md#0xc0deb00c_tablist_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a></code>: The tablist is not empty.


<a name="@Testing_9"></a>

### Testing


* <code>test_destroy_empty_not_empty()</code>
* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_destroy_empty">destroy_empty</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(<a href="tablist.md#0xc0deb00c_tablist">tablist</a>: <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;)
</code></pre>



<a name="0xc0deb00c_tablist_get_head_key"></a>

## Function `get_head_key`

Return optional head key from given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>.


<a name="@Testing_10"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_get_head_key">get_head_key</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;): <a href="_Option">option::Option</a>&lt;K&gt;
</code></pre>



<a name="0xc0deb00c_tablist_get_tail_key"></a>

## Function `get_tail_key`

Return optional tail key in given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>.


<a name="@Testing_11"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_get_tail_key">get_tail_key</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;): <a href="_Option">option::Option</a>&lt;K&gt;
</code></pre>



<a name="0xc0deb00c_tablist_length"></a>

## Function `length`

Return number of elements in given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>.


<a name="@Testing_12"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_length">length</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;): u64
</code></pre>



<a name="0xc0deb00c_tablist_new"></a>

## Function `new`

Return an empty <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>.


<a name="@Testing_13"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_new">new</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(): <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;
</code></pre>



<a name="0xc0deb00c_tablist_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code> is empty, else <code><b>false</b></code>.


<a name="@Testing_14"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_is_empty">is_empty</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref: &<a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;): bool
</code></pre>



<a name="0xc0deb00c_tablist_remove"></a>

## Function `remove`

Remove <code>key</code> from given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, returning the value <code>key</code>
mapped to.

See wrapped function <code><a href="tablist.md#0xc0deb00c_tablist_remove_iterable">remove_iterable</a>()</code>.

Aborts if there is no entry for <code>key</code>.


<a name="@Testing_15"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_remove">remove</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): V
</code></pre>



<a name="0xc0deb00c_tablist_remove_iterable"></a>

## Function `remove_iterable`

Remove <code>key</code> from given <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code>, returning the value <code>key</code>
mapped to, the previous key it mapped to (if any), and the
next key it mapped to (if any).

Aborts if there is no entry for <code>key</code>.


<a name="@Testing_16"></a>

### Testing


* <code>test_iterate_remove()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_remove_iterable">remove_iterable</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(tablist_ref_mut: &<b>mut</b> <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;, key: K): (V, <a href="_Option">option::Option</a>&lt;K&gt;, <a href="_Option">option::Option</a>&lt;K&gt;)
</code></pre>



<a name="0xc0deb00c_tablist_singleton"></a>

## Function `singleton`

Return a new <code><a href="tablist.md#0xc0deb00c_tablist_Tablist">Tablist</a></code> containing <code>key</code>-<code>value</code> pair.


<a name="@Testing_17"></a>

### Testing


* <code>test_mixed()</code>


<pre><code><b>public</b> <b>fun</b> <a href="tablist.md#0xc0deb00c_tablist_singleton">singleton</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(key: K, value: V): <a href="tablist.md#0xc0deb00c_tablist_Tablist">tablist::Tablist</a>&lt;K, V&gt;
</code></pre>
