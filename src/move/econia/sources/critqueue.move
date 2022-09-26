/// Crit-queue: A hybrid between a crit-bit tree and a queue.
///
/// A crit-queue contains an inner crit-bit tree with sub-queues at each
/// leaf node, enabling chronological ordering among multiple instances
/// of the same insertion key. While multiple instances of the same
/// insertion key are sorted by order of insertion, different
/// insertion keys can be sorted in either ascending or descending
/// order relative to the head of the crit-queue, as specified during
/// initialization. Like a crit-bit tree, a crit-queue can be used as an
/// associative array that maps keys to values, as in the present
/// implementation.
///
/// The present implementation, based on hash tables, offers:
///
/// * Insertions that are $O(1)$ in the best case, $O(log_2(n))$ in the
///   intermediate case, and parallelizable in the general case.
/// * Removals that are always $O(1)$, and parallelizable in the general
///   case.
/// * Iterated dequeues that are always $O(1)$.
///
/// # Module-level documentation sections
///
/// [Bit conventions](#bit-conventions)
///
/// * [Number](#number)
/// * [Status](#status)
/// * [Masking](#masking)
///
/// [Crit-bit trees](#crit-bit-trees)
///
/// * [General](#general)
/// * [Structure](#structure)
/// * [Insertions](#insertions)
/// * [Removals](#removals)
/// * [As a map](#as-a-map)
/// * [References](#references)
///
/// [Crit-queues](#crit-queues)
///
/// * [Key storage multiplicity](#key-storage-multiplicity)
/// * [Sorting order](#sorting-order)
/// * [Leaves](#leaves)
/// * [Sub-queue nodes](#sub-queue-nodes)
/// * [Inner keys](#inner-keys)
/// * [Insertion counts](#insertion-counts)
/// * [Dequeue order preservation](#dequeue-order-preservation)
/// * [Sub-queue removal updates](#sub-queue-removal-updates)
/// * [Free leaves](#free-leaves)
/// * [Dequeues](#dequeues)
///
/// [Implementation analysis](#implementation-analysis)
///
/// * [Core functionality](#core-functionality)
/// * [Inserting](#inserting)
/// * [Removing](#removing)
/// * [Dequeuing](#dequeuing)
///
/// # Bit conventions
///
/// ## Number
///
/// Bit numbers are 0-indexed from the least-significant bit (LSB):
///
/// >     11101...1010010101
/// >       bit 5 = 0 ^    ^ bit 0 = 1
///
/// ## Status
///
/// `0` is considered an "unset" bit, and `1` is considered a "set" bit.
/// Hence `11101` is set at bit 0 and unset at bit 1.
///
/// ## Masking
///
/// In the present implementation, a bitmask refers to a bitstring that
/// is only set at the indicated bit. For example, a bitmask with bit 0
/// set corresponds to `000...001`, and a bitmask with bit 3 set
/// corresponds to `000...01000`.
///
/// # Crit-bit trees
///
/// ## General
///
/// A critical bit (crit-bit) tree is a compact binary prefix tree
/// that stores a prefix-free set of bitstrings, like n-bit integers or
/// variable-length 0-terminated byte strings. For a given set of keys
/// there exists a unique crit-bit tree representing the set, such that
/// crit-bit trees do not require complex rebalancing algorithms like
/// those of AVL or red-black binary search trees. Crit-bit trees
/// support the following operations:
///
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Inorder predecessor iteration
/// * Inorder successor iteration
///
/// ## Structure
///
/// Crit-bit trees have two types of nodes: inner nodes, and leaf nodes.
/// Inner nodes have two leaf children each, and leaf nodes do not
/// have children. Inner nodes store a bitmask set at the node's
/// critical bit (crit-bit), which indicates the most-significant bit of
/// divergence between keys from the node's two subtrees: keys in an
/// inner node's left subtree are unset at the critical bit, while
/// keys in an inner node's right subtree are set at the critical bit.
///
/// Inner nodes are arranged hierarchically, with the most-significant
/// critical bits at the top of the tree. For example, the binary keys
/// `001`, `101`, `110`, and `111` produce the following crit-bit tree:
///
/// >        2nd
/// >       /   \
/// >     001   1st
/// >          /   \
/// >        101   0th
/// >             /   \
/// >           110   111
///
/// Here, the inner node marked `2nd` stores a bitmask set at bit 2, the
/// inner node marked `1st` stores a bitmask set at bit 1, and the inner
/// node marked `0th` stores a bitmask set at bit 0. Hence, the sole key
/// in the left subtree of `2nd` is unset at bit 2, while all the keys
/// in the right subtree of `2nd` are set at bit 2. And similarly for
/// `0th`, the key of its left child is unset at bit 0, while the key of
/// its right child is set at bit 0.
///
/// ## Insertions
///
/// Crit-bit trees are automatically sorted upon insertion, such that
/// inserting `111` to
///
/// >        2nd
/// >       /   \
/// >     001   1st
/// >          /   \
/// >        101    110
///
/// produces:
///
/// >        2nd
/// >       /   \
/// >     001   1st
/// >          /   \
/// >        101   0th
/// >             /   \
/// >           110   111
///
/// Here, `111` may not be re-inserted unless it is first removed from
/// the tree.
///
/// ## Removals
///
/// Continuing the above example, crit-bit trees are automatically
/// compacted and sorted upon removal, such that removing `111` again
/// results in:
///
/// >        2nd
/// >       /   \
/// >     001   1st
/// >          /   \
/// >        101    110
///
/// ## As a map
///
/// Crit-bit trees can be used as an associative array that maps keys
/// to values, simply by storing values in the leaves of the tree.
/// For example, the insertion sequence
///
/// 1. $\langle \texttt{0b001}, v_0 \rangle$
/// 2. $\langle \texttt{0b111}, v_1 \rangle$
/// 3. $\langle \texttt{0b110}, v_2 \rangle$
/// 4. $\langle \texttt{0b101}, v_3 \rangle$
///
/// produces the following tree:
///
/// >                2nd
/// >               /   \
/// >     <001, v_0>    1st
/// >                  /   \
/// >        <101, v_3>    0th
/// >                     /   \
/// >           <110, v_2>     <111, v_1>
///
/// ## References
///
/// * [Bernstein 2004] (Earliest identified author)
/// * [Langley 2008] (Primary reference for this implementation)
/// * [Langley 2012]
/// * [Tcler's Wiki 2021]
///
/// [Bernstein 2004]:
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
/// ## Key storage multiplicity
///
/// Unlike a crit-bit tree, which can only store one instance of a given
/// key, crit-queues can store multiple instances. For example, the
/// following insertion sequence, without intermediate removals, is
/// invalid in a crit-bit tree but valid in a crit-queue:
///
/// 1. $p_{3, 0} = \langle 3, 5 \rangle$
/// 2. $p_{3, 1} = \langle 3, 8 \rangle$
/// 3. $p_{3, 2} = \langle 3, 2 \rangle$
/// 4. $p_{3, 3} = \langle 3, 5 \rangle$
///
/// Here, the "key-value insertion pair"
/// $p_{i, j} = \langle i, v_j \rangle$ has:
///
/// * "Insertion key" $i$: the inserted key.
/// * "Insertion count" $j$: the number of key-value insertion pairs,
///   having the same insertion key, that were previously inserted.
/// * "Insertion value" $v_j$: the value from the key-value
///   insertion pair having insertion count $j$.
///
/// ## Sorting order
///
/// Key-value insertion pairs in a crit-queue are sorted by:
///
/// 1. Either ascending or descending order of insertion key, then by
/// 2. Ascending order of insertion count.
///
/// For example, consider the following binary insertion key sequence,
/// where $k_{i, j}$ denotes insertion key $i$ with insertion count $j$:
///
/// 1. $k_{0, 0} = \texttt{0b00}$
/// 2. $k_{1, 0} = \texttt{0b01}$
/// 3. $k_{1, 1} = \texttt{0b01}$
/// 4. $k_{0, 1} = \texttt{0b00}$
/// 5. $k_{3, 0} = \texttt{0b11}$
///
/// In an ascending crit-queue, the dequeue sequence would be:
///
/// 1. $k_{0, 0} = \texttt{0b00}$
/// 2. $k_{0, 1} = \texttt{0b00}$
/// 3. $k_{1, 0} = \texttt{0b01}$
/// 4. $k_{1, 1} = \texttt{0b01}$
/// 5. $k_{3, 0} = \texttt{0b11}$
///
/// In a descending crit-queue, the dequeue sequence would instead be:
///
/// 1. $k_{3, 0} = \texttt{0b11}$
/// 2. $k_{1, 0} = \texttt{0b01}$
/// 3. $k_{1, 1} = \texttt{0b01}$
/// 4. $k_{0, 0} = \texttt{0b00}$
/// 5. $k_{0, 1} = \texttt{0b00}$
///
/// ## Leaves
///
/// The present crit-queue implementation involves a crit-bit tree with
/// a leaf node for each insertion key, where each "leaf key" has the
/// following bit structure:
///
/// | Bit(s) | Value         |
/// |--------|---------------|
/// | 64-127 | Insertion key |
/// | 0-63   | 0             |
///
/// Continuing the above example:
///
/// | Insertion key | Leaf key bits 64-127 | Leaf key bits 0-63 |
/// |---------------|----------------------|--------------------|
/// | `0 = 0b00`    | `000...000`          | `000...000`        |
/// | `1 = 0b01`    | `000...001`          | `000...000`        |
/// | `3 = 0b11`    | `000...011`          | `000...000`        |
///
/// Each leaf contains a nested sub-queue of key-values insertion
/// pairs all sharing the corresponding insertion key, with lower
/// insertion counts at the front of the queue. Continuing the above
/// example, this yields the following:
///
/// >                                   65th
/// >                                  /    \
/// >                              64th      000...011000...000
/// >                             /    \     [k_{3, 0}]
/// >                            /      \
/// >          000...000000...000        000...001000...000
/// >     [k_{0, 0} --> k_{0, 1}]        [k_{1, 0} --> k_{1, 1}]
/// >      ^ sub-queue head               ^ sub-queue head
///
/// Leaf keys are guaranteed to be unique, and all leaf nodes are stored
/// in a single hash table.
///
/// ## Sub-queue nodes
///
/// All sub-queue nodes are similarly stored in single hash table, and
/// assigned a unique "access key" with the following bit structure
/// (`NOT` denotes bitwise complement):
///
/// | Bit(s) | Ascending crit-queue | Descending crit-queue |
/// |--------|----------------------|-----------------------|
/// | 64-127 | Insertion key        | Insertion key         |
/// | 63     | 0                    | 0                     |
/// | 62     | 0                    | 1                     |
/// | 0-61   | Insertion count      | `NOT` insertion count |
///
/// For an ascending crit-queue, access keys are thus dequeued in
/// ascending lexicographical order:
///
/// | Insertion key | Access key bits 64-127 | Access key bits 0-63 |
/// |---------------|------------------------|----------------------|
/// | $k_{0, 0}$    | `000...000`            | `000...000`          |
/// | $k_{0, 1}$    | `000...000`            | `000...001`          |
/// | $k_{1, 0}$    | `000...001`            | `000...000`          |
/// | $k_{1, 1}$    | `000...001`            | `000...001`          |
/// | $k_{3, 0}$    | `000...011`            | `000...000`          |
///
/// Conversely, for a descending crit-queue, access keys are thus
/// dequeued in descending lexicographical order:
///
/// | Insertion key | Access key bits 64-127 | Access key bits 0-63 |
/// |---------------|----------------------|--------------------|
/// | $k_{3, 0}$    | `000...011`          | `011...111`        |
/// | $k_{1, 0}$    | `000...001`          | `011...111`        |
/// | $k_{1, 1}$    | `000...001`          | `011...110`        |
/// | $k_{0, 0}$    | `000...000`          | `011...111`        |
/// | $k_{0, 1}$    | `000...000`          | `011...110`        |
///
/// ## Inner keys
///
/// After access key assignment, if the insertion of a key-value
/// insertion pair requires the creation of a new inner node, the
/// inner node is assigned a unique "inner key" that is identical to
/// the new access key, except with bit 63 set. This schema allows for
/// discrimination between inner keys and leaf keys based solely on
/// bit 63.
///
/// All inner nodes are stored in a single hash table.
///
/// ## Insertion counts
///
/// Insertion counts are tracked in leaf nodes, such that before the
/// insertion of the first instance of a given insertion key,
/// $k_{i, 0}$, the leaf table does not have an entry corresponding
/// to insertion key $i$.
///
/// When $k_{i, 0}$ is inserted, a new leaf node is initialized with
/// an insertion counter set to 0, then added to the leaf hash table.
/// The new leaf node is inserted to the crit-bit tree, and a
/// corresponding sub-queue node is placed at the head of the new leaf's
/// sub-queue. For each subsequent insertion of the same insertion key,
/// $k_{i, n}$, the leaf insertion counter is updated to $n$, and the
/// new sub-queue node becomes the tail of the corresponding sub-queue.
///
/// Since bits 62 and 63 in access keys are reserved for flag bits, the
/// maximum insertion count per insertion key is thus $2^{62} - 1$.
///
/// ## Dequeue order preservation
///
/// Removals can take place from anywhere inside of a crit-queue, with
/// the specified dequeue order preserved among remaining elements.
/// For example, consider the elements in an ascending crit-queue
/// with the following dequeue sequence:
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
/// ## Sub-queue removal updates
///
/// Removal via access key lookup in the sub-queue node hash table leads
/// to an update within the corresponding sub-queue.
///
/// For example, consider the following crit-queue:
///
/// >                                          64th
/// >                                         /    \
/// >                       000...000000...000      000...001000...000
/// >     [k_{0, 0} --> k_{0, 1} --> k_{0, 2}]      [k_{1, 0}]
/// >      ^ sub-queue head
///
/// Removal of $k_{0, 1}$ produces:
///
/// >                             64th
/// >                            /    \
/// >          000...000000...000      000...001000...000
/// >     [k_{0, 0} --> k_{0, 2}]      [k_{1, 0}]
///
/// And similarly for $k_{0, 0}$:
///
/// >                        64th
/// >                       /    \
/// >     000...000000...000      000...001000...000
/// >             [k_{0, 2}]      [k_{1, 0}]
///
/// Here, if ${k_{0, 2}}$ were to be removed, the tree would then have a
/// single leaf at its root:
///
/// >     000...001000...000 (root)
/// >         [k_{1, 0}]
///
/// Notably, however, the leaf corresponding to insertion key 0 is not
/// deallocated, but rather, is converted to a "free leaf" with an
/// empty sub-queue.
///
/// ## Free leaves
///
/// Free leaves are leaf nodes with an empty sub-queue.
///
/// Free leaves track insertion counts in case another key-value
/// insertion pair, having the insertion key encoded in the free leaf
/// key, is inserted. Here, the free leaf is added back to the crit-bit
/// tree and the new sub-queue node becomes the head of the leaf's
/// sub-queue. Continuing the example, inserting another key-value pair
/// with insertion key 0, $k_{0, 3}$, produces:
///
/// >                        64th
/// >                       /    \
/// >     000...000000...000      000...001000...000
/// >             [k_{0, 3}]      [k_{1, 0}]
///
/// ## Dequeues
///
/// Dequeues are processed as removals from the crit-queue head, a field
/// that stores:
///
/// * The maximum access key in a descending crit-queue, or
/// * The minimum access key in an ascending crit-queue.
///
/// After all elements in the corresponding sub-queue have been dequeued
/// in order of ascending insertion count, dequeueing proceeds with the
/// head of the sub-queue in the next leaf, which is accessed by either:
///
/// * Inorder predecessor traversal if a descending crit-queue, or
/// * Inorder successor traversal if an ascending crit-queue.
///
/// # Implementation analysis
///
/// ## Core functionality
///
/// In the present implementation, key-value insertion pairs are
/// inserted via `insert()`, which accepts a `u64` insertion key and
/// insertion value of type `V`. A corresponding `u128` access key is
/// returned, which can be used for subsequent access key lookup via `
/// borrow()`, `borrow_mut()`, `dequeue()`, or `remove()`.
///
/// ## Inserting
///
/// Insertions are, like a crit-bit tree, $O(k)$ in the worst case,
/// where $k = 64$ (the number of variable bits in an insertion key),
/// since a new leaf node has to be inserted into the crit-bit tree.
/// In the intermediate case where a new leaf node has to be inserted
/// into the crit-bit tree but the tree is generally balanced,
/// insertions improve to $O(log_2(n))$, where $n$ is the number of
/// leaves in the tree. In the best case, where the corresponding
/// sub-queue already has a leaf in the crit-bit tree and a new
/// sub-queue node simply has to be inserted at the tail of the
/// sub-queue, insertions improve to $O(1)$.
///
/// Insertions are parallelizable in the general case where:
///
/// 1. They do not alter the head of the crit-queue.
/// 2. They do not write to overlapping crit-bit tree edges.
/// 3. They do not write to overlapping sub-queue edges.
/// 4. They alter neither the head nor the tail of the same sub-queue.
/// 5. They do not write to the same sub-queue.
///
/// The final parallelism constraint is a result of insertion count
/// updates, and may potentially be eliminated in the case of a
/// parallelized insertion count aggregator.
///
/// ## Removing
///
/// With sub-queue nodes stored in a hash table, removal operations via
/// access key are are thus $O(1)$, and are parallelizable in the
/// general case where:
///
/// 1. They do not alter the head of the crit-queue.
/// 2. They do not write to overlapping crit-bit tree edges.
/// 3. They do not write to overlapping sub-queue edges.
/// 4. They alter neither the head nor the tail of the same sub-queue.
///
/// ## Dequeuing
///
/// Dequeues, as a form of removal, are $O(1)$, but since they alter
/// the head of the queue, they are not parallelizable. Dequeues
/// are initialized via `dequeue_init()`, and iterated via `dequeue()`.
///
/// ---
///
module econia::critqueue {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table::{Self, Table};
    use std::option::{Self, Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use std::vector;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Hybrid between a crit-bit tree and a queue. See above.
    struct CritQueue<V> has store {
        /// Crit-queue sort order, `ASCENDING` or `DESCENDING`.
        order: bool,
        /// Node key of crit-bit tree root. None if crit-queue is empty.
        root: Option<u128>,
        /// Access key of crit-queue head. None if crit-queue is empty,
        /// else minimum access key if ascending crit-queue, and
        /// maximum access key if descending crit-queue.
        head: Option<u128>,
        /// Map from inner key to inner node.
        inners: Table<u128, Inner>,
        /// Map from leaf key to leaf node.
        leaves: Table<u128, Leaf>,
        /// Map from access key to sub-queue node.
        subqueue_nodes: Table<u128, SubQueueNode<V>>
    }

    /// A crit-bit tree inner node.
    struct Inner has store {
        /// Bitmask set at critical bit.
        bitmask: u128,
        /// If none, node is root. Else parent key.
        parent: Option<u128>,
        /// Left child key.
        left: u128,
        /// Right child key.
        right: u128
    }

    /// A crit-bit tree leaf node. A free leaf if no sub-queue head.
    /// Else the root of the crit-bit tree if no parent.
    struct Leaf has store {
        /// 0-indexed insertion count for corresponding insertion key.
        count: u64,
        /// If no sub-queue head or tail, should also be none, since
        /// leaf is a free leaf. Else corresponds to the inner key of
        /// the leaf's parent node, none when leaf is the root of the
        /// crit-bit tree.
        parent: Option<u128>,
        /// If none, node is a free leaf. Else the access key of the
        /// sub-queue head.
        head: Option<u128>,
        /// If none, node is a free leaf. Else the access key of the
        /// sub-queue tail.
        tail: Option<u128>
    }

    /// A node in a sub-queue.
    struct SubQueueNode<V> has store {
        /// Insertion value.
        insertion_value: V,
        /// Access key of previous sub-queue node, if any.
        previous: Option<u128>,
        /// Access key of next sub-queue node, if any.
        next: Option<u128>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When an insertion key has been inserted too many times.
    const E_TOO_MANY_INSERTIONS: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// `u128` bitmask set at bit 63, for converting an access key
    /// to an inner key via bitwise `OR`. Generated in Python via
    /// `hex(int('1' + '0' * 63, 2))`.
    const ACCESS_KEY_TO_INNER_KEY: u128 = 0x8000000000000000;
    /// `u128` bitmask set at bits 64-127, for converting an access key
    /// to a leaf key via bitwise `AND`. Generated in Python via
    /// `hex(int('1' * 64 + '0' * 64, 2))`.
    const ACCESS_KEY_TO_LEAF_KEY: u128 = 0xffffffffffffffff0000000000000000;
    /// Ascending crit-queue flag.
    const ASCENDING: bool = false;
    /// Descending crit-queue flag.
    const DESCENDING: bool = true;
    /// `u128` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 128, 2))`.
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// Number of bits that insertion key is shifted in a `u128` key.
    const INSERTION_KEY: u8 = 64;
    /// Maximum number of times a given insertion key can be inserted.
    /// A `u64` bitmask with all bits set except 62 and 63, generated
    /// in Python via `hex(int('1' * 62, 2))`.
    const MAX_INSERTION_COUNT: u64 = 0x3fffffffffffffff;
    /// Most significant bit number for a `u128`
    const MSB_u128: u8 = 127;
    /// `u128` bitmask set at bit 63, the crit-bit tree node type
    /// bit flag, generated in Python via `hex(int('1' + '0' * 63, 2))`.
    const TREE_NODE_TYPE: u128 = 0x8000000000000000;
    /// Result of bitwise crit-bit tree node key `AND` with
    /// `TREE_NODE_TYPE`, indicating that the key is set at bit 63 and
    /// is thus an inner key. Generated in Python via
    /// `hex(int('1' + '0' * 63, 2))`.
    const TREE_NODE_INNER: u128 = 0x8000000000000000;
    /// Result of bitwise crit-bit tree node key `AND` with
    /// `TREE_NODE_TYPE`, indicating that the key is unset at bit 63
    /// and is thus a leaf key.
    const TREE_NODE_LEAF: u128 = 0;
    /// `XOR` bitmask for flipping insertion count bits 0-61 and
    /// setting bit 62 high in the case of a descending crit-queue.
    /// `u64` bitmask with all bits set except bit 63, cast to a `u128`.
    /// Generated in Python via `hex(int('1' * 63, 2))`.
    const NOT_INSERTION_COUNT_DESCENDING: u128 = 0x7fffffffffffffff;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow insertion value corresponding to `access_key` in given
    /// `CritQueue`, aborting if no such access key.
    public fun borrow<V>(
        critqueue_ref: &CritQueue<V>,
        access_key: u128
    ): &V {
        &table::borrow(
            &critqueue_ref.subqueue_nodes, access_key).insertion_value
    }

    /// Mutably borrow insertion value corresponding to `access_key`
    /// `CritQueue`, aborting if no such access key
    public fun borrow_mut<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        access_key: u128
    ): &mut V {
        &mut table::borrow_mut(
            &mut critqueue_ref_mut.subqueue_nodes, access_key).insertion_value
    }

    /// Return access key of given `CritQueue` head, if any.
    public fun get_head_access_key<V>(
        critqueue_ref: &CritQueue<V>,
    ): Option<u128> {
        critqueue_ref.head
    }

    /// Return `true` if given `CritQueue` has the given `access_key`.
    public fun has_access_key<V>(
        critqueue_ref: &CritQueue<V>,
        access_key: u128
    ): bool {
        table::contains(&critqueue_ref.subqueue_nodes, access_key)
    }

    /// Insert the given `key`-`value` insertion pair into the given
    /// `CritQueue`, returning an access key.
    public fun insert<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        insertion_key: u64,
        insertion_value: V
    ): u128 {
        // Initialize a sub-queue node with the insertion value,
        // assuming it is the sole sub-queue node in a free leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Get leaf key from insertion key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Borrow mutable reference to leaves table.
        let leaves_ref_mut = &mut critqueue_ref_mut.leaves;
        // Determine if corresponding leaf has already been allocated.
        let leaf_already_allocated = table::contains(leaves_ref_mut, leaf_key);
        // Get access key for new sub-queue node, and if corresponding
        // leaf node is a free leaf. If leaf is already allocated:
        let (access_key, _free_leaf) = if (leaf_already_allocated)
            // Update its sub-queue and the new sub-queue node, storing
            // the access key of the new sub-queue node and if the
            // corresponding leaf is free.
            insert_update_subqueue(
                critqueue_ref_mut, &mut subqueue_node, leaf_key)
            // Otherwise, store access key of the new sub-queue node,
            // found in a newly-allocated free leaf.
            else (insert_allocate_leaf(critqueue_ref_mut, leaf_key), true);
        // Borrow mutable reference to sub-queue nodes table.
        let subqueue_nodes_ref_mut = &mut critqueue_ref_mut.subqueue_nodes;
        // Add new sub-queue node to the sub-queue nodes table.
        table::add(subqueue_nodes_ref_mut, access_key, subqueue_node);
        // Check the crit-queue head, updating as necessary.
        insert_check_head(critqueue_ref_mut, access_key);
        // if (free_leaf) insert_leaf(critqueue_ref_mut, leaf_key, access_key);
        access_key // Return access key.
    }

    /// Return `true` if given `CritQueue` is empty.
    public fun is_empty<V>(
        critqueue_ref: &CritQueue<V>,
    ): bool {
        option::is_none(&critqueue_ref.root)
    }

    /// Return `CritQueue` of sort `order` `ASCENDING` or `DESCENDING`.
    public fun new<V: store>(
        order: bool
    ): CritQueue<V> {
        CritQueue{
            order,
            root: option::none(),
            head: option::none(),
            inners: table::new(),
            leaves: table::new(),
            subqueue_nodes: table::new()
        }
    }

    /// Return `true` if, were `insertion_key` to be inserted, its
    /// access key would become the new head of the given `CritQueue`.
    public fun would_become_new_head<V>(
        critqueue_ref: &CritQueue<V>,
        insertion_key: u64
    ): bool {
        // If the crit-queue is empty and thus has no head:
        if (option::is_none(&critqueue_ref.head)) {
            // Return that insertion key would become new head.
            return true
        } else { // Otherwise, if crit-queue is not empty:
            // Get insertion key of crit-queue head.
            let head_insertion_key = (*option::borrow(&critqueue_ref.head) >>
                INSERTION_KEY as u64);
            // If an ascending crit-queue, return true if insertion key
            // is less than insertion key of crit-queue head.
            return if (critqueue_ref.order == ASCENDING)
                insertion_key < head_insertion_key else
                // If a descending crit-queue, return true if insertion
                // key is greater than insertion key of crit-queue head.
                insertion_key > head_insertion_key
        }
    }

    /// Return `true` if, were `insertion_key` to be inserted, its
    /// access key would trail behind the head of the given `CritQueue`.
    public fun would_trail_head<V>(
        critqueue_ref: &CritQueue<V>,
        insertion_key: u64
    ): bool {
        !would_become_new_head(critqueue_ref, insertion_key)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return a bitmask set at the most significant bit at which two
    /// unequal bitstrings, `s1` and `s2`, vary.
    ///
    /// # `XOR`/`AND` method
    ///
    /// Frist, a bitwise `XOR` is used to flag all differing bits:
    ///
    /// >              s1: 11110001
    /// >              s2: 11011100
    /// >     x = s1 ^ s2: 00101101
    /// >                    ^ critical bit = 5
    ///
    /// Here, the critical bit is equivalent to the bit number of the
    /// most significant set bit in the bitwise `XOR` result
    /// `x = s1 ^ s2`. At this point, [Langley 2008] notes that `x`
    /// bitwise `AND` `x - 1` will be nonzero so long as `x` contains
    /// at least some bits set which are of lesser significance than the
    /// critical bit:
    ///
    /// >                   x: 00101101
    /// >               x - 1: 00101100
    /// >     x = x & (x - 1): 00101100
    ///
    /// Thus he suggests repeating `x & (x - 1)` while the new result
    /// `x = x & (x - 1)` is not equal to zero, because such a loop will
    /// eventually reduce `x` to a power of two (excepting the trivial
    /// case where `x` starts as all 0 except bit 0 set, for which the
    /// loop never enters past the initial conditional check). Per this
    /// method, using the new `x` value for the current example, the
    /// second iteration proceeds as follows:
    ///
    /// >                   x: 00101100
    /// >               x - 1: 00101011
    /// >     x = x & (x - 1): 00101000
    ///
    /// The third iteration:
    ///
    /// >                   x: 00101000
    /// >               x - 1: 00100111
    /// >     x = x & (x - 1): 00100000
    //
    /// Now, `x & x - 1` will equal zero and the loop will not begin a
    /// fourth iteration:
    ///
    /// >                 x: 00100000
    /// >             x - 1: 00011111
    /// >     x AND (x - 1): 00000000
    ///
    /// Thus after three iterations a corresponding critical bitmask
    /// has been determined. However, in the case where the two input
    /// strings vary at all bits of lesser significance than the
    /// critical bit, there may be required as many as `k - 1`
    /// iterations, where `k` is the number of bits in each string under
    /// comparison. For instance, consider the case of the two 8-bit
    /// strings `s1` and `s2` as follows:
    ///
    /// >                  s1: 10101010
    /// >                  s2: 01010101
    /// >         x = s1 ^ s2: 11111111
    /// >                      ^ critical bit = 7
    /// >     x = x & (x - 1): 11111110 [iteration 1]
    /// >     x = x & (x - 1): 11111100 [iteration 2]
    /// >     x = x & (x - 1): 11111000 [iteration 3]
    /// >     ...
    ///
    /// Notably, this method is only suggested after already having
    /// identified the varying byte between the two strings, thus
    /// limiting `x & (x - 1)` operations to at most 7 iterations.
    ///
    /// # Binary search method
    ///
    /// For the present implementation, unlike in [Langley 2008],
    /// strings are not partitioned into a multi-byte array, rather,
    /// they are stored as `u128` integers, so a binary search is
    /// instead proposed. Here, the same `x = s1 ^ s2` operation is
    /// first used to identify all differing bits, before iterating on
    /// an upper (`u`) and lower bound (`l`) for the critical bit
    /// number:
    ///
    /// >              s1: 10101010
    /// >              s2: 01010101
    /// >     x = s1 ^ s2: 11111111
    /// >            u = 7 ^      ^ l = 0
    ///
    /// The upper bound `u` is initialized to the length of the
    /// bitstring (7 in this example, but 127 for a `u128`), and the
    /// lower bound `l` is initialized to 0. Next the midpoint `m` is
    /// calculated as the average of `u` and `l`, in this case
    /// `m = (7 + 0) / 2 = 3`, per truncating integer division. Finally,
    /// the shifted compare value `s = x >> m` is calculated, with the
    /// result having three potential outcomes:
    ///
    /// | Shift result | Outcome                              |
    /// |--------------|--------------------------------------|
    /// | `s == 1`     | The critical bit `c` is equal to `m` |
    /// | `s == 0`     | `c < m`, so set `u` to `m - 1`       |
    /// | `s > 1`      | `c > m`, so set `l` to `m + 1`       |
    ///
    /// Hence, continuing the current example:
    ///
    /// >              x: 11111111
    /// >     s = x >> m: 00011111
    ///
    /// `s > 1`, so `l = m + 1 = 4`, and the search window has shrunk:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >            u = 7 ^  ^ l = 4
    ///
    /// Updating the midpoint yields `m = (7 + 4) / 2 = 5`:
    ///
    /// >              x: 11111111
    /// >     s = x >> m: 00000111
    ///
    /// Again `s > 1`, so update `l = m + 1 = 6`, and the window
    /// shrinks again:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >            u = 7 ^^ l = 6
    /// >      s = x >> m: 00000011
    ///
    /// Again `s > 1`, so update `l = m + 1 = 7`, the final iteration:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >            u = 7 ^ l = 7
    /// >      s = x >> m: 00000001
    ///
    /// Here, `s == 1`, which means that `c = m = 7`, and the
    /// corresponding critical bitmask `1 << c` is returned:
    ///
    /// >         s1: 10101010
    /// >         s2: 01010101
    /// >     1 << c: 10000000
    ///
    /// Notably this search has converged after only 3 iterations, as
    /// opposed to 7 for the linear search proposed above, and in
    /// general such a search converges after $log_2(k)$ iterations at
    /// most, where $k$ is the number of bits in each of the strings
    /// `s1` and `s2` under comparison. Hence this search method
    /// improves the $O(k)$ search proposed by [Langley 2008] to
    /// $O(log_2(k))$.
    fun get_critical_bitmask(
        s1: u128,
        s2: u128,
    ): u128 {
        let x = s1 ^ s2; // XOR result marked 1 at bits that differ.
        let l = 0; // Lower bound on critical bit search.
        let u = MSB_u128; // Upper bound on critical bit search.
        loop { // Begin binary search.
            let m = (l + u) / 2; // Calculate midpoint of search window.
            let s = x >> m; // Calculate midpoint shift of XOR result.
            if (s == 1) return 1 << m; // If shift equals 1, c = m.
            // Update search bounds.
            if (s > 1) l = m + 1 else u = m - 1;
        }
    }

    /// Allocate a leaf during insertion.
    ///
    /// Inner function for `insert()`.
    ///
    /// # Returns
    /// * `u128`: Access key of new sub-queue node.
    ///
    /// # Assumptions
    /// * `critqueue_ref_mut` indicates a `CritQueue` that does not have
    ///   an allocated leaf with the given `leaf_key`.
    /// * A `SubQueueNode` with the appropriate access key has been
    ///   initialized as if it were the sole sub-queue node in a free
    ///   leaf.
    fun insert_allocate_leaf<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        leaf_key: u128
    ): u128 {
        // Get the sort order of the crit-queue.
        let order = critqueue_ref_mut.order;
        // Get access key. If ascending, is identical to leaf key, which
        // has insertion count in bits 64-127 and 0 for bits 0-63.
        let access_key = if (order == ASCENDING) leaf_key else
            // Else same, but flipped insertion count and bit 63 set.
            leaf_key  ^ NOT_INSERTION_COUNT_DESCENDING;
        // Declare leaf with insertion count 0, no parent, and new
        // sub-queue node as both head and tail.
        let leaf = Leaf{count: 0, parent: option::none(), head:
            option::some(access_key), tail: option::some(access_key)};
        // Borrow mutable reference to leaves table.
        let leaves_ref_mut = &mut critqueue_ref_mut.leaves;
        // Add the leaf to the leaves table.
        table::add(leaves_ref_mut, leaf_key, leaf);
        access_key // Return access key.
    }

    /// Check head of given `CritQueue`, optionally setting it to the
    /// `access_key` of a new key-value insertion pair.
    ///
    /// Inner function for `insert()`.
    fun insert_check_head<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        access_key: u128
    ) {
        // Get crit-queue sort order.
        let order = critqueue_ref_mut.order;
        // Get mutable reference to crit-queue head field.
        let head_ref_mut = &mut critqueue_ref_mut.head;
        if (option::is_none(head_ref_mut)) { // If an empty crit-queue:
            // Set the head to be the new access key.
            option::fill(head_ref_mut, access_key);
        } else { // If crit-queue is not empty:
            // If the sort order is ascending and new access key is less
            // than that of the crit-queue head, or
            if ((order == ASCENDING &&
                    access_key < *option::borrow(head_ref_mut)) ||
                // If descending sort order and new access key is
                // greater than that of crit-queue head:
                (order == DESCENDING &&
                    access_key > *option::borrow(head_ref_mut)))
                // Set new access key as the crit-queue head.
                _ = option::swap(head_ref_mut, access_key);
        };
    }

    /// Insert a free leaf to the crit-bit tree in a crit-queue.
    ///
    /// Inner function for `insert()`.
    ///
    /// If crit-queue is empty, set root as new leaf key and return,
    /// otherwise search for the closest leaf in the crit-bit tree. Then
    /// get the critical bit between the new leaf key and the search
    /// match, which becomes the critical bitmask of a new inner node to
    /// insert. Start walking up the tree, inserting the new inner node
    /// below the first walked node with a larger critical bit, or above
    /// the root of the tree, whichever comes first.
    ///
    /// # Parameters
    /// * `critqueue_ref_mut`: Mutable reference to crit-queue.
    /// * `leaf_key`: Leaf key of free leaf to insert.
    /// * `access_key`: Unique access key of key-value insertion pair
    ///   just inserted, from which new inner node key is derived.
    ///
    /// # Assumptions
    /// * Given `CritQueue` has a free leaf with `leaf_key`.
    ///
    /// # Diagrams
    ///
    /// For ease of illustration, critical bitmasks and leaf keys are
    /// depicted relative to bit 64, but tested with correspondingly
    /// bitshifted amounts, for inner keys that are additionally
    /// encoded with a mock insertion key, mock insertion count,
    /// and inner node bit flag.
    ///
    /// 1. Start by inserting `0011` to an empty tree:
    ///
    /// >     0011
    ///
    /// 2. Then insert `0100`:
    ///
    /// >         2nd
    /// >        /   \
    /// >     0011   0100
    ///
    /// 3. Insert `0101`:
    ///
    /// >          2nd
    /// >         /   \
    /// >      0011   0th
    /// >            /   \
    /// >         0100   0101
    ///
    /// 4. Insert `1000`:
    ///
    /// >             3rd
    /// >            /   \
    /// >          2nd   1000
    /// >         /   \
    /// >      0011   0th
    /// >            /   \
    /// >         0100   0101
    ///
    /// 5. Insert `0110`:
    ///
    /// >             3rd
    /// >            /   \
    /// >          2nd   1000
    /// >         /   \
    /// >      0011   1st
    /// >            /   \
    /// >          0th   0110
    /// >         /   \
    /// >      0100   0101
    ///
    /// ## Testing
    /// * `test_insert_leaf()`
    fun insert_leaf<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        leaf_key: u128,
        access_key: u128
    ) {
        // If crit-queue is empty, set root as new leaf key and return.
        if (option::is_none(&critqueue_ref_mut.root))
            return option::fill(&mut critqueue_ref_mut.root, leaf_key);
        // Get inner key for new inner node corresponding to access key.
        let new_inner_node_key = access_key | ACCESS_KEY_TO_INNER_KEY;
        // Search for closest leaf, returning its leaf key, the inner
        // key of its parent, and the parent's critical bitmask.
        let (walk_node_key, optional_parent_key, optional_parent_bitmask) =
            search(critqueue_ref_mut, leaf_key);
        // Get critical bitmask between new leaf key and walk leaf key.
        let critical_bitmask = get_critical_bitmask(leaf_key, walk_node_key);
        loop { // Start walking up tree from search leaf.
            // Return if walk node is root and has no parent,
            if (option::is_none(&optional_parent_key)) return
                // By inserting free leaf above it.
                insert_leaf_above_root_node(critqueue_ref_mut, walk_node_key,
                    new_inner_node_key, critical_bitmask, leaf_key);
            // Otherwise there is a parent, so get its key and bitmask.
            let (parent_key, parent_bitmask) =
                (*option::borrow(&optional_parent_key),
                 *option::borrow(&optional_parent_bitmask));
            // Return if critical bitmask is less than that of parent,
            if (critical_bitmask < parent_bitmask) return
                // By inserting free leaf below the parent.
                insert_leaf_below_anchor_node(critqueue_ref_mut, parent_key,
                    new_inner_node_key, critical_bitmask, leaf_key);
            // If have not returned, walk continues at parent node.
            walk_node_key = parent_key;
            // Immutably borrow inner nodes table.
            let inners_ref = &critqueue_ref_mut.inners;
            // Immutably borrow the new inner node to walk.
            let walk_node_ref = table::borrow(inners_ref, walk_node_key);
            // Get its optional parent key.
            optional_parent_key = walk_node_ref.parent;
            // If new node to walk has no parent:
            if (option::is_none(&optional_parent_key)) {
                // Set optional parent bitmask to none.
                optional_parent_bitmask = option::none();
            } else { // If new node to walk does have a parent:
                // Get the parent's key.
                parent_key = *(option::borrow(&optional_parent_key));
                // Immutably borrow the parent.
                let parent_ref = table::borrow(inners_ref, parent_key);
                // Pack its bitmask in an option.
                optional_parent_bitmask = option::some(parent_ref.bitmask);
            }
        }
    }

    /// Insert new free leaf and inner node above the root inner node.
    ///
    /// Inner function for `insert_leaf()`.
    ///
    /// # Parameters
    /// * `critqueue_ref_mut`: Mutable reference to crit-queue.
    /// * `root_node_key`: Key of the inner node to insert above.
    /// * `new_inner_node_key`: Inner key of new inner node to insert.
    /// * `new_inner_node_bitmask`: Critical bitmask for new inner node.
    /// * `new_leaf_key`: Leaf key of free leaf to insert to the tree.
    ///
    /// # Assumptions
    /// * Given `CritQueue` has a free leaf with `new_leaf_key`.
    /// * `new_inner_node_bitmask` is greater than that of root node,
    ///   which has been reached via upward walk in `insert_leaf()`.
    ///
    /// # Reference diagrams
    ///
    /// For ease of illustration, critical bitmasks and leaf keys are
    /// depicted relative to bit 64, but tested with correspondingly
    /// bitshifted amounts, for inner keys that are additionally
    /// encoded with a mock insertion key, mock insertion count,
    /// and inner node bit flag.
    ///
    /// Both insertion examples reference the following diagram:
    ///
    /// >         1st
    /// >        /   \
    /// >     1001   1011
    ///
    /// ## Insertion above to the left
    ///
    /// Here, inserting `0001` yields:
    ///
    /// >                     3rd <- new inner node
    /// >                    /   \
    /// >     new leaf -> 0001   1st <- old root node
    /// >                       /   \
    /// >                    1001   1011
    ///
    /// ## Insertion above to the right
    ///
    /// If `1100` were to be inserted instead:
    ///
    /// >       new inner node -> 2nd
    /// >                        /   \
    /// >     old root node -> 1st   1100 <- new leaf
    /// >                     /   \
    /// >                  1001   1011
    ///
    /// ## Testing
    /// * `test_insert_leaf_above_root_node_1()`
    /// * `test_insert_leaf_above_root_node_2()`
    fun insert_leaf_above_root_node<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        root_node_key: u128,
        new_inner_node_key: u128,
        new_inner_node_bitmask: u128,
        new_leaf_key: u128
    ) {
        // Set crit-queue root field to indicate new inner node.
        option::swap(&mut critqueue_ref_mut.root, new_inner_node_key);
        // Borrow mutable reference to leaves table.
        let leaves_ref_mut = &mut critqueue_ref_mut.leaves;
        let new_leaf_ref_mut = // Borrow mutable reference to new leaf.
            table::borrow_mut(leaves_ref_mut, new_leaf_key);
        // Set new leaf to have as its parent the new inner node.
        option::fill(&mut new_leaf_ref_mut.parent, new_inner_node_key);
        // Borrow mutable reference to inner nodes table.
        let inners_ref_mut = &mut critqueue_ref_mut.inners;
        let root_node_ref_mut = // Mutably borrow old root node.
            table::borrow_mut(inners_ref_mut, root_node_key);
        // Set old root node to have new inner node as its parent.
        option::fill(&mut root_node_ref_mut.parent, new_inner_node_key);
        // If leaf key AND new inner node's critical bitmask is 0,
        // free leaf is unset at new inner node's critical bit and
        // should thus go on its left, with the old root on new inner
        // node's right. Else the opposite.
        let (left, right) = if (new_leaf_key & new_inner_node_bitmask == 0)
            (new_leaf_key, root_node_key) else (root_node_key, new_leaf_key);
        // Add to inner nodes table the new inner node as root.
        table::add(inners_ref_mut, new_inner_node_key, Inner{left, right,
            bitmask: new_inner_node_bitmask, parent: option::none()});
    }

    /// Insert new free leaf and inner node below anchor node.
    ///
    /// Inner function for `insert_leaf()`.
    ///
    /// # Parameters
    /// * `critqueue_ref_mut`: Mutable reference to crit-queue.
    /// * `anchor_node_key`: Key of the inner node to insert below, the
    ///   "anchor node".
    /// * `new_inner_node_key`: Inner key of new inner node to insert.
    /// * `new_inner_node_bitmask`: Critical bitmask for new inner node.
    /// * `new_leaf_key`: Leaf key of free leaf to insert to the tree.
    ///
    /// # Assumptions
    /// * Given `CritQueue` has a free leaf with `new_leaf_key`.
    /// * `new_inner_node_bitmask` is less than that of anchor node,
    ///   which has been reached via upward walk in `insert_leaf()`.
    /// * `new_inner_node_bitmask` is greater than that of the displaced
    ///   child, if the displaced child is an inner node (see below).
    ///
    /// # Reference diagrams
    ///
    /// For ease of illustration, critical bitmasks and leaf keys are
    /// depicted relative to bit 64, but tested with correspondingly
    /// bitshifted amounts, for inner keys that are additionally
    /// encoded with a mock insertion key, mock insertion count,
    /// and inner node bit flag.
    ///
    /// Both insertion examples reference the following diagram:
    ///
    /// >         3rd
    /// >        /   \
    /// >     0001   1st
    /// >           /   \
    /// >        1001   1011
    ///
    /// ## Anchor node children polarity
    ///
    /// The anchor node is the node below which the free leaf and new
    /// inner node should be inserted, for example either `3rd` or
    /// `1st`. The free leaf key can be inserted to either the left or
    /// the right of the anchor node, depending on its whether it is
    /// unset or set, respectively, at the anchor node's critical bit.
    /// For example, per below, a free leaf key of `1000` would
    /// be inserted to the left of `1st`, while a free leaf key of
    /// `1111` would be inserted to the right of `3rd`.
    ///
    /// ## Child displacement
    ///
    /// When a leaf key is inserted, a new inner node is generated,
    /// which displaces either the left or the right child of the anchor
    /// node, based on the side that the leaf key should be inserted.
    /// For example, inserting free leaf key `1000` displaces `1001`:
    ///
    /// >                       3rd
    /// >                      /   \
    /// >                   0001   1st <- anchor node
    /// >                         /   \
    /// >     new inner node -> 0th   1011
    /// >                      /   \
    /// >       new leaf -> 1000   1001 <- displaced child
    ///
    /// Both leaves and inner nodes can be displaced. For example,
    /// were free leaf key `1111` to be inserted instead, it would
    /// displace `1st`:
    ///
    /// >                        3rd <- anchor node
    /// >                       /   \
    /// >                    0001   2nd <- new inner node
    /// >                          /   \
    /// >     displaced child -> 1st   1111 <- new leaf
    /// >                       /   \
    /// >                    1001   1011
    ///
    /// ## New inner node children polarity
    ///
    /// The new inner node can have the new leaf as either its left or
    /// right child, depending on the new inner node's critical bit.
    /// As in the first example above, where the new leaf is unset at
    /// the new inner node's critical bit, the new inner node's left
    /// child is the new leaf and new inner node's right child is the
    /// displaced child. Conversely, as in the second example above,
    /// where the new leaf is set at the new inner node's critical bit,
    /// the new inner node's left child is the displaced child and the
    /// new inner node's right child is the new leaf.
    ///
    /// ## Testing
    /// * `test_insert_leaf_below_anchor_node_case_1()`
    /// * `test_insert_leaf_below_anchor_node_case_2()`
    fun insert_leaf_below_anchor_node<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        anchor_node_key: u128,
        new_inner_node_key: u128,
        new_inner_node_bitmask: u128,
        new_leaf_key: u128
    ) {
        // Borrow mutable reference to inner nodes table.
        let inners_ref_mut = &mut critqueue_ref_mut.inners;
        // Borrow mutable reference to leaves table.
        let leaves_ref_mut = &mut critqueue_ref_mut.leaves;
        let anchor_node_ref_mut = // Mutably borrow anchor node.
            table::borrow_mut(inners_ref_mut, anchor_node_key);
        // Get anchor node critical bitmask.
        let anchor_bitmask = anchor_node_ref_mut.bitmask;
        let displaced_child_key; // Declare displaced child key.
        // If new leaf key AND anchor bitmask is 0, new leaf is unset
        // at anchor node's critical bit and should thus go on its left:
        if (new_leaf_key & anchor_bitmask == 0) {
            // Displaced child is thus on anchor's left.
            displaced_child_key = anchor_node_ref_mut.left;
            // Anchor node now has as its left child the new inner node.
            anchor_node_ref_mut.left = new_inner_node_key;
        } else { // If new leaf goes to right of anchor node:
            // Displaced child is thus on anchor's right.
            displaced_child_key = anchor_node_ref_mut.right;
            // Anchor node now has the new inner node as right child.
            anchor_node_ref_mut.right = new_inner_node_key;
        };
        // Determine if displaced child is a leaf.
        let displaced_child_is_leaf =
            displaced_child_key & TREE_NODE_TYPE == TREE_NODE_LEAF;
        // Get mutable reference to displaced child's parent field:
        let displaced_child_parent_field_ref_mut = if (displaced_child_is_leaf)
            // If displaced child is a leaf, borrow from leaves table.
            &mut table::borrow_mut(leaves_ref_mut, displaced_child_key).parent
                else // Else borrow from inner nodes table.
            &mut table::borrow_mut(inners_ref_mut, displaced_child_key).parent;
        // Swap anchor node key in displaced child's parent field with
        // the new inner node key, discarding the anchor node key.
        option::swap(displaced_child_parent_field_ref_mut, new_inner_node_key);
        // If new leaf key AND new inner node's critical bitmask is 0,
        // free leaf is unset at new inner node's critical bit and
        // should thus go on its left, with displaced child on new
        // inner node's right. Else the opposite.
        let (left, right) = if (new_leaf_key & new_inner_node_bitmask == 0)
            (new_leaf_key, displaced_child_key) else
            (displaced_child_key, new_leaf_key);
        // Add to inner nodes table the new inner node.
        table::add(inners_ref_mut, new_inner_node_key, Inner{left, right,
            bitmask: new_inner_node_bitmask,
            parent: option::some(anchor_node_key)});
        let new_leaf_ref_mut = // Borrow mutable reference to new leaf.
            table::borrow_mut(leaves_ref_mut, new_leaf_key);
        // Set new leaf to have as its parent the new inner node.
        option::fill(&mut new_leaf_ref_mut.parent, new_inner_node_key);
    }

    /// Update a sub-queue, inside an allocated leaf, during insertion.
    ///
    /// Inner function for `insert()`.
    ///
    /// # Returns
    /// * `u128`: Access key of new sub-queue node.
    /// * `bool`: `true` if allocated leaf is a free leaf, else `false`.
    ///
    /// # Assumptions
    /// * `critqueue_ref_mut` indicates a `CritQueue` that already
    ///   contains an allocated leaf with the given `leaf_key`.
    /// * `subqueue_node_ref_mut` indicates a `SubQueueNode` with the
    ///   appropriate access key, which has been initialized as if it
    ///   were the sole sub-queue node in a free leaf.
    ///
    /// # Aborts if
    /// * Insertion key encoded in `leaf_key` has already been inserted
    ///   the maximum number of times.
    fun insert_update_subqueue<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        subqueue_node_ref_mut: &mut SubQueueNode<V>,
        leaf_key: u128,
    ): (
        u128,
        bool
    ) {
        // Get the sort order of the crit-queue.
        let order = critqueue_ref_mut.order;
        // Borrow mutable reference to leaves table.
        let leaves_ref_mut = &mut critqueue_ref_mut.leaves;
        // Borrow mutable reference to leaf.
        let leaf_ref_mut = table::borrow_mut(leaves_ref_mut, leaf_key);
        // Get insertion count of new insertion key.
        let count = leaf_ref_mut.count + 1;
        // Assert max insertion count is not exceeded.
        assert!(count <= MAX_INSERTION_COUNT, E_TOO_MANY_INSERTIONS);
        // Update leaf insertion counter.
        leaf_ref_mut.count = count;
        // Get access key. If ascending, bits 64-127 are the same as the
        // leaf key, and bits 0-63 are the insertion count.
        let access_key = if (order == ASCENDING) leaf_key | (count as u128)
            // Else same, but flipped insertion count and bit 63 set.
            else (leaf_key | (count as u128)) ^ NOT_INSERTION_COUNT_DESCENDING;
        // Get old sub-queue tail field.
        let old_tail = leaf_ref_mut.tail;
        // Set sub-queue to have new sub-queue node as its tail.
        leaf_ref_mut.tail = option::some(access_key);
        let free_leaf = true; // Assume free leaf.
        if (option::is_none(&old_tail)) { // If leaf is a free leaf:
            // Update sub-queue to have new node as its head.
            leaf_ref_mut.head = option::some(access_key);
        } else { // If not a free leaf:
            free_leaf = false; // Flag as such.
            // Get the access key of the old sub-queue tail.
            let old_tail_access_key = *option::borrow(&old_tail);
            // Borrow mutable reference to the old sub-queue tail.
            let old_tail_ref_mut = table::borrow_mut(
                &mut critqueue_ref_mut.subqueue_nodes, old_tail_access_key);
            // Set old sub-queue tail to have as its next sub-queue
            // node the new sub-queue node.
            old_tail_ref_mut.next = option::some(access_key);
            // Set the new sub-queue node to have as its previous
            // sub-queue node the old sub-queue tail.
            subqueue_node_ref_mut.previous = old_tail;
        };
        (access_key, free_leaf) // Return access key and if free leaf.
    }

    /// Return `true` if crit-bit tree node `key` is an inner key.
    fun is_inner_key(key: u128): bool {key & TREE_NODE_TYPE == TREE_NODE_INNER}

    /// Return `true` if crit-bit tree node `key` is a leaf key.
    fun is_leaf_key(key: u128): bool {key & TREE_NODE_TYPE == TREE_NODE_LEAF}

    /// Return `true` if `key` is set at `bit_number`.
    fun is_set(key: u128, bit_number: u8): bool {key >> bit_number & 1 == 1}

    /// Search in given `CritQueue` for closest match to `seed_key`.
    ///
    /// If root is a leaf, return immediately. Otherwise, starting at
    /// the root, walk down from inner node to inner node, branching
    /// left whenever `seed_key` is unset at an inner node's critical
    /// bit, and right whenever `seed_key` is set at an inner node's
    /// critical bit. After arriving at a leaf, known as the "match
    /// leaf", return its leaf key, the inner key of its parent, and the
    /// parent's critical bitmask.
    ///
    /// # Returns
    /// * `u128`: Match leaf key.
    /// * `Option<u128>`: Match parent inner key, if any.
    /// * `Option<u128>`: Match parent's critical bitmask, if any.
    ///
    /// # Assumptions
    /// * Given `CritQueue` does not have an empty crit-bit tree.
    ///
    /// # Reference diagrams
    ///
    /// For ease of illustration, critical bitmasks and leaf keys are
    /// depicted relative to bit 64, but tested with correspondingly
    /// bitshifted amounts, for inner keys that are additionally
    /// encoded with a mock insertion key, mock insertion count,
    /// and inner node bit flag.
    ///
    /// ## Leaf at root
    ///
    /// >     111
    ///
    /// | `seed_key` | Match leaf key | Match parent bitmask |
    /// |------------|----------------|----------------------|
    /// | Any        | `111`          | None                 |
    ///
    /// ## Inner node at root
    ///
    /// >        2nd
    /// >       /   \
    /// >     001   1st
    /// >          /   \
    /// >        101   111
    ///
    /// | `seed_key` | Match leaf key  | Match parent bitmask  |
    /// |------------|-----------------|-----------------------|
    /// | `011`      | `001`           | `2nd`                 |
    /// | `100`      | `101`           | `1st`                 |
    /// | `111`      | `111`           | `1st`                 |
    ///
    /// ## Testing
    /// * `test_search()`
    fun search<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        seed_key: u128
    ): (
        u128,
        Option<u128>,
        Option<u128>
    ) {
        // Get crit-queue root key.
        let root_key = *option::borrow(&critqueue_ref_mut.root);
        // If root is a leaf, return its leaf key, and indicate that
        // it does not have a parent.
        if (root_key & TREE_NODE_TYPE == TREE_NODE_LEAF) return
            (root_key, option::none(), option::none());
        let parent_key = root_key; // Otherwise begin walk from root.
        // Borrow mutable reference to table of inner nodes.
        let inners_ref_mut = &mut critqueue_ref_mut.inners;
        // Initialize match parent to corresponding node.
        let parent_ref_mut = table::borrow_mut(inners_ref_mut, parent_key);
        loop { // Loop over inner nodes until arriving at a leaf:
            // Get bitmask of inner node for current iteration.
            let parent_bitmask = parent_ref_mut.bitmask;
            // If leaf key AND inner node's critical bitmask is 0, then
            // the leaf key is unset at the critical bit, so branch to
            // the inner node's left child. Else the right child.
            let child_key = if (seed_key & parent_bitmask == 0)
                parent_ref_mut.left else parent_ref_mut.right;
            // If child is a leaf, have arrived at the match leaf.
            if (child_key & TREE_NODE_TYPE == TREE_NODE_LEAF) return
                // So return the match leaf key, the inner key of the
                // match parent, and the match parent's bitmask, with
                // the latter two packed in an option
                (child_key, option::some(parent_key),
                    option::some(parent_bitmask));
            // If have not returned, child is an inner node, so inner
            // key for next iteration becomes parent key.
            parent_key = child_key;
            // Borrow mutable reference to new inner node to check.
            parent_ref_mut = table::borrow_mut(inners_ref_mut, parent_key);
        }
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// When a char in a bytestring is neither 0 nor 1.
    const E_BIT_NOT_0_OR_1: u64 = 100;

    // Test-only error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Allocate inside given `CritQueue` a mock free leaf, with a leaf
    /// key having the insertion key encoded in `access_key`, and a leaf
    /// insertion counter corresponding to the insertion count encoded
    /// in access key.
    fun allocate_free_leaf_test<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        access_key: u128
    ) {
        // Mutably borrow leaves table.
        let leaves_ref_mut = &mut critqueue_ref_mut.leaves;
        // Get insertion count bits encoded in access key.
        let count = (access_key & (MAX_INSERTION_COUNT as u128) as u64);
        // If a descending crit-queue, take bitwise complement.
        if (critqueue_ref_mut.order == DESCENDING) count = count ^
            MAX_INSERTION_COUNT;
        // Declare mock free leaf.
        let free_leaf = Leaf{count: (count as u64), parent: option::none(),
            head: option::none(), tail: option::none()};
        table::add( // Add mock free leaf to leaves table.
            leaves_ref_mut, access_key & ACCESS_KEY_TO_LEAF_KEY, free_leaf);
    }

    #[test_only]
    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `HI_128`
    fun bit_lo(b: u8): u128 {1 << b ^ HI_128}

    #[test_only]
    /// Return immutable reference to inner node having `inner_key` in
    /// given `CritQueue`.
    fun borrow_inner_test<V>(
        critqueue_ref: &CritQueue<V>,
        inner_key: u128
    ): &Inner {
        table::borrow(&critqueue_ref.inners, inner_key)
    }

    #[test_only]
    /// Return immutable reference to leaf having `leaf_key` in given
    /// `CritQueue`.
    fun borrow_leaf_test<V>(
        critqueue_ref: &CritQueue<V>,
        leaf_key: u128
    ): &Leaf {
        table::borrow(&critqueue_ref.leaves, leaf_key)
    }

    #[test_only]
    /// Return immutable reference to sub-queue node having `access_key`
    /// in given `CritQueue`.
    fun borrow_subqueue_node_test<V>(
        critqueue_ref: &CritQueue<V>,
        access_key: u128
    ): &SubQueueNode<V> {
        table::borrow(&critqueue_ref.subqueue_nodes, access_key)
    }

    #[test_only]
    /// Destroy a crit-queue even if it is not empty.
    fun drop_critqueue_test<V>(
        critqueue: CritQueue<V>
    ) {
        // Unpack all fields, dropping those that are not tables.
        let CritQueue<V>{order: _, root: _, head: _, inners, leaves,
            subqueue_nodes} = critqueue;
        // Drop all tables.
        table::drop_unchecked(inners);
        table::drop_unchecked(leaves);
        table::drop_unchecked(subqueue_nodes);
    }

    #[test_only]
    /// Unpack and destroy a sub-queue node.
    fun drop_subqueue_node_test<V: drop>(
        subqueue_node: SubQueueNode<V>
    ) {
        let SubQueueNode<V>{insertion_value: _, previous: _, next: _} =
            subqueue_node;
    }

    #[test_only]
    /// Wraper for `u_128()`, casting to return to `u64`.
    public fun u_64(s: vector<u8>): u64 {(u_128(s) as u64)}

    #[test_only]
    /// Return a `u128` corresponding to provided byte string `s`. The
    /// byte should only contain only "0"s and "1"s, up to 128
    /// characters max (e.g. `b"100101...10101010"`).
    public fun u_128(
        s: vector<u8>
    ): u128 {
        let n = vector::length<u8>(&s); // Get number of bits.
        let r = 0; // Initialize result to 0.
        let i = 0; // Start loop at least significant bit.
        while (i < n) { // While there are bits left to review.
            // Get bit under review.
            let b = *vector::borrow<u8>(&s, n - 1 - i);
            if (b == 0x31) { // If the bit is 1 (0x31 in ASCII):
                // OR result with the correspondingly leftshifted bit.
                r = r | 1 << (i as u8);
            // Otherwise, assert bit is marked 0 (0x30 in ASCII).
            } else assert!(b == 0x30, E_BIT_NOT_0_OR_1);
            i = i + 1; // Proceed to next-least-significant bit.
        };
        r // Return result.
    }

    #[test_only]
    /// Return `u128` corresponding to concatenated result of `a`, `b`,
    /// `c`, and `d`. Useful for line-wrapping long byte strings, and
    /// inspection via 32-bit sections.
    public fun u_128_by_32(
        a: vector<u8>,
        b: vector<u8>,
        c: vector<u8>,
        d: vector<u8>,
    ): u128 {
        vector::append<u8>(&mut c, d); // Append d onto c.
        vector::append<u8>(&mut b, c); // Append c onto b.
        vector::append<u8>(&mut a, b); // Append b onto a.
        u_128(a) // Return u128 equivalent of concatenated bytestring.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify successful bitmask generation
    fun test_bit_lo() {
        assert!(bit_lo(0) == HI_128 - 1, 0);
        assert!(bit_lo(1) == HI_128 - 2, 0);
        assert!(bit_lo(127) == 0x7fffffffffffffffffffffffffffffff, 0);
    }

    #[test]
    /// Verify borrowing, immutably and mutably.
    fun test_borrowers() {
        let critqueue = new(ASCENDING); // Get ascending crit-queue.
        // Add a mock sub-queue node to the values table.
        table::add(&mut critqueue.subqueue_nodes, 0,
            SubQueueNode{insertion_value: 0, previous: option::none(),
                next: option::none()});
        // Assert correct value borrow.
        assert!(*borrow(&critqueue, 0) == 0, 0);
        *borrow_mut(&mut critqueue, 0) = 123; // Mutate value.
        assert!(*borrow(&critqueue, 0) == 123, 0); // Assert mutation.
        drop_critqueue_test(critqueue); // Drop crit-queue.
    }

    #[test]
    /// Verify successful calculation of critical bit at all positions.
    fun test_get_critical_bitmask() {
        let b = 0; // Start loop for bit 0.
        while (b <= MSB_u128) { // Loop over all bit numbers.
            // Compare 0 versus a bitmask that is only set at bit b.
            assert!(get_critical_bitmask(0, 1 << b) == 1 << b, (b as u64));
            b = b + 1; // Increment bit counter.
        };
    }

    #[test]
    /// Verify lookup returns.
    fun test_get_head_access_key() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Assert no head access key indicated.
        assert!(option::is_none(&get_head_access_key(&critqueue)), 0);
        // Set mock head access key.
        option::fill(&mut critqueue.head, 123);
        // Assert head access key returned correctly.
        assert!(*option::borrow(&get_head_access_key(&critqueue)) == 123, 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify returns for membership checks.
    fun test_has_access_key() {
        let critqueue = new(ASCENDING); // Get ascending crit-queue.
        // Assert arbitrary access key not contained.
        assert!(!has_access_key(&critqueue, 0), 0);
        // Add a mock sub-queue node to the values table.
        table::add(&mut critqueue.subqueue_nodes, 0,
            SubQueueNode{insertion_value: 0, previous: option::none(),
                next: option::none()});
        // Assert arbitrary access key contained.
        assert!(has_access_key(&critqueue, 0), 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify successful allocation.
    fun test_insert_allocate_leaf() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Allocate new leaf, storing access key of new sub-queue node.
        let access_key = insert_allocate_leaf(&mut critqueue, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000001010101",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000"
        ), 0);
        // Borrow reference to newly-allocated leaf.
        let leaf_ref = table::borrow(&critqueue.leaves, leaf_key);
        // Assert fields.
        assert!(leaf_ref.count == 0, 0);
        assert!(option::is_none(&leaf_ref.parent), 0);
        assert!(*option::borrow(&leaf_ref.head) == access_key, 0);
        assert!(*option::borrow(&leaf_ref.head) == access_key, 0);
        critqueue.order = DESCENDING; // Switch crit-queue order.
        insertion_key = u_64(b"10101"); // Reassign insertion key.
        // Reassign leaf key.
        leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Allocate new leaf, storing access key of new sub-queue node.
        access_key = insert_allocate_leaf(&mut critqueue, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000010101",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ), 0);
        // Borrow reference to newly-allocated leaf.
        leaf_ref = table::borrow(&critqueue.leaves, leaf_key);
        // Assert fields.
        assert!(leaf_ref.count == 0, 0);
        assert!(option::is_none(&leaf_ref.parent), 0);
        assert!(*option::borrow(&leaf_ref.head) == access_key, 0);
        assert!(*option::borrow(&leaf_ref.head) == access_key, 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
    }

    #[test]
    /// Verify successful state updates.
    fun test_insert_check_head() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        let new_access_key = u_128(b"10101"); // Get new access key.
        // Check head against new access key.
        insert_check_head(&mut critqueue, new_access_key);
        // Assert head updates to new access key.
        assert!(*option::borrow(&critqueue.head) == new_access_key, 0);
        // Store new access key as old access key.
        let old_access_key = new_access_key;
        // Declare new access key that is less than old one.
        new_access_key = old_access_key - 1;
        // Check head against new access key.
        insert_check_head(&mut critqueue, new_access_key);
        // Assert head updates to new access key.
        assert!(*option::borrow(&critqueue.head) == new_access_key, 0);
        // Store new access key as old access key.
        old_access_key = new_access_key;
        // Declare new access key that is more than old one.
        new_access_key = old_access_key + 1;
        // Check head against new access key.
        insert_check_head(&mut critqueue, new_access_key);
        // Assert head unchanged.
        assert!(*option::borrow(&critqueue.head) == old_access_key, 0);
        // Switch to descending crit-queue.
        critqueue.order = DESCENDING;
        // Check head against new access key.
        insert_check_head(&mut critqueue, new_access_key);
        // Assert head updates to new access key.
        assert!(*option::borrow(&critqueue.head) == new_access_key, 0);
        // Store new access key as old access key.
        old_access_key = new_access_key;
        // Declare new access key that is less than old one.
        new_access_key = old_access_key - 1;
        // Check head against new access key.
        insert_check_head(&mut critqueue, new_access_key);
        // Assert head unchanged.
        assert!(*option::borrow(&critqueue.head) == old_access_key, 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
    }

    #[test]
    /// Verify final tree for `insert_leaf()` reference insertions.
    fun test_insert_leaffffffffffffffffffffffffffff(): CritQueue<u8> {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Declare access keys with mock insertion counts.
        let access_key_0011 = u_128(b"0011") << INSERTION_KEY | 123;
        //let access_key_0100 = u_128(b"0100") << INSERTION_KEY | 456;
        //let access_key_0101 = u_128(b"0101") << INSERTION_KEY | 0;
        //let access_key_1000 = u_128(b"1000") << INSERTION_KEY | 1;
        //let access_key_0110 = u_128(b"0110") << INSERTION_KEY |
            //(MAX_INSERTION_COUNT as u128);
        // Get leaf keys from access keys.
        let leaf_key_0011 =  access_key_0011 & ACCESS_KEY_TO_LEAF_KEY;
        //let leaf_key_0100 =  access_key_0100 & ACCESS_KEY_TO_LEAF_KEY;
        //let leaf_key_0101 =  access_key_0101 & ACCESS_KEY_TO_LEAF_KEY;
        //let leaf_key_1000 =  access_key_1000 & ACCESS_KEY_TO_LEAF_KEY;
        //let leaf_key_0110 =  access_key_0110 & ACCESS_KEY_TO_LEAF_KEY;
        // Allocate free leaves for all access keys.
        allocate_free_leaf_test(&mut critqueue, access_key_0011);
        //allocate_free_leaf_test(&mut critqueue, access_key_0100);
        //allocate_free_leaf_test(&mut critqueue, access_key_0101);
        //allocate_free_leaf_test(&mut critqueue, access_key_1000);
        //allocate_free_leaf_test(&mut critqueue, access_key_0110);
        // Insert all leaves.
        insert_leaf(&mut critqueue, leaf_key_0011, access_key_0011);
        //insert_leaf(&mut critqueue, leaf_key_0100, access_key_0100);
        //insert_leaf(&mut critqueue, leaf_key_0101, access_key_0101);
        //insert_leaf(&mut critqueue, leaf_key_1000, access_key_1000);
        //insert_leaf(&mut critqueue, leaf_key_0110, access_key_0110);
        critqueue
        //drop_critqueue_test(critqueue); // Drop crit-queue.
    }

    #[test]
    /// Verify state updates for `insert_leaf_above_root_node()`
    /// reference insertion 1.
    fun test_insert_leaf_above_root_node_1() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Mutably borrow inner nodes table.
        let inners_ref_mut = &mut critqueue.inners;
        // Mutably borrow leaves table.
        let leaves_ref_mut = &mut critqueue.leaves;
        // Define inner key with mock insertion key and count.
        let inner_key_1st = 2 << INSERTION_KEY | TREE_NODE_INNER | 5678;
        // Define leaf keys.
        let leaf_key_1001 = u_128(b"1001") << INSERTION_KEY;
        let leaf_key_1011 = u_128(b"1011") << INSERTION_KEY;
        // Declare mock sub-queue parameters.
        let (count, head, tail) = (0, option::none(), option::none());
        // Set root.
        option::fill(&mut critqueue.root, inner_key_1st);
        // Add inner node to inner nodes table.
        table::add(inners_ref_mut, inner_key_1st, Inner{
            bitmask: 1 << (1 + INSERTION_KEY),
            parent: option::none(),
            left: leaf_key_1001,
            right: leaf_key_1011});
        // Add leaves to leaves table.
        table::add(leaves_ref_mut, leaf_key_1001, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        table::add(leaves_ref_mut, leaf_key_1011, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        // Declare access key with mock insertion count.
        let access_key = u_128(b"0001") << INSERTION_KEY | 4321;
        // Declare new inner node key
        let new_inner_node_key = access_key | TREE_NODE_TYPE;
        // Declare critical bitmask for new inner node.
        let new_inner_node_bitmask = 1 << (3 + INSERTION_KEY);
        // Declare new leaf key.
        let new_leaf_key = access_key & ACCESS_KEY_TO_LEAF_KEY;
        // Allocate a new leaf corresponding to access key.
        allocate_free_leaf_test(&mut critqueue, access_key);
        // Insert above root node
        insert_leaf_above_root_node(&mut critqueue, inner_key_1st,
            new_inner_node_key, new_inner_node_bitmask, new_leaf_key);
        // Assert crit-bit tree root update.
        assert!(*option::borrow(&critqueue.root) == new_inner_node_key, 0);
        // Assert new inner node state.
        let new_inner_node_ref =
            borrow_inner_test(&critqueue, new_inner_node_key);
        assert!(new_inner_node_ref.bitmask == new_inner_node_bitmask, 0);
        assert!(option::is_none(&new_inner_node_ref.parent), 0);
        assert!(new_inner_node_ref.left == new_leaf_key, 0);
        assert!(new_inner_node_ref.right == inner_key_1st, 0);
        // Assert new leaf parent.
        assert!(*option::borrow(
            &borrow_leaf_test(&critqueue, new_leaf_key).parent)
                == new_inner_node_key, 0);
        // Assert old root's parent.
        assert!(*option::borrow(
            &borrow_inner_test(&critqueue, inner_key_1st).parent)
                == new_inner_node_key, 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify state updates for `insert_leaf_above_root_node()`
    /// reference insertion 2.
    fun test_insert_leaf_above_root_node_2() {
        // Get ascending crit-queue.
        let critqueue = new<u8>(DESCENDING);
        // Mutably borrow inner nodes table.
        let inners_ref_mut = &mut critqueue.inners;
        // Mutably borrow leaves table.
        let leaves_ref_mut = &mut critqueue.leaves;
        // Define inner key with mock insertion key and count.
        let inner_key_1st = 2 << INSERTION_KEY | TREE_NODE_INNER | 5678 ^
            NOT_INSERTION_COUNT_DESCENDING;
        // Define leaf keys.
        let leaf_key_1001 = u_128(b"1001") << INSERTION_KEY;
        let leaf_key_1011 = u_128(b"1011") << INSERTION_KEY;
        // Declare mock sub-queue parameters.
        let (count, head, tail) = (0, option::none(), option::none());
        // Set root.
        option::fill(&mut critqueue.root, inner_key_1st);
        // Add inner node to inner nodes table.
        table::add(inners_ref_mut, inner_key_1st, Inner{
            bitmask: 1 << (1 + INSERTION_KEY),
            parent: option::none(),
            left: leaf_key_1001,
            right: leaf_key_1011});
        // Add leaves to leaves table.
        table::add(leaves_ref_mut, leaf_key_1001, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        table::add(leaves_ref_mut, leaf_key_1011, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        // Declare access key with mock insertion count.
        let access_key = u_128(b"1100") << INSERTION_KEY | 4321 ^
            NOT_INSERTION_COUNT_DESCENDING;
        // Declare new inner node key
        let new_inner_node_key = access_key | TREE_NODE_TYPE;
        // Declare critical bitmask for new inner node.
        let new_inner_node_bitmask = 1 << (2 + INSERTION_KEY);
        // Declare new leaf key.
        let new_leaf_key = access_key & ACCESS_KEY_TO_LEAF_KEY;
        // Allocate a new leaf corresponding to access key.
        allocate_free_leaf_test(&mut critqueue, access_key);
        // Insert above root node
        insert_leaf_above_root_node(&mut critqueue, inner_key_1st,
            new_inner_node_key, new_inner_node_bitmask, new_leaf_key);
        // Assert crit-bit tree root update.
        assert!(*option::borrow(&critqueue.root) == new_inner_node_key, 0);
        // Assert new inner node state.
        let new_inner_node_ref =
            borrow_inner_test(&critqueue, new_inner_node_key);
        assert!(new_inner_node_ref.bitmask == new_inner_node_bitmask, 0);
        assert!(option::is_none(&new_inner_node_ref.parent), 0);
        assert!(new_inner_node_ref.left == inner_key_1st, 0);
        assert!(new_inner_node_ref.right == new_leaf_key, 0);
        // Assert new leaf parent.
        assert!(*option::borrow(
            &borrow_leaf_test(&critqueue, new_leaf_key).parent)
                == new_inner_node_key, 0);
        // Assert old root's parent.
        assert!(*option::borrow(
            &borrow_inner_test(&critqueue, inner_key_1st).parent)
                == new_inner_node_key, 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify state updates for `insert_leaf_below_anchor_node()`
    /// reference insertion 1.
    fun test_insert_leaf_below_anchor_node_case_1() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Mutably borrow inner nodes table.
        let inners_ref_mut = &mut critqueue.inners;
        // Mutably borrow leaves table.
        let leaves_ref_mut = &mut critqueue.leaves;
        // Define inner keys for mock insertion keys and counts.
        let inner_key_3rd = 2 << INSERTION_KEY | TREE_NODE_INNER | 1234;
        let inner_key_1st = 2 << INSERTION_KEY | TREE_NODE_INNER | 5678;
        // Define leaf keys.
        let leaf_key_0001 = u_128(b"0001") << INSERTION_KEY;
        let leaf_key_1001 = u_128(b"1001") << INSERTION_KEY;
        let leaf_key_1011 = u_128(b"1011") << INSERTION_KEY;
        // Declare mock sub-queue parameters.
        let (count, head, tail) = (0, option::none(), option::none());
        // Set root.
        option::fill(&mut critqueue.root, inner_key_3rd);
        // Add inner nodes to inner nodes table.
        table::add(inners_ref_mut, inner_key_3rd, Inner{
            bitmask: 1 << (3 + INSERTION_KEY),
            parent: option::none(),
            left: leaf_key_0001,
            right: inner_key_1st});
        table::add(inners_ref_mut, inner_key_1st, Inner{
            bitmask: 1 << (1 + INSERTION_KEY),
            parent: option::some(inner_key_3rd),
            left: leaf_key_1001,
            right: leaf_key_1011});
        // Add leaves to leaves table.
        table::add(leaves_ref_mut, leaf_key_0001, Leaf{count, head, tail,
            parent: option::some(inner_key_3rd)});
        table::add(leaves_ref_mut, leaf_key_1001, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        table::add(leaves_ref_mut, leaf_key_1011, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        // Declare access key with mock insertion count.
        let access_key = u_128(b"1000") << INSERTION_KEY | 4321;
        // Declare new inner node key
        let new_inner_node_key = access_key | TREE_NODE_TYPE;
        // Declare critical bitmask for new inner node.
        let new_inner_node_bitmask = 1 << (0 + INSERTION_KEY);
        // Declare new leaf key.
        let new_leaf_key = access_key & ACCESS_KEY_TO_LEAF_KEY;
        // Allocate a new leaf corresponding to access key.
        allocate_free_leaf_test(&mut critqueue, access_key);
        // Insert below anchor node.
        insert_leaf_below_anchor_node(&mut critqueue, inner_key_1st,
            new_inner_node_key, new_inner_node_bitmask, new_leaf_key);
        // Assert anchor node child update.
        assert!(borrow_inner_test(&critqueue, inner_key_1st).left ==
            new_inner_node_key, 0);
        // Assert new inner node state.
        let new_inner_node_ref =
            borrow_inner_test(&critqueue, new_inner_node_key);
        assert!(new_inner_node_ref.bitmask == new_inner_node_bitmask, 0);
        assert!(*option::borrow(&new_inner_node_ref.parent) ==
            inner_key_1st, 0);
        assert!(new_inner_node_ref.left == new_leaf_key, 0);
        assert!(new_inner_node_ref.right == leaf_key_1001, 0);
        // Assert new leaf parent.
        assert!(*option::borrow(
            &borrow_leaf_test(&critqueue, new_leaf_key).parent)
                == new_inner_node_key, 0);
        // Assert displaced child parent.
        assert!(*option::borrow(
            &borrow_leaf_test(&critqueue, leaf_key_1001).parent)
                == new_inner_node_key, 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify state updates for `insert_leaf_below_anchor_node()`
    /// reference insertion 2.
    fun test_insert_leaf_below_anchor_node_case_2() {
        // Get descending crit-queue.
        let critqueue = new<u8>(DESCENDING);
        // Mutably borrow inner nodes table.
        let inners_ref_mut = &mut critqueue.inners;
        // Mutably borrow leaves table.
        let leaves_ref_mut = &mut critqueue.leaves;
        // Define inner keys for mock insertion keys and counts.
        let inner_key_3rd = 2 << INSERTION_KEY | TREE_NODE_INNER | 1234 ^
            NOT_INSERTION_COUNT_DESCENDING;
        let inner_key_1st = 2 << INSERTION_KEY | TREE_NODE_INNER | 5678 ^
            NOT_INSERTION_COUNT_DESCENDING;
        // Define leaf keys.
        let leaf_key_0001 = u_128(b"0001") << INSERTION_KEY;
        let leaf_key_1001 = u_128(b"1001") << INSERTION_KEY;
        let leaf_key_1011 = u_128(b"1011") << INSERTION_KEY;
        // Declare mock sub-queue parameters.
        let (count, head, tail) = (0, option::none(), option::none());
        // Set root.
        option::fill(&mut critqueue.root, inner_key_3rd);
        // Add inner nodes to inner nodes table.
        table::add(inners_ref_mut, inner_key_3rd, Inner{
            bitmask: 1 << (3 + INSERTION_KEY),
            parent: option::none(),
            left: leaf_key_0001,
            right: inner_key_1st});
        table::add(inners_ref_mut, inner_key_1st, Inner{
            bitmask: 1 << (1 + INSERTION_KEY),
            parent: option::some(inner_key_3rd),
            left: leaf_key_1001,
            right: leaf_key_1011});
        // Add leaves to leaves table.
        table::add(leaves_ref_mut, leaf_key_0001, Leaf{count, head, tail,
            parent: option::some(inner_key_3rd)});
        table::add(leaves_ref_mut, leaf_key_1001, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        table::add(leaves_ref_mut, leaf_key_1011, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        // Declare access key with mock insertion count.
        let access_key = u_128(b"1111") << INSERTION_KEY | 4321 ^
            NOT_INSERTION_COUNT_DESCENDING;
        // Declare new inner node key
        let new_inner_node_key = access_key | TREE_NODE_TYPE;
        // Declare critical bitmask for new inner node.
        let new_inner_node_bitmask = 1 << (2 + INSERTION_KEY);
        // Declare new leaf key.
        let new_leaf_key = access_key & ACCESS_KEY_TO_LEAF_KEY;
        // Allocate a new leaf corresponding to access key.
        allocate_free_leaf_test(&mut critqueue, access_key);
        // Insert below anchor node.
        insert_leaf_below_anchor_node(&mut critqueue, inner_key_3rd,
            new_inner_node_key, new_inner_node_bitmask, new_leaf_key);
        // Assert anchor node child update.
        assert!(borrow_inner_test(&critqueue, inner_key_3rd).right ==
            new_inner_node_key, 0);
        // Assert new inner node state.
        let new_inner_node_ref =
            borrow_inner_test(&critqueue, new_inner_node_key);
        assert!(new_inner_node_ref.bitmask == new_inner_node_bitmask, 0);
        assert!(*option::borrow(&new_inner_node_ref.parent) ==
            inner_key_3rd, 0);
        assert!(new_inner_node_ref.left == inner_key_1st, 0);
        assert!(new_inner_node_ref.right == new_leaf_key, 0);
        // Assert new leaf parent.
        assert!(*option::borrow(
            &borrow_leaf_test(&critqueue, new_leaf_key).parent)
                == new_inner_node_key, 0);
        // Assert displaced child parent.
        assert!(*option::borrow(
            &borrow_inner_test(&critqueue, inner_key_1st).parent)
                == new_inner_node_key, 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify correct update for ascending crit-queue, free leaf.
    fun test_insert_update_subqueue_ascending_free() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        let insertion_value = 0; // Declare quasi-null insertion value.
        let count = u_64(b"110"); // Declare nonzero insertion count.
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Initialize new sub-queue node for allocated leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Insert to crit-queue an allocated free leaf.
        table::add(&mut critqueue.leaves, leaf_key, Leaf{
            count, parent: option::none(), head: option::none(),
            tail: option::none()});
        // Update sub-queue, storing access key and if allocated leaf is
        // a free leaf.
        let (access_key, free_leaf) = insert_update_subqueue(
            &mut critqueue, &mut subqueue_node, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000001010101",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000111"
        ), 0);
        // Assert indicated as free leaf.
        assert!(free_leaf, 0);
        // Assert sub-queue node fields.
        assert!(subqueue_node.insertion_value == insertion_value, 0);
        assert!(option::is_none(&subqueue_node.previous), 0);
        assert!(option::is_none(&subqueue_node.next), 0);
        // Borrow immutable reference to allocated leaf.
        let leaf_ref = table::borrow(&critqueue.leaves, leaf_key);
        // Assert fields.
        assert!(leaf_ref.count == count + 1, 0);
        assert!(option::is_none(&leaf_ref.parent), 0);
        assert!(*option::borrow(&leaf_ref.head) == access_key, 0);
        assert!(*option::borrow(&leaf_ref.tail) == access_key, 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        drop_subqueue_node_test(subqueue_node); // Drop sub-queue node.
    }

    #[test]
    /// Verify correct update for ascending crit-queue, leaf already in
    /// tree.
    fun test_insert_update_subqueue_ascending_not_free() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        let insertion_value = 0; // Declare quasi-null insertion value.
        let count = u_64(b"110"); // Declare nonzero insertion count.
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Declare different value for old tail node insertion value.
        let old_tail_node_value = 1;
        // Get access key for old tail, the most recent insertion.
        let old_tail_access_key = leaf_key | (count as u128);
        // Declare key of mock parent to allocated leaf.
        let parent_key = 1234;
        // Initialize old tail node at head of sub-queue.
        let old_tail_node = SubQueueNode{insertion_value: old_tail_node_value,
            previous: option::none(), next: option::none()};
        // Add old tail node to sub-queue nodes table.
        table::add(&mut critqueue.subqueue_nodes, old_tail_access_key,
            old_tail_node);
        // Insert to crit-queue an allocated free leaf having old tail
        // node as its head.
        table::add(&mut critqueue.leaves, leaf_key, Leaf{
            count, parent: option::some(parent_key),
            head: option::some(old_tail_access_key),
            tail: option::some(old_tail_access_key)});
        // Initialize new sub-queue node for allocated leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Update sub-queue, storing access key and if allocated leaf is
        // a free leaf.
        let (access_key, free_leaf) = insert_update_subqueue(
            &mut critqueue, &mut subqueue_node, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000001010101",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000111"
        ), 0);
        // Assert indicated as not free leaf.
        assert!(!free_leaf, 0);
        // Assert sub-queue node fields.
        assert!(subqueue_node.insertion_value == insertion_value, 0);
        assert!(*option::borrow(&subqueue_node.previous) ==
            old_tail_access_key, 0);
        assert!(option::is_none(&subqueue_node.next), 0);
        // Borrow immutable reference to allocated leaf.
        let leaf_ref = table::borrow(&critqueue.leaves, leaf_key);
        // Assert fields.
        assert!(leaf_ref.count == count + 1, 0);
        assert!(*option::borrow(&leaf_ref.parent) == parent_key, 0);
        assert!(*option::borrow(&leaf_ref.head) == old_tail_access_key, 0);
        assert!(*option::borrow(&leaf_ref.tail) == access_key, 0);
        // Borrow immutable reference to old sub-queue tail node.
        let old_tail_ref = table::borrow(
            &critqueue.subqueue_nodes, old_tail_access_key);
        // Assert old sub-queue tail node fields.
        assert!(old_tail_ref.insertion_value == old_tail_node_value, 0);
        assert!(option::is_none(&old_tail_ref.previous), 0);
        assert!(*option::borrow(&old_tail_ref.next) == access_key, 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        drop_subqueue_node_test(subqueue_node); // Drop sub-queue node.
    }

    #[test]
    /// Verify correct update for descending crit-queue, free leaf.
    fun test_insert_update_subqueue_descending_free() {
        // Get ascending crit-queue.
        let critqueue = new<u8>(DESCENDING);
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        let insertion_value = 0; // Declare quasi-null insertion value.
        let count = u_64(b"110"); // Declare nonzero insertion count.
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Initialize new sub-queue node for allocated leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Insert to crit-queue an allocated free leaf.
        table::add(&mut critqueue.leaves, leaf_key, Leaf{
            count, parent: option::none(), head: option::none(),
            tail: option::none()});
        // Update sub-queue, storing access key and if allocated leaf is
        // a free leaf.
        let (access_key, free_leaf) = insert_update_subqueue(
            &mut critqueue, &mut subqueue_node, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000001010101",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111000"
        ), 0);
        // Assert indicated as free leaf.
        assert!(free_leaf, 0);
        // Assert sub-queue node fields.
        assert!(subqueue_node.insertion_value == insertion_value, 0);
        assert!(option::is_none(&subqueue_node.previous), 0);
        assert!(option::is_none(&subqueue_node.next), 0);
        // Borrow immutable reference to allocated leaf.
        let leaf_ref = table::borrow(&critqueue.leaves, leaf_key);
        // Assert fields.
        assert!(leaf_ref.count == count + 1, 0);
        assert!(option::is_none(&leaf_ref.parent), 0);
        assert!(*option::borrow(&leaf_ref.head) == access_key, 0);
        assert!(*option::borrow(&leaf_ref.tail) == access_key, 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        drop_subqueue_node_test(subqueue_node); // Drop sub-queue node.
    }

    #[test]
    /// Verify correct update for descending crit-queue, leaf already in
    /// tree.
    fun test_insert_update_subqueue_descending_not_free() {
        // Get descending crit-queue.
        let critqueue = new<u8>(DESCENDING);
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        let insertion_value = 0; // Declare quasi-null insertion value.
        let count = u_64(b"110"); // Declare nonzero insertion count.
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Declare different value for old tail node insertion value.
        let old_tail_node_value = 1;
        // Get access key for old tail, the most recent insertion.
        let old_tail_access_key = (leaf_key | (count as u128)) ^
            NOT_INSERTION_COUNT_DESCENDING;
        // Declare key of mock parent to allocated leaf.
        let parent_key = 1234;
        // Initialize old tail node at head of sub-queue.
        let old_tail_node = SubQueueNode{insertion_value: old_tail_node_value,
            previous: option::none(), next: option::none()};
        // Add old tail node to sub-queue nodes table.
        table::add(&mut critqueue.subqueue_nodes, old_tail_access_key,
            old_tail_node);
        // Insert to crit-queue an allocated free leaf having old tail
        // node as its head.
        table::add(&mut critqueue.leaves, leaf_key, Leaf{
            count, parent: option::some(parent_key),
            head: option::some(old_tail_access_key),
            tail: option::some(old_tail_access_key)});
        // Initialize new sub-queue node for allocated leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Update sub-queue, storing access key and if allocated leaf is
        // a free leaf.
        let (access_key, free_leaf) = insert_update_subqueue(
            &mut critqueue, &mut subqueue_node, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000001010101",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111000"
        ), 0);
        // Assert indicated as not free leaf.
        assert!(!free_leaf, 0);
        // Assert sub-queue node fields.
        assert!(subqueue_node.insertion_value == insertion_value, 0);
        assert!(*option::borrow(&subqueue_node.previous) ==
            old_tail_access_key, 0);
        assert!(option::is_none(&subqueue_node.next), 0);
        // Borrow immutable reference to allocated leaf.
        let leaf_ref = table::borrow(&critqueue.leaves, leaf_key);
        // Assert fields.
        assert!(leaf_ref.count == count + 1, 0);
        assert!(*option::borrow(&leaf_ref.parent) == parent_key, 0);
        assert!(*option::borrow(&leaf_ref.head) == old_tail_access_key, 0);
        assert!(*option::borrow(&leaf_ref.tail) == access_key, 0);
        // Borrow immutable reference to old sub-queue tail node.
        let old_tail_ref = table::borrow(
            &critqueue.subqueue_nodes, old_tail_access_key);
        // Assert old sub-queue tail node fields.
        assert!(old_tail_ref.insertion_value == old_tail_node_value, 0);
        assert!(option::is_none(&old_tail_ref.previous), 0);
        assert!(*option::borrow(&old_tail_ref.next) == access_key, 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        drop_subqueue_node_test(subqueue_node); // Drop sub-queue node.
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for max insertion count exceedance.
    fun test_insert_update_subqueue_max_failure() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        let insertion_value = 0; // Declare quasi-null insertion value.
        // Declare insertion count as max.
        let count = MAX_INSERTION_COUNT;
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Initialize new sub-queue node for allocated leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Insert to crit-queue an allocated free leaf.
        table::add(&mut critqueue.leaves, leaf_key, Leaf{
            count, parent: option::none(), head: option::none(),
            tail: option::none()});
        // Attempt invalid invocation.
        let (_, _) = insert_update_subqueue(
            &mut critqueue, &mut subqueue_node, leaf_key);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        drop_subqueue_node_test(subqueue_node); // Drop sub-queue node.
    }

    #[test]
    /// Verify successful insertion up to max insertion count.
    fun test_insert_update_subqueue_max_success() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        let insertion_key = u_64(b"1010101"); // Get insertion key.
        let insertion_value = 0; // Declare quasi-null insertion value.
        // Declare insertion count as one less than max.
        let count = MAX_INSERTION_COUNT - 1;
        // Get leaf key.
        let leaf_key = (insertion_key as u128) << INSERTION_KEY;
        // Initialize new sub-queue node for allocated leaf.
        let subqueue_node = SubQueueNode{insertion_value,
            previous: option::none(), next: option::none()};
        // Insert to crit-queue an allocated free leaf.
        table::add(&mut critqueue.leaves, leaf_key, Leaf{
            count, parent: option::none(), head: option::none(),
            tail: option::none()});
        // Update sub-queue, storing access key.
        let (access_key, _) = insert_update_subqueue(
            &mut critqueue, &mut subqueue_node, leaf_key);
        // Assert access key as expected.
        assert!(access_key == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000001010101",
            b"00111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ), 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        drop_subqueue_node_test(subqueue_node); // Drop sub-queue node.
    }

    #[test]
    /// Verify successful returns.
    fun test_is_empty() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Assert is marked empty.
        assert!(is_empty(&critqueue), 0);
        option::fill(&mut critqueue.root, 1234); // Mark mock root.
        // Assert is marked not empty.
        assert!(!is_empty(&critqueue), 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify correct returns.
    fun test_is_set_success() {
        assert!(is_set(u_128(b"11"), 0), 0);
        assert!(is_set(u_128(b"11"), 1), 0);
        assert!(!is_set(u_128(b"10"), 0), 0);
        assert!(!is_set(u_128(b"01"), 1), 0);
    }

    #[test]
    /// Verify successful determination of key types.
    fun test_key_types() {
        assert!(is_inner_key(u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000000",
            b"00000000000000000000000000000000",
        )), 0);
        assert!(is_leaf_key(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
        )), 0);
    }

    #[test]
    /// Verify reference diagram cases from `search()`.
    fun test_search() {
        // Define inner keys for mock insertion keys and counts.
        let inner_key_2nd = 2 << INSERTION_KEY | TREE_NODE_INNER | 1234;
        let inner_key_1st = 2 << INSERTION_KEY | TREE_NODE_INNER | 5678;
        // Define leaf keys.
        let leaf_key_001 = u_128(b"001") << INSERTION_KEY;
        let leaf_key_101 = u_128(b"101") << INSERTION_KEY;
        let leaf_key_111 = u_128(b"111") << INSERTION_KEY;
        // Declare mock sub-queue parameters.
        let (count, head, tail) = (0, option::none(), option::none());
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Set root to single leaf key.
        option::fill(&mut critqueue.root, leaf_key_111);
        // Add leaf to leaves table.
        table::add(&mut critqueue.leaves, leaf_key_001, Leaf{count, head, tail,
            parent: option::none()});
        // Search tree for assorted seed keys, asserting same returns.
        let (match_key, optional_match_parent_key,
             optional_match_parent_bitmask) =
                    search(&mut critqueue, u_128(b"111111") << INSERTION_KEY);
        assert!(match_key == leaf_key_111, 0);
        assert!(option::is_none(&optional_match_parent_key), 0);
        assert!(option::is_none(&optional_match_parent_bitmask), 0);
        (match_key, optional_match_parent_key, optional_match_parent_bitmask) =
            search(&mut critqueue, u_128(b"101010101") << INSERTION_KEY);
        assert!(match_key == leaf_key_111, 0);
        assert!(option::is_none(&optional_match_parent_key), 0);
        assert!(option::is_none(&optional_match_parent_bitmask), 0);
        drop_critqueue_test(critqueue); // Drop crit-queue.
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Set root to inner node.
        critqueue.root = option::some(inner_key_2nd);
        // Add inner nodes to inner nodes table.
        table::add(&mut critqueue.inners, inner_key_2nd, Inner{
            bitmask: 1 << (2 + INSERTION_KEY),
            parent: option::none(),
            left: leaf_key_001,
            right: inner_key_1st});
        table::add(&mut critqueue.inners, inner_key_1st, Inner{
            bitmask: 1 << (1 + INSERTION_KEY),
            parent: option::some(inner_key_2nd),
            left: leaf_key_101,
            right: leaf_key_111});
        // Add leaves to leaves table.
        table::add(&mut critqueue.leaves, leaf_key_001, Leaf{count, head, tail,
            parent: option::some(inner_key_2nd)});
        table::add(&mut critqueue.leaves, leaf_key_101, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        table::add(&mut critqueue.leaves, leaf_key_111, Leaf{count, head, tail,
            parent: option::some(inner_key_1st)});
        // Search tree for assorted seed keys, asserting returns.
        (match_key, optional_match_parent_key, optional_match_parent_bitmask) =
            search(&mut critqueue, u_128(b"011") << INSERTION_KEY);
        assert!(match_key == leaf_key_001, 0);
        let (match_parent_key, match_parent_bitmask) = (
            *option::borrow(&optional_match_parent_key),
            *option::borrow(&optional_match_parent_bitmask));
        assert!(borrow_inner_test(&critqueue, match_parent_key).bitmask ==
            match_parent_bitmask, 0);
        assert!(match_parent_bitmask == 1 << (2 + INSERTION_KEY), 0);
        (match_key, optional_match_parent_key, optional_match_parent_bitmask) =
            search(&mut critqueue, u_128(b"100") << INSERTION_KEY);
        assert!(match_key == leaf_key_101, 0);
        (match_parent_key, match_parent_bitmask) = (
            *option::borrow(&optional_match_parent_key),
            *option::borrow(&optional_match_parent_bitmask));
        assert!(borrow_inner_test(&critqueue, match_parent_key).bitmask ==
            match_parent_bitmask, 0);
        assert!(match_parent_bitmask == 1 << (1 + INSERTION_KEY), 0);
        (match_key, optional_match_parent_key, optional_match_parent_bitmask) =
            search(&mut critqueue, u_128(b"111") << INSERTION_KEY);
        assert!(match_key == leaf_key_111, 0);
        (match_parent_key, match_parent_bitmask) = (
            *option::borrow(&optional_match_parent_key),
            *option::borrow(&optional_match_parent_bitmask));
        assert!(borrow_inner_test(&critqueue, match_parent_key).bitmask ==
            match_parent_bitmask, 0);
        assert!(match_parent_bitmask == 1 << (1 + INSERTION_KEY), 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    #[test]
    /// Verify successful return values
    fun test_u_128_64() {
        assert!(u_128(b"0") == 0, 0);
        assert!(u_128(b"1") == 1, 0);
        assert!(u_128(b"00") == 0, 0);
        assert!(u_128(b"01") == 1, 0);
        assert!(u_128(b"10") == 2, 0);
        assert!(u_128(b"11") == 3, 0);
        assert!(u_128(b"10101010") == 170, 0);
        assert!(u_128(b"00000001") == 1, 0);
        assert!(u_128(b"11111111") == 255, 0);
        assert!(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ) == HI_128, 0);
        assert!(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111110"
        ) == HI_128 - 1, 0);
        assert!(u_64(b"0") == 0, 0);
        assert!(u_64(b"0") == 0, 0);
        assert!(u_64(b"1") == 1, 0);
        assert!(u_64(b"00") == 0, 0);
        assert!(u_64(b"01") == 1, 0);
        assert!(u_64(b"10") == 2, 0);
        assert!(u_64(b"11") == 3, 0);
        assert!(u_64(b"10101010") == 170, 0);
        assert!(u_64(b"00000001") == 1, 0);
        assert!(u_64(b"11111111") == 255, 0);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    /// Verify failure for non-binary-representative byte string.
    fun test_u_failure() {u_128(b"2");}

    #[test]
    /// Verify lookup returns.
    fun test_would_become_trail_head() {
        let critqueue = new<u8>(ASCENDING); // Get ascending crit-queue.
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&critqueue, HI_64), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&critqueue, HI_64), 0);
        // Set mock head access key.
        option::fill(&mut critqueue.head, u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
        ));
        // Assert return for insertion key that would become new head.
        assert!(would_become_new_head(&critqueue, (u_128(b"01") as u64)), 0);
        // Assert return for insertion key that would not trail head.
        assert!(!would_trail_head(&critqueue, (u_128(b"01") as u64)), 0);
        // Assert return for insertion key that would not become new
        // head.
        assert!(!would_become_new_head(&critqueue, (u_128(b"10") as u64)), 0);
        // Assert return for insertion key that would trail head.
        assert!(would_trail_head(&critqueue, (u_128(b"10") as u64)), 0);
        // Flip crit-queue order.
        critqueue.order = DESCENDING;
        // Assert return for insertion key that would become new head.
        assert!(would_become_new_head(&critqueue, (u_128(b"11") as u64)), 0);
        // Assert return for insertion key that would not trail head.
        assert!(!would_trail_head(&critqueue, (u_128(b"11") as u64)), 0);
        // Assert return for insertion key that would not become new
        // head.
        assert!(!would_become_new_head(&critqueue, (u_128(b"10") as u64)), 0);
        // Assert return for insertion key that would trail head.
        assert!(would_trail_head(&critqueue, (u_128(b"10") as u64)), 0);
        drop_critqueue_test(critqueue) // Drop crit-queue.
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}