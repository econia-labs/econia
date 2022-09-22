/// Hybrid data structure combining crit-bit tree and queue properties.
///
/// Bit numbers are 0-indexed from the least-significant bit (LSB):
///
/// >     11101...1010010101
/// >      bit 5 = 0 -|    |- bit 0 = 1
///
/// # Module-level documentation sections
///
/// [Crit-bit trees](#crit-bit-trees):
///
/// * [General](#general)
/// * [Structure](#structure)
/// * [References](#references)
///
/// [Crit-queues](#crit-queues):
///
/// * [Enqueue key multiplicity](#enqueue-key-multiplicity)
/// * [Dequeue order](#dequeue-order)
/// * [Leaf key structure](#leaf-key-structure)
/// * [Parent keys](#parent-keys)
/// * [Key tables](#key-tables)
///
/// [Operations](#operations):
///
/// * [Enqueues](#enqueues)
/// * [Removals](#removals)
/// * [Dequeues](#dequeues)
///
/// # Crit-bit trees
///
/// ## General
///
/// A critical bit (crit-bit) tree is a compact binary prefix tree
/// that stores a prefix-free set of bitstrings, like n-bit integers or
/// variable-length 0-terminated byte strings. For a given set of keys
/// there exists a unique crit-bit tree representing the set, to the
/// effect that crit-bit trees do not require complex rebalancing
/// algorithms like those of AVL or red-black binary search trees.
/// Crit-bit trees support the following operations:
///
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Inorder predecessor iteration
/// * Inorder successor iteration
///
/// ## Structure
///
/// The present implementation involves a tree with `Leaf` and `Parent`
/// nodes. `Parent` nodes have two `Leaf` children each, and `Leaf`
/// nodes do not have children. `Leaf` nodes store a value of type `V`,
/// and have a `u128` key. `Parent` nodes store a `u8` indicating the
/// most-significant critical bit (crit-bit) of divergence between
/// `Leaf` keys from the `Parent` node's two subtrees: `Leaf` keys in
/// a `Parent` node's left subtree are unset at the critical bit, while
/// `Leaf` keys in a `Parent` node's right subtree are set at the
/// critical bit.
///
/// `Parent` nodes are arranged hierarchically, with the most
/// significant critical bits at the top of the tree. For instance, the
/// `Leaf` keys `001`, `101`, `110`, and `111` would be stored in a
/// crit-bit tree as follows:
///
/// >        2nd
/// >       /   \
/// >     001   1st
/// >          /   \
/// >        101   0th
/// >             /   \
/// >           110   111
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
/// # Crit-queues
///
/// ## Enqueue key multiplicity
///
/// Unlike a crit-bit tree, which only allows for a single insertion of
/// a given key, crit-queues support multiple enqueues of a given key
/// across key-value pairs. For example, the following key-value pairs,
/// all having the same "enqueue key", `3`, may be stored inside of a
/// single crit-queue:
///
/// * $p_{3, 0} = \langle 3, 5 \rangle$
/// * $p_{3, 1} = \langle 3, 8 \rangle$
/// * $p_{3, 2} = \langle 3, 2 \rangle$
/// * $p_{3, 3} = \langle 3, 5 \rangle$
///
/// Here, key-value pair $p_{i, j}$ has enqueue key $i$ and "enqueue
/// count" $j$, with the enqueue count describing the number
/// of key-value pairs, having the same enqueue key, that were
/// previously enqueued.
///
/// ## Dequeue order
///
/// After a key-value pair has been enqueued and assigned an enqueue
/// count, a separate key is generated, which allows for sorted
/// insertion into a crit-bit tree. Here, the corresponding "leaf key"
/// is constructed such that key-value pairs are sorted within the
/// crit-bit tree by:
///
/// 1. Either ascending or descending order of enqueue key, then by
/// 2. Ascending order of enqueue count.
///
/// For example, consider the following enqueue sequence ($k_{i, j}$
/// denotes enqueue key $i$ with enqueue count $j$):
///
/// 1. $k_{0, 0}$
/// 2. $k_{1, 0}$
/// 3. $k_{1, 1}$
/// 4. $k_{0, 1}$
/// 5. $k_{3, 0}$
///
/// In an ascending crit-queue, these elements would be dequeued as
/// follows:
///
/// 1. $k_{0, 0}$
/// 2. $k_{0, 1}$
/// 3. $k_{1, 0}$
/// 4. $k_{1, 1}$
/// 5. $k_{3, 0}$
///
/// In a descending crit-queue, the dequeue sequence would instead be:
///
/// 1. $k_{3, 0}$
/// 2. $k_{1, 0}$
/// 3. $k_{1, 1}$
/// 4. $k_{0, 0}$
/// 5. $k_{0, 1}$
///
/// ## Leaf key structure
///
/// In the present implementation, crit-queue leaf keys have the
/// following bit structure (`NOT` denotes bitwise complement):
///
/// | Bit(s) | Ascending crit-queue | Descending crit-queue |
/// |--------|----------------------|-----------------------|
/// | 64-127 | Enqueue key          | Enqueue key           |
/// | 63     | 0                    | 0                     |
/// | 62     | 0                    | 1                     |
/// | 0-61   | Enqueue count        | `NOT` enqueue count   |
///
/// With the enqueue key contained in the most significant bits,
/// elements are thus sorted in the crit-bit tree first by enqueue key
/// and then by:
///
/// * Enqueue count if an ascending crit-queue, or
/// * Bitwise complement of enqueue count if a descending queue.
///
/// Continuing the above example, this yields the following leaf keys
/// and crit-bit tree for an ascending crit-queue, with elements
/// dequeued via inorder successor traversal starting from the minimum
/// leaf key:
///
/// | Enqueue key | Leaf key bits 64-127 | Leaf key bits 0-63 |
/// |-------------|----------------------|--------------------|
/// | $k_{0, 0}$  | `000...000`          | `000...000`        |
/// | $k_{0, 1}$  | `000...000`          | `000...001`        |
/// | $k_{1, 0}$  | `000...001`          | `000...000`        |
/// | $k_{1, 1}$  | `000...001`          | `000...001`        |
/// | $k_{3, 0}$  | `000...011`          | `000...000`        |
///
/// >                                          65th
/// >                                         /    \
/// >                                     64th      k_{3, 0}
/// >                            ________/    \________
/// >                         0th                      0th
/// >      Queue             /   \                    /   \
/// >       head --> k_{0, 0}     k_{0, 1}    k_{1, 0}     k_{1, 1}
///
/// For a descending crit-queue, elements are dequeued via
/// inorder predecessor traversal starting from the maximum leaf key:
///
/// | Enqueue key | Leaf key bits 64-127 | Leaf key bits 0-63 |
/// |-------------|----------------------|--------------------|
/// | $k_{3, 0}$  | `000...011`          | `011...111`        |
/// | $k_{1, 0}$  | `000...001`          | `011...111`        |
/// | $k_{1, 1}$  | `000...001`          | `011...110`        |
/// | $k_{0, 0}$  | `000...000`          | `011...111`        |
/// | $k_{0, 1}$  | `000...000`          | `011...110`        |
///
/// >                               65th
/// >                              /    \             Queue
/// >                          64th      k_{3, 0} <-- head
/// >                 ________/    \________
/// >              0th                      0th
/// >             /   \                    /   \
/// >     k_{0, 1}     k_{0, 0}    k_{1, 1}     k_{1, 0}
///
///
/// ## Parent keys
///
/// If the insertion of a crit-bit tree leaf is accompanied by the
/// generation of a crit-bit tree parent node, the parent is assigned
/// a "parent key" that is identical to the corresponding leaf key,
/// except with bit 63 set. This schema allows for
/// discrimination between leaf keys and parent keys based simply on
/// bit 63.
///
/// ## Key tables
///
/// Enqueue, leaf, and parent keys are stored in separate hash tables:
///
/// | Table key  | Key type | Table value                       |
/// |------------|----------|-----------------------------------|
/// | Enqueue    | `u64`    | Enqueue count for key, if nonzero |
/// | Leaf       | `u128`   | Crit-bit tree leaf                |
/// | Parent     | `u128`   | Crit-bit tree parent node         |
///
/// The enqueue key table is initialized empty, such that before
/// enqueuing the first instance of a given enqueue key, $k_{i, 0}$,
/// the enqueue key table does not have an entry for key $i$. After
/// $k_{i, 0}$ is enqueued, the entry $\langle i, 0\rangle$ is added to
/// the enqueue key table, and for each subsequent enqueue,
/// $k_{i, n}$, the value corresponding to key $i$, the enqueue count,
/// is updated to $n$. Since bits 62 and 63 in leaf keys are
/// reserved for flag bits, the maximum enqueue count per enqueue key
/// is thus $2^{62} - 1$.
///
/// # Operations
///
/// In the present implementation, key-value pairs are enqueued via
/// `enqueue()`, which accepts a `u64` enqueue key and an enqueue value
/// of type `V`. A corresponding `u128` leaf key is returned, which can
/// be used for subsequent leaf key lookup via `borrow()`,
/// `borrow_mut()`, or `remove()`.
///
/// ## Enqueues
///
/// Enqueues are, like a crit-bit tree, $O(k^{\dagger})$ in the worst
/// case, where $k^{\dagger} = k - 2 = 126$ (the number of variable bits
/// in a leaf key), but parallelizable in the general case where:
///
/// 1. Enqueues do not alter the head of the crit-queue.
/// 2. Enqueues do not write to overlapping tree edges.
/// 3. Enqueues do not share the same enqueue key.
///
/// The third parallelism constraint is a result of enqueue count
/// updates, and may potentially be eliminated in the case of a
/// parallelized insertion count aggregator.
///
/// ## Removals
///
/// With `Leaf` nodes stored in a `Table`, `remove()` operations are
/// thus $O(1)$, and are additionally parallelizable in the general case
/// where:
///
/// 1. Removals do not write to overlapping tree edges.
/// 2. Removals do not alter the head of the crit-queue.
///
/// Removals can take place from anywhere inside of the crit-queue, with
/// the specified sorting order preserved among remaining elements. For
/// example, consider the elements in an ascending crit-queue with the
/// following dequeue sequence:
///
/// 1. $k_{0, 6}$
/// 2. $k_{2, 5}$
/// 3. $k_{2, 8}$
/// 4. $k_{4, 5}$
/// 5. $k_{5, 0}$
///
/// Here, removing $k_{2, 5}$ simply updates the dequeue sequence to:
///
/// 1. $k_{0, 6}$
/// 2. $k_{2, 8}$
/// 3. $k_{4, 5}$
/// 4. $k_{5, 0}$
///
/// ## Dequeues
///
/// Dequeues, as a form of removal, are $O(1)$, but since they alter
/// the head of the queue, they are not parallelizable. Dequeues
/// are initialized via `dequeue_init()`, and iterated via `dequeue()`.
///
/// ---
///
module econia::critqueue {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table::{Table};
    use std::option::{Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Hybrid between a crit-bit tree and a queue. See above.
    struct CritQueue<V> has store {
        /// Crit-queue sort direction, `ASCENDING` or `DESCENDING`.
        direction: bool,
        /// Crit-bit tree root node key. If none, tree is empty.
        root: Option<u128>,
        /// Queue head key. If none, tree is empty. Else minimum leaf
        /// key if `direction` is `ASCENDING`, and maximum leaf key
        /// if `direction` is `DESCENDING`.
        head: Option<u128>,
        /// Map from enqueue key to 0-indexed enqueue count.
        enqueues: Table<u64, u64>,
        /// Map from parent key to `Parent`.
        parents: Table<u128, Parent>,
        /// Map from leaf key to `Leaf` having enqueue value type `V`.
        leaves: Table<u128, Leaf<V>>
    }

    /// A crit-bit tree leaf node.
    struct Leaf<V> has store {
        /// Enqueue value.
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

    /// Bit number of crit-queue sort direction flag.
    const DIRECTION: u8 = 62;
    /// Ascending sort direction flag. `0` when cast to `u64` bit flag.
    const ASCENDING: bool = false;
    /// Descending sort direction flag. `1` when cast to `u64` bit flag.
    const DESCENDING: bool = true;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // To implement >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow enqueue value corresponding to given leaf key.
    public fun borrow<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _leaf_key: u128
    )/*: &V*/ {}

    /// Mutably borrow enqueue value corresponding to given leaf key.
    public fun borrow_mut<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _leaf_key: u128
    )/*: &V*/ {}

    /// Dequeue head and borrow next element in the queue, the new head.
    ///
    /// Should only be called after `dequeue_init()` indicates that
    /// iteration can proceed, or if a subsequent call to `dequeue()`
    /// indicates the same.
    ///
    /// # Parameters
    /// * `crit_queue_ref_mut`: Mutable reference to `CritQueue`.
    ///
    /// # Returns
    /// * `u128`: New queue head leaf key.
    /// * `&mut V`: Mutable reference to new queue head enqueue value.
    /// * `bool`: `true` if the new queue head `Leaf` has a parent, and
    ///   thus if iteration can proceed.
    ///
    /// # Aborts if
    /// * Indicated `CritQueue` is empty.
    /// * Indicated `CritQueue` is a singleton, e.g. if there are no
    ///   elements to proceed to after dequeueing.
    public fun dequeue<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // the corresponding leaf key from the option field, which
        // aborts if it is none.
    }

    /// Mutably borrow the head of the queue before dequeueing.
    ///
    /// # Parameters
    /// * `crit_queue_ref_mut`: Mutable reference to `CritQueue`.
    ///
    /// # Returns
    /// * `u128`: Queue head leaf key.
    /// * `&mut V`: Mutable reference to queue head enqueue value.
    /// * `bool`: `true` if the queue `Leaf` has a parent, and thus if
    ///   there is another element to iterate to. If `false`, can still
    ///   remove the head via `remove()`.
    ///
    /// # Aborts if
    /// * Indicated `CritQueue` is empty.
    public fun dequeue_init<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // corresponding leaf key from `CritQueue.head`, which aborts
        // if none.
    }

    /// Enqueue key-value pair, returning generated leaf key.
    public fun enqueue<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _enqueue_key: u64,
        //_enqueue_value: V,
    )/*: u128*/ {}

    /// Return head leaf key, if any.
    public fun get_head_leaf_key<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
    )/*: Option<u128> */ {}

    /// Return `ASCENDING` or `DESCENDING` `CritQueue`, per `direction`.
    public fun new<V>(
        _direction: bool
    )/*: QueueCrit*/ {}

    /// Remove corresponding leaf, return enqueue value.
    public fun remove<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _leaf_key: u128
    )/*: V*/ {}

    /// Return `true` if `enqueue_key` would become new head if
    /// enqueued, else `false`.
    public fun takes_priority<V>(
        _crit_queue_ref: &CritQueue<V>,
        _enqueue_key: u64
    )/*: bool*/ {
        // Return true if empty.
        // If ascending, return true if less than head enqueue key.
        // If descending, return true if greater than head enqueue key.
    }

    /// Return `true` if `enqueue_key` would not become the head if
    /// enqueued.
    public fun trails_head<V>(
        _crit_queue_ref: &CritQueue<V>,
        _enqueue_key: u64
    )/*: bool*/ {
        // Return false if empty.
        // If ascending, return true if greater than/equal to head
        // enqueue key.
        // If descending, return true if less than/equal to head
        // enqueue key.
    }

    // To implement <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}