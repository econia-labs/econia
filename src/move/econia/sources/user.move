/// User-side collateral and book keeping management. For a given
/// market, a user can register multiple "market accounts", with each
/// such market account having a different delegated custodian and a
/// unique `MarketAccountInfo`. For a given market account, a user has
/// entries in both `Collateral` and `OpenOrders`.
module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::registry;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// All collateral for a given coin type, across all
    /// `MarketAccountInfo`s for a given user
    struct Collateral<phantom CoinType> has key {
        /// Map from `MarketAccountInfo` to coins held as collateral on
        /// given market account. Separated into different table entries
        /// to prevent transaction collisions across markets
        market_accounts: open_table::OpenTable<MarketAccountInfo,
            MarketAccountCollateral<CoinType>>
    }

    /// Unique ID describing a market and a delegated custodian
    struct MarketAccountInfo has copy, drop, store {
        /// The market that a user is trading on
        market_info: registry::MarketInfo,
        /// Serial ID of registered account custodian, set to 0 when
        /// given account does not have an authorized custodian
        custodian_id: u64
    }

    /// Collateral for a given `MarketAccountInfo`
    struct MarketAccountCollateral<phantom CoinType> has store {
       /// Coins held as collateral
       coins: Coin<CoinType>,
       /// Coins available to withdraw
       coins_available: u64
    }

    /// Open orders for a given `MarketAccountInfo`
    struct MarketAccountOpenOrders has store {
        /// Scale factor for given market, included as a lookup
        /// optimization for integer-based arithmetic
        scale_factor: u64,
        /// Map from order ID to size of order, in base parcels
        asks: CritBitTree<u64>,
        /// Map from order ID to size of order, in base parcels
        bids: CritBitTree<u64>,
    }

    /// All open orders across all `MarketAccountInfo`s for a given user
    struct OpenOrders has key {
        /// Map from `MarketAccountInfo` to open orders on given market
        /// account. Separated into different table entries to prevent
        /// transaction collisions across markets
        market_accounts: open_table::OpenTable<
            MarketAccountInfo,
            MarketAccountOpenOrders
        >
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When no such market has been registered
    const E_NO_MARKET: u64 = 0;
    /// When the passed custodian ID is invalid
    const E_INVALID_CUSTODIAN_ID: u64 = 1;
    /// When a market account registered for given market account info
    const E_MARKET_ACCOUNT_REGISTERED: u64 = 2;
    /// When a collateral transfer does not have specified amount
    const E_NO_TRANSFER_AMOUNT: u64 = 3;
    /// When a market account is not registered
    const E_NO_MARKET_ACCOUNT: u64 = 4;
    /// When specified coin type does not correspond to the trading pair
    /// for a given market
    const E_NOT_IN_MARKET_PAIR: u64 = 5;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register `user` with a market account for given market and
    /// `custodian_id`
    ///
    /// # Abort conditions
    /// * If market is not already registered
    /// * If invalid `custodian_id`
    public entry fun register_market_account<B, Q, E>(
        user: &signer,
        custodian_id: u64
    ) acquires Collateral, OpenOrders {
        // Assert the market has alrady been registered
        assert!(registry::is_registered_types<B, Q, E>(), E_NO_MARKET);
        // Assert that given custodian ID is in bounds
        assert!(registry::is_valid_custodian_id(custodian_id),
            E_INVALID_CUSTODIAN_ID);
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<B, Q, E>(),
            custodian_id}; // Pack market account info
        register_open_orders(user, market_account_info);
        register_collateral<B>(user, market_account_info);
        register_collateral<Q>(user, market_account_info);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Deposit `coins` as collateral for `user`'s market account
    /// specified by `market_account_info`.
    ///
    /// # Abort conditions
    /// * If `CoinType` is neither base nor quote for market account
    /// * If `coins` has a value of 0
    /// * If `user` does not have corresponding market account
    ///   registered
    public fun deposit_collateral<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        coins: coin::Coin<CoinType>
    ) acquires Collateral, OpenOrders {
        // Assert coin type is either base or quote for market account
        assert!(registry::coin_is_in_market_pair<CoinType>(
            &market_account_info.market_info), E_NOT_IN_MARKET_PAIR);
        // Assert attempting to actually deposit coins
        assert!(coin::value(&coins) != 0, E_NO_TRANSFER_AMOUNT);
        // Assert market account registered for market account info
        assert!(exists_market_account(market_account_info, user),
            E_NO_MARKET_ACCOUNT);
        // Borrow mutable reference to market accounts collateral table
        let market_accounts =
            &mut borrow_global_mut<Collateral<CoinType>>(user).market_accounts;
        // Borrow mutable reference to market account collateral
        let market_account_collateral = open_table::borrow_mut(market_accounts,
            market_account_info);
        // Increment available coin count
        market_account_collateral.coins_available =
            market_account_collateral.coins_available + coin::value(&coins);
        // Merge coins into market account collateral
        coin::merge(&mut market_account_collateral.coins, coins);
    }

    /// Return `true` if `user` has an `OpenOrders` entry for
    /// `market_account_info`, otherwise `false`.
    public fun exists_market_account(
        market_account_info: MarketAccountInfo,
        user: address
    ): bool
    acquires OpenOrders {
        // Return false if no open orders resource exists
        if(!exists<OpenOrders>(user)) return false;
        // Borrow immutable ref to open orders market accounts table
        let market_accounts = &borrow_global<OpenOrders>(user).market_accounts;
        // Return if market account is registered in table
        open_table::contains(market_accounts, market_account_info)
    }

    /// Get a `MarketInfo` for type arguments, pack with `custodian_id`
    /// into a `MarketAccountInfo` and return
    public fun market_account_info<B, Q, E>(
        custodian_id: u64
    ): MarketAccountInfo {
        MarketAccountInfo{
            market_info: registry::market_info<B, Q, E>(),
            custodian_id
        }
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register user with a `Collateral` entry for given `CoinType`
    /// and `market_account_info`, initializing `Collateral` if it does
    /// not already exist
    /// # Abort conditions
    /// * If user already has a `Collateral` entry for given
    ///   `market_account_info`
    fun register_collateral<CoinType>(
        user: &signer,
        market_account_info: MarketAccountInfo,
    ) acquires Collateral {
        let user_address = address_of(user); // Get user's address
        // If user does not have a collateral resource initialized
        if(!exists<Collateral<CoinType>>(user_address)) {
            // Pack an empty one and move to their account
            move_to<Collateral<CoinType>>(user,
                Collateral{market_accounts: open_table::empty()})
        };
        // Borrow mutable reference to collateral market accounts table
        let market_accounts =
            &mut borrow_global_mut<Collateral<CoinType>>(
                user_address).market_accounts;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(market_accounts,
            market_account_info), E_MARKET_ACCOUNT_REGISTERED);
        // Add an empty entry for given market account info
        open_table::add(market_accounts, market_account_info,
            MarketAccountCollateral{
                coins: coin::zero<CoinType>(),
                coins_available: 0});
    }

    /// Register user with an `OpenOrders` entry for the given
    /// `market_account_info`, initializing `OpenOrders` if it does not
    /// already exist
    /// # Abort conditions
    /// * If user already has an `OpenOrders` entry for given
    ///   `market_account_info`
    fun register_open_orders(
        user: &signer,
        market_account_info: MarketAccountInfo,
    ) acquires OpenOrders {
        let user_address = address_of(user); // Get user's address
        // If user does not have an open orders initialized
        if(!exists<OpenOrders>(user_address)) {
            // Pack an empty one and move to their account
            move_to<OpenOrders>(user,
                OpenOrders{market_accounts: open_table::empty()})
        };
        // Borrow mutable reference to open orders market accounts table
        let market_accounts =
            &mut borrow_global_mut<OpenOrders>(user_address).market_accounts;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(market_accounts,
            market_account_info), E_MARKET_ACCOUNT_REGISTERED);
        // Get scale factor for corresponding market
        let scale_factor = registry::scale_factor_from_market_info(
            &market_account_info.market_info);
        // Add an empty entry for given market account info
        open_table::add(market_accounts, market_account_info,
            MarketAccountOpenOrders{
                scale_factor,
                asks: critbit::empty(),
                bids: critbit::empty()});
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::coins::{
        BC,
        QC,
        Self
    };

    #[test_only]
    use econia::registry::{E1, E2};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for attempting to deposit zero amount
    fun test_deposit_collateral_no_amount()
    acquires Collateral, OpenOrders {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123 }; // Declare market account info
        // Attempt invalid deposit
        deposit_collateral<BC>(@user, market_account_info, coin::zero<BC>());
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for attempting to deposit coin not in market pair
    fun test_deposit_collateral_not_in_pair()
    acquires Collateral, OpenOrders {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<E1, E1, E1>(),
            custodian_id: 123 }; // Declare market account info
        // Attempt invalid deposit
        deposit_collateral<BC>(@user, market_account_info, coin::zero<BC>());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempting to deposit when no market account
    fun test_deposit_collateral_no_market_account(
        econia: &signer
    ) acquires Collateral, OpenOrders {
        coins::init_coin_types(econia); // Initialize coin types
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123 }; // Declare market account info
        // Attempt invalid deposit
        deposit_collateral<BC>(@user, market_account_info,
            coins::mint<BC>(econia, 25));
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful collateral deposit
    fun test_deposit_collateral(
        econia: &signer,
        user: &signer
    ) acquires Collateral, OpenOrders {
        let deposit_amount = 25; // Declare deposit amount
        // Register a test market for trading
        registry::register_test_market(econia);
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 0}; // Declare market account info
        // Register user with market account
        register_market_account<BC, QC, E1>(user, 0);
        // Attempt make valid deposit
        deposit_collateral<BC>(@user, market_account_info,
            coins::mint<BC>(econia, deposit_amount));
        // Borrow immutable ref to collateral market accounts table
        let market_accounts =
            &borrow_global<Collateral<BC>>(@user).market_accounts;
        // Borrow immutable ref to collateral for market account
        let market_collateral = open_table::borrow(market_accounts,
            market_account_info);
        // Assert fields
        assert!(coin::value(&market_collateral.coins) == deposit_amount, 0);
        assert!(market_collateral.coins_available == deposit_amount, 0);
    }

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_collateral(
        user: &signer
    ) acquires Collateral {
        let market_account_info_1 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E1>(),
            custodian_id: 123 }; // Declare market account info
        let market_account_info_2 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E2>(),
            custodian_id: 456 }; // Declare market account info
        // Register collateral entry
        register_collateral<BC>(user, market_account_info_1);
        // Register another collateral entry
        register_collateral<BC>(user, market_account_info_2);
        // Borrow immutable ref to collateral market accounts table
        let market_accounts =
            &borrow_global<Collateral<BC>>(address_of(user)).market_accounts;
        // Borrow immutable ref to collateral for first market account
        let market_collateral = open_table::borrow(market_accounts,
            market_account_info_1);
        // Assert fields
        assert!(coin::value(&market_collateral.coins) == 0, 0);
        assert!(market_collateral.coins_available == 0, 0);
        // Borrow immutable ref to collateral for second market account
        let market_collateral = open_table::borrow(market_accounts,
            market_account_info_2);
        // Assert fields
        assert!(coin::value(&market_collateral.coins) == 0, 0);
        assert!(market_collateral.coins_available == 0, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for given market account is already registered
    fun test_register_collateral_already_registered(
        user: &signer
    ) acquires Collateral {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123 }; // Declare market account info
        // Register collateral entry
        register_collateral<BC>(user, market_account_info);
        // Attempt invalid re-registration
        register_collateral<BC>(user, market_account_info);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for invalid custodian
    fun test_register_market_account_invalid_custodian_id(
        econia: &signer,
        user: &signer
    ) acquires Collateral, OpenOrders {
       registry::register_test_market(econia); // Init test market
       // Attempt invalid registration
       register_market_account<BC, QC, E1>(user, 1);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for no such registered market
    fun test_register_market_account_no_market(
        user: &signer
    ) acquires Collateral, OpenOrders {
       // Attempt invalid registration
       register_market_account<BC, QC, E1>(user, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful market account registration
    fun test_register_market_accounts(
        econia: &signer,
        user: &signer
    ): registry::CustodianCapability
    acquires Collateral, OpenOrders {
        registry::register_test_market(econia); // Init test market
        // Register a custodian
        let custodian_capability = registry::register_custodian_capability();
        // Register uncustodied and custodied test market accounts
        register_market_account<BC, QC, E1>(user, 0);
        register_market_account<BC, QC, E1>(user, 1);
        // Get market account info for both market accounts
        let market_account_info_0 = market_account_info<BC, QC, E1>(0);
        let market_account_info_1 = market_account_info<BC, QC, E1>(1);
        // Borrow immutable ref to open orders market accounts table
        let market_accounts =
            &borrow_global<OpenOrders>(address_of(user)).market_accounts;
        // Assert entries added to table
        assert!(
            open_table::contains(market_accounts, market_account_info_0), 0);
        assert!(
            open_table::contains(market_accounts, market_account_info_1), 0);
        // Borrow immutable ref to base collateral market accounts table
        let market_accounts =
            &borrow_global<Collateral<BC>>(address_of(user)).market_accounts;
        // Assert entries added to table
        assert!(
            open_table::contains(market_accounts, market_account_info_0), 0);
        assert!(
            open_table::contains(market_accounts, market_account_info_1), 0);
        // Borrow immutable ref to quote collateral table
        let market_accounts =
            &borrow_global<Collateral<QC>>(address_of(user)).market_accounts;
        assert!(
            open_table::contains(market_accounts, market_account_info_0), 0);
        assert!(
            open_table::contains(market_accounts, market_account_info_1), 0);
        custodian_capability // Return registered custodian capability
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify registration for multiple market accounts
    fun test_register_open_orders(
        econia: &signer,
        user: &signer
    ) acquires OpenOrders {
        registry::init_registry(econia); // Initialize registry
        let market_account_info_1 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123}; // Declare mock market account info
        let market_account_info_2 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E2>(),
            custodian_id: 456}; // Declare mock market account info
        // Register open orders entry
        register_open_orders(user, market_account_info_1);
        // Register open orders entry
        register_open_orders(user, market_account_info_2);
        // Borrow immutable ref to open orders market accounts table
        let market_accounts =
            &borrow_global<OpenOrders>(address_of(user)).market_accounts;
        // Borrow immutable ref to open orders for first market account
        let market_orders = open_table::borrow(market_accounts,
            market_account_info_1);
        // Assert fields
        assert!(market_orders.scale_factor == 10, 0);
        assert!(critbit::is_empty(&market_orders.asks), 0);
        assert!(critbit::is_empty(&market_orders.bids), 0);
        // Borrow immutable ref to open orders for second market account
        let market_orders = open_table::borrow(market_accounts,
            market_account_info_2);
        // Assert fields
        assert!(market_orders.scale_factor == 100, 0);
        assert!(critbit::is_empty(&market_orders.asks), 0);
        assert!(critbit::is_empty(&market_orders.bids), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for given market account is already registered
    fun test_register_open_orders_already_registered(
        econia: &signer,
        user: &signer
    ) acquires OpenOrders {
        registry::init_registry(econia); // Initialize registry
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E1>(),
            custodian_id: 123 }; // Declare market account info
        // Register open orders entry
        register_open_orders(user, market_account_info);
        // Attempt invalid re-registration
        register_open_orders(user, market_account_info);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}