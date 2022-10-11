
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


Tree nodes and list nodes are each assigned a 1-indexed 15-bit
serial ID known as a node ID. Node ID 0 is reserved for null, such
that the maximum number of allocated nodes for each node type is
thus $2^{15} - 1$.

15-bit node IDs are used rather than 16-bit node IDs so that a node
ID and a bit flag can be stored in 16 bits.


<a name="@Access_keys_2"></a>

## Access keys


| Bit(s) | Data                                         |
|--------|----------------------------------------------|
| 48-62  | Tree node ID                                 |
| 33-47  | List node ID                                 |
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
-  [Function `activate_list_node`](#0xc0deb00c_avl_queue_activate_list_node)
    -  [Parameters](#@Parameters_9)
    -  [Returns](#@Returns_10)
    -  [Assumptions](#@Assumptions_11)
    -  [Testing](#@Testing_12)
-  [Function `activate_tree_node`](#0xc0deb00c_avl_queue_activate_tree_node)
    -  [Parameters](#@Parameters_13)
    -  [Assumptions](#@Assumptions_14)
    -  [Testing](#@Testing_15)
-  [Function `verify_node_count`](#0xc0deb00c_avl_queue_verify_node_count)
    -  [Aborts](#@Aborts_16)
    -  [Testing](#@Testing_17)


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
| 124     | If set, ascending AVL queue, else descending       |
| 109-123 | Tree node ID at top of inactive stack              |
| 94-108  | List node ID at top of inactive stack              |
| 79-93   | AVL queue head list node ID                        |
| 47-78   | AVL queue head insertion key (if node ID not null) |
| 32-46   | AVL queue tail list node ID                        |
| 0-31    | AVL queue tail insertion key (if node ID not null) |


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
<code>root_msbs: u8</code>
</dt>
<dd>
 Bits 8-14 of tree root node ID.
</dd>
<dt>
<code>root_lsbs: u8</code>
</dt>
<dd>
 Bits 0-7 of tree root node ID.
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
| 92-123 | Insertion key                        |
| 90-91  | Balance factor (see below)           |
| 75-89  | Parent node ID                       |
| 60-74  | Left child node ID                   |
| 45-59  | Right child node ID                  |
| 30-44  | List head node ID                    |
| 15-29  | List tail node ID                    |
| 0-14   | Next inactive node ID, when in stack |

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

When set at bit 15, the 16-bit concatenated result of <code>_msbs</code>
and <code>_lsbs</code> fields, in either case, refers to a tree node ID: If
<code>last_msbs</code> and <code>last_lsbs</code> indicate a tree node ID, then the
list node is the head of the list at the given tree node. If
<code>next_msbs</code> and <code>next_lsbs</code> indicate a tree node ID, then the
list node is the tail of the list at the given tree node.

If not set at bit 15, the corresponding node ID is either the
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



<a name="0xc0deb00c_avl_queue_BALANCE_FACTOR_0"></a>

Balance factor bits in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code> indicating balance factor
of 0.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BALANCE_FACTOR_0">BALANCE_FACTOR_0</a>: u8 = 0;
</code></pre>



<a name="0xc0deb00c_avl_queue_BALANCE_FACTOR_NEG_1"></a>

Balance factor bits in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code> indicating balance factor
of -1. Generated in Python via <code>hex(int('10', 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BALANCE_FACTOR_NEG_1">BALANCE_FACTOR_NEG_1</a>: u8 = 2;
</code></pre>



<a name="0xc0deb00c_avl_queue_BALANCE_FACTOR_POS_1"></a>

Balance factor bits in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code> indicating balance factor
of 1.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BALANCE_FACTOR_POS_1">BALANCE_FACTOR_POS_1</a>: u8 = 1;
</code></pre>



<a name="0xc0deb00c_avl_queue_BITS_PER_BYTE"></a>

Number of bits in a byte.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>: u8 = 8;
</code></pre>



<a name="0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING"></a>

Bit flag denoting ascending AVL queue.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a>: u8 = 1;
</code></pre>



<a name="0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE"></a>

Bit flag denoting a tree node.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a>: u8 = 1;
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



<a name="0xc0deb00c_avl_queue_HI_BALANCE_FACTOR"></a>

All bits set in integer of width required to encode balance
factor. Generated in Python via <code>hex(int('1' * 2, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BALANCE_FACTOR">HI_BALANCE_FACTOR</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_BYTE"></a>

All bits set in integer of width required to encode a byte.
Generated in Python via <code>hex(int('1' * 8, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>: u64 = 255;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_INSERTION_KEY"></a>

All bits set in integer of width required to encode insertion
key. Generated in Python via <code>hex(int('1' * 32, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a>: u64 = 4294967295;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_NODE_ID"></a>

All bits set in integer of width required to encode node ID.
Generated in Python via <code>hex(int('1' * 15, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a>: u64 = 32767;
</code></pre>



<a name="0xc0deb00c_avl_queue_NIL"></a>

Flag for null value when null defined as 0.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_avl_queue_N_NODES_MAX"></a>

$2^{15} - 1$, the maximum number of nodes that can be allocated
for either node type.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a>: u64 = 32767;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_BALANCE_FACTOR"></a>

Number of bits balance factor is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_BALANCE_FACTOR">SHIFT_BALANCE_FACTOR</a>: u8 = 90;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT"></a>

Number of bits left child node ID is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>: u8 = 60;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT"></a>

Number of bits right child node ID is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>: u8 = 45;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY"></a>

Number of bits insertion key is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY">SHIFT_INSERTION_KEY</a>: u8 = 92;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_LIST_HEAD"></a>

Number of bits list head node ID is shited in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a>: u8 = 30;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP"></a>

Number of bits inactive list node stack top is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>: u8 = 94;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_LIST_TAIL"></a>

Number of bits list tail node ID is shited in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>: u8 = 15;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_NODE_TYPE"></a>

Number of bits node type bit flag is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a></code>
virtual last and next fields.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_NODE_TYPE">SHIFT_NODE_TYPE</a>: u8 = 15;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_PARENT"></a>

Number of bits parent node ID is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>: u8 = 75;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_SORT_ORDER"></a>

Number of bits sort order is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a>: u8 = 124;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP"></a>

Number of bits inactive tree node stack top is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>: u8 = 109;
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
* <code>test_new_some_nodes_loop()</code>


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
    <b>let</b> bits = <b>if</b> (sort_order == <a href="avl_queue.md#0xc0deb00c_avl_queue_DESCENDING">DESCENDING</a>) (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u128) <b>else</b>
        ((<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a>);
    // Mask in 1-indexed node ID at top of each inactive node stack.
    bits = bits | ((n_inactive_tree_nodes <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>)
        | ((n_inactive_list_nodes <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>);
    // Declare empty AVL queue.
    <b>let</b> avlq = <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>{bits,
                        root_msbs: (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u8),
                        root_lsbs: (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u8),
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
                next_lsbs: (i & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u8)});
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
    avlq_ref.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a> & (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a> <b>as</b> u128) ==
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a> <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_list_node"></a>

## Function `activate_list_node`

Activate a list node and return its node ID.

If inactive list node stack is empty, allocate a new list node,
otherwise pop one off the inactive stack.

If activated list node will be the only list node in a doubly
linked list, then it will have to indicate for next and last
node IDs a tree node, which will also have to be activated via
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>()</code>. Hence error checking for the number of
allocated tree nodes is performed here first, and is not
re-performed in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>()</code>.


<a name="@Parameters_9"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>solo</code>: If <code><b>true</b></code>, is only list node in corresponding doubly
linked list.
* <code>last</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>.last_msbs</code> concatenated with
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>.last_lsbs</code>. Overwritten if <code>solo</code> is <code><b>true</b></code>.
* <code>next</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>.next_msbs</code> concatenated with
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>.next_lsbs</code>. Overwritten if <code>solo</code> is <code><b>true</b></code>.
* <code>value</code>: Insertion value for list node to activate.


<a name="@Returns_10"></a>

### Returns


* <code>u64</code>: Node ID of activated list node.


<a name="@Assumptions_11"></a>

### Assumptions


* <code>last</code> and <code>next</code> are not set at any bits above 14.


<a name="@Testing_12"></a>

### Testing


* <code>test_activate_list_node_not_solo()</code>
* <code>test_activate_list_node_solo_empty_empty()</code>
* <code>test_activate_list_node_solo_stacked_stacked()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, solo: bool, last: u64, next: u64, value: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    solo: bool,
    last: u64,
    next: u64,
    value: V
): u64 {
    // If only list node in doubly linked list, will need <b>to</b>
    // activate tree node having given list:
    <b>if</b> (solo) {
        // Get top of inactive tree nodes stack.
        <b>let</b> tree_node_id = ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &
            (avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>) <b>as</b> u64);
        // If will need <b>to</b> allocate a new tree node:
        <b>if</b> (tree_node_id == <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>) {
            tree_node_id = // Get new 1-indexed tree node ID.
                <a href="_length">table_with_length::length</a>(&avlq_ref_mut.tree_nodes) + 1;
            // Verify tree nodes not over-allocated.
            <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(tree_node_id);
        };
        // Declare bitmask for flagging a tree node.
        <b>let</b> is_tree_node = (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a> <b>as</b> u64) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_NODE_TYPE">SHIFT_NODE_TYPE</a>;
        // Set last node ID <b>as</b> flagged tree node ID.
        last = tree_node_id | is_tree_node;
        // Set next node ID <b>as</b> flagged tree node ID.
        next = tree_node_id | is_tree_node;
    }; // Last and next arguments now overwritten <b>if</b> solo.
    // Mutably borrow insertion values <a href="">table</a>.
    <b>let</b> values_ref_mut = &<b>mut</b> avlq_ref_mut.values;
    // Split last and next arguments into byte fields.
    <b>let</b> (last_msbs, last_lsbs, next_msbs, next_lsbs) = (
        (last &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a> <b>as</b> u8), (last & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u8),
        (next &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a> <b>as</b> u8), (next & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u8));
    // Get top of inactive list nodes stack.
    <b>let</b> list_node_id = ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &
        (avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>) <b>as</b> u64);
    // If will need <b>to</b> allocate a new list node:
    <b>if</b> (list_node_id == <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>) {
        list_node_id = // Get new 1-indexed list node ID.
            <a href="_length">table_with_length::length</a>(&avlq_ref_mut.list_nodes) + 1;
        // Verify list nodes not over-allocated.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(list_node_id);
        // Mutably borrow list nodes <a href="">table</a>.
        <b>let</b> list_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.list_nodes;
        // Allocate a new list node <b>with</b> given fields.
        <a href="_add">table_with_length::add</a>(list_nodes_ref_mut, list_node_id, <a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>{
            last_msbs, last_lsbs, next_msbs, next_lsbs});
        // Allocate a new list node value <a href="">option</a>.
        <a href="_add">table::add</a>(values_ref_mut, list_node_id, <a href="_some">option::some</a>(value));
    } <b>else</b> { // If can pop inactive node off stack:
        // Mutably borrow list nodes <a href="">table</a>.
        <b>let</b> list_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.list_nodes;
        // Mutably borrow inactive node at top of stack.
        <b>let</b> node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            list_nodes_ref_mut, list_node_id);
        <b>let</b> new_list_stack_top = // Get new list stack top node ID.
            ((node_ref_mut.next_msbs <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) |
             (node_ref_mut.next_lsbs <b>as</b> u128);
        // Reassign inactive list node stack top bits:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out all bits via mask unset at relevant bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>)) |
            // Mask in the new stack top bits.
            (new_list_stack_top &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>);
        node_ref_mut.last_msbs = last_msbs; // Reassign last MSBs.
        node_ref_mut.last_lsbs = last_lsbs; // Reassign last LSBs.
        node_ref_mut.next_msbs = next_msbs; // Reassign next MSBs.
        node_ref_mut.next_lsbs = next_lsbs; // Reassign next LSBs.
        // Mutably borrow empty value <a href="">option</a> for node ID.
        <b>let</b> value_option_ref_mut =
            <a href="_borrow_mut">table::borrow_mut</a>(values_ref_mut, list_node_id);
        // Fill the empty value <a href="">option</a> <b>with</b> the insertion value.
        <a href="_fill">option::fill</a>(value_option_ref_mut, value);
    };
    list_node_id // Return activated list node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_tree_node"></a>

## Function `activate_tree_node`

Activate a tree node and return its node ID.

If inactive tree node stack is empty, allocate a new tree node,
otherwise pop one off the inactive stack.

Should only be called when <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>()</code> activates a
solo list node in an AVL tree leaf.


<a name="@Parameters_13"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>key</code>: Insertion key for activation node.
* <code>parent</code>: Node ID of parent to actvation node.
* <code>head_tail</code>: Node ID of sole list node in tree node's doubly
linked list.


<a name="@Assumptions_14"></a>

### Assumptions


* Node is a leaf in the AVL tree and has a single list node in
its doubly linked list.
* The number of allocated tree nodes has already been checked
via <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>()</code>.
* <code>key</code> is not set at any bits above 31, and both other <code>u64</code>
fields are not set at any bits above 13.


<a name="@Testing_15"></a>

### Testing


* <code>test_activate_tree_node_empty()</code>.
* <code>test_activate_tree_node_stacked()</code>.


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, key: u64, parent: u64, solo_node_id: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    key: u64,
    parent: u64,
    solo_node_id: u64
): u64 {
    // Pack field bits.
    <b>let</b> bits = (key <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY">SHIFT_INSERTION_KEY</a> |
        (parent <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a> |
        (solo_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a> |
        (solo_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>;
    // Get top of inactive tree nodes stack.
    <b>let</b> tree_node_id = ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &
        (avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>) <b>as</b> u64);
    <b>if</b> (tree_node_id == <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>) { // If need <b>to</b> allocate new tree node:
        tree_node_id = // Get new 1-indexed tree node ID.
            <a href="_length">table_with_length::length</a>(&avlq_ref_mut.tree_nodes) + 1;
        // Mutably borrow tree nodes <a href="">table</a>.
        <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
        <a href="_add">table_with_length::add</a>( // Allocate new packed tree node.
            tree_nodes_ref_mut, tree_node_id, <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>{bits})
    } <b>else</b> { // If can pop inactive node off stack:
        // Mutably borrow tree nodes <a href="">table</a>.
        <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
        // Mutably borrow inactive node at top of stack.
        <b>let</b> node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, tree_node_id);
        // Get new inactive tree nodes stack top node ID.
        <b>let</b> new_tree_stack_top = node_ref_mut.bits & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128);
        // Reassign inactive tree node stack top bits:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out all bits via mask unset at relevant bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>)) |
            // Mask in the new stack top bits.
            (new_tree_stack_top &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>);
        node_ref_mut.bits = bits; // Reassign activated node bits.
    };
    tree_node_id // Return activated tree node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_verify_node_count"></a>

## Function `verify_node_count`

Verify node count is not too high.


<a name="@Aborts_16"></a>

### Aborts


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a></code>: <code>n_nodes</code> is not less than <code><a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a></code>.


<a name="@Testing_17"></a>

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
