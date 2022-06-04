/// # Prices and scales
/// * "Scale exponent"
/// * "Scale factor"
module Econia::Market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use AptosFramework::Coin::{
        Coin as C,
        is_coin_initialized as c_i_c_i
    };

    use AptosFramework::Table::{
        add as t_a,
        contains as t_c,
        new as t_n,
        Table as T
    };

    use AptosFramework::TypeInfo::{
        account_address as ti_a_a,
        module_name as ti_m_n,
        struct_name as ti_s_n,
        type_of as ti_t_o,
        TypeInfo as TI
    };

    use Econia::CritBit::{
        CB,
        empty as cb_e

    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use AptosFramework::Coin::{
        BurnCapability as CBC,
        initialize as c_i,
        MintCapability as CMC
    };

    #[test_only]
    use Std::ASCII::{
        string as a_s
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Scale exponent type flags
    struct E0{}
    struct E1{}
    struct E2{}
    struct E3{}
    struct E4{}
    struct E5{}
    struct E6{}
    struct E7{}
    struct E8{}
    struct E9{}
    struct E10{}
    struct E11{}
    struct E12{}
    struct E13{}
    struct E14{}
    struct E15{}
    struct E16{}
    struct E17{}
    struct E18{}
    struct E19{}

    /// Market container
    struct MC<phantom B, phantom Q, phantom E> has key {
        /// Order book
        ob: OB<B, Q, E>
    }

    /// Market info
    struct MI has copy, drop {
        /// Base CoinType TypeInfo
        b: TI,
        /// Quote CoinType TypeInfo
        q: TI,
        /// Scale exponent TypeInfo
        e: TI
    }

    /// Market registry
    struct MR has key {
        /// Table from `MI` to address hosting the corresponding `MC`
        t: T<MI, address>
    }

    /// Order book
    struct OB<phantom B, phantom Q, phantom E> has store {
        /// Scale factor
        f: u64,
        /// Asks
        a: CB<P>,
        /// Bids
        b: CB<P>
    }

    /// Open orders on a user's account
    struct OO<phantom B, phantom Q, phantom E> has key {
        /// Scale factor
        f: u64,
        /// Asks
        a: CB<u64>,
        /// Bids
        b: CB<u64>,
        /// Base coins
        b_c: C<B>,
        /// Base coins available to withdraw
        b_a: u64,
        /// Quote coins
        q_c: C<Q>,
        /// Quote coins available to withdraw
        q_a: u64,
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

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Scale factors
    const F0 : u64 = 1;
    const F1 : u64 = 10;
    const F2 : u64 = 100;
    const F3 : u64 = 1000;
    const F4 : u64 = 10000;
    const F5 : u64 = 100000;
    const F6 : u64 = 1000000;
    const F7 : u64 = 10000000;
    const F8 : u64 = 100000000;
    const F9 : u64 = 1000000000;
    const F10: u64 = 10000000000;
    const F11: u64 = 100000000000;
    const F12: u64 = 1000000000000;
    const F13: u64 = 10000000000000;
    const F14: u64 = 100000000000000;
    const F15: u64 = 1000000000000000;
    const F16: u64 = 10000000000000000;
    const F17: u64 = 100000000000000000;
    const F18: u64 = 1000000000000000000;
    const F19: u64 = 10000000000000000000;

    /// # Type name bytestrings

    /// This module's name
    const M_NAME: vector<u8> = b"Market";

    /// # Error codes

    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 0;
    /// When wrong module
    const E_WRONG_MODULE: u64 = 1;
    /// When wrong type for exponent flag
    const E_WRONG_EXPONENT_T: u64 = 2;
    /// When market registry not initialized
    const E_NO_REGISTRY: u64 = 3;
    /// When a given market is already registered
    const E_REGISTERED: u64 = 4;
    /// When a type does not correspond to a coin
    const E_NOT_COIN: u64 = 5;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base coin type
    struct BCT{}

    #[test_only]
    /// Base coin capabilities
    struct BCC has key {
        /// Mint capability
        m: CMC<BCT>,
        /// Burn capability
        b: CBC<BCT>
    }

    #[test_only]
    /// Quote coin type
    struct QCT{}

    #[test_only]
    /// Quote coin capabilities
    struct QCC has key {
        /// Mint capability
        m: CMC<QCT>,
        /// Burn capability
        b: CBC<QCT>
    }

    #[test_only]
    struct E20{} // Invalid scale exponent type

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Base coin type coin name
    const BCT_CN: vector<u8> = b"Base";
    /// Base coin type coin symbol
    const BCT_CS: vector<u8> = b"B";
    /// Base coin type decimal
    const BCT_D: u64 = 4;
    /// Base coin type type name
    const BCT_TN: vector<u8> = b"BCT";
    /// Quote coin type coin name
    const QCT_CN: vector<u8> = b"Quote";
    /// Quote coin type coin symbol
    const QCT_CS: vector<u8> = b"Q";
    /// Base coin type decimal
    const QCT_D: u64 = 8;
    /// Quote coin type type name
    const QCT_TN: vector<u8> = b"QCT";

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public script functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Publish `MR` to Econia's acount, aborting for all other accounts
    public(script) fun init_registry(
        account: &signer
    ) {
        // Assert account is Econia
        assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
        // Move empty market registry to account
        move_to<MR>(account, MR{t: t_n<MI, address>()});
    }

    /// Register a market for the given base coin type `B`, quote coin
    /// type `Q`, and scale exponent `E` , aborting if registry not
    /// initialized or if market already registered
    public(script) fun register_market<B, Q, E>(
        host: &signer
    ) acquires MR {
        verify_market_types<B, Q, E>(); // Verify valid type arguments
        // Assert market registry is initialized at Econia account
        assert!(exists<MR>(@Econia), E_NO_REGISTRY);
        // Get market info for given type arguments
        let m_i = MI{b: ti_t_o<B>(), q: ti_t_o<Q>(), e: ti_t_o<E>()};
        // Borrow mutable reference to market registry table
        let r_t = &mut borrow_global_mut<MR>(@Econia).t;
        // Assert requested market not already registered
        assert!(!t_c(r_t, m_i), E_REGISTERED);
        // Pack empty order book with corresponding scale factor
        let ob = OB<B, Q, E>{f: scale_factor<E>(), a: cb_e<P>(), b: cb_e<P>()};
        // Pack market container with order book, move to host
        move_to<MC<B, Q, E>>(host, MC{ob});
        t_a(r_t, m_i, s_a_o(host)); // Register market-host relationship
    }

    // Public script functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return scale factor corresponding to scale exponent type `E`
    fun scale_factor<E>():
    u64 {
        let t_i = ti_t_o<E>(); // Get type info of exponent type flag
        // Verify exponent type flag is from Econia address
        verify_address(ti_a_a(&t_i), @Econia, E_NOT_ECONIA);
        // Verify exponent type flag is from this module
        verify_bytestring(ti_m_n(&t_i), M_NAME, E_WRONG_MODULE);
        let s_n = ti_s_n(&t_i); // Get type struct name
        // Return corresponding scale factor
        if (s_n == ti_s_n(&ti_t_o<E0>() )) return F0;
        if (s_n == ti_s_n(&ti_t_o<E1>() )) return F1;
        if (s_n == ti_s_n(&ti_t_o<E2>() )) return F2;
        if (s_n == ti_s_n(&ti_t_o<E3>() )) return F3;
        if (s_n == ti_s_n(&ti_t_o<E4>() )) return F4;
        if (s_n == ti_s_n(&ti_t_o<E5>() )) return F5;
        if (s_n == ti_s_n(&ti_t_o<E6>() )) return F6;
        if (s_n == ti_s_n(&ti_t_o<E7>() )) return F7;
        if (s_n == ti_s_n(&ti_t_o<E8>() )) return F8;
        if (s_n == ti_s_n(&ti_t_o<E9>() )) return F9;
        if (s_n == ti_s_n(&ti_t_o<E10>())) return F10;
        if (s_n == ti_s_n(&ti_t_o<E11>())) return F11;
        if (s_n == ti_s_n(&ti_t_o<E12>())) return F12;
        if (s_n == ti_s_n(&ti_t_o<E13>())) return F13;
        if (s_n == ti_s_n(&ti_t_o<E14>())) return F14;
        if (s_n == ti_s_n(&ti_t_o<E15>())) return F15;
        if (s_n == ti_s_n(&ti_t_o<E16>())) return F16;
        if (s_n == ti_s_n(&ti_t_o<E17>())) return F17;
        if (s_n == ti_s_n(&ti_t_o<E18>())) return F18;
        if (s_n == ti_s_n(&ti_t_o<E19>())) return F19;
        abort E_WRONG_EXPONENT_T // Else abort
    }

    /// Assert `a1` equals `a2`, aborting with code `e` if not
    fun verify_address(
        a1: address,
        a2: address,
        e: u64
    ) {
        assert!(a1 == a2, e); // Assert equality
    }

    /// Assert `s1` equals `s2`, aborting with code `e` if not
    fun verify_bytestring(
        bs1: vector<u8>,
        bs2: vector<u8>,
        e: u64
    ) {
        assert!(bs1 == bs2, e); // Assert equality
    }

    /// Assert `B` and `Q` are coins, and that `E` is scale exponent
    fun verify_market_types<B, Q, E>() {
        assert!(c_i_c_i<B>(), E_NOT_COIN); // Assert base quote type
        assert!(c_i_c_i<Q>(), E_NOT_COIN); // Assert quote coin type
        // Assert scale exponent type has corresponding scale factor
        scale_factor<E>();
    }

    /// Assert `t1` equals `t2`, aborting with code `e` if not
    fun verify_t(
        t1: &TI,
        t2: &TI,
        e: u64
    ) {
        verify_address(ti_a_a(t1), ti_a_a(t2), e); // Verify address
        verify_bytestring(ti_m_n(t1), ti_m_n(t2), e); // Verify module
        verify_bytestring(ti_s_n(t1), ti_s_n(t2), e); // Verify struct
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    #[test_only]
    /// Initialize base and quote coin types under Econia account
    fun init_coin_types(
        econia: &signer
    ) {
        // Assert initializing coin types under Econia account
        assert!(s_a_o(econia) == @Econia, 0);
        // Initialize base coin type, storing mint/burn capabilities
        let(m, b) = c_i<BCT>(econia, a_s(BCT_CN), a_s(BCT_CS), BCT_D, false);
        // Save capabilities in global storage
        move_to(econia, BCC{m, b});
        // Initialize quote coin type, storing mint/burn capabilities
        let(m, b) = c_i<QCT>(econia, a_s(QCT_CN), a_s(QCT_CS), QCT_D, false);
        // Save capabilities in global storage
        move_to(econia, QCC{m, b});
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify registry publication fails for non-Econia account
    public(script) fun init_registry_failure(
        account: &signer
    ) {
        init_registry(account); // Attempt invalid initialization
    }

    #[test(econia = @Econia)]
    /// Verify registry publish correctly
    public(script) fun init_registry_success(
        econia: &signer
    ) {
        init_registry(econia); // Initialize registry
        // Assert exists at Econia account
        assert!(exists<MR>(s_a_o(econia)), 0);
    }

    #[test]
    /// Pack market info and verify fields
    fun pack_market_info() {
        // Pack market info for test coin types
        let m_i = MI{b: ti_t_o<BCT>(), q: ti_t_o<QCT>(), e: ti_t_o<E2>()};
        verify_t(&m_i.b, &ti_t_o<BCT>(), 0); // Verify base coin type
        verify_t(&m_i.q, &ti_t_o<QCT>(), 1); // Verify quote coin type
        // Verify scale exponent type
        verify_t(&m_i.e, &ti_t_o<E2>(), 2);
    }

    #[test(
        econia = @Econia,
        host = @TestUser
    )]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for uninitialized market registry
    public(script) fun register_market_failure_no_registry(
        econia: &signer,
        host: &signer
    ) acquires MR {
        init_coin_types(econia); // Initialize coin types
        // Attempt invalid registration
        register_market<BCT, QCT, E0>(host);
    }

/*
    #[test(
        econia = @Econia,
        host = @TestUser
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempted re-registration
    public(script) fun register_market_failure_registered(
        econia: &signer,
        host: &signer
    ) acquires MR {
        init_coin_types(econia); // Initialize coin types
        init_registry(econia); // Initialize registry
        register_market<BCT, QCT, E0>(host); // Register market
    }
*/

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for invalid type
    fun scale_factor_failure() {scale_factor<E20>();}

    #[test]
    /// Verify successful return for all scale exponent types
    fun scale_factor_success() {
        assert!(scale_factor<E0>()  == F0 , 0 );
        assert!(scale_factor<E1>()  == F1 , 1 );
        assert!(scale_factor<E2>()  == F2 , 2 );
        assert!(scale_factor<E3>()  == F3 , 3 );
        assert!(scale_factor<E4>()  == F4 , 4 );
        assert!(scale_factor<E5>()  == F5 , 5 );
        assert!(scale_factor<E6>()  == F6 , 6 );
        assert!(scale_factor<E7>()  == F7 , 7 );
        assert!(scale_factor<E8>()  == F8 , 8 );
        assert!(scale_factor<E9>()  == F9 , 9 );
        assert!(scale_factor<E10>() == F10, 10);
        assert!(scale_factor<E11>() == F11, 11);
        assert!(scale_factor<E12>() == F12, 12);
        assert!(scale_factor<E13>() == F13, 13);
        assert!(scale_factor<E14>() == F14, 14);
        assert!(scale_factor<E15>() == F15, 15);
        assert!(scale_factor<E16>() == F16, 16);
        assert!(scale_factor<E17>() == F17, 17);
        assert!(scale_factor<E18>() == F18, 18);
        assert!(scale_factor<E19>() == F19, 19);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify abort for different address
    fun verify_address_failure() {
        verify_address(@TestUser, @Econia, E_NOT_ECONIA);
    }

    #[test]
    /// Verify no error raised for same address
    fun verify_address_success() {
        verify_address(@Econia, @Econia, 0);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify abort for different bytestrings
    fun verify_bytestring_failure() {
        verify_bytestring(M_NAME, b"foo", E_WRONG_MODULE);
    }

    #[test]
    /// Verify no error raised for same bytestring
    fun verify_bytestring_success() {
        verify_bytestring(M_NAME, M_NAME, 0);
    }

    #[test(econia = @Econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid base coin type
    fun verify_market_types_failure_b(
        econia: &signer
    ) {
        init_coin_types(econia); // Initialize coins
        // Pass invalid base coin type
        verify_market_types<E0, QCT, E0>();
    }

    #[test(econia = @Econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid quote coin type
    fun verify_market_types_failure_q(
        econia: &signer
    ) {
        init_coin_types(econia); // Initialize coins
        // Pass invalid quote coin type
        verify_market_types<BCT, E0, E0>();
    }

    #[test(econia = @Econia)]
    /// Verify success for all valid types
    fun verify_market_types_success(
        econia: &signer
    ) {
        init_coin_types(econia); // Initialize coins
        verify_market_types<BCT, QCT, E0>(); // Verify sample market
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}