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
/// `0th` the integer 0. Hence, the sole key in the left subtree of
/// `2nd` is unset at bit 2, while all the keys in the right subtree of
/// `2nd` are set at bit 2. And similarly for `0th`, the key of its left
/// child is unset at bit 0, while the key of its right child is set at
/// bit 0.
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
/// ## Access keys
///
/// The present critqueue implementation involves a critbit tree outer
/// node for each key-value insertion pair, corresponding to an "access
/// key" having the following bit structure (`NOT` denotes
/// bitwise complement):
///
/// | Bit(s) | Ascending critqueue | Descending critqueue  |
/// |--------|---------------------|-----------------------|
/// | 64-127 | Insertion key       | Insertion key         |
/// | 63     | 0                   | 1                     |
/// | 0-62   | Insertion count     | `NOT` insertion count |
///
/// For an ascending critqueue, access keys can thus be dequeued in
/// ascending lexicographical order via inorder successor iteration
/// starting at the minimum access key:
///
/// | Insertion key | Access key bits 64-127 | Access key bits 0-63 |
/// |---------------|------------------------|----------------------|
/// | $k_{0, 0}$    | `000...000`            | `000...000`          |
/// | $k_{0, 3}$    | `000...000`            | `000...011`          |
/// | $k_{1, 1}$    | `000...001`            | `000...001`          |
/// | $k_{1, 2}$    | `000...001`            | `000...010`          |
/// | $k_{3, 4}$    | `000...011`            | `000...100`          |
///
/// >                                          65th
/// >                                         /    \           critqueue
/// >                                      64th    k_{3, 4} <- tail
/// >                            _________/    \________
/// >                          1st                     1st
/// >     critqueue           /   \                   /   \
/// >          head -> k_{0, 0}   k_{0, 3}     k_{1, 1}   k_{1, 2}
///
/// Conversely, for an descending critqueue, access keys can thus be
/// dequeued in descending lexicographical order via inorder predecessor
/// iteration starting at the maximum access key:
///
///
/// | Insertion key | Access key bits 64-127 | Access key bits 0-63 |
/// |---------------|----------------------|------------------------|
/// | $k_{3, 4}$    | `000...011`          | `111...011`            |
/// | $k_{1, 1}$    | `000...001`          | `111...110`            |
/// | $k_{1, 2}$    | `000...001`          | `111...101`            |
/// | $k_{0, 0}$    | `000...000`          | `111...111`            |
/// | $k_{0, 3}$    | `000...000`          | `111...100`            |
///
/// >                                          65th
/// >                                         /    \           critqueue
/// >                                      64th    k_{3, 4} <- head
/// >                            _________/    \________
/// >                          1st                     1st
/// >     critqueue           /   \                   /   \
/// >          tail -> k_{0, 3}   k_{0, 0}     k_{1, 2}   k_{1, 1}
///
/// Since access keys have bit 63 reserved, the maximum permissible
/// insertion count is thus $2^{62} - 1$.
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
/// it is assigned a unique node ID, corresponding to the number of
/// nodes of the given type that have already been allocated. Inner node
/// IDs are set at bit 63, and outer node IDs are unset at bit 63.
///
/// Since node IDs have bit 63 reserved, the maximum permissible number
/// of node IDs for either type is thus $2^{62} - 1$.
///
/// ## Leading edges and nodes
///
/// In the present implementation, a "leading edge" is defined as a tree
/// found in the shortest path from the root to the head.
///
/// For example, consider the following tree:
///
/// >                    node c -> 3rd
/// >              edge a -> _____/   \_____ <- edge e
/// >                      2nd             2nd
/// >           edge b -> /   \           /   \ <- edge f
/// >                   1st   0100     1000   1st
/// >        edge c -> /   \                 /   \ <- edge g
/// >      node a -> 0th   0010  node b -> 0th   1110
/// >     edge d -> /   \                 /   \
/// >            0000   0001           1100   1101
///
/// * In an ascending critqueue, `0000` is at the head, with leading
///   edges a, b, c, and d.
/// * In a descending critqueue, `1110` is at the head, with leading
///   edges e, f, and g.
///
/// A "leading inner node" is defined as an inner node having a leading
/// edge, including the root. For example, node c is a leading inner
/// node for both ascending and descending cases, node a is a leading
/// inner node for the ascending case only, and node b is a leading
/// inner node for neither case.
///
/// ## Lookup caching
///
/// Critbit trees are self-sorting but not self-rebalancing, such that
/// worst-case lookup times are $O(k)$, where $k$ is the number of bits
/// in each outer node key. For example, consider the following
/// unbalanced critbit tree for an ascending critqueue:
///
/// >                   127th
/// >                  /     \
/// >               126th    100000000000000.....
/// >             ...
/// >            2nd
/// >           /   \
/// >         1st   100
/// >        /   \
/// >      0th   10
/// >     /   \
/// >     0   1
///
/// Here, searching for the key `1` involves walking from the root,
/// branching left at each inner node until ariving at `0th`, then
/// checking the right child, effectively an $O(n)$ operation.
/// Conventionally, this operation would involve a storage gas per-item
/// read cost for every leading inner node, as well as one for the
/// corresponding outer node.
///
/// In the present implementation, however, this gas cost is effectively
/// reduced to $O(1)$ via a vector-based cache of leading inner node
/// IDs, stored in the base critqueue resource. Here, the search key is
/// first checked to see if it is unset at the root critical bit (or set
/// it the case of a descending critqueue), and if it is, the search key
/// thus shares a leading edge with the head key, so the critical bit
/// between the head key and the search key is calculated. Once the
/// critical bit has been determined, the corresponding leading inner
/// node ID is looked up in the leading inner node ID cache, enabling in
/// this case, an $O(1)$ global storage lookup for `0th`. Then searching
/// can proceed as usual, by branching left or right depending on
/// whether a search key is set or unset at a walked inner node.
///
/// This optimization only applies to search keys sharing at least one
/// leading edge with the head key, meaning that gas optimizations are
/// only prioritized for insertion keys near the head of the critqueue.
///
/// ## Insertion effects
///
/// During insertion, if a leading edge search yields a critical bit
/// that is not described in the lookup cache, insertion can take place
/// directly below the next-highest critical bit. For example, consider
/// inserting `11` to the following ascending critqueue:
///
/// >                127th
/// >               /     \
/// >            126th    100000000000000.....
/// >          ...
/// >         2nd
/// >        /   \
/// >      0th   100
/// >     /   \
/// >     0   1
///
/// Here, the search key is unset at the root critical bit, which means
/// that it shares a leading edge with the head. The critical bit is
/// then calculated between the head and the search key, in this case
/// `1st`, but there is no corresponding leading `1st` inner node. Hence
/// insertion can take place directly below the next-highest leading
/// inner node, `2nd`, and the new `1st` inner node is added to the
/// lookup cache.
///
/// Alternatively, consider inserting `100` to the following ascending
/// critqueue:
///
/// >                  127th
/// >                 /     \
/// >              126th    100000000000000.....
/// >            ...
/// >           2nd
/// >        __/   \__
/// >      0th       1st
/// >     /   \     /   \
/// >     0   1   101   0th
/// >                  /   \
/// >                110   111
///
/// Here, the search key is compared with the head, yielding the leading
/// inner node `2nd`, from which a search can proceed: to `1st`, then to
/// `101`. Here the critical bit `0th` is determined, so an insertion
/// walk then returns to the common leading inner node, `2nd`, checks
/// the next inner node `1st`, then inserts `0th` and `100` below. In
/// effect, the lookup cache establishes the shared leading inner node
/// as a local root for insert operations.
///
/// ## Cache alterations
///
/// Each time a leading inner node is removed, the lookup cache must be
/// updated to indicate that there is no corresponding node ID for the
/// given critical bit.
///
/// Additionally, whenever a new head is inserted above the root the
/// lookup cache must be completely cleared out. For example, consider
/// the following descending critqueue, where `1st` and `0th` are
/// leading inner nodes.
///
/// >         1st <- root
/// >        /   \
/// >     1001   0th
/// >           /   \
/// >        1010   1011 <- head
///
/// Inserting `1100` yields:
///
/// >                    2nd <- new root
/// >                   /   \
/// >     old root -> 1st   1100 <- new head
/// >                /   \
/// >             1001   0th
/// >                   /   \
/// >                1010   1011 <- old head
///
/// Here, `100` becomes the new head, with `2nd` as the only leading
/// inner node. Notably, inserting above the root does not refresh the
/// lookup cache when the new node does not become the new head. For
/// example, inserting `0000` yields:
///
/// >         3rd <- new root
/// >        /   \
/// >     0000   2nd <- old root
/// >           /   \
/// >         1st   1100 <- same head
/// >        /   \
/// >     1001   0th
/// >           /   \
/// >        1010   1011
///
/// Here, `3rd` simply gets added to the lookup cache.
///
///
/// Note, however, when removing `1100` in either case, the entire
/// cache has to be recalculated.
///
/// # Complete docgen index
///
/// The below index is automatically generated from source code:
module econia::critqueue {

}