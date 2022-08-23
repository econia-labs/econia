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
        /// Amount `base_total` will increase to if all open bids fill
        base_ceiling: u64,
        /// Total quote asset units held as collateral
        quote_total: u64,
        /// Quote asset units available for withdraw
        quote_available: u64,
        /// Amount `quote_total` will increase to if all open asks fill
        quote_ceiling: u64
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

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag for asks side
    const ASK: bool = true;
    /// Flag for asks side
    const BID: bool = false;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Flag for inbound coins
    const IN: bool = true;
    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;
    /// Flag for outbound coins
    const OUT: bool = false;

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
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_asset<CoinType>(
            user,
            MarketAccountInfo{market_id, general_custodian_id,
                generic_asset_transfer_custodian_id},
            coin::value(&coins),
            option::some(coins)
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
            MarketAccountInfo{market_id, general_custodian_id,
                generic_asset_transfer_custodian_id},
            amount,
            option::none<Coin<AssetType>>()
        )
    }

    /// Return a `MarketAccountInfo` having `market_id`,
    /// `general_custodian_id`, and
    /// `generic_asset_transfer_custodian_id`
    public fun get_market_account_info(
        market_id: u64,
        general_custodian_id: u64,
        generic_asset_transfer_custodian_id: u64
    ): MarketAccountInfo {
        MarketAccountInfo{
            market_id,
            general_custodian_id,
            generic_asset_transfer_custodian_id
        }
    }

    /// Return `market_account_info` fields
    ///
    /// # Returns
    /// * `u64`: `MarketAccountInfo.market_id`
    /// * `u64`: `MarketAccountInfo.general_custodian_id`
    /// * `u64`: `MarketAccountInfo.generic_asset_transfer_custodian_id`
    public fun get_market_account_info_fields(
        market_account_info: MarketAccountInfo
    ): (
        u64,
        u64,
        u64
    ) {
        (
            market_account_info.market_id,
            market_account_info.general_custodian_id,
            market_account_info.generic_asset_transfer_custodian_id
        )
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id`, and
    /// `generic_asset_transfer_custodian_id`, under authority of
    /// custodian indicated by `general_custodian_capability_ref`
    ///
    /// See wrapped function `withdraw_coins()`
    public fun withdraw_coins_custodian<CoinType>(
        user: address,
        market_id: u64,
        generic_asset_transfer_custodian_id: u64,
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
            generic_asset_transfer_custodian_id,
            amount
        )
    }

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account having `market_id` and
    /// `generic_asset_transfer_custodian_id` but no general custodian,
    /// returning coins
    ///
    /// See wrapped function `withdraw_coins()`
    public fun withdraw_coins_user<CoinType>(
        user: &signer,
        market_id: u64,
        generic_asset_transfer_custodian_id: u64,
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
            generic_asset_transfer_custodian_id,
            amount
        )
    }

    /// Withdraw `amount` of non-coin assets of `AssetType` from
    /// `user`'s market account having `market_id` and
    /// `general_custodian_id`, under authority of custodian indicated
    /// by `generic_asset_transfer_custodian_capability_ref`
    ///
    /// See wrapped function `withdraw_asset()`
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
    /// market account having `market_id` and
    /// `generic_asset_transfer_custodian_id` but no general custodian
    ///
    /// See wrapped function `withdraw_coins_user()`
    public entry fun withdraw_to_coinstore<CoinType>(
        user: &signer,
        market_id: u64,
        generic_asset_transfer_custodian_id: u64,
        amount: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Withdraw coins from user's market account
        let coins = withdraw_coins_user<CoinType>(user, market_id,
            generic_asset_transfer_custodian_id, amount);
        // Deposit coins to user's coin store
        coin::deposit<CoinType>(address_of(user), coins);
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `size_filled`: Number of lots filled
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
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        size_filled: u64,
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
        fill_order_update_market_account(user, market_account_info, side,
            order_id, complete_fill, size_filled, base_to_route,
            quote_to_route);
        // Route collateral accordingly, as needed
        fill_order_route_collateral<BaseType, QuoteType>(user,
            market_account_info, side, optional_base_coins_ref_mut,
            optional_quote_coins_ref_mut, base_to_route, quote_to_route);
    }

    /// Register a new order under a user's market account
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side:` `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `size`: Size of order in lots
    /// * `price`: Price of order in ticks per lot
    /// * `lot_size`: Base asset units per lot
    /// * `tick_size`: Quote asset units per tick
    public(friend) fun register_order_internal(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128,
        size: u64,
        price: u64,
        lot_size: u64,
        tick_size: u64,
    ) acquires MarketAccounts {
        // Verify user has a corresponding market account
        verify_market_account_exists(user, market_account_info);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to corresponding market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_info);
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
    /// * `market_accont_info`: `MarketAccountInfo` for corresponding
    ///   market account
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
        market_account_info: MarketAccountInfo,
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
            market_accounts_map_ref_mut, market_account_info);
        // Get mutable reference to corresponding tree, mutable
        // reference to corresponding assets available field, mutable
        // reference to corresponding asset ceiling fields, available
        // size multiplier, and ceiling size multipler, based on side
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

    /// Withdraw `amount` of coins of `CoinType` from `user`'s market
    /// account indicated by `market_account_info`, returning them
    /// wrapped in an option
    public(friend) fun withdraw_coins_as_option_internal<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64
    ): option::Option<Coin<CoinType>>
    acquires
        Collateral,
        MarketAccounts
    {
        withdraw_asset<CoinType>(user, market_account_info, amount, true)
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
    /// * `u64`: Mutable reference to `MarketAccount.base_ceiling` for
    ///   corresponding market account if `AssetType` is market base,
    ///   else mutable reference to `MarketAccount.quote_ceiling`
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
                &mut market_account_ref_mut.base_available,
                &mut market_account_ref_mut.base_ceiling,
            )
        // If is quote asset, return mutable references to quote fields
        } else if (asset_type_info == market_account_ref_mut.quote_type_info) {
            return (
                &mut market_account_ref_mut.quote_total,
                &mut market_account_ref_mut.quote_available,
                &mut market_account_ref_mut.quote_ceiling
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
    /// * If deposit would overflow the total asset holdings ceiling
    fun deposit_asset<AssetType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64,
        optional_coins: option::Option<Coin<AssetType>>
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Verify user has corresponding market account
        verify_market_account_exists(user, market_account_info);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total asset holdings, mutable
        // reference to amount of assets available for withdrawal,
        // and mutable reference to total asset holdings ceiling
        let (asset_total_ref_mut, asset_available_ref_mut,
             asset_ceiling_ref_mut) = borrow_asset_counts_mut<AssetType>(
                market_accounts_map_ref_mut, market_account_info);
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
                collateral_map_ref_mut, market_account_info);
            coin::merge( // Merge optional coins into collateral
                collateral_ref_mut, option::destroy_some(optional_coins));
        } else { // If asset is not coin type
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
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
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
        market_account_info: MarketAccountInfo,
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
                user, market_account_info,
                option::borrow_mut(optional_base_coins_ref_mut),
                base_to_route, base_direction);
        // If quote asset is coin type then route quote coins
        if (option::is_some(optional_quote_coins_ref_mut))
            fill_order_route_collateral_single<QuoteType>(
                user, market_account_info,
                option::borrow_mut(optional_quote_coins_ref_mut),
                quote_to_route, quote_direction);
    }

    /// Route `amount` of `Collateral` in `direction` either `IN` or
    /// `OUT`, relative to `user` with `market_account_info`, either
    /// from or to, respectively, coins at `external_coins_ref_mut`.
    ///
    /// Inner function for `fill_order_route_collateral()`.
    ///
    /// # Assumes
    /// * User has a `Collateral` entry for given `market_account_info`
    ///   with range-checked coin amount for given operation: should
    ///   only be called after a user has successfully placed an order
    ///   in the first place.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `external_coins_ref_mut`: Effectively a counterparty to `user`
    /// * `amount`: Amount of coins to route
    /// * `direction`: `IN` or `OUT`
    fun fill_order_route_collateral_single<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        external_coins_ref_mut: &mut coin::Coin<CoinType>,
        amount: u64,
        direction: bool
    ) acquires Collateral {
        // Borrow mutable reference to user's collateral map
        let collateral_map_ref_mut =
            &mut borrow_global_mut<Collateral<CoinType>>(user).map;
        // Borrow mutable reference to user's collateral
        let collateral_ref_mut = open_table::borrow_mut(collateral_map_ref_mut,
            market_account_info);
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
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `size_filled`: Number of lots filled
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
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        size_filled: u64,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires MarketAccounts {
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to market account
        let market_account_ref_mut = open_table::borrow_mut(
            market_accounts_map_ref_mut, market_account_info);
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
            *order_size_ref_mut = *order_size_ref_mut - size_filled;
        };
        // Update asset counts for incoming and outgoing assets
        *asset_in_total_ref_mut     = *asset_in_total_ref_mut     + asset_in;
        *asset_in_available_ref_mut = *asset_in_available_ref_mut + asset_in;
        *asset_out_total_ref_mut    = *asset_out_total_ref_mut    - asset_out;
        *asset_out_ceiling_ref_mut  = *asset_out_ceiling_ref_mut  - asset_out;
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
                base_ceiling: 0,
                quote_total: 0,
                quote_available: 0,
                quote_ceiling: 0
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
    acquires
        Collateral,
        MarketAccounts
    {
        // Verify user has corresponding market account
        verify_market_account_exists(user, market_account_info);
        // Borrow mutable reference to market accounts map
        let market_accounts_map_ref_mut =
                &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total asset holdings, mutable
        // reference to amount of assets available for withdrawal,
        // and mutable reference to total asset holdings ceiling
        let (asset_total_ref_mut, asset_available_ref_mut,
             asset_ceiling_ref_mut) = borrow_asset_counts_mut<AssetType>(
                market_accounts_map_ref_mut, market_account_info);
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
    acquires
        Collateral,
        MarketAccounts
    {
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
    /// Return asset counts of `user`'s market account for given
    /// `market_id` and `general_custodian_id`
    public fun get_asset_counts_test(
        user: address,
        market_id: u64,
        general_custodian_id: u64
    ): (
        u64,
        u64,
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
            market_account_ref.base_ceiling,
            market_account_ref.quote_total,
            market_account_ref.quote_available,
            market_account_ref.quote_ceiling,
        )
    }

    #[test_only]
    /// Return `Coin.value` of `user`'s entry in `Collateral` for given
    /// `AssetType`, `market_id`, and `general_custodian_id`
    public fun get_collateral_value_test<CoinType>(
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
    public fun get_market_account_info_test(
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
    /// Return `true` if `user` has an open order for given
    /// `market_account_info`, `side`, and `order_id`, else `false`
    ///
    /// # Assumes
    /// * `user` has a market account as specified
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions
    public fun has_order_test(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128
    ): bool
    acquires MarketAccounts {
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to market account
        let market_account_ref = open_table::borrow(market_accounts_map_ref,
            market_account_info);
        // Get immutable reference to corresponding orders tree
        let tree_ref = if (side == ASK) &market_account_ref.asks else
            &market_account_ref.bids;
        // Return if tree has given order
        critbit::has_key(tree_ref, order_id)
    }

    #[test_only]
    /// Return size of order for given `user`, `market_account_info`,
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
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128
    ): u64
    acquires MarketAccounts {
        // Borrow immutable reference to market accounts map
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to market account
        let market_account_ref = open_table::borrow(market_accounts_map_ref,
            market_account_info);
        // Get immutable reference to corresponding orders tree
        let tree_ref = if (side == ASK) &market_account_ref.asks else
            &market_account_ref.bids;
        // Return order size for given order ID in tree
        *critbit::borrow(tree_ref, order_id)
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        coin::register_for_test<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, coin_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_amount, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert state
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_id, general_custodian_id);
        assert!(base_total      == generic_amount, 0);
        assert!(base_available  == generic_amount, 0);
        assert!(base_ceiling    == generic_amount, 0);
        assert!(quote_total     == coin_amount,    0);
        assert!(quote_available == coin_amount,    0);
        assert!(quote_ceiling   == coin_amount,    0);
        assert!(!has_collateral_test<BG>(
            @user, market_id, general_custodian_id), 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == coin_amount, 0);
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
        let (_, market_account_info) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, general_custodian_id);
        // Get market account info fields
        let (market_id, _, generic_asset_transfer_custodian_id) =
            get_market_account_info_fields(market_account_info);
        // Deposit as many coins as possible to market account
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint<BC>(econia, HI_64));
        // Try to deposit one more coin
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, assets::mint<BC>(econia, 1));
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
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Declare order values
        let side = ASK;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let size_filled_1 = 5; // Partial fill
        let size_filled_2 = size - size_filled_1; // Complete fill
        let base_start = size * lot_size;
        let quote_filled_total = size * price * tick_size;
        let base_to_route_1 = size_filled_1 * lot_size;
        let base_to_route_2 = size_filled_2 * lot_size;
        let quote_to_route_1 = size_filled_1 * price * tick_size;
        let quote_to_route_2 = size_filled_2 * price * tick_size;
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
            generic_asset_transfer_custodian_id,
            assets::mint(econia, base_start));
        // Register user with order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has base collateral deposited
        assert!(get_collateral_value_test<BC>(
            @user, market_id, general_custodian_id) == base_start, 0);
        // Assert has no quote collateral structure
        assert!(!has_collateral_test<QG>(
            @user, market_id, general_custodian_id), 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_start, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BC, QG>(@user, market_account_info, side, order_id,
            false, size_filled_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_base_coins)) ==
            base_to_route_1, 0);
        // Assert base collateral withdrawn
        assert!(get_collateral_value_test<BC>(
            @user, market_id, general_custodian_id) ==
            base_start - base_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start - base_to_route_1, 0);
        assert!(base_available  ==                            0, 0);
        assert!(base_ceiling    == base_start - base_to_route_1, 0);
        assert!(quote_total     ==             quote_to_route_1, 0);
        assert!(quote_available ==             quote_to_route_1, 0);
        assert!(quote_ceiling   ==           quote_filled_total, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size - size_filled_1, 0);
        // Execute complete fill
        fill_order_internal<BC, QG>(@user, market_account_info, side, order_id,
            true, size_filled_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_base_coins)) ==
            base_start, 0);
        // Assert all base collateral withdrawn
        assert!(get_collateral_value_test<BC>(
            @user, market_id, general_custodian_id) == 0, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_filled_total, 0);
        assert!(quote_available == quote_filled_total, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_info, side, order_id), 0);
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
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Declare order values
        let side = ASK;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let size_filled_1 = 5; // Partial fill
        let size_filled_2 = size - size_filled_1; // Complete fill
        let base_start = size * lot_size;
        let quote_filled_total = size * price * tick_size;
        let base_to_route_1 = size_filled_1 * lot_size;
        let base_to_route_2 = size_filled_2 * lot_size;
        let quote_to_route_1 = size_filled_1 * price * tick_size;
        let quote_to_route_2 = size_filled_2 * price * tick_size;
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
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has no base collateral structure
        assert!(!has_collateral_test<BG>(
            @user, market_id, general_custodian_id), 0);
        // Assert has no quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == 0, 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_start, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            false, size_filled_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_filled_total - quote_to_route_1, 0);
        // Assert quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == quote_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_start - base_to_route_1, 0);
        assert!(base_available  ==                            0, 0);
        assert!(base_ceiling    == base_start - base_to_route_1, 0);
        assert!(quote_total     ==             quote_to_route_1, 0);
        assert!(quote_available ==             quote_to_route_1, 0);
        assert!(quote_ceiling   ==           quote_filled_total, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size - size_filled_1, 0);
        // Execute complete fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            true, size_filled_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) == 0, 0);
        // Assert quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == quote_filled_total, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == 0, 0);
        assert!(quote_total     == quote_filled_total, 0);
        assert!(quote_available == quote_filled_total, 0);
        assert!(quote_ceiling   == quote_filled_total, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_info, side, order_id), 0);
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
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Declare order values
        let side = BID;
        let size = 123;
        let price = 456;
        let counter = 0;
        let order_id = order_id::order_id(price, counter, side);
        // Declare fill values
        let size_filled_1 = 5; // Partial fill
        let size_filled_2 = size - size_filled_1; // Complete fill
        let quote_start = size * price * tick_size;
        let base_filled_total = size * lot_size;
        let base_to_route_1 = size_filled_1 * lot_size;
        let base_to_route_2 = size_filled_2 * lot_size;
        let quote_to_route_1 = size_filled_1 * price * tick_size;
        let quote_to_route_2 = size_filled_2 * price * tick_size;
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
            generic_asset_transfer_custodian_id,
            assets::mint(econia, quote_start));
        // Register user with order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Assert has no base collateral structure
        assert!(!has_collateral_test<BG>(
            @user, market_id, general_custodian_id), 0);
        // Assert has quote collateral deposited
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == quote_start, 0);
        // Get asset counts
        let (base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == 0, 0);
        assert!(base_available  == 0, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == quote_start, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_start, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Execute partial fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            false, size_filled_1, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_1, quote_to_route_1);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_to_route_1, 0);
        // Assert quote collateral withdrawn
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) ==
            quote_start - quote_to_route_1, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_to_route_1, 0);
        assert!(base_available  == base_to_route_1, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == quote_start - quote_to_route_1, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == quote_start - quote_to_route_1, 0);
        // Assert order size update
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size - size_filled_1, 0);
        // Execute complete fill
        fill_order_internal<BG, QC>(@user, market_account_info, side, order_id,
            true, size_filled_2, &mut optional_base_coins,
            &mut optional_quote_coins, base_to_route_2, quote_to_route_2);
        // Assert optional coin count
        assert!(coin::value(option::borrow(&optional_quote_coins)) ==
            quote_to_route_1 + quote_to_route_2, 0);
        // Assert no more quote collateral
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == 0, 0);
        // Get asset counts
        (base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert values
        assert!(base_total      == base_filled_total, 0);
        assert!(base_available  == base_filled_total, 0);
        assert!(base_ceiling    == base_filled_total, 0);
        assert!(quote_total     == 0, 0);
        assert!(quote_available == 0, 0);
        assert!(quote_ceiling   == 0, 0);
        assert!( // Assert order removed from tree
            !has_order_test(@user, market_account_info, side, order_id), 0);
        // Destroy optional coin structures
        option::destroy_none(optional_base_coins);
        assets::burn(option::destroy_some(optional_quote_coins));
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(
            generic_asset_transfer_custodian_capability)
    }

    #[test]
    /// Verify packed successfuly
    fun test_get_market_account_info() {
        // Declare fields
        let market_id = 123;
        let general_custodian_id = 456;
        let generic_asset_transfer_custodian_id = 789;
        // Pack struct
        let market_account_info = get_market_account_info(
            market_id, general_custodian_id,
            generic_asset_transfer_custodian_id);
        // Assert fields
        assert!(market_account_info.market_id == market_id, 0);
        assert!(market_account_info.general_custodian_id ==
            general_custodian_id, 0);
        assert!(market_account_info.generic_asset_transfer_custodian_id ==
            generic_asset_transfer_custodian_id, 0);
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
        assert!(market_account_ref_1.base_ceiling == 0, 0);
        assert!(market_account_ref_1.quote_total == 0, 0);
        assert!(market_account_ref_1.quote_available == 0, 0);
        assert!(market_account_ref_1.quote_ceiling == 0, 0);
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
        assert!(market_account_ref_2.base_ceiling == 0, 0);
        assert!(market_account_ref_2.quote_total == 0, 0);
        assert!(market_account_ref_2.quote_available == 0, 0);
        assert!(market_account_ref_2.quote_ceiling == 0, 0);
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
        let (_, _, _, _, lot_size, tick_size,
            generic_asset_transfer_custodian_id, market_id
        ) = registry::register_market_internal_multiple_test(econia);
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
        // Declare market account info
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Deposit enough base coins to cover the ask
        deposit_coins<BC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint<BC>(econia, base_required));
        // Register user's market account with given order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Get asset counts
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert asset counts
        assert!(base_total      ==  base_required, 0);
        assert!(base_available  ==              0, 0);
        assert!(base_ceiling    ==  base_required, 0);
        assert!(quote_total     ==              0, 0);
        assert!(quote_available ==              0, 0);
        assert!(quote_ceiling   == quote_received, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Remove the order from the user's market account
        remove_order_internal(@user, market_account_info, lot_size, tick_size,
            side, order_id);
        // Get asset counts
        ( base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert asset counts
        assert!(base_total      == base_required, 0);
        assert!(base_available  == base_required, 0);
        assert!(base_ceiling    == base_required, 0);
        assert!(quote_total     ==             0, 0);
        assert!(quote_available ==             0, 0);
        assert!(quote_ceiling   ==             0, 0);
        assert!( // Assert user no longer has order in market account
            !has_order_test(@user, market_account_info, side, order_id), 0);
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
        let (_, _, _, _, lot_size, tick_size,
            generic_asset_transfer_custodian_id, market_id
        ) = registry::register_market_internal_multiple_test(econia);
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
        // Declare market account info
        let market_account_info = MarketAccountInfo{market_id,
            general_custodian_id, generic_asset_transfer_custodian_id};
        // Deposit enough quote coins to cover the bid
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint<QC>(econia, quote_required));
        // Register user's market account with given order
        register_order_internal(@user, market_account_info, side, order_id,
            size, price, lot_size, tick_size);
        // Get asset counts
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert asset counts
        assert!(base_total      ==              0, 0);
        assert!(base_available  ==              0, 0);
        assert!(base_ceiling    ==  base_received, 0);
        assert!(quote_total     == quote_required, 0);
        assert!(quote_available ==              0, 0);
        assert!(quote_ceiling   == quote_required, 0);
        // Assert order added to corresponding tree with correct size
        assert!(get_order_size_test(@user, market_account_info, side, order_id)
            == size, 0);
        // Remove the order from the user's market account
        remove_order_internal(@user, market_account_info, lot_size, tick_size,
            side, order_id);
        // Get asset counts
        ( base_total,  base_available,  base_ceiling,
         quote_total, quote_available, quote_ceiling,
        ) = get_asset_counts_test(@user, market_id, general_custodian_id);
        // Assert asset counts
        assert!(base_total      ==              0, 0);
        assert!(base_available  ==              0, 0);
        assert!(base_ceiling    ==              0, 0);
        assert!(quote_total     == quote_required, 0);
        assert!(quote_available == quote_required, 0);
        assert!(quote_ceiling   == quote_required, 0);
        assert!( // Assert user no longer has order in market account
            !has_order_test(@user, market_account_info, side, order_id), 0);
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
    ) acquires
        Collateral,
        MarketAccounts
    {
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
        let (market_account_info, _) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, NO_CUSTODIAN);
        let empty_option = // Attempt invalid invocation
            withdraw_asset<BG>(@user, market_account_info, 1, false);
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
        // Register user to trade on the account
        register_market_account<BG, QC>(user, market_id, general_custodian_id);
        coin::register_for_test<QC>(user); // Register coin store
        coin::deposit(@user, assets::mint<QC>(econia, coin_deposit_amount));
        // Deposit coin asset
        deposit_from_coinstore<QC>(user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id, coin_deposit_amount);
        // Deposit generic asset
        deposit_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_deposit_amount, &custodian_capability);
        // Withdraw coin asset to coinstore
        withdraw_to_coinstore<QC>(user, market_id,
            generic_asset_transfer_custodian_id, coin_withdrawal_amount);
        // Withdraw generic asset
        withdraw_generic_asset<BG>(@user, market_id, general_custodian_id,
            generic_withdrawal_amount, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability_test(custodian_capability);
        // Assert state
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_id, general_custodian_id);
        assert!(base_total      == generic_end_amount, 0);
        assert!(base_available  == generic_end_amount, 0);
        assert!(base_ceiling    == generic_end_amount, 0);
        assert!(quote_total     == coin_end_amount,    0);
        assert!(quote_available == coin_end_amount,    0);
        assert!(quote_ceiling   == coin_end_amount,    0);
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == coin_end_amount, 0);
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
        let (_, market_account_info) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, general_custodian_id);
        // Extract market account fields
        let market_id = market_account_info.market_id;
        let generic_asset_transfer_custodian_id = market_account_info.
            generic_asset_transfer_custodian_id;
        // Get custodian capability
        let custodian_capability =
            registry::get_custodian_capability_test(general_custodian_id);
        // Deposit coins to market account
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint<QC>(econia, coin_deposit_amount));
        // Withdraw from market account
        let coins = withdraw_coins_custodian<QC>(@user, market_id,
            generic_asset_transfer_custodian_id, coin_withdrawal_amount,
            &custodian_capability);
        // Assert raw coin value
        assert!(coin::value(&coins) == coin_withdrawal_amount, 0);
        // Assert market account state
        let (_, _, _, quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_id, general_custodian_id);
        assert!(quote_total     == coin_end_amount, 0);
        assert!(quote_available == coin_end_amount, 0);
        assert!(quote_ceiling   == coin_end_amount, 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == coin_end_amount, 0);
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
        let (_, market_account_info) = register_user_with_market_accounts_test(
            econia, user, NO_CUSTODIAN, general_custodian_id);
        // Extract market account fields
        let market_id = market_account_info.market_id;
        let generic_asset_transfer_custodian_id = market_account_info.
            generic_asset_transfer_custodian_id;
        // Get custodian capability
        let custodian_capability =
            registry::get_custodian_capability_test(general_custodian_id);
        // Deposit coins to market account
        deposit_coins<QC>(@user, market_id, general_custodian_id,
            generic_asset_transfer_custodian_id,
            assets::mint<QC>(econia, coin_deposit_amount));
        // Withdraw from market account
        let option_coins = withdraw_coins_as_option_internal<QC>(@user,
            market_account_info, coin_withdrawal_amount);
        // Assert coin value
        assert!(coin::value(option::borrow(&option_coins)) ==
            coin_withdrawal_amount, 0);
        // Assert market account state
        let (_, _, _, quote_total, quote_available, quote_ceiling) =
            get_asset_counts_test(@user, market_id, general_custodian_id);
        assert!(quote_total     == coin_end_amount, 0);
        assert!(quote_available == coin_end_amount, 0);
        assert!(quote_ceiling   == coin_end_amount, 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_id, general_custodian_id) == coin_end_amount, 0);
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
        assets::burn(withdraw_coins<BG>(@user, 1, 1, 1, 1));
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

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}