module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::type_info;
    use econia::open_table;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Scale exponent types
    /// Corresponds to `F0`
    struct E0{}
    /// Corresponds to `F1`
    struct E1{}
    /// Corresponds to `F2`
    struct E2{}
    /// Corresponds to `F3`
    struct E3{}
    /// Corresponds to `F4`
    struct E4{}
    /// Corresponds to `F5`
    struct E5{}
    /// Corresponds to `F6`
    struct E6{}
    /// Corresponds to `F7`
    struct E7{}
    /// Corresponds to `F8`
    struct E8{}
    /// Corresponds to `F9`
    struct E9{}
    /// Corresponds to `F10`
    struct E10{}
    /// Corresponds to `F11`
    struct E11{}
    /// Corresponds to `F12`
    struct E12{}
    /// Corresponds to `F13`
    struct E13{}
    /// Corresponds to `F14`
    struct E14{}
    /// Corresponds to `F15`
    struct E15{}
    /// Corresponds to `F16`
    struct E16{}
    /// Corresponds to `F17`
    struct E17{}
    /// Corresponds to `F18`
    struct E18{}
    /// Corresponds to `F19`
    struct E19{}

    /// Custodian capability used to manage delegated trading
    /// permissions, administered to third-party registrants who may
    /// store it as they wish.
    struct CustodianCapability<phantom B, phantom Q, phantom E> has store {
        /// Serial ID, for the given market, generated upon registration
        /// as a custodian
        custodian_id: u64
    }

    /// Type info for a `<B, Q, E>`-style market
    struct MarketInfo has copy, drop, store {
        /// Generic `CoinType` of `aptos_framework::coin::Coin`
        base_coin_type: type_info::TypeInfo,
        /// Generic `CoinType` of `aptos_framework::coin::Coin`
        quote_coin_type: type_info::TypeInfo,
        /// Scale exponent type defined in this module
        scale_exponent: type_info::TypeInfo
    }

    /// Container for core key-value pair maps
    struct Registry has key {
        /// Map from scale exponent type (like `E0` or `E12`) to scale
        /// factor value (like `F0` or `F12`)
        scales: open_table::OpenTable<type_info::TypeInfo, u64>,
        /// Map from market to the order book host address
        hosts: open_table::OpenTable<MarketInfo, address>,
        /// Map from market to the last version number during which a
        /// custodian-facilitated order was placed for the given market.
        /// Only one such order permitted per transaction, per market,
        /// to ensure that users do not end up submitting orders having
        /// the same encoded version number within a given order book.
        /// Without this protocol-wide counter, it would be possible for
        /// a third party to simply register as a custodian multiple
        /// times, aggregate multiple `CustodianCapability` instances,
        /// then pass them in succession to circumvent other forms of
        /// error-checking.
        custodian_counters: open_table::OpenTable<MarketInfo, u64>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When caller is not Econia
    const E_NOT_ECONIA: u64 = 0;
    /// When registry already initialized
    const E_REGISTRY_EXISTS: u64 = 1;
    /// When registry not already initialized
    const E_NO_REGISTRY: u64 = 2;
    /// When looking up a type that is not a valid scale exponent
    const E_NOT_EXPONENT_TYPE: u64 = 3;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Scale factors
    /// Corresponds to `E0`
    const F0 : u64 = 1;
    /// Corresponds to `E1`
    const F1 : u64 = 10;
    /// Corresponds to `E2`
    const F2 : u64 = 100;
    /// Corresponds to `E3`
    const F3 : u64 = 1000;
    /// Corresponds to `E4`
    const F4 : u64 = 10000;
    /// Corresponds to `E5`
    const F5 : u64 = 100000;
    /// Corresponds to `E6`
    const F6 : u64 = 1000000;
    /// Corresponds to `E7`
    const F7 : u64 = 10000000;
    /// Corresponds to `E8`
    const F8 : u64 = 100000000;
    /// Corresponds to `E9`
    const F9 : u64 = 1000000000;
    /// Corresponds to `E10`
    const F10: u64 = 10000000000;
    /// Corresponds to `E11`
    const F11: u64 = 100000000000;
    /// Corresponds to `E12`
    const F12: u64 = 1000000000000;
    /// Corresponds to `E13`
    const F13: u64 = 10000000000000;
    /// Corresponds to `E14`
    const F14: u64 = 100000000000000;
    /// Corresponds to `E15`
    const F15: u64 = 1000000000000000;
    /// Corresponds to `E16`
    const F16: u64 = 10000000000000000;
    /// Corresponds to `E17`
    const F17: u64 = 100000000000000000;
    /// Corresponds to `E18`
    const F18: u64 = 1000000000000000000;
    /// Corresponds to `E19`
    const F19: u64 = 10000000000000000000;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Move empty registry to the Econia account, then add scale map
    public fun init_registry(
        account: &signer,
    ) acquires Registry {
        // Assert caller is Econia account
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Assert registry does not already exist at Econia account
        assert!(!exists<Registry>(@econia), E_REGISTRY_EXISTS);
        // Move an empty registry to the Econia Account
        move_to<Registry>(account, Registry{
            scales: open_table::empty(),
            hosts: open_table::empty(),
            custodian_counters: open_table::empty()
        });
        // Borrow mutable reference to the scales table
        let scales = &mut borrow_global_mut<Registry>(@econia).scales;
        // Add all entries to map from scale exponent to scale factor
        open_table::add(scales, type_info::type_of<E0>(), F0);
        open_table::add(scales, type_info::type_of<E1>(), F1);
        open_table::add(scales, type_info::type_of<E2>(), F2);
        open_table::add(scales, type_info::type_of<E3>(), F3);
        open_table::add(scales, type_info::type_of<E4>(), F4);
        open_table::add(scales, type_info::type_of<E5>(), F5);
        open_table::add(scales, type_info::type_of<E6>(), F6);
        open_table::add(scales, type_info::type_of<E7>(), F7);
        open_table::add(scales, type_info::type_of<E8>(), F8);
        open_table::add(scales, type_info::type_of<E9>(), F9);
        open_table::add(scales, type_info::type_of<E10>(), F10);
        open_table::add(scales, type_info::type_of<E11>(), F11);
        open_table::add(scales, type_info::type_of<E12>(), F12);
        open_table::add(scales, type_info::type_of<E13>(), F13);
        open_table::add(scales, type_info::type_of<E14>(), F14);
        open_table::add(scales, type_info::type_of<E15>(), F15);
        open_table::add(scales, type_info::type_of<E16>(), F16);
        open_table::add(scales, type_info::type_of<E17>(), F17);
        open_table::add(scales, type_info::type_of<E18>(), F18);
        open_table::add(scales, type_info::type_of<E19>(), F19);
    }

    /// Return scale factor corresponding to scale exponent type `E`,
    /// aborting if registry not initialized or if an invalid type
    public fun scale_factor<E>():
    u64
    acquires Registry {
        // Assert registry initialized under Econia account
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Get type info of passed exponent
        let type_info = type_info::type_of<E>();
        // Borrow immutable reference to scales table
        let scales = &borrow_global<Registry>(@econia).scales;
        // Assert valid exponent type passed
        assert!(open_table::contains(scales, type_info), E_NOT_EXPONENT_TYPE);
        // Return scale factor corresponding to scale exponent type
        *open_table::borrow(scales, type_info)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Invalid scale exponent type
    struct E20{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @econia)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to re-init under Econia account
    fun test_init_has_registry(
        account: &signer
    ) acquires Registry {
        init_registry(account); // Execute valid initialization
        init_registry(account); // Attempt invalid init
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempting to init under non-Econia account
    fun test_init_not_econia(
        account: &signer
    ) acquires Registry {
        init_registry(account); // Attempt invalid init
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for looking up invalid scale exponent type
    fun test_scale_factor_invalid_type(
        econia: &signer
    )
    acquires Registry {
        init_registry(econia); // Initialize registry
        scale_factor<E20>(); // Attempt invalid lookup
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for looking up scale factor when no registry
    fun test_scale_factor_no_registry() acquires Registry {scale_factor<E0>();}

    #[test(econia = @econia)]
    /// Verify lookup returns
    fun test_scale_factor_returns(
        econia: &signer
    )
    acquires Registry {
        init_registry(econia); // Initialize registry
        // Assert lookup returns
        assert!(scale_factor<E0>() == F0, 0);
        assert!(scale_factor<E0>() == F0, 0);
        assert!(scale_factor<E1>() == F1, 0);
        assert!(scale_factor<E2>() == F2, 0);
        assert!(scale_factor<E3>() == F3, 0);
        assert!(scale_factor<E4>() == F4, 0);
        assert!(scale_factor<E5>() == F5, 0);
        assert!(scale_factor<E6>() == F6, 0);
        assert!(scale_factor<E7>() == F7, 0);
        assert!(scale_factor<E8>() == F8, 0);
        assert!(scale_factor<E9>() == F9, 0);
        assert!(scale_factor<E10>() == F10, 0);
        assert!(scale_factor<E11>() == F11, 0);
        assert!(scale_factor<E12>() == F12, 0);
        assert!(scale_factor<E13>() == F13, 0);
        assert!(scale_factor<E14>() == F14, 0);
        assert!(scale_factor<E15>() == F15, 0);
        assert!(scale_factor<E16>() == F16, 0);
        assert!(scale_factor<E17>() == F17, 0);
        assert!(scale_factor<E18>() == F18, 0);
        assert!(scale_factor<E19>() == F19, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}