/// Econia-wide registry functionality. Provides permissionless market
/// registration and tracking, delegated custodian registration.
module econia::registry {

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When lot size specified as 0
    const E_LOT_SIZE_0: u64 = 3;
    /// When tick size specified as 0
    const E_TICK_SIZE_0: u64 = 4;
    /// When invalid custodian ID for given operation
    const E_INVALID_CUSTODIAN: u64 = 5;
    /// When base and quote types are the same for a pure-coin market
    const E_SAME_COIN: u64 = 6;
    /// When a given market is already registered
    const E_MARKET_EXISTS: u64 = 7;
    /// When a type is neither base nor quote on given market
    const E_NOT_IN_MARKET_PAIR: u64 = 8;
    /// When invalid market ID
    const E_INVALID_MARKET_ID: u64 = 9;
    /// When an invalid base asset specified
    const E_INVALID_BASE_ASSET: u64 = 10;
    /// When an invalid quote asset specified
    const E_INVALID_QUOTE_ASSET: u64 = 11;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Verify assets for market with given serial ID, then return
    /// corresponding generic asset transfer custodian ID
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `market_id`: Serial ID of market to look up
    ///
    /// # Returns
    /// * ID of custodian capability required to approve deposits and
    ///   withdrawals of non-coin assets, else `PURE_COIN_PAIR`
    public(friend) fun get_verified_market_custodian_id<
        BaseType,
        QuoteType
    >(
        market_id: u64,
    ): u64
    acquires Registry {
        // Assert the registry is already initialized
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Borrow immutable reference to registry
        let registry_ref = borrow_global<Registry>(@econia);
        // Assert that a market exists with the given serial ID
        assert!(market_id < vector::length(&registry_ref.markets),
            E_INVALID_MARKET_ID);
        // Borrow immutable reference to corresponding trading pair info
        let trading_pair_info_ref = &vector::borrow(
            &registry_ref.markets, market_id).trading_pair_info;
        // Assert valid base asset type info
        assert!(trading_pair_info_ref.base_type_info ==
            type_info::type_of<BaseType>(), E_INVALID_BASE_ASSET);
        // Assert valid quote asset type info
        assert!(trading_pair_info_ref.quote_type_info ==
            type_info::type_of<QuoteType>(), E_INVALID_QUOTE_ASSET);
        // Return market-wide generic asset transfer custodian ID
        trading_pair_info_ref.generic_asset_transfer_custodian_id
    }

    /// Return `true` if `T` is base type in `market_info`, `false` if
    /// is quote type, and abort otherwise
    ///
    /// Set as friend function to restrict excess registry queries
    public(friend) fun is_base_asset<T>(
        market_info: &MarketInfo
    ): bool {
        let type_info = type_info::type_of<T>(); // Get type info
        if (type_info ==  market_info.trading_pair_info.base_type_info)
            return true; // Return true if base match
        if (type_info ==  market_info.trading_pair_info.quote_type_info)
            return false; // Return false if quote match
        abort E_NOT_IN_MARKET_PAIR // Else abort
    }

    /// Return `true` if `T` is either base or quote in `market_info`
    ///
    /// Set as friend function to restrict excess registry queries
    public(friend) fun is_base_or_quote<T>(
        market_info: &MarketInfo
    ): bool {
        let type_info = type_info::type_of<T>(); // Get type info
        // Return if type is either base or quote
        type_info == market_info.trading_pair_info.base_type_info ||
        type_info == market_info.trading_pair_info.quote_type_info
    }

    /// Return `true` if `custodian_id` has been registered
    ///
    /// Set as friend function to restrict excess registry queries
    public(friend) fun is_registered_custodian_id(
        custodian_id: u64
    ): bool
    acquires Registry {
        // Return false if registry hasn't been initialized
        if (!exists<Registry>(@econia)) return false;
        // Return if custodian ID has been registered
        custodian_id <= n_custodians() && custodian_id != NO_CUSTODIAN
    }

    /// Register a market, returning its market ID
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `host`: Host of corresponding order book
    /// * `lot_size`: Number of base units exchanged per lot
    /// * `tick_size`: Number of quote units exchanged per lot
    /// * `generic_asset_transfer_custodian_id`: ID of custodian
    ///   capability required to approve deposits and withdrawals of
    ///   non-coin assets (pass as `PURE_COIN_PAIR` when base and quote
    ///   assets are both coins)
    ///
    /// # Returns
    /// * `u64`: Market's ID
    ///
    /// # Abort conditions
    /// * If registry is not initialized
    /// * If `lot_size` is zero
    /// * If `tick_size` is zero
    /// * If `BaseType` and `QuoteType` are the same coin type
    /// * If corresponding pure-coin market is already registered
    /// * If attempting to register an asset-agnostic order book for an
    ///   invalid `custodian_id`
    ///
    /// # Coin types
    /// * When registering a market with an asset corresponding to an
    ///   `aptos_framework::coin::Coin`, use only the phantom
    ///   `CoinType` as a type parameter: for example pass `MyCoin`
    ///   rather than `Coin<MyCoin>`
    /// * If both `BaseType` and `QuoteType` are coins, only one such
    ///   market may be registered with the corresponding `lot_size` and
    ///   `tick_size` for the given base/quote combination
    ///
    /// # Non-coin types
    /// * If either `BaseType` or `QuoteType` is a non-coin type, then
    ///   the trading pair will be considered asset-agnostic, and
    ///   registration will thus require a registered custodian ID
    /// * Registrants may optionally supply their own custom types
    ///   rather than `GenericAsset`, which is considered the default
    public(friend) fun register_market_internal<
        BaseType,
        QuoteType
    >(
        host: address,
        lot_size: u64,
        tick_size: u64,
        generic_asset_transfer_custodian_id: u64,
    ): u64
    acquires Registry {
        // Assert the registry is already initialized
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Assert lot size is nonzero
        assert!(lot_size > 0, E_LOT_SIZE_0);
        // Assert tick size is nonzero
        assert!(tick_size > 0, E_TICK_SIZE_0);
        // Get base type info
        let base_type_info = type_info::type_of<BaseType>();
        // Get quote type info
        let quote_type_info = type_info::type_of<QuoteType>();
        // Determine if base is a coin type
        let base_is_coin = coin::is_coin_initialized<BaseType>();
        // Determine if quote is a coin type
        let quote_is_coin = coin::is_coin_initialized<QuoteType>();
        // Determine if a pure coin pair
        let pure_coin = base_is_coin && quote_is_coin;
        // Get 0-indexed market ID
        let market_id = n_markets();
        // If a pure coin pair, flag as such, otherwise set agnostic
        // disambiguator to market ID
        let agnostic_disambiguator =
            if (pure_coin) PURE_COIN_PAIR else market_id;
        // Pack corresponding trading pair info
        let trading_pair_info = TradingPairInfo{base_type_info,
            quote_type_info, lot_size, tick_size,
            generic_asset_transfer_custodian_id, agnostic_disambiguator};
        if (pure_coin) { // If attempting to register pure coin pair
            // Assert base and quote not same type
            assert!(base_type_info != quote_type_info, E_SAME_COIN);
            // Assert market is not already registered
            assert!(!is_registered_trading_pair(trading_pair_info),
                E_MARKET_EXISTS);
            // Assert no indicated generic asset transfer custodian
            assert!(generic_asset_transfer_custodian_id == PURE_COIN_PAIR,
                E_INVALID_CUSTODIAN);
        } else { // If an asset-agnostic order book
            // Assert generic asset transfer custodian ID has been
            // registered
            assert!(is_registered_custodian_id(
                generic_asset_transfer_custodian_id), E_INVALID_CUSTODIAN);
        };
        // Borrow mutable reference to registry
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        // Register host for given trading pair
        table::add(&mut registry_ref_mut.hosts, trading_pair_info, host);
        // Push back onto markets list a packed market info
        vector::push_back(&mut registry_ref_mut.markets,
            MarketInfo{host, trading_pair_info});
        market_id // Return market ID
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return `true` if `TradingPairInfo` is registered, else `false`
    ///
    /// Set as private function to restrict excess registry queries
    fun is_registered_trading_pair(
        trading_pair_info: TradingPairInfo
    ): bool
    acquires Registry {
        // Return false if no registry initialized
        if (!exists<Registry>(@econia)) return false;
        // Borrow immutable reference to registry
        let registry_ref = borrow_global<Registry>(@econia);
        // Return if hosts table contains given trading pair info
        table::contains(&registry_ref.hosts, trading_pair_info)
    }

    /// Return the number of registered custodians, aborting if registry
    /// is not initialized
    ///
    /// Set as private function to restrict excess registry queries
    fun n_custodians():
    u64
    acquires Registry {
        // Assert registry exists
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Return number of registered custodians
        borrow_global<Registry>(@econia).n_custodians
    }

    /// Return the number of registered markets, aborting if registry
    /// is not initialized
    ///
    /// Set as private function to restrict excess registry queries
    fun n_markets():
    u64
    acquires Registry {
        // Assert registry exists
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Return number of registered markets
        vector::length(&borrow_global<Registry>(@econia).markets)
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return `CustodianCapability` with `custodian_id`
    public fun get_custodian_capability_test(
        custodian_id: u64
    ): CustodianCapability {
        CustodianCapability{custodian_id} // Pack and return capability
    }

    #[test_only]
    /// Return a mock `MarketInfo`
    public fun get_market_info_test():
    MarketInfo {
        MarketInfo{
            host: @user,
            trading_pair_info: TradingPairInfo{
                base_type_info: type_info::type_of<BC>(),
                quote_type_info: type_info::type_of<QC>(),
                lot_size: 100,
                tick_size: 25,
                generic_asset_transfer_custodian_id: PURE_COIN_PAIR,
                agnostic_disambiguator: PURE_COIN_PAIR
            }
        }
    }

    #[test_only]
    /// Return market-level custodian ID for valid `market_id`
    public fun get_generic_asset_transfer_custodian_id_test(
        market_id: u64
    ): u64
    acquires Registry {
        // Borrow immutable reference to markets list
        let markets_ref = &borrow_global<Registry>(@econia).markets;
        // Return custodian ID for corresponding market
        vector::borrow(markets_ref, market_id).trading_pair_info.
            generic_asset_transfer_custodian_id
    }

    #[test_only]
    /// Register several test markets, given `econia` signature
    public fun register_market_internal_multiple_test(
        econia: &signer
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
        u64,
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        assets::init_coin_types(econia); // Initialize coin types
        // Define mock market parameters for agnostic market
        let lot_size_agnostic = 1;
        let tick_size_agnostic = 2;
        let generic_asset_transfer_custodian_id_agnostic = 3;
        let market_id_agnostic = 0;
        // Define mock market parameters for pure coin market
        let lot_size_pure_coin = 4;
        let tick_size_pure_coin = 5;
        let generic_asset_transfer_custodian_id_pure_coin = PURE_COIN_PAIR;
        let market_id_pure_coin = 1;
        // Set market-level agnostic custodian ID to be valid
        set_registered_custodian_test(
            generic_asset_transfer_custodian_id_agnostic);
        // Register markets
        register_market_internal<BG, QG>(@econia, lot_size_agnostic,
            tick_size_agnostic, generic_asset_transfer_custodian_id_agnostic);
        register_market_internal<BC, QC>(
            @econia, lot_size_pure_coin, tick_size_pure_coin,
            generic_asset_transfer_custodian_id_pure_coin);
        ( // Return market parameters
            lot_size_agnostic,
            tick_size_agnostic,
            generic_asset_transfer_custodian_id_agnostic,
            market_id_agnostic,
            lot_size_pure_coin,
            tick_size_pure_coin,
            generic_asset_transfer_custodian_id_pure_coin,
            market_id_pure_coin
        )
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

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for invalid base asset
    fun test_get_verified_market_custodian_id_invalid_base(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Init registry
        // Declare mock market parameters
        let (host, lot_size, tick_size, custodian_id) = (@econia, 1, 2, 3);
        set_registered_custodian_test(3); // Set custodian ID as valid
        register_market_internal<BG, QG>( // Register mock market
            host, lot_size, tick_size, custodian_id);
        // Attempt invalid invocation
        get_verified_market_custodian_id<BC, QG>(0);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for invalid market ID
    fun test_get_verified_market_custodian_id_invalid_market(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Init registry
        // Attempt invalid invocation
        get_verified_market_custodian_id<BC, BC>(1);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 11)]
    /// Verify failure for invalid base asset
    fun test_get_verified_market_custodian_id_invalid_quote(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Init registry
        // Declare mock market parameters
        let (host, lot_size, tick_size, custodian_id) = (@econia, 1, 2, 3);
        set_registered_custodian_test(3); // Set custodian ID as valid
        register_market_internal<BG, QG>( // Register mock market
            host, lot_size, tick_size, custodian_id);
        // Attempt invalid invocation
        get_verified_market_custodian_id<BG, QC>(0);
    }

    #[test(econia = @econia)]
    /// Verify failure for invalid base asset
    fun test_get_verified_market_custodian_id_success(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Init registry
        // Declare mock market parameters
        let (host, lot_size, tick_size, custodian_id) = (@econia, 1, 2, 3);
        // Set custodian ID as valid
        set_registered_custodian_test(custodian_id);
        register_market_internal<BG, QG>( // Register mock market
            host, lot_size, tick_size, custodian_id);
        // Get returned custodian ID
        let return_val = get_verified_market_custodian_id<BG, QG>(0);
        // Assert correct return
        assert!(return_val == custodian_id, 0);
        // Declare new mock market parameters
        (host, lot_size, tick_size, custodian_id) = (@user, 4, 5, 6);
        // Set custodian ID as valid
        set_registered_custodian_test(custodian_id);
        register_market_internal<BG, QG>( // Register mock market
            host, lot_size, tick_size, custodian_id);
        // Get returned custodian ID
        let return_val = get_verified_market_custodian_id<BG, QG>(1);
        // Assert correct return
        assert!(return_val == custodian_id, 0);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not initialized
    fun test_get_verified_market_custodian_id_no_registry()
    acquires Registry {
        // Attempt invalid invocation
        get_verified_market_custodian_id<BC, QC>(1);
    }

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
    fun test_is_base_asset() {
        // Define mock market info
        let market_info = get_market_info_test();
        // Assert base coin returns true
        assert!(is_base_asset<BC>(&market_info), 0);
        // Assert quote coin returns false
        assert!(!is_base_asset<QC>(&market_info), 0);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for neither base nor quote match
    fun test_is_base_asset_neither() {
        // Define mock market info
        let market_info = get_market_info_test();
        // Attempt invalid check
        is_base_asset<QG>(&market_info);
    }

    #[test]
    /// Verify correct returns
    fun test_is_base_or_quote() {
        // Define mock market info
        let market_info = get_market_info_test();
        // Assert base coin returns true
        assert!(is_base_or_quote<BC>(&market_info), 0);
        // Assert quote coin returns true
        assert!(is_base_or_quote<QC>(&market_info), 0);
        // Assert generic base asset returns false
        assert!(!is_base_or_quote<BG>(&market_info), 0);
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
    ) acquires Registry {
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
        destroy_custodian_capability_test(first_cap);
        destroy_custodian_capability_test(second_cap);
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
    /// Verify failure for pure-coin market already exists
    fun test_register_market_internal_duplicate(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module
        assets::init_coin_types(econia); // Initialize coin types
        let custodian_id = PURE_COIN_PAIR;
        // Run valid init
        register_market_internal<BC, QC>(@econia, 1, 2, custodian_id);
        // Attempt invalid re-init
        register_market_internal<BC, QC>(@econia, 1, 2, custodian_id);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid custodian on asset-agnostic market
    fun test_register_market_internal_invalid_custodian_agnostic(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize module
        // Attempt invalid init
        register_market_internal<BG, QG>(@econia, 1, 2, 2);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid custodian on pure-coin market
    fun test_register_market_internal_invalid_custodian_coins(
        econia: &signer
    ) acquires Registry {
        assets::init_coin_types(econia); // Initalize coin types
        init_registry(econia); // Initialize module
        // Attempt invalid init
        register_market_internal<BC, QC>(@econia, 1, 2, 1);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for lot size declared zero
    fun test_register_market_internal_no_lot_size(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        // Attempt invalid init
        register_market_internal<BG, QG>(@econia, 0, 2, 3);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for registry not yet initialized
    fun test_register_market_internal_no_registry()
    acquires Registry {
        // Attempt invalid init
        register_market_internal<BG, QG>(@econia, 1, 2, 3);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for tick size declared zero
    fun test_register_market_internal_no_tick_size(
        econia: &signer
    ) acquires Registry {
        init_registry(econia); // Initialize registry
        // Attempt invalid init
        register_market_internal<BG, QG>(@econia, 1, 0, 3);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for base and quote are same coin type
    fun test_register_market_internal_same_type(
        econia: &signer
    ) acquires Registry {
        assets::init_coin_types(econia); // Initialize coin types
        init_registry(econia); // Initialize registry
        // Attempt invalid init
        register_market_internal<BC, BC>(@econia, 1, 2, 3);
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
        let generic_asset_transfer_custodian_id = PURE_COIN_PAIR;
        let agnostic_disambiguator  = PURE_COIN_PAIR;
        let trading_pair_info = TradingPairInfo{base_type_info,
            quote_type_info, lot_size, tick_size,
            generic_asset_transfer_custodian_id,
            agnostic_disambiguator};
        let market_info = MarketInfo{trading_pair_info, host};
        // Run valid initialization
        let market_id = register_market_internal<BC, QC>(
            @user, lot_size, tick_size, generic_asset_transfer_custodian_id);
        // Assert market ID administered correctly
        assert!(market_id == 0, 0);
        // Borrow immutable reference to registry
        let registry_ref = borrow_global<Registry>(@econia);
        // Assert correct host registration
        assert!(
            *table::borrow(&registry_ref.hosts, trading_pair_info) == host, 0);
        // Assert correct market listing
        assert!(*vector::borrow(&registry_ref.markets, 0) == market_info, 0);
        // Declare new asset-agnostic market
        base_type_info = type_info::type_of<BG>();
        generic_asset_transfer_custodian_id = 3; // Arbitrary custodian
        agnostic_disambiguator = 1; // Serial ID of corresponding market
        trading_pair_info = TradingPairInfo{base_type_info,
            quote_type_info, lot_size, tick_size,
            generic_asset_transfer_custodian_id,
            agnostic_disambiguator};
        market_info = MarketInfo{trading_pair_info, host};
        // Set custodian ID to be registered
        set_registered_custodian_test(generic_asset_transfer_custodian_id);
        // Run valid initialization
        market_id = register_market_internal<BG, QC>(
            @user, lot_size, tick_size, generic_asset_transfer_custodian_id);
        // Assert market ID administered correctly
        assert!(market_id == 1, 0);
        // Borrow immutable reference to registry
        registry_ref = borrow_global<Registry>(@econia);
        // Assert correct host registration
        assert!(
            *table::borrow(&registry_ref.hosts, trading_pair_info) == host, 0);
        // Assert correct market listing
        assert!(
            *vector::borrow(&registry_ref.markets, 1) == market_info, 0);
        // Register a second asset-agnostic market with same parameters
        register_market_internal<BG, QC>( // Run valid initialization
            @user, lot_size, tick_size, generic_asset_transfer_custodian_id);
        // Borrow immutable reference to registry
        registry_ref = borrow_global<Registry>(@econia);
        // Set new serial ID for agnostic disambiguator
        trading_pair_info.agnostic_disambiguator = 2;
        // Assert correct host registration
        assert!(
            *table::borrow(&registry_ref.hosts, trading_pair_info) == host, 0);
        // Update market info for new agnostic mnarket
        market_info = MarketInfo{trading_pair_info, host};
        // Assert correct market listing
        assert!(
            *vector::borrow(&registry_ref.markets, 2) == market_info, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}