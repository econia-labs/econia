
<a name="0xc0deb00c_critqueue"></a>

# Module `0xc0deb00c::critqueue`

Hybrid data structure combining crit-bit tree and queue properties.

Bit numbers are 0-indexed from the least-significant bit (LSB):

>     11101...1010010101
>      bit 5 = 0 -|    |- bit 0 = 1


<a name="@Crit-bit_trees_0"></a>

## Crit-bit trees



<a name="@General_1"></a>

### General


A critical bit (crit-bit) tree is a compact binary prefix tree
that stores a prefix-free set of bitstrings, like n-bit integers or
variable-length 0-terminated byte strings. For a given set of keys
there exists a unique crit-bit tree representing the set, and
crit-bit trees do not require complex rebalancing algorithms like
those of AVL or red-black binary search trees. Crit-bit trees
support the following operations:

* Membership testing
* Insertion
* Deletion
* Predecessor
* Successor
* Iteration


<a name="@Structure_2"></a>

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

<code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> keys are automatically sorted upon insertion.


<a name="@References_3"></a>

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


<a name="@Crit-queues_4"></a>

## Crit-queues



<a name="@Enqueue_key_multiplicity_5"></a>

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


<a name="@Dequeue_order_6"></a>

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


<a name="@Leaf_key_structure_7"></a>

### Leaf key structure


In the present implementation, crit-queue leaf keys have the
following bit structure (<code>NOT</code> denotes bitwise complement):

| Bit(s) | Ascending crit-queue | Descending crit-queue |
|--------|----------------------|-----------------------|
| 0-61   | Enqueue count        | <code>NOT</code> enqueue count   |
| 62     | 0                    | 1                     |
| 63     | 0                    | 0                     |
| 64-127 | Enqueue key          | Enqueue key           |

Continuing the above example, this yields the following leaf keys
and crit-bit tree for an ascending crit-queue:

| Enqueue key | Leaf key bits 64-127 | Leaf key bits 0-63 |
|-------------|----------------------|--------------------|
| $k_{0, 0}$  | <code>000...000</code>          | <code>000...000</code>        |
| $k_{0, 1}$  | <code>000...000</code>          | <code>000...001</code>        |
| $k_{1, 0}$  | <code>000...001</code>          | <code>000...000</code>        |
| $k_{1, 1}$  | <code>000...001</code>          | <code>000...001</code>        |
| $k_{3, 0}$  | <code>000...011</code>          | <code>000...000</code>        |

>                               65th
>                              /    \
>                          64th      k_{3, 0}
>                 ________/    \________
>              0th                      0th
>             /   \                    /   \
>     k_{0, 0}     k_{0, 1}    k_{1, 0}     k_{1, 1}

---


-  [Crit-bit trees](#@Crit-bit_trees_0)
    -  [General](#@General_1)
    -  [Structure](#@Structure_2)
    -  [References](#@References_3)
-  [Crit-queues](#@Crit-queues_4)
    -  [Enqueue key multiplicity](#@Enqueue_key_multiplicity_5)
    -  [Dequeue order](#@Dequeue_order_6)
    -  [Leaf key structure](#@Leaf_key_structure_7)
-  [Struct `QueueCrit`](#0xc0deb00c_critqueue_QueueCrit)
    -  [Parent keys](#@Parent_keys_8)
    -  [Key tables](#@Key_tables_9)
    -  [Insertion key table](#@Insertion_key_table_10)
    -  [Advantages](#@Advantages_11)
-  [Struct `Leaf`](#0xc0deb00c_critqueue_Leaf)
-  [Struct `Parent`](#0xc0deb00c_critqueue_Parent)
-  [Constants](#@Constants_12)
-  [Function `crit_borrow`](#0xc0deb00c_critqueue_crit_borrow)
-  [Function `crit_borrow_mut`](#0xc0deb00c_critqueue_crit_borrow_mut)
-  [Function `crit_pop`](#0xc0deb00c_critqueue_crit_pop)
-  [Function `get_head`](#0xc0deb00c_critqueue_get_head)
-  [Function `insert`](#0xc0deb00c_critqueue_insert)
-  [Function `new`](#0xc0deb00c_critqueue_new)
-  [Function `queue_pop_init`](#0xc0deb00c_critqueue_queue_pop_init)
    -  [Parameters](#@Parameters_13)
    -  [Returns](#@Returns_14)
    -  [Aborts if](#@Aborts_if_15)
-  [Function `queue_pop`](#0xc0deb00c_critqueue_queue_pop)
    -  [Parameters](#@Parameters_16)
    -  [Returns](#@Returns_17)
    -  [Aborts if](#@Aborts_if_18)
-  [Function `takes_priority`](#0xc0deb00c_critqueue_takes_priority)
-  [Function `trails_head`](#0xc0deb00c_critqueue_trails_head)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table</a>;
</code></pre>



<a name="0xc0deb00c_critqueue_QueueCrit"></a>

## Struct `QueueCrit`

With the insertion key contained in the most significant bits,
elements are thus sorted in the crit-bit tree first by insertion
key and then by:

* Insertion count if an ascending queue, or
* Bitwise complement of insertion count if a descending queue.

Hence when accessing elements starting from the front of the
queue, the queue-specific sorting order is thus acheived by:

* Inorder successor traversal starting from the minimum leaf key
if an ascending queue, or
* Inorder predecessor traversal starting from the maximum leaf
key if a descending queue.


<a name="@Parent_keys_8"></a>

### Parent keys


If the insertion of a crit-bit tree leaf is accompanied by the
generation of a crit-bit tree parent node, the parent is
assigned a "parent key" that is identical to the corresponding
leaf key, except with bit 63 set. This schema allows for
discrimination between leaf keys and parent keys based simply
on bit 63.


<a name="@Key_tables_9"></a>

### Key tables


Insertion, leaf, and parent keys are each stored in separate
hash tables:

| Table key  | Key type | Table value                         |
|------------|----------|-------------------------------------|
| Insertion  | <code>u64</code>    | Insertion count for key, if nonzero |
| Leaf       | <code>u128</code>   | Crit-bit tree leaf                  |
| Parent     | <code>u128</code>   | Crit-bit tree parent node           |


<a name="@Insertion_key_table_10"></a>

### Insertion key table


The insertion key table is initialized empty, such that before
inserting the first instance of a given insertion key,
$k_{i, 0}$, the insertion key table does not have an entry for
key $i$. During insertion, the entry $\{i, 0\}$ is added to the
table, and for each subsequent insertion, $k_{i, n}$, the value
corresponding to key $i$ is updated to $n$.

Since bits 62 and 63 in leaf keys are reserved for flag bits,
the maximum insertion count per insertion key is thus
$2^{62} - 1$.


<a name="@Advantages_11"></a>

### Advantages


Key-value insertion to a <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code> accepts a <code>u64</code> insertion
key and an insertion value of type <code>V</code>, and returns a <code>u128</code>
leaf key. Subsequent leaf key lookup, including deletion, is
thus $O(1)$ since each <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> is stored in a <code>Table</code>,
and deletions behind the head of the queue are additionally
parallelizable in the general case where:

* Deletions do not have overlapping tree edges.

Insertions are, like a crit-bit tree, $O(k^{\dagger})$ in the
worst case, where $k^{\dagger} = k - 2 = 126$ (the number of
variable bits in a leaf key), but parallelizable in the general
case where:

1. Insertions do not have overlapping tree edges.
2. Insertions do not share the same insertion key.

The second parallelism constraint is a result of insertion count
updates, and may potentially be eliminated in the case of a
parallelized insertion count aggregator.

---


<pre><code><b>struct</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>direction: bool</code>
</dt>
<dd>
 Queue sort direction, <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code>.
</dd>
<dt>
<code>root: <a href="_Option">option::Option</a>&lt;u128&gt;</code>
</dt>
<dd>
 Key of root node. If none, tree is empty.
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
<code>insertions: <a href="_Table">table::Table</a>&lt;u64, u64&gt;</code>
</dt>
<dd>
 Map from insertion key to 0-indexed insertion count.
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
 Map from leaf key to <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> having insertion value type <code>V</code>.
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
 Insertion value.
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

<a name="@Constants_12"></a>

## Constants


<a name="0xc0deb00c_critqueue_ASCENDING"></a>

Ascending sort direction flag. <code>0</code> when cast to <code>u64</code> bit flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_DESCENDING"></a>

Descending sort direction flag. <code>1</code> when cast to <code>u64</code> bit flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_critqueue_DIRECTION"></a>

Bit number of queue sort direction flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_DIRECTION">DIRECTION</a>: u8 = 62;
</code></pre>



<a name="0xc0deb00c_critqueue_LEAF"></a>

Node type bit flag indicating <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_LEAF">LEAF</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_critqueue_NODE_TYPE"></a>

Bit number of crit-bit node type flag.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_NODE_TYPE">NODE_TYPE</a>: u8 = 63;
</code></pre>



<a name="0xc0deb00c_critqueue_PARENT"></a>

Node type bit flag indicating <code><a href="critqueue.md#0xc0deb00c_critqueue_Parent">Parent</a></code>.


<pre><code><b>const</b> <a href="critqueue.md#0xc0deb00c_critqueue_PARENT">PARENT</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_critqueue_crit_borrow"></a>

## Function `crit_borrow`

Borrow insertion value corresponding to given leaf key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_crit_borrow">crit_borrow</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;, _leaf_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_crit_borrow">crit_borrow</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
    _leaf_key: u128
)/*: &V*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_crit_borrow_mut"></a>

## Function `crit_borrow_mut`

Mutably borrow insertion value corresponding to given leaf key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_crit_borrow_mut">crit_borrow_mut</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;, _leaf_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_crit_borrow_mut">crit_borrow_mut</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
    _leaf_key: u128
)/*: &V*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_crit_pop"></a>

## Function `crit_pop`

Pop corresonding leaf, return insertion value.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_crit_pop">crit_pop</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;, _leaf_key: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_crit_pop">crit_pop</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
    _leaf_key: u128
)/*: V*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_get_head"></a>

## Function `get_head`

Return head leaf key, if any.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_head">get_head</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_get_head">get_head</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
)/*: Option&lt;u128&gt; */ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_insert"></a>

## Function `insert`

Insert key-value pair, returning generated leaf key.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;, _insert_key: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_insert">insert</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
    _insert_key: u64,
    //_insert_value: V,
)/*: u128*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_new"></a>

## Function `new`

Return <code><a href="critqueue.md#0xc0deb00c_critqueue_ASCENDING">ASCENDING</a></code> or <code><a href="critqueue.md#0xc0deb00c_critqueue_DESCENDING">DESCENDING</a></code> <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code>, per <code>direction</code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V&gt;(_direction: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_new">new</a>&lt;V&gt;(
    _direction: bool
)/*: <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>*/ {}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_queue_pop_init"></a>

## Function `queue_pop_init`

Mutably borrow the head of the queue in preparation for a pop.


<a name="@Parameters_13"></a>

### Parameters

* <code>queue_crit_ref_mut</code>: Mutable reference to <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code>.


<a name="@Returns_14"></a>

### Returns

* <code>u128</code>: Queue head leaf key.
* <code>&<b>mut</b> V</code>: Mutable reference to queue head insertion value.
* <code>bool</code>: <code><b>true</b></code> if the queue <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> has a parent, and thus if
there is another element to iterate to. If <code><b>false</b></code>, can still
pop the head via <code><a href="critqueue.md#0xc0deb00c_critqueue_crit_pop">crit_pop</a>()</code>.


<a name="@Aborts_if_15"></a>

### Aborts if

* Indicated <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code> is empty.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_queue_pop_init">queue_pop_init</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_queue_pop_init">queue_pop_init</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;
)//: (
    //u128,
    //&<b>mut</b> V,
    //bool
/*)*/ {
    // Can ensure that there is a queue head by attempting <b>to</b> borrow
    // corresponding leaf key from `CritQueue.head`, which aborts
    // <b>if</b> none.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_queue_pop"></a>

## Function `queue_pop`

Pop head and borrow next element in the queue, the new head.

Should only be called after <code>queue_borrow_mut()</code> indicates that
iteration can proceed, or if a subsequent call to <code><a href="critqueue.md#0xc0deb00c_critqueue_queue_pop">queue_pop</a>()</code>
indicates the same.


<a name="@Parameters_16"></a>

### Parameters

* <code>queue_crit_ref_mut</code>: Mutable reference to <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code>.


<a name="@Returns_17"></a>

### Returns

* <code>u128</code>: New queue head leaf key.
* <code>&<b>mut</b> V</code>: Mutable reference to new queue head insertion value.
* <code>bool</code>: <code><b>true</b></code> if the new queue head <code><a href="critqueue.md#0xc0deb00c_critqueue_Leaf">Leaf</a></code> has a parent, and
thus if iteration can proceed for another pop.


<a name="@Aborts_if_18"></a>

### Aborts if

* Indicated <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code> is empty.
* Indicated <code><a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a></code> is a singleton, e.g. if there are no
elements to proceed to after popping.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_queue_pop">queue_pop</a>&lt;V&gt;(_queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_queue_pop">queue_pop</a>&lt;V&gt;(
    _queue_crit_ref_mut: &<b>mut</b> <a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;
)//: (
    //u128,
    //&<b>mut</b> V,
    //bool
/*)*/ {
    // Can ensure that there is a queue head by attempting <b>to</b> borrow
    // the corresonding leaf key from the <a href="">option</a> field, which aborts
    // <b>if</b> it is none.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_takes_priority"></a>

## Function `takes_priority`

Return <code><b>true</b></code> if <code>insertion_key</code> would become new head if
inserted, else <code><b>false</b></code>.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_takes_priority">takes_priority</a>&lt;V&gt;(_queue_crit_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;, _insertion_key: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_takes_priority">takes_priority</a>&lt;V&gt;(
    _queue_crit_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
    _insertion_key: u64
)/*: bool*/ {
    // Return <b>true</b> <b>if</b> empty.
    // If ascending, <b>return</b> <b>true</b> <b>if</b> less than head insertion key.
    // If descending, <b>return</b> <b>true</b> <b>if</b> greater than head insertion
    // key.
}
</code></pre>



</details>

<a name="0xc0deb00c_critqueue_trails_head"></a>

## Function `trails_head`

Return <code><b>true</b></code> if <code>insertion_key</code> would not become the head if
inserted.


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_trails_head">trails_head</a>&lt;V&gt;(_queue_crit_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">critqueue::QueueCrit</a>&lt;V&gt;, _insertion_key: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critqueue.md#0xc0deb00c_critqueue_trails_head">trails_head</a>&lt;V&gt;(
    _queue_crit_ref: &<a href="critqueue.md#0xc0deb00c_critqueue_QueueCrit">QueueCrit</a>&lt;V&gt;,
    _insertion_key: u64
)/*: bool*/ {
    // Return <b>false</b> <b>if</b> empty.
    // If ascending, <b>return</b> <b>true</b> <b>if</b> greater than/equal <b>to</b> head
    // insertion key.
    // If descending, <b>return</b> <b>true</b> <b>if</b> less than/equal <b>to</b> head
    // insertion key.
}
</code></pre>



</details>
