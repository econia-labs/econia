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
    /// Too little available for withdrawal.
    const E_WITHDRAW_TOO_LITTLE_AVAILABLE: u64 = 7;
    /// Price is zero.
    const E_PRICE_0: u64 = 8;
    /// Price exceeds maximum possible price.
    const E_PRICE_TOO_HIGH: u64 = 9;
    /// Size is below minimum size for market.
    const E_SIZE_TOO_LOW: u64 = 10;
    /// Ticks to fill an order overflows a `u64`.
    const E_TICKS_OVERFLOW: u64 = 11;
    /// Filling order would overflow asset received from trade.
    const E_OVERFLOW_ASSET_IN: u64 = 12;
    /// Not enough asset to trade away.
    const E_NOT_ENOUGH_ASSET_OUT: u64 = 13;
    /// No change in order size.
    const E_CHANGE_ORDER_NO_CHANGE: u64 = 14;
    /// Market order ID mismatch with user's open order.
    const E_INVALID_MARKET_ORDER_ID: u64 = 15;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag for ask side
    const ASK: bool = true;
    /// Flag for bid side
    const BID: bool = false;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// Maximum possible price that can be encoded in 32 bits. Generated
    /// in Python via `hex(int('1' * 32, 2))`.
    const MAX_PRICE: u64 = 0xffffffff;
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

    /// Wrapped call to `withdraw_coins()` for withdrawing under
    /// authority of delegated custodian.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    public fun withdraw_coins_custodian<
        CoinType
    >(
        user_address: address,
        market_id: u64,
        amount: u64,
        custodian_capability_ref: &CustodianCapability
    ): Coin<CoinType>
    acquires
        Collateral,
        MarketAccounts
    {
        option::destroy_some(withdraw_asset<CoinType>(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            amount,
            NO_UNDERWRITER))
    }

    /// Wrapped call to `withdraw_coins()` for withdrawing under
    /// authority of signing user.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    public fun withdraw_coins_user<
        CoinType
    >(
        user: &signer,
        market_id: u64,
        amount: u64,
    ): Coin<CoinType>
    acquires
        Collateral,
        MarketAccounts
    {
        option::destroy_some(withdraw_asset<CoinType>(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            amount,
            NO_UNDERWRITER))
    }

    /// Wrapped call to `withdraw_generic_asset()` for withdrawing under
    /// authority of delegated custodian.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    public fun withdraw_generic_asset_custodian(
        user_address: address,
        market_id: u64,
        amount: u64,
        custodian_capability_ref: &CustodianCapability,
        underwriter_capability_ref: &UnderwriterCapability
    ) acquires
        Collateral,
        MarketAccounts
    {
        withdraw_generic_asset(
            user_address,
            market_id,
            registry::get_custodian_id(custodian_capability_ref),
            amount,
            underwriter_capability_ref)
    }

    /// Wrapped call to `withdraw_generic_asset()` for withdrawing under
    /// authority of signing user.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    public fun withdraw_generic_asset_user(
        user: &signer,
        market_id: u64,
        amount: u64,
        underwriter_capability_ref: &UnderwriterCapability
    ) acquires
        Collateral,
        MarketAccounts
    {
        withdraw_generic_asset(
            address_of(user),
            market_id,
            NO_CUSTODIAN,
            amount,
            underwriter_capability_ref)
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

    #[cmd]
    /// Wrapped call to `withdraw_coins_user()` for withdrawing from
    /// market account to user's `aptos_framework::coin::CoinStore`.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    public entry fun withdraw_to_coinstore<
        CoinType
    >(
        user: &signer,
        market_id: u64,
        amount: u64,
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Register coin store if user does not have one.
        if (!coin::is_account_registered<CoinType>(address_of(user)))
            coin::register<CoinType>(user);
        // Deposit to coin store coins withdrawn from market account.
        coin::deposit<CoinType>(address_of(user), withdraw_coins_user(
            user, market_id, amount));
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Fill a user's order, routing collateral appropriately.
    ///
    /// Updates asset counts in a user's market account. Transfers
    /// coins as needed between a user's collateral, and an external
    /// source of coins passing through the matching engine. If a
    /// complete fill, pushes the newly inactive order to the top of the
    /// inactive orders stack for the given side.
    ///
    /// Should only be called by the matching engine, which has already
    /// calculated the corresponding amount of assets to fill. If the
    /// matching engine gets to this stage, then the user has an open
    /// order as indicated with sufficient assets to fill it. Hence no
    /// error checking.
    ///
    /// # Type parameters
    ///
    /// * `BaseType`: Base type for indicated market.
    /// * `QuoteType`: Quote type for indicated market.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `side`: `ASK` or `BID`, the side of the open order.
    /// * `order_access_key`: The open order's access key.
    /// * `fill_size`: The number of lots filled.
    /// * `complete_fill`: `true` if order is completely filled.
    /// * `optional_base_coins_ref_mut`: Mutable reference to optional
    ///   external base coins passing through the matching engine.
    /// * `quote_coins_ref_mut`: Mutable reference to quote coins
    ///   passing through the matching engine.
    /// * `base_to_route`: Amount of base asset filled.
    /// * `quote_to_route`: Amount of quote asset filled.
    ///
    /// # Assumptions
    ///
    /// * Only called by the matching engine as described above.
    public(friend) fun fill_order_internal<
        BaseType,
        QuoteType
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
        order_access_key: u64,
        fill_size: u64,
        complete_fill: bool,
        optional_base_coins_ref_mut: &mut Option<Coin<BaseType>>,
        quote_coins_ref_mut: &mut Coin<QuoteType>,
        base_to_route: u64,
        quote_to_route: u64
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Mutably borrow market accounts map.
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        let market_account_ref_mut = // Mutably borrow market account.
            table::borrow_mut(market_accounts_map_ref_mut, market_account_id);
        let ( // Mutably borrow corresponding orders tablist,
            orders_ref_mut,
            stack_top_ref_mut, // Inactive orders stack top,
            asset_in, // Amount of inbound asset,
            asset_in_total_ref_mut, // Inbound asset total field,
            asset_in_available_ref_mut, // Available field,
            asset_out, // Amount of outbound asset,
            asset_out_total_ref_mut, // Outbound asset total field,
            asset_out_ceiling_ref_mut, // And ceiling field.
        ) = if (side == ASK) ( // If an ask is matched:
            &mut market_account_ref_mut.asks,
            &mut market_account_ref_mut.asks_stack_top,
            quote_to_route,
            &mut market_account_ref_mut.quote_total,
            &mut market_account_ref_mut.quote_available,
            base_to_route,
            &mut market_account_ref_mut.base_total,
            &mut market_account_ref_mut.base_ceiling,
        ) else ( // If a bid is matched
            &mut market_account_ref_mut.bids,
            &mut market_account_ref_mut.bids_stack_top,
            base_to_route,
            &mut market_account_ref_mut.base_total,
            &mut market_account_ref_mut.base_available,
            quote_to_route,
            &mut market_account_ref_mut.quote_total,
            &mut market_account_ref_mut.quote_ceiling,
        );
        let order_ref_mut = // Mutably borrow corresponding order.
            tablist::borrow_mut(orders_ref_mut, order_access_key);
        if (complete_fill) { // If completely filling order:
            // Clear out order's market order ID field.
            order_ref_mut.market_order_id = (NIL as u128);
            // Mark order's size field to indicate inactive stack top.
            order_ref_mut.size = *stack_top_ref_mut;
            // Reassign stack top field to indicate new inactive order.
            *stack_top_ref_mut = order_access_key;
        } else { // If only partially filling the order:
            // Decrement amount still unfilled on order.
            order_ref_mut.size = order_ref_mut.size - fill_size;
        };
        // Increment asset in total amount by asset in amount.
        *asset_in_total_ref_mut = *asset_in_total_ref_mut + asset_in;
        // Increment asset in available amount by asset in amount.
        *asset_in_available_ref_mut = *asset_in_available_ref_mut + asset_in;
        // Decrement asset out total amount by asset out amount.
        *asset_out_total_ref_mut = *asset_out_total_ref_mut - asset_out;
        // Decrement asset out ceiling amount by asset out amount.
        *asset_out_ceiling_ref_mut = *asset_out_ceiling_ref_mut - asset_out;
        // If base coins to route:
        if (option::is_some(optional_base_coins_ref_mut)) {
            // Mutably borrow base collateral map.
            let collateral_map_ref_mut =
                &mut borrow_global_mut<Collateral<BaseType>>(user_address).map;
            let collateral_ref_mut = // Mutably borrow base collateral.
                tablist::borrow_mut(collateral_map_ref_mut, market_account_id);
            let base_coins_ref_mut = // Mutably borrow external coins.
                option::borrow_mut(optional_base_coins_ref_mut);
            // If filling as ask, merge to external coins those
            // extracted from user's collateral. Else if a bid, merge to
            // user's collateral those extracted from external coins.
            if (side == ASK)
                coin::merge(base_coins_ref_mut,
                    coin::extract(collateral_ref_mut, base_to_route)) else
                coin::merge(collateral_ref_mut,
                    coin::extract(base_coins_ref_mut, base_to_route));
        };
        // Mutably borrow quote collateral map.
        let collateral_map_ref_mut =
            &mut borrow_global_mut<Collateral<QuoteType>>(user_address).map;
        let collateral_ref_mut = // Mutably borrow quote collateral.
            tablist::borrow_mut(collateral_map_ref_mut, market_account_id);
        // If filling an ask, merge to user's collateral coins extracted
        // from external coins. Else if a bid, merge to external coins
        // those extracted from user's collateral.
        if (side == ASK)
            coin::merge(collateral_ref_mut,
                coin::extract(quote_coins_ref_mut, quote_to_route)) else
            coin::merge(quote_coins_ref_mut,
                coin::extract(collateral_ref_mut, quote_to_route));
    }

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
    public(friend) fun get_asset_counts_internal(
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
        // Assert user has market account for given market account ID.
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

    /// Cancel order from a user's tablist of open orders on given side.
    ///
    /// Updates asset counts, pushes order onto top of inactive orders
    /// stack and overwrites its fields accordingly.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `side`: `ASK` or `BID`, the side on which an order was placed.
    /// * `size`: Order size, in lots.
    /// * `price`: Order price, in ticks per lot.
    /// * `order_access_key`: Order access key for user order lookup.
    /// * `market_order_id`: Market order ID for order book lookup.
    ///
    /// # Terminology
    ///
    /// * The "inbound" asset is the asset that would have been received
    ///   from a trade if the cancelled order had been filled.
    /// * The "outbound" asset is the asset that would have been traded
    ///   away if the cancelled order had been filled.
    ///
    /// # Aborts
    ///
    /// * `E_INVALID_MARKET_ORDER_ID`: Market order ID mismatch with
    ///   user's open order.
    ///
    /// # Assumptions
    ///
    /// * Only called when also cancelling an order from the order book.
    /// * User has an open order under indicated market account with
    ///   provided access key, but not necessarily with provided market
    ///   order ID: if order is cancelled from the book, then it had to
    ///   have been successfully placed on the book to begin with for
    ///   the given access key. Market order IDs, however, are not
    ///   maintained in order book state and so could be potentially
    ///   passed erroneously.
    /// * `price` matches that encoded in market order ID from cancelled
    ///   order.
    ///
    /// # Expected value testing
    ///
    /// * `test_place_cancel_order_ask()`
    /// * `test_place_cancel_order_bid()`
    /// * `test_place_cancel_order_stack()`
    ///
    /// # Failure testing
    ///
    /// * `test_cancel_order_internal_mismatch()`
    public(friend) fun cancel_order_internal(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
        price: u64,
        order_access_key: u64,
        market_order_id: u128
    ) acquires MarketAccounts {
        // Mutably borrow market accounts map.
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        let market_account_ref_mut = // Mutably borrow market account.
            table::borrow_mut(market_accounts_map_ref_mut, market_account_id);
        // Mutably borrow orders tablist, inactive orders stack top,
        // inbound asset ceiling, and outbound asset available fields,
        // and determine size multiplier for calculating change in
        // available and ceiling fields, based on order side.
        let (orders_ref_mut, stack_top_ref_mut, in_ceiling_ref_mut,
             out_available_ref_mut, size_multiplier_ceiling,
             size_multiplier_available) = if (side == ASK) (
                &mut market_account_ref_mut.asks,
                &mut market_account_ref_mut.asks_stack_top,
                &mut market_account_ref_mut.quote_ceiling,
                &mut market_account_ref_mut.base_available,
                price * market_account_ref_mut.tick_size,
                market_account_ref_mut.lot_size
            ) else (
                &mut market_account_ref_mut.bids,
                &mut market_account_ref_mut.bids_stack_top,
                &mut market_account_ref_mut.base_ceiling,
                &mut market_account_ref_mut.quote_available,
                market_account_ref_mut.lot_size,
                price * market_account_ref_mut.tick_size);
        let order_ref_mut = // Mutably borrow order to remove.
            tablist::borrow_mut(orders_ref_mut, order_access_key);
        let size = order_ref_mut.size; // Store order's size field.
        // Assert market order ID on order is as expected.
        assert!(order_ref_mut.market_order_id == market_order_id,
                E_INVALID_MARKET_ORDER_ID);
        // Clear out order's market order ID field.
        order_ref_mut.market_order_id = (NIL as u128);
        // Mark order's size field to indicate top of inactive stack.
        order_ref_mut.size = *stack_top_ref_mut;
        // Reassign stack top field to indicate newly inactive order.
        *stack_top_ref_mut = order_access_key;
        // Calculate increment amount for outbound available field.
        let available_increment_amount = size * size_multiplier_available;
        *out_available_ref_mut = // Increment available field.
            *out_available_ref_mut + available_increment_amount;
        // Calculate decrement amount for inbound ceiling field.
        let ceiling_decrement_amount = size * size_multiplier_ceiling;
        *in_ceiling_ref_mut = // Decrement ceiling field.
            *in_ceiling_ref_mut - ceiling_decrement_amount;
    }

    /// Change the size of a user's open order on given side.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `side`: `ASK` or `BID`, the side on which an order was placed.
    /// * `new_size`: New order size, in lots.
    /// * `price`: Order price, in ticks per lot.
    /// * `order_access_key`: Order access key for user order lookup.
    /// * `market_order_id`: Market order ID for order book lookup.
    ///
    /// # Aborts
    ///
    /// * `E_CHANGE_ORDER_NO_CHANGE`: No change in order size.
    ///
    /// # Assumptions
    ///
    /// * Only called when also changing order size on the order book.
    /// * User has an open order as specified: if order is changed on
    ///   the book, then it had to have been placed on the book
    ///   successfully to begin with.
    /// * `price` matches that encoded in market order ID for changed
    ///   order.
    ///
    /// # Testing
    ///
    /// * `test_change_order_size_internal_ask()`
    /// * `test_change_order_size_internal_bid()`
    /// * `test_change_order_size_internal_no_change()`
    public(friend) fun change_order_size_internal(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
        new_size: u64,
        price: u64,
        order_access_key: u64,
        market_order_id: u128
    ) acquires MarketAccounts {
        // Mutably borrow market accounts map.
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        let market_account_ref_mut = // Mutably borrow market account.
            table::borrow_mut(market_accounts_map_ref_mut, market_account_id);
        // Immutably borrow corresponding orders tablist based on side.
        let orders_ref = if (side == ASK)
            &market_account_ref_mut.asks else &market_account_ref_mut.bids;
        // Immutably borrow order.
        let order_ref = tablist::borrow(orders_ref, order_access_key);
        // Assert change in size.
        assert!(order_ref.size != new_size, E_CHANGE_ORDER_NO_CHANGE);
        // Cancel order with size to be changed.
        cancel_order_internal(user_address, market_id, custodian_id, side,
                              price, order_access_key, market_order_id);
        // Place order with new size.
        place_order_internal(user_address, market_id, custodian_id, side,
                             new_size, price, market_order_id);
    }

    /// Return all active market order IDs for given market account.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `side`: `ASK` or `BID`, the side on which to check.
    ///
    /// # Returns
    ///
    /// * `vector<u128>`: Vector of all active market order IDs for
    ///   given market account and side, empty if none.
    ///
    /// # Aborts
    ///
    /// * `E_NO_MARKET_ACCOUNTS`: No market accounts resource found.
    /// * `E_NO_MARKET_ACCOUNT`: No market account resource found.
    ///
    /// # Testing
    ///
    /// * `test_get_active_market_order_ids_internal()`
    /// * `test_get_active_market_order_ids_internal_no_account()`
    /// * `test_get_active_market_order_ids_internal_no_accounts()`
    public(friend) fun get_active_market_order_ids_internal(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
    ): vector<u128>
    acquires MarketAccounts {
        // Assert user has market accounts resource.
        assert!(exists<MarketAccounts>(user_address), E_NO_MARKET_ACCOUNTS);
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        // Assert user has market account for given market account ID.
        assert!(table::contains(market_accounts_map_ref, market_account_id),
                E_NO_MARKET_ACCOUNT);
        let market_account_ref = // Immutably borrow market account.
            table::borrow(market_accounts_map_ref, market_account_id);
        // Immutably borrow corresponding orders tablist based on side.
        let orders_ref = if (side == ASK)
            &market_account_ref.asks else &market_account_ref.bids;
        // Initialize empty vector of market order IDs.
        let market_order_ids = vector::empty();
        // Initialize 1-indexed loop counter and get number of orders.
        let (i, n) = (1, tablist::length(orders_ref));
        while (i <= n) { // Loop over all allocated orders.
            // Immutably borrow order with given access key.
            let order_ref = tablist::borrow(orders_ref, i);
            // If order is active, push back its market order ID.
            if (order_ref.market_order_id != (NIL as u128)) vector::push_back(
                &mut market_order_ids, order_ref.market_order_id);
            i = i + 1; // Increment loop counter.
        };
        market_order_ids // Return market order IDs.
    }

    /// Place order in user's tablist of open orders on given side.
    ///
    /// Range checks order parameters and updates asset counts
    /// accordingly.
    ///
    /// Allocates a new order if the inactive order stack is empty,
    /// otherwise pops one off the top of the stack and overwrites it.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `side`: `ASK` or `BID`, the side on which an order is placed.
    /// * `size`: Order size, in lots.
    /// * `price`: Order price, in ticks per lot.
    /// * `market_order_id`: Market order ID for order book access.
    ///
    /// # Terminology
    ///
    /// * The "inbound" asset is the asset received from a trade.
    /// * The "outbound" asset is the asset traded away.
    ///
    /// # Assumptions
    ///
    /// * Only called when also placing an order on the order book.
    /// * `price` matches that encoded in `market_order_id`.
    ///
    /// # Aborts
    ///
    /// * `E_PRICE_0`: Price is zero.
    /// * `E_PRICE_TOO_HIGH`: Price exceeds maximum possible price.
    /// * `E_NO_MARKET_ACCOUNTS`: No market accounts resource found.
    /// * `E_NO_MARKET_ACCOUNT`: No market account resource found.
    /// * `E_SIZE_TOO_LOW`: Size is below minimum size for market.
    /// * `E_TICKS_OVERFLOW`: Ticks to fill order overflows a `u64`.
    /// * `E_OVERFLOW_ASSET_IN`: Filling order would overflow asset
    ///   received from trade.
    /// * `E_NOT_ENOUGH_ASSET_OUT`: Not enough asset to trade away.
    ///
    /// # Expected value testing
    ///
    /// * `test_place_cancel_order_ask()`
    /// * `test_place_cancel_order_bid()`
    /// * `test_place_cancel_order_stack()`
    ///
    /// # Failure testing
    ///
    /// * `test_place_order_internal_in_overflow()`
    /// * `test_place_order_internal_no_account()`
    /// * `test_place_order_internal_no_accounts()`
    /// * `test_place_order_internal_out_underflow()`
    /// * `test_place_order_internal_price_0()`
    /// * `test_place_order_internal_price_hi()`
    /// * `test_place_order_internal_size_lo()`
    /// * `test_place_order_internal_ticks_overflow()`
    public(friend) fun place_order_internal(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        side: bool,
        size: u64,
        price: u64,
        market_order_id: u128
    ) acquires MarketAccounts {
        assert!(price > 0, E_PRICE_0); // Assert price is nonzero.
        // Assert price is not too high.
        assert!(price <= MAX_PRICE, E_PRICE_TOO_HIGH);
        // Assert user has market accounts resource.
        assert!(exists<MarketAccounts>(user_address), E_NO_MARKET_ACCOUNTS);
        // Mutably borrow market accounts map.
        let market_accounts_map_ref_mut =
            &mut borrow_global_mut<MarketAccounts>(user_address).map;
        let market_account_id = // Get market account ID.
            ((market_id as u128) << SHIFT_MARKET_ID) | (custodian_id as u128);
        let has_market_account = // Check if user has market account.
            table::contains(market_accounts_map_ref_mut, market_account_id);
        // Assert user has market account for given market account ID.
        assert!(has_market_account, E_NO_MARKET_ACCOUNT);
        let market_account_ref_mut = // Mutably borrow market account.
            table::borrow_mut(market_accounts_map_ref_mut, market_account_id);
        // Assert order size is greater than or equal to market minimum.
        assert!(size >= market_account_ref_mut.min_size, E_SIZE_TOO_LOW);
        let base_fill = // Calculate base units needed to fill order.
            (size as u128) * (market_account_ref_mut.lot_size as u128);
        // Calculate ticks to fill order.
        let ticks = (size as u128) * (price as u128);
        // Assert ticks to fill order is not too large.
        assert!(ticks <= (HI_64 as u128), E_TICKS_OVERFLOW);
        // Calculate quote units to fill order.
        let quote_fill = ticks * (market_account_ref_mut.tick_size as u128);
        // Mutably borrow orders tablist, inactive orders stack top,
        // inbound asset ceiling, and outbound asset available fields,
        // and assign inbound and outbound asset fill amounts, based on
        // order side.
        let (orders_ref_mut, stack_top_ref_mut, in_ceiling_ref_mut,
             out_available_ref_mut, in_fill, out_fill) = if (side == ASK)
             (&mut market_account_ref_mut.asks,
              &mut market_account_ref_mut.asks_stack_top,
              &mut market_account_ref_mut.quote_ceiling,
              &mut market_account_ref_mut.base_available,
              quote_fill, base_fill) else
             (&mut market_account_ref_mut.bids,
              &mut market_account_ref_mut.bids_stack_top,
              &mut market_account_ref_mut.base_ceiling,
              &mut market_account_ref_mut.quote_available,
              base_fill, quote_fill);
        // Assert no inbound asset overflow.
        assert!((in_fill + (*in_ceiling_ref_mut as u128)) <= (HI_64 as u128),
                E_OVERFLOW_ASSET_IN);
        // Assert enough outbound asset to cover the fill, which also
        // ensures outbound fill amount does not overflow.
        assert!((out_fill <= (*out_available_ref_mut as u128)),
                E_NOT_ENOUGH_ASSET_OUT);
        // Update ceiling for inbound asset.
        *in_ceiling_ref_mut = *in_ceiling_ref_mut + (in_fill as u64);
        // Update available amount for outbound asset.
        *out_available_ref_mut = *out_available_ref_mut - (out_fill as u64);
        if (*stack_top_ref_mut == NIL) { // If empty inactive stack:
            // Get one-indexed order access key for new order.
            let order_access_key = tablist::length(orders_ref_mut) + 1;
            // Allocate new order.
            tablist::add(orders_ref_mut, order_access_key, Order{
                market_order_id, size});
        } else { // If inactive order stack not empty:
            let order_ref_mut = // Mutably borrow order at top of stack.
                tablist::borrow_mut(orders_ref_mut, *stack_top_ref_mut);
            // Reassign stack top field to next in stack.
            *stack_top_ref_mut = order_ref_mut.size;
            // Reassign market order ID for active order.
            order_ref_mut.market_order_id = market_order_id;
            order_ref_mut.size = size; // Reassign order size field.
        };
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
        let has_market_account = // Check if user has market account.
            table::contains(market_accounts_map_ref_mut, market_account_id);
        // Assert user has market account for given market account ID.
        assert!(has_market_account, E_NO_MARKET_ACCOUNT);
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
        // If asset is generic:
        if (asset_type == type_info::type_of<GenericAsset>()) {
            assert!(underwriter_id == market_account_ref_mut.underwriter_id,
                    E_INVALID_UNDERWRITER); // Assert underwriter ID.
            option::destroy_none(optional_coins); // Destroy option.
        } else { // If asset is coin:
            // Mutably borrow collateral map.
            let collateral_map_ref_mut = &mut borrow_global_mut<
                Collateral<AssetType>>(user_address).map;
            // Mutably borrow collateral for market account.
            let collateral_ref_mut = tablist::borrow_mut(
                collateral_map_ref_mut, market_account_id);
            coin::merge( // Merge optional coins into collateral.
                collateral_ref_mut, option::destroy_some(optional_coins));
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

    /// Withdraw an asset from a user's market account.
    ///
    /// Update asset counts, withdraw optional collateral coins.
    ///
    /// # Type parameters
    ///
    /// * `AssetType`: Asset type to withdraw, `registry::GenericAsset`
    ///   if a generic asset.
    ///
    /// # Parameters
    ///
    /// * `user_address`: User address for market account.
    /// * `market_id`: Market ID for market account.
    /// * `custodian_id`: Custodian ID for market account.
    /// * `amount`: Amount to withdraw.
    /// * `underwriter_id`: Underwriter ID for market, ignored when
    ///   withdrawing coins.
    ///
    /// # Returns
    ///
    /// * `Option<Coin<AssetType>>`: Optional collateral coins.
    ///
    /// # Aborts
    ///
    /// * `E_NO_MARKET_ACCOUNTS`: No market accounts resource found.
    /// * `E_NO_MARKET_ACCOUNT`: No market account resource found.
    /// * `E_ASSET_NOT_IN_PAIR`: Asset type is not in trading pair for
    ///    market.
    /// * `E_WITHDRAW_TOO_LITTLE_AVAILABLE`: Too little available for
    ///   withdrawal.
    /// * `E_INVALID_UNDERWRITER`: Underwriter is not valid for
    ///   indicated market, in the case of a generic asset withdrawal.
    ///
    /// # Testing
    ///
    /// * `test_withdraw_asset_no_account()`
    /// * `test_withdraw_asset_no_accounts()`
    /// * `test_withdraw_asset_not_in_pair()`
    /// * `test_withdraw_asset_underflow()`
    /// * `test_withdraw_asset_underwriter()`
    /// * `test_withdrawals()`
    fun withdraw_asset<
        AssetType
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
        underwriter_id: u64
    ): Option<Coin<AssetType>>
    acquires
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
        let has_market_account = // Check if user has market account.
            table::contains(market_accounts_map_ref_mut, market_account_id);
        // Assert user has market account for given market account ID.
        assert!(has_market_account, E_NO_MARKET_ACCOUNT);
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
        // Assert enough asset available for withdraw.
        assert!(amount <= *available_ref_mut, E_WITHDRAW_TOO_LITTLE_AVAILABLE);
        *total_ref_mut = *total_ref_mut - amount; // Update total.
        // Update available asset amount.
        *available_ref_mut = *available_ref_mut - amount;
        *ceiling_ref_mut = *ceiling_ref_mut - amount; // Update ceiling.
        // Return based on if asset type. If is generic:
        return if (asset_type == type_info::type_of<GenericAsset>()) {
            assert!(underwriter_id == market_account_ref_mut.underwriter_id,
                    E_INVALID_UNDERWRITER); // Assert underwriter ID.
            option::none() // Return empty option.
        } else { // If asset is coin:
            // Mutably borrow collateral map.
            let collateral_map_ref_mut = &mut borrow_global_mut<
                Collateral<AssetType>>(user_address).map;
            // Mutably borrow collateral for market account.
            let collateral_ref_mut = tablist::borrow_mut(
                collateral_map_ref_mut, market_account_id);
            // Withdraw coin and return in an option.
            option::some<Coin<AssetType>>(
                coin::extract(collateral_ref_mut, amount))
        }
    }

    /// Wrapped call to `withdraw_asset()` for withdrawing generic
    /// asset.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    fun withdraw_generic_asset(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
        underwriter_capability_ref: &UnderwriterCapability
    ) acquires
        Collateral,
        MarketAccounts
    {
        option::destroy_none(withdraw_asset<GenericAsset>(
            user_address,
            market_id,
            custodian_id,
            amount,
            registry::get_underwriter_id(underwriter_capability_ref)))
    }

    /// Wrapped call to `withdraw_asset()` for withdrawing coins.
    ///
    /// # Testing
    ///
    /// * `test_withdrawals()`
    fun withdraw_coins<
        CoinType
    >(
        user_address: address,
        market_id: u64,
        custodian_id: u64,
        amount: u64,
    ): Coin<CoinType>
    acquires
        Collateral,
        MarketAccounts
    {
        option::destroy_some(withdraw_asset<CoinType>(
            user_address,
            market_id,
            custodian_id,
            amount,
            NO_UNDERWRITER))
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base asset starting amount for testing.
    const BASE_START: u64 = 7500000000;
    #[test_only]
    /// Quote asset starting amount for testing.
    const QUOTE_START: u64 = 8000000000;

    #[test_only]
    /// Custodian ID for market with delegated custodian.
    const CUSTODIAN_ID: u64 = 123;
    #[test_only]
    /// Market ID for generic test market.
    const MARKET_ID_GENERIC: u64 = 2;
    #[test_only]
    /// Market ID for pure coin test market.
    const MARKET_ID_PURE_COIN: u64 = 1;
    #[test_only]
    /// From `registry::register_markets_test()`. Underwriter ID for
    /// generic test market.
    const UNDERWRITER_ID: u64 = 7;

    #[test_only]
    /// From `registry::register_markets_test()`.
    const LOT_SIZE_PURE_COIN: u64 = 1;
    #[test_only]
    /// From `registry::register_markets_test()`.
    const TICK_SIZE_PURE_COIN: u64 = 2;
    #[test_only]
    /// From `registry::register_markets_test()`.
    const MIN_SIZE_PURE_COIN: u64 = 3;
    #[test_only]
    /// From `registry::register_markets_test()`.
    const LOT_SIZE_GENERIC: u64 = 4;
    #[test_only]
    /// From `registry::register_markets_test()`.
    const TICK_SIZE_GENERIC: u64 = 5;
    #[test_only]
    /// From `registry::register_markets_test()`.
    const MIN_SIZE_GENERIC: u64 = 6;

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
    /// Get order access key at top of inactive order stack.
    public fun get_inactive_stack_top_test(
        user_address: address,
        market_account_id: u128,
        side: bool,
    ): u64
    acquires MarketAccounts {
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user_address).map;
        let market_account_ref = // Immutably borrow market account.
            table::borrow(market_accounts_map_ref, market_account_id);
        // Return corresponding stack top field.
        if (side == ASK) market_account_ref.asks_stack_top else
            market_account_ref.bids_stack_top
    }

    #[test_only]
    /// Return next inactive order in inactive orders stack.
    public fun get_next_inactive_order_test(
        user_address: address,
        market_account_id: u128,
        side: bool,
        order_access_key: u64
    ): u64
    acquires MarketAccounts {
        assert!(!is_order_active_test( // Assert order is inactive.
            user_address, market_account_id, side, order_access_key), 0);
        // Get order's size field, indicating next inactive order.
        let (_, next) = get_order_fields_test(
            user_address, market_account_id, side, order_access_key);
        next // Return next inactive order access key.
    }

    #[test_only]
    /// Return order fields for given order parameters.
    public fun get_order_fields_test(
        user_address: address,
        market_account_id: u128,
        side: bool,
        order_access_key: u64
    ): (
        u128,
        u64
    ) acquires MarketAccounts {
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user_address).map;
        let market_account_ref = // Immutably borrow market account.
            table::borrow(market_accounts_map_ref, market_account_id);
        // Immutably borrow corresponding orders tablist based on side.
        let (orders_ref) = if (side == ASK)
            &market_account_ref.asks else &market_account_ref.bids;
        // Immutably borrow order.
        let order_ref = tablist::borrow(orders_ref, order_access_key);
        // Return order fields.
        (order_ref.market_order_id, order_ref.size)
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
    /// Check if user has allocated order for given parameters.
    public fun has_order_test(
        user_address: address,
        market_account_id: u128,
        side: bool,
        order_access_key: u64
    ): bool
    acquires MarketAccounts {
        // Immutably borrow market accounts map.
        let market_accounts_map_ref =
            &borrow_global<MarketAccounts>(user_address).map;
        let market_account_ref = // Immutably borrow market account.
            table::borrow(market_accounts_map_ref, market_account_id);
        // Immutably borrow corresponding orders tablist based on side.
        let (orders_ref) = if (side == ASK)
            &market_account_ref.asks else &market_account_ref.bids;
        tablist::contains(orders_ref, order_access_key)
    }

    #[test_only]
    /// Register market accounts under test `@user`, return signer and
    /// market account ID of:
    ///
    /// * Pure coin self-custodied market account.
    /// * Pure coin market account with delegated custodian.
    /// * Generic self-custodian market account.
    /// * Generic market account with delegated custodian.
    fun register_market_accounts_test(): (
        signer,
        u128,
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
        // Register a pure coin and a generic market, storing most
        // returns.
        let (market_id_pure_coin, _, lot_size_pure_coin, tick_size_pure_coin,
             min_size_pure_coin, underwriter_id_pure_coin, market_id_generic,
             _, lot_size_generic, tick_size_generic, min_size_generic,
             underwriter_id_generic) = registry::register_markets_test();
        // Assert market info.
        assert!(market_id_pure_coin      == MARKET_ID_PURE_COIN, 0);
        assert!(lot_size_pure_coin       == LOT_SIZE_PURE_COIN, 0);
        assert!(tick_size_pure_coin      == TICK_SIZE_PURE_COIN, 0);
        assert!(min_size_pure_coin       == MIN_SIZE_PURE_COIN, 0);
        assert!(underwriter_id_pure_coin == NO_UNDERWRITER, 0);
        assert!(market_id_generic        == MARKET_ID_GENERIC, 0);
        assert!(lot_size_generic         == LOT_SIZE_GENERIC, 0);
        assert!(tick_size_generic        == TICK_SIZE_GENERIC, 0);
        assert!(min_size_generic         == MIN_SIZE_GENERIC, 0);
        assert!(underwriter_id_generic   == UNDERWRITER_ID, 0);
        // Register self-custodied pure coin account.
        register_market_account<BC, QC>(
            &user, market_id_pure_coin, NO_CUSTODIAN);
        // Set delegated custodian ID as registered.
        registry::set_registered_custodian_test(CUSTODIAN_ID);
        // Register delegated custody pure coin account.
        register_market_account<BC, QC>(
            &user, market_id_pure_coin, CUSTODIAN_ID);
        // Register self-custodied generic asset account.
        register_market_account_generic_base<QC>(
            &user, market_id_generic, NO_CUSTODIAN);
        // Register delegated custody generic asset account.
        register_market_account_generic_base<QC>(
            &user, market_id_generic, CUSTODIAN_ID);
        // Get market account IDs.
        let market_account_id_coin_self =
            get_market_account_id(market_id_pure_coin, NO_CUSTODIAN);
        let market_account_id_coin_delegated =
            get_market_account_id(market_id_pure_coin, CUSTODIAN_ID);
        let market_account_id_generic_self =
            get_market_account_id(market_id_generic  , NO_CUSTODIAN);
        let market_account_id_generic_delegated =
            get_market_account_id(market_id_generic  , CUSTODIAN_ID);
        (user, // Return signing user and market account IDs.
         market_account_id_coin_self,
         market_account_id_coin_delegated,
         market_account_id_generic_self,
         market_account_id_generic_delegated)
    }

    #[test_only]
    /// Return `true` if order is active.
    public fun is_order_active_test(
        user_address: address,
        market_account_id: u128,
        side: bool,
        order_access_key: u64
    ): bool
    acquires MarketAccounts {
        // Get order's market order ID field.
        let (market_order_id, _) = get_order_fields_test(
            user_address, market_account_id, side, order_access_key);
        market_order_id != (NIL as u128) // Return true if non-null ID.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    #[expected_failure(abort_code = 15)]
    /// Verify failure for market account ID mismatch.
    fun test_cancel_order_internal_mismatch()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register test markets.
        // Define order parameters.
        let market_order_id = 123;
        let size            = MIN_SIZE_PURE_COIN;
        let price           = 1;
        let side            = BID;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Place order
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
        // Attempt invalid cancellation.
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                              price, 1, market_order_id + 1);
    }

    #[test]
    /// Verify state updates for changing ask size. Based on
    /// `test_place_cancel_order_ask()`.
    fun test_change_order_size_internal_ask()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register test markets.
        // Define order parameters.
        let market_order_id  = 1234;
        let size             = 789;
        let size_old         = size - 1;
        let price            = 321;
        let side             = ASK;
        let order_access_key = 1;
        // Calculate change in base asset and quote asset fields.
        let base_delta = size * LOT_SIZE_PURE_COIN;
        let quote_delta = size * price * TICK_SIZE_PURE_COIN;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Place order.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size_old, price, market_order_id);
        change_order_size_internal( // Change order size.
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side, size, price,
            order_access_key, market_order_id);
        // Assert asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(
                @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        assert!(base_total      == BASE_START , 0);
        assert!(base_available  == BASE_START - base_delta, 0);
        assert!(base_ceiling    == BASE_START , 0);
        assert!(quote_total     == QUOTE_START, 0);
        assert!(quote_available == QUOTE_START, 0);
        assert!(quote_ceiling   == QUOTE_START + quote_delta, 0);
    }

    #[test]
    /// Verify state updates for changing bid size. Based on
    /// `test_place_cancel_order_bid()`.
    fun test_change_order_size_internal_bid()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register test markets.
        // Define order parameters.
        let market_order_id  = 1234;
        let size             = 789;
        let size_old         = size - 1;
        let price            = 321;
        let side             = BID;
        let order_access_key = 1;
        // Calculate change in base asset and quote asset fields.
        let base_delta = size * LOT_SIZE_PURE_COIN;
        let quote_delta = size * price * TICK_SIZE_PURE_COIN;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Place order.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size_old, price, market_order_id);
        change_order_size_internal( // Change order size.
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side, size, price,
            order_access_key, market_order_id);
        // Assert asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(
                @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        assert!(base_total      == BASE_START , 0);
        assert!(base_available  == BASE_START , 0);
        assert!(base_ceiling    == BASE_START + base_delta, 0);
        assert!(quote_total     == QUOTE_START, 0);
        assert!(quote_available == QUOTE_START - quote_delta, 0);
        assert!(quote_ceiling   == QUOTE_START, 0);
    }

    #[test]
    #[expected_failure(abort_code = 14)]
    /// Verify failure for no change in size.
    fun test_change_order_size_internal_no_change()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register test markets.
        // Define order parameters.
        let market_order_id = 123;
        let size            = MIN_SIZE_PURE_COIN;
        let price           = 1;
        let side            = BID;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Place order
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
        change_order_size_internal( // Attempt invalid order size change.
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side, size, price,
            1, market_order_id);
    }

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
        let (user, _, market_account_id_coin_delegated,
                      market_account_id_generic_self, _) =
             register_market_accounts_test();
        coin::register<QC>(&user); // Register coin store.
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
    /// Verify expected returns.
    fun test_get_active_market_order_ids_internal()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        // Define order parameters.
        let market_order_id_1 = 123;
        let market_order_id_2 = 234;
        let market_order_id_3 = 345;
        let market_order_id_4 = 456;
        let size              = MIN_SIZE_PURE_COIN;
        let price             = 1;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Assert empty returns.
        assert!(get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, ASK) == vector[], 0);
        assert!(get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, BID) == vector[], 0);
        // Place three asks, then cancel second ask.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, ASK,
                             size, price, market_order_id_1);
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, ASK,
                             size, price, market_order_id_2);
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, ASK,
                             size, price, market_order_id_3);
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, ASK,
                              price, 2, market_order_id_2);
        // Get expected market order IDs vector.
        let expected = vector[market_order_id_1, market_order_id_3];
        // Assert expected return.
        assert!(get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, ASK) == expected, 0);
        // Place single bid.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, BID,
                             size, price, market_order_id_4);
        // Get expected market order IDs vector.
        expected = vector[market_order_id_4];
        // Assert expected return.
        assert!(get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, BID) == expected, 0);
        // Cancel order.
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, BID,
                              price, 1, market_order_id_4);
        // Assert expected return.
        assert!(get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, BID) == vector[], 0);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no market account resource.
    fun test_get_active_market_order_ids_internal_no_account()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        register_market_accounts_test();
        // Attempt invalid invocation.
        get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN + 10, CUSTODIAN_ID, BID);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for no market accounts resource.
    fun test_get_active_market_order_ids_internal_no_accounts()
    acquires MarketAccounts {
        // Attempt invalid invocation.
        get_active_market_order_ids_internal(
            @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, BID);
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
            MARKET_ID_GENERIC  , NO_CUSTODIAN);
        let market_account_id_generic_delegated = get_market_account_id(
            MARKET_ID_GENERIC  , CUSTODIAN_ID);
        // Assert empty returns.
        assert!(get_all_market_account_ids_for_market_id(
                @user, MARKET_ID_PURE_COIN) == vector[], 0);
        assert!(get_all_market_account_ids_for_market_id(
                @user, MARKET_ID_GENERIC) == vector[], 0);
        assert!(get_all_market_account_ids_for_user(
                @user) == vector[], 0);
        // Assert false returns.
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_coin_self), 0);
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_coin_delegated), 0);
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_generic_self), 0);
        assert!(!has_market_account_by_market_account_id(
                @user, market_account_id_generic_delegated), 0);
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
        expected_ids = vector[market_account_id_generic_self,
                              market_account_id_generic_delegated];
        assert!(get_all_market_account_ids_for_market_id(
                @user, MARKET_ID_GENERIC) == expected_ids, 0);
        expected_ids = vector[market_account_id_coin_self,
                              market_account_id_coin_delegated,
                              market_account_id_generic_self,
                              market_account_id_generic_delegated];
        assert!(get_all_market_account_ids_for_user(
                @user) == expected_ids, 0);
        // Assert true returns.
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_coin_self), 0);
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_coin_delegated), 0);
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_generic_self), 0);
        assert!(has_market_account_by_market_account_id(
                @user, market_account_id_generic_delegated), 0);
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
        assert!(!has_market_account_by_market_account_id(
                @user_2, market_account_id_generic_delegated), 0);
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

    #[test]
    /// Verify valid state updates for placing and cancelling an ask.
    fun test_place_cancel_order_ask()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test markets, get market account ID for pure coin
        // market with delegated custodian.
        let (_, _, market_account_id, _, _) = register_market_accounts_test();
        // Define order parameters.
        let market_order_id  = 1234;
        let size             = 789;
        let price            = 321;
        let side             = ASK;
        let order_access_key = 1;
        // Calculate change in base asset and quote asset fields.
        let base_delta = size * LOT_SIZE_PURE_COIN;
        let quote_delta = size * price * TICK_SIZE_PURE_COIN;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == NIL, 0);
        // Place order.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
        // Assert asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(
                @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        assert!(base_total      == BASE_START , 0);
        assert!(base_available  == BASE_START - base_delta, 0);
        assert!(base_ceiling    == BASE_START , 0);
        assert!(quote_total     == QUOTE_START, 0);
        assert!(quote_available == QUOTE_START, 0);
        assert!(quote_ceiling   == QUOTE_START + quote_delta, 0);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == NIL, 0);
        // Assert order fields.
        let (market_order_id_r, size_r) = get_order_fields_test(
            @user, market_account_id, side, order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r == size, 0);
        // Cancel order.
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                              price, order_access_key, market_order_id);
        // Assert asset counts.
        (base_total , base_available , base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(
                @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        assert!(base_total      == BASE_START , 0);
        assert!(base_available  == BASE_START , 0);
        assert!(base_ceiling    == BASE_START , 0);
        assert!(quote_total     == QUOTE_START, 0);
        assert!(quote_available == QUOTE_START, 0);
        assert!(quote_ceiling   == QUOTE_START, 0);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == order_access_key, 0);
        // Assert order marked inactive.
        assert!(!is_order_active_test(
            @user, market_account_id, side, order_access_key), 0);
        // Assert next inactive node field.
        assert!(get_next_inactive_order_test(@user, market_account_id, side,
                                             order_access_key) == NIL, 0);
    }

    #[test]
    /// Verify valid state updates for placing and cancelling a bid.
    fun test_place_cancel_order_bid()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test markets, get market account ID for pure coin
        // market with delegated custodian.
        let (_, _, market_account_id, _, _) = register_market_accounts_test();
        // Define order parameters.
        let market_order_id  = 1234;
        let size             = 789;
        let price            = 321;
        let side             = BID;
        let order_access_key = 1;
        // Calculate change in base asset and quote asset fields.
        let base_delta = size * LOT_SIZE_PURE_COIN;
        let quote_delta = size * price * TICK_SIZE_PURE_COIN;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == NIL, 0);
        // Place order.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
        // Assert asset counts.
        let (base_total , base_available , base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(
                @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        assert!(base_total      == BASE_START , 0);
        assert!(base_available  == BASE_START , 0);
        assert!(base_ceiling    == BASE_START + base_delta, 0);
        assert!(quote_total     == QUOTE_START, 0);
        assert!(quote_available == QUOTE_START - quote_delta, 0);
        assert!(quote_ceiling   == QUOTE_START, 0);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == NIL, 0);
        // Assert order fields.
        let (market_order_id_r, size_r) = get_order_fields_test(
            @user, market_account_id, side, order_access_key);
        assert!(market_order_id_r == market_order_id, 0);
        assert!(size_r == size, 0);
        // Cancel order.
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                              price, order_access_key, market_order_id);
        // Assert asset counts.
        (base_total , base_available , base_ceiling,
         quote_total, quote_available, quote_ceiling) =
            get_asset_counts_internal(
                @user, MARKET_ID_PURE_COIN, CUSTODIAN_ID);
        assert!(base_total      == BASE_START , 0);
        assert!(base_available  == BASE_START , 0);
        assert!(base_ceiling    == BASE_START , 0);
        assert!(quote_total     == QUOTE_START, 0);
        assert!(quote_available == QUOTE_START, 0);
        assert!(quote_ceiling   == QUOTE_START, 0);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == order_access_key, 0);
        // Assert order marked inactive.
        assert!(!is_order_active_test(
            @user, market_account_id, side, order_access_key), 0);
        // Assert next inactive node field.
        assert!(get_next_inactive_order_test(@user, market_account_id, side,
                                             order_access_key) == NIL, 0);
    }

    #[test]
    /// Verify state updates for multiple pushes and pops from stack.
    fun test_place_cancel_order_stack()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test markets, get market account ID for pure coin
        // market with delegated custodian.
        let (_, _, market_account_id, _, _) = register_market_accounts_test();
        // Define order parameters.
        let market_order_id_1  = 123;
        let market_order_id_2  = 234;
        let market_order_id_3  = 345;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = 1;
        let side             = BID;
        // Deposit starting base and quote coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(BASE_START));
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(QUOTE_START));
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == NIL, 0);
        // Place two orders.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id_1);
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id_2);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == NIL, 0);
        // Cancel first order.
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                              price, 1, market_order_id_1);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == 1, 0);
        // Cancel second order.
        cancel_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                              price, 2, market_order_id_2);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == 2, 0);
        // Assert both orders marked inactive.
        assert!(!is_order_active_test(@user, market_account_id, side, 1), 0);
        assert!(!is_order_active_test(@user, market_account_id, side, 2), 0);
        // Assert next inactive node fields.
        assert!(get_next_inactive_order_test(
            @user, market_account_id, side, 2) == 1, 0);
        assert!(get_next_inactive_order_test(
            @user, market_account_id, side, 1) == NIL, 0);
        // Place an order
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id_3);
        // Assert inactive stack top on given side.
        assert!(get_inactive_stack_top_test(@user, market_account_id, side)
                == 1, 0);
        // Assert order fields.
        let (market_order_id_r, size_r) = get_order_fields_test(
            @user, market_account_id, side, 2);
        assert!(market_order_id_r == market_order_id_3, 0);
        assert!(size_r == size, 0);
    }

    #[test]
    #[expected_failure(abort_code = 12)]
    /// Verify failure for overflowed inbound asset.
    fun test_place_order_internal_in_overflow()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register market accounts.
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = 1;
        let side             = BID;
        // Calculate minimum base fill amount for price of 1.
        let min_fill_base = MIN_SIZE_PURE_COIN * LOT_SIZE_PURE_COIN;
        // Calculate starting base coin amount for barely overflowing.
        let base_start = HI_64 - min_fill_base + 1;
        // Deposit base coins.
        deposit_coins<BC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(base_start));
        // Deposit max quote coins.
        deposit_coins<QC>(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID,
                          assets::mint_test(HI_64));
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no market account resource.
    fun test_place_order_internal_no_account()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register market accounts.
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = MAX_PRICE;
        let side             = ASK;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_GENERIC + 5, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for no market accounts resource.
    fun test_place_order_internal_no_accounts()
    acquires
        MarketAccounts
    {
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = MAX_PRICE;
        let side             = ASK;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 13)]
    /// Verify failure for underflowed outbound asset.
    fun test_place_order_internal_out_underflow()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register market accounts.
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = 1;
        let side             = BID;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for price 0.
    fun test_place_order_internal_price_0()
    acquires
        MarketAccounts
    {
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = 0;
        let side             = ASK;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for price too high.
    fun test_place_order_internal_price_hi()
    acquires
        MarketAccounts
    {
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN;
        let price            = MAX_PRICE + 1;
        let side             = ASK;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for size too low.
    fun test_place_order_internal_size_lo()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register market accounts.
        // Declare order parameters
        let market_order_id  = 123;
        let size             = MIN_SIZE_PURE_COIN - 1;
        let price            = MAX_PRICE;
        let side             = ASK;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
    }

    #[test]
    #[expected_failure(abort_code = 11)]
    /// Verify failure for overflowed ticks.
    fun test_place_order_internal_ticks_overflow()
    acquires
        Collateral,
        MarketAccounts
    {
        register_market_accounts_test(); // Register market accounts.
        // Declare order parameters
        let market_order_id  = 123;
        let size             = HI_64 / MAX_PRICE + 1;
        let price            = MAX_PRICE;
        let side             = ASK;
        // Attempt invalid invocation.
        place_order_internal(@user, MARKET_ID_PURE_COIN, CUSTODIAN_ID, side,
                             size, price, market_order_id);
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

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no market account.
    fun test_withdraw_asset_no_account()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        let (user, _, _, _, _) = register_market_accounts_test();
        // Attempt invalid invocation, burning returned coins.
        assets::burn(withdraw_coins_user<BC>(&user, 0, 0));
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for no market accounts.
    fun test_withdraw_asset_no_accounts(
        user: &signer
    ) acquires
        Collateral,
        MarketAccounts
    {
        // Attempt invalid invocation, burning returned coins.
        assets::burn(withdraw_coins_user<BC>(user, 0, 0));
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for asset not in pair.
    fun test_withdraw_asset_not_in_pair()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        let (user, _, _, _, _) = register_market_accounts_test();
        // Attempt invalid invocation, burning returned coins.
        assets::burn(withdraw_coins_user<UC>(&user, MARKET_ID_PURE_COIN, 0));
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for not enough asset available to withdraw.
    fun test_withdraw_asset_underflow()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        let (user, _, _, _, _) = register_market_accounts_test();
        // Attempt invalid invocation, burning returned coins.
        assets::burn(withdraw_coins_user<QC>(&user, MARKET_ID_PURE_COIN, 1));
    }

    #[test]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for invalid underwriter.
    fun test_withdraw_asset_underwriter()
    acquires
        Collateral,
        MarketAccounts
    {
        // Register test market accounts.
        let (user, _, _, _, _) = register_market_accounts_test();
        let underwriter_capability = // Get underwriter capability.
            registry::get_underwriter_capability_test(UNDERWRITER_ID + 1);
        // Attempt invalid invocation.
        withdraw_generic_asset_user(&user, MARKET_ID_GENERIC, 0,
                                    &underwriter_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
    }

    #[test]
    /// Verify state updates for assorted withdrawal styles.
    fun test_withdrawals()
    acquires
        Collateral,
        MarketAccounts
    {
        // Declare start amount parameters.
        let amount_start_coin = 700;
        let amount_start_generic = 500;
        // Declare withdrawal amount parameters.
        let amount_withdraw_coin_0 = 350;
        let amount_withdraw_generic_0 = 450;
        let amount_withdraw_coin_1 = 300;
        let amount_withdraw_generic_1 = 400;
        // Declare final amounts.
        let amount_final_coin_0 = amount_start_coin - amount_withdraw_coin_0;
        let amount_final_generic_0 = amount_start_generic
                                     - amount_withdraw_generic_0;
        let amount_final_coin_1 = amount_start_coin - amount_withdraw_coin_1;
        let amount_final_generic_1 = amount_start_generic
                                     - amount_withdraw_generic_1;
        // Get signing user and test market account IDs.
        let (user, _, _, market_account_id_generic_self,
                         market_account_id_generic_delegated) =
             register_market_accounts_test();
        let custodian_capability = // Get custodian capability.
            registry::get_custodian_capability_test(CUSTODIAN_ID);
        let underwriter_capability = // Get underwriter capability.
            registry::get_underwriter_capability_test(UNDERWRITER_ID);
        // Deposit to both market accounts.
        deposit_coins<QC>(@user, MARKET_ID_GENERIC, NO_CUSTODIAN,
                          assets::mint_test(amount_start_coin));
        deposit_coins<QC>(@user, MARKET_ID_GENERIC, CUSTODIAN_ID,
                          assets::mint_test(amount_start_coin));
        deposit_generic_asset(@user, MARKET_ID_GENERIC, NO_CUSTODIAN,
                              amount_start_generic, &underwriter_capability);
        deposit_generic_asset(@user, MARKET_ID_GENERIC, CUSTODIAN_ID,
                              amount_start_generic, &underwriter_capability);
        // Withdraw coins to coin store under authority of signing user.
        withdraw_to_coinstore<QC>(&user, MARKET_ID_GENERIC, 1);
        withdraw_to_coinstore<QC>(&user, MARKET_ID_GENERIC,
                                  amount_withdraw_coin_0 - 1);
        // Assert coin store balance.
        assert!(coin::balance<QC>(@user) == amount_withdraw_coin_0, 0);
        // Withdraw coins under authority of delegated custodian.
        let coins = withdraw_coins_custodian<QC>(
            @user, MARKET_ID_GENERIC, amount_withdraw_coin_1,
            &custodian_capability);
        // Assert withdrawn coin value.
        assert!(coin::value(&coins) == amount_withdraw_coin_1, 0);
        assets::burn(coins); // Burn coins.
        // Withdraw generic asset under authority of signing user.
        withdraw_generic_asset_user(
            &user, MARKET_ID_GENERIC, amount_withdraw_generic_0,
            &underwriter_capability);
        // Withdraw generic asset under authority of delegated
        // custodian.
        withdraw_generic_asset_custodian(
            @user, MARKET_ID_GENERIC, amount_withdraw_generic_1,
            &custodian_capability, &underwriter_capability);
        // Assert state for self-custodied account.
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_user(&user, MARKET_ID_GENERIC);
        assert!(base_total      == amount_final_generic_0, 0);
        assert!(base_available  == amount_final_generic_0, 0);
        assert!(base_ceiling    == amount_final_generic_0, 0);
        assert!(quote_total     == amount_final_coin_0   , 0);
        assert!(quote_available == amount_final_coin_0   , 0);
        assert!(quote_ceiling   == amount_final_coin_0   , 0);
        assert!(!has_collateral_test<GenericAsset>(
            @user, market_account_id_generic_self), 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_account_id_generic_self) == amount_final_coin_0, 0);
        // Assert state for delegated custody account.
        let ( base_total,  base_available,  base_ceiling,
             quote_total, quote_available, quote_ceiling) =
            get_asset_counts_custodian(
                @user, MARKET_ID_GENERIC, &custodian_capability);
        assert!(base_total      == amount_final_generic_1, 0);
        assert!(base_available  == amount_final_generic_1, 0);
        assert!(base_ceiling    == amount_final_generic_1, 0);
        assert!(quote_total     == amount_final_coin_1   , 0);
        assert!(quote_available == amount_final_coin_1   , 0);
        assert!(quote_ceiling   == amount_final_coin_1   , 0);
        assert!(!has_collateral_test<GenericAsset>(
            @user, market_account_id_generic_delegated), 0);
        assert!(get_collateral_value_test<QC>(
            @user, market_account_id_generic_delegated) ==
            amount_final_coin_1, 0);
        // Drop custodian capability.
        registry::drop_custodian_capability_test(custodian_capability);
        // Drop underwriter capability.
        registry::drop_underwriter_capability_test(underwriter_capability);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}