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

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{/*Self,*/ Coin};
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

    /// Represents a user's open orders and available assets for a given
    ///`MarketAccountInfo`
    struct MarketAccount has store {
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

    /// Unique ID describing a market and a user-specific custodian
    struct MarketAccountInfo has copy, drop, store {
        /// The market that a user is trading on
        market_info: registry::MarketInfo,
        /// Serial ID of registered account custodian, set to 0 when
        /// given account does not have an authorized custodian
        custodian_id: u64
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

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Register user with a `MarketAccounts` map entry corresponding to
    /// `market_account_info`, initializing `MarketAccounts` if it does
    /// not already exist
    ///
    /// # Abort conditions
    /// * If user already has a `MarketAccounts` entry for given
    ///   `market_account_info`
    fun register_market_account(
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