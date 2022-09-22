
<a name="0xc0deb00c_critqueue"></a>

# Module `0xc0deb00c::critqueue`

Hybrid data structure combining crit-bit tree and queue properties.

Bit numbers are 0-indexed from the least-significant bit (LSB):

>     11101...1010010101
>      bit 5 = 0 -|    |- bit 0 = 1


<a name="@Module-level_documentation_sections_0"></a>

## Module-level documentation sections


[Crit-bit trees](#crit-bit-trees):

* [General](#general)
* [Structure](#structure)
* [References](#references)

[Crit-queues](#crit-queues):

* [Enqueue key multiplicity](#enqueue-key-multiplicity)
* [Dequeue order](#dequeue-order)
* [Leaf key structure](#leaf-key-structure)
* [Parent keys](#parent-keys)
* [Key tables](#key-tables)

[Operations](#operations):

* [Enqueues](#enqueues)
* [Removals](#removals)
* [Dequeues](#dequeues)


<a name="@Crit-bit_trees_1"></a>

## Crit-bit trees



<a name="@General_2"></a>

### General


A critical bit (crit-bit) tree is a compact binary prefix tree
that stores a prefix-free set of bitstrings, like n-bit integers or
variable-length 0-terminated byte strings. For a given set of keys
there exists a unique crit-bit tree representing the set, to the
effect that crit-bit trees do not require complex rebalancing
algorithms like those of AVL or red-black binary search trees.
Crit-bit trees support the following operations:

* Membership testing
* Insertion
* Deletion
* Inorder predecessor iteration
* Inorder successor iteration


<a name="@Structure_3"></a>

### Structure


The present implementation involves a tree with <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> and <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code>
nodes. <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> nodes have two <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> children each, and <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code>
nodes do not have children. <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> nodes store a value of type <code>V</code>,
and have a <code>u128</code> key. <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> nodes store a <code>u8</code> indicating the
most-significant critical bit (crit-bit) of divergence between
<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys from the <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> node's two subtrees: <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys in
a <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> node's left subtree are unset at the critical bit, while
<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys in a <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> node's right subtree are set at the
critical bit.

<code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> nodes are arranged hierarchically, with the most
significant critical bits at the top of the tree. For instance, the
<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys <code>001</code>, <code>101</code>, <code>110</code>, and <code>111</code> would be stored in a
crit-bit tree as follows:

>        2nd
>       /   \
>     001   1st
>          /   \
>        101   0th
>             /   \
>           110   111

Here, the <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> node marked <code>2nd</code> stores the critical bit <code>2</code>,
the <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> node marked <code>1st</code> stores the critical bit <code>1</code>, and the
<code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> node marked <code>0th</code> stores the critical bit <code>0</code>. Hence, the
sole <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> key in the left subtree of the <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> marked <code>2nd</code> is
unset at bit 2, while all the keys in right subtree of the <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code>
marked <code>2nd</code> are set at bit 2. And similarly for the <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code> marked
<code>0th</code>, the <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> key of its left child is unset at bit 0, while the
<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> key of its right child is set at bit 0.


<a name="@References_4"></a>

### References


* [Bernstein 2006]
* [Langley 2008] (Primary reference for this implementation)
* [Langley 2012]
* [Tcler's Wiki 2021]

[Bernstein 2006]:
https://cr.yp.to/critbit.html
[Langley 2008]:
https://www.imperialviolet.org/2008/09/29/critbit-trees.html
[Langley 2012]:
https://github.com/agl/critbit
[Tcler's Wiki 2021]:
https://wiki.tcl-lang.org/page/critbit


<a name="@Crit-queues_5"></a>

## Crit-queues



<a name="@Enqueue_key_multiplicity_6"></a>

### Enqueue key multiplicity


Unlike a crit-bit tree, which only allows for a single insertion of
a given key, crit-queues support multiple enqueues of a given key
across key-value pairs. For example, the following key-value pairs,
all having the same "enqueue key", <code>3</code>, may be stored inside of a
single crit-queue:

* $p_{3, 0} = \langle 3, 5 \rangle$
* $p_{3, 1} = \langle 3, 8 \rangle$
* $p_{3, 2} = \langle 3, 2 \rangle$
* $p_{3, 3} = \langle 3, 5 \rangle$

Here, key-value pair $p_{i, j}$ has enqueue key $i$ and "enqueue
count" $j$, with the enqueue count describing the number
of key-value pairs, having the same enqueue key, that were
previously enqueued.


<a name="@Dequeue_order_7"></a>

### Dequeue order


After a key-value pair has been enqueued and assigned an enqueue
count, a separate key is generated, which allows for sorted
insertion into a crit-bit tree. Here, the corresponding "leaf key"
is constructed such that key-value pairs are sorted within the
crit-bit tree by:

1. Either ascending or descending order of enqueue key, then by
2. Ascending order of enqueue count.

For example, consider the following enqueue sequence ($k_{i, j}$
denotes enqueue key $i$ with enqueue count $j$):

1. $k_{0, 0}$
2. $k_{1, 0}$
3. $k_{1, 1}$
4. $k_{0, 1}$
5. $k_{3, 0}$

In an ascending crit-queue, these elements would be dequeued as
follows:

1. $k_{0, 0}$
2. $k_{0, 1}$
3. $k_{1, 0}$
4. $k_{1, 1}$
5. $k_{3, 0}$

In a descending crit-queue, the dequeue sequence would instead be:

1. $k_{3, 0}$
2. $k_{1, 0}$
3. $k_{1, 1}$
4. $k_{0, 0}$
5. $k_{0, 1}$


<a name="@Leaf_key_structure_8"></a>

### Leaf key structure


In the present implementation, crit-queue leaf keys have the
following bit structure (<code>NOT</code> denotes bitwise complement):

| Bit(s) | Ascending crit-queue | Descending crit-queue |
|--------|----------------------|-----------------------|
| 64-127 | Enqueue key          | Enqueue key           |
| 63     | 0                    | 0                     |
| 62     | 0                    | 1                     |
| 0-61   | Enqueue count        | <code>NOT</code> enqueue count   |

With the enqueue key contained in the most significant bits,
elements are thus sorted in the crit-bit tree first by enqueue key
and then by:

* Enqueue count if an ascending crit-queue, or
* Bitwise complement of enqueue count if a descending queue.

Continuing the above example, this yields the following leaf keys
and crit-bit tree for an ascending crit-queue, with elements
dequeued via inorder successor traversal starting from the minimum
leaf key:

| Enqueue key | Leaf key bits 64-127 | Leaf key bits 0-63 |
|-------------|----------------------|--------------------|
| $k_{0, 0}$  | <code>000...000</code>          | <code>000...000</code>        |
| $k_{0, 1}$  | <code>000...000</code>          | <code>000...001</code>        |
| $k_{1, 0}$  | <code>000...001</code>          | <code>000...000</code>        |
| $k_{1, 1}$  | <code>000...001</code>          | <code>000...001</code>        |
| $k_{3, 0}$  | <code>000...011</code>          | <code>000...000</code>        |

>                                          65th
>                                         /    \
>                                     64th      k_{3, 0}
>                            ________/    \________
>                         0th                      0th
>      Queue             /   \                    /   \
>       head --> k_{0, 0}     k_{0, 1}    k_{1, 0}     k_{1, 1}

For a descending crit-queue, elements are dequeued via
inorder predecessor traversal starting from the maximum leaf key:

| Enqueue key | Leaf key bits 64-127 | Leaf key bits 0-63 |
|-------------|----------------------|--------------------|
| $k_{3, 0}$  | <code>000...011</code>          | <code>011...111</code>        |
| $k_{1, 0}$  | <code>000...001</code>          | <code>011...111</code>        |
| $k_{1, 1}$  | <code>000...001</code>          | <code>011...110</code>        |
| $k_{0, 0}$  | <code>000...000</code>          | <code>011...111</code>        |
| $k_{0, 1}$  | <code>000...000</code>          | <code>011...110</code>        |

>                               65th
>                              /    \             Queue
>                          64th      k_{3, 0} <-- head
>                 ________/    \________
>              0th                      0th
>             /   \                    /   \
>     k_{0, 1}     k_{0, 0}    k_{1, 1}     k_{1, 0}



<a name="@Parent_keys_9"></a>

### Parent keys


If the insertion of a crit-bit tree leaf is accompanied by the
generation of a crit-bit tree parent node, the parent is assigned
a "parent key" that is identical to the corresponding leaf key,
except with bit 63 set. This schema allows for
discrimination between leaf keys and parent keys based simply on
bit 63.


<a name="@Key_tables_10"></a>

### Key tables


Enqueue, leaf, and parent keys are stored in separate hash tables:

| Table key  | Key type | Table value                       |
|------------|----------|-----------------------------------|
| Enqueue    | <code>u64</code>    | Enqueue count for key, if nonzero |
| Leaf       | <code>u128</code>   | Crit-bit tree leaf                |
| Parent     | <code>u128</code>   | Crit-bit tree parent node         |

The enqueue key table is initialized empty, such that before
enqueuing the first instance of a given enqueue key, $k_{i, 0}$,
the enqueue key table does not have an entry for key $i$. After
$k_{i, 0}$ is enqueued, the entry $\langle i, 0\rangle$ is added to
the enqueue key table, and for each subsequent enqueue,
$k_{i, n}$, the value corresponding to key $i$, the enqueue count,
is updated to $n$. Since bits 62 and 63 in leaf keys are
reserved for flag bits, the maximum enqueue count per enqueue key
is thus $2^{62} - 1$.


<a name="@Operations_11"></a>

## Operations


In the present implementation, key-value pairs are enqueued via
<code><a href="critqueue.md#0xc0deb00c_critqueue_enqueue">enqueue</a>()</code>, which accepts a <code>u64</code> enqueue key and an enqueue value
of type <code>V</code>. A corresponding <code>u128</code> leaf key is returned, which can
be used for subsequent leaf key lookup via <code><a href="critqueue.md#0xc0deb00c_critqueue_borrow">borrow</a>()</code>,
<code><a href="critqueue.md#0xc0deb00c_critqueue_borrow_mut">borrow_mut</a>()</code>, or <code><a href="critqueue.md#0xc0deb00c_critqueue_remove">remove</a>()</code>.


<a name="@Enqueues_12"></a>

### Enqueues


Enqueues are, like a crit-bit tree, $O(k^{\dagger})$ in the worst
case, where $k^{\dagger} = k - 2 = 126$ (the number of variable bits
in a leaf key), but parallelizable in the general case where:

1. Enqueues do not alter the head of the crit-queue.
2. Enqueues do not write to overlapping tree edges.
3. Enqueues do not share the same enqueue key.

The third parallelism constraint is a result of enqueue count
updates, and may potentially be eliminated in the case of a
parallelized insertion count aggregator.


<a name="@Removals_13"></a>

### Removals


With <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> nodes stored in a <code>Table</code>, <code><a href="critqueue.md#0xc0deb00c_critqueue_remove">remove</a>()</code> operations are
thus $O(1)$, and are additionally parallelizable in the general case
where:

1. Removals do not write to overlapping tree edges.
2. Removals do not alter the head of the crit-queue.

Removals can take place from anywhere inside of the crit-queue, with
the specified sorting order preserved among remaining elements. For
example, consider the elements in an ascending crit-queue with the
following dequeue sequence:

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


<a name="@Dequeues_14"></a>

### Dequeues


Dequeues, as a form of removal, are $O(1)$, but since they alter
the head of the queue, they are not parallelizable. Dequeues
are initialized via <code><a href="critqueue.md#0xc0deb00c_critqueue_dequeue_init">dequeue_init</a>()</code>, and iterated via <code><a href="critqueue.md#0xc0deb00c_critqueue_dequeue">dequeue</a>()</code>.

---


-  [Module-level documentation sections](#@Module-level_documentation_sections_0)
-  [Crit-bit trees](#@Crit-bit_trees_1)
    -  [General](#@General_2)
    -  [Structure](#@Structure_3)
    -  [References](#@References_4)
-  [Crit-queues](#@Crit-queues_5)
    -  [Enqueue key multiplicity](#@Enqueue_key_multiplicity_6)
    -  [Dequeue order](#@Dequeue_order_7)
    -  [Leaf key structure](#@Leaf_key_structure_8)
    -  [Parent keys](#@Parent_keys_9)
    -  [Key tables](#@Key_tables_10)
-  [Operations](#@Operations_11)
    -  [Enqueues](#@Enqueues_12)
    -  [Removals](#@Removals_13)
    -  [Dequeues](#@Dequeues_14)
-  [Struct `CritQueue`](#0xc0deb00c_critqueue_CritQueue)
-  [Struct `Leaf`](#0xc0deb00c_critqueue_Leaf)
-  [Struct `Parent`](#0xc0deb00c_critqueue_Parent)
-  [Constants](#@Constants_15)
-  [Function `borrow`](#0xc0deb00c_critqueue_borrow)
-  [Function `borrow_mut`](#0xc0deb00c_critqueue_borrow_mut)
-  [Function `dequeue`](#0xc0deb00c_critqueue_dequeue)
    -  [Parameters](#@Parameters_16)
    -  [Returns](#@Returns_17)
    -  [Aborts if](#@Aborts_if_18)
-  [Function `dequeue_init`](#0xc0deb00c_critqueue_dequeue_init)
    -  [Parameters](#@Parameters_19)
    -  [Returns](#@Returns_20)
    -  [Aborts if](#@Aborts_if_21)
-  [Function `enqueue`](#0xc0deb00c_critqueue_enqueue)
-  [Function `get_head_leaf_key`](#0xc0deb00c_critqueue_get_head_leaf_key)
-  [Function `new`](#0xc0deb00c_critqueue_new)
-  [Function `remove`](#0xc0deb00c_critqueue_remove)
-  [Function `takes_priority`](#0xc0deb00c_critqueue_takes_priority)
-  [Function `trails_head`](#0xc0deb00c_critqueue_trails_head)
-  [Function `get_critical_bit`](#0xc0deb00c_critqueue_get_critical_bit)
    -  [XOR/AND method](#@XOR/AND_method_22)
    -  [Binary search method](#@Binary_search_method_23)
-  [Function `is_set`](#0xc0deb00c_critqueue_is_set)


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
<code>direction: bool</code>
</dt>
<dd>
 Crit-queue sort direction, <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.
</dd>
<dt>
<code>root: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Crit-bit tree root node key. If none, tree is empty.
</dd>
<dt>
<code>head: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Queue head key. If none, tree is empty. Else minimum leaf
 key if <code>direction</code> is <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code>, and maximum leaf key
 if <code>direction</code> is <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.
</dd>
<dt>
<code>enqueues: <a href="_Table">table::Table</a>&lt;u64, u64&gt;</code>
</dt>
<dd>
 Map from enqueue key to 0-indexed enqueue count.
</dd>
<dt>
<code>parents: <a href="_Table">table::Table</a>&lt;u128, <a href="critqueue.md#0xc0deb00c_critqueue_Parent">critqueue::Parent</a>&gt;</code>
</dt>
<dd>
 Map from parent key to <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code>.
</dd>
<dt>
<code>leaves: <a href="_Table">table::Table</a>&lt;u128, <a href="critqueue.md#0xc0deb00c_critqueue_Leaf">critqueue::Leaf</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Map from leaf key to <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> having enqueue value type <code>V</code>.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_Leaf"></a>

## Struct `Leaf`

A crit-bit tree leaf node.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: V</code>
</dt>
<dd>
 Enqueue value.
</dd>
<dt>
<code>parent: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 If none, node is root. Else parent key.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critqueue_Parent"></a>

## Struct `Parent`

A crit-bit tree parent node.


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bit: u8</code>
</dt>
<dd>
 Critical bit position.
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

<a name="@Constants_15"></a>

## Constants


<a name="0xc0deb00c_critqueue_ASCENDING"></a>

Ascending crit-queue flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_ASCENDING_BIT_FLAG"></a>

Crit-queue direction bit flag indicating <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING_BIT_FLAG">ASCENDING_BIT_FLAG</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_critqueue_DESCENDING"></a>

Descending crit-queue flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_DESCENDING_BIT_FLAG"></a>

Crit-queue direction bit flag indicating <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING_BIT_FLAG">DESCENDING_BIT_FLAG</a>: u128 = 1;
</code></pre>



<a name="0xc0deb00c_critqueue_DIRECTION"></a>

Bit number of crit-queue direction bit flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DIRECTION">DIRECTION</a>: u8 = 62;
</code></pre>



<a name="0xc0deb00c_critqueue_HI_128"></a>

<code>u128</code> bitmask with all bits set


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_critqueue_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_critqueue_LEAF"></a>

Node type bit flag indicating <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_LEAF">LEAF</a>: u128 = 0;
</code></pre>



<a name="0xc0deb00c_critqueue_MSB_u128"></a>

Most significant bit number for a <code>u128</code>


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_MSB_u128">MSB_u128</a>: u8 = 127;
</code></pre>



<a name="0xc0deb00c_critqueue_NODE_TYPE"></a>

Bit number of crit-bit tree node type bit flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE">NODE_TYPE</a>: u8 = 63;
</code></pre>



<a name="0xc0deb00c_critqueue_PARENT"></a>

Node type bit flag indicating <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_PARENT">PARENT</a>: u128 = 1;
</code></pre>



<a name="0xc0deb00c_critqueue_borrow"></a>

## Function `borrow`

Borrow enqueue value corresponding to given leaf key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow">borrow</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, _leaf_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow">borrow</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    _leaf_key: u128
)/*: &V*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_borrow_mut"></a>

## Function `borrow_mut`

Mutably borrow enqueue value corresponding to given leaf key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow_mut">borrow_mut</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, _leaf_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_borrow_mut">borrow_mut</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    _leaf_key: u128
)/*: &V*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_dequeue"></a>

## Function `dequeue`

Dequeue head and borrow next element in the queue, the new head.

Should only be called after <code><a href="critqueue.md#0xc0deb00c_critqueue_dequeue_init">dequeue_init</a>()</code> indicates that
iteration can proceed, or if a subsequent call to <code><a href="critqueue.md#0xc0deb00c_critqueue_dequeue">dequeue</a>()</code>
indicates the same.


<a name="@Parameters_16"></a>

### Parameters

* <code>crit_queue_ref_mut</code>: Mutable reference to <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>.


<a name="@Returns_17"></a>

### Returns

* <code>u128</code>: New queue head leaf key.
* <code>&<b>mut</b> V</code>: Mutable reference to new queue head enqueue value.
* <code>bool</code>: <code><b>true</b></code> if the new queue head <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> has a parent, and
thus if iteration can proceed.


<a name="@Aborts_if_18"></a>

### Aborts if

* Indicated <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> is empty.
* Indicated <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> is a singleton, e.g. if there are no
elements to proceed to after dequeueing.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_dequeue">dequeue</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_dequeue">dequeue</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;
)//: (
    //u128,
    //&<b>mut</b> V,
    //bool
/*)*/ {
    // Can ensure that there is a queue head by attempting <b>to</b> borrow
    // the corresponding leaf key from the <a href="">option</a> field, which
    // aborts <b>if</b> it is none.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_dequeue_init"></a>

## Function `dequeue_init`

Mutably borrow the head of the queue before dequeueing.


<a name="@Parameters_19"></a>

### Parameters

* <code>crit_queue_ref_mut</code>: Mutable reference to <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>.


<a name="@Returns_20"></a>

### Returns

* <code>u128</code>: Queue head leaf key.
* <code>&<b>mut</b> V</code>: Mutable reference to queue head enqueue value.
* <code>bool</code>: <code><b>true</b></code> if the queue <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> has a parent, and thus if
there is another element to iterate to. If <code><b>false</b></code>, can still
remove the head via <code><a href="critqueue.md#0xc0deb00c_critqueue_remove">remove</a>()</code>.


<a name="@Aborts_if_21"></a>

### Aborts if

* Indicated <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code> is empty.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_dequeue_init">dequeue_init</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_dequeue_init">dequeue_init</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;
)//: (
    //u128,
    //&<b>mut</b> V,
    //bool
/*)*/ {
    // Can ensure that there is a queue head by attempting <b>to</b> borrow
    // corresponding leaf key from `<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>.head`, which aborts
    // <b>if</b> none.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_enqueue"></a>

## Function `enqueue`

Enqueue key-value pair, returning generated leaf key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_enqueue">enqueue</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, _enqueue_key: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_enqueue">enqueue</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    _enqueue_key: u64,
    //_enqueue_value: V,
)/*: u128*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_get_head_leaf_key"></a>

## Function `get_head_leaf_key`

Return head leaf key, if any.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_head_leaf_key">get_head_leaf_key</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_head_leaf_key">get_head_leaf_key</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
)/*: Option&lt;u128&gt; */ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_new"></a>

## Function `new`

Return <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code> <code><a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a></code>, per <code>direction</code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V&gt;(_direction: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V&gt;(
    _direction: bool
)/*: QueueCrit*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_remove"></a>

## Function `remove`

Remove corresponding leaf, return enqueue value.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_remove">remove</a>&lt;V&gt;(_crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, _leaf_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_remove">remove</a>&lt;V&gt;(
    _crit_queue_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    _leaf_key: u128
)/*: V*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_takes_priority"></a>

## Function `takes_priority`

Return <code><b>true</b></code> if <code>enqueue_key</code> would become new head if
enqueued, else <code><b>false</b></code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_takes_priority">takes_priority</a>&lt;V&gt;(_crit_queue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, _enqueue_key: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_takes_priority">takes_priority</a>&lt;V&gt;(
    _crit_queue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    _enqueue_key: u64
)/*: bool*/ {
    // Return <b>true</b> <b>if</b> empty.
    // If ascending, <b>return</b> <b>true</b> <b>if</b> less than head enqueue key.
    // If descending, <b>return</b> <b>true</b> <b>if</b> greater than head enqueue key.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_trails_head"></a>

## Function `trails_head`

Return <code><b>true</b></code> if <code>enqueue_key</code> would not become the head if
enqueued.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_trails_head">trails_head</a>&lt;V&gt;(_crit_queue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">critqueue::CritQueue</a>&lt;V&gt;, _enqueue_key: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_trails_head">trails_head</a>&lt;V&gt;(
    _crit_queue_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_CritQueue">CritQueue</a>&lt;V&gt;,
    _enqueue_key: u64
)/*: bool*/ {
    // Return <b>false</b> <b>if</b> empty.
    // If ascending, <b>return</b> <b>true</b> <b>if</b> greater than/equal <b>to</b> head
    // enqueue key.
    // If descending, <b>return</b> <b>true</b> <b>if</b> less than/equal <b>to</b> head
    // enqueue key.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_get_critical_bit"></a>

## Function `get_critical_bit`

Return the number of the most significant bit (0-indexed from
LSB) at which two non-identical bitstrings, <code>s1</code> and <code>s2</code>, vary.


<a name="@XOR/AND_method_22"></a>

### XOR/AND method


To begin with, a bitwise XOR is used to flag all differing bits:

>              s1: 11110001
>              s2: 11011100
>     x = s1 ^ s2: 00101101
>                    |- critical bit = 5

Here, the critical bit is equivalent to the bit number of the
most significant set bit in XOR result <code>x = s1 ^ s2</code>. At this
point, [Langley 2008](#references) notes that <code>x</code> bitwise AND
<code>x - 1</code> will be nonzero so long as <code>x</code> contains at least some
bits set which are of lesser significance than the critical bit:

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

>               x: 00101100
>           x - 1: 00101011
> x = x & (x - 1): 00101000

The third iteration:

>                   x: 00101000
>               x - 1: 00100111
>     x = x & (x - 1): 00100000
Now, <code>x & x - 1</code> will equal zero and the loop will not begin a
fourth iteration:

>                 x: 00100000
>             x - 1: 00011111
>     x AND (x - 1): 00000000

Thus after three iterations a corresponding critical bit bitmask
has been determined. However, in the case where the two input
strings vary at all bits of lesser significance than that of the
critical bit, there may be required as many as <code>k - 1</code>
iterations, where <code>k</code> is the number of bits in each string under
comparison. For instance, consider the case of the two 8-bit
strings <code>s1</code> and <code>s2</code> as follows:

>                  s1: 10101010
>                  s2: 01010101
>         x = s1 ^ s2: 11111111
>                      |- critical bit = 7
>     x = x & (x - 1): 11111110 [iteration 1]
>     x = x & (x - 1): 11111100 [iteration 2]
>     x = x & (x - 1): 11111000 [iteration 3]
>     ...

Notably, this method is only suggested after already having
identified the varying byte between the two strings, thus
limiting <code>x & (x - 1)</code> operations to at most 7 iterations.


<a name="@Binary_search_method_23"></a>

### Binary search method


For the present implementation, strings are not partitioned into
a multi-byte array, rather, they are stored as <code>u128</code> integers,
so a binary search is instead proposed. Here, the same
<code>x = s1 ^ s2</code> operation is first used to identify all differing
bits, before iterating on an upper and lower bound for the
critical bit number:

>              s1: 10101010
>              s2: 01010101
>     x = s1 ^ s2: 11111111
>           u = 7 -|      |- l = 0

The upper bound <code>u</code> is initialized to the length of the string
(7 in this example, but 127 for a <code>u128</code>), and the lower bound
<code>l</code> is initialized to 0. Next the midpoint <code>m</code> is calculated as
the average of <code>u</code> and <code>l</code>, in this case <code>m = (7 + 0) / 2 = 3</code>,
per truncating integer division. Now, the shifted compare value
<code>s = r &gt;&gt; m</code> is calculated and updates are applied according to
three potential outcomes:

* <code>s == 1</code> means that the critical bit <code>c</code> is equal to <code>m</code>
* <code>s == 0</code> means that <code>c &lt; m</code>, so <code>u</code> is set to <code>m - 1</code>
* <code>s &gt; 1</code> means that <code>c &gt; m</code>, so <code>l</code> us set to <code>m + 1</code>

Hence, continuing the current example:

>              x: 11111111
>     s = x >> m: 00011111

<code>s &gt; 1</code>, so <code>l = m + 1 = 4</code>, and the search window has shrunk:

>     x = s1 ^ s2: 11111111
>           u = 7 -|  |- l = 4

Updating the midpoint yields <code>m = (7 + 4) / 2 = 5</code>:

>              x: 11111111
>     s = x >> m: 00000111

Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 6</code>, and the window
shrinks again:

>     x = s1 ^ s2: 11111111
>           u = 7 -||- l = 6
>     s = x >> m: 00000011

Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 7</code>, the final iteration:

>     x = s1 ^ s2: 11111111
>           u = 7 -|- l = 7
>     s = x >> m: 00000001

Here, <code>s == 1</code>, which means that <code>c = m = 7</code>. Notably this
search has converged after only 3 iterations, as opposed to 7
for the linear search proposed above, and in general such a
search converges after $log_2(k)$ iterations at most, where $k$
is the number of bits in each of the strings <code>s1</code> and <code>s2</code> under
comparison. Hence this search method improves the $O(k)$ search
proposed by [Langley 2008](#references) to $O(log_2(k))$, and
moreover, determines the actual number of the critical bit,
rather than just a bitmask with bit <code>c</code> set, as he proposes,
which can also be easily generated via <code>1 &lt;&lt; c</code>.


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_critical_bit">get_critical_bit</a>(s1: u128, s2: u128): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_critical_bit">get_critical_bit</a>(
    s1: u128,
    s2: u128,
): u8 {
    <b>let</b> x = s1 ^ s2; // XOR result marked 1 at bits that differ.
    <b>let</b> l = 0; // Lower bound on critical bit search.
    <b>let</b> u = <a href="critqueue.md#0xc0deb00c_critqueue_MSB_u128">MSB_u128</a>; // Upper bound on critical bit search.
    <b>loop</b> { // Begin binary search.
        <b>let</b> m = (l + u) / 2; // Calculate midpoint of search window.
        <b>let</b> s = x &gt;&gt; m; // Calculate midpoint shift of XOR result.
        <b>if</b> (s == 1) <b>return</b> m; // If shift equals 1, c = m.
        // Update search bounds.
        <b>if</b> (s &gt; 1) l = m + 1 <b>else</b> u = m - 1;
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_is_set"></a>

## Function `is_set`

Return <code><b>true</b></code> if <code>key</code> is set at <code>bit_number</code>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_set">is_set</a>(key: u128, bit_number: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_is_set">is_set</a>(key: u128, bit_number: u8): bool {key &gt;&gt; bit_number & 1 == 1}
</code></pre>



</details>
