/// User-side collateral and book keeping management. For a given
/// market, a user can register multiple `MarketAccount`s, with each
/// such market account having a different delegated custodian and a
/// unique `MarketAccountInfo`. For a given `MarketAccount`, a user has
/// entries in a `Collateral` map for both base and quote coins.
module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::registry;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Collateral map for given coin type, across all `MarketAccount`s
    struct Collateral<phantom CoinType> has key {
        /// Map from `MarketAccountInfo` to coins held as collateral for
        /// given `MarketAccount`. Separated into different table
        /// entries to reduce transaction collisions across markets
        map: open_table::OpenTable<MarketAccountInfo, Coin<CoinType>>
    }

    /// Unique ID describing a market and a delegated custodian
    struct MarketAccountInfo has copy, drop, store {
        /// The market that a user is trading on
        market_info: registry::MarketInfo,
        /// Serial ID of registered account custodian, set to 0 when
        /// given account does not have an authorized custodian
        custodian_id: u64
    }

    /// Represents a user's open orders and collateral status for a
    /// given `MarketAccountInfo`
    struct MarketAccount has store {
        /// Scale factor for given market, included as a lookup
        /// optimization for integer-based arithmetic
        scale_factor: u64,
        /// Map from order ID to size of order, in base parcels
        asks: CritBitTree<u64>,
        /// Map from order ID to size of order, in base parcels
        bids: CritBitTree<u64>,
        /// Base coins available for withdraw
        base_coins_available: u64,
        /// Quote coins available for withdraw
        quote_coins_available: u64,
    }

    /// Market account map for all of a user's `MarketAccount`s
    struct MarketAccounts has key {
        /// Map from `MarketAccountInfo` to `MarketAccount`. Separated
        /// into different table entries to reduce transaction
        /// collisions across markets
        map: open_table::OpenTable<MarketAccountInfo, MarketAccount>
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
    /// When not enough collateral
    const E_NOT_ENOUGH_COLLATERAL: u64 = 5;
    /// When unauthorized custodian ID
    const E_UNAUTHORIZED_CUSTODIAN: u64 = 6;
    /// When user attempts invalid custodian override
    const E_CUSTODIAN_OVERRIDE: u64 = 7;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const E_NO_CUSTODIAN: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register `user` with a `MarketAccount` and `Collateral` entries
    /// for given market and `custodian_id`.
    ///
    /// # Abort conditions
    /// * If market is not already registered
    /// * If invalid `custodian_id`
    public entry fun register_market_account<B, Q, E>(
        user: &signer,
        custodian_id: u64
    ) acquires Collateral, MarketAccounts {
        // Get market info
        let market_info = registry::market_info<B, Q, E>();
        // Assert market has already been registered
        assert!(registry::is_registered(market_info), E_NO_MARKET);
        // Assert given custodian ID is in bounds
        assert!(registry::is_valid_custodian_id(custodian_id),
            E_INVALID_CUSTODIAN_ID);
        let market_account_info = // Pack market account info
            MarketAccountInfo{market_info, custodian_id};
        // Register entry in market accounts map (aborts if already
        // registered)
        register_market_accounts_entry(user, market_account_info);
        // Registry collateral entry for base coin (aborts if already
        // registered)
        register_collateral_entry<B>(user, market_account_info);
        // Registry collateral entry for quote coin (aborts if already
        // registered)
        register_collateral_entry<Q>(user, market_account_info);
    }

    /// Withdraw `amount` of `Coin` having `CoinType` from `Collateral`
    /// entry corresponding to `market_account_info`, then return it.
    /// Aborts if custodian serial ID for given market account is not 0.
    public entry fun withdraw_collateral_user<CoinType>(
        user: &signer,
        market_account_info: MarketAccountInfo,
        amount: u64,
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert user is not trying to override delegated custody
        assert!(market_account_info.custodian_id == E_NO_CUSTODIAN,
            E_CUSTODIAN_OVERRIDE);
        // Withdraw collateral from user's market account
        withdraw_collateral_internal<CoinType>(
            address_of(user), market_account_info, amount)
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Deposit `coins` to `user`'s `Collateral` for given
    /// `market_account_info`.
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
    ) acquires Collateral, MarketAccounts {
        // Assert attempting to actually deposit coins
        assert!(coin::value(&coins) != 0, E_NO_TRANSFER_AMOUNT);
        // Assert market account registered for market account info
        assert!(exists_market_account(market_account_info, user),
            E_NO_MARKET_ACCOUNT);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to available coin count (aborts if
        // coin type is neither base nor quote for given market account)
        let coins_available_ref_mut = borrow_coins_available_mut<CoinType>(
            market_accounts_map, market_account_info);
        *coins_available_ref_mut = // Increment available coin count
            *coins_available_ref_mut + coin::value(&coins);
        // Borrow mutable reference to collateral map
        let collateral_map =
            &mut borrow_global_mut<Collateral<CoinType>>(user).map;
        // Borrow mutable reference to collateral for market account
        let collateral =
            open_table::borrow_mut(collateral_map, market_account_info);
        // Merge coins into market account collateral
        coin::merge(collateral, coins);
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

    /// Withdraw `amount` of `Coin` having `CoinType` from `Collateral`
    /// entry corresponding to `market_account_info`, then return it.
    /// Requires a reference to a `registry::CustodianCapability` for
    /// authorization, and aborts if custodian serial ID does not
    /// correspond to that specified in `market_account_info`.
    public fun withdraw_collateral_custodian<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64,
        custodian_capability: &registry::CustodianCapability,
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert serial custodian ID from capability matches ID from
        // market account info
        assert!(registry::custodian_id(custodian_capability) ==
            market_account_info.custodian_id, E_UNAUTHORIZED_CUSTODIAN);
        // Withdraw collateral from user's market account
        withdraw_collateral_internal<CoinType>(
            user, market_account_info, amount)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Look up the `MarketAccount` in `market_accounts_map` having
    /// `market_account_info`, then return a mutable reference to the
    /// number of available coins of `CoinType`.
    ///
    /// # Abort conditions
    /// * If `CoinType` is neither base nor quote coin in
    ///   `market_account_info`.
    ///
    /// # Assumes
    /// * `market_accounts_map` has an entry with `market_account_info`
    fun borrow_coins_available_mut<CoinType>(
        market_accounts_map:
            &mut open_table::OpenTable<MarketAccountInfo, MarketAccount>,
        market_account_info: MarketAccountInfo
    ): &mut u64 {
        // Determine if coin is base coin for market (aborts if is
        // neither base nor quote
        let is_base_coin = registry::coin_is_base_coin<CoinType>(
            &market_account_info.market_info);
        // Borrow mutable reference to market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // If is base coin, return mutable ref to base coins available
        (if (is_base_coin) &mut market_account.base_coins_available else
            &mut market_account.quote_coins_available) // Else quote
    }

    /// Return `true` if `user` has an `MarketAccounts` entry for
    /// `market_account_info`, otherwise `false`.
    fun exists_market_account(
        market_account_info: MarketAccountInfo,
        user: address
    ): bool
    acquires MarketAccounts {
        // Return false if no market accounts map exists
        if(!exists<MarketAccounts>(user)) return false;
        // Borrow immutable ref to market accounts map
        let market_accounts_map = &borrow_global<MarketAccounts>(user).map;
        // Return if market account is registered in table
        open_table::contains(market_accounts_map, market_account_info)
    }

    /// Register user with a `Collateral` map entry for given `CoinType`
    /// and `market_account_info`, initializing `Collateral` if it does
    /// not already exist.
    ///
    /// # Abort conditions
    /// * If user already has a `Collateral` entry for given
    ///   `market_account_info`
    fun register_collateral_entry<CoinType>(
        user: &signer,
        market_account_info: MarketAccountInfo,
    ) acquires Collateral {
        let user_address = address_of(user); // Get user's address
        // If user does not have a collateral map initialized
        if(!exists<Collateral<CoinType>>(user_address)) {
            // Pack an empty one and move to their account
            move_to<Collateral<CoinType>>(user,
                Collateral{map: open_table::empty()})
        };
        let map = // Borrow mutable reference to collateral map
            &mut borrow_global_mut<Collateral<CoinType>>(user_address).map;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(map,
            market_account_info), E_MARKET_ACCOUNT_REGISTERED);
        // Add an empty entry for given market account info
        open_table::add(map, market_account_info, coin::zero<CoinType>());
    }

    /// Register user with a `MarketAccounts` map entry corresponding to
    /// `market_account_info`, initializing `MarketAccounts` if it does
    /// not already exist
    ///
    /// # Abort conditions
    /// * If user already has a `MarketAccounts` entry for given
    ///   `market_account_info`
    fun register_market_accounts_entry(
        user: &signer,
        market_account_info: MarketAccountInfo,
    ) acquires MarketAccounts {
        let user_address = address_of(user); // Get user's address
        // If user does not have a market accounts map initialized
        if(!exists<MarketAccounts>(user_address)) {
            // Pack an empty one and move it to their account
            move_to<MarketAccounts>(user,
                MarketAccounts{map: open_table::empty()})
        };
        // Borrow mutable reference to market accounts map
        let map = &mut borrow_global_mut<MarketAccounts>(user_address).map;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(map, market_account_info),
            E_MARKET_ACCOUNT_REGISTERED);
        // Get scale factor for corresponding market
        let scale_factor = registry::scale_factor_from_market_info(
            &market_account_info.market_info);
        // Add an empty entry for given market account info
        open_table::add(map, market_account_info, MarketAccount{
            scale_factor,
            asks: critbit::empty(),
            bids: critbit::empty(),
            base_coins_available: 0,
            quote_coins_available: 0
        });
    }

    /// Withdraw `amount` of `Coin` having `CoinType` from `Collateral`
    /// entry corresponding to `market_account_info`, then return it.
    ///
    /// # Abort conditions
    /// * If `CoinType` is neither base nor quote for market account
    /// * If `coins` has a value of 0
    /// * If `user` does not have corresponding market account
    ///   registered
    /// * If `user` has insufficient collateral to withdraw
    fun withdraw_collateral_internal<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert attempting to actually withdraw coins
        assert!(amount != 0, E_NO_TRANSFER_AMOUNT);
        // Assert market account registered for market account info
        assert!(exists_market_account(market_account_info, user),
            E_NO_MARKET_ACCOUNT);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to available coin count (aborts if
        // coin type is neither base nor quote for given market account)
        let coins_available_ref_mut = borrow_coins_available_mut<CoinType>(
            market_accounts_map, market_account_info);
        // Assert user has enough available collateral to withdraw
        assert!(amount <= *coins_available_ref_mut, E_NOT_ENOUGH_COLLATERAL);
        // Decrement withdrawn amount from available coin count
        *coins_available_ref_mut = *coins_available_ref_mut - amount;
        // Borrow mutable reference to collateral map
        let collateral_map =
            &mut borrow_global_mut<Collateral<CoinType>>(user).map;
        // Borrow mutable reference to collateral for market account
        let collateral =
            open_table::borrow_mut(collateral_map, market_account_info);
        // Extract collateral from market account and return
        coin::extract(collateral, amount)
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
    acquires Collateral, MarketAccounts {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123 }; // Declare market account info
        // Attempt invalid deposit
        deposit_collateral<BC>(@user, market_account_info, coin::zero<BC>());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempting to deposit when no market account
    fun test_deposit_collateral_no_market_account(
        econia: &signer
    ) acquires Collateral, MarketAccounts {
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
    ) acquires Collateral, MarketAccounts {
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
        // Borrow immutable ref to collateral map
        let collateral_map = &borrow_global<Collateral<BC>>(@user).map;
        // Borrow immutable ref to collateral for market account
        let collateral =
            open_table::borrow(collateral_map, market_account_info);
        // Assert amount
        assert!(coin::value(collateral) == deposit_amount, 0);
        // Borrow immutable ref to market accounts map
        let market_accounts_map = &borrow_global<MarketAccounts>(@user).map;
        // Borrow mutable reference to market account
        let market_account =
            open_table::borrow(market_accounts_map, market_account_info);
        assert!(market_account.base_coins_available == deposit_amount, 0);
    }

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_collateral_entry(
        user: &signer
    ) acquires Collateral {
        let market_account_info_1 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123 }; // Declare market account info
        let market_account_info_2 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E2>(),
            custodian_id: 456 }; // Declare market account info
        // Register collateral entry
        register_collateral_entry<BC>(user, market_account_info_1);
        // Register another collateral entry
        register_collateral_entry<BC>(user, market_account_info_2);
        // Borrow immutable ref to collateral map
        let collateral_map =
            &borrow_global<Collateral<BC>>(address_of(user)).map;
        // Borrow immutable ref to collateral for first market account
        let collateral_1 =
            open_table::borrow(collateral_map, market_account_info_1);
        // Assert amount
        assert!(coin::value(collateral_1) == 0, 0);
        // Borrow immutable ref to collateral for second market account
        let collateral_2 =
            open_table::borrow(collateral_map, market_account_info_2);
        // Assert amount
        assert!(coin::value(collateral_2) == 0, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for given market account is already registered
    fun test_register_collateral_entry_already_registered(
        user: &signer
    ) acquires Collateral {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123 }; // Declare market account info
        // Register collateral entry
        register_collateral_entry<BC>(user, market_account_info);
        // Attempt invalid re-registration
        register_collateral_entry<BC>(user, market_account_info);
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
    ) acquires Collateral, MarketAccounts {
       registry::register_test_market(econia); // Init test market
       // Attempt invalid registration
       register_market_account<BC, QC, E1>(user, 1);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for no such registered market
    fun test_register_market_account_no_market(
        user: &signer
    ) acquires Collateral, MarketAccounts {
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
    acquires Collateral, MarketAccounts {
        registry::register_test_market(econia); // Init test market
        // Register a custodian
        let custodian_capability = registry::register_custodian_capability();
        // Register uncustodied and custodied test market accounts
        register_market_account<BC, QC, E1>(user, 0);
        register_market_account<BC, QC, E1>(user, 1);
        // Get market account info for both market accounts
        let market_account_info_0 = market_account_info<BC, QC, E1>(0);
        let market_account_info_1 = market_account_info<BC, QC, E1>(1);
        // Borrow immutable reference to market accounts map
        let market_accounts_map =
            &borrow_global<MarketAccounts>(address_of(user)).map;
        // Assert entries added to table
        assert!(open_table::contains(
            market_accounts_map, market_account_info_0), 0);
        assert!(open_table::contains(
            market_accounts_map, market_account_info_1), 0);
        // Borrow immutable ref to base coin collateral map
        let base_collateral_map =
            &borrow_global<Collateral<BC>>(address_of(user)).map;
        // Assert entries added to table
        assert!(open_table::contains(
            base_collateral_map, market_account_info_0), 0);
        assert!(open_table::contains(
            base_collateral_map, market_account_info_1), 0);
        // Borrow immutable ref to quote coin collateral map
        let quote_collateral_map =
            &borrow_global<Collateral<QC>>(address_of(user)).map;
        assert!(open_table::contains(
            quote_collateral_map, market_account_info_0), 0);
        assert!(open_table::contains(
            quote_collateral_map, market_account_info_1), 0);
        custodian_capability // Return registered custodian capability
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify registration for multiple market accounts
    fun test_register_market_accounts_entry(
        econia: &signer,
        user: &signer
    ) acquires MarketAccounts {
        registry::init_registry(econia); // Initialize registry
        let market_account_info_1 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E1>(),
            custodian_id: 123}; // Declare mock market account info
        let market_account_info_2 = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, E2>(),
            custodian_id: 456}; // Declare mock market account info
        // Register market accounts entry
        register_market_accounts_entry(user, market_account_info_1);
        // Register another market accounts entry
        register_market_accounts_entry(user, market_account_info_2);
        // Borrow immutable reference to market accounts map
        let market_accounts_map =
            &borrow_global<MarketAccounts>(address_of(user)).map;
        // Borrow immutable ref to first market account
        let market_account_1 = open_table::borrow(
            market_accounts_map, market_account_info_1);
        // Assert fields
        assert!(market_account_1.scale_factor == 10, 0);
        assert!(critbit::is_empty(&market_account_1.asks), 0);
        assert!(critbit::is_empty(&market_account_1.bids), 0);
        assert!(market_account_1.base_coins_available == 0, 0);
        assert!(market_account_1.quote_coins_available == 0, 0);
        // Borrow immutable ref to second market account
        let market_account_2 = open_table::borrow(
            market_accounts_map, market_account_info_2);
        // Assert fields
        assert!(market_account_2.scale_factor == 100, 0);
        assert!(critbit::is_empty(&market_account_2.asks), 0);
        assert!(critbit::is_empty(&market_account_2.bids), 0);
        assert!(market_account_2.base_coins_available == 0, 0);
        assert!(market_account_2.quote_coins_available == 0, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for given market account is already registered
    fun test_register_market_accounts_entry_already_registered(
        econia: &signer,
        user: &signer
    ) acquires MarketAccounts {
        registry::init_registry(econia); // Initialize registry
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E1>(),
            custodian_id: 123 }; // Declare market account info
        // Register market accounts entry
        register_market_accounts_entry(user, market_account_info);
        // Attempt invalid re-registration
        register_market_accounts_entry(user, market_account_info);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}