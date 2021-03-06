
<a name="0xc0deb00c_CritBit"></a>

# Module `0xc0deb00c::CritBit`


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
inner (<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a></code>) and outer (<code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a></code>). Inner nodes have two children each
(<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.l</code> and <code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.r</code>), while outer nodes have no children. There are no
nodes that have exactly one child. Outer nodes store a key-value
pair with a 128-bit integer as a key (<code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>.k</code>), and an arbitrary value
of generic type (<code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>.v</code>). Inner nodes do not store a key, but rather,
an 8-bit integer (<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.c</code>) indicating the most-significant critical
bit (crit-bit) of divergence between keys located within the node's
two subtrees: keys in the node's left subtree are unset at the
critical bit, while keys in the node's right subtree are set at the
critical bit. Both node types have a parent (<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.p</code>, <code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>.p</code>), which
may be flagged as <code><a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a></code> if the the node is the root.

Bit numbers are 0-indexed starting at the least-significant bit
(LSB), such that a critical bit of 3, for instance, corresponds to a
comparison between <code>00...00000</code> and <code>00...01111</code>. Inner nodes are
arranged hierarchically, with the most significant critical bits at
the top of the tree. For instance, the keys <code>001</code>, <code>101</code>, <code>110</code>, and
<code>111</code> would be stored in a crit-bit tree as follows (right carets
included at left of illustration per issue with documentation build
engine, namely, the automatic stripping of leading whitespace in
documentation comments, which prohibits the simple initiation of
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


Both inner nodes (<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a></code>) and outer nodes (<code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a></code>) are stored in vectors
(<code><a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>.i</code> and <code><a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>.o</code>), and parent-child relationships between nodes
are described in terms of vector indices: an outer node indicating
<code>123</code> in its parent field (<code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>.p</code>), for instance, has as its parent
an inner node at vector index <code>123</code>. Notably, the vector index of an
inner node is identical to the number indicated by its child's
parent field (<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.p</code> or <code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>.p</code>), but the vector index of an outer node
is **not** identical to the number indicated by its parent's child
field (<code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.l</code> or <code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>.r</code>), because the 63rd bit of a so-called "field
index" (the number stored in a struct field) is reserved for a node
type bit flag, with outer nodes having bit 63 set and inner nodes
having bit 63 unset. This schema enables discrimination between node
types based solely on the "field index" of a related node via
<code><a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>()</code>, but requires that outer node indices be routinely
converted between "child field index" form and "vector index" form
via <code><a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>()</code> and <code><a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>()</code>.

Similarly, if a node, inner or outer, is located at the root, its
"parent field index" will indicate <code><a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a></code>, and will not correspond
to the vector index of any inner node, since the root node does not
have a parent. Likewise, the "root field" of the tree (<code><a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>.r</code>) will
contain the field index of the given node, set at bit 63 if the root
is an outer node.


<a name="@Basic_public_functions_6"></a>

## Basic public functions



<a name="@Initialization_7"></a>

### Initialization

* <code><a href="CritBit.md#0xc0deb00c_CritBit_empty">empty</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_singleton">singleton</a>()</code>


<a name="@Mutation_8"></a>

### Mutation

* <code><a href="CritBit.md#0xc0deb00c_CritBit_borrow_mut">borrow_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_insert">insert</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_pop">pop</a>()</code>


<a name="@Lookup_9"></a>

### Lookup

* <code><a href="CritBit.md#0xc0deb00c_CritBit_borrow">borrow</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_has_key">has_key</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_max_key">max_key</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_min_key">min_key</a>()</code>


<a name="@Size_10"></a>

### Size

* <code><a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_length">length</a>()</code>


<a name="@Destruction_11"></a>

### Destruction

* <code><a href="CritBit.md#0xc0deb00c_CritBit_destroy_empty">destroy_empty</a>()</code>


<a name="@Traversal_12"></a>

## Traversal


[Predecessor public functions](#Predecessor-public-functions) and
[successor public functions](#Successor-public-functions) are
wrapped [generic public functions](#Generic-public-functions),
with documentation comments from <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>()</code> as well as
[generic public functions](#Generic-public-functions) detailing the
relevant algorithms. See [walkthrough](#Walkthrough) for canonical
implementation syntax.


<a name="@Predecessor_public_functions_13"></a>

### Predecessor public functions

* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_init_mut">traverse_p_init_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_mut">traverse_p_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_pop_mut">traverse_p_pop_mut</a>()</code>


<a name="@Successor_public_functions_14"></a>

### Successor public functions

* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_init_mut">traverse_s_init_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_mut">traverse_s_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_pop_mut">traverse_s_pop_mut</a>()</code>


<a name="@Generic_public_functions_15"></a>

### Generic public functions

* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>()</code>
* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>()</code>


<a name="@Public_end_on_pop_function_16"></a>

### Public end on pop function

* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_end_pop">traverse_end_pop</a>()</code>


<a name="@Private_traversal_function_17"></a>

### Private traversal function

* <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>()</code>


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
mutably borrowing a <code><a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a></code> when an <code><a href="CritBit.md#0xc0deb00c_CritBit_I">I</a></code> or <code><a href="CritBit.md#0xc0deb00c_CritBit_O">O</a></code> is already being mutably
borrowed. Not that this borrow-checking constraint introduces an
absolute prohibition on iterated traversal without exposed node
indices, but rather, the given borrow-checking constraints
render non-node-index-exposed traversal inefficient: to traverse
without exposing internal node indices would require searching for a
key from the root during each iteration. Instead, by publicly
exposing node indices, it is possible to walk from one outer node to
the next without having to perform such redundant operations, per
<code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>()</code>.

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

```move
assert!(!is_empty(&cb), 0); // Assert tree not empty
```

This check could be performed within the generalized initialization
function, <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>()</code>, but doing so would introduce
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
let n = length(&cb); // Get number of keys in the tree
let r = n - 1; // Get number of remaining traversals possible
```

Continuing the example, then initialize predecessor traversal per
<code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_init_mut">traverse_p_init_mut</a>()</code>, storing the max key in the tree, a mutable
reference to its corresponding value, the parent field of the
corresponding node, and the child field index of the corresponding
node.

```move
// Initialize predecessor traversal: get max key in tree,
// mutable reference to corresponding value, parent field of
// corresponding node, and the child field index of it
let (k, v_r, p_f, c_i) = traverse_p_init_mut(&mut cb);
```

Now perform an inorder predecessor traversal, popping out the node
for any keys that are a multiple of 4, otherwise incrementing the
corresponding value by a monotonically increasing multiple of 10,
starting at 10, with the exception of the final node, which has its
value set to 0. Hence, {9, 900} updates to {9, 910}, {8, 800} gets
popped, {7, 700} updates to {7, 720}, and so on, until {1, 100} gets
updated to {1, 0}. Again, since Move's documentation build engine
strips leading whitespace, right carets are included to preserve
indentation:

```move
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

After the traversal, {4, 400} and {8, 800} have thus been popped,
and key-value pairs have updated accordingly:

```move
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

Here, the only assurance that the traversal does not go past the end
of the tree is the proper tracking of loop variables: again, the
relevant error-checking could have been implemented in a
corresponding traversal function, namely <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>()</code>, but this
would introduce compounding computational overhead. Since traversal
already requires precise management of loop counter variables and
node indices, it is assumed that they are managed correctly and thus
no redundant error-checking is implemented so as to improve
efficiency.


<a name="@Partial_successor_traversal_21"></a>

#### Partial successor traversal


Continuing the example, since the number of keys was updated during
the last loop, simply check that key count is greater than 0 to
verify tree is not empty. Then re-initialize the remaining traversal
counter, and this time use a value increment counter for a
monotonically increasing multiple of 1. Then initialize successor
traversal:

```move
assert!(n > 0, 9); // Assert tree still not empty
// Re-initialize remaining traversal, value increment counters
(r, i) = (n - 1, 1);
// Initialize successor traversal
(k, v_r, p_f, c_i) = traverse_s_init_mut(&mut cb);
```

Here, if the key is equal to 7, then traverse pop the corresponding
node and store its value, then stop traversal:

```move
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
Hence {7, 720} has been popped, {9, 910} has been left unmodified,
and other key-value pairs have been updated accordingly:

```move
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


<a name="@Singleton_traversal_initialization_22"></a>

#### Singleton traversal initialization


Traversal initializers can still be validly called in the case of a
singleton tree:

```move
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

In this case, the value of the corresponding node can still be
updated, and a traversal loop can even be implemented, with the loop
simply being skipped over:

```move
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


<a name="@Ending_traversal_on_a_pop_23"></a>

#### Ending traversal on a pop

Traversal popping can similarly be executed without traversing any
further via <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_end_pop">traverse_end_pop</a>()</code>, which can be invoked at any point
during iterated traversal, thus ending the traversal with a pop.
See the <code>traverse_end_pop_success()</code> test.

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
-  [Struct `CB`](#0xc0deb00c_CritBit_CB)
-  [Struct `I`](#0xc0deb00c_CritBit_I)
-  [Struct `O`](#0xc0deb00c_CritBit_O)
-  [Constants](#@Constants_24)
-  [Function `borrow`](#0xc0deb00c_CritBit_borrow)
-  [Function `borrow_mut`](#0xc0deb00c_CritBit_borrow_mut)
-  [Function `destroy_empty`](#0xc0deb00c_CritBit_destroy_empty)
-  [Function `empty`](#0xc0deb00c_CritBit_empty)
-  [Function `has_key`](#0xc0deb00c_CritBit_has_key)
-  [Function `insert`](#0xc0deb00c_CritBit_insert)
-  [Function `is_empty`](#0xc0deb00c_CritBit_is_empty)
-  [Function `length`](#0xc0deb00c_CritBit_length)
-  [Function `max_key`](#0xc0deb00c_CritBit_max_key)
-  [Function `min_key`](#0xc0deb00c_CritBit_min_key)
-  [Function `pop`](#0xc0deb00c_CritBit_pop)
-  [Function `singleton`](#0xc0deb00c_CritBit_singleton)
-  [Function `traverse_init_mut`](#0xc0deb00c_CritBit_traverse_init_mut)
    -  [Parameters](#@Parameters_25)
    -  [Returns](#@Returns_26)
    -  [Considerations](#@Considerations_27)
-  [Function `traverse_mut`](#0xc0deb00c_CritBit_traverse_mut)
    -  [Returns](#@Returns_28)
-  [Function `traverse_pop_mut`](#0xc0deb00c_CritBit_traverse_pop_mut)
    -  [Parameters](#@Parameters_29)
    -  [Returns](#@Returns_30)
    -  [Considerations](#@Considerations_31)
-  [Function `traverse_end_pop`](#0xc0deb00c_CritBit_traverse_end_pop)
    -  [Parameters](#@Parameters_32)
    -  [Returns](#@Returns_33)
    -  [Considerations](#@Considerations_34)
-  [Function `traverse_p_init_mut`](#0xc0deb00c_CritBit_traverse_p_init_mut)
-  [Function `traverse_p_mut`](#0xc0deb00c_CritBit_traverse_p_mut)
-  [Function `traverse_p_pop_mut`](#0xc0deb00c_CritBit_traverse_p_pop_mut)
-  [Function `traverse_s_init_mut`](#0xc0deb00c_CritBit_traverse_s_init_mut)
-  [Function `traverse_s_mut`](#0xc0deb00c_CritBit_traverse_s_mut)
-  [Function `traverse_s_pop_mut`](#0xc0deb00c_CritBit_traverse_s_pop_mut)
-  [Function `b_s_o`](#0xc0deb00c_CritBit_b_s_o)
-  [Function `b_s_o_m`](#0xc0deb00c_CritBit_b_s_o_m)
-  [Function `check_len`](#0xc0deb00c_CritBit_check_len)
-  [Function `crit_bit`](#0xc0deb00c_CritBit_crit_bit)
    -  [XOR/AND method](#@XOR/AND_method_35)
    -  [Binary search method](#@Binary_search_method_36)
-  [Function `insert_above`](#0xc0deb00c_CritBit_insert_above)
-  [Function `insert_above_root`](#0xc0deb00c_CritBit_insert_above_root)
-  [Function `insert_below`](#0xc0deb00c_CritBit_insert_below)
-  [Function `insert_below_walk`](#0xc0deb00c_CritBit_insert_below_walk)
-  [Function `insert_empty`](#0xc0deb00c_CritBit_insert_empty)
-  [Function `insert_general`](#0xc0deb00c_CritBit_insert_general)
-  [Function `insert_singleton`](#0xc0deb00c_CritBit_insert_singleton)
-  [Function `max_node_c_i`](#0xc0deb00c_CritBit_max_node_c_i)
-  [Function `min_node_c_i`](#0xc0deb00c_CritBit_min_node_c_i)
-  [Function `is_out`](#0xc0deb00c_CritBit_is_out)
-  [Function `is_set`](#0xc0deb00c_CritBit_is_set)
-  [Function `o_c`](#0xc0deb00c_CritBit_o_c)
-  [Function `o_v`](#0xc0deb00c_CritBit_o_v)
-  [Function `pop_destroy_nodes`](#0xc0deb00c_CritBit_pop_destroy_nodes)
-  [Function `pop_general`](#0xc0deb00c_CritBit_pop_general)
-  [Function `pop_singleton`](#0xc0deb00c_CritBit_pop_singleton)
-  [Function `pop_update_relationships`](#0xc0deb00c_CritBit_pop_update_relationships)
-  [Function `push_back_insert_nodes`](#0xc0deb00c_CritBit_push_back_insert_nodes)
-  [Function `search_outer`](#0xc0deb00c_CritBit_search_outer)
-  [Function `stitch_child_of_parent`](#0xc0deb00c_CritBit_stitch_child_of_parent)
-  [Function `stitch_parent_of_child`](#0xc0deb00c_CritBit_stitch_parent_of_child)
-  [Function `stitch_swap_remove`](#0xc0deb00c_CritBit_stitch_swap_remove)
-  [Function `traverse_c_i`](#0xc0deb00c_CritBit_traverse_c_i)
    -  [Method (predecessor)](#@Method_(predecessor)_37)
    -  [Method (successor)](#@Method_(successor)_38)
    -  [Parameters](#@Parameters_39)
    -  [Returns](#@Returns_40)
    -  [Considerations](#@Considerations_41)


<pre><code><b>use</b> <a href="">0x1::vector</a>;
</code></pre>



<a name="0xc0deb00c_CritBit_CB"></a>

## Struct `CB`

A crit-bit tree for key-value pairs with value type <code>V</code>


<pre><code><b>struct</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Root node index. When bit 63 is set, root node is an outer
 node. Otherwise root is an inner node. 0 when tree is empty
</dd>
<dt>
<code>i: <a href="">vector</a>&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">CritBit::I</a>&gt;</code>
</dt>
<dd>
 Inner nodes
</dd>
<dt>
<code>o: <a href="">vector</a>&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">CritBit::O</a>&lt;V&gt;&gt;</code>
</dt>
<dd>
 Outer nodes
</dd>
</dl>


</details>

<a name="0xc0deb00c_CritBit_I"></a>

## Struct `I`

Inner node


<pre><code><b>struct</b> <a href="CritBit.md#0xc0deb00c_CritBit_I">I</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>c: u8</code>
</dt>
<dd>
 Critical bit position. Bit numbers 0-indexed from LSB:

 ```
 >    11101...1010010101
 >     bit 5 = 0 -|    |- bit 0 = 1
 ```
</dd>
<dt>
<code>p: u64</code>
</dt>
<dd>
 Parent node vector index. <code><a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a></code> when node is root,
 otherwise corresponds to vector index of an inner node.
</dd>
<dt>
<code>l: u64</code>
</dt>
<dd>
 Left child node index. When bit 63 is set, left child is an
 outer node. Otherwise left child is an inner node.
</dd>
<dt>
<code>r: u64</code>
</dt>
<dd>
 Right child node index. When bit 63 is set, right child is
 an outer node. Otherwise right child is an inner node.
</dd>
</dl>


</details>

<a name="0xc0deb00c_CritBit_O"></a>

## Struct `O`

Outer node with key <code>k</code> and value <code>v</code>


<pre><code><b>struct</b> <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>k: u128</code>
</dt>
<dd>
 Key, which would preferably be a generic type representing
 the union of {<code>u8</code>, <code>u64</code>, <code>u128</code>}. However this kind of
 union typing is not supported by Move, so the most general
 (and memory intensive) <code>u128</code> is instead specified strictly.
 Must be an integer for bitwise operations.
</dd>
<dt>
<code>v: V</code>
</dt>
<dd>
 Value from node's key-value pair
</dd>
<dt>
<code>p: u64</code>
</dt>
<dd>
 Parent node vector index. <code><a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a></code> when node is root,
 otherwise corresponds to vector index of an inner node.
</dd>
</dl>


</details>

<a name="@Constants_24"></a>

## Constants


<a name="0xc0deb00c_CritBit_HI_64"></a>

<code>u64</code> bitmask with all bits set


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_HI_64">HI_64</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_CritBit_E_BIT_NOT_0_OR_1"></a>

When a char in a bytestring is neither 0 nor 1


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_BIT_NOT_0_OR_1">E_BIT_NOT_0_OR_1</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_CritBit_E_BORROW_EMPTY"></a>

When unable to borrow from empty tree


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>: u64 = 3;
</code></pre>



<a name="0xc0deb00c_CritBit_E_DESTROY_NOT_EMPTY"></a>

When attempting to destroy a non-empty tree


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_CritBit_E_HAS_K"></a>

When an insertion key is already present in a tree


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_HAS_K">E_HAS_K</a>: u64 = 2;
</code></pre>



<a name="0xc0deb00c_CritBit_E_INSERT_FULL"></a>

When no more keys can be inserted


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_INSERT_FULL">E_INSERT_FULL</a>: u64 = 5;
</code></pre>



<a name="0xc0deb00c_CritBit_E_LOOKUP_EMPTY"></a>

When attempting to look up on an empty tree


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_LOOKUP_EMPTY">E_LOOKUP_EMPTY</a>: u64 = 7;
</code></pre>



<a name="0xc0deb00c_CritBit_E_NOT_HAS_K"></a>

When no matching key in tree


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>: u64 = 4;
</code></pre>



<a name="0xc0deb00c_CritBit_E_POP_EMPTY"></a>

When attempting to pop from empty tree


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_E_POP_EMPTY">E_POP_EMPTY</a>: u64 = 6;
</code></pre>



<a name="0xc0deb00c_CritBit_HI_128"></a>

<code>u128</code> bitmask with all bits set


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_HI_128">HI_128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0xc0deb00c_CritBit_IN"></a>

Node type bit flag indicating inner node


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_IN">IN</a>: u64 = 0;
</code></pre>



<a name="0xc0deb00c_CritBit_L"></a>

Left direction


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>: bool = <b>true</b>;
</code></pre>



<a name="0xc0deb00c_CritBit_MSB_u128"></a>

Most significant bit number for a <code>u128</code>


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_MSB_u128">MSB_u128</a>: u8 = 127;
</code></pre>



<a name="0xc0deb00c_CritBit_N_TYPE"></a>

Bit number of node type flag in a <code>u64</code> vector index


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_N_TYPE">N_TYPE</a>: u8 = 63;
</code></pre>



<a name="0xc0deb00c_CritBit_OUT"></a>

Node type bit flag indicating outer node


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a>: u64 = 1;
</code></pre>



<a name="0xc0deb00c_CritBit_R"></a>

Right direction


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>: bool = <b>false</b>;
</code></pre>



<a name="0xc0deb00c_CritBit_ROOT"></a>

<code>u64</code> bitmask with all bits set, to flag that a node is at root


<pre><code><b>const</b> <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc0deb00c_CritBit_borrow"></a>

## Function `borrow`

Return immutable reference to value corresponding to key <code>k</code> in
<code>cb</code>, aborting if empty tree or no match


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_borrow">borrow</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_borrow">borrow</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &V {
    <b>assert</b>!(!<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb), <a href="CritBit.md#0xc0deb00c_CritBit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>); // Abort <b>if</b> empty
    <b>let</b> c_o = <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o">b_s_o</a>&lt;V&gt;(cb, k); // Borrow search outer node
    <b>assert</b>!(c_o.k == k, <a href="CritBit.md#0xc0deb00c_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>); // Abort <b>if</b> key not in tree
    &c_o.v // Return immutable reference <b>to</b> corresponding value
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_borrow_mut"></a>

## Function `borrow_mut`

Return mutable reference to value corresponding to key <code>k</code> in
<code>cb</code>, aborting if empty tree or no match


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_borrow_mut">borrow_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &<b>mut</b> V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_borrow_mut">borrow_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &<b>mut</b> V {
    <b>assert</b>!(!<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb), <a href="CritBit.md#0xc0deb00c_CritBit_E_BORROW_EMPTY">E_BORROW_EMPTY</a>); // Abort <b>if</b> empty
    <b>let</b> c_o = <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o_m">b_s_o_m</a>&lt;V&gt;(cb, k); // Borrow search outer node
    <b>assert</b>!(c_o.k == k, <a href="CritBit.md#0xc0deb00c_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>); // Abort <b>if</b> key not in tree
    &<b>mut</b> c_o.v // Return mutable reference <b>to</b> corresponding value
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_destroy_empty"></a>

## Function `destroy_empty`

Destroy empty tree <code>cb</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_destroy_empty">destroy_empty</a>&lt;V&gt;(cb: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_destroy_empty">destroy_empty</a>&lt;V&gt;(
    cb: <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;
) {
    <b>assert</b>!(<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>(&cb), <a href="CritBit.md#0xc0deb00c_CritBit_E_DESTROY_NOT_EMPTY">E_DESTROY_NOT_EMPTY</a>);
    <b>let</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>{r: _, i, o} = cb; // Unpack root index and node vectors
    v_d_e(i); // Destroy empty inner node <a href="">vector</a>
    v_d_e(o); // Destroy empty outer node <a href="">vector</a>
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_empty"></a>

## Function `empty`

Return an empty tree


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_empty">empty</a>&lt;V&gt;(): <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_empty">empty</a>&lt;V&gt;():
<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt; {
    <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>{r: 0, i: v_e&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(), o: v_e&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;()}
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_has_key"></a>

## Function `has_key`

Return true if <code>cb</code> has key <code>k</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_has_key">has_key</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_has_key">has_key</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): bool {
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb)) <b>return</b> <b>false</b>; // Return <b>false</b> <b>if</b> empty
    // Return <b>true</b> <b>if</b> search outer node <b>has</b> same key
    <b>return</b> <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o">b_s_o</a>&lt;V&gt;(cb, k).k == k
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert"></a>

## Function `insert`

Insert key <code>k</code> and value <code>v</code> into <code>cb</code>, aborting if <code>k</code> already
in <code>cb</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert">insert</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert">insert</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V
) {
    <b>let</b> l = <a href="CritBit.md#0xc0deb00c_CritBit_length">length</a>(cb); // Get length of tree
    <a href="CritBit.md#0xc0deb00c_CritBit_check_len">check_len</a>(l); // Verify insertion can take place
    // Insert via one of three cases, depending on the length
    <b>if</b> (l == 0) <a href="CritBit.md#0xc0deb00c_CritBit_insert_empty">insert_empty</a>(cb, k , v) <b>else</b>
    <b>if</b> (l == 1) <a href="CritBit.md#0xc0deb00c_CritBit_insert_singleton">insert_singleton</a>(cb, k, v) <b>else</b>
    <a href="CritBit.md#0xc0deb00c_CritBit_insert_general">insert_general</a>(cb, k, v, l);
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_is_empty"></a>

## Function `is_empty`

Return <code><b>true</b></code> if <code>cb</code> has no outer nodes


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;): bool {v_i_e&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o)}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_length"></a>

## Function `length`

Return number of keys in <code>cb</code> (number of outer nodes)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_length">length</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_length">length</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;): u64 {v_l&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o)}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_max_key"></a>

## Function `max_key`

Return the maximum key in <code>cb</code>, aborting if <code>cb</code> is empty


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_max_key">max_key</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_max_key">max_key</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
): u128 {
    <b>assert</b>!(!<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>(cb), <a href="CritBit.md#0xc0deb00c_CritBit_E_LOOKUP_EMPTY">E_LOOKUP_EMPTY</a>); // Assert tree not empty
    v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(<a href="CritBit.md#0xc0deb00c_CritBit_max_node_c_i">max_node_c_i</a>&lt;V&gt;(cb))).k // Return max key
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_min_key"></a>

## Function `min_key`

Return the minimum key in <code>cb</code>, aborting if <code>cb</code> is empty


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_min_key">min_key</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_min_key">min_key</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
): u128 {
    <b>assert</b>!(!<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>(cb), <a href="CritBit.md#0xc0deb00c_CritBit_E_LOOKUP_EMPTY">E_LOOKUP_EMPTY</a>); // Assert tree not empty
    v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(<a href="CritBit.md#0xc0deb00c_CritBit_min_node_c_i">min_node_c_i</a>&lt;V&gt;(cb))).k // Return <b>min</b> key
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_pop"></a>

## Function `pop`

Pop from <code>cb</code> value corresponding to key <code>k</code>, aborting if <code>cb</code>
is empty or does not contain <code>k</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop">pop</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop">pop</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128
): V {
    <b>assert</b>!(!<a href="CritBit.md#0xc0deb00c_CritBit_is_empty">is_empty</a>(cb), <a href="CritBit.md#0xc0deb00c_CritBit_E_POP_EMPTY">E_POP_EMPTY</a>); // Assert tree not empty
    <b>let</b> l = <a href="CritBit.md#0xc0deb00c_CritBit_length">length</a>(cb); // Get number of outer nodes in tree
    // Depending on length, pop from singleton or for general case
    <b>if</b> (l == 1) <a href="CritBit.md#0xc0deb00c_CritBit_pop_singleton">pop_singleton</a>(cb, k) <b>else</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_general">pop_general</a>(cb, k, l)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_singleton"></a>

## Function `singleton`

Return a tree with one node having key <code>k</code> and value <code>v</code>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_singleton">singleton</a>&lt;V&gt;(k: u128, v: V): <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_singleton">singleton</a>&lt;V&gt;(
    k: u128,
    v: V
):
<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt; {
    <b>let</b> cb = <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>{r: 0, i: v_e&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(), o: v_e&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;()};
    <a href="CritBit.md#0xc0deb00c_CritBit_insert_empty">insert_empty</a>&lt;V&gt;(&<b>mut</b> cb, k, v);
    cb
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_init_mut"></a>

## Function `traverse_init_mut`

Initialize a mutable iterated inorder traversal in a tree having
at least one outer node. See [traversal](#Traversal)


<a name="@Parameters_25"></a>

### Parameters

* <code>cb</code>: A crit-bit tree containing at least one outer node
* <code>d</code>: Direction to traverse. If <code><a href="CritBit.md#0xc0deb00c_CritBit_L">L</a></code>, initialize predecessor
traversal, else successor traversal


<a name="@Returns_26"></a>

### Returns

* <code>u128</code>: Maximum key in <code>cb</code> if <code>d</code> is <code><a href="CritBit.md#0xc0deb00c_CritBit_L">L</a></code>, else minimum key
* <code>&<b>mut</b> V</code>: Mutable reference to corresponding node's value
* <code>u64</code>: Parent field of corresponding node
* <code>u64</code>: Child field index of corresponding node


<a name="@Considerations_27"></a>

### Considerations

* Exposes node indices
* Assumes caller has already verified tree is not empty


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, d: bool): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    d: bool,
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    // If predecessor traversal, get child field index of node
    // having maximum key, <b>else</b> node having minimum key
    <b>let</b> i_n = <b>if</b> (d == <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>) <a href="CritBit.md#0xc0deb00c_CritBit_max_node_c_i">max_node_c_i</a>(cb) <b>else</b> <a href="CritBit.md#0xc0deb00c_CritBit_min_node_c_i">min_node_c_i</a>(cb);
    // Borrow mutable reference <b>to</b> node
    <b>let</b> n = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_n));
    // Return node's key, mutable reference <b>to</b> its value, its parent
    // field, and the child field index of it
    (n.k, &<b>mut</b> n.v, n.p, i_n)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_mut"></a>

## Function `traverse_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>()</code> call for enumerated return extraction.
See [traversal](#Traversal)

<a name="@Returns_28"></a>

### Returns

* <code>u128</code>: Target key
* <code>&<b>mut</b> V</code>: Mutable reference to target node's value
* <code>u64</code>: Target node's parent field
* <code>u64</code>: Child field index of target node


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64, d: bool): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64,
    d: bool
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    // Get child field index of target node
    <b>let</b> i_t = <a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>&lt;V&gt;(cb, k, p_f, d);
    // Borrow mutable reference <b>to</b> target node
    <b>let</b> t = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_t));
    // Return target node's key, mutable reference <b>to</b> its value, its
    // parent field, and child field index of it
    (t.k, &<b>mut</b> t.v, t.p, i_t)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_pop_mut"></a>

## Function `traverse_pop_mut`

Traverse in the specified direction from the node containing the
specified key (the "start node" containing the "start key") to
either the inorder predecessor or the inorder successor to the
start key (the "target node" containing the "target key"), then
pop the start node and return its value. See
[traversal](#Traversal)


<a name="@Parameters_29"></a>

### Parameters

* <code>cb</code>: Crit-bit tree containing at least two nodes
* <code>k</code>: Start key. If predecessor traversal, <code>k</code> cannot be
minimum key in <code>cb</code>, since this key does not have a
predecessor. Likewise, if successor traversal, <code>k</code> cannot be
maximum key in <code>cb</code>, since this key does not have a successor
* <code>p_f</code>: Start node's parent field
* <code>c_i</code>: Child field index of start node
* <code>n_o</code>: Number of outer nodes in <code>cb</code>
* <code>d</code>: Direction to traverse. If <code><a href="CritBit.md#0xc0deb00c_CritBit_L">L</a></code>, predecessor traversal,
else successor traversal


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
* Takes exposed node indices (<code>p_f</code>, <code>c_i</code>) as parameters
* Does not calculate number of outer nodes in <code>cb</code>, but rather
accepts this number as a parameter (<code>n_o</code>), which should be
tracked by the caller


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64, c_i: u64, n_o: u64, d: bool): (u128, &<b>mut</b> V, u64, u64, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64,
    c_i: u64,
    n_o: u64,
    d: bool
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64,
    V
) {
    // Mark start node's side <b>as</b> a child <b>as</b> left (<b>true</b>) <b>if</b> node's
    // parent <b>has</b> the node <b>as</b> its left child, <b>else</b> right (<b>false</b>)
    <b>let</b> s_s = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, p_f).l == c_i;
    // Store target node's pre-pop child field index
    <b>let</b> i_t = <a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>(cb, k, p_f, d);
    // Update relationships for popped start node
    <a href="CritBit.md#0xc0deb00c_CritBit_pop_update_relationships">pop_update_relationships</a>(cb, s_s, p_f);
    // Store start node value from pop-facilitated node destruction
    <b>let</b> s_v = <a href="CritBit.md#0xc0deb00c_CritBit_pop_destroy_nodes">pop_destroy_nodes</a>(cb, p_f, c_i, n_o);
    // If target node was last in outer node <a href="">vector</a>, then swap
    // remove will have relocated it, so <b>update</b> its <b>post</b>-pop field
    // index <b>to</b> the start node's pre-pop field index
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_t) == n_o - 1) i_t = c_i;
    // Borrow mutable reference <b>to</b> target node
    <b>let</b> t = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_t));
    // Return target node's key, mutable reference <b>to</b> its value, its
    // parent field, the child field index of it, and the start
    // node's popped value
    (t.k, &<b>mut</b> t.v, t.p, i_t, s_v)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_end_pop"></a>

## Function `traverse_end_pop`

Terminate iterated traversal by popping the outer node for the
current iteration, without traversing further. Implements
similar algorithms as <code><a href="CritBit.md#0xc0deb00c_CritBit_pop_general">pop_general</a>()</code>, but without having to
do another search from root.


<a name="@Parameters_32"></a>

### Parameters

* <code>cb</code>: Crit-bit tree containing at least one node
* <code>p_f</code>: Node's parent field
* <code>c_i</code>: Child field index of node
* <code>n_o</code>: Number of outer nodes in <code>cb</code>


<a name="@Returns_33"></a>

### Returns

* <code>V</code>: Popped value from outer node


<a name="@Considerations_34"></a>

### Considerations

* Takes exposed node indices (<code>p_f</code>, <code>c_i</code>) as parameters
* Does not calculate number of outer nodes in <code>cb</code>, but rather
accepts this number as a parameter (<code>n_o</code>), which should be
tracked by the caller and should be nonzero


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_end_pop">traverse_end_pop</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, p_f: u64, c_i: u64, n_o: u64): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_end_pop">traverse_end_pop</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    p_f: u64,
    c_i: u64,
    n_o: u64,
): V {
    <b>if</b> (n_o == 1) { // If popping only remaining node in tree
        cb.r = 0; // Update root
        // Pop off and unpack outer node at root
        <b>let</b> <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>{k: _, v, p: _} = v_po_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o);
        v // Return popped value
    } <b>else</b> { // If popping from tree <b>with</b> more than 1 outer node
        // Mark node's side <b>as</b> a child <b>as</b> left (<b>true</b>) <b>if</b> node's
        // parent <b>has</b> the node <b>as</b> its left child, <b>else</b> right (<b>false</b>)
        <b>let</b> n_s_c = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, p_f).l == c_i;
        // Update sibling, parent, grandparent relationships
        <a href="CritBit.md#0xc0deb00c_CritBit_pop_update_relationships">pop_update_relationships</a>(cb, n_s_c, p_f);
        // Destroy <b>old</b> nodes, returning popped value
        <a href="CritBit.md#0xc0deb00c_CritBit_pop_destroy_nodes">pop_destroy_nodes</a>(cb, p_f, c_i, n_o)
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_p_init_mut"></a>

## Function `traverse_p_init_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>()</code> call for predecessor traversal.
See [traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_init_mut">traverse_p_init_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_init_mut">traverse_p_init_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>(cb, <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_p_mut"></a>

## Function `traverse_p_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>()</code> call for predecessor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_mut">traverse_p_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_mut">traverse_p_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>&lt;V&gt;(cb, k, p_f, <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_p_pop_mut"></a>

## Function `traverse_p_pop_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>()</code> call for predecessor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_pop_mut">traverse_p_pop_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64, c_i: u64, n_o: u64): (u128, &<b>mut</b> V, u64, u64, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_p_pop_mut">traverse_p_pop_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64,
    c_i: u64,
    n_o: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64,
    V
) {
    <a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>(cb, k, p_f, c_i, n_o, <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_s_init_mut"></a>

## Function `traverse_s_init_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>()</code> call for successor traversal.
See [traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_init_mut">traverse_s_init_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_init_mut">traverse_s_init_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="CritBit.md#0xc0deb00c_CritBit_traverse_init_mut">traverse_init_mut</a>(cb, <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_s_mut"></a>

## Function `traverse_s_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>()</code> call for successor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_mut">traverse_s_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64): (u128, &<b>mut</b> V, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_mut">traverse_s_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64
) {
    <a href="CritBit.md#0xc0deb00c_CritBit_traverse_mut">traverse_mut</a>&lt;V&gt;(cb, k, p_f, <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_s_pop_mut"></a>

## Function `traverse_s_pop_mut`

Wrapped <code><a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>()</code> call for successor traversal. See
[traversal walkthrough](#Walkthrough)


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_pop_mut">traverse_s_pop_mut</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64, c_i: u64, n_o: u64): (u128, &<b>mut</b> V, u64, u64, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_s_pop_mut">traverse_s_pop_mut</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64,
    c_i: u64,
    n_o: u64
): (
    u128,
    &<b>mut</b> V,
    u64,
    u64,
    V
) {
    <a href="CritBit.md#0xc0deb00c_CritBit_traverse_pop_mut">traverse_pop_mut</a>(cb, k, p_f, c_i, n_o, <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_b_s_o"></a>

## Function `b_s_o`

Walk non-empty tree <code>cb</code>, breaking out if at outer node,
branching left or right at each inner node depending on whether
<code>k</code> is unset or set, respectively, at the given critical bit.
Then return mutable reference to search outer node (<code>b_c_o</code>
indicates borrow search outer)


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o">b_s_o</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &<a href="CritBit.md#0xc0deb00c_CritBit_O">CritBit::O</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o">b_s_o</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt; {
    // If root is an outer node, <b>return</b> reference <b>to</b> it
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(cb.r)) <b>return</b> (v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(cb.r)));
    // Otherwise borrow inner node at root
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, cb.r);
    <b>loop</b> { // Loop over inner nodes
        // If key is set at critical bit, get index of child on <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>
        <b>let</b> i_c = <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, n.c)) n.r <b>else</b> n.l; // Otherwise <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>
        // If child is outer node, <b>return</b> reference <b>to</b> it
        <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_c)) <b>return</b> v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_c));
        n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_c); // Borrow next inner node <b>to</b> review
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_b_s_o_m"></a>

## Function `b_s_o_m`

Like <code><a href="CritBit.md#0xc0deb00c_CritBit_b_s_o">b_s_o</a>()</code>, but for mutable reference


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o_m">b_s_o_m</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_O">CritBit::O</a>&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_b_s_o_m">b_s_o_m</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
): &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt; {
    // If root is an outer node, <b>return</b> mutable reference <b>to</b> it
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(cb.r)) <b>return</b> (v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(cb.r)));
    // Otherwise borrow inner node at root
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, cb.r);
    <b>loop</b> { // Loop over inner nodes
        // If key is set at critical bit, get index of child on <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>
        <b>let</b> i_c = <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, n.c)) n.r <b>else</b> n.l; // Otherwise <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>
        // If child is outer node, <b>return</b> mutable reference <b>to</b> it
        <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_c)) <b>return</b> v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_c));
        n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_c); // Borrow next inner node <b>to</b> review
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_check_len"></a>

## Function `check_len`

Assert that <code>l</code> is less than the value indicated by a bitmask
where only the 63rd bit is not set (this bitmask corresponds to
the maximum number of keys that can be stored in a tree, since
the 63rd bit is reserved for the node type bit flag)


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_check_len">check_len</a>(l: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_check_len">check_len</a>(l: u64) {<b>assert</b>!(l &lt; <a href="CritBit.md#0xc0deb00c_CritBit_HI_64">HI_64</a> ^ <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0xc0deb00c_CritBit_N_TYPE">N_TYPE</a>, <a href="CritBit.md#0xc0deb00c_CritBit_E_INSERT_FULL">E_INSERT_FULL</a>);}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_crit_bit"></a>

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


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_crit_bit">crit_bit</a>(s1: u128, s2: u128): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_crit_bit">crit_bit</a>(
    s1: u128,
    s2: u128,
): u8 {
    <b>let</b> x = s1 ^ s2; // XOR result marked 1 at bits that differ
    <b>let</b> l = 0; // Lower bound on critical bit search
    <b>let</b> u = <a href="CritBit.md#0xc0deb00c_CritBit_MSB_u128">MSB_u128</a>; // Upper bound on critical bit search
    <b>loop</b> { // Begin binary search
        <b>let</b> m = (l + u) / 2; // Calculate midpoint of search window
        <b>let</b> s = x &gt;&gt; m; // Calculate midpoint shift of XOR result
        <b>if</b> (s == 1) <b>return</b> m; // If shift equals 1, c = m
        <b>if</b> (s &gt; 1) l = m + 1 <b>else</b> u = m - 1; // Update search bounds
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_above"></a>

## Function `insert_above`

Decomposed case specified in <code>insert_general</code>, walk up tree, for
parameters:
* <code>cb</code>: Tree to insert into
* <code>k</code> : Key to insert
* <code>v</code> : Value to insert
* <code>n_o</code> : Number of keys (outer nodes) in <code>cb</code> pre-insert
* <code>i_n_i</code> : Number of inner nodes in <code>cb</code> pre-insert (index of
new inner node)
* <code>i_s_p</code>: Index of search parent
* <code>c</code>: Critical bit between insertion key and search outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_above">insert_above</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, n_o: u64, i_n_i: u64, i_s_p: u64, c: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_above">insert_above</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    i_s_p: u64,
    c: u8
) {
    // Set index of node under review <b>to</b> search parent's parent
    <b>let</b> i_n_r = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_s_p).p;
    <b>loop</b> { // Loop over inner nodes
        <b>if</b> (i_n_r == <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>) { // If walk arrives at root
            // Insert above root
            <b>return</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_above_root">insert_above_root</a>(cb, k, v, n_o, i_n_i, c)
        } <b>else</b> { // If walk <b>has</b> not arrived at root
            // Borrow mutable reference <b>to</b> node under review
            <b>let</b> n_r = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_n_r);
            // If critical bit between insertion key and search
            // outer node is less than that of node under review
            <b>if</b> (c &lt; n_r.c) { // If need <b>to</b> insert below
                // Insert below node under review
                <b>return</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_below_walk">insert_below_walk</a>(cb, k, v, n_o, i_n_i, i_n_r, c)
            } <b>else</b> { // If need <b>to</b> insert above
                i_n_r = n_r.p; // Review node under review's parent
            }
        }
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_above_root"></a>

## Function `insert_above_root`

Decomposed case specified in <code>insert_general</code>, insertion above
root, for parameters:
* <code>cb</code>: Tree to insert into
* <code>k</code> : Key to insert
* <code>v</code> : Value to insert
* <code>n_o</code> : Number of keys (outer nodes) in <code>cb</code> pre-insert
* <code>i_n_i</code> : Number of inner nodes in <code>cb</code> pre-insert (index of
new inner node)
* <code>c</code>: Critical bit between insertion key and search outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_above_root">insert_above_root</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, n_o: u64, i_n_i: u64, c: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_above_root">insert_above_root</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    c: u8
) {
    <b>let</b> i_o_r = cb.r; // Get index of <b>old</b> root <b>to</b> insert above
    // Set <b>old</b> root node <b>to</b> have new inner node <b>as</b> parent
    v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_o_r).p = i_n_i;
    // Set root field index <b>to</b> indicate new inner node
    cb.r = i_n_i;
    // Push back new inner and outer nodes, <b>with</b> inner node
    // indicating that it is root. If insertion key is set at
    // critical bit, new inner node should have <b>as</b> its left child
    // the previous root node and should have <b>as</b> its right child
    // the new outer node
    <a href="CritBit.md#0xc0deb00c_CritBit_push_back_insert_nodes">push_back_insert_nodes</a>(
        cb, k, v, i_n_i, c, <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>, <a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, c), i_o_r, <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(n_o)
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_below"></a>

## Function `insert_below`

Decomposed case specified in <code>insert_general</code>, insertion below
search parent, for parameters:
* <code>cb</code>: Tree to insert into
* <code>k</code> : Key to insert
* <code>v</code> : Value to insert
* <code>n_o</code> : Number of keys (outer nodes) in <code>cb</code> pre-insert
* <code>i_n_i</code> : Number of inner nodes in <code>cb</code> pre-insert (index of
new inner node)
* <code>i_s_o</code>: Field index of search outer node (with bit flag)
* <code>s_s_o</code>: Side on which search outer node is child
* <code>k_s_o</code>: Key of search outer node
* <code>i_s_p</code>: Index of search parent
* <code>c</code>: Critical bit between insertion key and search outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_below">insert_below</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, n_o: u64, i_n_i: u64, i_s_o: u64, s_s_o: bool, k_s_o: u128, i_s_p: u64, c: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_below">insert_below</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
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
    // Borrow mutable reference <b>to</b> search parent
    <b>let</b> s_p = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_s_p);
    // Update search parent <b>to</b> have new inner node <b>as</b> child, on same
    // side that the search outer node was a child at
    <b>if</b> (s_s_o == <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>) s_p.l = i_n_i <b>else</b> s_p.r = i_n_i;
    // Set search outer node <b>to</b> have new inner node <b>as</b> parent
    v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_s_o)).p = i_n_i;
    // Push back new inner and outer nodes, <b>with</b> inner node having
    // <b>as</b> its parent the search parent. If insertion key is less
    // than key of search outer node, new inner node should have <b>as</b>
    // its left child the new outer node and should have <b>as</b> its
    // right child the search outer node
    <a href="CritBit.md#0xc0deb00c_CritBit_push_back_insert_nodes">push_back_insert_nodes</a>(
        cb, k, v, i_n_i, c, i_s_p, k &lt; k_s_o, <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(n_o), i_s_o
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_below_walk"></a>

## Function `insert_below_walk`

Decomposed case specified in <code>insert_general</code>, insertion below
a node encountered during walk, for parameters:
* <code>cb</code>: Tree to insert into
* <code>k</code> : Key to insert
* <code>v</code> : Value to insert
* <code>n_o</code> : Number of keys (outer nodes) in <code>cb</code> pre-insert
* <code>i_n_i</code> : Number of inner nodes in <code>cb</code> pre-insert (index of
new inner node)
* <code>i_n_r</code> : Index of node under review from walk
* <code>c</code>: Critical bit between insertion key and search outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_below_walk">insert_below_walk</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, n_o: u64, i_n_i: u64, i_n_r: u64, c: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_below_walk">insert_below_walk</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V,
    n_o: u64,
    i_n_i: u64,
    i_n_r: u64,
    c: u8
) {
    // Borrow mutable reference <b>to</b> node under review
    <b>let</b> n_r = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_n_r);
    // If insertion key is set at critical bit indicated by node
    // under review, mark side and index of walked child <b>as</b> its
    // right child, <b>else</b> left
    <b>let</b> (s_w_c, i_w_c) = <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, n_r.c)) (<a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>, n_r.r) <b>else</b> (<a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>, n_r.l);
    // Set node under review <b>to</b> have <b>as</b> child new inner node on same
    // side <b>as</b> walked child
    <b>if</b> (s_w_c == <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>) n_r.l = i_n_i <b>else</b> n_r.r = i_n_i;
    // Update walked child <b>to</b> have new inner node <b>as</b> its parent
    v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_w_c).p = i_n_i;
    // Push back new inner and outer nodes, <b>with</b> inner node having
    // <b>as</b> its parent the node under review. If insertion key is set
    // at critical bit, new inner node should have <b>as</b> its left child
    // the walked child of the node under review and should have <b>as</b>
    // its right child the new outer node
    <a href="CritBit.md#0xc0deb00c_CritBit_push_back_insert_nodes">push_back_insert_nodes</a>(
        cb, k, v, i_n_i, c, i_n_r, <a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, c), i_w_c, <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(n_o)
    );
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_empty"></a>

## Function `insert_empty`

Insert key-value pair <code>k</code> and <code>v</code> into an empty <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_empty">insert_empty</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_empty">insert_empty</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V
) {
    // Push back outer node onto tree's <a href="">vector</a> of outer nodes
    v_pu_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;{k, v, p: <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>});
    // Set root index field <b>to</b> indicate 0th outer node
    cb.r = <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0xc0deb00c_CritBit_N_TYPE">N_TYPE</a>;
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_general"></a>

## Function `insert_general`

Insert key <code>k</code> and value <code>v</code> into tree <code>cb</code> already having <code>n_o</code>
keys for general case where root is an inner node, aborting if
<code>k</code> is already present. First, perform an outer node search and
identify the critical bit of divergence between the search outer
node and <code>k</code>. Then, if the critical bit is less than that of the
search parent (<code><a href="CritBit.md#0xc0deb00c_CritBit_insert_below">insert_below</a>()</code>):

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
Otherwise, begin walking back up the tree (<code><a href="CritBit.md#0xc0deb00c_CritBit_insert_above">insert_above</a>()</code>). If
walk arrives at the root node, insert a new inner node above the
root, updating associated relationships (<code><a href="CritBit.md#0xc0deb00c_CritBit_insert_above_root">insert_above_root</a>()</code>):
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
insert the new inner node below it (<code><a href="CritBit.md#0xc0deb00c_CritBit_insert_below_walk">insert_below_walk</a>()</code>):
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


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_general">insert_general</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, n_o: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_general">insert_general</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V,
    n_o: u64
) {
    // Get number of inner nodes in tree (index of new inner node)
    <b>let</b> i_n_i = v_l&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i);
    // Get field index of search outer node, its side <b>as</b> a child,
    // its key, the <a href="">vector</a> index of its parent, and the critical
    // bit indicated by the search parent
    <b>let</b> (i_s_o, s_s_o, k_s_o, i_s_p, s_p_c) = <a href="CritBit.md#0xc0deb00c_CritBit_search_outer">search_outer</a>(cb, k);
    <b>assert</b>!(k_s_o != k, <a href="CritBit.md#0xc0deb00c_CritBit_E_HAS_K">E_HAS_K</a>); // Assert key not a duplicate
    // Get critical bit between insertion key and search outer node
    <b>let</b> c = <a href="CritBit.md#0xc0deb00c_CritBit_crit_bit">crit_bit</a>(k_s_o, k);
    // If critical bit is less than that indicated by search parent
    <b>if</b> (c &lt; s_p_c) {
        // Insert new inner node below search parent
        <a href="CritBit.md#0xc0deb00c_CritBit_insert_below">insert_below</a>(cb, k, v, n_o, i_n_i, i_s_o, s_s_o, k_s_o, i_s_p, c);
    } <b>else</b> { // If need <b>to</b> insert new inner node above search parent
        <a href="CritBit.md#0xc0deb00c_CritBit_insert_above">insert_above</a>(cb, k, v, n_o, i_n_i, i_s_p, c);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_insert_singleton"></a>

## Function `insert_singleton`

Insert key <code>k</code> and value <code>v</code> into singleton tree <code>cb</code>, aborting
if <code>k</code> already in <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_singleton">insert_singleton</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_insert_singleton">insert_singleton</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V
) {
    <b>let</b> n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, 0); // Borrow existing outer node
    <b>assert</b>!(k != n.k, <a href="CritBit.md#0xc0deb00c_CritBit_E_HAS_K">E_HAS_K</a>); // Assert insertion key not in tree
    <b>let</b> c = <a href="CritBit.md#0xc0deb00c_CritBit_crit_bit">crit_bit</a>(n.k, k); // Get critical bit between two keys
    // Push back new inner and outer nodes, <b>with</b> inner node
    // indicating that it is root. If insertion key is greater than
    // singleton key, new inner node should have <b>as</b> its left child
    // existing outer node and should have <b>as</b> its right child new
    // outer node
    <a href="CritBit.md#0xc0deb00c_CritBit_push_back_insert_nodes">push_back_insert_nodes</a>(cb, k, v, 0, c, <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>, k &gt; n.k, <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(0), <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(1));
    cb.r = 0; // Update tree root field <b>to</b> indicate new inner node
    // Update existing outer node <b>to</b> have new inner node <b>as</b> parent
    v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, 0).p = 0;
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_max_node_c_i"></a>

## Function `max_node_c_i`

Return the child field index of the outer node containing the
maximum key in non-empty tree <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_max_node_c_i">max_node_c_i</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_max_node_c_i">max_node_c_i</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;
): u64 {
    <b>let</b> i_n = cb.r; // Initialize index of search node <b>to</b> root
    <b>loop</b> { // Loop over nodes
        // If search node is an outer node <b>return</b> its field index
        <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_n)) <b>return</b> i_n;
        i_n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_n).r // Review node's right child next
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_min_node_c_i"></a>

## Function `min_node_c_i`

Return the child field index of the outer node containing the
minimum key in non-empty tree <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_min_node_c_i">min_node_c_i</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_min_node_c_i">min_node_c_i</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;
): u64 {
    <b>let</b> i_n = cb.r; // Initialize index of search node <b>to</b> root
    <b>loop</b> { // Loop over nodes
        // If search node is an outer node <b>return</b> its field index
        <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_n)) <b>return</b> i_n;
        i_n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_n).l // Review node's left child next
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_is_out"></a>

## Function `is_out`

Return <code><b>true</b></code> if vector index <code>i</code> indicates an outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i: u64): bool {(i &gt;&gt; <a href="CritBit.md#0xc0deb00c_CritBit_N_TYPE">N_TYPE</a> & <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a> == <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a>)}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_is_set"></a>

## Function `is_set`

Return <code><b>true</b></code> if <code>k</code> is set at bit <code>b</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k: u128, b: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k: u128, b: u8): bool {k &gt;&gt; b & 1 == 1}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_o_c"></a>

## Function `o_c`

Convert unflagged outer node vector index <code>v</code> to flagged child
node index, by OR with a bitmask that has only flag bit set


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(v: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(v: u64): u64 {v | <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0xc0deb00c_CritBit_N_TYPE">N_TYPE</a>}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_o_v"></a>

## Function `o_v`

Convert flagged child node index <code>c</code> to unflagged outer node
vector index, by AND with a bitmask that has only flag bit unset


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(c: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(c: u64): u64 {c & <a href="CritBit.md#0xc0deb00c_CritBit_HI_64">HI_64</a> ^ <a href="CritBit.md#0xc0deb00c_CritBit_OUT">OUT</a> &lt;&lt; <a href="CritBit.md#0xc0deb00c_CritBit_N_TYPE">N_TYPE</a>}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_pop_destroy_nodes"></a>

## Function `pop_destroy_nodes`

Remove from <code>cb</code> inner node at child field index <code>i_i</code>, and
outer node at child field index <code>i_o</code> (from node vector with
<code>n_o</code> outer nodes pre-pop). Then return the popped value from
the outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_destroy_nodes">pop_destroy_nodes</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, i_i: u64, i_o: u64, n_o: u64): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_destroy_nodes">pop_destroy_nodes</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    i_i: u64,
    i_o: u64,
    n_o: u64
): V {
    <b>let</b> n_i = v_l&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i); // Get number of inner nodes pre-pop
    // Swap remove parent of popped outer node, storing no fields
    <b>let</b> <a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>{c: _, p: _, l: _, r: _} = v_s_r&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_i);
    // If destroyed inner node was not last inner node in <a href="">vector</a>,
    // repair the parent-child relationship broken by swap remove
    <b>if</b> (i_i &lt; n_i - 1) <a href="CritBit.md#0xc0deb00c_CritBit_stitch_swap_remove">stitch_swap_remove</a>(cb, i_i, n_i);
    // Swap remove popped outer node, storing only its value
    <b>let</b> <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>{k: _, v, p: _} = v_s_r&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_o));
    // If destroyed outer node was not last outer node in <a href="">vector</a>,
    // repair the parent-child relationship broken by swap remove
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_o) &lt; n_o - 1) <a href="CritBit.md#0xc0deb00c_CritBit_stitch_swap_remove">stitch_swap_remove</a>(cb, i_o, n_o);
    v // Return popped value
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_pop_general"></a>

## Function `pop_general`

Return the value corresponding to key <code>k</code> in tree <code>cb</code> having
<code>n_o</code> keys and destroy the outer node where it was stored, for
the general case of a tree with more than one outer node. Abort
if <code>k</code> not in <code>cb</code>. Here, the parent of the popped node must be
removed, and if the popped node has a grandparent, the
grandparent of the popped node must be updated to have as its
child the popped node's sibling at the same position where the
popped node's parent previously was, whether the sibling is an
outer or inner node. Likewise the sibling must be updated to
have as its parent the grandparent to the popped node. Outer
node sibling case:
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


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_general">pop_general</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, n_o: u64): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_general">pop_general</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    n_o: u64
): V {
    // Get field index of search outer node, its side <b>as</b> a child,
    // its key, and the <a href="">vector</a> index of its parent
    <b>let</b> (i_s_o, s_s_o, k_s_o, i_s_p, _) = <a href="CritBit.md#0xc0deb00c_CritBit_search_outer">search_outer</a>(cb, k);
    <b>assert</b>!(k_s_o == k, <a href="CritBit.md#0xc0deb00c_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>); // Assert key in tree
    // Update sibling, parent, grandparent relationships
    <a href="CritBit.md#0xc0deb00c_CritBit_pop_update_relationships">pop_update_relationships</a>(cb, s_s_o, i_s_p);
    // Destroy <b>old</b> nodes, returning popped value
    <a href="CritBit.md#0xc0deb00c_CritBit_pop_destroy_nodes">pop_destroy_nodes</a>(cb, i_s_p, i_s_o, n_o)
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_pop_singleton"></a>

## Function `pop_singleton`

Return the value corresponding to key <code>k</code> in singleton tree <code>cb</code>
and destroy the outer node where it was stored, aborting if <code>k</code>
not in <code>cb</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_singleton">pop_singleton</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_singleton">pop_singleton</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128
): V {
    // Assert key actually in tree at root node
    <b>assert</b>!(v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, 0).k == k, <a href="CritBit.md#0xc0deb00c_CritBit_E_NOT_HAS_K">E_NOT_HAS_K</a>);
    cb.r = 0; // Update root
    // Pop off and unpack outer node at root
    <b>let</b> <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>{k: _, v, p: _} = v_po_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o);
    v // Return popped value
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_pop_update_relationships"></a>

## Function `pop_update_relationships`

Update relationships in <code>cb</code> for popping a node which is a child
on side <code>s_c</code> (<code><a href="CritBit.md#0xc0deb00c_CritBit_L">L</a></code> or <code><a href="CritBit.md#0xc0deb00c_CritBit_R">R</a></code>), to parent node at index <code>i_p</code>, per
<code><a href="CritBit.md#0xc0deb00c_CritBit_pop_general">pop_general</a>()</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_update_relationships">pop_update_relationships</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, s_c: bool, i_p: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_pop_update_relationships">pop_update_relationships</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    s_c: bool,
    i_p: u64,
) {
    // Borrow immutable reference <b>to</b> popped node's parent
    <b>let</b> p = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_p);
    // If popped outer node was a left child, store the right child
    // field index of its parent <b>as</b> the child field index of the
    // popped node's sibling. Else flip the direction
    <b>let</b> i_s = <b>if</b> (s_c == <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>) p.r <b>else</b> p.l;
    // Get parent field index of popped node's parent
    <b>let</b> i_p_p = p.p;
    // Update popped node's sibling <b>to</b> have at its parent index
    // field the same <b>as</b> that of the popped node's parent, whether
    // the sibling is an inner or outer node
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_s)) v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_s)).p = i_p_p
        <b>else</b> v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_s).p = i_p_p;
    <b>if</b> (i_p_p == <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>) { // If popped node's parent is root
        // Set root field index <b>to</b> child field index of popped
        // node's sibling
        cb.r = i_s;
    } <b>else</b> { // If popped node <b>has</b> a grandparent
        // Borrow mutable reference <b>to</b> popped node's grandparent
        <b>let</b> g_p = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_p_p);
        // If popped node's parent was a left child, <b>update</b> popped
        // node's grandparent <b>to</b> have <b>as</b> its child the popped node's
        // sibling. Else the right child
        <b>if</b> (g_p.l == i_p) g_p.l = i_s <b>else</b> g_p.r = i_s;
    };
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_push_back_insert_nodes"></a>

## Function `push_back_insert_nodes`

Push back a new inner node and outer node into tree <code>cb</code>, where
the new outer node should have key <code>k</code>, value <code>v</code>, and have as
its parent the new inner node at vector index <code>i_n_i</code>, which
should have critical bit <code>c</code>, parent field index <code>i_p</code>, and if
<code>i_n_c_c</code> is <code><b>true</b></code>, left child field index <code>c1</code> and right child
field index <code>c2</code>. If the "inner node child condition" is <code><b>false</b></code>
the polarity of the children should be flipped


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_push_back_insert_nodes">push_back_insert_nodes</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, v: V, i_n_i: u64, c: u8, i_p: u64, i_n_c_c: bool, c1: u64, c2: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_push_back_insert_nodes">push_back_insert_nodes</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    v: V,
    i_n_i: u64,
    c: u8,
    i_p: u64,
    i_n_c_c: bool,
    c1: u64,
    c2: u64,
) {
    // If inner node child condition marked <b>true</b>, declare left child
    // field for new inner node <b>as</b> c1 and right <b>as</b> c2, <b>else</b> flip
    <b>let</b> (l, r) = <b>if</b> (i_n_c_c) (c1, c2) <b>else</b> (c2, c1);
    // Push back new outer node <b>with</b> new inner node <b>as</b> parent
    v_pu_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>{k, v, p: i_n_i});
    // Push back new inner node <b>with</b> specified parent and children
    v_pu_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, <a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>{c, p: i_p, l, r});
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_search_outer"></a>

## Function `search_outer`

Walk from root tree <code>cb</code> having an inner node as its root,
branching left or right at each inner node depending on whether
<code>k</code> is unset or set, respectively, at the given critical bit.
After arriving at an outer node, then return:
* <code>u64</code>: index of search outer node (with node type bit flag)
* <code>bool</code>: the side, <code><a href="CritBit.md#0xc0deb00c_CritBit_L">L</a></code> or <code><a href="CritBit.md#0xc0deb00c_CritBit_R">R</a></code>, on which the search outer node
is a child of its parent
* <code>u128</code>: key of search outer node
* <code>u64</code>: vector index of parent of search outer node
* <code>u8</code>: critical bit indicated by parent of search outer node


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_search_outer">search_outer</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128): (u64, bool, u128, u64, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_search_outer">search_outer</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128
): (
    u64,
    bool,
    u128,
    u64,
    u8,
) {
    // Initialize search parent <b>to</b> root
    <b>let</b> s_p = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, cb.r);
    <b>loop</b> { // Loop over inner nodes until branching <b>to</b> outer node
        // If key set at critical bit, track field index and side of
        // <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a> child, <b>else</b> <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>
        <b>let</b> (i, s) = <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, s_p.c)) (s_p.r, <a href="CritBit.md#0xc0deb00c_CritBit_R">R</a>) <b>else</b> (s_p.l, <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>);
        <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i)) { // If child is outer node
            // Borrow immutable reference <b>to</b> it
            <b>let</b> s_o = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i));
            // Return child field index of search outer node, its
            // side <b>as</b> a child, its key, the <a href="">vector</a> index of its
            // parent, and parent's indicated critical bit
            <b>return</b> (i, s, s_o.k, s_o.p, s_p.c)
        };
        s_p = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i); // Search next inner node
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_stitch_child_of_parent"></a>

## Function `stitch_child_of_parent`

Update parent node at index <code>i_p</code> in <code>cb</code> to reflect as its
child a node that has been relocated from old child field index
<code>i_o</code> to new child field index <code>i_n</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, i_n: u64, i_p: u64, i_o: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    i_n: u64,
    i_p: u64,
    i_o: u64
) {
    // Borrow mutable reference <b>to</b> parent
    <b>let</b> p = v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_p);
    // If relocated node was previously left child, <b>update</b>
    // parent's left child <b>to</b> indicate the relocated node's new
    // position, otherwise do <b>update</b> for right child of parent
    <b>if</b> (p.l == i_o) p.l = i_n <b>else</b> p.r = i_n;
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_stitch_parent_of_child"></a>

## Function `stitch_parent_of_child`

Update child node at child field index <code>i_c</code> in <code>cb</code> to reflect
as its parent an inner node that has be relocated to child field
index <code>i_n</code>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_stitch_parent_of_child">stitch_parent_of_child</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, i_n: u64, i_c: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_stitch_parent_of_child">stitch_parent_of_child</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    i_n: u64,
    i_c: u64
) {
    // If child is an outer node, borrow corresponding node and
    // <b>update</b> its parent field index <b>to</b> that of relocated node
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_c)) v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&<b>mut</b> cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_c)).p = i_n
        // Otherwise perform <b>update</b> on an inner node
        <b>else</b> v_b_m&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&<b>mut</b> cb.i, i_c).p = i_n;
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_stitch_swap_remove"></a>

## Function `stitch_swap_remove`

Repair a broken parent-child relationship in <code>cb</code> caused by
swap removing, for relocated node now at index indicated by
child field index <code>i_n</code>, in vector that contained <code>n_n</code> nodes
before the swap remove (when relocated node was last in vector)


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_stitch_swap_remove">stitch_swap_remove</a>&lt;V&gt;(cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, i_n: u64, n_n: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_stitch_swap_remove">stitch_swap_remove</a>&lt;V&gt;(
    cb: &<b>mut</b> <a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    i_n: u64,
    n_n: u64
) {
    // If child field index indicates relocated outer node
    <b>if</b> (<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(i_n)) {
        // Get node's parent field index
        <b>let</b> i_p = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_O">O</a>&lt;V&gt;&gt;(&cb.o, <a href="CritBit.md#0xc0deb00c_CritBit_o_v">o_v</a>(i_n)).p;
        // If root node was relocated, <b>update</b> root field and <b>return</b>
        <b>if</b> (i_p == <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>) {cb.r = i_n; <b>return</b>};
        // Else <b>update</b> parent <b>to</b> reflect relocated node position
        <a href="CritBit.md#0xc0deb00c_CritBit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(cb, i_n, i_p, <a href="CritBit.md#0xc0deb00c_CritBit_o_c">o_c</a>(n_n - 1));
    } <b>else</b> { // If child field index indicates relocated inner node
        // Borrow mutable reference <b>to</b> it
        <b>let</b> n = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, i_n);
        // Get field index of node's parent and children
        <b>let</b> (i_p, i_l, i_r) = (n.p, n.l, n.r);
        // Update children <b>to</b> have relocated node <b>as</b> their parent
        <a href="CritBit.md#0xc0deb00c_CritBit_stitch_parent_of_child">stitch_parent_of_child</a>(cb, i_n, i_l); // Left child
        <a href="CritBit.md#0xc0deb00c_CritBit_stitch_parent_of_child">stitch_parent_of_child</a>(cb, i_n, i_r); // Right child
        // If root node relocated, <b>update</b> root field and <b>return</b>
        <b>if</b> (i_p == <a href="CritBit.md#0xc0deb00c_CritBit_ROOT">ROOT</a>) {cb.r = i_n; <b>return</b>};
        // Else <b>update</b> parent <b>to</b> reflect relocated node position
        <a href="CritBit.md#0xc0deb00c_CritBit_stitch_child_of_parent">stitch_child_of_parent</a>&lt;V&gt;(cb, i_n, i_p, n_n - 1);
    }
}
</code></pre>



</details>

<a name="0xc0deb00c_CritBit_traverse_c_i"></a>

## Function `traverse_c_i`

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

* <code>cb</code>: Crit-bit tree containing at least two nodes
* <code>k</code>: Start key. If predecessor traversal, <code>k</code> cannot be
minimum key in <code>cb</code>, since this key does not have a
predecessor. Likewise, if successor traversal, <code>k</code> cannot be
maximum key in <code>cb</code>, since this key does not have a successor
* <code>p_f</code>: Start node's parent field
* <code>d</code>: Direction to traverse. If <code><a href="CritBit.md#0xc0deb00c_CritBit_L">L</a></code>, predecessor traversal,
else successor traversal


<a name="@Returns_40"></a>

### Returns

* <code>u64</code>: Child field index of target node


<a name="@Considerations_41"></a>

### Considerations

* Assumes passed start key is not minimum key in tree if
predecessor traversal, and that passed start key is not
maximum key in tree if successor traversal
* Takes an exposed vector index (<code>p_f</code>) as a parameter


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>&lt;V&gt;(cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CritBit::CB</a>&lt;V&gt;, k: u128, p_f: u64, d: bool): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="CritBit.md#0xc0deb00c_CritBit_traverse_c_i">traverse_c_i</a>&lt;V&gt;(
    cb: &<a href="CritBit.md#0xc0deb00c_CritBit_CB">CB</a>&lt;V&gt;,
    k: u128,
    p_f: u64,
    d: bool,
): u64 {
    // Borrow immutable reference <b>to</b> start node's parent
    <b>let</b> p = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, p_f);
    // If start key is set at parent node's critical bit, then the
    // upward walk <b>has</b> reach an inner node via its right child. This
    // is the <b>break</b> condition for successor traversal, when d is <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>,
    // a constant value that evaluates <b>to</b> <b>true</b>. The inverse case
    // applies for predecessor traversal, so <b>continue</b> upward walk
    // <b>as</b> long <b>as</b> d is not equal <b>to</b> the conditional critbit check
    <b>while</b> (d != <a href="CritBit.md#0xc0deb00c_CritBit_is_set">is_set</a>(k, p.c)) { // While <b>break</b> condition not met
        // Borrow immutable reference <b>to</b> next parent in upward walk
        p = v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, p.p);
    }; // Now at apex node
    // If predecessor traversal get left child field of apex node,
    // <b>else</b> left right field
    <b>let</b> c_f = <b>if</b> (d == <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>) p.l <b>else</b> p.r;
    <b>while</b> (!<a href="CritBit.md#0xc0deb00c_CritBit_is_out">is_out</a>(c_f)) { // While child field indicates inner node
        // If predecessor traversal review child's right child next,
        // <b>else</b> review child's left child next
        c_f = <b>if</b> (d == <a href="CritBit.md#0xc0deb00c_CritBit_L">L</a>) v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, c_f).r <b>else</b> v_b&lt;<a href="CritBit.md#0xc0deb00c_CritBit_I">I</a>&gt;(&cb.i, c_f).l;
    }; // Child field now indicates target node
    c_f // Return child field index of target node
}
</code></pre>



</details>
