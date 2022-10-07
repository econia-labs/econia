
<a name="0xc0deb00c_critqueue"></a>

# Module `0xc0deb00c::critqueue`


<a name="@Bit_conventions_0"></a>

## Bit conventions



<a name="@Number_1"></a>

### Number


Bit numbers are 0-indexed from the least-significant bit (LSB):

>     11101...1010010101
>       bit 5 = 0 ^    ^ bit 0 = 1


<a name="@Status_2"></a>

### Status


<code>0</code> is considered an "unset" bit, and <code>1</code> is considered a "set" bit.
Hence <code>11101</code> is set at bit 0 and unset at bit 1.


<a name="@Masking_3"></a>

### Masking


In the present implementation, a bitmask refers to a bitstring that
is only set at the indicated bit. For example, a bitmask with bit 0
set corresponds to <code>000...001</code>, and a bitmask with bit 3 set
corresponds to <code>000...01000</code>.


<a name="@Critbit_trees_4"></a>

## Critbit trees



<a name="@General_5"></a>

### General


A critical bit (critbit) tree is a compact binary prefix tree that
stores a prefix-free set of bitstrings, like n-bit integers or
variable-length 0-terminated byte strings. For a given set of keys
there exists a unique critbit tree representing the set, such that
critbit trees do not require complex rebalancing algorithms like
those of AVL or red-black binary search trees. Critbit trees support
the following operations:

* Membership testing
* Insertion
* Deletion
* Inorder predecessor iteration
* Inorder successor iteration


<a name="@Structure_6"></a>

### Structure


Critbit trees have two types of nodes: inner nodes and outer nodes.
Inner nodes have two children each, and outer nodes do not have
children. Inner nodes store an integer indicating the
most-significant critical bit (critbit) of divergence between keys
from the node's two subtrees: keys in an inner node's left subtree
are unset at the critical bit, while keys in an inner node's right
subtree are set at the critical bit.

Inner nodes are arranged hierarchically, with the most-significant
critical bits at the top of the tree. For example, the binary keys
<code>001</code>, <code>101</code>, <code>110</code>, and <code>111</code> produce the following critbit tree:

>        2nd
>       /   \
>     001   1st
>          /   \
>        101   0th
>             /   \
>           110   111

Here, the inner node marked <code>2nd</code> stores the integer 2, the inner
node marked <code>1st</code> stores the integer 1, and the inner node marked
<code>0th</code> stores the integer 0. Hence, the sole key in the left
subtree of <code>2nd</code> is unset at bit 2, while all the keys in the
right subtree of <code>2nd</code> are set at bit 2. And similarly for <code>0th</code>,
the key of its left child is unset at bit 0, while the key of its
right child is set at bit 0.


<a name="@Insertions_7"></a>

### Insertions


Critbit trees are automatically sorted upon insertion, such that
inserting <code>111</code> to

>        2nd
>       /   \
>     001   1st
>          /   \
>        101    110

produces:

>                    2nd
>                   /   \
>                 001   1st <- has new right child
>                      /   \
>                    101   0th <- new inner node
>                         /   \
>     has new parent -> 110   111 <- new outer node

Here, <code>111</code> may not be re-inserted unless it is first removed from
the tree.


<a name="@Removals_8"></a>

### Removals


Continuing the above example, critbit trees are automatically
compacted and sorted upon removal, such that removing <code>111</code> again
results in:

>        2nd
>       /   \
>     001   1st <- has new right child
>          /   \
>        101    110 <- has new parent


<a name="@As_a_map_9"></a>

### As a map


Critbit trees can be used as an associative array that maps from
keys to values, simply by storing values in outer nodes of the tree.
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


<a name="@References_10"></a>

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


<a name="@Critqueues_11"></a>

## Critqueues



<a name="@Key_storage_multiplicity_12"></a>

### Key storage multiplicity


Unlike a critbit tree, which can only store one instance of a given
key, critqueues can store multiple instances. For example, the
following insertion sequence, without intermediate removals, is
invalid in a critbit tree but valid in a critqueue:

1. $p_{3, 0} = \langle 3, 5 \rangle$
2. $p_{2, 1} = \langle 2, 8 \rangle$
3. $p_{2, 2} = \langle 2, 2 \rangle$
4. $p_{3, 3} = \langle 3, 5 \rangle$

Here, the "key-value insertion pair"
$p_{i, j} = \langle i, v_j \rangle$ has:

* "Insertion key" $i$: the inserted key.
* "Insertion count" $j$: the total number of key-value insertion
pairs that were previously inserted.
* "Insertion value" $v_j$: the value from the key-value insertion
pair having insertion count $j$.


<a name="@Sorting_order_13"></a>

### Sorting order


Key-value insertion pairs in a critqueue are sorted by:

1. Either ascending or descending order of insertion key, then by
2. Ascending order of insertion count.

For example, consider the following binary insertion key sequence,
where $k_{i, j}$ denotes insertion key $i$ with insertion count $j$:

1. $k_{0, 0} = \texttt{0b00}$
2. $k_{1, 1} = \texttt{0b01}$
3. $k_{1, 2} = \texttt{0b01}$
4. $k_{0, 3} = \texttt{0b00}$
5. $k_{3, 4} = \texttt{0b11}$

In an ascending critqueue, the dequeue sequence would be:

1. $k_{0, 0} = \texttt{0b00}$
2. $k_{0, 3} = \texttt{0b00}$
3. $k_{1, 1} = \texttt{0b01}$
4. $k_{1, 2} = \texttt{0b01}$
5. $k_{3, 4} = \texttt{0b11}$

In a descending critqueue, the dequeue sequence would instead be:

1. $k_{3, 4} = \texttt{0b11}$
2. $k_{1, 1} = \texttt{0b01}$
3. $k_{1, 2} = \texttt{0b01}$
4. $k_{0, 0} = \texttt{0b00}$
5. $k_{0, 3} = \texttt{0b00}$


<a name="@Index_keys_14"></a>

### Index keys


The present critqueue implementation involves a critbit tree outer
node for each key-value insertion pair, corresponding to an "index
key" having the following bit structure (<code>NOT</code> denotes
bitwise complement):

| Bit(s) | Ascending critqueue  | Descending critqueue  |
|--------|----------------------|-----------------------|
| 64-95  | 32-bit insertion key | 32-bit insertion key  |
| 63     | 0                    | 1                     |
| 0-62   | Insertion count      | <code>NOT</code> insertion count |

For an ascending critqueue, index keys can thus be dequeued in
ascending lexicographical order via inorder successor iteration
starting at the minimum index key:

| Insertion key | Index key bits 64-95 | Index key bits 0-63 |
|---------------|----------------------|---------------------|
| $k_{0, 0}$    | <code>000...000</code>          | <code>000...000</code>         |
| $k_{0, 3}$    | <code>000...000</code>          | <code>000...011</code>         |
| $k_{1, 1}$    | <code>000...001</code>          | <code>000...001</code>         |
| $k_{1, 2}$    | <code>000...001</code>          | <code>000...010</code>         |
| $k_{3, 4}$    | <code>000...011</code>          | <code>000...100</code>         |

>                                          65th
>                                         /    \           critqueue
>                                      64th    k_{3, 4} <- tail
>                            _________/    \________
>                          1st                     1st
>     critqueue           /   \                   /   \
>          head -> k_{0, 0}   k_{0, 3}     k_{1, 1}   k_{1, 2}

Conversely, for a descending critqueue, index keys can thus be
dequeued in descending lexicographical order via inorder predecessor
iteration starting at the maximum index key:

| Insertion key | Index key bits 64-95 | Index key bits 0-63   |
|---------------|----------------------|-----------------------|
| $k_{3, 4}$    | <code>000...011</code>          | <code>111...011</code>           |
| $k_{1, 1}$    | <code>000...001</code>          | <code>111...110</code>           |
| $k_{1, 2}$    | <code>000...001</code>          | <code>111...101</code>           |
| $k_{0, 0}$    | <code>000...000</code>          | <code>111...111</code>           |
| $k_{0, 3}$    | <code>000...000</code>          | <code>111...100</code>           |

>                                          65th
>                                         /    \           critqueue
>                                      64th    k_{3, 4} <- head
>                            _________/    \________
>                          1st                     1st
>     critqueue           /   \                   /   \
>          tail -> k_{0, 3}   k_{0, 0}     k_{1, 2}   k_{1, 1}

Since index keys have bit 63 reserved, the maximum permissible
insertion count is thus $2^{63} - 1$.


<a name="@Dequeue_order_preservation_15"></a>

### Dequeue order preservation


Removals can take place from anywhere inside of a critqueue, with
the specified dequeue order preserved among remaining elements.
For example, consider the elements in an ascending critqueue
with the following dequeue sequence:

1. $k_{0, 6}$
2. $k_{2, 5}$
3. $k_{2, 8}$
4. $k_{4, 7}$
5. $k_{5, 0}$

Here, removing $k_{2, 5}$ simply updates the dequeue sequence to:

1. $k_{0, 6}$
2. $k_{2, 8}$
3. $k_{4, 7}$
4. $k_{5, 0}$


<a name="@Node_status_and_ID_16"></a>

### Node status and ID


Tree nodes are stored as separate items in global memory, and thus
incur per-item storage gas costs whenever they are operated on.
With per-item creations constituting by far the most expensive
operation in the Aptos gas schedule, it is thus most gas-efficient
to re-use allocated nodes, rather than deallocate them, after they
have been removed from the tree. Hence when a node is removed from
the tree it is not deallocated, but rather, is marked as "inactive"
and pushed onto a stack of inactive nodes. During insertion, new
nodes are only allocated if there are no inactive nodes to pop off
the stack.

Each time a new node is allocated, it is assigned a unique 32-bit
node ID, where bits 0-30 indicate the number of nodes of the given
type that have already been allocated. Node 31 is then set in the
case of an inner node, but left unset in the case of an outer node:

| Bit(s) | Inner node ID       | Outer node ID       |
|--------|---------------------|---------------------|
| 31     | 1                   | 0                   |
| 0-30   | 0-indexed serial ID | 0-indexed serial ID |

Since 32-bit node IDs have bit 31 reserved, the maximum permissible
number of node IDs for either type is thus $2^{31}$.


<a name="@Balance_regimes_17"></a>

### Balance regimes


Critbit trees are self-sorting but not self-rebalancing, such that
worst-case lookup times are $O(k)$, where $k$ is the number of bits
in an outer node key. For example, consider the following unbalanced
critbit tree, generating by inserting <code>0</code>, then bitmasks set only at
each successive bit up until $k$:

>                 k
>               _/ \_
>             ...   100000000000000.....
>            2nd
>           /   \
>         1st   100
>        /   \
>      0th   10
>     /   \
>     0   1

Here, searching for <code>1</code> involves walking from the root, branching
left at each inner node until ariving at <code>0th</code>, then checking
the right child, effectively an $O(n)$ operation.

In contrast, inserting the natural number sequence <code>0</code>, <code>1</code>, <code>10</code>,
..., <code>111</code> results in a generally-balanced tree where lookups are
$O(log_2(n))$:

>                          2nd
>                _________/   \_________
>              1st                     1st
>          ___/   \___             ___/   \___
>        0th         0th         0th         0th
>       /   \       /   \       /   \       /   \
>     000   001   010   011   100   101   110   111

In the present implementation, with insertion keys limited to 32
bits and insertion counts corresponding to a natural number
sequence, lookups are thus effectively $O(32)$ in the worst case for
index key bits 64-95 (insertion key), and $O(log_2(n_i))$ in the
general case for index key bits 0-63 (insertion count), where $n_i$
is the number of insertions for a given insertion key. Hence for
insertion keys <code>0</code>, <code>1</code>, <code>10</code>, <code>100</code>, ... and multiple insertions of
insertion key <code>1</code> in an ascending critqueue, the following critbit
tree is generated, having the following index keys at each outer
node:

>                     95th
>                    /    \
>                  ...    1000000...000...
>                 66th    ^ bit 95  ^ bit 63
>                /    \
>              65th   100000...
>             /    \     ^ bit 63
>           64th   10000...
>          /    \    ^ bit 63
>     000...     \____________
>     ^ bit 63               1st
>                 __________/   \__________
>               0th                       0th
>              /   \                     /   \
>     1000...000   1000...001   1000...010   1000...011
>      ^ bit 63     ^ bit 63     ^ bit 63     ^ bit 63


<a name="@Lookup_gas_18"></a>

### Lookup gas


While critqueue insertion key lookup is theoretically $O(k)$ in the
worst case, this only applies for bitstrings with maximally sparse
prefixes. Here, with each node stored as a separate hash table entry
in global storage, Aptos storage gas is thus assessed as a per-item
read for each node accessed during a search.

Notably, however, per-item reads cost only one fifth as much as
per-item writes as of the time of this writing, and while $O(k)$
per-item reads could potentially be eliminated via a self-balancing
alternative, e.g. an AVL or red-black tree, the requisite
rebalancing operations would entail per-item write costs that far
outweigh the reduction in $O(k)$-associated lookup gas.

Hence for the present implementation, insertion keys are limited to
32 bits to reduce the worst-case $O(k)$ lookup, and are combined
with a natural number insertion counter to generate outer node index
keys.


<a name="@Access_keys_19"></a>

### Access keys


Upon insertion, index keys (which contain only 96 bits), are
concatenated with the corresponding outer node ID for the outer node
just inserted to the critqueue, yielding a unique "access key" that
can be used for $O(1)$ insertion value lookup by outer node ID:

| Bits   | Data          |
|--------|---------------|
| 32-127 | Index key     |
| 0-31   | Outer node ID |

Access keys are returned to callers during insertion, and have the
same lexicographical sorting properites as index keys.


<a name="@Complete_docgen_index_20"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [Bit conventions](#@Bit_conventions_0)
    -  [Number](#@Number_1)
    -  [Status](#@Status_2)
    -  [Masking](#@Masking_3)
-  [Critbit trees](#@Critbit_trees_4)
    -  [General](#@General_5)
    -  [Structure](#@Structure_6)
    -  [Insertions](#@Insertions_7)
    -  [Removals](#@Removals_8)
    -  [As a map](#@As_a_map_9)
    -  [References](#@References_10)
-  [Critqueues](#@Critqueues_11)
    -  [Key storage multiplicity](#@Key_storage_multiplicity_12)
    -  [Sorting order](#@Sorting_order_13)
    -  [Index keys](#@Index_keys_14)
    -  [Dequeue order preservation](#@Dequeue_order_preservation_15)
    -  [Node status and ID](#@Node_status_and_ID_16)
    -  [Balance regimes](#@Balance_regimes_17)
    -  [Lookup gas](#@Lookup_gas_18)
    -  [Access keys](#@Access_keys_19)
-  [Complete docgen index](#@Complete_docgen_index_20)
-  [Struct `CritQueue`](#0xc0deb00c_critqueue_CritQueue)
-  [Struct `Inner`](#0xc0deb00c_critqueue_Inner)
-  [Struct `Outer`](#0xc0deb00c_critqueue_Outer)
-  [Constants](#@Constants_21)
-  [Function `new`](#0xc0deb00c_critqueue_new)
    -  [Parameters](#@Parameters_22)
    -  [Returns](#@Returns_23)
    -  [Aborts](#@Aborts_24)
    -  [Testing](#@Testing_25)
-  [Function `verify_new_node_count`](#0xc0deb00c_critqueue_verify_new_node_count)
    -  [Aborts](#@Aborts_26)
    -  [Testing](#@Testing_27)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
</code></pre>



<a name="0xc0deb00c_critqueue_CritQueue"></a>

## Struct `CritQueue`

A hybrid between a critbit tree and a queue. See above.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>sort_order: bool</code>
</dt>
<dd>
 <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.
</dd>
<dt>
<code>root_node_id: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 Node ID of root node, if any.
</dd>
<dt>
<code>head_access_key: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Access key of head node, if any.
</dd>
<dt>
<code>insertion_count: u64</code>
</dt>
<dd>
 Cumulative insertion count.
</dd>
<dt>
<code>inners: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="critqueue.md#0xc0deb00c_critqueue_Inner">critqueue::Inner</a>&gt;</code>
</dt>
<dd>
 Map from inner node ID to inner node.
</dd>
<dt>
<code>outers: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="critqueue.md#0xc0deb00c_critqueue_Outer">critqueue::Outer</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Map from outer node ID to outer node.
</dd>
<dt>
<code>inactive_inner_top: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 ID of inactive inner node at top of stack, if any.
</dd>
<dt>
<code>inactive_outer_top: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 ID of inactive outer node at top of stack, if any.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_Inner"></a>

## Struct `Inner`

An inner node in a critqueue.

If an active node, <code>next</code> field is ignored. If an inactive node,
all fields except <code>next</code> are ignored.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>critical_bit: u8</code>
</dt>
<dd>
 Critical bit number.
</dd>
<dt>
<code>left: u64</code>
</dt>
<dd>
 Node ID of left child.
</dd>
<dt>
<code>right: u64</code>
</dt>
<dd>
 Node ID of right child.
</dd>
<dt>
<code>next: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 Node ID of next inactive inner node in stack, if any.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_Outer"></a>

## Struct `Outer`

An outer node in a critqueue.

If an active node, <code>next</code> field is ignored. If an inactive node,
all fields except <code>next</code> are ignored.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_Outer">Outer</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>index_key: u128</code>
</dt>
<dd>
 Index key for given key-value insertion pair.
</dd>
<dt>
<code>value: <a href="_Option">option::Option</a>&lt;V&gt;</code>
</dt>
<dd>
 Insertion value.
</dd>
<dt>
<code>next: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 Node ID of next inactive inner node in stack, if any.
</dd>
</dl>


</details>

<a name="@Constants_21"></a>

## Constants


<a name="0xc0deb00c_critqueue_ASCENDING"></a>

Ascending critqueue flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_DESCENDING"></a>

Descending critqueue flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_E_TOO_MANY_NODES"></a>

Specified node count is too high.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a>: u64 = 0;
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



<a name="0xc0deb00c_critqueue_MAX_NODE_COUNT"></a>

<code>u64</code> bitmask set at all bits except bit 31, generated in Python
via <code>hex(int('1' * 31, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_MAX_NODE_COUNT">MAX_NODE_COUNT</a>: u64 = 2147483647;
</code></pre>



<a name="0xc0deb00c_critqueue_NODE_TYPE"></a>

<code>u64</code> bitmask set at bit 31 (the node type bit flag), generated
in Python via <code>hex(int('1' + '0' * 31, 2))</code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE">NODE_TYPE</a>: u64 = 2147483648;
</code></pre>



<a name="0xc0deb00c_critqueue_NODE_TYPE_INNER"></a>

Result of node ID bitwise <code>AND</code> <code><a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE">NODE_TYPE</a></code> for an inner node,
Generated in Python via <code>hex(int('1' + '0' * 31, 2))</code>. Can also
be used to generate an inner node ID via bitwise <code>OR</code> the node's
0-indexed serial ID.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE_INNER">NODE_TYPE_INNER</a>: u64 = 2147483648;
</code></pre>



<a name="0xc0deb00c_critqueue_new"></a>

## Function `new`

Return a new critqueue, optionally allocating inactive nodes.

Inserting the root outer node requires a single allocated outer
node, while all other insertions require an outer and an inner
node. Hence for a nonzero number of outer nodes, the number of
inner nodes in the tree is one less than the number of outer
nodes.


<a name="@Parameters_22"></a>

### Parameters


* <code>sort_order</code>: <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.
* <code>n_inactive_outer_nodes</code>: The number of inactive outer nodes
to allocate.


<a name="@Returns_23"></a>

### Returns


* <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;</code>: A new critqueue.


<a name="@Aborts_24"></a>

### Aborts


* <code><a href="critqueue.md#0xc0deb00c_critqueue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a></code>: If <code>n_inactive_outer_nodes</code> exceeds
<code><a href="critqueue.md#0xc0deb00c_critqueue_MAX_NODE_COUNT">MAX_NODE_COUNT</a></code>.


<a name="@Testing_25"></a>

### Testing


* <code>test_new()</code>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V: store&gt;(sort_order: bool, n_inactive_outer_nodes: u64): <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V: store&gt;(
    sort_order: bool,
    n_inactive_outer_nodes: u64
): <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt; {
    // Assert not trying <b>to</b> allocate too many nodes.
    <a href="critqueue.md#0xc0deb00c_critqueue_verify_new_node_count">verify_new_node_count</a>(n_inactive_outer_nodes);
    <b>let</b> <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a> = <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>{ // Declare empty <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>.
        sort_order,
        root_node_id: <a href="_none">option::none</a>(),
        head_access_key: <a href="_none">option::none</a>(),
        insertion_count: 0,
        inners: <a href="_new">table_with_length::new</a>(),
        outers: <a href="_new">table_with_length::new</a>(),
        inactive_inner_top: <b>if</b> (n_inactive_outer_nodes &gt; 1)
            <a href="_some">option::some</a>((n_inactive_outer_nodes - 2) | <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE_INNER">NODE_TYPE_INNER</a>)
            <b>else</b> <a href="_none">option::none</a>(),
        inactive_outer_top: <b>if</b> (n_inactive_outer_nodes &gt; 0)
            <a href="_some">option::some</a>(n_inactive_outer_nodes - 1) <b>else</b> <a href="_none">option::none</a>()
    };
    // If need <b>to</b> allocate at least one outer node:
    <b>if</b> (n_inactive_outer_nodes &gt; 0) {
        <b>let</b> i = 0; // Declare <b>loop</b> counter.
        // While nodes <b>to</b> allocate:
        <b>while</b> (i &lt; n_inactive_outer_nodes) {
            <b>if</b> (i &gt; 0) { // If not on the first <b>loop</b> iteration:
                // Next inactive inner node is none <b>if</b> on second
                // <b>loop</b> iteration, otherwise is <b>loop</b> count minus 2.
                <b>let</b> next = <b>if</b> (i == 1) <a href="_none">option::none</a>() <b>else</b>
                    <a href="_some">option::some</a>((i - 2) | <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE_INNER">NODE_TYPE_INNER</a>);
                // Push inactive inner node onto stack.
                <a href="_add">table_with_length::add</a>(
                    &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>.inners, (i - 1) | <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE_INNER">NODE_TYPE_INNER</a>,
                    <a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a>{critical_bit: 0, left: 0, right: 0, next});
            };
            // Next inactive outer node is none <b>if</b> on first <b>loop</b>
            // iteration, otherwise is <b>loop</b> count minus 1.
            <b>let</b> next = <b>if</b> (i == 0) <a href="_none">option::none</a>() <b>else</b>
                <a href="_some">option::some</a>(i - 1);
            // Push inactive outer node onto stack.
            <a href="_add">table_with_length::add</a>(&<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>.outers, i, <a href="critqueue.md#0xc0deb00c_critqueue_Outer">Outer</a>&lt;V&gt;{
                index_key: 0, value: <a href="_none">option::none</a>(), next});
            i = i + 1; // Increment <b>loop</b> counter.
        }
    };
    <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a> // Return <a href="critqueue.md#0xc0deb00c_critqueue">critqueue</a>.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_verify_new_node_count"></a>

## Function `verify_new_node_count`

Verify proposed new node count is not too high.


<a name="@Aborts_26"></a>

### Aborts


* <code><a href="critqueue.md#0xc0deb00c_critqueue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a></code>: If <code>n_nodes</code> exceeds <code><a href="critqueue.md#0xc0deb00c_critqueue_MAX_NODE_COUNT">MAX_NODE_COUNT</a></code>.


<a name="@Testing_27"></a>

### Testing


* <code>test_verify_new_node_count_fail()</code>
* <code>test_verify_new_node_count_pass()</code>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_verify_new_node_count">verify_new_node_count</a>(n_nodes: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_verify_new_node_count">verify_new_node_count</a>(
    n_nodes: u64,
) {
    // Assert proposed node count is less than or equal <b>to</b> max.
    <b>assert</b>!(n_nodes &lt;= <a href="critqueue.md#0xc0deb00c_critqueue_MAX_NODE_COUNT">MAX_NODE_COUNT</a>, <a href="critqueue.md#0xc0deb00c_critqueue_E_TOO_MANY_NODES">E_TOO_MANY_NODES</a>);
}
</code></pre>



</details>
