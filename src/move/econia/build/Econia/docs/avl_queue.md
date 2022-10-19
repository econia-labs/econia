
<a name="0xc0deb00c_avl_queue"></a>

# Module `0xc0deb00c::avl_queue`

AVL queue: a hybrid between an AVL tree and a queue.


<a name="@Node_IDs_0"></a>

## Node IDs


Tree nodes and list nodes are each assigned a 1-indexed 14-bit
serial ID known as a node ID. Node ID 0 is reserved for null, such
that the maximum number of allocated nodes for each node type is
thus $2^{14} - 1 = 16383$.


<a name="@Access_keys_1"></a>

## Access keys


| Bit(s) | Data                                         |
|--------|----------------------------------------------|
| 47-60  | Tree node ID                                 |
| 33-46  | List node ID                                 |
| 32     | If set, ascending AVL queue, else descending |
| 0-31   | Insertion key                                |


<a name="@Height_2"></a>

## Height


In the present implementation, left or right height denotes the
height of a node's left or right subtree, respectively, plus one.
Subtree height is adjusted by one to avoid negative numbers, with
the resultant value denoting the height of a tree rooted at the
given node, accounting only for height to the given side:

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


<a name="@References_3"></a>

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


<a name="@Complete_docgen_index_4"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [Node IDs](#@Node_IDs_0)
-  [Access keys](#@Access_keys_1)
-  [Height](#@Height_2)
-  [References](#@References_3)
-  [Complete docgen index](#@Complete_docgen_index_4)
-  [Struct `AVLqueue`](#0xc0deb00c_avl_queue_AVLqueue)
-  [Struct `TreeNode`](#0xc0deb00c_avl_queue_TreeNode)
-  [Struct `ListNode`](#0xc0deb00c_avl_queue_ListNode)
-  [Constants](#@Constants_5)
-  [Function `get_access_key_insertion_key`](#0xc0deb00c_avl_queue_get_access_key_insertion_key)
    -  [Testing](#@Testing_6)
-  [Function `insert`](#0xc0deb00c_avl_queue_insert)
    -  [Parameters](#@Parameters_7)
    -  [Returns](#@Returns_8)
    -  [Aborts](#@Aborts_9)
    -  [Failure testing](#@Failure_testing_10)
    -  [State verification testing](#@State_verification_testing_11)
-  [Function `new`](#0xc0deb00c_avl_queue_new)
    -  [Parameters](#@Parameters_12)
    -  [Returns](#@Returns_13)
    -  [Testing](#@Testing_14)
-  [Function `is_ascending`](#0xc0deb00c_avl_queue_is_ascending)
    -  [Testing](#@Testing_15)
-  [Function `insert_check_head_tail`](#0xc0deb00c_avl_queue_insert_check_head_tail)
    -  [Parameters](#@Parameters_16)
    -  [Testing](#@Testing_17)
-  [Function `insert_list_node`](#0xc0deb00c_avl_queue_insert_list_node)
    -  [Parameters](#@Parameters_18)
    -  [Returns](#@Returns_19)
    -  [Testing](#@Testing_20)
-  [Function `insert_list_node_assign_fields`](#0xc0deb00c_avl_queue_insert_list_node_assign_fields)
    -  [Parameters](#@Parameters_21)
    -  [Returns](#@Returns_22)
    -  [Testing](#@Testing_23)
-  [Function `insert_list_node_get_last_next`](#0xc0deb00c_avl_queue_insert_list_node_get_last_next)
    -  [Parameters](#@Parameters_24)
    -  [Returns](#@Returns_25)
    -  [Testing](#@Testing_26)
-  [Function `insert_tree_node`](#0xc0deb00c_avl_queue_insert_tree_node)
    -  [Parameters](#@Parameters_27)
    -  [Returns](#@Returns_28)
    -  [Assumptions](#@Assumptions_29)
    -  [Testing](#@Testing_30)
-  [Function `insert_tree_node_update_parent_edge`](#0xc0deb00c_avl_queue_insert_tree_node_update_parent_edge)
    -  [Parameters](#@Parameters_31)
    -  [Testing](#@Testing_32)
-  [Function `remove_list_node`](#0xc0deb00c_avl_queue_remove_list_node)
    -  [Parameters](#@Parameters_33)
    -  [Returns](#@Returns_34)
    -  [Testing](#@Testing_35)
-  [Function `remove_list_node_update_edges`](#0xc0deb00c_avl_queue_remove_list_node_update_edges)
    -  [Parameters](#@Parameters_36)
    -  [Returns](#@Returns_37)
    -  [Testing](#@Testing_38)
-  [Function `remove_tree_node`](#0xc0deb00c_avl_queue_remove_tree_node)
    -  [Parameters](#@Parameters_39)
    -  [Case 1](#@Case_1_40)
    -  [Case 2](#@Case_2_41)
        -  [Left child](#@Left_child_42)
        -  [Right child](#@Right_child_43)
    -  [Case 3](#@Case_3_44)
-  [Function `remove_tree_node_follow_up`](#0xc0deb00c_avl_queue_remove_tree_node_follow_up)
    -  [Parameters](#@Parameters_45)
-  [Function `remove_tree_node_with_children`](#0xc0deb00c_avl_queue_remove_tree_node_with_children)
    -  [Parameters](#@Parameters_46)
    -  [Returns](#@Returns_47)
    -  [Predecessor is not immediate child](#@Predecessor_is_not_immediate_child_48)
-  [Function `retrace`](#0xc0deb00c_avl_queue_retrace)
    -  [Parameters](#@Parameters_49)
    -  [Testing](#@Testing_50)
        -  [Reference diagram](#@Reference_diagram_51)
-  [Function `retrace_prep_iterate`](#0xc0deb00c_avl_queue_retrace_prep_iterate)
    -  [Parameters](#@Parameters_52)
    -  [Returns](#@Returns_53)
    -  [Testing](#@Testing_54)
-  [Function `retrace_rebalance`](#0xc0deb00c_avl_queue_retrace_rebalance)
    -  [Parameters](#@Parameters_55)
    -  [Returns](#@Returns_56)
    -  [Node x status](#@Node_x_status_57)
        -  [Node x left-heavy](#@Node_x_left-heavy_58)
        -  [Node x right-heavy](#@Node_x_right-heavy_59)
    -  [Testing](#@Testing_60)
-  [Function `retrace_rebalance_rotate_left`](#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left)
    -  [Parameters](#@Parameters_61)
    -  [Returns](#@Returns_62)
    -  [Reference rotations](#@Reference_rotations_63)
        -  [Case 1](#@Case_1_64)
        -  [Case 2](#@Case_2_65)
    -  [Testing](#@Testing_66)
-  [Function `retrace_rebalance_rotate_left_right`](#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left_right)
    -  [Procedure](#@Procedure_67)
    -  [Reference rotations](#@Reference_rotations_68)
        -  [Case 1](#@Case_1_69)
        -  [Case 2](#@Case_2_70)
    -  [Testing](#@Testing_71)
-  [Function `retrace_rebalance_rotate_right`](#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right)
    -  [Parameters](#@Parameters_72)
    -  [Returns](#@Returns_73)
    -  [Reference rotations](#@Reference_rotations_74)
        -  [Case 1](#@Case_1_75)
        -  [Case 2](#@Case_2_76)
    -  [Testing](#@Testing_77)
-  [Function `retrace_rebalance_rotate_right_left`](#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right_left)
    -  [Parameters](#@Parameters_78)
    -  [Procedure](#@Procedure_79)
    -  [Reference rotations](#@Reference_rotations_80)
        -  [Case 1](#@Case_1_81)
        -  [Case 2](#@Case_2_82)
    -  [Testing](#@Testing_83)
-  [Function `retrace_update_heights`](#0xc0deb00c_avl_queue_retrace_update_heights)
    -  [Parameters](#@Parameters_84)
    -  [Returns](#@Returns_85)
    -  [Testing](#@Testing_86)
-  [Function `search`](#0xc0deb00c_avl_queue_search)
    -  [Parameters](#@Parameters_87)
    -  [Returns](#@Returns_88)
    -  [Assumptions](#@Assumptions_89)
    -  [Reference diagram](#@Reference_diagram_90)
    -  [Testing](#@Testing_91)
-  [Function `traverse`](#0xc0deb00c_avl_queue_traverse)
    -  [Parameters](#@Parameters_92)
    -  [Conventions](#@Conventions_93)
    -  [Returns](#@Returns_94)
    -  [Membership considerations](#@Membership_considerations_95)
    -  [Predecessor](#@Predecessor_96)
    -  [Successor](#@Successor_97)
    -  [Reference diagram](#@Reference_diagram_98)
    -  [Testing](#@Testing_99)
-  [Function `verify_node_count`](#0xc0deb00c_avl_queue_verify_node_count)
    -  [Aborts](#@Aborts_100)
    -  [Testing](#@Testing_101)


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
| 89-93  | Left height                          |
| 84-88  | Right height                         |
| 70-83  | Parent node ID                       |
| 56-69  | Left child node ID                   |
| 42-55  | Right child node ID                  |
| 28-41  | List head node ID                    |
| 14-27  | List tail node ID                    |
| 0-13   | Next inactive node ID, when in stack |

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



<a name="0xc0deb00c_avl_queue_DECREMENT"></a>

Flag for decrement to height during retrace.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_DESCENDING"></a>

Descending AVL queue flag.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_DESCENDING">DESCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_E_INSERTION_KEY_TOO_LARGE"></a>

Insertion key is too large.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_E_INSERTION_KEY_TOO_LARGE">E_INSERTION_KEY_TOO_LARGE</a>: u64 = 1;
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



<a name="0xc0deb00c_avl_queue_HI_BIT"></a>

Single bit set in integer of width required to encode bit flag.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BIT">HI_BIT</a>: u8 = 1;
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



<a name="0xc0deb00c_avl_queue_INCREMENT"></a>

Flag for increment to height during retrace.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a>: bool = <b>true</b>;
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



<a name="0xc0deb00c_avl_queue_PREDECESSOR"></a>

Flag for inorder predecessor traversal.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_PREDECESSOR">PREDECESSOR</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_RIGHT"></a>

Flag for right direction.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_ACCESS_LIST_NODE_ID"></a>

Number of bits list node ID is shifted in an access key.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_ACCESS_LIST_NODE_ID">SHIFT_ACCESS_LIST_NODE_ID</a>: u8 = 33;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_ACCESS_SORT_ORDER"></a>

Number of bits sort order bit flag is shifted in an access key.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_ACCESS_SORT_ORDER">SHIFT_ACCESS_SORT_ORDER</a>: u8 = 32;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_ACCESS_TREE_NODE_ID"></a>

Number of bits tree node ID is shifted in an access key.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_ACCESS_TREE_NODE_ID">SHIFT_ACCESS_TREE_NODE_ID</a>: u8 = 47;
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



<a name="0xc0deb00c_avl_queue_SHIFT_HEAD_KEY"></a>

Number of bits AVL queue head insertion key is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_KEY">SHIFT_HEAD_KEY</a>: u8 = 52;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_HEAD_NODE_ID"></a>

Number of bits AVL queue head list node ID is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_NODE_ID">SHIFT_HEAD_NODE_ID</a>: u8 = 84;
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



<a name="0xc0deb00c_avl_queue_SHIFT_TAIL_KEY"></a>

Number of bits AVL queue tail insertion key is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_KEY">SHIFT_TAIL_KEY</a>: u8 = 6;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_TAIL_NODE_ID"></a>

Number of bits AVL queue tail list node ID is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_NODE_ID">SHIFT_TAIL_NODE_ID</a>: u8 = 38;
</code></pre>



<a name="0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP"></a>

Number of bits inactive tree node stack top is shifted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>.bits</code>.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>: u8 = 112;
</code></pre>



<a name="0xc0deb00c_avl_queue_SUCCESSOR"></a>

Flag for inorder successor traversal.


<pre><code><b>const</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SUCCESSOR">SUCCESSOR</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_avl_queue_get_access_key_insertion_key"></a>

## Function `get_access_key_insertion_key`

Get insertion key encoded in an access key.


<a name="@Testing_6"></a>

### Testing


* <code>test_access_key_getters()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_get_access_key_insertion_key">get_access_key_insertion_key</a>(access_key: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_get_access_key_insertion_key">get_access_key_insertion_key</a>(
    access_key: u64
): u64 {
    access_key & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_insert"></a>

## Function `insert`

Insert a key-value pair into an AVL queue.


<a name="@Parameters_7"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>key</code>: Key to insert.
* <code>value</code>: Value to insert.


<a name="@Returns_8"></a>

### Returns


* <code>u64</code>: Access key used for lookup.


<a name="@Aborts_9"></a>

### Aborts


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_E_INSERTION_KEY_TOO_LARGE">E_INSERTION_KEY_TOO_LARGE</a></code>: Insertion key is too large.


<a name="@Failure_testing_10"></a>

### Failure testing


* <code>test_insert_insertion_key_too_large()</code>
* <code>test_insert_too_many_list_nodes()</code>
* <code>test_insert_too_many_tree_nodes()</code>


<a name="@State_verification_testing_11"></a>

### State verification testing


See <code>test_insert()</code> for state verification testing of the
below insertion sequence.

Insert $\langle 3, 9 \rangle$:

>      3
>     [9]

Insert $\langle 4, 8 \rangle$:

>      3
>     [9]
>        \
>         4
>        [8]

Insert $\langle 5, 7 \rangle$:

>         4
>        [8]
>       /   \
>      3     5
>     [9]   [7]

Insert $\langle 3, 6 \rangle$

>               4
>              [8]
>             /   \
>            3     5
>     [9 -> 6]    [7]

Insert $\langle 5, 5 \rangle$

>               4
>              [8]
>             /   \
>            3     5
>     [9 -> 6]     [7 -> 5]


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert">insert</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, key: u64, value: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert">insert</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    key: u64,
    value: V
): u64 {
    // Assert insertion key is not too many bits.
    <b>assert</b>!(key &lt;= <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a>, <a href="avl_queue.md#0xc0deb00c_avl_queue_E_INSERTION_KEY_TOO_LARGE">E_INSERTION_KEY_TOO_LARGE</a>);
    // Search for key, storing match node ID, and optional side on
    // which a new leaf would be inserted relative <b>to</b> match node.
    <b>let</b> (match_node_id, new_leaf_side) = <a href="avl_queue.md#0xc0deb00c_avl_queue_search">search</a>(avlq_ref_mut, key);
    // If search returned null from the root, or <b>if</b> search flagged
    // that a new tree node will have <b>to</b> be inserted <b>as</b> child, flag
    // that the inserted list node will be the sole node in the
    // corresponding doubly linked list.
    <b>let</b> solo = match_node_id == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64) ||
               <a href="_is_some">option::is_some</a>(&new_leaf_side);
    // If a solo list node, flag no anchor tree node yet inserted,
    // otherwise set anchor tree node <b>as</b> match node from search.
    <b>let</b> anchor_tree_node_id = <b>if</b> (solo) (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64) <b>else</b> match_node_id;
    <b>let</b> list_node_id = // Insert list node, storing its node ID.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node">insert_list_node</a>(avlq_ref_mut, anchor_tree_node_id, value);
    // Get corresponding tree node: <b>if</b> solo list node, insert a tree
    // node and store its ID. Otherwise tree node is match node from
    // search.
    <b>let</b> tree_node_id = <b>if</b> (solo) <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node">insert_tree_node</a>(
        avlq_ref_mut, key, match_node_id, list_node_id, new_leaf_side) <b>else</b>
        match_node_id;
    // If just inserted new tree node that is not root, retrace
    // starting at the parent <b>to</b> the inserted tree node.
    <b>if</b> (solo && (match_node_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)))
        <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>(avlq_ref_mut, match_node_id, <a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a>,
                *<a href="_borrow">option::borrow</a>(&new_leaf_side));
    // Check AVL queue head and tail.
    <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_check_head_tail">insert_check_head_tail</a>(avlq_ref_mut, key, list_node_id);
    <b>let</b> order_bit = // Get sort order bit from AVL queue bits.
        (avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BIT">HI_BIT</a> <b>as</b> u128);
    // Return bit-packed access key.
    key | ((order_bit <b>as</b> u64) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_ACCESS_SORT_ORDER">SHIFT_ACCESS_SORT_ORDER</a>) |
          ((list_node_id    ) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_ACCESS_LIST_NODE_ID">SHIFT_ACCESS_LIST_NODE_ID</a>) |
          ((tree_node_id    ) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_ACCESS_TREE_NODE_ID">SHIFT_ACCESS_TREE_NODE_ID</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_new"></a>

## Function `new`

Return a new AVL queue, optionally allocating inactive nodes.


<a name="@Parameters_12"></a>

### Parameters


* <code>sort_order</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_ASCENDING">ASCENDING</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DESCENDING">DESCENDING</a></code>.
* <code>n_inactive_tree_nodes</code>: The number of inactive tree nodes
to allocate.
* <code>n_inactive_list_nodes</code>: The number of inactive list nodes
to allocate.


<a name="@Returns_13"></a>

### Returns


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;</code>: A new AVL queue.


<a name="@Testing_14"></a>

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


<a name="@Testing_15"></a>

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

<a name="0xc0deb00c_avl_queue_insert_check_head_tail"></a>

## Function `insert_check_head_tail`

Check head and tail of AVL queue during insertion.

Update fields as needed based on sort order.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert">insert</a>()</code>.


<a name="@Parameters_16"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>key</code>: Insertion key just inserted.
* <code>list_node_id</code>: ID of list node just inserted.


<a name="@Testing_17"></a>

### Testing


* <code>test_insert_check_head_tail_ascending()</code>
* <code>test_insert_check_head_tail_descending()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_check_head_tail">insert_check_head_tail</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, key: u64, list_node_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_check_head_tail">insert_check_head_tail</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    key: u64,
    list_node_id: u64
) {
    <b>let</b> bits = avlq_ref_mut.bits; // Get AVL queue field bits.
    // Extract relevant fields.
    <b>let</b> (order_bit, head_key, tail_key) =
        (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_SORT_ORDER">SHIFT_SORT_ORDER</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BIT">HI_BIT</a> <b>as</b> u128) <b>as</b> u8),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_KEY">SHIFT_HEAD_KEY</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a>  <b>as</b> u128) <b>as</b> u64),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_KEY">SHIFT_TAIL_KEY</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a>  <b>as</b> u128) <b>as</b> u64));
    // Determine <b>if</b> AVL queue is ascending.
    <b>let</b> ascending = order_bit == <a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_ASCENDING">BIT_FLAG_ASCENDING</a>;
    <b>if</b> ((head_key == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) || // If no head key,
        // If ascending AVL queue and insertion key less than head
        // key,
        (ascending && key &lt; head_key) || // If
        // Or <b>if</b> descending AVL queue and insertion key greater than
        // head key,
        (!ascending && key &gt; head_key))
        // Reassign bits for head key and node ID:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_KEY">SHIFT_HEAD_KEY</a>) |
                       ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_NODE_ID">SHIFT_HEAD_NODE_ID</a>))) |
            // Mask in new bits.
            ((list_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_NODE_ID">SHIFT_HEAD_NODE_ID</a>) |
            ((key <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEAD_KEY">SHIFT_HEAD_KEY</a>);
    <b>if</b> ((tail_key == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) || // If no tail key,
        // If ascending AVL queue and insertion key greater than or
        // equal <b>to</b> tail key,
        (ascending && key &gt;= tail_key) || // If
        // Or <b>if</b> descending AVL queue and insertion key less than or
        // equal <b>to</b> tail key:
        (!ascending && key &lt;= tail_key))
        // Reassign bits for tail key and node ID:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ (((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_KEY">SHIFT_TAIL_KEY</a>) |
                       ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_NODE_ID">SHIFT_TAIL_NODE_ID</a>))) |
            // Mask in new bits.
            ((list_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_NODE_ID">SHIFT_TAIL_NODE_ID</a>) |
            ((key <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TAIL_KEY">SHIFT_TAIL_KEY</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_insert_list_node"></a>

## Function `insert_list_node`

Insert a list node and return its node ID.

In the case of inserting a list node to a doubly linked list in
an existing tree node, known as the "anchor tree node", the list
node becomes the new list tail.

In the other case of inserting a "solo node" as the sole list
node in a doubly linked list in a new tree leaf, the list node
becomes the head and tail of the new list.


<a name="@Parameters_18"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>anchor_tree_node_id</code>: Node ID of anchor tree node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if
inserting a list node as the sole list node in a new tree
node.
* <code>value</code>: Insertion value for list node to insert.


<a name="@Returns_19"></a>

### Returns


* <code>u64</code>: Node ID of inserted list node.


<a name="@Testing_20"></a>

### Testing


* <code>test_insert_list_node_not_solo()</code>
* <code>test_insert_list_node_solo()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node">insert_list_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, anchor_tree_node_id: u64, value: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node">insert_list_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    anchor_tree_node_id: u64,
    value: V
): u64 {
    <b>let</b> (last, next) = // Get virtual last and next fields for node.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>(avlq_ref_mut, anchor_tree_node_id);
    <b>let</b> list_node_id = // Assign fields, store inserted node ID.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_assign_fields">insert_list_node_assign_fields</a>(avlq_ref_mut, last, next, value);
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
        // Reassign its next LSBs <b>to</b> those of inserted list node.
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
    list_node_id // Return inserted list node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_insert_list_node_assign_fields"></a>

## Function `insert_list_node_assign_fields`

Assign fields when inserting a list node.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node">insert_list_node</a>()</code>.

If inactive list node stack is empty, allocate a new list node,
otherwise pop one off the inactive stack.


<a name="@Parameters_21"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>last</code>: Virtual last field from
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>()</code>.
* <code>next</code>: Virtual next field from
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>()</code>.
* <code>value</code>: Insertion value.


<a name="@Returns_22"></a>

### Returns


* <code>u64</code>: Node ID of inserted list node.


<a name="@Testing_23"></a>

### Testing


* <code>test_insert_list_node_assign_fields_allocate()</code>
* <code>test_insert_list_node_assign_fields_stacked()</code>
* <code>test_insert_too_many_list_nodes()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_assign_fields">insert_list_node_assign_fields</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, last: u64, next: u64, value: V): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_assign_fields">insert_list_node_assign_fields</a>&lt;V&gt;(
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

<a name="0xc0deb00c_avl_queue_insert_list_node_get_last_next"></a>

## Function `insert_list_node_get_last_next`

Get virtual last and next fields when inserting a list node.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node">insert_list_node</a>()</code>.

If inserted list node will be the only list node in a doubly
linked list, a "solo list node", then it will have to indicate
for next and last node IDs a new tree node, which will also have
to be inserted via <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node">insert_tree_node</a>()</code>. Hence error checking
for the number of allocated tree nodes is performed here first,
and is not re-performed in <code>inserted_tree_node()</code> for the case
of a solo list node.


<a name="@Parameters_24"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>anchor_tree_node_id</code>: Node ID of anchor tree node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if
inserting a solo list node.


<a name="@Returns_25"></a>

### Returns


* <code>u64</code>: Virtual last field of inserted list node.
* <code>u64</code>: Virtual next field of inserted list node.


<a name="@Testing_26"></a>

### Testing


* <code>test_insert_list_node_get_last_next_new_tail()</code>
* <code>test_insert_list_node_get_last_next_solo_allocate()</code>
* <code>test_insert_list_node_get_last_next_solo_stacked()</code>
* <code>test_insert_too_many_tree_nodes()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>&lt;V&gt;(avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, anchor_tree_node_id: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>&lt;V&gt;(
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
    <b>let</b> last; // Declare virtual last field for inserted list node.
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

<a name="0xc0deb00c_avl_queue_insert_tree_node"></a>

## Function `insert_tree_node`

Insert a tree node and return its node ID.

If inactive tree node stack is empty, allocate a new tree node,
otherwise pop one off the inactive stack.

Should only be called when <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node">insert_list_node</a>()</code> inserts the
sole list node in new AVL tree node, thus checking the number
of allocated tree nodes in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>()</code>.


<a name="@Parameters_27"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>key</code>: Insertion key for inserted node.
* <code>parent</code>: Node ID of parent to inserted node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> when
inserted node is to become root.
* <code>solo_node_id</code>: Node ID of sole list node in tree node's
doubly linked list.
* <code>new_leaf_side</code>: None if inserted node is root, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> if
inserted node is left child of its parent, and <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code> if
inserted node is right child of its parent.


<a name="@Returns_28"></a>

### Returns


* <code>u64</code>: Node ID of inserted tree node.


<a name="@Assumptions_29"></a>

### Assumptions


* Node is a leaf in the AVL tree and has a single list node in
its doubly linked list.
* The number of allocated tree nodes has already been checked
via <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_list_node_get_last_next">insert_list_node_get_last_next</a>()</code>.
* All <code>u64</code> fields correspond to valid node IDs.


<a name="@Testing_30"></a>

### Testing


* <code>test_insert_tree_node_empty()</code>
* <code>test_insert_tree_node_stacked()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node">insert_tree_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, key: u64, parent: u64, solo_node_id: u64, new_leaf_side: <a href="_Option">option::Option</a>&lt;bool&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node">insert_tree_node</a>&lt;V&gt;(
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
        node_ref_mut.bits = bits; // Reassign inserted node bits.
    };
    <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node_update_parent_edge">insert_tree_node_update_parent_edge</a>( // Update parent edge.
        avlq_ref_mut, tree_node_id, parent, new_leaf_side);
    tree_node_id // Return inserted tree node ID.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_insert_tree_node_update_parent_edge"></a>

## Function `insert_tree_node_update_parent_edge`

Update the parent edge for a tree node just inserted.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node">insert_tree_node</a>()</code>.


<a name="@Parameters_31"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>tree_node_id</code>: Node ID of tree node just inserted in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node">insert_tree_node</a>()</code>.
* <code>parent</code>: Node ID of parent to inserted node, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> when
inserted node is root.
* <code>new_leaf_side</code>: None if inserted node is root, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> if
inserted node is left child of its parent, and <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code> if
inserted node is right child of its parent.


<a name="@Testing_32"></a>

### Testing


* <code>test_insert_tree_node_update_parent_edge_left()</code>
* <code>test_insert_tree_node_update_parent_edge_right()</code>
* <code>test_insert_tree_node_update_parent_edge_root()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node_update_parent_edge">insert_tree_node_update_parent_edge</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, tree_node_id: u64, parent: u64, new_leaf_side: <a href="_Option">option::Option</a>&lt;bool&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_insert_tree_node_update_parent_edge">insert_tree_node_update_parent_edge</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    tree_node_id: u64,
    parent: u64,
    new_leaf_side: Option&lt;bool&gt;
) {
    <b>if</b> (<a href="_is_none">option::is_none</a>(&new_leaf_side)) { // If inserting root:
        // Reassign bits for root MSBs:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u128)) |
            // Mask in new bits.
            ((tree_node_id <b>as</b> u128) &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>);
        // Set root LSBs.
        avlq_ref_mut.root_lsbs = ((tree_node_id & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a>) <b>as</b> u8);
    } <b>else</b> { // If inserting child <b>to</b> existing node:
        // Mutably borrow tree nodes <a href="">table</a>.
        <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
        // Mutably borrow parent.
        <b>let</b> parent_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, parent);
        // Determine <b>if</b> inserting left child.
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

<a name="0xc0deb00c_avl_queue_remove_list_node"></a>

## Function `remove_list_node`

Remove list node for given access key, return insertion value.

Inner function for <code>remove()</code>.

Updates last and next nodes in doubly linked list, optionally
updating head or tail field in corresponding tree node if list
node was head or tail of doubly linked list. Does not modify
corresponding tree node if list node was sole node in doubly
linked list.

Pushes inactive list node onto inactive list nodes stack.


<a name="@Parameters_33"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>list_node_id</code>: List node ID of node to remove.


<a name="@Returns_34"></a>

### Returns


* <code>V</code>: Corresponding insertion value.
* <code>Option&lt;u64&gt;</code>: New list head node ID, if any, with <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>
indicating that corresponding doubly linked list has been
cleared out.
* <code>Option&lt;u64&gt;</code>: New list tail node ID, if any, with <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>
indicating that corresponding doubly linked list has been
cleared out.


<a name="@Testing_35"></a>

### Testing


* <code>test_remove_list_node()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_list_node">remove_list_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, list_node_id: u64): (V, <a href="_Option">option::Option</a>&lt;u64&gt;, <a href="_Option">option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_list_node">remove_list_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    list_node_id: u64
): (
    V,
    Option&lt;u64&gt;,
    Option&lt;u64&gt;
) {
    // Mutably borrow list nodes <a href="">table</a>.
    <b>let</b> list_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.list_nodes;
    <b>let</b> list_node_ref_mut = // Mutably borrow list node.
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(list_nodes_ref_mut, list_node_id);
    // Get virtual last field.
    <b>let</b> last = ((list_node_ref_mut.last_msbs <b>as</b> u64) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) |
                (list_node_ref_mut.last_lsbs <b>as</b> u64);
    // Get virtual next field.
    <b>let</b> next = ((list_node_ref_mut.next_msbs <b>as</b> u64) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) |
                (list_node_ref_mut.next_lsbs <b>as</b> u64);
    // Determine <b>if</b> last node is flagged <b>as</b> tree node.
    <b>let</b> last_is_tree = ((last &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_NODE_TYPE">SHIFT_NODE_TYPE</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a> <b>as</b> u64)) == (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a> <b>as</b> u64);
    // Determine <b>if</b> next node is flagged <b>as</b> tree node.
    <b>let</b> next_is_tree = ((next &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_NODE_TYPE">SHIFT_NODE_TYPE</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a> <b>as</b> u64)) == (<a href="avl_queue.md#0xc0deb00c_avl_queue_BIT_FLAG_TREE_NODE">BIT_FLAG_TREE_NODE</a> <b>as</b> u64);
    <b>let</b> last_node_id = last & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a>; // Get last node ID.
    <b>let</b> next_node_id = next & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a>; // Get next node ID.
    // Get inactive list nodes stack top.
    <b>let</b> list_top = (((avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
    list_node_ref_mut.last_msbs = 0; // Clear node's last MSBs.
    list_node_ref_mut.last_lsbs = 0; // Clear node's last LSBs.
    // Set node's next MSBs <b>to</b> those of inactive stack top.
    list_node_ref_mut.next_msbs = ((list_top &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8);
    // Set node's next LSBs <b>to</b> those of inactive stack top.
    list_node_ref_mut.next_lsbs = ((list_top & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u64)) <b>as</b> u8);
    // Reassign bits for inactive list node stack top:
    avlq_ref_mut.bits = avlq_ref_mut.bits &
        // Clear out field via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>)) |
        // Mask in new bits.
        ((list_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>);
    // Update node edges, storing optional new head and tail.
    <b>let</b> (new_head, new_tail) = <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_list_node_update_edges">remove_list_node_update_edges</a>(
        avlq_ref_mut, last, next, last_is_tree, next_is_tree, last_node_id,
        next_node_id);
    // Mutably borrow insertion values <a href="">table</a>.
    <b>let</b> values_ref_mut = &<b>mut</b> avlq_ref_mut.values;
    <b>let</b> value = <a href="_extract">option::extract</a>( // Extract insertion value.
        <a href="_borrow_mut">table::borrow_mut</a>(values_ref_mut, list_node_id));
    // Return insertion value, optional new head, optional new tail.
    (value, new_head, new_tail)
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_remove_list_node_update_edges"></a>

## Function `remove_list_node_update_edges`

Update node edges when removing a list node.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_remove_list_node">remove_list_node</a>()</code>.

Update last and next edges relative to removed list node,
returning optional new list head and tail list node IDs. If
removed list node was sole node in doubly linked list, does not
modify corresponding tree node.


<a name="@Parameters_36"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>last</code>: Virtual last field from removed list node.
* <code>next</code>: Virtual next field from removed list node.
* <code>last_is_tree</code>: <code><b>true</b></code> if last node is flagged as tree node.
* <code>next_is_tree</code>: <code><b>true</b></code> if next node is flagged as tree node.
* <code>last_node_id</code>: Node ID of last node.
* <code>next_node_id</code>: Node ID of next node.


<a name="@Returns_37"></a>

### Returns


* <code>Option&lt;u64&gt;</code>: New list head node ID, if any, with <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>
indicating that corresponding doubly linked list has been
cleared out.
* <code>Option&lt;u64&gt;</code>: New list tail node ID, if any, with <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>
indicating that corresponding doubly linked list has been
cleared out.


<a name="@Testing_38"></a>

### Testing


* <code>test_remove_list_node()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_list_node_update_edges">remove_list_node_update_edges</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, last: u64, next: u64, last_is_tree: bool, next_is_tree: bool, last_node_id: u64, next_node_id: u64): (<a href="_Option">option::Option</a>&lt;u64&gt;, <a href="_Option">option::Option</a>&lt;u64&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_list_node_update_edges">remove_list_node_update_edges</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    last: u64,
    next: u64,
    last_is_tree: bool,
    next_is_tree: bool,
    last_node_id: u64,
    next_node_id: u64
): (
    Option&lt;u64&gt;,
    Option&lt;u64&gt;
) {
    // If node was sole list node in doubly linked list, <b>return</b> that
    // the doubly linked list <b>has</b> been cleared out.
    <b>if</b> (last_is_tree && next_is_tree) <b>return</b>
        (<a href="_some">option::some</a>((<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)), <a href="_some">option::some</a>((<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)));
    // Otherwise, <b>assume</b> no new list head or tail.
    <b>let</b> (new_head, new_tail) = (<a href="_none">option::none</a>(), <a href="_none">option::none</a>());
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> tree_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    // Mutably borrow list nodes <a href="">table</a>.
    <b>let</b> list_nodes_ref_mut = &<b>mut</b> avlq_ref_mut.list_nodes;
    <b>if</b> (last_is_tree) { // If removed node was list head:
        // Mutably borrow corresponding tree node.
        <b>let</b> tree_node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, last_node_id);
        // Reassign bits for list head <b>to</b> next node ID:
        tree_node_ref_mut.bits = tree_node_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a>)) |
            // Mask in new bits.
            ((next_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a>);
        new_head = <a href="_some">option::some</a>(next_node_id); // Flag new head.
    } <b>else</b> { // If node was not list head:
        // Mutably borrow last list node.
        <b>let</b> list_node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            list_nodes_ref_mut, last_node_id);
        // Set node's next MSBs <b>to</b> those of virtual next field.
        list_node_ref_mut.next_msbs = ((next &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8);
        // Set node's next LSBs <b>to</b> those of virtual next field.
        list_node_ref_mut.next_lsbs = ((next & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u64)) <b>as</b> u8);
    };
    <b>if</b> (next_is_tree) { // If removed node was list tail:
        // Mutably borrow corresponding tree node.
        <b>let</b> tree_node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            tree_nodes_ref_mut, next_node_id);
        // Reassign bits for list tail <b>to</b> last node ID:
        tree_node_ref_mut.bits = tree_node_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>)) |
            // Mask in new bits.
            ((last_node_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>);
        new_tail = <a href="_some">option::some</a>(last_node_id); // Flag new tail.
    } <b>else</b> { // If node was not list tail:
        // Mutably borrow next list node.
        <b>let</b> list_node_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            list_nodes_ref_mut, next_node_id);
        // Set node's last MSBs <b>to</b> those of virtual next field.
        list_node_ref_mut.last_msbs = ((last &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>) <b>as</b> u8);
        // Set node's last LSBs <b>to</b> those of virtual next field.
        list_node_ref_mut.last_lsbs = ((last & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u64)) <b>as</b> u8);
    };
    (new_head, new_tail) // Return optional new head and tail.
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_remove_tree_node"></a>

## Function `remove_tree_node`

Remove tree node from an AVL queue.

Inner function for <code>remove()</code>.


<a name="@Parameters_39"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of node to remove.

Here, node x refers to the node to remove from the tree. Node
x may have a parent or may be the tree root, and may have 0, 1,
or 2 children.

>        |
>        x
>       / \


<a name="@Case_1_40"></a>

### Case 1


Node x has no children. Here, the parent to node x gets updated
to have a null subtree as its child on the side that node x used
to be a child at. If node x has no parent the tree is completely
cleared out and no retrace takes place, otherwise a decrement
retrace starts from node x's pre-removal parent on the side that
node x used to be a child at.


<a name="@Case_2_41"></a>

### Case 2


Node x has a single child node. Here, the parent to node x gets
updated to have node x's sole child as its child on the side
that node x used to be a child at. If node x has no parent then
the child becomes the root of the tree and no retrace takes
place, otherwise a decrement retrace starts from node x's
pre-removal parent on the side that node x used to be a child
at.


<a name="@Left_child_42"></a>

#### Left child


Pre-removal:

>       |
>       x
>      /
>     l

Post-removal:

>     |
>     l


<a name="@Right_child_43"></a>

#### Right child


Pre-removal:

>     |
>     x
>      \
>       r

Post-removal:

>     |
>     r


<a name="@Case_3_44"></a>

### Case 3


Node x has two children. Handled by
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_with_children">remove_tree_node_with_children</a>()</code>.


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node">remove_tree_node</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node">remove_tree_node</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64
) {
    <b>let</b> node_x_ref = // Immutably borrow node x.
        <a href="_borrow">table_with_length::borrow</a>(&<b>mut</b> avlq_ref_mut.tree_nodes, node_x_id);
    <b>let</b> bits = node_x_ref.bits; // Get node x bits.
    // Get node x's left height, right height, parent, and children
    // fields.
    <b>let</b> (node_x_height_left, node_x_height_right, node_x_parent,
         node_x_child_left , node_x_child_right) =
        (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) <b>as</b> u8),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) <b>as</b> u8),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>      ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) <b>as</b> u64),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>  ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) <b>as</b> u64),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) <b>as</b> u64));
    // Determine <b>if</b> node x <b>has</b> left child.
    <b>let</b> has_child_left  = node_x_child_left  != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64);
    // Determine <b>if</b> node x <b>has</b> right child.
    <b>let</b> has_child_right = node_x_child_right != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64);
    // Assume case 1: node x is leaf node replaced by null subtree,
    // potentially requiring decrement retrace on side that node x
    // was child at (retrace side reassigned later).
    <b>let</b> (new_subtree_root, retrace_node_id, retrace_side) =
        ((<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)    , node_x_parent  , <b>false</b>       );
    <b>if</b> (( has_child_left && !has_child_right) ||
        (!has_child_left &&  has_child_right)) { // If only 1 child:
        new_subtree_root = <b>if</b> (has_child_left) node_x_child_left <b>else</b>
            node_x_child_right; // New subtree root is the child.
        // Mutably borrow child.
        <b>let</b> child_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            &<b>mut</b> avlq_ref_mut.tree_nodes, new_subtree_root);
        // Reassign bits for new parent field.
        child_ref_mut.bits = child_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>)) |
            // Mask in new bits.
            ((node_x_parent <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>);
    }; // Case 2 handled.
    // If node x <b>has</b> left and right child remove node per case 3,
    // storing new subtree root, retrace node ID, and retrace side.
    <b>if</b> (has_child_left && has_child_right)
        (new_subtree_root, retrace_node_id, retrace_side) =
        <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_with_children">remove_tree_node_with_children</a>(
            avlq_ref_mut, node_x_id, node_x_height_left,
            node_x_height_right, node_x_parent, node_x_child_left,
            node_x_child_right);
    // Clean up parent edge, optionally retrace, push onto stack.
    <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_follow_up">remove_tree_node_follow_up</a>(
        avlq_ref_mut, node_x_id, node_x_parent, new_subtree_root,
        retrace_node_id, retrace_side);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_remove_tree_node_follow_up"></a>

## Function `remove_tree_node_follow_up`

Clean up parent edge, optionally retrace, push onto stack.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node">remove_tree_node</a>()</code>, following up on removal
of node x.

Follow up on tree node removal re-ordering operations, updating
parent to node x (if there is one). Retrace as needed, then push
node x onto the inactive tree nodes stack.


<a name="@Parameters_45"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of removed node.
* <code>node_x_parent</code>: Parent field of node x before it was removed,
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if x was root.
* <code>new_subtree_root</code>: New root of subtree where node x was root
pre-removal, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if node x was a leaf node.
* <code>retrace_node_id</code>: Node ID to retrace from, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if node x
was at the root and had less than two children before it was
removed.
* <code>retrace_side</code>: Side of decrement retrace for the case of node
x having two children, reassigned if node x was not at root
before removal and had less than two children.


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_follow_up">remove_tree_node_follow_up</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_x_parent: u64, new_subtree_root: u64, retrace_node_id: u64, retrace_side: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_follow_up">remove_tree_node_follow_up</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64,
    node_x_parent: u64,
    new_subtree_root: u64,
    retrace_node_id: u64,
    retrace_side: bool
) {
    <b>if</b> (node_x_parent == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If node x was tree root:
        // Reassign bits for root MSBs:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>)) |
            // Mask in new bits.
            ((new_subtree_root <b>as</b> u128) &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>);
        avlq_ref_mut.root_lsbs = // Set AVL queue root LSBs.
            (new_subtree_root & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u8);
    } <b>else</b> { // If node x was not root:
        // Mutably borrow node x's parent.
        <b>let</b> parent_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
            &<b>mut</b> avlq_ref_mut.tree_nodes, new_subtree_root);
        // Get parent's left child.
        <b>let</b> parent_left_child = (((parent_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>)
            & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
        // Get child shift based on node x's side <b>as</b> a child.
        <b>let</b> child_shift = <b>if</b> (parent_left_child == node_x_id)
            <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a> <b>else</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>;
        // Reassign bits for new child field.
        parent_ref_mut.bits = parent_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; child_shift)) |
            // Mask in new bits.
            ((new_subtree_root <b>as</b> u128) &lt;&lt; child_shift);
        // If retrace node id is node x's parent, then node x had
        // less than two children before removal, so retrace side
        // is the side on which node x was previously a child.
        <b>if</b> (retrace_node_id == node_x_parent) retrace_side =
            <b>if</b> (parent_left_child == node_x_id) <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a> <b>else</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a>;
    }; // Parent edge updated, retrace side assigned <b>if</b> needed.
    <b>if</b> (retrace_node_id != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) // Retrace <b>if</b> needed.
        <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>(avlq_ref_mut, retrace_node_id, <a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a>, retrace_side);
    // Get inactive tree nodes stack top.
    <b>let</b> tree_top = (((avlq_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>) &
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
    // Mutably borrow node x.
    <b>let</b> node_x_ref_mut = <a href="_borrow_mut">table_with_length::borrow_mut</a>(
        &<b>mut</b> avlq_ref_mut.tree_nodes, node_x_id);
    // Set node x <b>to</b> indicate the next inactive tree node in stack.
    node_x_ref_mut.bits = (tree_top <b>as</b> u128);
    // Reassign bits for inactive tree node stack top:
    avlq_ref_mut.bits = avlq_ref_mut.bits &
        // Clear out field via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_TREE_STACK_TOP">SHIFT_TREE_STACK_TOP</a>)) |
        // Mask in new bits.
        ((node_x_id <b>as</b> u128) &lt;&lt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_STACK_TOP">SHIFT_LIST_STACK_TOP</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_remove_tree_node_with_children"></a>

## Function `remove_tree_node_with_children`

Replace node x with its predecessor in preparation for retrace.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node">remove_tree_node</a>()</code> in the case of removing
a node with two children.  Here, node x is the node to remove,
having left child node l and right child node r.

>           |
>           x
>          / \
>         l   r


<a name="@Parameters_46"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of removed node.
* <code>node_x_height_left</code>: Node x's left height.
* <code>node_x_height_right</code>: Node x's right height.
* <code>node_x_parent</code>: Node x's parent field.
* <code>node_l_id</code>: Node ID of node x's left child.
* <code>node_r_id</code>: Node ID of node x's right child.


<a name="@Returns_47"></a>

### Returns


* <code>u64</code>: Node ID of new root subtree where node x was root
pre-removal.
* <code>u64</code>: Node ID of node to begin decremrent retrace from in
<code><a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_follow_up">remove_tree_node_follow_up</a>()</code>.
* <code>bool</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code>, the side on which the decrement
retrace should take place.

Node l does not have a right child, but has left child tree l
which may or may not be empty.

>           |
>           x
>          / \
>         l   r
>        /
>     t_l

Here, node l takes the place of node x, with node l's left
height and right height set to those of node x pre-removal. Then
a left decrement retrace is initiated at node l.

>         |
>         l
>        / \
>     t_l   r


<a name="@Predecessor_is_not_immediate_child_48"></a>

### Predecessor is not immediate child


Node l has a right child, with node y as the maximum node in the
corresponding subtree. Node y has no right child, but has as its
left child tree y, which may or may not be empty. Node y may or
may not have node l as its parent.

>           |
>           x
>          / \
>         l   r
>        / \
>     t_l   ~
>            \
>             y
>            /
>         t_y

Here, node y takes the place of node x, with node y's left
height and right height updated to those of node x pre-removal.
Tree y then takes the place of y, and a right decrement retrace
is initiated at node y's pre-removal parent.

>           |
>           y
>          / \
>         l   r
>        / \
>     t_l   ~
>            \
>             t_y


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_with_children">remove_tree_node_with_children</a>&lt;V&gt;(_avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, _node_x_id: u64, _node_x_height_left: u8, _node_x_height_right: u8, _node_x_parent: u64, _node_l_id: u64, _node_r_id: u64): (u64, u64, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_remove_tree_node_with_children">remove_tree_node_with_children</a>&lt;V&gt;(
    _avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    _node_x_id: u64,
    _node_x_height_left: u8,
    _node_x_height_right: u8,
    _node_x_parent: u64,
    _node_l_id: u64,
    _node_r_id: u64,
): (
    u64, // New subtree root
    u64, // Retrace node
    bool // Retrace side
) {
    (0, 0, <b>true</b>)
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_retrace"></a>

## Function `retrace`

Retrace ancestor heights after tree node insertion or removal.

Should only be called by <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert">insert</a>()</code> or <code>remove()</code>.

When a tree leaf node is inserted or removed, the parent-leaf
edge is first updated with corresponding node IDs for both
parent and optional leaf. Then the corresponding change in
height at the parent node, on the affected side, must be
updated, along with any affected heights up to the root. If the
process results in an imbalance of more than one between the
left height and right height of a node in the ancestor chain,
the corresponding subtree must be rebalanced.

Parent-leaf edge updates are handled in <code><a href="avl_queue.md#0xc0deb00c_avl_queue_insert">insert</a>()</code> and
<code>remove()</code>, while the height retracing process is handled here.


<a name="@Parameters_49"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_id</code> : Node ID of tree node that just had a child
inserted or removed, resulting in a modification to its height
on the side that the insertion or removal took place.
* <code>operation</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a></code> if height on given side increases as
a result, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a></code> if it decreases.
* <code>side</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code>, the side on which the child was
inserted or deleted.


<a name="@Testing_50"></a>

### Testing


Tests are designed to evaluate both true and false outcomes for
all logical branches, with each relevant test covering multiple
conditional branches, optionally via a retrace back to the root.

See <code>test_rotate_right_1()</code> and <code>test_rotate_left_2()</code> for more
information on their corresponding reference diagrams.

<code><b>if</b> (height_left != height_right)</code>

| Exercises <code><b>true</b></code>       | Excercises <code><b>false</b></code>             |
|------------------------|--------------------------------|
| <code>test_rotate_left_2()</code> | <code>test_retrace_insert_remove()</code> |

<code><b>if</b> (height_left &gt; height_right)</code>

| Exercises <code><b>true</b></code>        | Excercises <code><b>false</b></code>     |
|-------------------------|------------------------|
| <code>test_rotate_right_1()</code> | <code>test_rotate_left_2()</code> |

<code><b>if</b> (imbalance &gt; 1)</code>

| Exercises <code><b>true</b></code>       | Excercises <code><b>false</b></code>             |
|------------------------|--------------------------------|
| <code>test_rotate_left_2()</code> | <code>test_retrace_insert_remove()</code> |

<code><b>if</b> (left_heavy)</code>

| Exercises <code><b>true</b></code>        | Excercises <code><b>false</b></code>     |
|-------------------------|------------------------|
| <code>test_rotate_right_1()</code> | <code>test_rotate_left_2()</code> |

<code><b>if</b> (parent == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64))</code>

| Exercises <code><b>true</b></code>        | Excercises <code><b>false</b></code>     |
|-------------------------|------------------------|
| <code>test_rotate_right_1()</code> | <code>test_rotate_left_2()</code> |

<code><b>if</b> (new_subtree_root != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64))</code>

| Exercises <code><b>true</b></code>        | Excercises <code><b>false</b></code>             |
|-------------------------|--------------------------------|
| <code>test_rotate_right_1()</code> | <code>test_retrace_insert_remove()</code> |

<code><b>if</b> (delta == 0)</code>

| Exercises <code><b>true</b></code>       | Excercises <code><b>false</b></code>             |
|------------------------|--------------------------------|
| <code>test_rotate_left_2()</code> | <code>test_retrace_insert_remove()</code> |


<a name="@Reference_diagram_51"></a>

#### Reference diagram


For <code>test_retrace_insert_remove()</code>, insert node d and retrace
from node c, then remove node d and retrace from c again.

Pre-insertion:

>       4
>      / \
>     3   5

Pre-removal:

>       node b -> 4
>                / \
>     node a -> 3   5 <- node c
>                    \
>                     6 <- node d

Post-removal:

>       4
>      / \
>     3   5


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_id: u64, operation: bool, side: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_id: u64,
    operation: bool,
    side: bool
) {
    <b>let</b> delta = 1; // Mark height change of one for first iteration.
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    // Mutably borrow node under consideration.
    <b>let</b> node_ref_mut =
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, node_id);
    <b>loop</b> {
        // Get parent field of node under review.
        <b>let</b> parent = (((node_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) &
                       (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
        <b>let</b> (height_left, height_right, height, height_old) =
            <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_update_heights">retrace_update_heights</a>(node_ref_mut, side, operation, delta);
        // Flag no rebalancing via null new subtree root.
        <b>let</b> new_subtree_root = (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64);
        <b>if</b> (height_left != height_right) { // If node not balanced:
            // Determine <b>if</b> node is left-heavy, and calculate the
            // imbalance of the node (the difference in height
            // between node's two subtrees).
            <b>let</b> (left_heavy, imbalance) = <b>if</b> (height_left &gt; height_right)
                (<b>true</b>, height_left - height_right) <b>else</b>
                (<b>false</b>, height_right - height_left);
            <b>if</b> (imbalance &gt; 1) { // If imbalance greater than 1:
                // Get shift amount for child on heavy side.
                <b>let</b> child_shift = <b>if</b> (left_heavy) <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a> <b>else</b>
                    <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>;
                // Get child ID from node bits.
                <b>let</b> child_id = (((node_ref_mut.bits &gt;&gt; child_shift) &
                                 (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
                // Rebalance, storing node ID of new subtree root
                // and new subtree height.
                (new_subtree_root, height) = <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>(
                    avlq_ref_mut, node_id, child_id, left_heavy);
            };
        }; // Corresponding subtree <b>has</b> been optionally rebalanced.
        <b>if</b> (parent == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If just retraced root:
            // If just rebalanced at root:
            <b>if</b> (new_subtree_root != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
                // Reassign bits for root MSBs:
                avlq_ref_mut.bits = avlq_ref_mut.bits &
                    // Clear out field via mask unset at field bits.
                    (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>)) |
                    // Mask in new bits.
                    ((new_subtree_root <b>as</b> u128) &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_BITS_PER_BYTE">BITS_PER_BYTE</a>);
                avlq_ref_mut.root_lsbs = // Set AVL queue root LSBs.
                    (new_subtree_root & <a href="avl_queue.md#0xc0deb00c_avl_queue_HI_BYTE">HI_BYTE</a> <b>as</b> u8);
            }; // AVL queue root now current for actual root.
            <b>return</b> // Stop looping.
        } <b>else</b> { // If just retraced node not at root:
            // Prepare <b>to</b> optionally iterate again.
            (node_ref_mut, operation, side, delta) =
                <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_prep_iterate">retrace_prep_iterate</a>(avlq_ref_mut, parent, node_id,
                                     new_subtree_root, height, height_old);
            // Return <b>if</b> current iteration did not result in height
            // change for corresponding subtree.
            <b>if</b> (delta == 0) <b>return</b>;
            // Store parent ID <b>as</b> node ID for next iteration.
            node_id = parent;
        };
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_retrace_prep_iterate"></a>

## Function `retrace_prep_iterate`

Prepare for an optional next retrace iteration.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>()</code>, should only be called if just
retraced below the root of the AVL queue.


<a name="@Parameters_52"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>parent_id</code>: Node ID of next ancestor in retrace chain.
* <code>node_id</code>: Node ID at root of subtree just retraced, before
any optional rebalancing took place.
* <code>new_subtree_root</code>: Node ID of new subtree root for when
rebalancing took place, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if no rebalancing.
* <code>height</code>: Height of subtree after retrace.
* <code>height_old</code>: Height of subtree before retrace.


<a name="@Returns_53"></a>

### Returns


* <code>&<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a></code>: Mutable reference to next ancestor.
* <code>bool</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a></code>, the change in height for
the subtree just retraced. Evalutes to <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a></code> when
height does not change.
* <code>bool</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code>, the side on which the retraced
subtree was a child to the next ancestor.
* <code>u8</code>: Change in height of subtree due to retrace, evaluates to
0 when height does not change.


<a name="@Testing_54"></a>

### Testing


* <code>test_retrace_prep_iterate_1()</code>
* <code>test_retrace_prep_iterate_2()</code>
* <code>test_retrace_prep_iterate_3()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_prep_iterate">retrace_prep_iterate</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, parent_id: u64, node_id: u64, new_subtree_root: u64, height: u8, height_old: u8): (&<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">avl_queue::TreeNode</a>, bool, bool, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_prep_iterate">retrace_prep_iterate</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    parent_id: u64,
    node_id: u64,
    new_subtree_root: u64,
    height: u8,
    height_old: u8,
): (
    &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>,
    bool,
    bool,
    u8
) {
    // Mutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref_mut = &<b>mut</b> avlq_ref_mut.tree_nodes;
    // Mutably borrow parent <b>to</b> subtree just retraced.
    <b>let</b> node_ref_mut =
        <a href="_borrow_mut">table_with_length::borrow_mut</a>(nodes_ref_mut, parent_id);
    // Get parent's left child.
    <b>let</b> left_child = ((node_ref_mut.bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>) &
                      (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) <b>as</b> u64);
    // Flag side on which retracing operation took place.
    <b>let</b> side = <b>if</b> (left_child == node_id) <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a> <b>else</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a>;
    // If subtree rebalanced:
    <b>if</b> (new_subtree_root != (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) {
        // Get corresponding child field shift amount.
        <b>let</b> child_shift = <b>if</b> (side == <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a>)
            <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a> <b>else</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>;
        // Reassign bits for new child field.
        node_ref_mut.bits = node_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) &lt;&lt; child_shift)) |
            // Mask in new bits.
            ((new_subtree_root <b>as</b> u128) &lt;&lt; child_shift)
    }; // Parent-child edge updated.
    // Determine retrace operation type and height delta.
    <b>let</b> (operation, delta) = <b>if</b> (height &gt; height_old)
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a>, height - height_old) <b>else</b>
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a>, height_old - height);
    // Return mutable reference <b>to</b> parent node, operation performed,
    // side of operation, and corresponding change in height.
    (node_ref_mut, operation, side, delta)
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_retrace_rebalance"></a>

## Function `retrace_rebalance`

Rebalance a subtree, returning new root and height.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>()</code>.

Updates state for nodes in subtree, but not for potential parent
to subtree.


<a name="@Parameters_55"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_id_x</code>: Node ID of subtree root.
* <code>node_id_z</code>: Node ID of child to subtree root, on subtree
root's heavy side.
* <code>node_x_left_heavy</code>: <code><b>true</b></code> if node x is left-heavy.


<a name="@Returns_56"></a>

### Returns


* <code>u64</code>: Tree node ID of new subtree root after rotation.
* <code>u8</code>: Height of subtree after rotation.


<a name="@Node_x_status_57"></a>

### Node x status


Node x can be either left-heavy or right heavy. In either case,
consider that node z has left child and right child fields.


<a name="@Node_x_left-heavy_58"></a>

#### Node x left-heavy


>             n_x
>            /
>          n_z
>         /   \
>     z_c_l   z_c_r


<a name="@Node_x_right-heavy_59"></a>

#### Node x right-heavy


>       n_x
>          \
>          n_z
>         /   \
>     z_c_l   z_c_r


<a name="@Testing_60"></a>

### Testing


* <code>test_rotate_left_1()</code>
* <code>test_rotate_left_2()</code>
* <code>test_rotate_left_right_1()</code>
* <code>test_rotate_left_right_2()</code>
* <code>test_rotate_right_1()</code>
* <code>test_rotate_right_2()</code>
* <code>test_rotate_right_left_1()</code>
* <code>test_rotate_right_left_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, node_x_left_heavy: bool): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>&lt;V&gt;(
    avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    node_x_id: u64,
    node_z_id: u64,
    node_x_left_heavy: bool,
): (
    u64,
    u8
) {
    <b>let</b> node_z_ref = // Immutably borrow node z.
        <a href="_borrow">table_with_length::borrow</a>(&avlq_ref_mut.tree_nodes, node_z_id);
    <b>let</b> bits = node_z_ref.bits; // Get node z bits.
    // Get node z's left height, right height, and child fields.
    <b>let</b> (node_z_height_left, node_z_height_right,
         node_z_child_left , node_z_child_right  ) =
        (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) <b>as</b> u8),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a>  <b>as</b> u128) <b>as</b> u8),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a>  ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) <b>as</b> u64),
         ((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128) <b>as</b> u64));
    // Return result of rotation. If node x is left-heavy:
    <b>return</b> (<b>if</b> (node_x_left_heavy)
        // If node z is right-heavy, rotate left-right
        (<b>if</b> (node_z_height_right &gt; node_z_height_left)
            <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left_right">retrace_rebalance_rotate_left_right</a>(
                avlq_ref_mut, node_x_id, node_z_id, node_z_child_right,
                node_z_height_left)
            // Otherwise node z is not right-heavy so rotate right.
            <b>else</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right">retrace_rebalance_rotate_right</a>(
                avlq_ref_mut, node_x_id, node_z_id, node_z_child_right,
                node_z_height_right))
        <b>else</b> // If node x is right-heavy:
        // If node z is left-heavy, rotate right-left
        (<b>if</b> (node_z_height_left &gt; node_z_height_right)
            <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right_left">retrace_rebalance_rotate_right_left</a>(
                avlq_ref_mut, node_x_id, node_z_id, node_z_child_left,
                node_z_height_right)
            // Otherwise node z is not left-heavy so rotate left.
            <b>else</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left">retrace_rebalance_rotate_left</a>(
                avlq_ref_mut, node_x_id, node_z_id, node_z_child_left,
                node_z_height_left)))
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_retrace_rebalance_rotate_left"></a>

## Function `retrace_rebalance_rotate_left`

Rotate left during rebalance.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>()</code>.

Updates state for nodes in subtree, but not for potential parent
to subtree.

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


<a name="@Parameters_61"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree root post-rotation.
* <code>tree_2_id</code>: Node z's left child field.
* <code>node_z_height_left</code>: Node z's left height.


<a name="@Returns_62"></a>

### Returns


* <code>u64</code>: Node z's ID.
* <code>u8</code>: The height of the subtree rooted at node z,
post-rotation.


<a name="@Reference_rotations_63"></a>

### Reference rotations



<a name="@Case_1_64"></a>

#### Case 1


* Tree 2 null.
* Node x left height greater than or equal to right height
post-rotation.
* Node z right height greater than or equal to left height
post-rotation.

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


<a name="@Case_2_65"></a>

#### Case 2


* Tree 2 not null.
* Node x left height not greater than or equal to right height
post-rotation.
* Node z right height not greater than or equal to left height
post-rotation.
* Simulates removing node d, then retracing from node x.

Pre-removal:

>                   3 <- node a
>                  / \
>       node b -> 2   5
>                /   / \
>     node c -> 1   4   7
>            node d ^  / \
>                     6   8

Pre-rotation:

>             3
>            / \
>           2   5 <- node x
>          /     \
>         1       7 <- node z
>                / \
>     tree 2 -> 6   8 <- tree 3

Post-rotation:

>         3
>        / \
>       2   7 <- node z
>      /   / \
>     1   5   8 <- tree 3
>          \
>           6 <- tree 2


<a name="@Testing_66"></a>

### Testing


* <code>test_rotate_left_1()</code>
* <code>test_rotate_left_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left">retrace_rebalance_rotate_left</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, tree_2_id: u64, node_z_height_left: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left">retrace_rebalance_rotate_left</a>&lt;V&gt;(
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
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64); // Get node x parent field.
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

<a name="0xc0deb00c_avl_queue_retrace_rebalance_rotate_left_right"></a>

## Function `retrace_rebalance_rotate_left_right`

Rotate left-right during rebalance.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>()</code>.

Updates state for nodes in subtree, but not for potential parent
to subtree.

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


<a name="@Procedure_67"></a>

### Procedure


* Inspect node y's fields.
* Optionally update tree 2's parent field.
* Optionally update tree 3's parent field.
* Update node x's left child and parent fields.
* Update node z's right child and parent fields.
* Update node y's children and parent fields.


<a name="@Reference_rotations_68"></a>

### Reference rotations



<a name="@Case_1_69"></a>

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


<a name="@Case_2_70"></a>

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

Post-rotation:

>                   6 <- node y
>                  / \
>       node z -> 2   8 <- node x
>                / \   \
>     tree 1 -> 1   5   9 <- tree 4
>                   ^ tree 2


<a name="@Testing_71"></a>

### Testing


* <code>test_rotate_left_right_1()</code>
* <code>test_rotate_left_right_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left_right">retrace_rebalance_rotate_left_right</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, node_y_id: u64, node_z_height_left: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_left_right">retrace_rebalance_rotate_left_right</a>&lt;V&gt;(
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
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64); // Store node x parent field.
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

<a name="0xc0deb00c_avl_queue_retrace_rebalance_rotate_right"></a>

## Function `retrace_rebalance_rotate_right`

Rotate right during rebalance.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>()</code>.

Updates state for nodes in subtree, but not for potential parent
to subtree.

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


<a name="@Parameters_72"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree root post-rotation.
* <code>tree_2_id</code>: Node z's right child field.
* <code>node_z_height_right</code>: Node z's right height.


<a name="@Returns_73"></a>

### Returns


* <code>u64</code>: Node z's ID.
* <code>u8</code>: The height of the subtree rooted at node z,
post-rotation.


<a name="@Reference_rotations_74"></a>

### Reference rotations



<a name="@Case_1_75"></a>

#### Case 1


* Tree 2 null.
* Node x right height greater than or equal to left height
post-rotation.
* Node z left height greater than or equal to right height
post-rotation.
* Simulates inserting tree 1, then retracing from node z.

Pre-insertion:

>       8
>      /
>     6

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


<a name="@Case_2_76"></a>

#### Case 2


* Tree 2 not null.
* Node x right height not greater than or equal to left height
post-rotation.
* Node z left height not greater than or equal to right height
post-rotation.

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


<a name="@Testing_77"></a>

### Testing


* <code>test_rotate_right_1()</code>
* <code>test_rotate_right_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right">retrace_rebalance_rotate_right</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, tree_2_id: u64, node_z_height_right: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right">retrace_rebalance_rotate_right</a>&lt;V&gt;(
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
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64); // Get node x parent field.
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

<a name="0xc0deb00c_avl_queue_retrace_rebalance_rotate_right_left"></a>

## Function `retrace_rebalance_rotate_right_left`

Rotate right-left during rebalance.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance">retrace_rebalance</a>()</code>.

Updates state for nodes in subtree, but not for potential parent
to subtree.

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


<a name="@Parameters_78"></a>

### Parameters


* <code>avlq_ref_mut</code>: Mutable reference to AVL queue.
* <code>node_x_id</code>: Node ID of subtree root pre-rotation.
* <code>node_z_id</code>: Node ID of subtree right child pre-rotation.
* <code>node_y_id</code>: Node ID of subtree root post-rotation.
* <code>node_z_height_right</code>: Node z's right height pre-rotation.


<a name="@Procedure_79"></a>

### Procedure


* Inspect node y's fields.
* Optionally update tree 2's parent field.
* Optionally update tree 3's parent field.
* Update node x's right child and parent fields.
* Update node z's left child and parent fields.
* Update node y's children and parent fields.


<a name="@Reference_rotations_80"></a>

### Reference rotations



<a name="@Case_1_81"></a>

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

>                   4 <- node y
>                  / \
>       node x -> 2   8 <- node z
>                / \   \
>     tree 1 -> 1   3   9 <- tree 4
>                   ^ tree 2


<a name="@Case_2_82"></a>

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

>                   4 <- node y
>                  / \
>       node x -> 2   8 <- node z
>                /   / \
>     tree 1 -> 1   5   9 <- tree 4
>                   ^ tree 3


<a name="@Testing_83"></a>

### Testing


* <code>test_rotate_right_left_1()</code>
* <code>test_rotate_right_left_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right_left">retrace_rebalance_rotate_right_left</a>&lt;V&gt;(avlq_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, node_x_id: u64, node_z_id: u64, node_y_id: u64, node_z_height_right: u8): (u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_rebalance_rotate_right_left">retrace_rebalance_rotate_right_left</a>&lt;V&gt;(
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
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64); // Store node x parent field.
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

<a name="0xc0deb00c_avl_queue_retrace_update_heights"></a>

## Function `retrace_update_heights`

Update height fields during retracing.

Inner function for <code><a href="avl_queue.md#0xc0deb00c_avl_queue_retrace">retrace</a>()</code>.


<a name="@Parameters_84"></a>

### Parameters


* <code>node_ref_mut</code>: Mutable reference to a node that needs to have
its height fields updated during retrace.
* <code>side</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code>, the side on which the node's height
needs to be updated.
* <code>operation</code>: <code><a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_DECREMENT">DECREMENT</a></code>, the kind of change in
the height field for the given side.
* <code>delta</code>: The amount of height change for the operation.


<a name="@Returns_85"></a>

### Returns


* <code>u8</code>: The left height of the node after updating height.
* <code>u8</code>: The right height of the node after updating height.
* <code>u8</code>: The height of the node before updating height.
* <code>u8</code>: The height of the node after updating height.


<a name="@Testing_86"></a>

### Testing


* <code>test_retrace_update_heights_1()</code>
* <code>test_retrace_update_heights_2()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_update_heights">retrace_update_heights</a>(node_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">avl_queue::TreeNode</a>, side: bool, operation: bool, delta: u8): (u8, u8, u8, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_retrace_update_heights">retrace_update_heights</a>(
    node_ref_mut: &<b>mut</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_TreeNode">TreeNode</a>,
    side: bool,
    operation: bool,
    delta: u8
): (
    u8,
    u8,
    u8,
    u8
) {
    <b>let</b> bits = node_ref_mut.bits; // Get node's field bits.
    // Get node's left height, right height, and parent fields.
    <b>let</b> (height_left, height_right) =
        ((((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a> ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128)) <b>as</b> u8),
         (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128)) <b>as</b> u8));
    <b>let</b> height_old = <b>if</b> (height_left &gt;= height_right) height_left <b>else</b>
        height_right; // Get height of node before retracing.
    // Get height field and shift amount for operation side.
    <b>let</b> (height_field, height_shift) = <b>if</b> (side == <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a>)
        (height_left , <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_LEFT">SHIFT_HEIGHT_LEFT</a> ) <b>else</b>
        (height_right, <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_HEIGHT_RIGHT">SHIFT_HEIGHT_RIGHT</a>);
    // Get updated height field for side.
    <b>let</b> height_field = <b>if</b> (operation == <a href="avl_queue.md#0xc0deb00c_avl_queue_INCREMENT">INCREMENT</a>) height_field + delta
        <b>else</b> height_field - delta;
    // Reassign bits for corresponding height field:
    node_ref_mut.bits = bits &
        // Clear out field via mask unset at field bits.
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_128">HI_128</a> ^ ((<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_HEIGHT">HI_HEIGHT</a> <b>as</b> u128) &lt;&lt; height_shift)) |
        // Mask in new bits.
        ((height_field <b>as</b> u128) &lt;&lt; height_shift);
    // Reassign <b>local</b> height <b>to</b> that of indicated field.
    <b>if</b> (side == <a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a>) height_left = height_field <b>else</b>
        height_right = height_field;
    <b>let</b> height = <b>if</b> (height_left &gt;= height_right) height_left <b>else</b>
        height_right; // Get height of node after <b>update</b>.
    (height_left, height_right, height, height_old)
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


<a name="@Parameters_87"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>seed_key</code>: Seed key to search for.


<a name="@Returns_88"></a>

### Returns


* <code>u64</code>: Node ID of match node, or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if empty tree.
* <code>Option&lt;bool&gt;</code>: None if empty tree or if match key equals seed
key, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_LEFT">LEFT</a></code> if seed key is less than match key but match node
has no left child, <code><a href="avl_queue.md#0xc0deb00c_avl_queue_RIGHT">RIGHT</a></code> if seed key is greater than match
key but match node has no right child.


<a name="@Assumptions_89"></a>

### Assumptions


* AVL queue is not empty, and <code>root_node_id</code> properly indicates
the root node.
* Seed key fits in 32 bits.


<a name="@Reference_diagram_90"></a>

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


<a name="@Testing_91"></a>

### Testing


* <code>test_search()</code>


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

<a name="0xc0deb00c_avl_queue_traverse"></a>

## Function `traverse`

Traverse from tree node to inorder predecessor or succesor.


<a name="@Parameters_92"></a>

### Parameters


* <code>avlq_ref</code>: Immutable reference to AVL queue.
* <code>start_node_id</code>: Tree node ID of node to traverse from.
* <code>target</code>: Either <code><a href="avl_queue.md#0xc0deb00c_avl_queue_PREDECESSOR">PREDECESSOR</a></code> or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_SUCCESSOR">SUCCESSOR</a></code>.


<a name="@Conventions_93"></a>

### Conventions


Traversal starts at the "start node" and ends at the "target
node", if any.


<a name="@Returns_94"></a>

### Returns


* <code>u64</code>: Insertion key of target node, or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>.
* <code>u64</code>: List node ID for head of doubly linked list in
target node, or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>.
* <code>u64</code>: List node ID for tail of doubly linked list in
target node, or <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code>.


<a name="@Membership_considerations_95"></a>

### Membership considerations


* Aborts if no tree node in AVL queue with given start node ID.
* Returns all <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if start node is sole node at root.
* Returns all <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if no predecessor or successor.
* Returns all <code><a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a></code> if start node ID indicates inactive node.


<a name="@Predecessor_96"></a>

### Predecessor


1. If start node has left child, return maximum node in left
child's right subtree.
2. Otherwise, walk upwards until reaching a node that had last
walked node as the root of its right subtree.


<a name="@Successor_97"></a>

### Successor


1. If start node has right child, return minimum node in right
child's left subtree.
2. Otherwise, walk upwards until reaching a node that had last
walked node as the root of its left subtree.


<a name="@Reference_diagram_98"></a>

### Reference diagram


>                 5
>            ____/ \____
>           2           8
>          / \         / \
>         1   3       7   9
>              \     /
>               4   6

Inserted in following sequence:

| Insertion key | Sequence number |
|---------------|-----------------|
| 5             | 1               |
| 8             | 2               |
| 2             | 3               |
| 1             | 4               |
| 3             | 5               |
| 7             | 6               |
| 9             | 7               |
| 4             | 8               |
| 6             | 9               |


<a name="@Testing_99"></a>

### Testing


* <code>test_traverse()</code>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_traverse">traverse</a>&lt;V&gt;(avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">avl_queue::AVLqueue</a>&lt;V&gt;, start_node_id: u64, target: bool): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="avl_queue.md#0xc0deb00c_avl_queue_traverse">traverse</a>&lt;V&gt;(
    avlq_ref: &<a href="avl_queue.md#0xc0deb00c_avl_queue_AVLqueue">AVLqueue</a>&lt;V&gt;,
    start_node_id: u64,
    target: bool
): (
    u64,
    u64,
    u64
) {
    // Immutably borrow tree nodes <a href="">table</a>.
    <b>let</b> nodes_ref = &avlq_ref.tree_nodes;
    // Immutably borrow start node.
    <b>let</b> node_ref = <a href="_borrow">table_with_length::borrow</a>(nodes_ref, start_node_id);
    // Determine child and subtree side based on target.
    <b>let</b> (child_shift, subtree_shift) = <b>if</b> (target == <a href="avl_queue.md#0xc0deb00c_avl_queue_PREDECESSOR">PREDECESSOR</a>)
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a> , <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>) <b>else</b>
        (<a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_RIGHT">SHIFT_CHILD_RIGHT</a>, <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_CHILD_LEFT">SHIFT_CHILD_LEFT</a> );
    <b>let</b> bits = node_ref.bits; // Get node bits.
    // Get node ID of relevant child <b>to</b> start node.
    <b>let</b> child = (((bits &gt;&gt; child_shift) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
    <b>if</b> (child == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) { // If no such child:
        child = start_node_id; // Set child <b>as</b> start node.
        <b>loop</b> { // Start upward walk.
            <b>let</b> parent = // Get parent field from node bits.
                (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_PARENT">SHIFT_PARENT</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
            // Return all null <b>if</b> no parent.
            <b>if</b> (parent == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) <b>return</b>
                ((<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64), (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64), (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64));
            // Otherwise, immutably borrow parent node.
            node_ref = <a href="_borrow">table_with_length::borrow</a>(nodes_ref, parent);
            bits = node_ref.bits; // Get node bits.
            <b>let</b> subtree = // Get subtree field for <b>break</b> side.
                (((bits &gt;&gt; subtree_shift) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
            // If child from indicated subtree, <b>break</b> out of <b>loop</b>.
            <b>if</b> (subtree == child) <b>break</b>;
            // Otherwise store node ID for next iteration.
            child = parent;
        };
    } <b>else</b> { // If start node <b>has</b> child on relevant side:
        <b>loop</b> { // Start downward walk.
            // Immutably borrow child node.
            node_ref = <a href="_borrow">table_with_length::borrow</a>(nodes_ref, child);
            bits = node_ref.bits; // Get node bits.
            child = // Get node ID of child in relevant subtree.
                (((bits &gt;&gt; subtree_shift) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a> <b>as</b> u128)) <b>as</b> u64);
            // If no subtree left <b>to</b> check, <b>break</b> out of <b>loop</b>.
            <b>if</b> (child == (<a href="avl_queue.md#0xc0deb00c_avl_queue_NIL">NIL</a> <b>as</b> u64)) <b>break</b>; // Else iterate again.
        }
    };
    <b>let</b> bits = node_ref.bits; // Get node bits.
    // Return insertion key, list head, and list tail.
    ((((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_INSERTION_KEY">SHIFT_INSERTION_KEY</a>) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_INSERTION_KEY">HI_INSERTION_KEY</a> <b>as</b> u128)) <b>as</b> u64),
     (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_HEAD">SHIFT_LIST_HEAD</a>    ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a>       <b>as</b> u128)) <b>as</b> u64),
     (((bits &gt;&gt; <a href="avl_queue.md#0xc0deb00c_avl_queue_SHIFT_LIST_TAIL">SHIFT_LIST_TAIL</a>    ) & (<a href="avl_queue.md#0xc0deb00c_avl_queue_HI_NODE_ID">HI_NODE_ID</a>       <b>as</b> u128)) <b>as</b> u64))
}
</code></pre>



</details>

<a name="0xc0deb00c_avl_queue_verify_node_count"></a>

## Function `verify_node_count`

Verify node count is not too high.


<a name="@Aborts_100"></a>

### Aborts


* <code><a href="avl_queue.md#0xc0deb00c_avl_queue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a></code>: <code>n_nodes</code> is not less than <code><a href="avl_queue.md#0xc0deb00c_avl_queue_N_NODES_MAX">N_NODES_MAX</a></code>.


<a name="@Testing_101"></a>

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
