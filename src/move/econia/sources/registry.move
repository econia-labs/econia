/// Econia-wide registry functionality. Provides permissionless market
/// registration and tracking, delegated custodian registration.
module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use aptos_std::type_info;
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
        /// Map from trading pair to order book host address, used for
        /// duplicate checks on pure-coin trading pairs
        hosts: table::Table<TradingPairInfo, address>,
        /// List of all available markets, with each market's serial ID
        /// defined as its vector index (0-indexed)
        markets: vector<MarketInfo>,
        /// Number of registered custodians
        n_custodians: u64
    }

    /// Information about a trading pair
    struct TradingPairInfo has copy, drop, store {
        /// Base asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds to `GenericAsset`, or
        /// a non-coin asset indicated by the market host.
        base_type_info: type_info::TypeInfo,
        /// Quote asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds to `GenericAsset`, or
        /// a non-coin asset indicated by the market host.
        quote_type_info: type_info::TypeInfo,
        /// Number of base units exchanged per lot
        lot_size: u64,
        /// Number of quote units exchanged per tick
        tick_size: u64,
        /// ID of custodian capability required to verify deposits,
        /// swaps, and withdrawals of assets that are not coins. A
        /// "market-wide asset transfer custodian ID" that only applies
        /// to markets having at least one non-coin asset. For a market
        /// having one coin asset and one generic asset, only applies to
        /// the generic asset. Marked `PURE_COIN_PAIR` when base and
        /// quote types are both coins.
        generic_asset_transfer_custodian_id: u64,
        /// `PURE_COIN_PAIR` when base and quote types are both coins,
        /// otherwise the serial ID of the corresponding market. Used to
        /// disambiguate between asset-agnostic trading pairs having
        /// identical values for all of the above fields, without which
        /// such trading pairs would collide as key entries in
        /// `Registry.hosts`.
        agnostic_disambiguator: u64,
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
    /// When invalid custodian ID for given operation
    const E_INVALID_CUSTODIAN: u64 = 5;
    /// When base and quote types are the same for a pure-coin market
    const E_SAME_COIN: u64 = 6;
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

    /// Update the number of registered custodians and issue a
    /// `CustodianCapability` with the corresponding serial ID. Abort if
    /// registry is not initialized
    public fun register_custodian_capability():
    CustodianCapability
    acquires Registry {
        // Assert the registry is already initialized
        assert!(exists<Registry>(@econia), E_NO_REGISTRY);
        // Borrow mutable reference to registry
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        // Set custodian serial ID to the new number of custodians
        let custodian_id = registry.n_custodians + 1;
        // Update the registry for the new count
        registry.n_custodians = custodian_id;
        // Pack and return corresponding capability
        CustodianCapability{custodian_id}
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Move empty registry to the Econia account
    public entry fun init_registry(
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

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
    public fun destroy_custodian_capability_test(
        custodian_capability: CustodianCapability
    ) {
        // Unpack passed capability
        CustodianCapability{custodian_id: _} = custodian_capability;
    }

    #[test_only]
    /// Return `CustodianCapability` with `custodian_id`
    public fun get_custodian_capability_test(
        custodian_id: u64
    ): CustodianCapability {
        CustodianCapability{custodian_id} // Pack and return capability
    }

    #[test_only]
    /// Return a mock `MarketInfo`
    fun get_market_info_test():
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
    /// Verify failure for pure-coin market already exists
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