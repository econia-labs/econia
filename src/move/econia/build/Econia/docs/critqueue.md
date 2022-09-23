
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
* [Inner keys](#inner-keys)
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


The present implementation involves a tree with <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> and <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code>
nodes. <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> nodes have two <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> children each, and <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> nodes
do not have children. <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> nodes store a value of type <code>V</code>, and
have a <code>u128</code> key. <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> nodes store a <code>u8</code> indicating the
most-significant critical bit (crit-bit) of divergence between
<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys from the <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node's two subtrees: <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys in an
<code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node's left subtree are unset at the critical bit, while
<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys in a <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node's right subtree are set at the
critical bit.

<code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> nodes are arranged hierarchically, with the most
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

Here, the <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node marked <code>2nd</code> stores the critical bit <code>2</code>, the
<code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node marked <code>1st</code> stores the critical bit <code>1</code>, and the
<code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node marked <code>0th</code> stores the critical bit <code>0</code>. Hence, the
sole <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> key in the left subtree of the <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node marked <code>2nd
</code> is unset at bit 2, while all the keys in right subtree of
the <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node marked <code>2nd</code> are set at bit 2. And similarly
for the <code><a href="critqueue.md#0xc0deb00c_critqueue_Inner">Inner</a></code> node marked <code>0th</code>, the <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> key of its left child
is unset at bit 0, while the <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> key of its right child is set
at bit 0.


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



<a name="@Inner_keys_9"></a>

### Inner keys


If the insertion of a crit-bit tree leaf is accompanied by the
generation of a crit-bit tree inner node, the inner node is assigned
an "inner key" that is identical to the corresponding leaf key,
except with bit 63 set. This schema allows for
discrimination between leaf keys and inner keys based simply on
bit 63.


<a name="@Key_tables_10"></a>

### Key tables


Enqueue, inner, and leaf keys are stored in separate hash tables:

| Table key  | Key type | Table value                       |
|------------|----------|-----------------------------------|
| Enqueue    | <code>u64</code>    | Enqueue count for key, if nonzero |
| Inner      | <code>u128</code>   | Crit-bit tree inner node          |
| Leaf       | <code>u128</code>   | Crit-bit tree leaf                |

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
<code>enqueue()</code>, which accepts a <code>u64</code> enqueue key and an enqueue value
of type <code>V</code>. A corresponding <code>u128</code> leaf key is returned, which can
be used for subsequent leaf key lookup via <code>borrow()</code>,
<code>borrow_mut()</code>, or <code>remove()</code>.


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


With <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> nodes stored in a <code>Table</code>, <code>remove()</code> operations are
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
are initialized via <code>dequeue_init()</code>, and iterated via <code>dequeue()</code>.

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
    -  [Inner keys](#@Inner_keys_9)
    -  [Key tables](#@Key_tables_10)
-  [Operations](#@Operations_11)
    -  [Enqueues](#@Enqueues_12)
    -  [Removals](#@Removals_13)
    -  [Dequeues](#@Dequeues_14)
-  [Struct `CritQueue`](#0xc0deb00c_critqueue_CritQueue)
-  [Struct `Inner`](#0xc0deb00c_critqueue_Inner)
-  [Struct `Leaf`](#0xc0deb00c_critqueue_Leaf)
-  [Struct `SubQueueNode`](#0xc0deb00c_critqueue_SubQueueNode)


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
 Crit-queue sort direction, <code>ASCENDING</code> or <code>DESCENDING</code>.
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
<code>values: <a href="_Table">table::Table</a>&lt;u128, <a href="critqueue.md#0xc0deb00c_critqueue_SubQueueNode">critqueue::SubQueueNode</a>&lt;V&gt;&gt;</code>
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
 If no sub-queue head, should also be none, since leaf is a
 free leaf. Else corresponds to the inner key of the parent
 node, none when leaf is the root of the crit-bit tree.
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
<code>value: V</code>
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
