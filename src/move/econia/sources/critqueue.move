/// Hybrid data structure combining crit-bit tree and queue properties.
///
/// A crit-queue contains an inner crit-bit tree with subqueues at each
/// leaf node, enabling chronological ordering among multiple instances
/// of the same insertion key. Like a crit-bit tree, a crit-queue can be
/// used as an associative array that maps keys to values, as in the
/// present implementation. While multiple instances of the same
/// insertion key are sorted by order of insertion, different
/// insertion keys can be sorted in either ascending or descending
/// order relative to the head of the crit-queue, as specified during
/// initialization.
///
/// The present implementation, based on hash tables, offers:
///
/// * Insertions that are $O(1)$ in the best case, $O(log(n))$ in the
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
/// * [Subqueue nodes](#subqueue-nodes)
/// * [Inner keys](#inner-keys)
/// * [Insertion counts](#insertion-counts)
/// * [Dequeue order preservation](#dequeue-order-preservation)
/// * [Subqueue removal updates](#subqueue-removal-updates)
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
/// >      bit 5 = 0 -|    |- bit 0 = 1
///
/// ## Status
///
/// `0` is considered an "unset" bit, and `1` is considered a "set" bit.
/// Hence `11101` is set at bit 0 and unset at bit 1.
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
/// have children. Inner nodes store an integer, known as a critical bit
/// (crit-bit), which indicates the most-significant bit of
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
/// Here, the inner node marked `2nd` stores the critical bit 2, the
/// inner node marked `1st` stores the critical bit 1, and the
/// inner node marked `0th` stores the critical bit 0. Hence, the sole
/// key in the left subtree of `2nd` is unset at bit 2, while all the
/// keys in the right subtree of `2nd` are set at bit 2. And similarly
/// for `0th`, its left child key is unset at bit 0, while its right
/// child key is set at bit 0.
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
/// Each leaf contains a nested subqueue of key-values insertion
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
/// >      ^ subqueue head                ^ subqueue head
///
/// Leaf keys are guaranteed to be unique, and all leaf nodes are stored
/// in a single hash table.
///
/// ## Subqueue nodes
///
/// All subqueue nodes are similarly stored in single hash table, and
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
/// corresponding subqueue node is placed at the head of the new leaf's
/// subqueue. For each subsequent insertion of the same insertion key,
/// $k_{i, n}$, the leaf insertion counter is updated to $n$, and the
/// new subqueue node becomes the tail of the corresponding subqueue.
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
/// ## Subqueue removal updates
///
/// Removal via access key lookup in the subqueue node hash table leads
/// to an update within the corresponding subqueue.
///
/// For example, consider the following crit-queue:
///
/// >                                          64th
/// >                                         /    \
/// >                       000...000000...000      000...001000...000
/// >     [k_{0, 0} --> k_{0, 1} --> k_{0, 2}]      [k_{1, 0}]
/// >      ^ subqueue head
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
/// empty subqueue.
///
/// ## Free leaves
///
/// Free leaves are leaf nodes with an empty subqueue.
///
/// Free leaves track insertion counts in case another key-value
/// insertion pair, having the insertion key encoded in the free leaf
/// key, is inserted. Here, the free leaf is added back to the crit-bit
/// tree and the new subqueue node becomes the head of the leaf's
/// subqueue. Continuing the example, inserting another key-value pair
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
/// After all elements in the corresponding subqueue have been dequeued
/// in order of ascending insertion count, dequeueing proceeds with the
/// head of the subqueue in the next leaf, which is accessed by either:
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
/// insertions improve to $O(log(n))$, where $n$ is the number of leaves
/// in the tree. In the best case, where the corresponding
/// subqueue already has a leaf in the crit-bit tree and a new
/// subqueue node simply has to be inserted at the tail of the subqueue,
/// insertions improve to $O(1)$.
///
/// Insertions are parallelizable in the general case where:
///
/// 1. They do not alter the head of the crit-queue.
/// 2. They do not write to overlapping crit-bit tree edges.
/// 3. They do not write to overlapping subqueue edges.
/// 4. They alter neither the head nor the tail of the same subqueue.
/// 5. They do not write to the same subqueue.
///
/// The final parallelism constraint is a result of insertion count
/// updates, and may potentially be eliminated in the case of a
/// parallelized insertion count aggregator.
///
/// ## Removing
///
/// With subqueue nodes stored in a hash table, removal operations via
/// access key are are thus $O(1)$, and are parallelizable in the
/// general case where:
///
/// 1. They do not alter the head of the crit-queue.
/// 2. They do not write to overlapping crit-bit tree edges.
/// 3. They do not write to overlapping subqueue edges.
/// 4. They alter neither the head nor the tail of the same subqueue.
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
        /// Map from access key to subqueue node.
        values: Table<u128, SubQueueNode<V>>
    }

    /// A crit-bit tree inner node.
    struct Inner has store {
        /// Critical bit position.
        bit: u8,
        /// If none, node is root. Else parent key.
        parent: Option<u128>,
        /// Left child key.
        left: u128,
        /// Right child key.
        right: u128
    }

    /// A crit-bit tree leaf node. A free leaf if no subqueue head.
    /// Else the root of the crit-bit tree if no parent.
    struct Leaf has store {
        /// 0-indexed insertion count for corresponding insertion key.
        count: u64,
        /// If no subqueue head, should also be none, since leaf is a
        /// free leaf. Else corresponds to the inner key of the parent
        /// node, none when leaf is the root of the crit-bit tree.
        parent: Option<u128>,
        /// If none, node is a free leaf. Else the access key of the
        /// subqueue head.
        head: Option<u128>,
        /// If none, node is a free leaf. Else the access key of the
        /// subqueue tail.
        tail: Option<u128>
    }

    /// A node in a subqueue.
    struct SubQueueNode<V> has store {
        /// Insertion value.
        value: V,
        /// Access key of previous subqueue node, if any.
        previous: Option<u128>,
        /// Access key of next subqueue node, if any.
        next: Option<u128>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When an enqueue key has been enqueued too many times.
    const E_TOO_MANY_ENQUEUES: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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
    /// Most significant bit number for a `u128`
    const MSB_u128: u8 = 127;
    /// `u128` bitmask set at bit 63, the crit-bit tree node type
    /// bit flag, generated in Python via `hex(int('1' + '0' * 63, 2))`.
    const NODE_TYPE: u128 = 0x8000000000000000;
    /// Result of bitwise crit-bit tree node key `AND` with `NODE_TYPE`,
    /// indicating that the key is set at bit 63 and is thus an inner
    /// key. Generated in Python via `hex(int('1' + '0' * 63, 2))`.
    const NODE_INNER: u128 = 0x8000000000000000;
    /// Result of bitwise crit-bit tree node key `AND` with `NODE_TYPE`,
    /// indicating that the key is unset at bit 63 and is thus a leaf
    /// key.
    const NODE_LEAF: u128 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow insertion value corresponding to `access_key` in given
    /// `CritQueue`, aborting if no such access key.
    public fun borrow<V>(
        crit_queue_ref: &CritQueue<V>,
        access_key: u128
    ): &V {
        &table::borrow(&crit_queue_ref.values, access_key).value
    }

    /// Mutably borrow insertion value corresponding to `access_key`
    /// `CritQueue`, aborting if no such access key
    public fun borrow_mut<V>(
        crit_queue_ref_mut: &mut CritQueue<V>,
        access_key: u128
    ): &mut V {
        &mut table::borrow_mut(&mut crit_queue_ref_mut.values, access_key).
            value
    }

    /// Return access key of given `CritQueue` head, if any.
    public fun get_head_access_key<V>(
        crit_queue_ref: &CritQueue<V>,
    ): Option<u128> {
        crit_queue_ref.head
    }

    /// Return `true` if given `CritQueue` has the given `access_key`.
    public fun has_access_key<V>(
        crit_queue_ref: &CritQueue<V>,
        access_key: u128
    ): bool {
        table::contains(&crit_queue_ref.values, access_key)
    }

    /// Return `true` if given `CritQueue` is empty.
    public fun is_empty<V>(
        crit_queue_ref: &CritQueue<V>,
    ): bool {
        option::is_none(&crit_queue_ref.root)
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
            values: table::new()
        }
    }

    /// Return `true` if, were `insertion_key` to be inserted, its
    /// access key would become the new head of the given `CritQueue`.
    public fun would_become_new_head<V>(
        crit_queue_ref: &CritQueue<V>,
        insertion_key: u64
    ): bool {
        // If the crit-queue is empty and thus has no head:
        if (option::is_none(&crit_queue_ref.head)) {
            // Return that insertion key would become new head.
            return true
        } else { // Otherwise, if crit-queue is not empty:
            // Get insertion key of crit-queue head.
            let head_insertion_key = (*option::borrow(&crit_queue_ref.head) >>
                INSERTION_KEY as u64);
            // If an ascending crit-queue, return true if insertion key
            // is less than insertion key of crit-queue head.
            return if (crit_queue_ref.order == ASCENDING)
                insertion_key < head_insertion_key else
                // If a descending crit-queue, return true if insertion
                // key is greater than insertion key of crit-queue head.
                insertion_key > head_insertion_key
        }
    }

    /// Return `true` if, were `insertion_key` to be inserted, its
    /// access key would trail behind the head of the given `CritQueue`.
    public fun would_trail_head<V>(
        crit_queue_ref: &CritQueue<V>,
        insertion_key: u64
    ): bool {
        !would_become_new_head(crit_queue_ref, insertion_key)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return the number of the most significant bit (0-indexed from
    /// LSB) at which two non-identical bitstrings, `s1` and `s2`, vary.
    ///
    /// # XOR/AND method
    ///
    /// To begin with, a bitwise XOR is used to flag all differing bits:
    ///
    /// >              s1: 11110001
    /// >              s2: 11011100
    /// >     x = s1 ^ s2: 00101101
    /// >                    |- critical bit = 5
    ///
    /// Here, the critical bit is equivalent to the bit number of the
    /// most significant set bit in XOR result `x = s1 ^ s2`. At this
    /// point, [Langley 2008](#references) notes that `x` bitwise AND
    /// `x - 1` will be nonzero so long as `x` contains at least some
    /// bits set which are of lesser significance than the critical bit:
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
    /// >               x: 00101100
    /// >           x - 1: 00101011
    /// > x = x & (x - 1): 00101000
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
    /// Thus after three iterations a corresponding critical bit bitmask
    /// has been determined. However, in the case where the two input
    /// strings vary at all bits of lesser significance than that of the
    /// critical bit, there may be required as many as `k - 1`
    /// iterations, where `k` is the number of bits in each string under
    /// comparison. For instance, consider the case of the two 8-bit
    /// strings `s1` and `s2` as follows:
    ///
    /// >                  s1: 10101010
    /// >                  s2: 01010101
    /// >         x = s1 ^ s2: 11111111
    /// >                      |- critical bit = 7
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
    /// For the present implementation, strings are not partitioned into
    /// a multi-byte array, rather, they are stored as `u128` integers,
    /// so a binary search is instead proposed. Here, the same
    /// `x = s1 ^ s2` operation is first used to identify all differing
    /// bits, before iterating on an upper and lower bound for the
    /// critical bit number:
    ///
    /// >              s1: 10101010
    /// >              s2: 01010101
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -|      |- l = 0
    ///
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
    ///
    /// >              x: 11111111
    /// >     s = x >> m: 00011111
    ///
    /// `s > 1`, so `l = m + 1 = 4`, and the search window has shrunk:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -|  |- l = 4
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
    /// >           u = 7 -||- l = 6
    /// >     s = x >> m: 00000011
    ///
    /// Again `s > 1`, so update `l = m + 1 = 7`, the final iteration:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -|- l = 7
    /// >     s = x >> m: 00000001
    ///
    /// Here, `s == 1`, which means that `c = m = 7`. Notably this
    /// search has converged after only 3 iterations, as opposed to 7
    /// for the linear search proposed above, and in general such a
    /// search converges after $log_2(k)$ iterations at most, where $k$
    /// is the number of bits in each of the strings `s1` and `s2` under
    /// comparison. Hence this search method improves the $O(k)$ search
    /// proposed by [Langley 2008](#references) to $O(log_2(k))$, and
    /// moreover, determines the actual number of the critical bit,
    /// rather than just a bitmask with bit `c` set, as he proposes,
    /// which can also be easily generated via `1 << c`.
    fun get_critical_bit(
        s1: u128,
        s2: u128,
    ): u8 {
        let x = s1 ^ s2; // XOR result marked 1 at bits that differ.
        let l = 0; // Lower bound on critical bit search.
        let u = MSB_u128; // Upper bound on critical bit search.
        loop { // Begin binary search.
            let m = (l + u) / 2; // Calculate midpoint of search window.
            let s = x >> m; // Calculate midpoint shift of XOR result.
            if (s == 1) return m; // If shift equals 1, c = m.
            // Update search bounds.
            if (s > 1) l = m + 1 else u = m - 1;
        }
    }

    /// Return `true` if crit-bit tree node `key` is an inner key.
    fun is_inner_key(key: u128): bool {key & NODE_TYPE == NODE_INNER}

    /// Return `true` if crit-bit tree `node_key` is a leaf key.
    fun is_leaf_key(key: u128): bool {key & NODE_TYPE == NODE_LEAF}

    /// Return `true` if `key` is set at `bit_number`.
    fun is_set(key: u128, bit_number: u8): bool {key >> bit_number & 1 == 1}

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// When a char in a bytestring is neither 0 nor 1.
    const E_BIT_NOT_0_OR_1: u64 = 100;

    // Test-only error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `HI_128`
    fun bit_lo(b: u8): u128 {1 << b ^ HI_128}

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
    fun test_borrowers():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Add a mock subqueue node to the values table.
        table::add(&mut crit_queue.values, 0, SubQueueNode{
            value: 0, previous: option::none(), next: option::none()});
        // Assert correct value borrow.
        assert!(*borrow(&crit_queue, 0) == 0, 0);
        *borrow_mut(&mut crit_queue, 0) = 123; // Mutate value.
        assert!(*borrow(&crit_queue, 0) == 123, 0); // Assert mutation.
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful calculation of critical bit at all positions.
    fun test_get_critical_bit() {
        let b = 0; // Start loop for bit 0.
        while (b <= MSB_u128) { // Loop over all bit numbers.
            // Compare 0 versus a bitmask that is only set at bit b.
            assert!(get_critical_bit(0, 1 << b) == b, (b as u64));
            b = b + 1; // Increment bit counter.
        };
    }

    #[test]
    /// Verify lookup returns.
    fun test_get_head_access_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert no head access key indicated.
        assert!(option::is_none(&get_head_access_key(&crit_queue)), 0);
        // Set mock head access key.
        option::fill(&mut crit_queue.head, 123);
        // Assert head access key returned correctly.
        assert!(*option::borrow(&get_head_access_key(&crit_queue)) == 123, 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify returns for membership checks.
    fun test_has_access_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert arbitrary access key not contained.
        assert!(!has_access_key(&crit_queue, 0), 0);
        // Add a mock subqueue node to the values table.
        table::add(&mut crit_queue.values, 0, SubQueueNode{
            value: 0, previous: option::none(), next: option::none()});
        // Assert arbitrary access key contained.
        assert!(has_access_key(&crit_queue, 0), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful returns.
    fun test_is_empty():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert is marked empty.
        assert!(is_empty(&crit_queue), 0);
        option::fill(&mut crit_queue.root, 1234); // Mark mock root.
        // Assert is marked not empty.
        assert!(!is_empty(&crit_queue), 0);
        crit_queue // Return crit-queue.
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
    /// Verify successful return values
    fun test_u_128() {
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
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    /// Verify failure for non-binary-representative byte string.
    fun test_u_failure() {u_128(b"2");}

    #[test]
    /// Verify lookup returns.
    fun test_would_become_trail_head():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, HI_64), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, HI_64), 0);
        // Set mock head access key.
        option::fill(&mut crit_queue.head, u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
        ));
        // Assert return for insertion key that would become new head.
        assert!(would_become_new_head(&crit_queue, (u_128(b"01") as u64)), 0);
        // Assert return for insertion key that would not trail head.
        assert!(!would_trail_head(&crit_queue, (u_128(b"01") as u64)), 0);
        // Assert return for insertion key that would not become new
        // head.
        assert!(!would_become_new_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Assert return for insertion key that would trail head.
        assert!(would_trail_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Flip crit-queue order.
        crit_queue.order = DESCENDING;
        // Assert return for insertion key that would become new head.
        assert!(would_become_new_head(&crit_queue, (u_128(b"11") as u64)), 0);
        // Assert return for insertion key that would not trail head.
        assert!(!would_trail_head(&crit_queue, (u_128(b"11") as u64)), 0);
        // Assert return for insertion key that would not become new
        // head.
        assert!(!would_become_new_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Assert return for insertion key that would trail head.
        assert!(would_trail_head(&crit_queue, (u_128(b"10") as u64)), 0);
        crit_queue // Return crit-queue.
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}