/// User-side book keeping and, optionally, collateral management.
///
/// For a given market, a user can register multiple `MarketAccount`s,
/// with each such market account having a different delegated custodian
/// ID and therefore a unique `MarketAccountInfo`: hence, each market
/// account has a particular "user-specific" custodian ID. For a given
/// `MarketAccount`, a user has entries in a `Collateral` map for each
/// asset that is a coin type.
///
/// For assets that are not a coin type, the "market-wide generic asset
/// transfer" custodian (`registry::TradingPairInfo`) is required to
/// verify deposits and withdrawals. Hence a user-specific general
/// custodian overrides a market-wide generic asset transfer
/// custodian when placing or cancelling trades on an asset-agnostic
/// market, whereas the market-wide generic asset transfer custodian
/// overrides the user-specific general custodian ID when depositing or
/// withdrawing a non-coin asset.
module econia::user {

    // Dependency planning stubs
    public(friend) fun return_0(): u8 {0}

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::registry::{Self, CustodianCapability};
    use std::option;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{Self, BC, BG, QC, QG};

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
        /// authorized custodian for general purposes. Otherwise
        /// corresponding custodian capability required to place trades
        /// and deposit or withdraw coin assets. Is overridden by
        /// `generic_asset_transfer_custodian_id` when depositing or
        /// withdrawing a non-coin asset, since the market-level
        /// custodian is required to verify deposit and withdraw amounts
        /// for non-coin assets. Can be the same as
        /// `generic_asset_transfer_custodian_id`.
        general_custodian_id: u64,
        /// ID of custodian capability required to verify deposits and
        /// withdrawals of assets that are not coins. A "market-wide
        /// asset transfer custodian ID" that only applies to markets
        /// having at least one non-coin asset. For a market having
        /// one coin asset and one generic asset, only applies to the
        /// generic asset. Marked `PURE_COIN_PAIR` when base and quote
        /// types are both coins, otherwise overrides
        /// `general_custodian_id` for deposits and withdraws of generic
        /// assets. Can be the same as `general_custodian_id`.
        generic_asset_transfer_custodian_id: u64
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
    /// When indicated custodian ID is not registered
    const E_UNREGISTERED_CUSTODIAN_ID: u64 = 1;
    /// When market account already exists for given market account info
    const E_EXISTS_MARKET_ACCOUNT: u64 = 2;
    /// When indicated market account does not exist
    const E_NO_MARKET_ACCOUNT: u64 = 3;
    /// When not enough asset avaialable for withdraw
    const E_NOT_ENOUGH_ASSET_AVAILABLE: u64 = 4;
    /// When indicated custodian does not have authority for operation
    const E_UNAUTHORIZED_CUSTODIAN: u64 = 5;
    /// When user attempts invalid custodian override
    const E_CUSTODIAN_OVERRIDE: u64 = 6;
    /// When a user does not a `MarketAccounts`
    const E_NO_MARKET_ACCOUNTS: u64 = 7;
    /// When asset indicated as generic actually corresponds to a coin
    const E_NOT_GENERIC_ASSET: u64 = 12;
    /// When asset indicated as coin actually corresponds to a generic
    const E_NOT_COIN_ASSET: u64 = 13;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Deposit `coins` of `CoinType` to `user`'s market account having
    /// `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`
    ///
    /// See wrapped function `deposit_asset()`
    public fun deposit_coins<CoinType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        coins: Coin<CoinType>
    ) acquires Collateral, MarketAccounts {
        deposit_asset<CoinType>(
            user,
            MarketAccountInfo{market_id, general_custodian_id,
                generic_asset_transfer_custodian_id},
            coin::value(&coins),
            option::some(coins)
        )
    }

    /// Deposit `amount` of non-coin assets of `AssetType` to `user`'s
    /// market account having `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`, under authority of
    /// custodian indicated by
    /// `generic_asset_transfer_custodian_capability_ref`
    ///
    /// See wrapped function `deposit_asset()`
    ///
    /// # Abort conditions
    /// * If generic asset transfer custodian ID for market does not
    ///   match that indicated by
    ///   `generic_asset_transfer_custodian_capbility_ref`
    /// * If `AssetType` corresponds to the `CoinType` of an initialized
    ///   coin
    public fun deposit_generic_asset<AssetType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64,
        generic_asset_transfer_custodian_capability_ref: &CustodianCapability
    ) acquires Collateral, MarketAccounts {
        // Assert indicated generic asset transfer custodian ID matches
        // that of capability
        assert!(registry::custodian_id(
            generic_asset_transfer_custodian_capability_ref) ==
            generic_asset_transfer_custodian_id, E_UNAUTHORIZED_CUSTODIAN);
        // Assert asset type does not correspond to an initialized coin
        assert!(!coin::is_coin_initialized<AssetType>(), E_NOT_GENERIC_ASSET);
        deposit_asset<AssetType>( // Deposit generic asset
            user,
            MarketAccountInfo{market_id, general_custodian_id,
                generic_asset_transfer_custodian_id},
            amount,
            option::none<Coin<AssetType>>()
        )
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`, under authority of
    /// custodian indicated by `general_custodian_capability_ref`
    ///
    /// See wrapped function `withdraw_coins()`
    ///
    /// # Abort conditions
    /// * If `CoinType` does not correspond to a coin
    /// * If `general_custodian_id` is not `NO_CUSTODIAN`
    public fun withdraw_coins_custodian<CoinType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64,
        general_custodian_capability_ref: &CustodianCapability
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert indicated general custodian ID matches that of
        // capability
        assert!(registry::custodian_id(general_custodian_capability_ref) ==
            general_custodian_id, E_UNAUTHORIZED_CUSTODIAN);
        withdraw_coins<CoinType>(
            user,
            market_id,
            general_custodian_id,
            generic_asset_transfer_custodian_id,
            amount
        ) // Withdraw coins from market account and return
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`, returning coins
    ///
    /// See wrapped function `withdraw_coins()`
    ///
    /// # Abort conditions
    /// * If `CoinType` does not correspond to a coin
    /// * If `general_custodian_id` is not `NO_CUSTODIAN`
    public fun withdraw_coins_user<CoinType>(
        user: &signer,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64,
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert custodian ID indicates no custodian
        assert!(general_custodian_id == NO_CUSTODIAN, E_CUSTODIAN_OVERRIDE);
        withdraw_coins<CoinType>(
            address_of(user),
            market_id,
            general_custodian_id,
            generic_asset_transfer_custodian_id,
            amount
        ) // Withdraw coins from market account and return
    }

    /// Withdraw `amount` of non-coin assets of `AssetType` from
    /// `user`'s market account having `market_id`,
    /// `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`, under authority of
    /// custodian indicated by
    /// `generic_asset_transfer_custodian_capability_ref`
    ///
    /// See wrapped function `withdraw_asset()`
    ///
    /// # Abort conditions
    /// * If generic asset transfer custodian ID for market does not
    ///   match that indicated by
    ///   `generic_asset_transfer_custodian_capbility_ref`
    /// * If `AssetType` corresponds to the `CoinType` of an initialized
    ///   coin
    public fun withdraw_generic_asset<AssetType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64,
        generic_asset_transfer_custodian_capability_ref: &CustodianCapability
    ) acquires Collateral, MarketAccounts {
        // Assert indicated generic asset transfer custodian ID matches
        // that of capability
        assert!(registry::custodian_id(
            generic_asset_transfer_custodian_capability_ref) ==
            generic_asset_transfer_custodian_id, E_UNAUTHORIZED_CUSTODIAN);
        // Assert asset type does not correspond to an initialized coin
        assert!(!coin::is_coin_initialized<AssetType>(), E_NOT_GENERIC_ASSET);
        // Pack market account info
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        let empty_option = withdraw_asset<AssetType>(user, market_account_info,
            amount, false); // Withdraw asset as empty option
        option::destroy_none(empty_option); // Destroy empty option
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Transfer `amount` of coins of `CoinType` from `user`'s
    /// `aptos_framework::coin::CoinStore` to their `Collateral` for
    /// market account having `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`.
    ///
    /// See wrapped function `deposit_coins()`
    public entry fun deposit_from_coinstore<CoinType>(
        user: &signer,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64
    ) acquires Collateral, MarketAccounts {
        deposit_coins<CoinType>(
            address_of(user),
            market_id,
            general_custodian_id,
            generic_asset_transfer_custodian_id,
            coin::withdraw<CoinType>(user, amount)
        )
    }

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
    /// * `general_custodian_id`: Serial ID of custodian capability
    ///   required for general account authorization, set to
    ///   `NO_CUSTODIAN` if signing user required for authorization on
    ///   market account
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
        general_custodian_id: u64
    ) acquires Collateral, MarketAccounts {
        // Get generic asset transfer custodian ID for verified market
        let generic_asset_transfer_custodian_id = registry::
            get_verified_market_custodian_id<BaseType, QuoteType>(market_id);
        // If general custodian ID indicated, assert it is registered
        if (general_custodian_id != NO_CUSTODIAN) assert!(
            registry::is_registered_custodian_id(general_custodian_id),
            E_UNREGISTERED_CUSTODIAN_ID);
        // Pack corresonding market account info
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
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

    #[cmd]
    /// Transfer `amount` of coins of `CoinType` from `user`'s
    /// `Collateral` to their `aptos_framework::coin::CoinStore` for
    /// market account having `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`.
    ///
    /// See wrapped function `withdraw_coins_user()`
    public entry fun withdraw_to_coinstore<CoinType>(
        user: &signer,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64
    ) acquires Collateral, MarketAccounts {
        // Withdraw coins from user's market account
        let coins = withdraw_coins_user<CoinType>(user, market_id,
            general_custodian_id, generic_asset_transfer_custodian_id, amount);
        // Deposit coins to user's coin store
        coin::deposit<CoinType>(address_of(user), coins);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow mutable references to market account `AssetType` counts
    ///
    /// Look up the `MarketAccount` having `market_account_info` in the
    /// market accounts map indicated by `market_accounts_map_ref_mut`,
    /// then return a mutable reference to the amount of `AssetType`
    /// holdings, and a mutable reference to the reference to the amount
    /// of `AssetType` available for withdraw.
    ///
    /// # Returns
    /// * `u64`: Mutable reference to `MarketAccount.base_total` for
    ///   corresponding market account if `AssetType` is market base,
    ///   else mutable reference to `MarketAccount.quote_total`
    /// * `u64`: Mutable reference to `MarketAccount.base_available` for
    ///   corresponding market account if `AssetType` is market base,
    ///   else mutable reference to `MarketAccount.quote_available`
    ///
    /// # Assumes
    /// * `market_accounts_map` has an entry with `market_account_info`
    ///
    /// # Abort conditions
    /// * If `AssetType` is neither base nor quote for given market
    ///   account
    fun borrow_asset_counts_mut<AssetType>(
        market_accounts_map_ref_mut:
            &mut open_table::OpenTable<MarketAccountInfo, MarketAccount>,
        market_account_info: MarketAccountInfo
    ): (
        &mut u64,
        &mut u64
    ) {
        // Borrow mutable reference to market account
        let market_account_ref_mut =
            open_table::borrow_mut(
                market_accounts_map_ref_mut, market_account_info);
        // Get asset type info
        let asset_type_info = type_info::type_of<AssetType>();
        // If is base asset, return mutable references to base fields
        if (asset_type_info == market_account_ref_mut.base_type_info) {
            return (
                &mut market_account_ref_mut.base_total,
                &mut market_account_ref_mut.base_available
            )
        // If is quote asset, return mutable references to quote fields
        } else if (asset_type_info == market_account_ref_mut.quote_type_info) {
            return (
                &mut market_account_ref_mut.quote_total,
                &mut market_account_ref_mut.quote_available
            )
        }; // Otherwise abort
        abort E_NOT_IN_MARKET_PAIR
    }

    /// Deposit `amount` of `AssetType` to `user`'s market account,
    /// which may include `optional_coins`
    ///
    /// # Assumes
    /// * That if depositing a coin asset, `amount` matches value of
    ///   `optional_coins`
    /// * That when depositing a coin asset, if the market account
    ///   exists, then a corresponding collateral container does too
    ///
    /// # Abort conditions
    /// * If `user` does not have corresponding market account
    ///   registered
    /// * If `AssetType` is neither base nor quote for market account
    fun deposit_asset<AssetType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64,
        optional_coins: option::Option<Coin<AssetType>>
    ) acquires Collateral, MarketAccounts {
        // Verify user has corresponding market account
        verify_market_account_exists(user, market_account_info);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
                &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total asset holdings, and mutable
        // reference to amount of assets available for withdrawal
        let (asset_total_ref_mut, asset_available_ref_mut) =
            borrow_asset_counts_mut<AssetType>(market_accounts_map_ref_mut,
                market_account_info);
        // Increment total asset holdings amount
        *asset_total_ref_mut = *asset_total_ref_mut + amount;
        // Increment assets available for withdrawal amount
        *asset_available_ref_mut = *asset_available_ref_mut + amount;
        if (option::is_some(&optional_coins)) { // If asset is coin type
            // Borrow mutable reference to collateral map
            let collateral_map_ref_mut =
                &mut borrow_global_mut<Collateral<AssetType>>(user).map;
            // Borrow mutable reference to collateral for market account
            let collateral_ref_mut = open_table::borrow_mut(
                collateral_map_ref_mut, market_account_info);
            coin::merge( // Merge optional coins into collateral
                collateral_ref_mut, option::destroy_some(optional_coins));
        } else { // If asset is not coin type
            // Destroy empty option resource
            option::destroy_none(optional_coins);
        }
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

    /// Verify `user` has a market account with `market_account_info`
    ///
    /// # Abort conditions
    /// * If user does not have a `MarketAccounts`
    /// * If user does not have a `MarketAccount` for given
    ///   `market_account_info`
    fun verify_market_account_exists(
        user: address,
        market_account_info: MarketAccountInfo
    ) acquires MarketAccounts {
        // Assert user has a market accounts map
        assert!(exists<MarketAccounts>(user), E_NO_MARKET_ACCOUNTS);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user).map;
        // Assert user has an entry in map for market account info
        assert!(open_table::contains(market_accounts_map_ref,
            market_account_info), E_NO_MARKET_ACCOUNT);
    }

    /// Withdraw `amount` of `AssetType` from `user`'s market account,
    /// optionally returning coins if `asset_is_coin` is `true`
    ///
    /// # Abort conditions
    /// * If `user` has insufficient assets available for withdrawal
    fun withdraw_asset<AssetType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64,
        asset_is_coin: bool
    ): option::Option<Coin<AssetType>>
    acquires Collateral, MarketAccounts {
        // Verify user has corresponding market account
        verify_market_account_exists(user, market_account_info);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
                &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total asset holdings, and mutable
        // reference to amount of assets available for withdrawal
        let (asset_total_ref_mut, asset_available_ref_mut) =
            borrow_asset_counts_mut<AssetType>(market_accounts_map_ref_mut,
                market_account_info);
        // Assert user has enough available asset to withdraw
        assert!(amount <= *asset_available_ref_mut,
            E_NOT_ENOUGH_ASSET_AVAILABLE);
        // Decrement total asset holdings amount
        *asset_total_ref_mut = *asset_total_ref_mut - amount;
        // Decrement assets available for withdrawal amount
        *asset_available_ref_mut = *asset_available_ref_mut - amount;
        if (asset_is_coin) { // If asset is coin type
            // Borrow mutable reference to collateral map
            let collateral_map_ref_mut =
                &mut borrow_global_mut<Collateral<AssetType>>(user).map;
            // Borrow mutable reference to collateral for market account
            let collateral_ref_mut = open_table::borrow_mut(
                collateral_map_ref_mut, market_account_info);
            // Return coin in an option wrapper
            return option::some<Coin<AssetType>>(
                coin::extract(collateral_ref_mut, amount))
        } else { // If asset is not coin type
            // Return empty option wrapper
            return option::none<Coin<AssetType>>()
        }
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id`, `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`, returning coins
    ///
    /// # Abort conditions
    /// * If `CoinType` does not correspond to a coin
    fun withdraw_coins<CoinType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64,
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert type corresponds to an initialized coin
        assert!(coin::is_coin_initialized<CoinType>(), E_NOT_COIN_ASSET);
        // Pack market account info
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Withdraw corresponding amount of coins, as an option
        let option_coins = withdraw_asset<CoinType>(
            user, market_account_info, amount, true);
        option::destroy_some(option_coins) // Return extracted coins
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return asset counts of `user`'s market account for given
    /// `market_id` and `general_custodian_id`
    public fun asset_counts_test(
        user: address,
        market_id: u64,
        general_custodian_id: u64
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
            market_id, general_custodian_id, market_accounts_ref);
        (
            market_account_ref.base_total,
            market_account_ref.base_available,
            market_account_ref.quote_total,
            market_account_ref.quote_available
        )
    }

    #[test_only]
    /// Return immutable reference to market account for given
    /// `market_id` and `general_custodian_id` in `MarketAccounts`
    /// indicated by `market_accounts_ref`
    fun borrow_market_account_test(
        market_id: u64,
        general_custodian_id: u64,
        market_accounts_ref: &MarketAccounts
    ): &MarketAccount {
        // Get corresponding market account info
        let market_account_info = get_market_account_info_test(
            market_id, general_custodian_id);
        // Return immutable reference to market account
        open_table::borrow(&market_accounts_ref.map, market_account_info)
    }

    #[test_only]
    /// Return `Coin.value` of `user`'s entry in `Collateral` for given
    /// `AssetType`, `market_id`, and `general_custodian_id`
    public fun collateral_value_test<CoinType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64
    ): u64
    acquires Collateral {
        // Get corresponding market account info
        let market_account_info = get_market_account_info_test(
            market_id, general_custodian_id);
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
    /// `general_custodian_id`
    fun get_market_account_info_test(
        market_id: u64,
        general_custodian_id: u64
    ): MarketAccountInfo {
        // Get market-level custodian ID
        let generic_asset_transfer_custodian_id =
            registry::get_generic_asset_transfer_custodian_id_test(market_id);
        // Pack and return corresponding market account info
        MarketAccountInfo{market_id, general_custodian_id,
            generic_asset_transfer_custodian_id}
    }

    #[test_only]
    /// Return `true` if `user` has an entry in `Collateral` for given
    /// `AssetType`, `market_id`, and `general_custodian_id`
    public fun has_collateral_test<AssetType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64
    ): bool
    acquires Collateral {
        // Return false if does not even have collateral map
        if (!exists<Collateral<AssetType>>(user)) return false;
        // Get corresponding market account info
        let market_account_info = get_market_account_info_test(
            market_id, general_custodian_id);
        // Borrow immutable reference to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<AssetType>>(user).map;
        // Return if table contains entry for market account info
        open_table::contains(collateral_map_ref, market_account_info)
    }

    #[test_only]
    /// Register user to trade on markets initialized via
    /// `registry::register_market_internal_multiple_test`, returning
    /// corresponding `MarketAccountInfo` for each market
    public fun register_user_with_market_accounts_test(
        econia: &signer,
        user: &signer,
        general_custodian_id_agnostic: u64,
        general_custodian_id_pure_coin: u64
    ): (
        MarketAccountInfo,
        MarketAccountInfo
    ) acquires Collateral, MarketAccounts {
        // Init test markets, storing relevant parameters
        let  (_, _,
              generic_asset_transfer_custodian_id_agnostic,
              market_id_agnostic,
              _, _,
              generic_asset_transfer_custodian_id_pure_coin,
              market_id_pure_coin
        ) = registry::register_market_internal_multiple_test(econia);
        // Register user for agnostic market
        register_market_account<BG, QG>(
            user, market_id_agnostic, general_custodian_id_agnostic);
        // Register user for pure coin market
        register_market_account<BC, QC>(
            user, market_id_pure_coin, general_custodian_id_pure_coin);
        let market_account_info_agnostic = MarketAccountInfo{
            market_id: market_id_agnostic,
            general_custodian_id: general_custodian_id_agnostic,
            generic_asset_transfer_custodian_id:
                generic_asset_transfer_custodian_id_agnostic
        }; // Define agnostic market account info
        let market_account_info_pure_coin = MarketAccountInfo{
            market_id: market_id_pure_coin,
            general_custodian_id: general_custodian_id_pure_coin,
            generic_asset_transfer_custodian_id:
                generic_asset_transfer_custodian_id_pure_coin
        }; // Define pure coin market account info
        // Return corresponding market account info
        (market_account_info_agnostic, market_account_info_pure_coin)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for asset not in pair
    fun test_borrow_asset_counts_mut_not_in_pair(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register user with agnostic market account
        let (market_account_info, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        borrow_asset_counts_mut<BC>( // Attempt invalid invocation
            market_accounts_map_ref_mut, market_account_info);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify state for depositing generic and coin assets
    fun test_deposit_assets_mixed(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Declare deposit parameters
        let coin_amount = 700;
        let generic_amount = 500;
        // Declare user-level general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        assets::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initalize registry
        // Register a custodian capability
        let custodian_capability = registry::register_custodian_capability();
        // Get ID of custodian capability
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            &custodian_capability);
        // Register market with generic base asset and coin quote asset
        registry::register_market_internal<BG, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id);
        let market_id = 0; // Declare market ID
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        coin::register_for_test<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, coin_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, generic_amount,
            &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert state
        let (base_total, base_available, quote_total, quote_available) =
            asset_counts_test(@user, market_id, general_custodian_id);
        assert!(base_total      == generic_amount, 0);
        assert!(base_available  == generic_amount, 0);
        assert!(quote_total     == coin_amount,    0);
        assert!(quote_available == coin_amount,    0);
        assert!(!has_collateral_test<BG>(
            @user, market_id, general_custodian_id), 0);
        assert!(collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == coin_amount, 0);

    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 12)]
    /// Verify failure for calling with a coin type
    fun test_deposit_generic_asset_not_generic_asset(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        assets::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initalize registry
        // Register a custodian capability
        let custodian_capability = registry::register_custodian_capability();
        // Get ID of custodian capability
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            &custodian_capability);
        // Register market with generic base asset and coin quote asset
        registry::register_market_internal<BG, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id);
        let market_id = 0; // Declare market ID
        // Declare user-level general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Attempt invalid invocation
        deposit_generic_asset<QC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, 500, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for invalid generic asset transfer custodian
    fun test_deposit_generic_asset_unauthorized_custodian(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register user with agnostic market account
        let (market_account_info, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        // Unpack market account info fields
        let MarketAccountInfo{market_id, general_custodian_id,
                generic_asset_transfer_custodian_id} = market_account_info;
        // Get capability for invalid custodian
        let custodian_capability = registry::get_custodian_capability_test(
            generic_asset_transfer_custodian_id + 1);
        // Attempt invalid invocation
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, 500, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
    }

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_collateral_entry(
        user: &signer
    ) acquires Collateral {
        let market_account_info_1 = MarketAccountInfo{
            market_id: 0,
            general_custodian_id: 1,
            generic_asset_transfer_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        let market_account_info_2 = MarketAccountInfo{
            market_id: 0,
            general_custodian_id: NO_CUSTODIAN,
            generic_asset_transfer_custodian_id: PURE_COIN_PAIR
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
            general_custodian_id: 1,
            generic_asset_transfer_custodian_id: PURE_COIN_PAIR
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
        let agnostic_test_market_id = 0; // Declare market ID
        // Attempt invalid registration
        register_market_account<BG, QG>(
            user, agnostic_test_market_id, 1000000000);
    }

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_market_accounts_entry(
        user: &signer
    ) acquires MarketAccounts {
        let market_account_info_1 = MarketAccountInfo{
            market_id: 0,
            general_custodian_id: 1,
            generic_asset_transfer_custodian_id: PURE_COIN_PAIR
        }; // Declare market account info
        let market_account_info_2 = MarketAccountInfo{
            market_id: 0,
            general_custodian_id: NO_CUSTODIAN,
            generic_asset_transfer_custodian_id: PURE_COIN_PAIR
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
            general_custodian_id: 1,
            generic_asset_transfer_custodian_id: PURE_COIN_PAIR
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
        let  (_, _,
              generic_asset_transfer_custodian_id_agnostic,
              market_id_agnostic,
              _, _,
              generic_asset_transfer_custodian_id_pure_coin,
              market_id_pure_coin
        ) = registry::register_market_internal_multiple_test(econia);
        // Declare custodian IDs
        let general_custodian_id_agnostic = NO_CUSTODIAN;
        let general_custodian_id_pure_coin = 2;
        // Register corresponding market accounts
        register_market_account<BG, QG>(
            user, market_id_agnostic, general_custodian_id_agnostic);
        register_market_account<BC, QC>(
            user, market_id_pure_coin, general_custodian_id_pure_coin);
        // Get market account info for both market accounts
        let market_account_info_agnostic = MarketAccountInfo{
            market_id: market_id_agnostic,
            general_custodian_id: general_custodian_id_agnostic,
            generic_asset_transfer_custodian_id:
                generic_asset_transfer_custodian_id_agnostic
        };
        let market_account_info_pure_coin = MarketAccountInfo{
            market_id: market_id_pure_coin,
            general_custodian_id: general_custodian_id_pure_coin,
            generic_asset_transfer_custodian_id:
                generic_asset_transfer_custodian_id_pure_coin
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

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no market accounts
    fun test_verify_market_account_exists_no_market_accounts()
    acquires MarketAccounts {
        let market_account_info = MarketAccountInfo{
            market_id: 5,
            general_custodian_id: 7,
            generic_asset_transfer_custodian_id: 9
        }; // Define bogus market account info
        // Attempt invalid invocation
        verify_market_account_exists(@user, market_account_info);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for wrong market account
    fun test_verify_market_account_exists_wrong_market_account(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register user with agnostic market account
        let (market_account_info, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        // Update market account field with bogus value
        market_account_info.general_custodian_id = 1;
        // Attempt invalid existence verification
        verify_market_account_exists(@user, market_account_info);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify state for withdrawing generic and coin assets
    fun test_withdraw_assets_mixed(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Declare asset count deposit parameters
        let coin_deposit_amount = 700;
        let generic_deposit_amount = 500;
        let coin_withdrawal_amount = 600;
        let generic_withdrawal_amount = generic_deposit_amount;
        let coin_end_amount = coin_deposit_amount - coin_withdrawal_amount;
        let generic_end_amount = 0;
        let coinstore_end_amount = coin_withdrawal_amount;
        // Declare user-level general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        assets::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initalize registry
        // Register a custodian capability
        let custodian_capability = registry::register_custodian_capability();
        // Get ID of custodian capability
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            &custodian_capability);
        // Register market with generic base asset and coin quote asset
        registry::register_market_internal<BG, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id);
        let market_id = 0; // Declare market ID
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        coin::register_for_test<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_deposit_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, coin_deposit_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, generic_deposit_amount,
            &custodian_capability);
        // Withdraw coin asset to coinstore
        withdraw_to_coinstore<QC>(user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, coin_withdrawal_amount);
        // Withdraw generic asset
        withdraw_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, generic_withdrawal_amount,
            &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert state
        let (base_total, base_available, quote_total, quote_available) =
            asset_counts_test(@user, market_id, general_custodian_id);
        assert!(base_total      == generic_end_amount, 0);
        assert!(base_available  == generic_end_amount, 0);
        assert!(quote_total     == coin_end_amount,    0);
        assert!(quote_available == coin_end_amount,    0);
        assert!(collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == coin_end_amount, 0);
        assert!(coin::balance<QC>(@user) == coinstore_end_amount, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}