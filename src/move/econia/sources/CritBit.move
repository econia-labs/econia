/// # Background
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
/// inner (`I`) and outer (`O`). Inner nodes have two children each
/// (`I.l` and `I.r`), while outer nodes have no children. There are no
/// nodes that have exactly one child. Outer nodes store a key-value
/// pair with a 128-bit integer as a key (`O.k`), and an arbitrary value
/// of generic type (`O.v`). Inner nodes do not store a key, but rather,
/// an 8-bit integer (`I.c`) indicating the most significant critical
/// bit (crit-bit) of divergence between keys located within the node's
/// two subtrees: keys in the node's left subtree are unset at the
/// critical bit, while keys in the node's right subtree are set at the
/// critical bit. Both node types have a parent (`I.p`, `O.p`), which
/// may be flagged as `ROOT` if the the node is the root.
///
/// Bit numbers are 0-indexed starting at the least-significant bit
/// (LSB), such that a critical bit of 3, for instance, corresponds to a
/// comparison between `00...00000` and `00...01111`. Inner nodes are
/// arranged hierarchically, with the most significant critical bits at
/// the top of the tree. For instance, the keys `001`, `101`, `110`, and
/// `111` would be stored in a crit-bit tree as follows (right carets
/// included at left of illustration per issue with documentation build
/// engine, namely, the automatic stripping of leading whitespace in
/// documentation comments, which prohibits the simple initiation of
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
/// Both inner nodes (`I`) and outer nodes (`O`) are stored in vectors
/// (`CB.i` and `CB.o`), and parent-child relationships between nodes
/// are described in terms of vector indices: an outer node indicating
/// `123` in its parent field (`O.p`), for instance, has as its parent
/// an inner node at vector index `123`. Notably, the vector index of an
/// inner node is identical to the number indicated by its child's
/// parent field (`I.p` or `O.p`), but the vector index of an outer node
/// is **not** identical to the number indicated by its parent's child
/// field (`I.l` or `I.r`), because the 63rd bit of a so-called "field
/// index" (the number stored in a struct field) is reserved for a node
/// type bit flag, with outer nodes having bit 63 set and inner nodes
/// having bit 63 unset. This schema enables discrimination between node
/// types based solely on the "field index" of a related node via
/// `is_out()`, but requires that outer node indices be routinely
/// converted between "child field index" form and "vector index" form
/// via `o_c()` and `o_v()`.
///
/// Similarly, if a node, inner or outer, is located at the root, its
/// "parent field index" will indicate `ROOT`, and will not correspond
/// to the vector index of any inner node, since the root node does not
/// have a parent. Likewise, the "root field" of the tree (`CB.r`) will
/// contain the field index of the given node, set at bit 63 if the root
/// is an outer node.
///
/// ---
///
module Econia::CritBit {

    use Std::Vector::{
        borrow as v_b,
        borrow_mut as v_b_m,
        destroy_empty as v_d_e,
        empty as v_e,
        is_empty as v_i_e,
        length as v_l,
        pop_back as v_po_b,
        push_back as v_pu_b,
        swap_remove as v_s_r
    };

    #[test_only]
    use Std::Vector::{
        append as v_a,
    };

    /// A crit-bit tree for key-value pairs with value type `V`
    struct CB<V> has store {
        /// Root node index. When bit 63 is set, root node is an outer
        /// node. Otherwise root is an inner node. 0 when tree is empty
        r: u64,
        /// Inner nodes
        i: vector<I>,
        /// Outer nodes
        o: vector<O<V>>
    }

    /// Inner node
    struct I has store {
        // Documentation comments, specifically within struct fields,
        // apparently do not support fenced code blocks unless they are
        // preceded by a blank line...
        /// Critical bit position. Bit numbers 0-indexed from LSB:
        ///
        /// ```
        /// >    11101...1010010101
        /// >     bit 5 = 0 -|    |- bit 0 = 1
        /// ```
        c: u8,
        /// Parent node vector index. `ROOT` when node is root,
        /// otherwise corresponds to vector index of an inner node.
        p: u64,
        /// Left child node index. When bit 63 is set, left child is an
        /// outer node. Otherwise left child is an inner node.
        l: u64,
        /// Right child node index. When bit 63 is set, right child is
        /// an outer node. Otherwise right child is an inner node.
        r: u64
    }

    /// Outer node with key `k` and value `v`
    struct O<V> has store {
        /// Key, which would preferably be a generic type representing
        /// the union of {`u8`, `u64`, `u128`}. However this kind of
        /// union typing is not supported by Move, so the most general
        /// (and memory intensive) `u128` is instead specified strictly.
        /// Must be an integer for bitwise operations.
        k: u128,
        /// Value from node's key-value pair
        v: V,
        /// Parent node vector index. `ROOT` when node is root,
        /// otherwise corresponds to vector index of an inner node.
        p: u64,
    }

    /// # Error codes

    /// When a char in a bytestring is neither 0 nor 1
    const E_BIT_NOT_0_OR_1: u64 = 0;
    /// When attempting to destroy a non-empty tree
    const E_DESTROY_NOT_EMPTY: u64 = 1;
    /// When an insertion key is already present in a tree
    const E_HAS_K: u64 = 2;
    /// When unable to borrow from empty tree
    const E_BORROW_EMPTY: u64 = 3;
    /// When no matching key in tree
    const E_NOT_HAS_K: u64 = 4;
    /// When no more keys can be inserted
    const E_INSERT_FULL: u64 = 5;
    /// When attempting to pop from empty tree
    const E_POP_EMPTY: u64 = 6;
    /// When attempting to look up on an empty tree
    const E_LOOKUP_EMPTY: u64 = 7;
    /// When attempting to traverse an empty tree
    const E_TRAVERSE_EMPTY: u64 = 8;

    /// # General constants

    /// `u128` bitmask with all bits set
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// `u64` bitmask with all bits set, to flag that a node is at root
    const ROOT: u64 = 0xffffffffffffffff;
    /// Most significant bit number for a `u128`
    const MSB_u128: u8 = 127;
    /// Bit number of node type flag in a `u64` vector index
    const N_TYPE: u8 = 63;
    /// Node type bit flag indicating inner node
    const IN: u64 = 0;
    /// Node type bit flag indicating outer node
    const OUT: u64 = 1;
    /// Left direction
    const L: bool = true;
    /// Right direction
    const R: bool = false;

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return immutable reference to value corresponding to key `k` in
    /// `cb`, aborting if empty tree or no match
    public fun borrow<V>(
        cb: &CB<V>,
        k: u128,
    ): &V {
        assert!(!is_empty<V>(cb), E_BORROW_EMPTY); // Abort if empty
        let c_o = b_s_o<V>(cb, k); // Borrow search outer node
        assert!(c_o.k == k, E_NOT_HAS_K); // Abort if key not in tree
        &c_o.v // Return immutable reference to corresponding value
    }

/*
    /// Return immutable reference to outer node having maximum key in
    /// `cb`, aborting if `cb` empty
    public fun borrow_max_node<V>(
        cb: &CB<V>,
    ): &O<V> {
        let l = length(cb); // Get number of keys in tree
        assert!(l != 0, E_BORROW_EMPTY); // Assert tree not empty
        // If singleton tree, return immutable reference to root node
        if (l == 1) return v_b<O<V>>(&cb.o, o_v(cb.r));
        // Else initialize index of search node to right child of root
        let i_n = v_b<I>(&cb.i, cb.r).r;
        while (!is_out(i_n)) { // While search node is inner node
            i_n = v_b<I>(&cb.i, i_n).r // Review node's right child next
        }; // Index of search node now corresponds to outer node
        // Return immutable reference to node
        v_b<O<V>>(&cb.o, o_v(i_n))
    }

    /// Return immutable reference to outer node having minimum key in
    /// `cb`, aborting if `cb` empty
    public fun borrow_min_node<V>(
        cb: &CB<V>,
    ): &O<V> {
        let l = length(cb); // Get number of keys in tree
        assert!(l != 0, E_BORROW_EMPTY); // Assert tree not empty
        // If singleton tree, return immutable reference to root node
        if (l == 1) return v_b<O<V>>(&cb.o, o_v(cb.r));
        // Else initialize index of search node to left child of root
        let i_n = v_b<I>(&cb.i, cb.r).l;
        while (!is_out(i_n)) { // While search node is inner node
            i_n = v_b<I>(&cb.i, i_n).l // Review node's left child next
        }; // Index of search node now corresponds to outer node
        // Return immutable reference to node
        v_b<O<V>>(&cb.o, o_v(i_n))
    }
*/

    /// Return mutable reference to value corresponding to key `k` in
    /// `cb`, aborting if empty tree or no match
    public fun borrow_mut<V>(
        cb: &mut CB<V>,
        k: u128,
    ): &mut V {
        assert!(!is_empty<V>(cb), E_BORROW_EMPTY); // Abort if empty
        let c_o = b_s_o_m<V>(cb, k); // Borrow search outer node
        assert!(c_o.k == k, E_NOT_HAS_K); // Abort if key not in tree
        &mut c_o.v // Return mutable reference to corresponding value
    }

    /// Destroy empty tree `cb`
    public fun destroy_empty<V>(
        cb: CB<V>
    ) {
        assert!(is_empty(&cb), E_DESTROY_NOT_EMPTY);
        let CB{r: _, i, o} = cb; // Unpack root index and node vectors
        v_d_e(i); // Destroy empty inner node vector
        v_d_e(o); // Destroy empty outer node vector
    }

    /// Return an empty tree
    public fun empty<V>():
    CB<V> {
        CB{r: 0, i: v_e<I>(), o: v_e<O<V>>()}
    }

    /// Insert key `k` and value `v` into `cb`, aborting if `k` already
    /// in `cb`
    public fun insert<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V
    ) {
        let l = length(cb); // Get length of tree
        check_len(l); // Verify insertion can take place
        // Insert via one of three cases, depending on the length
        if (l == 0) insert_empty(cb, k , v) else
        if (l == 1) insert_singleton(cb, k, v) else
        insert_general(cb, k, v, l);
    }

    /// Return `true` if `cb` has no outer nodes
    public fun is_empty<V>(cb: &CB<V>): bool {v_i_e<O<V>>(&cb.o)}

    /// Return number of keys in `cb` (number of outer nodes)
    public fun length<V>(cb: &CB<V>): u64 {v_l<O<V>>(&cb.o)}

    /// Return the maximum key in `cb`, aborting if `cb` is empty
    public fun max_key<V>(
        cb: &CB<V>,
    ): u128 {
        let l = length(cb); // Get number of keys in tree
        assert!(l != 0, E_LOOKUP_EMPTY); // Assert tree not empty
        // If singleton tree, return key of outer node at root
        if (l == 1) return v_b<O<V>>(&cb.o, o_v(cb.r)).k;
        // Else initialize index of search node to right child of root
        let i_n = v_b<I>(&cb.i, cb.r).r;
        while (!is_out(i_n)) { // While search node is inner node
            i_n = v_b<I>(&cb.i, i_n).r // Review node's right child next
        }; // Index of search node now corresponds to outer node
        v_b<O<V>>(&cb.o, o_v(i_n)).k // Return key of node
    }

    /// Return the minimum key in `cb`, aborting if `cb` is empty
    public fun min_key<V>(
        cb: &CB<V>,
    ): u128 {
        let l = length(cb); // Get number of keys in tree
        assert!(l != 0, E_LOOKUP_EMPTY); // Assert tree not empty
        // If singleton tree, return key of outer node at root
        if (l == 1) return v_b<O<V>>(&cb.o, o_v(cb.r)).k;
        // Else initialize index of search node to left child of root
        let i_n = v_b<I>(&cb.i, cb.r).l;
        while (!is_out(i_n)) { // While search node is inner node
            i_n = v_b<I>(&cb.i, i_n).l // Review node's left child next
        }; // Index of search node now corresponds to outer node
        v_b<O<V>>(&cb.o, o_v(i_n)).k // Return key of node
    }

    /// Pop from `cb` value corresponding to key `k`, aborting if `cb`
    /// is empty or does not contain `k`
    public fun pop<V>(
        cb: &mut CB<V>,
        k: u128
    ): V {
        assert!(!is_empty(cb), E_POP_EMPTY); // Assert tree not empty
        let l = length(cb); // Get number of outer nodes in tree
        // Depending on length, pop from singleton or for general case
        if (l == 1) pop_singleton(cb, k) else pop_general(cb, k, l)
    }

    /// Return the value corresponding to key `k` in singleton tree `cb`
    /// and destroy the outer node where it was stored, aborting if `k`
    /// not in `cb`
    fun pop_singleton<V>(
        cb: &mut CB<V>,
        k: u128
    ): V {
        // Assert key actually in tree at root node
        assert!(v_b<O<V>>(&cb.o, 0).k == k, E_NOT_HAS_K);
        cb.r = 0; // Update root
        // Pop off and unpack outer node at root
        let O{k: _, v, p: _} = v_po_b<O<V>>(&mut cb.o);
        v // Return popped value
    }

    /// Return a tree with one node having key `k` and value `v`
    public fun singleton<V>(
        k: u128,
        v: V
    ):
    CB<V> {
        let cb = CB{r: 0, i: v_e<I>(), o: v_e<O<V>>()};
        insert_empty<V>(&mut cb, k, v);
        cb
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Walk non-empty tree `cb`, breaking out if at outer node,
    /// branching left or right at each inner node depending on whether
    /// `k` is unset or set, respectively, at the given critical bit.
    /// Then return mutable reference to search outer node (`b_c_o`
    /// indicates borrow search outer)
    fun b_s_o<V>(
        cb: &CB<V>,
        k: u128,
    ): &O<V> {
        // If root is an outer node, return reference to it
        if (is_out(cb.r)) return (v_b<O<V>>(&cb.o, o_v(cb.r)));
        // Otherwise borrow inner node at root
        let n = v_b<I>(&cb.i, cb.r);
        loop { // Loop over inner nodes
            // If key is set at critical bit, get index of child on R
            let i_c = if (is_set(k, n.c)) n.r else n.l; // Otherwise L
            // If child is outer node, return reference to it
            if (is_out(i_c)) return v_b<O<V>>(&cb.o, o_v(i_c));
            n = v_b<I>(&cb.i, i_c); // Borrow next inner node to review
        }
    }

    /// Like `b_s_o()`, but for mutable reference
    fun b_s_o_m<V>(
        cb: &mut CB<V>,
        k: u128,
    ): &mut O<V> {
        // If root is an outer node, return mutable reference to it
        if (is_out(cb.r)) return (v_b_m<O<V>>(&mut cb.o, o_v(cb.r)));
        // Otherwise borrow inner node at root
        let n = v_b<I>(&cb.i, cb.r);
        loop { // Loop over inner nodes
            // If key is set at critical bit, get index of child on R
            let i_c = if (is_set(k, n.c)) n.r else n.l; // Otherwise L
            // If child is outer node, return mutable reference to it
            if (is_out(i_c)) return v_b_m<O<V>>(&mut cb.o, o_v(i_c));
            n = v_b<I>(&cb.i, i_c); // Borrow next inner node to review
        }
    }

    /// Assert that `l` is less than the value indicated by a bitmask
    /// where only the 63rd bit is not set (this bitmask corresponds to
    /// the maximum number of keys that can be stored in a tree, since
    /// the 63rd bit is reserved for the node type bit flag)
    fun check_len(l: u64) {assert!(l < HI_64 ^ OUT << N_TYPE, E_INSERT_FULL);}

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
    /// point, [Langley 2012](#@References_1) notes that `x` bitwise AND
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
    /// proposed by [Langley 2012](#@References_1) to $O(log_2(k))$, and
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

    /// Return true if `cb` has key `k`
    fun has_key<V>(
        cb: &CB<V>,
        k: u128,
    ): bool {
        if (is_empty<V>(cb)) return false; // Return false if empty
        // Return true if search outer node has same key
        return b_s_o<V>(cb, k).k == k
    }

    /// Decomposed case specified in `insert_general`, walk up tree, for
    /// parameters:
    /// * `cb`: Tree to insert into
    /// * `k` : Key to insert
    /// * `v` : Value to insert
    /// * `n_o` : Number of keys (outer nodes) in `cb` pre-insert
    /// * `i_n_i` : Number of inner nodes in `cb` pre-insert (index of
    ///   new inner node)
    /// * `i_s_p`: Index of search parent
    /// * `c`: Critical bit between insertion key and search outer node
    fun insert_above<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V,
        n_o: u64,
        i_n_i: u64,
        i_s_p: u64,
        c: u8
    ) {
        // Set index of node under review to search parent's parent
        let i_n_r = v_b<I>(&cb.i, i_s_p).p;
        loop { // Loop over inner nodes
            if (i_n_r == ROOT) { // If walk arrives at root
                // Insert above root
                return insert_above_root(cb, k, v, n_o, i_n_i, c)
            } else { // If walk has not arrived at root
                // Borrow mutable reference to node under review
                let n_r = v_b_m<I>(&mut cb.i, i_n_r);
                // If critical bit between insertion key and search
                // outer node is less than that of node under review
                if (c < n_r.c) { // If need to insert below
                    // Insert below node under review
                    return insert_below_walk(cb, k, v, n_o, i_n_i, i_n_r, c)
                } else { // If need to insert above
                    i_n_r = n_r.p; // Review node under review's parent
                }
            }
        }
    }

    /// Decomposed case specified in `insert_general`, insertion above
    /// root, for parameters:
    /// * `cb`: Tree to insert into
    /// * `k` : Key to insert
    /// * `v` : Value to insert
    /// * `n_o` : Number of keys (outer nodes) in `cb` pre-insert
    /// * `i_n_i` : Number of inner nodes in `cb` pre-insert (index of
    ///   new inner node)
    /// * `c`: Critical bit between insertion key and search outer node
    fun insert_above_root<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V,
        n_o: u64,
        i_n_i: u64,
        c: u8
    ) {
        let i_o_r = cb.r; // Get index of old root to insert above
        // Set old root node to have new inner node as parent
        v_b_m<I>(&mut cb.i, i_o_r).p = i_n_i;
        // Set root field index to indicate new inner node
        cb.r = i_n_i;
        // Push back new inner and outer nodes, with inner node
        // indicating that it is root. If insertion key is set at
        // critical bit, new inner node should have as its left child
        // the previous root node and should have as its right child
        // the new outer node
        push_back_insert_nodes(
            cb, k, v, i_n_i, c, ROOT, is_set(k, c), i_o_r, o_c(n_o)
        );
    }

    /// Decomposed case specified in `insert_general`, insertion below
    /// search parent, for parameters:
    /// * `cb`: Tree to insert into
    /// * `k` : Key to insert
    /// * `v` : Value to insert
    /// * `n_o` : Number of keys (outer nodes) in `cb` pre-insert
    /// * `i_n_i` : Number of inner nodes in `cb` pre-insert (index of
    ///   new inner node)
    /// * `i_s_o`: Field index of search outer node (with bit flag)
    /// * `s_s_o`: Side on which search outer node is child
    /// * `k_s_o`: Key of search outer node
    /// * `i_s_p`: Index of search parent
    /// * `c`: Critical bit between insertion key and search outer node
    fun insert_below<V>(
        cb: &mut CB<V>,
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
        // Borrow mutable reference to search parent
        let s_p = v_b_m<I>(&mut cb.i, i_s_p);
        // Update search parent to have new inner node as child, on same
        // side that the search outer node was a child at
        if (s_s_o == L) s_p.l = i_n_i else s_p.r = i_n_i;
        // Set search outer node to have new inner node as parent
        v_b_m<O<V>>(&mut cb.o, o_v(i_s_o)).p = i_n_i;
        // Push back new inner and outer nodes, with inner node having
        // as its parent the search parent. If insertion key is less
        // than key of search outer node, new inner node should have as
        // its left child the new outer node and should have as its
        // right child the search outer node
        push_back_insert_nodes(
            cb, k, v, i_n_i, c, i_s_p, k < k_s_o, o_c(n_o), i_s_o
        );
    }

    /// Decomposed case specified in `insert_general`, insertion below
    /// a node encountered during walk, for parameters:
    /// * `cb`: Tree to insert into
    /// * `k` : Key to insert
    /// * `v` : Value to insert
    /// * `n_o` : Number of keys (outer nodes) in `cb` pre-insert
    /// * `i_n_i` : Number of inner nodes in `cb` pre-insert (index of
    ///   new inner node)
    /// * `i_n_r` : Index of node under review from walk
    /// * `c`: Critical bit between insertion key and search outer node
    fun insert_below_walk<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V,
        n_o: u64,
        i_n_i: u64,
        i_n_r: u64,
        c: u8
    ) {
        // Borrow mutable reference to node under review
        let n_r = v_b_m<I>(&mut cb.i, i_n_r);
        // If insertion key is set at critical bit indicated by node
        // under review, mark side and index of walked child as its
        // right child, else left
        let (s_w_c, i_w_c) = if (is_set(k, n_r.c)) (R, n_r.r) else (L, n_r.l);
        // Set node under review to have as child new inner node on same
        // side as walked child
        if (s_w_c == L) n_r.l = i_n_i else n_r.r = i_n_i;
        // Update walked child to have new inner node as its parent
        v_b_m<I>(&mut cb.i, i_w_c).p = i_n_i;
        // Push back new inner and outer nodes, with inner node having
        // as its parent the node under review. If insertion key is set
        // at critical bit, new inner node should have as its left child
        // the walked child of the node under review and should have as
        // its right child the new outer node
        push_back_insert_nodes(
            cb, k, v, i_n_i, c, i_n_r, is_set(k, c), i_w_c, o_c(n_o)
        );
    }

    /// Insert key-value pair `k` and `v` into an empty `cb`
    fun insert_empty<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V
    ) {
        // Push back outer node onto tree's vector of outer nodes
        v_pu_b<O<V>>(&mut cb.o, O<V>{k, v, p: ROOT});
        // Set root index field to indicate 0th outer node
        cb.r = OUT << N_TYPE;
    }

    /// Insert key `k` and value `v` into tree `cb` already having `n_o`
    /// keys for general case where root is an inner node, aborting if
    /// `k` is already present. First, perform an outer node search and
    /// identify the critical bit of divergence between the search outer
    /// node and `k`. Then, if the critical bit is less than that of the
    /// search parent (`insert_below()`):
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
    /// >           101   111 <- search outer node
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
        cb: &mut CB<V>,
        k: u128,
        v: V,
        n_o: u64
    ) {
        // Get number of inner nodes in tree (index of new inner node)
        let i_n_i = v_l<I>(&cb.i);
        // Get field index of search outer node, its side as a child,
        // its key, the vector index of its parent, and the critical
        // bit indicated by the search parent
        let (i_s_o, s_s_o, k_s_o, i_s_p, s_p_c) = search_outer(cb, k);
        assert!(k_s_o != k, E_HAS_K); // Assert key not a duplicate
        // Get critical bit between insertion key and search outer node
        let c = crit_bit(k_s_o, k);
        // If critical bit is less than that indicated by search parent
        if (c < s_p_c) {
            // Insert new inner node below search parent
            insert_below(cb, k, v, n_o, i_n_i, i_s_o, s_s_o, k_s_o, i_s_p, c);
        } else { // If need to insert new inner node above search parent
            insert_above(cb, k, v, n_o, i_n_i, i_s_p, c);
        }
    }

    /// Insert key `k` and value `v` into singleton tree `cb`, aborting
    /// if `k` already in `cb`
    fun insert_singleton<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V
    ) {
        let n = v_b<O<V>>(&cb.o, 0); // Borrow existing outer node
        assert!(k != n.k, E_HAS_K); // Assert insertion key not in tree
        let c = crit_bit(n.k, k); // Get critical bit between two keys
        // Push back new inner and outer nodes, with inner node
        // indicating that it is root. If insertion key is greater than
        // singleton key, new inner node should have as its left child
        // existing outer node and should have as its right child new
        // outer node
        push_back_insert_nodes(cb, k, v, 0, c, ROOT, k > n.k, o_c(0), o_c(1));
        cb.r = 0; // Update tree root field to indicate new inner node
        // Update existing outer node to have new inner node as parent
        v_b_m<O<V>>(&mut cb.o, 0).p = 0;
    }

    /// Return `true` if vector index `i` indicates an outer node
    fun is_out(i: u64): bool {(i >> N_TYPE & OUT == OUT)}

    /// Return `true` if `k` is set at bit `b`
    fun is_set(k: u128, b: u8): bool {k >> b & 1 == 1}

    /// Convert unflagged outer node vector index `v` to flagged child
    /// node index, by OR with a bitmask that has only flag bit set
    fun o_c(v: u64): u64 {v | OUT << N_TYPE}

    /// Convert flagged child node index `c` to unflagged outer node
    /// vector index, by AND with a bitmask that has only flag bit unset
    fun o_v(c: u64): u64 {c & HI_64 ^ OUT << N_TYPE}

    /// Remove from `cb` inner node at child field index `i_i`, and
    /// outer node at child field index `i_o` (from node vector with
    /// `n_o` outer nodes pre-pop). Then return the popped value from
    /// the outer node
    fun pop_destroy_nodes<V>(
        cb: &mut CB<V>,
        i_i: u64,
        i_o: u64,
        n_o: u64
    ): V {
        let n_i = v_l<I>(&cb.i); // Get number of inner nodes pre-pop
        // Swap remove parent of popped outer node, storing no fields
        let I{c: _, p: _, l: _, r: _} = v_s_r<I>(&mut cb.i, i_i);
        // If destroyed inner node was not last inner node in vector,
        // repair the parent-child relationship broken by swap remove
        if (i_i < n_i - 1) stitch_swap_remove(cb, i_i, n_i);
        // Swap remove popped outer node, storing only its value
        let O{k: _, v, p: _} = v_s_r<O<V>>(&mut cb.o, o_v(i_o));
        // If destroyed outer node was not last outer node in vector,
        // repair the parent-child relationship broken by swap remove
        if (o_v(i_o) < n_o - 1) stitch_swap_remove(cb, i_o, n_o);
        v // Return popped value
    }

    /// Return the value corresponding to key `k` in tree `cb` having
    /// `n_o` keys and destroy the outer node where it was stored, for
    /// the general case of a tree with more than one outer node. Abort
    /// if `k` not in `cb`. Here, the parent of the popped node must be
    /// removed, and if the popped node has a grandparent, the
    /// grandparent of the popped node must be updated to have as its
    /// child the popped node's sibling at the same position where the
    /// popped node's parent previously was, whether the sibling is an
    /// outer or inner node. Likewise the sibling must be updated to
    /// have as its parent the grandparent to the popped node. Outer
    /// node sibling case:
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
        cb: &mut CB<V>,
        k: u128,
        n_o: u64
    ): V {
        // Get field index of search outer node, its side as a child,
        // its key, and the vector index of its parent
        let (i_s_o, s_s_o, k_s_o, i_s_p, _) = search_outer(cb, k);
        assert!(k_s_o == k, E_NOT_HAS_K); // Assert key in tree
        // Update sibling, parent, grandparent relationships
        pop_update_relationships(cb, s_s_o, i_s_p);
        // Destroy old nodes, returning popped value
        pop_destroy_nodes(cb, i_s_p, i_s_o, n_o)
    }

    /// Update relationships in `cb` for popping a node which is a child
    /// on side `s_c` (`L` or `R`), to parent node at index `i_p`, per
    /// `pop_general()`
    fun pop_update_relationships<V>(
        cb: &mut CB<V>,
        s_c: bool,
        i_p: u64,
    ) {
        // Borrow immutable reference to popped node's parent
        let p = v_b<I>(&cb.i, i_p);
        // If popped outer node was a left child, store the right child
        // field index of its parent as the child field index of the
        // popped node's sibling. Else flip the direction
        let i_s = if (s_c == L) p.r else p.l;
        // Get parent field index of popped node's parent
        let i_p_p = p.p;
        // Update popped node's sibling to have at its parent index
        // field the same as that of the popped node's parent, whether
        // the sibling is an inner or outer node
        if (is_out(i_s)) v_b_m<O<V>>(&mut cb.o, o_v(i_s)).p = i_p_p
            else v_b_m<I>(&mut cb.i, i_s).p = i_p_p;
        if (i_p_p == ROOT) { // If popped node's parent is root
            // Set root field index to child field index of popped
            // node's sibling
            cb.r = i_s;
        } else { // If popped node has a grandparent
            // Borrow mutable reference to popped node's grandparent
            let g_p = v_b_m<I>(&mut cb.i, i_p_p);
            // If popped node's parent was a left child, update popped
            // node's grandparent to have as its child the popped node's
            // sibling. Else the right child
            if (g_p.l == i_p) g_p.l = i_s else g_p.r = i_s;
        };
    }

    /// Push back a new inner node and outer node into tree `cb`, where
    /// the new outer node should have key `k`, value `v`, and have as
    /// its parent the new inner node at vector index `i_n_i`, which
    /// should have critical bit `c`, parent field index `i_p`, and if
    /// `i_n_c_c` is `true`, left child field index `c1` and right child
    /// field index `c2`. If the "inner node child condition" is `false`
    /// the polarity of the children should be flipped
    fun push_back_insert_nodes<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V,
        i_n_i: u64,
        c: u8,
        i_p: u64,
        i_n_c_c: bool,
        c1: u64,
        c2: u64,
    ) {
        // If inner node child condition marked true, declare left child
        // field for new inner node as c1 and right as c2, else flip
        let (l, r) = if (i_n_c_c) (c1, c2) else (c2, c1);
        // Push back new outer node with new inner node as parent
        v_pu_b<O<V>>(&mut cb.o, O{k, v, p: i_n_i});
        // Push back new inner node with specified parent and children
        v_pu_b<I>(&mut cb.i, I{c, p: i_p, l, r});
    }

    /// Walk from root tree `cb` having an inner node as its root,
    /// branching left or right at each inner node depending on whether
    /// `k` is unset or set, respectively, at the given critical bit.
    /// After arriving at an outer node, then return:
    /// * `u64`: index of search outer node (with node type bit flag)
    /// * `bool`: the side, `L` or `R`, on which the search outer node
    ///    is a child of its parent
    /// * `u128`: key of search outer node
    /// * `u64`: vector index of parent of search outer node
    /// * `u8`: critical bit indicated by parent of search outer node
    fun search_outer<V>(
        cb: &CB<V>,
        k: u128
    ): (
        u64,
        bool,
        u128,
        u64,
        u8,
    ) {
        // Initialize search parent to root
        let s_p = v_b<I>(&cb.i, cb.r);
        loop { // Loop over inner nodes until branching to outer node
            // If key set at critical bit, track field index and side of
            // R child, else L
            let (i, s) = if (is_set(k, s_p.c)) (s_p.r, R) else (s_p.l, L);
            if (is_out(i)) { // If child is outer node
                // Borrow immutable reference to it
                let s_o = v_b<O<V>>(&cb.o, o_v(i));
                // Return child field index of search outer node, its
                // side as a child, its key, the vector index of its
                // parent, and parent's indicated critical bit
                return (i, s, s_o.k, s_o.p, s_p.c)
            };
            s_p = v_b<I>(&cb.i, i); // Search next inner node
        }
    }

    /// Update parent node at index `i_p` in `cb` to reflect as its
    /// child a node that has been relocated from old child field index
    /// `i_o` to new child field index `i_n`
    fun stitch_child_of_parent<V>(
        cb: &mut CB<V>,
        i_n: u64,
        i_p: u64,
        i_o: u64
    ) {
        // Borrow mutable reference to parent
        let p = v_b_m<I>(&mut cb.i, i_p);
        // If relocated node was previously left child, update
        // parent's left child to indicate the relocated node's new
        // position, otherwise do update for right child of parent
        if (p.l == i_o) p.l = i_n else p.r = i_n;
    }

    /// Update child node at child field index `i_c` in `cb` to reflect
    /// as its parent an inner node that has be relocated to child field
    /// index `i_n`
    fun stitch_parent_of_child<V>(
        cb: &mut CB<V>,
        i_n: u64,
        i_c: u64
    ) {
        // If child is an outer node, borrow corresponding node and
        // update its parent field index to that of relocated node
        if (is_out(i_c)) v_b_m<O<V>>(&mut cb.o, o_v(i_c)).p = i_n
            // Otherwise perform update on an inner node
            else v_b_m<I>(&mut cb.i, i_c).p = i_n;
    }

    /// Repair a broken parent-child relationship in `cb` caused by
    /// swap removing, for relocated node now at index indicated by
    /// child field index `i_n`, in vector that contained `n_n` nodes
    /// before the swap remove (when relocated node was last in vector)
    fun stitch_swap_remove<V>(
        cb: &mut CB<V>,
        i_n: u64,
        n_n: u64
    ) {
        // If child field index indicates relocated outer node
        if (is_out(i_n)) {
            // Get node's parent field index
            let i_p = v_b<O<V>>(&cb.o, o_v(i_n)).p;
            // If root node was relocated, update root field and return
            if (i_p == ROOT) {cb.r = i_n; return};
            // Else update parent to reflect relocated node position
            stitch_child_of_parent<V>(cb, i_n, i_p, o_c(n_n - 1));
        } else { // If child field index indicates relocated inner node
            // Borrow mutable reference to it
            let n = v_b<I>(&cb.i, i_n);
            // Get field index of node's parent and children
            let (i_p, i_l, i_r) = (n.p, n.l, n.r);
            // Update children to have relocated node as their parent
            stitch_parent_of_child(cb, i_n, i_l); // Left child
            stitch_parent_of_child(cb, i_n, i_r); // Right child
            // If root node relocated, update root field and return
            if (i_p == ROOT) {cb.r = i_n; return};
            // Else update parent to reflect relocated node position
            stitch_child_of_parent<V>(cb, i_n, i_p, n_n - 1);
        }
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
    fun u(
        s: vector<u8>
    ): u128 {
        let n = v_l<u8>(&s); // Get number of bits
        let r = 0; // Initialize result to 0
        let i = 0; // Start loop at least significant bit
        while (i < n) { // While there are bits left to review
            let b = *v_b<u8>(&s, n - 1 - i); // Get bit under review
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
    fun u_long(
        a: vector<u8>,
        b: vector<u8>,
        c: vector<u8>
    ): u128 {
        v_a<u8>(&mut b, c); // Append c onto b
        v_a<u8>(&mut a, b); // Append b onto a
        u(a) // Return u128 equivalent of concatenated bytestring
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify successful bitmask generation
    fun b_lo_success() {
        assert!(b_lo(0) == HI_128 - 1, 0);
        assert!(b_lo(1) == HI_128 - 2, 1);
        assert!(b_lo(127) == 0x7fffffffffffffffffffffffffffffff, 2);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun borrow_empty() {
        let cb = empty<u8>(); // Initialize empty tree
        borrow<u8>(&cb, 0); // Attempt invalid borrow
        destroy_empty(cb); // Destroy empty tree
    }

/*
    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun borrow_max_node_failure() {
        let cb = empty<u8>(); // Initialize empty tree
        borrow_max_node(&cb); // Attempt invalid borrow
        destroy_empty(cb); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun borrow_max_node_mut_failure() {
        let cb = empty<u8>(); // Initialize empty tree
        borrow_max_node_mut(&mut cb); // Attempt invalid borrow
        destroy_empty(cb); // Destroy empty tree
    }

    #[test]
    /// Verify correct maximum key node borrow
    fun borrow_max_node_mut_success():
    CB<u8> {
        let cb = singleton(3, 5); // Initialize singleton
        // Borrow node with max key
        let n = borrow_max_node_mut(&mut cb);
        // Assert correct key-value pair
        assert!(n.k == 3 && n.v == 5, 0);
        // Insert additional values
        insert(&mut cb, 2, 7);
        insert(&mut cb, 5, 8);
        insert(&mut cb, 4, 6);
        // Borrow node with max key
        let n = borrow_max_node_mut(&mut cb);
        // Assert correct key-value pair
        assert!(n.k == 5 && n.v == 8, 1);
        cb // Return rather than unpack
    }

    #[test]
    /// Verify correct maximum key node borrow
    fun borrow_max_node_success():
    CB<u8> {
        let cb = singleton(3, 5); // Initialize singleton
        let n = borrow_max_node(&cb); // Borrow node with max key
        // Assert correct key-value pair
        assert!(n.k == 3 && n.v == 5, 0);
        // Insert additional values
        insert(&mut cb, 2, 7);
        insert(&mut cb, 5, 8);
        insert(&mut cb, 4, 6);
        let n = borrow_max_node(&cb); // Borrow node with max key
        // Assert correct key-value pair
        assert!(n.k == 5 && n.v == 8, 1);
        cb // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun borrow_min_node_failure() {
        let cb = empty<u8>(); // Initialize empty tree
        borrow_min_node(&cb); // Attempt invalid borrow
        destroy_empty(cb); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun borrow_min_node_mut_failure() {
        let cb = empty<u8>(); // Initialize empty tree
        borrow_min_node_mut(&mut cb); // Attempt invalid borrow
        destroy_empty(cb); // Destroy empty tree
    }

    #[test]
    /// Verify correct maximum key node borrow
    fun borrow_min_node_mut_success():
    CB<u8> {
        let cb = singleton(3, 5); // Initialize singleton
        // Borrow node with min key
        let n = borrow_min_node_mut(&mut cb);
        // Assert correct key-value pair
        assert!(n.k == 3 && n.v == 5, 0);
        // Insert additional values
        insert(&mut cb, 2, 7);
        insert(&mut cb, 5, 8);
        insert(&mut cb, 4, 6);
        // Borrow node with min key
        let n = borrow_min_node_mut(&mut cb);
        // Assert correct key-value pair
        assert!(n.k == 2 && n.v == 7, 1);
        cb // Return rather than unpack
    }

    #[test]
    /// Verify correct minimum key node borrow
    fun borrow_min_node_success():
    CB<u8> {
        let cb = singleton(3, 5); // Initialize singleton
        let n = borrow_min_node(&cb); // Borrow node with min key
        // Assert correct key-value pair
        assert!(n.k == 3 && n.v == 5, 0);
        // Insert additional values
        insert(&mut cb, 2, 7);
        insert(&mut cb, 5, 8);
        insert(&mut cb, 1, 6);
        let n = borrow_min_node(&cb); // Borrow node with min key
        // Assert correct key-value pair
        assert!(n.k == 1 && n.v == 6, 1);
        cb // Return rather than unpack
    }
*/

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    fun borrow_mut_empty() {
        let cb = empty<u8>(); // Initialize empty tree
        borrow_mut<u8>(&mut cb, 0); // Attempt invalid borrow
        destroy_empty(cb); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Assert failure for attempted borrow without matching key
    fun borrow_mut_no_match():
    CB<u8> {
        let cb = singleton<u8>(3, 4); // Initialize singleton
        borrow_mut<u8>(&mut cb, 6); // Attempt invalid borrow
        cb // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    /// Assert correct modification of values
    fun borrow_mut_success():
    CB<u8> {
        let cb = empty<u8>(); // Initialize empty tree
        // Insert assorted key-value pairs
        insert(&mut cb, 2, 6);
        insert(&mut cb, 3, 8);
        insert(&mut cb, 1, 9);
        insert(&mut cb, 7, 5);
        // Modify some of the values
        *borrow_mut<u8>(&mut cb, 1) = 2;
        *borrow_mut<u8>(&mut cb, 2) = 4;
        // Assert values are as expected
        assert!(*borrow<u8>(&mut cb, 2) == 4, 0); // Changed
        assert!(*borrow<u8>(&mut cb, 3) == 8, 0); // Unchanged
        assert!(*borrow<u8>(&mut cb, 1) == 2, 0); // Changed
        assert!(*borrow<u8>(&mut cb, 7) == 5, 0); // Unchanged
        cb // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Assert failure for attempted borrow without matching key
    fun borrow_no_match():
    CB<u8> {
        let cb = singleton<u8>(3, 4); // Initialize singleton
        borrow<u8>(&cb, 6); // Attempt invalid borrow
        cb // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify length check fails for too many elements
    fun check_len_failure() {
        check_len(HI_64 ^ OUT << N_TYPE); // Tree is full
    }

    #[test]
    /// Verify length check passes for valid sizes
    fun check_len_success() {
        check_len(0);
        check_len(1200);
        // Maximum number of keys that can be in tree pre-insert
        check_len((HI_64 ^ OUT << N_TYPE) - 1);
    }

    #[test]
    /// Verify successful determination of critical bit at all positions
    fun crit_bit_success() {
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
    fun destroy_empty_fail() {
        // Attempt destroying singleton
        destroy_empty<u8>(singleton<u8>(0, 0));
    }

    #[test]
    /// Verify empty tree destruction
    fun destroy_empty_success() {
        let cb = empty<u8>(); // Initialize empty tree
        destroy_empty<u8>(cb); // Destroy it
    }

    #[test]
    /// Verify new tree created empty
    fun empty_success():
    (
        vector<I>,
        vector<O<u8>>
    ) {
        // Unpack root index and node vectors
        let CB{r, i, o} = empty<u8>();
        assert!(v_i_e<I>(&i), 0); // Assert empty inner node vector
        assert!(v_i_e<O<u8>>(&o), 1); // Assert empty outer node vector
        assert!(r == 0, 0); // Assert root set to 0
        (i, o) // Return rather than unpack
    }

    #[test]
    /// Verify returns `false` for empty tree
    fun has_key_empty_success() {
        let cb = empty<u8>(); // Initialize empty tree
        assert!(!has_key(&cb, 0), 0); // Assert key check returns false
        destroy_empty<u8>(cb); // Drop empty tree
    }

    #[test]
    /// Verify successful key checks in special case of singleton tree
    fun has_key_singleton():
    CB<u8> {
        // Create singleton with key 1 and value 2
        let cb = singleton<u8>(1, 2);
        assert!(has_key(&cb, 1), 0); // Assert key of 1 registered
        assert!(!has_key(&cb, 3), 0); // Assert key of 3 not registered
        cb // Return rather than unpack
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
    fun has_key_success():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree
        v_pu_b<I>(&mut cb.i, I{c: 2, p: ROOT, l: o_c(0), r:     1 });
        v_pu_b<I>(&mut cb.i, I{c: 1, p:    0, l: o_c(1), r:     2 });
        v_pu_b<I>(&mut cb.i, I{c: 0, p:    1, l: o_c(2), r: o_c(3)});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v, p: 0});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"101"), v, p: 1});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"110"), v, p: 2});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"111"), v, p: 2});
        // Assert correct membership checks
        assert!(has_key(&cb, u(b"001")), 0);
        assert!(has_key(&cb, u(b"101")), 1);
        assert!(has_key(&cb, u(b"110")), 2);
        assert!(has_key(&cb, u(b"111")), 3);
        assert!(!has_key(&cb, u(b"011")), 4); // Not in tree
        cb // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify aborts when key already in tree
    fun insert_general_failure():
    CB<u8> {
        let cb = singleton<u8>(3, 4); // Initialize singleton
        insert_singleton(&mut cb, 5, 6); // Insert onto singleton
        // Attempt insert for general case, but with duplicate key
        insert_general(&mut cb, 5, 7, 2);
        cb // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempting duplicate insertion on singleton
    fun insert_singleton_failure():
    CB<u8> {
        let cb = singleton<u8>(1, 2); // Initialize singleton
        insert_singleton(&mut cb, 1, 5); // Attempt to insert same key
        cb // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    /// Verify proper insertion result for insertion to left:
    /// ```
    /// >      1111     Insert         1st
    /// >                1101         /   \
    /// >               ----->    1101     1111
    /// ```
    fun insert_singleton_success_l():
    (
        CB<u8>
    ) {
        let cb = singleton<u8>(u(b"1111"), 4); // Initialize singleton
        insert_singleton(&mut cb, u(b"1101"), 5); // Insert to left
        assert!(cb.r == 0, 0); // Assert root is at new inner node
        let i = v_b<I>(&cb.i, 0); // Borrow inner node at root
        // Assert root inner node values are as expected
        assert!(i.c == 1 && i.p == ROOT && i.l == o_c(1) && i.r == o_c(0), 1);
        let o_o = v_b<O<u8>>(&cb.o, 0); // Borrow original outer node
        // Assert original outer node values are as expected
        assert!(o_o.k == u(b"1111") && o_o.v == 4 && o_o.p == 0, 2);
        let n_o = v_b<O<u8>>(&cb.o, 1); // Borrow new outer node
        // Assert new outer node values are as expected
        assert!(n_o.k == u(b"1101") && n_o.v == 5 && n_o.p == 0, 3);
        cb // Return rather than unpack
    }

    #[test]
    /// Verify proper insertion result for insertion to right:
    /// ```
    /// >      1011     Insert         2nd
    /// >                1111         /   \
    /// >               ----->    1011     1111
    /// ```
    fun insert_singleton_success_r():
    CB<u8> {
        let cb = singleton<u8>(u(b"1011"), 6); // Initialize singleton
        insert_singleton(&mut cb, u(b"1111"), 7); // Insert to right
        assert!(cb.r == 0, 0); // Assert root is at new inner node
        let i = v_b<I>(&cb.i, 0); // Borrow inner node at root
        // Assert root inner node values are as expected
        assert!(i.c == 2 && i.p == ROOT && i.l == o_c(0) && i.r == o_c(1), 1);
        let o_o = v_b<O<u8>>(&cb.o, 0); // Borrow original outer node
        // Assert original outer node values are as expected
        assert!(o_o.k == u(b"1011") && o_o.v == 6 && o_o.p == 0, 2);
        let n_o = v_b<O<u8>>(&cb.o, 1); // Borrow new outer node
        // Assert new outer node values are as expected
        assert!(n_o.k == u(b"1111") && n_o.v == 7 && o_o.p == 0, 3);
        cb // Return rather than unpack
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
    fun insert_success_1():
    CB<u8> {
        let cb = empty(); // Initialize empty tree
        // Insert various key-value pairs
        insert(&mut cb, u(b"1101"), 0);
        insert(&mut cb, u(b"1000"), 1);
        insert(&mut cb, u(b"1100"), 2);
        insert(&mut cb, u(b"1110"), 3);
        insert(&mut cb, u(b"0000"), 4);
        // Verify root field indicates correct inner node
        assert!(cb.r == 3, 0);
        // Verify inner node fields in ascending order of vector index
        let i = v_b<I>(&cb.i, 0);
        assert!(i.c == 2 && i.p ==    3 && i.l == o_c(1) && i.r ==     2 , 1);
        let i = v_b<I>(&cb.i, 1);
        assert!(i.c == 0 && i.p ==    2 && i.l == o_c(2) && i.r == o_c(0), 2);
        let i = v_b<I>(&cb.i, 2);
        assert!(i.c == 1 && i.p ==    0 && i.l ==     1  && i.r == o_c(3), 3);
        let i = v_b<I>(&cb.i, 3);
        assert!(i.c == 3 && i.p == ROOT && i.l == o_c(4) && i.r ==     0 , 4);
        // Verify outer node fields in ascending order of vector index
        let o = v_b<O<u8>>(&cb.o, 0);
        assert!(o.k == u(b"1101") && o.v == 0 && o.p == 1, 5);
        let o = v_b<O<u8>>(&cb.o, 1);
        assert!(o.k == u(b"1000") && o.v == 1 && o.p == 0, 6);
        let o = v_b<O<u8>>(&cb.o, 2);
        assert!(o.k == u(b"1100") && o.v == 2 && o.p == 1, 7);
        let o = v_b<O<u8>>(&cb.o, 3);
        assert!(o.k == u(b"1110") && o.v == 3 && o.p == 2, 8);
        let o = v_b<O<u8>>(&cb.o, 4);
        assert!(o.k == u(b"0000") && o.v == 4 && o.p == 3, 9);
        cb // Return rather than unpack
    }

    #[test]
    /// Variation on `insert_success_1()`:
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
    fun insert_success_2():
    CB<u8> {
        let cb = empty(); // Initialize empty tree
        // Insert various key-value pairs
        insert(&mut cb, u(b"0101"), 0);
        insert(&mut cb, u(b"0000"), 1);
        insert(&mut cb, u(b"0001"), 2);
        insert(&mut cb, u(b"1000"), 3);
        insert(&mut cb, u(b"0011"), 4);
        // Verify root field indicates correct inner node
        assert!(cb.r == 2, 0);
        // Verify inner node fields in ascending order of vector index
        let i = v_b<I>(&cb.i, 0);
        assert!(i.c == 2 && i.p ==    2 && i.l ==     3  && i.r == o_c(0), 1);
        let i = v_b<I>(&cb.i, 1);
        assert!(i.c == 0 && i.p ==    3 && i.l == o_c(1) && i.r == o_c(2), 2);
        let i = v_b<I>(&cb.i, 2);
        assert!(i.c == 3 && i.p == ROOT && i.l ==     0  && i.r == o_c(3), 3);
        let i = v_b<I>(&cb.i, 3);
        assert!(i.c == 1 && i.p ==    0 && i.l ==     1  && i.r == o_c(4), 4);
        // Verify outer node fields in ascending order of vector index
        let o = v_b<O<u8>>(&cb.o, 0);
        assert!(o.k == u(b"0101") && o.v == 0 && o.p == 0, 5);
        let o = v_b<O<u8>>(&cb.o, 1);
        assert!(o.k == u(b"0000") && o.v == 1 && o.p == 1, 6);
        let o = v_b<O<u8>>(&cb.o, 2);
        assert!(o.k == u(b"0001") && o.v == 2 && o.p == 1, 7);
        let o = v_b<O<u8>>(&cb.o, 3);
        assert!(o.k == u(b"1000") && o.v == 3 && o.p == 2, 8);
        let o = v_b<O<u8>>(&cb.o, 4);
        assert!(o.k == u(b"0011") && o.v == 4 && o.p == 3, 9);
        cb // Return rather than unpack
    }

    #[test]
    /// Verify emptiness check validity
    fun is_empty_success():
    CB<u8> {
        let cb = empty<u8>(); // Get empty tree
        assert!(is_empty<u8>(&cb), 0); // Assert is empty
        insert_empty<u8>(&mut cb, 1, 2); // Insert key 1 and value 2
        // Assert not marked empty
        assert!(!is_empty<u8>(&cb), 0);
        cb // Return rather than unpack
    }

    #[test]
    /// Verify correct returns
    fun is_out_success() {
        assert!(is_out(OUT << N_TYPE), 0);
        assert!(!is_out(0), 1);
    }

    #[test]
    /// Verify correct returns
    fun is_set_success() {
        assert!(is_set(u(b"11"), 0) && is_set(u(b"11"), 1), 0);
        assert!(!is_set(u(b"10"), 0) && !is_set(u(b"01"), 1), 1);
    }

    #[test]
    /// Verify length check validity
    fun length_success():
    CB<u8> {
        let cb = empty(); // Initialize empty tree
        assert!(length<u8>(&cb) == 0, 0); // Assert length is 0
        insert(&mut cb, 1, 2); // Insert
        assert!(length<u8>(&cb) == 1, 1); // Assert length is 1
        insert(&mut cb, 3, 4); // Insert
        assert!(length<u8>(&cb) == 2, 2); // Assert length is 2
        cb // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify maximum key lookup failure when tree empty
    fun max_key_failure_empty() {
        let cb = empty<u8>(); // Initialize empty tree
        let _ = max_key(&cb); // Attempt invalid lookup
        destroy_empty(cb);
    }

    #[test]
    /// Verify correct maximum key lookup
    fun max_key_success():
    CB<u8> {
        let cb = singleton(3, 5); // Initialize singleton
        assert!(max_key(&cb) == 3, 0); // Assert correct lookup
        // Insert additional values
        insert(&mut cb, 2, 7);
        insert(&mut cb, 5, 8);
        insert(&mut cb, 4, 6);
        assert!(max_key(&cb) == 5, 0); // Assert correct lookup
        cb // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify minimum key lookup failure when tree empty
    fun min_key_failure_empty() {
        let cb = empty<u8>(); // Initialize empty tree
        let _ = min_key(&cb); // Attempt invalid lookup
        destroy_empty(cb);
    }

    #[test]
    /// Verify correct minimum key lookup
    fun min_key_success():
    CB<u8> {
        let cb = singleton(3, 5); // Initialize singleton
        assert!(min_key(&cb) == 3, 0); // Assert correct lookup
        // Insert additional values
        insert(&mut cb, 2, 7);
        insert(&mut cb, 5, 8);
        insert(&mut cb, 1, 6);
        assert!(min_key(&cb) == 1, 0); // Assert correct lookup
        cb // Return rather than unpack
    }

    #[test]
    /// Verify correct returns
    fun o_v_success() {
        assert!(o_v(OUT << N_TYPE) == 0, 0);
        assert!(o_v(OUT << N_TYPE | 123) == 123, 1); }

    #[test]
    /// Verify correct returns
    fun out_c_success() {
        assert!(o_c(0) == OUT << N_TYPE, 0);
        assert!(o_c(123) == OUT << N_TYPE | 123, 1);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for attempting to pop from empty tree
    fun pop_failure_empty() {
        let cb = empty<u8>(); // Initialize empty tree
        let _ = pop(&mut cb, 3); // Attempt invalid pop
        destroy_empty(cb); // Destroy empty tree
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempting to pop key not in tree
    fun pop_general_failure_no_key():
    CB<u8> {
        let cb = singleton(1, 7); // Initialize singleton
        insert(&mut cb, 2, 8); // Add a second element
        let _ = pop(&mut cb, 3); // Attempt invalid pop
        cb // Return rather than unpack (or signal to compiler as much)
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
    fun pop_general_success_1():
    CB<u8> {
        // Initialize singleton for node to be popped
        let cb = singleton(u(b"111"), 7);
        // Insert sibling, generating inner node marked 1st
        insert(&mut cb, u(b"101"), 8);
        // Insert key 001, generating new inner node marked 2nd, at root
        insert(&mut cb, u(b"001"), 9);
        // Assert correct pop value for key 111
        assert!(pop_general(&mut cb, u(b"111"), 3) == 7, 0);
        assert!(cb.r == 0, 1); // Assert root field updated
        let r = v_b<I>(&mut cb.i, 0); // Borrow inner node at root
        // Assert root inner node fields are as expected
        assert!(r.c == 2 && r.p == ROOT && r.l == o_c(0) && r.r == o_c(1), 2);
        let o_l = v_b<O<u8>>(&mut cb.o, 0); // Borrow outer node on left
        // Assert left outer node fields are as expected
        assert!(o_l.k == u(b"001") && o_l.v == 9 && o_l.p == 0, 3);
        let o_r = v_b<O<u8>>(&mut cb.o, 1); // Borrow outer node on right
        // Assert right outer node fields are as expected
        assert!(o_r.k == u(b"101") && o_r.v == 8 && o_r.p == 0, 4);
        cb // Return rather than unpack
    }

    #[test]
    /// Variation on `pop_general_success_1()`:
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
    /// >      o_i = 0 -> 0th   111 <- o_i = 2
    /// >                /   \
    /// >   o_i = 1 -> 010   011 <- o_i = 0
    /// >
    /// >       Pop 111
    /// >       ------>
    /// >
    /// >      o_i = 0 -> 0th
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
    fun pop_general_success_2() {
        // Initialize singleton tree with key-value pair {011, 5}
        let cb = singleton(u(b"011"), 5); // Initialize singleton tree
        insert(&mut cb, u(b"010"), 6); // Insert {010, 6}
        insert(&mut cb, u(b"001"), 7); // Insert {001, 7}
        insert(&mut cb, u(b"111"), 8); // Insert {001, 8}
        assert!(pop(&mut cb, u(b"001")) == 7, 0); // Assert correct pop
        assert!(cb.r == 1, 1); // Assert root field updated correctly
        // Verify post-pop inner node fields in ascending order of index
        let i = v_b<I>(&cb.i, 0);
        assert!(i.c == 0 && i.p ==    1 && i.l == o_c(1) && i.r == o_c(0), 2);
        let i = v_b<I>(&cb.i, 1);
        assert!(i.c == 2 && i.p == ROOT && i.l ==     0  && i.r == o_c(2), 3);
        // Verify outer node fields in ascending order of vector index
        let o = v_b<O<u8>>(&cb.o, 0);
        assert!(o.k == u(b"011") && o.v == 5 && o.p == 0, 4);
        let o = v_b<O<u8>>(&cb.o, 1);
        assert!(o.k == u(b"010") && o.v == 6 && o.p == 0, 5);
        let o = v_b<O<u8>>(&cb.o, 2);
        assert!(o.k == u(b"111") && o.v == 8 && o.p == 1, 6);
        assert!(pop(&mut cb, u(b"111")) == 8, 7); // Assert correct pop
        assert!(cb.r == 0, 8); // Assert root field updated correctly
        // Verify post-pop inner node fields at root
        let i = v_b<I>(&cb.i, 0);
        assert!(i.c == 0 && i.p == ROOT && i.l == o_c(1) && i.r == o_c(0), 9);
        // Verify outer node fields in ascending order of vector index
        let o = v_b<O<u8>>(&cb.o, 0);
        assert!(o.k == u(b"011") && o.v == 5 && o.p == 0, 10);
        let o = v_b<O<u8>>(&cb.o, 1);
        assert!(o.k == u(b"010") && o.v == 6 && o.p == 0, 11);
        assert!(pop(&mut cb, u(b"011")) == 5, 12); // Assert correct pop
        assert!(cb.r == o_c(0), 13); // Assert correct root field update
        // Verify post-pop outer node fields at root
        let o = v_b<O<u8>>(&cb.o, 0);
        assert!(o.k == u(b"010") && o.v == 6 && o.p == ROOT, 14);
        assert!(pop(&mut cb, u(b"010")) == 6, 15); // Assert correct pop
        assert!(cb.r == 0, 16); // Assert root field updated correctly
        assert!(is_empty(&cb), 17); // Assert is empty
        destroy_empty(cb); // Destroy
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    // Verify pop failure when key not in tree
    fun pop_singleton_failure():
    CB<u8> {
        let cb = singleton(1, 2); // Initialize singleton
        let _ = pop_singleton<u8>(&mut cb, 3); // Attempt invalid pop
        cb // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    // Verify successful pop
    fun pop_singleton_success() {
        let cb = singleton(1, 2); // Initialize singleton
        assert!(pop_singleton(&mut cb, 1) == 2, 0); // Verify pop value
        assert!(is_empty(&mut cb), 1); // Assert marked as empty
        assert!(cb.r == 0, 2); // Assert root index field updated
        destroy_empty<u8>(cb); // Destroy empty tree
    }

    #[test]
    /// Verify singleton initialized with correct values
    fun singleton_success():
    (
        vector<I>,
        vector<O<u8>>,
    ) {
        let cb = singleton<u8>(2, 3); // Initialize w/ key 2 and value 3
        assert!(v_i_e<I>(&cb.i), 0); // Assert no inner nodes
        assert!(v_l<O<u8>>(&cb.o) == 1, 1); // Assert single outer node
        let CB{r, i, o} = cb; // Unpack root index and node vectors
        // Assert root index field indicates 0th outer node
        assert!(r == OUT << N_TYPE, 2);
        // Pop and unpack last node from vector of outer nodes
        let O{k, v, p} = v_po_b<O<u8>>(&mut o);
        // Assert values in node are as expected
        assert!(k == 2 && v == 3 && p == ROOT, 3);
        (i, o) // Return rather than unpack
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
    fun stitch_swap_remove_i_l():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus inner node at
        // vector index 1, which will be swap removed
        v_pu_b<I>(&mut cb.i, I{c: 2, p: ROOT, l:     2 , r: o_c(0)});
        // Bogus node
        v_pu_b<I>(&mut cb.i, I{c: 0, p:    0, l:     0 , r:     0 });
        v_pu_b<I>(&mut cb.i, I{c: 1, p:    0, l: o_c(1), r: o_c(2)});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"100"), v, p: 0});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v, p: 2});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"011"), v, p: 2});
        // Swap remove and unpack bogus node
        let I{c: _, p: _, l: _, r: _} = v_s_r<I>(&mut cb.i, 1);
        // Stitch broken relationships
        stitch_swap_remove(&mut cb, 1, 3);
        // Assert parent to relocated node indicates proper child update
        assert!(v_b<I>(&cb.i, 0).l == 1, 0);
        // Assert children to relocated node indicate proper parent
        // update
        assert!(v_b<O<u8>>(&cb.o, 1).p == 1, 1); // Left child
        assert!(v_b<O<u8>>(&cb.o, 2).p == 1, 2); // Right child
        cb // Return rather than unpack
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
    fun stitch_swap_remove_i_r():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus inner node at
        // vector index 1, which will be swap removed
        v_pu_b<I>(&mut cb.i, I{c: 2, p: ROOT, l: o_c(0), r:     2 });
        // Bogus node
        v_pu_b<I>(&mut cb.i, I{c: 0, p:    0, l:     0 , r:     0 });
        v_pu_b<I>(&mut cb.i, I{c: 1, p:    0, l: o_c(1), r: o_c(2)});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v, p: 0});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"101"), v, p: 2});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"111"), v, p: 2});
        // Swap remove and unpack bogus node
        let I{c: _, p: _, l: _, r: _} = v_s_r<I>(&mut cb.i, 1);
        // Stitch broken relationships
        stitch_swap_remove(&mut cb, 1, 3);
        // Assert parent to relocated node indicates proper child update
        assert!(v_b<I>(&cb.i, 0).r == 1, 0);
        // Assert children to relocated node indicate proper parent
        // update
        assert!(v_b<O<u8>>(&cb.o, 1).p == 1, 1); // Left child
        assert!(v_b<O<u8>>(&cb.o, 2).p == 1, 2); // Right child
        cb // Return rather than unpack
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
    fun stitch_swap_remove_o_l():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus outer node at
        // vector index 2, which will be swap removed
        v_pu_b<I>(&mut cb.i, I{c: 2, p: ROOT, l: o_c(0), r:     1 });
        v_pu_b<I>(&mut cb.i, I{c: 1, p:    0, l: o_c(3), r: o_c(1)});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v, p: 0});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"111"), v, p: 1});
        v_pu_b<O<u8>>(&mut cb.o, O{k:    HI_128, v, p: HI_64}); // Bogus
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"101"), v, p: 1});
        // Swap remove and unpack bogus node
        let O{k: _, v: _, p: _} = v_s_r<O<u8>>(&mut cb.o, 2);
        // Stitch broken relationship
        stitch_swap_remove(&mut cb, o_c(2), 4);
        // Assert parent to relocated node indicates proper child update
        assert!(v_b<I>(&cb.i, 1).l == o_c(2), 0);
        cb // Return rather than unpack
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
    fun stitch_swap_remove_o_r():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus outer node at
        // vector index 2, which will be swap removed
        v_pu_b<I>(&mut cb.i, I{c: 2, p: ROOT, l: o_c(0), r:     1 });
        v_pu_b<I>(&mut cb.i, I{c: 1, p:    0, l: o_c(1), r: o_c(3)});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v, p: 0});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"101"), v, p: 1});
        v_pu_b<O<u8>>(&mut cb.o, O{k:    HI_128, v, p: HI_64}); // Bogus
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"111"), v, p: 1});
        // Swap remove and unpack bogus node
        let O{k: _, v: _, p: _} = v_s_r<O<u8>>(&mut cb.o, 2);
        // Stitch broken relationship
        stitch_swap_remove(&mut cb, o_c(2), 4);
        // Assert parent to relocated node indicates proper child update
        assert!(v_b<I>(&cb.i, 1).r == o_c(2), 0);
        cb // Return rather than unpack
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
    fun stitch_swap_remove_r_i():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree, including bogus inner node at
        // vector index 1, which will be swap removed
        v_pu_b<I>(&mut cb.i, I{c: 1, p:    2, l: o_c(1), r: o_c(2)});
        // Bogus node
        v_pu_b<I>(&mut cb.i, I{c: 0, p:    0, l:     0 , r:     0 });
        v_pu_b<I>(&mut cb.i, I{c: 2, p: ROOT, l: o_c(0), r:     0 });
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v, p: 0});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"101"), v, p: 2});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"111"), v, p: 2});
        // Swap remove and unpack bogus node
        let I{c: _, p: _, l: _, r: _} = v_s_r<I>(&mut cb.i, 1);
        // Stitch broken relationships
        stitch_swap_remove(&mut cb, 1, 3);
        // Assert root field reflects relocated node position
        assert!(cb.r == 1, 0);
        // Assert children to relocated node indicate proper parent
        // update
        assert!(v_b<O<u8>>(&cb.o, 0).p == 1, 1); // Left child
        assert!(v_b<I>(&cb.i, 0).p == 1, 2); // Right child
        cb // Return rather than unpack
    }

    #[test]
    /// Verify successful stitch for relocated root outer node
    /// ```
    /// >      100 <- i_i = 1 (relocated)
    /// ```
    fun stitch_swap_remove_r_o():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append root outer node per above diagram, including bogus
        // outer node at vector index 0, which will be swap removed
        v_pu_b<O<u8>>(&mut cb.o, O{k:    HI_128, v, p: HI_64}); // Bogus
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"100"), v, p:  ROOT});
        // Swap remove and unpack bogus node
        let O{k: _, v: _, p: _} = v_s_r<O<u8>>(&mut cb.o, 0);
        // Stitch broken relationships
        stitch_swap_remove(&mut cb, o_c(0), 2);
        // Assert root field indicates relocated outer node
        assert!(cb.r == o_c(0), 0);
        // Borrow reference to outer node at root
        let n = v_b<O<u8>>(&cb.o, 0);
        // Assert fields are as expected
        assert!(n.k == u(b"100") && n.v == 0 && n.p == ROOT, 1);
        cb // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-binary-representative byte string
    fun u_failure() {u(b"2");}

    #[test]
    /// Verify successful return values
    fun u_success() {
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

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // To sort >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    public(friend) fun inner_at<V>(
        cb: &mut CB<V>,
        i_p: u64
    ): &I {
        v_b_m<I>(&mut cb.i, i_p)
    }

    // The walk takes the index of the parent and the val of key from
    // traverse_dec_via_parent
    // next_from_parent_of_dec

    // Return the parent field of outer node `o_n`
    public(friend) fun parent_field_of<V>(
        o_n: &O<V>
    ): u64 {
        o_n.p
    }

/*
    #[test]
    /// ```
    /// >         2nd
    /// >        /   \
    /// >      001   1st
    /// >           /   \
    /// >         100   0th
    /// >              /   \
    /// >            110   111
    /// ```
    fun parent_at_success():
    CB<u8> {
        let v = 0; // Ignore values by setting to 0
        let cb = singleton(u(b"001"), v); // Initialize singleton
        insert(&mut cb, u(b"100"), v); // Insert key 100
        insert(&mut cb, u(b"110"), v); // Insert key 110
        insert(&mut cb, u(b"111"), v); // Insert key 111
        // Borrow mutable reference to max node
        let n_m = borrow_max_node_mut(&mut cb);
        // Borrow immutable reference to parent of max node
        let p_m = inner_at(&mut cb, parent_field_of(n_m));
        assert!(p_m.c == 0, 0); // Assert has critical bit of 0
        cb // Return rather than unpack
    }
*/

    /// Return maximum key in `cb`, a mutable reference to the value
    /// from the corresponding node, and the parent field of the node,
    /// aborting if `cb` empty, to begin decreasing traversal
    public fun begin_dec_traverse_mut<V>(
        cb: &mut CB<V>,
    ): (
        u128,
        &mut V,
        u64
    ) {
        // Assert tree not empty
        assert!(!is_empty(cb), E_TRAVERSE_EMPTY);
        let i_n = cb.r; // Initialize index of search node to root field
        while (!is_out(i_n)) { // While search node is inner node
            i_n = v_b<I>(&cb.i, i_n).r // Review node's right child next
        }; // Index of search node now corresponds to max outer node
        // Borrow mutable reference to max node
        let n = v_b_m<O<V>>(&mut cb.o, o_v(i_n));
        // Return its key, mutable reference to its value, and its
        // parent field
        (n.k, &mut n.v, n.p)
    }

    #[test]
    /// Verify successful start of decreasing traversal for tree
    /// sequence below, where `o_i` indicates outer node vector index
    /// and `i_i` indicates inner node vector index:
    /// ```
    /// >     100 <- o_i = 0                  Insert 110
    /// >                                     --------->
    /// >                   1st <- i_i = 0
    /// >                  /   \
    /// >    o_i = 0 -> 100     110 <- o_i = 1
    /// ```
    fun begin_dec_traverse_mut_success():
    CB<u8> {
       let cb = singleton(u(b"100"), 5); // Initialize singleton
       // Start decreasing traversal
       let (n_k, v_ref, n_p) = begin_dec_traverse_mut(&mut cb);
       // Verify return values are as expected
       assert!(n_k == u(b"100") && *v_ref == 5 && n_p == ROOT, 0);
       *v_ref = 6; // Modify value
       // Assert update persistence
       assert!(*borrow(&cb, u(b"100")) == 6, 1);
       cb // Return rather than unpack
    }

/*
    /// Return mutable reference to outer node having minimum key in
    /// `cb`, aborting if `cb` empty
    public fun borrow_min_node_mut<V>(
        cb: &mut CB<V>,
    ): &mut O<V> {
        let l = length(cb); // Get number of keys in tree
        assert!(l != 0, E_BORROW_EMPTY); // Assert tree not empty
        // If singleton tree, return mutable reference to root node
        if (l == 1) return v_b_m<O<V>>(&mut cb.o, o_v(cb.r));
        // Else initialize index of search node to left child of root
        let i_n = v_b<I>(&cb.i, cb.r).l;
        while (!is_out(i_n)) { // While search node is inner node
            i_n = v_b<I>(&cb.i, i_n).l // Review node's left child next
        }; // Index of search node now corresponds to outer node
        // Return mutable reference to node
        v_b_m<O<V>>(&mut cb.o, o_v(i_n))
    }
*/
    // To sort <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}