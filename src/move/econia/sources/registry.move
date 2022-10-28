/// Manages registration capabilities and operations.
///
/// # Indexing
///
/// Custodian capabilities and underwriter capabilities are 1-indexed,
/// with an ID of 0 reserved as a flag for null. For consistency, market
/// IDs are 1-indexed too.
///
/// # Complete docgen index
///
/// The below index is automatically generated from source code:
module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::table::{Self, Table};
    use aptos_framework::type_info::{Self, TypeInfo};
    use econia::incentives;
    use econia::tablist::{Self, Tablist};
    use std::option::{Option};
    use std::string::{Self, String};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{Self, BC, QC, UC};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian capability required to approve order placement, order
    /// cancellation, and coin withdrawals. Administered to third-party
    /// registrants who may store it as they wish.
    struct CustodianCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as a
        /// custodian.
        custodian_id: u64
    }

    /// Type flag for generic asset. Must be passed as base asset type
    /// argument for generic market operations.
    struct GenericAsset has key {}

    /// Information about a market.
    struct MarketInfo has copy, drop, store {
        /// Base asset type info. When base asset is an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        /// Otherwise should be `GenericAsset`.
        base_type: TypeInfo,
        /// Custom base asset name for a generic market, provided by the
        /// underwriter who registers the market. Empty if a pure coin
        /// market.
        base_name_generic: String,
        /// Quote asset coin type info. Corresponds to a phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        quote_type: TypeInfo,
        /// Number of base units exchanged per lot (when base asset is
        /// a coin, corresponds to `aptos_framework::coin::Coin.value`).
        lot_size: u64,
        /// Number of quote coin units exchanged per tick (corresponds
        /// to `aptos_framework::coin::Coin.value`).
        tick_size: u64,
        /// Minimum number of lots per order.
        min_size: u64,
        /// `NIL` if a pure coin market, otherwise ID of underwriter
        /// capability required to verify generic asset amounts. A
        /// market-wide ID that only applies to markets having a generic
        /// base asset.
        underwriter_id: u64
    }

    /// Emitted when a market is registered.
    struct MarketRegistrationEvent has drop, store {
        /// Market ID of the market just registered.
        market_id: u64,
        /// Base asset type info.
        base_type: TypeInfo,
        /// Base asset generic name, if any.
        base_name_generic: String,
        /// Quote asset type info.
        quote_type: TypeInfo,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// Minimum number of lots per order.
        min_size: u64,
        /// `NIL` if a pure coin market, otherwise ID of underwriter
        /// capability required to verify generic asset amounts.
        underwriter_id: u64,
    }

    /// Emitted when a recognized market is added, removed, or updated.
    struct RecognizedMarketEvent has drop, store {
        /// The associated trading pair.
        trading_pair: TradingPair,
        /// The recognized market info for the given trading pair after
        /// an addition or update. None if a removal.
        recognized_market_info: Option<RecognizedMarketInfo>,
    }

    /// Recognized market info for a given trading pair.
    struct RecognizedMarketInfo has drop, store {
        /// Market ID of recognized market, 0-indexed.
        market_id: u64,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// Minimum number of lots per order.
        min_size: u64,
        /// `NIL` if a pure coin market, otherwise ID of underwriter
        /// capability required to verify generic asset amounts.
        underwriter_id: u64,
    }

    /// Recognized markets for specific trading pairs.
    struct RecognizedMarkets has key {
        /// Map from trading pair info to market information for the
        /// recognized market, if any, for given trading pair.
        map: Tablist<TradingPair, RecognizedMarketInfo>,
        /// Event handle for recognized market events.
        recognized_market_events: EventHandle<RecognizedMarketEvent>
    }

    /// Global registration information.
    struct Registry has key {
        /// Map from 1-indexed market ID to corresponding market info,
        /// enabling iterated indexing by market ID.
        market_id_to_info: Tablist<u64, MarketInfo>,
        /// Map from market info to corresponding 1-indexed market ID,
        /// enabling market duplicate checks.
        market_info_to_id: Table<MarketInfo, u64>,
        /// The number of registered custodians.
        n_custodians: u64,
        /// The number of registered underwriters.
        n_underwriters: u64,
        /// Event handle for market registration events.
        market_registration_events: EventHandle<MarketRegistrationEvent>
    }

    /// A combination of a base asset and a quote asset.
    struct TradingPair has copy, drop, store {
        /// Base asset type info.
        base_type: TypeInfo,
        /// Base asset generic name, if any.
        base_name_generic: String,
        /// Quote asset type info.
        quote_type: TypeInfo
    }

    /// Underwriter capability required to verify generic asset
    /// amounts. Administered to third-party registrants who may store
    /// it as they wish.
    struct UnderwriterCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as an
        /// underwriter.
        underwriter_id: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Lot size specified as 0.
    const E_LOT_SIZE_0: u64 = 0;
    /// Tick size specified as 0.
    const E_TICK_SIZE_0: u64 = 1;
    /// Minimum order size specified as 0.
    const E_MIN_SIZE_0: u64 = 2;
    /// Quote asset type has not been initialized as a coin.
    const E_QUOTE_NOT_COIN: u64 = 3;
    /// Base and quote asset descriptors are identical.
    const E_BASE_QUOTE_SAME: u64 = 4;
    /// Market is already registered.
    const E_MARKET_REGISTERED: u64 = 5;
    /// Base coin type has not been initialized for a pure coin market.
    const E_BASE_NOT_COIN: u64 = 6;
    /// Generic base asset descriptor has too few charaters.
    const E_GENERIC_TOO_FEW_CHARACTERS: u64 = 7;
    /// Generic base asset descriptor has too many charaters.
    const E_GENERIC_TOO_MANY_CHARACTERS: u64 = 8;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Maximum number of characters permitted in a generic asset name,
    /// equal to the maximum number of characters permitted in a comment
    /// line per PEP 8.
    const MAX_CHARACTERS_GENERIC: u64 = 72;
    /// Minimum number of characters permitted in a generic asset name,
    /// equal to the number of spaces in an indentation level per PEP 8.
    const MIN_CHARACTERS_GENERIC: u64 = 4;
    /// Flag for null value when null defined as 0.
    const NIL: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return serial ID of given `CustodianCapability`.
    ///
    /// # Testing
    ///
    /// * `test_register_capabilities()`
    public fun get_custodian_id(
        custodian_capability_ref: &CustodianCapability
    ): u64 {
        custodian_capability_ref.custodian_id
    }

    /// Return the number of registered custodians.
    ///
    /// # Testing
    ///
    /// * `test_register_capabilities()`
    public fun get_n_custodians():
    u64
    acquires Registry {
        borrow_global<Registry>(@econia).n_custodians
    }

    /// Return the number of registered underwriters.
    ///
    /// # Testing
    ///
    /// * `test_register_capabilities()`
    public fun get_n_underwriters():
    u64
    acquires Registry {
        borrow_global<Registry>(@econia).n_underwriters
    }

    /// Return serial ID of given `UnderwriterCapability`.
    ///
    /// # Testing
    ///
    /// * `test_register_capabilities()`
    public fun get_underwriter_id(
        underwriter_capability_ref: &UnderwriterCapability
    ): u64 {
        underwriter_capability_ref.underwriter_id
    }

    /// Return a unique `CustodianCapability`.
    ///
    /// Increment the number of registered custodians, then issue a
    /// capability with the corresponding serial ID. Requires utility
    /// coins to cover the custodian registration fee.
    ///
    /// # Testing
    ///
    /// * `test_register_capabilities()`
    public fun register_custodian_capability<UtilityCoinType>(
        utility_coins: Coin<UtilityCoinType>
    ): CustodianCapability
    acquires Registry {
        // Borrow mutable reference to registry.
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        // Set custodian serial ID to the new number of custodians.
        let custodian_id = registry_ref_mut.n_custodians + 1;
        // Update the registry for the new count.
        registry_ref_mut.n_custodians = custodian_id;
        incentives:: // Deposit provided utility coins.
            deposit_custodian_registration_utility_coins(utility_coins);
        // Pack and return corresponding capability.
        CustodianCapability{custodian_id}
    }

    /// Return a unique `UnderwriterCapability`.
    ///
    /// Increment the number of registered underwriters, then issue a
    /// capability with the corresponding serial ID. Requires utility
    /// coins to cover the underwriter registration fee.
    ///
    /// # Testing
    ///
    /// * `test_register_capabilities()`
    public fun register_underwriter_capability<UtilityCoinType>(
        utility_coins: Coin<UtilityCoinType>
    ): UnderwriterCapability
    acquires Registry {
        // Borrow mutable reference to registry.
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        // Set underwriter serial ID to the new number of underwriters.
        let underwriter_id = registry_ref_mut.n_underwriters + 1;
        // Update the registry for the new count.
        registry_ref_mut.n_underwriters = underwriter_id;
        incentives:: // Deposit provided utility coins.
            deposit_underwriter_registration_utility_coins(utility_coins);
        // Pack and return corresponding capability.
        UnderwriterCapability{underwriter_id}
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Wrapped market registration call for a base coin type.
    ///
    /// See inner function `register_market_internal()`.
    ///
    /// # Aborts
    ///
    /// * `E_BASE_NOT_COIN`: Base coin type is not initialized.
    ///
    /// # Testing
    ///
    /// * `test_register_market_base_not_coin()`
    public(friend) fun register_market_base_coin_internal<
        BaseCoinType,
        QuoteCoinType,
        UtilityCoinType
    >(
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        utility_coins: Coin<UtilityCoinType>
    ): u64
    acquires Registry {
        // Assert base coin type is initialized.
        assert!(coin::is_coin_initialized<BaseCoinType>(), E_BASE_NOT_COIN);
        // Add to the registry a corresponding entry, returning new
        // market ID.
        register_market_internal<QuoteCoinType, UtilityCoinType>(
            type_info::type_of<BaseCoinType>(), string::utf8(b""), lot_size,
            tick_size, min_size, NIL, utility_coins)
    }

    /// Wrapped market registration call for a generic base type,
    /// requiring immutable reference to corresponding
    /// `UnderwriterCapability` for the market, and `base_type`
    /// descriptor.
    ///
    /// See inner function `register_market_internal()`.
    ///
    /// # Aborts
    ///
    /// * `E_GENERIC_TOO_FEW_CHARACTERS`: Asset descriptor is too short.
    /// * `E_GENERIC_TOO_MANY_CHARACTERS`: Asset descriptor is too long.
    ///
    /// # Testing
    ///
    /// * `test_register_market_generic_name_too_few()`
    /// * `test_register_market_generic_name_too_many()`
    public(friend) fun register_market_base_generic_internal<
        QuoteCoinType,
        UtilityCoinType
    >(
        base_name_generic: String,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        underwriter_capability_ref: &UnderwriterCapability,
        utility_coins: Coin<UtilityCoinType>
    ): u64
    acquires Registry {
        // Get generic asset name length.
        let name_length = string::length(&base_name_generic);
        assert!( // Assert generic base asset string is not too short.
            name_length >= MIN_CHARACTERS_GENERIC,
            E_GENERIC_TOO_FEW_CHARACTERS);
        assert!( // Assert generic base asset string is not too long.
            name_length <= MIN_CHARACTERS_GENERIC,
            E_GENERIC_TOO_MANY_CHARACTERS);
        // Get underwriter ID.
        let underwriter_id = underwriter_capability_ref.underwriter_id;
        // Add to the registry a corresponding entry, returning new
        // market ID.
        register_market_internal<QuoteCoinType, UtilityCoinType>(
            type_info::type_of<GenericAsset>(), base_name_generic, lot_size,
            tick_size, min_size, underwriter_id, utility_coins)
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize the Econia registry and recognized markets list upon
    /// module publication.
    fun init_module(
        econia: &signer
    ) {
        // Initialize registry.
        move_to(econia, Registry{
            market_id_to_info: tablist::new(),
            market_info_to_id: table::new(),
            n_custodians: 0,
            n_underwriters: 0,
            market_registration_events:
                account::new_event_handle<MarketRegistrationEvent>(econia)});
        // Initialize recognized markets list.
        move_to(econia, RecognizedMarkets{
            map: tablist::new(),
            recognized_market_events:
                account::new_event_handle<RecognizedMarketEvent>(econia)});
    }

    /// Register a market in the global registry.
    ///
    /// # Type parameters
    ///
    /// * `QuoteCoinType`: The quote coin type for the market.
    /// * `UtilityCoinType`: The utility coin type.
    ///
    /// # Parameters
    ///
    /// * `base_type`: The base coin type info for a pure coin market,
    ///   otherwise that of `GenericAsset`.
    /// * `base_name_generic`: Base asset generic name, if any.
    /// * `lot_size`: Lot size for the market.
    /// * `tick_size`: Tick size for the market.
    /// * `min_size`: Minimum lots per order for market.
    /// * `underwriter_id`: `NIL` if a pure coin market, otherwise ID
    ///   of market underwriter.
    /// * `utility_coins`: Utility coins paid to register a market.
    ///
    /// # Emits
    ///
    /// * `MarketRegistrationEvent`: Parameters of market just
    ///   registered.
    ///
    /// # Aborts
    ///
    /// * `E_LOT_SIZE_0`: Lot size is 0.
    /// * `E_TICK_SIZE_0`: Tick size is 0.
    /// * `E_MIN_SIZE_0`: Minimum size is 0.
    /// * `E_QUOTE_NOT_COIN`: Quote coin type not initialized as coin.
    /// * `E_BASE_QUOTE_SAME`: Base and quote type are the same.
    /// * `E_MARKET_REGISTERED`: Markets map already contains an entry
    ///   for specified market info.
    ///
    /// # Assumptions
    ///
    /// * `underwriter_id` has been properly passed by either
    ///   `register_market_base_coin_internal` or
    ///   `register_market_base_generic_interal`.
    ///
    /// # Testing
    ///
    /// * `test_register_market_lot_size_0()`
    /// * `test_register_market_min_size_0()`
    /// * `test_register_market_quote_not_coin()`
    /// * `test_register_market_registered()`
    /// * `test_register_market_same_type()`
    /// * `test_register_market_tick_size_0()`
    fun register_market_internal<
        QuoteCoinType,
        UtilityCoinType
    >(
        base_type: TypeInfo,
        base_name_generic: String,
        lot_size: u64,
        tick_size: u64,
        min_size: u64,
        underwriter_id: u64,
        utility_coins: Coin<UtilityCoinType>
    ): u64
    acquires Registry {
        // Assert lot size is nonzero.
        assert!(lot_size > 0, E_LOT_SIZE_0);
        // Assert tick size is nonzero.
        assert!(tick_size > 0, E_TICK_SIZE_0);
        // Assert minimum size is nonzero.
        assert!(min_size > 0, E_MIN_SIZE_0);
        // Assert quote coin type is initialized.
        assert!(coin::is_coin_initialized<QuoteCoinType>(), E_QUOTE_NOT_COIN);
        // Get quote coin type.
        let quote_type = type_info::type_of<QuoteCoinType>();
        // Assert base and quote type names are not the same.
        assert!(base_type != quote_type, E_BASE_QUOTE_SAME);
        let market_info = MarketInfo{ // Pack market info.
            base_type, base_name_generic, quote_type, lot_size, tick_size,
            min_size, underwriter_id};
        // Mutably borrow registry.
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        // Mutably borrow map from market info to market ID.
        let info_to_id_ref_mut = &mut registry_ref_mut.market_info_to_id;
        assert!( // Assert market not registered.
            !table::contains(info_to_id_ref_mut, market_info),
            E_MARKET_REGISTERED);
        // Mutably borrow map from market ID to market info.
        let id_to_info_ref_mut = &mut registry_ref_mut.market_id_to_info;
        // Get 1-indexed market ID.
        let market_id = tablist::length(id_to_info_ref_mut) + 1;
        // Register a market entry in map from market info to market ID.
        table::add(info_to_id_ref_mut, market_info, market_id);
        // Register a market entry in map from market ID to market info.
        tablist::add(id_to_info_ref_mut, market_id, market_info);
        // Get market registration events handle.
        let event_handle = &mut registry_ref_mut.market_registration_events;
        // Emit a market registration event.
        event::emit_event(event_handle, MarketRegistrationEvent{
            market_id, base_type, base_name_generic, quote_type, lot_size,
            tick_size, min_size, underwriter_id});
        incentives::deposit_market_registration_utility_coins<UtilityCoinType>(
                utility_coins); // Deposit utility coins.
        market_id // Return market ID.
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Drop the given `CustodianCapability`.
    public fun drop_custodian_capability_test(
        custodian_capability: CustodianCapability
    ) {
        // Unpack provided capability.
        let CustodianCapability{custodian_id: _} = custodian_capability;
    }

    #[test_only]
    /// Drop the given `UnderwriterCapability`.
    public fun drop_underwriter_capability_test(
        underwriter_capability: UnderwriterCapability
    ) {
        // Unpack provided capability.
        let UnderwriterCapability{underwriter_id: _} = underwriter_capability;
    }

/*
    #[test_only]
    /// Return `MarketInfo` fields corresponding to given `market_id`,
    /// aborting if no such registered market.
    ///
    /// # Restrictions
    ///
    /// * Restricted to test-only to prevent excessive public queries
    ///   against the registry and thus potential transaction collisions
    ///   across markets.
    public fun get_market_info_test(
        market_id: u64
    ): (
        String,
        String,
        u64,
        u64,
        Option<u64>
    ) acquires Registry {
        // Immutably borrow map from market ID to market info.
        let markets_ref = &borrow_global<Registry>(@econia).market_id_to_info;
        // Immutably borrow corresponding market info.
        let market_info_ref = tablist::borrow(markets_ref, market_id);
        (market_info_ref.base_type, // Return market info fields.
         market_info_ref.quote_type,
         market_info_ref.lot_size,
         market_info_ref.tick_size,
         market_info_ref.underwriter_id)
    }
*/

    #[test_only]
    /// Return an `UnderwriterCapabilty` having given ID, setting it as
    /// a valid ID in the registry.
    public fun get_underwriter_capability_test(
        underwriter_id: u64
    ): UnderwriterCapability
    acquires Registry {
        // If proposed underwriter ID is less than number registered:
        if (underwriter_id < borrow_global<Registry>(@econia).n_underwriters)
            // Update registry to have provided ID as number registered.
            borrow_global_mut<Registry>(@econia).n_underwriters =
                underwriter_id;
        // Return corresponding underwriter capability.
        UnderwriterCapability{underwriter_id}
    }

    #[test_only]
    /// Initialize registry for testing.
    public fun init_test() {
        // Get signer for Econia account.
        let econia = account::create_signer_with_capability(
            &account::create_test_signer_cap(@econia));
        // Create Aptos-style account for Econia.
        account::create_account_for_test(@econia);
        init_module(&econia); // Init registry.
        incentives::init_test(); // Init incentives
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify custodian then underwriter capability registration.
    fun test_register_capabilities()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Assert number of registered custodians, underwriters.
        assert!(get_n_custodians() == 0, 0);
        assert!(get_n_underwriters() == 0, 0);
        // Get custodian registration fee.
        let custodian_registration_fee =
            incentives::get_custodian_registration_fee();
        // Get custodian capability.
        let custodian_capability = register_custodian_capability(
            assets::mint_test<UC>(custodian_registration_fee));
        // Assert it has ID 1.
        assert!(get_custodian_id(&custodian_capability) == 1, 0);
        // Drop custodian capability.
        drop_custodian_capability_test(custodian_capability);
        // Get another custodian capability.
        custodian_capability = register_custodian_capability(
            assets::mint_test<UC>(custodian_registration_fee));
        // Assert it has ID 2.
        assert!(get_custodian_id(&custodian_capability) == 2, 0);
        // Drop custodian capability.
        drop_custodian_capability_test(custodian_capability);
        // Get another custodian capability.
        custodian_capability = register_custodian_capability(
            assets::mint_test<UC>(custodian_registration_fee));
        // Assert it has ID 3.
        assert!(get_custodian_id(&custodian_capability) == 3, 0);
        // Drop custodian capability.
        drop_custodian_capability_test(custodian_capability);
        // Get underwriter registration fee.
        let underwriter_registration_fee =
            incentives::get_underwriter_registration_fee();
        // Get underwriter capability.
        let underwriter_capability = register_underwriter_capability(
            assets::mint_test<UC>(underwriter_registration_fee));
        // Assert it has ID 1.
        assert!(get_underwriter_id(&underwriter_capability) == 1, 0);
        // Drop underwriter capability.
        drop_underwriter_capability_test(underwriter_capability);
        // Get another underwriter capability.
        underwriter_capability = register_underwriter_capability(
            assets::mint_test<UC>(underwriter_registration_fee));
        // Assert it has ID 2.
        assert!(get_underwriter_id(&underwriter_capability) == 2, 0);
        // Drop underwriter capability.
        drop_underwriter_capability_test(underwriter_capability);
        // Get another underwriter capability.
        underwriter_capability = register_underwriter_capability(
            assets::mint_test<UC>(underwriter_registration_fee));
        // Assert it has ID 3.
        assert!(get_underwriter_id(&underwriter_capability) == 3, 0);
        // Drop underwriter capability.
        drop_underwriter_capability_test(underwriter_capability);
        // Assert number of registered custodians, underwriters.
        assert!(get_n_custodians() == 3, 0);
        assert!(get_n_underwriters() == 3, 0);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for non-coin type.
    fun test_register_market_base_not_coin()
    acquires Registry {
        // Declare arguments.
        let lot_size = 0;
        let tick_size = 0;
        let min_size = 0;
        // Attempt invalid invocation.
        register_market_base_coin_internal<BC, QC, UC>(
            lot_size, tick_size, min_size, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for too few characters in generic asset name.
    fun test_register_market_generic_name_too_few()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Get underwriter capability.
        let underwriter_capability = get_underwriter_capability_test(1);
        // Declare arguments.
        let base_name_generic = string::utf8(b"ABC");
        let lot_size = 0;
        let tick_size = 0;
        let min_size = 0;
        // Attempt invalid invocation.
        register_market_base_generic_internal<QC, UC>(
            base_name_generic, lot_size, tick_size, min_size,
            &underwriter_capability, coin::zero());
        // Drop underwriter capability.
        drop_underwriter_capability_test(underwriter_capability);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for too many characters in generic asset name.
    fun test_register_market_generic_name_too_many()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Get underwriter capability.
        let underwriter_capability = get_underwriter_capability_test(1);
        // Declare arguments.
        let base_name_generic = // Get 36-character string.
            string::utf8(b"123456789012345678901234567890123456");
        string::append(&mut base_name_generic, // Append 37 characters.
            string::utf8(b"1111111111111111111111111111111111111"));
        let lot_size = 0;
        let tick_size = 0;
        let min_size = 0;
        // Attempt invalid invocation.
        register_market_base_generic_internal<QC, UC>(
            base_name_generic, lot_size, tick_size, min_size,
            &underwriter_capability, coin::zero());
        // Drop underwriter capability.
        drop_underwriter_capability_test(underwriter_capability);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for lot size 0.
    fun test_register_market_lot_size_0()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Declare arguments.
        let lot_size = 0;
        let tick_size = 0;
        let min_size = 0;
        // Attempt invalid invocation.
        register_market_base_coin_internal<BC, QC, UC>(
            lot_size, tick_size, min_size, assets::mint_test(1));
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for minimum size 0.
    fun test_register_market_min_size_0()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Declare arguments.
        let lot_size = 1;
        let tick_size = 1;
        let min_size = 0;
        // Attempt invalid invocation.
        register_market_base_coin_internal<BC, QC, UC>(
            lot_size, tick_size, min_size, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for quote asset not coin.
    fun test_register_market_quote_not_coin()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Declare arguments.
        let lot_size = 1;
        let tick_size = 1;
        let min_size = 1;
        // Attempt invalid invocation.
        register_market_base_coin_internal<QC, GenericAsset, UC>(
            lot_size, tick_size, min_size, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for market already registered.
    fun test_register_market_registered()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Declare arguments.
        let lot_size = 1;
        let tick_size = 1;
        let min_size = 1;
        // Get market registration fee.
        let fee = incentives::get_market_registration_fee();
        // Register valid market.
        register_market_base_coin_internal<BC, QC, UC>(
            lot_size, tick_size, min_size, assets::mint_test(fee));
        // Attempt invalid re-registration.
        register_market_base_coin_internal<BC, QC, UC>(
            lot_size, tick_size, min_size, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for base and quote same coin type.
    fun test_register_market_same_type()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Declare arguments.
        let lot_size = 1;
        let tick_size = 1;
        let min_size = 1;
        // Attempt invalid invocation.
        register_market_base_coin_internal<QC, QC, UC>(
            lot_size, tick_size, min_size, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for tick size 0.
    fun test_register_market_tick_size_0()
    acquires Registry {
        init_test(); // Initialize for testing.
        // Declare arguments.
        let lot_size = 1;
        let tick_size = 0;
        let min_size = 0;
        // Attempt invalid invocation.
        register_market_base_coin_internal<BC, QC, UC>(
            lot_size, tick_size, min_size, coin::zero());
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}