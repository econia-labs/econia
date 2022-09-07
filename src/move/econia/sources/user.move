/// User-side book keeping and, optionally, collateral management.
///
/// # Market account custodians
///
/// For any given market, designated by a unique market ID, a user can
/// register multiple `MarketAccount`s, distinguished from one another
/// by their corresponding "general custodian ID". The custodian
/// capability having this ID is required to approve all market
/// transactions within the market account with the exception of coin
/// deposits and generic asset transfers, with the latter approved by a
/// market-wide "generic asset transfer custodian" in the case of
/// a market having at least one non-coin asset. When a general
/// custodian ID is marked `NO_CUSTODIAN`, a signing user is required to
/// approve general transactions rather than a custodian capability.
/// Again, no authority is required to deposit coin types.
///
/// For example: market 5 has a generic (non-coin) base asset, a coin
/// quote asset, and generic asset transfer custodian ID 6. A user
/// opens two market accounts for market 5, one having general
/// custodian ID 7, and one having general custodian ID `NO_CUSTODIAN`.
/// When a user wishes to deposit base assets to the first market
/// account, custodian 6 is required for authorization. Then when the
/// user wishes to submit an ask, custodian 7 must approve it. As for
/// the second account, a user can withdraw quote coins and place or
/// cancel trades via a signature, but custodian 6 is still required to
/// verify base deposits and withdrawals.
///
/// In other words, the market-wide generic asset transfer custodian ID
/// overrides the user-specific general custodian ID only when
/// depositing or withdrawing generic assets, otherwise the
/// user-specific general custodian ID takes precedence. Notably, a user
/// can register a `MarketAccount` having the same general custodian ID
/// and generic asset transfer custodian ID, and here, no overriding
/// takes place. For example, if market 8 requires generic asset
/// transfer custodian ID 9, a user can still register a market account
/// having general custodian ID 9, and then custodian 9 will be required
/// to authorize all of a user's transactions for the given
/// `MarketAccount`.
///
/// # Market account ID
///
/// Since any of a user's `MarketAccount`s are specified by a
/// unique combination of market ID and general custodian ID, a user's
/// market account ID is thus defined as a 128-bit number, where the
/// most-significant ("first") 64 bits correspond to the market ID, and
/// the least-significant ("last") 64 bits correspond to the general
/// custodian ID.
///
/// For a market ID of `255` (`0b11111111`) and a general custodian ID
/// of `170` (`0b10101010`), for example, the corresponding market
/// account ID has the first 64 bits
/// `0000000000000000000000000000000000000000000000000000000011111111`
/// and the last 64 bits
/// `0000000000000000000000000000000000000000000000000000000010101010`,
/// corresponding to the base-10 integer `4703919738795935662250`. Note
/// that when a user opts to sign general transactions rather than
/// delegate to a general custodian, the market account ID uses a
/// general custodian ID of `NO_CUSTODIAN`, corresponding to `0`.
///
/// ---
///
module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
    use econia::order_id;
    use econia::registry::{Self, CustodianCapability};
    use std::option;
    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use econia::assets::{Self, BC, BG, QC, QG};
    #[test_only]
    use econia::critbit::{u, u_long};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Collateral map for given coin type, across all `MarketAccount`s
    struct Collateral<phantom CoinType> has key {
        /// Map from market account ID to coins held as collateral for
        /// given `MarketAccount`. Separated into different table
        /// entries to reduce transaction collisions across markets
        map: open_table::OpenTable<u128, Coin<CoinType>>
    }

    /// Represents a user's open orders and available assets for a given
    /// market account ID
    struct MarketAccount has store {
        /// Base asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds to
        /// `registry::GenericAsset`, or a non-coin asset indicated by
        /// the market host.
        base_type_info: type_info::TypeInfo,
        /// Quote asset type info. When trading an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType`, for instance `MyCoin` rather than
        /// `Coin<MyCoin>`. Otherwise corresponds to
        /// `registry::GenericAsset`, or a non-coin asset indicated by
        /// the market host.
        quote_type_info: type_info::TypeInfo,
        /// ID of custodian capability required to verify deposits,
        /// swaps, and withdrawals of assets that are not coins. A
        /// "market-wide asset transfer custodian ID" that only applies
        /// to markets having at least one non-coin asset. For a market
        /// having one coin asset and one generic asset, only applies to
        /// the generic asset. Marked `PURE_COIN_PAIR` when base and
        /// quote types are both coins.
        generic_asset_transfer_custodian_id: u64,
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
        /// Amount `base_total` will increase to if all open bids fill
        base_ceiling: u64,
        /// Total quote asset units held as collateral
        quote_total: u64,
        /// Quote asset units available for withdraw
        quote_available: u64,
        /// Amount `quote_total` will increase to if all open asks fill
        quote_ceiling: u64
    }

    /// Market account map for all of a user's `MarketAccount`s
    struct MarketAccounts has key {
        /// Map from market account ID to `MarketAccount`. Separated
        /// into different table entries to reduce transaction
        /// collisions across markets
        map: open_table::OpenTable<u128, MarketAccount>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When indicated asset is not in the market pair
    const E_NOT_IN_MARKET_PAIR: u64 = 0;
    /// When indicated custodian ID is not registered
    const E_UNREGISTERED_CUSTODIAN_ID: u64 = 1;
    /// When market account already exists for given market account ID
    const E_EXISTS_MARKET_ACCOUNT: u64 = 2;
    /// When indicated market account does not exist
    const E_NO_MARKET_ACCOUNT: u64 = 3;
    /// When not enough asset available for operation
    const E_NOT_ENOUGH_ASSET_AVAILABLE: u64 = 4;
    /// When depositing an asset would overflow total holdings ceiling
    const E_DEPOSIT_OVERFLOW_ASSET_CEILING: u64 = 5;
    /// When number of ticks to fill order overflows a `u64`
    const E_TICKS_OVERFLOW: u64 = 6;
    /// When a user does not a `MarketAccounts`
    const E_NO_MARKET_ACCOUNTS: u64 = 7;
    /// When proposed order indicates a size of 0
    const E_SIZE_0: u64 = 8;
    /// When proposed order indicates a price of 0
    const E_PRICE_0: u64 = 9;
    /// When filling proposed order overflows asset received from trade
    const E_OVERFLOW_ASSET_IN: u64 = 10;
    /// When filling proposed order overflows asset traded away
    const E_OVERFLOW_ASSET_OUT: u64 = 11;
    /// When asset indicated as generic actually corresponds to a coin
    const E_NOT_GENERIC_ASSET: u64 = 12;
    /// When asset indicated as coin actually corresponds to a generic
    const E_NOT_COIN_ASSET: u64 = 13;
    /// When indicated custodian unauthorized to perform operation
    const E_UNAUTHORIZED_CUSTODIAN: u64 = 14;
    /// When no orders for indicated operation
    const E_NO_ORDERS: u64 = 15;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag for asks side
    const ASK: bool = true;
    /// Flag for asks side
    const BID: bool = false;
    /// Flag for asset transfer of coin type
    const COIN_ASSET_TRANSFER: u64 = 0;
    /// Positions to bitshift for operating on first 64 bits
    const FIRST_64: u8 = 64;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Flag for inbound coins
    const IN: bool = true;
    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// Flag for outbound coins
    const OUT: bool = false;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Deposit `coins` of `CoinType` to `user`'s market account having
    /// `market_id` and `general_custodian_id`
    ///
    /// See wrapped function `deposit_asset()`
    public fun deposit_coins<CoinType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        coins: Coin<CoinType>
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_asset<CoinType>(
            user,
            get_market_account_id(market_id, general_custodian_id),
            coin::value(&coins),
            option::some(coins),
            COIN_ASSET_TRANSFER
        )
    }

    /// Deposit `amount` of non-coin assets of `AssetType` to `user`'s
    /// market account having `market_id` and `general_custodian_id`,
    /// under authority of custodian indicated by
    /// `generic_asset_transfer_custodian_capability_ref`
    ///
    /// See wrapped function `deposit_asset()`
    ///
    /// # Abort conditions
    /// * If `AssetType` corresponds to the `CoinType` of an initialized
    ///   coin
    public fun deposit_generic_asset<AssetType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        amount: u64,
        generic_asset_transfer_custodian_capability_ref: &CustodianCapability
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Assert asset type does not correspond to an initialized coin
        assert!(!coin::is_coin_initialized<AssetType>(), E_NOT_GENERIC_ASSET);
        // Get generic asset transfer custodian ID
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            generic_asset_transfer_custodian_capability_ref);
        deposit_asset<AssetType>( // Deposit generic asset
            user,
            get_market_account_id(market_id, general_custodian_id),
            amount,
            option::none<Coin<AssetType>>(),
            generic_asset_transfer_custodian_id
        )
    }

    /// Return `MarketAccount` asset count fields for given `user` and
    /// `market_account_id`, under authority of general custodian
    /// indicated by `general_custodian_capability_ref()`.
    ///
    /// See wrapped call `get_asset_counts()`.
    ///
    /// # Restrictions
    /// * Restricted to general custodian for given account to prevent
    ///   excessive public queries and thus transaction collisions
    public fun get_asset_counts_custodian(
        user: address,
        market_id: u64,
        general_custodian_capability_ref: &CustodianCapability
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        get_asset_counts(user, get_market_account_id(
            market_id,
            registry::custodian_id(general_custodian_capability_ref)
        ))
    }

    /// Return `MarketAccount` asset count fields for given `user` and
    /// `market_account_id`, under authority of signing user for a
    /// market account without a delegated general custodian.
    ///
    /// See wrapped call `get_asset_counts()`.
    ///
    /// # Restrictions
    /// * Restricted to signing user for given account to prevent
    ///   excessive public queries and thus transaction collisions
    public fun get_asset_counts_user(
        user: &signer,
        market_id: u64,
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        get_asset_counts(
            address_of(user),
            get_market_account_id(market_id, NO_CUSTODIAN)
        )
    }

    /// Get general custodian ID encoded in `market_account_id`
    public fun get_general_custodian_id(
        market_account_id: u128
    ): u64 {
        (market_account_id & (HI_64 as u128) as u64)
    }

    /// Return market account ID for given `market_id` and
    /// `general_custodian_id`
    public fun get_market_account_id(
        market_id: u64,
        general_custodian_id: u64
    ): u128 {
        (market_id as u128) << FIRST_64 | (general_custodian_id as u128)
    }

    /// Get market ID encoded in `market_account_id`
    public fun get_market_id(
        market_account_id: u128
    ): u64 {
        (market_account_id >> FIRST_64 as u64)
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id`, under authority of custodian
    /// indicated by `general_custodian_capability_ref`
    ///
    /// See wrapped function `withdraw_coins()`
    public fun withdraw_coins_custodian<CoinType>(
        user: address,
        market_id: u64,
        amount: u64,
        general_custodian_capability_ref: &CustodianCapability
    ): coin::Coin<CoinType>
    acquires
        Collateral,
        MarketAccounts
    {
        withdraw_coins<CoinType>(
            user,
            market_id,
            registry::custodian_id(general_custodian_capability_ref),
            amount
        )
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id` and no general custodian,returning
    /// coins.
    ///
    /// See wrapped function `withdraw_coins()`.
    public fun withdraw_coins_user<CoinType>(
        user: &signer,
        market_id: u64,
        amount: u64,
    ): coin::Coin<CoinType>
    acquires
        Collateral,
        MarketAccounts
    {
        withdraw_coins<CoinType>(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            amount
        )
    }

    /// Withdraw `amount` of non-coin assets of `AssetType` from
    /// `user`'s market account having `market_id` and
    /// `general_custodian_id`, under authority of custodian indicated
    /// by `generic_asset_transfer_custodian_capability_ref`.
    ///
    /// See wrapped function `withdraw_asset()`.
    ///
    /// # Abort conditions
    /// * If `AssetType` corresponds to the `CoinType` of an initialized
    ///   coin
    public fun withdraw_generic_asset<AssetType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        amount: u64,
        generic_asset_transfer_custodian_capability_ref: &CustodianCapability
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Assert asset type does not correspond to an initialized coin
        assert!(!coin::is_coin_initialized<AssetType>(), E_NOT_GENERIC_ASSET);
        // Get generic asset transfer custodian ID
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            generic_asset_transfer_custodian_capability_ref);
        // Get market account ID
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Withdraw asset as empty option
        let empty_option = withdraw_asset<AssetType>(user, market_account_id,
            amount, false, generic_asset_transfer_custodian_id);
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
        amount: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_coins<CoinType>(
            address_of(user),
            market_id,
            general_custodian_id,
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
    /// * `market_id`: Serial ID of corresponding market
    /// * `general_custodian_id`: Serial ID of custodian capability
    ///   required for general account authorization, set to
    ///   `NO_CUSTODIAN` if signing user required for authorization on
    ///   market account
    ///
    /// # Abort conditions
    /// * If invalid `custodian_id`
    public entry fun register_market_account<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        general_custodian_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // If general custodian ID indicated, assert it is registered
        if (general_custodian_id != NO_CUSTODIAN) assert!(
            registry::is_registered_custodian_id(general_custodian_id),
            E_UNREGISTERED_CUSTODIAN_ID);
        // Get market account ID
        let market_account_id = get_market_account_id(
            market_id, general_custodian_id);
        // Register entry in market accounts map
        register_market_accounts_entry<BaseType, QuoteType>(
            user, market_account_id);
        // If base asset is coin, register collateral entry
        if (coin::is_coin_initialized<BaseType>())
            register_collateral_entry<BaseType>(user, market_account_id);
        // If quote asset is coin, register collateral entry
        if (coin::is_coin_initialized<QuoteType>())
            register_collateral_entry<QuoteType>(user, market_account_id);
    }

    #[cmd]
    /// Transfer `amount` of coins of `CoinType` from `user`'s
    /// `Collateral` to their `aptos_framework::coin::CoinStore` for
    /// market account having `market_id` and
    /// `generic_asset_transfer_custodian_id` but no general custodian
    ///
    /// See wrapped function `withdraw_coins_user()`
    public entry fun withdraw_to_coinstore<CoinType>(
        user: &signer,
        market_id: u64,
        amount: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Withdraw coins from user's market account
        let coins = withdraw_coins_user<CoinType>(user, market_id, amount);
        // Deposit coins to user's coin store
        coin::deposit<CoinType>(address_of(user), coins);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Deposit `amount` of assets of `AssetType` to `user`'s market
    /// account indicated by `market_account_id` and having
    /// `generic_asset_transfer_custodian_id`, returning coins
    /// in an `option::Option` if `AssetType` is a coin type.
    ///
    /// See wrapped function `deposit_asset()`.
    public(friend) fun deposit_asset_as_option_internal<AssetType>(
        user: address,
        market_account_id: u128,
        amount: u64,
        optional_coins: option::Option<Coin<AssetType>>,
        generic_asset_transfer_custodian_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_asset<AssetType>(user, market_account_id, amount,
            optional_coins, generic_asset_transfer_custodian_id)
    }

    /// Withdraw `base_amount` of `BaseType` and `quote_amount` of
    /// Deposit `base_amount` of `BaseType` and `quote_amount` of
    /// `QuoteType` from `user`'s market account indicated by
    /// `market_account_id` and having
    /// `generic_asset_transfer_custodian_id`, returning coins
    /// in an `option::Option` as needed for each type.
    ///
    /// See wrapped function `deposit_asset_as_option_internal()`.
    public(friend) fun deposit_assets_as_option_internal<
        BaseType,
        QuoteType
    >(
        user: address,
        market_account_id: u128,
        base_amount: u64,
        quote_amount: u64,
        optional_base_coins: option::Option<Coin<BaseType>>,
        optional_quote_coins: option::Option<Coin<QuoteType>>,
        generic_asset_transfer_custodian_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Deposit base
        deposit_asset_as_option_internal<BaseType>(user, market_account_id,
            base_amount, optional_base_coins,
            generic_asset_transfer_custodian_id);
        // Deposit quote
        deposit_asset_as_option_internal<QuoteType>(user, market_account_id,
            quote_amount, optional_quote_coins,
            generic_asset_transfer_custodian_id);
    }

    /// Fill a user's order, routing coin collateral as needed.
    ///
    /// Only to be called by the matching engine, which has already
    /// calculated the corresponding amount of assets to fill. If the
    /// matching engine gets to this stage, then it is assumed that
    /// given user has the indicated open order and sufficient assets
    /// to fill it. Hence no error checking.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_id`: Corresponding market account ID
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `fill_size`: Number of lots filled
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine
    /// * `base_to_route`: If `side` is `ASK`, number of base asset
    ///   units routed from `user`, else to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote asset
    ///   units routed to `user`, else from `user`
    public(friend) fun fill_order_internal<
        BaseType,
        QuoteType
    >(
        user: address,
        market_account_id: u128,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        fill_size: u64,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Update user's market account
        fill_order_update_market_account(user, market_account_id, side,
            order_id, complete_fill, fill_size, base_to_route, quote_to_route);
        // Route collateral accordingly, as needed
        fill_order_route_collateral<BaseType, QuoteType>(user,
            market_account_id, side, optional_base_coins_ref_mut,
            optional_quote_coins_ref_mut, base_to_route, quote_to_route);
    }

    /// Return `MarketAccount` asset count fields for given `user` and
    /// `market_account_id` .
    ///
    /// See wrapped call `get_asset_counts()`.
    ///
    /// # Restrictions
    /// * Restricted to friend modules to prevent excessive public
    ///   queries and thus transaction collisions
    public(friend) fun get_asset_counts_internal(
        user: address,
        market_account_id: u128
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        get_asset_counts(user, market_account_id)
    }

    /// Return number of open orders for given `user`,
    /// `market_account_id`, and `side`
    ///
    /// # Restrictions
    /// * Restricted to friends prevent excessive public queries and
    ///   thus transaction collisions
    public(friend) fun get_n_orders_internal(
        user: address,
        market_account_id: u128,
        side: bool
    ): u64
    acquires MarketAccounts {
        // Verify user has a corresponding market account
        verify_market_account_exists(user, market_account_id);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref = &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to corresponding market account
        let market_account_ref =
            open_table::borrow(market_accounts_map_ref, market_account_id);
        // Borrow immutable reference to corresponding orders tree
        let tree_ref = if (side == ASK) &market_account_ref.asks else
            &market_account_ref.bids;
        critbit::length(tree_ref) // Return number of orders
    }

    /// Return order ID of order nearest the spread, for given `user`,
    /// `market_account_id`, and `side`
    ///
    /// # Restrictions
    /// * Restricted to friends prevent excessive public queries and
    ///   thus transaction collisions
    public(friend) fun get_order_id_nearest_spread_internal(
        user: address,
        market_account_id: u128,
        side: bool
    ): u128
    acquires MarketAccounts {
        // Verify user has a corresponding market account
        verify_market_account_exists(user, market_account_id);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref = &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to corresponding market account
        let market_account_ref =
            open_table::borrow(market_accounts_map_ref, market_account_id);
        // Borrow immutable reference to corresponding orders tree
        let tree_ref = if (side == ASK) &market_account_ref.asks else
            &market_account_ref.bids;
        // Assert tree is not empty
        assert!(!critbit::is_empty(tree_ref), E_NO_ORDERS);
        if (side == ASK) critbit::min_key(tree_ref) else
            critbit::max_key(tree_ref)
    }

    /// Register a new order under a user's market account
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_id`: Corresponding market account ID
    /// * `side:` `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `size`: Size of order in lots
    /// * `price`: Price of order in ticks per lot
    /// * `lot_size`: Base asset units per lot
    /// * `tick_size`: Quote asset units per tick
    ///
    /// # Assumes
    /// * `price` is same as that encoded in `order_id`, since called by
    ///   the matching engine
    /// * `lot_size` and `tick_size` correspond to market ID encoded in
    ///   `market_account_id`, since called by the matching engine
    public(friend) fun register_order_internal(
        user: address,
        market_account_id: u128,
        side: bool,
        order_id: u128,
        size: u64,
        price: u64,
        lot_size: u64,
        tick_size: u64,
    ) acquires MarketAccounts {
        // Verify user has a corresponding market account
        verify_market_account_exists(user, market_account_id);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to corresponding market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_id);
        // Borrow mutable reference to open orders tree, mutable
        // reference to ceiling field for asset received from trade, and
        // mutable reference to available field for asset traded away
        let (
            tree_ref_mut,
            in_asset_ceiling_ref_mut,
            out_asset_available_ref_mut
        ) = if (side == ASK) (
                &mut market_account_ref_mut.asks,
                &mut market_account_ref_mut.quote_ceiling,
                &mut market_account_ref_mut.base_available
            ) else (
                &mut market_account_ref_mut.bids,
                &mut market_account_ref_mut.base_ceiling,
                &mut market_account_ref_mut.quote_available
            );
        // Range check proposed order, store fill amounts
        let (in_asset_fill, out_asset_fill) = range_check_new_order(
            side, size, price, lot_size, tick_size,
            *in_asset_ceiling_ref_mut, *out_asset_available_ref_mut);
        // Add order to corresponding tree
        critbit::insert(tree_ref_mut, order_id, size);
        // Increment asset ceiling amount for asset received from trade
        *in_asset_ceiling_ref_mut = *in_asset_ceiling_ref_mut + in_asset_fill;
        // Decrement asset available amount for asset traded away
        *out_asset_available_ref_mut =
            *out_asset_available_ref_mut - out_asset_fill;
    }

    /// Remove an order from a user's market account
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_id`: Corresponding market account ID
    /// * `lot_size`: Base asset units per lot
    /// * `tick_size`: Quote asset units per tick
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    ///
    /// # Assumes
    /// * That order has already been cancelled from the order book, and
    ///   as such that user necessarily has an open order as specified:
    ///   if an order has been cancelled from the book, then it had to
    ///   have been placed on the book, which means that the
    ///   corresponding user successfully placed it to begin with.
    public(friend) fun remove_order_internal(
        user: address,
        market_account_id: u128,
        lot_size: u64,
        tick_size: u64,
        side: bool,
        order_id: u128,
    ) acquires MarketAccounts {
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to corresponding market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_id);
        // Get mutable reference to corresponding tree, mutable
        // reference to corresponding assets available field, mutable
        // reference to corresponding asset ceiling fields, available
        // size multiplier, and ceiling size multiplier, based on side
        let (tree_ref_mut, asset_available_ref_mut, asset_ceiling_ref_mut,
             size_multiplier_available, size_multiplier_ceiling) =
            if (side == ASK) (
                &mut market_account_ref_mut.asks,
                &mut market_account_ref_mut.base_available,
                &mut market_account_ref_mut.quote_ceiling,
                lot_size,
                order_id::price(order_id) * tick_size
            ) else (
                &mut market_account_ref_mut.bids,
                &mut market_account_ref_mut.quote_available,
                &mut market_account_ref_mut.base_ceiling,
                order_id::price(order_id) * tick_size,
                lot_size
            );
        // Pop order from corresponding tree, storing specified size
        let size = critbit::pop(tree_ref_mut, order_id);
        // Calculate amount of asset unlocked by order cancellation
        let unlocked = size * size_multiplier_available;
        // Update available asset field for amount unlocked
        *asset_available_ref_mut = *asset_available_ref_mut + unlocked;
        // Calculate amount that ceiling decrements due to cancellation
        let ceiling_decrement_amount = size * size_multiplier_ceiling;
        // Decrement ceiling amount accordingly
        *asset_ceiling_ref_mut = *asset_ceiling_ref_mut -
            ceiling_decrement_amount;
    }

    /// Withdraw `amount` of assets of `AssetType` from `user`'s market
    /// account indicated by `market_account_id` and having
    /// `generic_asset_transfer_custodian_id`, returning coins
    /// in an `option::Option` if `AssetType` is a coin type.
    ///
    /// See wrapped function `withdraw_asset()`.
    public(friend) fun withdraw_asset_as_option_internal<AssetType>(
        user: address,
        market_account_id: u128,
        amount: u64,
        generic_asset_transfer_custodian_id: u64
    ): option::Option<Coin<AssetType>>
    acquires
        Collateral,
        MarketAccounts
    {
        withdraw_asset<AssetType>(user, market_account_id, amount,
            coin::is_coin_initialized<AssetType>(),
            generic_asset_transfer_custodian_id)
    }

    /// Withdraw `base_amount` of `BaseType` and `quote_amount` of
    /// `QuoteType` assets from `user`'s market account indicated by
    /// `market_account_id` and having
    /// `generic_asset_transfer_custodian_id`, returning coins in an
    /// `option::Option` as needed for each type.
    ///
    /// See wrapped function `withdraw_asset_as_option_internal()`.
    public(friend) fun withdraw_assets_as_option_internal<
        BaseType,
        QuoteType,
    >(
        user: address,
        market_account_id: u128,
        base_amount: u64,
        quote_amount: u64,
        generic_asset_transfer_custodian_id: u64
    ): (
        option::Option<Coin<BaseType>>,
        option::Option<Coin<QuoteType>>
    ) acquires
        Collateral,
        MarketAccounts
    {
        ( // Withdraw and return base/quote types in an option
            withdraw_asset<BaseType>(user, market_account_id, base_amount,
                coin::is_coin_initialized<BaseType>(),
                generic_asset_transfer_custodian_id),
            withdraw_asset<QuoteType>(user, market_account_id, quote_amount,
                coin::is_coin_initialized<QuoteType>(),
                generic_asset_transfer_custodian_id)
        )
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account indicated by `market_account_id`, returning them
    /// wrapped in an option
    ///
    /// See wrapped function `withdraw_asset()`.
    public(friend) fun withdraw_coins_as_option_internal<CoinType>(
        user: address,
        market_account_id: u128,
        amount: u64
    ): option::Option<Coin<CoinType>>
    acquires
        Collateral,
        MarketAccounts
    {
        withdraw_asset<CoinType>(user, market_account_id, amount, true,
            COIN_ASSET_TRANSFER)
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow mutable/immutable references to `MarketAccount` fields
    /// required when depositing/withdrawing `AssetType`
    ///
    /// Look up the `MarketAccount` having `market_account_id` in the
    /// market accounts map indicated by `market_accounts_map_ref_mut`,
    /// then return a mutable reference to the amount of `AssetType`
    /// holdings, a mutable reference to the amount of `AssetType`
    /// available for withdraw, a mutable reference to `AssetType`
    /// ceiling, and an immutable reference to the generic asset
    /// transfer custodian ID for the given market
    ///
    /// # Returns
    /// * `u64`: Mutable reference to `MarketAccount.base_total` for
    ///   corresponding market account if `AssetType` is market base,
    ///   else mutable reference to `MarketAccount.quote_total`
    /// * `u64`: Mutable reference to `MarketAccount.base_available` for
    ///   corresponding market account if `AssetType` is market base,
    ///   else mutable reference to `MarketAccount.quote_available`
    /// * `u64`: Mutable reference to `MarketAccount.base_ceiling` for
    ///   corresponding market account if `AssetType` is market base,
    ///   else mutable reference to `MarketAccount.quote_ceiling`
    /// * `u64`: Immutable reference to generic asset transfer custodian
    ///   ID
    ///
    /// # Assumes
    /// * `market_accounts_map` has an entry with `market_account_id`
    ///
    /// # Abort conditions
    /// * If `AssetType` is neither base nor quote for given market
    ///   account
    fun borrow_transfer_fields_mixed<AssetType>(
        market_accounts_map_ref_mut:
            &mut open_table::OpenTable<u128, MarketAccount>,
        market_account_id: u128
    ): (
        &mut u64,
        &mut u64,
        &mut u64,
        &u64,
    ) {
        // Borrow mutable reference to market account
        let market_account_ref_mut =
            open_table::borrow_mut(
                market_accounts_map_ref_mut, market_account_id);
        // Get asset type info
        let asset_type_info = type_info::type_of<AssetType>();
        // If is base asset, return mutable references to base fields
        if (asset_type_info == market_account_ref_mut.base_type_info) {
            return (
                &mut market_account_ref_mut.base_total,
                &mut market_account_ref_mut.base_available,
                &mut market_account_ref_mut.base_ceiling,
                &market_account_ref_mut.generic_asset_transfer_custodian_id
            )
        // If is quote asset, return mutable references to quote fields
        } else if (asset_type_info == market_account_ref_mut.quote_type_info) {
            return (
                &mut market_account_ref_mut.quote_total,
                &mut market_account_ref_mut.quote_available,
                &mut market_account_ref_mut.quote_ceiling,
                &market_account_ref_mut.generic_asset_transfer_custodian_id
            )
        }; // Otherwise abort
        abort E_NOT_IN_MARKET_PAIR
    }

    /// Deposit `amount` of `AssetType`, which may include
    /// `optional_coins`, to `user`'s market account
    /// having `market_account_id`, optionally verifying
    /// `generic_asset_transfer_custodian_id` in the case of depositing
    /// a generic asset (ignored if depositing coin type)
    ///
    /// # Assumes
    /// * That if depositing a coin asset, `amount` matches value of
    ///   `optional_coins`
    /// * That when depositing a coin asset, if the market account
    ///   exists, then a corresponding collateral container does too
    ///
    /// # Abort conditions
    /// * If deposit would overflow the total asset holdings ceiling
    /// * If unauthorized `generic_asset_transfer_custodian_id` in the
    ///   case of depositing a generic asset
    fun deposit_asset<AssetType>(
        user: address,
        market_account_id: u128,
        amount: u64,
        optional_coins: option::Option<Coin<AssetType>>,
        generic_asset_transfer_custodian_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Verify user has corresponding market account
        verify_market_account_exists(user, market_account_id);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total asset holdings, mutable
        // reference to amount of assets available for withdrawal,
        // mutable reference to total asset holdings ceiling, and
        // immutable reference to generic asset transfer custodian ID
        let (asset_total_ref_mut, asset_available_ref_mut,
             asset_ceiling_ref_mut, generic_asset_transfer_custodian_id_ref) =
                borrow_transfer_fields_mixed<AssetType>(
                    market_accounts_map_ref_mut, market_account_id);
        // Assert deposit does not overflow asset ceiling
        assert!(!((*asset_ceiling_ref_mut as u128) + (amount as u128) >
            (HI_64 as u128)), E_DEPOSIT_OVERFLOW_ASSET_CEILING);
        // Increment total asset holdings amount
        *asset_total_ref_mut = *asset_total_ref_mut + amount;
        // Increment assets available for withdrawal amount
        *asset_available_ref_mut = *asset_available_ref_mut + amount;
        // Increment total asset holdings ceiling amount
        *asset_ceiling_ref_mut = *asset_ceiling_ref_mut + amount;
        if (option::is_some(&optional_coins)) { // If asset is coin type
            // Borrow mutable reference to collateral map
            let collateral_map_ref_mut =
                &mut borrow_global_mut<Collateral<AssetType>>(user).map;
            // Borrow mutable reference to collateral for market account
            let collateral_ref_mut = open_table::borrow_mut(
                collateral_map_ref_mut, market_account_id);
            coin::merge( // Merge optional coins into collateral
                collateral_ref_mut, option::destroy_some(optional_coins));
        } else { // If asset is not coin type
            // Verify indicated generic asset transfer custodian ID
            assert!(generic_asset_transfer_custodian_id ==
                *generic_asset_transfer_custodian_id_ref,
                E_UNAUTHORIZED_CUSTODIAN);
            // Destroy empty option resource
            option::destroy_none(optional_coins);
        }
    }

    /// Route collateral when filling an order, for coin assets.
    ///
    /// Inner function for `fill_order_internal()`.
    ///
    /// # Type parameters
    /// * `BaseType`: Base type for market
    /// * `QuoteType`: Quote type for market
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_id`: Corresponding market account ID
    /// * `side`: `ASK` or `BID`
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   base coins passing through the matching engine
    /// * `optional_quote_coins_ref_mut`: Mutable reference to optional
    ///   quote coins passing through the matching engine
    /// * `base_to_route`: If `side` is `ASK`, number of base coins to
    ///   route from `user` to `base_coins_ref_mut`, else from
    ///   `base_coins_ref_mut` to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote coins to
    ///   route from `quote_coins_ref_mut` to `user`, else from `user`
    ///   to `quote_coins_ref_mut`
    fun fill_order_route_collateral<
        BaseType,
        QuoteType
    >(
        user: address,
        market_account_id: u128,
        side: bool,
        optional_base_coins_ref_mut:
            &mut option::Option<coin::Coin<BaseType>>,
        optional_quote_coins_ref_mut:
            &mut option::Option<coin::Coin<QuoteType>>,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires Collateral {
        // Determine route direction for base and quote relative to user
        let (base_direction, quote_direction) =
            if (side == ASK) (OUT, IN) else (IN, OUT);
        // If base asset is coin type then route base coins
        if (option::is_some(optional_base_coins_ref_mut))
            fill_order_route_collateral_single<BaseType>(
                user, market_account_id,
                option::borrow_mut(optional_base_coins_ref_mut),
                base_to_route, base_direction);
        // If quote asset is coin type then route quote coins
        if (option::is_some(optional_quote_coins_ref_mut))
            fill_order_route_collateral_single<QuoteType>(
                user, market_account_id,
                option::borrow_mut(optional_quote_coins_ref_mut),
                quote_to_route, quote_direction);
    }

    /// Route `amount` of `Collateral` in `direction` either `IN` or
    /// `OUT`, relative to `user` with `market_account_id`, either
    /// from or to, respectively, coins at `external_coins_ref_mut`.
    ///
    /// Inner function for `fill_order_route_collateral()`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_id`: Corresponding market account id
    /// * `external_coins_ref_mut`: Effectively a counterparty to `user`
    /// * `amount`: Amount of coins to route
    /// * `direction`: `IN` or `OUT`
    ///
    /// # Assumes
    /// * User has a `Collateral` entry for given `market_account_id`
    ///   with range-checked coin amount for given operation: should
    ///   only be called after a user has successfully placed an order
    ///   in the first place.
    fun fill_order_route_collateral_single<CoinType>(
        user: address,
        market_account_id: u128,
        external_coins_ref_mut: &mut coin::Coin<CoinType>,
        amount: u64,
        direction: bool
    ) acquires Collateral {
        // Borrow mutable reference to user's collateral map
        let collateral_map_ref_mut =
            &mut borrow_global_mut<Collateral<CoinType>>(user).map;
        // Borrow mutable reference to user's collateral
        let collateral_ref_mut = open_table::borrow_mut(collateral_map_ref_mut,
            market_account_id);
        // If inbound collateral to user
        if (direction == IN)
            // Merge to their collateral the extracted external coins
            coin::merge(collateral_ref_mut,
                coin::extract(external_coins_ref_mut, amount)) else
            // If outbound collateral from user, merge to external coins
            // those extracted from user's collateral
            coin::merge(external_coins_ref_mut,
                coin::extract(collateral_ref_mut, amount));
    }

    /// Update a user's market account when filling an order.
    ///
    /// Inner function for `fill_order_internal()`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_id`: Corresponding market account ID
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `fill_size`: Number of lots filled
    /// * `base_to_route`: If `side` is `ASK`, number of base asset
    ///   units routed from `user`, else to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote asset
    ///   units routed to `user`, else from `user`
    ///
    /// # Assumes
    /// * User has an open order as specified: should only be called
    ///   after a user has successfully placed an order in the first
    ///   place.
    fun fill_order_update_market_account(
        user: address,
        market_account_id: u128,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        fill_size: u64,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires MarketAccounts {
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_id);
        let ( // Get mutable reference to corresponding orders tree,
            tree_ref_mut,
            asset_in, // Amount of inbound asset
            asset_in_total_ref_mut, // Inbound asset total field
            asset_in_available_ref_mut, // Available field
            asset_out, // Amount of outbound asset
            asset_out_total_ref_mut, // Outbound asset total field
            asset_out_ceiling_ref_mut, // Ceiling field
        ) = if (side == ASK) ( // If an ask is matched
            &mut market_account_ref_mut.asks,
            quote_to_route,
            &mut market_account_ref_mut.quote_total,
            &mut market_account_ref_mut.quote_available,
            base_to_route,
            &mut market_account_ref_mut.base_total,
            &mut market_account_ref_mut.base_ceiling,
        ) else ( // If a bid is matched
            &mut market_account_ref_mut.bids,
            base_to_route,
            &mut market_account_ref_mut.base_total,
            &mut market_account_ref_mut.base_available,
            quote_to_route,
            &mut market_account_ref_mut.quote_total,
            &mut market_account_ref_mut.quote_ceiling,
        );
        if (complete_fill) { // If completely filling the order
            critbit::pop(tree_ref_mut, order_id); // Pop order
        } else { // If only partially filling the order
            // Get mutable reference to size left to fill on order
            let order_size_ref_mut =
                critbit::borrow_mut(tree_ref_mut, order_id);
            // Decrement amount still unfilled
            *order_size_ref_mut = *order_size_ref_mut - fill_size;
        };
        // Increment asset in total amount by asset in amount
        *asset_in_total_ref_mut = *asset_in_total_ref_mut + asset_in;
        // Increment asset in available amount by asset in amount
        *asset_in_available_ref_mut = *asset_in_available_ref_mut + asset_in;
        // Decrement asset out total amount by asset out amount
        *asset_out_total_ref_mut = *asset_out_total_ref_mut - asset_out;
        // Decrement asset out ceiling amount by asset out amount
        *asset_out_ceiling_ref_mut = *asset_out_ceiling_ref_mut - asset_out;
    }

    /// Return `MarketAccount` asset count fields for given `user` and
    /// `market_account_id`.
    ///
    /// # Returns
    /// * `MarketAccount.base_total`
    /// * `MarketAccount.base_available`
    /// * `MarketAccount.base_ceiling`
    /// * `MarketAccount.quote_total`
    /// * `MarketAccount.quote_available`
    /// * `MarketAccount.quote_ceiling`
    ///
    /// # Restrictions
    /// * Restricted to private function to prevent excessive public
    ///   queries and thus transaction collisions
    fun get_asset_counts(
        user: address,
        market_account_id: u128
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        // Verify user has a corresponding market account
        verify_market_account_exists(user, market_account_id);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref = &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to corresponding market account
        let market_account_ref =
            open_table::borrow(market_accounts_map_ref, market_account_id);
        ( // Return asset count fields
            market_account_ref.base_total,
            market_account_ref.base_available,
            market_account_ref.base_ceiling,
            market_account_ref.quote_total,
            market_account_ref.quote_available,
            market_account_ref.quote_ceiling
        )
    }

    /// Range check proposed order
    ///
    /// # Parameters
    /// * `side:` `ASK` or `BID`
    /// * `size`: Order size, in lots
    /// * `price`: Order price, in ticks per lot
    /// * `lot_size`: Base asset units per lot
    /// * `tick_size`: Quote asset units per tick
    /// * `in_asset_ceiling`: `MarketAccount.quote_ceiling` if `side` is
    ///   `ASK`, and `MarketAccount.base_ceiling` if `side` is `BID`
    ///   (total holdings ceiling amount for asset received from trade)
    /// * `out_asset_available`: `MarketAccount.base_available` if
    ///   `side` is `ASK`, and `MarketAccount.quote_available` if `side`
    ///   is `BID` (available withdraw amount for asset traded away)
    ///
    /// # Returns
    /// * `u64`: If `side` is `ASK` quote asset units required to fill
    ///   order, else base asset units (inbound asset fill)
    /// * `u64`: If `side` is `ASK` base asset units required to fill
    ///   order, else quote asset units (outbound asset fill)
    ///
    /// # Abort conditions
    /// * If `size` is 0
    /// * If `price` is 0
    /// * If number of ticks required to fill order overflows a `u64`
    /// * If filling the order results in an overflow for incoming asset
    /// * If filling the order results in an overflow for outgoing asset
    /// * If not enough available outgoing asset to fill the order
    fun range_check_new_order(
        side: bool,
        size: u64,
        price: u64,
        lot_size: u64,
        tick_size: u64,
        in_asset_ceiling: u64,
        out_asset_available: u64
    ): (
        u64,
        u64
    ) {
        // Assert order has actual price
        assert!(size > 0, E_SIZE_0);
        // Assert order has actual size
        assert!(price > 0, E_PRICE_0);
        // Calculate base units needed to fill order
        let base_fill = (size as u128) * (lot_size as u128);
        // Calculate ticks to fill order
        let ticks = (size as u128) * (price as u128);
        // Assert ticks count can fit in a u64
        assert!(!(ticks > (HI_64 as u128)), E_TICKS_OVERFLOW);
        // Calculate quote units to fill order
        let quote_fill = ticks * (tick_size as u128);
        // If an ask, user gets quote and trades away base, else flipped
        let (in_asset_fill, out_asset_fill) = if (side == ASK)
            (quote_fill, base_fill) else (base_fill, quote_fill);
        assert!( // Assert inbound asset does not overflow
            !(in_asset_fill + (in_asset_ceiling as u128) > (HI_64 as u128)),
            E_OVERFLOW_ASSET_IN);
        // Assert outbound asset fill amount fits in a u64
        assert!(!(out_asset_fill > (HI_64 as u128)), E_OVERFLOW_ASSET_OUT);
        // Assert enough outbound asset to cover the fill
        assert!(!(out_asset_fill > (out_asset_available as u128)),
            E_NOT_ENOUGH_ASSET_AVAILABLE);
        // Return re-casted, range-checked amounts
        ((in_asset_fill as u64), (out_asset_fill as u64))
    }

    /// Register `user` with `Collateral` map entry for given `CoinType`
    /// and `market_account_id`, initializing `Collateral` if it does
    /// not already exist.
    ///
    /// # Abort conditions
    /// * If user already has a `Collateral` entry for given
    ///   `market_account_id`
    fun register_collateral_entry<
        CoinType
    >(
        user: &signer,
        market_account_id: u128,
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
        // Assert no entry exists for given market account ID
        assert!(!open_table::contains(collateral_map_ref_mut,
            market_account_id), E_EXISTS_MARKET_ACCOUNT);
        // Add an empty entry for given market account ID
        open_table::add(collateral_map_ref_mut, market_account_id,
            coin::zero<CoinType>());
    }

    /// Register user with a `MarketAccounts` map entry for given
    /// `BaseType`, `QuoteType`, and `market_account_id`, initializing
    /// `MarketAccounts` if it does not already exist
    ///
    /// # Abort conditions
    /// * If user already has a `MarketAccounts` entry for given
    ///   `market_account_id`
    fun register_market_accounts_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_account_id: u128,
    ) acquires MarketAccounts {
        // Get generic asset transfer custodian ID for verified market
        let generic_asset_transfer_custodian_id = registry::
            get_verified_market_custodian_id<BaseType, QuoteType>(
                get_market_id(market_account_id));
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
        // Assert no entry exists for given market account ID
        assert!(!open_table::contains(market_accounts_map_ref_mut,
            market_account_id), E_EXISTS_MARKET_ACCOUNT);
        // Add an empty entry for given market account ID
        open_table::add(market_accounts_map_ref_mut, market_account_id,
            MarketAccount{
                base_type_info: type_info::type_of<BaseType>(),
                quote_type_info: type_info::type_of<QuoteType>(),
                generic_asset_transfer_custodian_id,
                asks: critbit::empty(),
                bids: critbit::empty(),
                base_total: 0,
                base_available: 0,
                base_ceiling: 0,
                quote_total: 0,
                quote_available: 0,
                quote_ceiling: 0
        });
    }

    /// Verify `user` has a `MarketAccount` with `market_account_id`
    ///
    /// # Abort conditions
    /// * If `user` does not have a `MarketAccounts`
    /// * If `user` does not have a `MarketAccount` for given
    ///   `market_account_id`
    fun verify_market_account_exists(
        user: address,
        market_account_id: u128
    ) acquires MarketAccounts {
        // Assert user has a market accounts map
        assert!(exists<MarketAccounts>(user), E_NO_MARKET_ACCOUNTS);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref = &borrow_global<MarketAccounts>(user).map;
        // Assert user has an entry in map for market account ID
        assert!(open_table::contains(market_accounts_map_ref,
            market_account_id), E_NO_MARKET_ACCOUNT);
    }

    /// Withdraw `amount` of `AssetType` from `user`'s market account
    /// indicated by `market_account_id`, optionally returning coins if
    /// `asset_is_coin` is `true`, optionally verifying
    /// `generic_asset_transfer_custodian_id` in the case of withdrawing
    /// a generic asset (ignored for withdrawing coin type)
    ///
    /// # Abort conditions
    /// * If `user` has insufficient assets available for withdrawal
    /// * If unauthorized `generic_asset_transfer_custodian_id` in the
    ///   case of depositing a generic asset
    /// * If `AssetType` is not in the corresponding market pair, per
    ///   `borrow_transfer_fields_mixed()`
    fun withdraw_asset<AssetType>(
        user: address,
        market_account_id: u128,
        amount: u64,
        asset_is_coin: bool,
        generic_asset_transfer_custodian_id: u64
    ): option::Option<Coin<AssetType>>
    acquires
        Collateral,
        MarketAccounts
    {
        // Verify user has corresponding market account
        verify_market_account_exists(user, market_account_id);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
                &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total asset holdings, mutable
        // reference to amount of assets available for withdrawal,
        // mutable reference to total asset holdings ceiling, and
        // immutable reference to generic asset transfer custodian ID
        let (asset_total_ref_mut, asset_available_ref_mut,
             asset_ceiling_ref_mut, generic_asset_transfer_custodian_id_ref) =
                borrow_transfer_fields_mixed<AssetType>(
                    market_accounts_map_ref_mut, market_account_id);
        // Assert user has enough available asset to withdraw
        assert!(!(amount > *asset_available_ref_mut),
            E_NOT_ENOUGH_ASSET_AVAILABLE);
        // Decrement total asset holdings amount
        *asset_total_ref_mut = *asset_total_ref_mut - amount;
        // Decrement assets available for withdrawal amount
        *asset_available_ref_mut = *asset_available_ref_mut - amount;
        // Decrement total asset holdings ceiling amount
        *asset_ceiling_ref_mut = *asset_ceiling_ref_mut - amount;
        if (asset_is_coin) { // If asset is coin type
            // Borrow mutable reference to collateral map
            let collateral_map_ref_mut =
                &mut borrow_global_mut<Collateral<AssetType>>(user).map;
            // Borrow mutable reference to collateral for market account
            let collateral_ref_mut = open_table::borrow_mut(
                collateral_map_ref_mut, market_account_id);
            // Return coin in an option wrapper
            return option::some<Coin<AssetType>>(
                coin::extract(collateral_ref_mut, amount))
        } else { // If asset is not coin type
            // Verify indicated generic asset transfer custodian ID
            assert!(generic_asset_transfer_custodian_id ==
                *generic_asset_transfer_custodian_id_ref,
                E_UNAUTHORIZED_CUSTODIAN);
            // Return empty option wrapper
            return option::none<Coin<AssetType>>()
        }
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id` and `general_custodian_id`,
    /// returning coins
    ///
    /// # Abort conditions
    /// * If `CoinType` does not correspond to a coin
    fun withdraw_coins<CoinType>(
        user: address,
        market_id: u64,
        general_custodian_id: u64,
        amount: u64,
    ): coin::Coin<CoinType>
    acquires
        Collateral,
        MarketAccounts
    {
        // Assert type corresponds to an initialized coin
        assert!(coin::is_coin_initialized<CoinType>(), E_NOT_COIN_ASSET);
        // Get market account ID
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Withdraw corresponding amount of coins, as an option
        let option_coins = withdraw_asset<CoinType>(
            user, market_account_id, amount, true, COIN_ASSET_TRANSFER);
        option::destroy_some(option_coins) // Return extracted coins
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return asset counts of `user`'s market account for given
    /// `market_account_id`, via wrapped call to `get_asset_counts()`.
    public fun get_asset_counts_test(
        user: address,
        market_account_id: u128,
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        get_asset_counts(user, market_account_id)
    }

    #[test_only]
    /// Return `Coin.value` of `user`'s entry in `Collateral` for given
    /// `AssetType` and `market_account_id`
    public fun get_collateral_value_test<CoinType>(
        user: address,
        market_account_id: u128,
    ): u64
    acquires Collateral {
        // Borrow immutable reference to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<CoinType>>(user).map;
        // Borrow immutable reference to corresonding coin collateral
        let coin_ref = open_table::borrow(
            collateral_map_ref, market_account_id);
        coin::value(coin_ref) // Return value of coin
    }

    #[test_only]
    /// Return size of order for given `user`, `market_account_id`,
    /// `side`, and `order_id`
    ///
    /// # Assumes
    /// * `user` has an open order as specified
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions
    public fun get_order_size_test(
        user: address,
        market_account_id: u128,
        side: bool,
        order_id: u128
    ): u64
    acquires MarketAccounts {
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to market account
        let market_account_ref = open_table::borrow(market_accounts_map_ref,
            market_account_id);
        // Get immutable reference to corresponding orders tree
        let tree_ref = if (side == ASK) &market_account_ref.asks else
            &market_account_ref.bids;
        // Return order size for given order ID in tree
        *critbit::borrow(tree_ref, order_id)
    }

    #[test_only]
    /// Return `true` if `user` has an entry in `Collateral` for given
    /// `AssetType` and `market_account_id`
    public fun has_collateral_test<AssetType>(
        user: address,
        market_account_id: u128,
    ): bool
    acquires Collateral {
        // Return false if does not even have collateral map
        if (!exists<Collateral<AssetType>>(user)) return false;
        // Borrow immutable reference to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<AssetType>>(user).map;
        // Return if table contains entry for market account ID
        open_table::contains(collateral_map_ref, market_account_id)
    }

    #[test_only]
    /// Return `true` if `user` has an open order for given
    /// `market_account_id`, `side`, and `order_id`, else `false`
    ///
    /// # Assumes
    /// * `user` has a market account as specified
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions
    public fun has_order_test(
        user: address,
        market_account_id: u128,
        side: bool,
        order_id: u128
    ): bool
    acquires MarketAccounts {
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to market account
        let market_account_ref = open_table::borrow(market_accounts_map_ref,
            market_account_id);
        // Get immutable reference to corresponding orders tree
        let tree_ref = if (side == ASK) &market_account_ref.asks else
            &market_account_ref.bids;
        // Return if tree has given order
        critbit::has_key(tree_ref, order_id)
    }

    #[test_only]
    /// Register user to trade on markets initialized via
    /// `registry::register_market_internal_multiple_test`, returning
    /// corresponding market account ID for each market
    public fun register_user_with_market_accounts_test(
        econia: &signer,
        user: &signer,
        general_custodian_id_pure_generic: u64,
        general_custodian_id_pure_coin: u64
    ): (
        u128,
        u128
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Init test markets, storing market IDs
        let  (_, _, _, market_id_pure_generic,
              _, _, _, market_id_pure_coin
        ) = registry::register_market_internal_multiple_test(econia);
        // Register user for pure generic market
        register_market_account<BG, QG>(
            user, market_id_pure_generic, general_custodian_id_pure_generic);
        // Register user for pure coin market
        register_market_account<BC, QC>(
            user, market_id_pure_coin, general_custodian_id_pure_coin);
        // Declare market account IDs
        let market_account_id_pure_generic = get_market_account_id(
            market_id_pure_generic, general_custodian_id_pure_generic);
        let market_account_id_pure_coin = get_market_account_id(
            market_id_pure_coin, general_custodian_id_pure_coin);
        // Return corresponding market account IDs
        (market_account_id_pure_generic, market_account_id_pure_coin)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for asset not in pair
    fun test_borrow_transfer_fields_mixed_not_in_pair(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register user with agnostic market account
        let (market_account_id, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        borrow_transfer_fields_mixed<BC>( // Attempt invalid invocation
            market_accounts_map_ref_mut, market_account_id);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for deposit that overflows asset ceiling
    fun test_deposit_asset_overflow_ceiling(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Declare general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        // Register user with pure coin market account
        let (_, market_account_id) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, general_custodian_id);
        // Get market ID
        let market_id = get_market_id(market_account_id);
        // Deposit as many coins as possible to market account
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            assets::mint<BC>(econia, HI_64));
        // Try to deposit one more coin
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            assets::mint<BC>(econia, 1));
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify state for depositing generic and coin assets
    fun test_deposit_assets_mixed(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
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
        let market_account_id = // Declare market account ID
            get_market_account_id(market_id, general_custodian_id);
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        account::create_account_for_test(@user); // Create account
        coin::register<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            coin_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_amount, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert state
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        assert!(base_total      == generic_amount, 0);
        assert!(base_available  == generic_amount, 0);
        assert!(base_ceiling    == generic_amount, 0);
        assert!(quote_total     == coin_amount,    0);
        assert!(quote_available == coin_amount,    0);
        assert!(quote_ceiling   == coin_amount,    0);
        assert!(!has_collateral_test<BG>(@user, market_account_id), 0);
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            coin_amount, 0);
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
            500, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 14)]
    /// Verify failure for calling with unauthorized custodian
    fun test_deposit_generic_asset_unauthorized_custodian(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        assets::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initalize registry
        // Register a custodian capability
        let custodian_capability = registry::register_custodian_capability();
        // Get ID of custodian capability
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            &custodian_capability);
        // Register test market
        registry::register_market_internal<BG, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id);
        let market_id = 0; // Declare market ID
        // Declare user-level general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Get a custodian capability that is not authorized for generic
        // asset transfers
        let unauthorized_capability =
            registry::register_custodian_capability();
        // Attempt invalid invocation
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            500, &unauthorized_capability);
        // Destroy custodian capabilities
        registry::destroy_custodian_capability_test(custodian_capability);
        registry::destroy_custodian_capability_test(unauthorized_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify filling asks for a market with base coin/quote generic
    fun test_fill_order_internal_asks_base_coin_quote_generic(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Declare market parameters
        let lot_size = 10;
        let tick_size = 125;
        let generic_asset_transfer_custodian_id = 5;
        let market_id = 0;
        // Declare user-specific parameters
        let general_custodian_id = NO_CUSTODIAN;
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Declare order values
        let side = ASK;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let fill_size_1 = 5; // Partial fill
        let fill_size_2 = size - fill_size_1; // Complete fill
        let base_start = size * lot_size;
        let quote_filled_total = size * price * tick_size;
        let base_to_route_1 = fill_size_1 * lot_size;
        let base_to_route_2 = fill_size_2 * lot_size;
        let quote_to_route_1 = fill_size_1 * price * tick_size;
        let quote_to_route_2 = fill_size_2 * price * tick_size;
        let optional_base_coins = option::some<Coin<BC>>(coin::zero<BC>());
        let optional_quote_coins = option::none<Coin<QG>>();
        // Set generic asset transfer cusotdian ID as valid
        registry::set_registered_custodian_test(
            generic_asset_transfer_custodian_id);
        // Get custodian ID
        let generic_asset_transfer_custodian_capability = registry::
            get_custodian_capability_test(generic_asset_transfer_custodian_id);
        // Register mixed market
        registry::register_market_internal<BC, QG>(@econia, lot_size,
            tick_size, generic_asset_transfer_custodian_id);
        // Register user with market account for given market
        register_market_account<BC, QG>(user, market_id, general_custodian_id);
        // Deposit coin asset to user's market account
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            assets::mint(econia, base_start));
        // Register user with order
        register_order_internal(@user, market_account_id, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has base collateral deposited
        assert!(get_collateral_value_test<BC>(@user, market_account_id) ==
            base_start, 0);
        // Assert has no quote collateral structure
        assert!(!has_collateral_test<QG>(@user, market_account_id), 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == base_start, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_start, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BC, QG>(@user, market_account_id, side, order_id,
            false, fill_size_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_base_coins)) ==
            base_to_route_1, 0);
        // Assert base collateral withdrawn
        assert!(get_collateral_value_test<BC>(@user, market_account_id) ==
            base_start - base_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == base_start - base_to_route_1, 0);
        assert!(base_available  ==                            0, 0);
        assert!(base_ceiling    == base_start - base_to_route_1, 0);
        assert!(quote_total     ==             quote_to_route_1, 0);
        assert!(quote_available ==             quote_to_route_1, 0);
        assert!(quote_ceiling   ==           quote_filled_total, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size - fill_size_1, 0);
        // Execute complete fill
        fill_order_internal<BC, QG>(@user, market_account_id, side, order_id,
            true, fill_size_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_base_coins)) ==
            base_start, 0);
        assert!( // Assert all base collateral withdrawn
            get_collateral_value_test<BC>(@user, market_account_id) == 0, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_filled_total, 0);
        assert!(quote_available == quote_filled_total, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_id, side, order_id), 0);
        // Destroy optional coin structures
        assets::burn(option::destroy_some(optional_base_coins));
        option::destroy_none(optional_quote_coins);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify filling asks for a market with base generic/quote coin
    fun test_fill_order_internal_asks_base_generic_quote_coin(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Declare market parameters
        let lot_size = 10;
        let tick_size = 125;
        let generic_asset_transfer_custodian_id = 5;
        let market_id = 0;
        // Declare user-specific parameters
        let general_custodian_id = NO_CUSTODIAN;
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Declare order values
        let side = ASK;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let fill_size_1 = 5; // Partial fill
        let fill_size_2 = size - fill_size_1; // Complete fill
        let base_start = size * lot_size;
        let quote_filled_total = size * price * tick_size;
        let base_to_route_1 = fill_size_1 * lot_size;
        let base_to_route_2 = fill_size_2 * lot_size;
        let quote_to_route_1 = fill_size_1 * price * tick_size;
        let quote_to_route_2 = fill_size_2 * price * tick_size;
        let optional_base_coins = option::none<Coin<BG>>();
        let optional_quote_coins = option::some<Coin<QC>>(
            assets::mint<QC>(econia, quote_filled_total));
        // Set generic asset transfer cusotdian ID as valid
        registry::set_registered_custodian_test(
            generic_asset_transfer_custodian_id);
        // Get custodian ID
        let generic_asset_transfer_custodian_capability = registry::
            get_custodian_capability_test(generic_asset_transfer_custodian_id);
        // Register mixed market
        registry::register_market_internal<BG, QC>(@econia, lot_size,
            tick_size, generic_asset_transfer_custodian_id);
        // Register user with market account for given market
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Deposit generic asset to user's market account
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            base_start, &generic_asset_transfer_custodian_capability);
        // Register user with order
        register_order_internal(@user, market_account_id, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has no base collateral structure
        assert!(!has_collateral_test<BG>(@user, market_account_id), 0);
        assert!( // Assert has no quote collateral deposited
            get_collateral_value_test<QC>(@user, market_account_id) == 0, 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == base_start, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_start, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BG, QC>(@user, market_account_id, side, order_id,
            false, fill_size_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_filled_total - quote_to_route_1, 0);
        // Assert quote collateral deposited
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            quote_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == base_start - base_to_route_1, 0);
        assert!(base_available  ==                            0, 0);
        assert!(base_ceiling    == base_start - base_to_route_1, 0);
        assert!(quote_total     ==             quote_to_route_1, 0);
        assert!(quote_available ==             quote_to_route_1, 0);
        assert!(quote_ceiling   ==           quote_filled_total, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size - fill_size_1, 0);
        // Execute complete fill
        fill_order_internal<BG, QC>(@user, market_account_id, side, order_id,
            true, fill_size_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) == 0, 0);
        // Assert quote collateral deposited
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            quote_filled_total, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_filled_total, 0);
        assert!(quote_available == quote_filled_total, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_id, side, order_id), 0);
        // Destroy optional coin structures
        option::destroy_none(optional_base_coins);
        coin::destroy_zero(option::destroy_some(optional_quote_coins));
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify filling bids for a market with base generic/quote coin
    fun test_fill_order_internal_bids_base_generic_quote_coin(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Declare market parameters
        let lot_size = 10;
        let tick_size = 125;
        let generic_asset_transfer_custodian_id = 5;
        let market_id = 0;
        // Declare user-specific parameters
        let general_custodian_id = NO_CUSTODIAN;
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Declare order values
        let side = BID;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let fill_size_1 = 5; // Partial fill
        let fill_size_2 = size - fill_size_1; // Complete fill
        let quote_start = size * price * tick_size;
        let base_filled_total = size * lot_size;
        let base_to_route_1 = fill_size_1 * lot_size;
        let base_to_route_2 = fill_size_2 * lot_size;
        let quote_to_route_1 = fill_size_1 * price * tick_size;
        let quote_to_route_2 = fill_size_2 * price * tick_size;
        let optional_base_coins = option::none<Coin<BG>>();
        let optional_quote_coins = option::some<Coin<QC>>(coin::zero<QC>());
        // Set generic asset transfer cusotdian ID as valid
        registry::set_registered_custodian_test(
            generic_asset_transfer_custodian_id);
        // Get custodian ID
        let generic_asset_transfer_custodian_capability = registry::
            get_custodian_capability_test(generic_asset_transfer_custodian_id);
        // Register mixed market
        registry::register_market_internal<BG, QC>(@econia, lot_size,
            tick_size, generic_asset_transfer_custodian_id);
        // Register user with market account for given market
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Deposit coin asset to user's market account
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            assets::mint(econia, quote_start));
        // Register user with order
        register_order_internal(@user, market_account_id, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has no base collateral structure
        assert!(!has_collateral_test<BG>(@user, market_account_id), 0);
        // Assert has quote collateral deposited
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            quote_start, 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == quote_start, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_start, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BG, QC>(@user, market_account_id, side, order_id,
            false, fill_size_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_to_route_1, 0);
        // Assert quote collateral withdrawn
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            quote_start - quote_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == base_to_route_1, 0);
        assert!(base_available  == base_to_route_1, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == quote_start - quote_to_route_1, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_start - quote_to_route_1, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size - fill_size_1, 0);
        // Execute complete fill
        fill_order_internal<BG, QC>(@user, market_account_id, side, order_id,
            true, fill_size_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_to_route_1 + quote_to_route_2, 0);
        assert!( // Assert no more quote collateral
            get_collateral_value_test<QC>(@user, market_account_id) == 0, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert values
        assert!(base_total      == base_filled_total, 0);
        assert!(base_available  == base_filled_total, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_id, side, order_id), 0);
        // Destroy optional coin structures
        option::destroy_none(optional_base_coins);
        assets::burn(option::destroy_some(optional_quote_coins));
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify expected returns
    fun test_get_asset_counts_custodian_user_internal(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Define mock market parameters
        let market_id_pure_generic = 0;
        let market_id_pure_coin = 1;
        let general_custodian_id_pure_generic = NO_CUSTODIAN;
        let general_custodian_id_pure_coin = 1;
        let market_account_id_pure_generic = get_market_account_id(
            market_id_pure_generic, general_custodian_id_pure_generic);
        let market_account_id_pure_coin = get_market_account_id(
            market_id_pure_coin, general_custodian_id_pure_coin);
        // Define bogus asset counts
        let base_total_pure_generic      = 0;
        let base_available_pure_generic  = 1;
        let base_ceiling_pure_generic    = 2;
        let quote_total_pure_generic     = 3;
        let quote_available_pure_generic = 4;
        let quote_ceiling_pure_generic   = 5;
        let base_total_pure_coin         = 6;
        let base_available_pure_coin     = 7;
        let base_ceiling_pure_coin       = 8;
        let quote_total_pure_coin        = 9;
        let quote_available_pure_coin    = 10;
        let quote_ceiling_pure_coin      = 11;
        // Register user to trade on markets
        register_user_with_market_accounts_test(econia, user,
            general_custodian_id_pure_generic, general_custodian_id_pure_coin);
        // Get general custodian capability for pure coin market
        let general_custodian_capability_pure_coin =
            registry::get_custodian_capability_test(
                general_custodian_id_pure_coin);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to pure generic market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_id_pure_generic);
        // Set fields to mock values
        market_account_ref_mut.base_total      = base_total_pure_generic;
        market_account_ref_mut.base_available  = base_available_pure_generic;
        market_account_ref_mut.base_ceiling    = base_ceiling_pure_generic;
        market_account_ref_mut.quote_total     = quote_total_pure_generic;
        market_account_ref_mut.quote_available = quote_available_pure_generic;
        market_account_ref_mut.quote_ceiling   = quote_ceiling_pure_generic;
        // Borrow mutable reference to pure coin market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_id_pure_coin);
        // Set fields to mock values
        market_account_ref_mut.base_total      = base_total_pure_coin;
        market_account_ref_mut.base_available  = base_available_pure_coin;
        market_account_ref_mut.base_ceiling    = base_ceiling_pure_coin;
        market_account_ref_mut.quote_total     = quote_total_pure_coin;
        market_account_ref_mut.quote_available = quote_available_pure_coin;
        market_account_ref_mut.quote_ceiling   = quote_ceiling_pure_coin;
        // Get pure generic market account asset fields
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_user(user, market_id_pure_generic);
        // Assert fields
        assert!(base_total      == base_total_pure_generic, 0);
        assert!(base_available  == base_available_pure_generic, 0);
        assert!(base_ceiling    == base_ceiling_pure_generic, 0);
        assert!(quote_total     == quote_total_pure_generic, 0);
        assert!(quote_available == quote_available_pure_generic, 0);
        assert!(quote_ceiling   == quote_ceiling_pure_generic, 0);
        // Get pure coin market account asset fields
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_custodian(@user, market_id_pure_coin,
                &general_custodian_capability_pure_coin);
        // Assert fields
        assert!(base_total      == base_total_pure_coin, 0);
        assert!(base_available  == base_available_pure_coin, 0);
        assert!(base_ceiling    == base_ceiling_pure_coin, 0);
        assert!(quote_total     == quote_total_pure_coin, 0);
        assert!(quote_available == quote_available_pure_coin, 0);
        assert!(quote_ceiling   == quote_ceiling_pure_coin, 0);
        // Get pure coin market account values via internal function
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(@user, market_account_id_pure_coin);
        // Assert fields
        assert!(base_total      == base_total_pure_coin, 0);
        assert!(base_available  == base_available_pure_coin, 0);
        assert!(base_ceiling    == base_ceiling_pure_coin, 0);
        assert!(quote_total     == quote_total_pure_coin, 0);
        assert!(quote_available == quote_available_pure_coin, 0);
        assert!(quote_ceiling   == quote_ceiling_pure_coin, 0);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            general_custodian_capability_pure_coin);
    }

    #[test]
    /// Verify expected return
    fun test_get_general_custodian_id() {
        // Define market_account id (60 characters on first two lines,
        // 8 on last)
        let market_account_id = u_long(
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111100000000000000000000000000000000000000000000000000000000",
            b"10101010"
        );
        // Assert expected return
        assert!(get_general_custodian_id(market_account_id) ==
            (u(b"10101010") as u64), 0);
    }

    #[test]
    /// Verify expected return
    fun test_get_market_account_id() {
        // Declare market ID
        let market_id = (u(b"1101") as u64);
        // Declare general custodian ID
        let general_custodian_id = (u(b"1010") as u64);
        // Define expected return (60 characters on first two lines, 8
        // on last)
        let market_account_id = u_long(
            b"000000000000000000000000000000000000000000000000000000000000",
            b"110100000000000000000000000000000000000000000000000000000000",
            b"00001010"
        );
        // Assert expected return
        assert!(get_market_account_id(market_id, general_custodian_id) ==
            market_account_id, 0);
    }

    #[test]
    /// Verify expected return
    fun test_get_market_id() {
        // Define market_account id (60 characters on first two lines,
        // 8 on last)
        let market_account_id = u_long(
            b"000000000000000000000000000000000000000000000000000000001010",
            b"101011111111111111111111111111111111111111111111111111111111",
            b"11111111"
        );
        // Assert expected return
        assert!(get_market_id(market_account_id) ==
            (u(b"10101010") as u64), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify returns for both sides
    fun test_get_n_orders_order_id_nearest_spread_internal(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Declare order IDs
        let ask_id_1 = 400;
        let ask_id_2 = 500;
        let ask_id_3 = 600;
        let bid_id_1 = 100;
        let bid_id_2 = 200;
        let bid_id_3 = 300;
        // Register user with pure coin market account
        let (_, market_account_id) = register_user_with_market_accounts_test(
            econia, user, 1, NO_CUSTODIAN);
        // Deposit collateral for both sides
        deposit_coins<BC>(
            @user, 1, NO_CUSTODIAN, assets::mint<BC>(econia, 1000000));
        deposit_coins<QC>(
            @user, 1, NO_CUSTODIAN, assets::mint<QC>(econia, 1000000));
        // Assert order counts
        assert!(get_n_orders_internal(@user, market_account_id, ASK) == 0, 0);
        assert!(get_n_orders_internal(@user, market_account_id, BID) == 0, 0);
        register_order_internal( // Register order
            @user, market_account_id, ASK, ask_id_1, 1, 1, 1, 1);
        // Assert order counts
        assert!(get_n_orders_internal(@user, market_account_id, ASK) == 1, 0);
        assert!(get_n_orders_internal(@user, market_account_id, BID) == 0, 0);
        // Assert order lookup
        assert!(get_order_id_nearest_spread_internal(
            @user, market_account_id, ASK) == ask_id_1, 0);
        register_order_internal( // Register order
            @user, market_account_id, ASK, ask_id_2, 1, 1, 1, 1);
        // Assert order lookup
        assert!(get_order_id_nearest_spread_internal(
            @user, market_account_id, ASK) == ask_id_1, 0);
        register_order_internal( // Register order
            @user, market_account_id, ASK, ask_id_3, 1, 1, 1, 1);
        // Assert order lookup
        assert!(get_order_id_nearest_spread_internal(
            @user, market_account_id, ASK) == ask_id_1, 0);
        // Assert order counts
        assert!(get_n_orders_internal(@user, market_account_id, ASK) == 3, 0);
        assert!(get_n_orders_internal(@user, market_account_id, BID) == 0, 0);
        register_order_internal( // Register order
            @user, market_account_id, BID, bid_id_1, 1, 1, 1, 1);
        // Assert order lookup
        assert!(get_order_id_nearest_spread_internal(
            @user, market_account_id, BID) == bid_id_1, 0);
        register_order_internal( // Register order
            @user, market_account_id, BID, bid_id_2, 1, 1, 1, 1);
        // Assert order lookup
        assert!(get_order_id_nearest_spread_internal(
            @user, market_account_id, BID) == bid_id_2, 0);
        register_order_internal( // Register order
            @user, market_account_id, BID, bid_id_3, 1, 1, 1, 1);
        // Assert order lookup
        assert!(get_order_id_nearest_spread_internal(
            @user, market_account_id, BID) == bid_id_3, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 15)]
    /// Verify failure for no orders
    fun test_get_order_id_nearest_spread_internal_no_orders(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register user with pure coin market account
        let (_, market_account_id) = register_user_with_market_accounts_test(
            econia, user, 1, NO_CUSTODIAN);
        // Attempt invalid invocation
        get_order_id_nearest_spread_internal(@user, market_account_id, ASK);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for overflowing asset traded away
    fun test_range_check_new_order_not_enough_asset() {
        // Define order parameters
        let side = BID;
        let size = 2;
        let price = 1;
        let lot_size = 1;
        let tick_size = 1;
        let in_asset_ceiling = 1;
        let out_asset_available = 1;
        // Attempt invalid range check
        range_check_new_order(side, size, price, lot_size, tick_size,
            in_asset_ceiling, out_asset_available);
    }

    #[test]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for overflowing asset received from trade
    fun test_range_check_new_order_overflow_asset_in() {
        // Define order parameters
        let side = ASK;
        let size = 1;
        let price = 1;
        let lot_size = 1;
        let tick_size = 1;
        let in_asset_ceiling = HI_64;
        let out_asset_available = 1;
        // Attempt invalid range check
        range_check_new_order(side, size, price, lot_size, tick_size,
            in_asset_ceiling, out_asset_available);
    }

    #[test]
    #[expected_failure(abort_code = 11)]
    /// Verify failure for overflowing asset traded away
    fun test_range_check_new_order_overflow_asset_out() {
        // Define order parameters
        let side = BID;
        let size = 2;
        let price = 1;
        let lot_size = 1;
        let tick_size = HI_64;
        let in_asset_ceiling = 1;
        let out_asset_available = 1;
        // Attempt invalid range check
        range_check_new_order(side, size, price, lot_size, tick_size,
            in_asset_ceiling, out_asset_available);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for overflowing ticks required to fill trade
    fun test_range_check_new_order_overflow_ticks() {
        // Define order parameters
        let side = BID;
        let size = HI_64;
        let price = 2;
        let lot_size = 1;
        let tick_size = 1;
        let in_asset_ceiling = 1;
        let out_asset_available = 1;
        // Attempt invalid range check
        range_check_new_order(side, size, price, lot_size, tick_size,
            in_asset_ceiling, out_asset_available);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for price 0
    fun test_range_check_new_order_price_0() {
        // Define order parameters
        let side = ASK;
        let size = 1;
        let price = 0;
        let lot_size = 2;
        let tick_size = 3;
        let in_asset_ceiling = 4;
        let out_asset_available = 5;
        // Attempt invalid range check
        range_check_new_order(side, size, price, lot_size, tick_size,
            in_asset_ceiling, out_asset_available);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for size 0
    fun test_range_check_new_order_size_0() {
        // Define order parameters
        let side = ASK;
        let size = 0;
        let price = 1;
        let lot_size = 2;
        let tick_size = 3;
        let in_asset_ceiling = 4;
        let out_asset_available = 5;
        // Attempt invalid range check
        range_check_new_order(side, size, price, lot_size, tick_size,
            in_asset_ceiling, out_asset_available);
    }

    #[test]
    /// Verify successful returns
    fun test_range_check_new_order_success() {
        // Define order parameters
        let side = ASK;
        let size = 3;
        let price = 4;
        let lot_size = 5;
        let tick_size = 6;
        let in_asset_ceiling = 1000;
        let out_asset_available = 2000;
        // Range check order, store asset in and asset out fill amounts
        let (in_asset_fill, out_asset_fill) = range_check_new_order(side, size,
            price, lot_size, tick_size, in_asset_ceiling, out_asset_available);
        // Assert returns
        assert!(in_asset_fill  == size * price * tick_size, 0);
        assert!(out_asset_fill == size * lot_size         , 0);
        // Swtich side and re-evaluate
        side = BID;
        (in_asset_fill, out_asset_fill) = range_check_new_order(side, size,
            price, lot_size, tick_size, in_asset_ceiling, out_asset_available);
        assert!(in_asset_fill  == size * lot_size         , 0);
        assert!(out_asset_fill == size * price * tick_size, 0);
    }

    #[test(user = @user)]
    /// Verify registration for multiple market accounts
    fun test_register_collateral_entry(
        user: &signer
    ) acquires Collateral {
        // Declare market account IDs
        let market_account_id_1 = get_market_account_id(0, 1);
        let market_account_id_2 = get_market_account_id(0, NO_CUSTODIAN);
        // Register collateral entry
        register_collateral_entry<BC>(user, market_account_id_1);
        // Register another collateral entry
        register_collateral_entry<BC>(user, market_account_id_2);
        // Borrow immutable ref to collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<BC>>(address_of(user)).map;
        // Borrow immutable ref to collateral for first market account
        let collateral_ref_1 =
            open_table::borrow(collateral_map_ref, market_account_id_1);
        // Assert amount
        assert!(coin::value(collateral_ref_1) == 0, 0);
        // Borrow immutable ref to collateral for second market account
        let collateral_ref_2 =
            open_table::borrow(collateral_map_ref, market_account_id_2);
        // Assert amount
        assert!(coin::value(collateral_ref_2) == 0, 0);
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for given market account is already registered
    fun test_register_collateral_entry_already_registered(
        user: &signer
    ) acquires Collateral {
        // Declare market account ID
        let market_account_id = get_market_account_id(0, 1);
        // Register collateral entry
        register_collateral_entry<BC>(user, market_account_id);
        // Attempt invalid re-registration
        register_collateral_entry<BC>(user, market_account_id);
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
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register test markets
        registry::register_market_internal_multiple_test(econia);
        let agnostic_test_market_id = 0; // Declare market ID
        // Attempt invalid registration
        register_market_account<BG, QG>(
            user, agnostic_test_market_id, 1000000000);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful market account registration
    fun test_register_market_accounts(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Init test markets, storing market IDs
        let  (_, _, _, market_id_agnostic,
              _, _, _, market_id_pure_coin
        ) = registry::register_market_internal_multiple_test(econia);
        // Declare custodian IDs
        let general_custodian_id_agnostic = NO_CUSTODIAN;
        let general_custodian_id_pure_coin = 2;
        // Register corresponding market accounts
        register_market_account<BG, QG>(
            user, market_id_agnostic, general_custodian_id_agnostic);
        register_market_account<BC, QC>(
            user, market_id_pure_coin, general_custodian_id_pure_coin);
        // Get market account ID for both market accounts
        let market_account_id_agnostic = get_market_account_id(
            market_id_agnostic, general_custodian_id_agnostic);
        let market_account_id_pure_coin = get_market_account_id(
            market_id_pure_coin, general_custodian_id_pure_coin);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(@user).map;
        // Assert entries added to table
        assert!(open_table::contains(
            market_accounts_map_ref, market_account_id_agnostic), 0);
        assert!(open_table::contains(
            market_accounts_map_ref, market_account_id_pure_coin), 0);
        // Assert no initialized collateral map for generic assets
        assert!(!exists<Collateral<BG>>(@user), 0);
        assert!(!exists<Collateral<QG>>(@user), 0);
        // Borrow immutable reference to base coin collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<BC>>(@user).map;
        // Assert entry added for pure coin market account
        assert!(open_table::contains(collateral_map_ref,
            market_account_id_pure_coin), 0);
        // Borrow immutable reference to quote coin collateral map
        let collateral_map_ref =
            &borrow_global<Collateral<QC>>(@user).map;
        // Assert entry added for pure coin market account
        assert!(open_table::contains(collateral_map_ref,
            market_account_id_pure_coin), 0);
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
        // Declare market values
        let market_id_1 = 0;
        let general_custodian_id_1 = 1;
        let market_account_id_1 = get_market_account_id(market_id_1,
            general_custodian_id_1);
        let generic_asset_transfer_custodian_id_1 = PURE_COIN_PAIR;
        let market_id_2 = 0;
        let general_custodian_id_2 = NO_CUSTODIAN;
        let market_account_id_2 = get_market_account_id(market_id_2,
            general_custodian_id_2);
        let generic_asset_transfer_custodian_id_2 = PURE_COIN_PAIR;
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Set custodian to be valid
        registry::set_registered_custodian_test(general_custodian_id_1);
        // Register test markets
        registry::register_market_internal<BC, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id_1);
        registry::register_market_internal<BC, QC>(@econia, 3, 4,
            generic_asset_transfer_custodian_id_2);
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_id_1);
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_id_2);
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(address_of(user)).map;
        // Borrow immutable reference to first market account
        let market_account_ref_1 =
            open_table::borrow(market_accounts_map_ref, market_account_id_1);
        // Assert fields
        assert!(market_account_ref_1.base_type_info ==
            type_info::type_of<BC>(), 0);
        assert!(market_account_ref_1.quote_type_info ==
            type_info::type_of<QC>(), 0);
        assert!(market_account_ref_1.generic_asset_transfer_custodian_id ==
            generic_asset_transfer_custodian_id_1, 0);
        assert!(critbit::is_empty(&market_account_ref_1.asks), 0);
        assert!(critbit::is_empty(&market_account_ref_1.bids), 0);
        assert!(market_account_ref_1.base_total == 0, 0);
        assert!(market_account_ref_1.base_available == 0, 0);
        assert!(market_account_ref_1.base_ceiling == 0, 0);
        assert!(market_account_ref_1.quote_total == 0, 0);
        assert!(market_account_ref_1.quote_available == 0, 0);
        assert!(market_account_ref_1.quote_ceiling == 0, 0);
        // Borrow immutable reference to second market account
        let market_account_ref_2 =
            open_table::borrow(market_accounts_map_ref, market_account_id_2);
        // Assert fields
        assert!(market_account_ref_2.base_type_info ==
            type_info::type_of<BC>(), 0);
        assert!(market_account_ref_2.quote_type_info ==
            type_info::type_of<QC>(), 0);
        assert!(market_account_ref_2.generic_asset_transfer_custodian_id ==
            generic_asset_transfer_custodian_id_2, 0);
        assert!(critbit::is_empty(&market_account_ref_2.asks), 0);
        assert!(critbit::is_empty(&market_account_ref_2.bids), 0);
        assert!(market_account_ref_2.base_total == 0, 0);
        assert!(market_account_ref_2.base_available == 0, 0);
        assert!(market_account_ref_2.base_ceiling == 0, 0);
        assert!(market_account_ref_2.quote_total == 0, 0);
        assert!(market_account_ref_2.quote_available == 0, 0);
        assert!(market_account_ref_2.quote_ceiling == 0, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for attempting to re-register market account
    fun test_register_market_accounts_entry_already_registered(
        econia: &signer,
        user: &signer
    ) acquires MarketAccounts {
        // Declare market values
        let market_id_1 = 0;
        let general_custodian_id_1 = 1;
        let market_account_id_1 = get_market_account_id(market_id_1,
            general_custodian_id_1);
        let generic_asset_transfer_custodian_id_1 = PURE_COIN_PAIR;
        // Initialize registry
        registry::init_registry(econia);
        // Initialize coin types
        assets::init_coin_types(econia);
        // Set custodian to be valid
        registry::set_registered_custodian_test(general_custodian_id_1);
        // Register test markets
        registry::register_market_internal<BC, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id_1);
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_id_1);
        // Register market accounts entry
        register_market_accounts_entry<BC, QC>(user, market_account_id_1);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify adding an ask, then removing it
    fun test_register_remove_order_internal_ask(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register a pure coin market for trading
        let (_, _, _, _, lot_size, tick_size, _, market_id) =
            registry::register_market_internal_multiple_test(econia);
        // Declare user-specific general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        // Declare order parameters
        let side = ASK;
        let counter = 123;
        let price = 456;
        let order_id = order_id::order_id(price, counter, side);
        let size = 789;
        let base_required = lot_size * size;
        let quote_received = size * price * tick_size;
        // Register user with a market account for given market
        register_market_account<BC, QC>(user, market_id, general_custodian_id);
        // Get market account ID
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Deposit enough base coins to cover the ask
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            assets::mint<BC>(econia, base_required));
        // Register user's market account with given order
        register_order_internal(@user, market_account_id, side, order_id,
            size, price, lot_size, tick_size);
        // Get asset counts
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert asset counts
        assert!(base_total      ==  base_required, 0);
        assert!(base_available  ==              0, 0);
        assert!(base_ceiling    ==  base_required, 0);
        assert!(quote_total     ==              0, 0);
        assert!(quote_available ==              0, 0);
        assert!(quote_ceiling   == quote_received, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size, 0);
        // Remove the order from the user's market account
        remove_order_internal(@user, market_account_id, lot_size, tick_size,
            side, order_id);
        // Get asset counts
        ( base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert asset counts
        assert!(base_total      == base_required, 0);
        assert!(base_available  == base_required, 0);
        assert!(base_ceiling    == base_required, 0);
        assert!(quote_total     ==             0, 0);
        assert!(quote_available ==             0, 0);
        assert!(quote_ceiling   ==             0, 0);
        assert!( // Assert user no longer has order in market account
            !has_order_test(@user, market_account_id, side, order_id), 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify adding a bid, then removing it
    fun test_register_remove_order_internal_bid(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register a pure coin market for trading
        let (_, _, _, _, lot_size, tick_size, _, market_id) =
            registry::register_market_internal_multiple_test(econia);
        // Declare user-specific general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        // Declare order parameters
        let side = BID;
        let counter = 123;
        let price = 456;
        let order_id = order_id::order_id(price, counter, side);
        let size = 789;
        let base_received = lot_size * size;
        let quote_required = size * price * tick_size;
        // Register user with a market account for given market
        register_market_account<BC, QC>(user, market_id, general_custodian_id);
        // Get market account ID
        let market_account_id = get_market_account_id(market_id,
            general_custodian_id);
        // Deposit enough quote coins to cover the bid
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            assets::mint<QC>(econia, quote_required));
        // Register user's market account with given order
        register_order_internal(@user, market_account_id, side, order_id,
            size, price, lot_size, tick_size);
        // Get asset counts
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert asset counts
        assert!(base_total      ==              0, 0);
        assert!(base_available  ==              0, 0);
        assert!(base_ceiling    ==  base_received, 0);
        assert!(quote_total     == quote_required, 0);
        assert!(quote_available ==              0, 0);
        assert!(quote_ceiling   == quote_required, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_id, side, order_id)
            == size, 0);
        // Remove the order from the user's market account
        remove_order_internal(@user, market_account_id, lot_size, tick_size,
            side, order_id);
        // Get asset counts
        ( base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_account_id);
        // Assert asset counts
        assert!(base_total      ==              0, 0);
        assert!(base_available  ==              0, 0);
        assert!(base_ceiling    ==              0, 0);
        assert!(quote_total     == quote_required, 0);
        assert!(quote_available == quote_required, 0);
        assert!(quote_ceiling   == quote_required, 0);
        assert!( // Assert user no longer has order in market account
            !has_order_test(@user, market_account_id, side, order_id), 0);
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no market accounts
    fun test_verify_market_account_exists_no_market_accounts()
    acquires MarketAccounts {
        // Attempt invalid invocation
        verify_market_account_exists(@user, get_market_account_id(1, 2));
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
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register user with pure generic market account
        let (market_account_id, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        // Attempt invalid existence verification
        verify_market_account_exists(@user, market_account_id + 1);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for attempting to withdraw more than available
    fun test_withdraw_asset_not_enough_asset_available(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register user to trade on generic asset market
        let (market_account_id, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        let empty_option = // Attempt invalid invocation
            withdraw_asset<BG>(@user, market_account_id, 1, false, 1);
        option::destroy_none(empty_option); // Destroy empty result
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify state for withdrawing generic and coin assets
    fun test_withdraw_assets_mixed(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
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
        let market_account_id =  // Declare market account ID
            get_market_account_id(market_id, general_custodian_id);
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        account::create_account_for_test(@user); // Create account
        coin::register<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_deposit_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            coin_deposit_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_deposit_amount, &custodian_capability);
        // Withdraw coin asset to coinstore
        withdraw_to_coinstore<QC>(user, market_id, coin_withdrawal_amount);
        // Withdraw generic asset
        withdraw_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_withdrawal_amount, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert state
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        assert!(base_total      == generic_end_amount, 0);
        assert!(base_available  == generic_end_amount, 0);
        assert!(base_ceiling    == generic_end_amount, 0);
        assert!(quote_total     == coin_end_amount,    0);
        assert!(quote_available == coin_end_amount,    0);
        assert!(quote_ceiling   == coin_end_amount,    0);
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            coin_end_amount, 0);
        assert!(coin::balance<QC>(@user) == coinstore_end_amount, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful withdrawal
    fun test_withdraw_coins_custodian_success(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Declare user-specific general custodian ID
        let general_custodian_id = 3;
        // Declare asset count deposit parameters
        let coin_deposit_amount = 700;
        let coin_withdrawal_amount = 600;
        let coin_end_amount = coin_deposit_amount - coin_withdrawal_amount;
        // Register user to trade on pure coin market
        let (_, market_account_id) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, general_custodian_id);
        // Extract market ID
        let market_id = get_market_id(market_account_id);
        // Get custodian capability
        let custodian_capability =
            registry::get_custodian_capability_test(general_custodian_id);
        // Deposit coins to market account
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            assets::mint<QC>(econia, coin_deposit_amount));
        // Withdraw from market account
        let coins = withdraw_coins_custodian<QC>(@user, market_id,
            coin_withdrawal_amount, &custodian_capability);
        // Assert raw coin value
        assert!(coin::value(&coins) == coin_withdrawal_amount, 0);
        // Assert market account state
        let (_, _, _, quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        assert!(quote_total     == coin_end_amount, 0);
        assert!(quote_available == coin_end_amount, 0);
        assert!(quote_ceiling   == coin_end_amount, 0);
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            coin_end_amount, 0);
        // Destroy resources
        registry::destroy_custodian_capability_test(custodian_capability);
        assets::burn(coins);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful withdrawal
    fun test_withdraw_coins_internal_success(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Declare user-specific general custodian ID
        let general_custodian_id = 3;
        // Declare asset count deposit parameters
        let coin_deposit_amount = 700;
        let coin_withdrawal_amount = 600;
        let coin_end_amount = coin_deposit_amount - coin_withdrawal_amount;
        // Register user to trade on pure coin market
        let (_, market_account_id) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, general_custodian_id);
        // Extract market ID
        let market_id = get_market_id(market_account_id);
        // Get custodian capability
        let custodian_capability =
            registry::get_custodian_capability_test(general_custodian_id);
        // Deposit coins to market account
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            assets::mint<QC>(econia, coin_deposit_amount));
        // Withdraw from market account
        let option_coins = withdraw_coins_as_option_internal<QC>(@user,
            market_account_id, coin_withdrawal_amount);
        // Assert coin value
        assert!(coin::value(option::borrow(&option_coins)) ==
            coin_withdrawal_amount, 0);
        // Assert market account state
        let (_, _, _, quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        assert!(quote_total     == coin_end_amount, 0);
        assert!(quote_available == coin_end_amount, 0);
        assert!(quote_ceiling   == coin_end_amount, 0);
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            coin_end_amount, 0);
        // Destroy resources
        registry::destroy_custodian_capability_test(custodian_capability);
        assets::burn(option::destroy_some(option_coins));
    }

    #[test]
    #[expected_failure(abort_code = 13)]
    /// Verify failure for not a coin asset type
    fun test_withdraw_coins_not_coins()
    acquires
        Collateral,
        MarketAccounts
    {
        // Attempt invalid invocation, burning result
        assets::burn(withdraw_coins<BG>(@user, 1, 1, 1));
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify state for withdrawing, depositing generic and coin assets
    fun test_withdraw_deposit_asset_as_option_internal_mixed(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Declare asset count deposit parameters
        let coin_deposit_amount = 700;
        let generic_deposit_amount = 500;
        let coin_withdrawal_amount = 600;
        let generic_withdrawal_amount = generic_deposit_amount;
        let coin_end_amount = coin_deposit_amount - coin_withdrawal_amount;
        let generic_end_amount = 0;
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
        let market_account_id =  // Declare market account ID
            get_market_account_id(market_id, general_custodian_id);
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        account::create_account_for_test(@user); // Create account
        coin::register<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_deposit_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            coin_deposit_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_deposit_amount, &custodian_capability);
        // Withdraw base/coin assets as option
        let (generic_as_option, coin_as_option) =
            withdraw_assets_as_option_internal<BG, QC>(
                @user, market_account_id, generic_withdrawal_amount,
                coin_withdrawal_amount, generic_asset_transfer_custodian_id);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert market account asset counts
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        assert!(base_total      == generic_end_amount, 0);
        assert!(base_available  == generic_end_amount, 0);
        assert!(base_ceiling    == generic_end_amount, 0);
        assert!(quote_total     == coin_end_amount,    0);
        assert!(quote_available == coin_end_amount,    0);
        assert!(quote_ceiling   == coin_end_amount,    0);
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            coin_end_amount, 0);
        // Assert generic asset option is none
        assert!(option::is_none(&generic_as_option), 0);
        // Assert coin value is as expected
        assert!(coin::value(option::borrow(&coin_as_option)) ==
            coin_withdrawal_amount, 0);
        // Deposit both withdrawn assets back to user's market account
        deposit_assets_as_option_internal<BG, QC>(@user, market_account_id,
            generic_withdrawal_amount, coin_withdrawal_amount,
            generic_as_option, coin_as_option,
            generic_asset_transfer_custodian_id);
        // Assert market account asset counts
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_account_id);
        assert!(base_total      == generic_deposit_amount, 0);
        assert!(base_available  == generic_deposit_amount, 0);
        assert!(base_ceiling    == generic_deposit_amount, 0);
        assert!(quote_total     == coin_deposit_amount,    0);
        assert!(quote_available == coin_deposit_amount,    0);
        assert!(quote_ceiling   == coin_deposit_amount,    0);
        assert!(get_collateral_value_test<QC>(@user, market_account_id) ==
            coin_deposit_amount, 0);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 12)]
    /// Verify failure for coin type
    fun test_withdraw_generic_asset_not_generic(
        econia: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        assets::init_coin_types(econia); // Initialize coin types
        // Get mock custodian capability
        let custodian_capability = registry::get_custodian_capability_test(1);
        // Attempt invalid invocation
        withdraw_generic_asset<BC>(@user, 1, 2, 3, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 14)]
    /// Verify failure for unauthorized custodian
    fun test_withdraw_generic_asset_unauthorized_custodian(
        econia: &signer,
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        assets::init_coin_types(econia); // Initialize coin types
        registry::init_registry(econia); // Initalize registry
        // Register a custodian capability
        let custodian_capability = registry::register_custodian_capability();
        // Get ID of custodian capability
        let generic_asset_transfer_custodian_id = registry::custodian_id(
            &custodian_capability);
        // Register test market
        registry::register_market_internal<BG, QC>(@econia, 1, 2,
            generic_asset_transfer_custodian_id);
        let market_id = 0; // Declare market ID
        // Declare user-level general custodian ID
        let general_custodian_id = NO_CUSTODIAN;
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        // Deposit to the account
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            500, &custodian_capability);
        // Get a custodian capability that is not authorized for generic
        // asset transfers
        let unauthorized_capability =
            registry::register_custodian_capability();
        // Attempt invalid invocation
        withdraw_generic_asset<BG>(@user, market_id, general_custodian_id,
            500, &unauthorized_capability);
        // Destroy custodian capabilities
        registry::destroy_custodian_capability_test(custodian_capability);
        registry::destroy_custodian_capability_test(unauthorized_capability);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}