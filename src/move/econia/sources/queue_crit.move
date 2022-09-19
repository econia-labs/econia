/// Hybrid data structure combining queue and crit-bit tree properties.
///
/// # Bit number convention
///
/// Bit numbers 0-indexed from least-significant bit (LSB):
///
/// ```
/// >    11101...1010010101
/// >     bit 5 = 0 -|    |- bit 0 = 1
/// ```
///
/// # Crit-bit trees
///
/// ## General
///
/// A critical bit (crit-bit) tree is a compact binary prefix tree,
/// similar to a binary search tree, that stores a prefix-free set of
/// bitstrings, like n-bit integers or variable-length 0-terminated byte
/// strings. For a given set of keys there exists a unique crit-bit tree
/// representing the set, hence crit-bit trees do not require complex
/// rebalancing algorithms like those of AVL or red-black binary search
/// trees. Crit-bit trees support the following operations:
///
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Predecessor
/// * Successor
/// * Iteration
///
/// ## Structure
///
/// The present implementation involves a tree with `Leaf` and `Parent`
/// nodes. `Parent` nodes have two `Leaf` children each, and `Leaf`
/// nodes do not have children. `Leaf` nodes store a value of type `V`,
/// and have a `u128` key. `Parent` nodes store a `u8` indicating the
/// most-significant critical bit (crit-bit) of divergence between
/// `Leaf` keys from the `Parent` node's two subtrees: `Leaf` keys in
/// the `Parent` node's left subtree are unset at the critical bit,
/// while `Leaf` keys in the node's right subtree are set at the
/// critical bit.
///
/// `Parent` nodes are arranged hierarchically, with the most
/// significant critical bits at the top of the tree. For instance, the
/// `Leaf` keys `001`, `101`, `110`, and `111` would be stored in a
/// crit-bit tree as follows (right carets included at left of
/// illustration per issue with documentation build engine, namely,
/// the automatic stripping of leading whitespace in documentation
/// comments, which prohibits the simple initiation of monospaced code
/// blocks through indentation by 4 spaces):
///
/// ```
/// >       2nd
/// >      /   \
/// >    001   1st
/// >         /   \
/// >       101   0th
/// >            /   \
/// >          110   111
/// ```
///
/// Here, the `Parent` node marked `2nd` stores the critical bit `2`,
/// the `Parent` node marked `1st` stores the critical bit `1`, and the
/// `Parent` node marked `0th` stores the critical bit `0`. Hence, the
/// sole `Leaf` key in the left subtree of the `Parent` marked `2nd` is
/// unset at bit 2, while all the keys in right subtree of the `Parent`
/// marked `2nd` are set at bit 2. And similarly for the `Parent` marked
/// `0th`, the `Leaf` key of its left child is unset at bit 0, while the
/// `Leaf` key of its right child is set at bit 0.
///
/// `Leaf` keys are automatically sorted upon insertion.
///
/// ## References
///
/// * [Bernstein 2006]
/// * [Langley 2008] (Primary reference for this implementation)
/// * [Langley 2012]
/// * [Tcler's Wiki 2021]
///
/// [Bernstein 2006]:
///     https://cr.yp.to/critbit.html
/// [Langley 2008]:
///     https://www.imperialviolet.org/2008/09/29/critbit-trees.html
/// [Langley 2012]:
///     https://github.com/agl/critbit
/// [Tcler's Wiki 2021]:
///     https://wiki.tcl-lang.org/page/critbit
///
/// ---
///
module econia::queue_crit {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table::{Table};
    use std::option::{Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A hybrid between a queue and a crit-bit tree.
    ///
    /// # Insertion key multiplicity
    ///
    /// Accepts key-value pair insertions for multiple instances of
    /// the same "insertion key". For example, the following key-value
    /// pairs, each having an insertion key of `3`, can all be inserted:
    ///
    /// * $p_{3, 0} = \{ 3, 5 \}$
    /// * $p_{3, 1} = \{ 3, 8 \}$
    /// * $p_{3, 2} = \{ 3, 5 \}$
    ///
    /// Upon insertion, key-value pairs are assigned an "insertion
    /// count", which describes the number of key-value pairs, sharing
    /// the same insertion key, that were previously inserted.
    /// Continuing the above example, the first inserted instance of
    /// $\{ 3, 5 \}$ ( $p_{3, 0}$ ) has insertion count `0`, the only
    /// inserted instance of $\{ 3, 8 \}$ ( $p_{3, 1}$ ) has insertion
    /// count `1`, and the second instance of $\{ 3, 5 \}$
    /// ( $p_{3, 2}$ ) has insertion count `2`.
    ///
    /// # Nested sorting
    ///
    /// After insertion count assignment, key-value pairs are then
    /// automatically sorted upon insertion into a crit-bit tree,
    /// such that they can be accessed via a queue which is sorted by:
    ///
    /// 1. Either ascending or descending order of insertion key, then
    ///    by
    /// 2. Ascending order of insertion count.
    ///
    /// For example, consider the following insertion sequence:
    ///
    /// 1. $k_{2, 0}$
    /// 2. $k_{3, 0}$
    /// 3. $k_{3, 1}$
    /// 4. $k_{2, 1}$
    /// 5. $k_{5, 0}$
    ///
    /// These elements would be accessed from an ascending queue in the
    /// following sequence:
    ///
    /// 1. $k_{2, 0}$
    /// 2. $k_{2, 1}$
    /// 3. $k_{3, 0}$
    /// 4. $k_{3, 1}$
    /// 5. $k_{5, 0}$
    ///
    /// In the case of an descending queue, the access sequence would
    /// instead be:
    ///
    /// 1. $k_{5, 0}$
    /// 2. $k_{3, 0}$
    /// 3. $k_{3, 1}$
    /// 4. $k_{2, 0}$
    /// 5. $k_{2, 1}$
    ///
    /// # Leaf keys
    ///
    /// After insertion count assignment, key-value pairs are assigned
    /// a "leaf key" corresponding to a leaf in a crit-bit tree, which
    /// has the the following bit structure (`NOT` denotes bitwise
    /// complement):
    ///
    ///
    /// | Bit(s) | If ascending queue | If descending queue   |
    /// |--------|--------------------|-----------------------|
    /// | 0-61   | Insertion count    | `NOT` insertion count |
    /// | 62     | 0                  | 1                     |
    /// | 63     | 0                  | 0                     |
    /// | 64-127 | Insertion key      | Insertion key         |
    ///
    /// With the insertion key contained in the most significant bits,
    /// elements are thus sorted in the crit-bit tree first by insertion
    /// key and then by:
    ///
    /// * Insertion count if an ascending queue, or
    /// * Bitwise complement of insertion count if a descending queue.
    ///
    /// Hence when accessing elements starting from the front of the
    /// queue, the queue-specific sorting order is thus acheived by:
    ///
    /// * Inorder successor traversal starting from the minimum leaf key
    ///   if an ascending queue, or
    /// * Inorder predecessor traversal starting from the maximum leaf
    ///   key if a descending queue.
    ///
    /// # Parent keys
    ///
    /// If the insertion of a crit-bit tree leaf is accompanied by the
    /// generation of a crit-bit tree parent node, the parent is
    /// assigned a "parent key" that is identical to the corresponding
    /// leaf key, except with bit 63 set. This schema allows for
    /// discrimination between leaf keys and parent keys based simply
    /// on bit 63.
    ///
    /// # Key tables
    ///
    /// Insertion, leaf, and parent keys are each stored in separate
    /// hash tables:
    ///
    /// | Table key  | Key type | Table value                         |
    /// |------------|----------|-------------------------------------|
    /// | Insertion  | `u64`    | Insertion count for key, if nonzero |
    /// | Leaf       | `u128`   | Crit-bit tree leaf                  |
    /// | Parent     | `u128`   | Crit-bit tree parent node           |
    ///
    /// # Insertion key table
    ///
    /// The insertion key table is initialized empty, such that before
    /// inserting the first instance of a given insertion key,
    /// $k_{i, 0}$, the insertion key table does not have an entry for
    /// key $i$. During insertion, the entry $\{i, 0\}$ is added to the
    /// table, and for each subsequent insertion, $k_{i, n}$, the value
    /// corresponding to key $i$ is updated to $n$.
    ///
    /// Since bits 62 and 63 in leaf keys are reserved for flag bits,
    /// the maximum insertion count per insertion key is thus
    /// $2^{62} - 1$.
    ///
    /// # Advantages
    ///
    /// Key-value insertion to a `QueueCrit` accepts a `u64` insertion
    /// key and an insertion value of type `V`, and returns a `u128`
    /// leaf key. Subsequent leaf key lookup, including deletion, is
    /// thus $O(1)$ since each `Leaf` is stored in a `Table`,
    /// and deletions behind the head of the queue are additionally
    /// parallelizable in the general case where:
    ///
    /// * Deletions do not have overlapping tree edges.
    ///
    /// Insertions are, like a crit-bit tree, $O(k^{\dagger})$ in the
    /// worst case, where $k^{\dagger} = k - 2 = 126$ (the number of
    /// variable bits in a leaf key), but parallelizable in the general
    /// case where:
    ///
    /// 1. Insertions do not have overlapping tree edges.
    /// 2. Insertions do not share the same insertion key.
    ///
    /// The second parallelism constraint is a result of insertion count
    /// updates, and may potentially be eliminated in the case of a
    /// parallelized insertion count aggregator.
    ///
    /// ---
    ///
    struct QueueCrit<V> has store {
        /// Queue sort direction, `ASCENDING` or `DESCENDING`.
        direction: bool,
        /// Key of root node. If none, tree is empty.
        root: Option<u128>,
        /// Queue head key. If none, tree is empty. Else minimum leaf
        /// key if `direction` is `ASCENDING`, and maximum leaf key
        /// if `direction` is `DESCENDING`.
        head: Option<u128>,
        /// Map from insertion key to 0-indexed insertion count.
        insertions: Table<u64, u64>,
        /// Map from parent key to `Parent`.
        parents: Table<u128, Parent>,
        /// Map from leaf key to `Leaf` having insertion value type `V`.
        leaves: Table<u128, Leaf<V>>
    }

    /// A crit-bit tree leaf node.
    struct Leaf<V> has store {
        /// Insertion value.
        value: V,
        /// If none, node is root. Else parent key.
        parent: Option<u128>
    }

    /// A crit-bit tree parent node.
    struct Parent has store {
        /// Critical bit position.
        bit: u8,
        /// If none, node is root. Else parent key.
        parent: Option<u128>,
        /// Left child key.
        left: u128,
        /// Right child key.
        right: u128
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Bit number of crit-bit node type flag.
    const NODE_TYPE: u8 = 63;
    /// Node type bit flag indicating `Leaf`.
    const LEAF: u64 = 0;
    /// Node type bit flag indicating `Parent`.
    const PARENT: u64 = 1;

    /// Bit number of queue sort direction flag.
    const DIRECTION: u8 = 62;
    /// Ascending sort direction flag. `0` when cast to `u64` bit flag.
    const ASCENDING: bool = false;
    /// Descending sort direction flag. `1` when cast to `u64` bit flag.
    const DESCENDING: bool = true;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow insertion value corresponding to given leaf key.
    public fun crit_borrow<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>,
        _leaf_key: u128
    )/*: &V*/ {}

    /// Mutably borrow insertion value corresponding to given leaf key.
    public fun crit_borrow_mut<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>,
        _leaf_key: u128
    )/*: &V*/ {}

    /// Pop corresonding leaf, return insertion value.
    public fun crit_pop<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>,
        _leaf_key: u128
    )/*: V*/ {}

    /// Return head leaf key, if any.
    public fun get_head<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>,
    )/*: Option<u128> */ {}

    /// Insert key-value pair, returning generated leaf key.
    public fun insert<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>,
        _insert_key: u64,
        //_insert_value: V,
    )/*: u128*/ {}

    /// Return `ASCENDING` or `DESCENDING` `QueueCrit`, per `direction`.
    public fun new<V>(
        _direction: bool
    )/*: QueueCrit*/ {}

    /// Mutably borrow the head of the queue in preparation for a pop.
    ///
    /// # Parameters
    /// * `queue_crit_ref_mut`: Mutable reference to `QueueCrit`.
    ///
    /// # Returns
    /// * `u128`: Queue head leaf key.
    /// * `&mut V`: Mutable reference to queue head insertion value.
    /// * `bool`: `true` if the queue `Leaf` has a parent, and thus if
    ///   there is another element to iterate to. If `false`, can still
    ///   pop the head via `crit_pop()`.
    ///
    /// # Aborts if
    /// * Indicated `QueueCrit` is empty.
    public fun queue_pop_init<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // corresponding leaf key from `CritQueue.head`, which aborts
        // if none.
    }

    /// Pop head and borrow next element in the queue, the new head.
    ///
    /// Should only be called after `queue_borrow_mut()` indicates that
    /// iteration can proceed, or if a subsequent call to `queue_pop()`
    /// indicates the same.
    ///
    /// # Parameters
    /// * `queue_crit_ref_mut`: Mutable reference to `QueueCrit`.
    ///
    /// # Returns
    /// * `u128`: New queue head leaf key.
    /// * `&mut V`: Mutable reference to new queue head insertion value.
    /// * `bool`: `true` if the new queue head `Leaf` has a parent, and
    ///   thus if iteration can proceed for another pop.
    ///
    /// # Aborts if
    /// * Indicated `QueueCrit` is empty.
    /// * Indicated `QueueCrit` is a singleton, e.g. if there are no
    ///   elements to proceed to after popping.
    public fun queue_pop<V>(
        _queue_crit_ref_mut: &mut QueueCrit<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // the corresonding leaf key from the option field, which aborts
        // if it is none.
    }

    /// Return `true` if `insertion_key` would become new head if
    /// inserted, else `false`.
    public fun takes_priority<V>(
        _queue_crit_ref: &QueueCrit<V>,
        _insertion_key: u64
    )/*: bool*/ {
        // Return true if empty.
        // If ascending, return true if less than head insertion key.
        // If descending, return true if greater than head insertion
        // key.
    }

    /// Return `true` if `insertion_key` would not become the head if
    /// inserted.
    public fun trails_head<V>(
        _queue_crit_ref: &QueueCrit<V>,
        _insertion_key: u64
    )/*: bool*/ {
        // Return false if empty.
        // If ascending, return true if greater than/equal to head
        // insertion key.
        // If descending, return true if less than/equal to head
        // insertion key.
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}