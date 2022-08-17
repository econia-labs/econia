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
    fun invoke_registry() {registry::n_markets();}
    public(friend) fun return_0(): u8 {0}

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Coin};
    use aptos_std::type_info;
    use econia::critbit::{Self, CritBitTree};
    use econia::open_table;
     use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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

    /// When market account already exists for given market account info
    const E_EXISTS_MARKET_ACCOUNT: u64 = 2;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// When both base and quote assets are coins
    const PURE_COIN_PAIR: u64 = 0;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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
        let map = &mut borrow_global_mut<MarketAccounts>(user_address).map;
        // Assert no entry exists for given market account info
        assert!(!open_table::contains(map, market_account_info),
            E_EXISTS_MARKET_ACCOUNT);
        // Add an empty entry for given market account info
        open_table::add(map, market_account_info, MarketAccount{
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

}