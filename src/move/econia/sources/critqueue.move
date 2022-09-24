/// Hybrid data structure combining crit-bit tree and queue properties.
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
/// ## Core functions
///
/// In the present implementation, key-value insertion pairs are
/// inserted via `insert()`, which accepts a `u64` insertion key and
/// insertion value of type `V`. A corresponding `u128` access key is
/// returned, which can be used for subsequent access key lookup via `
/// borrow()`, `borrow_mut()`, `dequeue()`, or `remove()`.
///
/// ## Insertions
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
/// ## Removals
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
    use std::option::Option;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Hybrid between a crit-bit tree and a queue. See above.
    struct CritQueue<V> has store {
        /// Crit-queue sort direction, `ASCENDING` or `DESCENDING`.
        direction: bool,
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

}