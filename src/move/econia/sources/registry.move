/// Econia-wide registry functionality. Provides permissionless market
/// registration and tracking, delegated custodian registration.
module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use aptos_std::type_info;
    use aptos_std::table;
    use econia::capability::EconiaCapability;
    use std::signer::address_of;
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{Self, BA, BC, MA, QA, QC};

    #[test_only]
    use econia::capability::{get_econia_capability_test};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian capability used to manage delegated trading
    /// permissions, administered to third-party registrants who may
    /// store it as they wish.
    struct CustodianCapability has store {
        /// Serial ID generated upon registration as a custodian
        custodian_id: u64
    }

    /// Unique identifier for a market
    struct MarketInfo has copy, drop, store {
        /// Account hosting corresponding `OrderBook`
        host: address,
        /// Trading pair parameters
        trading_pair_info: TradingPairInfo
    }

    /// Container for core registration information
    struct Registry has key {
        /// Map from trading pair to order book host address
        hosts: table::Table<TradingPairInfo, address>,
        /// List of all available markets
        markets: vector<MarketInfo>,
        /// Number of registered custodians
        n_custodians: u64,
    }

    /// Information about a trading pair
    struct TradingPairInfo has copy, drop, store {
        /// Base asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`.
        base_type_info: type_info::TypeInfo,
        /// Quote asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`.
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot
        lot_size: u64,
        /// Number of quote units exchanged per lot
        tick_size: u64,
        /// `true` if base asset is an `aptos_framework::coin::Coin`
        base_is_coin: bool,
        /// `true` if quote asset is an `aptos_framework::coin::Coin`
        quote_is_coin: bool,
        /// ID of custodian capability required to withdraw/deposit
        /// collateral for an asset that is not a coin. A "market-wide"
        /// collateral transfer custodian ID, required to verify deposit
        /// and withdraw amounts for asset-agnostic markets.
        custodian_id: u64,
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When caller is not Econia
    const E_NOT_ECONIA: u64 = 0;
    /// When registry already initialized
    const E_REGISTRY_EXISTS: u64 = 1;
    /// When registry not already initialized
    const E_NO_REGISTRY: u64 = 2;
    /// When lot size specified as 0
    const E_LOT_SIZE_0: u64 = 3;
    /// When tick size specified as 0
    const E_TICK_SIZE_0: u64 = 4;
    /// When invalid custodian ID
    const E_INVALID_CUSTODIAN: u64 = 5;
    /// When base and quote type are same
    const E_SAME_TYPE: u64 = 6;
    /// When a given market is already registered
    const E_MARKET_EXISTS: u64 = 7;
    /// When a type is neither base nor quote on given market
    const E_NOT_IN_MARKET_PAIR: u64 = 8;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return serial ID of `CustodianCapability`
    public fun custodian_id(
        custodian_capability_ref: &CustodianCapability
    ): u64 {
        custodian_capability_ref.custodian_id // Return serial ID
    }

    /// Move empty registry to the Econia account
    public fun init_registry(
        account: &signer,
    ) {
        // Assert caller is Econia account
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Assert registry does not already exist at Econia account
        assert!(!exists<Registry>(@econia), E_REGISTRY_EXISTS);
        // Move an empty registry to the Econia Account
        move_to<Registry>(account, Registry{
            hosts: table::new(),
            markets: vector::empty(),
            n_custodians: 0
        });
    }

    /// Return `true` if `T` is either base or quote in `market_info`
    public fun is_in_market_pair<T>(
        market_info: &MarketInfo
    ): bool {
        let type_info = type_info::type_of<T>(); // Get type info
        // Return if type is either base or quote
        type_info == market_info.trading_pair_info.base_type_info ||
        type_info == market_info.trading_pair_info.quote_type_info
    }

    /// Return `true` if `T` is base type in `market_info`, `false` if
    /// is quote type, and abort otherwise
    public fun is_market_base<T>(
        market_info: &MarketInfo
    ): bool {
        let type_info = type_info::type_of<T>(); // Get type info
        if (type_info ==  market_info.trading_pair_info.base_type_info)
            return true; // Return true if base match
        if (type_info ==  market_info.trading_pair_info.quote_type_info)
            return false; // Return false if quote match
        abort E_NOT_IN_MARKET_PAIR // Else abort
    }

    /// Return `true` if `custodian_id` has been registered
    public fun is_registered_custodian_id(
        custodian_id: u64
    ): bool
    acquires Registry {
        // Return false if registry hasn't been initialized
        if (!exists<Registry>(@econia)) return false;
        // Return if custodian ID has been registered
        custodian_id <= n_custodians() && custodian_id != NO_CUSTODIAN
    }

    /// Return `true` if `TradingPairInfo` is registered, else `false`
    public fun is_registered_trading_pair(
        trading_pair_info: TradingPairInfo
    ): bool
    acquires Registry {
        // Return false if no registry initialized
        if (!exists<Registry>(@econia)) return false;
        // Borrow immutable reference to registry
        let registry = borrow_global<Registry>(@econia);
        // Return if hosts table contains given trading pair info
        table::contains(&registry.hosts, trading_pair_info)
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

    /// Register a market, provided an immutable reference to an
    /// `EconiaCapability`.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `host`: Host of corresponding order book
    /// * `lot_size`: Number of base units exchanged per lot
    /// * `tick_size`: Number of quote units exchanged per lot
    /// * `custodian_id`: ID of custodian capability required
    ///   to withdraw/deposit collateral for an asset that is not a coin
    ///
    /// # Abort conditions
    /// * If registry is not initialized
    /// * If `BaseType` and `QuoteType` are the same
    /// * If `lot_size` is zero
    /// * If `tick_size` is zero
    /// * If market is already registered
    /// * If attempting to register an asset-agnostic order book for an
    ///   invalid `custodian_id`
    ///
    /// # Coin types
    /// When registering a market with an asset corresponding to an
    /// `aptos_framework::coin::Coin`, use only the phantom
    /// `CoinType` as a type parameter. For example pass `MyCoin` rather
    /// than `Coin<MyCoin>`.
    public fun register_market_internal<
        BaseType,
        QuoteType
    >(
        host: address,
        lot_size: u64,
        tick_size: u64,
        custodian_id: u64,
        _econia_capability: &EconiaCapability
    ) acquires Registry {
        // Assert the registry is already initialized
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Get base type info
        let base_type_info = type_info::type_of<BaseType>();
        // Get quote type info
        let quote_type_info = type_info::type_of<QuoteType>();
        // Assert base and quote not same type
        assert!(base_type_info != quote_type_info, E_SAME_TYPE);
        // Determine if base is a coin type
        let base_is_coin = coin::is_coin_initialized<BaseType>();
        // Determine if quote is a coin type
        let quote_is_coin = coin::is_coin_initialized<QuoteType>();
        // Assert lot size is nonzero
        assert!(lot_size > 0, E_LOT_SIZE_0);
        // Assert tick size is nonzero
        assert!(tick_size > 0, E_TICK_SIZE_0);
        // Pack corresponding trading pair info
        let trading_pair_info = TradingPairInfo{
            base_type_info, quote_type_info, lot_size, tick_size,
            base_is_coin, quote_is_coin, custodian_id};
        assert!(!is_registered_trading_pair(trading_pair_info),
            E_MARKET_EXISTS); // Assert market is not already registered
        if (!base_is_coin || !quote_is_coin) { // If asset-agnostic
            // Assert custodian ID has been registered
            assert!(is_registered_custodian_id(custodian_id),
                E_INVALID_CUSTODIAN);
        } else { // If both base and quote are coins
            // Assert no market-level custodian for withdraw/deposits
            assert!(custodian_id == NO_CUSTODIAN, E_INVALID_CUSTODIAN);
        };
        // Borrow mutable reference to registry
        let registry = borrow_global_mut<Registry>(@econia);
        // Register host for given trading pair
        table::add(&mut registry.hosts, trading_pair_info, host);
        // Push back onto markets list a packed market info
        vector::push_back(&mut registry.markets,
            MarketInfo{host, trading_pair_info});
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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
    /// Return a mock `MarketInfo`
    fun get_market_info_test():
    MarketInfo {
        MarketInfo{
            trading_pair_info: TradingPairInfo{
                base_type_info: type_info::type_of<BC>(),
                quote_type_info: type_info::type_of<QC>(),
                lot_size: 100,
                tick_size: 25,
                base_is_coin: true,
                quote_is_coin: true,
                custodian_id: NO_CUSTODIAN
            },
            host: @user
        }
    }

    #[test_only]
    /// Update registry to indicate `custodian_id` as valid. Assumes
    /// registry already initialized under Econia account.
    public fun set_registered_custodian_test(
        custodian_id: u64
    ) acquires Registry {
        // Set registered custodian count to include given ID
        borrow_global_mut<Registry>(@econia).n_custodians = custodian_id;
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @econia)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to re-init under Econia account
    fun test_init_registry_has_registry(
        account: &signer
    ) {
        init_registry(account); // Execute valid initialization
        init_registry(account); // Attempt invalid init
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempting to init under non-Econia account
    fun test_init_registry_not_econia(
        account: &signer
    ) {
        init_registry(account); // Attempt invalid init
    }

    #[test]
    /// Verify correct returns
    fun test_is_in_market_pair() {
        // Define mock market info
        let market_info = get_market_info_test();
        // Assert base coin returns true
        assert!(is_in_market_pair<BC>(&market_info), 0);
        // Assert quote coin returns true
        assert!(is_in_market_pair<QC>(&market_info), 0);
        // Assert mock asset returns false
        assert!(!is_in_market_pair<MA>(&market_info), 0);
    }

    #[test]
    /// Verify correct returns
    fun test_is_market_base() {
        // Define mock market info
        let market_info = get_market_info_test();
        // Assert base coin returns true
        assert!(is_market_base<BC>(&market_info), 0);
        // Assert quote coin returns false
        assert!(!is_market_base<QC>(&market_info), 0);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for neither base nor quote match
    fun test_is_market_base_neither() {
        // Define mock market info
        let market_info = get_market_info_test();
        // Attempt invalid check
        is_market_base<MA>(&market_info);
    }

    #[test]
    /// Verify false return for uninitialized registry
    fun test_is_registered_trading_pair_no_registry()
    acquires Registry {
        // Define mock market info
        let market_info = get_market_info_test();
        // Assert false return
        assert!(!is_registered_trading_pair(market_info.trading_pair_info), 0);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not initialized
    fun test_n_custodians_no_registry()
    acquires Registry {
        n_custodians(); // Attempt invalid query
    }

    #[test(econia = @econia)]
    /// Verify custodian returns
    fun test_register_custodian_capability(
        econia: &signer
    ): ()
    acquires Registry {
        // Verify 0 is unregistered custodian ID
        assert!(!is_registered_custodian_id(0), 0);
        init_registry(econia); // Initialize registry
        // Verify 0 still marked as unregistered custodian ID
        assert!(!is_registered_custodian_id(0), 0);
        // Verify 1 marked as unregistered custodian ID
        assert!(!is_registered_custodian_id(1), 0);
        assert!(n_custodians() == 0, 0); // Assert custodian count
        // Register custodian
        let first_cap = register_custodian_capability();
        assert!(n_custodians() == 1, 0); // Assert custodian count
        // Verify 0 still marked as unregistered custodian ID
        assert!(!is_registered_custodian_id(0), 0);
        // Verify 1 marked as registered custodian ID
        assert!(is_registered_custodian_id(1), 0);
        // Register custodianship
        let second_cap = register_custodian_capability();
        // Verify 2 marked as registered custodian ID
        assert!(is_registered_custodian_id(2), 0);
        assert!(n_custodians() == 2, 0); // Assert custodian count
        // Assert serial IDs administered correctly
        assert!(custodian_id(&first_cap) == 1, 0);
        assert!(custodian_id(&second_cap) == 2, 0);
        // Destroy custodian capabilities
        destroy_custodian_capability(first_cap);
        destroy_custodian_capability(second_cap);
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
    #[expected_failure(abort_code = 7)]
    /// Verify failure for market already exists
    fun test_register_market_internal_duplicate(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module
        let custodian_id = 3; // Declare custodian ID
        // Set custodian as registered
        set_registered_custodian_test(custodian_id);
        register_market_internal<BA, QA>( // Run valid init
            @econia, 1, 2, custodian_id, &get_econia_capability_test());
        register_market_internal<BA, QA>( // Attempt invalid re-init
            @econia, 1, 2, custodian_id, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid custodian on asset-agnostic market
    fun test_register_market_internal_invalid_custodian_agnostic(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module
        register_market_internal<BA, QA>( // Attempt invalid init
            @econia, 1, 2, NO_CUSTODIAN, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid custodian on pure-coin market
    fun test_register_market_internal_invalid_custodian_coins(
        econia: &signer
    ) acquires Registry {
        assets::init_coin_types(econia); // Initalize coin types
        init_registry(econia); // Initialize module
        register_market_internal<BC, QC>( // Attempt invalid init
            @econia, 1, 2, 1, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for lot size declared zero
    fun test_register_market_internal_no_lot_size(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        register_market_internal<BA, QA>( // Attempt invalid init
            @econia, 0, 2, 3, &get_econia_capability_test());
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not yet initialized
    fun test_register_market_internal_no_registry()
    acquires Registry {
        // Attempt invalid init
        register_market_internal<BA, QA>(
            @econia, 1, 2, 3, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for tick size declared zero
    fun test_register_market_internal_no_tick_size(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        register_market_internal<BA, QA>( // Attempt invalid init
            @econia, 1, 0, 3, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for base and quote are same type
    fun test_register_market_internal_same_type(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        register_market_internal<MA, MA>( // Attempt invalid init
            @econia, 1, 2, 3, &get_econia_capability_test());
    }

    #[test(econia = @econia)]
    /// Verify successful market registration
    fun test_register_market_internal_success(
        econia: &signer,
    ) acquires Registry {
        init_registry(econia); // Init registry
        assets::init_coin_types(econia); // Initialize coin types
        // Declare market parameters
        let host = @user;
        let base_type_info = type_info::type_of<BC>();
        let quote_type_info = type_info::type_of<QC>();
        let lot_size = 100;
        let tick_size = 25;
        let base_is_coin = true;
        let quote_is_coin = true;
        let custodian_id = NO_CUSTODIAN;
        let trading_pair_info = TradingPairInfo{base_type_info,
            quote_type_info, lot_size, tick_size, base_is_coin, quote_is_coin,
            custodian_id};
        let market_info = MarketInfo{trading_pair_info, host};
        // Run valid initialization
        register_market_internal<BC, QC>(@user, lot_size, tick_size,
            custodian_id, &get_econia_capability_test());
        // Borrow immutable reference to registry
        let registry = borrow_global<Registry>(@econia);
        // Assert correct host registration
        assert!(*table::borrow(&registry.hosts, trading_pair_info) == host, 0);
        // Assert correct market listing
        assert!(*vector::borrow(&registry.markets, 0) == market_info, 0);
        // Declare new asset-agnostic market
        base_type_info = type_info::type_of<BA>();
        base_is_coin = false;
        custodian_id = 1;
        trading_pair_info = TradingPairInfo{base_type_info, quote_type_info,
            lot_size, tick_size, base_is_coin, quote_is_coin, custodian_id};
        market_info = MarketInfo{trading_pair_info, host};
        // Set custodian ID to be registered
        set_registered_custodian_test(custodian_id);
        // Run valid initialization
        register_market_internal<BA, QC>(@user, lot_size, tick_size,
            custodian_id, &get_econia_capability_test());
        // Borrow immutable reference to registry
        registry = borrow_global<Registry>(@econia);
        // Assert correct host registration
        assert!(*table::borrow(&registry.hosts, trading_pair_info) == host, 0);
        // Assert correct market listing
        assert!(*vector::borrow(&registry.markets, 1) == market_info, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}