# CritBit

## Module `0xc0deb00c::CritBit`

### Background

A critical bit (crit-bit) tree is a compact binary prefix tree, similar to a binary search tree, that stores a prefix-free set of bitstrings, like n-bit integers or variable-length 0-terminated byte strings. For a given set of keys there exists a unique crit-bit tree representing the set, hence crit-bit trees do not require complex rebalancing algorithms like those of AVL or red-black binary search trees. Crit-bit trees support the following operations, quickly:

* Membership testing
* Insertion
* Deletion
* Predecessor
* Successor
* Iteration

#### References

* [Bernstein 2006](https://cr.yp.to/critbit.html)
* [Langley 2008](https://www.imperialviolet.org/2008/09/29/critbit-trees.html)
* [Langley 2012](https://github.com/agl/critbit)
* [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)

### Implementation

#### Structure

The present implementation involves a tree with two types of nodes, inner ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)) and outer ([`O`](critbit.md#0xc0deb00c\_CritBit\_O)). Inner nodes have two children each ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.l` and [`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.r`), while outer nodes have no children. There are no nodes that have exactly one child. Outer nodes store a key-value pair with a 128-bit integer as a key ([`O`](critbit.md#0xc0deb00c\_CritBit\_O)`.k`), and an arbitrary value of generic type ([`O`](critbit.md#0xc0deb00c\_CritBit\_O)`.v`). Inner nodes do not store a key, but rather, an 8-bit integer ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.c`) indicating the most significant critical bit (crit-bit) of divergence between keys located within the node's two subtrees: keys in the node's left subtree are unset at the critical bit, while keys in the node's right subtree are set at the critical bit. Both node types have a parent ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.p`, [`O`](critbit.md#0xc0deb00c\_CritBit\_O)`.p`), which may be flagged as [`ROOT`](critbit.md#0xc0deb00c\_CritBit\_ROOT) if the the node is the root.

Bit numbers are 0-indexed starting at the least-significant bit (LSB), such that a critical bit of 3, for instance, corresponds to a comparison between `00...00000` and `00...01111`. Inner nodes are arranged hierarchically, with the most significant critical bits at the top of the tree. For instance, the keys `001`, `101`, `110`, and `111` would be stored in a crit-bit tree as follows (right carets included at left of illustration per issue with documentation build engine, namely, the automatic stripping of leading whitespace in documentation comments, which prohibits the simple initiation of monospaced code blocks through indentation by 4 spaces):

```
>       2nd
>      /   \
>    001   1st
>         /   \
>       101   0th
>            /   \
>          110   111
```

Here, the inner node marked `2nd` stores the integer 2, the inner node marked `1st` stores the integer 1, and the inner node marked `0th` stores the integer 0. Hence, the sole key in the left subtree of the inner node marked `2nd` is unset at bit 2, while all the keys in the node's right subtree are set at bit 2. And similarly for the inner node marked `0th`, its left child is unset at bit 0, while its right child is set at bit 0.

#### Node indices

Both inner nodes ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)) and outer nodes ([`O`](critbit.md#0xc0deb00c\_CritBit\_O)) are stored in vectors ([`CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`.i` and [`CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`.o`), and parent-child relationships between nodes are described in terms of vector indices: an outer node indicating `123` in its parent field ([`O`](critbit.md#0xc0deb00c\_CritBit\_O)`.p`), for instance, has as its parent an inner node at vector index `123`. Notably, the vector index of an inner node is identical to the number indicated by its child's parent field ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.p` or [`O`](critbit.md#0xc0deb00c\_CritBit\_O)`.p`), but the vector index of an outer node is **not** identical to the number indicated by its parent's child field ([`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.l` or [`I`](critbit.md#0xc0deb00c\_CritBit\_I)`.r`), because the 63rd bit of a so-called "field index" (the number stored in a struct field) is reserved for a node type bit flag, with outer nodes having bit 63 set and inner nodes having bit 63 unset. This schema enables discrimination between node types based solely on the "field index" of a related node via [`is_out`](critbit.md#0xc0deb00c\_CritBit\_is\_out)`()`, but requires that outer node indices be routinely converted between "child field index" form and "vector index" form via [`o_c`](critbit.md#0xc0deb00c\_CritBit\_o\_c)`()` and [`o_v`](critbit.md#0xc0deb00c\_CritBit\_o\_v)`()`.

Similarly, if a node, inner or outer, is located at the root, its "parent field index" will indicate [`ROOT`](critbit.md#0xc0deb00c\_CritBit\_ROOT), and will not correspond to the vector index of any inner node, since the root node does not have a parent. Likewise, the "root field" of the tree ([`CB`](critbit.md#0xc0deb00c\_CritBit\_CB)`.r`) will contain the field index of the given node, set at bit 63 if the root is an outer node.

### Basic public functions

#### Initialization

* [`empty`](critbit.md#0xc0deb00c\_CritBit\_empty)`()`
* [`singleton`](critbit.md#0xc0deb00c\_CritBit\_singleton)`()`

#### Mutation

* [`borrow_mut`](critbit.md#0xc0deb00c\_CritBit\_borrow\_mut)`()`
* [`insert`](critbit.md#0xc0deb00c\_CritBit\_insert)`()`
* [`pop`](critbit.md#0xc0deb00c\_CritBit\_pop)`()`

#### Lookup

* [`borrow`](critbit.md#0xc0deb00c\_CritBit\_borrow)`()`
* [`has_key`](critbit.md#0xc0deb00c\_CritBit\_has\_key)`()`
* [`max_key`](critbit.md#0xc0deb00c\_CritBit\_max\_key)`()`
* [`min_key`](critbit.md#0xc0deb00c\_CritBit\_min\_key)`()`

#### Size

* [`is_empty`](critbit.md#0xc0deb00c\_CritBit\_is\_empty)`()`
* [`length`](critbit.md#0xc0deb00c\_CritBit\_length)`()`

#### Destruction

* [`destroy_empty`](critbit.md#0xc0deb00c\_CritBit\_destroy\_empty)`()`

### Traversal

[Predecessor public functions](critbit.md#Predecessor-public-functions) and [successor public functions](critbit.md#Successor-public-functions) are wrapped [generic private functions](critbit.md#Generic-private-functions), with [generic private function](critbit.md#Generic-private-functions) documentation comments detailing the relevant algorithms. See [walkthrough](critbit.md#Walkthrough) for canonical implementation syntax.

#### Predecessor public functions

* [`traverse_p_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_init\_mut)`()`
* [`traverse_p_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_mut)`()`
* [`traverse_p_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_pop\_mut)`()`

#### Successor public functions

* [`traverse_s_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_s\_init\_mut)`()`
* [`traverse_s_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_s\_mut)`()`
* [`traverse_s_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_s\_pop\_mut)`()`

#### Generic private functions

* [`traverse_c_i`](critbit.md#0xc0deb00c\_CritBit\_traverse\_c\_i)`()`
* [`traverse_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_init\_mut)`()`
* [`traverse_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_mut)`()`
* [`traverse_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_pop\_mut)`()`

#### Walkthrough

* [Syntax motivations](critbit.md#Syntax-motivations)
* [Full predecessor traversal](critbit.md#Full-predecessor-traversal)
* [Partial successor traversal](critbit.md#Partial-successor-traversal)
* [Singleton traversal initialization](critbit.md#Singleton-traversal-initialization)

**Syntax motivations**

Iterated traversal, unlike other public implementations, exposes internal [node indices](critbit.md#Node-indices) that must be tracked during loopwise operations, because Move's borrow-checking system prohibits mutably borrowing a [`CB`](critbit.md#0xc0deb00c\_CritBit\_CB) when an [`I`](critbit.md#0xc0deb00c\_CritBit\_I) or [`O`](critbit.md#0xc0deb00c\_CritBit\_O) is already being mutably borrowed. Not that this borrow-checking constraint introduces an absolute prohibition on iterated traversal without exposed node indices, but rather, the given borrow-checking constraints render non-node-index-exposed traversal inefficient: to traverse without exposing internal node indices would require searching for a key from the root during each iteration. Instead, by publicly exposing node indices, it is possible to walk from one outer node to the next without having to perform such redundant operations, per [`traverse_c_i`](critbit.md#0xc0deb00c\_CritBit\_traverse\_c\_i)`()`.

The test `traverse_demo()` provides canonical traversal syntax in this regard, with exposed node indices essentially acting as pointers. Hence, node-index-exposed traversal presents a kind of circumvention of Move's borrow-checking system, implemented only due to a need for greater efficiency. Like pointer-based implementations in general, this solution is extremely powerful in terms of the speed enhancement it provides, but if used incorrectly it can lead to "undefined behavior." As such, a breakdown of the canonical syntax is provided below, along with additional discussion on error-checking facilities that have been intentionally excluded in the interest of efficiency.

**Full predecessor traversal**

To start, initialize a tree with {$n, 100n$}, for $0 < n < 10$:

```
let cb = empty(); // Initialize empty tree
// Insert {n, 100 * n} for 0 < n < 10, out of order
insert(&mut cb, 9, 900);
insert(&mut cb, 6, 600);
insert(&mut cb, 3, 300);
insert(&mut cb, 1, 100);
insert(&mut cb, 8, 800);
insert(&mut cb, 2, 200);
insert(&mut cb, 7, 700);
insert(&mut cb, 5, 500);
insert(&mut cb, 4, 400);
```

Before starting traversal, first verify that the tree is not empty:

```
assert!(!is_empty(&cb), 0); // Assert tree not empty
```

This check could be performed within the generalized initialization function, [`traverse_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_init\_mut)`()`, but doing so would introduce compounding computational overhead, especially for applications where traversal is repeatedly initialized after having already established that the tree in question is not empty. Hence it is assumed that any functions which call traversal initializers will only do so after having verified that node iteration is possible in the first place, and that they will track loop counters to prevent an attempted traversal past the end of the tree. The loop counters in question include a counter for the number of keys in the tree, which must be decremented if any nodes are popped during traversal, and a counter for the number of remaining traversals possible:

```
let n = length(&cb); // Get number of keys in the tree
let r = n - 1; // Get number of remaining traversals possible
```

Continuing the example, then initialize predecessor traversal per [`traverse_p_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_init\_mut)`()`, storing the max key in the tree, a mutable reference to its corresponding value, the parent field of the corresponding node, and the child field index of the corresponding node.

```
// Initialize predecessor traversal: get max key in tree,
// mutable reference to corresponding value, parent field of
// corresponding node, and the child field index of it
let (k, v_r, p_f, c_i) = traverse_p_init_mut(&mut cb);
```

Now perform an inorder predecessor traversal, popping out the node for any keys that are a multiple of 4, otherwise incrementing the corresponding value by a monotonically increasing multiple of 10, starting at 10, with the exception of the final node, which has its value set to 0. Hence, {9, 900} updates to {9, 910}, {8, 800} gets popped, {7, 700} updates to {7, 720}, and so on, until {1, 100} gets updated to {1, 0}. Again, since Move's documentation build engine strips leading whitespace, right carets are included to preserve indentation:

```
> let i = 10; // Initialize value increment counter
> while(r > 0) { // While remaining traversals possible
>     if (k % 4 == 0) { // If key is a multiple of 4
>         // Traverse pop corresponding node and discard its value
>         (k, v_r, p_f, c_i, _) =
>             traverse_p_pop_mut(&mut cb, k, p_f, c_i, n);
>         n = n - 1; // Decrement key count
>     } else { // If key is not a multiple of 4
>         *v_r = *v_r + i; // Increment corresponding value
>         i = i + 10; // Increment by 10 more next iteration
>         // Traverse to predecessor
>         (k, v_r, p_f, c_i) = traverse_p_mut(&mut cb, k, p_f);
>     };
>     r = r - 1; // Decrement remaining traversal count
> }; // Traversal has ended up at node having minimum key
> *v_r = 0; // Set corresponding value to 0
```

After the traversal, {4, 400} and {8, 800} have thus been popped, and key-value pairs have updated accordingly:

```
// Assert keys popped correctly
assert!(!has_key(&cb, 4) && !has_key(&cb, 8), 1);
// Assert correct value updates
assert!(*borrow(&cb, 1) ==   0, 2);
assert!(*borrow(&cb, 2) == 260, 3);
assert!(*borrow(&cb, 3) == 350, 4);
assert!(*borrow(&cb, 5) == 540, 5);
assert!(*borrow(&cb, 6) == 630, 6);
assert!(*borrow(&cb, 7) == 720, 7);
assert!(*borrow(&cb, 9) == 910, 8);
```

Here, the only assurance that the traversal does not go past the end of the tree is the proper tracking of loop variables: again, the relevant error-checking could have been implemented in a corresponding traversal function, namely [`traverse_c_i`](critbit.md#0xc0deb00c\_CritBit\_traverse\_c\_i)`()`, but this would introduce compounding computational overhead. Since traversal already requires precise management of loop counter variables and node indices, it is assumed that they are managed correctly and thus no native error-checking is implemented so as to improve efficiency.

**Partial successor traversal**

Continuing the example, since the number of keys was updated during the last loop, simply check that key count is greater than 0 to verify tree is not empty. Then re-initialize the remaining traversal counter, and this time use a value increment counter for a monotonically increasing multiple of 1. Then initialize sucessor traversal:

```
assert!(n > 0, 9); // Assert tree still not empty
// Re-initialize remaining traversal, value increment counters
(r, i) = (n - 1, 1);
// Initialize successor traversal
(k, v_r, p_f, c_i) = traverse_s_init_mut(&mut cb);
```

Here, if the key is equal to 7, then traverse pop the corresponding node and store its value, then stop traversal:

```
> let v = 0; // Initialize variable to store value of matched node
> while(r > 0) { // While remaining traversals possible
>     if (k == 7) { // If key is 7
>         // Traverse pop corresponding node and store its value
>         (_, _, _, _, v) = traverse_s_pop_mut(&mut cb, k, p_f, c_i, n);
>         break // Stop traversal
>     } else { // For all keys not equal to 7
>         *v_r = *v_r + i; // Increment corresponding value
>         // Traverse to successor
>         (k, v_r, p_f, c_i) = traverse_s_mut(&mut cb, k, p_f);
>         i = i + 1; // Increment by 1 more next iteration
>     };
>     r = r - 1; // Decrement remaining traversal count
> };
```

Hence {7, 720} has been popped, {9, 910} has been left unmodified, and other key-value pairs have been updated accordingly:

```
// Assert key popped correctly
assert!(!has_key(&cb, 7), 10);
// Assert value of popped node stored correctly
assert!(v == 720, 11);
// Assert values updated correctly
assert!(*borrow(&cb, 1) ==   1, 12);
assert!(*borrow(&cb, 2) == 262, 13);
assert!(*borrow(&cb, 3) == 353, 14);
assert!(*borrow(&cb, 5) == 544, 15);
assert!(*borrow(&cb, 6) == 635, 16);
assert!(*borrow(&cb, 9) == 910, 17);
```

**Singleton traversal initialization**

Traversal initializers can still be validly called in the case of a singleton tree:

```
// Pop all key-value pairs except {9, 910}
_ = pop(&mut cb, 1);
_ = pop(&mut cb, 2);
_ = pop(&mut cb, 3);
_ = pop(&mut cb, 5);
_ = pop(&mut cb, 6);
assert!(!is_empty(&cb), 18); // Assert tree not empty
let n = length(&cb); // Get number of keys in the tree
let r = n - 1; // Get number of remaining traversals possible
// Initialize successor traversal
(k, v_r, p_f, _) = traverse_s_init_mut(&mut cb);
```

In this case, the value of the corresponding node can still be updated, and a traversal loop can even be implemented, with the loop simply being skipped over:

```
> *v_r = 1234; // Update value of node having minimum key
> while(r > 0) { // While remaining traversals possible
>     *v_r = 4321; // Update value of corresponding node
>     // Traverse to successor
>     (k, v_r, p_f, _) = traverse_s_mut(&mut cb, k, p_f);
>     r = r - 1; // Decrement remaining traversal count
> }; // This loop does not go through any iterations
> // Assert value unchanged via loop
> assert!(pop(&mut cb, 9) == 1234, 19);
> destroy_empty(cb); // Destroy empty tree
```

***

* [Background](critbit.md#@Background\_0)
  * [References](critbit.md#@References\_1)
* [Implementation](critbit.md#@Implementation\_2)
  * [Structure](critbit.md#@Structure\_3)
  * [Node indices](critbit.md#@Node\_indices\_4)
* [Basic public functions](critbit.md#@Basic\_public\_functions\_5)
  * [Initialization](critbit.md#@Initialization\_6)
  * [Mutation](critbit.md#@Mutation\_7)
  * [Lookup](critbit.md#@Lookup\_8)
  * [Size](critbit.md#@Size\_9)
  * [Destruction](critbit.md#@Destruction\_10)
* [Traversal](critbit.md#@Traversal\_11)
  * [Predecessor public functions](critbit.md#@Predecessor\_public\_functions\_12)
  * [Successor public functions](critbit.md#@Successor\_public\_functions\_13)
  * [Generic private functions](critbit.md#@Generic\_private\_functions\_14)
  * [Walkthrough](critbit.md#@Walkthrough\_15)
    * [Syntax motivations](critbit.md#@Syntax\_motivations\_16)
    * [Full predecessor traversal](critbit.md#@Full\_predecessor\_traversal\_17)
    * [Partial successor traversal](critbit.md#@Partial\_successor\_traversal\_18)
    * [Singleton traversal initialization](critbit.md#@Singleton\_traversal\_initialization\_19)
* [Struct `CB`](critbit.md#0xc0deb00c\_CritBit\_CB)
* [Struct `I`](critbit.md#0xc0deb00c\_CritBit\_I)
* [Struct `O`](critbit.md#0xc0deb00c\_CritBit\_O)
* [Constants](critbit.md#@Constants\_20)
* [Function `borrow`](critbit.md#0xc0deb00c\_CritBit\_borrow)
* [Function `borrow_mut`](critbit.md#0xc0deb00c\_CritBit\_borrow\_mut)
* [Function `destroy_empty`](critbit.md#0xc0deb00c\_CritBit\_destroy\_empty)
* [Function `empty`](critbit.md#0xc0deb00c\_CritBit\_empty)
* [Function `has_key`](critbit.md#0xc0deb00c\_CritBit\_has\_key)
* [Function `insert`](critbit.md#0xc0deb00c\_CritBit\_insert)
* [Function `is_empty`](critbit.md#0xc0deb00c\_CritBit\_is\_empty)
* [Function `length`](critbit.md#0xc0deb00c\_CritBit\_length)
* [Function `max_key`](critbit.md#0xc0deb00c\_CritBit\_max\_key)
* [Function `min_key`](critbit.md#0xc0deb00c\_CritBit\_min\_key)
* [Function `pop`](critbit.md#0xc0deb00c\_CritBit\_pop)
* [Function `singleton`](critbit.md#0xc0deb00c\_CritBit\_singleton)
* [Function `traverse_p_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_init\_mut)
* [Function `traverse_p_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_mut)
* [Function `traverse_p_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_p\_pop\_mut)
* [Function `traverse_s_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_s\_init\_mut)
* [Function `traverse_s_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_s\_mut)
* [Function `traverse_s_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_s\_pop\_mut)
* [Function `b_s_o`](critbit.md#0xc0deb00c\_CritBit\_b\_s\_o)
* [Function `b_s_o_m`](critbit.md#0xc0deb00c\_CritBit\_b\_s\_o\_m)
* [Function `check_len`](critbit.md#0xc0deb00c\_CritBit\_check\_len)
* [Function `crit_bit`](critbit.md#0xc0deb00c\_CritBit\_crit\_bit)
  * [XOR/AND method](critbit.md#@XOR/AND\_method\_21)
  * [Binary search method](critbit.md#@Binary\_search\_method\_22)
* [Function `insert_above`](critbit.md#0xc0deb00c\_CritBit\_insert\_above)
* [Function `insert_above_root`](critbit.md#0xc0deb00c\_CritBit\_insert\_above\_root)
* [Function `insert_below`](critbit.md#0xc0deb00c\_CritBit\_insert\_below)
* [Function `insert_below_walk`](critbit.md#0xc0deb00c\_CritBit\_insert\_below\_walk)
* [Function `insert_empty`](critbit.md#0xc0deb00c\_CritBit\_insert\_empty)
* [Function `insert_general`](critbit.md#0xc0deb00c\_CritBit\_insert\_general)
* [Function `insert_singleton`](critbit.md#0xc0deb00c\_CritBit\_insert\_singleton)
* [Function `max_node_c_i`](critbit.md#0xc0deb00c\_CritBit\_max\_node\_c\_i)
* [Function `min_node_c_i`](critbit.md#0xc0deb00c\_CritBit\_min\_node\_c\_i)
* [Function `is_out`](critbit.md#0xc0deb00c\_CritBit\_is\_out)
* [Function `is_set`](critbit.md#0xc0deb00c\_CritBit\_is\_set)
* [Function `o_c`](critbit.md#0xc0deb00c\_CritBit\_o\_c)
* [Function `o_v`](critbit.md#0xc0deb00c\_CritBit\_o\_v)
* [Function `pop_destroy_nodes`](critbit.md#0xc0deb00c\_CritBit\_pop\_destroy\_nodes)
* [Function `pop_general`](critbit.md#0xc0deb00c\_CritBit\_pop\_general)
* [Function `pop_singleton`](critbit.md#0xc0deb00c\_CritBit\_pop\_singleton)
* [Function `pop_update_relationships`](critbit.md#0xc0deb00c\_CritBit\_pop\_update\_relationships)
* [Function `push_back_insert_nodes`](critbit.md#0xc0deb00c\_CritBit\_push\_back\_insert\_nodes)
* [Function `search_outer`](critbit.md#0xc0deb00c\_CritBit\_search\_outer)
* [Function `stitch_child_of_parent`](critbit.md#0xc0deb00c\_CritBit\_stitch\_child\_of\_parent)
* [Function `stitch_parent_of_child`](critbit.md#0xc0deb00c\_CritBit\_stitch\_parent\_of\_child)
* [Function `stitch_swap_remove`](critbit.md#0xc0deb00c\_CritBit\_stitch\_swap\_remove)
* [Function `traverse_c_i`](critbit.md#0xc0deb00c\_CritBit\_traverse\_c\_i)
  * [Method (predecessor)](critbit.md#@Method\_\(predecessor\)\_23)
  * [Method (successor)](critbit.md#@Method\_\(successor\)\_24)
  * [Parameters](critbit.md#@Parameters\_25)
  * [Returns](critbit.md#@Returns\_26)
  * [Considerations](critbit.md#@Considerations\_27)
* [Function `traverse_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_init\_mut)
  * [Parameters](critbit.md#@Parameters\_28)
  * [Returns](critbit.md#@Returns\_29)
  * [Considerations](critbit.md#@Considerations\_30)
* [Function `traverse_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_mut)
  * [Returns](critbit.md#@Returns\_31)
* [Function `traverse_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_pop\_mut)
  * [Parameters](critbit.md#@Parameters\_32)
  * [Returns](critbit.md#@Returns\_33)
  * [Considerations](critbit.md#@Considerations\_34)

```
use 0x1::Vector;
```

### Struct `CB`

A crit-bit tree for key-value pairs with value type `V`

```
struct CB<V> has store
```

<details>

<summary>Fields</summary>

`r: u64`Root node index. When bit 63 is set, root node is an outer node. Otherwise root is an inner node. 0 when tree is empty`i: vector<`[`CritBit::I`](critbit.md#0xc0deb00c\_CritBit\_I)`>`Inner nodes`o: vector<`[`CritBit::O`](critbit.md#0xc0deb00c\_CritBit\_O)`<V>>`Outer nodes

</details>

### Struct `I`

Inner node

```
struct I has store
```

<details>

<summary>Fields</summary>

`c: u8`Critical bit position. Bit numbers 0-indexed from LSB:

```
>    11101...1010010101
>     bit 5 = 0 -|    |- bit 0 = 1
```

`p: u64`Parent node vector index. [`ROOT`](critbit.md#0xc0deb00c\_CritBit\_ROOT) when node is root, otherwise corresponds to vector index of an inner node.`l: u64`Left child node index. When bit 63 is set, left child is an outer node. Otherwise left child is an inner node.`r: u64`Right child node index. When bit 63 is set, right child is an outer node. Otherwise right child is an inner node.

</details>

### Struct `O`

Outer node with key `k` and value `v`

```
struct O<V> has store
```

<details>

<summary>Fields</summary>

`k: u128`Key, which would preferably be a generic type representing the union of {`u8`, `u64`, `u128`}. However this kind of union typing is not supported by Move, so the most general (and memory intensive) `u128` is instead specified strictly. Must be an integer for bitwise operations.`v: V`Value from node's key-value pair`p: u64`Parent node vector index. [`ROOT`](critbit.md#0xc0deb00c\_CritBit\_ROOT) when node is root, otherwise corresponds to vector index of an inner node.

</details>

### Constants

`u64` bitmask with all bits set

```
const HI_64: u64 = 18446744073709551615;
```

When a char in a bytestring is neither 0 nor 1

```
const E_BIT_NOT_0_OR_1: u64 = 0;
```

When unable to borrow from empty tree

```
const E_BORROW_EMPTY: u64 = 3;
```

When attempting to destroy a non-empty tree

```
const E_DESTROY_NOT_EMPTY: u64 = 1;
```

When an insertion key is already present in a tree

```
const E_HAS_K: u64 = 2;
```

When no more keys can be inserted

```
const E_INSERT_FULL: u64 = 5;
```

When attempting to look up on an empty tree

```
const E_LOOKUP_EMPTY: u64 = 7;
```

When no matching key in tree

```
const E_NOT_HAS_K: u64 = 4;
```

When attempting to pop from empty tree

```
const E_POP_EMPTY: u64 = 6;
```

`u128` bitmask with all bits set

```
const HI_128: u128 = 340282366920938463463374607431768211455;
```

Node type bit flag indicating inner node

```
const IN: u64 = 0;
```

Left direction

```
const L: bool = true;
```

Most significant bit number for a `u128`

```
const MSB_u128: u8 = 127;
```

Bit number of node type flag in a `u64` vector index

```
const N_TYPE: u8 = 63;
```

Node type bit flag indicating outer node

```
const OUT: u64 = 1;
```

Right direction

```
const R: bool = false;
```

`u64` bitmask with all bits set, to flag that a node is at root

```
const ROOT: u64 = 18446744073709551615;
```

### Function `borrow`

Return immutable reference to value corresponding to key `k` in `cb`, aborting if empty tree or no match

```
public fun borrow<V>(cb: &CritBit::CB<V>, k: u128): &V
```

<details>

<summary>Implementation</summary>

```
public fun borrow<V>(
    cb: &CB<V>,
    k: u128,
): &V {
    assert!(!is_empty<V>(cb), E_BORROW_EMPTY); // Abort if empty
    let c_o = b_s_o<V>(cb, k); // Borrow search outer node
    assert!(c_o.k == k, E_NOT_HAS_K); // Abort if key not in tree
    &c_o.v // Return immutable reference to corresponding value
}
```

</details>

### Function `borrow_mut`

Return mutable reference to value corresponding to key `k` in `cb`, aborting if empty tree or no match

```
public fun borrow_mut<V>(cb: &mut CritBit::CB<V>, k: u128): &mut V
```

<details>

<summary>Implementation</summary>

```
public fun borrow_mut<V>(
    cb: &mut CB<V>,
    k: u128,
): &mut V {
    assert!(!is_empty<V>(cb), E_BORROW_EMPTY); // Abort if empty
    let c_o = b_s_o_m<V>(cb, k); // Borrow search outer node
    assert!(c_o.k == k, E_NOT_HAS_K); // Abort if key not in tree
    &mut c_o.v // Return mutable reference to corresponding value
}
```

</details>

### Function `destroy_empty`

Destroy empty tree `cb`

```
public fun destroy_empty<V>(cb: CritBit::CB<V>)
```

<details>

<summary>Implementation</summary>

```
public fun destroy_empty<V>(
    cb: CB<V>
) {
    assert!(is_empty(&cb), E_DESTROY_NOT_EMPTY);
    let CB{r: _, i, o} = cb; // Unpack root index and node vectors
    v_d_e(i); // Destroy empty inner node vector
    v_d_e(o); // Destroy empty outer node vector
}
```

</details>

### Function `empty`

Return an empty tree

```
public fun empty<V>(): CritBit::CB<V>
```

<details>

<summary>Implementation</summary>

```
public fun empty<V>():
CB<V> {
    CB{r: 0, i: v_e<I>(), o: v_e<O<V>>()}
}
```

</details>

### Function `has_key`

Return true if `cb` has key `k`

```
public fun has_key<V>(cb: &CritBit::CB<V>, k: u128): bool
```

<details>

<summary>Implementation</summary>

```
public fun has_key<V>(
    cb: &CB<V>,
    k: u128,
): bool {
    if (is_empty<V>(cb)) return false; // Return false if empty
    // Return true if search outer node has same key
    return b_s_o<V>(cb, k).k == k
}
```

</details>

### Function `insert`

Insert key `k` and value `v` into `cb`, aborting if `k` already in `cb`

```
public fun insert<V>(cb: &mut CritBit::CB<V>, k: u128, v: V)
```

<details>

<summary>Implementation</summary>

```
public fun insert<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V
) {
    let l = length(cb); // Get length of tree
    check_len(l); // Verify insertion can take place
    // Insert via one of three cases, depending on the length
    if (l == 0) insert_empty(cb, k , v) else
    if (l == 1) insert_singleton(cb, k, v) else
    insert_general(cb, k, v, l);
}
```

</details>

### Function `is_empty`

Return **`true`** if `cb` has no outer nodes

```
public fun is_empty<V>(cb: &CritBit::CB<V>): bool
```

<details>

<summary>Implementation</summary>

```
public fun is_empty<V>(cb: &CB<V>): bool {v_i_e<O<V>>(&cb.o)}
```

</details>

### Function `length`

Return number of keys in `cb` (number of outer nodes)

```
public fun length<V>(cb: &CritBit::CB<V>): u64
```

<details>

<summary>Implementation</summary>

```
public fun length<V>(cb: &CB<V>): u64 {v_l<O<V>>(&cb.o)}
```

</details>

### Function `max_key`

Return the maximum key in `cb`, aborting if `cb` is empty

```
public fun max_key<V>(cb: &CritBit::CB<V>): u128
```

<details>

<summary>Implementation</summary>

```
public fun max_key<V>(
    cb: &CB<V>,
): u128 {
    assert!(!is_empty(cb), E_LOOKUP_EMPTY); // Assert tree not empty
    v_b<O<V>>(&cb.o, o_v(max_node_c_i<V>(cb))).k // Return max key
}
```

</details>

### Function `min_key`

Return the minimum key in `cb`, aborting if `cb` is empty

```
public fun min_key<V>(cb: &CritBit::CB<V>): u128
```

<details>

<summary>Implementation</summary>

```
public fun min_key<V>(
    cb: &CB<V>,
): u128 {
    assert!(!is_empty(cb), E_LOOKUP_EMPTY); // Assert tree not empty
    v_b<O<V>>(&cb.o, o_v(min_node_c_i<V>(cb))).k // Return min key
}
```

</details>

### Function `pop`

Pop from `cb` value corresponding to key `k`, aborting if `cb` is empty or does not contain `k`

```
public fun pop<V>(cb: &mut CritBit::CB<V>, k: u128): V
```

<details>

<summary>Implementation</summary>

```
public fun pop<V>(
    cb: &mut CB<V>,
    k: u128
): V {
    assert!(!is_empty(cb), E_POP_EMPTY); // Assert tree not empty
    let l = length(cb); // Get number of outer nodes in tree
    // Depending on length, pop from singleton or for general case
    if (l == 1) pop_singleton(cb, k) else pop_general(cb, k, l)
}
```

</details>

### Function `singleton`

Return a tree with one node having key `k` and value `v`

```
public fun singleton<V>(k: u128, v: V): CritBit::CB<V>
```

<details>

<summary>Implementation</summary>

```
public fun singleton<V>(
    k: u128,
    v: V
):
CB<V> {
    let cb = CB{r: 0, i: v_e<I>(), o: v_e<O<V>>()};
    insert_empty<V>(&mut cb, k, v);
    cb
}
```

</details>

### Function `traverse_p_init_mut`

Wrapped [`traverse_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_init\_mut)`()` call for predecessor traversal. See [traversal walkthrough](critbit.md#Walkthrough)

```
public fun traverse_p_init_mut<V>(cb: &mut CritBit::CB<V>): (u128, &mut V, u64, u64)
```

<details>

<summary>Implementation</summary>

```
public fun traverse_p_init_mut<V>(
    cb: &mut CB<V>,
): (
    u128,
    &mut V,
    u64,
    u64
) {
    traverse_init_mut(cb, L)
}
```

</details>

### Function `traverse_p_mut`

Wrapped [`traverse_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_mut)`()` call for predecessor traversal. See [traversal walkthrough](critbit.md#Walkthrough)

```
public fun traverse_p_mut<V>(cb: &mut CritBit::CB<V>, k: u128, p_f: u64): (u128, &mut V, u64, u64)
```

<details>

<summary>Implementation</summary>

```
public fun traverse_p_mut<V>(
    cb: &mut CB<V>,
    k: u128,
    p_f: u64
): (
    u128,
    &mut V,
    u64,
    u64
) {
    traverse_mut<V>(cb, k, p_f, L)
}
```

</details>

### Function `traverse_p_pop_mut`

Wrapped [`traverse_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_pop\_mut)`()` call for predecessor traversal. See [traversal walkthrough](critbit.md#Walkthrough)

```
public fun traverse_p_pop_mut<V>(cb: &mut CritBit::CB<V>, k: u128, p_f: u64, c_i: u64, n_o: u64): (u128, &mut V, u64, u64, V)
```

<details>

<summary>Implementation</summary>

```
public fun traverse_p_pop_mut<V>(
    cb: &mut CB<V>,
    k: u128,
    p_f: u64,
    c_i: u64,
    n_o: u64
): (
    u128,
    &mut V,
    u64,
    u64,
    V
) {
    traverse_pop_mut(cb, k, p_f, c_i, n_o, L)
}
```

</details>

### Function `traverse_s_init_mut`

Wrapped [`traverse_init_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_init\_mut)`()` call for successor traversal. See [traversal walkthrough](critbit.md#Walkthrough)

```
public fun traverse_s_init_mut<V>(cb: &mut CritBit::CB<V>): (u128, &mut V, u64, u64)
```

<details>

<summary>Implementation</summary>

```
public fun traverse_s_init_mut<V>(
    cb: &mut CB<V>,
): (
    u128,
    &mut V,
    u64,
    u64
) {
    traverse_init_mut(cb, R)
}
```

</details>

### Function `traverse_s_mut`

Wrapped [`traverse_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_mut)`()` call for successor traversal. See [traversal walkthrough](critbit.md#Walkthrough)

```
public fun traverse_s_mut<V>(cb: &mut CritBit::CB<V>, k: u128, p_f: u64): (u128, &mut V, u64, u64)
```

<details>

<summary>Implementation</summary>

```
public fun traverse_s_mut<V>(
    cb: &mut CB<V>,
    k: u128,
    p_f: u64
): (
    u128,
    &mut V,
    u64,
    u64
) {
    traverse_mut<V>(cb, k, p_f, R)
}
```

</details>

### Function `traverse_s_pop_mut`

Wrapped [`traverse_pop_mut`](critbit.md#0xc0deb00c\_CritBit\_traverse\_pop\_mut)`()` call for successor traversal. See [traversal walkthrough](critbit.md#Walkthrough)

```
public fun traverse_s_pop_mut<V>(cb: &mut CritBit::CB<V>, k: u128, p_f: u64, c_i: u64, n_o: u64): (u128, &mut V, u64, u64, V)
```

<details>

<summary>Implementation</summary>

```
public fun traverse_s_pop_mut<V>(
    cb: &mut CB<V>,
    k: u128,
    p_f: u64,
    c_i: u64,
    n_o: u64
): (
    u128,
    &mut V,
    u64,
    u64,
    V
) {
    traverse_pop_mut(cb, k, p_f, c_i, n_o, R)
}
```

</details>

### Function `b_s_o`

Walk non-empty tree `cb`, breaking out if at outer node, branching left or right at each inner node depending on whether `k` is unset or set, respectively, at the given critical bit. Then return mutable reference to search outer node (`b_c_o` indicates borrow search outer)

```
fun b_s_o<V>(cb: &CritBit::CB<V>, k: u128): &CritBit::O<V>
```

<details>

<summary>Implementation</summary>

```
fun b_s_o<V>(
    cb: &CB<V>,
    k: u128,
): &O<V> {
    // If root is an outer node, return reference to it
    if (is_out(cb.r)) return (v_b<O<V>>(&cb.o, o_v(cb.r)));
    // Otherwise borrow inner node at root
    let n = v_b<I>(&cb.i, cb.r);
    loop { // Loop over inner nodes
        // If key is set at critical bit, get index of child on R
        let i_c = if (is_set(k, n.c)) n.r else n.l; // Otherwise L
        // If child is outer node, return reference to it
        if (is_out(i_c)) return v_b<O<V>>(&cb.o, o_v(i_c));
        n = v_b<I>(&cb.i, i_c); // Borrow next inner node to review
    }
}
```

</details>

### Function `b_s_o_m`

Like [`b_s_o`](critbit.md#0xc0deb00c\_CritBit\_b\_s\_o)`()`, but for mutable reference

```
fun b_s_o_m<V>(cb: &mut CritBit::CB<V>, k: u128): &mut CritBit::O<V>
```

<details>

<summary>Implementation</summary>

```
fun b_s_o_m<V>(
    cb: &mut CB<V>,
    k: u128,
): &mut O<V> {
    // If root is an outer node, return mutable reference to it
    if (is_out(cb.r)) return (v_b_m<O<V>>(&mut cb.o, o_v(cb.r)));
    // Otherwise borrow inner node at root
    let n = v_b<I>(&cb.i, cb.r);
    loop { // Loop over inner nodes
        // If key is set at critical bit, get index of child on R
        let i_c = if (is_set(k, n.c)) n.r else n.l; // Otherwise L
        // If child is outer node, return mutable reference to it
        if (is_out(i_c)) return v_b_m<O<V>>(&mut cb.o, o_v(i_c));
        n = v_b<I>(&cb.i, i_c); // Borrow next inner node to review
    }
}
```

</details>

### Function `check_len`

Assert that `l` is less than the value indicated by a bitmask where only the 63rd bit is not set (this bitmask corresponds to the maximum number of keys that can be stored in a tree, since the 63rd bit is reserved for the node type bit flag)

```
fun check_len(l: u64)
```

<details>

<summary>Implementation</summary>

```
fun check_len(l: u64) {assert!(l < HI_64 ^ OUT << N_TYPE, E_INSERT_FULL);}
```

</details>

### Function `crit_bit`

Return the number of the most significant bit (0-indexed from LSB) at which two non-identical bitstrings, `s1` and `s2`, vary.

#### XOR/AND method

To begin with, a bitwise XOR is used to flag all differing bits:

```
>           s1: 11110001
>           s2: 11011100
>  x = s1 ^ s2: 00101101
>                 |- critical bit = 5
```

Here, the critical bit is equivalent to the bit number of the most significant set bit in XOR result `x = s1 ^ s2`. At this point, [Langley 2012](critbit.md#References) notes that `x` bitwise AND `x - 1` will be nonzero so long as `x` contains at least some bits set which are of lesser significance than the critical bit:

```
>               x: 00101101
>           x - 1: 00101100
> x = x & (x - 1): 00101100
```

Thus he suggests repeating `x & (x - 1)` while the new result `x = x & (x - 1)` is not equal to zero, because such a loop will eventually reduce `x` to a power of two (excepting the trivial case where `x` starts as all 0 except bit 0 set, for which the loop never enters past the initial conditional check). Per this method, using the new `x` value for the current example, the second iteration proceeds as follows:

```
>               x: 00101100
>           x - 1: 00101011
> x = x & (x - 1): 00101000
```

The third iteration:

```
>               x: 00101000
>           x - 1: 00100111
> x = x & (x - 1): 00100000
```

Now, `x & x - 1` will equal zero and the loop will not begin a fourth iteration:

```
>             x: 00100000
>         x - 1: 00011111
> x AND (x - 1): 00000000
```

Thus after three iterations a corresponding critical bit bitmask has been determined. However, in the case where the two input strings vary at all bits of lesser significance than that of the critical bit, there may be required as many as `k - 1` iterations, where `k` is the number of bits in each string under comparison. For instance, consider the case of the two 8-bit strings `s1` and `s2` as follows:

```
>              s1: 10101010
>              s2: 01010101
>     x = s1 ^ s2: 11111111
>                  |- critical bit = 7
> x = x & (x - 1): 11111110 [iteration 1]
> x = x & (x - 1): 11111100 [iteration 2]
> x = x & (x - 1): 11111000 [iteration 3]
> ...
```

Notably, this method is only suggested after already having identified the varying byte between the two strings, thus limiting `x & (x - 1)` operations to at most 7 iterations.

#### Binary search method

For the present implementation, strings are not partitioned into a multi-byte array, rather, they are stored as `u128` integers, so a binary search is instead proposed. Here, the same `x = s1 ^ s2` operation is first used to identify all differing bits, before iterating on an upper and lower bound for the critical bit number:

```
>          s1: 10101010
>          s2: 01010101
> x = s1 ^ s2: 11111111
>       u = 7 -|      |- l = 0
```

The upper bound `u` is initialized to the length of the string (7 in this example, but 127 for a `u128`), and the lower bound `l` is initialized to 0. Next the midpoint `m` is calculated as the average of `u` and `l`, in this case `m = (7 + 0) / 2 = 3`, per truncating integer division. Now, the shifted compare value `s = r >> m` is calculated and updates are applied according to three potential outcomes:

* `s == 1` means that the critical bit `c` is equal to `m`
* `s == 0` means that `c < m`, so `u` is set to `m - 1`
* `s > 1` means that `c > m`, so `l` us set to `m + 1`

Hence, continuing the current example:

```
>          x: 11111111
> s = x >> m: 00011111
```

`s > 1`, so `l = m + 1 = 4`, and the search window has shrunk:

```
> x = s1 ^ s2: 11111111
>       u = 7 -|  |- l = 4
```

Updating the midpoint yields `m = (7 + 4) / 2 = 5`:

```
>          x: 11111111
> s = x >> m: 00000111
```

Again `s > 1`, so update `l = m + 1 = 6`, and the window shrinks again:

```
> x = s1 ^ s2: 11111111
>       u = 7 -||- l = 6
> s = x >> m: 00000011
```

Again `s > 1`, so update `l = m + 1 = 7`, the final iteration:

```
> x = s1 ^ s2: 11111111
>       u = 7 -|- l = 7
> s = x >> m: 00000001
```

Here, `s == 1`, which means that `c = m = 7`. Notably this search has converged after only 3 iterations, as opposed to 7 for the linear search proposed above, and in general such a search converges after $log\_2(k)$ iterations at most, where $k$ is the number of bits in each of the strings `s1` and `s2` under comparison. Hence this search method improves the $O(k)$ search proposed by [Langley 2012](critbit.md#References) to $O(log\_2(k))$, and moreover, determines the actual number of the critical bit, rather than just a bitmask with bit `c` set, as he proposes, which can also be easily generated via `1 << c`.

```
fun crit_bit(s1: u128, s2: u128): u8
```

<details>

<summary>Implementation</summary>

```
fun crit_bit(
    s1: u128,
    s2: u128,
): u8 {
    let x = s1 ^ s2; // XOR result marked 1 at bits that differ
    let l = 0; // Lower bound on critical bit search
    let u = MSB_u128; // Upper bound on critical bit search
    loop { // Begin binary search
        let m = (l + u) / 2; // Calculate midpoint of search window
        let s = x >> m; // Calculate midpoint shift of XOR result
        if (s == 1) return m; // If shift equals 1, c = m
        if (s > 1) l = m + 1 else u = m - 1; // Update search bounds
    }
}
```

</details>

### Function `insert_above`

Decomposed case specified in `insert_general`, walk up tree, for parameters:

* `cb`: Tree to insert into
* `k` : Key to insert
* `v` : Value to insert
* `n_o` : Number of keys (outer nodes) in `cb` pre-insert
* `i_n_i` : Number of inner nodes in `cb` pre-insert (index of new inner node)
* `i_s_p`: Index of search parent
* `c`: Critical bit between insertion key and search outer node

```
fun insert_above<V>(cb: &mut CritBit::CB<V>, k: u128, v: V, n_o: u64, i_n_i: u64, i_s_p: u64, c: u8)
```

<details>

<summary>Implementation</summary>

```
fun insert_above<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    i_s_p: u64,
    c: u8
) {
    // Set index of node under review to search parent's parent
    let i_n_r = v_b<I>(&cb.i, i_s_p).p;
    loop { // Loop over inner nodes
        if (i_n_r == ROOT) { // If walk arrives at root
            // Insert above root
            return insert_above_root(cb, k, v, n_o, i_n_i, c)
        } else { // If walk has not arrived at root
            // Borrow mutable reference to node under review
            let n_r = v_b_m<I>(&mut cb.i, i_n_r);
            // If critical bit between insertion key and search
            // outer node is less than that of node under review
            if (c < n_r.c) { // If need to insert below
                // Insert below node under review
                return insert_below_walk(cb, k, v, n_o, i_n_i, i_n_r, c)
            } else { // If need to insert above
                i_n_r = n_r.p; // Review node under review's parent
            }
        }
    }
}
```

</details>

### Function `insert_above_root`

Decomposed case specified in `insert_general`, insertion above root, for parameters:

* `cb`: Tree to insert into
* `k` : Key to insert
* `v` : Value to insert
* `n_o` : Number of keys (outer nodes) in `cb` pre-insert
* `i_n_i` : Number of inner nodes in `cb` pre-insert (index of new inner node)
* `c`: Critical bit between insertion key and search outer node

```
fun insert_above_root<V>(cb: &mut CritBit::CB<V>, k: u128, v: V, n_o: u64, i_n_i: u64, c: u8)
```

<details>

<summary>Implementation</summary>

```
fun insert_above_root<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    c: u8
) {
    let i_o_r = cb.r; // Get index of old root to insert above
    // Set old root node to have new inner node as parent
    v_b_m<I>(&mut cb.i, i_o_r).p = i_n_i;
    // Set root field index to indicate new inner node
    cb.r = i_n_i;
    // Push back new inner and outer nodes, with inner node
    // indicating that it is root. If insertion key is set at
    // critical bit, new inner node should have as its left child
    // the previous root node and should have as its right child
    // the new outer node
    push_back_insert_nodes(
        cb, k, v, i_n_i, c, ROOT, is_set(k, c), i_o_r, o_c(n_o)
    );
}
```

</details>

### Function `insert_below`

Decomposed case specified in `insert_general`, insertion below search parent, for parameters:

* `cb`: Tree to insert into
* `k` : Key to insert
* `v` : Value to insert
* `n_o` : Number of keys (outer nodes) in `cb` pre-insert
* `i_n_i` : Number of inner nodes in `cb` pre-insert (index of new inner node)
* `i_s_o`: Field index of search outer node (with bit flag)
* `s_s_o`: Side on which search outer node is child
* `k_s_o`: Key of search outer node
* `i_s_p`: Index of search parent
* `c`: Critical bit between insertion key and search outer node

```
fun insert_below<V>(cb: &mut CritBit::CB<V>, k: u128, v: V, n_o: u64, i_n_i: u64, i_s_o: u64, s_s_o: bool, k_s_o: u128, i_s_p: u64, c: u8)
```

<details>

<summary>Implementation</summary>

```
fun insert_below<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    i_s_o: u64,
    s_s_o: bool,
    k_s_o: u128,
    i_s_p: u64,
    c: u8
) {
    // Borrow mutable reference to search parent
    let s_p = v_b_m<I>(&mut cb.i, i_s_p);
    // Update search parent to have new inner node as child, on same
    // side that the search outer node was a child at
    if (s_s_o == L) s_p.l = i_n_i else s_p.r = i_n_i;
    // Set search outer node to have new inner node as parent
    v_b_m<O<V>>(&mut cb.o, o_v(i_s_o)).p = i_n_i;
    // Push back new inner and outer nodes, with inner node having
    // as its parent the search parent. If insertion key is less
    // than key of search outer node, new inner node should have as
    // its left child the new outer node and should have as its
    // right child the search outer node
    push_back_insert_nodes(
        cb, k, v, i_n_i, c, i_s_p, k < k_s_o, o_c(n_o), i_s_o
    );
}
```

</details>

### Function `insert_below_walk`

Decomposed case specified in `insert_general`, insertion below a node encountered during walk, for parameters:

* `cb`: Tree to insert into
* `k` : Key to insert
* `v` : Value to insert
* `n_o` : Number of keys (outer nodes) in `cb` pre-insert
* `i_n_i` : Number of inner nodes in `cb` pre-insert (index of new inner node)
* `i_n_r` : Index of node under review from walk
* `c`: Critical bit between insertion key and search outer node

```
fun insert_below_walk<V>(cb: &mut CritBit::CB<V>, k: u128, v: V, n_o: u64, i_n_i: u64, i_n_r: u64, c: u8)
```

<details>

<summary>Implementation</summary>

```
fun insert_below_walk<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    i_n_r: u64,
    c: u8
) {
    // Borrow mutable reference to node under review
    let n_r = v_b_m<I>(&mut cb.i, i_n_r);
    // If insertion key is set at critical bit indicated by node
    // under review, mark side and index of walked child as its
    // right child, else left
    let (s_w_c, i_w_c) = if (is_set(k, n_r.c)) (R, n_r.r) else (L, n_r.l);
    // Set node under review to have as child new inner node on same
    // side as walked child
    if (s_w_c == L) n_r.l = i_n_i else n_r.r = i_n_i;
    // Update walked child to have new inner node as its parent
    v_b_m<I>(&mut cb.i, i_w_c).p = i_n_i;
    // Push back new inner and outer nodes, with inner node having
    // as its parent the node under review. If insertion key is set
    // at critical bit, new inner node should have as its left child
    // the walked child of the node under review and should have as
    // its right child the new outer node
    push_back_insert_nodes(
        cb, k, v, i_n_i, c, i_n_r, is_set(k, c), i_w_c, o_c(n_o)
    );
}
```

</details>

### Function `insert_empty`

Insert key-value pair `k` and `v` into an empty `cb`

```
fun insert_empty<V>(cb: &mut CritBit::CB<V>, k: u128, v: V)
```

<details>

<summary>Implementation</summary>

```
fun insert_empty<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V
) {
    // Push back outer node onto tree's vector of outer nodes
    v_pu_b<O<V>>(&mut cb.o, O<V>{k, v, p: ROOT});
    // Set root index field to indicate 0th outer node
    cb.r = OUT << N_TYPE;
}
```

</details>

### Function `insert_general`

Insert key `k` and value `v` into tree `cb` already having `n_o` keys for general case where root is an inner node, aborting if `k` is already present. First, perform an outer node search and identify the critical bit of divergence between the search outer node and `k`. Then, if the critical bit is less than that of the search parent ([`insert_below`](critbit.md#0xc0deb00c\_CritBit\_insert\_below)`()`):

* Insert a new inner node directly above the search outer node
* Update the search outer node to have as its parent the new inner node
* Update the search parent to have as its child the new inner node where the search outer node previously was:

```
>       2nd
>      /   \
>    001   1st <- search parent
>         /   \
>       101   111 <- search outer node
>
>       Insert 110
>       --------->
>
>                  2nd
>                 /   \
>               001   1st <- search parent
>                    /   \
>                  101   0th <- new inner node
>                       /   \
>   new outer node -> 110   111 <- search outer node
```

Otherwise, begin walking back up the tree ([`insert_above`](critbit.md#0xc0deb00c\_CritBit\_insert\_above)`()`). If walk arrives at the root node, insert a new inner node above the root, updating associated relationships ([`insert_above_root`](critbit.md#0xc0deb00c\_CritBit\_insert\_above\_root)`()`):

```
>          1st
>         /   \
>       101   0th <- search parent
>            /   \
>          110    111 <- search outer node
>
>       Insert 011
>       --------->
>
>                         2nd <- new inner node
>                        /   \
>    new outer node -> 011   1st
>                           /   \
>                         101   0th <- search parent
>                              /   \
>                            110   111 <- search outer node
```

Otherwise, if walk arrives at a node indicating a critical bit larger than that between the insertion key and the search node, insert the new inner node below it ([`insert_below_walk`](critbit.md#0xc0deb00c\_CritBit\_insert\_below\_walk)`()`):

```
>
>           2nd
>          /   \
>        011   0th <- search parent
>             /   \
>           101   111 <- search outer node
>
>       Insert 100
>       --------->
>
>                       2nd
>                      /   \
>                    001   1st <- new inner node
>                         /   \
>     new outer node -> 100   0th <- search parent
>                            /   \
>                          110   111 <- search outer node
```

```
fun insert_general<V>(cb: &mut CritBit::CB<V>, k: u128, v: V, n_o: u64)
```

<details>

<summary>Implementation</summary>

```
fun insert_general<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V,
    n_o: u64
) {
    // Get number of inner nodes in tree (index of new inner node)
    let i_n_i = v_l<I>(&cb.i);
    // Get field index of search outer node, its side as a child,
    // its key, the vector index of its parent, and the critical
    // bit indicated by the search parent
    let (i_s_o, s_s_o, k_s_o, i_s_p, s_p_c) = search_outer(cb, k);
    assert!(k_s_o != k, E_HAS_K); // Assert key not a duplicate
    // Get critical bit between insertion key and search outer node
    let c = crit_bit(k_s_o, k);
    // If critical bit is less than that indicated by search parent
    if (c < s_p_c) {
        // Insert new inner node below search parent
        insert_below(cb, k, v, n_o, i_n_i, i_s_o, s_s_o, k_s_o, i_s_p, c);
    } else { // If need to insert new inner node above search parent
        insert_above(cb, k, v, n_o, i_n_i, i_s_p, c);
    }
}
```

</details>

### Function `insert_singleton`

Insert key `k` and value `v` into singleton tree `cb`, aborting if `k` already in `cb`

```
fun insert_singleton<V>(cb: &mut CritBit::CB<V>, k: u128, v: V)
```

<details>

<summary>Implementation</summary>

```
fun insert_singleton<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V
) {
    let n = v_b<O<V>>(&cb.o, 0); // Borrow existing outer node
    assert!(k != n.k, E_HAS_K); // Assert insertion key not in tree
    let c = crit_bit(n.k, k); // Get critical bit between two keys
    // Push back new inner and outer nodes, with inner node
    // indicating that it is root. If insertion key is greater than
    // singleton key, new inner node should have as its left child
    // existing outer node and should have as its right child new
    // outer node
    push_back_insert_nodes(cb, k, v, 0, c, ROOT, k > n.k, o_c(0), o_c(1));
    cb.r = 0; // Update tree root field to indicate new inner node
    // Update existing outer node to have new inner node as parent
    v_b_m<O<V>>(&mut cb.o, 0).p = 0;
}
```

</details>

### Function `max_node_c_i`

Return the child field index of the outer node containing the maximum key in non-empty tree `cb`

```
fun max_node_c_i<V>(cb: &CritBit::CB<V>): u64
```

<details>

<summary>Implementation</summary>

```
fun max_node_c_i<V>(
    cb: &CB<V>
): u64 {
    let i_n = cb.r; // Initialize index of search node to root
    loop { // Loop over nodes
        // If search node is an outer node return its field index
        if (is_out(i_n)) return i_n;
        i_n = v_b<I>(&cb.i, i_n).r // Review node's right child next
    }
}
```

</details>

### Function `min_node_c_i`

Return the chield field index of the outer node containing the minimum key in non-empty tree `cb`

```
fun min_node_c_i<V>(cb: &CritBit::CB<V>): u64
```

<details>

<summary>Implementation</summary>

```
fun min_node_c_i<V>(
    cb: &CB<V>
): u64 {
    let i_n = cb.r; // Initialize index of search node to root
    loop { // Loop over nodes
        // If search node is an outer node return its field index
        if (is_out(i_n)) return i_n;
        i_n = v_b<I>(&cb.i, i_n).l // Review node's left child next
    }
}
```

</details>

### Function `is_out`

Return **`true`** if vector index `i` indicates an outer node

```
fun is_out(i: u64): bool
```

<details>

<summary>Implementation</summary>

```
fun is_out(i: u64): bool {(i >> N_TYPE & OUT == OUT)}
```

</details>

### Function `is_set`

Return **`true`** if `k` is set at bit `b`

```
fun is_set(k: u128, b: u8): bool
```

<details>

<summary>Implementation</summary>

```
fun is_set(k: u128, b: u8): bool {k >> b & 1 == 1}
```

</details>

### Function `o_c`

Convert unflagged outer node vector index `v` to flagged child node index, by OR with a bitmask that has only flag bit set

```
fun o_c(v: u64): u64
```

<details>

<summary>Implementation</summary>

```
fun o_c(v: u64): u64 {v | OUT << N_TYPE}
```

</details>

### Function `o_v`

Convert flagged child node index `c` to unflagged outer node vector index, by AND with a bitmask that has only flag bit unset

```
fun o_v(c: u64): u64
```

<details>

<summary>Implementation</summary>

```
fun o_v(c: u64): u64 {c & HI_64 ^ OUT << N_TYPE}
```

</details>

### Function `pop_destroy_nodes`

Remove from `cb` inner node at child field index `i_i`, and outer node at child field index `i_o` (from node vector with `n_o` outer nodes pre-pop). Then return the popped value from the outer node

```
fun pop_destroy_nodes<V>(cb: &mut CritBit::CB<V>, i_i: u64, i_o: u64, n_o: u64): V
```

<details>

<summary>Implementation</summary>

```
fun pop_destroy_nodes<V>(
    cb: &mut CB<V>,
    i_i: u64,
    i_o: u64,
    n_o: u64
): V {
    let n_i = v_l<I>(&cb.i); // Get number of inner nodes pre-pop
    // Swap remove parent of popped outer node, storing no fields
    let I{c: _, p: _, l: _, r: _} = v_s_r<I>(&mut cb.i, i_i);
    // If destroyed inner node was not last inner node in vector,
    // repair the parent-child relationship broken by swap remove
    if (i_i < n_i - 1) stitch_swap_remove(cb, i_i, n_i);
    // Swap remove popped outer node, storing only its value
    let O{k: _, v, p: _} = v_s_r<O<V>>(&mut cb.o, o_v(i_o));
    // If destroyed outer node was not last outer node in vector,
    // repair the parent-child relationship broken by swap remove
    if (o_v(i_o) < n_o - 1) stitch_swap_remove(cb, i_o, n_o);
    v // Return popped value
}
```

</details>

### Function `pop_general`

Return the value corresponding to key `k` in tree `cb` having `n_o` keys and destroy the outer node where it was stored, for the general case of a tree with more than one outer node. Abort if `k` not in `cb`. Here, the parent of the popped node must be removed, and if the popped node has a grandparent, the grandparent of the popped node must be updated to have as its child the popped node's sibling at the same position where the popped node's parent previously was, whether the sibling is an outer or inner node. Likewise the sibling must be updated to have as its parent the grandparent to the popped node. Outer node sibling case:

```
>              2nd <- grandparent
>             /   \
>           001   1st <- parent
>                /   \
>   sibling -> 101   111 <- popped node
>
>       Pop 111
>       ------>
>
>                  2nd <- grandparent
>                 /   \
>               001    101 <- sibling
```

Inner node sibling case:

```
>              2nd <- grandparent
>             /   \
>           001   1st <- parent
>                /   \
>   sibling -> 0th   111 <- popped node
>             /   \
>           100   101
>
>       Pop 111
>       ------>
>
>              2nd <- grandparent
>             /   \
>           001   0th <- sibling
>                /   \
>              100   101
```

If the popped node does not have a grandparent (if its parent is the root node), then the root node must be removed and the popped node's sibling must become the new root, whether the sibling is an inner or outer node. Likewise the sibling must be updated to indicate that it is the root. Inner node sibling case:

```
>                     2nd <- parent
>                    /   \
>   popped node -> 001   1st <- sibling
>                       /   \
>                     101   111
>
>       Pop 001
>       ------>
>
>                  1st <- sibling
>                 /   \
>               101    111
```

Outer node sibling case:

```
>                     2nd <- parent
>                    /   \
>   popped node -> 001   101 <- sibling
>
>       Pop 001
>       ------>
>
>                  101 <- sibling
```

```
fun pop_general<V>(cb: &mut CritBit::CB<V>, k: u128, n_o: u64): V
```

<details>

<summary>Implementation</summary>

```
fun pop_general<V>(
    cb: &mut CB<V>,
    k: u128,
    n_o: u64
): V {
    // Get field index of search outer node, its side as a child,
    // its key, and the vector index of its parent
    let (i_s_o, s_s_o, k_s_o, i_s_p, _) = search_outer(cb, k);
    assert!(k_s_o == k, E_NOT_HAS_K); // Assert key in tree
    // Update sibling, parent, grandparent relationships
    pop_update_relationships(cb, s_s_o, i_s_p);
    // Destroy old nodes, returning popped value
    pop_destroy_nodes(cb, i_s_p, i_s_o, n_o)
}
```

</details>

### Function `pop_singleton`

Return the value corresponding to key `k` in singleton tree `cb` and destroy the outer node where it was stored, aborting if `k` not in `cb`

```
fun pop_singleton<V>(cb: &mut CritBit::CB<V>, k: u128): V
```

<details>

<summary>Implementation</summary>

```
fun pop_singleton<V>(
    cb: &mut CB<V>,
    k: u128
): V {
    // Assert key actually in tree at root node
    assert!(v_b<O<V>>(&cb.o, 0).k == k, E_NOT_HAS_K);
    cb.r = 0; // Update root
    // Pop off and unpack outer node at root
    let O{k: _, v, p: _} = v_po_b<O<V>>(&mut cb.o);
    v // Return popped value
}
```

</details>

### Function `pop_update_relationships`

Update relationships in `cb` for popping a node which is a child on side `s_c` ([`L`](critbit.md#0xc0deb00c\_CritBit\_L) or [`R`](critbit.md#0xc0deb00c\_CritBit\_R)), to parent node at index `i_p`, per [`pop_general`](critbit.md#0xc0deb00c\_CritBit\_pop\_general)`()`

```
fun pop_update_relationships<V>(cb: &mut CritBit::CB<V>, s_c: bool, i_p: u64)
```

<details>

<summary>Implementation</summary>

```
fun pop_update_relationships<V>(
    cb: &mut CB<V>,
    s_c: bool,
    i_p: u64,
) {
    // Borrow immutable reference to popped node's parent
    let p = v_b<I>(&cb.i, i_p);
    // If popped outer node was a left child, store the right child
    // field index of its parent as the child field index of the
    // popped node's sibling. Else flip the direction
    let i_s = if (s_c == L) p.r else p.l;
    // Get parent field index of popped node's parent
    let i_p_p = p.p;
    // Update popped node's sibling to have at its parent index
    // field the same as that of the popped node's parent, whether
    // the sibling is an inner or outer node
    if (is_out(i_s)) v_b_m<O<V>>(&mut cb.o, o_v(i_s)).p = i_p_p
        else v_b_m<I>(&mut cb.i, i_s).p = i_p_p;
    if (i_p_p == ROOT) { // If popped node's parent is root
        // Set root field index to child field index of popped
        // node's sibling
        cb.r = i_s;
    } else { // If popped node has a grandparent
        // Borrow mutable reference to popped node's grandparent
        let g_p = v_b_m<I>(&mut cb.i, i_p_p);
        // If popped node's parent was a left child, update popped
        // node's grandparent to have as its child the popped node's
        // sibling. Else the right child
        if (g_p.l == i_p) g_p.l = i_s else g_p.r = i_s;
    };
}
```

</details>

### Function `push_back_insert_nodes`

Push back a new inner node and outer node into tree `cb`, where the new outer node should have key `k`, value `v`, and have as its parent the new inner node at vector index `i_n_i`, which should have critical bit `c`, parent field index `i_p`, and if `i_n_c_c` is **`true`**, left child field index `c1` and right child field index `c2`. If the "inner node child condition" is **`false`** the polarity of the children should be flipped

```
fun push_back_insert_nodes<V>(cb: &mut CritBit::CB<V>, k: u128, v: V, i_n_i: u64, c: u8, i_p: u64, i_n_c_c: bool, c1: u64, c2: u64)
```

<details>

<summary>Implementation</summary>

```
fun push_back_insert_nodes<V>(
    cb: &mut CB<V>,
    k: u128,
    v: V,
    i_n_i: u64,
    c: u8,
    i_p: u64,
    i_n_c_c: bool,
    c1: u64,
    c2: u64,
) {
    // If inner node child condition marked true, declare left child
    // field for new inner node as c1 and right as c2, else flip
    let (l, r) = if (i_n_c_c) (c1, c2) else (c2, c1);
    // Push back new outer node with new inner node as parent
    v_pu_b<O<V>>(&mut cb.o, O{k, v, p: i_n_i});
    // Push back new inner node with specified parent and children
    v_pu_b<I>(&mut cb.i, I{c, p: i_p, l, r});
}
```

</details>

### Function `search_outer`

Walk from root tree `cb` having an inner node as its root, branching left or right at each inner node depending on whether `k` is unset or set, respectively, at the given critical bit. After arriving at an outer node, then return:

* `u64`: index of search outer node (with node type bit flag)
* `bool`: the side, [`L`](critbit.md#0xc0deb00c\_CritBit\_L) or [`R`](critbit.md#0xc0deb00c\_CritBit\_R), on which the search outer node is a child of its parent
* `u128`: key of search outer node
* `u64`: vector index of parent of search outer node
* `u8`: critical bit indicated by parent of search outer node

```
fun search_outer<V>(cb: &CritBit::CB<V>, k: u128): (u64, bool, u128, u64, u8)
```

<details>

<summary>Implementation</summary>

```
fun search_outer<V>(
    cb: &CB<V>,
    k: u128
): (
    u64,
    bool,
    u128,
    u64,
    u8,
) {
    // Initialize search parent to root
    let s_p = v_b<I>(&cb.i, cb.r);
    loop { // Loop over inner nodes until branching to outer node
        // If key set at critical bit, track field index and side of
        // R child, else L
        let (i, s) = if (is_set(k, s_p.c)) (s_p.r, R) else (s_p.l, L);
        if (is_out(i)) { // If child is outer node
            // Borrow immutable reference to it
            let s_o = v_b<O<V>>(&cb.o, o_v(i));
            // Return child field index of search outer node, its
            // side as a child, its key, the vector index of its
            // parent, and parent's indicated critical bit
            return (i, s, s_o.k, s_o.p, s_p.c)
        };
        s_p = v_b<I>(&cb.i, i); // Search next inner node
    }
}
```

</details>

### Function `stitch_child_of_parent`

Update parent node at index `i_p` in `cb` to reflect as its child a node that has been relocated from old child field index `i_o` to new child field index `i_n`

```
fun stitch_child_of_parent<V>(cb: &mut CritBit::CB<V>, i_n: u64, i_p: u64, i_o: u64)
```

<details>

<summary>Implementation</summary>

```
fun stitch_child_of_parent<V>(
    cb: &mut CB<V>,
    i_n: u64,
    i_p: u64,
    i_o: u64
) {
    // Borrow mutable reference to parent
    let p = v_b_m<I>(&mut cb.i, i_p);
    // If relocated node was previously left child, update
    // parent's left child to indicate the relocated node's new
    // position, otherwise do update for right child of parent
    if (p.l == i_o) p.l = i_n else p.r = i_n;
}
```

</details>

### Function `stitch_parent_of_child`

Update child node at child field index `i_c` in `cb` to reflect as its parent an inner node that has be relocated to child field index `i_n`

```
fun stitch_parent_of_child<V>(cb: &mut CritBit::CB<V>, i_n: u64, i_c: u64)
```

<details>

<summary>Implementation</summary>

```
fun stitch_parent_of_child<V>(
    cb: &mut CB<V>,
    i_n: u64,
    i_c: u64
) {
    // If child is an outer node, borrow corresponding node and
    // update its parent field index to that of relocated node
    if (is_out(i_c)) v_b_m<O<V>>(&mut cb.o, o_v(i_c)).p = i_n
        // Otherwise perform update on an inner node
        else v_b_m<I>(&mut cb.i, i_c).p = i_n;
}
```

</details>

### Function `stitch_swap_remove`

Repair a broken parent-child relationship in `cb` caused by swap removing, for relocated node now at index indicated by child field index `i_n`, in vector that contained `n_n` nodes before the swap remove (when relocated node was last in vector)

```
fun stitch_swap_remove<V>(cb: &mut CritBit::CB<V>, i_n: u64, n_n: u64)
```

<details>

<summary>Implementation</summary>

```
fun stitch_swap_remove<V>(
    cb: &mut CB<V>,
    i_n: u64,
    n_n: u64
) {
    // If child field index indicates relocated outer node
    if (is_out(i_n)) {
        // Get node's parent field index
        let i_p = v_b<O<V>>(&cb.o, o_v(i_n)).p;
        // If root node was relocated, update root field and return
        if (i_p == ROOT) {cb.r = i_n; return};
        // Else update parent to reflect relocated node position
        stitch_child_of_parent<V>(cb, i_n, i_p, o_c(n_n - 1));
    } else { // If child field index indicates relocated inner node
        // Borrow mutable reference to it
        let n = v_b<I>(&cb.i, i_n);
        // Get field index of node's parent and children
        let (i_p, i_l, i_r) = (n.p, n.l, n.r);
        // Update children to have relocated node as their parent
        stitch_parent_of_child(cb, i_n, i_l); // Left child
        stitch_parent_of_child(cb, i_n, i_r); // Right child
        // If root node relocated, update root field and return
        if (i_p == ROOT) {cb.r = i_n; return};
        // Else update parent to reflect relocated node position
        stitch_child_of_parent<V>(cb, i_n, i_p, n_n - 1);
    }
}
```

</details>

### Function `traverse_c_i`

Traverse in the specified direction from the node containing the specified key (the "start node" containing the "start key") to either the inorder predecessor or the inorder successor to the start key (the "target node" containing the "target key"), then return the child field index of the target node. See [traversal](critbit.md#Traversal)

#### Method (predecessor)

1. Walk up from start node until arriving at an inner node that has the start key as the minimum key in its right subtree (the "apex node"): walk up until arriving at a parent that has the last walked node as its right child
2. Walk to maximum key in apex node's left subtree, breaking out at target node (the first outer node): walk to apex node's left child, then walk along right children

#### Method (successor)

1. Walk up from start node until arriving at an inner node that has the start key as the maximum key in its left subtree (the "apex node"): walk up until arriving at a parent that has the last walked node as its left child
2. Walk to minimum key in apex node's right subtree, breaking out at target node (the first outer node): walk to apex node's right child, then walk along left children

#### Parameters

* `cb`: Crit-bit tree containing at least two nodes
* `k`: Start key. If predecessor traversal, `k` cannot be minimum key in `cb`, since this key does not have a predecessor. Likewise, if successor traversal, `k` cannot be maximum key in `cb`, since this key does not have a successor
* `p_f`: Start node's parent field
* `d`: Direction to traverse. If [`L`](critbit.md#0xc0deb00c\_CritBit\_L), predecessor traversal, else successor traversal

#### Returns

* `u64`: Child field index of target node

#### Considerations

* Assumes passed start key is not minimum key in tree if predecessor traversal, and that passed start key is not maximum key in tree if successor traversal
* Takes an exposed vector index (`p_f`) as a parameter

```
fun traverse_c_i<V>(cb: &CritBit::CB<V>, k: u128, p_f: u64, d: bool): u64
```

<details>

<summary>Implementation</summary>

```
fun traverse_c_i<V>(
    cb: &CB<V>,
    k: u128,
    p_f: u64,
    d: bool,
): u64 {
    // Borrow immutable reference to start node's parent
    let p = v_b<I>(&cb.i, p_f);
    // If start key is set at parent node's critical bit, then the
    // upward walk has reach an inner node via its right child. This
    // is the break condition for successor traversal, when d is L,
    // a constant value that evaluates to true. The inverse case
    // applies for predecessor traversal, so continue upward walk
    // as long as d is not equal to the conditional critbit check
    while (d != is_set(k, p.c)) { // While break condition not met
        // Borrow immutable reference to next parent in upward walk
        p = v_b<I>(&cb.i, p.p);
    }; // Now at apex node
    // If predecessor traversal get left child field of apex node,
    // else left right field
    let c_f = if (d == L) p.l else p.r;
    while (!is_out(c_f)) { // While child field indicates inner node
        // If predecessor traversal review child's right child next,
        // else review child's left child next
        c_f = if (d == L) v_b<I>(&cb.i, c_f).r else v_b<I>(&cb.i, c_f).l;
    }; // Child field now indicates target node
    c_f // Return child field index of target node
}
```

</details>

### Function `traverse_init_mut`

Initialize a mutable iterated inorder traversal in a tree having at least one outer node. See [traversal](critbit.md#Traversal)

#### Parameters

* `cb`: A crit-bit tree containing at least one outer node
* `d`: Direction to traverse. If [`L`](critbit.md#0xc0deb00c\_CritBit\_L), initialize predecessor traversal, else successor traversal

#### Returns

* `u128`: Maximum key in `cb` if `d` is [`L`](critbit.md#0xc0deb00c\_CritBit\_L), else minimum key
* `&`**`mut`**` ``V`: Mutable reference to corresponding node's value
* `u64`: Parent field of corresponding node
* `u64`: Child field index of corresponding node

#### Considerations

* Exposes node indices
* Assumes caller has already verified tree is not empty

```
fun traverse_init_mut<V>(cb: &mut CritBit::CB<V>, d: bool): (u128, &mut V, u64, u64)
```

<details>

<summary>Implementation</summary>

```
fun traverse_init_mut<V>(
    cb: &mut CB<V>,
    d: bool,
): (
    u128,
    &mut V,
    u64,
    u64
) {
    // If predecessor traversal, get child field index of node
    // having maximum key, else node having minimum key
    let i_n = if (d == L) max_node_c_i(cb) else min_node_c_i(cb);
    // Borrow mutable reference to node
    let n = v_b_m<O<V>>(&mut cb.o, o_v(i_n));
    // Return node's key, mutable reference to its value, its parent
    // field, and the child field index of it
    (n.k, &mut n.v, n.p, i_n)
}
```

</details>

### Function `traverse_mut`

Wrapped [`traverse_c_i`](critbit.md#0xc0deb00c\_CritBit\_traverse\_c\_i)`()` call for enumerated return extraction. See [traversal](critbit.md#Traversal)

#### Returns

* `u128`: Target key
* `&`**`mut`**` ``V`: Mutable reference to target node's value
* `u64`: Target node's parent field
* `u64`: Child field index of target node

```
fun traverse_mut<V>(cb: &mut CritBit::CB<V>, k: u128, p_f: u64, d: bool): (u128, &mut V, u64, u64)
```

<details>

<summary>Implementation</summary>

```
fun traverse_mut<V>(
    cb: &mut CB<V>,
    k: u128,
    p_f: u64,
    d: bool
): (
    u128,
    &mut V,
    u64,
    u64
) {
    // Get child field index of target node
    let i_t = traverse_c_i<V>(cb, k, p_f, d);
    // Borrow mutable reference to target node
    let t = v_b_m<O<V>>(&mut cb.o, o_v(i_t));
    // Return target node's key, mutable reference to its value, its
    // parent field, and child field index of it
    (t.k, &mut t.v, t.p, i_t)
}
```

</details>

### Function `traverse_pop_mut`

Traverse in the specified direction from the node containing the specified key (the "start node" containing the "start key") to either the inorder predecessor or the inorder successor to the start key (the "target node" containing the "target key"), then pop the start node and return its value. See [traversal](critbit.md#Traversal)

#### Parameters

* `cb`: Crit-bit tree containing at least two nodes
* `k`: Start key. If predecessor traversal, `k` cannot be minimum key in `cb`, since this key does not have a predecessor. Likewise, if successor traversal, `k` cannot be maximum key in `cb`, since this key does not have a successor
* `p_f`: Start node's parent field
* `c_i`: Child field index of start node
* `n_o`: Number of outer nodes in `cb`
* `d`: Direction to traverse. If [`L`](critbit.md#0xc0deb00c\_CritBit\_L), predecessor traversal, else successor traversal

#### Returns

* `u128`: Target key
* `&`**`mut`**` ``V`: Mutable reference to target node's value
* `u64`: Target node's parent field
* `u64`: Child field index of target node
* `V`: Popped start node's value

#### Considerations

* Assumes passed start key is not minimum key in tree if predecessor traversal, and that passed start key is not maximum key in tree if successor traversal
* Takes exposed node indices (`p_f`, `c_i`) as parameters
* Does not calculate number of outer nodes in `cb`, but rather accepts this number as a parameter (`n_o`), which should be tracked by the caller

```
fun traverse_pop_mut<V>(cb: &mut CritBit::CB<V>, k: u128, p_f: u64, c_i: u64, n_o: u64, d: bool): (u128, &mut V, u64, u64, V)
```

<details>

<summary>Implementation</summary>

```
fun traverse_pop_mut<V>(
    cb: &mut CB<V>,
    k: u128,
    p_f: u64,
    c_i: u64,
    n_o: u64,
    d: bool
): (
    u128,
    &mut V,
    u64,
    u64,
    V
) {
    // Store side on which the start node is a child of its parent
    let s_s = if(is_set(k, v_b<I>(&cb.i, p_f).c)) R else L;
    // Store target node's pre-pop child field index
    let i_t = traverse_c_i(cb, k, p_f, d);
    // Update relationships for popped start node
    pop_update_relationships(cb, s_s, p_f);
    // Store start node value from pop-facilitated node destruction
    let s_v = pop_destroy_nodes(cb, p_f, c_i, n_o);
    // If target node was last in outer node vector, then swap
    // remove will have relocated it, so update its post-pop field
    // index to the start node's pre-pop field index
    if (o_v(i_t) == n_o - 1) i_t = c_i;
    // Borrow mutable reference to target node
    let t = v_b_m<O<V>>(&mut cb.o, o_v(i_t));
    // Return target node's key, mutable reference to its value, its
    // parent field, the child field index of it, and the start
    // node's popped value
    (t.k, &mut t.v, t.p, i_t, s_v)
}
```

</details>
