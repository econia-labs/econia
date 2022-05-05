
<a name="0x1d157846c6d7ac69cbbc60590c325683_BST"></a>

# Module `0x1d157846c6d7ac69cbbc60590c325683::BST`

Red-black binary search tree


-  [Struct `Keys`](#0x1d157846c6d7ac69cbbc60590c325683_BST_Keys)
-  [Struct `Node`](#0x1d157846c6d7ac69cbbc60590c325683_BST_Node)
-  [Struct `MockValueType`](#0x1d157846c6d7ac69cbbc60590c325683_BST_MockValueType)
-  [Struct `MockBST`](#0x1d157846c6d7ac69cbbc60590c325683_BST_MockBST)
-  [Constants](#@Constants_0)


<pre><code></code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_Keys"></a>

## Struct `Keys`

Contains a vector of <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a></code>, each with a <code>key</code> field, such that
each <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a></code> is stored at an index in <code>nodes</code> identical to the
storage index of its corresponding value, per <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MockBST">MockBST</a>.values</code>.


<pre><code><b>struct</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Keys">Keys</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>root: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nodes: vector&lt;<a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">BST::Node</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_Node"></a>

## Struct `Node`

A single node in the tree, containing a key but not a
corresponding value. Ideally, values from the key-value pair
would simply be stored in a <code>value</code> field of type
<code>vector&lt;ValueType&gt;</code>, with <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a></code> taking the generically-typed
form <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a>&lt;<b>phantom</b> ValueType&gt;</code>. But this kind of dynamic typing
is forbidden in Move, so values must be stored per the data
structure speficied by <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MockBST">MockBST</a></code>.


<pre><code><b>struct</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>key: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>color: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>parent: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>left: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>right: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>metadata: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_MockValueType"></a>

## Struct `MockValueType`

A mock value resource type for modelling and testing


<pre><code><b>struct</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MockValueType">MockValueType</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>field: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_MockBST"></a>

## Struct `MockBST`

A mock instantiation of a binary search tree containing
key-value pairs, where each <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a></code> in <code>keys</code> corresponds to the
<code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MockValueType">MockValueType</a></code> in <code>values</code> at the same  vector index.
Ideally, values would more simply be stored as fields within
each <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Node">Node</a></code>, but Move's typing constraints prohibit this data
structure.


<pre><code><b>struct</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MockBST">MockBST</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>keys: <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_Keys">BST::Keys</a></code>
</dt>
<dd>

</dd>
<dt>
<code>values: vector&lt;<a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MockValueType">BST::MockValueType</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_BLACK"></a>

Flag for black node


<pre><code><b>const</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_BLACK">BLACK</a>: bool = <b>true</b>;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_MAX_NODES"></a>

Maximum number of nodes that can be kept in the tree, equivalent
to <code><a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_NULL">NULL</a></code> - 1


<pre><code><b>const</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_MAX_NODES">MAX_NODES</a>: u64 = 18446744073709551614;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_NULL"></a>

Flag to indicate that there is no connected node for the given
relationship field (<code>parent</code>, <code>left</code>, or <code>right</code>), analagous to
a null pointer


<pre><code><b>const</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_NULL">NULL</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0x1d157846c6d7ac69cbbc60590c325683_BST_RED"></a>

Flag for red node


<pre><code><b>const</b> <a href="BST.md#0x1d157846c6d7ac69cbbc60590c325683_BST_RED">RED</a>: bool = <b>false</b>;
</code></pre>
