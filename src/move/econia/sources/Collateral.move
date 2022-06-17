/// Collateral management functionality
module Econia::Collateral {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use AptosFramework::Coin::{
        Coin as C,
        zero as c_z,
    };

    use Econia::Registry::{
        is_registered as r_i_r
    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use AptosFramework::Coin::{
        value as c_v,
    };

    #[test_only]
    use Econia::Registry::{
        BCT,
        QCT,
        E0
    };

    #[test_only]
    use Econia::Registry::{
        register_test_market as r_r_t_m,
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
    /// When no corresponding market to register collateral for
    const E_NO_MARKET: u64 = 1;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

/*
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
*/

    /// Return `true` if address has specified collateral container type
    fun exists_c_c<B, Q, E>(a: address): bool {exists<CC<B, Q, E>>(a)}

    /// Initialize order collateral container for given user, aborting
    /// if already initialized
    fun init_c_c<B, Q, E>(
        user: &signer,
    ) {
        // Assert user does not already have order collateral for market
        assert!(!exists_c_c<B, Q, E>(s_a_o(user)), E_C_C_EXISTS);
        // Assert given market has actually been registered
        assert!(r_i_r<B, Q, E>(), E_NO_MARKET);
        // Pack empty collateral container
        let o_c = CC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
        move_to<CC<B, Q, E>>(user, o_c); // Move to user account
    }

/*
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
*/

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to initialize order collateral for
    /// non-existent market
    fun init_c_c_failure_no_market(
        user: &signer
    ) {
        init_c_c<BCT, QCT, E0>(user); // Attempt invalid intialization
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempting to re-initialize order collateral
    public(script) fun init_c_c_failure_exists(
        econia: &signer,
        user: &signer
    ) {
        r_r_t_m(econia); // Register test market
        init_c_c<BCT, QCT, E0>(user); // Initialize order collateral
        init_c_c<BCT, QCT, E0>(user); // Attempt invalid re-initialization
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful initialization of order collateral
    public(script) fun init_c_c_success(
        econia: &signer,
        user: &signer
    ) acquires CC {
        r_r_t_m(econia); // Register test market
        init_c_c<BCT, QCT, E0>(user); // Initialize order collateral
        // Borrow immutable reference to order collateral container
        let c_c = borrow_global<CC<BCT, QCT, E0>>(s_a_o(user));
        // Assert no base coins or quote coins in collateral container
        assert!(c_v(&c_c.b_c) == 0 && c_v(&c_c.q_c) == 0, 0);
        // Assert no base coins or quote coins marked available
        assert!(c_c.b_a == 0 && c_c.q_a == 0, 1);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}