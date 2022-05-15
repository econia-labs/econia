/// A crit-bit tree is a compact binary prefix tree, similar to a binary
/// search tree, that stores a prefix-free set of bitstrings, like
/// n-bit integers or variable-length 0-terminated byte strings. For a
/// given set of keys there exists a unique crit-bit tree representing
/// the set, hence crit-bit trees do not requre complex rebalancing
/// algorithms like those of AVL or red-black binary search trees.
/// Crit-bit trees support the following operations, quickly:
///
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Predecessor
/// * Successor
/// * Iteration
///
/// References:
///
/// * [Bernstein 2006](https://cr.yp.to/critbit.html)
/// * [Langley 2012](https://github.com/agl/critbit)
/// * [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)
///
/// The present implementation involves a tree with two types of nodes,
/// inner and outer. Inner nodes have two children each, while outer
/// nodes have no children. There are no nodes that have exactly one
/// child. Outer nodes store a key-value pair with a 128-bit integer as
/// a key, and an arbitrary value of generic type. Inner nodes do not
/// store a key, but rather, a bitmask indicating the critical bit
/// (crit-bit) of divergence between keys located within the node's two
/// subtrees: keys in the node's left subtree have a 0 at the critical
/// bit, while keys in the node's right subtree have a 1 at the critical
/// bit. Bit numbers are 0-indexed starting at the least-significant bit
/// (LSB), such that a critical bit of 3, for instance, corresponds to
/// the bitmask `00....001000`. Inner nodes are arranged hierarchically,
/// with the most sigificant critical bits at the top of the tree. For
/// instance, the keys `001`, `101`, `110`, and `111` would be stored in
/// a crit-bit tree as follows (vertical bars included at left of
/// illustration per issue with documentation build engine, namely, the
/// automatic stripping of leading whitespace in fenced code blocks):
/// ```
/// |       2nd
/// |      /   \
/// |    001   1st
/// |         /   \
/// |       101   0th
/// |            /   \
/// |          110   111
/// ```
/// Here, the inner node marked `2nd` stores the bitmask `00...00100`,
/// the inner node marked `1st` stores the bitmask `00...00010`, and the
/// inner node marked `0th` stores the bitmask `00...00001`. Hence, the
/// sole key in the left subtree of the inner node marked `2nd` has 0 at
/// bit 2, while all the keys in the node's right subtree have 1 at bit
/// 2. And similarly for the inner node marked `0th`, its left child
/// node does not have bit 0 set, while its right child does have bit 0
/// set.
///
/// ---
///
module Econia::CritBit {

    use Std::Vector::{
        borrow as v_b,
        destroy_empty as v_d_e,
        empty as v_e,
        push_back as v_pu_b
    };

    #[test_only]
    use Std::Vector::{
        append as v_a,
        length as v_l,
        is_empty as v_i_e,
        pop_back as v_po_b,
    };

// Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag to indicate that there is no connected node for the given
    /// child relationship field, analagous to a `NULL` pointer
    const NIL: u64 = 0xffffffffffffffff;
    /// Flag to indicate outer node
    const OUT: u8 = 0xff;
    /// u128 bitmask with all bits set
    const ALL_HI: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Left direction
    const L: bool = true;
    /// Right direction
    const R: bool = false;

// Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    const E_BIT_NOT_0_OR_1: u64 = 0;
    const E_DESTROY_NOT_EMPTY: u64 = 1;

// Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A node in the crit-bit tree, representing a key-value pair with
    /// value type `V`
    struct N<V> has store {
        /// Bitstring, which would preferably be a generic type
        /// representing the union of {u8, u64, u128}. However this kind
        /// of union typing is not supported by Move, so the most
        /// general (and memory intensive) u128 is instead specified
        /// strictly.
        s: u128,
        // Documentation comments, specifically on struct fields,
        // apparently do not support fenced code blocks unless they are
        // preceded by a blank line...
        /// Critical bit position. Bit numbers 0-indexed from LSB:
        ///
        /// ```
        /// 11101...1000100100
        ///             |    |- bit 0 is 0
        /// bit 5 is 1 -|
        /// ```
        c: u8,
        /// Left child node index, marked `NIL` when outer node
        l: u64,
        /// Right child node index, marked `NIL` when outer node
        r: u64,
        /// Value from node's key-value pair
        v: V
    }

    /// A crit-bit tree for key-value pairs with value type `V`
    struct CB<V> has store {
        /// Root node index
        r: u64,
        /// Vector of nodes in the tree
        t: vector<N<V>>
    }

// Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Binary operation helper functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return the number of the most significant bit (0-indexed from
    /// LSB) at which two non-identical bitstrings, `s1` and `s2`, vary.
    /// To begin with, a bitwise XOR is used to flag all differing bits:
    /// ```
    ///      s1: 101110001
    ///      s2: 101011100
    /// s1 ^ s2: 000101101
    ///             |- critical bit = 5
    /// ```
    /// Next
    /// ```
    ///           r: 000101101
    ///       r - 1: 000101100
    /// r & (r - 1): 000101100
    ///  r = r >> 1: 000010110
    /// ```
    /// The critical bit is then the number of the left-most 1 in the
    /// XOR result `r`. From here, so long as `r` is greater than 1,
    /// then `r` AND (`r` - 1)
    /// then `r` if the LSB of `r` is 1, then so will
    /// the LSB of the `r` & (`r` - 1) if the LSB
    /// of `r` is 1, which means that so long as `r` AND (`r` - 1) is
    /// not equal to
    fun crit_bit(
        s1: u128,
        s2: u128,
    ) {
        let r = s1 ^ s2; // Marked 1 at bits that differ
        r;
    }

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
        ) == ALL_HI, 9);
        assert!(u_long( // 60 characters on first two lines, 8 on last
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111111111111111111111111111111111111111111111111111111111111",
            b"11111110"
        ) == ALL_HI - 1, 10);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-binary-representative byte string
    fun u_failure() {u(b"2");}

    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `ALL_HI`
    fun b_lo(b: u8): u128 {1 << b ^ ALL_HI}

    #[test]
    /// Verify successful bitmask generation
    fun b_lo_success() {
        assert!(b_lo(0) == ALL_HI - 1, 0);
        assert!(b_lo(1) == ALL_HI - 2, 1);
        assert!(b_lo(127) == 0x7fffffffffffffffffffffffffffffff, 2);
    }

// Binary operation helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Initialization >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an empty tree
    public fun empty<V>():
    CB<V> {
        CB{r: NIL, t: v_e<N<V>>()}
    }

    #[test]
    /// Verify new tree created empty
    fun empty_success():
    vector<N<u8>> {
        // Unpack root index and node vector
        let CB{r, t} = empty<u8>();
        assert!(r == NIL, 0); // Assert root set to NIL
        assert!(v_i_e<N<u8>>(&t), 1); // Assert empty node vector
        t // Return rather than unpack
    }

    /// Insert key-value pair `k` and `v` into an empty `cb`
    fun insert_empty<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V
    ) {
        v_pu_b<N<V>>(&mut cb.t, N<V>{s: k, c: OUT, l: NIL, r: NIL, v});
    }

    /// Return a tree with one node having key `k` and value `v`
    public fun singleton<V>(
        k: u128,
        v: V
    ):
    CB<V> {
        let cb = CB{r: 0, t: v_e<N<V>>()};
        insert_empty<V>(&mut cb, k, v);
        cb
    }

    #[test]
    /// Verify singleton initialized with correct values
    fun singleton_success():
    vector<N<u8>> {
        let cb = singleton<u8>(2, 3); // Initialize w/ key 2 and value 3
        assert!(v_l<N<u8>>(&cb.t) == 1, 0); // Assert only one node
        let CB{r, t} = cb; // Unpack the root index and nodes vector
        assert!(r == 0, 1); // Assert root index = 0
        // Pop and unpack last node from tree's vector of nodes
        let N{s, c, l, r, v} = v_po_b<N<u8>>(&mut t);
        // Assert values in the node are as expected
        assert!(s == 2 && c == OUT && l == NIL && r == NIL && v == 3, 2);
        t // Return vector of nodes rather than unpack
    }

// Initialization <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Destruction >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Destroy empty tree `cb`
    public fun destroy_empty<V>(
        cb: CB<V>
    ) {
        assert!(is_empty(&cb), E_DESTROY_NOT_EMPTY);
        let CB{r: _, t} = cb; // Unpack root node index and node vector
        v_d_e(t); // Destroy empty node vector
    }

    #[test]
    /// Verify empty tree destruction
    fun destroy_empty_success() {
        let cb = empty<u8>(); // Initialize empty tree
        destroy_empty<u8>(cb); // Destroy it
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify cannot destroy non-empty tree
    fun destroy_empty_fail() {
        // Attempt destroying singleton
        destroy_empty<u8>(singleton<u8>(0, 0));
    }

// Destruction <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Size checks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return `true` if the tree is empty (if root is `NIL`)
    fun is_empty<V>(cb: &CB<V>): bool {cb.r == NIL}

    #[test]
    /// Verify emptiness check validity
    fun is_empty_success():
    CB<u8> {
        let cb = empty<u8>(); // Get empty tree
        assert!(is_empty<u8>(&cb), 0); // Assert is empty
        cb.r = 0; // Change root to non-NIL
        // Assert not marked empty
        assert!(!is_empty<u8>(&cb), 0);
        cb // Return rather than unpack
    }


// Size checks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// Node borrowing >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return immutable reference to either left or right child of node
    /// `n` in `cb` (left when `d` is `L`, right when `d` is `R`)
    fun b_c<V>(
        cb: & CB<V>,
        n: & N<V>,
        d: bool
    ): &N<V> {
        if (d == L) v_b<N<V>>(&cb.t, n.l) else v_b<N<V>>(&cb.t, n.r)
    }

    /// Walk a non-empty tree until arriving at the outer node sharing
    /// the largest common prefix with `k`, then return a reference to
    /// the node. Inner nodes store a bitmask where all bits except the
    /// critical bit are not set, so if bitwise AND between `k` and an
    /// inner node's bitmask is 0, then `k` has 0 at the critical bit:
    /// ```
    /// Insertion key, bit 5 = 0:  ...1011000101
    /// Inner node bitmask, c = 5: ...0000100000
    /// Result of bitwise AND:     ...0000000000
    /// ```
    /// Hence, since the directional constants `L` and `R` are set to
    /// `true` and `false` respectively, a conditional check on equality
    /// between the 0 and the bitwise AND result evaluates to `L` when
    /// `k` does not have the critical bit set, and `R` when `k` does
    /// have the critical bit set.
    fun borrow_closest_outer<V>(
        cb: &CB<V>,
        k: u128,
    ): &N<V> {
        let n = v_b<N<V>>(&cb.t, cb.r); // Borrow root node reference
        while (n.c != OUT) { // While node under review is inner node
            // Borrow either L or R child node depending on AND result
            n = b_c<V>(cb, n, n.s & k == 0);
        }; // Node reference now corresponds to closest outer node
        n // Return closest outer node reference
    }

// Node borrowing <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Membership checks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return true if `cb` has key `k`
    fun has_key<V>(
        cb: &CB<V>,
        k: u128,
    ): bool {
        if (is_empty<V>(cb)) return false; // Return false if empty
        // Return true if closest outer node match bitstring is `k`
        return borrow_closest_outer<V>(cb, k).s == k
    }

    #[test]
    /// Verify returns `false` for empty tree
    fun has_key_empty_success() {
        let cb = empty<u8>(); // Initialize empty tree
        assert!(!has_key(&cb, 0), 0); // Assert key check returns false
        destroy_empty<u8>(cb); // Drop empty tree
    }

    #[test]
    /// Verify successful key checks for the following tree, where `i`
    /// indicates each node's vector index:
    /// ```
    ///              i = 0 -> 2nd
    ///                      /   \
    ///           i = 1 -> 001   1st <- i = 2
    ///                         /   \
    ///              i = 3 -> 101   0th <- i = 4
    ///                            /   \
    ///                 i = 5 -> 110   111 <- i = 6
    /// ```
    fun has_key_success():
    CB<u8> {
        let v = 0; // Ignore values in key-value pair by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        cb.r = 0; // Set root to node at vector index 0
        // Append nodes per above tree
        v_pu_b<N<u8>>(&mut cb.t, N{s:    1 << 2, c:   2, l:   1, r:   2, v});
        v_pu_b<N<u8>>(&mut cb.t, N{s: u(b"001"), c: OUT, l: NIL, r: NIL, v});
        v_pu_b<N<u8>>(&mut cb.t, N{s:    1 << 1, c:   1, l:   3, r:   4, v});
        v_pu_b<N<u8>>(&mut cb.t, N{s: u(b"101"), c: OUT, l: NIL, r: NIL, v});
        v_pu_b<N<u8>>(&mut cb.t, N{s:    1 << 0, c:   0, l:   5, r:   6, v});
        v_pu_b<N<u8>>(&mut cb.t, N{s: u(b"110"), c: OUT, l: NIL, r: NIL, v});
        v_pu_b<N<u8>>(&mut cb.t, N{s: u(b"111"), c: OUT, l: NIL, r: NIL, v});
        // Assert correct membership checks
        assert!(has_key(&cb, u(b"001")), 0);
        assert!(has_key(&cb, u(b"101")), 1);
        assert!(has_key(&cb, u(b"110")), 2);
        assert!(has_key(&cb, u(b"111")), 3);
        assert!(!has_key(&cb, u(b"011")), 4); // Not in tree
        cb // Return rather than unpack
    }

// Membership checks <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Critical bit determination <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Critical bit determination >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
}