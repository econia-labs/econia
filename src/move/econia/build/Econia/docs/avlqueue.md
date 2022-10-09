
<a name="0xc0deb00c_avlqueue"></a>

# Module `0xc0deb00c::avlqueue`

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


Tree nodes and list nodes are each assigned a 0-indexed 14-bit
serial ID known as a node ID. Node ID <code>0b11111111111111</code> is reserved
for null, such that the maximum number of allocated nodes for each
node type is thus $2 ^ {14} - 1$.


<a name="@Access_keys_2"></a>

## Access keys


| Bit(s) | Data                            |
|--------|---------------------------------|
| 61     | If set, ascending AVL queue     |
| 60     | If set, descending AVL queue    |
| 46-59  | Tree node ID                    |
| 32-45  | List node ID                    |
| 0-31   | Insertion key                   |


<a name="@Complete_docgen_index_3"></a>

## Complete docgen index


The below index is automatically generated from source code:


-  [References](#@References_0)
-  [Node IDs](#@Node_IDs_1)
-  [Access keys](#@Access_keys_2)
-  [Complete docgen index](#@Complete_docgen_index_3)
-  [Struct `AVLqueue`](#0xc0deb00c_avlqueue_AVLqueue)
-  [Struct `TreeNode`](#0xc0deb00c_avlqueue_TreeNode)
-  [Struct `ListNode`](#0xc0deb00c_avlqueue_ListNode)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::table_with_length</a>;
</code></pre>



<a name="0xc0deb00c_avlqueue_AVLqueue"></a>

## Struct `AVLqueue`

A hybrid between an AVL tree and a queue. See above.

Most non-table fields stored compactly in <code>bits</code> as follows:

| Bit(s)  | Data                                  |
|---------|---------------------------------------|
| 127     | If set, ascending AVL queue           |
| 126     | If set, descending AVL queue          |
| 112-125 | Tree node ID at top of inactive stack |
| 98-111  | List node ID at top of inactive stack |
| 84-97   | AVL queue head list node ID           |
| 52-83   | AVL queue head insertion key          |
| 38-51   | AVL queue tail list node ID           |
| 6-37    | AVL queue tail insertion key          |
| 0-5     | Bits 8-13 of tree root node ID        |

Bits 0-7 of the tree root node ID are stored in <code>root_lsbs</code>.


<pre><code><b>struct</b> <a href="avlqueue.md#0xc0deb00c_avlqueue_AVLqueue">AVLqueue</a>&lt;V&gt; <b>has</b> store
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
<code>tree_nodes: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="avlqueue.md#0xc0deb00c_avlqueue_TreeNode">avlqueue::TreeNode</a>&gt;</code>
</dt>
<dd>
 Map from tree node ID to tree node.
</dd>
<dt>
<code>list_nodes: <a href="_TableWithLength">table_with_length::TableWithLength</a>&lt;u64, <a href="avlqueue.md#0xc0deb00c_avlqueue_ListNode">avlqueue::ListNode</a>&gt;</code>
</dt>
<dd>
 Map from list node ID to list node.
</dd>
<dt>
<code>insertion_values: <a href="_Table">table::Table</a>&lt;u64, <a href="_Option">option::Option</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Map from list node ID to optional insertion value.
</dd>
</dl>


</details>

<a name="0xc0deb00c_avlqueue_TreeNode"></a>

## Struct `TreeNode`

A tree node in an AVL queue.

All fields stored compactly in <code>bits</code> as follows:

| Bit(s) | Data                                 |
|--------|--------------------------------------|
| 87-118 | Insertion key                        |
| 86     | If set, balance factor is 1          |
| 85     | If set, balance factor is 0          |
| 84     | If set, balance factor is -1         |
| 70-83  | Parent node ID                       |
| 56-69  | Left child node ID                   |
| 42-55  | Right child node ID                  |
| 28-41  | List head node ID                    |
| 14-27  | List tail node ID                    |
| 0-13   | Next inactive node ID, when in stack |


<pre><code><b>struct</b> <a href="avlqueue.md#0xc0deb00c_avlqueue_TreeNode">TreeNode</a> <b>has</b> store
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

<a name="0xc0deb00c_avlqueue_ListNode"></a>

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

In only the case of the next node ID, if set at bit 15 and bit
14, the next node is the next inactive list node in the
inactive list nodes stack.


<pre><code><b>struct</b> <a href="avlqueue.md#0xc0deb00c_avlqueue_ListNode">ListNode</a> <b>has</b> store
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
