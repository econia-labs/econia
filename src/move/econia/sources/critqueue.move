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
/// # Critbit trees
///
/// ## General
///
/// A critical bit (critbit) tree is a compact binary prefix tree that
/// stores a prefix-free set of bitstrings, like n-bit integers or
/// variable-length 0-terminated byte strings. For a given set of keys
/// there exists a unique critbit tree representing the set, such that
/// critbit trees do not require complex rebalancing algorithms like
/// those of AVL or red-black binary search trees. Critbit trees support
/// the following operations:
///
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Inorder predecessor iteration
/// * Inorder successor iteration
///
/// ## Structure
///
/// Critbit trees have two types of nodes: inner nodes and outer nodes.
/// Inner nodes have two children each, and outer nodes do not have
/// children. Inner nodes store an integer indicating the
/// most-significant critical bit (critbit) of divergence between keys
/// from the node's two subtrees: keys in an inner node's left subtree
/// are unset at the critical bit, while keys in an inner node's right
/// subtree are set at the critical bit.
///
/// Inner nodes are arranged hierarchically, with the most-significant
/// critical bits at the top of the tree. For example, the binary keys
/// `001`, `101`, `110`, and `111` produce the following critbit tree:
///
/// >        2nd
/// >       /   \
/// >     001   1st
/// >          /   \
/// >        101   0th
/// >             /   \
/// >           110   111
///
/// Here, the inner node marked `2nd` stores the integer 2, the inner
/// node marked `1st` stores the integer 1, and the inner node marked
/// `0th` stores the integer 0. Hence, the sole key in the left
/// subtree of `2nd` is unset at bit 2, while all the keys in the
/// right subtree of `2nd` are set at bit 2. And similarly for `0th`,
/// the key of its left child is unset at bit 0, while the key of its
/// right child is set at bit 0.
///
/// ## Insertions
///
/// Critbit trees are automatically sorted upon insertion, such that
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
/// >                    2nd
/// >                   /   \
/// >                 001   1st <- has new right child
/// >                      /   \
/// >                    101   0th <- new inner node
/// >                         /   \
/// >     has new parent -> 110   111 <- new outer node
///
/// Here, `111` may not be re-inserted unless it is first removed from
/// the tree.
///
/// ## Removals
///
/// Continuing the above example, critbit trees are automatically
/// compacted and sorted upon removal, such that removing `111` again
/// results in:
///
/// >        2nd
/// >       /   \
/// >     001   1st <- has new right child
/// >          /   \
/// >        101    110 <- has new parent
///
/// ## As a map
///
/// Critbit trees can be used as an associative array that maps from
/// keys to values, simply by storing values in outer nodes of the tree.
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
/// # Critqueues
///
/// ## Key storage multiplicity
///
/// Unlike a critbit tree, which can only store one instance of a given
/// key, critqueues can store multiple instances. For example, the
/// following insertion sequence, without intermediate removals, is
/// invalid in a critbit tree but valid in a critqueue:
///
/// 1. $p_{3, 0} = \langle 3, 5 \rangle$
/// 2. $p_{2, 1} = \langle 2, 8 \rangle$
/// 3. $p_{2, 2} = \langle 2, 2 \rangle$
/// 4. $p_{3, 3} = \langle 3, 5 \rangle$
///
/// Here, the "key-value insertion pair"
/// $p_{i, j} = \langle i, v_j \rangle$ has:
///
/// * "Insertion key" $i$: the inserted key.
/// * "Insertion count" $j$: the total number of key-value insertion
///   pairs that were previously inserted.
/// * "Insertion value" $v_j$: the value from the key-value insertion
///   pair having insertion count $j$.
///
/// ## Sorting order
///
/// Key-value insertion pairs in a critqueue are sorted by:
///
/// 1. Either ascending or descending order of insertion key, then by
/// 2. Ascending order of insertion count.
///
/// For example, consider the following binary insertion key sequence,
/// where $k_{i, j}$ denotes insertion key $i$ with insertion count $j$:
///
/// 1. $k_{0, 0} = \texttt{0b00}$
/// 2. $k_{1, 1} = \texttt{0b01}$
/// 3. $k_{1, 2} = \texttt{0b01}$
/// 4. $k_{0, 3} = \texttt{0b00}$
/// 5. $k_{3, 4} = \texttt{0b11}$
///
/// In an ascending critqueue, the dequeue sequence would be:
///
/// 1. $k_{0, 0} = \texttt{0b00}$
/// 2. $k_{0, 3} = \texttt{0b00}$
/// 3. $k_{1, 1} = \texttt{0b01}$
/// 4. $k_{1, 2} = \texttt{0b01}$
/// 5. $k_{3, 4} = \texttt{0b11}$
///
/// In a descending critqueue, the dequeue sequence would instead be:
///
/// 1. $k_{3, 4} = \texttt{0b11}$
/// 2. $k_{1, 1} = \texttt{0b01}$
/// 3. $k_{1, 2} = \texttt{0b01}$
/// 4. $k_{0, 0} = \texttt{0b00}$
/// 5. $k_{0, 3} = \texttt{0b00}$
///
/// ## Index keys
///
/// The present critqueue implementation involves a critbit tree outer
/// node for each key-value insertion pair, corresponding to an "index
/// key" having the following bit structure (`NOT` denotes
/// bitwise complement):
///
/// | Bit(s) | Ascending critqueue  | Descending critqueue  |
/// |--------|----------------------|-----------------------|
/// | 64-95  | 32-bit insertion key | 32-bit insertion key  |
/// | 63     | 0                    | 1                     |
/// | 0-62   | Insertion count      | `NOT` insertion count |
///
/// For an ascending critqueue, index keys can thus be dequeued in
/// ascending lexicographical order via inorder successor iteration
/// starting at the minimum index key:
///
/// | Insertion key | Index key bits 64-95 | Index key bits 0-63 |
/// |---------------|----------------------|---------------------|
/// | $k_{0, 0}$    | `000...000`          | `000...000`         |
/// | $k_{0, 3}$    | `000...000`          | `000...011`         |
/// | $k_{1, 1}$    | `000...001`          | `000...001`         |
/// | $k_{1, 2}$    | `000...001`          | `000...010`         |
/// | $k_{3, 4}$    | `000...011`          | `000...100`         |
///
/// >                                          65th
/// >                                         /    \           critqueue
/// >                                      64th    k_{3, 4} <- tail
/// >                            _________/    \________
/// >                          1st                     1st
/// >     critqueue           /   \                   /   \
/// >          head -> k_{0, 0}   k_{0, 3}     k_{1, 1}   k_{1, 2}
///
/// Conversely, for a descending critqueue, index keys can thus be
/// dequeued in descending lexicographical order via inorder predecessor
/// iteration starting at the maximum index key:
///
/// | Insertion key | Index key bits 64-95 | Index key bits 0-63   |
/// |---------------|----------------------|-----------------------|
/// | $k_{3, 4}$    | `000...011`          | `111...011`           |
/// | $k_{1, 1}$    | `000...001`          | `111...110`           |
/// | $k_{1, 2}$    | `000...001`          | `111...101`           |
/// | $k_{0, 0}$    | `000...000`          | `111...111`           |
/// | $k_{0, 3}$    | `000...000`          | `111...100`           |
///
/// >                                          65th
/// >                                         /    \           critqueue
/// >                                      64th    k_{3, 4} <- head
/// >                            _________/    \________
/// >                          1st                     1st
/// >     critqueue           /   \                   /   \
/// >          tail -> k_{0, 3}   k_{0, 0}     k_{1, 2}   k_{1, 1}
///
/// Since index keys have bit 63 reserved, the maximum permissible
/// insertion count is thus $2^{63} - 1$.
///
/// ## Dequeue order preservation
///
/// Removals can take place from anywhere inside of a critqueue, with
/// the specified dequeue order preserved among remaining elements.
/// For example, consider the elements in an ascending critqueue
/// with the following dequeue sequence:
///
/// 1. $k_{0, 6}$
/// 2. $k_{2, 5}$
/// 3. $k_{2, 8}$
/// 4. $k_{4, 7}$
/// 5. $k_{5, 0}$
///
/// Here, removing $k_{2, 5}$ simply updates the dequeue sequence to:
///
/// 1. $k_{0, 6}$
/// 2. $k_{2, 8}$
/// 3. $k_{4, 7}$
/// 4. $k_{5, 0}$
///
/// ## Node status and ID
///
/// Tree nodes are stored as separate items in global memory, and thus
/// incur per-item storage gas costs whenever they are operated on.
/// With per-item creations constituting by far the most expensive
/// operation in the Aptos gas schedule, it is thus most gas-efficient
/// to re-use allocated nodes, rather than deallocate them, after they
/// have been removed from the tree. Hence when a node is removed from
/// the tree it is not deallocated, but rather, is marked as "inactive"
/// and pushed onto a stack of inactive nodes. During insertion, new
/// nodes are only allocated if there are no inactive nodes to pop off
/// the stack.
///
/// Each time a new "active" node is allocated and inserted to the tree,
/// it is assigned a unique 32-bit node ID, corresponding to the number
/// of nodes of the given type that have already been allocated. Inner
/// node IDs are set at bit 31, and outer node IDs are unset at bit 31.
///
/// Since 32-bit node IDs have bit 31 reserved, the maximum permissible
/// number of node IDs for either type is thus $2^{31} - 1$.
///
/// ## Balance regimes
///
/// Critbit trees are self-sorting but not self-rebalancing, such that
/// worst-case lookup times are $O(k)$, where $k$ is the number of bits
/// in an outer node key. For example, consider the following unbalanced
/// critbit tree, generating by inserting `0`, then bitmasks set only at
/// each successive bit up until $k$:
///
/// >                 k
/// >               _/ \_
/// >             ...   100000000000000.....
/// >            2nd
/// >           /   \
/// >         1st   100
/// >        /   \
/// >      0th   10
/// >     /   \
/// >     0   1
///
/// Here, searching for `1` involves walking from the root, branching
/// left at each inner node until ariving at `0th`, then checking
/// the right child, effectively an $O(n)$ operation.
///
/// In contrast, inserting the natural number sequence `0`, `1`, `10`,
/// ..., `111` results in a generally-balanced tree where lookups are
/// $O(log_2(n))$:
///
/// >                          2nd
/// >                _________/   \_________
/// >              1st                     1st
/// >          ___/   \___             ___/   \___
/// >        0th         0th         0th         0th
/// >       /   \       /   \       /   \       /   \
/// >     000   001   010   011   100   101   110   111
///
/// In the present implementation, with insertion keys limited to 32
/// bits and insertion counts corresponding to a natural number
/// sequence, lookups are thus effectively $O(32)$ in the worst case for
/// index key bits 64-95 (insertion key), and $O(log_2(n_i))$ in the
/// general case for index key bits 0-63 (insertion count), where $n_i$
/// is the number of insertions for a given insertion key. Hence for
/// insertion keys `0`, `1`, `10`, `100`, ... and multiple insertions of
/// insertion key `1` in an ascending critqueue, the following critbit
/// tree is generated, having the following index keys at each outer
/// node:
///
/// >                     95th
/// >                    /    \
/// >                  ...    1000000...000...
/// >                 66th    ^ bit 95  ^ bit 63
/// >                /    \
/// >              65th   100000...
/// >             /    \     ^ bit 63
/// >           64th   10000...
/// >          /    \    ^ bit 63
/// >     000...     \____________
/// >     ^ bit 63               1st
/// >                 __________/   \__________
/// >               0th                       0th
/// >              /   \                     /   \
/// >     1000...000   1000...001   1000...010   1000...011
/// >      ^ bit 63     ^ bit 63     ^ bit 63     ^ bit 63
///
/// ## Lookup gas
///
/// While critqueue insertion key lookup is theoretically $O(k)$ in the
/// worst case, this only applies for bitstrings with maximally sparse
/// prefixes. Here, with each node stored as a separate hash table entry
/// in global storage, Aptos storage gas is thus assessed as a per-item
/// read for each node accessed during a search.
///
/// Notably, however, per-item reads cost only one fifth as much as
/// per-item writes as of the time of this writing, and while $O(k)$
/// per-item reads could potentially be eliminated via a self-balancing
/// alternative, e.g. an AVL or red-black tree, the requisite
/// rebalancing operations would entail per-item write costs that far
/// outweigh the reduction in $O(k)$-associated lookup gas.
///
/// Hence for the present implementation, insertion keys are limited to
/// 32 bits to reduce the worst-case $O(k)$ lookup, and are combined
/// with a natural number insertion counter to generate outer node index
/// keys.
///
/// ## Access keys
///
/// Upon insertion, index keys (which contain only 96 bits), are
/// concatenated with the corresponding outer node ID for the outer node
/// just inserted to the critqueue, yielding a unique "access key" that
/// can be used for $O(1)$ insertion value lookup by outer node ID:
///
/// | Bits   | Data          |
/// |--------|---------------|
/// | 32-127 | Index key     |
/// | 0-31   | Outer node ID |
///
/// Access keys are returned to callers during insertion, and have the
/// same lexicographical sorting properites as index keys.
///
/// # Complete docgen index
///
/// The below index is automatically generated from source code:
module econia::critqueue {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table_with_length::{TableWithLength};
    use std::option::{Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A hybrid between a critbit tree and a queue. See above.
    struct CritQueue<V> has store {
        /// `ASCENDING` or `DESCENDING`.
        sort_order: bool,
        /// Map from inner node ID to inner node.
        inners: TableWithLength<u64, Inner>,
        /// Map from outer node ID to outer node.
        outers: TableWithLength<u64, Outer<V>>,
        /// Node ID of root node, if any.
        root_node_id: Option<u64>,
        /// Node ID of head node, if any.
        head_node_id: Option<u64>,
        /// Insertion key of head node, if any.
        head_insertion_key: Option<u64>,
        /// Cumulative insertion count.
        insertion_count: u64,
        /// ID of inactive inner node at top of stack, if any.
        inactive_inner_top: Option<u64>,
        /// ID of inactive outer node at top of stack, if any.
        inactive_outer_top: Option<u64>,
    }

    /// An inner node in a critqueue.
    ///
    /// If an active node, `next` field is ignored. If an inactive node,
    /// all fields except `next` are ignored.
    struct Inner has store {
        /// Critical bit number.
        critical_bit: u8,
        /// Node ID of left child.
        left: u64,
        /// Node ID of right child.
        right: u64,
        /// Node ID of next inactive inner node in stack, if any.
        next: Option<u64>,
    }

    /// An outer node in a critqueue.
    ///
    /// If an active node, `next` field is ignored. If an inactive node,
    /// all fields except `next` are ignored.
    struct Outer<V> has store {
        /// Index key for given key-value insertion pair.
        index_key: u128,
        /// Insertion value.
        value: Option<V>,
        /// Node ID of next inactive inner node in stack, if any.
        next: Option<u64>,
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}