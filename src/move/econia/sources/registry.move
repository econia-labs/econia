module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use aptos_framework::type_info;
    use econia::capability::EconiaCapability;
    use econia::open_table;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::coins::{BC, init_coin_types, QC};

    #[test_only]
    use econia::capability::{get_econia_capability_test};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
    struct CustodianCapability has store {
        /// Serial ID generated upon registration as a custodian
        custodian_id: u64
    }

    /// Type info for a `<B, Q, E>`-style market
    struct MarketInfo has copy, drop, store {
        /// Generic `CoinType` of `aptos_framework::coin::Coin`
        base_coin_type: type_info::TypeInfo,
        /// Generic `CoinType` of `aptos_framework::coin::Coin`
        quote_coin_type: type_info::TypeInfo,
        /// Scale exponent type defined in this module
        scale_exponent_type: type_info::TypeInfo
    }

    /// Container for core key-value pair maps
    struct Registry has key {
        /// Map from scale exponent type (like `E0` or `E12`) to scale
        /// factor value (like `F0` or `F12`)
        scales: open_table::OpenTable<type_info::TypeInfo, u64>,
        /// Map from market to the order book host address
        markets: open_table::OpenTable<MarketInfo, address>,
        /// Number of custodians who have registered
        n_custodians: u64,
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
    /// When base type is not a valid coin
    const E_NOT_COIN_BASE: u64 = 4;
    /// When quote type is not a valid coin
    const E_NOT_COIN_QUOTE: u64 = 5;
    /// When base and quote type are same
    const E_SAME_COIN_TYPE: u64 = 6;
    /// When a given market is already registered
    const E_MARKET_EXISTS: u64 = 7;
    /// When no such market exists
    const E_MARKET_NOT_REGISTERED: u64 = 8;
    /// When a coin is neither base nor quote on given market
    const E_NOT_IN_MARKET_PAIR: u64 = 9;

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

    /// Return `true` if `CoinType` is either base or quote coin in
    /// `market_info`
    public fun coin_is_in_market_pair<CoinType>(
        market_info: &MarketInfo
    ): bool {
        // Get coin type info
        let coin_type_info = type_info::type_of<CoinType>();
        // Return if coin is either base or quote
        coin_type_info == market_info.base_coin_type ||
        coin_type_info == market_info.quote_coin_type
    }

    /// Return `true` if `CoinType` is base coin in `market_info`,
    /// `false` if is quote coin, and abort otherwise
    public fun coin_is_base_coin<CoinType>(
        market_info: &MarketInfo
    ): bool {
        // Get coin type info
        let coin_type_info = type_info::type_of<CoinType>();
        // Return true if base coin match
        if (coin_type_info ==  market_info.base_coin_type) return true;
        // Return false if quote coin match
        if (coin_type_info ==  market_info.quote_coin_type) return false;
        abort E_NOT_IN_MARKET_PAIR // Else abort
    }

    /// Return serial ID of `CustodianCapability`
    public fun custodian_id(
        custodian_capability_ref: &CustodianCapability
    ): u64 {
        custodian_capability_ref.custodian_id // Return serial ID
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
            n_custodians: 0
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

    /// Pack provided type arguments into a `MarketInfo` and return
    public fun market_info<B, Q, E>(
    ): MarketInfo {
        MarketInfo{
            base_coin_type: type_info::type_of<B>(),
            quote_coin_type: type_info::type_of<Q>(),
            scale_exponent_type: type_info::type_of<E>(),
        }
    }

    /// Return the number of registered custodians, aborting if registry
    /// is not initialized
    public fun n_custodians():
    u64
    acquires Registry {
        // Assert registry exists
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Return number of registered custodians
        borrow_global<Registry>(@econia).n_custodians
    }

    /// Register a market for the given base type, quote type,
    /// scale exponent type, and `host`, provided an immutable reference
    /// to an `EconiaCapability`.
    ///
    /// # Abort conditions
    /// * If registry is not initialized
    /// * If either of `B` or `Q` are not valid coin types
    /// * If `B` and `Q` are the same type
    /// * If market is already registered
    /// * If `E` is not a valid scale exponent type
    public fun register_market_internal<B, Q, E>(
        host: address,
        _econia_capability: &EconiaCapability
    ) acquires Registry {
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
        // Assert base and quote not same type
        assert!(base_coin_type != quote_coin_type, E_SAME_COIN_TYPE);
        // Get scale exponent type type info
        let scale_exponent_type = type_info::type_of<E>();
        // Borrow mutable reference to registry
        let registry = borrow_global_mut<Registry>(@econia);
        assert!(open_table::contains(&registry.scales, scale_exponent_type),
            E_NOT_EXPONENT_TYPE); // Verify valid exponent type
        let market_info = MarketInfo{base_coin_type, quote_coin_type,
            scale_exponent_type}; // Pack new market info for types
        assert!(!open_table::contains(&registry.markets, market_info),
            E_MARKET_EXISTS); // Assert market is not already registered
        // Register host-market relationship
        open_table::add(&mut registry.markets, market_info, host);
    }

    /// Wrapper for `scale_factor_from_type_info()`, for type argument
    public fun scale_factor<E>():
    u64
    acquires Registry {
        // Pass type info, returning result
        scale_factor_from_type_info(type_info::type_of<E>())
    }

    /// Return scale factor corresponding to `scale_exponent_type_info`,
    /// aborting if registry not initialized or if an invalid type
    public fun scale_factor_from_type_info(
        scale_exponent_type_info: type_info::TypeInfo
    ): u64
    acquires Registry {
        // Assert registry initialized under Econia account
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Borrow immutable reference to scales table
        let scales = &borrow_global<Registry>(@econia).scales;
        // Assert valid exponent type passed
        assert!(open_table::contains(scales, scale_exponent_type_info),
            E_NOT_EXPONENT_TYPE);
        // Return scale factor corresponding to scale exponent type
        *open_table::borrow(scales, scale_exponent_type_info)
    }

    /// Wrapper for `scale_factor_from_type_info()`, for `MarketInfo`
    /// reference
    public fun scale_factor_from_market_info(
        market_info: &MarketInfo
    ): u64
    acquires Registry {
        // Return query on accessed field
        scale_factor_from_type_info(market_info.scale_exponent_type)
    }

    /// Return `true` if `MarketInfo` is registered, else `false`
    public fun is_registered(
        market_info: MarketInfo
    ): bool
    acquires Registry {
        // Return false if no registry initialized
        if (!exists<Registry>(@econia)) return false;
        // Borrow mutable reference to registry
        let registry = borrow_global_mut<Registry>(@econia);
        // Return if market registry cointains given market info
        open_table::contains(&registry.markets, market_info)
    }

    /// Wrapper for `is_registered()`, accepting type arguments
    public fun is_registered_types<B, Q, E>():
    bool
    acquires Registry {
        // Pass type argument market info info
        is_registered(market_info<B, Q, E>())
    }

    /// Return `true` if `custodian_id` has already been registered
    public fun is_valid_custodian_id(
        custodian_id: u64
    ): bool
    acquires Registry {
        // Return false if registry hasn't been initialized
        if (!exists<Registry>(@econia)) return false;
        custodian_id <= n_custodians() // Return if custodian ID valid
    }

    /// Update the number of registered custodians and issue a
    /// `CustodianCapability` with the corresponding serial ID. Abort if
    /// registry is not initialized
    public fun register_custodian_capability():
    CustodianCapability
    acquires Registry {
        // Assert the registry is already initialized
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Borrow mutable reference to registy
        let registry = borrow_global_mut<Registry>(@econia);
        // Set custodian serial ID to the new number of custodians
        let custodian_id = registry.n_custodians + 1;
        // Update the registry for the new count
        registry.n_custodians = custodian_id;
        // Pack and return corresponding capability
        CustodianCapability{custodian_id}
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Initialize registry, register test coin markets
    public fun register_test_market_internal(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module's core resources
        init_coin_types(econia); // Initialize test coins
        register_market_internal<BC, QC, E1>( // Register test market
            @econia, &get_econia_capability_test());
    }

    #[test_only]
    /// Destroy `custodian_capability`
    public fun destroy_custodian_capability(
        custodian_capability: CustodianCapability
    ) {
        // Unpack passed capability
        CustodianCapability{custodian_id: _} = custodian_capability;
    }

    #[test_only]
    /// Return `CustodianCapability` with `custodian_id`
    public fun get_custodian_capability(
        custodian_id: u64
    ): CustodianCapability {
        CustodianCapability{custodian_id} // Pack and return capability
    }

    #[test_only]
    /// Update registry to indicate `custodian_id` as valid. Assumes
    /// registry already initialized under Econia account.
    public fun set_registered_custodian(
        custodian_id: u64
    ) acquires Registry {
        // Set registered custodian count to include given ID
        borrow_global_mut<Registry>(@econia).n_custodians = custodian_id;
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify correct returns
    fun test_coin_is_in_market_pair() {
        // Define mock market info
        let market_info = MarketInfo{
            base_coin_type: type_info::type_of<BC>(),
            quote_coin_type: type_info::type_of<QC>(),
            scale_exponent_type: type_info::type_of<E1>()};
        // Assert base coin returns true
        assert!(coin_is_in_market_pair<BC>(&market_info), 0);
        // Assert quote coin returns true
        assert!(coin_is_in_market_pair<QC>(&market_info), 0);
        // Assert scale exponent type returns false
        assert!(!coin_is_in_market_pair<E1>(&market_info), 0);
    }

    #[test]
    /// Verify correct returns
    fun test_coin_is_base_coin() {
        // Define mock market info
        let market_info = MarketInfo{
            base_coin_type: type_info::type_of<BC>(),
            quote_coin_type: type_info::type_of<QC>(),
            scale_exponent_type: type_info::type_of<E1>()};
        // Assert base coin returns true
        assert!(coin_is_base_coin<BC>(&market_info), 0);
        // Assert quote coin returns false
        assert!(!coin_is_base_coin<QC>(&market_info), 0);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for neither base nor quote coin match
    fun test_coin_is_base_coin_neither() {
        // Define mock market info
        let market_info = MarketInfo{
            base_coin_type: type_info::type_of<BC>(),
            quote_coin_type: type_info::type_of<QC>(),
            scale_exponent_type: type_info::type_of<E1>()};
        // Attempt invalid check
        coin_is_base_coin<E1>(&market_info);
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
    fun test_init_registry_not_econia(
        account: &signer
    ) acquires Registry {
        init_registry(account); // Attempt invalid init
    }

    #[test]
    /// Verify false return for uninitialized registry
    fun test_is_registered_no_registry()
    acquires Registry {
        // Assert false return
        assert!(!is_registered_types<BC, QC, E0>(), 0);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not initialized
    fun test_n_custodians_no_registry()
    acquires Registry {
        n_custodians(); // Attempt invalid query
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not initialized
    fun test_register_custodian_capability_no_registry():
    CustodianCapability
    acquires Registry {
        register_custodian_capability() // Attempt invalid registration
    }

    #[test(econia = @econia)]
    /// Verify custodian returns
    fun test_register_custodian_capability(
        econia: &signer
    ): (
        CustodianCapability,
        CustodianCapability
    )
    acquires Registry {
        // Verify 0 is invalid custodian ID
        assert!(!is_valid_custodian_id(0), 0);
        init_registry(econia); // Initialize registry
        // Verify 0 is valid custodian ID
        assert!(is_valid_custodian_id(0), 0);
        // Verify 1 is invalid custodian ID
        assert!(!is_valid_custodian_id(1), 0);
        assert!(n_custodians() == 0, 0); // Assert custodian count
        // Register custodianship
        let first_cap = register_custodian_capability();
        assert!(n_custodians() == 1, 0); // Assert custodian count
        // Verify 0 is valid custodian ID
        assert!(is_valid_custodian_id(0), 0);
        // Verify 1 is valid custodian ID
        assert!(is_valid_custodian_id(1), 0);
        // Register custodianship
        let second_cap = register_custodian_capability();
        // Verify 2 is valid custodian ID
        assert!(is_valid_custodian_id(2), 0);
        assert!(n_custodians() == 2, 0); // Assert custodian count
        // Assert serial IDs administered correctly
        assert!(custodian_id(&first_cap) == 1, 0);
        assert!(custodian_id(&second_cap) == 2, 0);
        // Assert registry counter correct
        assert!(borrow_global_mut<Registry>(@econia).n_custodians == 2, 0);
        (first_cap, second_cap)
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for base type not a valid coin type
    fun test_register_market_internal_base_not_coin(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        register_market_internal<E0, QC, E0>( // Attempt invalid init
            @econia, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for market already exists
    fun test_register_market_internal_duplicate(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module
        init_coin_types(econia); // Initialize coin types
        register_market_internal<BC, QC, E0>( // Run valid initialization
            @econia, &get_econia_capability_test());
        register_market_internal<BC, QC, E0>( // Attempt invalid init
            @econia, &get_econia_capability_test());
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not yet initialized
    fun test_register_market_internal_no_registry()
    acquires Registry {
        register_market_internal<BC, QC, E0>( // Attempt invalid init
            @user, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for invalid exponent type
    fun test_register_market_internal_not_exponent_type(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module
        init_coin_types(econia); // Initialize coin types
        register_market_internal<BC, QC, QC>( // Attempt invalid init
            @econia, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for quote type not a valid coin type
    fun test_register_market_internal_quote_not_coin(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        register_market_internal<BC, E0, E0>( // Attempt invalid init
            @econia, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for base and quote are same type
    fun test_register_market_internal_same_coin(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        init_coin_types(econia); // Initialize coin types
        register_market_internal<BC, BC, E0>( // Attempt invalid init
            @econia, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    /// Verify successful market registration
    fun test_register_market_internal_success(
        econia: &signer,
    ) acquires Registry {
        init_registry(econia); // Init registry
        init_coin_types(econia); // Initialize coin types
        register_market_internal<BC, QC, E2>(
        // Run valid initialization
            @user, &get_econia_capability_test());
        // Borrow immutable reference to registry
        let registry = borrow_global<Registry>(@econia);
        // Get market info for given market
        let market_info = MarketInfo{
            base_coin_type: type_info::type_of<BC>(),
            quote_coin_type: type_info::type_of<QC>(),
            scale_exponent_type: type_info::type_of<E2>()};
        // Borrow immutable reference to market host
        assert!( // Assert correct host registration
            *open_table::borrow(&registry.markets, market_info) == @user, 0);
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
        assert!(scale_factor_from_market_info(&MarketInfo{
            base_coin_type: type_info::type_of<BC>(),
            quote_coin_type: type_info::type_of<QC>(),
            scale_exponent_type: type_info::type_of<E19>()}) == F19, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}