/// User-side functionality. Like `Econia::Registry`, relies on
/// `AptosFramework` functions and an associated pure-Move
/// module (`Econia::Orders`) for coverage testing.
module Econia::User {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use AptosFramework::Coin::{
        Coin as C,
        zero as c_z,
    };

    use Econia::Orders::{
        exists_orders as o_e_o,
        get_orders_init_cap as o_g_o_i_c,
        init_orders as o_i_o,
        OrdersInitCap as OIC,
    };

    use Econia::Registry::{
        is_registered as r_i_r,
        scale_factor as r_s_f
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
    use Econia::Orders::{
        scale_factor as o_s_f
    };

    #[test_only]
    use Econia::Registry::{
        BCT,
        E0,
        QCT,
        register_test_market as r_r_t_m
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Order collateral for a given market
    struct OC<phantom B, phantom Q, phantom E> has key {
        /// Indivisible subunits of base coins available to withdraw
        b_a: u64,
        /// Base coins held as collateral
        b_c: C<B>,
        /// Indivisible subunits of quote coins available to withdraw
        q_a: u64,
        /// Quote coins held as collateral
        q_c: C<Q>
    }

    /// Open orders initialization capability container
    struct OICC has key {
        o_i_c: OIC
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When order collateral container already exists
    const E_O_C_EXISTS: u64 = 0;
    /// When no corresponding market
    const E_NO_MARKET: u64 = 1;
    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 2;
    /// When open orders initialization capability container already
    /// published
    const E_HAS_OICC: u64 = 3;
    /// When open orders container already exists
    const E_O_O_EXISTS: u64 = 4;
    /// When Econia does not have open orders initialization capability
    const E_NO_OICC: u64 = 5;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public script functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Publish `OICC` to Econia acount, aborting for all other accounts
    public(script) fun init_o_i_c_c(
        account: &signer
    ) {
        // Assert account is Econia
        assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
        // Assert capability container not already initialized
        assert!(!exists<OICC>(@Econia), E_HAS_OICC);
        // Move orders initialization capability container to account
        move_to(account, OICC{o_i_c: o_g_o_i_c(account)});
    }

    /// Initialize a user with `Econia::Orders::OO` and `OC` for market
    /// with base coin type `B`, quote coin type `Q`, and scale exponent
    /// `E`, aborting if no such market or if user already initialized
    /// for market
    public(script) fun init_user<B, Q, E>(
        user: &signer
    ) acquires OICC {
        assert!(r_i_r<B, Q, E>(), E_NO_MARKET); // Assert market exists
        let user_addr = s_a_o(user); // Get user address
        // Assert user does not already have collateral container
        assert!(!exists<OC<B, Q, E>>(user_addr), E_O_C_EXISTS);
        // Assert user does not already have open orders
        assert!(!o_e_o<B, Q, E>(user_addr), E_O_O_EXISTS);
        // Assert Econia account has orders initialization capability
        assert!(exists<OICC>(@Econia), E_NO_OICC);
        // Pack empty collateral container
        let o_c = OC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
        move_to<OC<B, Q, E>>(user, o_c); // Move to user account
        // Borrow immutable reference to open orders init capability
        let o_i_c = &borrow_global<OICC>(@Econia).o_i_c;
        // Initialize empty open orders container under user account
        o_i_o<B, Q, E>(user, r_s_f<E>(), o_i_c);
    }

    // Public script functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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

    /// Return `true` if address has specified order collateral type
    fun exists_o_c<B, Q, E>(a: address): bool {exists<OC<B, Q, E>>(a)}

    /// Initialize order collateral container for given user, aborting
    /// if already initialized
    fun init_o_c<B, Q, E>(
        user: &signer,
    ) {
        // Assert user does not already have order collateral for market
        assert!(!exists_o_c<B, Q, E>(s_a_o(user)), E_O_C_EXISTS);
        // Assert given market has actually been registered
        assert!(r_i_r<B, Q, E>(), E_NO_MARKET);
        // Pack empty order collateral container
        let o_c = OC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
        move_to<OC<B, Q, E>>(user, o_c); // Move to user account
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

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempting to re-initialize order collateral
    public(script) fun init_o_c_failure_exists(
        econia: &signer,
        user: &signer
    ) {
        r_r_t_m(econia); // Register test market
        init_o_c<BCT, QCT, E0>(user); // Initialize order collateral
        init_o_c<BCT, QCT, E0>(user); // Attempt invalid re-init
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to initialize order collateral for
    /// non-existent market
    fun init_o_c_failure_no_market(
        user: &signer
    ) {
        init_o_c<BCT, QCT, E0>(user); // Attempt invalid intialization
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful initialization of order collateral
    public(script) fun init_o_c_success(
        econia: &signer,
        user: &signer
    ) acquires OC {
        r_r_t_m(econia); // Register test market
        init_o_c<BCT, QCT, E0>(user); // Initialize order collateral
        // Borrow immutable reference to order collateral container
        let o_c = borrow_global<OC<BCT, QCT, E0>>(s_a_o(user));
        // Assert no base coins or quote coins in collateral container
        assert!(c_v(&o_c.b_c) == 0 && c_v(&o_c.q_c) == 0, 0);
        // Assert no base coins or quote coins marked available
        assert!(o_c.b_a == 0 && o_c.q_a == 0, 1);
    }

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 2)]
    /// Verify failed publication of `OICC` for non-Econia account
    public(script) fun init_o_i_c_c_failure_not_econia(
        account: &signer
    ) {
        // Attempt invalid initialization of container
        init_o_i_c_c(account); // Initialize capability container
    }

    #[test(econia = @Econia)]
    #[expected_failure(abort_code = 3)]
    /// Verify failed re-publication of `OICC` to Econia account
    public(script) fun init_o_i_c_c_failure_o_i_c_c_exists(
        econia: &signer
    ) {
        init_o_i_c_c(econia); // Initialize capability container
        init_o_i_c_c(econia); // Attempt invalid re-initialization
    }

    #[test(econia = @Econia)]
    /// Verify successful publication of `OICC`
    public(script) fun init_o_i_c_c_success(
        econia: &signer
    ) acquires OICC {
        init_o_i_c_c(econia); // Initialize capability container
        // Assert capability container initialized
        assert!(exists<OICC>(@Econia), 0);
        // Assert can invoke open orders initialization
        o_i_o<BCT, QCT, E0>(econia, 1, &borrow_global<OICC>(@Econia).o_i_c);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for user having order collateral container
    public(script) fun init_user_failure_has_o_c(
        econia: &signer,
        user: &signer
    ) acquires OICC {
        r_r_t_m(econia); // Register test market
        init_o_c<BCT, QCT, E0>(user); // Init order collateral container
        init_user<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for user already having open orders container
    public(script) fun init_user_failure_has_o_o(
        econia: &signer,
        user: &signer
    ) acquires OICC {
        r_r_t_m(econia); // Register test market
        init_o_i_c_c(econia); // Initialize capability container
        // Borrow immutable reference to open orders init capability
        let o_i_c = &borrow_global<OICC>(@Econia).o_i_c;
        // Initialize empty open orders container under user account
        o_i_o<BCT, QCT, E0>(user, r_s_f<E0>(), o_i_c);
        init_user<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for unregistered market
    public(script) fun init_user_failure_no_market(
        user: &signer
    ) acquires OICC {
        init_user<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for Econia without open orders init capability
    public(script) fun init_user_failure_no_o_i_c(
        econia: &signer,
        user: &signer
    ) acquires OICC {
        r_r_t_m(econia); // Register test market
        init_user<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful user initialization
    public(script) fun init_user_success(
        econia: &signer,
        user: &signer
    ) acquires OC, OICC {
        r_r_t_m(econia); // Register test market
        init_o_i_c_c(econia); // Initialize order init capability
        init_user<BCT, QCT, E0>(user); // Init user for test market
        let user_addr = s_a_o(user); // Get user address
        // Borrow immutable reference to order collateral container
        let o_c = borrow_global<OC<BCT, QCT, E0>>(user_addr);
        // Assert no base coins or quote coins in collateral container
        assert!(c_v(&o_c.b_c) == 0 && c_v(&o_c.q_c) == 0, 0);
        // Assert no base coins or quote coins marked available
        assert!(o_c.b_a == 0 && o_c.q_a == 0, 1);
        // Assert open orders exists and has correct scale factor
        assert!(o_s_f<BCT, QCT, E0>(user_addr) == r_s_f<E0>(), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}