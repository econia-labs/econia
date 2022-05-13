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
module Econia::CritBit {

    use Std::Vector::{
        borrow as v_b,
        empty as v_e,
        length as v_l,
    };

    #[test_only]
    use Std::Vector::{
        is_empty as v_i_e,
    };

// Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag to indicate that there is no connected node for the given
    /// child relationship field, analagous to a `NULL` pointer
    const NIL: u64 = 0xffffffffffffffff;

// Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    const E_BIT_NOT_0_OR_1: u64 = 0;

// Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A node in the crit-bit tree, representing a key-value pair of
    /// key type `K` and value type `V`
    struct N<K, V> has store {
        /// Bitstring prefix from key
        p: K,
        /// Critical bit position
        c: u8,
        /// Left child node index
        l: u64,
        /// Right child node index
        r: u64,
        /// Value from the key-value pair
        v: V
    }

    /// A crit-bit tree (CBT) for key-value pairs with key type `K` and
    /// value type `V`
    struct CBT<K, V> has store {
        /// Root node index
        r: u64,
        /// Vector of nodes in the tree
        t: vector<N<K, V>>
    }

// Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Binary operation helper functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return a `u8` corresponding to the provided human-readable
    /// string, comprising only "0" and "1", of 8 characters or less
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
                // Or result with the correspondingly leftshifted bit
                r = r | 1 << (i as u8);
            // Otherwise, assert bit is marked 0 (0x30 in ASCII)
            } else assert!(b == 0x30, E_BIT_NOT_0_OR_1);
            i = i + 1; // Proceed to next-least-significant bit
        };
        r
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
    /// Verify failure for non-binary ASCII string
    fun bu8_failure() {bu8(b"2");}

// Binary operation helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Initialization >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an empty CBT
    public fun empty<K, V>():
    CBT<K, V> {
        CBT{r: NIL, t: v_e<N<K, V>>()}
    }

    #[test]
    /// Verify new CBT created empty
    fun empty_success():
    vector<N<u8, u8>> {
        // Unpack root index and node vector
        let CBT{r, t} = empty<u8, u8>();
        assert!(r == NIL, 0); // Assert root set to NIL
        assert!(v_i_e<N<u8, u8>>(&t), 1); // Assert empty node vector
        t // Return rather than unpack
    }

// Initialization <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}