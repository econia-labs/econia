module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use aptos_framework::type_info;
    use econia::book;
    use econia::open_table;
    use econia::capability::{Self, EconiaCapability};
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

    /// Stores an `EconiaCapability` for cross-module authorization
    struct EconiaCapabilityStore has key {
        econia_capability: EconiaCapability
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

    /// Tracks address of order book host and number of registered
    /// custodians for a given market
    struct MarketAffiliates has copy, drop, store {
        /// Where market's order book is hosted
        host: address,
        /// Number of custodians registered on the market
        n_custodians: u64
    }

    /// Container for core key-value pair maps
    struct Registry has key {
        /// Map from scale exponent type (like `E0` or `E12`) to scale
        /// factor value (like `F0` or `F12`)
        scales: open_table::OpenTable<type_info::TypeInfo, u64>,
        /// Map from market to the order book host address
        markets: open_table::OpenTable<MarketInfo, MarketAffiliates>,
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
    /// When `EconiaCapabilityStore` already exists
    const E_HAS_CAPABILITY: u64 = 4;
    /// When base type is not a valid coin
    const E_NOT_COIN_BASE: u64 = 5;
    /// When quote type is not a valid coin
    const E_NOT_COIN_QUOTE: u64 = 6;
    /// When base and quote type are same
    const E_SAME_COIN_TYPE: u64 = 7;
    /// When a given market is already registered
    const E_MARKET_EXISTS: u64 = 8;

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

    /// Initializes an `EconiaCapabilityStore`, aborting if one already
    /// exists under the Econia account or if caller is not Econia
    public fun init_econia_capability_store(
        account: &signer
    ) {
        // Assert capability store not already registered
        assert!(!exists<EconiaCapabilityStore>(@econia), E_HAS_CAPABILITY);
        // Get new capability instance (aborts if caller is not Econia)
        let econia_capability = capability::get_econia_capability(account);
        move_to<EconiaCapabilityStore>(account, EconiaCapabilityStore{
            econia_capability}); // Move to account capability store
    }

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
            markets: open_table::empty(),
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

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register the market for given base, quote, exponent types,
    /// initializing an order book under `host` account
    ///
    /// # Abort conditions
    /// * If registry is not initialized
    /// * If either of `B` or `Q` are not valid coin types
    /// * If `B` and `Q` are the same type
    /// * If market is already registered
    /// * If `E` is not a valid scale exponent type
    public entry fun register_market<B, Q, E>(
        host: &signer
    ) acquires EconiaCapabilityStore, Registry {
        // Assert the registry is already initialized
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Assert base type is a valid coin type
        assert!(coin::is_coin_initialized<B>(), E_NOT_COIN_BASE);
        // Assert quote type is a valid coin type
        assert!(coin::is_coin_initialized<Q>(), E_NOT_COIN_QUOTE);
        // Get base type type info
        let base_coin_type = type_info::type_of<B>();
        // Get quote type type info
        let quote_coin_type = type_info::type_of<Q>();
        assert!(!( // Assert base and quote are not same type
            type_info::account_address(&base_coin_type) ==
                type_info::account_address(&quote_coin_type) &&
            type_info::module_name(&base_coin_type) ==
                type_info::module_name(&quote_coin_type) &&
            type_info::struct_name(&base_coin_type) ==
                type_info::struct_name(&quote_coin_type)), E_SAME_COIN_TYPE);
        // Get scale factor (aborts if not a valid scale exponent type)
        let scale_factor = scale_factor<E>();
        // Pack new market info for given types
        let market_info = MarketInfo{base_coin_type, quote_coin_type,
            scale_exponent: type_info::type_of<E>()};
        // Borrow mutable reference to registry
        let registry = borrow_global_mut<Registry>(@econia);
        // Assert the market is not already registered
        assert!(!open_table::contains(&registry.markets, market_info),
            E_MARKET_EXISTS);
        // Register host-market relationship, mark 0 custodians
        open_table::add(&mut registry.markets, market_info, MarketAffiliates{
            host: address_of(host), n_custodians: 0});
        // Initialize book under host account
        book::init_book<B, Q, E>(host, scale_factor, &get_econia_capability());
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an `EconiaCapability`
    ///
    /// # Assumes
    /// * `EconiaCapabilityStore` has already been successfully
    ///   initialized, and thus skips existence checks
    fun get_econia_capability():
    EconiaCapability
    acquires EconiaCapabilityStore {
        borrow_global<EconiaCapabilityStore>(@econia).econia_capability
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::coins::{
        BC,
        init_coin_types,
        QC
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempting to re-init under Econia account
    fun test_init_econia_capability_store_exists(
        econia: &signer
    ) {
        init_econia_capability_store(econia); // Initialize store
        init_econia_capability_store(econia); // Attempt invalid re-init
    }

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
        scale_factor<BC>(); // Attempt invalid lookup
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for base type not a valid coin type
    fun test_register_market_base_not_coin(
        econia: &signer
    ) acquires EconiaCapabilityStore, Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        register_market<E0, QC, E0>(econia); // Attempt invalid init
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for market already exists
    fun test_register_market_duplicate(
        econia: &signer
    ) acquires EconiaCapabilityStore, Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        init_econia_capability_store(econia); // Initialize capability
        register_market<BC, QC, E0>(econia); // Run valid initialization
        register_market<BC, QC, E0>(econia); // Attempt invalid init
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not yet initialized
    fun test_register_market_no_registry(
        user: &signer
    ) acquires EconiaCapabilityStore, Registry {
        register_market<BC, QC, E0>(user); // Attempt invalid init
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for quote type not a valid coin type
    fun test_register_market_quote_not_coin(
        econia: &signer
    ) acquires EconiaCapabilityStore, Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        register_market<BC, E0, E0>(econia); // Attempt invalid init
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for base and quote are same type
    fun test_register_market_same_coin(
        econia: &signer
    ) acquires EconiaCapabilityStore, Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        register_market<BC, BC, E0>(econia); // Attempt invalid init
    }

    #[test(
        econia = @econia,
        host = @user
    )]
    /// Verify successful market registration
    fun test_register_market_success(
        econia: &signer,
        host: &signer
    ) acquires  EconiaCapabilityStore, Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        init_econia_capability_store(econia); // Initialize capability
        register_market<BC, QC, E2>(host); // Run valid initialization
        // Borrow immutable reference to registry
        let registry = borrow_global<Registry>(@econia);
        // Get market info for given market
        let market_info = MarketInfo{
            base_coin_type: type_info::type_of<BC>(),
            quote_coin_type: type_info::type_of<QC>(),
            scale_exponent: type_info::type_of<E2>()};
        // Borrow immutable reference to market affiliates
        let market_affiliates =
            open_table::borrow(&registry.markets, market_info);
        // Assert correct host registration
        assert!(market_affiliates.host == @user, 0);
        // Assert custodian count initializes to 0
        assert!(market_affiliates.n_custodians == 0, 0);
        // Assert scale factor initialized correctly
        assert!(book::scale_factor<BC, QC, E2>(@user,
            &get_econia_capability()) == F2, 0);
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