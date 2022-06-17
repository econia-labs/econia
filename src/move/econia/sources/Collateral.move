/// Collateral management functionality
module Econia::Collateral {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use AptosFramework::Coin::{
        Coin as C,
        value as c_v,
        zero as c_z,
    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use Econia::Book::{
        BT,
        QT,
        ET
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Order collateral container for a given market
    struct CC<phantom B, phantom Q, phantom E> has key {
        /// Indivisible subunits of base coins available to withdraw
        b_a: u64,
        /// Base coins held as collateral
        b_c: C<B>,
        /// Indivisible subunits of quote coins available to withdraw
        q_a: u64,
        /// Quote coins held as collateral
        q_c: C<Q>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When order collateral container already exists at given address
    const E_C_C_EXISTS: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return number of indivisible subunits of base coin collateral
    /// available for withdraw, for given market, at given address
    fun b_a<B, Q, E>(
        addr: address
    ): u64
    acquires CC {
        borrow_global<CC<B, Q, E>>(addr).b_a
    }

    /// Return number of indivisible subunits of base coin collateral,
    /// for given market, held at given address
    fun b_c<B, Q, E>(
        addr: address
    ): u64
    acquires CC {
        c_v(&borrow_global<CC<B, Q, E>>(addr).b_c)
    }

    /// Return `true` if address has specified collateral container type
    fun exists_c_c<B, Q, E>(a: address): bool {exists<CC<B, Q, E>>(a)}

    /// Initialize order collateral container for given user, aborting
    /// if already initialized
    fun init_c_c<B, Q, E>(
        user: &signer,
    ) {
        // Assert user does not already have order collateral for market
        assert!(!exists_c_c<B, Q, E>(s_a_o(user)), E_C_C_EXISTS);
        // Pack empty order collateral container
        let o_c = CC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
        move_to<CC<B, Q, E>>(user, o_c); // Move to user account
    }

    /// Return number of indivisible subunits of quote coin collateral
    /// available for withdraw, for given market, at given address
    fun q_a<B, Q, E>(
        addr: address
    ): u64
    acquires CC {
        borrow_global<CC<B, Q, E>>(addr).q_a
    }

    /// Return number of indivisible subunits of quote coin collateral,
    /// for given market, held at given address
    fun q_c<B, Q, E>(
        addr: address
    ): u64
    acquires CC {
        c_v(&borrow_global<CC<B, Q, E>>(addr).q_c)
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempting to re-initialize order collateral
    fun init_o_c_failure_exists(
        user: &signer
    ) {
        init_c_c<BT, QT, ET>(user); // Initialize order collateral
        init_c_c<BT, QT, ET>(user); // Attempt invalid re-initialization
    }

    #[test(user = @TestUser)]
    /// Verify successful initialization of order collateral
    fun init_o_c_failure_success(
        user: &signer
    ) acquires CC {
        init_c_c<BT, QT, ET>(user); // Initialize order collateral
        // Borrow immutable reference to order collateral container
        let c_c = borrow_global<CC<BT, QT, ET>>(s_a_o(user));
        // Assert no base coins or quote coins in collateral container
        assert!(c_v(&c_c.b_c) == 0 && c_v(&c_c.q_c) == 0, 0);
        // Assert no base coins or quote coins marked available
        assert!(c_c.b_a == 0 && c_c.q_a == 0, 1);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}