/// User-side book keeping and, optionally, collateral management.
///
/// For a given market, a user can register multiple `MarketAccount`s,
/// with each such market account having a different delegated custodian
/// ID and therefore a unique `MarketAccountInfo`: hence, each market
/// account has a particular "user-specific" custodian ID. For a given
/// `MarketAccount`, a user has entries in a `Collateral` map for each
/// asset that is a coin type.
///
/// For assets that are not a coin type, the "market-wide" custodian
/// (`registry::TradingPairInfo`) is required to verify
/// deposits and withdrawals. Hence a user-specific custodian ID
/// overrides a market-wide custodian ID when placing or cancelling
/// trades on an asset-agnostic market, whereas the market-wide
/// custodian ID overrides the user-specific custodian ID when
/// depositing or withdrawing a non-coin asset.
module econia::user {

    // Dependency planning stubs
    use econia::registry;
    fun invoke_registry() {registry::is_registered_custodian_id(0);}
    public(friend) fun return_0(): u8 {0}

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{BC, BG, QC, QG};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Collateral map for given coin type, across all `MarketAccount`s
    struct Collateral<phantom CoinType> has key {
        /// Map from `MarketAccountInfo` to coins held as collateral for
        /// given `MarketAccount`. Separated into different table
        /// entries to reduce transaction collisions across markets
        map: open_table::OpenTable<MarketAccountInfo, Coin<CoinType>>
    }

    /// Represents a user's open orders and available assets for a given
    /// `MarketAccountInfo`
    struct MarketAccount has store {
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
        /// Map from order ID to size of outstanding order, measured in
        /// lots lefts to fill
        asks: CritBitTree<u64>,
        /// Map from order ID to size of outstanding order, measured in
        /// lots lefts to fill
        bids: CritBitTree<u64>,
        /// Total base asset units held as collateral
        base_total: u64,
        /// Base asset units available for withdraw
        base_available: u64,
        /// Total quote asset units held as collateral
        quote_total: u64,
        /// Quote asset units available for withdraw
        quote_available: u64
    }

    /// Unique ID for a user's market account
    struct MarketAccountInfo has copy, drop, store {
        /// Serial ID of the market that a user is trading on
        market_id: u64,
        /// Serial ID of registered account custodian, set to
        /// `NO_CUSTODIAN` when given account does not have an
        /// authorized user-level custodian. Otherwise corresponding
        /// custodian capability required to place trades and, in the
        /// case of a pure coin market, to withdraw/deposit collateral.
        /// For an asset-agnostic market, is overridden by
        /// `market_level_custodian_id` when depositing or withdrawing a
        /// non-coin asset, since the market-level custodian is required
        /// to verify deposit and withdraw amounts. Can be the same as
        /// `market_level_custodian_id`.
        user_level_custodian_id: u64,
        /// ID of custodian capability required to withdraw/deposit
        /// collateral for an asset that is not a coin. A "market-wide"
        /// collateral transfer custodian ID, required to verify deposit
        /// and withdraw amounts for asset-agnostic markets. Marked as
        /// `PURE_COIN_PAIR` when base and quote types are both coins.
        /// Otherwise overrides the `user_level_custodian_id` for
        /// deposits and withdrawals only. Can be the same as
        /// `market_level_custodian_id`.
        market_level_custodian_id: u64
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

    /// When indicated asset is not in the market pair
    const E_NOT_IN_MARKET_PAIR: u64 = 0;
    /// When the passed custodian ID is invalid
    const E_INVALID_CUSTODIAN_ID: u64 = 1;
    /// When market account already exists for given market account info
    const E_EXISTS_MARKET_ACCOUNT: u64 = 2;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Register user with a market account
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `user`: Signing user
    /// * `market_id`: Serial ID of corresonding market
    /// * `user_level_custodian_id`: Serial ID of custodian capability
    ///   required for user-level authorization, set to `NO_CUSTODIAN`
    ///   if signing user required for authorization on market account
    ///
    /// # Abort conditions
    /// * If market is not already registered
    /// * If invalid `custodian_id`
    public entry fun register_market_account<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        user_level_custodian_id: u64
    ) acquires Collateral, MarketAccounts {
        // Get market-level custodian ID for verified market
        let market_level_custodian_id = registry::
            get_verified_market_custodian_id<BaseType, QuoteType>(market_id);
        // If user-level custodian ID indicated, assert it is registered
        if (user_level_custodian_id != NO_CUSTODIAN) assert!(
            registry::is_registered_custodian_id(user_level_custodian_id),
            E_INVALID_CUSTODIAN_ID);
        // Pack corresonding market account info
        let market_account_info = MarketAccountInfo{market_id,
            user_level_custodian_id, market_level_custodian_id};
        // Register entry in market accounts map
        register_market_accounts_entry<BaseType, QuoteType>(
            user, market_account_info);
        // If base asset is coin, register collateral entry
        if (coin::is_coin_initialized<BaseType>())
            register_collateral_entry<BaseType>(user, market_account_info);
        // If quote asset is coin, register collateral entry
        if (coin::is_coin_initialized<QuoteType>())
            register_collateral_entry<QuoteType>(user, market_account_info);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Look up the `MarketAccount` in `market_accounts_map` having
    /// `market_account_info`, then return a mutable reference to the
    /// amount of `AssetType` holdings, and a mutable reference to the
    /// reference to the amount of `AssetType` available for withdraw.
    ///
    /// # Assumes
    /// * `market_accounts_map` has an entry with `market_account_info`
    ///
    /// # Abort conditions
    /// * If `AssetType` is neither base nor quote for given market
    ///   account
    fun borrow_asset_counts_mut<AssetType>(
        market_accounts_map:
            &mut open_table::OpenTable<MarketAccountInfo, MarketAccount>,
        market_account_info: MarketAccountInfo
    ): (
        &mut u64,
        &mut u64
    ) {
        // Borrow mutable reference to market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Get asset type info
        let asset_type_info = type_info::type_of<AssetType>();
        // If is base asset, return mutable references to base fields
        if (asset_type_info == market_account.base_type_info) {
            return (
                &mut market_account.base_total,
                &mut market_account.base_available
            )
        // If is quote asset, return mutable references to quote fields
        } else if (asset_type_info == market_account.quote_type_info) {
            return (
                &mut market_account.quote_total,
                &mut market_account.quote_available
            )
        }; // Otherwise abort
        abort E_NOT_IN_MARKET_PAIR
    }

    /// Register `user` with `Collateral` map entry for given `CoinType`
    /// and `market_account_info`, initializing `Collateral` if it does
    /// not already exist.
    ///
    /// # Abort conditions
    /// * If user already has a `Collateral` entry for given
    ///   `market_account_info`
    fun register_collateral_entry<
        CoinType
    >(
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
        // Borrow mutable reference to collateral map
        let collateral_map_ref_mut =
            &mut borrow_global_mut<Collateral<CoinType>>(user_address).map;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(collateral_map_ref_mut,
            market_account_info), E_EXISTS_MARKET_ACCOUNT);
        // Add an empty entry for given market account info
        open_table::add(collateral_map_ref_mut, market_account_info,
            coin::zero<CoinType>());
    }

    /// Register user with a `MarketAccounts` map entry for given
    /// `BaseType`, `QuoteType`, and `market_account_info`, initializing
    /// `MarketAccounts` if it does not already exist
    ///
    /// # Abort conditions
    /// * If user already has a `MarketAccounts` entry for given
    ///   `market_account_info`
    fun register_market_accounts_entry<
        BaseType,
        QuoteType
    >(
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
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(market_accounts_map_ref_mut,
            market_account_info), E_EXISTS_MARKET_ACCOUNT);
        // Add an empty entry for given market account info
        open_table::add(market_accounts_map_ref_mut, market_account_info,
            MarketAccount{
                base_type_info: type_info::type_of<BaseType>(),
                quote_type_info: type_info::type_of<QuoteType>(),
                asks: critbit::empty(),
                bids: critbit::empty(),
                base_total: 0,
                base_available: 0,
                quote_total: 0,
                quote_available: 0
        });
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return asset counts of `user`'s market account for given
    /// `market_id` and `user_level_custodian_id`
    public fun asset_counts_test(
        user: address,
        market_id: u64,
        user_level_custodian_id: u64
    ): (
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        // Borrow immutable reference to user's market accounts
        let market_accounts_ref = borrow_global<MarketAccounts>(user);
        // Borrow immutable reference to corresponding market account
        let market_account_ref = borrow_market_account_test(
            market_id, user_level_custodian_id, market_accounts_ref);
        (
            market_account_ref.base_total,
            market_account_ref.base_available,
            market_account_ref.quote_total,
            market_account_ref.quote_available
        )
    }

    #[test_only]
    /// Return immutable reference to market account for given
    /// `market_id` and `user_level_custodian_id` in `MarketAccounts`
    /// indicated by `market_accounts_ref`
    fun borrow_market_account_test(
        market_id: u64,
        user_level_custodian_id: u64,
        market_accounts_ref: &MarketAccounts
    ): &MarketAccount {
        // Get corresponding market account info
        let market_account_info = get_market_account_info_test(
            market_id, user_level_custodian_id);
        // Return immutable reference to market account
        open_table::borrow(&market_accounts_ref.map, market_account_info)
    }

    #[test_only]
    /// Return `Coin.value` of `user`'s entry in `Collateral` for given
    /// `AssetType`, `market_id`, and `user_level_custodian_id`
    public fun collateral_value_test<CoinType>(
        user: address,
        market_id: u64,
        user_level_custodian_id: u64
    ): u64
    acquires Collateral {
        // Get corresponding market account info
        let market_account_info = get_market_account_info_test(
            market_id, user_level_custodian_id);
        // Borrow immutable reference to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<CoinType>>(user).map;
        // Borrow immutable reference to corresonding coin collateral
        let coin_ref = open_table::borrow(
            collateral_map_ref, market_account_info);
        coin::value(coin_ref) // Return value of coin
    }

    #[test_only]
    /// Return market account info for given `market_id` and
    /// `user_level_custodian_id`
    fun get_market_account_info_test(
        market_id: u64,
        user_level_custodian_id: u64
    ): MarketAccountInfo {
        // Get market-level custodian ID
        let market_level_custodian_id =
            registry::get_market_level_custodian_id_test(market_id);
        // Pack and return corresponding market account info
        MarketAccountInfo{
            market_id, user_level_custodian_id, market_level_custodian_id}
    }

    #[test_only]
    /// Return `true` if `user` has an entry in `Collateral` for given
    /// `AssetType`, `market_id`, and `user_level_custodian_id`
    public fun has_collateral_test<AssetType>(
        user: address,
        market_id: u64,
        user_level_custodian_id: u64
    ): bool
    acquires Collateral {
        // Return false if does not even have collateral map
        if (!exists<Collateral<AssetType>>(user)) return false;
        // Get corresponding market account info
        let market_account_info = get_market_account_info_test(
            market_id, user_level_custodian_id);
        // Borrow immutable reference to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<AssetType>>(user).map;
        // Return if table contains entry for market account info
        open_table::contains(collateral_map_ref, market_account_info)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_collateral_entry(
        user: &signer
    ) acquires Collateral {
        let market_account_info_1 = MarketAccountInfo{
            market_id: 0,
            user_level_custodian_id: 1,
            market_level_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        let market_account_info_2 = MarketAccountInfo{
            market_id: 0,
            user_level_custodian_id: NO_CUSTODIAN,
            market_level_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        // Register collateral entry
        register_collateral_entry<BC>(user, market_account_info_1);
        // Register another collateral entry
        register_collateral_entry<BC>(user, market_account_info_2);
        // Borrow immutable ref to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<BC>>(address_of(user)).map;
        // Borrow immutable ref to collateral for first market account
        let collateral_ref_1 =
            open_table::borrow(collateral_map_ref, market_account_info_1);
        // Assert amount
        assert!(coin::value(collateral_ref_1) == 0, 0);
        // Borrow immutable ref to collateral for second market account
        let collateral_ref_2 =
            open_table::borrow(collateral_map_ref, market_account_info_2);
        // Assert amount
        assert!(coin::value(collateral_ref_2) == 0, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for given market account is already registered
    fun test_register_collateral_entry_already_registered(
        user: &signer
    ) acquires Collateral {
        let market_account_info = MarketAccountInfo{
            market_id: 0,
            user_level_custodian_id: 1,
            market_level_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
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
    /// Verify failure for invalid user-level custodian ID
    fun test_register_market_account_invalid_custodian_id(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test markets
        registry::register_market_internal_multiple_test(econia);
        let agnostic_test_market_serial_id = 0; // Declare market ID
        // Attempt invalid registration
        register_market_account<BG, QG>(
            user, agnostic_test_market_serial_id, 1000000000);
    }

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_market_accounts_entry(
        user: &signer
    ) acquires MarketAccounts {
        let market_account_info_1 = MarketAccountInfo{
            market_id: 0,
            user_level_custodian_id: 1,
            market_level_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        let market_account_info_2 = MarketAccountInfo{
            market_id: 0,
            user_level_custodian_id: NO_CUSTODIAN,
            market_level_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_info_1);
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_info_2);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(address_of(user)).map;
        // Borrow immutable reference to first market account
        let market_account_ref_1 =
            open_table::borrow(market_accounts_map_ref, market_account_info_1);
        // Assert fields
        assert!(market_account_ref_1.base_type_info ==
            type_info::type_of<BC>(), 0);
        assert!(market_account_ref_1.quote_type_info ==
            type_info::type_of<QC>(), 0);
        assert!(critbit::is_empty(&market_account_ref_1.asks), 0);
        assert!(critbit::is_empty(&market_account_ref_1.bids), 0);
        assert!(market_account_ref_1.base_total == 0, 0);
        assert!(market_account_ref_1.base_available == 0, 0);
        assert!(market_account_ref_1.quote_total == 0, 0);
        assert!(market_account_ref_1.quote_available == 0, 0);
        // Borrow immutable reference to second market account
        let market_account_ref_2 =
            open_table::borrow(market_accounts_map_ref, market_account_info_1);
        // Assert fields
        assert!(market_account_ref_2.base_type_info ==
            type_info::type_of<BC>(), 0);
        assert!(market_account_ref_2.quote_type_info ==
            type_info::type_of<QC>(), 0);
        assert!(critbit::is_empty(&market_account_ref_2.asks), 0);
        assert!(critbit::is_empty(&market_account_ref_2.bids), 0);
        assert!(market_account_ref_2.base_total == 0, 0);
        assert!(market_account_ref_2.base_available == 0, 0);
        assert!(market_account_ref_2.quote_total == 0, 0);
        assert!(market_account_ref_2.quote_available == 0, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempting to re-register market account
    fun test_register_market_accounts_entry_already_registered(
        user: &signer
    ) acquires MarketAccounts {
        let market_account_info = MarketAccountInfo{
            market_id: 0,
            user_level_custodian_id: 1,
            market_level_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_info);
        // Attemp invalid re-registration
        register_market_accounts_entry<BC, QC>(user, market_account_info);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful market account registration
    fun test_register_market_accounts(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Init test markets, storing relevant parameters
        let  (_, _, market_level_custodian_id_agnostic,  market_id_agnostic,
              _, _, market_level_custodian_id_pure_coin, market_id_pure_coin) =
            registry::register_market_internal_multiple_test(econia);
        // Declare custodian IDs
        let user_level_custodian_id_agnostic = NO_CUSTODIAN;
        let user_level_custodian_id_pure_coin = 2;
        // Register corresponding market accounts
        register_market_account<BG, QG>(
            user, market_id_agnostic, user_level_custodian_id_agnostic);
        register_market_account<BC, QC>(
            user, market_id_pure_coin, user_level_custodian_id_pure_coin);
        // Get market account info for both market accounts
        let market_account_info_agnostic = MarketAccountInfo{
            market_id: market_id_agnostic,
            user_level_custodian_id: user_level_custodian_id_agnostic,
            market_level_custodian_id: market_level_custodian_id_agnostic
        };
        let market_account_info_pure_coin = MarketAccountInfo{
            market_id: market_id_pure_coin,
            user_level_custodian_id: user_level_custodian_id_pure_coin,
            market_level_custodian_id: market_level_custodian_id_pure_coin
        };
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(@user).map;
        // Assert entries added to table
        assert!(open_table::contains(
            market_accounts_map_ref, market_account_info_agnostic), 0);
        assert!(open_table::contains(
            market_accounts_map_ref, market_account_info_pure_coin), 0);
        // Assert no initialized collateral map for generic assets
        assert!(!exists<Collateral<BG>>(@user), 0);
        assert!(!exists<Collateral<QG>>(@user), 0);
        // Borrow immutable reference to base coin collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<BC>>(@user).map;
        // Assert entry added for pure coin market account
        assert!(open_table::contains(collateral_map_ref,
            market_account_info_pure_coin), 0);
        // Borrow immutable reference to quote coin collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<QC>>(@user).map;
        // Assert entry added for pure coin market account
        assert!(open_table::contains(collateral_map_ref,
            market_account_info_pure_coin), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}