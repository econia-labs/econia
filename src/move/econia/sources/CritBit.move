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
/// * [Langley 2008](
///   https://www.imperialviolet.org/2008/09/29/critbit-trees.html)
/// * [Langley 2012](https://github.com/agl/critbit)
/// * [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)
///
/// The present implementation involves a tree with two types of nodes,
/// inner and outer. Inner nodes have two children each, while outer
/// nodes have no children. There are no nodes that have exactly one
/// child. Outer nodes store a key-value pair with a 128-bit integer as
/// a key, and an arbitrary value of generic type. Inner nodes do not
/// store a key, but rather, an 8-bit integer indicating the most
/// significatn critical bit (crit-bit) of divergence between keys
/// located within the node's two subtrees: keys in the node's left
/// subtree have a 0 at the critical bit, while keys in the node's right
/// subtree have a 1 at the critical bit. Bit numbers are 0-indexed
/// starting at the least-significant bit (LSB), such that a critical
/// bit of 3, for instance, corresponds to a comparison between the
/// bitstrings `00...00000` and `00...01111`. Inner nodes are arranged
/// hierarchically, with the most sigificant critical bits at the top of
/// the tree. For instance, the keys `001`, `101`, `110`, and `111`
/// would be stored in a crit-bit tree as follows (right carets included
/// at left of illustration per issue with documentation build engine,
/// namely, the automatic stripping of leading whitespace in fenced code
/// blocks):
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
/// of the inner node marked `2nd` has 0 at bit 2, while all the keys in
/// the node's right subtree have 1 at bit 2. And similarly for the
/// inner node marked `0th`, its left child node does not have bit 0
/// set, while its right child does have bit 0 set.
///
/// ---
///
module Econia::CritBit {

    use Std::Vector::{
        borrow as v_b,
        destroy_empty as v_d_e,
        empty as v_e,
        is_empty as v_i_e,
        push_back as v_pu_b
    };

    #[test_only]
    use Std::Vector::{
        append as v_a,
        //borrow_mut as v_b_m,
        length as v_l,
        pop_back as v_po_b,
    };

// Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// `u128` bitmask with all bits set
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
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

// Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When a char in a bytestring is neither 0 nor 1
    const E_BIT_NOT_0_OR_1: u64 = 0;
    /// When attempting to destroy a non-empty crit-bit tree
    const E_DESTROY_NOT_EMPTY: u64 = 1;
    /// When an insertion key is already present in a crit-bit tree
    const E_HAS_K: u64 = 2;
    /// When unable to borrow from empty tree
    const E_BORROW_EMPTY: u64 = 3;
    /// When no match to borrow
    const E_BORROW_NO_K: u64 = 4;

// Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Inner node
    struct I has store {
        // Documentation comments, specifically on struct fields,
        // apparently do not support fenced code blocks unless they are
        // preceded by a blank line...
        /// Critical bit position. Bit numbers 0-indexed from LSB:
        ///
        /// ```
        /// 11101...1010010101
        ///  bit 5 = 0 -|    |- bit 0 = 1
        /// ```
        c: u8,
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
        v: V
    }

    /// A crit-bit tree for key-value pairs with value type `V`
    struct CB<V> has store {
        /// Root node index. When bit 63 is set, root node is an outer
        /// node. Otherwise root is an inner node. Should be 0 if empty
        r: u64,
        /// Inner nodes
        i: vector<I>,
        /// Outer nodes
        o: vector<O<V>>
    }

// Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Binary operation helper functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return the number of the most significant bit (0-indexed from
    /// LSB) at which two non-identical bitstrings, `s1` and `s2`, vary.
    /// To begin with, a bitwise XOR is used to flag all differing bits:
    /// ```
    /// >           s1: 11110001
    /// >           s2: 11011100
    /// >  x = s1 ^ s2: 00101101
    /// >                 |- critical bit = 5
    /// ```
    /// Here, the critical bit is equivalent to the bit number of the
    /// most significant set bit in XOR result `x = s1 ^ s2`. At this
    /// point, [Langley 2012](https://github.com/agl/critbit) notes that
    /// `x` bitwise AND `x - 1` will be nonzero so long as `x` contains
    /// at least some bits set which are of lesser significance than the
    /// critical bit:
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
    /// indentified the varying byte between the two strings, thus
    /// limiting `x & (x - 1)` operations to at most 7 iterations. But
    /// for the present implementation, strings are not partioned into
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
    /// search converges after log_2(`k`) iterations at most, where `k`
    /// is the number of bits in each of the strings `s1` and `s2` under
    /// comparison. Hence this search method improves the O(`k`) search
    /// proposed by [Langley 2012](https://github.com/agl/critbit) to
    /// O(log(`k`)), and moreover, determines the actual number of the
    /// critical bit, rather than just a bitmask with bit `c` set, as he
    /// proposes, which can also be easily generated via `1 << c`.
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

    #[test]
    /// Verify successful determination of critical bit
    fun crit_bit_success() {
        let b = 0; // Start loop for bit 0
        while (b <= MSB_u128) { // Loop over all bit numbers
            // Compare 0 versus a bitmask that is only set at bit b
            assert!(crit_bit(0, 1 << b) == b, (b as u64));
            b = b + 1; // Increment bit counter
        };
    }

    /// Return `true` if `k` is set at bit `b`
    fun is_set(k: u128, b: u8): bool {k >> b & 1 == 1}

    /// Return `true` if vector index `i` indicates an outer node
    fun is_out(i: u64): bool {(i >> N_TYPE & 1 == 1)}

    /// Convert flagged child node index `c` to unflagged outer node
    /// vector index, by AND with a bitmask that has only flag bit unset
    fun o_v(c: u64): u64 {c & HI_64 ^ OUT << N_TYPE}

    /// Convert unflagged outer node vector index `v` to flagged child
    /// node index, by OR with a bitmask that has only flag bit set
    fun o_c(v: u64): u64 {v | OUT << N_TYPE}

    #[test]
    /// Verify correct returns
    fun is_set_success() {
        assert!(is_set(u(b"11"), 0) && is_set(u(b"11"), 1), 0);
        assert!(!is_set(u(b"10"), 0) && !is_set(u(b"01"), 1), 1);
    }

    #[test]
    /// Verify correct returns
    fun is_out_success() {
        assert!(is_out(1 << N_TYPE), 0);
        assert!(!is_out(0), 1);
    }

    #[test]
    /// Verify correct returns
    fun o_v_success() {
        assert!(o_v(1 << N_TYPE) == 0, 0);
        assert!(o_v(1 << N_TYPE | 123) == 123, 1);
    }

    #[test]
    /// Verify correct returns
    fun out_c_success() {
        assert!(o_c(0) == 1 << N_TYPE, 0);
        assert!(o_c(123) == 1 << N_TYPE | 123, 1);
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
        ) == HI_128, 9);
        assert!(u_long( // 60 characters on first two lines, 8 on last
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111111111111111111111111111111111111111111111111111111111111",
            b"11111110"
        ) == HI_128 - 1, 10);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-binary-representative byte string
    fun u_failure() {u(b"2");}

    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `HI_128`
    fun b_lo(b: u8): u128 {1 << b ^ HI_128}

    #[test]
    /// Verify successful bitmask generation
    fun b_lo_success() {
        assert!(b_lo(0) == HI_128 - 1, 0);
        assert!(b_lo(1) == HI_128 - 2, 1);
        assert!(b_lo(127) == 0x7fffffffffffffffffffffffffffffff, 2);
    }

// Binary operation helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Initialization >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an empty tree
    public fun empty<V>():
    CB<V> {
        CB{r: 0, i: v_e<I>(), o: v_e<O<V>>()}
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

    /// Insert key-value pair `k` and `v` into an empty `cb`
    fun insert_empty<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V
    ) {
        // Push back outer node onto tree's vector of outer nodes
        v_pu_b<O<V>>(&mut cb.o, O<V>{k, v});
        // Set root index field to indicate 0th outer node
        cb.r = OUT << N_TYPE;
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
        let O{k, v} = v_po_b<O<u8>>(&mut o);
        // Assert values in node are as expected
        assert!(k == 2 && v == 3, 3);
        (i, o) // Return rather than unpack
    }

// Initialization <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Destruction >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Destroy empty tree `cb`
    public fun destroy_empty<V>(
        cb: CB<V>
    ) {
        assert!(is_empty(&cb), E_DESTROY_NOT_EMPTY);
        let CB{r: _, i, o} = cb; // Unpack root index and node vectors
        v_d_e(i); // Destroy empty inner node vector
        v_d_e(o); // Destroy empty outer node vector
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

    /// Return `true` if `cb` has no outer nodes
    fun is_empty<V>(cb: &CB<V>): bool {v_i_e<O<V>>(&cb.o)}

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


// Size checks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// Borrowing >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /*
    /// Return immutable reference to either left or right child of
    /// inner node `n` in `cb` (left if `d` is `L`, right if `d` is `R`)
    fun b_i_c<V>(
        cb: &CB<V>,
        n: &N<V>,
        d: bool
    ): &N<V> {
        if (d == L) v_b<N<V>>(&cb.t, n.l) else v_b<N<V>>(&cb.t, n.r)
    }

    /// Return mutable reference to the field where an inner node stores
    /// the index of either its left or right child (left if `d` is `L`,
    /// right if `d` is `R`). The inner node in question is borrowed by
    /// dereferencing a reference to the field where its own node index
    /// is stored, `i_f_r`, ("index field reference")
    fun b_c_i_f_r<V>(
        cb: &mut CB<V>,
        i_f_r: &mut u64,
        d: bool
    ): &mut u64 {
        if (d == L) &mut v_b_m<N<V>>(&mut cb.t, *i_f_r).l else
            &mut v_b_m<N<V>>(&mut cb.t, *i_f_r).r
    }

    */
    /// Walk a non-empty tree until arriving at the outer node sharing
    /// the largest common prefix with `k`, then return a reference to
    /// it. `b_c_o` indicates "borrow closest outer"
    fun b_c_o<V>(
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
            // If child is outer node, borrow and return it
            if (is_out(i_c)) return v_b<O<V>>(&cb.o, o_v(i_c));
            n = v_b<I>(&cb.i, i_c); // Borrow next inner node to review
        }
    }

    /// Borrow value corresponding to key `k` in `cb`, aborting if empty
    /// tree or no match
    public fun borrow<V>(
        cb: &CB<V>,
        k: u128,
    ): &V {
        assert!(!is_empty<V>(cb), E_BORROW_EMPTY); // Abort if empty
        let c_o = b_c_o<V>(cb, k); // Borrow closest outer node
        assert!(c_o.k == k, E_BORROW_NO_K); // Abort if key not in tree
        &c_o.v // Return immutable reference to corresponding value
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Assert failure for attempted borrow on empty tree
    public fun borrow_empty():
    CB<u8> {
        let cb = empty<u8>();
        borrow<u8>(&cb, 0);
        cb // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Assert failure for attempted borrow without matching key
    public fun borrow_no_match():
    CB<u8> {
        let cb = singleton<u8>(3, 4);
        borrow<u8>(&cb, 6);
        cb // Return rather than unpack (or signal to compiler as much)
    }

    /*
    /// Return same as `b_c_o`, but also return mutable reference to the
    /// field that stores the node vector index of the outer node
    /// sharing the largest common prefix with `k` in `cb` (an "index
    /// field reference", analagous to a pointer to the closest outer
    /// node)
    fun b_c_o_i_f_r<V>(
        cb: &mut CB<V>,
        k: u128,
    ): (
        &N<V>,
        &mut u64
    ) {
        // Get mutable reference to the field where a node's vector
        // index is stored ("index field reference"), starting at root
        let i_f_r = &mut cb.r;
        let n = v_b<N<V>>(&cb.t, *i_f_r); // Get root node reference
        while (n.c != OUT) { // While node under review is inner node
            // Borrow mutable reference to the field that stores the
            // vector index of the node's L or R child node, depending
            // on AND result discussed in `b_c_o`
            i_f_r = b_c_i_f_r<V>(cb, i_f_r, n.s & k == 0);
            // Get reference to new node under review
            n = v_b<N<V>>(&cb.t, *i_f_r);
        }; // Index field reference is now that of closest outer node
        // Return closest outer node reference, and corresponding index
        // field reference (analagous to a pointer to the node)
        (n, i_f_r)
    }
    */

// Borrowing <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Membership checks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return true if `cb` has key `k`
    fun has_key<V>(
        cb: &CB<V>,
        k: u128,
    ): bool {
        if (is_empty<V>(cb)) return false; // Return false if empty
        // Return true if closest outer node has same key
        return b_c_o<V>(cb, k).k == k
    }

    #[test]
    /// Verify returns `false` for empty tree
    fun has_key_empty_success() {
        let cb = empty<u8>(); // Initialize empty tree
        assert!(!has_key(&cb, 0), 0); // Assert key check returns false
        destroy_empty<u8>(cb); // Drop empty tree
    }

    #[test]
    /// Verify successful key checks for the following tree, where `i_i`
    /// indicates an inner node's vector index, and `o_i` indicates an
    /// outer node's vector index:
    /// ```
    ///            i_i = 0 -> 2nd
    ///                      /   \
    ///         o_i = 0 -> 001   1st <- i_i = 1
    ///                         /   \
    ///            o_i = 1 -> 101   0th <- i_i = 2
    ///                            /   \
    ///               o_i = 2 -> 110   111 <- o_i = 3
    /// ```
    fun has_key_success():
    CB<u8> {
        let v = 0; // Ignore values in key-value pairs by setting to 0
        let cb = empty<u8>(); // Initialize empty tree
        // Append nodes per above tree
        v_pu_b<I>(&mut cb.i, I{c: 2, l: o_c(0), r:     1 });
        v_pu_b<I>(&mut cb.i, I{c: 1, l: o_c(1), r:     2 });
        v_pu_b<I>(&mut cb.i, I{c: 0, l: o_c(2), r: o_c(3)});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"001"), v});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"101"), v});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"110"), v});
        v_pu_b<O<u8>>(&mut cb.o, O{k: u(b"111"), v});
        // Assert correct membership checks
        assert!(has_key(&cb, u(b"001")), 0);
        assert!(has_key(&cb, u(b"101")), 1);
        assert!(has_key(&cb, u(b"110")), 2);
        assert!(has_key(&cb, u(b"111")), 3);
        assert!(!has_key(&cb, u(b"011")), 4); // Not in tree
        cb // Return rather than unpack
    }

    #[test]
    /// Verify successful key checks in special case of singleton tree
    fun has_key_singleton():
    CB<u8> {
        // Create singleton with key 1 and value 2
        let cb = singleton<u8>(1, 2);
        assert!(has_key(&cb, 1), 0); // Assert key of 1 registered
        //assert!(!has_key(&cb, 3), 0); // Assert key of 3 not registered
        cb // Return rather than unpack
    }


// Insertion >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Insert key `k` and value `v` into singleton tree `cb`, a special
    /// case that that requires updating the root field of the tree
    fun insert_singleton<V>(
        cb: &mut CB<V>,
        k: u128,
        v: V
    ) {
        let n = v_b<O<V>>(&cb.o, 0); // Borrow existing outer node
        assert!(k != n.k, E_HAS_K); // Assert insertion key not in tree
        let c = crit_bit(n.k, k); // Get critical bit between two keys
        // If insertion key greater than existing key, new inner node at
        // root should have existing key as left child and insertion key
        // as right child, otherwise the opposite
        let (l, r) = if (k > n.k) (o_c(0), o_c(1)) else (o_c(1), o_c(0));
        // Push back new outer node onto outer node vector
        v_pu_b<O<V>>(&mut cb.o, O<V>{k, v});
        // Push back new inner node with corresponding children
        v_pu_b<I>(&mut cb.i, I{c, l, r});
        // Update tree root field for newly-created inner node
        cb.r = 0;
    }

    #[test]
    /// Verify proper insertion result for left and right cases
    fun insert_singleton_success():
    (
        CB<u8>,
        CB<u8>
    ) {
        let cb1 = singleton<u8>(u(b"1111"), 2); // Initialize singleton
        insert_singleton(&mut cb1, u(b"1101"), 5); // Inserts to left
        // Assert proper lookup traversal
        assert!(*borrow<u8>(&cb1, u(b"1111")) == 2, 0);
        assert!(*borrow<u8>(&cb1, u(b"1101")) == 5, 1);
        // Repeat for add to right
        let cb2 = singleton<u8>(u(b"1011"), 2); // Initialize singleton
        insert_singleton(&mut cb2, u(b"1111"), 5); // Inserts to right
        // Assert proper lookup traversal
        assert!(*borrow<u8>(&cb2, u(b"1011")) == 2, 0);
        assert!(*borrow<u8>(&cb2, u(b"1111")) == 5, 1);
        (cb1, cb2) // Return rather than unpack
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

    /// Insert key `k` and value `v` into tree `cb` already having `n`
    /// keys for general case where root is an inner node, aborting if
    /// `k` is already present
    fun insert_general<V>(
        cb: &mut CB<V>,
        k: u128,
        //v: V,
        //n: u64
    ) {
        let i_p = cb.r; // Initialize parent index to that of root node
        let i_c: u64; // Initialize tracker for child node index
        let c_s: bool; // Initialize tracker for child side
        loop { // Loop over inner nodes
            let p = v_b<I>(&cb.i, i_p); // Borrow parent inner node
            // If key is set at critical bit, track the R child, else L
            (i_c, c_s) = if (is_set(k, p.c)) (p.r, R) else (p.l, L);
            if (is_out(i_c)) break; // Stop loop if child is outer node
            i_p = i_c; // Else borrow next inner node to review
        }; // Now child node index corresponds to closest outer node
        // Borrow closest outer node, the child from the loop
        let c_o = v_b<O<V>>(&cb.o, o_v(i_c));
        let c = crit_bit(c_o.k, k); // Get critical bit of divergence
        c_s; c;
    }

// Insertion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}