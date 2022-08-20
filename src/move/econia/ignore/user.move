module econia::user {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use econia::capability::EconiaCapability;
    use econia::order_id;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::capability::get_econia_capability_test;

    #[test_only]
    use econia::coins::{Self, BC, QC};

    #[test_only]
    use econia::registry::{E1, E2};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When not enough collateral
    const E_NOT_ENOUGH_COLLATERAL: u64 = 4;
    /// When unauthorized custodian ID
    const E_UNAUTHORIZED_CUSTODIAN: u64 = 5;
    /// When user attempts invalid custodian override
    const E_CUSTODIAN_OVERRIDE: u64 = 6;
    /// When an order has no price listed
    const E_PRICE_0: u64 = 8;
    /// When an order has no base parcel count listed
    const E_BASE_PARCELS_0: u64 = 9;
    /// When a base fill amount would not fit into a `u64`
    const E_OVERFLOW_BASE: u64 = 10;
    /// When a quote fill amount would not fit into a `u64`
    const E_OVERFLOW_QUOTE: u64 = 11;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian ID flag for no delegated custodian
    const NO_CUSTODIAN: u64 = 0;
    /// Flag for asks side
    const ASK: bool = true;
    /// Flag for asks side
    const BID: bool = false;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Flag for inbound coins
    const IN: bool = true;
    /// Flag for outbound coins
    const OUT: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// For given market, withdraw `amount` of `user`'s coins from their
    /// `Collateral`, depositing them to their
    /// `aptos_framework::coin::CoinStore`: base coins if `base` is true
    /// else quote coins. See wrapped function `withdraw_collateral()`.
    ///
    /// # Patch notes
    /// * Previously allowed for any `custodian_id`, which would
    ///   inappropriately allow for user to override a custodian. Rather
    ///   than removing the `custodian_id` parameter, however, the
    ///   assert statement was instead added so as not to introduce
    ///   breaking API changes.
    public entry fun withdraw_collateral_coinstore<B, Q, E>(
        user: &signer,
        custodian_id: u64,
        base: bool,
        amount: u64
    ) acquires Collateral, MarketAccounts {
        // Assert custodian ID indicates no custodian
        assert!(custodian_id == NO_CUSTODIAN, E_CUSTODIAN_OVERRIDE);
        // Get corresponding market account info
        let market_account_info = market_account_info<B, Q, E>(custodian_id);
        if (base) // If marked for withdrawing base coins, use base type
            coin::deposit<B>(address_of(user), withdraw_collateral<B>(
                address_of(user), market_account_info, amount)) else
            // Else withdraw quote coins from collateral to coinstore
            coin::deposit<Q>(address_of(user), withdraw_collateral<Q>(
                address_of(user), market_account_info, amount));
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
        assert!(market_account_info.custodian_id == NO_CUSTODIAN,
            E_CUSTODIAN_OVERRIDE);
        // Withdraw collateral from user's market account
        withdraw_collateral<CoinType>(
            address_of(user), market_account_info, amount)
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Add an order to a user's market account, provided an immutable
    /// reference to an `EconiaCapability`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `custodian_id`: Serial ID of delegated custodian for given
    ///   market account
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `base_parcels`: Number of base parcels the order is for
    /// * `price`: Order price
    ///
    /// # Abort conditions
    /// * If user does not have a `MarketAccounts`
    /// * If user does not have a corresponding `MarketAccount` for
    ///   given type arguments and `custodian_id`
    /// * If user does not have sufficient collateral to cover the order
    /// * If range checking does not pass per `range_check_order_fills`
    public fun add_order_internal<B, Q, E>(
        user: address,
        custodian_id: u64,
        side: bool,
        order_id: u128,
        base_parcels: u64,
        price: u64,
        _econia_capability: &EconiaCapability
    ) acquires MarketAccounts {
        // Assert user has a market accounts map
        assert!(exists<MarketAccounts>(user), E_NO_MARKET_ACCOUNTS);
        // Declare market account info
        let market_account_info = market_account_info<B, Q, E>(custodian_id);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Assert user has market account for given market info
        assert!(open_table::contains(market_accounts_map, market_account_info),
            E_NO_MARKET_ACCOUNT);
        // Borrow mutable reference to corresponding market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Get base and quote subunits required to fill order
        let (base_to_fill, quote_to_fill) = range_check_order_fills(
            market_account.scale_factor, base_parcels, price);
        // Get mutable reference to corresponding tree, mutable
        // reference to corresponding coins available field, and
        // coins required for lockup based on given side
        let (tree_ref_mut, coins_available_ref_mut, coins_required) =
            if (side == ASK) (
                &mut market_account.asks,
                &mut market_account.base_coins_available,
                base_to_fill
            ) else (
                &mut market_account.bids,
                &mut market_account.quote_coins_available,
                quote_to_fill
            );
        // Assert user has enough collateral to place the order
        assert!(coins_required <= *coins_available_ref_mut,
            E_NOT_ENOUGH_COLLATERAL);
        // Decrement available coin amount
        *coins_available_ref_mut = *coins_available_ref_mut - coins_required;
        // Add order to corresponding tree
        critbit::insert(tree_ref_mut, order_id, base_parcels);
    }

    /// Fill a user's order, routing collateral accordingly.
    ///
    /// Only to be called by the matching engine, which has already
    /// calculated the corresponding amount of collateral to route. If
    /// the matching engine gets to this stage, then it is assumed that
    /// given user has the indicated open order and appropriate
    /// collateral to fill it. Hence no error checking.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `custodian_id`: Serial ID of delegated custodian for given
    ///   market account
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    /// * `complete_fill`: If `true`, the order is completely filled
    /// * `base_parcels_filled`: Number of base parcels filled
    /// * `base_coins_ref_mut`: Mutable reference to base coins passing
    ///   through the matching engine
    /// * `quote_coins_ref_mut`: Mutable reference to quote coins
    ///   passing through the matching engine
    /// * `base_to_route`: If `side` is `ASK`, number of base coins to
    ///   route from `user` to `base_coins_ref_mut`, else from
    ///   `base_coins_ref_mut` to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote coins to
    ///   route from `quote_coins_ref_mut` to `user`, else from `user`
    ///   to `quote_coins_ref_mut`
    public fun fill_order_internal<B, Q, E>(
        user: address,
        custodian_id: u64,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        base_parcels_filled: u64,
        base_coins_ref_mut: &mut coin::Coin<B>,
        quote_coins_ref_mut: &mut coin::Coin<Q>,
        base_to_route: u64,
        quote_to_route: u64,
        _econia_capability: &EconiaCapability
    ) acquires Collateral, MarketAccounts {
        // Get market account info
        let market_account_info = market_account_info<B, Q, E>(custodian_id);
        // Update user's market account
        fill_order_update_market_account(user, market_account_info, side,
            order_id, complete_fill, base_parcels_filled, base_to_route,
            quote_to_route);
        // Route collateral accordingly
        fill_order_route_collateral<B, Q>(user, market_account_info, side,
            base_coins_ref_mut, quote_coins_ref_mut, base_to_route,
            quote_to_route);
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

    /// Remove an order from a user's market account, provided an
    /// immutable reference to an `EconiaCapability`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `custodian_id`: Serial ID of delegated custodian for given
    ///   market account
    /// * `side`: `ASK` or `BID`
    /// * `order_id`: Order ID for given order
    ///
    /// # Assumes
    /// * That order has already been cancelled from the order book, and
    ///   as such that user necessarily has an open order as specified:
    ///   if an order has been cancelled from the book, then it had to
    ///   have been placed on the book, which means that the
    ///   corresponding user successfully placed it to begin with.
    public fun remove_order_internal<B, Q, E>(
        user: address,
        custodian_id: u64,
        side: bool,
        order_id: u128,
        _econia_capability: &EconiaCapability
    ) acquires MarketAccounts {
        // Declare market account info
        let market_account_info = market_account_info<B, Q, E>(custodian_id);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to corresponding market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Get mutable reference to corresponding tree, mutable
        // reference to corresponding coins available field, and
        // base parcel multiplier based on given side
        let (tree_ref_mut, coins_available_ref_mut, base_parcel_multiplier) =
            if (side == ASK) (
                &mut market_account.asks,
                &mut market_account.base_coins_available,
                market_account.scale_factor
            ) else (
                &mut market_account.bids,
                &mut market_account.quote_coins_available,
                order_id::price(order_id)
            );
        // Pop order from corresponding tree, storing number of base
        // parcels it specified
        let base_parcels = critbit::pop(tree_ref_mut, order_id);
        // Calculate number of coins unlocked by order cancellation
        let coins_unlocked = base_parcels * base_parcel_multiplier;
        // Increment available coin amount
        *coins_available_ref_mut = *coins_available_ref_mut + coins_unlocked;
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
        custodian_capability_ref: &registry::CustodianCapability,
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert serial custodian ID from capability matches ID from
        // market account info
        assert!(registry::custodian_id(custodian_capability_ref) ==
            market_account_info.custodian_id, E_UNAUTHORIZED_CUSTODIAN);
        // Withdraw collateral from user's market account
        withdraw_collateral<CoinType>(user, market_account_info, amount)
    }

    /// Withdraw `amount` of `Coin` having `CoinType` from `Collateral`
    /// entry corresponding to `market_account_info`, then return it.
    /// Reserved for internal cross-module clls, and requires a
    /// reference to an `EconiaCapability`.
    public fun withdraw_collateral_internal<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64,
        _econia_capability: &EconiaCapability
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Withdraw collateral from user's market account
        withdraw_collateral<CoinType>(user, market_account_info, amount)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Route collateral when filling an order.
    ///
    /// Inner function for `fill_order_internal()`.
    ///
    /// # Parameters
    /// * `user`: Address of corresponding user
    /// * `market_account_info`: Corresponding `MarketAccountInfo`
    /// * `side`: `ASK` or `BID`
    /// * `base_coins_ref_mut`: Mutable reference to base coins passing
    ///   through the matching engine
    /// * `quote_coins_ref_mut`: Mutable reference to quote coins
    ///   passing through the matching engine
    /// * `base_to_route`: If `side` is `ASK`, number of base coins to
    ///   route from `user` to `base_coins_ref_mut`, else from
    ///   `base_coins_ref_mut` to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote coins to
    ///   route from `quote_coins_ref_mut` to `user`, else from `user`
    ///   to `quote_coins_ref_mut`
    fun fill_order_route_collateral<B, Q>(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        base_coins_ref_mut: &mut coin::Coin<B>,
        quote_coins_ref_mut: &mut coin::Coin<Q>,
        base_to_route: u64,
        quote_to_route: u64,
    ) acquires Collateral {
        // Determine route direction for base and quote relative to user
        let (base_direction, quote_direction) =
            if (side == ASK) (OUT, IN) else (IN, OUT);
        // Route base coins
        fill_order_route_collateral_single<B>(user, market_account_info,
            base_coins_ref_mut, base_to_route, base_direction);
        // Route quote coins
        fill_order_route_collateral_single<Q>(user, market_account_info,
            quote_coins_ref_mut, quote_to_route, quote_direction);
    }

    /// Route `amount` of `Collateral` in `direction` either `IN` or
    /// `OUT`, relative to `user` with `market_account_info`, either
    /// from or to, respectively, coins at `external_coins_ref_mut`.
    ///
    /// Inner function for `fill_order_route_collateral()`
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
            // Merge to their collateral store extracted external coins
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
    /// * `base_parcels_filled`: Number of base parcels filled
    /// * `base_to_route`: If `side` is `ASK`, number of base coins
    ///   routed from `user`, else to `user`
    /// * `quote_to_route`: If `side` is `ASK`, number of quote coins
    ///   routed to `user`, else from `user`
    fun fill_order_update_market_account(
        user: address,
        market_account_info: MarketAccountInfo,
        side: bool,
        order_id: u128,
        complete_fill: bool,
        base_parcels_filled: u64,
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
            order_tree_ref_mut,
            coins_in, // Amount of inbound coins
            coins_in_total_ref_mut, // Totals field for inbound coins
            coins_in_available_ref_mut, // Available field
            coins_out, // Amount of outbound coins
            coins_out_total_ref_mut, // Totals field for outbound coins
        ) = if (side == ASK) ( // If an ask is matched
            &mut market_account_ref_mut.asks,
            quote_to_route,
            &mut market_account_ref_mut.quote_coins_total,
            &mut market_account_ref_mut.quote_coins_available,
            base_to_route,
            &mut market_account_ref_mut.base_coins_total,
        ) else ( // If a bid is matched
            &mut market_account_ref_mut.bids,
            base_to_route,
            &mut market_account_ref_mut.base_coins_total,
            &mut market_account_ref_mut.base_coins_available,
            quote_to_route,
            &mut market_account_ref_mut.quote_coins_total,
        );
        if (complete_fill) { // If completely filling the order
            critbit::pop(order_tree_ref_mut, order_id); // Pop order
        } else { // If only partially filling the order
            // Get mutable reference to base parcels left to be filled
            // on the order
            let order_base_parcels_ref_mut =
                critbit::borrow_mut(order_tree_ref_mut, order_id);
            // Decrement amount still unfilled
            *order_base_parcels_ref_mut = *order_base_parcels_ref_mut -
                base_parcels_filled;
        };
        // Update coin counts for incoming and outgoing coins
        *coins_in_total_ref_mut = *coins_in_total_ref_mut + coins_in;
        *coins_in_available_ref_mut = *coins_in_available_ref_mut + coins_in;
        *coins_out_total_ref_mut = *coins_out_total_ref_mut - coins_out;
    }

    /// For order with given `scale_factor`, `base_parcels`, and
    /// `price`, check that price and size are zero, and that fill
    /// amounts can fit in a `u64`. Then return the number of base coins
    /// and quote coins required to fill the order.
    fun range_check_order_fills(
        scale_factor: u64,
        base_parcels: u64,
        price: u64
    ): (
        u64,
        u64
    ) {
        assert!(price > 0, E_PRICE_0); // Assert order has actual price
        // Assert actually trying to trade amount of base parcels
        assert!(base_parcels > 0, E_BASE_PARCELS_0);
        // Calculate base coins required to fill the order
        let base_to_fill = (scale_factor as u128) * (base_parcels as u128);
        // Assert that amount can fit in a u64
        assert!(!(base_to_fill > (HI_64 as u128)), E_OVERFLOW_BASE);
        // Determine amount of quote coins needed to fill order
        let quote_to_fill = (price as u128) * (base_parcels as u128);
        // Assert that amount can fit in a u64
        assert!(!(quote_to_fill > (HI_64 as u128)), E_OVERFLOW_QUOTE);
        // Return casted, range-checked amounts
        ((base_to_fill as u64), (quote_to_fill as u64))
    }

    /// Withdraw `amount` of `Coin` having `CoinType` from `Collateral`
    /// entry corresponding to `market_account_info`, then return it.
    ///
    /// # Abort conditions
    /// * If `CoinType` is neither base nor quote for market account
    /// * If `user` does not have corresponding market account
    ///   registered
    /// * If `user` has insufficient collateral to withdraw
    fun withdraw_collateral<CoinType>(
        user: address,
        market_account_info: MarketAccountInfo,
        amount: u64
    ): coin::Coin<CoinType>
    acquires Collateral, MarketAccounts {
        // Assert market account registered for market account info
        assert!(exists_market_account(market_account_info, user),
            E_NO_MARKET_ACCOUNT);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(user).map;
        // Borrow mutable reference to total coins held as collateral,
        // and mutable reference to amount of coins available for
        // withdraw (aborts if coin type is neither base nor quote for
        // given market account)
        let (coins_total_ref_mut, coins_available_ref_mut) =
            borrow_coin_counts_mut<CoinType>(market_accounts_map,
                market_account_info);
        // Assert user has enough available collateral to withdraw
        assert!(amount <= *coins_available_ref_mut, E_NOT_ENOUGH_COLLATERAL);
        // Decrement withdrawn amount from total coin count
        *coins_total_ref_mut = *coins_total_ref_mut - amount;
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

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return `true` if `user` has order with given `order_id` on given
    /// `side` for market account with given `custodian_id`.
    ///
    /// # Assumes
    /// * `user` market account as specified
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions
    public fun has_order_test<B, Q, E>(
        user: address,
        custodian_id: u64,
        side: bool,
        order_id: u128
    ): bool
    acquires MarketAccounts {
        // Declare market account info
        let market_account_info = market_account_info<B, Q, E>(custodian_id);
        // Borrow immutable reference to market accounts map
        let market_accounts_map = &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to corresponding market account
        let market_account =
            open_table::borrow(market_accounts_map, market_account_info);
        // Get immutable reference to orders tree for given side
        let tree_ref = if (side == ASK) &market_account.asks else
            &market_account.bids;
        // Return if orders tree contains given order ID
        critbit::has_key(tree_ref, order_id)
    }

    #[test_only]
    /// Return number of base parcels indicated for order having
    /// `order_id` on given `side` of `user`'s market account having
    /// `custodian_id`.
    ///
    /// # Assumes
    /// * `user` has an open order as specified
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions
    public fun order_base_parcels_test<B, Q, E>(
        user: address,
        custodian_id: u64,
        side: bool,
        order_id: u128
    ): u64
    acquires MarketAccounts {
        // Declare market account info
        let market_account_info = market_account_info<B, Q, E>(custodian_id);
        // Borrow immutable reference to market accounts map
        let market_accounts_map = &borrow_global<MarketAccounts>(user).map;
        // Borrow immutable reference to corresponding market account
        let market_account =
            open_table::borrow(market_accounts_map, market_account_info);
        // Get immutable reference to orders tree for given side
        let tree_ref = if (side == ASK) &market_account.asks else
            &market_account.bids;
        // Return order base parcels
        *critbit::borrow(tree_ref, order_id)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for insufficient collateral
    fun test_add_order_internal_no_collateral(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Register market account for user with no custodian ID
        register_market_account<BC, QC, E1>(user, NO_CUSTODIAN);
        // Attempt invalid order add on market account with custodian
        add_order_internal<BC, QC, E1>(@user, NO_CUSTODIAN, ASK, 0, 2, 3,
            &get_econia_capability_test()); // Attemp invalid call
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no market account
    fun test_add_order_internal_no_market_account(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Register market account for user with no custodian ID
        register_market_account<BC, QC, E1>(user, NO_CUSTODIAN);
        // Attempt invalid order add on market account with custodian
        add_order_internal<BC, QC, E1>(@user, 1, ASK, 0, 0, 0,
            &get_econia_capability_test()); // Attemp invalid call
    }

    #[test]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no market accounts map
    fun test_add_order_internal_no_market_accounts()
    acquires MarketAccounts {
        add_order_internal<BC, QC, E1>(@user, NO_CUSTODIAN, ASK, 0, 0, 0,
            &get_econia_capability_test()); // Attemp invalid call
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for not enough collateral
    fun test_add_order_internal_not_enough_collateral(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Register market account for user with no custodian ID
        register_market_account<BC, QC, E1>(user, NO_CUSTODIAN);
        // Declare function arguments
        let custodian_id = NO_CUSTODIAN; let side = ASK; let order_id = 123;
        let base_parcels = 456; let price = 789;
        // Attempt invalid order add
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            base_parcels, price, &get_econia_capability_test());
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify end-to-end internal adding and removing of ask
    fun test_add_remove_order_internal_ask(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Declare ask parameters
        let custodian_id = NO_CUSTODIAN;
        let side = ASK;
        let order_id = 123;
        let base_parcels = 456;
        let price = 789;
        // Declare base coins at start
        let base_coins_start = 12345678;
        // Declare scale factor
        let scale_factor = registry::scale_factor<E1>();
        // Declare base coins available after ask added
        let base_coins_available = base_coins_start -
            base_parcels * scale_factor;
        let market_account_info = // Get market account info
            market_account_info<BC, QC, E1>(custodian_id);
        // Register market account for user with no custodian ID
        register_market_account<BC, QC, E1>(user, custodian_id);
        // Deposit base coins
        deposit_collateral<BC>(@user, market_account_info,
            coins::mint<BC>(econia, base_coins_start));
        // Add ask
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            base_parcels, price, &get_econia_capability_test());
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to corresponding market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        assert!(*critbit::borrow(&market_account.asks, order_id) ==
            base_parcels, 0); // Assert order added to correct tree
        // Assert coin counts
        assert!(market_account.base_coins_total == base_coins_start, 0);
        assert!(market_account.base_coins_available ==
            base_coins_available, 0);
        assert!(market_account.quote_coins_total == 0, 0);
        assert!(market_account.quote_coins_available == 0, 0);
        remove_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            &get_econia_capability_test()); // Remove order
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to corresponding market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Assert order removed from asks tree
        assert!(!critbit::has_key(&market_account.asks, order_id), 0);
        // Assert coin counts
        assert!(market_account.base_coins_total == base_coins_start, 0);
        assert!(market_account.base_coins_available == base_coins_start, 0);
        assert!(market_account.quote_coins_total == 0, 0);
        assert!(market_account.quote_coins_available == 0, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify end-to-end internal adding and removing of bid
    fun test_add_remove_order_internal_bid(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Declare bid parameters
        let custodian_id = NO_CUSTODIAN;
        let side = BID;
        let price = 123;
        let serial_id = 45;
        let order_id = order_id::order_id_bid(price, serial_id);
        let base_parcels = 456;
        // Declare quote coins at start
        let quote_coins_start = 12345678;
        // Declare quote coins available after bid added
        let quote_coins_available = quote_coins_start - base_parcels * price;
        let market_account_info = // Get market account info
            market_account_info<BC, QC, E1>(custodian_id);
        // Register market account for user with no custodian ID
        register_market_account<BC, QC, E1>(user, custodian_id);
        // Deposit base coins
        deposit_collateral<QC>(@user, market_account_info,
            coins::mint<QC>(econia, quote_coins_start));
        // Add bid
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            base_parcels, price, &get_econia_capability_test());
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to corresponding market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        assert!(*critbit::borrow(&market_account.bids, order_id) ==
            base_parcels, 0); // Assert order added to correct tree
        // Assert coin counts
        assert!(market_account.base_coins_total == 0, 0);
        assert!(market_account.base_coins_available == 0, 0);
        assert!(market_account.quote_coins_total == quote_coins_start, 0);
        assert!(market_account.quote_coins_available ==
            quote_coins_available, 0);
        remove_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            &get_econia_capability_test()); // Remove order
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to corresponding market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Assert order removed from bids tree
        assert!(!critbit::has_key(&market_account.bids, order_id), 0);
        // Assert coin counts
        assert!(market_account.base_coins_total == 0, 0);
        assert!(market_account.base_coins_available == 0, 0);
        assert!(market_account.quote_coins_total == quote_coins_start, 0);
        assert!(market_account.quote_coins_available == quote_coins_start, 0);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful state update for asks
    fun test_fill_order_internal_ask(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Declare ask parameters
        let (custodian_id, side, order_id, order_base_parcels, price) = (
             NO_CUSTODIAN,  ASK,      123,                456,   789);
        // Declare base coins at start
        let base_coins_start = 12345678;
        // Declare scale factor
        let scale_factor = registry::scale_factor<E1>();
        let market_account_info = // Get market account info
            market_account_info<BC, QC, E1>(custodian_id);
        // Register market account for user
        register_market_account<BC, QC, E1>(user, custodian_id);
        // Deposit base coins
        deposit_collateral<BC>(@user, market_account_info,
            coins::mint<BC>(econia, base_coins_start));
        // Add ask
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            order_base_parcels, price, &get_econia_capability_test());
        // Declare number of quote coins held by matching engine
        let engine_quote_coins_start = 654321;
        let (engine_base_coins, engine_quote_coins) = (
            coin::zero<BC>(),
            coins::mint<QC>(econia, engine_quote_coins_start)
        ); // Initialize matching engine side of route with coins
        // Declare partial fill parameters relative to user
        let base_parcels_filled_1 = 100;
        let base_to_route_1 = base_parcels_filled_1 * scale_factor;
        let quote_to_route_1 = base_parcels_filled_1 * price;
        // Process a partial fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            false, base_parcels_filled_1, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_1, quote_to_route_1,
            &get_econia_capability_test());
        // Assert base coin counts
        let (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == base_coins_start - base_to_route_1, 0);
        assert!(base_coins_available == base_coins_start -
            order_base_parcels * scale_factor, 0);
        // Assert quote coin counts
        let (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == quote_to_route_1, 0);
        assert!(quote_coins_available == quote_to_route_1, 0);
        // Assert order base parcel size updates
        assert!(order_base_parcels_test<BC, QC, E1>(@user, custodian_id, side,
            order_id) == order_base_parcels - base_parcels_filled_1, 0);
        // Get collateral amounts
        let (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_coins_start - base_to_route_1, 0);
        assert!(quote_collateral == quote_to_route_1, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) == base_to_route_1, 0);
        assert!(coin::value(&engine_quote_coins) == engine_quote_coins_start -
            quote_to_route_1, 0);
        // Declare complete fill parameters relative to user
        let base_parcels_filled_2 = order_base_parcels - base_parcels_filled_1;
        let base_to_route_2 = base_parcels_filled_2 * scale_factor;
        let quote_to_route_2 = base_parcels_filled_2 * price;
        // Process a complete fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            true, base_parcels_filled_2, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_2, quote_to_route_2,
            &get_econia_capability_test());
        // Assert base coin counts
        (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == base_coins_start -
            order_base_parcels * scale_factor, 0);
        assert!(base_coins_available == base_coins_start -
            order_base_parcels * scale_factor, 0);
        // Assert quote coin counts
        (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == order_base_parcels * price, 0);
        assert!(quote_coins_available == order_base_parcels * price, 0);
        // Assert order popped of user's open orders
        assert!(!has_order_test<BC, QC, E1>(@user, custodian_id, side,
            order_id), 0);
        // Get collateral amounts
        (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_coins_start -
            base_to_route_1 - base_to_route_2, 0);
        assert!(quote_collateral == quote_to_route_1 + quote_to_route_2, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) ==
            base_to_route_1 + base_to_route_2, 0);
        assert!(coin::value(&engine_quote_coins) ==
            engine_quote_coins_start - quote_to_route_1 - quote_to_route_2, 0);
        // Burn matching engine's coins
        coins::burn(engine_base_coins); coins::burn(engine_quote_coins);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful state update for bids
    fun test_fill_order_internal_bids(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Declare ask parameters
        let (custodian_id, side, order_id, order_base_parcels, price) = (
             NO_CUSTODIAN,  BID,      123,                456,   789);
        // Declare quote coins at start
        let quote_coins_start = 12345678;
        // Declare scale factor
        let scale_factor = registry::scale_factor<E1>();
        let market_account_info = // Get market account info
            market_account_info<BC, QC, E1>(custodian_id);
        // Register market account for user
        register_market_account<BC, QC, E1>(user, custodian_id);
        // Deposit quote coins
        deposit_collateral<QC>(@user, market_account_info,
            coins::mint<QC>(econia, quote_coins_start));
        // Add bid
        add_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            order_base_parcels, price, &get_econia_capability_test());
        // Declare number of base coins held by matching engine
        let engine_base_coins_start = 654321;
        let (engine_base_coins, engine_quote_coins) = (
            coins::mint<BC>(econia, engine_base_coins_start),
            coin::zero<QC>()
        ); // Initialize matching engine side of route with coins
        // Declare partial fill parameters relative to user
        let base_parcels_filled_1 = 100;
        let base_to_route_1 = base_parcels_filled_1 * scale_factor;
        let quote_to_route_1 = base_parcels_filled_1 * price;
        // Process a partial fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            false, base_parcels_filled_1, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_1, quote_to_route_1,
            &get_econia_capability_test());
        // Assert base coin counts
        let (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == base_to_route_1, 0);
        assert!(base_coins_available == base_to_route_1, 0);
        // Assert quote coin counts
        let (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == quote_coins_start - quote_to_route_1, 0);
        assert!(quote_coins_available == quote_coins_start -
            order_base_parcels * price, 0);
        // Assert order base parcel size updates
        assert!(order_base_parcels_test<BC, QC, E1>(@user, custodian_id, side,
            order_id) == order_base_parcels - base_parcels_filled_1, 0);
        // Get collateral amounts
        let (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_to_route_1, 0);
        assert!(quote_collateral == quote_coins_start - quote_to_route_1, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) == engine_base_coins_start -
            base_to_route_1, 0);
        assert!(coin::value(&engine_quote_coins) == quote_to_route_1, 0);
        // Declare complete fill parameters relative to user
        let base_parcels_filled_2 = order_base_parcels - base_parcels_filled_1;
        let base_to_route_2 = base_parcels_filled_2 * scale_factor;
        let quote_to_route_2 = base_parcels_filled_2 * price;
        // Process a complete fill
        fill_order_internal<BC, QC, E1>(@user, custodian_id, side, order_id,
            true, base_parcels_filled_2, &mut engine_base_coins,
            &mut engine_quote_coins, base_to_route_2, quote_to_route_2,
            &get_econia_capability_test());
        // Assert base coin counts
        (base_coins_total, base_coins_available) =
            get_collateral_counts_test<BC, QC, E1, BC>(@user, custodian_id);
        assert!(base_coins_total == order_base_parcels * scale_factor, 0);
        assert!(base_coins_available == order_base_parcels * scale_factor, 0);
        // Assert quote coin counts
        (quote_coins_total, quote_coins_available) =
            get_collateral_counts_test<BC, QC, E1, QC>(@user, custodian_id);
        assert!(quote_coins_total == quote_coins_start -
            order_base_parcels * price, 0);
        assert!(quote_coins_available == quote_coins_start -
            order_base_parcels * price, 0);
        // Assert order popped of user's open orders
        assert!(!has_order_test<BC, QC, E1>(@user, custodian_id, side,
            order_id), 0);
        // Get collateral amounts
        (base_collateral, quote_collateral) =
            get_collateral_amounts_test<BC, QC, E1>(@user, custodian_id);
        // Assert collateral amounts
        assert!(base_collateral == base_to_route_1 + base_to_route_2, 0);
        assert!(quote_collateral ==
            quote_coins_start - quote_to_route_1 - quote_to_route_2, 0);
        // Assert matching engine coin coints
        assert!(coin::value(&engine_base_coins) ==
            engine_base_coins_start - base_to_route_1 - base_to_route_2, 0);
        assert!(coin::value(&engine_quote_coins) ==
            quote_to_route_1 + quote_to_route_2, 0);
        // Burn matching engine's coins
        coins::burn(engine_base_coins); coins::burn(engine_quote_coins);
    }

    #[test]
    /// Verify successful returns
    fun test_range_check_order_fills() {
        // Define function parameters
        let (scale_factor, base_parcels, price) = (10, 11, 12);
        // Run calculations
        let (base_to_fill, quote_to_fill) = range_check_order_fills(
            scale_factor, base_parcels, price);
        // Assert returns
        assert!(base_to_fill == scale_factor * base_parcels, 0);
        assert!(quote_to_fill == price * base_parcels, 0);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for base parcels set to 0
    fun test_range_check_order_fills_base_parcels_0() {
        range_check_order_fills(123, 0, 456); // Attempt invalid call
    }

    #[test]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for base fill overflow
    fun test_range_check_order_fills_overflow_base() {
        // Attempt invalid call
        range_check_order_fills(10, HI_64 / 9, 1);
    }

    #[test]
    #[expected_failure(abort_code = 11)]
    /// Verify failure for quote fill overflow
    fun test_range_check_order_fills_overflow_quote() {
        // Attempt invalid call
        range_check_order_fills(1, HI_64, 2);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for price set to 0
    fun test_range_check_order_fills_price_0() {
        range_check_order_fills(123, 456, 0); // Attempt invalid call
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for custodian ID not flagged as no custodian
    fun test_withdraw_collateral_coinstore_override(
        user: &signer
    ) acquires Collateral, MarketAccounts {
        withdraw_collateral_coinstore<BC, QC, E1>(user, 1, true, 1);
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    /// Verify successful withdraw
    fun test_withdraw_collateral_success(
        econia: &signer,
        user: &signer
    ) acquires Collateral, MarketAccounts {
        let deposit_amount = 20; // Declare first deposit amount
        let withdraw_amount_1 = 15; // Declare first withdraw amount
        let withdraw_amount_2 = 5; // Declare second withdraw amount
        // Register test market
        registry::register_test_market_internal(econia);
        // Register market account for user without custodian
        register_market_account<BC, QC, E1>(user, NO_CUSTODIAN);
        let market_account_info = MarketAccountInfo{
                market_info: registry::market_info<BC, QC, registry::E1>(),
                custodian_id: NO_CUSTODIAN
        }; // Declare market account info
        // Mint coins to deposit
        let coins = coins::mint<QC>(econia, deposit_amount);
        // Deposit coins as collateral
        deposit_collateral<QC>(@user, market_account_info, coins);
        // Withdraw first withdraw amount
        let coins = withdraw_collateral_user<QC>(
            user, market_account_info, withdraw_amount_1);
        // Assert correct amount withdrawn
        assert!(coin::value(&coins) == withdraw_amount_1, 0);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Assert coin counts
        assert!(market_account.base_coins_total == 0, 0);
        assert!(market_account.base_coins_available == 0, 0);
        assert!(market_account.quote_coins_total ==
            deposit_amount - withdraw_amount_1, 0);
        assert!(market_account.quote_coins_available ==
            deposit_amount - withdraw_amount_1, 0);
        // Borrow mutable reference to collateral map
        let collateral_map =
            &mut borrow_global_mut<Collateral<QC>>(@user).map;
        // Borrow immutable reference to collateral for market account
        let collateral =
            open_table::borrow(collateral_map, market_account_info);
        assert!( // Assert correct value
            coin::value(collateral) == deposit_amount - withdraw_amount_1, 0);
        coins::burn(coins); // Burn withdrawn coins
        // Register user with quote coin store
        coin::register_for_test<QC>(user);
        // Withdraw second withdraw amount
        withdraw_collateral_coinstore<BC, QC, E1>(
            user, NO_CUSTODIAN, false, withdraw_amount_2);
        // Assert correct amount withdrawn
        assert!(coin::balance<QC>(@user) == withdraw_amount_2, 0);
        // Borrow mutable reference to market accounts map
        let market_accounts_map =
            &mut borrow_global_mut<MarketAccounts>(@user).map;
        // Borrow mutable reference to market account
        let market_account =
            open_table::borrow_mut(market_accounts_map, market_account_info);
        // Assert coin counts
        assert!(market_account.base_coins_total == 0, 0);
        assert!(market_account.base_coins_available == 0, 0);
        assert!(market_account.quote_coins_total == 0, 0);
        assert!(market_account.quote_coins_available == 0, 0);
        // Borrow mutable reference to collateral map
        let collateral_map =
            &mut borrow_global_mut<Collateral<QC>>(@user).map;
        // Borrow immutable reference to collateral for market account
        let collateral =
            open_table::borrow(collateral_map, market_account_info);
        // Assert correct value
        assert!(coin::value(collateral) == 0, 0);
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for unauthorized custodian withdraw
    fun test_withdraw_collateral_custodian_unauthorized():
    Coin<BC>
    acquires Collateral, MarketAccounts {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E1>(),
            custodian_id: 123 }; // Declare market account info
        // Get a custodian capability
        let custodian_capability = registry::get_custodian_capability(1);
        // Attempt invalid withdraw
        let coins = withdraw_collateral_custodian<BC>(
            @user, market_account_info, 100, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability(custodian_capability);
        coins // Return coins (or signal to compiler as much)
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for no registered market account
    fun test_withdraw_collateral_no_market_account(
        user: &signer
    ): Coin<BC>
    acquires Collateral, MarketAccounts {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E1>(),
            custodian_id: 0 }; // Declare market account info
        // Attempt invalid withdraw
        withdraw_collateral_user<BC>(user, market_account_info, 10)
    }

    #[test(
        econia = @econia,
        user = @user
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for not enough collateral
    fun test_withdraw_collateral_not_enough_collateral(
        econia: &signer,
        user: &signer
    ): Coin<BC>
    acquires Collateral, MarketAccounts {
        // Register test market
        registry::register_test_market_internal(econia);
        // Register custodian, store capability
        let custodian_capability = registry::register_custodian_capability();
        // Register market account for user w/ custodian ID 1
        register_market_account<BC, QC, E1>(user, 1);
        let market_account_info = MarketAccountInfo{
                market_info: registry::market_info<BC, QC, registry::E1>(),
                custodian_id: 1
        }; // Declare market account info
        // Attempt invalid withdraw
        let coins = withdraw_collateral_custodian<BC>(
            @user, market_account_info, 1, &custodian_capability);
        // Destroy custodian capability
        registry::destroy_custodian_capability(custodian_capability);
        coins // Return coins (or signal to compiler as much)
    }

    #[test(user = @user)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for attempting to override custodian
    fun test_withdraw_collateral_user_override(
        user: &signer
    ): Coin<BC>
    acquires Collateral, MarketAccounts {
        let market_account_info = MarketAccountInfo{
            market_info: registry::market_info<BC, QC, registry::E1>(),
            custodian_id: 123 }; // Declare market account info
        // Attempt invalid withdraw
        withdraw_collateral_user<BC>(user, market_account_info, 100)
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}