/// Pure-Move implementation of order book functionality
module Econia::Book {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Econia::CritBit::{
        CB,
        empty as cb_e,
    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use Econia::CritBit::{
        is_empty as cb_i_e
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Order book initialization capability
    struct BookInitCap has store {}

    /// Order book with base coin type `B`, quote coin type `Q`, and
    /// scale exponent type `E`
    struct OB<phantom B, phantom Q, phantom E> has key {
        /// Scale factor
        f: u64,
        /// Asks
        a: CB<P>,
        /// Bids
        b: CB<P>,
        /// Order id of minimum ask
        m_a: u128,
        /// Order id of maximum bid
        m_b: u128
    }

    /// Position in an order book
    struct P has store {
        /// Size of position, in base coin subunits. Corresponds to
        /// `AptosFramework::Coin::Coin.value`
        s: u64,
        /// Address
        a: address
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base coin type
    struct BT{}

    #[test_only]
    /// Scale exponent type
    struct ET{}

    #[test_only]
    /// Quote coin type
    struct QT{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When order book already exists at given address
    const E_BOOK_EXISTS: u64 = 0;
    /// When order book does not exist at given address
    const E_NO_BOOK: u64 = 1;
    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 2;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return `true` if specified order book type exists at address
    public fun exists_book<B, Q, E>(a: address): bool {exists<OB<B, Q, E>>(a)}

    /// Return a `BookInitCap`, aborting if not called by Econia account
    public fun get_book_init_cap(
        account: &signer
    ): BookInitCap {
        // Assert called by Econia
        assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
        BookInitCap{} // Return requested capability
    }

    /// Initialize order book under host account, provided `BookInitCap`
    public fun init_book<B, Q, E>(
        host: &signer,
        f: u64,
        _cap: &BookInitCap
    ) {
        // Assert book does not already exist under host account
        assert!(!exists_book<B, Q, E>(s_a_o(host)), E_BOOK_EXISTS);
        // Pack empty order book
        let o_b = OB<B, Q, E>{f, a: cb_e<P>(), b: cb_e<P>(), m_a: 0, m_b: 0};
        move_to<OB<B, Q, E>>(host, o_b); // Move to host
    }

    /// Return scale factor of specified order book at given address
    public fun scale_factor<B, Q, E>(
        addr: address
    ): u64
    acquires OB {
        // Assert book exists at given address
        assert!(exists_book<B, Q, E>(addr), E_NO_BOOK);
        borrow_global<OB<B, Q, E>>(addr).f // Return book's scale factor
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for non-Econia account
    fun get_book_init_cap_failure(
        account: &signer
    ) {
        // Attempt invalid getter invocation, unpacking result
        let BookInitCap{} = get_book_init_cap(account);
    }

    #[test(econia = @Econia)]
    /// Verify success for Econia account
    fun get_book_init_cap_success(
        econia: &signer
    ) {
        // Unpack result of valid getter invocation
        let BookInitCap{} = get_book_init_cap(econia);
    }

    #[test(host = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failed re-initialization of order book
    fun init_book_failure_exists(
        host: &signer,
    ) {
        let b_i_c = BookInitCap{}; // Initialize book init capability
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &b_i_c);
        // Attempt invalid re-initialization
        init_book<BT, QT, ET>(host, 1, &b_i_c);
        let BookInitCap{} = b_i_c; // Unpack init capability
    }

    #[test(host = @TestUser)]
    /// Verify successful initialization of order book
    fun init_book_success(
        host: &signer,
    ) acquires OB {
        let b_i_c = BookInitCap{}; // Initialize book init capability
        // Initialize book with scale factor 1
        init_book<BT, QT, ET>(host, 1, &b_i_c);
        let BookInitCap{} = b_i_c; // Unpack init capability
        let host_addr = s_a_o(host); // Get host address
        // Assert book exists and has correct scale factor
        assert!(scale_factor<BT, QT, ET>(host_addr) == 1, 0);
        // Borrow mutable reference to order book
        let o_b = borrow_global<OB<BT, QT, ET>>(host_addr);
        // Assert minimum ask and maximum bid order ids init to 0
        assert!(o_b.m_a == 0 && o_b.m_b == 0, 1);
        // Assert bid and ask trees init empty
        assert!(cb_i_e(&o_b.a) && cb_i_e(&o_b.b), 2);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no book
    fun scale_factor_failure()
    acquires OB {
        scale_factor<BT, QT, ET>(@TestUser); // Attempt invalid query
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}