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
/// Each time a new node is allocated, it is assigned a unique 32-bit
/// node ID, where bits 0-30 indicate the number of nodes of the given
/// type that have already been allocated. Node 31 is then set in the
/// case of an inner node, but left unset in the case of an outer node:
///
/// | Bit(s) | Inner node ID       | Outer node ID       |
/// |--------|---------------------|---------------------|
/// | 31     | 1                   | 0                   |
/// | 0-30   | 0-indexed serial ID | 0-indexed serial ID |
///
/// Since 32-bit node IDs have bit 31 reserved, the maximum permissible
/// number of node IDs for either type is thus $2^{31}$.
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

    use aptos_std::table_with_length::{Self, TableWithLength};
    use std::option::{Self, Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use std::vector;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A hybrid between a critbit tree and a queue. See above.
    struct CritQueue<V> has store {
        /// `ASCENDING` or `DESCENDING`.
        sort_order: bool,
        /// Node ID of root node, if any.
        root_node_id: Option<u64>,
        /// Access key of head node, if any.
        head_access_key: Option<u128>,
        /// Cumulative insertion count.
        insertion_count: u64,
        /// Map from inner node ID to inner node.
        inners: TableWithLength<u64, Inner>,
        /// Map from outer node ID to outer node.
        outers: TableWithLength<u64, Outer<V>>,
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

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Specified node count is too high.
    const E_TOO_MANY_NODES: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending critqueue flag.
    const ASCENDING: bool = true;
    /// Descending critqueue flag.
    const DESCENDING: bool = false;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// `u128` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 128, 2))`.
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// `u64` bitmask set at all bits except bit 31, generated in Python
    /// via `hex(int('1' * 31, 2))`.
    const MAX_NODE_COUNT: u64 = 0x7fffffff;
    /// Most significant bit number in a 96-bit index key.
    const MSB_INDEX_KEY: u8 = 95;
    /// Number of bits in a node ID.
    const N_BITS_NODE_ID: u8 = 32;
    /// `u64` bitmask set at bit 31 (the node type bit flag), generated
    /// in Python via `hex(int('1' + '0' * 31, 2))`.
    const NODE_TYPE: u64 = 0x80000000;
    /// Result of node ID bitwise `AND` `NODE_TYPE` for an inner node,
    /// Generated in Python via `hex(int('1' + '0' * 31, 2))`. Can also
    /// be used to generate an inner node ID via bitwise `OR` the node's
    /// 0-indexed serial ID.
    const NODE_TYPE_INNER: u64 = 0x80000000;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return a new critqueue, optionally allocating inactive nodes.
    ///
    /// Inserting the root outer node requires a single allocated outer
    /// node, while all other insertions require an outer and an inner
    /// node. Hence for a nonzero number of outer nodes, the number of
    /// inner nodes in the tree is one less than the number of outer
    /// nodes.
    ///
    /// # Parameters
    ///
    /// * `sort_order`: `ASCENDING` or `DESCENDING`.
    /// * `n_inactive_outer_nodes`: The number of inactive outer nodes
    ///   to allocate.
    ///
    /// # Returns
    ///
    /// * `CritQueue<V>`: A new critqueue.
    ///
    /// # Testing
    ///
    /// * `test_new()`
    public fun new<V: store>(
        sort_order: bool,
        n_inactive_outer_nodes: u64
    ): CritQueue<V> {
        // Assert not trying to allocate too many nodes.
        verify_new_node_count(n_inactive_outer_nodes);
        let critqueue = CritQueue{ // Declare empty critqueue.
            sort_order,
            root_node_id: option::none(),
            head_access_key: option::none(),
            insertion_count: 0,
            inners: table_with_length::new(),
            outers: table_with_length::new(),
            inactive_inner_top: if (n_inactive_outer_nodes > 1)
                option::some((n_inactive_outer_nodes - 2) | NODE_TYPE_INNER)
                else option::none(),
            inactive_outer_top: if (n_inactive_outer_nodes > 0)
                option::some(n_inactive_outer_nodes - 1) else option::none()
        };
        // If need to allocate at least one outer node:
        if (n_inactive_outer_nodes > 0) {
            let i = 0; // Declare loop counter.
            // While nodes to allocate:
            while (i < n_inactive_outer_nodes) {
                if (i > 0) { // If not on the first loop iteration:
                    // Next inactive inner node is none if on second
                    // loop iteration, otherwise is loop count minus 2.
                    let next = if (i == 1) option::none() else
                        option::some((i - 2) | NODE_TYPE_INNER);
                    // Push inactive inner node onto stack.
                    table_with_length::add(
                        &mut critqueue.inners, (i - 1) | NODE_TYPE_INNER,
                        Inner{critical_bit: 0, left: 0, right: 0, next});
                };
                // Next inactive outer node is none if on first loop
                // iteration, otherwise is loop count minus 1.
                let next = if (i == 0) option::none() else
                    option::some(i - 1);
                // Push inactive outer node onto stack.
                table_with_length::add(&mut critqueue.outers, i, Outer<V>{
                    index_key: 0, value: option::none(), next});
                i = i + 1; // Increment loop counter.
            }
        };
        critqueue // Return critqueue.
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return the number of the most significant bit at which two
    /// unequal index key bitstrings, `s1` and `s2`, vary.
    ///
    /// # `XOR`/`AND` method
    ///
    /// First, a bitwise `XOR` is used to flag all differing bits:
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
    /// they are stored as 96-bit integers, so a binary search is
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
    /// bitstring (7 in the present example, but 95 in the case of a
    /// 96-bit index key), and the lower bound `l` is initialized to 0.
    /// Next the midpoint `m` is calculated as the average of `u` and
    /// `l`, in this case `m = (7 + 0) / 2 = 3`, per truncating integer
    /// division. Finally, the shifted compare value `s = x >> m` is
    /// calculated, with the result having three potential outcomes:
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
    /// Notably this search has converged after only 3 iterations, as
    /// opposed to 7 for the linear search proposed above, and in
    /// general such a search converges after $log_2(k)$ iterations at
    /// most, where $k$ is the number of bits in each of the strings
    /// `s1` and `s2` under comparison. Hence this search method
    /// improves the $O(k)$ search proposed by [Langley 2008] to
    /// $O(log_2(k))$, and moreover, determines the actual number of
    /// the critical bit, rather than just a bitmask with bit `c` set,
    /// as he proposes, which can also be easily generated via `1 << c`.
    ///
    /// # Testing
    ///
    /// * `test_get_critical_bit()`
    fun get_critical_bit(
        s1: u128,
        s2: u128,
    ): u8 {
        let x = s1 ^ s2; // XOR result marked 1 at bits that differ.
        let l = 0; // Lower bound on critical bit search.
        let u = MSB_INDEX_KEY; // Upper bound on critical bit search.
        loop { // Begin binary search.
            let m = (l + u) / 2; // Calculate midpoint of search window.
            let s = x >> m; // Calculate midpoint shift of XOR result.
            if (s == 1) return m; // If shift equals 1, c = m.
            // Update search bounds.
            if (s > 1) l = m + 1 else u = m - 1;
        }
    }

    /// Activate an inner node with given fields, returning node ID.
    ///
    /// If inactive inner node stack is empty, allocate a new inner node
    /// in global storage. Otherwise pop an inactive node off the stack
    /// and activate it.
    ///
    /// # Parameters
    ///
    /// * `critqueue_ref_mut`: Mutable reference to critqueue to
    ///   activate within.
    /// * `critical_bit`: Critical bit field for new inner node.
    /// * `left`: Left child node ID.
    /// * `right`: Right child node ID.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of activated node.
    ///
    /// # Node counts
    ///
    /// The number of allocated inner nodes should always be less than
    /// or equal to the number of allocated outer nodes, and since
    /// `activate_outer_node()` is called before `activate_inner_node()`
    /// during `insert()`, there is no need for an additional node count
    /// check in `activate_inner_node()`, since
    /// `verify_new_node_count()` will have already been called by
    /// `activate_outer_node()`.
    ///
    /// # Testing
    ///
    /// * `test_activate_inner_node()`
    fun activate_inner_node<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        critical_bit: u8,
        left: u64,
        right: u64
    ): u64 {
        let node_id; // Declare inner node ID.
        // If inactive inner node stack is empty:
        if (option::is_none(&critqueue_ref_mut.inactive_inner_top)) {
            // Get numer of allocated inner nodes.
            let n_nodes = table_with_length::length(&critqueue_ref_mut.inners);
            // Get 0-indexed inner node ID, set at node type flag bit.
            node_id = n_nodes | NODE_TYPE_INNER;
            // Mutably borrow inner nodes table.
            let inners_ref_mut = &mut critqueue_ref_mut.inners;
            // Allocate a new inner node with given fields.
            table_with_length::add(inners_ref_mut, node_id, Inner{
                critical_bit, left, right, next: option::none()});
        } else { // If can pop inactive node off stack:
            // Get node ID of inactive node at top of stack.
            node_id = *option::borrow(&critqueue_ref_mut.inactive_inner_top);
            // Mutably borrow inactive node at top of stack.
            let node_ref_mut = table_with_length::borrow_mut(
                &mut critqueue_ref_mut.inners, node_id);
            // Set top of stack to be next node indicated by stack top.
            critqueue_ref_mut.inactive_inner_top = node_ref_mut.next;
            // Set critical bit for activated node.
            node_ref_mut.critical_bit = critical_bit;
            // Set left child field for activated node.
            node_ref_mut.left = left;
            // Set right child field for activated node.
            node_ref_mut.right = right;
        };
        node_id // Return node ID of activated inner node.
    }

    /// Activate an outer node with given fields, returning access key.
    ///
    /// If inactive outer node stack is empty, allocate a new outer node
    /// in global storage. Otherwise pop an inactive node off the stack
    /// and activate it.
    ///
    /// # Parameters
    ///
    /// * `critqueue_ref_mut`: Mutable reference to critqueue to
    ///   activate within.
    /// * `index_key`: Index key corresponding to key-value insertion
    ///   pair.
    /// * `value`: Insertion value from key-value insertion pair.
    ///
    /// # Returns
    ///
    /// * `u128`: Access key for activated node.
    ///
    /// # Testing
    ///
    /// * `test_activate_outer_node()`
    fun activate_outer_node<V>(
        critqueue_ref_mut: &mut CritQueue<V>,
        index_key: u128,
        value: V
    ): u128 {
        let node_id; // Declare outer node ID.
        // If inactive outer node stack is empty:
        if (option::is_none(&critqueue_ref_mut.inactive_outer_top)) {
            // Get numer of allocated outer nodes.
            let n_nodes = table_with_length::length(&critqueue_ref_mut.outers);
            // Verify new number of nodes.
            verify_new_node_count(n_nodes + 1);
            node_id = n_nodes; // Get 0-indexed outer node ID.
            // Mutably borrow outer nodes table.
            let outers_ref_mut = &mut critqueue_ref_mut.outers;
            // Allocate a new outer node with given fields.
            table_with_length::add(outers_ref_mut, node_id, Outer{
                index_key, value: option::some(value), next: option::none()});
        } else { // If can pop inactive node off stack:
            // Get node ID of inactive node at top of stack.
            node_id = *option::borrow(&critqueue_ref_mut.inactive_outer_top);
            // Mutably borrow inactive node at top of stack.
            let node_ref_mut = table_with_length::borrow_mut(
                &mut critqueue_ref_mut.outers, node_id);
            // Set top of stack to be next node indicated by stack top.
            critqueue_ref_mut.inactive_outer_top = node_ref_mut.next;
            // Set index key for activated node.
            node_ref_mut.index_key = index_key;
            // Set insertion value for activated node.
            option::fill(&mut node_ref_mut.value, value);
        };
        // Return access key derived from index key and node ID.
        (index_key << N_BITS_NODE_ID) | (node_id as u128)
    }

    /// Verify proposed new node count is not too high.
    ///
    /// # Aborts
    ///
    /// * `E_TOO_MANY_NODES`: If `n_nodes` exceeds `MAX_NODE_COUNT`.
    ///
    /// # Testing
    ///
    /// * `test_verify_new_node_count_fail()`
    /// * `test_verify_new_node_count_pass()`
    fun verify_new_node_count(
        n_nodes: u64,
    ) {
        // Assert proposed node count is less than or equal to max.
        assert!(n_nodes <= MAX_NODE_COUNT, E_TOO_MANY_NODES);
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// When a char in a bytestring is neither 0 nor 1.
    const E_BIT_NOT_0_OR_1: u64 = 100;

    // Test-only error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return fields for inner node having given node ID in given
    /// critqueue.
    fun get_inner_node_fields_test<V: copy>(
        critqueue_ref: &CritQueue<V>,
        node_id: u64
    ): (
        u8,
        u64,
        u64,
        Option<u64>
    ) {
        // Immutably borrow inner nodes table.
        let inners_ref = &critqueue_ref.inners;
        // Immutably borrow node.
        let node_ref = table_with_length::borrow(inners_ref, node_id);
        // Return fields.
        (node_ref.critical_bit, node_ref.left, node_ref.right, node_ref.next)
    }

    #[test_only]
    /// Return fields for outer node having given node ID in given
    /// critqueue.
    fun get_outer_node_fields_test<V: copy>(
        critqueue_ref: &CritQueue<V>,
        node_id: u64
    ): (
        u128,
        Option<V>,
        Option<u64>
    ) {
        // Immutably borrow outer nodes table.
        let outers_ref = &critqueue_ref.outers;
        // Immutably borrow node.
        let node_ref = table_with_length::borrow(outers_ref, node_id);
        // Return fields.
        (node_ref.index_key, node_ref.value, node_ref.next)
    }

    #[test_only]
    /// Return a `u128` corresponding to provided byte string `s`. The
    /// byte should only contain only "0"s and "1"s, up to 128
    /// characters max (e.g. `b"100101...10101010"`).
    ///
    /// # Testing
    ///
    /// * `test_u_128_64()`
    /// * `test_u_128_failure()`
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
    ///
    /// # Testing
    ///
    /// * `test_u_128_64()`
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

    #[test_only]
    /// Wrapper for `u_128()`, casting return to `u64`.
    ///
    /// # Testing
    ///
    /// * `test_u_128_64()`
    public fun u_64(s: vector<u8>): u64 {(u_128(s) as u64)}

    #[test_only]
    /// Wrapper for `u_128_by_32()`, accepting only two inputs, with
    /// casted return to `u64`.
    public fun u_64_by_32(
        a: vector<u8>,
        b: vector<u8>
    ): u64 {
        // Get u128 for given inputs, cast to u64.
        (u_128_by_32(a, b, b"", b"") as u64)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify activating inner node at top of stack, bottom of stack,
    /// and when no stack.
    fun test_activate_inner_node():
    CritQueue<u8> {
        // Get critqueue with 3 allocated outer nodes, and thus 2
        // allocated inner nodes.
        let critqueue = new(ASCENDING, 3);
        // Declare inner node fields.
        let (critical_bit, left, right) = (1, 2, 3);
        let node_id = activate_inner_node( // Activate outer node.
            &mut critqueue, critical_bit, left, right);
        // Assert node ID.
        assert!(node_id == u_64_by_32(
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000001"
        ), 0);
        // Assert activated node's fields.
        let (critical_bit_activated, left_activated, right_activated, _) =
            get_inner_node_fields_test(&critqueue, node_id);
        assert!(critical_bit_activated == critical_bit, 0);
        assert!(left_activated == left, 0);
        assert!(right_activated == right, 0);
        // Assert stack top update.
        assert!(*option::borrow(&critqueue.inactive_inner_top) ==
            0 | NODE_TYPE_INNER, 0);
        // Declare inner node fields.
        (critical_bit, left, right) = (4, 5, 6);
        node_id = activate_inner_node( // Activate outer node.
            &mut critqueue, critical_bit, left, right);
        // Assert node ID.
        assert!(node_id == u_64_by_32(
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000000"
        ), 0);
        // Assert activated node's fields.
        (critical_bit_activated, left_activated, right_activated, _) =
            get_inner_node_fields_test(&critqueue, node_id);
        assert!(critical_bit_activated == critical_bit, 0);
        assert!(left_activated == left, 0);
        assert!(right_activated == right, 0);
        // Assert stack top update.
        assert!(option::is_none(&critqueue.inactive_inner_top), 0);
        // Declare inner node fields.
        (critical_bit, left, right) = (7, 8, 9);
        node_id = activate_inner_node( // Activate outer node.
            &mut critqueue, critical_bit, left, right);
        // Assert node ID.
        assert!(node_id == u_64_by_32(
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000010"
        ), 0);
        // Assert activated node's fields.
        (critical_bit_activated, left_activated, right_activated, _) =
            get_inner_node_fields_test(&critqueue, node_id);
        assert!(critical_bit_activated == critical_bit, 0);
        assert!(left_activated == left, 0);
        assert!(right_activated == right, 0);
        critqueue // Return critqueue.
    }

    #[test]
    /// Verify activating outer node at top of stack, bottom of stack,
    /// and when no stack.
    fun test_activate_outer_node():
    CritQueue<u8> {
        // Get critqueue with 2 allocated outer nodes.
        let critqueue = new(ASCENDING, 2);
        // Declare index key.
        let index_key = u_128_by_32(
            b"00000000000000000000000000000000",
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000"
        );
        // Declare insertion value.
        let insertion_value = 123;
        let access_key = activate_outer_node( // Activate outer node.
            &mut critqueue, index_key, insertion_value);
        // Assert access key.
        assert!(access_key == u_128_by_32(
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001"
        ), 0);
        // Assert activated node's fields.
        let (index_key_activated, value, _) = get_outer_node_fields_test(
            &critqueue, 1);
        assert!(index_key_activated == index_key, 0);
        assert!(*option::borrow(&value) == insertion_value, 0);
        // Assert stack top update.
        assert!(*option::borrow(&critqueue.inactive_outer_top) == 0, 0);
        // Declare index key.
        index_key = u_128_by_32(
            b"00000000000000000000000000000000",
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001"
        );
        // Declare insertion value.
        insertion_value = 234;
        access_key = activate_outer_node( // Activate outer node.
            &mut critqueue, index_key, insertion_value);
        // Assert access key.
        assert!(access_key == u_128_by_32(
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"00000000000000000000000000000000"
        ), 0);
        // Assert activated node's fields.
        (index_key_activated, value, _) = get_outer_node_fields_test(
            &critqueue, 0);
        assert!(index_key_activated == index_key, 0);
        assert!(*option::borrow(&value) == insertion_value, 0);
        // Assert stack top update.
        assert!(option::is_none(&critqueue.inactive_outer_top), 0);
        // Declare index key.
        index_key = u_128_by_32(
            b"00000000000000000000000000000000",
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010"
        );
        // Declare insertion value.
        insertion_value = 210;
        access_key = activate_outer_node( // Activate outer node.
            &mut critqueue, index_key, insertion_value);
        // Assert access key.
        assert!(access_key == u_128_by_32(
            b"11111111111111111111111111111111",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
            b"00000000000000000000000000000010"
        ), 0);
        // Assert activated node's fields.
        (index_key_activated, value, _) = get_outer_node_fields_test(
            &critqueue, 2);
        assert!(index_key_activated == index_key, 0);
        assert!(*option::borrow(&value) == insertion_value, 0);
        critqueue // Return critqueue.
    }

    #[test]
    /// Verify successful calculation of critical bit at all positions.
    fun test_get_critical_bit() {
        let b = 0; // Start loop for bit 0.
        while (b <= MSB_INDEX_KEY) { // Loop over all bit numbers.
            // Compare 0 versus a bitmask that is only set at bit b.
            assert!(get_critical_bit(0, 1 << b) == b, (b as u64));
            b = b + 1; // Increment bit counter.
        };
    }

    #[test]
    /// Verify successful initialization for both sort orders and all
    /// allocation counts from 0 to 4 inclusive.
    fun test_new(): (
        CritQueue<u8>,
        CritQueue<u8>,
        CritQueue<u8>,
        CritQueue<u8>,
        CritQueue<u8>
    ) {
        let critqueue = new(ASCENDING, 0); // Get ascending critqueue.
        // Verify fields.
        assert!(critqueue.sort_order == ASCENDING, 0);
        assert!(option::is_none(&critqueue.root_node_id), 0);
        assert!(option::is_none(&critqueue.head_access_key), 0);
        assert!(critqueue.insertion_count == 0, 0);
        assert!(table_with_length::length(&critqueue.inners) == 0, 0);
        assert!(table_with_length::length(&critqueue.outers) == 0, 0);
        assert!(option::is_none(&critqueue.inactive_inner_top), 0);
        assert!(option::is_none(&critqueue.inactive_outer_top), 0);
        let critqueue_0 = critqueue; // Move critqueue.
        critqueue = new(DESCENDING, 1); // Get descending critqueue.
        // Verify fields.
        assert!(critqueue.sort_order == DESCENDING, 0);
        assert!(table_with_length::length(&critqueue.inners) == 0, 0);
        assert!(table_with_length::length(&critqueue.outers) == 1, 0);
        assert!(option::is_none(&critqueue.inactive_inner_top), 0);
        assert!(*option::borrow(&critqueue.inactive_outer_top) == 0, 0);
        // Verify outer node stack next field chain.
        let outer_node_ref = table_with_length::borrow(&critqueue.outers, 0);
        assert!(option::is_none(&outer_node_ref.next), 0);
        let critqueue_1 = critqueue; // Move critqueue.
        critqueue = new(ASCENDING, 2); // Get ascending critqueue.
        // Verify fields.
        assert!(table_with_length::length(&critqueue.inners) == 1, 0);
        assert!(table_with_length::length(&critqueue.outers) == 2, 0);
        assert!(*option::borrow(&critqueue.inactive_inner_top) ==
            0 | NODE_TYPE_INNER, 0);
        assert!(*option::borrow(&critqueue.inactive_outer_top) == 1, 0);
        // Verify inner node stack next field chain.
        let inner_node_ref = table_with_length::borrow(&critqueue.inners,
            0 | NODE_TYPE_INNER);
        assert!(option::is_none(&inner_node_ref.next), 0);
        // Verify outer node stack next field chain.
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 1);
        assert!(*option::borrow(&outer_node_ref.next) == 0, 0);
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 0);
        assert!(option::is_none(&outer_node_ref.next), 0);
        let critqueue_2 = critqueue; // Move critqueue.
        critqueue = new(ASCENDING, 3); // Get ascending critqueue.
        // Verify fields.
        assert!(table_with_length::length(&critqueue.inners) == 2, 0);
        assert!(table_with_length::length(&critqueue.outers) == 3, 0);
        assert!(*option::borrow(&critqueue.inactive_inner_top) ==
            1 | NODE_TYPE_INNER, 0);
        assert!(*option::borrow(&critqueue.inactive_outer_top) == 2, 0);
        // Verify inner node stack next field chain.
        inner_node_ref = table_with_length::borrow(&critqueue.inners,
            1 | NODE_TYPE_INNER);
        assert!(*option::borrow(&inner_node_ref.next) ==
            0 | NODE_TYPE_INNER, 0);
        inner_node_ref = table_with_length::borrow(&critqueue.inners,
            0 | NODE_TYPE_INNER);
        assert!(option::is_none(&inner_node_ref.next), 0);
        // Verify outer node stack next field chain.
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 2);
        assert!(*option::borrow(&outer_node_ref.next) == 1, 0);
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 1);
        assert!(*option::borrow(&outer_node_ref.next) == 0, 0);
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 0);
        assert!(option::is_none(&outer_node_ref.next), 0);
        let critqueue_3 = critqueue; // Move critqueue.
        critqueue = new(ASCENDING, 4); // Get ascending critqueue.
        // Verify fields.
        assert!(table_with_length::length(&critqueue.inners) == 3, 0);
        assert!(table_with_length::length(&critqueue.outers) == 4, 0);
        assert!(*option::borrow(&critqueue.inactive_inner_top) ==
            2 | NODE_TYPE_INNER, 0);
        assert!(*option::borrow(&critqueue.inactive_outer_top) == 3, 0);
        // Verify inner node stack next field chain.
        inner_node_ref = table_with_length::borrow(&critqueue.inners,
            2 | NODE_TYPE_INNER);
        assert!(*option::borrow(&inner_node_ref.next) ==
            1 | NODE_TYPE_INNER, 0);
        inner_node_ref = table_with_length::borrow(&critqueue.inners,
            1 | NODE_TYPE_INNER);
        assert!(*option::borrow(&inner_node_ref.next) ==
            0 | NODE_TYPE_INNER, 0);
        inner_node_ref = table_with_length::borrow(&critqueue.inners,
            0 | NODE_TYPE_INNER);
        assert!(option::is_none(&inner_node_ref.next), 0);
        // Verify outer node stack next field chain.
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 3);
        assert!(*option::borrow(&outer_node_ref.next) == 2, 0);
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 2);
        assert!(*option::borrow(&outer_node_ref.next) == 1, 0);
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 1);
        assert!(*option::borrow(&outer_node_ref.next) == 0, 0);
        outer_node_ref = table_with_length::borrow(&critqueue.outers, 0);
        assert!(option::is_none(&outer_node_ref.next), 0);
        let critqueue_4 = critqueue; // Move critqueue.
        // Return critqueues.
        (critqueue_0, critqueue_1, critqueue_2, critqueue_3, critqueue_4)
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
        assert!(u_64_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ) == HI_64, 0);
        assert!(u_64_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111110"
        ) == HI_64 - 1, 0);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    /// Verify failure for non-binary-representative byte string.
    fun test_u_128_failure() {u_128(b"2");}

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for too many nodes.
    fun test_verify_new_node_count_fail() {
        // Attempt invalid invocation for one too many nodes.
        verify_new_node_count(u_64_by_32(
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000000"
        ));
    }

    #[test]
    /// Verify maximum node count allocation.
    fun test_verify_new_node_count_pass() {
        // Attempt valid invocation for max number of nodes.
        verify_new_node_count(u_64_by_32(
            b"00000000000000000000000000000000",
            b"01111111111111111111111111111111"
        ));
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}