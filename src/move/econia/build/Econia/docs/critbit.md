
<a name="0xc0deb00c_critbit"></a>

# Module `0xc0deb00c::critbit`


<a name="@Module-level_documentation_sections_0"></a>

## Module-level documentation sections


* [Background](#Background)
* [Implementation](#Implementation)
* [Basic public functions](#Basic-public-functions)
* [Traversal](#Traversal)


<a name="@Background_1"></a>

## Background


A critical bit (crit-bit) tree is a compact binary prefix tree,
similar to a binary search tree, that stores a prefix-free set of
bitstrings, like n-bit integers or variable-length 0-terminated byte
strings. For a given set of keys there exists a unique crit-bit tree
representing the set, hence crit-bit trees do not require complex
rebalancing algorithms like those of AVL or red-black binary search
trees. Crit-bit trees support the following operations, quickly:

* Membership testing
* Insertion
* Deletion
* Predecessor
* Successor
* Iteration


<a name="@References_2"></a>

### References


* [Bernstein 2006](https://cr.yp.to/critbit.html)
* [Langley 2008](
https://www.imperialviolet.org/2008/09/29/critbit-trees.html)
* [Langley 2012](https://github.com/agl/critbit)
* [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)


<a name="@Implementation_3"></a>

## Implementation



<a name="@Structure_4"></a>

### Structure


The present implementation involves a tree with two types of nodes,
inner (<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a></code>) and outer (<code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a></code>). Inner nodes have two
children each (<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.left_child_index</code> and
<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.right_child_index</code>), while outer nodes have no children.
There are no nodes that have exactly one child. Outer nodes store a
key-value pair with a 128-bit integer as a key (<code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>.key</code>),
and an arbitrary value of generic type (<code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>.value</code>). Inner
nodes do not store a key, but rather, an 8-bit integer
(<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.critical_bit</code>) indicating the most-significant critical
bit (crit-bit) of divergence between keys located within the node's
two subtrees: keys in the node's left subtree are unset at the
critical bit, while keys in the node's right subtree are set at the
critical bit. Both node types have a parent field
(<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.parent_index</code>, <code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>.parent_index</code>), which may be
flagged as <code><a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a></code> if the the node is the root.

Bit numbers are 0-indexed starting at the least-significant bit
(LSB), such that a critical bit of 3, for instance, corresponds to a
comparison between <code>00...00000</code> and <code>00...01111</code>. Inner nodes are
arranged hierarchically, with the most significant critical bits at
the top of the tree. For instance, the keys <code>001</code>, <code>101</code>, <code>110</code>, and
<code>111</code> would be stored in a <code><a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a></code> tree as follows (right
carets included at left of illustration per issue with documentation
build engine, namely, the automatic stripping of leading whitespace
in documentation comments, which prohibits the simple initiation of
monospaced code blocks through indentation by 4 spaces):
```
>       2nd
>      /   \
>    001   1st
>         /   \
>       101   0th
>            /   \
>          110   111
```
Here, the inner node marked <code>2nd</code> stores the integer 2, the inner
node marked <code>1st</code> stores the integer 1, and the inner node marked
<code>0th</code> stores the integer 0. Hence, the sole key in the left subtree
of the inner node marked <code>2nd</code> is unset at bit 2, while all the keys
in the node's right subtree are set at bit 2. And similarly for the
inner node marked <code>0th</code>, its left child is unset at bit 0, while its
right child is set at bit 0.


<a name="@Node_indices_5"></a>

### Node indices


Both <code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a></code>s and <code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a></code>s are stored in vectors
(<code><a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>.inner_nodes</code> and <code><a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>.outer_nodes</code>), and
parent-child relationships between nodes are described in terms of
vector indices: an outer node having <code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>.parent_index = 123</code>,
for instance, has as its parent an inner node at vector index <code>123</code>.
Notably, the vector index of an inner node is identical to the
number indicated by its child's <code>parent_index</code>
(<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.parent_index</code> or <code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>.parent_index</code>), but the
vector index of an outer node is **not** identical to the number
indicated by its parent's <code>child_index</code>
(<code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.left_child_index</code> or <code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>.right_child_index</code>),
because the 63rd bit of a so-called "field index" (the number stored
in a struct field) is reserved for a node type bit flag, with outer
nodes having bit 63 set and inner nodes having bit 63 unset. This
schema enables discrimination between node types based solely on the
"field index" of a related node via <code><a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>()</code>, but requires
that outer node indices be routinely converted between "child field
index" form and "vector index" form via <code><a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>()</code>
and <code><a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>()</code>.

Similarly, if a node, inner or outer, is located at the root, its
<code>parent_index</code> will indicate <code><a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a></code>, and will not correspond to the
vector index of any inner node, since the root node does not have a
parent. Likewise, the "root field" of the tree (<code><a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>.root</code>)
will contain the field index of the given node, set at bit 63 if the
root is an outer node.


<a name="@Basic_public_functions_6"></a>

## Basic public functions



<a name="@Initialization_7"></a>

### Initialization

* <code><a href="critbit.md#0xc0deb00c_critbit_empty">empty</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_singleton">singleton</a>()</code>


<a name="@Mutation_8"></a>

### Mutation

* <code><a href="critbit.md#0xc0deb00c_critbit_borrow_mut">borrow_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_insert">insert</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_pop">pop</a>()</code>


<a name="@Lookup_9"></a>

### Lookup

* <code><a href="critbit.md#0xc0deb00c_critbit_borrow">borrow</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_has_key">has_key</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_max_key">max_key</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_min_key">min_key</a>()</code>


<a name="@Size_10"></a>

### Size

* <code><a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_length">length</a>()</code>


<a name="@Destruction_11"></a>

### Destruction

* <code><a href="critbit.md#0xc0deb00c_critbit_destroy_empty">destroy_empty</a>()</code>


<a name="@Traversal_12"></a>

## Traversal


[Predecessor public functions](#Predecessor-public-functions) and
[successor public functions](#Successor-public-functions) are
wrapped [generic public functions](#Generic-public-functions),
with documentation comments from <code><a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>()</code> as
well as [generic public functions](#Generic-public-functions)
detailing the relevant algorithms. See [walkthrough](#Walkthrough)
for canonical implementation syntax.


<a name="@Predecessor_public_functions_13"></a>

### Predecessor public functions

* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_init_mut">traverse_predecessor_init_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_mut">traverse_predecessor_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_pop_mut">traverse_predecessor_pop_mut</a>()</code>


<a name="@Successor_public_functions_14"></a>

### Successor public functions

* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_successor_init_mut">traverse_successor_init_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_successor_mut">traverse_successor_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_successor_pop_mut">traverse_successor_pop_mut</a>()</code>


<a name="@Generic_public_functions_15"></a>

### Generic public functions

* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>()</code>
* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>()</code>


<a name="@Public_end_on_pop_function_16"></a>

### Public end on pop function

* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_end_pop">traverse_end_pop</a>()</code>


<a name="@Private_traversal_function_17"></a>

### Private traversal function

* <code><a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>()</code>


<a name="@Walkthrough_18"></a>

### Walkthrough

* [Syntax motivations](#Syntax-motivations)
* [Full predecessor traversal](#Full-predecessor-traversal)
* [Partial successor traversal](#Partial-successor-traversal)
* [Singleton traversal initialization
](#Singleton-traversal-initialization)
* [Ending traversal on a pop](#Ending-traversal-on-a-pop)


<a name="@Syntax_motivations_19"></a>

#### Syntax motivations


Iterated traversal, unlike other public implementations, exposes
internal [node indices](#Node-indices) that must be tracked during
loopwise operations, because Move's borrow-checking system prohibits
mutably borrowing a <code><a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a></code> when an <code><a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a></code> or <code><a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a></code>
is already being mutably borrowed. Not that this borrow-checking
constraint introduces an absolute prohibition on iterated traversal
without exposed node indices, but rather, the given borrow-checking
constraints render non-node-index-exposed traversal inefficient: to
traverse without exposing internal node indices would require
searching for a key from the root during each iteration. Instead, by
publicly exposing node indices, it is possible to traverse from one
outer node to the next without having to perform such redundant
operations, per <code><a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>()</code>.

The test <code>traverse_demo()</code> provides canonical traversal syntax
in this regard, with exposed node indices essentially acting as
pointers. Hence, node-index-exposed traversal presents a kind of
circumvention of Move's borrow-checking system, implemented only
due to a need for greater efficiency. Like pointer-based
implementations in general, this solution is extremely powerful in
terms of the speed enhancement it provides, but if used incorrectly
it can lead to "undefined behavior." As such, a breakdown of the
canonical syntax is provided below, along with additional discussion
on error-checking facilities that have been intentionally excluded
in the interest of efficiency.


<a name="@Full_predecessor_traversal_20"></a>

#### Full predecessor traversal


To start, initialize a tree with {$n, 100n$}, for $0 < n < 10$:

```move
let tree = empty(); // Initialize empty tree
// Insert {n, 100 * n} for 0 < n < 10, out of order
insert(&mut tree, 9, 900);
insert(&mut tree, 6, 600);
insert(&mut tree, 3, 300);
insert(&mut tree, 1, 100);
insert(&mut tree, 8, 800);
insert(&mut tree, 2, 200);
insert(&mut tree, 7, 700);
insert(&mut tree, 5, 500);
insert(&mut tree, 4, 400);
```

Before starting traversal, first verify that the tree is not empty:

```move
assert!(!is_empty(&tree), 0); // Assert tree not empty
```

This check could be performed within the generalized initialization
function, <code><a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>()</code>, but doing so would introduce
compounding computational overhead, especially for applications
where traversal is repeatedly initialized after having already
established that the tree in question is not empty. Hence it is
assumed that any functions which call traversal initializers will
only do so after having verified that node iteration is possible in
the first place, and that they will track loop counters to prevent
an attempted traversal past the end of the tree. The loop counters
in question include a counter for the number of keys in the tree,
which must be decremented if any nodes are popped during traversal,
and a counter for the number of remaining traversals possible:

```move
let n_keys = length(&tree); // Get number of keys in the tree
// Get number of remaining traversals possible
let remaining_traversals = n_keys - 1;
```

Continuing the example, then initialize predecessor traversal per
<code><a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_init_mut">traverse_predecessor_init_mut</a>()</code>, storing the max key in the tree,
a mutable reference to its corresponding value, the parent field of
the corresponding node, and the child field index of the
corresponding node. Again, since Move's documentation build engine
strips leading whitespace, right carets are included to preserve
indentation:

```move
> // Initialize predecessor traversal: get max key in tree,
> // mutable reference to corresponding value, parent field of
> // corresponding node, and the child field index of it
> let (key, value_ref, parent_index, child_index) =
>     traverse_predecessor_init_mut(&mut tree);
```

Now perform an inorder predecessor traversal, popping out the node
for any keys that are a multiple of 4, otherwise incrementing the
corresponding value by a monotonically increasing multiple of 10,
starting at 10, with the exception of the final node, which has its
value set to 0. Hence, {9, 900} updates to {9, 910}, {8, 800} gets
popped, {7, 700} updates to {7, 720}, and so on, until {1, 100} gets
updated to {1, 0}.

```move
> let i = 10; // Initialize value increment counter
> // While remaining traversals possible
> while(remaining_traversals > 0) {
>     if (key % 4 == 0) { // If key is a multiple of 4
>         // Traverse pop corresponding node and discard its value
>         (key, value_ref, parent_index, child_index, _) =
>             traverse_predecessor_pop_mut(
>                 &mut tree, key, parent_index, child_index, n_keys);
>         n_keys = n_keys - 1; // Decrement key count
>     } else { // If key is not a multiple of 4
>         // Increment corresponding value
>         *value_ref = *value_ref + i;
>         i = i + 10; // Increment by 10 more next iteration
>         // Traverse to predecessor
>         (key, value_ref, parent_index, child_index) =
>             traverse_predecessor_mut(&mut tree, key, parent_index);
>     };
>     // Decrement remaining traversal count
>     remaining_traversals = remaining_traversals - 1;
> }; // Traversal has ended up at node having minimum key
> *value_ref = 0; // Set corresponding value to 0
```

After the traversal, {4, 400} and {8, 800} have thus been popped,
and key-value pairs have updated accordingly:

```move
// Assert keys popped correctly
assert!(!has_key(&tree, 4) && !has_key(&tree, 8), 1);
// Assert keys popped correctly
assert!(!has_key(&tree, 4) && !has_key(&tree, 8), 1);
// Assert correct value updates
assert!(*borrow(&tree, 1) ==   0, 2);
assert!(*borrow(&tree, 2) == 260, 3);
assert!(*borrow(&tree, 3) == 350, 4);
assert!(*borrow(&tree, 5) == 540, 5);
assert!(*borrow(&tree, 6) == 630, 6);
assert!(*borrow(&tree, 7) == 720, 7);
assert!(*borrow(&tree, 9) == 910, 8);
```

Here, the only assurance that the traversal does not go past the end
of the tree is the proper tracking of loop variables: again, the
relevant error-checking could have been implemented in a
corresponding traversal function, namely
<code><a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>()</code>, but this would introduce
compounding computational overhead. Since traversal already requires
precise management of loop counter variables and node indices, it is
assumed that they are managed correctly and thus no redundant
error-checking is implemented so as to improve efficiency.


<a name="@Partial_successor_traversal_21"></a>

#### Partial successor traversal


Continuing the example, since the number of keys was updated during
the last loop, simply check that key count is greater than 0 to
verify tree is not empty. Then re-initialize the remaining traversal
counter, and this time use a value increment counter for a
monotonically increasing multiple of 1. Then initialize successor
traversal:

```move
> assert!(n_keys > 0, 9); // Assert tree still not empty
> // Re-initialize counters: remaining traversal, value increment
> (remaining_traversals, i) = (n_keys - 1, 1);
> // Initialize successor traversal
> (key, value_ref, parent_index, child_index) =
>     traverse_successor_init_mut(&mut tree);
```

Here, if the key is equal to 7, then traverse pop the corresponding
node and store its value, then stop traversal:

```move
> // Initialize variable to store value of matched node
> let value = 0;
> // While remaining traversals possible
> while(remaining_traversals > 0) {
>     if (key == 7) { // If key is 7
>         // Traverse pop corresponding node and store its value
>         (_, _, _, _, value) = traverse_successor_pop_mut(
>             &mut tree, key, parent_index, child_index, n_keys);
>         break // Stop traversal
>     } else { // For all keys not equal to 7
>         // Increment corresponding value
>         *value_ref = *value_ref + i;
>         // Traverse to successor
>         (key, value_ref, parent_index, child_index) =
>             traverse_successor_mut(&mut tree, key, parent_index);
>         i = i + 1; // Increment by 1 more next iteration
>     };
>     // Decrement remaining traversal count
>     remaining_traversals = remaining_traversals - 1;
> };
```
Hence {7, 720} has been popped, {9, 910} has been left unmodified,
and other key-value pairs have been updated accordingly:

```move
// Assert key popped correctly
assert!(!has_key(&tree, 7), 10);
// Assert value of popped node stored correctly
assert!(value == 720, 11);
// Assert values updated correctly
assert!(*borrow(&tree, 1) ==   1, 12);
assert!(*borrow(&tree, 2) == 262, 13);
assert!(*borrow(&tree, 3) == 353, 14);
assert!(*borrow(&tree, 5) == 544, 15);
assert!(*borrow(&tree, 6) == 635, 16);
assert!(*borrow(&tree, 9) == 910, 17);
```


<a name="@Singleton_traversal_initialization_22"></a>

#### Singleton traversal initialization


Traversal initializers can still be validly called in the case of a
singleton tree:

```move
> // Pop all key-value pairs except {9, 910}
> pop(&mut tree, 1);
> pop(&mut tree, 2);
> pop(&mut tree, 3);
> pop(&mut tree, 5);
> pop(&mut tree, 6);
> assert!(!is_empty(&tree), 18); // Assert tree not empty
> let n_keys = length(&tree); // Get number of keys in the tree
> // Get number of remaining traversals possible
> let remaining_traversals = n_keys - 1;
> // Initialize successor traversal
> (key, value_ref, parent_index, _) =
>     traverse_successor_init_mut(&mut tree);
```

In this case, the value of the corresponding node can still be
updated, and a traversal loop can even be implemented, with the loop
simply being skipped over:

```move
> *value_ref = 1234; // Update value of node having minimum key
> // While remaining traversals possible
> while(remaining_traversals > 0) {
>     *value_ref = 4321; // Update value of corresponding node
>     // Traverse to successor
>     (key, value_ref, parent_index, _) = traverse_successor_mut(
>         &mut tree, key, parent_index);
>     // Decrement remaining traversal count
>     remaining_traversals = remaining_traversals - 1;
> }; // This loop does not go through any iterations
> // Assert value unchanged via loop
> assert!(pop(&mut tree, 9) == 1234, 19);
> destroy_empty(tree); // Destroy empty tree
```


<a name="@Ending_traversal_on_a_pop_23"></a>

#### Ending traversal on a pop

Traversal popping can similarly be executed, but without traversing
any further, via <code><a href="critbit.md#0xc0deb00c_critbit_traverse_end_pop">traverse_end_pop</a>()</code>, which can be invoked at any
point during iterated traversal, thus ending the traversal with a
pop. See the <code>traverse_end_pop_success()</code> test.

---


-  [Module-level documentation sections](#@Module-level_documentation_sections_0)
-  [Background](#@Background_1)
    -  [References](#@References_2)
-  [Implementation](#@Implementation_3)
    -  [Structure](#@Structure_4)
    -  [Node indices](#@Node_indices_5)
-  [Basic public functions](#@Basic_public_functions_6)
    -  [Initialization](#@Initialization_7)
    -  [Mutation](#@Mutation_8)
    -  [Lookup](#@Lookup_9)
    -  [Size](#@Size_10)
    -  [Destruction](#@Destruction_11)
-  [Traversal](#@Traversal_12)
    -  [Predecessor public functions](#@Predecessor_public_functions_13)
    -  [Successor public functions](#@Successor_public_functions_14)
    -  [Generic public functions](#@Generic_public_functions_15)
    -  [Public end on pop function](#@Public_end_on_pop_function_16)
    -  [Private traversal function](#@Private_traversal_function_17)
    -  [Walkthrough](#@Walkthrough_18)
        -  [Syntax motivations](#@Syntax_motivations_19)
        -  [Full predecessor traversal](#@Full_predecessor_traversal_20)
        -  [Partial successor traversal](#@Partial_successor_traversal_21)
        -  [Singleton traversal initialization](#@Singleton_traversal_initialization_22)
        -  [Ending traversal on a pop](#@Ending_traversal_on_a_pop_23)
-  [Struct `CritBitTree`](#0xc0deb00c_critbit_CritBitTree)
-  [Struct `InnerNode`](#0xc0deb00c_critbit_InnerNode)
-  [Struct `OuterNode`](#0xc0deb00c_critbit_OuterNode)
-  [Constants](#@Constants_24)
-  [Function `borrow`](#0xc0deb00c_critbit_borrow)
-  [Function `borrow_mut`](#0xc0deb00c_critbit_borrow_mut)
-  [Function `destroy_empty`](#0xc0deb00c_critbit_destroy_empty)
-  [Function `empty`](#0xc0deb00c_critbit_empty)
-  [Function `has_key`](#0xc0deb00c_critbit_has_key)
-  [Function `insert`](#0xc0deb00c_critbit_insert)
-  [Function `is_empty`](#0xc0deb00c_critbit_is_empty)
-  [Function `length`](#0xc0deb00c_critbit_length)
-  [Function `max_key`](#0xc0deb00c_critbit_max_key)
-  [Function `min_key`](#0xc0deb00c_critbit_min_key)
-  [Function `pop`](#0xc0deb00c_critbit_pop)
-  [Function `singleton`](#0xc0deb00c_critbit_singleton)
-  [Function `traverse_init_mut`](#0xc0deb00c_critbit_traverse_init_mut)
    -  [Parameters](#@Parameters_25)
    -  [Returns](#@Returns_26)
    -  [Considerations](#@Considerations_27)
-  [Function `traverse_mut`](#0xc0deb00c_critbit_traverse_mut)
    -  [Returns](#@Returns_28)
-  [Function `traverse_pop_mut`](#0xc0deb00c_critbit_traverse_pop_mut)
    -  [Parameters](#@Parameters_29)
    -  [Returns](#@Returns_30)
    -  [Considerations](#@Considerations_31)
-  [Function `traverse_end_pop`](#0xc0deb00c_critbit_traverse_end_pop)
    -  [Parameters](#@Parameters_32)
    -  [Returns](#@Returns_33)
    -  [Considerations](#@Considerations_34)
-  [Function `traverse_predecessor_init_mut`](#0xc0deb00c_critbit_traverse_predecessor_init_mut)
-  [Function `traverse_predecessor_mut`](#0xc0deb00c_critbit_traverse_predecessor_mut)
-  [Function `traverse_predecessor_pop_mut`](#0xc0deb00c_critbit_traverse_predecessor_pop_mut)
-  [Function `traverse_successor_init_mut`](#0xc0deb00c_critbit_traverse_successor_init_mut)
-  [Function `traverse_successor_mut`](#0xc0deb00c_critbit_traverse_successor_mut)
-  [Function `traverse_successor_pop_mut`](#0xc0deb00c_critbit_traverse_successor_pop_mut)
-  [Function `borrow_closest_outer_node`](#0xc0deb00c_critbit_borrow_closest_outer_node)
-  [Function `borrow_closest_outer_node_mut`](#0xc0deb00c_critbit_borrow_closest_outer_node_mut)
-  [Function `check_length`](#0xc0deb00c_critbit_check_length)
-  [Function `crit_bit`](#0xc0deb00c_critbit_crit_bit)
    -  [XOR/AND method](#@XOR/AND_method_35)
    -  [Binary search method](#@Binary_search_method_36)
-  [Function `insert_above`](#0xc0deb00c_critbit_insert_above)
-  [Function `insert_above_root`](#0xc0deb00c_critbit_insert_above_root)
-  [Function `insert_below`](#0xc0deb00c_critbit_insert_below)
-  [Function `insert_below_walk`](#0xc0deb00c_critbit_insert_below_walk)
-  [Function `insert_empty`](#0xc0deb00c_critbit_insert_empty)
-  [Function `insert_general`](#0xc0deb00c_critbit_insert_general)
-  [Function `insert_singleton`](#0xc0deb00c_critbit_insert_singleton)
-  [Function `max_node_child_index`](#0xc0deb00c_critbit_max_node_child_index)
-  [Function `min_node_child_index`](#0xc0deb00c_critbit_min_node_child_index)
-  [Function `is_outer_node`](#0xc0deb00c_critbit_is_outer_node)
-  [Function `is_set`](#0xc0deb00c_critbit_is_set)
-  [Function `outer_node_child_index`](#0xc0deb00c_critbit_outer_node_child_index)
-  [Function `outer_node_vector_index`](#0xc0deb00c_critbit_outer_node_vector_index)
-  [Function `pop_destroy_nodes`](#0xc0deb00c_critbit_pop_destroy_nodes)
-  [Function `pop_general`](#0xc0deb00c_critbit_pop_general)
-  [Function `pop_singleton`](#0xc0deb00c_critbit_pop_singleton)
-  [Function `pop_update_relationships`](#0xc0deb00c_critbit_pop_update_relationships)
-  [Function `push_back_insert_nodes`](#0xc0deb00c_critbit_push_back_insert_nodes)
-  [Function `search_outer`](#0xc0deb00c_critbit_search_outer)
-  [Function `stitch_child_of_parent`](#0xc0deb00c_critbit_stitch_child_of_parent)
-  [Function `stitch_parent_of_child`](#0xc0deb00c_critbit_stitch_parent_of_child)
-  [Function `stitch_swap_remove`](#0xc0deb00c_critbit_stitch_swap_remove)
-  [Function `traverse_target_child_index`](#0xc0deb00c_critbit_traverse_target_child_index)
    -  [Method (predecessor)](#@Method_(predecessor)_37)
    -  [Method (successor)](#@Method_(successor)_38)
    -  [Parameters](#@Parameters_39)
    -  [Returns](#@Returns_40)
    -  [Considerations](#@Considerations_41)


<pre><code><b>use</b> <a href="">0x1::vector</a>;
</code></pre>



<a name="0xc0deb00c_critbit_CritBitTree"></a>

## Struct `CritBitTree`

A crit-bit tree for key-value pairs with value type <code>V</code>


<pre><code><b>struct</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>root: u64</code>
</dt>
<dd>
 Root node index. When bit 63 is set, root node is an outer
 node. Otherwise root is an inner node. 0 when tree is empty
</dd>
<dt>
<code>inner_nodes: <a href="">vector</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">critbit::InnerNode</a>&gt;</code>
</dt>
<dd>
 Inner nodes
</dd>
<dt>
<code>outer_nodes: <a href="">vector</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">critbit::OuterNode</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Outer nodes
</dd>
</dl>


</details>

<a name="0xc0deb00c_critbit_InnerNode"></a>

## Struct `InnerNode`

Inner node


<pre><code><b>struct</b> <a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>critical_bit: u8</code>
</dt>
<dd>
 Critical bit position. Bit numbers 0-indexed from LSB:

 ```
 >    11101...1010010101
 >     bit 5 = 0 -|    |- bit 0 = 1
 ```
</dd>
<dt>
<code>parent_index: u64</code>
</dt>
<dd>
 Parent node vector index. <code><a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a></code> when node is root,
 otherwise corresponds to vector index of an inner node.
</dd>
<dt>
<code>left_child_index: u64</code>
</dt>
<dd>
 Left child node index. When bit 63 is set, left child is an
 outer node. Otherwise left child is an inner node.
</dd>
<dt>
<code>right_child_index: u64</code>
</dt>
<dd>
 Right child node index. When bit 63 is set, right child is
 an outer node. Otherwise right child is an inner node.
</dd>
</dl>


</details>

<a name="0xc0deb00c_critbit_OuterNode"></a>

## Struct `OuterNode`

Outer node with key <code>k</code> and value <code>v</code>


<pre><code><b>struct</b> <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>key: u128</code>
</dt>
<dd>
 Key, which would preferably be a generic type representing
 the union of {<code>u8</code>, <code>u64</code>, <code>u128</code>}. However this kind of
 union typing is not supported by Move, so the most general
 (and memory intensive) <code>u128</code> is instead specified strictly.
 Must be an integer for bitwise operations.
</dd>
<dt>
<code>value: V</code>
</dt>
<dd>
 Value from node's key-value pair
</dd>
<dt>
<code>parent_index: u64</code>
</dt>
<dd>
 Parent node vector index. <code><a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a></code> when node is root,
 otherwise corresponds to vector index of an inner node.
</dd>
</dl>


</details>

<a name="@Constants_24"></a>

## Constants


<a name="0xc0deb00c_critbit_E_BIT_NOT_0_OR_1"></a>

When a char in a bytestring is neither 0 nor 1


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_critbit_E_BORROW_EMPTY"></a>

When unable to borrow from empty tree


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_critbit_E_DESTROY_NOT_EMPTY"></a>

When attempting to destroy a non-empty tree


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_critbit_E_HAS_KEY"></a>

When an insertion key is already present in a tree


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_HAS_KEY">E_HAS_KEY</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_critbit_E_INSERT_FULL"></a>

When no more keys can be inserted


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_INSERT_FULL">E_INSERT_FULL</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_critbit_E_LOOKUP_EMPTY"></a>

When attempting to look up on an empty tree


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_LOOKUP_EMPTY">E_LOOKUP_EMPTY</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_critbit_E_NOT_HAS_KEY"></a>

When no matching key in tree


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_NOT_HAS_KEY">E_NOT_HAS_KEY</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_critbit_E_POP_EMPTY"></a>

When attempting to pop from empty tree


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_E_POP_EMPTY">E_POP_EMPTY</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_critbit_HI_128"></a>

<code>u128</code> bitmask with all bits set


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_critbit_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_critbit_INNER"></a>

Node type bit flag indicating inner node


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_INNER">INNER</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_critbit_LEFT"></a>

Left direction


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_critbit_MSB_u128"></a>

Most significant bit number for a <code>u128</code>


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_MSB_u128">MSB_u128</a>: u8 = 127;
</code></pre>



<a name="0xc0deb00c_critbit_NODE_TYPE"></a>

Bit number of node type flag in a <code>u64</code> vector index


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_NODE_TYPE">NODE_TYPE</a>: u8 = 63;
</code></pre>



<a name="0xc0deb00c_critbit_OUTER"></a>

Node type bit flag indicating outer node


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_critbit_RIGHT"></a>

Right direction


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_critbit_ROOT"></a>

<code>u64</code> bitmask with all bits set, to flag that a node is at root


<pre><code><b>const</b> <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_critbit_borrow"></a>

## Function `borrow`

Return immutable reference to value corresponding to key <code>k</code> in
<code>tree</code>, aborting if empty tree or no match


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow">borrow</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow">borrow</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
): &V {
    <b>assert</b>!(!<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>&lt;V&gt;(tree), <a href="critbit.md#0xc0deb00c_critbit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>); // Abort <b>if</b> empty
    // Borrow immutable reference <b>to</b> closest outer node
    <b>let</b> closest_outer_node_ref = <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node">borrow_closest_outer_node</a>&lt;V&gt;(tree, key);
    // Abort <b>if</b> key not in tree
    <b>assert</b>!(closest_outer_node_ref.key == key, <a href="critbit.md#0xc0deb00c_critbit_E_NOT_HAS_KEY">E_NOT_HAS_KEY</a>);
    // Return immutable reference <b>to</b> corresponding value
    &closest_outer_node_ref.value
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_borrow_mut"></a>

## Function `borrow_mut`

Return mutable reference to value corresponding to key <code>k</code> in
<code>tree</code>, aborting if empty tree or no match


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_mut">borrow_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): &<b>mut</b> V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_mut">borrow_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
): &<b>mut</b> V {
    <b>assert</b>!(!<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>&lt;V&gt;(tree), <a href="critbit.md#0xc0deb00c_critbit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>); // Abort <b>if</b> empty
    <b>let</b> closest_outer_node_ref_mut =
        <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node_mut">borrow_closest_outer_node_mut</a>&lt;V&gt;(tree, key);
    // Abort <b>if</b> key not in tree
    <b>assert</b>!(closest_outer_node_ref_mut.key == key, <a href="critbit.md#0xc0deb00c_critbit_E_NOT_HAS_KEY">E_NOT_HAS_KEY</a>);
    // Return mutable reference <b>to</b> corresponding value
    &<b>mut</b> closest_outer_node_ref_mut.value
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_destroy_empty"></a>

## Function `destroy_empty`

Destroy empty tree <code>tree</code>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_destroy_empty">destroy_empty</a>&lt;V&gt;(tree: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_destroy_empty">destroy_empty</a>&lt;V&gt;(
    tree: <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;
) {
    <b>assert</b>!(<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>(&tree), <a href="critbit.md#0xc0deb00c_critbit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>);
    // Unpack root index and node vectors
    <b>let</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>{root: _, inner_nodes, outer_nodes} = tree;
    // Destroy empty inner node <a href="">vector</a>
    <a href="_destroy_empty">vector::destroy_empty</a>(inner_nodes);
    // Destroy empty outer node <a href="">vector</a>
    <a href="_destroy_empty">vector::destroy_empty</a>(outer_nodes);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_empty"></a>

## Function `empty`

Return an empty tree


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_empty">empty</a>&lt;V&gt;(): <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_empty">empty</a>&lt;V&gt;():
<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt; {
    <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>{
        root: 0,
        inner_nodes: <a href="_empty">vector::empty</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(),
        outer_nodes: <a href="_empty">vector::empty</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;()
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_has_key"></a>

## Function `has_key`

Return true if <code>tree</code> has <code>key</code>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_has_key">has_key</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_has_key">has_key</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
): bool {
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>&lt;V&gt;(tree)) <b>return</b> <b>false</b>; // Return <b>false</b> <b>if</b> empty
    // Return <b>true</b> <b>if</b> closest outer node <b>has</b> same key
    <b>return</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node">borrow_closest_outer_node</a>&lt;V&gt;(tree, key).key == key
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert"></a>

## Function `insert`

Insert <code>key</code> and <code>value</code> into <code>tree</code>, aborting if <code>key</code> already
in <code>tree</code>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert">insert</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert">insert</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V
) {
    <b>let</b> length = <a href="critbit.md#0xc0deb00c_critbit_length">length</a>(tree); // Get length of tree
    <a href="critbit.md#0xc0deb00c_critbit_check_length">check_length</a>(length); // Verify insertion can take place
    // Insert via one of three cases, depending on the length
    <b>if</b> (length == 0) <a href="critbit.md#0xc0deb00c_critbit_insert_empty">insert_empty</a>(tree, key, value) <b>else</b>
    <b>if</b> (length == 1) <a href="critbit.md#0xc0deb00c_critbit_insert_singleton">insert_singleton</a>(tree, key, value) <b>else</b>
    <a href="critbit.md#0xc0deb00c_critbit_insert_general">insert_general</a>(tree, key, value, length);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if <code>tree</code> has no outer nodes


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;
): bool {
    <a href="_is_empty">vector::is_empty</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_length"></a>

## Function `length`

Return number of keys in <code>tree</code> (number of outer nodes)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_length">length</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_length">length</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;
): u64 {
    <a href="_length">vector::length</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_max_key"></a>

## Function `max_key`

Return the maximum key in <code>tree</code>, aborting if <code>tree</code> is empty


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_max_key">max_key</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_max_key">max_key</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
): u128 {
    // Assert tree not empty
    <b>assert</b>!(!<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>(tree), <a href="critbit.md#0xc0deb00c_critbit_E_LOOKUP_EMPTY">E_LOOKUP_EMPTY</a>);
    // Return max key
    <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(
        &tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(<a href="critbit.md#0xc0deb00c_critbit_max_node_child_index">max_node_child_index</a>&lt;V&gt;(tree))
    ).key
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_min_key"></a>

## Function `min_key`

Return the minimum key in <code>tree</code>, aborting if <code>tree</code> is empty


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_min_key">min_key</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_min_key">min_key</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
): u128 {
    // Assert tree not empty
    <b>assert</b>!(!<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>(tree), <a href="critbit.md#0xc0deb00c_critbit_E_LOOKUP_EMPTY">E_LOOKUP_EMPTY</a>);
    // Return <b>min</b> key
    <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(
        &tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(<a href="critbit.md#0xc0deb00c_critbit_min_node_child_index">min_node_child_index</a>&lt;V&gt;(tree))
    ).key
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_pop"></a>

## Function `pop`

Pop from <code>tree</code> value corresponding to <code>key</code>, aborting if <code>tree</code>
is empty or does not contain <code>key</code>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop">pop</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop">pop</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128
): V {
    <b>assert</b>!(!<a href="critbit.md#0xc0deb00c_critbit_is_empty">is_empty</a>(tree), <a href="critbit.md#0xc0deb00c_critbit_E_POP_EMPTY">E_POP_EMPTY</a>); // Assert tree not empty
    <b>let</b> length = <a href="critbit.md#0xc0deb00c_critbit_length">length</a>(tree); // Get number of outer nodes in tree
    // If length 1, pop from singleton tree
    <b>if</b> (length == 1) <a href="critbit.md#0xc0deb00c_critbit_pop_singleton">pop_singleton</a>(tree, key) <b>else</b>
        // Otherwise pop in the general case
        <a href="critbit.md#0xc0deb00c_critbit_pop_general">pop_general</a>(tree, key, length)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_singleton"></a>

## Function `singleton`

Return a tree with one node having <code>key</code> and <code>value</code>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_singleton">singleton</a>&lt;V&gt;(key: u128, value: V): <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_singleton">singleton</a>&lt;V&gt;(
    key: u128,
    value: V
): <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt; {
    <b>let</b> tree = <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>{
        root: 0,
        inner_nodes: <a href="_empty">vector::empty</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(),
        outer_nodes: <a href="_empty">vector::empty</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;()
    };
    <a href="critbit.md#0xc0deb00c_critbit_insert_empty">insert_empty</a>&lt;V&gt;(&<b>mut</b> tree, key, value);
    tree
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_init_mut"></a>

## Function `traverse_init_mut`

Initialize a mutable iterated inorder traversal in a tree having
at least one outer node. See [traversal](#Traversal)


<a name="@Parameters_25"></a>

### Parameters

* <code>tree</code>: A crit-bit tree containing at least one outer node
* <code>direction</code>: Direction to traverse. If <code><a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a></code>, initialize
predecessor traversal, else successor traversal


<a name="@Returns_26"></a>

### Returns

* <code>u128</code>: Maximum key in <code>tree</code> if <code>direction</code> is <code><a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a></code>, else
minimum key
* <code>&<b>mut</b> V</code>: Mutable reference to corresponding node's value
* <code>u64</code>: Parent field of corresponding node
* <code>u64</code>: Child field index of corresponding node


<a name="@Considerations_27"></a>

### Considerations

* Exposes node indices
* Assumes caller has already verified tree is not empty


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, direction: bool): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    direction: bool,
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    // If predecessor traversal, get child field index of node
    // having maximum key, <b>else</b> node having minimum key
    <b>let</b> child_field_index = <b>if</b> (direction == <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>)
        <a href="critbit.md#0xc0deb00c_critbit_max_node_child_index">max_node_child_index</a>(tree) <b>else</b>
        <a href="critbit.md#0xc0deb00c_critbit_min_node_child_index">min_node_child_index</a>(tree);
    // Borrow mutable reference <b>to</b> node
    <b>let</b> node = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(child_field_index));
    // Return node's key, mutable reference <b>to</b> its value, its parent
    // field, and the child field index of it
    (node.key, &<b>mut</b> node.value, node.parent_index, child_field_index)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_mut"></a>

## Function `traverse_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>()</code> call for enumerated
return extraction. See [traversal](#Traversal)


<a name="@Returns_28"></a>

### Returns

* <code>u128</code>: Target key
* <code>&<b>mut</b> V</code>: Mutable reference to target node's value
* <code>u64</code>: Target node's parent field
* <code>u64</code>: Child field index of target node


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64, direction: bool): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64,
    direction: bool
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    // Get child field index of target node
    <b>let</b> target_child_index =
        <a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>&lt;V&gt;(tree, key, parent_index, direction);
    // Borrow mutable reference <b>to</b> target node
    <b>let</b> node = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(target_child_index));
    // Return target node's key, mutable reference <b>to</b> its value, its
    // parent field, and child field index of it
    (node.key, &<b>mut</b> node.value, node.parent_index, target_child_index)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_pop_mut"></a>

## Function `traverse_pop_mut`

Traverse in the specified direction from the node containing the
specified key (the "start node" containing the "start key") to
either the inorder predecessor or the inorder successor to the
start key (the "target node" containing the "target key"), then
pop the start node and return its value. See
[traversal](#Traversal)


<a name="@Parameters_29"></a>

### Parameters

* <code>tree</code>: Crit-bit tree containing at least two nodes
* <code>key</code>: Start key. If predecessor traversal, cannot be minimum
key in <code>tree</code>, since this key does not have a predecessor.
Likewise, if successor traversal, cannot be maximum key in
<code>tree</code>, since this key does not have a successor
* <code>parent_index</code>: Start node's parent field
* <code>child_index</code>: Child index of start node
* <code>n_outer_nodes</code>: Number of outer nodes in <code>tree</code>
* <code>direction</code>: Direction to traverse. If <code><a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a></code>, predecessor
traversal, else successor traversal


<a name="@Returns_30"></a>

### Returns

* <code>u128</code>: Target key
* <code>&<b>mut</b> V</code>: Mutable reference to target node's value
* <code>u64</code>: Target node's parent field
* <code>u64</code>: Child field index of target node
* <code>V</code>: Popped start node's value


<a name="@Considerations_31"></a>

### Considerations

* Assumes passed start key is not minimum key in tree if
predecessor traversal, and that passed start key is not
maximum key in tree if successor traversal
* Takes exposed node indices (<code>parent_index</code>, <code>child_index</code>) as
parameters
* Does not calculate number of outer nodes in <code>tree</code>, but rather
accepts this number as a parameter (<code>n_outer_nodes</code>), which
should be tracked by the caller


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64, child_index: u64, n_outer_nodes: u64, direction: bool): (u128, &<b>mut</b> V, u64, u64, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64,
    child_index: u64,
    n_outer_nodes: u64,
    direction: bool
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64,
    V
) {
    // Mark start node's side <b>as</b> a child <b>as</b> left (<b>true</b>) <b>if</b> node's
    // parent <b>has</b> the node <b>as</b> its left child, <b>else</b> right (<b>false</b>)
    <b>let</b> start_child_side = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(
        &tree.inner_nodes, parent_index).left_child_index == child_index;
    // Store target node's pre-pop child field index
    <b>let</b> target_child_index = <a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>(
        tree, key, parent_index, direction);
    // Update relationships for popped start node
    <a href="critbit.md#0xc0deb00c_critbit_pop_update_relationships">pop_update_relationships</a>(tree, start_child_side, parent_index);
    // Store start node value from pop-facilitated node destruction
    <b>let</b> start_value =
        <a href="critbit.md#0xc0deb00c_critbit_pop_destroy_nodes">pop_destroy_nodes</a>(tree, parent_index, child_index, n_outer_nodes);
    // If target node was last in outer node <a href="">vector</a>, then swap
    // remove will have relocated it, so <b>update</b> its <b>post</b>-pop field
    // index <b>to</b> the start node's pre-pop field index
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(target_child_index) == n_outer_nodes - 1)
        target_child_index = child_index;
    // Borrow mutable reference <b>to</b> target node
    <b>let</b> target_node = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(
        &<b>mut</b> tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(target_child_index));
    // Return target node's key, mutable reference <b>to</b> its value, its
    // parent field, the child field index of it, and the start
    // node's popped value
    (target_node.key, &<b>mut</b> target_node.value, target_node.parent_index,
        target_child_index, start_value)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_end_pop"></a>

## Function `traverse_end_pop`

Terminate iterated traversal by popping the outer node for the
current iteration, without traversing further. Implements
similar algorithms as <code><a href="critbit.md#0xc0deb00c_critbit_pop_general">pop_general</a>()</code>, but without having to
do another search from root.


<a name="@Parameters_32"></a>

### Parameters

* <code>tree</code>: Crit-bit tree containing at least one node
* <code>parent_index</code>: Node's parent field
* <code>child_index</code>: Child field index of node
* <code>n_outer_node</code>: Number of outer nodes in <code>tree</code>


<a name="@Returns_33"></a>

### Returns

* <code>V</code>: Popped value from outer node


<a name="@Considerations_34"></a>

### Considerations

* Takes exposed node indices (<code>parent_index</code>, <code>child_index</code>) as
parameters
* Does not calculate number of outer nodes in <code>tree</code>, but rather
accepts this number as a parameter (<code>n_outer_nodes</code>), which
should be tracked by the caller and should be nonzero


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_end_pop">traverse_end_pop</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, parent_index: u64, child_index: u64, n_outer_nodes: u64): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_end_pop">traverse_end_pop</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    parent_index: u64,
    child_index: u64,
    n_outer_nodes: u64,
): V {
    <b>if</b> (n_outer_nodes == 1) { // If popping only node in tree
        tree.root = 0; // Update root
        // Pop off and unpack outer node at root
        <b>let</b> <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>{key: _, value, parent_index: _} =
            <a href="_pop_back">vector::pop_back</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes);
        value // Return popped value
    } <b>else</b> { // If popping from tree <b>with</b> more than 1 outer node
        // Mark node's side <b>as</b> a child <b>as</b> left (<b>true</b>) <b>if</b> node's
        // parent <b>has</b> the node <b>as</b> its left child, <b>else</b> right (<b>false</b>)
        <b>let</b> node_child_side = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes,
            parent_index).left_child_index == child_index;
        // Update sibling, parent, grandparent relationships
        <a href="critbit.md#0xc0deb00c_critbit_pop_update_relationships">pop_update_relationships</a>(tree, node_child_side, parent_index);
        // Destroy <b>old</b> nodes, returning popped value
        <a href="critbit.md#0xc0deb00c_critbit_pop_destroy_nodes">pop_destroy_nodes</a>(tree, parent_index, child_index, n_outer_nodes)
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_predecessor_init_mut"></a>

## Function `traverse_predecessor_init_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>()</code> call for predecessor traversal.
See [traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_init_mut">traverse_predecessor_init_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_init_mut">traverse_predecessor_init_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>(tree, <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_predecessor_mut"></a>

## Function `traverse_predecessor_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>()</code> call for predecessor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_mut">traverse_predecessor_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_mut">traverse_predecessor_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>&lt;V&gt;(tree, key, parent_index, <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_predecessor_pop_mut"></a>

## Function `traverse_predecessor_pop_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>()</code> call for predecessor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_pop_mut">traverse_predecessor_pop_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64, child_index: u64, n_outer_nodes: u64): (u128, &<b>mut</b> V, u64, u64, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_predecessor_pop_mut">traverse_predecessor_pop_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64,
    child_index: u64,
    n_outer_nodes: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64,
    V
) {
    <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>(tree, key, parent_index, child_index, n_outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_successor_init_mut"></a>

## Function `traverse_successor_init_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>()</code> call for successor traversal.
See [traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_successor_init_mut">traverse_successor_init_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_successor_init_mut">traverse_successor_init_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="critbit.md#0xc0deb00c_critbit_traverse_init_mut">traverse_init_mut</a>(tree, <a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_successor_mut"></a>

## Function `traverse_successor_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>()</code> call for successor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_successor_mut">traverse_successor_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_successor_mut">traverse_successor_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="critbit.md#0xc0deb00c_critbit_traverse_mut">traverse_mut</a>&lt;V&gt;(tree, key, parent_index, <a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_successor_pop_mut"></a>

## Function `traverse_successor_pop_mut`

Wrapped <code><a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>()</code> call for successor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_successor_pop_mut">traverse_successor_pop_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64, child_index: u64, n_outer_nodes: u64): (u128, &<b>mut</b> V, u64, u64, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_successor_pop_mut">traverse_successor_pop_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64,
    child_index: u64,
    n_outer_nodes: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64,
    V
) {
    <a href="critbit.md#0xc0deb00c_critbit_traverse_pop_mut">traverse_pop_mut</a>(tree, key, parent_index, child_index, n_outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_borrow_closest_outer_node"></a>

## Function `borrow_closest_outer_node`

Walk non-empty tree <code>tree</code>, breaking out if at outer node,
branching left or right at each inner node depending on whether
<code>key</code> is unset or set, respectively, at the given critical bit.
Then return mutable reference to the found outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node">borrow_closest_outer_node</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): &<a href="critbit.md#0xc0deb00c_critbit_OuterNode">critbit::OuterNode</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node">borrow_closest_outer_node</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
): &<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt; {
    // If root is an outer node, <b>return</b> reference <b>to</b> it
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(tree.root)) <b>return</b> (<a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(
        &tree.outer_nodes, <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(tree.root)));
    // Otherwise borrow inner node at root
    <b>let</b> node = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, tree.root);
    <b>loop</b> { // Loop over inner nodes
        // If key is set at critical bit, get index of child on R
        <b>let</b> child_index = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, node.critical_bit))
            // Otherwise L
            node.right_child_index <b>else</b> node.left_child_index;
        // If child is outer node, <b>return</b> reference <b>to</b> it
        <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_index)) <b>return</b>
            <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes,
                <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(child_index));
        // Borrow next inner node <b>to</b> review
        node = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, child_index);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_borrow_closest_outer_node_mut"></a>

## Function `borrow_closest_outer_node_mut`

Like <code><a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node">borrow_closest_outer_node</a>()</code>, but for mutable reference


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node_mut">borrow_closest_outer_node_mut</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_OuterNode">critbit::OuterNode</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_borrow_closest_outer_node_mut">borrow_closest_outer_node_mut</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
): &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt; {
    // If root is an outer node, <b>return</b> mutable reference <b>to</b> it
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(tree.root)) <b>return</b> (<a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(
        &<b>mut</b> tree.outer_nodes, <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(tree.root)));
    // Otherwise borrow inner node at root
    <b>let</b> node = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, tree.root);
    <b>loop</b> { // Loop over inner nodes
        // If key is set at critical bit, get index of child on R
        <b>let</b> child_index = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, node.critical_bit))
            // Otherwise L
            node.right_child_index <b>else</b> node.left_child_index;
        // If child is outer node, <b>return</b> mutable reference <b>to</b> it
        <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_index)) <b>return</b>
            <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
                <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(child_index));
        // Borrow next inner node <b>to</b> review
        node = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, child_index);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_check_length"></a>

## Function `check_length`

Assert that <code>length</code> is less than the value indicated by a
bitmask where only the 63rd bit is not set (this bitmask
corresponds to the maximum number of keys that can be stored in
a tree, since the 63rd bit is reserved for the node type bit
flag)


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_check_length">check_length</a>(length: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_check_length">check_length</a>(
    length: u64
) {
    <b>assert</b>!(<a href="critbit.md#0xc0deb00c_critbit_length">length</a> &lt; <a href="critbit.md#0xc0deb00c_critbit_HI_64">HI_64</a> ^ <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a> &lt;&lt; <a href="critbit.md#0xc0deb00c_critbit_NODE_TYPE">NODE_TYPE</a>, <a href="critbit.md#0xc0deb00c_critbit_E_INSERT_FULL">E_INSERT_FULL</a>);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_crit_bit"></a>

## Function `crit_bit`

Return the number of the most significant bit (0-indexed from
LSB) at which two non-identical bitstrings, <code>s1</code> and <code>s2</code>, vary.


<a name="@XOR/AND_method_35"></a>

### XOR/AND method


To begin with, a bitwise XOR is used to flag all differing bits:
```
>           s1: 11110001
>           s2: 11011100
>  x = s1 ^ s2: 00101101
>                 |- critical bit = 5
```
Here, the critical bit is equivalent to the bit number of the
most significant set bit in XOR result <code>x = s1 ^ s2</code>. At this
point, [Langley 2012](#References) notes that <code>x</code> bitwise AND
<code>x - 1</code> will be nonzero so long as <code>x</code> contains at least some
bits set which are of lesser significance than the critical bit:
```
>               x: 00101101
>           x - 1: 00101100
> x = x & (x - 1): 00101100
```
Thus he suggests repeating <code>x & (x - 1)</code> while the new result
<code>x = x & (x - 1)</code> is not equal to zero, because such a loop will
eventually reduce <code>x</code> to a power of two (excepting the trivial
case where <code>x</code> starts as all 0 except bit 0 set, for which the
loop never enters past the initial conditional check). Per this
method, using the new <code>x</code> value for the current example, the
second iteration proceeds as follows:
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
Now, <code>x & x - 1</code> will equal zero and the loop will not begin a
fourth iteration:
```
>             x: 00100000
>         x - 1: 00011111
> x AND (x - 1): 00000000
```
Thus after three iterations a corresponding critical bit bitmask
has been determined. However, in the case where the two input
strings vary at all bits of lesser significance than that of the
critical bit, there may be required as many as <code>k - 1</code>
iterations, where <code>k</code> is the number of bits in each string under
comparison. For instance, consider the case of the two 8-bit
strings <code>s1</code> and <code>s2</code> as follows:
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
Notably, this method is only suggested after already having
identified the varying byte between the two strings, thus
limiting <code>x & (x - 1)</code> operations to at most 7 iterations.


<a name="@Binary_search_method_36"></a>

### Binary search method


For the present implementation, strings are not partitioned into
a multi-byte array, rather, they are stored as <code>u128</code> integers,
so a binary search is instead proposed. Here, the same
<code>x = s1 ^ s2</code> operation is first used to identify all differing
bits, before iterating on an upper and lower bound for the
critical bit number:
```
>          s1: 10101010
>          s2: 01010101
> x = s1 ^ s2: 11111111
>       u = 7 -|      |- l = 0
```
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
```
>          x: 11111111
> s = x >> m: 00011111
```
<code>s &gt; 1</code>, so <code>l = m + 1 = 4</code>, and the search window has shrunk:
```
> x = s1 ^ s2: 11111111
>       u = 7 -|  |- l = 4
```
Updating the midpoint yields <code>m = (7 + 4) / 2 = 5</code>:
```
>          x: 11111111
> s = x >> m: 00000111
```
Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 6</code>, and the window
shrinks again:
```
> x = s1 ^ s2: 11111111
>       u = 7 -||- l = 6
> s = x >> m: 00000011
```
Again <code>s &gt; 1</code>, so update <code>l = m + 1 = 7</code>, the final iteration:
```
> x = s1 ^ s2: 11111111
>       u = 7 -|- l = 7
> s = x >> m: 00000001
```
Here, <code>s == 1</code>, which means that <code>c = m = 7</code>. Notably this
search has converged after only 3 iterations, as opposed to 7
for the linear search proposed above, and in general such a
search converges after $log_2(k)$ iterations at most, where $k$
is the number of bits in each of the strings <code>s1</code> and <code>s2</code> under
comparison. Hence this search method improves the $O(k)$ search
proposed by [Langley 2012](#References) to $O(log_2(k))$, and
moreover, determines the actual number of the critical bit,
rather than just a bitmask with bit <code>c</code> set, as he proposes,
which can also be easily generated via <code>1 &lt;&lt; c</code>.


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_crit_bit">crit_bit</a>(s1: u128, s2: u128): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_crit_bit">crit_bit</a>(
    s1: u128,
    s2: u128,
): u8 {
    <b>let</b> x = s1 ^ s2; // XOR result marked 1 at bits that differ
    <b>let</b> l = 0; // Lower bound on critical bit search
    <b>let</b> u = <a href="critbit.md#0xc0deb00c_critbit_MSB_u128">MSB_u128</a>; // Upper bound on critical bit search
    <b>loop</b> { // Begin binary search
        <b>let</b> m = (l + u) / 2; // Calculate midpoint of search window
        <b>let</b> s = x &gt;&gt; m; // Calculate midpoint shift of XOR result
        <b>if</b> (s == 1) <b>return</b> m; // If shift equals 1, c = m
        <b>if</b> (s &gt; 1) l = m + 1 <b>else</b> u = m - 1; // Update search bounds
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_above"></a>

## Function `insert_above`

Decomposed case specified in <code>insert_general</code>, walk up tree, for
parameters:
* <code>tree</code>: Tree to insert into
* <code>key</code> : Key to insert
* <code>value</code> : Value to insert
* <code>n_outer_nodes</code> : Number of outer nodes in <code>tree</code> pre-insert
* <code>n_inner_nodes</code> : Number of inner nodes in <code>tree</code> pre-insert
(index of new inner node)
* <code>search_parent_index</code>: Index of search parent
* <code>critical_bit</code>: Critical bit between insertion key and search
outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_above">insert_above</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V, n_outer_nodes: u64, n_inner_nodes: u64, search_parent_index: u64, critical_bit: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_above">insert_above</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V,
    n_outer_nodes: u64,
    n_inner_nodes: u64,
    search_parent_index: u64,
    critical_bit: u8
) {
    // Set index of node under review <b>to</b> search parent's parent
    <b>let</b> node_index = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes,
        search_parent_index).parent_index;
    <b>loop</b> { // Loop over inner nodes
        <b>if</b> (node_index == <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>) { // If walk arrives at root
            // Insert above root
            <b>return</b> <a href="critbit.md#0xc0deb00c_critbit_insert_above_root">insert_above_root</a>(tree, key, value, n_outer_nodes,
                n_inner_nodes, critical_bit)
        } <b>else</b> { // If walk <b>has</b> not arrived at root
            // Borrow mutable reference <b>to</b> node under review
            <b>let</b> node = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
                node_index);
            // If critical bit between insertion key and search
            // outer node is less than that of node under review
            <b>if</b> (critical_bit &lt; node.critical_bit) {
                // Insert below node under review
                <b>return</b> <a href="critbit.md#0xc0deb00c_critbit_insert_below_walk">insert_below_walk</a>(tree, key, value, n_outer_nodes,
                    n_inner_nodes, node_index, critical_bit)
            } <b>else</b> { // If need <b>to</b> insert above
                // Review node under review's parent
                node_index = node.parent_index;
            }
        }
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_above_root"></a>

## Function `insert_above_root`

Decomposed case specified in <code>insert_general</code>, insertion above
root, for parameters:
* <code>tree</code>: Tree to insert into
* <code>key</code> : Key to insert
* <code>value</code> : Value to insert
* <code>n_outer_nodes</code> : Number of keys (outer nodes) in <code>tree</code>
pre-insert
* <code>n_inner_nodes</code> : Number of inner nodes in <code>tree</code> pre-insert
(index of new inner node)
* <code>critical_bit</code>: Critical bit between insertion key and search
outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_above_root">insert_above_root</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V, n_outer_nodes: u64, n_inner_nodes: u64, critical_bit: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_above_root">insert_above_root</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V,
    n_outer_nodes: u64,
    n_inner_nodes: u64,
    critical_bit: u8
) {
    // Get index of <b>old</b> root <b>to</b> insert above
    <b>let</b> old_root_index = tree.root;
    // Set <b>old</b> root node <b>to</b> have new inner node <b>as</b> parent
    <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
        old_root_index).parent_index = n_inner_nodes;
    // Set root field index <b>to</b> indicate new inner node
    tree.root = n_inner_nodes;
    // Push back new inner and outer nodes, <b>with</b> inner node
    // indicating that it is root. If insertion key is set at
    // critical bit, new inner node should have <b>as</b> its left child
    // the previous root node and should have <b>as</b> its right child
    // the new outer node
    <a href="critbit.md#0xc0deb00c_critbit_push_back_insert_nodes">push_back_insert_nodes</a>(
        tree, key, value, n_inner_nodes, critical_bit, <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>,
        <a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, critical_bit), old_root_index,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(n_outer_nodes));
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_below"></a>

## Function `insert_below`

Decomposed case specified in <code>insert_general</code>, insertion below
search parent, for parameters:
* <code>tree</code>: Tree to insert into
* <code>key</code> : Key to insert
* <code>value</code> : Value to insert
* <code>n_outer_nodes</code> : Number of keys (outer nodes) in <code>tree</code>
pre-insert
* <code>n_inner_nodes</code> : Number of inner nodes in <code>tree</code> pre-insert
(index of new inner node)
* <code>search_index</code>: Child field index of search outer node (with
bit flag)
* <code>search_child_side</code>: Side on which search outer node is child
* <code>search_key</code>: Key of search outer node
* <code>search_parent_index</code>: Index of search parent
* <code>critical_bit</code>: Critical bit between insertion key and search
outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_below">insert_below</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V, n_outer_nodes: u64, n_inner_nodes: u64, search_index: u64, search_child_side: bool, search_key: u128, search_parent_index: u64, critical_bit: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_below">insert_below</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V,
    n_outer_nodes: u64,
    n_inner_nodes: u64,
    search_index: u64,
    search_child_side: bool,
    search_key: u128,
    search_parent_index: u64,
    critical_bit: u8
) {
    // Borrow mutable reference <b>to</b> search parent
    <b>let</b> search_parent = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(
        &<b>mut</b> tree.inner_nodes, search_parent_index);
    // Update search parent <b>to</b> have new inner node <b>as</b> child, on same
    // side that the search outer node was a child at
    <b>if</b> (search_child_side == <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>) search_parent.left_child_index =
        n_inner_nodes <b>else</b> search_parent.right_child_index = n_inner_nodes;
    // Set search outer node <b>to</b> have new inner node <b>as</b> parent
    <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(search_index)).parent_index =
            n_inner_nodes;
    // Push back new inner and outer nodes, <b>with</b> inner node having
    // <b>as</b> its parent the search parent. If insertion key is less
    // than key of search outer node, new inner node should have <b>as</b>
    // its left child the new outer node and should have <b>as</b> its
    // right child the search outer node
    <a href="critbit.md#0xc0deb00c_critbit_push_back_insert_nodes">push_back_insert_nodes</a>(tree, key, value, n_inner_nodes, critical_bit,
        search_parent_index, key &lt; search_key,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(n_outer_nodes), search_index);
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_below_walk"></a>

## Function `insert_below_walk`

Decomposed case specified in <code>insert_general</code>, insertion below
a node encountered during walk, for parameters:
* <code>tree</code>: Tree to insert into
* <code>key</code> : Key to insert
* <code>value</code> : Value to insert
* <code>n_outer_nodes</code> : Number of keys (outer nodes) in <code>tree</code> pre-insert
* <code>n_inner_nodes</code> : Number of inner nodes in <code>tree</code> pre-insert
(index of new inner node)
* <code>review_node_index</code> : Index of node under review from walk
* <code>critical_bit</code>: Critical bit between insertion key and search
outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_below_walk">insert_below_walk</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V, n_outer_nodes: u64, n_inner_nodes: u64, review_node_index: u64, critical_bit: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_below_walk">insert_below_walk</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V,
    n_outer_nodes: u64,
    n_inner_nodes: u64,
    review_node_index: u64,
    critical_bit: u8
) {
    // Borrow mutable reference <b>to</b> node under review
    <b>let</b> review_node = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
        review_node_index);
    // If insertion key is set at critical bit indicated by node
    // under review, mark side and index of walked child <b>as</b> its
    // right child, <b>else</b> left
    <b>let</b> (walked_child_side, walked_child_index) =
        <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, review_node.critical_bit))
            (<a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a>, review_node.right_child_index) <b>else</b>
            (<a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>, review_node.left_child_index);
    // Set node under review <b>to</b> have <b>as</b> child new inner node on same
    // side <b>as</b> walked child
    <b>if</b> (walked_child_side == <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>)
        review_node.left_child_index = n_inner_nodes <b>else</b>
        review_node.right_child_index = n_inner_nodes;
    // Update walked child <b>to</b> have new inner node <b>as</b> its parent
    <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
        walked_child_index).parent_index = n_inner_nodes;
    // Push back new inner and outer nodes, <b>with</b> inner node having
    // <b>as</b> its parent the node under review. If insertion key is set
    // at critical bit, new inner node should have <b>as</b> its left child
    // the walked child of the node under review and should have <b>as</b>
    // its right child the new outer node
    <a href="critbit.md#0xc0deb00c_critbit_push_back_insert_nodes">push_back_insert_nodes</a>(tree, key, value, n_inner_nodes, critical_bit,
        review_node_index, <a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, critical_bit), walked_child_index,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(n_outer_nodes));
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_empty"></a>

## Function `insert_empty`

Insert key-value pair <code>key</code> and <code>value</code> into an empty <code>tree</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_empty">insert_empty</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_empty">insert_empty</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V
) {
    // Push back outer node onto tree's <a href="">vector</a> of outer nodes
    <a href="_push_back">vector::push_back</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;{key, value, parent_index: <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>});
    // Set root index field <b>to</b> indicate 0th outer node
    tree.root = <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a> &lt;&lt; <a href="critbit.md#0xc0deb00c_critbit_NODE_TYPE">NODE_TYPE</a>;
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_general"></a>

## Function `insert_general`

Insert <code>key</code> and <code>value</code> into <code>tree</code> already having
<code>n_outer_nodes</code> keys for general case where root is an inner
node, aborting if <code>key</code> is already present. First, perform an
outer node search and identify the critical bit of divergence
between the search outer node and <code>k</code>. Then, if the critical bit
is less than that of the search parent (<code><a href="critbit.md#0xc0deb00c_critbit_insert_below">insert_below</a>()</code>):

* Insert a new inner node directly above the search outer node
* Update the search outer node to have as its parent the new
inner node
* Update the search parent to have as its child the new inner
node where the search outer node previously was:
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
Otherwise, begin walking back up the tree (<code><a href="critbit.md#0xc0deb00c_critbit_insert_above">insert_above</a>()</code>). If
walk arrives at the root node, insert a new inner node above the
root, updating associated relationships (<code><a href="critbit.md#0xc0deb00c_critbit_insert_above_root">insert_above_root</a>()</code>):
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
Otherwise, if walk arrives at a node indicating a critical bit
larger than that between the insertion key and the search node,
insert the new inner node below it (<code><a href="critbit.md#0xc0deb00c_critbit_insert_below_walk">insert_below_walk</a>()</code>):
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


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_general">insert_general</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V, n_outer_nodes: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_general">insert_general</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V,
    n_outer_nodes: u64
) {
    // Get number of inner nodes in tree (index of new inner node)
    <b>let</b> n_inner_nodes = <a href="_length">vector::length</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes);
    // Get field index of search outer node, its side <b>as</b> a child,
    // its key, the <a href="">vector</a> index of its parent, and the critical
    // bit indicated by the search parent
    <b>let</b> (search_index, search_child_side, search_key, search_parent_index,
        search_parent_critical_bit) = <a href="critbit.md#0xc0deb00c_critbit_search_outer">search_outer</a>(tree, key);
    // Assert key not already in tree
    <b>assert</b>!(search_key != key, <a href="critbit.md#0xc0deb00c_critbit_E_HAS_KEY">E_HAS_KEY</a>);
    // Get critical bit between insertion key and search outer node
    <b>let</b> critical_bit = <a href="critbit.md#0xc0deb00c_critbit_crit_bit">crit_bit</a>(search_key, key);
    // If critical bit is less than that indicated by search parent
    <b>if</b> (critical_bit &lt; search_parent_critical_bit) {
        // Insert new inner node below search parent
        <a href="critbit.md#0xc0deb00c_critbit_insert_below">insert_below</a>(tree, key, value, n_outer_nodes, n_inner_nodes,
            search_index, search_child_side, search_key,
            search_parent_index, critical_bit);
    } <b>else</b> { // If need <b>to</b> insert new inner node above search parent
        <a href="critbit.md#0xc0deb00c_critbit_insert_above">insert_above</a>(tree, key, value, n_outer_nodes, n_inner_nodes,
            search_parent_index, critical_bit);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_insert_singleton"></a>

## Function `insert_singleton`

Insert <code>key</code> and <code>value</code> into singleton <code>tree</code>, aborting if
<code>key</code> already in <code>tree</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_singleton">insert_singleton</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_insert_singleton">insert_singleton</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V
) {
    // Borrow existing outer node
    <b>let</b> outer_node = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes, 0);
    // Assert insertion key not in tree
    <b>assert</b>!(key != outer_node.key, <a href="critbit.md#0xc0deb00c_critbit_E_HAS_KEY">E_HAS_KEY</a>);
    // Get critical bit between two keys
    <b>let</b> critical_bit = <a href="critbit.md#0xc0deb00c_critbit_crit_bit">crit_bit</a>(outer_node.key, key);
    // Push back new inner and outer nodes, <b>with</b> inner node
    // indicating that it is root. If insertion key is greater than
    // singleton key, new inner node should have <b>as</b> its left child
    // existing outer node and should have <b>as</b> its right child new
    // outer node
    <a href="critbit.md#0xc0deb00c_critbit_push_back_insert_nodes">push_back_insert_nodes</a>(tree, key, value, 0, critical_bit, <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>,
        key &gt; outer_node.key, <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(0),
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(1));
    // Update tree root field <b>to</b> indicate new inner node
    tree.root = 0;
    // Update existing outer node <b>to</b> have new inner node <b>as</b> parent
    <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
        0).parent_index = 0;
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_max_node_child_index"></a>

## Function `max_node_child_index`

Return the child field index of the outer node containing the
maximum key in non-empty tree <code>tree</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_max_node_child_index">max_node_child_index</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_max_node_child_index">max_node_child_index</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;
): u64 {
    // Initialize child field index of search node <b>to</b> root
    <b>let</b> child_field_index = tree.root;
    <b>loop</b> { // Loop over nodes
        // If search node is outer node <b>return</b> its child field index
        <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_field_index)) <b>return</b> child_field_index;
        // Review node's right child next
        child_field_index = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes,
            child_field_index).right_child_index
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_min_node_child_index"></a>

## Function `min_node_child_index`

Return the child field index of the outer node containing the
minimum key in non-empty tree <code>tree</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_min_node_child_index">min_node_child_index</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_min_node_child_index">min_node_child_index</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;
): u64 {
    // Initialize child field index of search node <b>to</b> root
    <b>let</b> child_field_index = tree.root;
    <b>loop</b> { // Loop over nodes
        // If search node is outer node <b>return</b> its child field index
        <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_field_index)) <b>return</b> child_field_index;
        // Review node's left child next
        child_field_index = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes,
            child_field_index).left_child_index
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_is_outer_node"></a>

## Function `is_outer_node`

Return <code><b>true</b></code> if <code>child_field_index</code> indicates an outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_field_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(
    child_field_index: u64
): bool {
    (child_field_index &gt;&gt; <a href="critbit.md#0xc0deb00c_critbit_NODE_TYPE">NODE_TYPE</a> & <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a> == <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_is_set"></a>

## Function `is_set`

Return <code><b>true</b></code> if <code>key</code> is set at <code>bit_number</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key: u128, bit_number: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key: u128, bit_number: u8): bool {key &gt;&gt; bit_number & 1 == 1}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_outer_node_child_index"></a>

## Function `outer_node_child_index`

Convert unflagged outer node <code>vector_index</code> to flagged child
field index, by <code>OR</code> with a bitmask that has only a flag bit set


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(vector_index: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(
    vector_index: u64
): u64 {
    vector_index | <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a> &lt;&lt; <a href="critbit.md#0xc0deb00c_critbit_NODE_TYPE">NODE_TYPE</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_outer_node_vector_index"></a>

## Function `outer_node_vector_index`

Convert flagged <code>child_field_index</code> to unflagged outer node
vector index, by <code>AND</code> with a bitmask that has only flag bit
unset


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(child_field_index: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(
    child_field_index: u64
): u64 {
    child_field_index & <a href="critbit.md#0xc0deb00c_critbit_HI_64">HI_64</a> ^ <a href="critbit.md#0xc0deb00c_critbit_OUTER">OUTER</a> &lt;&lt; <a href="critbit.md#0xc0deb00c_critbit_NODE_TYPE">NODE_TYPE</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_pop_destroy_nodes"></a>

## Function `pop_destroy_nodes`

Remove from <code>tree</code> inner node at child field index
<code>inner_index</code>, and outer node at child field index <code>outer_index</code>
(from node vector with <code>n_outer_nodes</code> outer nodes pre-pop).
Then return the popped value from the outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_destroy_nodes">pop_destroy_nodes</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, inner_index: u64, outer_index: u64, n_outer_nodes: u64): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_destroy_nodes">pop_destroy_nodes</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    inner_index: u64,
    outer_index: u64,
    n_outer_nodes: u64
): V {
    // Get number of inner nodes pre-pop
    <b>let</b> n_inner_nodes = <a href="_length">vector::length</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes);
    // Swap remove parent of popped outer node, storing no fields
    <b>let</b> <a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>{critical_bit: _, parent_index: _, left_child_index: _,
        right_child_index: _} = <a href="_swap_remove">vector::swap_remove</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(
            &<b>mut</b> tree.inner_nodes, inner_index);
    // If destroyed inner node was not last inner node in <a href="">vector</a>,
    // repair the parent-child relationship broken by swap remove
    <b>if</b> (inner_index &lt; n_inner_nodes - 1)
        <a href="critbit.md#0xc0deb00c_critbit_stitch_swap_remove">stitch_swap_remove</a>(tree, inner_index, n_inner_nodes);
    // Swap remove popped outer node, storing only its value
    <b>let</b> <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>{key: _, value, parent_index: _} =
        <a href="_swap_remove">vector::swap_remove</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
            <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(outer_index));
    // If destroyed outer node was not last outer node in <a href="">vector</a>,
    // repair the parent-child relationship broken by swap remove
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(outer_index) &lt; n_outer_nodes - 1)
        <a href="critbit.md#0xc0deb00c_critbit_stitch_swap_remove">stitch_swap_remove</a>(tree, outer_index, n_outer_nodes);
    value // Return popped value
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_pop_general"></a>

## Function `pop_general`

Return the value corresponding to <code>key</code> in <code>tree</code> having
<code>n_outer_nodes</code> keys and destroy the outer node where it was
stored, for the general case of a tree with more than one outer
node. Abort if <code>key</code> not in <code>tree</code>.

Here, the parent of the popped node must be removed, and if the
popped node has a grandparent, the grandparent of the popped
node must be updated to have as its child the popped node's
sibling at the same position where the popped node's parent
previously was, whether the sibling is an outer or inner node.
Likewise the sibling must be updated to have as its parent the
grandparent to the popped node. Outer node sibling case:
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
If the popped node does not have a grandparent (if its parent is
the root node), then the root node must be removed and the
popped node's sibling must become the new root, whether the
sibling is an inner or outer node. Likewise the sibling must be
updated to indicate that it is the root. Inner node sibling
case:
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


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_general">pop_general</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, n_outer_nodes: u64): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_general">pop_general</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    n_outer_nodes: u64
): V {
    // Get field index of search outer node, its side <b>as</b> a child,
    // its key, and the <a href="">vector</a> index of its parent
    <b>let</b> (search_index, search_child_side, search_key, search_parent_index,
        _) = <a href="critbit.md#0xc0deb00c_critbit_search_outer">search_outer</a>(tree, key);
    <b>assert</b>!(search_key == key, <a href="critbit.md#0xc0deb00c_critbit_E_NOT_HAS_KEY">E_NOT_HAS_KEY</a>); // Assert key in tree
    // Update sibling, parent, grandparent relationships
    <a href="critbit.md#0xc0deb00c_critbit_pop_update_relationships">pop_update_relationships</a>(tree, search_child_side, search_parent_index);
    // Destroy <b>old</b> nodes, returning popped value
    <a href="critbit.md#0xc0deb00c_critbit_pop_destroy_nodes">pop_destroy_nodes</a>(tree, search_parent_index, search_index,
        n_outer_nodes)
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_pop_singleton"></a>

## Function `pop_singleton`

Return the value corresponding to <code>key</code> in singleton <code>tree</code> and
destroy the outer node where it was stored, aborting if <code>key</code>
not in <code>tree</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_singleton">pop_singleton</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_singleton">pop_singleton</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128
): V {
    <b>assert</b>!(<a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes, 0).key == key,
        <a href="critbit.md#0xc0deb00c_critbit_E_NOT_HAS_KEY">E_NOT_HAS_KEY</a>); // Assert key actually in tree at root node
    tree.root = 0; // Update root
    // Pop off and unpack outer node at root
    <b>let</b> <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>{key: _, value, parent_index: _} =
        <a href="_pop_back">vector::pop_back</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes);
    value // Return popped value
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_pop_update_relationships"></a>

## Function `pop_update_relationships`

Update relationships in <code>tree</code> for popping a node which is a
child on side <code>child_side</code> (<code><a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a></code> or <code><a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a></code>), to parent node
at index <code>parent_index</code>, per <code><a href="critbit.md#0xc0deb00c_critbit_pop_general">pop_general</a>()</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_update_relationships">pop_update_relationships</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, child_side: bool, parent_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_pop_update_relationships">pop_update_relationships</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    child_side: bool,
    parent_index: u64,
) {
    // Borrow immutable reference <b>to</b> popped node's parent
    <b>let</b> parent = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes,
        parent_index);
    // If popped outer node was a left child, store the right child
    // field index of its parent <b>as</b> the child field index of the
    // popped node's sibling. Else flip the direction
    <b>let</b> sibling_index = <b>if</b> (child_side == <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>) parent.right_child_index
        <b>else</b> parent.left_child_index;
    // Get parent field index of popped node's parent
    <b>let</b> grandparent_index = parent.parent_index;
    // Update popped node's sibling <b>to</b> have at its parent index
    // field the same <b>as</b> that of the popped node's parent, whether
    // the sibling is an inner or outer node
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(sibling_index))
        <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
            <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(sibling_index)).parent_index =
                grandparent_index
        <b>else</b> <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
            sibling_index).parent_index = grandparent_index;
    // If popped node's parent is root
    <b>if</b> (grandparent_index == <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>) {
        // Set root field index <b>to</b> child field index of popped
        // node's sibling
        tree.root = sibling_index;
    } <b>else</b> { // If popped node <b>has</b> a grandparent
        // Borrow mutable reference <b>to</b> popped node's grandparent
        <b>let</b> grandparent = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(
            &<b>mut</b> tree.inner_nodes, grandparent_index);
        // If popped node's parent was a left child, <b>update</b> popped
        // node's grandparent <b>to</b> have <b>as</b> its child the popped node's
        // sibling. Else the right child
        <b>if</b> (grandparent.left_child_index == parent_index)
            grandparent.left_child_index = sibling_index <b>else</b>
            grandparent.right_child_index = sibling_index;
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_push_back_insert_nodes"></a>

## Function `push_back_insert_nodes`

Push back a new inner node and outer node into <code>tree</code>, where the
new outer node should have key <code>key</code>, value <code>value</code>, and have as
its parent the new inner node at vector index <code>inner_index</code>,
which should have critical bit <code>critical_bit</code>, parent field
index <code>parent_index</code>, and if <code>child_polarity</code> is <code><b>true</b></code>, left
child field index <code>child_index_1</code> and right child field index
<code>child_index_2</code>. If <code>child_polarity</code> is <code><b>false</b></code> the polarity of
the children should be flipped


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_push_back_insert_nodes">push_back_insert_nodes</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, value: V, inner_index: u64, critical_bit: u8, parent_index: u64, child_polarity: bool, child_index_1: u64, child_index_2: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_push_back_insert_nodes">push_back_insert_nodes</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    value: V,
    inner_index: u64,
    critical_bit: u8,
    parent_index: u64,
    child_polarity: bool,
    child_index_1: u64,
    child_index_2: u64,
) {
    // If child polarity marked <b>true</b>, declare left child field for
    // new inner node <b>as</b> child_index_1 and right <b>as</b> child_index_2
    <b>let</b> (left_child_index, right_child_index) = <b>if</b> (child_polarity)
        (child_index_1, child_index_2) <b>else</b> // Otherwise flipped
        (child_index_2, child_index_1);
    // Push back new outer node <b>with</b> new inner node <b>as</b> parent
    <a href="_push_back">vector::push_back</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&<b>mut</b> tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>{key, value, parent_index: inner_index});
    // Push back new inner node <b>with</b> specified parent and children
    <a href="_push_back">vector::push_back</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>{critical_bit, parent_index, left_child_index,
            right_child_index});
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_search_outer"></a>

## Function `search_outer`

Walk from root in a <code>tree</code> having an inner node as its root,
branching left or right at each inner node depending on whether
<code>key</code> is unset or set, respectively, at the given critical bit.
After arriving at an outer node, then return:
* <code>u64</code>: Child field index of search outer node (with node type
bit flag)
* <code>bool</code>: The side, <code><a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a></code> or <code><a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a></code>, on which the search outer
node is a child of its parent
* <code>u128</code>: Key of search outer node
* <code>u64</code>: Vector index of parent of search outer node
* <code>u8</code>: Critical bit indicated by parent of search outer node


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_search_outer">search_outer</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128): (u64, bool, u128, u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_search_outer">search_outer</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128
): (
    u64,
    bool,
    u128,
    u64,
    u8,
) {
    // Initialize search parent <b>to</b> root
    <b>let</b> parent = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, tree.root);
    <b>loop</b> { // Loop over inner nodes until branching <b>to</b> outer node
        // If key set at critical bit, track field index and side of
        // right child, <b>else</b> left child
        <b>let</b> (index, side) = <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, parent.critical_bit))
            (parent.right_child_index, <a href="critbit.md#0xc0deb00c_critbit_RIGHT">RIGHT</a>) <b>else</b>
            (parent.left_child_index, <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>);
        <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(index)) { // If child is outer node
            // Borrow immutable reference <b>to</b> it
            <b>let</b> node = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes,
                <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(index));
            // Return child field index of search outer node, its
            // side <b>as</b> a child, its key, the <a href="">vector</a> index of its
            // parent, and parent's indicated critical bit
            <b>return</b> (index, side, node.key, node.parent_index,
                parent.critical_bit)
        };
        // Search next inner node
        parent = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, index);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_stitch_child_of_parent"></a>

## Function `stitch_child_of_parent`

Update parent node at index <code>parent_index</code> in <code>tree</code> to reflect
as its child a node that has been relocated from old child field
index <code>old_index</code> to new child field index <code>new_index</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, new_index: u64, parent_index: u64, old_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    new_index: u64,
    parent_index: u64,
    old_index: u64
) {
    <b>let</b> parent = <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
        parent_index); // Borrow mutable reference <b>to</b> parent
    // If relocated node was previously left child, <b>update</b>
    // parent's left child <b>to</b> indicate the relocated node's new
    // position, otherwise do <b>update</b> for right child of parent
    <b>if</b> (parent.left_child_index == old_index) parent.left_child_index =
        new_index <b>else</b> parent.right_child_index = new_index;
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_stitch_parent_of_child"></a>

## Function `stitch_parent_of_child`

Update child node at child field index <code>child_index</code> in <code>tree</code>
to reflect as its parent an inner node that has be relocated to
child field index <code>new_index</code>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_stitch_parent_of_child">stitch_parent_of_child</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, new_index: u64, child_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_stitch_parent_of_child">stitch_parent_of_child</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    new_index: u64,
    child_index: u64
) {
    // If child is an outer node, borrow corresponding node and
    // <b>update</b> its parent field index <b>to</b> that of relocated node
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_index)) <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(
        &<b>mut</b> tree.outer_nodes, <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(child_index)
            ).parent_index = new_index <b>else</b>
        // Otherwise perform <b>update</b> on an inner node
        <a href="_borrow_mut">vector::borrow_mut</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&<b>mut</b> tree.inner_nodes,
            child_index).parent_index = new_index;
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_stitch_swap_remove"></a>

## Function `stitch_swap_remove`

Repair a broken parent-child relationship in <code>tree</code> caused by
swap removing, for relocated node now at index indicated by
child field index <code>node_index</code>, in vector that contained
<code>n_nodes</code> nodes before the swap remove (when relocated node was
last in vector)


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_stitch_swap_remove">stitch_swap_remove</a>&lt;V&gt;(tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, node_index: u64, n_nodes: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_stitch_swap_remove">stitch_swap_remove</a>&lt;V&gt;(
    tree: &<b>mut</b> <a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    node_index: u64,
    n_nodes: u64
) {
    // If child field index indicates relocated outer node
    <b>if</b> (<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(node_index)) {
        // Get node's parent field index
        <b>let</b> parent_index = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_OuterNode">OuterNode</a>&lt;V&gt;&gt;(&tree.outer_nodes,
        <a href="critbit.md#0xc0deb00c_critbit_outer_node_vector_index">outer_node_vector_index</a>(node_index)).parent_index;
        // If root node was relocated, <b>update</b> root field and <b>return</b>
        <b>if</b> (parent_index == <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>) {tree.root = node_index; <b>return</b>};
        // Else <b>update</b> parent <b>to</b> reflect relocated node position
        <a href="critbit.md#0xc0deb00c_critbit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(tree, node_index, parent_index,
            <a href="critbit.md#0xc0deb00c_critbit_outer_node_child_index">outer_node_child_index</a>(n_nodes - 1));
    } <b>else</b> { // If child field index indicates relocated inner node
        // Borrow mutable reference <b>to</b> it
        <b>let</b> node =
            <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, node_index);
        // Get field index of node's parent and children
        <b>let</b> (parent_index, left_child_index, right_child_index) =
            (node.parent_index, node.left_child_index,
                node.right_child_index);
        // Update left child <b>to</b> have relocated node <b>as</b> parent
        <a href="critbit.md#0xc0deb00c_critbit_stitch_parent_of_child">stitch_parent_of_child</a>(tree, node_index, left_child_index);
        // Update right child <b>to</b> have relocated node <b>as</b> parent
        <a href="critbit.md#0xc0deb00c_critbit_stitch_parent_of_child">stitch_parent_of_child</a>(tree, node_index, right_child_index);
        // If root node relocated, <b>update</b> root field and <b>return</b>
        <b>if</b> (parent_index == <a href="critbit.md#0xc0deb00c_critbit_ROOT">ROOT</a>) {tree.root = node_index; <b>return</b>};
        // Else <b>update</b> parent <b>to</b> reflect relocated node position
        <a href="critbit.md#0xc0deb00c_critbit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(
            tree, node_index, parent_index, n_nodes - 1);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_critbit_traverse_target_child_index"></a>

## Function `traverse_target_child_index`

Traverse in the specified direction from the node containing the
specified key (the "start node" containing the "start key") to
either the inorder predecessor or the inorder successor to the
start key (the "target node" containing the "target key"), then
return the child field index of the target node. See
[traversal](#Traversal)


<a name="@Method_(predecessor)_37"></a>

### Method (predecessor)

1. Walk up from start node until arriving at an inner node that
has the start key as the minimum key in its right subtree
(the "apex node"): walk up until arriving at a parent that
has the last walked node as its right child
2. Walk to maximum key in apex node's left subtree, breaking out
at target node (the first outer node): walk to apex node's
left child, then walk along right children


<a name="@Method_(successor)_38"></a>

### Method (successor)

1. Walk up from start node until arriving at an inner node that
has the start key as the maximum key in its left subtree
(the "apex node"): walk up until arriving at a parent that
has the last walked node as its left child
2. Walk to minimum key in apex node's right subtree, breaking
out at target node (the first outer node): walk to apex
node's right child, then walk along left children


<a name="@Parameters_39"></a>

### Parameters

* <code>tree</code>: Crit-bit tree containing at least two nodes
* <code>key</code>: Start key. If predecessor traversal, <code>key</code> cannot be
minimum key in <code>tree</code>, since this key does not have a
predecessor. Likewise, if successor traversal, <code>key</code> cannot be
maximum key in <code>tree</code>, since this key does not have a
successor
* <code>parent_index</code>: Start node's parent field
* <code>direction</code>: Direction to traverse. If <code><a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a></code>, predecessor
traversal, else successor traversal


<a name="@Returns_40"></a>

### Returns

* <code>u64</code>: Child field index of target node


<a name="@Considerations_41"></a>

### Considerations

* Assumes passed start key is not minimum key in tree if
predecessor traversal, and that passed start key is not
maximum key in tree if successor traversal
* Takes an exposed vector index (<code>parent_index</code>) as a parameter


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>&lt;V&gt;(tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">critbit::CritBitTree</a>&lt;V&gt;, key: u128, parent_index: u64, direction: bool): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="critbit.md#0xc0deb00c_critbit_traverse_target_child_index">traverse_target_child_index</a>&lt;V&gt;(
    tree: &<a href="critbit.md#0xc0deb00c_critbit_CritBitTree">CritBitTree</a>&lt;V&gt;,
    key: u128,
    parent_index: u64,
    direction: bool,
): u64 {
    // Borrow immutable reference <b>to</b> start node's parent
    <b>let</b> parent =
        <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes, parent_index);
    // If start key is set at parent node's critical bit, then the
    // upward walk <b>has</b> reach an inner node via its right child. This
    // is the <b>break</b> condition for successor traversal (when
    // `direction` is `<a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>`) a constant value that evaluates <b>to</b>
    // `<b>true</b>`. The inverse case applies for predecessor traversal,
    // so <b>continue</b> upward walk <b>as</b> long <b>as</b> `direction` is not equal
    // <b>to</b> the conditional <a href="critbit.md#0xc0deb00c_critbit">critbit</a> check
    <b>while</b> (direction != <a href="critbit.md#0xc0deb00c_critbit_is_set">is_set</a>(key, parent.critical_bit)) {
        // Borrow immutable reference <b>to</b> next parent in upward walk
        parent = <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(&tree.inner_nodes,
            parent.parent_index);
    }; // Now at apex node
    // If predecessor traversal get left child field of apex node,
    <b>let</b> child_index = <b>if</b> (direction == <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>) parent.left_child_index <b>else</b>
        parent.right_child_index; // Otherwise right child field
    // While child field indicates inner node
    <b>while</b> (!<a href="critbit.md#0xc0deb00c_critbit_is_outer_node">is_outer_node</a>(child_index)) {
        // If predecessor traversal review child's right child next,
        // <b>else</b> review child's left child next
        child_index = <b>if</b> (direction == <a href="critbit.md#0xc0deb00c_critbit_LEFT">LEFT</a>) <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(
            &tree.inner_nodes, child_index).right_child_index <b>else</b>
                <a href="_borrow">vector::borrow</a>&lt;<a href="critbit.md#0xc0deb00c_critbit_InnerNode">InnerNode</a>&gt;(
                    &tree.inner_nodes, child_index).left_child_index;
    }; // Child field now indicates target node
    child_index // Return child field index of target node
}
</code></pre>



</details>
