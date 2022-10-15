
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
thus $2^{14} - 1 = 16383$.


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
    -  [Height](#@Height_4)
-  [Struct `ListNode`](#0xc0deb00c_avl_queue_ListNode)
-  [Constants](#@Constants_5)
-  [Function `new`](#0xc0deb00c_avl_queue_new)
    -  [Parameters](#@Parameters_6)
    -  [Returns](#@Returns_7)
    -  [Testing](#@Testing_8)
-  [Function `is_ascending`](#0xc0deb00c_avl_queue_is_ascending)
    -  [Testing](#@Testing_9)
-  [Function `activate_list_node`](#0xc0deb00c_avl_queue_activate_list_node)
    -  [Parameters](#@Parameters_10)
    -  [Returns](#@Returns_11)
    -  [Testing](#@Testing_12)
-  [Function `activate_list_node_assign_fields`](#0xc0deb00c_avl_queue_activate_list_node_assign_fields)
    -  [Parameters](#@Parameters_13)
    -  [Returns](#@Returns_14)
    -  [Testing](#@Testing_15)
-  [Function `activate_list_node_get_last_next`](#0xc0deb00c_avl_queue_activate_list_node_get_last_next)
    -  [Parameters](#@Parameters_16)
    -  [Returns](#@Returns_17)
    -  [Testing](#@Testing_18)
-  [Function `activate_tree_node`](#0xc0deb00c_avl_queue_activate_tree_node)
    -  [Parameters](#@Parameters_19)
    -  [Returns](#@Returns_20)
    -  [Assumptions](#@Assumptions_21)
    -  [Testing](#@Testing_22)
-  [Function `activate_tree_node_update_parent_edge`](#0xc0deb00c_avl_queue_activate_tree_node_update_parent_edge)
    -  [Parameters](#@Parameters_23)
    -  [Testing](#@Testing_24)
-  [Function `rotate_left`](#0xc0deb00c_avl_queue_rotate_left)
    -  [Parameters](#@Parameters_25)
    -  [Returns](#@Returns_26)
    -  [Reference rotations:](#@Reference_rotations:_27)
        -  [Case 1](#@Case_1_28)
        -  [Case 1](#@Case_1_29)
    -  [Testing](#@Testing_30)
-  [Function `rotate_left_right`](#0xc0deb00c_avl_queue_rotate_left_right)
    -  [Procedure](#@Procedure_31)
    -  [Reference rotations:](#@Reference_rotations:_32)
        -  [Case 1](#@Case_1_33)
        -  [Case 2](#@Case_2_34)
    -  [Testing](#@Testing_35)
-  [Function `rotate_right`](#0xc0deb00c_avl_queue_rotate_right)
    -  [Parameters](#@Parameters_36)
    -  [Returns](#@Returns_37)
    -  [Reference rotations:](#@Reference_rotations:_38)
        -  [Case 1](#@Case_1_39)
        -  [Case 1](#@Case_1_40)
    -  [Testing](#@Testing_41)
-  [Function `rotate_right_left`](#0xc0deb00c_avl_queue_rotate_right_left)
    -  [Parameters](#@Parameters_42)
    -  [Procedure](#@Procedure_43)
    -  [Reference rotations:](#@Reference_rotations:_44)
        -  [Case 1](#@Case_1_45)
        -  [Case 2](#@Case_2_46)
    -  [Testing](#@Testing_47)
-  [Function `search`](#0xc0deb00c_avl_queue_search)
    -  [Parameters](#@Parameters_48)
    -  [Returns](#@Returns_49)
    -  [Assumptions](#@Assumptions_50)
    -  [Reference diagram](#@Reference_diagram_51)
    -  [Testing](#@Testing_52)
-  [Function `verify_node_count`](#0xc0deb00c_avl_queue_verify_node_count)
    -  [Aborts](#@Aborts_53)
    -  [Testing](#@Testing_54)


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
| 94-125 | Insertion key                        |
| 89-93  | Left height (see below)              |
| 84-88  | Right height (see below)             |
| 70-83  | Parent node ID                       |
| 56-69  | Left child node ID                   |
| 42-55  | Right child node ID                  |
| 28-41  | List head node ID                    |
| 14-27  | List tail node ID                    |
| 0-13   | Next inactive node ID, when in stack |

All fields except next inactive node ID are ignored when the
node is in the inactive nodes stack.


<a name="@Height_4"></a>

### Height


Left or right height denotes the height of the node's left
or right subtree, respectively, plus one. Subtree height is
adjusted by one to avoid negative numbers, with the resultant
value denoting the height of a tree rooted at the given node,
accounting only for height to the given side:

>       2
>      / \
>     1   3
>          \
>           4

| Key | Left height | Right height |
|-----|-------------|--------------|
| 1   | 0           | 0            |
| 2   | 1           | 2            |
| 3   | 0           | 1            |
| 4   | 0           | 0            |

For a tree of size $n \geq 1$, an AVL tree's height is at most

$$h \leq c \log_2(n + d) + b$$

where

* $\varphi = \frac{1 + \sqrt{5}}{2} \approx 1.618$ (the golden
ratio),
* $c = \frac{1}{\log_2 \varphi} \approx 1.440$ ,
* $b = \frac{c}{2} \log_2 5 - 2 \approx -0.328$ , and
* $d = 1 + \frac{1}{\varphi^4 \sqrt{5}} \approx 1.065$ .

With a maximum node count of $n_{max} = 2^{14} - 1 = 13683$, the
maximum height of an AVL tree in the present implementation is
thus

$$h_{max} = \lfloor c \log_2(n_{max} + d) + b \rfloor = 19$$

such that left height and right height can always be encoded in
$\lceil \log_2 19 \rceil = 5$ bits each.


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

For compact storage, a "virtual last field" and a "virtual next
field" are split into two <code>u8</code> fields each: one for
most-significant bits (<code>last_msbs</code>, <code>next_msbs</code>), and one for
least-significant bits (<code>last_lsbs</code>, <code>next_lsbs</code>).

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

<a name="@Constants_5"></a>

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



<a name="0xc0deb00c_avl_queue_HI_HEIGHT"></a>

All bits set in integer of width required to encode left or
right height. Generated in Python via <code>hex(int('1' * 5, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>: u8 = 31;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_INSERTION_KEY"></a>

All bits set in integer of width required to encode insertion
key. Generated in Python via <code>hex(int('1' * 32, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a>: u64 = 4294967295;
</code></pre>



<a name="0xc0deb00c_avl_queue_HI_NODE_ID"></a>

All bits set in integer of width required to encode node ID.
Generated in Python via <code>hex(int('1' * 14, 2))</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a>: u64 = 16383;
</code></pre>



<a name="0xc0deb00c_avl_queue_LEFT"></a>

Flag for left direction.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_NIL"></a>

Flag for null value when null defined as 0.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>: u8 = 0;
</code></pre>



<a name="0xc0deb00c_avl_queue_N_NODES_MAX"></a>

$2^{14} - 1$, the maximum number of nodes that can be allocated
for either node type.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a>: u64 = 16383;
</code></pre>



<a name="0xc0deb00c_avl_queue_RIGHT"></a>

Flag for right direction.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_BALANCE_FACTOR"></a>

Number of bits balance factor is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_BALANCE_FACTOR">SHIFT_BALANCE_FACTOR</a>: u8 = 84;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT"></a>

Number of bits left child node ID is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>: u8 = 56;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT"></a>

Number of bits right child node ID is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>: u8 = 42;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT"></a>

Number of bits left height is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>: u8 = 89;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT"></a>

Number of bits right height is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>: u8 = 84;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY"></a>

Number of bits insertion key is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY">SHIFT_INSERTION_KEY</a>: u8 = 94;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_LIST_HEAD"></a>

Number of bits list head node ID is shited in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a>: u8 = 28;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP"></a>

Number of bits inactive list node stack top is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>: u8 = 98;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_LIST_TAIL"></a>

Number of bits list tail node ID is shited in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>: u8 = 14;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_NODE_TYPE"></a>

Number of bits node type bit flag is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a></code>
virtual last and next fields.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_NODE_TYPE">SHIFT_NODE_TYPE</a>: u8 = 14;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_PARENT"></a>

Number of bits parent node ID is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>: u8 = 70;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_SORT_ORDER"></a>

Number of bits sort order is shifted in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a>: u8 = 126;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP"></a>

Number of bits inactive tree node stack top is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>: u8 = 112;
</code></pre>



<a name="0xc0deb00c_avl_queue_new"></a>

## Function `new`

Return a new AVL queue, optionally allocating inactive nodes.


<a name="@Parameters_6"></a>

### Parameters


* <code>sort_order</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ASCENDING">ASCENDING</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DESCENDING">DESCENDING</a></code>.
* <code>n_inactive_tree_nodes</code>: The number of inactive tree nodes
to allocate.
* <code>n_inactive_list_nodes</code>: The number of inactive list nodes
to allocate.


<a name="@Returns_7"></a>

### Returns


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;</code>: A new AVL queue.


<a name="@Testing_8"></a>

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
                        root_lsbs: <a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a>,
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
                next_msbs: ((i &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8),
                next_lsbs: ((i & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>) <b>as</b> u8)});
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


<a name="@Testing_9"></a>

### Testing


* <code>test_is_ascending()</code>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_is_ascending">is_ascending</a>&lt;V&gt;(avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_is_ascending">is_ascending</a>&lt;V&gt;(
    avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;
): bool {
    ((avlq_ref.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a> <b>as</b> u128)) ==
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a> <b>as</b> u128)
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_list_node"></a>

## Function `activate_list_node`

Activate a list node and return its node ID.

In the case of inserting a list node to a doubly linked list in
an existing tree node, known as the "anchor tree node", the list
node becomes the new list tail.

In the other case of inserting a "solo node" as the sole list
node in a doubly linked list in a new tree leaf, the list node
becomes the head and tail of the new list.


<a name="@Parameters_10"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>anchor_tree_node_id</code>: Node ID of anchor tree node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if
inserting a list node as the sole list node in a new tree
node.
* <code>value</code>: Insertion value for list node to activate.


<a name="@Returns_11"></a>

### Returns


* <code>u64</code>: Node ID of activated list node.


<a name="@Testing_12"></a>

### Testing


* <code>test_activate_list_node_not_solo()</code>
* <code>test_activate_list_node_solo()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, anchor_tree_node_id: u64, value: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    anchor_tree_node_id: u64,
    value: V
): u64 {
    // Get virtual last and next fields for activated list node.
    <b>let</b> (last, next) = <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>(
        avlq_ref_mut, anchor_tree_node_id);
    <b>let</b> list_node_id = // Assign fields, store activated node ID.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_assign_fields">activate_list_node_assign_fields</a>(avlq_ref_mut, last, next, value);
    // If inserting a new list tail that is not solo:
    <b>if</b> (anchor_tree_node_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
        // Mutably borrow tree nodes <a href="">table</a>.
        <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
        // Mutably borrow list nodes <a href="">table</a>.
        <b>let</b> list_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.list_nodes;
        <b>let</b> last_node_ref_mut = // Mutably borrow <b>old</b> tail.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(list_nodes_ref_mut, last);
        last_node_ref_mut.next_msbs = // Reassign its next MSBs.
            ((list_node_id &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8);
        // Reassign its next LSBs <b>to</b> those of activated list node.
        last_node_ref_mut.next_lsbs = ((list_node_id & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>) <b>as</b> u8);
        // Mutably borrow anchor tree node.
        <b>let</b> anchor_node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, anchor_tree_node_id);
        // Reassign bits for list tail node:
        anchor_node_ref_mut.bits = anchor_node_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>)) |
            // Mask in new bits.
            ((list_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>);
    };
    list_node_id // Return activated list node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_list_node_assign_fields"></a>

## Function `activate_list_node_assign_fields`

Assign fields when activating a list node.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>()</code>.

If inactive list node stack is empty, allocate a new list node,
otherwise pop one off the inactive stack.


<a name="@Parameters_13"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>last</code>: Virtual last field from
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>()</code>.
* <code>next</code>: Virtual next field from
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>()</code>.
* <code>value</code>: Insertion value.


<a name="@Returns_14"></a>

### Returns


* <code>u64</code>: Node ID of activated list node.


<a name="@Testing_15"></a>

### Testing


* <code>test_activate_list_node_assign_fields_allocate()</code>
* <code>test_activate_list_node_assign_fields_stacked()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_assign_fields">activate_list_node_assign_fields</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, last: u64, next: u64, value: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_assign_fields">activate_list_node_assign_fields</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    last: u64,
    next: u64,
    value: V
): u64 {
    // Mutably borrow list nodes <a href="">table</a>.
    <b>let</b> list_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.list_nodes;
    // Mutably borrow insertion values <a href="">table</a>.
    <b>let</b> values_ref_mut = &<b>mut</b> avlq_ref_mut.values;
    // Split last and next arguments into byte fields.
    <b>let</b> (last_msbs, last_lsbs, next_msbs, next_lsbs) = (
        ((last &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8), ((last & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>) <b>as</b> u8),
        ((next &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8), ((next & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>) <b>as</b> u8));
    // Get top of inactive list nodes stack.
    <b>let</b> list_node_id = (((avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>) &
                         (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
    // If will need <b>to</b> allocate a new list node:
    <b>if</b> (list_node_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
        // Get new 1-indexed list node ID.
        list_node_id = <a href="_length">table_with_length::length</a>(list_nodes_ref_mut) + 1;
        // Verify list nodes not over-allocated.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(list_node_id);
        // Allocate a new list node <b>with</b> given fields.
        <a href="_add">table_with_length::add</a>(list_nodes_ref_mut, list_node_id, <a href="avl_queue.md#0xc0deb00c_avl_queue_ListNode">ListNode</a>{
            last_msbs, last_lsbs, next_msbs, next_lsbs});
        // Allocate a new list node value <a href="">option</a>.
        <a href="_add">table::add</a>(values_ref_mut, list_node_id, <a href="_some">option::some</a>(value));
    } <b>else</b> { // If can pop inactive node off stack:
        // Mutably borrow inactive node at top of stack.
        <b>let</b> node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            list_nodes_ref_mut, list_node_id);
        <b>let</b> new_list_stack_top = // Get new list stack top node ID.
            ((node_ref_mut.next_msbs <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) |
             (node_ref_mut.next_lsbs <b>as</b> u128);
        // Reassign bits for inactive list node stack top:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>)) |
            // Mask in new bits.
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
    list_node_id // Return list node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_list_node_get_last_next"></a>

## Function `activate_list_node_get_last_next`

Get virtual last and next fields when activating a list node.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>()</code>.

If activated list node will be the only list node in a doubly
linked list, a "solo list node", then it will have to indicate
for next and last node IDs a new tree node, which will also have
to be activated via <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>()</code>. Hence error checking
for the number of allocated tree nodes is performed here first,
and is not re-performed in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>()</code> for the case
of a solo list node.


<a name="@Parameters_16"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>anchor_tree_node_id</code>: Node ID of anchor tree node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if
inserting a solo list node.


<a name="@Returns_17"></a>

### Returns


* <code>u64</code>: Virtual last field of activated list node.
* <code>u64</code>: Virtual next field of activated list node.


<a name="@Testing_18"></a>

### Testing


* <code>test_activate_list_node_get_last_next_new_tail()</code>
* <code>test_activate_list_node_get_last_next_solo_allocate()</code>
* <code>test_activate_list_node_get_last_next_solo_stacked()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>&lt;V&gt;(avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, anchor_tree_node_id: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>&lt;V&gt;(
    avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    anchor_tree_node_id: u64,
): (
    u64,
    u64
) {
    // Declare bitmask for flagging a tree node.
    <b>let</b> is_tree_node = ((<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a> <b>as</b> u64) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_NODE_TYPE">SHIFT_NODE_TYPE</a>);
    // Immutably borrow tree nodes <a href="">table</a>.
    <b>let</b> tree_nodes_ref = &avlq_ref.tree_nodes;
    <b>let</b> last; // Declare virtual last field for activated list node.
    // If inserting a solo list node:
    <b>if</b> (anchor_tree_node_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
        // Get top of inactive tree nodes stack.
        anchor_tree_node_id = (((avlq_ref.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>) &
                                (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
        // If will need <b>to</b> allocate a new tree node:
        <b>if</b> (anchor_tree_node_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
            anchor_tree_node_id = // Get new 1-indexed tree node ID.
                <a href="_length">table_with_length::length</a>(tree_nodes_ref) + 1;
            // Verify tree nodes not over-allocated.
            <a href="avl_queue.md#0xc0deb00c_avl_queue_verify_node_count">verify_node_count</a>(anchor_tree_node_id);
        };
        // Set virtual last field <b>as</b> flagged anchor tree node ID.
        last = anchor_tree_node_id | is_tree_node;
    } <b>else</b> { // If not inserting a solo list node:
        // Immutably borrow anchor tree node.
        <b>let</b> anchor_node_ref = <a href="_borrow">table_with_length::borrow</a>(
            tree_nodes_ref, anchor_tree_node_id);
        // Set virtual last field <b>as</b> anchor node list tail.
        last = (((anchor_node_ref.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>) &
                 (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
    };
    // Return virtual last field per above, and virtual next field
    // <b>as</b> flagged anchor tree node ID.
    (last, (anchor_tree_node_id | is_tree_node))
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_tree_node"></a>

## Function `activate_tree_node`

Activate a tree node and return its node ID.

If inactive tree node stack is empty, allocate a new tree node,
otherwise pop one off the inactive stack.

Should only be called when <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node">activate_list_node</a>()</code> activates the
sole list node in new AVL tree node, thus checking the number
of allocated tree nodes in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>()</code>.


<a name="@Parameters_19"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>key</code>: Insertion key for activated node.
* <code>parent</code>: Node ID of parent to actvated node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> when
activated node is to become root.
* <code>solo_node_id</code>: Node ID of sole list node in tree node's
doubly linked list.
* <code>new_leaf_side</code>: None if activated node is root, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> if
activated node is left child of its parent, and <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code> if
activated node is right child of its parent.


<a name="@Returns_20"></a>

### Returns


* <code>u64</code>: Node ID of activated tree node.


<a name="@Assumptions_21"></a>

### Assumptions


* Node is a leaf in the AVL tree and has a single list node in
its doubly linked list.
* The number of allocated tree nodes has already been checked
via <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_list_node_get_last_next">activate_list_node_get_last_next</a>()</code>.
* All <code>u64</code> fields correspond to valid node IDs.


<a name="@Testing_22"></a>

### Testing


* <code>test_activate_tree_node_empty()</code>.
* <code>test_activate_tree_node_stacked()</code>.


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, key: u64, parent: u64, solo_node_id: u64, new_leaf_side: <a href="_Option">option::Option</a>&lt;bool&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    key: u64,
    parent: u64,
    solo_node_id: u64,
    new_leaf_side: Option&lt;bool&gt;
): u64 {
    // Pack field bits.
    <b>let</b> bits = ((key          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY">SHIFT_INSERTION_KEY</a>) |
               ((parent       <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) |
               ((solo_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a>) |
               ((solo_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>);
    // Get top of inactive tree nodes stack.
    <b>let</b> tree_node_id = (((avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>) &
                         (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    // If need <b>to</b> allocate new tree node:
    <b>if</b> (tree_node_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
        // Get new 1-indexed tree node ID.
        tree_node_id = <a href="_length">table_with_length::length</a>(tree_nodes_ref_mut) + 1;
        <a href="_add">table_with_length::add</a>( // Allocate new packed tree node.
            tree_nodes_ref_mut, tree_node_id, <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>{bits})
    } <b>else</b> { // If can pop inactive node off stack:
        // Mutably borrow inactive node at top of stack.
        <b>let</b> node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, tree_node_id);
        // Get new inactive tree nodes stack top node ID.
        <b>let</b> new_tree_stack_top = node_ref_mut.bits & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128);
        // Reassign bits for inactive tree node stack top:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>)) |
            // Mask in new bits.
            (new_tree_stack_top &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>);
        node_ref_mut.bits = bits; // Reassign activated node bits.
    };
    <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node_update_parent_edge">activate_tree_node_update_parent_edge</a>( // Update parent edge.
        avlq_ref_mut, tree_node_id, parent, new_leaf_side);
    tree_node_id // Return activated tree node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_activate_tree_node_update_parent_edge"></a>

## Function `activate_tree_node_update_parent_edge`

Update the parent edge for a tree node just activated.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>()</code>.


<a name="@Parameters_23"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>tree_node_id</code>: Node ID of tree node just activated in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node">activate_tree_node</a>()</code>.
* <code>parent</code>: Node ID of parent to actvation node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> when
activated node is root.
* <code>new_leaf_side</code>: None if activated node is root, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> if
activated node is left child of its parent, and <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code> if
activated node is right child of its parent.


<a name="@Testing_24"></a>

### Testing


* <code>test_activate_tree_node_update_parent_edge_left()</code>
* <code>test_activate_tree_node_update_parent_edge_right()</code>
* <code>test_activate_tree_node_update_parent_edge_root()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node_update_parent_edge">activate_tree_node_update_parent_edge</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, tree_node_id: u64, parent: u64, new_leaf_side: <a href="_Option">option::Option</a>&lt;bool&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_activate_tree_node_update_parent_edge">activate_tree_node_update_parent_edge</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    tree_node_id: u64,
    parent: u64,
    new_leaf_side: Option&lt;bool&gt;
) {
    <b>if</b> (<a href="_is_none">option::is_none</a>(&new_leaf_side)) { // If activating root:
        // Set root LSBs.
        avlq_ref_mut.root_lsbs = ((tree_node_id & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>) <b>as</b> u8);
        // Reassign bits for root MSBs:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u128)) |
            // Mask in new bits.
            ((tree_node_id <b>as</b> u128) &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>)
    } <b>else</b> { // If activating child <b>to</b> existing node:
        // Mutably borrow tree nodes <a href="">table</a>.
        <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
        // Mutably borrow parent.
        <b>let</b> parent_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, parent);
        // Determine <b>if</b> activating left child.
        <b>let</b> left_child = *<a href="_borrow">option::borrow</a>(&new_leaf_side) == <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a>;
        // Get child node ID field shift amounts for given side;
        <b>let</b> child_shift = <b>if</b> (left_child) <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a> <b>else</b>
            <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>;
        // Reassign bits for child field on given side.
        parent_ref_mut.bits = parent_ref_mut.bits &
            // Clear out all bits via mask unset at relevant bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; child_shift)) |
            // Mask in new bits.
            ((tree_node_id <b>as</b> u128) &lt;&lt; child_shift);
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_rotate_left"></a>

## Function `rotate_left`

Rotate left during rebalance.

Here, subtree root node x is right-heavy, with right child
node z that is not left-heavy. Node x has an optional tree 1
as its left child subtree, and node z has optional trees 2 and
3 as its left and right child subtrees, respectively.

Pre-rotation:

>        n_x
>       /   \
>     t_1   n_z
>          /   \
>        t_2   t_3

Post-rotation:

>           n_z
>          /   \
>        n_x   t_3
>       /   \
>     t_1   t_2


<a name="@Parameters_25"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree root post-rotation.
* <code>tree_2_id</code>: Node z's left child field.
* <code>node_z_height_left</code>: Node z's left height.


<a name="@Returns_26"></a>

### Returns


* <code>u64</code>: Node z's ID.
* <code>u8</code>: The height of the subtree rooted at node z,
post-rotation.


<a name="@Reference_rotations:_27"></a>

### Reference rotations:



<a name="@Case_1_28"></a>

#### Case 1


* Tree 2 empty.
* Post-rotation, node x height equals node x left height.
* Post-rotation, node z height equals node z right height.

Pre-rotation:

>     4 <- node x
>      \
>       6 <- node z
>        \
>         8 <- tree 3

Post-rotation:

>                 6 <- node z
>                / \
>     node x -> 4   8 <- tree 3


<a name="@Case_1_29"></a>

#### Case 1


* Tree 2 not empty.
* Post-rotation, node x height equals node x right height.
* Post-rotation, node z height equals node z left height.

Pre-rotation:

>               4 <- node x
>                \
>                 7 <- node z
>                / \
>     tree 2 -> 6   8 <- tree 3

Post-rotation:

>                 7 <- node z
>                / \
>     node x -> 4   8 <- tree 3
>                \
>                 6 <- tree 2


<a name="@Testing_30"></a>

### Testing


* <code>test_rotate_left_1()</code>
* <code>test_rotate_left_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_left">rotate_left</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, tree_2_id: u64, node_z_height_left: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_left">rotate_left</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64,
    node_z_id: u64,
    tree_2_id: u64,
    node_z_height_left: u8
): (
    u64,
    u8
) {
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    <b>if</b> (tree_2_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If tree 2 is not empty:
        <b>let</b> tree_2_ref_mut = // Mutably borrow tree 2 root.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, tree_2_id);
        // Reassign bits for new parent field:
        tree_2_ref_mut.bits = tree_2_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_x_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    };
    <b>let</b> node_x_ref_mut =  // Mutably borrow node x.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_x_id);
    <b>let</b> node_x_height_left = (((node_x_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128)) <b>as</b> u8); // Get node x left height.
    // Node x's right height is from transferred tree 2.
    <b>let</b> node_x_height_right = node_z_height_left;
    <b>let</b> node_x_parent = (((node_x_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u8); // Get node x parent field.
    // Reassign bits for right child, right height, and parent:
    node_x_ref_mut.bits = node_x_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((tree_2_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
        ((node_x_height_right <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
        ((node_z_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    // Determine height of tree rooted at x.
    <b>let</b> node_x_height = <b>if</b> (node_x_height_left &gt;= node_x_height_right)
        node_x_height_left <b>else</b> node_x_height_right;
    // Get node z left height.
    <b>let</b> node_z_height_left = node_x_height + 1;
    <b>let</b> node_z_ref_mut =  // Mutably borrow node z.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_z_id);
    // Reassign bits for left child, left height, and parent:
    node_z_ref_mut.bits = node_z_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((node_x_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
        ((node_z_height_left <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
        ((node_x_parent      <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    <b>let</b> node_z_height_right = (((node_z_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>)
        & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128)) <b>as</b> u8); // Get node z right height.
    // Determine height of tree rooted at z.
    <b>let</b> node_z_height = <b>if</b> (node_z_height_right &gt;= node_z_height_left)
        node_z_height_right <b>else</b> node_z_height_left;
    (node_z_id, node_z_height) // Return new subtree root, height.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_rotate_left_right"></a>

## Function `rotate_left_right`

Rotate left-right during rebalance.

Here, subtree root node x is left-heavy, with left child node
z that is right-heavy. Node z has as its right child node y.

Node z has an optional tree 1 as its left child subtree, node
y has optional trees 2 and 3 as its left and right child
subtrees, respectively, and node x has an optional tree 4 as its
right child subtree.

Double rotations result in a subtree root with a balance factor
of zero, such that node y is has the same left and right height
post-rotation.

Pre-rotation:

>           n_x
>          /   \
>        n_z   t_4
>       /   \
>     t_1   n_y
>          /   \
>        t_2   t_3

Post-rotation:

>              n_y
>          ___/   \___
>        n_z         n_x
>       /   \       /   \
>     t_1   t_2   t_3   t_4

* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree left child pre-rotation.
* <code>node_y_id</code>: Node ID of subtree root post-rotation.
* <code>node_z_height_left</code>: Node z's left height pre-rotation.


<a name="@Procedure_31"></a>

### Procedure


* Inspect node y's fields.
* Optionally update tree 2's parent field.
* Optionally update tree 3's parent field.
* Update node x's left child and parent fields.
* Update node z's right child and parent fields.
* Update node y's children and parent fields.


<a name="@Reference_rotations:_32"></a>

### Reference rotations:



<a name="@Case_1_33"></a>

#### Case 1


* Tree 2 null.
* Tree 3 not null.
* Node z right height not greater than or equal to left height
post-rotation.

Pre-rotation:

>                   8 <- node x
>                  / \
>       node z -> 2   9 <- tree 4
>                / \
>     tree 1 -> 1   6 <- node y
>                    \
>                     7 <- tree 3

Post-rotation:

>                   6 <- node y
>                  / \
>       node z -> 2   8 <- node x
>                /   / \
>     tree 1 -> 1   7   9 <- tree 4
>                   ^ tree 3


<a name="@Case_2_34"></a>

#### Case 2


* Tree 2 not null.
* Tree 3 null.
* Node z right height greater than or equal to left height
post-rotation.

Pre-rotation:

>                   8 <- node x
>                  / \
>       node z -> 2   9 <- tree 4
>                / \
>     tree 1 -> 1   6 <- node y
>                  /
>       tree 2 -> 5

>                   6 <- node y
>                  / \
>       node z -> 2   8 <- node x
>                / \   \
>     tree 1 -> 1   5   9 <- tree 4
>                   ^ tree 2


<a name="@Testing_35"></a>

### Testing


* <code>test_rotate_left_right_1()</code>
* <code>test_rotate_left_right_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_left_right">rotate_left_right</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, node_y_id: u64, node_z_height_left: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_left_right">rotate_left_right</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64,
    node_z_id: u64,
    node_y_id: u64,
    node_z_height_left: u8
): (
    u64,
    u8
) {
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    // Immutably borrow node y.
    <b>let</b> node_y_ref = <a href="_borrow">table_with_length::borrow</a>(nodes_ref_mut, node_y_id);
    <b>let</b> y_bits = node_y_ref.bits; // Get node y bits.
    // Get node y's left and right height, and tree 2 and 3 IDs.
    <b>let</b> (node_y_height_left, node_y_height_right, tree_2_id, tree_3_id) =
        ((((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128)) <b>as</b> u8),
         (((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128)) <b>as</b> u8),
         (((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>  ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64),
         (((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64));
    <b>if</b> (tree_2_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If tree 2 not null:
        <b>let</b> tree_2_ref_mut = // Mutably borrow tree 2 root.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, tree_2_id);
        // Reassign bits for new parent field:
        tree_2_ref_mut.bits = tree_2_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_z_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    };
    <b>if</b> (tree_3_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If tree 3 not null:
        <b>let</b> tree_3_ref_mut = // Mutably borrow tree 3 root.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, tree_3_id);
        // Reassign bits for new parent field:
        tree_3_ref_mut.bits = tree_3_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_x_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    };
    <b>let</b> node_x_ref_mut =  // Mutably borrow node x.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_x_id);
    // Node x's left height is from transferred tree 3.
    <b>let</b> node_x_height_left = node_y_height_right;
    <b>let</b> node_x_parent = (((node_x_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u8); // Store node x parent field.
    // Reassign bits for left child, left height, and parent:
    node_x_ref_mut.bits = node_x_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((tree_3_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
        ((node_x_height_left <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
        ((node_y_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    <b>let</b> node_z_ref_mut =  // Mutably borrow node z.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_z_id);
    // Node z's right height is from transferred tree 2.
    <b>let</b> node_z_height_right = node_y_height_left;
    // Reassign bits for right child, right height, and parent:
    node_z_ref_mut.bits = node_z_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((tree_2_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
        ((node_z_height_right <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
        ((node_y_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    // Determine height of tree rooted at z.
    <b>let</b> node_z_height = <b>if</b> (node_z_height_right &gt;= node_z_height_left)
        node_z_height_right <b>else</b> node_z_height_left;
    // Get node y's <b>post</b>-rotation height (same on left and right).
    <b>let</b> node_y_height = node_z_height + 1;
    <b>let</b> node_y_ref_mut = // Mutably borrow node y.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_y_id);
    // Reassign bits for both child edges, and parent.
    node_y_ref_mut.bits = node_y_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((node_z_id     <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
        ((node_x_id     <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
        ((node_y_height <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
        ((node_y_height <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
        ((node_x_parent <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    (node_y_id, node_y_height) // Return new subtree root, height.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_rotate_right"></a>

## Function `rotate_right`

Rotate right during rebalance.

Here, subtree root node x is left-heavy, with left child
node z that is not right-heavy. Node x has an optional tree 3
as its right child subtree, and node z has optional trees 1 and
2 as its left and right child subtrees, respectively.

Pre-rotation:

>           n_x
>          /   \
>        n_z   t_3
>       /   \
>     t_1   t_2

Post-rotation:

>        n_z
>       /   \
>     t_1   n_x
>          /   \
>        t_2   t_3


<a name="@Parameters_36"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree root post-rotation.
* <code>tree_2_id</code>: Node z's right child field.
* <code>node_z_height_right</code>: Node z's right height.


<a name="@Returns_37"></a>

### Returns


* <code>u64</code>: Node z's ID.
* <code>u8</code>: The height of the subtree rooted at node z,
post-rotation.


<a name="@Reference_rotations:_38"></a>

### Reference rotations:



<a name="@Case_1_39"></a>

#### Case 1


* Tree 2 empty.
* Post-rotation, node x height equals node x right height.
* Post-rotation, node z height equals node z left height.

Pre-rotation:

>         8 <- node x
>        /
>       6 <- node z
>      /
>     4 <- tree 1

Post-rotation:

>                 6 <- node z
>                / \
>     tree 1 -> 4   8 <- node x


<a name="@Case_1_40"></a>

#### Case 1


* Tree 2 not empty.
* Post-rotation, node x height equals node x left height.
* Post-rotation, node z height equals node z right height.

Pre-rotation:

>                   7 <- node x
>                  /
>                 4 <- node z
>                / \
>     tree 1 -> 3   5 <- tree 2

Post-rotation:

>                 4 <- node z
>                / \
>     tree 1 -> 3   7 <- node x
>                  /
>                 5 <- tree 2


<a name="@Testing_41"></a>

### Testing


* <code>test_rotate_right_1()</code>
* <code>test_rotate_right_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_right">rotate_right</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, tree_2_id: u64, node_z_height_right: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_right">rotate_right</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64,
    node_z_id: u64,
    tree_2_id: u64,
    node_z_height_right: u8
): (
    u64,
    u8
) {
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    <b>if</b> (tree_2_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If tree 2 is not empty:
        <b>let</b> tree_2_ref_mut = // Mutably borrow tree 2 root.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, tree_2_id);
        // Reassign bits for new parent field:
        tree_2_ref_mut.bits = tree_2_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_x_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    };
    <b>let</b> node_x_ref_mut =  // Mutably borrow node x.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_x_id);
    <b>let</b> node_x_height_right = (((node_x_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>)
        & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128)) <b>as</b> u8); // Get node x right height.
    // Node x's left height is from transferred tree 2.
    <b>let</b> node_x_height_left = node_z_height_right;
    <b>let</b> node_x_parent = (((node_x_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u8); // Get node x parent field.
    // Reassign bits for left child, left height, and parent:
    node_x_ref_mut.bits = node_x_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((tree_2_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
        ((node_x_height_left <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
        ((node_z_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    // Determine height of tree rooted at x.
    <b>let</b> node_x_height = <b>if</b> (node_x_height_right &gt;= node_x_height_left)
        node_x_height_right <b>else</b> node_x_height_left;
    // Get node z right height.
    <b>let</b> node_z_height_right = node_x_height + 1;
    <b>let</b> node_z_ref_mut =  // Mutably borrow node z.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_z_id);
    // Reassign bits for right child, right height, and parent:
    node_z_ref_mut.bits = node_z_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((node_x_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
        ((node_z_height_right <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
        ((node_x_parent       <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    <b>let</b> node_z_height_left = (((node_z_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128)) <b>as</b> u8); // Get node z left height.
    // Determine height of tree rooted at z.
    <b>let</b> node_z_height = <b>if</b> (node_z_height_left &gt;= node_z_height_right)
        node_z_height_left <b>else</b> node_z_height_right;
    (node_z_id, node_z_height) // Return new subtree root, height.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_rotate_right_left"></a>

## Function `rotate_right_left`

Rotate right-left during rebalance.

Here, subtree root node x is right-heavy, with right child node
z that is left-heavy. Node z has as its left child node y.

Node x has an optional tree 1 as its left child subtree, node
y has optional trees 2 and 3 as its left and right child
subtrees, respectively, and node z has an optional tree 4 as its
right child subtree.

Double rotations result in a subtree root with a balance factor
of zero, such that node y is has the same left and right height
post-rotation.

Pre-rotation:

>        n_x
>       /   \
>     t_1   n_z
>          /   \
>        n_y   t_4
>       /   \
>     t_2   t_3

Post-rotation:

>              n_y
>          ___/   \___
>        n_x         n_z
>       /   \       /   \
>     t_1   t_2   t_3   t_4


<a name="@Parameters_42"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree right child pre-rotation.
* <code>node_y_id</code>: Node ID of subtree root post-rotation.
* <code>node_z_height_right</code>: Node z's right height pre-rotation.


<a name="@Procedure_43"></a>

### Procedure


* Inspect node y's fields.
* Optionally update tree 2's parent field.
* Optionally update tree 3's parent field.
* Update node x's right child and parent fields.
* Update node z's left child and parent fields.
* Update node y's children and parent fields.


<a name="@Reference_rotations:_44"></a>

### Reference rotations:



<a name="@Case_1_45"></a>

#### Case 1


* Tree 2 not null.
* Tree 3 null.
* Node z left height not greater than or equal to right height
post-rotation.

Pre-rotation:

>                 2 <- node x
>                / \
>     tree 1 -> 1   8 <- node z
>                  / \
>       node y -> 4   9 <- tree 4
>                /
>               3 <- tree 2

Post-rotation:

>                 4 <- node y
>                / \
>     node x -> 2   8 <- node z
>              / \   \
>   tree 1 -> 1   3   9 <- tree 4
>                 ^ tree 2


<a name="@Case_2_46"></a>

#### Case 2


* Tree 2 null.
* Tree 3 not null.
* Node z left height greater than or equal to right height
post-rotation.

Pre-rotation:

>                 2 <- node x
>                / \
>     tree 1 -> 1   8 <- node z
>                  / \
>       node y -> 4   9 <- tree 4
>                  \
>                   5 <- tree 3

Post-rotation:

>                 4 <- node y
>                / \
>     node x -> 2   8 <- node z
>              /   / \
>   tree 1 -> 1   5   9 <- tree 4
>                 ^ tree 3


<a name="@Testing_47"></a>

### Testing


* <code>test_rotate_right_left_1()</code>
* <code>test_rotate_right_left_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_right_left">rotate_right_left</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, node_y_id: u64, node_z_height_right: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_rotate_right_left">rotate_right_left</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64,
    node_z_id: u64,
    node_y_id: u64,
    node_z_height_right: u8
): (
    u64,
    u8
) {
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    // Immutably borrow node y.
    <b>let</b> node_y_ref = <a href="_borrow">table_with_length::borrow</a>(nodes_ref_mut, node_y_id);
    <b>let</b> y_bits = node_y_ref.bits; // Get node y bits.
    // Get node y's left and right height, and tree 2 and 3 IDs.
    <b>let</b> (node_y_height_left, node_y_height_right, tree_2_id, tree_3_id) =
        ((((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128)) <b>as</b> u8),
         (((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128)) <b>as</b> u8),
         (((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>  ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64),
         (((y_bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64));
    <b>if</b> (tree_2_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If tree 2 not null:
        <b>let</b> tree_2_ref_mut = // Mutably borrow tree 2 root.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, tree_2_id);
        // Reassign bits for new parent field:
        tree_2_ref_mut.bits = tree_2_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_x_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    };
    <b>if</b> (tree_3_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If tree 3 not null:
        <b>let</b> tree_3_ref_mut = // Mutably borrow tree 3 root.
            <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, tree_3_id);
        // Reassign bits for new parent field:
        tree_3_ref_mut.bits = tree_3_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_z_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    };
    <b>let</b> node_x_ref_mut =  // Mutably borrow node x.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_x_id);
    // Node x's right height is from transferred tree 2.
    <b>let</b> node_x_height_right = node_y_height_left;
    <b>let</b> node_x_parent = (((node_x_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u8); // Store node x parent field.
    // Reassign bits for right child, right height, and parent:
    node_x_ref_mut.bits = node_x_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((tree_2_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
        ((node_x_height_right <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
        ((node_y_id           <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    <b>let</b> node_z_ref_mut =  // Mutably borrow node z.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_z_id);
    // Node z's left height is from transferred tree 3.
    <b>let</b> node_z_height_left = node_y_height_right;
    // Reassign bits for left child, left height, and parent:
    node_z_ref_mut.bits = node_z_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((tree_3_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
        ((node_z_height_left <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
        ((node_y_id          <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    // Determine height of tree rooted at z.
    <b>let</b> node_z_height = <b>if</b> (node_z_height_left &gt;= node_z_height_right)
        node_z_height_left <b>else</b> node_z_height_right;
    // Get node y's <b>post</b>-rotation height (same on left and right).
    <b>let</b> node_y_height = node_z_height + 1;
    <b>let</b> node_y_ref_mut = // Mutably borrow node y.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_y_id);
    // Reassign bits for both child edges, and parent.
    node_y_ref_mut.bits = node_y_ref_mut.bits &
        // Clear out fields via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
                   ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>))) |
        // Mask in new bits.
        ((node_x_id     <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) |
        ((node_z_id     <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) |
        ((node_y_height <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a>) |
        ((node_y_height <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) |
        ((node_x_parent <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    (node_y_id, node_y_height) // Return new subtree root, height.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_search"></a>

## Function `search`

Search in AVL queue for closest match to seed key.

Return immediately if empty tree, otherwise get node ID of root
node. Then start walking down nodes, branching left whenever the
seed key is less than a node's key, right whenever the seed
key is greater than a node's key, and returning when the seed
key equals a node's key. Also return if there is no child to
branch to on a given side.

The "match" node is the node last walked before returning.


<a name="@Parameters_48"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>seed_key</code>: Seed key to search for.


<a name="@Returns_49"></a>

### Returns


* <code>u64</code>: Node ID of match node.
* <code>Option&lt;bool&gt;</code>: None if match key equals seed key, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> if
seed key is less than match key but match node has no left
child, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code> if seed key is greater than match key but match
node has no right child.


<a name="@Assumptions_50"></a>

### Assumptions


* AVL queue is not empty, and <code>root_node_id</code> properly indicates
the root node.
* Seed key fits in 32 bits.


<a name="@Reference_diagram_51"></a>

### Reference diagram


>               4 <- ID 1
>              / \
>     ID 5 -> 2   8 <- ID 2
>                / \
>       ID 4 -> 6   10 <- ID 3

| Seed key | Match key | Node ID | Side  |
|----------|-----------|---------|-------|
| 2        | 2         | 5       | None  |
| 7        | 6         | 4       | Right |
| 9        | 10        | 3       | Left  |
| 4        | 4         | 1       | None  |


<a name="@Testing_52"></a>

### Testing


* <code>test_search()</code>.


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_search">search</a>&lt;V&gt;(avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, seed_key: u64): (u64, <a href="_Option">option::Option</a>&lt;bool&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_search">search</a>&lt;V&gt;(
    avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    seed_key: u64
): (
    u64,
    Option&lt;bool&gt;
) {
    <b>let</b> root_msbs = // Get root MSBs.
        (avlq_ref.bits & ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u128) <b>as</b> u64);
    <b>let</b> node_id = // Shift over, mask in LSBs, store <b>as</b> search node.
        (root_msbs &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) | (avlq_ref.root_lsbs <b>as</b> u64);
    // If no node at root, <b>return</b> <b>as</b> such, <b>with</b> empty <a href="">option</a>.
    <b>if</b> (node_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) <b>return</b> (node_id, <a href="_none">option::none</a>());
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref = &avlq_ref.tree_nodes;
    <b>loop</b> { // Begin walking down tree nodes:
        <b>let</b> node_ref = // Mutably borrow node having given ID.
            <a href="_borrow">table_with_length::borrow</a>(nodes_ref, node_id);
        // Get insertion key encoded in search node's bits.
        <b>let</b> node_key = (((node_ref.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY">SHIFT_INSERTION_KEY</a>) &
                         (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a> <b>as</b> u128)) <b>as</b> u64);
        // If search key equals seed key, <b>return</b> node's ID and
        // empty <a href="">option</a>.
        <b>if</b> (seed_key == node_key) <b>return</b> (node_id, <a href="_none">option::none</a>());
        // Get bitshift for child node ID and side based on
        // inequality comparison between seed key and node key.
        <b>let</b> (child_shift, child_side) = <b>if</b> (seed_key &lt; node_key)
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>, <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a>) <b>else</b> (<a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>, <a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a>);
        <b>let</b> child_id = (((node_ref.bits &gt;&gt; child_shift) &
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64); // Get child node ID.
        // If no child on given side, <b>return</b> match node's ID
        // and <a href="">option</a> <b>with</b> given side.
        <b>if</b> (child_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) <b>return</b>
            (node_id, <a href="_some">option::some</a>(child_side));
        // Otherwise <b>continue</b> walk at given child.
        node_id = child_id;
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_verify_node_count"></a>

## Function `verify_node_count`

Verify node count is not too high.


<a name="@Aborts_53"></a>

### Aborts


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a></code>: <code>n_nodes</code> is not less than <code><a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a></code>.


<a name="@Testing_54"></a>

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
