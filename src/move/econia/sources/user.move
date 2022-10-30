module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::table::{Self, Table};
    use aptos_framework::type_info::{Self, TypeInfo};
    use econia::tablist::{Self, Tablist};
    use econia::registry::{Self, GenericAsset};
    use std::string::String;
    use std::signer::address_of;
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::avl_queue::{u_128_by_32, u_64_by_32};
    #[test_only]
    use econia::assets::{BC, QC};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// All of a user's collateral across all market accounts.
    struct Collateral<phantom CoinType> has key {
        /// Map from market account ID to collateral for market account.
        /// Separated into different table entries to reduce transaction
        /// collisions across markets. Enables off-chain iterated
        /// indexing by market account ID.
        map: Tablist<u128, Coin<CoinType>>
    }

    /// Represents a user's open orders and asset counts for a given
    /// market account ID. Contains `registry::MarketInfo` field
    /// duplicates to reduce global storage item queries.
    struct MarketAccount has store {
        /// `registry::MarketInfo.base_type`.
        base_type: TypeInfo,
        /// `registry::MarketInfo.base_name_generic`.
        base_name_generic: String,
        /// `registry::MarketInfo.quote_type`.
        quote_type: TypeInfo,
        /// `registry::MarketInfo.lot_size`.
        lot_size: u64,
        /// `registry::MarketInfo.tick_size`.
        tick_size: u64,
        /// `registry::MarketInfo.min_size`.
        min_size: u64,
        /// `registry::MarketInfo.underwriter_id`.
        underwriter_id: u64,
        /// Map from order access key to open ask order.
        asks: Tablist<u64, Order>,
        /// Map from order access key to open bid order.
        bids: Tablist<u64, Order>,
        /// Access key of ask order at top of inactive stack, if any.
        asks_stack_top: u64,
        /// Access key of bid order at top of inactive stack, if any.
        bids_stack_top: u64,
        /// Total base asset units held as collateral.
        base_total: u64,
        /// Base asset units available to withdraw.
        base_available: u64,
        /// Amount `base_total` will increase to if all open bids fill.
        base_ceiling: u64,
        /// Total quote asset units held as collateral.
        quote_total: u64,
        /// Quote asset units available to withdraw.
        quote_available: u64,
        /// Amount `quote_total` will increase to if all open asks fill.
        quote_ceiling: u64
    }

    /// All of a user's market accounts.
    struct MarketAccounts has key {
        /// Map from market account ID to `MarketAccount`.
        map: Table<u128, MarketAccount>,
        /// Map from market ID to vector of custodian IDs for which
        /// a market account has been registered on the given market.
        /// Enables off-chain iterated indexing by market account ID and
        /// assorted on-chain queries.
        custodians: Tablist<u64, vector<u64>>
    }

    /// An open order, either ask or bid.
    struct Order has store {
        /// Market order ID. `NIL` if inactive.
        market_order_id: u128,
        /// Order size left to fill, in lots. When `market_order_id` is
        /// `NIL`, indicates access key of next inactive order in stack.
        size: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Market account already exists.
    const E_EXISTS_MARKET_ACCOUNT: u64 = 0;
    /// Custodian ID has not been registered.
    const E_UNREGISTERED_CUSTODIAN: u64 = 1;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no custodian.
    const NO_CUSTODIAN: u64 = 0;
    /// Flag for null value when null defined as 0.
    const NIL: u64 = 0;
    /// Number of bits market ID is shifted in market account ID.
    const SHIFT_MARKET_ID: u8 = 64;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Register market account for indicated market and custodian.
    ///
    /// # Type parameters
    ///
    /// * `BaseType`: Base type for indicated market. If base asset is
    ///   a generic asset, must be passed as `registry::GenericAsset`
    ///   (alternatively use `register_market_account_base_generic()`).
    /// * `QuoteType`: Quote type for indicated market.
    ///
    /// # Parameters
    ///
    /// * `user`: User registering a market account.
    /// * `market_id`: Market ID for given market.
    /// * `custodian_id`: Custodian ID to register account with, or
    ///   `NO_CUSTODIAN`.
    ///
    /// # Aborts
    ///
    /// * `E_UNREGISTERED_CUSTODIAN`: Custodian ID has not been
    ///   registered.
    ///
    /// # Testing
    ///
    /// * `test_register_market_account_unregistered_custodian()`
    /// * `test_register_market_accounts()`
    public entry fun register_market_account<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        custodian_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // If custodian ID indicated, assert it is registered.
        if (custodian_id != NO_CUSTODIAN) assert!(
            registry::is_registered_custodian_id(custodian_id),
            E_UNREGISTERED_CUSTODIAN);
        let user_address = address_of(user); // Get user address.
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        // Register market accounts map entries.
        register_market_account_account_entries<BaseType, QuoteType>(
            user, user_address, market_account_id, market_id, custodian_id);
        // If base asset is coin, register collateral entry.
        if (coin::is_coin_initialized<BaseType>())
            register_market_account_collateral_entry<BaseType>(
                user, user_address, market_account_id);
        // Register quote asset collateral entry.
        register_market_account_collateral_entry<QuoteType>(
            user, user_address, market_account_id);
    }

    #[cmd]
    /// Wrapped `register_market_account()` call for generic base asset.
    ///
    /// # Testing
    ///
    /// * `test_register_market_accounts()`
    public entry fun register_market_account_generic_base<
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        custodian_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        register_market_account<GenericAsset, QuoteType>(
            user, market_id, custodian_id);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register market account entries for given market account info.
    ///
    /// Inner function for `register_market_account()`.
    ///
    /// # Type parameters
    ///
    /// * `BaseType`: Base type for indicated market.
    /// * `QuoteType`: Quote type for indicated market.
    ///
    /// # Parameters
    ///
    /// * `user`: User registering a market account.
    /// * `user_address`: Address of user registering a market account.
    /// * `market_account_id`: Market account ID for given market.
    /// * `market_id`: Market ID for given market.
    /// * `custodian_id`: Custodian ID to register account with, or
    ///   `NO_CUSTODIAN`.
    ///
    /// # Aborts
    ///
    /// * `E_EXISTS_MARKET_ACCOUNT`: Market account already exists.
    ///
    /// # Testing
    ///
    /// * `test_register_market_account_account_entries_exists()`
    /// * `test_register_market_accounts()`
    fun register_market_account_account_entries<
        BaseType,
        QuoteType
    >(
        user: &signer,
        user_address: address,
        market_account_id: u128,
        market_id: u64,
        custodian_id: u64
    ) acquires MarketAccounts {
        let (base_type, quote_type) = // Get base and quote types.
            (type_info::type_of<BaseType>(), type_info::type_of<QuoteType>());
        // Get market info.
        let (base_name_generic, lot_size, tick_size, min_size, underwriter_id)
            = registry::get_market_info_for_market_account(
                market_id, base_type, quote_type);
        // If user does not have a market accounts map initialized:
        if (!exists<MarketAccounts>(user_address))
            // Pack an empty one and move it to their account
            move_to<MarketAccounts>(user, MarketAccounts{
                map: table::new(), custodians: tablist::new()});
        // Mutably borrow market accounts map.
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        assert!( // Assert no entry exists for given market account ID.
            !table::contains(market_accounts_map_ref_mut, market_account_id),
            E_EXISTS_MARKET_ACCOUNT);
        table::add( // Add empty market account for market account ID.
            market_accounts_map_ref_mut, market_account_id, MarketAccount{
                base_type, base_name_generic, quote_type, lot_size, tick_size,
                min_size, underwriter_id, asks: tablist::new(),
                bids: tablist::new(), asks_stack_top: NIL, bids_stack_top: NIL,
                base_total: 0, base_available: 0, base_ceiling: 0,
                quote_total: 0, quote_available: 0, quote_ceiling: 0});
        let custodians_ref_mut = // Mutably borrow custodians maps.
            &mut borrow_global_mut<MarketAccounts>(user_address).custodians;
        // If custodians map has no entry for given market ID:
        if (!tablist::contains(custodians_ref_mut, market_id)) {
            // Add new entry indicating new custodian ID.
            tablist::add(custodians_ref_mut, market_id,
                         vector::singleton(custodian_id));
        } else { // If already entry for given market ID:
            // Mutably borrow vector of custodians for given market.
            let market_custodians_ref_mut =
                tablist::borrow_mut(custodians_ref_mut, market_id);
            // Push back custodian ID for given market account.
            vector::push_back(market_custodians_ref_mut, custodian_id);
        }
    }

    /// Inner function for `register_market_account()`.
    ///
    /// Does not check if collateral entry already exists for given
    /// market account ID, as market account existence check already
    /// performed by `register_market_account_accounts_entries()` in
    /// `register_market_account()`.
    ///
    /// # Type parameters
    ///
    /// * `CoinType`: Phantom coin type for indicated market.
    ///
    /// # Parameters
    ///
    /// * `user`: User registering a market account.
    /// * `user_address`: Address of user registering a market account.
    /// * `market_account_id`: Market account ID for given market.
    ///
    /// # Testing
    ///
    /// * `test_register_market_accounts()`
    fun register_market_account_collateral_entry<
        CoinType
    >(
        user: &signer,
        user_address: address,
        market_account_id: u128
    ) acquires Collateral {
        // If user does not have a collateral map initialized, pack an
        // empty one and move it to their account.
        if (!exists<Collateral<CoinType>>(user_address))
            move_to<Collateral<CoinType>>(user, Collateral{
                map: tablist::new()});
        let collateral_map_ref_mut = // Mutably borrow collateral map.
            &mut borrow_global_mut<Collateral<CoinType>>(user_address).map;
        // Add an empty entry for given market account ID.
        tablist::add(collateral_map_ref_mut, market_account_id,
                     coin::zero<CoinType>());
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return market account ID with encoded market and custodian IDs.
    ///
    /// # Testing
    ///
    /// * `test_get_market_account_id_test()`
    fun get_market_account_id_test(
        market_id: u64,
        custodian_id: u64
    ): u128 {
        ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify valid return.
    fun test_get_market_account_id_test() {
        let market_id =    u_64_by_32(b"10000000000000000000000000000000",
                                      b"00000000000000000000000000000001");
        let custodian_id = u_64_by_32(b"11000000000000000000000000000000",
                                      b"00000000000000000000000000000011");
        assert!(get_market_account_id_test(market_id, custodian_id) ==
                          u_128_by_32(b"10000000000000000000000000000000",
                                      b"00000000000000000000000000000001",
                                      b"11000000000000000000000000000000",
                                      b"00000000000000000000000000000011"), 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for market account already exists.
    fun test_register_market_account_account_entries_exists(
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register test markets, storing pure coin market ID.
        let (market_id_pure_coin, _, _, _, _, _, _, _, _, _, _, _) =
            registry::register_markets_test();
        // Register user with market account.
        register_market_account<BC, QC>(
            user, market_id_pure_coin, NO_CUSTODIAN);
        // Attempt invalid re-registration.
        register_market_account<BC, QC>(
            user, market_id_pure_coin, NO_CUSTODIAN);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for unregistered custodian.
    fun test_register_market_account_unregistered_custodian(
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        registry::init_test(); // Initialize registry.
        // Attempt invalid invocation.
        register_market_account<BC, QC>(user, 1, 123);
    }

    #[test(user = @user)]
    /// Verify state updates for market account registration.
    ///
    /// Exercises all non-assert conditional branches for:
    ///
    /// * `register_market_account()`
    /// * `register_market_account_account_entries()`
    /// * `register_market_account_collateral_entry()`
    fun test_register_market_accounts(
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register test markets, storing market info.
        let (market_id_pure_coin, base_name_generic_pure_coin,
             lot_size_pure_coin, tick_size_pure_coin, min_size_pure_coin,
             underwriter_id_pure_coin, market_id_generic,
             base_name_generic_generic, lot_size_generic, tick_size_generic,
             min_size_generic, underwriter_id_generic) =
             registry::register_markets_test();
        let margin_custodian_id = 123; // Declare custodian ID.
        // Set custodian ID as registered.
        registry::set_registered_custodian_test(margin_custodian_id);
        // Register market account for pure coin spot trading.
        register_market_account<BC, QC>(
            user, market_id_pure_coin, NO_CUSTODIAN);
        register_market_account<BC, QC>( // Register margin account
            user, market_id_pure_coin, margin_custodian_id);
        // Register generic asset account.
        register_market_account_generic_base<QC>(
            user, market_id_generic, NO_CUSTODIAN);
        // Get market account IDs.
        let market_account_id_spot = get_market_account_id_test(
            market_id_pure_coin, NO_CUSTODIAN);
        let market_account_id_margin = get_market_account_id_test(
            market_id_pure_coin, margin_custodian_id);
        let market_account_id_generic = get_market_account_id_test(
            market_id_generic, NO_CUSTODIAN);
        // Immutably borrow base coin collateral.
        let collateral_map_ref = &borrow_global<Collateral<BC>>(@user).map;
        // Assert entries only made for pure coin market accounts.
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_spot)) == 0, 0);
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_margin)) == 0, 0);
        assert!(!tablist::contains(
            collateral_map_ref, market_account_id_generic), 0);
        // Immutably borrow quote coin collateral.
        let collateral_map_ref = &borrow_global<Collateral<QC>>(@user).map;
        // Assert entries made for all market accounts.
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_spot)) == 0, 0);
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_margin)) == 0, 0);
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_generic)) == 0, 0);
        let custodians_map_ref = // Immutably borrow custodians map.
            &borrow_global<MarketAccounts>(@user).custodians;
        // Immutably borrow custodians entry for pure coin market.
        let custodians_ref =
            tablist::borrow(custodians_map_ref, market_id_pure_coin);
        assert!( // Assert listed custodians.
            *custodians_ref == vector[NO_CUSTODIAN, margin_custodian_id], 0);
        // Immutably borrow custodians entry for generic market.
        custodians_ref =
            tablist::borrow(custodians_map_ref, market_id_generic);
        assert!( // Assert listed custodian.
            *custodians_ref == vector[NO_CUSTODIAN], 0);
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(@user).map;
        // Immutably borrow pure coin spot market account.
        let market_account_ref =
            table::borrow(market_accounts_map_ref, market_account_id_spot);
        // Assert state.
        assert!(market_account_ref.base_type == type_info::type_of<BC>(), 0);
        assert!(market_account_ref.base_name_generic
                == base_name_generic_pure_coin, 0);
        assert!(market_account_ref.quote_type == type_info::type_of<QC>(), 0);
        assert!(market_account_ref.lot_size == lot_size_pure_coin, 0);
        assert!(market_account_ref.tick_size == tick_size_pure_coin, 0);
        assert!(market_account_ref.min_size == min_size_pure_coin, 0);
        assert!(market_account_ref.underwriter_id
                == underwriter_id_pure_coin, 0);
        assert!(tablist::is_empty(&market_account_ref.asks), 0);
        assert!(tablist::is_empty(&market_account_ref.bids), 0);
        assert!(market_account_ref.asks_stack_top == NIL, 0);
        assert!(market_account_ref.bids_stack_top == NIL, 0);
        assert!(market_account_ref.base_total == 0, 0);
        assert!(market_account_ref.base_available == 0, 0);
        assert!(market_account_ref.base_ceiling == 0, 0);
        assert!(market_account_ref.quote_total == 0, 0);
        assert!(market_account_ref.quote_available == 0, 0);
        assert!(market_account_ref.quote_ceiling == 0, 0);
        // Immutably borrow pure coin margin market account.
        market_account_ref =
            table::borrow(market_accounts_map_ref, market_account_id_margin);
        // Assert state.
        assert!(market_account_ref.base_type == type_info::type_of<BC>(), 0);
        assert!(market_account_ref.base_name_generic
                == base_name_generic_pure_coin, 0);
        assert!(market_account_ref.quote_type == type_info::type_of<QC>(), 0);
        assert!(market_account_ref.lot_size == lot_size_pure_coin, 0);
        assert!(market_account_ref.tick_size == tick_size_pure_coin, 0);
        assert!(market_account_ref.min_size == min_size_pure_coin, 0);
        assert!(market_account_ref.underwriter_id
                == underwriter_id_pure_coin, 0);
        assert!(tablist::is_empty(&market_account_ref.asks), 0);
        assert!(tablist::is_empty(&market_account_ref.bids), 0);
        assert!(market_account_ref.asks_stack_top == NIL, 0);
        assert!(market_account_ref.bids_stack_top == NIL, 0);
        assert!(market_account_ref.base_total == 0, 0);
        assert!(market_account_ref.base_available == 0, 0);
        assert!(market_account_ref.base_ceiling == 0, 0);
        assert!(market_account_ref.quote_total == 0, 0);
        assert!(market_account_ref.quote_available == 0, 0);
        assert!(market_account_ref.quote_ceiling == 0, 0);
        // Immutably borrow generic market account.
        market_account_ref =
            table::borrow(market_accounts_map_ref, market_account_id_generic);
        // Assert state.
        assert!(market_account_ref.base_type
                == type_info::type_of<GenericAsset>(), 0);
        assert!(market_account_ref.base_name_generic
                == base_name_generic_generic, 0);
        assert!(market_account_ref.quote_type == type_info::type_of<QC>(), 0);
        assert!(market_account_ref.lot_size == lot_size_generic, 0);
        assert!(market_account_ref.tick_size == tick_size_generic, 0);
        assert!(market_account_ref.min_size == min_size_generic, 0);
        assert!(market_account_ref.underwriter_id
                == underwriter_id_generic, 0);
        assert!(tablist::is_empty(&market_account_ref.asks), 0);
        assert!(tablist::is_empty(&market_account_ref.bids), 0);
        assert!(market_account_ref.asks_stack_top == NIL, 0);
        assert!(market_account_ref.bids_stack_top == NIL, 0);
        assert!(market_account_ref.base_total == 0, 0);
        assert!(market_account_ref.base_available == 0, 0);
        assert!(market_account_ref.base_ceiling == 0, 0);
        assert!(market_account_ref.quote_total == 0, 0);
        assert!(market_account_ref.quote_available == 0, 0);
        assert!(market_account_ref.quote_ceiling == 0, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}