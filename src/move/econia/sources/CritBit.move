/// A crit-bit tree is a compact binary prefix tree, similar to a binary
/// search tree, that stores a prefix-free set of bitstrings, like
/// 64-bit integers or variable-length 0-terminated byte strings. For a
/// given set of keys there exists a unique crit-bit tree representing
/// the set, hence crit-bit trees do not requre complex rebalancing
/// algorithms like those of AVL or red-black binary search trees.
/// Crit-bit trees support the following operations, quickly:
/// * Membership testing
/// * Insertion
/// * Deletion
/// * Predecessor
/// * Successor
/// * Iteration
///
/// References:
/// * [Bernstein 2006](https://cr.yp.to/critbit.html)
/// * [Langley 2012](https://github.com/agl/critbit)
/// * [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)
///
/// ---
///
module Econia::CritBit {

    use Std::Vector::{
        borrow as v_b,
        destroy_empty as v_d_e,
        empty as v_e,
        length as v_l,
        push_back as v_pu_b
    };

    #[test_only]
    use Std::Vector::{
        is_empty as v_i_e,
        pop_back as v_po_b,
    };

// Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag to indicate that there is no connected node for the given
    /// child relationship field, analagous to a `NULL` pointer
    const NIL: u64 = 0xffffffffffffffff;
    /// Flag to indicate external node
    const EXT: u8 = 0xff;
    /// u128 bitmask with all bits high
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
        /// Left child node index, marked `NIL` when external node
        l: u64,
        /// Right child node index, marked `NIL` when external node
        r: u64,
        /// Value from the key-value pair
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

    /// Return a `u8` corresponding to the provided human-readable
    /// string. The input string should contain only "0"s and "1"s, up
    /// to 8 characters max (e.g. `b"10101010"`)
    fun bu8(
        // Human-readable string, of form `b"10101010"`
        s: vector<u8>
    ): u8 {
        let n = v_l<u8>(&s); // Get number of bits in the string
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

    #[test]
    /// Verify successful return values
    fun bu8_success() {
        assert!(bu8(b"0") == 0, 0);
        assert!(bu8(b"1") == 1, 1);
        assert!(bu8(b"00") == 0, 2);
        assert!(bu8(b"01") == 1, 3);
        assert!(bu8(b"10") == 2, 4);
        assert!(bu8(b"11") == 3, 5);
        assert!(bu8(b"10101010") == 170, 6);
        assert!(bu8(b"00000001") == 1, 7);
        assert!(bu8(b"11111111") == 255, 8);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-binary-representing ASCII string
    fun bu8_failure() {bu8(b"2");}

    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `ALL_HI`
    fun bit_lo(b: u8): u128 {1 << b ^ ALL_HI}

    #[test]
    /// Verify successful bitmask generation
    fun bit_lo_success() {
        assert!(bit_lo(0) == ALL_HI - 1, 0);
        assert!(bit_lo(1) == ALL_HI - 2, 1);
        assert!(bit_lo(127) == 0x7fffffffffffffffffffffffffffffff, 2);
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
        v_pu_b<N<V>>(&mut cb.t, N<V>{s: k, c: EXT, l: NIL, r: NIL, v});
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
        assert!(s == 2 && c == EXT && l == NIL && r == NIL && v == 3, 2);
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

    /// Walk a non-empty tree until arriving at the external node
    /// sharing the largest common prefix with `k`, then return a
    /// reference to the node. Internal nodes store a bitstring where
    /// all bits except the critical bit are 1, so if bitwise OR between
    /// this bitstring and `k` is identical to the bitstring, then `k`
    /// has 0 at the critical bit:
    /// ```
    /// Internal node bitstring, c = 5: ....1111011111
    /// Insertion key, bit 5 = 0:       ....1011000101
    /// Result of bitwise OR:           ....1111011111
    /// ```
    /// Hence, since the directional constants `L` and `R` are set to
    /// `true` and `false` respectively, a conditional check on equality
    /// between the bitwise OR result and the original empty node
    /// bitstring evaluates to `L` when `k` has the critical bit at 0
    /// and `R` when `k` has the critical bit at 1.
    fun borrow_closest_ext<V>(
        cb: &CB<V>,
        k: u128,
    ): &N<V> {
        let n = v_b<N<V>>(&cb.t, cb.r); // Borrow root node reference
        while (n.c != EXT) { // While node under review is internal node
            // Borrow either L or R child node depending on OR result
            n = b_c<V>(cb, n, n.s | k == n.s);
        }; // Node reference now corresponds to closest match
        n // Return node reference
    }

// Node borrowing <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Membership checking >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return true if `cb` has key `k`
    fun has_key<V>(
        cb: &CB<V>,
        k: u128,
    ): bool {
        if (is_empty<V>(cb)) return false; // Return false if empty
        // Return true if closest external node match bitstring is `k`
        return borrow_closest_ext<V>(cb, k).s == k
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
    /// indicates the node's vector index:
    /// ```
    ///              i = 0 -> 2nd
    ///                      /   \
    ///           i = 1 -> 001   1st <- i = 2
    ///                         /   \
    ///              i = 3 -> 101   0th <- i = 4
    ///                            /   \
    ///                 i = 5 -> 110   111 <- i = 6
    /// ```
    fun has_key_success() {
        1;
    }

// Membership checking <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}