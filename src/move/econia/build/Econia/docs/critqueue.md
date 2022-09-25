
<a name="0xc0deb00c_critqueue"></a>

# Module `0xc0deb00c::critqueue`

Crit-queue: A hybrid between a crit-bit tree and a queue.

A crit-queue contains an inner crit-bit tree with sub-queues at each
leaf node, enabling chronological ordering among multiple instances
of the same insertion key. While multiple instances of the same
insertion key are sorted by order of insertion, different
insertion keys can be sorted in either ascending or descending
order relative to the head of the crit-queue, as specified during
initialization. Like a crit-bit tree, a crit-queue can be used as an
associative array that maps keys to values, as in the present
implementation.

The present implementation, based on hash tables, offers:

* Insertions that are $O(1)$ in the best case, $O(log_2(n))$ in the
intermediate case, and parallelizable in the general case.
* Removals that are always $O(1)$, and parallelizable in the general
case.
* Iterated dequeues that are always $O(1)$.


<a name="@Module-level_documentation_sections_0"></a>

## Module-level documentation sections


[Bit conventions](#bit-conventions)

* [Number](#number)
* [Status](#status)
* [Masking](#masking)

[Crit-bit trees](#crit-bit-trees)

* [General](#general)
* [Structure](#structure)
* [Insertions](#insertions)
* [Removals](#removals)
* [As a map](#as-a-map)
* [References](#references)

[Crit-queues](#crit-queues)

* [Key storage multiplicity](#key-storage-multiplicity)
* [Sorting order](#sorting-order)
* [Leaves](#leaves)
* [Sub-queue nodes](#sub-queue-nodes)
* [Inner keys](#inner-keys)
* [Insertion counts](#insertion-counts)
* [Dequeue order preservation](#dequeue-order-preservation)
* [Sub-queue removal updates](#sub-queue-removal-updates)
* [Free leaves](#free-leaves)
* [Dequeues](#dequeues)

[Implementation analysis](#implementation-analysis)

* [Core functionality](#core-functionality)
* [Inserting](#inserting)
* [Removing](#removing)
* [Dequeuing](#dequeuing)


<a name="@Bit_conventions_1"></a>

## Bit conventions



<a name="@Number_2"></a>

### Number


Bit numbers are 0-indexed from the least-significant bit (LSB):

>     11101...1010010101
>       bit 5 = 0 ^    ^ bit 0 = 1


<a name="@Status_3"></a>

### Status


<code>0</code> is considered an "unset" bit, and <code>1</code> is considered a "set" bit.
Hence <code>11101</code> is set at bit 0 and unset at bit 1.


<a name="@Masking_4"></a>

### Masking


In the present implementation, a bitmask refers to a bitstring that
is only set at the indicated bit. For example, a bitmask with bit 0
set corresponds to <code>000...001</code>, and a bitmask with bit 3 set
corresponds to <code>000...01000</code>.


<a name="@Crit-bit_trees_5"></a>

## Crit-bit trees



<a name="@General_6"></a>

### General


A critical bit (crit-bit) tree is a compact binary prefix tree
that stores a prefix-free set of bitstrings, like n-bit integers or
variable-length 0-terminated byte strings. For a given set of keys
there exists a unique crit-bit tree representing the set, such that
crit-bit trees do not require complex rebalancing algorithms like
those of AVL or red-black binary search trees. Crit-bit trees
support the following operations:

* Membership testing
* Insertion
* Deletion
* Inorder predecessor iteration
* Inorder successor iteration


<a name="@Structure_7"></a>

### Structure


Crit-bit trees have two types of nodes: inner nodes, and leaf nodes.
Inner nodes have two leaf children each, and leaf nodes do not
have children. Inner nodes store a bitmask set at the node's
critical bit (crit-bit), which indicates the most-significant bit of
divergence between keys from the node's two subtrees: keys in an
inner node's left subtree are unset at the critical bit, while
keys in an inner node's right subtree are set at the critical bit.

Inner nodes are arranged hierarchically, with the most-significant
critical bits at the top of the tree. For example, the binary keys
<code>001</code>, <code>101</code>, <code>110</code>, and <code>111</code> produce the following crit-bit tree:

>        2nd
>       /   \
>     001   1st
>          /   \
>        101   0th
>             /   \
>           110   111

Here, the inner node marked <code>2nd</code> stores a bitmask set at bit 2, the
inner node marked <code>1st</code> stores a bitmask set at bit 1, and the inner
node marked <code>0th</code> stores a bitmask set at bit 0. Hence, the sole key
in the left subtree of <code>2nd</code> is unset at bit 2, while all the keys
in the right subtree of <code>2nd</code> are set at bit 2. And similarly for
<code>0th</code>, the key of its left child is unset at bit 0, while the key of
its right child is set at bit 0.


<a name="@Insertions_8"></a>

### Insertions


Crit-bit trees are automatically sorted upon insertion, such that
inserting <code>111</code> to

>        2nd
>       /   \
>     001   1st
>          /   \
>        101    110

produces:

>        2nd
>       /   \
>     001   1st
>          /   \
>        101   0th
>             /   \
>           110   111

Here, <code>111</code> may not be re-inserted unless it is first removed from
the tree.


<a name="@Removals_9"></a>

### Removals


Continuing the above example, crit-bit trees are automatically
compacted and sorted upon removal, such that removing <code>111</code> again
results in:

>        2nd
>       /   \
>     001   1st
>          /   \
>        101    110


<a name="@As_a_map_10"></a>

### As a map


Crit-bit trees can be used as an associative array that maps keys
to values, simply by storing values in the leaves of the tree.
For example, the insertion sequence

1. $\langle \texttt{0b001}, v_0 \rangle$
2. $\langle \texttt{0b111}, v_1 \rangle$
3. $\langle \texttt{0b110}, v_2 \rangle$
4. $\langle \texttt{0b101}, v_3 \rangle$

produces the following tree:

>                2nd
>               /   \
>     <001, v_0>    1st
>                  /   \
>        <101, v_3>    0th
>                     /   \
>           <110, v_2>     <111, v_1>


<a name="@References_11"></a>

### References


* [Bernstein 2004] (Earliest identified author)
* [Langley 2008] (Primary reference for this implementation)
* [Langley 2012]
* [Tcler's Wiki 2021]

[Bernstein 2004]:
https://cr.yp.to/critbit.html
[Langley 2008]:
https://www.imperialviolet.org/2008/09/29/critbit-trees.html
[Langley 2012]:
https://github.com/agl/critbit
[Tcler's Wiki 2021]:
https://wiki.tcl-lang.org/page/critbit


<a name="@Crit-queues_12"></a>

## Crit-queues



<a name="@Key_storage_multiplicity_13"></a>

### Key storage multiplicity


Unlike a crit-bit tree, which can only store one instance of a given
key, crit-queues can store multiple instances. For example, the
following insertion sequence, without intermediate removals, is
invalid in a crit-bit tree but valid in a crit-queue:

1. $p_{3, 0} = \langle 3, 5 \rangle$
2. $p_{3, 1} = \langle 3, 8 \rangle$
3. $p_{3, 2} = \langle 3, 2 \rangle$
4. $p_{3, 3} = \langle 3, 5 \rangle$

Here, the "key-value insertion pair"
$p_{i, j} = \langle i, v_j \rangle$ has:

* "Insertion key" $i$: the inserted key.
* "Insertion count" $j$: the number of key-value insertion pairs,
having the same insertion key, that were previously inserted.
* "Insertion value" $v_j$: the value from the key-value
insertion pair having insertion count $j$.


<a name="@Sorting_order_14"></a>

### Sorting order


Key-value insertion pairs in a crit-queue are sorted by:

1. Either ascending or descending order of insertion key, then by
2. Ascending order of insertion count.

For example, consider the following binary insertion key sequence,
where $k_{i, j}$ denotes insertion key $i$ with insertion count $j$:

1. $k_{0, 0} = \texttt{0b00}$
2. $k_{1, 0} = \texttt{0b01}$
3. $k_{1, 1} = \texttt{0b01}$
4. $k_{0, 1} = \texttt{0b00}$
5. $k_{3, 0} = \texttt{0b11}$

In an ascending crit-queue, the dequeue sequence would be:

1. $k_{0, 0} = \texttt{0b00}$
2. $k_{0, 1} = \texttt{0b00}$
3. $k_{1, 0} = \texttt{0b01}$
4. $k_{1, 1} = \texttt{0b01}$
5. $k_{3, 0} = \texttt{0b11}$

In a descending crit-queue, the dequeue sequence would instead be:

1. $k_{3, 0} = \texttt{0b11}$
2. $k_{1, 0} = \texttt{0b01}$
3. $k_{1, 1} = \texttt{0b01}$
4. $k_{0, 0} = \texttt{0b00}$
5. $k_{0, 1} = \texttt{0b00}$


<a name="@Leaves_15"></a>

### Leaves


The present crit-queue implementation involves a crit-bit tree with
a leaf node for each insertion key, where each "leaf key" has the
following bit structure:

| Bit(s) | Value         |
|--------|---------------|
| 64-127 | Insertion key |
| 0-63   | 0             |

Continuing the above example:

| Insertion key | Leaf key bits 64-127 | Leaf key bits 0-63 |
|---------------|----------------------|--------------------|
| <code>0 = 0b00</code>    | <code>000...000</code>          | <code>000...000</code>        |
| <code>1 = 0b01</code>    | <code>000...001</code>          | <code>000...000</code>        |
| <code>3 = 0b11</code>    | <code>000...011</code>          | <code>000...000</code>        |

Each leaf contains a nested sub-queue of key-values insertion
pairs all sharing the corresponding insertion key, with lower
insertion counts at the front of the queue. Continuing the above
example, this yields the following:

>                                   65th
>                                  /    \
>                              64th      000...011000...000
>                             /    \     [k_{3, 0}]
>                            /      \
>          000...000000...000        000...001000...000
>     [k_{0, 0} --> k_{0, 1}]        [k_{1, 0} --> k_{1, 1}]
>      ^ sub-queue head               ^ sub-queue head

Leaf keys are guaranteed to be unique, and all leaf nodes are stored
in a single hash table.


<a name="@Sub-queue_nodes_16"></a>

### Sub-queue nodes


All sub-queue nodes are similarly stored in single hash table, and
assigned a unique "access key" with the following bit structure
(<code>NOT</code> denotes bitwise complement):

| Bit(s) | Ascending crit-queue | Descending crit-queue |
|--------|----------------------|-----------------------|
| 64-127 | Insertion key        | Insertion key         |
| 63     | 0                    | 0                     |
| 62     | 0                    | 1                     |
| 0-61   | Insertion count      | <code>NOT</code> insertion count |

For an ascending crit-queue, access keys are thus dequeued in
ascending lexicographical order:

| Insertion key | Access key bits 64-127 | Access key bits 0-63 |
|---------------|------------------------|----------------------|
| $k_{0, 0}$    | <code>000...000</code>            | <code>000...000</code>          |
| $k_{0, 1}$    | <code>000...000</code>            | <code>000...001</code>          |
| $k_{1, 0}$    | <code>000...001</code>            | <code>000...000</code>          |
| $k_{1, 1}$    | <code>000...001</code>            | <code>000...001</code>          |
| $k_{3, 0}$    | <code>000...011</code>            | <code>000...000</code>          |

Conversely, for a descending crit-queue, access keys are thus
dequeued in descending lexicographical order:

| Insertion key | Access key bits 64-127 | Access key bits 0-63 |
|---------------|----------------------|--------------------|
| $k_{3, 0}$    | <code>000...011</code>          | <code>011...111</code>        |
| $k_{1, 0}$    | <code>000...001</code>          | <code>011...111</code>        |
| $k_{1, 1}$    | <code>000...001</code>          | <code>011...110</code>        |
| $k_{0, 0}$    | <code>000...000</code>          | <code>011...111</code>        |
| $k_{0, 1}$    | <code>000...000</code>          | <code>011...110</code>        |


<a name="@Inner_keys_17"></a>

### Inner keys


After access key assignment, if the insertion of a key-value
insertion pair requires the creation of a new inner node, the
inner node is assigned a unique "inner key" that is identical to
the new access key, except with bit 63 set. This schema allows for
discrimination between inner keys and leaf keys based solely on
bit 63.

All inner nodes are stored in a single hash table.


<a name="@Insertion_counts_18"></a>

### Insertion counts


Insertion counts are tracked in leaf nodes, such that before the
insertion of the first instance of a given insertion key,
$k_{i, 0}$, the leaf table does not have an entry corresponding
to insertion key $i$.

When $k_{i, 0}$ is inserted, a new leaf node is initialized with
an insertion counter set to 0, then added to the leaf hash table.
The new leaf node is inserted to the crit-bit tree, and a
corresponding sub-queue node is placed at the head of the new leaf's
sub-queue. For each subsequent insertion of the same insertion key,
$k_{i, n}$, the leaf insertion counter is updated to $n$, and the
new sub-queue node becomes the tail of the corresponding sub-queue.

Since bits 62 and 63 in access keys are reserved for flag bits, the
maximum insertion count per insertion key is thus $2^{62} - 1$.


<a name="@Dequeue_order_preservation_19"></a>

### Dequeue order preservation


Removals can take place from anywhere inside of a crit-queue, with
the specified dequeue order preserved among remaining elements.
For example, consider the elements in an ascending crit-queue
with the following dequeue sequence:

1. $k_{0, 6}$
2. $k_{2, 5}$
3. $k_{2, 8}$
4. $k_{4, 5}$
5. $k_{5, 0}$

Here, removing $k_{2, 5}$ simply updates the dequeue sequence to:

1. $k_{0, 6}$
2. $k_{2, 8}$
3. $k_{4, 5}$
4. $k_{5, 0}$


<a name="@Sub-queue_removal_updates_20"></a>

### Sub-queue removal updates


Removal via access key lookup in the sub-queue node hash table leads
to an update within the corresponding sub-queue.

For example, consider the following crit-queue:

>                                          64th
>                                         /    \
>                       000...000000...000      000...001000...000
>     [k_{0, 0} --> k_{0, 1} --> k_{0, 2}]      [k_{1, 0}]
>      ^ sub-queue head

Removal of $k_{0, 1}$ produces:

>                             64th
>                            /    \
>          000...000000...000      000...001000...000
>     [k_{0, 0} --> k_{0, 2}]      [k_{1, 0}]

And similarly for $k_{0, 0}$:

>                        64th
>                       /    \
>     000...000000...000      000...001000...000
>             [k_{0, 2}]      [k_{1, 0}]

Here, if ${k_{0, 2}}$ were to be removed, the tree would then have a
single leaf at its root:

>     000...001000...000 (root)
>         [k_{1, 0}]

Notably, however, the leaf corresponding to insertion key 0 is not
deallocated, but rather, is converted to a "free leaf" with an
empty sub-queue.


<a name="@Free_leaves_21"></a>

### Free leaves


Free leaves are leaf nodes with an empty sub-queue.

Free leaves track insertion counts in case another key-value
insertion pair, having the insertion key encoded in the free leaf
key, is inserted. Here, the free leaf is added back to the crit-bit
tree and the new sub-queue node becomes the head of the leaf's
sub-queue. Continuing the example, inserting another key-value pair
with insertion key 0, $k_{0, 3}$, produces:

>                        64th
>                       /    \
>     000...000000...000      000...001000...000
>             [k_{0, 3}]      [k_{1, 0}]


<a name="@Dequeues_22"></a>

### Dequeues


Dequeues are processed as removals from the crit-queue head, a field
that stores:

* The maximum access key in a descending crit-queue, or
* The minimum access key in an ascending crit-queue.

After all elements in the corresponding sub-queue have been dequeued
in order of ascending insertion count, dequeueing proceeds with the
head of the sub-queue in the next leaf, which is accessed by either:

* Inorder predecessor traversal if a descending crit-queue, or
* Inorder successor traversal if an ascending crit-queue.


<a name="@Implementation_analysis_23"></a>

## Implementation analysis



<a name="@Core_functionality_24"></a>

### Core functionality


In the present implementation, key-value insertion pairs are
inserted via <code><a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>()</code>, which accepts a <code>u64</code> insertion key and
insertion value of type <code>V</code>. A corresponding <code>u128</code> access key is
returned, which can be used for subsequent access key lookup via <code>
<a href="critqueue.md#0xc0deb00c_critqueue_borrow">borrow</a>()</code>, <code><a href="critqueue.md#0xc0deb00c_critqueue_borrow_mut">borrow_mut</a>()</code>, <code>dequeue()</code>, or <code>remove()</code>.


<a name="@Inserting_25"></a>

### Inserting


Insertions are, like a crit-bit tree, $O(k)$ in the worst case,
where $k = 64$ (the number of variable bits in an insertion key),
since a new leaf node has to be inserted into the crit-bit tree.
In the intermediate case where a new leaf node has to be inserted
into the crit-bit tree but the tree is generally balanced,
insertions improve to $O(log_2(n))$, where $n$ is the number of
leaves in the tree. In the best case, where the corresponding
sub-queue already has a leaf in the crit-bit tree and a new
sub-queue node simply has to be inserted at the tail of the
sub-queue, insertions improve to $O(1)$.

Insertions are parallelizable in the general case where:

1. They do not alter the head of the crit-queue.
2. They do not write to overlapping crit-bit tree edges.
3. They do not write to overlapping sub-queue edges.
4. They alter neither the head nor the tail of the same sub-queue.
5. They do not write to the same sub-queue.

The final parallelism constraint is a result of insertion count
updates, and may potentially be eliminated in the case of a
parallelized insertion count aggregator.


<a name="@Removing_26"></a>

### Removing


With sub-queue nodes stored in a hash table, removal operations via
access key are are thus $O(1)$, and are parallelizable in the
general case where:

1. They do not alter the head of the crit-queue.
2. They do not write to overlapping crit-bit tree edges.
3. They do not write to overlapping sub-queue edges.
4. They alter neither the head nor the tail of the same sub-queue.


<a name="@Dequeuing_27"></a>

### Dequeuing


Dequeues, as a form of removal, are $O(1)$, but since they alter
the head of the queue, they are not parallelizable. Dequeues
are initialized via <code>dequeue_init()</code>, and iterated via <code>dequeue()</code>.

---


-  [Module-level documentation sections](#@Module-level_documentation_sections_0)
-  [Bit conventions](#@Bit_conventions_1)
    -  [Number](#@Number_2)
    -  [Status](#@Status_3)
    -  [Masking](#@Masking_4)
-  [Crit-bit trees](#@Crit-bit_trees_5)
    -  [General](#@General_6)
    -  [Structure](#@Structure_7)
    -  [Insertions](#@Insertions_8)
    -  [Removals](#@Removals_9)
    -  [As a map](#@As_a_map_10)
    -  [References](#@References_11)
-  [Crit-queues](#@Crit-queues_12)
    -  [Key storage multiplicity](#@Key_storage_multiplicity_13)
    -  [Sorting order](#@Sorting_order_14)
    -  [Leaves](#@Leaves_15)
    -  [Sub-queue nodes](#@Sub-queue_nodes_16)
    -  [Inner keys](#@Inner_keys_17)
    -  [Insertion counts](#@Insertion_counts_18)
    -  [Dequeue order preservation](#@Dequeue_order_preservation_19)
    -  [Sub-queue removal updates](#@Sub-queue_removal_updates_20)
    -  [Free leaves](#@Free_leaves_21)
    -  [Dequeues](#@Dequeues_22)
-  [Implementation analysis](#@Implementation_analysis_23)
    -  [Core functionality](#@Core_functionality_24)
    -  [Inserting](#@Inserting_25)
    -  [Removing](#@Removing_26)
    -  [Dequeuing](#@Dequeuing_27)
-  [Struct `CritQueue`](#0xc0deb00c_critqueue_CritQueue)
-  [Struct `Inner`](#0xc0deb00c_critqueue_Inner)
-  [Struct `Leaf`](#0xc0deb00c_critqueue_Leaf)
-  [Struct `SubQueueNode`](#0xc0deb00c_critqueue_SubQueueNode)
-  [Constants](#@Constants_28)
-  [Function `borrow`](#0xc0deb00c_critqueue_borrow)
-  [Function `borrow_mut`](#0xc0deb00c_critqueue_borrow_mut)
-  [Function `get_head_access_key`](#0xc0deb00c_critqueue_get_head_access_key)
-  [Function `has_access_key`](#0xc0deb00c_critqueue_has_access_key)
-  [Function `insert`](#0xc0deb00c_critqueue_insert)
-  [Function `is_empty`](#0xc0deb00c_critqueue_is_empty)
-  [Function `new`](#0xc0deb00c_critqueue_new)
-  [Function `would_become_new_head`](#0xc0deb00c_critqueue_would_become_new_head)
-  [Function `would_trail_head`](#0xc0deb00c_critqueue_would_trail_head)
-  [Function `get_critical_bitmask`](#0xc0deb00c_critqueue_get_critical_bitmask)
    -  [<code>XOR</code>/<code>AND</code> method](#@<code>XOR</code>/<code>AND</code>_method_29)
    -  [Binary search method](#@Binary_search_method_30)
-  [Function `insert_allocate_leaf`](#0xc0deb00c_critqueue_insert_allocate_leaf)
    -  [Returns](#@Returns_31)
    -  [Assumptions](#@Assumptions_32)
-  [Function `insert_check_head`](#0xc0deb00c_critqueue_insert_check_head)
-  [Function `insert_leaf_general_below`](#0xc0deb00c_critqueue_insert_leaf_general_below)
    -  [Parameters](#@Parameters_33)
    -  [Assumptions](#@Assumptions_34)
    -  [Reference diagrams](#@Reference_diagrams_35)
        -  [Anchor node children polarity](#@Anchor_node_children_polarity_36)
        -  [Child displacement](#@Child_displacement_37)
        -  [New inner node children polarity](#@New_inner_node_children_polarity_38)
        -  [Testing](#@Testing_39)
-  [Function `insert_update_subqueue`](#0xc0deb00c_critqueue_insert_update_subqueue)
    -  [Returns](#@Returns_40)
    -  [Assumptions](#@Assumptions_41)
    -  [Aborts if](#@Aborts_if_42)
-  [Function `is_inner_key`](#0xc0deb00c_critqueue_is_inner_key)
-  [Function `is_leaf_key`](#0xc0deb00c_critqueue_is_leaf_key)
-  [Function `is_set`](#0xc0deb00c_critqueue_is_set)
-  [Function `search`](#0xc0deb00c_critqueue_search)
    -  [Returns](#@Returns_43)
    -  [Assumptions](#@Assumptions_44)
    -  [Reference diagrams](#@Reference_diagrams_45)
        -  [Leaf at root](#@Leaf_at_root_46)
        -  [Inner node at root](#@Inner_node_at_root_47)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table</a>;
</code></pre>



<a name="0xc0deb00c_critqueue_CritQueue"></a>

## Struct `CritQueue`

Hybrid between a crit-bit tree and a queue. See above.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>order: bool</code>
</dt>
<dd>
 Crit-queue sort order, <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.
</dd>
<dt>
<code>root: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Node key of crit-bit tree root. None if crit-queue is empty.
</dd>
<dt>
<code>head: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Access key of crit-queue head. None if crit-queue is empty,
 else minimum access key if ascending crit-queue, and
 maximum access key if descending crit-queue.
</dd>
<dt>
<code>inners: <a href="_Table">table::Table</a>&lt;u128, <a href="critqueue.md#0xc0deb00c_critqueue_Inner">critqueue::Inner</a>&gt;</code>
</dt>
<dd>
 Map from inner key to inner node.
</dd>
<dt>
<code>leaves: <a href="_Table">table::Table</a>&lt;u128, <a href="critqueue.md#0xc0deb00c_critqueue_Leaf">critqueue::Leaf</a>&gt;</code>
</dt>
<dd>
 Map from leaf key to leaf node.
</dd>
<dt>
<code>subqueue_nodes: <a href="_Table">table::Table</a>&lt;u128, <a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">critqueue::SubQueueNode</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Map from access key to sub-queue node.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_Inner"></a>

## Struct `Inner`

A crit-bit tree inner node.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bitmask: u128</code>
</dt>
<dd>
 Bitmask set at critical bit.
</dd>
<dt>
<code>parent: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 If none, node is root. Else parent key.
</dd>
<dt>
<code>left: u128</code>
</dt>
<dd>
 Left child key.
</dd>
<dt>
<code>right: u128</code>
</dt>
<dd>
 Right child key.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_Leaf"></a>

## Struct `Leaf`

A crit-bit tree leaf node. A free leaf if no sub-queue head.
Else the root of the crit-bit tree if no parent.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>count: u64</code>
</dt>
<dd>
 0-indexed insertion count for corresponding insertion key.
</dd>
<dt>
<code>parent: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 If no sub-queue head or tail, should also be none, since
 leaf is a free leaf. Else corresponds to the inner key of
 the leaf's parent node, none when leaf is the root of the
 crit-bit tree.
</dd>
<dt>
<code>head: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 If none, node is a free leaf. Else the access key of the
 sub-queue head.
</dd>
<dt>
<code>tail: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 If none, node is a free leaf. Else the access key of the
 sub-queue tail.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_SubQueueNode"></a>

## Struct `SubQueueNode`

A node in a sub-queue.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">SubQueueNode</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>insertion_value: V</code>
</dt>
<dd>
 Insertion value.
</dd>
<dt>
<code>previous: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Access key of previous sub-queue node, if any.
</dd>
<dt>
<code>next: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Access key of next sub-queue node, if any.
</dd>
</dl>


</details>

<a name="@Constants_28"></a>

## Constants


<a name="0xc0deb00c_critqueue_ACCESS_KEY_TO_INNER_KEY"></a>

<code>u128</code> bitmask set at bit 63, for converting an access key
to an inner key via bitwise <code>OR</code>. Generated in Python via
<code>hex(int('1' + '0' * 63, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ACCESS_KEY_TO_INNER_KEY">ACCESS_KEY_TO_INNER_KEY</a>: u128 = 9223372036854775808;
</code></pre>



<a name="0xc0deb00c_critqueue_ACCESS_KEY_TO_LEAF_KEY"></a>

<code>u128</code> bitmask set at bits 64-127, for converting an access key
to a leaf key via bitwise <code>AND</code>. Generated in Python via
<code>hex(int('1' * 64 + '0' * 64, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ACCESS_KEY_TO_LEAF_KEY">ACCESS_KEY_TO_LEAF_KEY</a>: u128 = 340282366920938463444927863358058659840;
</code></pre>



<a name="0xc0deb00c_critqueue_ASCENDING"></a>

Ascending crit-queue flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_DESCENDING"></a>

Descending crit-queue flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_E_TOO_MANY_INSERTIONS"></a>

When an insertion key has been inserted too many times.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_E_TOO_MANY_INSERTIONS">E_TOO_MANY_INSERTIONS</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_critqueue_HI_128"></a>

<code>u128</code> bitmask with all bits set, generated in Python via
<code>hex(int('1' * 128, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_critqueue_HI_64"></a>

<code>u64</code> bitmask with all bits set, generated in Python via
<code>hex(int('1' * 64, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_critqueue_INSERTION_KEY"></a>

Number of bits that insertion key is shifted in a <code>u128</code> key.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_INSERTION_KEY">INSERTION_KEY</a>: u8 = 64;
</code></pre>



<a name="0xc0deb00c_critqueue_MAX_INSERTION_COUNT"></a>

Maximum number of times a given insertion key can be inserted.
A <code>u64</code> bitmask with all bits set except 62 and 63, generated
in Python via <code>hex(int('1' * 62, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_MAX_INSERTION_COUNT">MAX_INSERTION_COUNT</a>: u64 = 4611686018427387903;
</code></pre>



<a name="0xc0deb00c_critqueue_MSB_u128"></a>

Most significant bit number for a <code>u128</code>


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_MSB_u128">MSB_u128</a>: u8 = 127;
</code></pre>



<a name="0xc0deb00c_critqueue_NOT_INSERTION_COUNT_DESCENDING"></a>

<code>XOR</code> bitmask for flipping insertion count bits 0-61 and
setting bit 62 high in the case of a descending crit-queue.
<code>u64</code> bitmask with all bits set except bit 63, cast to a <code>u128</code>.
Generated in Python via <code>hex(int('1' * 63, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_NOT_INSERTION_COUNT_DESCENDING">NOT_INSERTION_COUNT_DESCENDING</a>: u128 = 9223372036854775807;
</code></pre>



<a name="0xc0deb00c_critqueue_TREE_NODE_INNER"></a>

Result of bitwise crit-bit tree node key <code>AND</code> with
<code><a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a></code>, indicating that the key is set at bit 63 and
is thus an inner key. Generated in Python via
<code>hex(int('1' + '0' * 63, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_INNER">TREE_NODE_INNER</a>: u128 = 9223372036854775808;
</code></pre>



<a name="0xc0deb00c_critqueue_TREE_NODE_LEAF"></a>

Result of bitwise crit-bit tree node key <code>AND</code> with
<code><a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a></code>, indicating that the key is unset at bit 63
and is thus a leaf key.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_LEAF">TREE_NODE_LEAF</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_critqueue_TREE_NODE_TYPE"></a>

<code>u128</code> bitmask set at bit 63, the crit-bit tree node type
bit flag, generated in Python via <code>hex(int('1' + '0' * 63, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a>: u128 = 9223372036854775808;
</code></pre>



<a name="0xc0deb00c_critqueue_borrow"></a>

## Function `borrow`

Borrow insertion value corresponding to <code>access_key</code> in given
<code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>, aborting if no such access key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow">borrow</a>&lt;V&gt;(critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, access_key: u128): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow">borrow</a>&lt;V&gt;(
    critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    access_key: u128
): &V {
    &<a href="_borrow">table::borrow</a>(
        &critqueue_ref.subqueue_nodes, access_key).insertion_value
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_borrow_mut"></a>

## Function `borrow_mut`

Mutably borrow insertion value corresponding to <code>access_key</code>
<code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>, aborting if no such access key


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow_mut">borrow_mut</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, access_key: u128): &<b>mut</b> V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow_mut">borrow_mut</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    access_key: u128
): &<b>mut</b> V {
    &<b>mut</b> <a href="_borrow_mut">table::borrow_mut</a>(
        &<b>mut</b> critqueue_ref_mut.subqueue_nodes, access_key).insertion_value
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_get_head_access_key"></a>

## Function `get_head_access_key`

Return access key of given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> head, if any.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_head_access_key">get_head_access_key</a>&lt;V&gt;(critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;): <a href="_Option">option::Option</a>&lt;u128&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_head_access_key">get_head_access_key</a>&lt;V&gt;(
    critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
): Option&lt;u128&gt; {
    critqueue_ref.head
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_has_access_key"></a>

## Function `has_access_key`

Return <code><b>true</b></code> if given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> has the given <code>access_key</code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_has_access_key">has_access_key</a>&lt;V&gt;(critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, access_key: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_has_access_key">has_access_key</a>&lt;V&gt;(
    critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    access_key: u128
): bool {
    <a href="_contains">table::contains</a>(&critqueue_ref.subqueue_nodes, access_key)
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_insert"></a>

## Function `insert`

Insert the given <code>key</code>-<code>value</code> insertion pair into the given
<code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>, returning an access key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, insertion_key: u64, insertion_value: V): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    insertion_key: u64,
    insertion_value: V
): u128 {
    // Initialize a sub-queue node <b>with</b> the insertion value,
    // assuming it is the sole sub-queue node in a free leaf.
    <b>let</b> subqueue_node = <a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">SubQueueNode</a>{insertion_value,
        previous: <a href="_none">option::none</a>(), next: <a href="_none">option::none</a>()};
    // Get leaf key from insertion key.
    <b>let</b> leaf_key = (insertion_key <b>as</b> u128) &lt;&lt; <a href="critqueue.md#0xc0deb00c_critqueue_INSERTION_KEY">INSERTION_KEY</a>;
    // Borrow mutable reference <b>to</b> leaves <a href="">table</a>.
    <b>let</b> leaves_ref_mut = &<b>mut</b> critqueue_ref_mut.leaves;
    // Determine <b>if</b> corresponding leaf <b>has</b> already been allocated.
    <b>let</b> leaf_already_allocated = <a href="_contains">table::contains</a>(leaves_ref_mut, leaf_key);
    // Get access key for new sub-queue node, and <b>if</b> corresponding
    // leaf node is a free leaf. If leaf is already allocated:
    <b>let</b> (access_key, _free_leaf) = <b>if</b> (leaf_already_allocated)
        // Update its sub-queue and the new sub-queue node, storing
        // the access key of the new sub-queue node and <b>if</b> the
        // corresponding leaf is free.
        <a href="critqueue.md#0xc0deb00c_critqueue_insert_update_subqueue">insert_update_subqueue</a>(
            critqueue_ref_mut, &<b>mut</b> subqueue_node, leaf_key)
        // Otherwise, store access key of the new sub-queue node,
        // found in a newly-allocated free leaf.
        <b>else</b> (<a href="critqueue.md#0xc0deb00c_critqueue_insert_allocate_leaf">insert_allocate_leaf</a>(critqueue_ref_mut, leaf_key), <b>true</b>);
    // Borrow mutable reference <b>to</b> sub-queue nodes <a href="">table</a>.
    <b>let</b> subqueue_nodes_ref_mut = &<b>mut</b> critqueue_ref_mut.subqueue_nodes;
    // Add new sub-queue node <b>to</b> the sub-queue nodes <a href="">table</a>.
    <a href="_add">table::add</a>(subqueue_nodes_ref_mut, access_key, subqueue_node);
    // Check the crit-queue head, updating <b>as</b> necessary.
    <a href="critqueue.md#0xc0deb00c_critqueue_insert_check_head">insert_check_head</a>(critqueue_ref_mut, access_key);
    // <b>if</b> (free_leaf) insert_leaf(critqueue_ref_mut, access_key);
    access_key // Return access key.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> is empty.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_empty">is_empty</a>&lt;V&gt;(critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_empty">is_empty</a>&lt;V&gt;(
    critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
): bool {
    <a href="_is_none">option::is_none</a>(&critqueue_ref.root)
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_new"></a>

## Function `new`

Return <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> of sort <code>order</code> <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V: store&gt;(order: bool): <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V: store&gt;(
    order: bool
): <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt; {
    <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>{
        order,
        root: <a href="_none">option::none</a>(),
        head: <a href="_none">option::none</a>(),
        inners: <a href="_new">table::new</a>(),
        leaves: <a href="_new">table::new</a>(),
        subqueue_nodes: <a href="_new">table::new</a>()
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_would_become_new_head"></a>

## Function `would_become_new_head`

Return <code><b>true</b></code> if, were <code>insertion_key</code> to be inserted, its
access key would become the new head of the given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_would_become_new_head">would_become_new_head</a>&lt;V&gt;(critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, insertion_key: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_would_become_new_head">would_become_new_head</a>&lt;V&gt;(
    critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    insertion_key: u64
): bool {
    // If the crit-queue is empty and thus <b>has</b> no head:
    <b>if</b> (<a href="_is_none">option::is_none</a>(&critqueue_ref.head)) {
        // Return that insertion key would become new head.
        <b>return</b> <b>true</b>
    } <b>else</b> { // Otherwise, <b>if</b> crit-queue is not empty:
        // Get insertion key of crit-queue head.
        <b>let</b> head_insertion_key = (*<a href="_borrow">option::borrow</a>(&critqueue_ref.head) &gt;&gt;
            <a href="critqueue.md#0xc0deb00c_critqueue_INSERTION_KEY">INSERTION_KEY</a> <b>as</b> u64);
        // If an ascending crit-queue, <b>return</b> <b>true</b> <b>if</b> insertion key
        // is less than insertion key of crit-queue head.
        <b>return</b> <b>if</b> (critqueue_ref.order == <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>)
            insertion_key &lt; head_insertion_key <b>else</b>
            // If a descending crit-queue, <b>return</b> <b>true</b> <b>if</b> insertion
            // key is greater than insertion key of crit-queue head.
            insertion_key &gt; head_insertion_key
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_would_trail_head"></a>

## Function `would_trail_head`

Return <code><b>true</b></code> if, were <code>insertion_key</code> to be inserted, its
access key would trail behind the head of the given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_would_trail_head">would_trail_head</a>&lt;V&gt;(critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, insertion_key: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_would_trail_head">would_trail_head</a>&lt;V&gt;(
    critqueue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    insertion_key: u64
): bool {
    !<a href="critqueue.md#0xc0deb00c_critqueue_would_become_new_head">would_become_new_head</a>(critqueue_ref, insertion_key)
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_get_critical_bitmask"></a>

## Function `get_critical_bitmask`

Return a bitmask set at the most significant bit at which two
unequal bitstrings, <code>s1</code> and <code>s2</code>, vary.


<a name="@<code>XOR</code>/<code>AND</code>_method_29"></a>

### <code>XOR</code>/<code>AND</code> method


Frist, a bitwise <code>XOR</code> is used to flag all differing bits:

>              s1: 11110001
>              s2: 11011100
>     x = s1 ^ s2: 00101101
>                    ^ critical bit = 5

Here, the critical bit is equivalent to the bit number of the
most significant set bit in the bitwise <code>XOR</code> result
<code>x = s1 ^ s2</code>. At this point, [Langley 2008] notes that <code>x</code>
bitwise <code>AND</code> <code>x - 1</code> will be nonzero so long as <code>x</code> contains
at least some bits set which are of lesser significance than the
critical bit:

>                   x: 00101101
>               x - 1: 00101100
>     x = x & (x - 1): 00101100

Thus he suggests repeating <code>x & (x - 1)</code> while the new result
<code>x = x & (x - 1)</code> is not equal to zero, because such a loop will
eventually reduce <code>x</code> to a power of two (excepting the trivial
case where <code>x</code> starts as all 0 except bit 0 set, for which the
loop never enters past the initial conditional check). Per this
method, using the new <code>x</code> value for the current example, the
second iteration proceeds as follows:

>                   x: 00101100
>               x - 1: 00101011
>     x = x & (x - 1): 00101000

The third iteration:

>                   x: 00101000
>               x - 1: 00100111
>     x = x & (x - 1): 00100000
Now, <code>x & x - 1</code> will equal zero and the loop will not begin a
fourth iteration:

>                 x: 00100000
>             x - 1: 00011111
>     x AND (x - 1): 00000000

Thus after three iterations a corresponding critical bitmask
has been determined. However, in the case where the two input
strings vary at all bits of lesser significance than the
critical bit, there may be required as many as <code>k - 1</code>
iterations, where <code>k</code> is the number of bits in each string under
comparison. For instance, consider the case of the two 8-bit
strings <code>s1</code> and <code>s2</code> as follows:

>                  s1: 10101010
>                  s2: 01010101
>         x = s1 ^ s2: 11111111
>                      ^ critical bit = 7
>     x = x & (x - 1): 11111110 [iteration 1]
>     x = x & (x - 1): 11111100 [iteration 2]
>     x = x & (x - 1): 11111000 [iteration 3]
>     ...

Notably, this method is only suggested after already having
identified the varying byte between the two strings, thus
limiting <code>x & (x - 1)</code> operations to at most 7 iterations.


<a name="@Binary_search_method_30"></a>

### Binary search method


For the present implementation, unlike in [Langley 2008],
strings are not partitioned into a multi-byte array, rather,
they are stored as <code>u128</code> integers, so a binary search is
instead proposed. Here, the same <code>x = s1 ^ s2</code> operation is
first used to identify all differing bits, before iterating on
an upper (<code>u</code>) and lower bound (<code>l</code>) for the critical bit
number:

>              s1: 10101010
>              s2: 01010101
>     x = s1 ^ s2: 11111111
>            u = 7 ^      ^ l = 0

The upper bound <code>u</code> is initialized to the length of the
bitstring (7 in this example, but 127 for a <code>u128</code>), and the
lower bound <code>l</code> is initialized to 0. Next the midpoint <code>m</code> is
calculated as the average of <code>u</code> and <code>l</code>, in this case
<code>m = (7 + 0) / 2 = 3</code>, per truncating integer division. Finally,
the shifted compare value <code>s = x &gt;&gt; m</code> is calculated, with the
result having three potential outcomes:

| Shift result | Outcome                              |
|--------------|--------------------------------------|
| <code>s == 1</code>     | The critical bit <code>c</code> is equal to <code>m</code> |
| <code>s == 0</code>     | <code>c &lt; m</code>, so set <code>u</code> to <code>m - 1</code>       |
| <code>s &gt; 1</code>      | <code>c &gt; m</code>, so set <code>l</code> to <code>m + 1</code>       |

Hence, continuing the current example:

>              x: 11111111
>     s = x >> m: 00011111

<code>s &gt; 1</code>, so <code>l = m + 1 = 4</code>, and the search window has shrunk:

>     x = s1 ^ s2: 11111111
>            u = 7 ^  ^ l = 4

Updating the midpoint yields <code>m = (7 + 4) / 2 = 5</code>:

>              x: 11111111
>     s = x >> m: 00000111

Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 6</code>, and the window
shrinks again:

>     x = s1 ^ s2: 11111111
>            u = 7 ^^ l = 6
>      s = x >> m: 00000011

Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 7</code>, the final iteration:

>     x = s1 ^ s2: 11111111
>            u = 7 ^ l = 7
>      s = x >> m: 00000001

Here, <code>s == 1</code>, which means that <code>c = m = 7</code>, and the
corresponding critical bitmask <code>1 &lt;&lt; c</code> is returned:

>         s1: 10101010
>         s2: 01010101
>     1 << c: 10000000

Notably this search has converged after only 3 iterations, as
opposed to 7 for the linear search proposed above, and in
general such a search converges after $log_2(k)$ iterations at
most, where $k$ is the number of bits in each of the strings
<code>s1</code> and <code>s2</code> under comparison. Hence this search method
improves the $O(k)$ search proposed by [Langley 2008] to
$O(log_2(k))$.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_critical_bitmask">get_critical_bitmask</a>(s1: u128, s2: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_critical_bitmask">get_critical_bitmask</a>(
    s1: u128,
    s2: u128,
): u128 {
    <b>let</b> x = s1 ^ s2; // XOR result marked 1 at bits that differ.
    <b>let</b> l = 0; // Lower bound on critical bit search.
    <b>let</b> u = <a href="critqueue.md#0xc0deb00c_critqueue_MSB_u128">MSB_u128</a>; // Upper bound on critical bit search.
    <b>loop</b> { // Begin binary search.
        <b>let</b> m = (l + u) / 2; // Calculate midpoint of search window.
        <b>let</b> s = x &gt;&gt; m; // Calculate midpoint shift of XOR result.
        <b>if</b> (s == 1) <b>return</b> 1 &lt;&lt; m; // If shift equals 1, c = m.
        // Update search bounds.
        <b>if</b> (s &gt; 1) l = m + 1 <b>else</b> u = m - 1;
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_insert_allocate_leaf"></a>

## Function `insert_allocate_leaf`

Allocate a leaf during insertion.

Inner function for <code><a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>()</code>.


<a name="@Returns_31"></a>

### Returns

* <code>u128</code>: Access key of new sub-queue node.


<a name="@Assumptions_32"></a>

### Assumptions

* <code>critqueue_ref_mut</code> indicates a <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> that does not have
an allocated leaf with the given <code>leaf_key</code>.
* A <code><a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">SubQueueNode</a></code> with the appropriate access key has been
initialized as if it were the sole sub-queue node in a free
leaf.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_allocate_leaf">insert_allocate_leaf</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, leaf_key: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_allocate_leaf">insert_allocate_leaf</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    leaf_key: u128
): u128 {
    // Get the sort order of the crit-queue.
    <b>let</b> order = critqueue_ref_mut.order;
    // Get access key. If ascending, is identical <b>to</b> leaf key, which
    // <b>has</b> insertion count in bits 64-127 and 0 for bits 0-63.
    <b>let</b> access_key = <b>if</b> (order == <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>) leaf_key <b>else</b>
        // Else same, but flipped insertion count and bit 63 set.
        leaf_key  ^ <a href="critqueue.md#0xc0deb00c_critqueue_NOT_INSERTION_COUNT_DESCENDING">NOT_INSERTION_COUNT_DESCENDING</a>;
    // Declare leaf <b>with</b> insertion count 0, no parent, and new
    // sub-queue node <b>as</b> both head and tail.
    <b>let</b> leaf = <a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a>{count: 0, parent: <a href="_none">option::none</a>(), head:
        <a href="_some">option::some</a>(access_key), tail: <a href="_some">option::some</a>(access_key)};
    // Borrow mutable reference <b>to</b> leaves <a href="">table</a>.
    <b>let</b> leaves_ref_mut = &<b>mut</b> critqueue_ref_mut.leaves;
    // Add the leaf <b>to</b> the leaves <a href="">table</a>.
    <a href="_add">table::add</a>(leaves_ref_mut, leaf_key, leaf);
    access_key // Return access key.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_insert_check_head"></a>

## Function `insert_check_head`

Check head of given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>, optionally setting it to the
<code>access_key</code> of a new key-value insertion pair.

Inner function for <code><a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>()</code>.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_check_head">insert_check_head</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, access_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_check_head">insert_check_head</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    access_key: u128
) {
    // Get crit-queue sort order.
    <b>let</b> order = critqueue_ref_mut.order;
    // Get mutable reference <b>to</b> crit-queue head field.
    <b>let</b> head_ref_mut = &<b>mut</b> critqueue_ref_mut.head;
    <b>if</b> (<a href="_is_none">option::is_none</a>(head_ref_mut)) { // If an empty crit-queue:
        // Set the head <b>to</b> be the new access key.
        <a href="_fill">option::fill</a>(head_ref_mut, access_key);
    } <b>else</b> { // If crit-queue is not empty:
        // If the sort order is ascending and new access key is less
        // than that of the crit-queue head, or
        <b>if</b> ((order == <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a> &&
                access_key &lt; *<a href="_borrow">option::borrow</a>(head_ref_mut)) ||
            // If descending sort order and new access key is
            // greater than that of crit-queue head:
            (order == <a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a> &&
                access_key &gt; *<a href="_borrow">option::borrow</a>(head_ref_mut)))
            // Set new access key <b>as</b> the crit-queue head.
            _ = <a href="_swap">option::swap</a>(head_ref_mut, access_key);
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_insert_leaf_general_below"></a>

## Function `insert_leaf_general_below`

Insert new free leaf and inner node below anchor node.

Inner function for <code>insert_leaf_general()</code>.


<a name="@Parameters_33"></a>

### Parameters

* <code>critqueue_ref_mut</code>: Mutable reference to crit-queue.
* <code>anchor_node_key</code>: Key of the inner node to insert below, the
"anchor node".
* <code>new_inner_node_bitmask</code>: Critical bitmask for new inner node.
* <code>access_key</code>: Access key of the key-value insertion pair just
inserted.


<a name="@Assumptions_34"></a>

### Assumptions

* Given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> has a free leaf with the insertion key
encoded in <code>access_key</code>.
* <code>new_inner_node_bitmask</code> is less than that of anchor node,
which has been reached via upward walk in
<code>insert_leaf_general()</code>.


<a name="@Reference_diagrams_35"></a>

### Reference diagrams


For ease of illustration, critical bitmasks and leaf keys are
depicted relative to bit 64, but tested with correspondingly
bitshifted amounts, for inner keys that are additionally
encoded with a mock insertion key, mock insertion count,
and inner node bit flag.

Both insertion examples reference the following diagram:

>         3rd
>        /   \
>     0001   1st
>           /   \
>        1001   1011


<a name="@Anchor_node_children_polarity_36"></a>

#### Anchor node children polarity


The anchor node is the node below which the free leaf and new
inner node should be inserted, for example either <code>3rd</code> or
<code>1st</code>. The free leaf key can be inserted to either the left or
the right of the anchor node, depending on its whether it is
unset or set, respectively, at the anchor node's critical bit.
For example, per below, a free leaf key of <code>1000</code> would
be inserted to the left of <code>1st</code>, while a free leaf key of
<code>1111</code> would be inserted to the right of <code>3rd</code>.


<a name="@Child_displacement_37"></a>

#### Child displacement


When a leaf key is inserted, a new inner node is generated,
which displaces either the left or the right child of the anchor
node, based on the side that the leaf key should be inserted.
For example, inserting free leaf key <code>1000</code> displaces <code>1001</code>:

>                       3rd
>                      /   \
>                   0001   1st <- anchor node
>                         /   \
>     new inner node -> 0th   1011
>                      /   \
>       new leaf -> 1000   1001 <- displaced child

Both leaves and inner nodes can be displaced. For example,
were free leaf key <code>1111</code> to be inserted instead, it would
displace <code>1st</code>:

>                        3rd <- anchor node
>                       /   \
>                    0001   2nd <- new inner node
>                          /   \
>     displaced child -> 1st   1111 <- new leaf
>                       /   \
>                    1001   1011


<a name="@New_inner_node_children_polarity_38"></a>

#### New inner node children polarity


The new inner node can have the new leaf as either its left or
right child, depending on the new inner node's critical bit.
As in the first example above, where the new leaf is unset at
the new inner node's critical bit, the new inner node's left
child is the new leaf and new inner node's right child is the
displaced child. Conversely, as in the second example above,
where the new leaf is set at the new inner node's critical bit,
the new inner node's left child is the displaced child and the
new inner node's right child is the new leaf.


<a name="@Testing_39"></a>

#### Testing

* <code>test_insert_leaf_general_below_case_1()</code>
* <code>test_insert_leaf_general_below_case_2()</code>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_leaf_general_below">insert_leaf_general_below</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, anchor_node_key: u128, new_inner_node_bitmask: u128, access_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_leaf_general_below">insert_leaf_general_below</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    anchor_node_key: u128,
    new_inner_node_bitmask: u128,
    access_key: u128,
) {
    // Get new leaf key corresponding <b>to</b> access key.
    <b>let</b> new_leaf_key = access_key & <a href="critqueue.md#0xc0deb00c_critqueue_ACCESS_KEY_TO_LEAF_KEY">ACCESS_KEY_TO_LEAF_KEY</a>;
    // Get inner key for new inner node corresponding <b>to</b> access key.
    <b>let</b> new_inner_node_key = access_key | <a href="critqueue.md#0xc0deb00c_critqueue_ACCESS_KEY_TO_INNER_KEY">ACCESS_KEY_TO_INNER_KEY</a>;
    // Borrow mutable reference <b>to</b> inner nodes <a href="">table</a>.
    <b>let</b> inners_ref_mut = &<b>mut</b> critqueue_ref_mut.inners;
    // Borrow mutable reference <b>to</b> leaves <a href="">table</a>.
    <b>let</b> leaves_ref_mut = &<b>mut</b> critqueue_ref_mut.leaves;
    <b>let</b> anchor_node_ref_mut = // Mutably borrow anchor node.
        <a href="_borrow_mut">table::borrow_mut</a>(inners_ref_mut, anchor_node_key);
    // Get anchor node critical bitmask.
    <b>let</b> anchor_bitmask = anchor_node_ref_mut.bitmask;
    <b>let</b> displaced_child_key; // Declare displaced child key.
    // If new leaf key AND anchor bitmask is 0, new leaf is unset
    // at anchor node's critical bit and should thus go on its left:
    <b>if</b> (new_leaf_key & anchor_bitmask == 0) {
        // Displaced child is thus on anchor's left.
        displaced_child_key = anchor_node_ref_mut.left;
        // Anchor node now <b>has</b> <b>as</b> its left child the new inner node.
        anchor_node_ref_mut.left = new_inner_node_key;
    } <b>else</b> { // If new leaf goes <b>to</b> right of anchor node:
        // Displaced child is thus on anchor's right.
        displaced_child_key = anchor_node_ref_mut.right;
        // Anchor node now <b>has</b> the new inner node <b>as</b> right child.
        anchor_node_ref_mut.right = new_inner_node_key;
    };
    // Determine <b>if</b> displaced child is a leaf.
    <b>let</b> displaced_child_is_leaf =
        displaced_child_key & <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a> == <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_LEAF">TREE_NODE_LEAF</a>;
    // Get mutable reference <b>to</b> displaced child's parent field:
    <b>let</b> displaced_child_parent_field_ref_mut = <b>if</b> (displaced_child_is_leaf)
        // If displaced child is a leaf, borrow from leaves <a href="">table</a>.
        &<b>mut</b> <a href="_borrow_mut">table::borrow_mut</a>(leaves_ref_mut, displaced_child_key).parent
            <b>else</b> // Else borrow from inner nodes <a href="">table</a>.
        &<b>mut</b> <a href="_borrow_mut">table::borrow_mut</a>(inners_ref_mut, displaced_child_key).parent;
    // Swap anchor node key in displaced child's parent field <b>with</b>
    // the new inner node key, discarding the anchor node key.
    <a href="_swap">option::swap</a>(displaced_child_parent_field_ref_mut, new_inner_node_key);
    // If new leaf key AND new inner node's critical bitmask is 0,
    // free leaf is unset at new inner node's critical bit and
    // should thus go on its left, <b>with</b> displaced child on new
    // inner node's right. Else the opposite.
    <b>let</b> (left, right) = <b>if</b> (new_leaf_key & new_inner_node_bitmask == 0)
        (new_leaf_key, displaced_child_key) <b>else</b>
        (displaced_child_key, new_leaf_key);
    // Add <b>to</b> inner nodes <a href="">table</a> the new inner node.
    <a href="_add">table::add</a>(inners_ref_mut, new_inner_node_key, <a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a>{left, right,
        bitmask: new_inner_node_bitmask,
        parent: <a href="_some">option::some</a>(anchor_node_key)});
    <b>let</b> new_leaf_ref_mut = // Borrow mutable reference <b>to</b> new leaf.
        <a href="_borrow_mut">table::borrow_mut</a>(leaves_ref_mut, new_leaf_key);
    // Set new leaf <b>to</b> have <b>as</b> its parent the new inner node.
    <a href="_fill">option::fill</a>(&<b>mut</b> new_leaf_ref_mut.parent, new_inner_node_key);
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_insert_update_subqueue"></a>

## Function `insert_update_subqueue`

Update a sub-queue, inside an allocated leaf, during insertion.

Inner function for <code><a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>()</code>.


<a name="@Returns_40"></a>

### Returns

* <code>u128</code>: Access key of new sub-queue node.
* <code>bool</code>: <code><b>true</b></code> if allocated leaf is a free leaf, else <code><b>false</b></code>.


<a name="@Assumptions_41"></a>

### Assumptions

* <code>critqueue_ref_mut</code> indicates a <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> that already
contains an allocated leaf with the given <code>leaf_key</code>.
* <code>subqueue_node_ref_mut</code> indicates a <code><a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">SubQueueNode</a></code> with the
appropriate access key, which has been initialized as if it
were the sole sub-queue node in a free leaf.


<a name="@Aborts_if_42"></a>

### Aborts if

* Insertion key encoded in <code>leaf_key</code> has already been inserted
the maximum number of times.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_update_subqueue">insert_update_subqueue</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, subqueue_node_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">critqueue::SubQueueNode</a>&lt;V&gt;, leaf_key: u128): (u128, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert_update_subqueue">insert_update_subqueue</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    subqueue_node_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">SubQueueNode</a>&lt;V&gt;,
    leaf_key: u128,
): (
    u128,
    bool
) {
    // Get the sort order of the crit-queue.
    <b>let</b> order = critqueue_ref_mut.order;
    // Borrow mutable reference <b>to</b> leaves <a href="">table</a>.
    <b>let</b> leaves_ref_mut = &<b>mut</b> critqueue_ref_mut.leaves;
    // Borrow mutable reference <b>to</b> leaf.
    <b>let</b> leaf_ref_mut = <a href="_borrow_mut">table::borrow_mut</a>(leaves_ref_mut, leaf_key);
    // Get insertion count of new insertion key.
    <b>let</b> count = leaf_ref_mut.count + 1;
    // Assert max insertion count is not exceeded.
    <b>assert</b>!(count &lt;= <a href="critqueue.md#0xc0deb00c_critqueue_MAX_INSERTION_COUNT">MAX_INSERTION_COUNT</a>, <a href="critqueue.md#0xc0deb00c_critqueue_E_TOO_MANY_INSERTIONS">E_TOO_MANY_INSERTIONS</a>);
    // Update leaf insertion counter.
    leaf_ref_mut.count = count;
    // Get access key. If ascending, bits 64-127 are the same <b>as</b> the
    // leaf key, and bits 0-63 are the insertion count.
    <b>let</b> access_key = <b>if</b> (order == <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>) leaf_key | (count <b>as</b> u128)
        // Else same, but flipped insertion count and bit 63 set.
        <b>else</b> (leaf_key | (count <b>as</b> u128)) ^ <a href="critqueue.md#0xc0deb00c_critqueue_NOT_INSERTION_COUNT_DESCENDING">NOT_INSERTION_COUNT_DESCENDING</a>;
    // Get <b>old</b> sub-queue tail field.
    <b>let</b> old_tail = leaf_ref_mut.tail;
    // Set sub-queue <b>to</b> have new sub-queue node <b>as</b> its tail.
    leaf_ref_mut.tail = <a href="_some">option::some</a>(access_key);
    <b>let</b> free_leaf = <b>true</b>; // Assume free leaf.
    <b>if</b> (<a href="_is_none">option::is_none</a>(&old_tail)) { // If leaf is a free leaf:
        // Update sub-queue <b>to</b> have new node <b>as</b> its head.
        leaf_ref_mut.head = <a href="_some">option::some</a>(access_key);
    } <b>else</b> { // If not a free leaf:
        free_leaf = <b>false</b>; // Flag <b>as</b> such.
        // Get the access key of the <b>old</b> sub-queue tail.
        <b>let</b> old_tail_access_key = *<a href="_borrow">option::borrow</a>(&old_tail);
        // Borrow mutable reference <b>to</b> the <b>old</b> sub-queue tail.
        <b>let</b> old_tail_ref_mut = <a href="_borrow_mut">table::borrow_mut</a>(
            &<b>mut</b> critqueue_ref_mut.subqueue_nodes, old_tail_access_key);
        // Set <b>old</b> sub-queue tail <b>to</b> have <b>as</b> its next sub-queue
        // node the new sub-queue node.
        old_tail_ref_mut.next = <a href="_some">option::some</a>(access_key);
        // Set the new sub-queue node <b>to</b> have <b>as</b> its previous
        // sub-queue node the <b>old</b> sub-queue tail.
        subqueue_node_ref_mut.previous = old_tail;
    };
    (access_key, free_leaf) // Return access key and <b>if</b> free leaf.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_is_inner_key"></a>

## Function `is_inner_key`

Return <code><b>true</b></code> if crit-bit tree node <code>key</code> is an inner key.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_inner_key">is_inner_key</a>(key: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_inner_key">is_inner_key</a>(key: u128): bool {key & <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a> == <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_INNER">TREE_NODE_INNER</a>}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_is_leaf_key"></a>

## Function `is_leaf_key`

Return <code><b>true</b></code> if crit-bit tree node <code>key</code> is a leaf key.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_leaf_key">is_leaf_key</a>(key: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_leaf_key">is_leaf_key</a>(key: u128): bool {key & <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a> == <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_LEAF">TREE_NODE_LEAF</a>}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_is_set"></a>

## Function `is_set`

Return <code><b>true</b></code> if <code>key</code> is set at <code>bit_number</code>.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_set">is_set</a>(key: u128, bit_number: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_set">is_set</a>(key: u128, bit_number: u8): bool {key &gt;&gt; bit_number & 1 == 1}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_search"></a>

## Function `search`

Search in given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> for closest match to <code>seed_key</code>.

If root is a leaf, return immediately. Otherwise, starting at
the root, walk down from inner node to inner node, branching
left whenever <code>seed_key</code> is unset at an inner node's critical
bit, and right whenever <code>seed_key</code> is set at an inner node's
critical bit. After arriving at a leaf, known as the "match
leaf", return its leaf key, the inner key of its parent, and the
parent's critical bitmask.


<a name="@Returns_43"></a>

### Returns

* <code>u128</code>: Match leaf key.
* <code>Option&lt;u128&gt;</code>: Match parent inner key, if any.
* <code>Option&lt;u128&gt;</code>: Match parent's critical bitmask, if any.


<a name="@Assumptions_44"></a>

### Assumptions

* Given <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> does not have an empty crit-bit tree.


<a name="@Reference_diagrams_45"></a>

### Reference diagrams


For ease of illustration, critical bitmasks and leaf keys are
depicted relative to bit 64, but tested with correspondingly
bitshifted amounts, for inner keys that are additionally
encoded with a mock insertion key, mock insertion count,
and inner node bit flag.


<a name="@Leaf_at_root_46"></a>

#### Leaf at root


>     111

| <code>seed_key</code> | Match leaf key | Match parent bitmask |
|------------|----------------|----------------------|
| Any        | <code>111</code>          | None                 |


<a name="@Inner_node_at_root_47"></a>

#### Inner node at root


>        2nd
>       /   \
>     001   1st
>          /   \
>        101   111

| <code>seed_key</code> | Match leaf key  | Match parent bitmask  |
|------------|-----------------|-----------------------|
| <code>011</code>      | <code>001</code>           | <code>2nd</code>                 |
| <code>100</code>      | <code>101</code>           | <code>1st</code>                 |
| <code>111</code>      | <code>111</code>           | <code>1st</code>                 |

See <code>test_search()</code>.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_search">search</a>&lt;V&gt;(critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, seed_key: u128): (u128, <a href="_Option">option::Option</a>&lt;u128&gt;, <a href="_Option">option::Option</a>&lt;u128&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_search">search</a>&lt;V&gt;(
    critqueue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    seed_key: u128
): (
    u128,
    Option&lt;u128&gt;,
    Option&lt;u128&gt;
) {
    // Get crit-queue root key.
    <b>let</b> root_key = *<a href="_borrow">option::borrow</a>(&critqueue_ref_mut.root);
    // If root is a leaf, <b>return</b> its leaf key, and indicate that
    // it does not have a parent.
    <b>if</b> (root_key & <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a> == <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_LEAF">TREE_NODE_LEAF</a>) <b>return</b>
        (root_key, <a href="_none">option::none</a>(), <a href="_none">option::none</a>());
    <b>let</b> parent_key = root_key; // Otherwise begin walk from root.
    // Borrow mutable reference <b>to</b> <a href="">table</a> of inner nodes.
    <b>let</b> inners_ref_mut = &<b>mut</b> critqueue_ref_mut.inners;
    // Initialize match parent <b>to</b> corresponding node.
    <b>let</b> parent_ref_mut = <a href="_borrow_mut">table::borrow_mut</a>(inners_ref_mut, parent_key);
    <b>loop</b> { // Loop over inner nodes until arriving at a leaf:
        // Get bitmask of inner node for current iteration.
        <b>let</b> parent_bitmask = parent_ref_mut.bitmask;
        // If leaf key AND inner node's critical bitmask is 0, then
        // the leaf key is unset at the critical bit, so branch <b>to</b>
        // the inner node's left child. Else the right child.
        <b>let</b> child_key = <b>if</b> (seed_key & parent_bitmask == 0)
            parent_ref_mut.left <b>else</b> parent_ref_mut.right;
        // If child is a leaf, have arrived at the match leaf.
        <b>if</b> (child_key & <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_TYPE">TREE_NODE_TYPE</a> == <a href="critqueue.md#0xc0deb00c_critqueue_TREE_NODE_LEAF">TREE_NODE_LEAF</a>) <b>return</b>
            // So <b>return</b> the match leaf key, the inner key of the
            // match parent, and the match parent's bitmask, <b>with</b>
            // the latter two packed in an <a href="">option</a>
            (child_key, <a href="_some">option::some</a>(parent_key),
                <a href="_some">option::some</a>(parent_bitmask));
        // If have not returned, child is an inner node, so inner
        // key for next iteration becomes parent key.
        parent_key = child_key;
        // Borrow mutable reference <b>to</b> new inner node <b>to</b> check.
        parent_ref_mut = <a href="_borrow_mut">table::borrow_mut</a>(inners_ref_mut, parent_key);
    }
}
</code></pre>



</details>
