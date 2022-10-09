
<a name="0xc0deb00c_avl_queue"></a>

# Module `0xc0deb00c::avl_queue`

AVL queue: a hybrid between an AVL tree and a queue.


<a name="@References_0"></a>

## References


* [Adelson-Velski and Landis 1962] (original paper)
* [Galles 2011] (interactive visualizer)
* [Wikipedia 2022]

[Adelson-Velski and Landis 1962]:
https://zhjwpku.com/assets/pdf/AED2-10-avl-paper.pdf
[Galles 2011]:
https://www.cs.usfca.edu/~galles/visualization/AVLtree.html
[Wikipedia 2022]:
https://en.wikipedia.org/wiki/AVL_tree


<a name="@Node_IDs_1"></a>

## Node IDs


Tree nodes and list nodes are each assigned a 1-indexed 14-bit
serial ID known as a node ID. Node ID 0 is reserved for null, such
that the maximum number of allocated nodes for each node type is
thus $2^{14} - 1$.


<a name="@Access_keys_2"></a>

## Access keys


| Bit(s) | Data                                         |
|--------|----------------------------------------------|
| 47-60  | Tree node ID                                 |
| 33-46  | List node ID                                 |
| 32     | If set, ascending AVL queue, else descending |
| 0-31   | Insertion key                                |


<a name="@Complete_docgen_index_3"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [References](#@References_0)
-  [Node IDs](#@Node_IDs_1)
-  [Access keys](#@Access_keys_2)
-  [Complete docgen index](#@Complete_docgen_index_3)
-  [Struct `AVLqueue`](#0xc0deb00c_avl_queue_AVLqueue)
-  [Struct `TreeNode`](#0xc0deb00c_avl_queue_TreeNode)
-  [Struct `ListNode`](#0xc0deb00c_avl_queue_ListNode)
-  [Constants](#@Constants_4)
-  [Function `new`](#0xc0deb00c_avl_queue_new)
    -  [Parameters](#@Parameters_5)
    -  [Returns](#@Returns_6)
    -  [Testing](#@Testing_7)
-  [Function `is_ascending`](#0xc0deb00c_avl_queue_is_ascending)
    -  [Testing](#@Testing_8)
-  [Function `verify_node_count`](#0xc0deb00c_avl_queue_verify_node_count)
    -  [Aborts](#@Aborts_9)
    -  [Testing](#@Testing_10)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
</code></pre>



<a name="0xc0deb00c_avl_queue_AVLqueue"></a>

## Struct `AVLqueue`

A hybrid between an AVL tree and a queue. See above.

Most non-table fields stored compactly in <code>bits</code> as follows:

| Bit(s)  | Data                                               |
|---------|----------------------------------------------------|
| 126     | If set, ascending AVL queue, else descending       |
| 112-125 | Tree node ID at top of inactive stack              |
| 98-111  | List node ID at top of inactive stack              |
| 84-97   | AVL queue head list node ID                        |
| 52-83   | AVL queue head insertion key (if node ID not null) |
| 38-51   | AVL queue tail list node ID                        |
| 6-37    | AVL queue tail insertion key (if node ID not null) |
| 0-5     | Bits 8-13 of tree root node ID                     |

Bits 0-7 of the tree root node ID are stored in <code>root_lsbs</code>.


<pre><code><b>struct</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bits: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>root_lsbs: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>tree_nodes: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">avl_queue::TreeNode</a>&gt;</code>
</dt>
<dd>
 Map from tree node ID to tree node.
</dd>
<dt>
<code>list_nodes: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">avl_queue::ListNode</a>&gt;</code>
</dt>
<dd>
 Map from list node ID to list node.
</dd>
<dt>
<code>values: <a href="_Table">table::Table</a>&lt;u64, <a href="_Option">option::Option</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Map from list node ID to optional insertion value.
</dd>
</dl>


</details>

<a name="0xc0deb00c_avl_queue_TreeNode"></a>

## Struct `TreeNode`

A tree node in an AVL queue.

All fields stored compactly in <code>bits</code> as follows:

| Bit(s) | Data                                 |
|--------|--------------------------------------|
| 86-117 | Insertion key                        |
| 84-85  | Balance factor (see below)           |
| 70-83  | Parent node ID                       |
| 56-69  | Left child node ID                   |
| 42-55  | Right child node ID                  |
| 28-41  | List head node ID                    |
| 14-27  | List tail node ID                    |
| 0-13   | Next inactive node ID, when in stack |

Balance factor bits:

| Bit(s) | Balance factor             |
|--------|----------------------------|
| <code>0b10</code> | -1  (left subtree taller)  |
| <code>0b00</code> | 0                          |
| <code>0b01</code> | +1  (right subtree taller) |

All fields except next inactive node ID are ignored when the
node is in the inactive nodes stack.


<pre><code><b>struct</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bits: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc0deb00c_avl_queue_ListNode"></a>

## Struct `ListNode`

A list node in an AVL queue.

For compact storage, last and next values are split into two
<code>u8</code> fields each: one for most-significant bits (<code>last_msbs</code>,
<code>next_msbs</code>), and one for least-significant bits (<code>last_lsbs</code>,
<code>next_lsbs</code>).

When set at bit 14, the 16-bit concatenated result of <code>_msbs</code>
and <code>_lsbs</code> fields, in either case, refers to a tree node ID: If
<code>last_msbs</code> and <code>last_lsbs</code> indicate a tree node ID, then the
list node is the head of the list at the given tree node. If
<code>next_msbs</code> and <code>next_lsbs</code> indicate a tree node ID, then the
list node is the tail of the list at the given tree node.

If not set at bit 14, the corresponding node ID is either the
last or the next list node in the doubly linked list.

If list node is in the inactive list node stack, next node ID
indicates next inactive node in the stack.


<pre><code><b>struct</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>last_msbs: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>last_lsbs: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>next_msbs: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>next_lsbs: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_4"></a>

## Constants


<a name="0xc0deb00c_avl_queue_ASCENDING"></a>

Ascending AVL queue flag.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_ASCENDING">ASCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_AVLQ_BITS_ASCENDING"></a>

Bitmask set at bit 126, the result of <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code> bitwise
<code>AND</code> <code>AVL_QUEUE_BITS_SORT_ORDER</code> for an ascending AVL queue.
Generated in Python via <code>hex(int('1' + '0' * 126, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_ASCENDING">AVLQ_BITS_ASCENDING</a>: u128 = 85070591730234615865843651857942052864;
</code></pre>



<a name="0xc0deb00c_avl_queue_AVLQ_BITS_DESCENDING"></a>

The result of <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code> bitwise <code>AND</code>
<code>AVL_QUEUE_BITS_SORT_ORDER</code> for a descending AVL queue.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_DESCENDING">AVLQ_BITS_DESCENDING</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_avl_queue_AVLQ_BITS_LIST_TOP_SHIFT"></a>

Number of bits the inactive list node stack top node ID is
shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_LIST_TOP_SHIFT">AVLQ_BITS_LIST_TOP_SHIFT</a>: u8 = 98;
</code></pre>



<a name="0xc0deb00c_avl_queue_AVLQ_BITS_SORT_ORDER"></a>

Bitmask set at bit 126, the sort order bit flag in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>. Generated in Python via
<code>hex(int('1' + '0' * 126, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_SORT_ORDER">AVLQ_BITS_SORT_ORDER</a>: u128 = 85070591730234615865843651857942052864;
</code></pre>



<a name="0xc0deb00c_avl_queue_AVLQ_BITS_TREE_TOP_SHIFT"></a>

Number of bits the inactive tree node stack top node ID is
shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_TREE_TOP_SHIFT">AVLQ_BITS_TREE_TOP_SHIFT</a>: u8 = 112;
</code></pre>



<a name="0xc0deb00c_avl_queue_BITS_PER_BYTE"></a>

Number of bits in a byte.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>: u8 = 8;
</code></pre>



<a name="0xc0deb00c_avl_queue_DESCENDING"></a>

Descending AVL queue flag.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_DESCENDING">DESCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_E_TOO_MANY_NODES"></a>

Number of allocated nodes is too high.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_128"></a>

<code>u128</code> bitmask with all bits set, generated in Python via
<code>hex(int('1' * 128, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_64"></a>

<code>u64</code> bitmask with all bits set, generated in Python via
<code>hex(int('1' * 64, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_avl_queue_LEAST_SIGNIFICANT_BYTE"></a>

Set at bits 0-7, yielding most significant byte after bitwise
<code>AND</code>. Generated in Python via <code>hex(int('1' * 8, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_LEAST_SIGNIFICANT_BYTE">LEAST_SIGNIFICANT_BYTE</a>: u64 = 255;
</code></pre>



<a name="0xc0deb00c_avl_queue_NIL"></a>

Flag for null node ID.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_avl_queue_NODE_ID_LSBS"></a>

Set at bits 0-13, for <code>AND</code> masking off all bits other than node
ID contained in least-significant bits. Generated in Python via
<code>hex(int('1' * 14, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_NODE_ID_LSBS">NODE_ID_LSBS</a>: u64 = 16383;
</code></pre>



<a name="0xc0deb00c_avl_queue_N_NODES_MAX"></a>

$2^{14} - 1$, the maximum number of nodes that can be allocated
for either node type.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a>: u64 = 16383;
</code></pre>



<a name="0xc0deb00c_avl_queue_new"></a>

## Function `new`

Return a new AVL queue, optionally allocating inactive nodes.


<a name="@Parameters_5"></a>

### Parameters


* <code>sort_order</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ASCENDING">ASCENDING</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DESCENDING">DESCENDING</a></code>.
* <code>n_inactive_tree_nodes</code>: The number of inactive tree nodes
to allocate.
* <code>n_inactive_list_nodes</code>: The number of inactive list nodes
to allocate.


<a name="@Returns_6"></a>

### Returns


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;</code>: A new AVL queue.


<a name="@Testing_7"></a>

### Testing


* <code>test_new_no_nodes()</code>
* <code>test_new_some_nodes()</code>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_new">new</a>&lt;V: store&gt;(sort_order: bool, n_inactive_tree_nodes: u64, n_inactive_list_nodes: u64): <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_new">new</a>&lt;V: store&gt;(
    sort_order: bool,
    n_inactive_tree_nodes: u64,
    n_inactive_list_nodes: u64,
): <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt; {
    // Assert not trying <b>to</b> allocate too many tree nodes.
    <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(n_inactive_tree_nodes);
    // Assert not trying <b>to</b> allocate too many list nodes.
    <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(n_inactive_list_nodes);
    // Initialize bits field based on sort order.
    <b>let</b> bits = <b>if</b> (sort_order == <a href="avl_queue.md#0xc0deb00c_avl_queue_ASCENDING">ASCENDING</a>) <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_ASCENDING">AVLQ_BITS_ASCENDING</a> <b>else</b>
        <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_DESCENDING">AVLQ_BITS_DESCENDING</a>;
    // Mask in 1-indexed node ID at top of each inactive node stack.
    bits = bits
        | ((n_inactive_tree_nodes <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_TREE_TOP_SHIFT">AVLQ_BITS_TREE_TOP_SHIFT</a>)
        | ((n_inactive_list_nodes <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_LIST_TOP_SHIFT">AVLQ_BITS_LIST_TOP_SHIFT</a>);
    // Declare empty AVL queue.
    <b>let</b> avlq = <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>{bits,
                        root_lsbs: 0,
                        tree_nodes: <a href="_new">table_with_length::new</a>(),
                        list_nodes: <a href="_new">table_with_length::new</a>(),
                        values: <a href="_new">table::new</a>()};
    // If need <b>to</b> allocate at least one tree node:
    <b>if</b> (n_inactive_tree_nodes &gt; 0) {
        <b>let</b> i = 0; // Declare <b>loop</b> counter.
        // While nodes <b>to</b> allocate:
        <b>while</b> (i &lt; n_inactive_tree_nodes) {
            // Add <b>to</b> tree nodes <a href="">table</a> a node having 1-indexed node
            // ID derived from counter, indicating next inactive
            // node in stack <b>has</b> ID of last allocated node (or null
            // in the case of the first <b>loop</b> iteration).
            <a href="_add">table_with_length::add</a>(
                &<b>mut</b> avlq.tree_nodes, i + 1, <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>{bits: (i <b>as</b> u128)});
            i = i + 1; // Increment <b>loop</b> counter.
        };
    };
    // If need <b>to</b> allocate at least one list node:
    <b>if</b> (n_inactive_list_nodes &gt; 0) {
        <b>let</b> i = 0; // Declare <b>loop</b> counter.
        // While nodes <b>to</b> allocate:
        <b>while</b> (i &lt; n_inactive_list_nodes) {
            // Add <b>to</b> list nodes <a href="">table</a> a node having 1-indexed node
            // ID derived from counter, indicating next inactive
            // node in stack <b>has</b> ID of last allocated node (or null
            // in the case of the first <b>loop</b> iteration).
            <a href="_add">table_with_length::add</a>(&<b>mut</b> avlq.list_nodes, i + 1, <a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>{
                last_msbs: 0,
                last_lsbs: 0,
                next_msbs: (i &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a> <b>as</b> u8),
                next_lsbs: (i & <a href="avl_queue.md#0xc0deb00c_avl_queue_LEAST_SIGNIFICANT_BYTE">LEAST_SIGNIFICANT_BYTE</a> <b>as</b> u8)});
            // Allocate optional insertion value entry.
            <a href="_add">table::add</a>(&<b>mut</b> avlq.values, i + 1, <a href="_none">option::none</a>());
            i = i + 1; // Increment <b>loop</b> counter.
        };
    };
    avlq // Return AVL queue.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_is_ascending"></a>

## Function `is_ascending`

Return <code><b>true</b></code> if given AVL queue has ascending sort order.


<a name="@Testing_8"></a>

### Testing


* <code>test_is_ascending()</code>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_is_ascending">is_ascending</a>&lt;V&gt;(avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_is_ascending">is_ascending</a>&lt;V&gt;(
    avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;
): bool {
    avlq_ref.bits & <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_ASCENDING">AVLQ_BITS_ASCENDING</a> == <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLQ_BITS_ASCENDING">AVLQ_BITS_ASCENDING</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_verify_node_count"></a>

## Function `verify_node_count`

Verify node count is not too high.


<a name="@Aborts_9"></a>

### Aborts


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a></code>: <code>n_nodes</code> is not less than <code><a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a></code>.


<a name="@Testing_10"></a>

### Testing


* <code>test_verify_node_count_fail()</code>
* <code>test_verify_node_count_pass()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(n_nodes: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(
    n_nodes: u64,
) {
    // Assert node count is less than or equal <b>to</b> max amount.
    <b>assert</b>!(n_nodes &lt;= <a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a>, <a href="avl_queue.md#0xc0deb00c_avl_queue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a>);
}
</code></pre>



</details>
