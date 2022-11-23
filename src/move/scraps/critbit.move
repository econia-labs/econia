/// # Module-level documentation sections
///
/// * [Background](#Background)
/// * [Implementation](#Implementation)
/// * [Basic public functions](#Basic-public-functions)
/// * [Traversal](#Traversal)
///
/// # Background
///
/// A critical bit (crit-bit) tree is a compact binary prefix tree,
/// similar to a binary search tree, that stores a prefix-free set of
/// bitstrings, like n-bit integers or variable-length 0-terminated byte
/// strings. For a given set of keys there exists a unique crit-bit tree
/// representing the set, hence crit-bit trees do not require complex
/// rebalancing algorithms like those of AVL or red-black binary search
/// trees. Crit-bit trees support the following operations, quickly:
///
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Predecessor
/// * Successor
/// * Iteration
///
/// ## References
///
/// * [Bernstein 2006](https://cr.yp.to/critbit.html)
/// * [Langley 2008](
///   https://www.imperialviolet.org/2008/09/29/critbit-trees.html)
/// * [Langley 2012](https://github.com/agl/critbit)
/// * [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)
///
/// # Implementation
///
/// ## Structure
///
/// The present implementation involves a tree with two types of nodes,
/// inner (`InnerNode`) and outer (`OuterNode`). Inner nodes have two
/// children each (`InnerNode.left_child_index` and
/// `InnerNode.right_child_index`), while outer nodes have no children.
/// There are no nodes that have exactly one child. Outer nodes store a
/// key-value pair with a 128-bit integer as a key (`OuterNode.key`),
/// and an arbitrary value of generic type (`OuterNode.value`). Inner
/// nodes do not store a key, but rather, an 8-bit integer
/// (`InnerNode.critical_bit`) indicating the most-significant critical
/// bit (crit-bit) of divergence between keys located within the node's
/// two subtrees: keys in the node's left subtree are unset at the
/// critical bit, while keys in the node's right subtree are set at the
/// critical bit. Both node types have a parent field
/// (`InnerNode.parent_index`, `OuterNode.parent_index`), which may be
/// flagged as `ROOT` if the the node is the root.
///
/// Bit numbers are 0-indexed starting at the least-significant bit
/// (LSB), such that a critical bit of 3, for instance, corresponds to a
/// comparison between `00...00000` and `00...01111`. Inner nodes are
/// arranged hierarchically, with the most significant critical bits at
/// the top of the tree. For instance, the keys `001`, `101`, `110`, and
/// `111` would be stored in a `CritBitTree` tree as follows (right
/// carets included at left of illustration per issue with documentation
/// build engine, namely, the automatic stripping of leading whitespace
/// in documentation comments, which prohibits the simple initiation of
/// monospaced code blocks through indentation by 4 spaces):
/// ```
/// >       2nd
/// >      /   \
/// >    001   1st
/// >         /   \
/// >       101   0th
/// >            /   \
/// >          110   111
/// ```
/// Here, the inner node marked `2nd` stores the integer 2, the inner
/// node marked `1st` stores the integer 1, and the inner node marked
/// `0th` stores the integer 0. Hence, the sole key in the left subtree
/// of the inner node marked `2nd` is unset at bit 2, while all the keys
/// in the node's right subtree are set at bit 2. And similarly for the
/// inner node marked `0th`, its left child is unset at bit 0, while its
/// right child is set at bit 0.
///
/// ## Node indices
///
/// Both `InnerNode`s and `OuterNode`s are stored in vectors
/// (`CritBitTree.inner_nodes` and `CritBitTree.outer_nodes`), and
/// parent-child relationships between nodes are described in terms of
/// vector indices: an outer node having `OuterNode.parent_index = 123`,
/// for instance, has as its parent an inner node at vector index `123`.
/// Notably, the vector index of an inner node is identical to the
/// number indicated by its child's `parent_index`
/// (`InnerNode.parent_index` or `OuterNode.parent_index`), but the
/// vector index of an outer node is **not** identical to the number
/// indicated by its parent's `child_index`
/// (`InnerNode.left_child_index` or `InnerNode.right_child_index`),
/// because the 63rd bit of a so-called "field index" (the number stored
/// in a struct field) is reserved for a node type bit flag, with outer
/// nodes having bit 63 set and inner nodes having bit 63 unset. This
/// schema enables discrimination between node types based solely on the
/// "field index" of a related node via `is_outer_node()`, but requires
/// that outer node indices be routinely converted between "child field
/// index" form and "vector index" form via `outer_node_child_index()`
/// and `outer_node_vector_index()`.
///
/// Similarly, if a node, inner or outer, is located at the root, its
/// `parent_index` will indicate `ROOT`, and will not correspond to the
/// vector index of any inner node, since the root node does not have a
/// parent. Likewise, the "root field" of the tree (`CritBitTree.root`)
/// will contain the field index of the given node, set at bit 63 if the
/// root is an outer node.
///
/// # Basic public functions
///
/// ## Initialization
/// * `empty()`
/// * `singleton()`
///
/// ## Mutation
/// * `borrow_mut()`
/// * `insert()`
/// * `pop()`
///
/// ## Lookup
/// * `borrow()`
/// * `has_key()`
/// * `max_key()`
/// * `min_key()`
///
/// ## Size
/// * `is_empty()`
/// * `length()`
///
/// ## Destruction
/// * `destroy_empty()`
///
/// # Traversal
///
/// [Predecessor public functions](#Predecessor-public-functions) and
/// [successor public functions](#Successor-public-functions) are
/// wrapped [generic public functions](#Generic-public-functions),
/// with documentation comments from `traverse_target_child_index()` as
/// well as [generic public functions](#Generic-public-functions)
/// detailing the relevant algorithms. See [walkthrough](#Walkthrough)
/// for canonical implementation syntax.
///
/// ## Predecessor public functions
/// * `traverse_predecessor_init_mut()`
/// * `traverse_predecessor_mut()`
/// * `traverse_predecessor_pop_mut()`
///
/// ## Successor public functions
/// * `traverse_successor_init_mut()`
/// * `traverse_successor_mut()`
/// * `traverse_successor_pop_mut()`
///
/// ## Generic public functions
/// * `traverse_init_mut()`
/// * `traverse_mut()`
/// * `traverse_pop_mut()`
///
/// ## Public end on pop function
/// * `traverse_end_pop()`
///
/// ## Private traversal function
/// * `traverse_target_child_index()`
///
/// ## Walkthrough
/// * [Syntax motivations](#Syntax-motivations)
/// * [Full predecessor traversal](#Full-predecessor-traversal)
/// * [Partial successor traversal](#Partial-successor-traversal)
/// * [Singleton traversal initialization
///   ](#Singleton-traversal-initialization)
/// * [Ending traversal on a pop](#Ending-traversal-on-a-pop)
///
/// ### Syntax motivations
///
/// Iterated traversal, unlike other public implementations, exposes
/// internal [node indices](#Node-indices) that must be tracked during
/// loopwise operations, because Move's borrow-checking system prohibits
/// mutably borrowing a `CritBitTree` when an `InnerNode` or `OuterNode`
/// is already being mutably borrowed. Not that this borrow-checking
/// constraint introduces an absolute prohibition on iterated traversal
/// without exposed node indices, but rather, the given borrow-checking
/// constraints render non-node-index-exposed traversal inefficient: to
/// traverse without exposing internal node indices would require
/// searching for a key from the root during each iteration. Instead, by
/// publicly exposing node indices, it is possible to traverse from one
/// outer node to the next without having to perform such redundant
/// operations, per `traverse_target_child_index()`.
///
/// The test `traverse_demo()` provides canonical traversal syntax
/// in this regard, with exposed node indices essentially acting as
/// pointers. Hence, node-index-exposed traversal presents a kind of
/// circumvention of Move's borrow-checking system, implemented only
/// due to a need for greater efficiency. Like pointer-based
/// implementations in general, this solution is extremely powerful in
/// terms of the speed enhancement it provides, but if used incorrectly
/// it can lead to "undefined behavior." As such, a breakdown of the
/// canonical syntax is provided below, along with additional discussion
/// on error-checking facilities that have been intentionally excluded
/// in the interest of efficiency.
///
/// ### Full predecessor traversal
///
/// To start, initialize a tree with {$n, 100n$}, for $0 < n < 10$:
///
/// ```move
/// let tree = empty(); // Initialize empty tree
/// // Insert {n, 100 * n} for 0 < n < 10, out of order
/// insert(&mut tree, 9, 900);
/// insert(&mut tree, 6, 600);
/// insert(&mut tree, 3, 300);
/// insert(&mut tree, 1, 100);
/// insert(&mut tree, 8, 800);
/// insert(&mut tree, 2, 200);
/// insert(&mut tree, 7, 700);
/// insert(&mut tree, 5, 500);
/// insert(&mut tree, 4, 400);
/// ```
///
/// Before starting traversal, first verify that the tree is not empty:
///
/// ```move
/// assert!(!is_empty(&tree), 0); // Assert tree not empty
/// ```
///
/// This check could be performed within the generalized initialization
/// function, `traverse_init_mut()`, but doing so would introduce
/// compounding computational overhead, especially for applications
/// where traversal is repeatedly initialized after having already
/// established that the tree in question is not empty. Hence it is
/// assumed that any functions which call traversal initializers will
/// only do so after having verified that node iteration is possible in
/// the first place, and that they will track loop counters to prevent
/// an attempted traversal past the end of the tree. The loop counters
/// in question include a counter for the number of keys in the tree,
/// which must be decremented if any nodes are popped during traversal,
/// and a counter for the number of remaining traversals possible:
///
/// ```move
/// let n_keys = length(&tree); // Get number of keys in the tree
/// // Get number of remaining traversals possible
/// let remaining_traversals = n_keys - 1;
/// ```
///
/// Continuing the example, then initialize predecessor traversal per
/// `traverse_predecessor_init_mut()`, storing the max key in the tree,
/// a mutable reference to its corresponding value, the parent field of
/// the corresponding node, and the child field index of the
/// corresponding node. Again, since Move's documentation build engine
/// strips leading whitespace, right carets are included to preserve
/// indentation:
///
/// ```move
/// > // Initialize predecessor traversal: get max key in tree,
/// > // mutable reference to corresponding value, parent field of
/// > // corresponding node, and the child field index of it
/// > let (key, value_ref, parent_index, child_index) =
/// >     traverse_predecessor_init_mut(&mut tree);
/// ```
///
/// Now perform an inorder predecessor traversal, popping out the node
/// for any keys that are a multiple of 4, otherwise incrementing the
/// corresponding value by a monotonically increasing multiple of 10,
/// starting at 10, with the exception of the final node, which has its
/// value set to 0. Hence, {9, 900} updates to {9, 910}, {8, 800} gets
/// popped, {7, 700} updates to {7, 720}, and so on, until {1, 100} gets
/// updated to {1, 0}.
///
/// ```move
/// > let i = 10; // Initialize value increment counter
/// > // While remaining traversals possible
/// > while(remaining_traversals > 0) {
/// >     if (key % 4 == 0) { // If key is a multiple of 4
/// >         // Traverse pop corresponding node and discard its value
/// >         (key, value_ref, parent_index, child_index, _) =
/// >             traverse_predecessor_pop_mut(
/// >                 &mut tree, key, parent_index, child_index, n_keys);
/// >         n_keys = n_keys - 1; // Decrement key count
/// >     } else { // If key is not a multiple of 4
/// >         // Increment corresponding value
/// >         *value_ref = *value_ref + i;
/// >         i = i + 10; // Increment by 10 more next iteration
/// >         // Traverse to predecessor
/// >         (key, value_ref, parent_index, child_index) =
/// >             traverse_predecessor_mut(&mut tree, key, parent_index);
/// >     };
/// >     // Decrement remaining traversal count
/// >     remaining_traversals = remaining_traversals - 1;
/// > }; // Traversal has ended up at node having minimum key
/// > *value_ref = 0; // Set corresponding value to 0
/// ```
///
/// After the traversal, {4, 400} and {8, 800} have thus been popped,
/// and key-value pairs have updated accordingly:
///
/// ```move
/// // Assert keys popped correctly
/// assert!(!has_key(&tree, 4) && !has_key(&tree, 8), 1);
/// // Assert keys popped correctly
/// assert!(!has_key(&tree, 4) && !has_key(&tree, 8), 1);
/// // Assert correct value updates
/// assert!(*borrow(&tree, 1) ==   0, 2);
/// assert!(*borrow(&tree, 2) == 260, 3);
/// assert!(*borrow(&tree, 3) == 350, 4);
/// assert!(*borrow(&tree, 5) == 540, 5);
/// assert!(*borrow(&tree, 6) == 630, 6);
/// assert!(*borrow(&tree, 7) == 720, 7);
/// assert!(*borrow(&tree, 9) == 910, 8);
/// ```
///
/// Here, the only assurance that the traversal does not go past the end
/// of the tree is the proper tracking of loop variables: again, the
/// relevant error-checking could have been implemented in a
/// corresponding traversal function, namely
/// `traverse_target_child_index()`, but this would introduce
/// compounding computational overhead. Since traversal already requires
/// precise management of loop counter variables and node indices, it is
/// assumed that they are managed correctly and thus no redundant
/// error-checking is implemented so as to improve efficiency.
///
/// ### Partial successor traversal
///
/// Continuing the example, since the number of keys was updated during
/// the last loop, simply check that key count is greater than 0 to
/// verify tree is not empty. Then re-initialize the remaining traversal
/// counter, and this time use a value increment counter for a
/// monotonically increasing multiple of 1. Then initialize successor
/// traversal:
///
/// ```move
/// > assert!(n_keys > 0, 9); // Assert tree still not empty
/// > // Re-initialize counters: remaining traversal, value increment
/// > (remaining_traversals, i) = (n_keys - 1, 1);
/// > // Initialize successor traversal
/// > (key, value_ref, parent_index, child_index) =
/// >     traverse_successor_init_mut(&mut tree);
/// ```
///
/// Here, if the key is equal to 7, then traverse pop the corresponding
/// node and store its value, then stop traversal:
///
/// ```move
/// > // Initialize variable to store value of matched node
/// > let value = 0;
/// > // While remaining traversals possible
/// > while(remaining_traversals > 0) {
/// >     if (key == 7) { // If key is 7
/// >         // Traverse pop corresponding node and store its value
/// >         (_, _, _, _, value) = traverse_successor_pop_mut(
/// >             &mut tree, key, parent_index, child_index, n_keys);
/// >         break // Stop traversal
/// >     } else { // For all keys not equal to 7
/// >         // Increment corresponding value
/// >         *value_ref = *value_ref + i;
/// >         // Traverse to successor
/// >         (key, value_ref, parent_index, child_index) =
/// >             traverse_successor_mut(&mut tree, key, parent_index);
/// >         i = i + 1; // Increment by 1 more next iteration
/// >     };
/// >     // Decrement remaining traversal count
/// >     remaining_traversals = remaining_traversals - 1;
/// > };
/// ```
/// Hence {7, 720} has been popped, {9, 910} has been left unmodified,
/// and other key-value pairs have been updated accordingly:
///
/// ```move
/// // Assert key popped correctly
/// assert!(!has_key(&tree, 7), 10);
/// // Assert value of popped node stored correctly
/// assert!(value == 720, 11);
/// // Assert values updated correctly
/// assert!(*borrow(&tree, 1) ==   1, 12);
/// assert!(*borrow(&tree, 2) == 262, 13);
/// assert!(*borrow(&tree, 3) == 353, 14);
/// assert!(*borrow(&tree, 5) == 544, 15);
/// assert!(*borrow(&tree, 6) == 635, 16);
/// assert!(*borrow(&tree, 9) == 910, 17);
/// ```
///
/// ### Singleton traversal initialization
///
/// Traversal initializers can still be validly called in the case of a
/// singleton tree:
///
/// ```move
/// > // Pop all key-value pairs except {9, 910}
/// > pop(&mut tree, 1);
/// > pop(&mut tree, 2);
/// > pop(&mut tree, 3);
/// > pop(&mut tree, 5);
/// > pop(&mut tree, 6);
/// > assert!(!is_empty(&tree), 18); // Assert tree not empty
/// > let n_keys = length(&tree); // Get number of keys in the tree
/// > // Get number of remaining traversals possible
/// > let remaining_traversals = n_keys - 1;
/// > // Initialize successor traversal
/// > (key, value_ref, parent_index, _) =
/// >     traverse_successor_init_mut(&mut tree);
/// ```
///
/// In this case, the value of the corresponding node can still be
/// updated, and a traversal loop can even be implemented, with the loop
/// simply being skipped over:
///
/// ```move
/// > *value_ref = 1234; // Update value of node having minimum key
/// > // While remaining traversals possible
/// > while(remaining_traversals > 0) {
/// >     *value_ref = 4321; // Update value of corresponding node
/// >     // Traverse to successor
/// >     (key, value_ref, parent_index, _) = traverse_successor_mut(
/// >         &mut tree, key, parent_index);
/// >     // Decrement remaining traversal count
/// >     remaining_traversals = remaining_traversals - 1;
/// > }; // This loop does not go through any iterations
/// > // Assert value unchanged via loop
/// > assert!(pop(&mut tree, 9) == 1234, 19);
/// > destroy_empty(tree); // Destroy empty tree
/// ```
///
/// ### Ending traversal on a pop
/// Traversal popping can similarly be executed, but without traversing
/// any further, via `traverse_end_pop()`, which can be invoked at any
/// point during iterated traversal, thus ending the traversal with a
/// pop. See the `traverse_end_pop_success()` test.
///
/// ---
///
module econia::critbit {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A crit-bit tree for key-value pairs with value type `V`
    struct CritBitTree<V> has store {
        /// Root node index. When bit 63 is set, root node is an outer
        /// node. Otherwise root is an inner node. 0 when tree is empty
        root: u64,
        /// Inner nodes
        inner_nodes: vector<InnerNode>,
        /// Outer nodes
        outer_nodes: vector<OuterNode<V>>
    }

    /// Inner node
    struct InnerNode has store {
        // Documentation comments, specifically for struct fields,
        // apparently do not support fenced code blocks unless they are
        // preceded by a blank line...
        /// Critical bit position. Bit numbers 0-indexed from LSB:
        ///
        /// ```
        /// >    11101...1010010101
        /// >     bit 5 = 0 -|    |- bit 0 = 1
        /// ```
        critical_bit: u8,
        /// Parent node vector index. `ROOT` when node is root,
        /// otherwise corresponds to vector index of an inner node.
        parent_index: u64,
        /// Left child node index. When bit 63 is set, left child is an
        /// outer node. Otherwise left child is an inner node.
        left_child_index: u64,
        /// Right child node index. When bit 63 is set, right child is
        /// an outer node. Otherwise right child is an inner node.
        right_child_index: u64
    }

    /// Outer node with key `k` and value `v`
    struct OuterNode<V> has store {
        /// Key, which would preferably be a generic type representing
        /// the union of {`u8`, `u64`, `u128`}. However this kind of
        /// union typing is not supported by Move, so the most general
        /// (and memory intensive) `u128` is instead specified strictly.
        /// Must be an integer for bitwise operations.
        key: u128,
        /// Value from node's key-value pair.
        value: V,
        /// Parent node vector index. `ROOT` when node is root,
        /// otherwise corresponds to vector index of an inner node.
        parent_index: u64,
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When a char in a bytestring is neither 0 nor 1
    const E_BIT_NOT_0_OR_1: u64 = 0;
    /// When attempting to destroy a non-empty tree
    const E_DESTROY_NOT_EMPTY: u64 = 1;
    /// When an insertion key is already present in a tree
    const E_HAS_KEY: u64 = 2;
    /// When unable to borrow from empty tree
    const E_BORROW_EMPTY: u64 = 3;
    /// When no matching key in tree
    const E_NOT_HAS_KEY: u64 = 4;
    /// When no more keys can be inserted
    const E_INSERT_FULL: u64 = 5;
    /// When attempting to pop from empty tree
    const E_POP_EMPTY: u64 = 6;
    /// When attempting to look up on an empty tree
    const E_LOOKUP_EMPTY: u64 = 7;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// `u128` bitmask with all bits set
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// `u64` bitmask with all bits set, to flag that a node is at root
    const ROOT: u64 = 0xffffffffffffffff;
    /// Most significant bit number for a `u128`
    const MSB_u128: u8 = 127;
    /// Bit number of node type flag in a `u64` vector index
    const NODE_TYPE: u8 = 63;
    /// Node type bit flag indicating inner node
    const INNER: u64 = 0;
    /// Node type bit flag indicating outer node
    const OUTER: u64 = 1;
    /// Left direction
    const LEFT: bool = true;
    /// Right direction
    const RIGHT: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return immutable reference to value corresponding to key `k` in
    /// `tree`, aborting if empty tree or no match
    public fun borrow<V>(
        tree: &CritBitTree<V>,
        key: u128,
    ): &V {
        assert!(!is_empty<V>(tree), E_BORROW_EMPTY); // Abort if empty
        // Borrow immutable reference to closest outer node
        let closest_outer_node_ref = borrow_closest_outer_node<V>(tree, key);
        // Abort if key not in tree
        assert!(closest_outer_node_ref.key == key, E_NOT_HAS_KEY);
        // Return immutable reference to corresponding value
        &closest_outer_node_ref.value
    }

    /// Return mutable reference to value corresponding to key `k` in
    /// `tree`, aborting if empty tree or no match
    public fun borrow_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
    ): &mut V {
        assert!(!is_empty<V>(tree), E_BORROW_EMPTY); // Abort if empty
        let closest_outer_node_ref_mut =
            borrow_closest_outer_node_mut<V>(tree, key);
        // Abort if key not in tree
        assert!(closest_outer_node_ref_mut.key == key, E_NOT_HAS_KEY);
        // Return mutable reference to corresponding value
        &mut closest_outer_node_ref_mut.value
    }

    /// Destroy empty tree `tree`
    public fun destroy_empty<V>(
        tree: CritBitTree<V>
    ) {
        assert!(is_empty(&tree), E_DESTROY_NOT_EMPTY);
        // Unpack root index and node vectors
        let CritBitTree{root: _, inner_nodes, outer_nodes} = tree;
        // Destroy empty inner node vector
        vector::destroy_empty(inner_nodes);
        // Destroy empty outer node vector
        vector::destroy_empty(outer_nodes);
    }

    /// Return an empty tree
    public fun empty<V>():
    CritBitTree<V> {
        CritBitTree{
            root: 0,
            inner_nodes: vector::empty<InnerNode>(),
            outer_nodes: vector::empty<OuterNode<V>>()
        }
    }

    /// Return true if `tree` has `key`
    public fun has_key<V>(
        tree: &CritBitTree<V>,
        key: u128,
    ): bool {
        if (is_empty<V>(tree)) return false; // Return false if empty
        // Return true if closest outer node has same key
        return borrow_closest_outer_node<V>(tree, key).key == key
    }

    /// Insert `key` and `value` into `tree`, aborting if `key` already
    /// in `tree`
    public fun insert<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V
    ) {
        let length = length(tree); // Get length of tree
        check_length(length); // Verify insertion can take place
        // Insert via one of three cases, depending on the length
        if (length == 0) insert_empty(tree, key, value) else
        if (length == 1) insert_singleton(tree, key, value) else
        insert_general(tree, key, value, length);
    }

    /// Return `true` if `tree` has no outer nodes
    public fun is_empty<V>(
        tree: &CritBitTree<V>
    ): bool {
        vector::is_empty<OuterNode<V>>(&tree.outer_nodes)
    }

    /// Return number of keys in `tree` (number of outer nodes)
    public fun length<V>(
        tree: &CritBitTree<V>
    ): u64 {
        vector::length<OuterNode<V>>(&tree.outer_nodes)
    }

    /// Return the maximum key in `tree`, aborting if `tree` is empty
    public fun max_key<V>(
        tree: &CritBitTree<V>,
    ): u128 {
        // Assert tree not empty
        assert!(!is_empty(tree), E_LOOKUP_EMPTY);
        // Return max key
        vector::borrow<OuterNode<V>>(
            &tree.outer_nodes,
            outer_node_vector_index(max_node_child_index<V>(tree))
        ).key
    }

    /// Return the minimum key in `tree`, aborting if `tree` is empty
    public fun min_key<V>(
        tree: &CritBitTree<V>,
    ): u128 {
        // Assert tree not empty
        assert!(!is_empty(tree), E_LOOKUP_EMPTY);
        // Return min key
        vector::borrow<OuterNode<V>>(
            &tree.outer_nodes,
            outer_node_vector_index(min_node_child_index<V>(tree))
        ).key
    }

    /// Pop from `tree` value corresponding to `key`, aborting if `tree`
    /// is empty or does not contain `key`
    public fun pop<V>(
        tree: &mut CritBitTree<V>,
        key: u128
    ): V {
        assert!(!is_empty(tree), E_POP_EMPTY); // Assert tree not empty
        let length = length(tree); // Get number of outer nodes in tree
        // If length 1, pop from singleton tree
        if (length == 1) pop_singleton(tree, key) else
            // Otherwise pop in the general case
            pop_general(tree, key, length)
    }

    /// Return a tree with one node having `key` and `value`
    public fun singleton<V>(
        key: u128,
        value: V
    ): CritBitTree<V> {
        let tree = CritBitTree{
            root: 0,
            inner_nodes: vector::empty<InnerNode>(),
            outer_nodes: vector::empty<OuterNode<V>>()
        };
        insert_empty<V>(&mut tree, key, value);
        tree
    }

    /// Initialize a mutable iterated inorder traversal in a tree having
    /// at least one outer node. See [traversal](#Traversal)
    ///
    /// # Parameters
    /// * `tree`: A crit-bit tree containing at least one outer node
    /// * `direction`: Direction to traverse. If `LEFT`, initialize
    ///   predecessor traversal, else successor traversal
    ///
    /// # Returns
    /// * `u128`: Maximum key in `tree` if `direction` is `LEFT`, else
    ///    minimum key
    /// * `&mut V`: Mutable reference to corresponding node's value
    /// * `u64`: Parent field of corresponding node
    /// * `u64`: Child field index of corresponding node
    ///
    /// # Considerations
    /// * Exposes node indices
    /// * Assumes caller has already verified tree is not empty
    public fun traverse_init_mut<V>(
        tree: &mut CritBitTree<V>,
        direction: bool,
    ): (
        u128,
        &mut V,
        u64,
        u64
    ) {
        // If predecessor traversal, get child field index of node
        // having maximum key, else node having minimum key
        let child_field_index = if (direction == LEFT)
            max_node_child_index(tree) else
            min_node_child_index(tree);
        // Borrow mutable reference to node
        let node = vector::borrow_mut<OuterNode<V>>(&mut tree.outer_nodes,
            outer_node_vector_index(child_field_index));
        // Return node's key, mutable reference to its value, its parent
        // field, and the child field index of it
        (node.key, &mut node.value, node.parent_index, child_field_index)
    }

    /// Wrapped `traverse_target_child_index()` call for enumerated
    /// return extraction. See [traversal](#Traversal)
    ///
    /// # Returns
    /// * `u128`: Target key
    /// * `&mut V`: Mutable reference to target node's value
    /// * `u64`: Target node's parent field
    /// * `u64`: Child field index of target node
    public fun traverse_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        parent_index: u64,
        direction: bool
    ): (
        u128,
        &mut V,
        u64,
        u64
    ) {
        // Get child field index of target node
        let target_child_index =
            traverse_target_child_index<V>(tree, key, parent_index, direction);
        // Borrow mutable reference to target node
        let node = vector::borrow_mut<OuterNode<V>>(&mut tree.outer_nodes,
            outer_node_vector_index(target_child_index));
        // Return target node's key, mutable reference to its value, its
        // parent field, and child field index of it
        (node.key, &mut node.value, node.parent_index, target_child_index)
    }

    /// Traverse in the specified direction from the node containing the
    /// specified key (the "start node" containing the "start key") to
    /// either the inorder predecessor or the inorder successor to the
    /// start key (the "target node" containing the "target key"), then
    /// pop the start node and return its value. See
    /// [traversal](#Traversal)
    ///
    /// # Parameters
    /// * `tree`: Crit-bit tree containing at least two nodes
    /// * `key`: Start key. If predecessor traversal, cannot be minimum
    ///   key in `tree`, since this key does not have a predecessor.
    ///   Likewise, if successor traversal, cannot be maximum key in
    ///   `tree`, since this key does not have a successor
    /// * `parent_index`: Start node's parent field
    /// * `child_index`: Child index of start node
    /// * `n_outer_nodes`: Number of outer nodes in `tree`
    /// * `direction`: Direction to traverse. If `LEFT`, predecessor
    ///   traversal, else successor traversal
    ///
    /// # Returns
    /// * `u128`: Target key
    /// * `&mut V`: Mutable reference to target node's value
    /// * `u64`: Target node's parent field
    /// * `u64`: Child field index of target node
    /// * `V`: Popped start node's value
    ///
    /// # Considerations
    /// * Assumes passed start key is not minimum key in tree if
    ///   predecessor traversal, and that passed start key is not
    ///   maximum key in tree if successor traversal
    /// * Takes exposed node indices (`parent_index`, `child_index`) as
    ///   parameters
    /// * Does not calculate number of outer nodes in `tree`, but rather
    ///   accepts this number as a parameter (`n_outer_nodes`), which
    ///   should be tracked by the caller
    public fun traverse_pop_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        parent_index: u64,
        child_index: u64,
        n_outer_nodes: u64,
        direction: bool
    ): (
        u128,
        &mut V,
        u64,
        u64,
        V
    ) {
        // Mark start node's side as a child as left (true) if node's
        // parent has the node as its left child, else right (false)
        let start_child_side = vector::borrow<InnerNode>(
            &tree.inner_nodes, parent_index).left_child_index == child_index;
        // Store target node's pre-pop child field index
        let target_child_index = traverse_target_child_index(
            tree, key, parent_index, direction);
        // Update relationships for popped start node
        pop_update_relationships(tree, start_child_side, parent_index);
        // Store start node value from pop-facilitated node destruction
        let start_value =
            pop_destroy_nodes(tree, parent_index, child_index, n_outer_nodes);
        // If target node was last in outer node vector, then swap
        // remove will have relocated it, so update its post-pop field
        // index to the start node's pre-pop field index
        if (outer_node_vector_index(target_child_index) == n_outer_nodes - 1)
            target_child_index = child_index;
        // Borrow mutable reference to target node
        let target_node = vector::borrow_mut<OuterNode<V>>(
            &mut tree.outer_nodes,
            outer_node_vector_index(target_child_index));
        // Return target node's key, mutable reference to its value, its
        // parent field, the child field index of it, and the start
        // node's popped value
        (target_node.key, &mut target_node.value, target_node.parent_index,
            target_child_index, start_value)
    }

    /// Terminate iterated traversal by popping the outer node for the
    /// current iteration, without traversing further. Implements
    /// similar algorithms as `pop_general()`, but without having to
    /// do another search from root.
    ///
    /// # Parameters
    /// * `tree`: Crit-bit tree containing at least one node
    /// * `parent_index`: Node's parent field
    /// * `child_index`: Child field index of node
    /// * `n_outer_node`: Number of outer nodes in `tree`
    ///
    /// # Returns
    /// * `V`: Popped value from outer node
    ///
    /// # Considerations
    /// * Takes exposed node indices (`parent_index`, `child_index`) as
    ///   parameters
    /// * Does not calculate number of outer nodes in `tree`, but rather
    ///   accepts this number as a parameter (`n_outer_nodes`), which
    ///   should be tracked by the caller and should be nonzero
    public fun traverse_end_pop<V>(
        tree: &mut CritBitTree<V>,
        parent_index: u64,
        child_index: u64,
        n_outer_nodes: u64,
    ): V {
        if (n_outer_nodes == 1) { // If popping only node in tree
            tree.root = 0; // Update root
            // Pop off and unpack outer node at root
            let OuterNode{key: _, value, parent_index: _} =
                vector::pop_back<OuterNode<V>>(&mut tree.outer_nodes);
            value // Return popped value
        } else { // If popping from tree with more than 1 outer node
            // Mark node's side as a child as left (true) if node's
            // parent has the node as its left child, else right (false)
            let node_child_side = vector::borrow<InnerNode>(&tree.inner_nodes,
                parent_index).left_child_index == child_index;
            // Update sibling, parent, grandparent relationships
            pop_update_relationships(tree, node_child_side, parent_index);
            // Destroy old nodes, returning popped value
            pop_destroy_nodes(tree, parent_index, child_index, n_outer_nodes)
        }
    }


    /// Wrapped `traverse_init_mut()` call for predecessor traversal.
    /// See [traversal walkthrough](#Walkthrough)
    public fun traverse_predecessor_init_mut<V>(
        tree: &mut CritBitTree<V>,
    ): (
        u128,
        &mut V,
        u64,
        u64
    ) {
        traverse_init_mut(tree, LEFT)
    }

    /// Wrapped `traverse_mut()` call for predecessor traversal. See
    /// [traversal walkthrough](#Walkthrough)
    public fun traverse_predecessor_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        parent_index: u64
    ): (
        u128,
        &mut V,
        u64,
        u64
    ) {
        traverse_mut<V>(tree, key, parent_index, LEFT)
    }

    /// Wrapped `traverse_pop_mut()` call for predecessor traversal. See
    /// [traversal walkthrough](#Walkthrough)
    public fun traverse_predecessor_pop_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        parent_index: u64,
        child_index: u64,
        n_outer_nodes: u64
    ): (
        u128,
        &mut V,
        u64,
        u64,
        V
    ) {
        traverse_pop_mut(tree, key, parent_index, child_index, n_outer_nodes,
            LEFT)
    }

    /// Wrapped `traverse_init_mut()` call for successor traversal.
    /// See [traversal walkthrough](#Walkthrough)
    public fun traverse_successor_init_mut<V>(
        tree: &mut CritBitTree<V>,
    ): (
        u128,
        &mut V,
        u64,
        u64
    ) {
        traverse_init_mut(tree, RIGHT)
    }

    /// Wrapped `traverse_mut()` call for successor traversal. See
    /// [traversal walkthrough](#Walkthrough)
    public fun traverse_successor_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        parent_index: u64
    ): (
        u128,
        &mut V,
        u64,
        u64
    ) {
        traverse_mut<V>(tree, key, parent_index, RIGHT)
    }

    /// Wrapped `traverse_pop_mut()` call for successor traversal. See
    /// [traversal walkthrough](#Walkthrough)
    public fun traverse_successor_pop_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        parent_index: u64,
        child_index: u64,
        n_outer_nodes: u64
    ): (
        u128,
        &mut V,
        u64,
        u64,
        V
    ) {
        traverse_pop_mut(tree, key, parent_index, child_index, n_outer_nodes,
            RIGHT)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Walk non-empty tree `tree`, breaking out if at outer node,
    /// branching left or right at each inner node depending on whether
    /// `key` is unset or set, respectively, at the given critical bit.
    /// Then return mutable reference to the found outer node
    fun borrow_closest_outer_node<V>(
        tree: &CritBitTree<V>,
        key: u128,
    ): &OuterNode<V> {
        // If root is an outer node, return reference to it
        if (is_outer_node(tree.root)) return (vector::borrow<OuterNode<V>>(
            &tree.outer_nodes, outer_node_vector_index(tree.root)));
        // Otherwise borrow inner node at root
        let node = vector::borrow<InnerNode>(&tree.inner_nodes, tree.root);
        loop { // Loop over inner nodes
            // If key is set at critical bit, get index of child on R
            let child_index = if (is_set(key, node.critical_bit))
                // Otherwise L
                node.right_child_index else node.left_child_index;
            // If child is outer node, return reference to it
            if (is_outer_node(child_index)) return
                vector::borrow<OuterNode<V>>(&tree.outer_nodes,
                    outer_node_vector_index(child_index));
            // Borrow next inner node to review
            node = vector::borrow<InnerNode>(&tree.inner_nodes, child_index);
        }
    }

    /// Like `borrow_closest_outer_node()`, but for mutable reference
    fun borrow_closest_outer_node_mut<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
    ): &mut OuterNode<V> {
        // If root is an outer node, return mutable reference to it
        if (is_outer_node(tree.root)) return (vector::borrow_mut<OuterNode<V>>(
            &mut tree.outer_nodes, outer_node_vector_index(tree.root)));
        // Otherwise borrow inner node at root
        let node = vector::borrow<InnerNode>(&tree.inner_nodes, tree.root);
        loop { // Loop over inner nodes
            // If key is set at critical bit, get index of child on R
            let child_index = if (is_set(key, node.critical_bit))
                // Otherwise L
                node.right_child_index else node.left_child_index;
            // If child is outer node, return mutable reference to it
            if (is_outer_node(child_index)) return
                vector::borrow_mut<OuterNode<V>>(&mut tree.outer_nodes,
                    outer_node_vector_index(child_index));
            // Borrow next inner node to review
            node = vector::borrow<InnerNode>(&tree.inner_nodes, child_index);
        }
    }

    /// Assert that `length` is less than the value indicated by a
    /// bitmask where only the 63rd bit is not set (this bitmask
    /// corresponds to the maximum number of keys that can be stored in
    /// a tree, since the 63rd bit is reserved for the node type bit
    /// flag)
    fun check_length(
        length: u64
    ) {
        assert!(length < HI_64 ^ OUTER << NODE_TYPE, E_INSERT_FULL);
    }

    /// Return the number of the most significant bit (0-indexed from
    /// LSB) at which two non-identical bitstrings, `s1` and `s2`, vary.
    ///
    /// # XOR/AND method
    ///
    /// To begin with, a bitwise XOR is used to flag all differing bits:
    /// ```
    /// >           s1: 11110001
    /// >           s2: 11011100
    /// >  x = s1 ^ s2: 00101101
    /// >                 |- critical bit = 5
    /// ```
    /// Here, the critical bit is equivalent to the bit number of the
    /// most significant set bit in XOR result `x = s1 ^ s2`. At this
    /// point, [Langley 2012](#References) notes that `x` bitwise AND
    /// `x - 1` will be nonzero so long as `x` contains at least some
    /// bits set which are of lesser significance than the critical bit:
    /// ```
    /// >               x: 00101101
    /// >           x - 1: 00101100
    /// > x = x & (x - 1): 00101100
    /// ```
    /// Thus he suggests repeating `x & (x - 1)` while the new result
    /// `x = x & (x - 1)` is not equal to zero, because such a loop will
    /// eventually reduce `x` to a power of two (excepting the trivial
    /// case where `x` starts as all 0 except bit 0 set, for which the
    /// loop never enters past the initial conditional check). Per this
    /// method, using the new `x` value for the current example, the
    /// second iteration proceeds as follows:
    /// ```
    /// >               x: 00101100
    /// >           x - 1: 00101011
    /// > x = x & (x - 1): 00101000
    /// ```
    /// The third iteration:
    /// ```
    /// >               x: 00101000
    /// >           x - 1: 00100111
    /// > x = x & (x - 1): 00100000
    /// ```
    /// Now, `x & x - 1` will equal zero and the loop will not begin a
    /// fourth iteration:
    /// ```
    /// >             x: 00100000
    /// >         x - 1: 00011111
    /// > x AND (x - 1): 00000000
    /// ```
    /// Thus after three iterations a corresponding critical bit bitmask
    /// has been determined. However, in the case where the two input
    /// strings vary at all bits of lesser significance than that of the
    /// critical bit, there may be required as many as `k - 1`
    /// iterations, where `k` is the number of bits in each string under
    /// comparison. For instance, consider the case of the two 8-bit
    /// strings `s1` and `s2` as follows:
    /// ```
    /// >              s1: 10101010
    /// >              s2: 01010101
    /// >     x = s1 ^ s2: 11111111
    /// >                  |- critical bit = 7
    /// > x = x & (x - 1): 11111110 [iteration 1]
    /// > x = x & (x - 1): 11111100 [iteration 2]
    /// > x = x & (x - 1): 11111000 [iteration 3]
    /// > ...
    /// ```
    /// Notably, this method is only suggested after already having
    /// identified the varying byte between the two strings, thus
    /// limiting `x & (x - 1)` operations to at most 7 iterations.
    ///
    /// # Binary search method
    ///
    /// For the present implementation, strings are not partitioned into
    /// a multi-byte array, rather, they are stored as `u128` integers,
    /// so a binary search is instead proposed. Here, the same
    /// `x = s1 ^ s2` operation is first used to identify all differing
    /// bits, before iterating on an upper and lower bound for the
    /// critical bit number:
    /// ```
    /// >          s1: 10101010
    /// >          s2: 01010101
    /// > x = s1 ^ s2: 11111111
    /// >       u = 7 -|      |- l = 0
    /// ```
    /// The upper bound `u` is initialized to the length of the string
    /// (7 in this example, but 127 for a `u128`), and the lower bound
    /// `l` is initialized to 0. Next the midpoint `m` is calculated as
    /// the average of `u` and `l`, in this case `m = (7 + 0) / 2 = 3`,
    /// per truncating integer division. Now, the shifted compare value
    /// `s = r >> m` is calculated and updates are applied according to
    /// three potential outcomes:
    ///
    /// * `s == 1` means that the critical bit `c` is equal to `m`
    /// * `s == 0` means that `c < m`, so `u` is set to `m - 1`
    /// * `s > 1` means that `c > m`, so `l` us set to `m + 1`
    ///
    /// Hence, continuing the current example:
    /// ```
    /// >          x: 11111111
    /// > s = x >> m: 00011111
    /// ```
    /// `s > 1`, so `l = m + 1 = 4`, and the search window has shrunk:
    /// ```
    /// > x = s1 ^ s2: 11111111
    /// >       u = 7 -|  |- l = 4
    /// ```
    /// Updating the midpoint yields `m = (7 + 4) / 2 = 5`:
    /// ```
    /// >          x: 11111111
    /// > s = x >> m: 00000111
    /// ```
    /// Again `s > 1`, so update `l = m + 1 = 6`, and the window
    /// shrinks again:
    /// ```
    /// > x = s1 ^ s2: 11111111
    /// >       u = 7 -||- l = 6
    /// > s = x >> m: 00000011
    /// ```
    /// Again `s > 1`, so update `l = m + 1 = 7`, the final iteration:
    /// ```
    /// > x = s1 ^ s2: 11111111
    /// >       u = 7 -|- l = 7
    /// > s = x >> m: 00000001
    /// ```
    /// Here, `s == 1`, which means that `c = m = 7`. Notably this
    /// search has converged after only 3 iterations, as opposed to 7
    /// for the linear search proposed above, and in general such a
    /// search converges after $log_2(k)$ iterations at most, where $k$
    /// is the number of bits in each of the strings `s1` and `s2` under
    /// comparison. Hence this search method improves the $O(k)$ search
    /// proposed by [Langley 2012](#References) to $O(log_2(k))$, and
    /// moreover, determines the actual number of the critical bit,
    /// rather than just a bitmask with bit `c` set, as he proposes,
    /// which can also be easily generated via `1 << c`.
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

    /// Decomposed case specified in `insert_general`, walk up tree, for
    /// parameters:
    /// * `tree`: Tree to insert into
    /// * `key` : Key to insert
    /// * `value` : Value to insert
    /// * `n_outer_nodes` : Number of outer nodes in `tree` pre-insert
    /// * `n_inner_nodes` : Number of inner nodes in `tree` pre-insert
    ///    (index of new inner node)
    /// * `search_parent_index`: Index of search parent
    /// * `critical_bit`: Critical bit between insertion key and search
    ///   outer node
    fun insert_above<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V,
        n_outer_nodes: u64,
        n_inner_nodes: u64,
        search_parent_index: u64,
        critical_bit: u8
    ) {
        // Set index of node under review to search parent's parent
        let node_index = vector::borrow<InnerNode>(&tree.inner_nodes,
            search_parent_index).parent_index;
        loop { // Loop over inner nodes
            if (node_index == ROOT) { // If walk arrives at root
                // Insert above root
                return insert_above_root(tree, key, value, n_outer_nodes,
                    n_inner_nodes, critical_bit)
            } else { // If walk has not arrived at root
                // Borrow mutable reference to node under review
                let node = vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
                    node_index);
                // If critical bit between insertion key and search
                // outer node is less than that of node under review
                if (critical_bit < node.critical_bit) {
                    // Insert below node under review
                    return insert_below_walk(tree, key, value, n_outer_nodes,
                        n_inner_nodes, node_index, critical_bit)
                } else { // If need to insert above
                    // Review node under review's parent
                    node_index = node.parent_index;
                }
            }
        }
    }

    /// Decomposed case specified in `insert_general`, insertion above
    /// root, for parameters:
    /// * `tree`: Tree to insert into
    /// * `key` : Key to insert
    /// * `value` : Value to insert
    /// * `n_outer_nodes` : Number of keys (outer nodes) in `tree`
    ///   pre-insert
    /// * `n_inner_nodes` : Number of inner nodes in `tree` pre-insert
    ///   (index of new inner node)
    /// * `critical_bit`: Critical bit between insertion key and search
    ///   outer node
    fun insert_above_root<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V,
        n_outer_nodes: u64,
        n_inner_nodes: u64,
        critical_bit: u8
    ) {
        // Get index of old root to insert above
        let old_root_index = tree.root;
        // Set old root node to have new inner node as parent
        vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
            old_root_index).parent_index = n_inner_nodes;
        // Set root field index to indicate new inner node
        tree.root = n_inner_nodes;
        // Push back new inner and outer nodes, with inner node
        // indicating that it is root. If insertion key is set at
        // critical bit, new inner node should have as its left child
        // the previous root node and should have as its right child
        // the new outer node
        push_back_insert_nodes(
            tree, key, value, n_inner_nodes, critical_bit, ROOT,
            is_set(key, critical_bit), old_root_index,
            outer_node_child_index(n_outer_nodes));
    }

    /// Decomposed case specified in `insert_general`, insertion below
    /// search parent, for parameters:
    /// * `tree`: Tree to insert into
    /// * `key` : Key to insert
    /// * `value` : Value to insert
    /// * `n_outer_nodes` : Number of keys (outer nodes) in `tree`
    ///   pre-insert
    /// * `n_inner_nodes` : Number of inner nodes in `tree` pre-insert
    ///   (index of new inner node)
    /// * `search_index`: Child field index of search outer node (with
    ///   bit flag)
    /// * `search_child_side`: Side on which search outer node is child
    /// * `search_key`: Key of search outer node
    /// * `search_parent_index`: Index of search parent
    /// * `critical_bit`: Critical bit between insertion key and search
    ///   outer node
    fun insert_below<V>(
        tree: &mut CritBitTree<V>,
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
        // Borrow mutable reference to search parent
        let search_parent = vector::borrow_mut<InnerNode>(
            &mut tree.inner_nodes, search_parent_index);
        // Update search parent to have new inner node as child, on same
        // side that the search outer node was a child at
        if (search_child_side == LEFT) search_parent.left_child_index =
            n_inner_nodes else search_parent.right_child_index = n_inner_nodes;
        // Set search outer node to have new inner node as parent
        vector::borrow_mut<OuterNode<V>>(&mut tree.outer_nodes,
            outer_node_vector_index(search_index)).parent_index =
                n_inner_nodes;
        // Push back new inner and outer nodes, with inner node having
        // as its parent the search parent. If insertion key is less
        // than key of search outer node, new inner node should have as
        // its left child the new outer node and should have as its
        // right child the search outer node
        push_back_insert_nodes(tree, key, value, n_inner_nodes, critical_bit,
            search_parent_index, key < search_key,
            outer_node_child_index(n_outer_nodes), search_index);
    }

    /// Decomposed case specified in `insert_general`, insertion below
    /// a node encountered during walk, for parameters:
    /// * `tree`: Tree to insert into
    /// * `key` : Key to insert
    /// * `value` : Value to insert
    /// * `n_outer_nodes` : Number of keys (outer nodes) in `tree` pre-insert
    /// * `n_inner_nodes` : Number of inner nodes in `tree` pre-insert
    ///   (index of new inner node)
    /// * `review_node_index` : Index of node under review from walk
    /// * `critical_bit`: Critical bit between insertion key and search
    ///   outer node
    fun insert_below_walk<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V,
        n_outer_nodes: u64,
        n_inner_nodes: u64,
        review_node_index: u64,
        critical_bit: u8
    ) {
        // Borrow mutable reference to node under review
        let review_node = vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
            review_node_index);
        // If insertion key is set at critical bit indicated by node
        // under review, mark side and index of walked child as its
        // right child, else left
        let (walked_child_side, walked_child_index) =
            if (is_set(key, review_node.critical_bit))
                (RIGHT, review_node.right_child_index) else
                (LEFT, review_node.left_child_index);
        // Set node under review to have as child new inner node on same
        // side as walked child
        if (walked_child_side == LEFT)
            review_node.left_child_index = n_inner_nodes else
            review_node.right_child_index = n_inner_nodes;
        // Update walked child to have new inner node as its parent
        vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
            walked_child_index).parent_index = n_inner_nodes;
        // Push back new inner and outer nodes, with inner node having
        // as its parent the node under review. If insertion key is set
        // at critical bit, new inner node should have as its left child
        // the walked child of the node under review and should have as
        // its right child the new outer node
        push_back_insert_nodes(tree, key, value, n_inner_nodes, critical_bit,
            review_node_index, is_set(key, critical_bit), walked_child_index,
            outer_node_child_index(n_outer_nodes));
    }

    /// Insert key-value pair `key` and `value` into an empty `tree`
    fun insert_empty<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V
    ) {
        // Push back outer node onto tree's vector of outer nodes
        vector::push_back<OuterNode<V>>(&mut tree.outer_nodes,
            OuterNode<V>{key, value, parent_index: ROOT});
        // Set root index field to indicate 0th outer node
        tree.root = OUTER << NODE_TYPE;
    }

    /// Insert `key` and `value` into `tree` already having
    /// `n_outer_nodes` keys for general case where root is an inner
    /// node, aborting if `key` is already present. First, perform an
    /// outer node search and identify the critical bit of divergence
    /// between the search outer node and `k`. Then, if the critical bit
    /// is less than that of the search parent (`insert_below()`):
    ///
    /// * Insert a new inner node directly above the search outer node
    /// * Update the search outer node to have as its parent the new
    ///   inner node
    /// * Update the search parent to have as its child the new inner
    ///   node where the search outer node previously was:
    /// ```
    /// >       2nd
    /// >      /   \
    /// >    001   1st <- search parent
    /// >         /   \
    /// >       101   111 <- search outer node
    /// >
    /// >       Insert 110
    /// >       --------->
    /// >
    /// >                  2nd
    /// >                 /   \
    /// >               001   1st <- search parent
    /// >                    /   \
    /// >                  101   0th <- new inner node
    /// >                       /   \
    /// >   new outer node -> 110   111 <- search outer node
    /// ```
    /// Otherwise, begin walking back up the tree (`insert_above()`). If
    /// walk arrives at the root node, insert a new inner node above the
    /// root, updating associated relationships (`insert_above_root()`):
    /// ```
    /// >          1st
    /// >         /   \
    /// >       101   0th <- search parent
    /// >            /   \
    /// >          110    111 <- search outer node
    /// >
    /// >       Insert 011
    /// >       --------->
    /// >
    /// >                         2nd <- new inner node
    /// >                        /   \
    /// >    new outer node -> 011   1st
    /// >                           /   \
    /// >                         101   0th <- search parent
    /// >                              /   \
    /// >                            110   111 <- search outer node
    /// ```
    /// Otherwise, if walk arrives at a node indicating a critical bit
    /// larger than that between the insertion key and the search node,
    /// insert the new inner node below it (`insert_below_walk()`):
    /// ```
    /// >
    /// >           2nd
    /// >          /   \
    /// >        011   0th <- search parent
    /// >             /   \
    /// >           110   111 <- search outer node
    /// >
    /// >       Insert 100
    /// >       --------->
    /// >
    /// >                       2nd
    /// >                      /   \
    /// >                    001   1st <- new inner node
    /// >                         /   \
    /// >     new outer node -> 100   0th <- search parent
    /// >                            /   \
    /// >                          110   111 <- search outer node
    /// ```
    fun insert_general<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V,
        n_outer_nodes: u64
    ) {
        // Get number of inner nodes in tree (index of new inner node)
        let n_inner_nodes = vector::length<InnerNode>(&tree.inner_nodes);
        // Get field index of search outer node, its side as a child,
        // its key, the vector index of its parent, and the critical
        // bit indicated by the search parent
        let (search_index, search_child_side, search_key, search_parent_index,
            search_parent_critical_bit) = search_outer(tree, key);
        // Assert key not already in tree
        assert!(search_key != key, E_HAS_KEY);
        // Get critical bit between insertion key and search outer node
        let critical_bit = crit_bit(search_key, key);
        // If critical bit is less than that indicated by search parent
        if (critical_bit < search_parent_critical_bit) {
            // Insert new inner node below search parent
            insert_below(tree, key, value, n_outer_nodes, n_inner_nodes,
                search_index, search_child_side, search_key,
                search_parent_index, critical_bit);
        } else { // If need to insert new inner node above search parent
            insert_above(tree, key, value, n_outer_nodes, n_inner_nodes,
                search_parent_index, critical_bit);
        }
    }

    /// Insert `key` and `value` into singleton `tree`, aborting if
    /// `key` already in `tree`
    fun insert_singleton<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V
    ) {
        // Borrow existing outer node
        let outer_node = vector::borrow<OuterNode<V>>(&tree.outer_nodes, 0);
        // Assert insertion key not in tree
        assert!(key != outer_node.key, E_HAS_KEY);
        // Get critical bit between two keys
        let critical_bit = crit_bit(outer_node.key, key);
        // Push back new inner and outer nodes, with inner node
        // indicating that it is root. If insertion key is greater than
        // singleton key, new inner node should have as its left child
        // existing outer node and should have as its right child new
        // outer node
        push_back_insert_nodes(tree, key, value, 0, critical_bit, ROOT,
            key > outer_node.key, outer_node_child_index(0),
            outer_node_child_index(1));
        // Update tree root field to indicate new inner node
        tree.root = 0;
        // Update existing outer node to have new inner node as parent
        vector::borrow_mut<OuterNode<V>>(&mut tree.outer_nodes,
            0).parent_index = 0;
    }

    /// Return the child field index of the outer node containing the
    /// maximum key in non-empty tree `tree`
    fun max_node_child_index<V>(
        tree: &CritBitTree<V>
    ): u64 {
        // Initialize child field index of search node to root
        let child_field_index = tree.root;
        loop { // Loop over nodes
            // If search node is outer node return its child field index
            if (is_outer_node(child_field_index)) return child_field_index;
            // Review node's right child next
            child_field_index = vector::borrow<InnerNode>(&tree.inner_nodes,
                child_field_index).right_child_index
        }
    }

    /// Return the child field index of the outer node containing the
    /// minimum key in non-empty tree `tree`
    fun min_node_child_index<V>(
        tree: &CritBitTree<V>
    ): u64 {
        // Initialize child field index of search node to root
        let child_field_index = tree.root;
        loop { // Loop over nodes
            // If search node is outer node return its child field index
            if (is_outer_node(child_field_index)) return child_field_index;
            // Review node's left child next
            child_field_index = vector::borrow<InnerNode>(&tree.inner_nodes,
                child_field_index).left_child_index
        }
    }

    /// Return `true` if `child_field_index` indicates an outer node
    fun is_outer_node(
        child_field_index: u64
    ): bool {
        (child_field_index >> NODE_TYPE & OUTER == OUTER)
    }

    /// Return `true` if `key` is set at `bit_number`
    fun is_set(key: u128, bit_number: u8): bool {key >> bit_number & 1 == 1}

    /// Convert unflagged outer node `vector_index` to flagged child
    /// field index, by `OR` with a bitmask that has only a flag bit set
    fun outer_node_child_index(
        vector_index: u64
    ): u64 {
        vector_index | OUTER << NODE_TYPE
    }

    /// Convert flagged `child_field_index` to unflagged outer node
    /// vector index, by `AND` with a bitmask that has only flag bit
    /// unset
    fun outer_node_vector_index(
        child_field_index: u64
    ): u64 {
        child_field_index & HI_64 ^ OUTER << NODE_TYPE
    }

    /// Remove from `tree` inner node at child field index
    /// `inner_index`, and outer node at child field index `outer_index`
    /// (from node vector with `n_outer_nodes` outer nodes pre-pop).
    /// Then return the popped value from the outer node
    fun pop_destroy_nodes<V>(
        tree: &mut CritBitTree<V>,
        inner_index: u64,
        outer_index: u64,
        n_outer_nodes: u64
    ): V {
        // Get number of inner nodes pre-pop
        let n_inner_nodes = vector::length<InnerNode>(&tree.inner_nodes);
        // Swap remove parent of popped outer node, storing no fields
        let InnerNode{critical_bit: _, parent_index: _, left_child_index: _,
            right_child_index: _} = vector::swap_remove<InnerNode>(
                &mut tree.inner_nodes, inner_index);
        // If destroyed inner node was not last inner node in vector,
        // repair the parent-child relationship broken by swap remove
        if (inner_index < n_inner_nodes - 1)
            stitch_swap_remove(tree, inner_index, n_inner_nodes);
        // Swap remove popped outer node, storing only its value
        let OuterNode{key: _, value, parent_index: _} =
            vector::swap_remove<OuterNode<V>>(&mut tree.outer_nodes,
                outer_node_vector_index(outer_index));
        // If destroyed outer node was not last outer node in vector,
        // repair the parent-child relationship broken by swap remove
        if (outer_node_vector_index(outer_index) < n_outer_nodes - 1)
            stitch_swap_remove(tree, outer_index, n_outer_nodes);
        value // Return popped value
    }

    /// Return the value corresponding to `key` in `tree` having
    /// `n_outer_nodes` keys and destroy the outer node where it was
    /// stored, for the general case of a tree with more than one outer
    /// node. Abort if `key` not in `tree`.
    ///
    /// Here, the parent of the popped node must be removed, and if the
    /// popped node has a grandparent, the grandparent of the popped
    /// node must be updated to have as its child the popped node's
    /// sibling at the same position where the popped node's parent
    /// previously was, whether the sibling is an outer or inner node.
    /// Likewise the sibling must be updated to have as its parent the
    /// grandparent to the popped node. Outer node sibling case:
    /// ```
    /// >              2nd <- grandparent
    /// >             /   \
    /// >           001   1st <- parent
    /// >                /   \
    /// >   sibling -> 101   111 <- popped node
    /// >
    /// >       Pop 111
    /// >       ------>
    /// >
    /// >                  2nd <- grandparent
    /// >                 /   \
    /// >               001    101 <- sibling
    /// ```
    /// Inner node sibling case:
    /// ```
    /// >              2nd <- grandparent
    /// >             /   \
    /// >           001   1st <- parent
    /// >                /   \
    /// >   sibling -> 0th   111 <- popped node
    /// >             /   \
    /// >           100   101
    /// >
    /// >       Pop 111
    /// >       ------>
    /// >
    /// >              2nd <- grandparent
    /// >             /   \
    /// >           001   0th <- sibling
    /// >                /   \
    /// >              100   101
    /// ```
    /// If the popped node does not have a grandparent (if its parent is
    /// the root node), then the root node must be removed and the
    /// popped node's sibling must become the new root, whether the
    /// sibling is an inner or outer node. Likewise the sibling must be
    /// updated to indicate that it is the root. Inner node sibling
    /// case:
    /// ```
    /// >                     2nd <- parent
    /// >                    /   \
    /// >   popped node -> 001   1st <- sibling
    /// >                       /   \
    /// >                     101   111
    /// >
    /// >       Pop 001
    /// >       ------>
    /// >
    /// >                  1st <- sibling
    /// >                 /   \
    /// >               101    111
    /// ```
    /// Outer node sibling case:
    /// ```
    /// >                     2nd <- parent
    /// >                    /   \
    /// >   popped node -> 001   101 <- sibling
    /// >
    /// >       Pop 001
    /// >       ------>
    /// >
    /// >                  101 <- sibling
    /// ```
    fun pop_general<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        n_outer_nodes: u64
    ): V {
        // Get field index of search outer node, its side as a child,
        // its key, and the vector index of its parent
        let (search_index, search_child_side, search_key, search_parent_index,
            _) = search_outer(tree, key);
        assert!(search_key == key, E_NOT_HAS_KEY); // Assert key in tree
        // Update sibling, parent, grandparent relationships
        pop_update_relationships(tree, search_child_side, search_parent_index);
        // Destroy old nodes, returning popped value
        pop_destroy_nodes(tree, search_parent_index, search_index,
            n_outer_nodes)
    }

    /// Return the value corresponding to `key` in singleton `tree` and
    /// destroy the outer node where it was stored, aborting if `key`
    /// not in `tree`
    fun pop_singleton<V>(
        tree: &mut CritBitTree<V>,
        key: u128
    ): V {
        assert!(vector::borrow<OuterNode<V>>(&tree.outer_nodes, 0).key == key,
            E_NOT_HAS_KEY); // Assert key actually in tree at root node
        tree.root = 0; // Update root
        // Pop off and unpack outer node at root
        let OuterNode{key: _, value, parent_index: _} =
            vector::pop_back<OuterNode<V>>(&mut tree.outer_nodes);
        value // Return popped value
    }

    /// Update relationships in `tree` for popping a node which is a
    /// child on side `child_side` (`LEFT` or `RIGHT`), to parent node
    /// at index `parent_index`, per `pop_general()`
    fun pop_update_relationships<V>(
        tree: &mut CritBitTree<V>,
        child_side: bool,
        parent_index: u64,
    ) {
        // Borrow immutable reference to popped node's parent
        let parent = vector::borrow<InnerNode>(&tree.inner_nodes,
            parent_index);
        // If popped outer node was a left child, store the right child
        // field index of its parent as the child field index of the
        // popped node's sibling. Else flip the direction
        let sibling_index = if (child_side == LEFT) parent.right_child_index
            else parent.left_child_index;
        // Get parent field index of popped node's parent
        let grandparent_index = parent.parent_index;
        // Update popped node's sibling to have at its parent index
        // field the same as that of the popped node's parent, whether
        // the sibling is an inner or outer node
        if (is_outer_node(sibling_index))
            vector::borrow_mut<OuterNode<V>>(&mut tree.outer_nodes,
                outer_node_vector_index(sibling_index)).parent_index =
                    grandparent_index
            else vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
                sibling_index).parent_index = grandparent_index;
        // If popped node's parent is root
        if (grandparent_index == ROOT) {
            // Set root field index to child field index of popped
            // node's sibling
            tree.root = sibling_index;
        } else { // If popped node has a grandparent
            // Borrow mutable reference to popped node's grandparent
            let grandparent = vector::borrow_mut<InnerNode>(
                &mut tree.inner_nodes, grandparent_index);
            // If popped node's parent was a left child, update popped
            // node's grandparent to have as its child the popped node's
            // sibling. Else the right child
            if (grandparent.left_child_index == parent_index)
                grandparent.left_child_index = sibling_index else
                grandparent.right_child_index = sibling_index;
        };
    }

    /// Push back a new inner node and outer node into `tree`, where the
    /// new outer node should have key `key`, value `value`, and have as
    /// its parent the new inner node at vector index `inner_index`,
    /// which should have critical bit `critical_bit`, parent field
    /// index `parent_index`, and if `child_polarity` is `true`, left
    /// child field index `child_index_1` and right child field index
    /// `child_index_2`. If `child_polarity` is `false` the polarity of
    /// the children should be flipped
    fun push_back_insert_nodes<V>(
        tree: &mut CritBitTree<V>,
        key: u128,
        value: V,
        inner_index: u64,
        critical_bit: u8,
        parent_index: u64,
        child_polarity: bool,
        child_index_1: u64,
        child_index_2: u64,
    ) {
        // If child polarity marked true, declare left child field for
        // new inner node as child_index_1 and right as child_index_2
        let (left_child_index, right_child_index) = if (child_polarity)
            (child_index_1, child_index_2) else // Otherwise flipped
            (child_index_2, child_index_1);
        // Push back new outer node with new inner node as parent
        vector::push_back<OuterNode<V>>(&mut tree.outer_nodes,
            OuterNode{key, value, parent_index: inner_index});
        // Push back new inner node with specified parent and children
        vector::push_back<InnerNode>(&mut tree.inner_nodes,
            InnerNode{critical_bit, parent_index, left_child_index,
                right_child_index});
    }

    /// Walk from root in a `tree` having an inner node as its root,
    /// branching left or right at each inner node depending on whether
    /// `key` is unset or set, respectively, at the given critical bit.
    /// After arriving at an outer node, then return:
    /// * `u64`: Child field index of search outer node (with node type
    ///   bit flag)
    /// * `bool`: The side, `LEFT` or `RIGHT`, on which the search outer
    ///   node is a child of its parent
    /// * `u128`: Key of search outer node
    /// * `u64`: Vector index of parent of search outer node
    /// * `u8`: Critical bit indicated by parent of search outer node
    fun search_outer<V>(
        tree: &CritBitTree<V>,
        key: u128
    ): (
        u64,
        bool,
        u128,
        u64,
        u8,
    ) {
        // Initialize search parent to root
        let parent = vector::borrow<InnerNode>(&tree.inner_nodes, tree.root);
        loop { // Loop over inner nodes until branching to outer node
            // If key set at critical bit, track field index and side of
            // right child, else left child
            let (index, side) = if (is_set(key, parent.critical_bit))
                (parent.right_child_index, RIGHT) else
                (parent.left_child_index, LEFT);
            if (is_outer_node(index)) { // If child is outer node
                // Borrow immutable reference to it
                let node = vector::borrow<OuterNode<V>>(&tree.outer_nodes,
                    outer_node_vector_index(index));
                // Return child field index of search outer node, its
                // side as a child, its key, the vector index of its
                // parent, and parent's indicated critical bit
                return (index, side, node.key, node.parent_index,
                    parent.critical_bit)
            };
            // Search next inner node
            parent = vector::borrow<InnerNode>(&tree.inner_nodes, index);
        }
    }

    /// Update parent node at index `parent_index` in `tree` to reflect
    /// as its child a node that has been relocated from old child field
    /// index `old_index` to new child field index `new_index`
    fun stitch_child_of_parent<V>(
        tree: &mut CritBitTree<V>,
        new_index: u64,
        parent_index: u64,
        old_index: u64
    ) {
        let parent = vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
            parent_index); // Borrow mutable reference to parent
        // If relocated node was previously left child, update
        // parent's left child to indicate the relocated node's new
        // position, otherwise do update for right child of parent
        if (parent.left_child_index == old_index) parent.left_child_index =
            new_index else parent.right_child_index = new_index;
    }

    /// Update child node at child field index `child_index` in `tree`
    /// to reflect as its parent an inner node that has be relocated to
    /// child field index `new_index`
    fun stitch_parent_of_child<V>(
        tree: &mut CritBitTree<V>,
        new_index: u64,
        child_index: u64
    ) {
        // If child is an outer node, borrow corresponding node and
        // update its parent field index to that of relocated node
        if (is_outer_node(child_index)) vector::borrow_mut<OuterNode<V>>(
            &mut tree.outer_nodes, outer_node_vector_index(child_index)
                ).parent_index = new_index else
            // Otherwise perform update on an inner node
            vector::borrow_mut<InnerNode>(&mut tree.inner_nodes,
                child_index).parent_index = new_index;
    }

    /// Repair a broken parent-child relationship in `tree` caused by
    /// swap removing, for relocated node now at index indicated by
    /// child field index `node_index`, in vector that contained
    /// `n_nodes` nodes before the swap remove (when relocated node was
    /// last in vector)
    fun stitch_swap_remove<V>(
        tree: &mut CritBitTree<V>,
        node_index: u64,
        n_nodes: u64
    ) {
        // If child field index indicates relocated outer node
        if (is_outer_node(node_index)) {
            // Get node's parent field index
            let parent_index = vector::borrow<OuterNode<V>>(&tree.outer_nodes,
            outer_node_vector_index(node_index)).parent_index;
            // If root node was relocated, update root field and return
            if (parent_index == ROOT) {tree.root = node_index; return};
            // Else update parent to reflect relocated node position
            stitch_child_of_parent<V>(tree, node_index, parent_index,
                outer_node_child_index(n_nodes - 1));
        } else { // If child field index indicates relocated inner node
            // Borrow mutable reference to it
            let node =
                vector::borrow<InnerNode>(&tree.inner_nodes, node_index);
            // Get field index of node's parent and children
            let (parent_index, left_child_index, right_child_index) =
                (node.parent_index, node.left_child_index,
                    node.right_child_index);
            // Update left child to have relocated node as parent
            stitch_parent_of_child(tree, node_index, left_child_index);
            // Update right child to have relocated node as parent
            stitch_parent_of_child(tree, node_index, right_child_index);
            // If root node relocated, update root field and return
            if (parent_index == ROOT) {tree.root = node_index; return};
            // Else update parent to reflect relocated node position
            stitch_child_of_parent<V>(
                tree, node_index, parent_index, n_nodes - 1);
        }
    }

    /// Traverse in the specified direction from the node containing the
    /// specified key (the "start node" containing the "start key") to
    /// either the inorder predecessor or the inorder successor to the
    /// start key (the "target node" containing the "target key"), then
    /// return the child field index of the target node. See
    /// [traversal](#Traversal)
    ///
    /// # Method (predecessor)
    /// 1. Walk up from start node until arriving at an inner node that
    ///    has the start key as the minimum key in its right subtree
    ///    (the "apex node"): walk up until arriving at a parent that
    ///    has the last walked node as its right child
    /// 2. Walk to maximum key in apex node's left subtree, breaking out
    ///    at target node (the first outer node): walk to apex node's
    ///    left child, then walk along right children
    ///
    /// # Method (successor)
    /// 1. Walk up from start node until arriving at an inner node that
    ///    has the start key as the maximum key in its left subtree
    ///    (the "apex node"): walk up until arriving at a parent that
    ///    has the last walked node as its left child
    /// 2. Walk to minimum key in apex node's right subtree, breaking
    ///    out at target node (the first outer node): walk to apex
    ///    node's right child, then walk along left children
    ///
    /// # Parameters
    /// * `tree`: Crit-bit tree containing at least two nodes
    /// * `key`: Start key. If predecessor traversal, `key` cannot be
    ///   minimum key in `tree`, since this key does not have a
    ///   predecessor. Likewise, if successor traversal, `key` cannot be
    ///   maximum key in `tree`, since this key does not have a
    ///   successor
    /// * `parent_index`: Start node's parent field
    /// * `direction`: Direction to traverse. If `LEFT`, predecessor
    /// traversal, else successor traversal
    ///
    /// # Returns
    /// * `u64`: Child field index of target node
    ///
    /// # Considerations
    /// * Assumes passed start key is not minimum key in tree if
    ///   predecessor traversal, and that passed start key is not
    ///   maximum key in tree if successor traversal
    /// * Takes an exposed vector index (`parent_index`) as a parameter
    fun traverse_target_child_index<V>(
        tree: &CritBitTree<V>,
        key: u128,
        parent_index: u64,
        direction: bool,
    ): u64 {
        // Borrow immutable reference to start node's parent
        let parent =
            vector::borrow<InnerNode>(&tree.inner_nodes, parent_index);
        // If start key is set at parent node's critical bit, then the
        // upward walk has reach an inner node via its right child. This
        // is the break condition for successor traversal (when
        // `direction` is `LEFT`) a constant value that evaluates to
        // `true`. The inverse case applies for predecessor traversal,
        // so continue upward walk as long as `direction` is not equal
        // to the conditional critbit check
        while (direction != is_set(key, parent.critical_bit)) {
            // Borrow immutable reference to next parent in upward walk
            parent = vector::borrow<InnerNode>(&tree.inner_nodes,
                parent.parent_index);
        }; // Now at apex node
        // If predecessor traversal get left child field of apex node,
        let child_index = if (direction == LEFT) parent.left_child_index else
            parent.right_child_index; // Otherwise right child field
        // While child field indicates inner node
        while (!is_outer_node(child_index)) {
            // If predecessor traversal review child's right child next,
            // else review child's left child next
            child_index = if (direction == LEFT) vector::borrow<InnerNode>(
                &tree.inner_nodes, child_index).right_child_index else
                    vector::borrow<InnerNode>(
                        &tree.inner_nodes, child_index).left_child_index;
        }; // Child field now indicates target node
        child_index // Return child field index of target node
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `HI_128`
    fun b_lo(b: u8): u128 {1 << b ^ HI_128}

    #[test_only]
    /// Return a `u128` corresponding to the provided byte string. The
    /// byte should only contain only "0"s and "1"s, up to 128
    /// characters max (e.g. `b"100101...10101010"`)
    public fun u(
        s: vector<u8>
    ): u128 {
        let n = vector::length<u8>(&s); // Get number of bits
        let r = 0; // Initialize result to 0
        let i = 0; // Start loop at least significant bit
        while (i < n) { // While there are bits left to review
            let b = *vector::borrow<u8>(&s, n - 1 - i); // Get bit under review
            if (b == 0x31) { // If the bit is 1 (0x31 in ASCII)
                // OR result with the correspondingly leftshifted bit
                r = r | 1 << (i as u8);
            // Otherwise, assert bit is marked 0 (0x30 in ASCII)
            } else assert!(b == 0x30, E_BIT_NOT_0_OR_1);
            i = i + 1; // Proceed to next-least-significant bit
        };
        r // Return result
    }

    #[test_only]
    /// Return `u128` corresponding to concatenated result of `a`, `b`,
    /// and `c`. Useful for line-wrapping long byte strings
    public fun u_long(
        a: vector<u8>,
        b: vector<u8>,
        c: vector<u8>
    ): u128 {
        vector::append<u8>(&mut b, c); // Append c onto b
        vector::append<u8>(&mut a, b); // Append b onto a
        u(a) // Return u128 equivalent of concatenated bytestring
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify successful bitmask generation
    fun test_b_lo() {
        assert!(b_lo(0) == HI_128 - 1, 0);
        assert!(b_lo(1) == HI_128 - 2, 1);
        assert!(b_lo(127) == 0x7fffffffffffffffffffffffffffffff, 2);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun test_borrow_empty() {
        let tree = empty<u8>(); // Initialize empty tree
        borrow<u8>(&tree, 0); // Attempt invalid borrow
        destroy_empty(tree); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun test_borrow_mut_empty() {
        let tree = empty<u8>(); // Initialize empty tree
        borrow_mut<u8>(&mut tree, 0); // Attempt invalid borrow
        destroy_empty(tree); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Assert failure for attempted borrow without matching key
    fun test_borrow_mut_no_match():
    CritBitTree<u8> {
        let tree = singleton<u8>(3, 4); // Initialize singleton
        borrow_mut<u8>(&mut tree, 6); // Attempt invalid borrow
        tree // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    /// Assert correct modification of values
    fun test_borrow_mut_success():
    CritBitTree<u8> {
        let tree = empty<u8>(); // Initialize empty tree
        // Insert assorted key-value pairs
        insert(&mut tree, 2, 6);
        insert(&mut tree, 3, 8);
        insert(&mut tree, 1, 9);
        insert(&mut tree, 7, 5);
        // Modify some of the values
        *borrow_mut<u8>(&mut tree, 1) = 2;
        *borrow_mut<u8>(&mut tree, 2) = 4;
        // Assert values are as expected
        assert!(*borrow<u8>(&mut tree, 2) == 4, 0); // Changed
        assert!(*borrow<u8>(&mut tree, 3) == 8, 0); // Unchanged
        assert!(*borrow<u8>(&mut tree, 1) == 2, 0); // Changed
        assert!(*borrow<u8>(&mut tree, 7) == 5, 0); // Unchanged
        tree // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Assert failure for attempted borrow without matching key
    fun test_borrow_no_match():
    CritBitTree<u8> {
        let tree = singleton<u8>(3, 4); // Initialize singleton
        borrow<u8>(&tree, 6); // Attempt invalid borrow
        tree // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify length check fails for too many elements
    fun test_check_length_failure() {
        check_length(HI_64 ^ OUTER << NODE_TYPE); // Tree is full
    }

    #[test]
    /// Verify length check passes for valid sizes
    fun test_check_length_success() {
        check_length(0);
        check_length(1200);
        // Maximum number of keys that can be in tree pre-insert
        check_length((HI_64 ^ OUTER << NODE_TYPE) - 1);
    }

    #[test]
    /// Verify successful determination of critical bit at all positions
    fun test_crit_bit_success() {
        let b = 0; // Start loop for bit 0
        while (b <= MSB_u128) { // Loop over all bit numbers
            // Compare 0 versus a bitmask that is only set at bit b
            assert!(crit_bit(0, 1 << b) == b, (b as u64));
            b = b + 1; // Increment bit counter
        };
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify cannot destroy non-empty tree
    fun test_destroy_empty_fail() {
        // Attempt destroying singleton
        destroy_empty<u8>(singleton<u8>(0, 0));
    }

    #[test]
    /// Verify empty tree destruction
    fun test_destroy_empty_success() {
        let tree = empty<u8>(); // Initialize empty tree
        destroy_empty<u8>(tree); // Destroy it
    }

    #[test]
    /// Verify new tree created empty
    fun test_empty_success():
    (
        vector<InnerNode>,
        vector<OuterNode<u8>>
    ) {
        // Unpack root index and node vectors
        let CritBitTree{root, inner_nodes, outer_nodes} = empty<u8>();
        // Assert empty inner node vector
        assert!(vector::is_empty<InnerNode>(&inner_nodes), 0);
        // Assert empty outer node vector
        assert!(vector::is_empty<OuterNode<u8>>(&outer_nodes), 0);
        // Assert root set to 0
        assert!(root == 0, 0);
        (inner_nodes, outer_nodes) // Return rather than unpack
    }

    #[test]
    /// Verify returns `false` for empty tree
    fun test_has_key_empty_success() {
        let tree = empty<u8>(); // Initialize empty tree
        // Assert key check returns false
        assert!(!has_key(&tree, 0), 0);
        destroy_empty<u8>(tree); // Drop empty tree
    }

    #[test]
    /// Verify successful key checks in special case of singleton tree
    fun test_has_key_singleton():
    CritBitTree<u8> {
        // Create singleton with key 1 and value 2
        let tree = singleton<u8>(1, 2);
        assert!(has_key(&tree, 1), 0); // Assert key of 1 registered
        // Assert key of 3 not registered
        assert!(!has_key(&tree, 3), 0);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify successful key checks for the following tree, where `i_i`
    /// indicates an inner node's vector index, and `o_i` indicates an
    /// outer node's vector index:
    /// ```
    /// >           i_i = 0 -> 2nd
    /// >                     /   \
    /// >        o_i = 0 -> 001   1st <- i_i = 1
    /// >                        /   \
    /// >           o_i = 1 -> 101   0th <- i_i = 2
    /// >                           /   \
    /// >              o_i = 2 -> 110   111 <- o_i = 3
    /// ```
    fun test_has_key_success():
    CritBitTree<u8> {
        // Ignore values in key-value pairs by setting to 0
        let value = 0;
        let tree = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             2 ,
            parent_index:                          ROOT ,
            left_child_index:  outer_node_child_index(0),
            right_child_index:                        1 });
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             1 ,
            parent_index:                             0 ,
            left_child_index:  outer_node_child_index(1),
            right_child_index:                        2 });
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             0,
            parent_index:                             1,
            left_child_index:  outer_node_child_index(2),
            right_child_index: outer_node_child_index(3)});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"001"), value, parent_index: 0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"101"), value, parent_index: 1});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"110"), value, parent_index: 2});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"111"), value, parent_index: 2});
        // Assert correct membership checks
        assert!(has_key(&tree, u(b"001")), 0);
        assert!(has_key(&tree, u(b"101")), 1);
        assert!(has_key(&tree, u(b"110")), 2);
        assert!(has_key(&tree, u(b"111")), 3);
        assert!(!has_key(&tree, u(b"011")), 4); // Not in tree
        tree // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify aborts when key already in tree
    fun test_insert_general_failure():
    CritBitTree<u8> {
        let tree = singleton<u8>(3, 4); // Initialize singleton
        insert_singleton(&mut tree, 5, 6); // Insert onto singleton
        // Attempt insert for general case, but with duplicate key
        insert_general(&mut tree, 5, 7, 2);
        tree // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempting duplicate insertion on singleton
    fun test_insert_singleton_failure():
    CritBitTree<u8> {
        let tree = singleton<u8>(1, 2); // Initialize singleton
        insert_singleton(&mut tree, 1, 5); // Attempt to insert same key
        tree // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    /// Verify proper insertion result for insertion to left:
    /// ```
    /// >      1111     Insert         1st
    /// >                1101         /   \
    /// >               ----->    1101     1111
    /// ```
    fun test_insert_singleton_success_l():
    (
        CritBitTree<u8>
    ) {
        let tree = singleton<u8>(u(b"1111"), 4); // Initialize singleton
        insert_singleton(&mut tree, u(b"1101"), 5); // Insert to left
        assert!(tree.root == 0, 0); // Assert root is at new inner node
        // Borrow inner node at root
        let inner_node = vector::borrow<InnerNode>(&tree.inner_nodes, 0);
        // Assert root inner node values are as expected
        assert!(inner_node.critical_bit == 1 &&
            inner_node.parent_index == ROOT &&
            inner_node.left_child_index == outer_node_child_index(1) &&
            inner_node.right_child_index == outer_node_child_index(0), 1);
        // Borrow original outer node
        let outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        // Assert original outer node values are as expected
        assert!(outer_node.key == u(b"1111") &&
            outer_node.value == 4 && outer_node.parent_index == 0, 2);
        // Borrow new outer node
        let outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 1);
        // Assert new outer node values are as expected
        assert!(outer_node.key == u(b"1101") &&
            outer_node.value == 5 && outer_node.parent_index == 0, 3);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify proper insertion result for insertion to right:
    /// ```
    /// >      1011     Insert         2nd
    /// >                1111         /   \
    /// >               ----->    1011     1111
    /// ```
    fun test_insert_singleton_success_r():
    CritBitTree<u8> {
        let tree = singleton<u8>(u(b"1011"), 6); // Initialize singleton
        insert_singleton(&mut tree, u(b"1111"), 7); // Insert to right
        assert!(tree.root == 0, 0); // Assert root is at new inner node
        // Borrow inner node at root
        let inner_node = vector::borrow<InnerNode>(&tree.inner_nodes, 0);
        // Assert root inner node values are as expected
        assert!(inner_node.critical_bit == 2 &&
            inner_node.parent_index == ROOT &&
            inner_node.left_child_index == outer_node_child_index(0) &&
            inner_node.right_child_index == outer_node_child_index(1), 1);
        // Borrow original outer node
        let outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        // Assert original outer node values are as expected
        assert!(outer_node.key == u(b"1011") &&
            outer_node.value == 6 &&
            outer_node.parent_index == 0, 2);
        // Borrow new outer node
        let outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 1);
        // Assert new outer node values are as expected
        assert!(outer_node.key == u(b"1111") &&
            outer_node.value == 7 &&
            outer_node.parent_index == 0, 3);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify correct node fields for following insertion sequence,
    /// where `i_i` and `o_i` indicate inner and outer node vector
    /// indices, respectively:
    /// ```
    /// >  Insert 1101    1101 <- o_i = 0    Insert 1000
    /// >  ---------->                       ---------->
    /// >
    /// >                  2nd <- i_i = 0
    /// >                 /   \                   Insert 1100
    /// >   o_i = 1 -> 1000    1101 <- o_i = 0    ---------->
    /// >
    /// >                  2nd <- i_i = 0
    /// >                 /   \                   Insert 1110
    /// >   o_i = 1 -> 1000    0th <- i_i = 1     ---------->
    /// >                     /   \
    /// >      o_i = 2 -> 1100     1101 <- o_i = 0
    /// >
    /// >                      2nd <- i_i = 0     Insert 0000
    /// >                     /   \               ---------->
    /// >      o_i = 1 -> 1000     1st <- i_i = 2
    /// >                         /   \
    /// >           i_i = 1 -> 0th     1110 <- o_i = 3
    /// >                     /   \
    /// >      o_i = 2 -> 1100     1101 <- o_i = 0
    /// >
    /// >                     3rd <- i_i = 3
    /// >                    /   \
    /// >     o_i = 4 -> 0000     2nd <- i_i = 0
    /// >                        /   \
    /// >         o_i = 1 -> 1000     1st <- i_i = 2
    /// >                            /   \
    /// >              i_i = 1 -> 0th     1110 <- o_i = 3
    /// >                        /   \
    /// >         o_i = 2 -> 1100     1101 <- o_i = 0
    /// ```
    fun test_insert_success_1():
    CritBitTree<u8> {
        let tree = empty(); // Initialize empty tree
        // Insert various key-value pairs
        insert(&mut tree, u(b"1101"), 0);
        insert(&mut tree, u(b"1000"), 1);
        insert(&mut tree, u(b"1100"), 2);
        insert(&mut tree, u(b"1110"), 3);
        insert(&mut tree, u(b"0000"), 4);
        // Verify root field indicates correct inner node
        assert!(tree.root == 3, 0);
        // Verify inner node fields in ascending order of vector index
        let inner_node = vector::borrow<InnerNode>(&tree.inner_nodes, 0);
        assert!(inner_node.critical_bit ==                         2 &&
            inner_node.parent_index ==                             3 &&
            inner_node.left_child_index ==  outer_node_child_index(1) &&
            inner_node.right_child_index ==                        2 , 1);
        inner_node = vector::borrow<InnerNode>(&tree.inner_nodes, 1);
        assert!(inner_node.critical_bit ==                         0 &&
            inner_node.parent_index ==                             2 &&
            inner_node.left_child_index ==  outer_node_child_index(2) &&
            inner_node.right_child_index == outer_node_child_index(0), 2);
        inner_node = vector::borrow<InnerNode>(&tree.inner_nodes, 2);
        assert!(inner_node.critical_bit ==                         1 &&
            inner_node.parent_index ==                             0 &&
            inner_node.left_child_index ==                         1 &&
            inner_node.right_child_index == outer_node_child_index(3), 3);
        inner_node = vector::borrow<InnerNode>(&tree.inner_nodes, 3);
        assert!(inner_node.critical_bit ==                         3 &&
            inner_node.parent_index ==                          ROOT &&
            inner_node.left_child_index ==  outer_node_child_index(4) &&
            inner_node.right_child_index ==                        0 , 4);
        // Verify outer node fields in ascending order of vector index
        let outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        assert!(outer_node.key == u(b"1101") &&
            outer_node.value ==          0 &&
            outer_node.parent_index ==   1, 5);
        outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 1);
        assert!(outer_node.key == u(b"1000") &&
            outer_node.value ==          1 &&
            outer_node.parent_index ==   0, 6);
        outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 2);
        assert!(outer_node.key == u(b"1100") &&
            outer_node.value ==          2 &&
            outer_node.parent_index ==   1, 7);
        outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 3);
        assert!(outer_node.key == u(b"1110") &&
            outer_node.value ==          3 &&
            outer_node.parent_index ==   2, 8);
        outer_node = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 4);
        assert!(outer_node.key == u(b"0000") &&
            outer_node.value ==          4 &&
            outer_node.parent_index ==   3, 9);
        tree // Return rather than unpack
    }

    #[test]
    /// Variation on `test_insert_success_1()`:
    /// ```
    /// >  Insert 0101    0101 <- o_i = 0    Insert 0000
    /// >  ---------->                       ---------->
    /// >
    /// >                  2nd <- i_i = 0
    /// >                 /   \                   Insert 0001
    /// >   o_i = 1 -> 0000    0101 <- o_i = 0    ---------->
    /// >
    /// >                        2nd <- i_i = 0       Insert 1000
    /// >                       /   \                 ---------->
    /// >         i_i = 1 -> 0th     0101 <- o_i = 0
    /// >                   /   \
    /// >    o_i = 1 -> 0000     0001 <- o_i = 2
    /// >
    /// >                            3rd <- i_i = 2    Insert 0011
    /// >                           /   \              ---------->
    /// >             i_i = 0 -> 2nd     1000 <- o_i = 3
    /// >                       /   \
    /// >         i_i = 1 -> 0th     0101 <- o_i = 0
    /// >                   /   \
    /// >    o_i = 1 -> 0000     0001 <- o_i = 2
    /// >
    /// >                                3rd <- i_i = 2
    /// >                               /   \
    /// >                 i_i = 0 -> 2nd     1000 <- o_i = 3
    /// >                           /   \
    /// >             i_i = 3 -> 1st     0101 <- o_i = 0
    /// >                       /   \
    /// >         i_i = 1 -> 0th     0011 <- o_i = 4
    /// >                   /   \
    /// >    o_i = 1 -> 0000     0001 <- o_i = 2
    /// ```
    fun test_insert_success_2():
    CritBitTree<u8> {
        let tree = empty(); // Initialize empty tree
        // Insert various key-value pairs
        insert(&mut tree, u(b"0101"), 0);
        insert(&mut tree, u(b"0000"), 1);
        insert(&mut tree, u(b"0001"), 2);
        insert(&mut tree, u(b"1000"), 3);
        insert(&mut tree, u(b"0011"), 4);
        // Verify root field indicates correct inner node
        assert!(tree.root == 2, 0);
        // Verify inner node fields in ascending order of vector index
        let i = vector::borrow<InnerNode>(&tree.inner_nodes, 0);
        assert!(i.critical_bit ==                         2 &&
            i.parent_index ==                             2 &&
            i.left_child_index ==                         3  &&
            i.right_child_index == outer_node_child_index(0), 1);
        i = vector::borrow<InnerNode>(&tree.inner_nodes, 1);
        assert!(i.critical_bit ==                         0 &&
            i.parent_index ==                             3 &&
            i.left_child_index ==  outer_node_child_index(1) &&
            i.right_child_index == outer_node_child_index(2), 2);
        i = vector::borrow<InnerNode>(&tree.inner_nodes, 2);
        assert!(i.critical_bit ==                         3 &&
            i.parent_index ==                          ROOT &&
            i.left_child_index ==                         0  &&
            i.right_child_index == outer_node_child_index(3), 3);
        i = vector::borrow<InnerNode>(&tree.inner_nodes, 3);
        assert!(i.critical_bit ==                         1 &&
            i.parent_index ==                             0 &&
            i.left_child_index ==                         1  &&
            i.right_child_index == outer_node_child_index(4), 4);
        // Verify outer node fields in ascending order of vector index
        let o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        assert!(o.key == u(b"0101") && o.value == 0 && o.parent_index == 0, 5);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 1);
        assert!(o.key == u(b"0000") && o.value == 1 && o.parent_index == 1, 6);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 2);
        assert!(o.key == u(b"0001") && o.value == 2 && o.parent_index == 1, 7);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 3);
        assert!(o.key == u(b"1000") && o.value == 3 && o.parent_index == 2, 8);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 4);
        assert!(o.key == u(b"0011") && o.value == 4 && o.parent_index == 3, 9);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify emptiness check validity
    fun test_is_empty_success():
    CritBitTree<u8> {
        let tree = empty<u8>(); // Get empty tree
        assert!(is_empty<u8>(&tree), 0); // Assert is empty
        insert_empty<u8>(&mut tree, 1, 2); // Insert key 1 and value 2
        // Assert not marked empty
        assert!(!is_empty<u8>(&tree), 0);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify correct returns
    fun test_is_outer_node_success() {
        assert!(is_outer_node(OUTER << NODE_TYPE), 0);
        assert!(!is_outer_node(0), 1);
    }

    #[test]
    /// Verify correct returns
    fun test_is_set_success() {
        assert!(is_set(u(b"11"), 0) && is_set(u(b"11"), 1), 0);
        assert!(!is_set(u(b"10"), 0) && !is_set(u(b"01"), 1), 1);
    }

    #[test]
    /// Verify length check validity
    fun test_length_success():
    CritBitTree<u8> {
        let tree = empty(); // Initialize empty tree
        assert!(length<u8>(&tree) == 0, 0); // Assert length is 0
        insert(&mut tree, 1, 2); // Insert
        assert!(length<u8>(&tree) == 1, 1); // Assert length is 1
        insert(&mut tree, 3, 4); // Insert
        assert!(length<u8>(&tree) == 2, 2); // Assert length is 2
        tree // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify maximum key lookup failure when tree empty
    fun test_max_key_failure_empty() {
        let tree = empty<u8>(); // Initialize empty tree
        let _ = max_key(&tree); // Attempt invalid lookup
        destroy_empty(tree);
    }

    #[test]
    /// Verify correct maximum key lookup
    fun test_max_key_success():
    CritBitTree<u8> {
        let tree = singleton(3, 5); // Initialize singleton
        assert!(max_key(&tree) == 3, 0); // Assert correct lookup
        // Insert additional values
        insert(&mut tree, 2, 7);
        insert(&mut tree, 5, 8);
        insert(&mut tree, 4, 6);
        assert!(max_key(&tree) == 5, 0); // Assert correct lookup
        tree // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify minimum key lookup failure when tree empty
    fun test_min_key_failure_empty() {
        let tree = empty<u8>(); // Initialize empty tree
        let _ = min_key(&tree); // Attempt invalid lookup
        destroy_empty(tree);
    }

    #[test]
    /// Verify correct minimum key lookup
    fun test_min_key_success():
    CritBitTree<u8> {
        let tree = singleton(3, 5); // Initialize singleton
        assert!(min_key(&tree) == 3, 0); // Assert correct lookup
        // Insert additional values
        insert(&mut tree, 2, 7);
        insert(&mut tree, 5, 8);
        insert(&mut tree, 1, 6);
        assert!(min_key(&tree) == 1, 0); // Assert correct lookup
        tree // Return rather than unpack
    }

    #[test]
    /// Verify correct returns
    fun test_outer_node_vector_index_success() {
        assert!(outer_node_vector_index(OUTER << NODE_TYPE) == 0, 0);
        assert!(outer_node_vector_index(OUTER << NODE_TYPE | 123) == 123, 1);
    }

    #[test]
    /// Verify correct returns
    fun test_out_c_success() {
        assert!(outer_node_child_index(0) == OUTER << NODE_TYPE, 0);
        assert!(outer_node_child_index(123) == OUTER << NODE_TYPE | 123, 1);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for attempting to pop from empty tree
    fun test_pop_failure_empty() {
        let tree = empty<u8>(); // Initialize empty tree
        let _ = pop(&mut tree, 3); // Attempt invalid pop
        destroy_empty(tree); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempting to pop key not in tree
    fun test_pop_general_failure_no_key():
    CritBitTree<u8> {
        let tree = singleton(1, 7); // Initialize singleton
        insert(&mut tree, 2, 8); // Add a second element
        let _ = pop(&mut tree, 3); // Attempt invalid pop
        // Return rather than unpack (or signal to compiler as much)
        tree
    }

    #[test]
    /// Verify correct pop result and node updates, for `o_i` indicating
    /// outer node vector index and `i_i` indicating inner node vector
    /// index:
    /// ```
    /// >                  2nd <- i_i = 1
    /// >                 /   \
    /// >    o_i = 2 -> 001   1st <- i_i = 0
    /// >                    /   \
    /// >       o_i = 1 -> 101   111 <- o_i = 0
    /// >
    /// >       Pop 111
    /// >       ------>
    /// >
    /// >                  2nd  <- i_i = 0
    /// >                 /   \
    /// >    o_i = 0 -> 001   101 <- o_i = 1
    /// ```
    fun test_pop_general_success_1():
    CritBitTree<u8> {
        // Initialize singleton for node to be popped
        let tree = singleton(u(b"111"), 7);
        // Insert sibling, generating inner node marked 1st
        insert(&mut tree, u(b"101"), 8);
        // Insert key 001, generating new inner node marked 2nd, at root
        insert(&mut tree, u(b"001"), 9);
        // Assert correct pop value for key 111
        assert!(pop_general(&mut tree, u(b"111"), 3) == 7, 0);
        assert!(tree.root == 0, 1); // Assert root field updated
        // Borrow inner node at root
        let r = vector::borrow<InnerNode>(&mut tree.inner_nodes, 0);
        // Assert root inner node fields are as expected
        assert!(r.critical_bit == 2 &&
            r.parent_index == ROOT &&
            r.left_child_index == outer_node_child_index(0) &&
            r.right_child_index == outer_node_child_index(1), 2);
        // Borrow outer node on left
        let o_l = vector::borrow<OuterNode<u8>>(&mut tree.outer_nodes, 0);
        // Assert left outer node fields are as expected
        assert!(o_l.key == u(b"001") &&
            o_l.value == 9 &&
            o_l.parent_index == 0, 3);
        // Borrow outer node on right
        let o_r = vector::borrow<OuterNode<u8>>(&mut tree.outer_nodes, 1);
        // Assert right outer node fields are as expected
        assert!(o_r.key == u(b"101") &&
            o_r.value == 8 &&
            o_r.parent_index == 0, 4);
        tree // Return rather than unpack
    }

    #[test]
    /// Variation on `test_pop_general_success_1()`:
    /// ```
    /// >                    2nd <- i_i = 2
    /// >                   /   \
    /// >      i_i = 1 -> 1st   111 <- o_i = 3
    /// >                /   \
    /// >   o_i = 2 -> 001   0th <- i_i = 0
    /// >                   /   \
    /// >     o_i = 1 ->  010    011 <- o_i = 0
    /// >
    /// >       Pop 001
    /// >       ------>
    /// >
    /// >                    2nd  <- i_i = 1
    /// >                   /   \
    /// >      i_i = 0 -> 0th   111 <- o_i = 2
    /// >                /   \
    /// >   o_i = 1 -> 010   011 <- o_i = 0
    /// >
    /// >       Pop 111
    /// >       ------>
    /// >
    /// >      i_i = 0 -> 0th
    /// >                /   \
    /// >   o_i = 1 -> 010   011 <- o_i = 0
    /// >
    /// >       Pop 011
    /// >       ------>
    /// >
    /// >   o_i = 0 -> 010
    /// >
    /// >       Pop 010
    /// >       ------>
    /// >
    /// >       (empty)
    /// ```
    fun test_pop_general_success_2() {
        // Initialize singleton tree with key-value pair {011, 5}
        let tree = singleton(u(b"011"), 5); // Initialize singleton tree
        insert(&mut tree, u(b"010"), 6); // Insert {010, 6}
        insert(&mut tree, u(b"001"), 7); // Insert {001, 7}
        insert(&mut tree, u(b"111"), 8); // Insert {001, 8}
        assert!(pop(&mut tree, u(b"001")) == 7, 0); // Assert correct pop
        // Assert root field updated correctly
        assert!(tree.root == 1, 1);
        // Verify post-pop inner node fields in ascending order of index
        let i = vector::borrow<InnerNode>(&tree.inner_nodes, 0);
        assert!(i.critical_bit ==                         0 &&
            i.parent_index ==                             1 &&
            i.left_child_index ==  outer_node_child_index(1) &&
            i.right_child_index == outer_node_child_index(0), 2);
        i = vector::borrow<InnerNode>(&tree.inner_nodes, 1);
        assert!(i.critical_bit ==                         2 &&
            i.parent_index ==                          ROOT &&
            i.left_child_index ==                         0 &&
            i.right_child_index == outer_node_child_index(2), 3);
        // Verify outer node fields in ascending order of vector index
        let o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        assert!(o.key == u(b"011") && o.value == 5 && o.parent_index == 0, 4);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 1);
        assert!(o.key == u(b"010") && o.value == 6 && o.parent_index == 0, 5);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 2);
        assert!(o.key == u(b"111") && o.value == 8 && o.parent_index == 1, 6);
        assert!(pop(&mut tree, u(b"111")) == 8, 7); // Assert correct pop
        // Assert root field updated correctly
        assert!(tree.root == 0, 8);
        // Verify post-pop inner node fields at root
        i = vector::borrow<InnerNode>(&tree.inner_nodes, 0);
        assert!(i.critical_bit ==                         0 &&
            i.parent_index ==                          ROOT &&
            i.left_child_index ==  outer_node_child_index(1) &&
            i.right_child_index == outer_node_child_index(0), 9);
        // Verify outer node fields in ascending order of vector index
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        assert!(o.key == u(b"011") && o.value == 5 && o.parent_index == 0, 10);
        o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 1);
        assert!(o.key == u(b"010") && o.value == 6 && o.parent_index == 0, 11);
        // Assert correct pop
        assert!(pop(&mut tree, u(b"011")) == 5, 12);
        // Assert correct root field update
        assert!(tree.root == outer_node_child_index(0), 13);
        // Verify post-pop outer node fields at root
        let o = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        assert!(o.key == u(b"010") &&
            o.value == 6 &&
            o.parent_index == ROOT, 14);
        // Assert correct pop
        assert!(pop(&mut tree, u(b"010")) == 6, 15);
        // Assert root field updated correctly
        assert!(tree.root == 0, 16);
        assert!(is_empty(&tree), 17); // Assert is empty
        destroy_empty(tree); // Destroy
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    // Verify pop failure when key not in tree
    fun test_pop_singleton_failure():
    CritBitTree<u8> {
        let tree = singleton(1, 2); // Initialize singleton
        let _ = pop_singleton<u8>(&mut tree, 3); // Attempt invalid pop
        tree // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    // Verify successful pop
    fun test_pop_singleton_success() {
        let tree = singleton(1, 2); // Initialize singleton
        assert!(pop_singleton(&mut tree, 1) == 2, 0); // Verify pop value
        assert!(is_empty(&mut tree), 1); // Assert marked as empty
        assert!(tree.root == 0, 2); // Assert root index field updated
        destroy_empty<u8>(tree); // Destroy empty tree
    }

    #[test]
    /// Verify singleton initialized with correct values
    fun test_singleton_success():
    (
        vector<InnerNode>,
        vector<OuterNode<u8>>,
    ) {
        // Initialize w/ key 2 and value 3
        let tree = singleton<u8>(2, 3);
        // Assert no inner nodes
        assert!(vector::is_empty<InnerNode>(&tree.inner_nodes), 0);
        // Assert single outer node
        assert!(vector::length<OuterNode<u8>>(&tree.outer_nodes) == 1, 1);
        // Unpack root index and node vectors
        let CritBitTree{root, inner_nodes, outer_nodes} = tree;
        // Assert root index field indicates 0th outer node
        assert!(root == OUTER << NODE_TYPE, 2);
        // Pop and unpack last node from vector of outer nodes
        let OuterNode{key, value, parent_index} =
            vector::pop_back<OuterNode<u8>>(&mut outer_nodes);
        // Assert values in node are as expected
        assert!(key == 2 && value == 3 && parent_index == ROOT, 3);
        (inner_nodes, outer_nodes) // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated left child inner node.
    /// `o_i` indicates outer index, `i_i` indicates inner index:
    /// ```
    /// >                 i_i = 0 -> 2nd
    /// >                           /   \
    /// >  (relocated) i_i = 2 -> 1st    100 <- i_i = 0
    /// >                        /   \
    /// >           o_i = 1 -> 001   011 <- o_i = 2
    /// ```
    fun test_stitch_swap_remove_i_l():
    CritBitTree<u8> {
        // Ignore values in key-value pairs by setting to 0
        let value = 0;
        let tree = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus inner node at
        // vector index 1, which will be swap removed
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             2,
            parent_index:                          ROOT,
            left_child_index:                         2,
            right_child_index: outer_node_child_index(0)});
        // Bogus node
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             0,
            parent_index:                             0,
            left_child_index:                         0,
            right_child_index:                        0 });
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             1,
            parent_index:                             0,
            left_child_index:  outer_node_child_index(1),
            right_child_index: outer_node_child_index(2)});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"100"), value, parent_index: 0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"001"), value, parent_index: 2});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"011"), value, parent_index: 2});
        // Swap remove and unpack bogus node
        let InnerNode{critical_bit: _, parent_index: _, left_child_index: _,
            right_child_index: _} =
                vector::swap_remove<InnerNode>(&mut tree.inner_nodes, 1);
        // Stitch broken relationships
        stitch_swap_remove(&mut tree, 1, 3);
        // Assert parent to relocated node indicates proper child update
        assert!(vector::borrow<InnerNode>(
            &tree.inner_nodes, 0).left_child_index == 1, 0);
        // Assert children to relocated node indicate proper parent
        // update
        assert!(vector::borrow<OuterNode<u8>>(
            &tree.outer_nodes, 1).parent_index == 1, 1); // Left child
        assert!(vector::borrow<OuterNode<u8>>(
            &tree.outer_nodes, 2).parent_index == 1, 2); // Right child
        tree // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated right child inner node.
    /// `o_i` indicates outer index, `i_i` indicates inner index:
    /// ```
    /// >                2nd <- i_i = 0
    /// >               /   \
    /// >  o_i = 0 -> 001   1st <- i_i = 2 (relocated)
    /// >                  /   \
    /// >     o_i = 1 -> 101   111 <- o_i = 2
    /// ```
    fun test_stitch_swap_remove_i_r():
    CritBitTree<u8> {
        // Ignore values in key-value pairs by setting to 0
        let value = 0;
        let tree = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus inner node at
        // vector index 1, which will be swap removed
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             2,
            parent_index:                          ROOT,
            left_child_index:  outer_node_child_index(0),
            right_child_index:                        2});
        // Bogus node
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             0,
            parent_index:                             0,
            left_child_index:                         0,
            right_child_index:                        0});
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             1,
            parent_index:                             0,
            left_child_index:  outer_node_child_index(1),
            right_child_index: outer_node_child_index(2)});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"001"), value, parent_index: 0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"101"), value, parent_index: 2});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"111"), value, parent_index: 2});
        // Swap remove and unpack bogus node
        let InnerNode{critical_bit: _, parent_index: _, left_child_index: _,
            right_child_index: _} = vector::swap_remove<InnerNode>(
                &mut tree.inner_nodes, 1);
        // Stitch broken relationships
        stitch_swap_remove(&mut tree, 1, 3);
        // Assert parent to relocated node indicates proper child update
        assert!(vector::borrow<InnerNode>(
            &tree.inner_nodes, 0).right_child_index == 1, 0);
        // Assert children to relocated node indicate proper parent
        // update
        assert!(vector::borrow<OuterNode<u8>>(
            &tree.outer_nodes, 1).parent_index == 1, 1); // Left child
        assert!(vector::borrow<OuterNode<u8>>(
            &tree.outer_nodes, 2).parent_index == 1, 2); // Right child
        tree // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated left child outer node.
    /// `o_i` indicates outer index, `i_i` indicates inner index:
    /// ```
    /// >                          2nd <- i_i = 0
    /// >                         /   \
    /// >            o_i = 0 -> 001   1st <- i_i = 1
    /// >                            /   \
    /// >   (relocated) o_i = 3 -> 101   111 <- o_i = 1
    /// ```
    fun test_stitch_swap_remove_o_l():
    CritBitTree<u8> {
        let value = 0; // Ignore values in key-value pairs by setting to 0
        let tree = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus outer node at
        // vector index 2, which will be swap removed
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             2,
            parent_index:                          ROOT,
            left_child_index:  outer_node_child_index(0),
            right_child_index:                        1});
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             1,
            parent_index:                             0,
            left_child_index:  outer_node_child_index(3),
            right_child_index: outer_node_child_index(1)});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"001"), value, parent_index: 0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"111"), value, parent_index: 1});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes, // Bogus
            OuterNode{key:    HI_128, value, parent_index: HI_64});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"101"), value, parent_index: 1});
        // Swap remove and unpack bogus node
        let OuterNode{key: _, value: _, parent_index: _} =
            vector::swap_remove<OuterNode<u8>>(&mut tree.outer_nodes, 2);
        // Stitch broken relationship
        stitch_swap_remove(&mut tree, outer_node_child_index(2), 4);
        // Assert parent to relocated node indicates proper child update
        assert!(vector::borrow<InnerNode>(&tree.inner_nodes, 1).
            left_child_index == outer_node_child_index(2), 0);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated right child outer node.
    /// `o_i` indicates outer index, `i_i` indicates inner index:
    /// ```
    /// >                2nd <- i_i = 0
    /// >               /   \
    /// >  o_i = 0 -> 001   1st <- i_i = 1
    /// >                  /   \
    /// >     o_i = 1 -> 101   111 <- o_i = 3 (relocated)
    /// ```
    fun test_stitch_swap_remove_o_r():
    CritBitTree<u8> {
        // Ignore values in key-value pairs by setting to 0
        let value = 0;
        let tree = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus outer node at
        // vector index 2, which will be swap removed
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             2,
            parent_index:                          ROOT,
            left_child_index:  outer_node_child_index(0),
            right_child_index:                        1});
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             1,
            parent_index:                             0,
            left_child_index:  outer_node_child_index(1),
            right_child_index: outer_node_child_index(3)});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"001"), value, parent_index: 0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"101"), value, parent_index: 1});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes, // Bogus
            OuterNode{key:    HI_128, value, parent_index: HI_64});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"111"), value, parent_index: 1});
        // Swap remove and unpack bogus node
        let OuterNode{key: _, value: _, parent_index: _} =
            vector::swap_remove<OuterNode<u8>>(&mut tree.outer_nodes, 2);
        // Stitch broken relationship
        stitch_swap_remove(&mut tree, outer_node_child_index(2), 4);
        // Assert parent to relocated node indicates proper child update
        assert!(vector::borrow<InnerNode>(
            &tree.inner_nodes, 1).right_child_index ==
            outer_node_child_index(2), 0);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated root inner node. `o_i`
    /// indicates outer index, `i_i` indicates inner index:
    /// ```
    /// >                2nd <- i_i = 2 (relocated)
    /// >               /   \
    /// >  o_i = 0 -> 001   1st <- i_i = 0
    /// >                  /   \
    /// >     o_i = 1 -> 101   111 <- o_i = 2
    /// ```
    fun test_stitch_swap_remove_r_i():
    CritBitTree<u8> {
        // Ignore values in key-value pairs by setting to 0
        let value = 0;
        let tree = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus inner node at
        // vector index 1, which will be swap removed
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             1,
            parent_index:                             2,
            left_child_index:  outer_node_child_index(1),
            right_child_index: outer_node_child_index(2)});
        // Bogus node
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             0,
            parent_index:                             0,
            left_child_index:                         0,
            right_child_index:                        0});
        vector::push_back<InnerNode>(&mut tree.inner_nodes, InnerNode{
            critical_bit:                             2,
            parent_index:                          ROOT,
            left_child_index:  outer_node_child_index(0),
            right_child_index:                        0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"001"), value, parent_index: 0});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"101"), value, parent_index: 2});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"111"), value, parent_index: 2});
        // Swap remove and unpack bogus node
        let InnerNode{critical_bit: _, parent_index: _, left_child_index: _,
            right_child_index: _} = vector::swap_remove<InnerNode>(
                &mut tree.inner_nodes, 1);
        // Stitch broken relationships
        stitch_swap_remove(&mut tree, 1, 3);
        // Assert root field reflects relocated node position
        assert!(tree.root == 1, 0);
        // Assert children to relocated node indicate proper parent
        // update
        assert!(vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0).
            parent_index == 1, 1); // Left child
        assert!(vector::borrow<InnerNode>(&tree.inner_nodes, 0).
            parent_index == 1, 2); // Right child
        tree // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated root outer node
    /// ```
    /// >      100 <- i_i = 1 (relocated)
    /// ```
    fun test_stitch_swap_remove_r_o():
    CritBitTree<u8> {
        // Ignore values in key-value pairs by setting to 0
        let value = 0;
        let tree = empty<u8>(); // Initialize empty tree
        // Append root outer node per above diagram, including bogus
        // outer node at vector index 0, which will be swap removed
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes, // Bogus
            OuterNode{key:    HI_128, value, parent_index: HI_64});
        vector::push_back<OuterNode<u8>>(&mut tree.outer_nodes,
            OuterNode{key: u(b"100"), value, parent_index:  ROOT});
        // Swap remove and unpack bogus node
        let OuterNode{key: _, value: _, parent_index: _} =
            vector::swap_remove<OuterNode<u8>>(&mut tree.outer_nodes, 0);
        // Stitch broken relationships
        stitch_swap_remove(&mut tree, outer_node_child_index(0), 2);
        // Assert root field indicates relocated outer node
        assert!(tree.root == outer_node_child_index(0), 0);
        // Borrow reference to outer node at root
        let n = vector::borrow<OuterNode<u8>>(&tree.outer_nodes, 0);
        // Assert fields are as expected
        assert!(n.key == u(b"100") && n.value == 0 && n.parent_index ==
            ROOT, 1);
        tree // Return rather than unpack
    }

    #[test]
    /// Verify proper traversal end pop for initial tree below, where
    /// `i_i` indicates inner node vector index and `o_i` indicates
    /// outer node vector index
    /// ```
    /// >                     3rd <- i_i = 3
    /// >                    /   \
    /// >     o_i = 4 -> 0000     2nd <- i_i = 0
    /// >                        /   \
    /// >         o_i = 1 -> 1000     1st <- i_i = 2
    /// >                            /   \
    /// >              i_i = 1 -> 0th     1110 <- o_i = 3
    /// >                        /   \
    /// >         o_i = 2 -> 1100     1101 <- o_i = 0
    /// >
    /// >                      Pop 1101
    /// >                      ------->
    /// >
    /// >                     3rd
    /// >                    /   \
    /// >                0000     2nd
    /// >                        /   \
    /// >                    1000     1st
    /// >                            /   \
    /// >                        1100     1110
    /// >
    /// >                      Pop 1000
    /// >                      ------->
    /// >
    /// >                     3rd
    /// >                    /   \
    /// >                0000     1st
    /// >                        /   \
    /// >                    1100     1110
    /// >
    /// >                      Pop 1110
    /// >                      ------->
    /// >
    /// >                     3rd
    /// >                    /   \
    /// >                0000     1100
    /// >
    /// >                      Pop 0000
    /// >                      ------->
    /// >
    /// >                      1100
    /// >
    /// >                      Pop 1100
    /// >                      ------->
    /// ```
    fun test_traverse_end_pop_success() {
        let tree = empty(); // Initialize empty tree
        // Insert various key-value pairs per above tree
        insert(&mut tree, u(b"1101"), 10);
        insert(&mut tree, u(b"1000"), 11);
        insert(&mut tree, u(b"1100"), 12);
        insert(&mut tree, u(b"1110"), 13);
        insert(&mut tree, u(b"0000"), 14);
        // Initialize predecessor traversal (at 1110)
        let (k, _, p_f, _) = traverse_predecessor_init_mut(&mut tree);
        // Traverse to predecessor (to 1101)
        let (_, _, p_f, c_i) = traverse_predecessor_mut(&mut tree, k, p_f);
        // End the traversal by popping 1101, assert value of 10
        assert!(traverse_end_pop(&mut tree, p_f, c_i, 5) == 10, 0);
        // Initialize successor traversal (at 0000)
        let (k, v_r, p_f, _) = traverse_successor_init_mut(&mut tree);
        // Assert key-value pair
        assert!(k == u(b"0000") && *v_r == 14, 1);
        // Traverse entire tree, assert key-value pairs along the way
        (k, v_r, p_f, _) = traverse_successor_mut(&mut tree, k, p_f);
        assert!(k == u(b"1000") && *v_r == 11, 2);
        (k, v_r, p_f, _) = traverse_successor_mut(&mut tree, k, p_f);
        assert!(k == u(b"1100") && *v_r == 12, 3);
        (k, v_r, _, _) = traverse_successor_mut(&mut tree, k, p_f);
        assert!(k == u(b"1110") && *v_r == 13, 4);
        // Initialize successor traversal (at 0000)
        (k, _, p_f, _) = traverse_successor_init_mut(&mut tree);
        // Traverse to successor (to 1000)
        (_, _, p_f, c_i) = traverse_successor_mut(&mut tree, k, p_f);
        // End the traversal by popping 1000, assert value of 11
        assert!(traverse_end_pop(&mut tree, p_f, c_i, 4) == 11, 5);
        // Initialize predecessor traversal (at 1110)
        (k, v_r, p_f, _) = traverse_predecessor_init_mut(&mut tree);
        // Assert key-value pair
        assert!(k == u(b"1110") && *v_r == 13, 6);
        // Traverse entire tree, assert key-value pairs along the way
        (k, v_r, p_f, _) = traverse_predecessor_mut(&mut tree, k, p_f);
        assert!(k == u(b"1100") && *v_r == 12, 7);
        (k, v_r, _, _) = traverse_predecessor_mut(&mut tree, k, p_f);
        assert!(k == u(b"0000") && *v_r == 14, 8);
        // Initialize predecessor traversal (at 1110)
        (_, _, p_f, c_i) = traverse_predecessor_init_mut(&mut tree);
        // End the traversal by popping 1110, assert value of 13
        assert!(traverse_end_pop(&mut tree, p_f, c_i, 3) == 13, 9);
        // Initialize successor traversal (at 0000)
        (k, v_r, p_f, _) = traverse_successor_init_mut(&mut tree);
        // Assert key-value pair
        assert!(k == u(b"0000") && *v_r == 14, 10);
        // Traverse entire tree, assert key-value pairs along the way
        (k, v_r, _, _) = traverse_successor_mut(&mut tree, k, p_f);
        assert!(k == u(b"1100") && *v_r == 12, 11);
        // Initialize successor traversal (at 0000)
        (_, _, p_f, c_i) = traverse_successor_init_mut(&mut tree);
        // End the traversal by popping 0000, assert value of 14
        assert!(traverse_end_pop(&mut tree, p_f, c_i, 2) == 14, 12);
        // Initialize predecessor traversal (at 1100)
        (_, _, p_f, c_i) = traverse_predecessor_init_mut(&mut tree);
        // End the traversal by popping 1100, assert value of 12
        assert!(traverse_end_pop(&mut tree, p_f, c_i, 1) == 12, 13);
        assert!(tree.root == 0, 14); // Assert root updates
        destroy_empty(tree); // Destroy empty tree
    }

    #[test]
    /// Verify proper traversal popping and associated operations for
    /// below sequence diagram, where `i_i` indicates inner node vector
    /// index and `o_i` indicates outer node vector index
    /// ```
    /// >                     3rd <- i_i = 3
    /// >                    /   \
    /// >     o_i = 4 -> 0000     2nd <- i_i = 0
    /// >                        /   \
    /// >         o_i = 1 -> 1000     1st <- i_i = 2
    /// >                            /   \
    /// >              i_i = 1 -> 0th     1110 <- o_i = 3
    /// >                        /   \
    /// >         o_i = 2 -> 1100     1101 <- o_i = 0
    /// >
    /// >                      Pop 1110
    /// >                      ------->
    /// >
    /// >                     3rd <- i_i = 2
    /// >                    /   \
    /// >     o_i = 3 -> 0000     2nd <- i_i = 0
    /// >                        /   \
    /// >         o_i = 1 -> 1000     0th <- i_i = 1
    /// >                            /   \
    /// >             o_i = 2 -> 1100     1101 <- o_i = 0
    /// >
    /// >                      Pop 0000
    /// >                      ------->
    /// >
    /// >                     2nd <- i_i = 0
    /// >                    /   \
    /// >     o_i = 1 -> 1000     0th <- i_i = 1
    /// >                        /   \
    /// >         o_i = 2 -> 1100     1101 <- o_i = 0
    /// >
    /// >                      Pop 1000
    /// >                      ------->
    /// >
    /// >                     0th <- i_i = 0
    /// >                    /   \
    /// >     o_i = 1 -> 1100     1101 <- o_i = 0
    /// >
    /// >                      Pop 1100
    /// >                      ------->
    /// >
    /// >                      1101 <- o_i = 0
    /// ```
    fun test_traverse_pop_success():
    CritBitTree<u8> {
        let tree = empty(); // Initialize empty tree
        // Insert various key-value pairs per above tree
        insert(&mut tree, u(b"1101"), 10);
        insert(&mut tree, u(b"1000"), 11);
        insert(&mut tree, u(b"1100"), 12);
        insert(&mut tree, u(b"1110"), 13);
        insert(&mut tree, u(b"0000"), 14);
        // Initialize predecessor traversal (at 1101)
        let (k, v_r, p_f, i) = traverse_predecessor_init_mut(&mut tree);
        // Assert correct predecessor traversal initialization returns
        assert!(k == u(b"1110") && *v_r == 13 && p_f == 2 &&
            i == outer_node_child_index(3), 0);
        *v_r = 15; // Mutate value of node having key 1110
        // Traverse to predecessor (to 1101)
        (k, v_r, p_f, i) = traverse_predecessor_mut(&mut tree, k, p_f);
        // Assert correct predecessor traversal returns
        assert!(k == u(b"1101") && *v_r == 10 && p_f == 1 &&
            i == outer_node_child_index(0), 1);
        *v_r = 16; // Mutate value of node having key 1101
        // Traverse back to successor (to 1110)
        (k, v_r, p_f, i) = traverse_successor_mut(&mut tree, k, p_f);
        // Assert correct successor traversal returns, including mutated
        // value
        assert!(k == u(b"1110") && *v_r == 15 && p_f == 2 &&
            i == outer_node_child_index(3), 2);
        // Traverse pop back to predecessor (to 1101)
        let (k, v_r, p_f, i, v) =
            traverse_predecessor_pop_mut(&mut tree, k, p_f, i, 5);
        assert!(v == 15, 3); // Assert value popped correctly
        // Assert correct predecessor traversal returns, including
        // mutated value
        assert!(k == u(b"1101") && *v_r == 16 && p_f == 1 &&
            i == outer_node_child_index(0), 4);
        // Initialize successor traversal (at 0000)
        (k, v_r, p_f, i) = traverse_successor_init_mut(&mut tree);
        // Assert correct successor traversal initialization returns
        assert!(k == u(b"0000") && *v_r == 14 && p_f == 2 &&
            i == outer_node_child_index(3), 5);
        // Traverse pop to successor (to 1000)
        (k, v_r, p_f, i, v) =
            traverse_successor_pop_mut(&mut tree, k, p_f, i, 4);
        assert!(v == 14, 6); // Assert value popped correctly
        // Assert correct predecessor traversal returns
        assert!(k == u(b"1000") && *v_r == 11 && p_f == 0 &&
            i == outer_node_child_index(1), 7);
        // Traverse pop to successor (to 1100)
        (k, v_r, p_f, i, v) =
            traverse_successor_pop_mut(&mut tree, k, p_f, i, 3);
        assert!(v == 11, 8); // Assert value popped correctly
        // Assert correct predecessor traversal returns
        assert!(k == u(b"1100") && *v_r == 12 && p_f == 0 && i ==
            outer_node_child_index(1), 9);
        // Traverse pop to successor (to 1101)
        (k, v_r, p_f, i, v) =
            traverse_successor_pop_mut(&mut tree, k, p_f, i, 2);
        assert!(v == 12, 10); // Assert value popped correctly
        // Assert correct successor traversal returns, including
        // mutation from beginning of test
        assert!(k == u(b"1101") && *v_r == 16 && i ==
            outer_node_child_index(0), 11);
        // Assert root relationship updated correctly
        assert!(tree.root == outer_node_child_index(0) && p_f == ROOT, 12);
        tree // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-binary-representative byte string
    fun test_u_failure() {u(b"2");}

    #[test]
    /// Verify successful return values
    fun test_u_success() {
        assert!(u(b"0") == 0, 0);
        assert!(u(b"1") == 1, 1);
        assert!(u(b"00") == 0, 2);
        assert!(u(b"01") == 1, 3);
        assert!(u(b"10") == 2, 4);
        assert!(u(b"11") == 3, 5);
        assert!(u(b"10101010") == 170, 6);
        assert!(u(b"00000001") == 1, 7);
        assert!(u(b"11111111") == 255, 8);
        assert!(u_long( // 60 characters on first two lines, 8 on last
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111111111111111111111111111111111111111111111111111111111111",
            b"11111111"
        ) == HI_128, 9);
        assert!(u_long( // 60 characters on first two lines, 8 on last
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111111111111111111111111111111111111111111111111111111111111",
            b"11111110"
        ) == HI_128 - 1, 10);
    }

    #[test]
    /// See [walkthrough](#Walkthrough)
    fun traverse_demo() {
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
        assert!(!is_empty(&tree), 0); // Assert tree not empty
        let n_keys = length(&tree); // Get number of keys in the tree
        // Get number of remaining traversals possible
        let remaining_traversals = n_keys - 1;
        // Initialize predecessor traversal: get max key in tree,
        // mutable reference to corresponding value, parent field of
        // corresponding node, and the child field index of it
        let (key, value_ref, parent_index, child_index) =
            traverse_predecessor_init_mut(&mut tree);
        let i = 10; // Initialize value increment counter
        // While remaining traversals possible
        while(remaining_traversals > 0) {
            if (key % 4 == 0) { // If key is a multiple of 4
                // Traverse pop corresponding node and discard its value
                (key, value_ref, parent_index, child_index, _) =
                    traverse_predecessor_pop_mut(
                        &mut tree, key, parent_index, child_index, n_keys);
                n_keys = n_keys - 1; // Decrement key count
            } else { // If key is not a multiple of 4
                // Increment corresponding value
                *value_ref = *value_ref + i;
                i = i + 10; // Increment by 10 more next iteration
                // Traverse to predecessor
                (key, value_ref, parent_index, child_index) =
                    traverse_predecessor_mut(&mut tree, key, parent_index);
            };
            // Decrement remaining traversal count
            remaining_traversals = remaining_traversals - 1;
        }; // Traversal has ended up at node having minimum key
        *value_ref = 0; // Set corresponding value to 0
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
        assert!(n_keys > 0, 9); // Assert tree still not empty
        // Re-initialize counters: remaining traversal, value increment
        (remaining_traversals, i) = (n_keys - 1, 1);
        // Initialize successor traversal
        (key, value_ref, parent_index, child_index) =
            traverse_successor_init_mut(&mut tree);
        // Initialize variable to store value of matched node
        let value = 0;
        // While remaining traversals possible
        while(remaining_traversals > 0) {
            if (key == 7) { // If key is 7
                // Traverse pop corresponding node and store its value
                (_, _, _, _, value) = traverse_successor_pop_mut(
                    &mut tree, key, parent_index, child_index, n_keys);
                break // Stop traversal
            } else { // For all keys not equal to 7
                // Increment corresponding value
                *value_ref = *value_ref + i;
                // Traverse to successor
                (key, value_ref, parent_index, child_index) =
                    traverse_successor_mut(&mut tree, key, parent_index);
                i = i + 1; // Increment by 1 more next iteration
            };
            // Decrement remaining traversal count
            remaining_traversals = remaining_traversals - 1;
        };
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
        // Pop all key-value pairs except {9, 910}
        pop(&mut tree, 1);
        pop(&mut tree, 2);
        pop(&mut tree, 3);
        pop(&mut tree, 5);
        pop(&mut tree, 6);
        assert!(!is_empty(&tree), 18); // Assert tree not empty
        let n_keys = length(&tree); // Get number of keys in the tree
        // Get number of remaining traversals possible
        let remaining_traversals = n_keys - 1;
        // Initialize successor traversal
        (key, value_ref, parent_index, _) =
            traverse_successor_init_mut(&mut tree);
        *value_ref = 1234; // Update value of node having minimum key
        // While remaining traversals possible
        while(remaining_traversals > 0) {
            *value_ref = 4321; // Update value of corresponding node
            // Traverse to successor
            (key, value_ref, parent_index, _) = traverse_successor_mut(
                &mut tree, key, parent_index);
            // Decrement remaining traversal count
            remaining_traversals = remaining_traversals - 1;
        }; // This loop does not go through any iterations
        // Assert value unchanged via loop
        assert!(pop(&mut tree, 9) == 1234, 19);
        destroy_empty(tree); // Destroy empty tree
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}
