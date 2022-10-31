module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::table::{Self, Table};
    use aptos_framework::type_info::{Self, TypeInfo};
    use econia::tablist::{Self, Tablist};
    use econia::registry::{
        Self, CustodianCapability, GenericAsset, UnderwriterCapability};
    use std::option::{Self, Option};
    use std::string::String;
    use std::signer::address_of;
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use econia::avl_queue::{u_128_by_32, u_64_by_32};
    #[test_only]
    use econia::assets::{Self, BC, QC, UC};

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
    /// No market accounts resource found.
    const E_NO_MARKET_ACCOUNTS: u64 = 2;
    /// No market account resource found.
    const E_NO_MARKET_ACCOUNT: u64 = 3;
    /// Asset type is not in trading pair for market.
    const E_ASSET_NOT_IN_PAIR: u64 = 4;
    /// Deposit would overflow asset ceiling.
    const E_DEPOSIT_OVERFLOW_ASSET_CEILING: u64 = 5;
    /// Underwriter is not valid for indicated market.
    const E_INVALID_UNDERWRITER: u64 = 6;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// Flag for null value when null defined as 0.
    const NIL: u64 = 0;
    /// Custodian ID flag for no custodian.
    const NO_CUSTODIAN: u64 = 0;
    /// Underwriter ID flag for no underwriter.
    const NO_UNDERWRITER: u64 = 0;
    /// Number of bits market ID is shifted in market account ID.
    const SHIFT_MARKET_ID: u8 = 64;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Wrapped call to `deposit_asset()` for depositing coins.
    ///
    /// # Testing
    ///
    /// * `test_deposits()`
    public fun deposit_coins<
        CoinType
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        coins: Coin<CoinType>
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_asset<CoinType>(
            user_address,
            market_id,
            custodian_id,
            coin::value(&coins),
            option::some(coins),
            NO_UNDERWRITER);
    }

    /// Wrapped call to `deposit_asset()` for depositing generic asset.
    ///
    /// # Testing
    ///
    /// * `test_deposits()`
    public fun deposit_generic_asset(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
        underwriter_capability_ref: &UnderwriterCapability
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_asset<GenericAsset>(
            user_address,
            market_id,
            custodian_id,
            amount,
            option::none(),
            registry::get_underwriter_id(underwriter_capability_ref));
    }

    /// Return all market account IDs associated with market ID.
    ///
    /// # Parameters
    ///
    /// * `user`: Address of user to check market account IDs for.
    /// * `market_id`: Market ID to check market accounts for.
    ///
    /// # Returns
    ///
    /// * `vector<u128>`: Vector of user's market account IDs for given
    ///   market, empty if no market accounts.
    ///
    /// # Gas considerations
    ///
    /// Loops over all elements within a vector that is itself a single
    /// item in global storage, and returns a vector via pass-by-value.
    ///
    /// # Testing
    ///
    /// * `test_market_account_getters()`
    public fun get_all_market_account_ids_for_market_id(
        user: address,
        market_id: u64
    ): vector<u128>
    acquires MarketAccounts {
        let market_account_ids = vector::empty(); // Init empty vector.
        // Return empty if user has no market accounts resource.
        if (!exists<MarketAccounts>(user)) return market_account_ids;
        let custodians_map_ref = // Immutably borrow custodians map.
            &borrow_global<MarketAccounts>(user).custodians;
        // Return empty if user has no market accounts for given market.
        if (!tablist::contains(custodians_map_ref, market_id))
            return market_account_ids;
        // Immutably borrow list of custodians for given market.
        let custodians_ref = tablist::borrow(custodians_map_ref, market_id);
        // Initialize loop counter and number of elements in vector.
        let (i, n_custodians) = (0, vector::length(custodians_ref));
        while (i < n_custodians) { // Loop over all elements.
            // Get custodian ID.
            let custodian_id = *vector::borrow(custodians_ref, i);
            // Get market account ID.
            let market_account_id = ((market_id as u128) << SHIFT_MARKET_ID) |
                                    (custodian_id as u128);
            // Push back onto ongoing market account ID vector.
            vector::push_back(&mut market_account_ids, market_account_id);
            i = i + 1; // Increment loop counter
        };
        market_account_ids // Return market account IDs.
    }

    /// Wrapped call to `get_asset_counts_internal()` for custodian.
    ///
    /// Restricted to custodian for given market account to prevent
    /// excessive public queries and thus transaction collisions.
    ///
    /// # Testing
    ///
    /// * `test_deposits()`
    public fun get_asset_counts_custodian(
        user_address: address,
        market_id: u64,
        custodian_capability_ref: &CustodianCapability
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        get_asset_counts_internal(
            user_address, market_id,
            registry::get_custodian_id(custodian_capability_ref))
    }

    /// Wrapped call to `get_asset_counts_internal()` for signing user.
    ///
    /// Restricted to signing user for given market account to prevent
    /// excessive public queries and thus transaction collisions.
    ///
    /// # Testing
    ///
    /// * `test_deposits()`
    public fun get_asset_counts_user(
        user: &signer,
        market_id: u64
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        get_asset_counts_internal(address_of(user), market_id, NO_CUSTODIAN)
    }

    /// Return all of a user's market account IDs.
    ///
    /// # Parameters
    ///
    /// * `user`: Address of user to check market account IDs for.
    ///
    /// # Returns
    ///
    /// * `vector<u128>`: Vector of user's market account IDs, empty if
    ///   no market accounts.
    ///
    /// # Gas considerations
    ///
    /// For each market that a user has market accounts for, loops over
    /// a separate item in global storage, incurring a per-item read
    /// cost. Additionally loops over a vector for each such per-item
    /// read, incurring linearly-scaled vector operation costs. Returns
    /// a vector via pass-by-value.
    ///
    /// # Testing
    ///
    /// * `test_market_account_getters()`
    public fun get_all_market_account_ids_for_user(
        user: address,
    ): vector<u128>
    acquires MarketAccounts {
        let market_account_ids = vector::empty(); // Init empty vector.
        // Return empty if user has no market accounts resource.
        if (!exists<MarketAccounts>(user)) return market_account_ids;
        let custodians_map_ref = // Immutably borrow custodians map.
            &borrow_global<MarketAccounts>(user).custodians;
        // Get market ID option at head of market ID list.
        let market_id_option = tablist::get_head_key(custodians_map_ref);
        // While market IDs left to loop over:
        while (option::is_some(&market_id_option)) {
            // Get market ID.
            let market_id = *option::borrow(&market_id_option);
            // Immutably borrow list of custodians for given market and
            // next market ID option in list.
            let (custodians_ref, _, next) = tablist::borrow_iterable(
                custodians_map_ref, market_id);
            // Initialize loop counter and number of elements in vector.
            let (i, n_custodians) = (0, vector::length(custodians_ref));
            while (i < n_custodians) { // Loop over all elements.
                // Get custodian ID.
                let custodian_id = *vector::borrow(custodians_ref, i);
                let market_account_id = // Get market account ID.
                    ((market_id as u128) << SHIFT_MARKET_ID) |
                    (custodian_id as u128);
                // Push back onto ongoing market account ID vector.
                vector::push_back(&mut market_account_ids, market_account_id);
                i = i + 1; // Increment loop counter
            };
            // Review next market ID option in list.
            market_id_option = next;
        };
        market_account_ids // Return market account IDs.
    }

    /// Return custodian ID encoded in market account ID.
    ///
    /// # Testing
    ///
    /// * `test_market_account_id_getters()`
    fun get_custodian_id(
        market_account_id: u128
    ): u64 {
        ((market_account_id & (HI_64 as u128)) as u64)
    }

    /// Return market account ID with encoded market and custodian IDs.
    ///
    /// # Testing
    ///
    /// * `test_market_account_id_getters()`
    fun get_market_account_id(
        market_id: u64,
        custodian_id: u64
    ): u128 {
        ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128)
    }

    /// Return market ID encoded in market account ID.
    ///
    /// # Testing
    ///
    /// * `test_market_account_id_getters()`
    fun get_market_id(
        market_account_id: u128
    ): u64 {
        (market_account_id >> SHIFT_MARKET_ID as u64)
    }

    /// Return `true` if `user` has at market account registered with
    /// given `market_account_id`.
    ///
    /// # Testing
    ///
    /// * `test_market_account_getters()`
    public fun has_market_account_by_market_account_id(
        user: address,
        market_account_id: u128
    ): bool
    acquires MarketAccounts {
        // Return false if user has no market accounts resource.
        if (!exists<MarketAccounts>(user)) return false;
        // Immutably borrow market accounts map.
        let market_accounts_map =
            &borrow_global<MarketAccounts>(user).map;
        // Return if map has entry for given market account ID.
        table::contains(market_accounts_map, market_account_id)
    }

    /// Return `true` if `user` has at least one market account
    /// registered with given `market_id`.
    ///
    /// # Testing
    ///
    /// * `test_market_account_getters()`
    public fun has_market_account_by_market_id(
        user: address,
        market_id: u64
    ): bool
    acquires MarketAccounts {
        // Return false if user has no market accounts resource.
        if (!exists<MarketAccounts>(user)) return false;
        let custodians_map_ref = // Immutably borrow custodians map.
            &borrow_global<MarketAccounts>(user).custodians;
        // Return if custodians map has entry for given market ID.
        tablist::contains(custodians_map_ref, market_id)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Wrapped call to `deposit_coins()` for depositing from an
    /// `aptos_framework::coin::CoinStore`.
    ///
    /// # Testing
    ///
    /// * `test_deposits()`
    public entry fun deposit_from_coinstore<
        CoinType
    >(
        user: &signer,
        market_id: u64,
        custodian_id: u64,
        amount: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        deposit_coins<CoinType>(
            address_of(user),
            market_id,
            custodian_id,
            coin::withdraw<CoinType>(user, amount));
    }

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

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return asset counts for specified market account.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    ///
    /// # Returns
    ///
    /// * `MarketAccount.base_total`
    /// * `MarketAccount.base_available`
    /// * `MarketAccount.base_ceiling`
    /// * `MarketAccount.quote_total`
    /// * `MarketAccount.quote_available`
    /// * `MarketAccount.quote_ceiling`
    ///
    /// # Aborts
    ///
    /// * `E_NO_MARKET_ACCOUNTS`: No market accounts resource found.
    /// * `E_NO_MARKET_ACCOUNT`: No market account resource found.
    ///
    /// # Testing
    ///
    /// * `test_deposits()`
    /// * `test_get_asset_counts_internal_no_account()`
    /// * `test_get_asset_counts_internal_no_accounts()`
    fun get_asset_counts_internal(
        user_address: address,
        market_id: u64,
        custodian_id: u64
    ): (
        u64,
        u64,
        u64,
        u64,
        u64,
        u64
    ) acquires MarketAccounts {
        // Assert user has market accounts resource.
        assert!(exists<MarketAccounts>(user_address), E_NO_MARKET_ACCOUNTS);
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        // Assert user has market account for given ID.
        assert!(table::contains(market_accounts_map_ref, market_account_id),
                E_NO_MARKET_ACCOUNT);
        let market_account_ref = // Immutably borrow market account.
            table::borrow(market_accounts_map_ref, market_account_id);
        (market_account_ref.base_total,
         market_account_ref.base_available,
         market_account_ref.base_ceiling,
         market_account_ref.quote_total,
         market_account_ref.quote_available,
         market_account_ref.quote_ceiling) // Return asset count fields.
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Deposit an asset to a user's market account.
    ///
    /// Update asset counts, deposit optional coins as collateral.
    ///
    /// # Type parameters
    ///
    /// * `AssetType`: Asset type to deposit, `registry::GenericAsset`
    ///   if a generic asset.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `amount`: Amount to deposit.
    /// * `optional_coins`: Optional coins to deposit.
    /// * `underwriter_id`: Underwriter ID for market, ignored when
    ///   depositing coins.
    ///
    /// # Aborts
    ///
    /// * `E_NO_MARKET_ACCOUNTS`: No market accounts resource found.
    /// * `E_NO_MARKET_ACCOUNT`: No market account resource found.
    /// * `E_ASSET_NOT_IN_PAIR`: Asset type is not in trading pair for
    ///    market.
    /// * `E_DEPOSIT_OVERFLOW_ASSET_CEILING`: Deposit would overflow
    ///   asset ceiling.
    /// * `E_INVALID_UNDERWRITER`: Underwriter is not valid for
    ///   indicated market, in the case of a generic asset deposit.
    ///
    /// # Assumptions
    ///
    /// * If optional coins provided, their value equals `amount`.
    /// * When depositing coins, if a market account exists, then so
    ///   does a corresponding collateral map entry.
    ///
    /// # Testing
    ///
    /// * `test_deposit_asset_no_account()`
    /// * `test_deposit_asset_no_accounts()`
    /// * `test_deposit_asset_not_in_pair()`
    /// * `test_deposit_asset_overflow()`
    /// * `test_deposit_asset_underwriter()`
    /// * `test_deposits()`
    fun deposit_asset<
        AssetType
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
        optional_coins: Option<Coin<AssetType>>,
        underwriter_id: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Assert user has market accounts resource.
        assert!(exists<MarketAccounts>(user_address), E_NO_MARKET_ACCOUNTS);
        // Mutably borrow market accounts map.
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        // Assert user has market account for given ID.
        assert!(table::contains(market_accounts_map_ref_mut, market_account_id),
                E_NO_MARKET_ACCOUNT);
        let market_account_ref_mut = // Mutably borrow market account.
            table::borrow_mut(market_accounts_map_ref_mut, market_account_id);
        // Get asset type info.
        let asset_type = type_info::type_of<AssetType>();
        // Get asset total, available, and ceiling amounts based on if
        // asset is base or quote for trading pair, aborting if neither.
        let (total_ref_mut, available_ref_mut, ceiling_ref_mut) =
            if (asset_type == market_account_ref_mut.base_type) (
                &mut market_account_ref_mut.base_total,
                &mut market_account_ref_mut.base_available,
                &mut market_account_ref_mut.base_ceiling
            ) else if (asset_type == market_account_ref_mut.quote_type) (
                &mut market_account_ref_mut.quote_total,
                &mut market_account_ref_mut.quote_available,
                &mut market_account_ref_mut.quote_ceiling
            ) else abort E_ASSET_NOT_IN_PAIR;
        assert!( // Assert deposit does not overflow asset ceiling.
            ((*ceiling_ref_mut as u128) + (amount as u128)) <= (HI_64 as u128),
            E_DEPOSIT_OVERFLOW_ASSET_CEILING);
        *total_ref_mut = *total_ref_mut + amount; // Update total.
        // Update available asset amount.
        *available_ref_mut = *available_ref_mut + amount;
        *ceiling_ref_mut = *ceiling_ref_mut + amount; // Update ceiling.
        if (option::is_some(&optional_coins)) { // If asset is coin:
            // Mutably borrow collateral map.
            let collateral_map_ref_mut = &mut borrow_global_mut<
                Collateral<AssetType>>(user_address).map;
            // Mutably borrow collateral for market account.
            let collateral_ref_mut = tablist::borrow_mut(
                collateral_map_ref_mut, market_account_id);
            coin::merge( // Merge optional coins into collateral.
                collateral_ref_mut, option::destroy_some(optional_coins));
        } else { // If asset is not coin:
            assert!(underwriter_id == market_account_ref_mut.underwriter_id,
                    E_INVALID_UNDERWRITER); // Assert underwriter ID.
            option::destroy_none(optional_coins); // Destroy option.
        };
    }

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

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Custodian ID for pure coin test market with delegated custodian.
    const CUSTODIAN_ID: u64 = 123;
    #[test_only]
    /// Market ID for generic test market.
    const MARKET_ID_GENERIC: u64 = 2;
    #[test_only]
    /// Market ID for pure coin test market.
    const MARKET_ID_PURE_COIN: u64 = 1;
    #[test_only]
    /// Underwriter ID for generic test market.
    const UNDERWRITER_ID: u64 = 7;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return `Coin.value` of entry in `Collateral` for given
    /// `user_address`, `AssetType` and `market_account_id`.
    public fun get_collateral_value_test<
        CoinType
    >(
        user_address: address,
        market_account_id: u128,
    ): u64
    acquires Collateral {
        let collateral_map_ref = // Immutably borrow collateral map.
            &borrow_global<Collateral<CoinType>>(user_address).map;
        let coin_ref = // Immutably borrow coin collateral.
            tablist::borrow(collateral_map_ref, market_account_id);
        coin::value(coin_ref) // Return coin value.
    }

    #[test_only]
    /// Return `true` if `user_adress` has an entry in `Collateral` for
    /// given `AssetType` and `market_account_id`.
    public fun has_collateral_test<
        AssetType
    >(
        user_address: address,
        market_account_id: u128,
    ): bool
    acquires Collateral {
        // Return false if does not even have collateral map.
        if (!exists<Collateral<AssetType>>(user_address)) return false;
        // Immutably borrow collateral map.
        let collateral_map_ref =
            &borrow_global<Collateral<AssetType>>(user_address).map;
        // Return if table contains entry for market account ID.
        tablist::contains(collateral_map_ref, market_account_id)
    }

    #[test_only]
    /// Register market accounts under test `@user`, return signer and
    /// market account ID of:
    ///
    /// * Pure coin self-custodied market account.
    /// * Pure coin market account with delegated custodian.
    /// * Generic self-custodian market account.
    fun register_market_accounts_test(): (
        signer,
        u128,
        u128,
        u128
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Get signer for test user account.
        let user = account::create_signer_with_capability(
            &account::create_test_signer_cap(@user));
        // Create Aptos account.
        account::create_account_for_test(@user);
        // Register coin store for test assets.
        coin::register<BC>(&user);
        coin::register<QC>(&user);
        // Register a pure coin and a generic market, discarding most
        // returns.
        let (market_id_pure_coin, _, _, _, _, _, market_id_generic, _, _, _, _,
             underwriter_id_generic) = registry::register_markets_test();
        // Assert both market IDs and generic underwriter ID.
        assert!(market_id_pure_coin    == MARKET_ID_PURE_COIN, 0);
        assert!(market_id_generic      == MARKET_ID_GENERIC, 0);
        assert!(underwriter_id_generic == UNDERWRITER_ID, 0);
        // Register pure coin account.
        register_market_account<BC, QC>(
            &user, market_id_pure_coin, NO_CUSTODIAN);
        // Set delegated custodian ID as registered.
        registry::set_registered_custodian_test(CUSTODIAN_ID);
        register_market_account<BC, QC>( // Register delegated account.
            &user, market_id_pure_coin, CUSTODIAN_ID);
        // Register generic asset account.
        register_market_account_generic_base<QC>(
            &user, market_id_generic, NO_CUSTODIAN);
        // Get market account IDs.
        let market_account_id_coin_self =
            get_market_account_id(market_id_pure_coin, NO_CUSTODIAN);
        let market_account_id_coin_delegated =
            get_market_account_id(market_id_pure_coin, CUSTODIAN_ID);
        let market_account_id_generic_self =
            get_market_account_id(market_id_generic  , NO_CUSTODIAN);
        (user, // Return signing user and market account IDs.
         market_account_id_coin_self,
         market_account_id_coin_delegated,
         market_account_id_generic_self)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no market account.
    fun test_deposit_asset_no_account()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        // Attempt invalid invocation.
        deposit_coins<BC>(@user, 0, 0, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for no market accounts.
    fun test_deposit_asset_no_accounts()
    acquires
        Collateral,
        MarketAccounts
    {
        // Attempt invalid invocation.
        deposit_coins<BC>(@user, 0, 0, coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for asset not in pair.
    fun test_deposit_asset_not_in_pair()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        // Attempt invalid invocation.
        deposit_coins<UC>(@user, MARKET_ID_PURE_COIN, NO_CUSTODIAN,
                          coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for ceiling overflow.
    fun test_deposit_asset_overflow()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        let underwriter_capability = // Get underwriter capability.
            registry::get_underwriter_capability_test(UNDERWRITER_ID);
        // Deposit maximum amount of generic asset.
        deposit_generic_asset(@user, MARKET_ID_GENERIC, NO_CUSTODIAN,
                              HI_64, &underwriter_capability);
        // Attempt invalid deposit of one more unit.
        deposit_generic_asset(@user, MARKET_ID_GENERIC, NO_CUSTODIAN,
                              1, &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid underwriter.
    fun test_deposit_asset_underwriter()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        let underwriter_capability = // Get underwriter capability.
            registry::get_underwriter_capability_test(UNDERWRITER_ID + 1);
        // Attempt deposit with invalid underwriter capability.
        deposit_generic_asset(@user, MARKET_ID_GENERIC, NO_CUSTODIAN,
                              1, &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
    }

    #[test]
    /// Verify state updates for assorted deposit styles.
    fun test_deposits()
    acquires
        Collateral,
        MarketAccounts
    {
        // Declare deposit parameters
        let coin_amount = 700;
        let generic_amount = 500;
        // Get signing user and test market account IDs.
        let (user, _,
             market_account_id_coin_delegated,
             market_account_id_generic_self) = register_market_accounts_test();
        // Deposit coin asset to user's coin store.
        coin::deposit(@user, assets::mint_test<QC>(coin_amount));
        // Deposit to user's delegated pure coin market account.
        deposit_from_coinstore<QC>(&user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                                   coin_amount);
        let underwriter_capability = // Get underwriter capability.
            registry::get_underwriter_capability_test(UNDERWRITER_ID);
        // Deposit to user's generic market account.
        deposit_generic_asset(@user, MARKET_ID_GENERIC, NO_CUSTODIAN,
                              generic_amount, &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
        let custodian_capability = // Get custodian capability.
            registry::get_custodian_capability_test(CUSTODIAN_ID);
        // Assert state for quote deposit.
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_custodian(
                @user, MARKET_ID_PURE_COIN, &custodian_capability);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        assert!(base_total      == 0             , 0);
        assert!(base_available  == 0             , 0);
        assert!(base_ceiling    == 0             , 0);
        assert!(quote_total     == coin_amount   , 0);
        assert!(quote_available == coin_amount   , 0);
        assert!(quote_ceiling   == coin_amount   , 0);
        assert!(get_collateral_value_test<BC>(
            @user, market_account_id_coin_delegated) == 0, 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_account_id_coin_delegated) == coin_amount, 0);
        // Assert state for base deposit.
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_user(&user, MARKET_ID_GENERIC);
        assert!(base_total      == generic_amount, 0);
        assert!(base_available  == generic_amount, 0);
        assert!(base_ceiling    == generic_amount, 0);
        assert!(quote_total     == 0             , 0);
        assert!(quote_available == 0             , 0);
        assert!(quote_ceiling   == 0             , 0);
        assert!(!has_collateral_test<GenericAsset>(
            @user, market_account_id_generic_self), 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_account_id_generic_self) == 0, 0);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no market account resource.
    fun test_get_asset_counts_internal_no_account()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        // Attempt invalid invocation.
        get_asset_counts_internal(@user, 0, 0);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for no market accounts resource.
    fun test_get_asset_counts_internal_no_accounts()
    acquires MarketAccounts {
        // Attempt invalid invocation.
        get_asset_counts_internal(@user, 0, 0);
    }

    #[test]
    /// Verify valid returns.
    fun test_market_account_getters()
    acquires
        Collateral,
        MarketAccounts
    {
        // Get market account IDs for test accounts.
        let market_account_id_coin_self = get_market_account_id(
            MARKET_ID_PURE_COIN, NO_CUSTODIAN);
        let market_account_id_coin_delegated = get_market_account_id(
            MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        let market_account_id_generic_self = get_market_account_id(
            MARKET_ID_GENERIC, NO_CUSTODIAN);
        // Assert empty returns.
        assert!(get_all_market_account_ids_for_market_id(
                @user, MARKET_ID_PURE_COIN) == vector[], 0);
        assert!(get_all_market_account_ids_for_user(
                @user) == vector[], 0);
        // Assert false returns.
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_coin_self), 0);
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_coin_delegated), 0);
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_generic_self), 0);
        assert!(!has_market_account_by_market_id(
                @user, MARKET_ID_PURE_COIN), 0);
        assert!(!has_market_account_by_market_id(
                @user, MARKET_ID_GENERIC), 0);
        register_market_accounts_test(); // Register market accounts.
        // Assert empty returns.
        assert!(get_all_market_account_ids_for_market_id(
                @user, 123) == vector[], 0);
        // Get signer for another test user account.
        let user_2 = account::create_signer_with_capability(
            &account::create_test_signer_cap(@user_2));
        // Move to another user empty market accounts resource.
        move_to<MarketAccounts>(&user_2, MarketAccounts{
            map: table::new(), custodians: tablist::new()});
        // Assert empty returns.
        assert!(get_all_market_account_ids_for_user(
                @user_2) == vector[], 0);
        // Assert non-empty returns.
        let expected_ids = vector[market_account_id_coin_self,
                                  market_account_id_coin_delegated];
        assert!(get_all_market_account_ids_for_market_id(
                @user, MARKET_ID_PURE_COIN) == expected_ids, 0);
        expected_ids = vector[market_account_id_generic_self];
        assert!(get_all_market_account_ids_for_market_id(
                @user, MARKET_ID_GENERIC) == expected_ids, 0);
        expected_ids = vector[market_account_id_coin_self,
                              market_account_id_coin_delegated,
                              market_account_id_generic_self];
        assert!(get_all_market_account_ids_for_user(
                @user) == expected_ids, 0);
        // Assert true returns.
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_coin_self), 0);
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_coin_delegated), 0);
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_generic_self), 0);
        assert!(has_market_account_by_market_id(
                @user, MARKET_ID_PURE_COIN), 0);
        assert!(has_market_account_by_market_id(
                @user, MARKET_ID_GENERIC), 0);
        // Assert false returns.
        assert!(!has_market_account_by_market_account_id(
                @user_2, market_account_id_coin_self), 0);
        assert!(!has_market_account_by_market_account_id(
                @user_2, market_account_id_coin_delegated), 0);
        assert!(!has_market_account_by_market_account_id(
                @user_2, market_account_id_generic_self), 0);
        assert!(!has_market_account_by_market_id(
                @user_2, MARKET_ID_PURE_COIN), 0);
        assert!(!has_market_account_by_market_id(
                @user_2, MARKET_ID_GENERIC), 0);
    }

    #[test]
    /// Verify valid returns
    fun test_market_account_id_getters() {
        let market_id =    u_64_by_32(b"10000000000000000000000000000000",
                                      b"00000000000000000000000000000001");
        let custodian_id = u_64_by_32(b"11000000000000000000000000000000",
                                      b"00000000000000000000000000000011");
        let market_account_id = get_market_account_id(market_id, custodian_id);
        assert!(market_account_id ==
                          u_128_by_32(b"10000000000000000000000000000000",
                                      b"00000000000000000000000000000001",
                                      b"11000000000000000000000000000000",
                                      b"00000000000000000000000000000011"), 0);
        assert!(get_market_id(market_account_id) == market_id, 0);
        assert!(get_custodian_id(market_account_id) == custodian_id, 0);
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
        // Set custodian ID as registered.
        registry::set_registered_custodian_test(CUSTODIAN_ID);
        // Register pure coin market account.
        register_market_account<BC, QC>(
            user, market_id_pure_coin, NO_CUSTODIAN);
        register_market_account<BC, QC>( // Register delegated account.
            user, market_id_pure_coin, CUSTODIAN_ID);
        // Register generic asset account.
        register_market_account_generic_base<QC>(
            user, market_id_generic, NO_CUSTODIAN);
        // Get market account IDs.
        let market_account_id_self = get_market_account_id(
            market_id_pure_coin, NO_CUSTODIAN);
        let market_account_id_delegated = get_market_account_id(
            market_id_pure_coin, CUSTODIAN_ID);
        let market_account_id_generic = get_market_account_id(
            market_id_generic, NO_CUSTODIAN);
        // Immutably borrow base coin collateral.
        let collateral_map_ref = &borrow_global<Collateral<BC>>(@user).map;
        // Assert entries only made for pure coin market accounts.
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_self)) == 0, 0);
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_delegated)) == 0, 0);
        assert!(!tablist::contains(
            collateral_map_ref, market_account_id_generic), 0);
        // Immutably borrow quote coin collateral.
        let collateral_map_ref = &borrow_global<Collateral<QC>>(@user).map;
        // Assert entries made for all market accounts.
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_self)) == 0, 0);
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_delegated)) == 0, 0);
        assert!(coin::value(tablist::borrow(
            collateral_map_ref, market_account_id_generic)) == 0, 0);
        let custodians_map_ref = // Immutably borrow custodians map.
            &borrow_global<MarketAccounts>(@user).custodians;
        // Immutably borrow custodians entry for pure coin market.
        let custodians_ref =
            tablist::borrow(custodians_map_ref, market_id_pure_coin);
        // Assert listed custodians.
        assert!(*custodians_ref
                == vector[NO_CUSTODIAN, CUSTODIAN_ID], 0);
        // Immutably borrow custodians entry for generic market.
        custodians_ref =
            tablist::borrow(custodians_map_ref, market_id_generic);
        assert!( // Assert listed custodian.
            *custodians_ref == vector[NO_CUSTODIAN], 0);
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(@user).map;
        // Immutably borrow pure coin self-custodied market account.
        let market_account_ref =
            table::borrow(market_accounts_map_ref, market_account_id_self);
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
        // Immutably borrow pure coin delegated market account.
        market_account_ref = table::borrow(market_accounts_map_ref,
                                           market_account_id_delegated);
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