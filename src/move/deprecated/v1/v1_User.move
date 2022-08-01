/// User-facing trading functionality
module Econia::User {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::account::{
        get_sequence_number as a_g_s_n
    };

    use aptos_framework::coin::{
        Coin as C,
        deposit as c_d,
        extract as coin_extract,
        merge as coin_merge,
        withdraw as coin_withdraw,
        zero as c_z
    };

    use Econia::Book::{
        add_ask as b_a_a,
        add_bid as b_a_b,
        cancel_ask as b_c_a,
        cancel_bid as b_c_b,
        exists_book as b_e_b
    };

    use Econia::Caps::{
        orders_f_c as orders_cap,
        book_f_c as book_cap
    };

    use Econia::ID::{
        id_a as id_a,
        id_b as id_b,
        price as id_price
    };

    use Econia::Orders::{
        add_ask as o_a_a,
        add_bid as o_a_b,
        cancel_ask as o_c_a,
        cancel_bid as o_c_b,
        decrement_order_size,
        exists_orders as o_e_o,
        FriendCap as OrdersCap,
        init_orders as o_i_o,
        remove_order,
        scale_factor as orders_scale_factor
    };

    use Econia::Registry::{
        is_registered as r_i_r,
        scale_factor as r_s_f
    };

    use Econia::Version::{
        get_v_n
    };

    use std::signer::{
        address_of
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend Econia::Match;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use aptos_framework::account::{
        create_account,
        increment_sequence_number as inc_seq_number,
        set_sequence_number as a_s_s_n
    };

    #[test_only]
    use aptos_framework::coin::{
        balance as c_b,
        register as coin_register,
        value as coin_value
    };

    #[test_only]
    use Econia::Book::{
        check_ask as b_ch_a,
        check_ask_min as b_ch_a_m,
        check_bid as b_ch_b,
        check_bid_max as b_ch_b_m,
        has_ask as b_h_a,
        has_bid as b_h_b
    };

    #[test_only]
    use Econia::Caps::{
        init_caps
    };

    #[test_only]
    use Econia::Init::init_econia;

    #[test_only]
    use Econia::Orders::{
        check_ask as orders_check_ask,
        check_bid as orders_check_bid,
        has_ask as orders_has_ask,
        has_bid as orders_has_bid
    };

    #[test_only]
    use Econia::Registry::{
        BCT,
        E0,
        E1,
        mint_bct_to,
        mint_qct_to,
        QCT,
        register_test_market as r_r_t_m,
        register_scaled_test_market
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Order collateral for a given market
    struct OC<phantom B, phantom Q, phantom E> has key {
        /// Indivisible subunits of base coins available to withdraw
        b_a: u64,
        /// Base coins held as collateral
        b_c: C<B>,
        /// Indivisible subunits of quote coins available to withdraw
        q_a: u64,
        /// Quote coins held as collateral
        q_c: C<Q>
    }

    /// Counter for sequence number of last monitored Econia transaction
    struct SC has key {
        i: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When order collateral container already exists
    const E_O_C_EXISTS: u64 = 0;
    /// When no corresponding market
    const E_NO_MARKET: u64 = 1;
    /// When open orders container already exists
    const E_O_O_EXISTS: u64 = 2;
    /// When sequence number counter already exists for user
    const E_S_C_EXISTS: u64 = 3;
    /// When sequence number counter does not exist for user
    const E_NO_S_C: u64 = 4;
    /// When invalid sequence number for current transaction
    const E_INVALID_S_N: u64 = 5;
    /// When no order collateral container
    const E_NO_O_C: u64 = 6;
    /// When no transfer of funds indicated
    const E_NO_TRANSFER: u64 = 7;
    /// When attempting to withdraw more than is available
    const E_WITHDRAW_TOO_MUCH: u64 = 8;
    /// When not enough collateral for an operation
    const E_NOT_ENOUGH_COLLATERAL: u64 = 9;
    /// When an attempted limit order crosses the spread
    const E_CROSSES_SPREAD: u64 = 10;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd(desc=b"deposit funds into market")]
    /// Deposit `b_val` base coin and `q_val` quote coin into `user`'s
    /// `OC`, from their `aptos_framework::Coin::CoinStore`, incrementing
    /// sequence counter to prevent transaction collisions
    public entry fun deposit<B, Q, E>(
        user: &signer,
        b_val: u64,
        q_val: u64
    ) acquires OC, SC {
        let orders_cap = orders_cap(); // Get orders capability
        // Deposit into user's account
        deposit_internal<B, Q, E>(user, b_val, q_val, &orders_cap);
        update_s_c(user, &orders_cap); // Update user sequence counter
    }

    #[cmd(desc=b"Cancel bid order with id")]
    /// Wrapped `cancel_order()` call for `ASK`
    public entry fun cancel_ask<B, Q, E>(
        user: &signer,
        host: address,
        id: u128
    ) acquires OC, SC {
        cancel_order<B, Q, E>(user, host, ASK, id);
    }

    #[cmd(desc=b"Cancel ask order with id")]
    /// Wrapped `cancel_order()` call for `BID`
    public entry fun cancel_bid<B, Q, E>(
        user: &signer,
        host: address,
        id: u128
    ) acquires OC, SC {
        cancel_order<B, Q, E>(user, host, BID, id);
    }

    #[cmd(desc=b"Initialize user for trading on B-Q-E market")]
    /// Initialize a user with `Econia::Orders::OO` and `OC` for market
    /// with base coin type `B`, quote coin type `Q`, and scale exponent
    /// `E`, aborting if no such market or if containers already
    /// initialized for market
    public entry fun init_containers<B, Q, E>(
        user: &signer
    ) {
        assert!(r_i_r<B, Q, E>(), E_NO_MARKET); // Assert market exists
        let user_addr = address_of(user); // Get user address
        // Assert user does not already have collateral container
        assert!(!exists<OC<B, Q, E>>(user_addr), E_O_C_EXISTS);
        // Assert user does not already have open orders container
        assert!(!o_e_o<B, Q, E>(user_addr), E_O_O_EXISTS);
        // Pack empty collateral container
        let o_c = OC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
        move_to<OC<B, Q, E>>(user, o_c); // Move to user account
        // Initialize empty open orders container under user account
        o_i_o<B, Q, E>(user, r_s_f<E>(), &orders_cap());
    }

    #[cmd(desc=b"Initializes account for placing limit orders")]
    /// Initialize an `SC` with the sequence number of the initializing
    /// transaction, aborting if one already exists
    public entry fun init_user(
        user: &signer
    ) {
        let user_addr = address_of(user); // Get user address
        // Assert user has not already initialized a sequence counter
        assert!(!exists<SC>(user_addr), E_S_C_EXISTS);
        // Initialize sequence counter with user's sequence number
        move_to<SC>(user, SC{i: a_g_s_n(user_addr)});
    }

    #[cmd(desc=b"Submit limit order to sell B to Q")]
    /// Wrapped `submit_limit_order()` call for `ASK`
    public entry fun submit_ask<B, Q, E>(
        user: &signer,
        host: address,
        price: u64,
        size: u64
    ) acquires OC, SC {
        submit_limit_order<B, Q, E>(user, host, ASK, price, size);
    }

    #[cmd(desc=b"Submit limit order to buy B with Q")]
    /// Wrapped `submit_limit_order()` call for `BID`
    public entry fun submit_bid<B, Q, E>(
        user: &signer,
        host: address,
        price: u64,
        size: u64
    ) acquires OC, SC {
        submit_limit_order<B, Q, E>(user, host, BID, price, size);
    }

    #[cmd(desc=b"Withdraw funds from market")]
    /// Withdraw `b_val` base coin and `q_val` quote coin from `user`'s
    /// `OC`, into their `aptos_framework::Coin::CoinStore`,
    /// incrementing sequence counter to prevent transaction collisions
    public entry fun withdraw<B, Q, E>(
        user: &signer,
        b_val: u64,
        q_val: u64
    ) acquires OC, SC {
        // Execute internal withdraw
        withdraw_internal<B, Q, E>(user, b_val, q_val, &orders_cap());
        update_s_c(user, &orders_cap()); // Update user sequence counter
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Update open orders for a user who has an order on the book and
    /// route the corresponding funds between them and a counterparty
    /// during a match fill, updating available collateral amounts
    /// accordingly. Should only be called by the matching engine and
    /// thus skips redundant error checking that should be performed by
    /// other functions if execution sequence has reached this step.
    ///
    /// # Terminology
    /// * The "target" user has an order that is on the order book
    /// * The "incoming" user's order has just been matched against the
    ///   target order by the matching engine
    ///
    /// # Parameters
    /// * `target`: Target user address
    /// * `incoming`: Incoming user address
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID of target order (See `Econia::ID`)
    /// * `size`: The fill size, in base coin parcels (See
    ///   `Econia::Registry`)
    /// * `scale_factor`: The scale factor for the given market (see
    ///   `Econia::Registry`)
    /// * `complete`: If `true`, target user's order is completely
    ///   filled, else only partially filled
    ///
    /// # Assumptions
    /// * Both users have order collateral containers with sufficient
    ///   collateral on hand
    /// * Target user has an open orders having an order with the
    ///   specified ID on the specified side, of sufficient size
    public(friend) fun process_fill<B, Q, E>(
        target: address,
        incoming: address,
        side: bool,
        id: u128,
        size: u64,
        scale_factor: u64,
        complete: bool,
    ) acquires OC {
        let orders_cap = orders_cap(); // Get orders friend capability
        // If target user's order completely filled, remove it from
        // their open orders
        if (complete) remove_order<B, Q, E>(target, side, id, &orders_cap) else
            // Else decrement their order size by the fill amount
            decrement_order_size<B, Q, E>(target, side, id, size, &orders_cap);
        // Compute amount of base coin subunits to route
        let base_to_route = size * scale_factor;
        // Compute amount of quote coin subunits to route
        let quote_to_route = size * id_price(id);
        // If target order is an ask, incoming user gets base coin from
        // target user
        let (base_to, base_from) = if (side == ASK) (incoming, target) else
            (target, incoming); // Flip the polarity if a bid
        // Get mutable reference to container yielding base coins
        let yields_base = borrow_global_mut<OC<B, Q, E>>(base_from);
        // Withdraw base coins from yielding container
        let base_coins = coin_extract<B>(&mut yields_base.b_c, base_to_route);
        // Get mutable reference to container receiving base coins
        let gets_base = borrow_global_mut<OC<B, Q, E>>(base_to);
        // Merge base coins into receiving container
        coin_merge<B>(&mut gets_base.b_c, base_coins);
        // Increment base coin recipient's available amount
        gets_base.b_a = gets_base.b_a + base_to_route;
        // Withdraw quote coins from base coin recipient
        let quote_coins = coin_extract<Q>(&mut gets_base.q_c, quote_to_route);
        // Get mutable reference to container getting quote coins
        let gets_quote = borrow_global_mut<OC<B, Q, E>>(base_from);
        // Merge quote coins into receiving container
        coin_merge<Q>(&mut gets_quote.q_c, quote_coins);
        // Increment quote coin recipient's available amount
        gets_quote.q_a = gets_quote.q_a + quote_to_route;
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Decrement `OC.b_a` and `OC.q_a` for extant `OC` at `user` by
    /// `base` and `quote` subunits, respectively. Does not check for
    /// underflow, as this should only be called after performing
    /// relevant sufficiency validity checks
    public fun dec_available_collateral<B, Q, E>(
        user: address,
        base: u64,
        quote: u64,
        _c: &OrdersCap
    ) acquires OC {
        // Borrow mutable reference to order collateral container
        let order_collateral = borrow_global_mut<OC<B, Q, E>>(user);
        // Decrement specified base coin amount
        order_collateral.b_a = order_collateral.b_a - base;
        // Decrement specified quote coin amount
        order_collateral.q_a = order_collateral.q_a - quote;
    }

    /// Deposit `b_val` base coin and `q_val` quote coin into `user`'s
    /// `OC`, from their `aptos_framework::Coin::CoinStore`
    public fun deposit_internal<B, Q, E>(
        user: &signer,
        b_val: u64,
        q_val: u64,
        _c: &OrdersCap
    ) acquires OC {
        let addr = address_of(user); // Get user address
        // Assert user has order collateral container
        assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
        // Assert user actually attempting to deposit
        assert!(b_val > 0 || q_val > 0, E_NO_TRANSFER);
        // Borrow mutable reference to user collateral container
        let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
        if (b_val > 0) { // If base coin to be deposited
            // Withdraw from CoinStore, merge into OC
            coin_merge<B>(&mut o_c.b_c, coin_withdraw<B>(user, b_val));
            o_c.b_a = o_c.b_a + b_val; // Increment available base coin
        };
        if (q_val > 0) { // If quote coin to be deposited
            // Withdraw from CoinStore, merge into OC
            coin_merge<Q>(&mut o_c.q_c, coin_withdraw<Q>(user, q_val));
            o_c.q_a = o_c.q_a + q_val; // Increment available quote coin
        };
    }

    /// Return `true` if specified order collateral container exists at
    /// address
    public fun exists_o_c<B, Q, E>(
        a: address,
        _c: &OrdersCap
    ): bool {
        exists<OC<B, Q, E>>(a)
    }

    /// Return `true` if `SC` exists at address
    public fun exists_sequence_counter(
        a: address,
        _c: &OrdersCap
    ): bool {
        exists<SC>(a)
    }

    /// Return `OC.b_a` and `OC.q_a` for extant `OC` at `user` address
    public fun get_available_collateral<B, Q, E>(
        user: address,
        _c: &OrdersCap
    ): (
        u64,
        u64
    ) acquires OC {
        // Borrow immutable reference to order collateral container
        let order_collateral = borrow_global<OC<B, Q, E>>(user);
        (order_collateral.b_a, order_collateral.q_a)
    }

    /// Update sequence counter for user `u` with the sequence number of
    /// the current transaction, aborting if user does not have an
    /// initialized sequence counter or if sequence number is not
    /// greater than the number indicated by the user's `SC`. Requires
    /// `OrdersCap` so can be called from external modules without
    /// invoking a dependency cycle
    public fun update_s_c(
        u: &signer,
        _c: &OrdersCap
    ) acquires SC {
        let user_addr = address_of(u); // Get user address
        // Assert user has already initialized a sequence counter
        assert!(exists<SC>(user_addr), E_NO_S_C);
        // Borrow mutable reference to user's sequence counter
        let s_c = borrow_global_mut<SC>(user_addr);
        let s_n = a_g_s_n(user_addr); // Get current sequence number
        // Assert new sequence number greater than that of counter
        assert!(s_n > s_c.i, E_INVALID_S_N);
        s_c.i = s_n; // Update counter with current sequence number
    }

    /// Withdraw `b_val` base coin and `q_val` quote coin from `user`'s
    /// `OC`, into their `aptos_framework::Coin::CoinStore`
    public fun withdraw_internal<B, Q, E>(
        user: &signer,
        b_val: u64,
        q_val: u64,
        _c: &OrdersCap
    ) acquires OC {
        let addr = address_of(user); // Get user address
        // Assert user has order collateral container
        assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
        // Assert user actually attempting to withdraw
        assert!(b_val > 0 || q_val > 0, E_NO_TRANSFER);
        // Borrow mutable reference to user collateral container
        let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
        if (b_val > 0) { // If base coin to be withdrawn
            // Assert not trying to withdraw more than available
            assert!(!(b_val > o_c.b_a), E_WITHDRAW_TOO_MUCH);
            // Withdraw from order collateral, deposit to coin store
            c_d<B>(addr, coin_extract<B>(&mut o_c.b_c, b_val));
            o_c.b_a = o_c.b_a - b_val; // Update available amount
        };
        if (q_val > 0) { // If quote coin to be withdrawn
            // Assert not trying to withdraw more than available
            assert!(!(q_val > o_c.q_a), E_WITHDRAW_TOO_MUCH);
            // Withdraw from order collateral, deposit to coin store
            c_d<Q>(addr, coin_extract<Q>(&mut o_c.q_c, q_val));
            o_c.q_a = o_c.q_a - q_val; // Update available amount
        };
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Cancel order for market `<B, Q, E>` and update available
    /// collateral accordingly, aborting if user does not have an order
    /// collateral container
    ///
    /// # Parameters
    /// * `user`: User cancelling an order
    /// * `host`: The market host (See `Econia::Registry`)
    /// * `side`: `ASK` or `BID`
    /// * `id`: Order ID (see `Econia::ID`)
    fun cancel_order<B, Q, E>(
        user: &signer,
        host: address,
        side: bool,
        id: u128
    ) acquires SC, OC {
        update_s_c(user, &orders_cap()); // Update user sequence counter
        let addr = address_of(user); // Get user address
        // Assert user has order collateral container
        assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
        // Borrow mutable reference to user's order collateral container
        let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
        if (side == ASK) { // If cancelling an ask
            // Cancel on user's open orders, storing scaled size
            let s_s = o_c_a<B, Q, E>(addr, id, &orders_cap());
            // Cancel on order book
            b_c_a<B, Q, E>(host, id, &book_cap());
            // Increment amount of base coins available for withdraw,
            // by order scaled size times scale factor on given market
            o_c.b_a = o_c.b_a +
                s_s * orders_scale_factor<B, Q, E>(addr, &orders_cap());
        } else { // If cancelling a bid
            // Cancel on user's open orders, storing scaled size
            let s_s = o_c_b<B, Q, E>(addr, id, &orders_cap());
            // Cancel on order book
            b_c_b<B, Q, E>(host, id, &book_cap());
            // Increment amount of quote coins available for withdraw,
            // by order scaled size times price from order ID
            o_c.q_a = o_c.q_a + s_s * id_price(id);
        }
    }

    /// Initialize order collateral container for given user, aborting
    /// if already initialized
    fun init_o_c<B, Q, E>(
        user: &signer,
    ) {
        // Assert user does not already have order collateral for market
        assert!(!exists<OC<B, Q, E>>(address_of(user)), E_O_C_EXISTS);
        // Assert given market has actually been registered
        assert!(r_i_r<B, Q, E>(), E_NO_MARKET);
        // Pack empty order collateral container
        let o_c = OC<B, Q, E>{b_c: c_z<B>(), b_a: 0, q_c: c_z<Q>(), q_a: 0};
        move_to<OC<B, Q, E>>(user, o_c); // Move to user account
    }

    /// Submit limit order for market `<B, Q, E>`
    ///
    /// # Parameters
    /// * `user`: User submitting a limit order
    /// * `host`: The market host (See `Econia::Registry`)
    /// * `side`: `ASK` or `BID`
    /// * `price`: Scaled integer price (see `Econia::ID`)
    /// * `size`: Scaled order size (number of base coin parcels per
    ///   `Econia::Orders`)
    ///
    /// # Abort conditions
    /// * If no such market exists at host address
    /// * If user does not have order collateral container for market
    /// * If user does not have enough collateral
    /// * If placing an order would cross the spread
    fun submit_limit_order<B, Q, E>(
        user: &signer,
        host: address,
        side: bool,
        price: u64,
        size: u64
    ) acquires OC, SC {
        update_s_c(user, &orders_cap()); // Update user sequence counter
        // Assert market exists at given host address
        assert!(b_e_b<B, Q, E>(host, &book_cap()), E_NO_MARKET);
        let addr = address_of(user); // Get user address
        // Assert user has order collateral container
        assert!(exists<OC<B, Q, E>>(addr), E_NO_O_C);
        // Borrow mutable reference to user's order collateral container
        let o_c = borrow_global_mut<OC<B, Q, E>>(addr);
        let v_n = get_v_n(); // Get transaction version number
        let c_s: bool; // Define flag for if order crosses the spread
        if (side == ASK) { // If limit order is an ask
            let id = id_a(price, v_n); // Get corresponding order id
            // Verify and add to user's open orders, storing amount of
            // base coin subunits required to fill the trade
            let (b_c_subs, _) =
                o_a_a<B, Q, E>(addr, id, price, size, &orders_cap());
            // Assert user has enough base coins held as collateral
            assert!(!(b_c_subs > o_c.b_a), E_NOT_ENOUGH_COLLATERAL);
            // Decrement amount of base coins available for withdraw
            o_c.b_a = o_c.b_a - b_c_subs;
            // Try adding to order book, storing crossed spread flag
            c_s =
                b_a_a<B, Q, E>(host, addr, id, price, size, &book_cap());
        } else { // If limit order is a bid
            let id = id_b(price, v_n); // Get corresponding order id
            // Verify and add to user's open orders, storing amount of
            // quote coin subunits required to fill the trade
            let (_, q_c_subs) =
                o_a_b<B, Q, E>(addr, id, price, size, &orders_cap());
            // Assert user has enough quote coins held as collateral
            assert!(!(q_c_subs > o_c.q_a), E_NOT_ENOUGH_COLLATERAL);
            // Decrement amount of quote coins available for withdraw
            o_c.q_a = o_c.q_a - q_c_subs;
            // Try adding to order book, storing crossed spread flag
            c_s =
                b_a_b<B, Q, E>(host, addr, id, price, size, &book_cap());
        };
        assert!(!c_s, E_CROSSES_SPREAD); // Assert uncrossed spread
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return field values for extant `OC` under `user` address for
    /// given market
    ///
    /// # Returns
    /// * `u64`: `OC.b_a`
    /// * `u64`: Indivisible subunits in `OC.b_c`
    /// * `u64`: `OC.q_a`
    /// * `u64`: Indivisible subunits in `OC.q_c`
    public fun check_collateral<B, Q, E>(
        user: address,
    ): (
        u64,
        u64,
        u64,
        u64
    ) acquires OC {
        // Borrow immutable reference to user's collateral container
        let collateral = borrow_global<OC<B, Q, E>>(user);
        // Return interpreted field values
        (collateral.b_a, coin_value<B>(&collateral.b_c),
         collateral.q_a, coin_value<Q>(&collateral.q_c))
    }

    #[test_only]
    /// Initialize a user with containers for a test market
    public entry fun init_test_market_user(
        econia: &signer,
        user: &signer
    ) {
        init_econia(econia); // Initialize Econia core resources
        r_r_t_m(econia); // Register test market
        create_account(address_of(user)); // Initialize Account resource
        init_user(user); // Initialize user
        init_containers<BCT, QCT, E0>(user); // Initialize containers
        coin_register<BCT>(user); // Register user with base coin store
        coin_register<QCT>(user); // Register user with quote coin store
    }

    #[test_only]
    /// Initialize test market with scale exponent `E` hosted by Econia,
    /// funding a test user with `b_c` base coins and `q_c` quote coins
    public entry fun init_test_scaled_market_funded_user<E>(
        econia: &signer,
        user: &signer,
        b_c: u64,
        q_c: u64
    ) acquires OC, SC {
        init_econia(econia); // Initialize Econia core resources
        // Register scaled test market under Econia registry
        register_scaled_test_market<E>(econia);
        init_funded_user<E>(user, b_c, q_c); // Initialize funded user
    }

    #[test_only]
    /// Initialize `user` to trade on test market with scale exponent
    /// `E`, funding with `b_c` base coins and `q_c` quote coins
    public entry fun init_funded_user<E>(
        user: &signer,
        base_coins: u64,
        quote_coins: u64
    ) acquires OC, SC {
        let user_addr = address_of(user); // Get user address
        create_account(user_addr); // Initialize Account resource
        init_user(user); // Initialize user
        inc_seq_number(user_addr); // Increment mock sequence number
        init_containers<BCT, QCT, E>(user); // Initialize containers
        inc_seq_number(user_addr); // Increment mock sequence number
        coin_register<BCT>(user); // Register user with base coin store
        coin_register<QCT>(user); // Register user with quote coin store
        mint_bct_to(user_addr, base_coins); // Mint base coins to user
        mint_qct_to(user_addr, quote_coins); // Mint quote coins to user
        // Deposit all coins into collateral container
        deposit<BCT, QCT, E>(user, base_coins, quote_coins);
        inc_seq_number(user_addr); // Increment mock sequence number
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for user not having order collateral container
    public entry fun cancel_order_failure_no_o_c(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_caps(econia); // Initialize friend-like capabilities
        create_account(@TestUser); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        inc_seq_number(@TestUser); // Increment mock sequence number
        // Attempt invalid order cancellation
        cancel_bid<BCT, QCT, E0>(user, @TestUser, 1);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful ask cancellation
    public entry fun cancel_ask_success(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 1, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E1>(econia, user, 100, 200);
        // Get version number of upcoming order
        let order_v_n = get_v_n() + 1;
        // Define order price, number of base coin parcels in order
        let (price, size) = (5, 3);
        let id = id_a(price, order_v_n); // Get order ID
        // Submit ask
        submit_ask<BCT, QCT, E1>(user, @Econia, price, size);
        // Assert user has ask registered in open orders
        assert!(orders_has_ask<BCT, QCT, E1>(@TestUser, id), 0);
        // Assert ask registered in order book
        assert!(b_h_a<BCT, QCT, E1>(@Econia, id), 1);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E1>>(@TestUser);
        // Assert correct collateral available amounts
        assert!(o_c.b_a == 70 && o_c.q_a == 200, 2);
        inc_seq_number(@TestUser); // Increment mock sequence number
        cancel_ask<BCT, QCT, E1>(user, @Econia, id); // Cancel ask
        // Assert user no longer has ask registered in open orders
        assert!(!orders_has_ask<BCT, QCT, E1>(@TestUser, id), 3);
        // Assert ask no longer registered in order book
        assert!(!b_h_a<BCT, QCT, E1>(@Econia, id), 4);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E1>>(@TestUser);
        // Assert correct collateral available amounts
        assert!(o_c.b_a == 100 && o_c.q_a == 200, 5);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful bid cancellation
    public entry fun cancel_bid_success(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 1, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E1>(econia, user, 100, 200);
        // Get version number of upcoming order
        let order_v_n = get_v_n() + 1;
        // Define order price, number of base coin parcels in order
        let (price, size) = (5, 3);
        let id = id_b(price, order_v_n); // Get order ID
        // Submit bid
        submit_bid<BCT, QCT, E1>(user, @Econia, price, size);
        // Assert user has bid registered in open orders
        assert!(orders_has_bid<BCT, QCT, E1>(@TestUser, id), 0);
        // Assert bid registered in order book
        assert!(b_h_b<BCT, QCT, E1>(@Econia, id), 1);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E1>>(@TestUser);
        // Assert correct collateral available amounts
        assert!(o_c.b_a == 100 && o_c.q_a == 185, 2);
        inc_seq_number(@TestUser); // Increment mock sequence number
        cancel_bid<BCT, QCT, E1>(user, @Econia, id); // Cancel bid
        // Assert user no longer has bid registered in open orders
        assert!(!orders_has_bid<BCT, QCT, E1>(@TestUser, id), 3);
        // Assert bid no longer registered in order book
        assert!(!b_h_b<BCT, QCT, E1>(@Econia, id), 4);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E1>>(@TestUser);
        // Assert correct collateral available amounts
        assert!(o_c.b_a == 100 && o_c.q_a == 200, 5);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no deposit indicated
    public entry fun deposit_failure_no_deposit(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_test_market_user(econia, user); // Init test market, user
        deposit<BCT, QCT, E0>(user, 0, 0); // Attempt invalid deposit
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for no order collateral container initialized
    public entry fun deposit_failure_no_o_c(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_econia(econia); // Initialize Econia core resources
        deposit<BCT, QCT, E0>(user, 1, 2); // Attempt invalid deposit
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful collateral deposits
    public entry fun deposit_success(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_test_market_user(econia, user); // Init test market, user
        let addr = address_of(user); // Get user address
        mint_bct_to(addr, 100); // Mint 100 base coins to user
        mint_qct_to(addr, 200); // Mint 200 base coins to user
        inc_seq_number(addr); // Increment mock sequence number
        deposit<BCT, QCT, E0>(user, 1, 0); // Deposit one base coin
        // Assert correct coin store balances
        assert!(c_b<BCT>(addr) == 99 && c_b<QCT>(addr) == 200, 0);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E0>>(addr);
        // Assert collateral holdings update correctly
        assert!(coin_value<BCT>(&o_c.b_c) == 1 &&
                coin_value<QCT>(&o_c.q_c) == 0, 1);
        // Assert withdraw availability updates correctly
        assert!(o_c.b_a == 1 && o_c.q_a == 0, 2);
        inc_seq_number(addr); // Increment mock sequence number
        deposit<BCT, QCT, E0>(user, 0, 2); // Deposit two quote coin
        // Assert correct coin store balances
        assert!(c_b<BCT>(addr) == 99 && c_b<QCT>(addr) == 198, 3);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E0>>(addr);
        // Assert collateral holdings update correctly
        assert!(coin_value<BCT>(&o_c.b_c) == 1 &&
                coin_value<QCT>(&o_c.q_c) == 2, 4);
        // Assert withdraw availability updates correctly
        assert!(o_c.b_a == 1 && o_c.q_a == 2, 5);
        inc_seq_number(addr); // Increment mock sequence number
        deposit<BCT, QCT, E0>(user, 5, 5); // Deposit 5 of each coin
        // Assert correct coin store balances
        assert!(c_b<BCT>(addr) == 94 && c_b<QCT>(addr) == 193, 6);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E0>>(addr);
        // Assert collateral holdings update correctly
        assert!(coin_value<BCT>(&o_c.b_c) == 6 &&
                coin_value<QCT>(&o_c.q_c) == 7, 7);
        // Assert withdraw availability updates correctly
        assert!(o_c.b_a == 6 && o_c.q_a == 7, 8);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for attempting to re-initialize order collateral
    public entry fun init_o_c_failure_exists(
        econia: &signer,
        user: &signer
    ) {
        init_econia(econia); // Initialize Econia core account resources
        r_r_t_m(econia); // Register test market
        init_o_c<BCT, QCT, E0>(user); // Initialize order collateral
        init_o_c<BCT, QCT, E0>(user); // Attempt invalid re-init
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to initialize order collateral for
    /// non-existent market
    fun init_o_c_failure_no_market(
        user: &signer
    ) {
        init_o_c<BCT, QCT, E0>(user); // Attempt invalid intialization
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful initialization of order collateral
    public entry fun init_o_c_success(
        econia: &signer,
        user: &signer
    ) acquires OC {
        init_econia(econia); // Initialize Econia core account resources
        r_r_t_m(econia); // Register test market
        init_o_c<BCT, QCT, E0>(user); // Initialize order collateral
        // Borrow immutable reference to order collateral container
        let o_c = borrow_global<OC<BCT, QCT, E0>>(address_of(user));
        // Assert no base coins or quote coins in collateral container
        assert!(coin_value(&o_c.b_c) == 0 &&
                coin_value(&o_c.q_c) == 0, 0);
        // Assert no base coins or quote coins marked available
        assert!(o_c.b_a == 0 && o_c.q_a == 0, 1);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for user having order collateral container
    public entry fun init_containers_failure_has_o_c(
        econia: &signer,
        user: &signer
    ) {
        init_econia(econia); // Initialize Econia core account resources
        r_r_t_m(econia); // Register test market
        init_o_c<BCT, QCT, E0>(user); // Init order collateral container
        init_containers<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for user already having open orders container
    public entry fun init_containers_failure_has_o_o(
        econia: &signer,
        user: &signer
    ) {
        init_econia(econia); // Initialize Econia core account resources
        r_r_t_m(econia); // Register test market
        // Initialize empty open orders container under user account
        o_i_o<BCT, QCT, E0>(user, r_s_f<E0>(), &orders_cap());
        init_containers<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for unregistered market
    public entry fun init_containers_failure_no_market(
        user: &signer
    ) {
        init_containers<BCT, QCT, E0>(user); // Attempt invalid init
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]

    /// Verify successful user initialization
    public entry fun init_containers_success(
        econia: &signer,
        user: &signer
    ) acquires OC {
        init_econia(econia); // Initalize Econia core account resources
        r_r_t_m(econia); // Register test market
        // Init test market user containers
        init_containers<BCT, QCT, E0>(user);
        let user_addr = address_of(user); // Get user address
        // Borrow immutable reference to order collateral container
        let o_c = borrow_global<OC<BCT, QCT, E0>>(user_addr);
        // Assert no base coins or quote coins in collateral container
        assert!(coin_value(&o_c.b_c) == 0 &&
                coin_value(&o_c.q_c) == 0, 0);
        // Assert no base coins or quote coins marked available
        assert!(o_c.b_a == 0 && o_c.q_a == 0, 1);
        // Assert open orders exists and has correct scale factor
        assert!(orders_scale_factor<BCT, QCT, E0>(user_addr, &orders_cap()) ==
            r_s_f<E0>(), 0);
    }

    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for attempted re-initialization
    public entry fun init_user_failure(
        user: &signer
    ) {
        create_account(address_of(user)); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        init_user(user); // Attempt invalid re-initialization
    }

    #[test(user = @TestUser)]
    /// Verify successful initialization
    public entry fun init_user_success(
        user: &signer
    ) {
        let user_addr = address_of(user); // Get user address
        create_account(user_addr); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        // Assert sequence counter initializes to user sequence number
        assert!(a_g_s_n(user_addr) == 0, 0);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful processing of filling against position on book
    public entry fun process_fill_ask_complete(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        let user_base_start = 100; // Define user's start base coins
        let user_quote_start = 200; // Define user's start quote coins
        // Initialize test market with scale exponent 1, fund user
        init_test_scaled_market_funded_user<E1>(
            econia, user, user_base_start, user_quote_start);
        let scale_factor = 10; // Define corresponding scale factor
        // Initialize Econia as funded user on same market
        let econia_base_start = 150; // Define Econia start base coins
        let econia_quote_start = 250; // Define Econia start quote coins
        init_funded_user<E1>(econia, econia_base_start, econia_quote_start);
        // Get upcoming order version number
        let order_v_n = get_v_n() + 1;
        let order_price = 5; // Define order price
        let order_size = 3; // Define order size
        let id = id_a(order_price, order_v_n); // Get order ID
        // Submit ask from Econia account
        submit_ask<BCT, QCT, E1>(econia, @Econia, order_price, order_size);
        let fill_size = order_size; // Define fill size
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Decrement user's availabe quote coins by amount required to
        // fill trade (simulated market order placement)
        user_collateral.q_a = user_collateral.q_a - fill_size * order_price;
        // Process complete fill for incoming user order
        process_fill<BCT, QCT, E1>(
            @Econia, @TestUser, ASK, id, fill_size, scale_factor, true);
        // Assert Econia no longer has open order
        assert!(!orders_has_ask<BCT, QCT, E1>(@Econia, id), 0);
        // Borrow immutable reference to Econia's order collateral
        let econia_collateral = borrow_global<OC<BCT, QCT, E1>>(@Econia);
        // Assert proper values for Econia available collateral amounts
        assert!(econia_collateral.b_a ==
            econia_base_start - order_size * scale_factor, 1);
        assert!(econia_collateral.q_a ==
            econia_quote_start + order_price * fill_size, 2);
        // Assert proper amount of coins in Econia collateral
        assert!(coin_value(&econia_collateral.b_c) ==
            econia_base_start - fill_size * scale_factor, 3);
        assert!(coin_value(&econia_collateral.q_c) ==
            econia_quote_start + order_price * fill_size, 4);
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Assert proper values for user available collateral amounts
        assert!(user_collateral.b_a ==
            user_base_start + fill_size * scale_factor, 5);
        assert!(user_collateral.q_a ==
            user_quote_start - fill_size * order_price, 6);
        // Assert proper amount of coins in user collateral
        assert!(coin_value(&user_collateral.b_c) ==
            user_base_start + fill_size * scale_factor, 7);
        assert!(coin_value(&user_collateral.q_c) ==
            user_quote_start - fill_size * order_price, 8);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful processing of filling against position on book
    public entry fun process_fill_ask_partial(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        let user_base_start = 100; // Define user's start base coins
        let user_quote_start = 200; // Define user's start quote coins
        // Initialize test market with scale exponent 1, fund user
        init_test_scaled_market_funded_user<E1>(
            econia, user, user_base_start, user_quote_start);
        let scale_factor = 10; // Define corresponding scale factor
        // Initialize Econia as funded user on same market
        let econia_base_start = 150; // Define Econia start base coins
        let econia_quote_start = 250; // Define Econia start quote coins
        init_funded_user<E1>(econia, econia_base_start, econia_quote_start);
        // Get upcoming order version number
        let order_v_n = get_v_n() + 1;
        let order_price = 5; // Define order price
        let order_size = 3; // Define order size
        let id = id_a(order_price, order_v_n); // Get order ID
        // Submit ask from Econia account
        submit_ask<BCT, QCT, E1>(econia, @Econia, order_price, order_size);
        let fill_size = 2; // Define fill size
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Decrement user's availabe quote coins by amount required to
        // fill trade (simulated market order placement)
        user_collateral.q_a = user_collateral.q_a - fill_size * order_price;
        // Process partial fill for incoming user order
        process_fill<BCT, QCT, E1>(
            @Econia, @TestUser, ASK, id, fill_size, scale_factor, false);
        // Assert Econia's open order size decremented accordingly
        assert!(orders_check_ask<BCT, QCT, E1>(@Econia, id) ==
            order_size - fill_size, 0);
        // Borrow immutable reference to Econia's order collateral
        let econia_collateral = borrow_global<OC<BCT, QCT, E1>>(@Econia);
        // Assert proper values for Econia available collateral amounts
        assert!(econia_collateral.b_a ==
            econia_base_start - order_size * scale_factor, 1);
        assert!(econia_collateral.q_a ==
            econia_quote_start + order_price * fill_size, 2);
        // Assert proper amount of coins in Econia collateral
        assert!(coin_value(&econia_collateral.b_c) ==
            econia_base_start - fill_size * scale_factor, 3);
        assert!(coin_value(&econia_collateral.q_c) ==
            econia_quote_start + order_price * fill_size, 4);
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Assert proper values for user available collateral amounts
        assert!(user_collateral.b_a ==
            user_base_start + fill_size * scale_factor, 5);
        assert!(user_collateral.q_a ==
            user_quote_start - fill_size * order_price, 6);
        // Assert proper amount of coins in user collateral
        assert!(coin_value(&user_collateral.b_c) ==
            user_base_start + fill_size * scale_factor, 7);
        assert!(coin_value(&user_collateral.q_c) ==
            user_quote_start - fill_size * order_price, 8);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful processing of filling against position on book
    public entry fun process_fill_bid_complete(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        let user_base_start = 100; // Define user's start base coins
        let user_quote_start = 200; // Define user's start quote coins
        // Initialize test market with scale exponent 1, fund user
        init_test_scaled_market_funded_user<E1>(
            econia, user, user_base_start, user_quote_start);
        let scale_factor = 10; // Define corresponding scale factor
        // Initialize Econia as funded user on same market
        let econia_base_start = 150; // Define Econia start base coins
        let econia_quote_start = 250; // Define Econia start quote coins
        init_funded_user<E1>(econia, econia_base_start, econia_quote_start);
        // Get upcoming order version number
        let order_v_n = get_v_n() + 1;
        let order_price = 5; // Define order price
        let order_size = 3; // Define order size
        let id = id_b(order_price, order_v_n); // Get order ID
        // Submit bid from Econia account
        submit_bid<BCT, QCT, E1>(econia, @Econia, order_price, order_size);
        let fill_size = order_size; // Define fill size
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Decrement user's availabe base coins by amount required to
        // fill trade (simulated market order placement)
        user_collateral.b_a = user_collateral.b_a - fill_size * scale_factor;
        // Process complete fill for incoming user order
        process_fill<BCT, QCT, E1>(
            @Econia, @TestUser, BID, id, fill_size, scale_factor, true);
        // Assert Econia no longer has open order
        assert!(!orders_has_bid<BCT, QCT, E1>(@Econia, id), 0);
        // Borrow immutable reference to Econia's order collateral
        let econia_collateral = borrow_global<OC<BCT, QCT, E1>>(@Econia);
        // Assert proper values for Econia available collateral amounts
        assert!(econia_collateral.b_a ==
            econia_base_start + fill_size * scale_factor, 1);
        assert!(econia_collateral.q_a ==
            econia_quote_start - order_price * order_size, 2);
        // Assert proper amount of coins in Econia collateral
        assert!(coin_value(&econia_collateral.b_c) ==
            econia_base_start + fill_size * scale_factor, 3);
        assert!(coin_value(&econia_collateral.q_c) ==
            econia_quote_start - order_price * order_size, 4);
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Assert proper values for user available collateral amounts
        assert!(user_collateral.b_a ==
            user_base_start - fill_size * scale_factor, 5);
        assert!(user_collateral.q_a ==
            user_quote_start + fill_size * order_price, 6);
        // Assert proper amount of coins in user collateral
        assert!(coin_value(&user_collateral.b_c) ==
            user_base_start - fill_size * scale_factor, 7);
        assert!(coin_value(&user_collateral.q_c) ==
            user_quote_start + fill_size * order_price, 8);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful processing of filling against position on book
    public entry fun process_fill_bid_partial(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        let user_base_start = 100; // Define user's start base coins
        let user_quote_start = 200; // Define user's start quote coins
        // Initialize test market with scale exponent 1, fund user
        init_test_scaled_market_funded_user<E1>(
            econia, user, user_base_start, user_quote_start);
        let scale_factor = 10; // Define corresponding scale factor
        // Initialize Econia as funded user on same market
        let econia_base_start = 150; // Define Econia start base coins
        let econia_quote_start = 250; // Define Econia start quote coins
        init_funded_user<E1>(econia, econia_base_start, econia_quote_start);
        // Get upcoming order version number
        let order_v_n = get_v_n() + 1;
        let order_price = 5; // Define order price
        let order_size = 3; // Define order size
        let id = id_b(order_price, order_v_n); // Get order ID
        // Submit bid from Econia account
        submit_bid<BCT, QCT, E1>(econia, @Econia, order_price, order_size);
        let fill_size = 2; // Define fill size
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Decrement user's availabe base coins by amount required to
        // fill trade (simulated market order placement)
        user_collateral.b_a = user_collateral.b_a - fill_size * scale_factor;
        // Process partial fill for incoming user order
        process_fill<BCT, QCT, E1>(
            @Econia, @TestUser, BID, id, fill_size, scale_factor, false);
        // Assert Econia's open order size decremented accordingly
        assert!(orders_check_bid<BCT, QCT, E1>(@Econia, id) ==
            order_size - fill_size, 0);
        // Borrow immutable reference to Econia's order collateral
        let econia_collateral = borrow_global<OC<BCT, QCT, E1>>(@Econia);
        // Assert proper values for Econia available collateral amounts
        assert!(econia_collateral.b_a ==
            econia_base_start + fill_size * scale_factor, 1);
        assert!(econia_collateral.q_a ==
            econia_quote_start - order_price * order_size, 2);
        // Assert proper amount of coins in Econia collateral
        assert!(coin_value(&econia_collateral.b_c) ==
            econia_base_start + fill_size * scale_factor, 3);
        assert!(coin_value(&econia_collateral.q_c) ==
            econia_quote_start - order_price * fill_size, 4);
        // Borrow mutable reference to user's order collateral
        let user_collateral = borrow_global_mut<OC<BCT, QCT, E1>>(@TestUser);
        // Assert proper values for user available collateral amounts
        assert!(user_collateral.b_a ==
            user_base_start - fill_size * scale_factor, 5);
        assert!(user_collateral.q_a ==
            user_quote_start + fill_size * order_price, 6);
        // Assert proper amount of coins in user collateral
        assert!(coin_value(&user_collateral.b_c) ==
            user_base_start - fill_size * scale_factor, 7);
        assert!(coin_value(&user_collateral.q_c) ==
            user_quote_start + fill_size * order_price, 8);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for user having insufficient collateral
    public entry fun submit_ask_failure_collateral(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 1, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E1>(econia, user, 100, 200);
        // Attempt submitting invalid ask of size 110 base coins
        submit_ask<BCT, QCT, E1>(user, address_of(econia), 1, 110);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for user placing order that crosses spread
    public entry fun submit_ask_failure_crossed_spread(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 0, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E0>(econia, user, 100, 200);
        let host = address_of(econia); // Get market host address
        // Submit bid of price 5, size 2
        submit_bid<BCT, QCT, E0>(user, host, 5, 2);
        let user_addr = address_of(user); // Get user address
        inc_seq_number(user_addr); // Increment mock sequence number
        // Submit ask of price 7, size 3
        submit_ask<BCT, QCT, E0>(user, host, 7, 3);
        inc_seq_number(user_addr); // Increment mock sequence number
        // Submit invalid ask of price 4, size 4, crossing the spread
        submit_ask<BCT, QCT, E0>(user, host, 4, 4);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful ask submission
    public entry fun submit_ask_success(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 1, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E1>(econia, user, 100, 200);
        let host = address_of(econia); // Get market host address
        let user_addr = address_of(user); // Get user address
        // Get version number of upcoming order
        let order_v_n = get_v_n() + 1;
        // Define order price, number of base coin parcels in order
        let (price, size) = (5, 3);
        let id = id_a(price, order_v_n); // Get order ID
        submit_ask<BCT, QCT, E1>(user, host, price, size); // Submit ask
        // Assert added to user's open orders
        assert!(orders_check_ask<BCT, QCT, E1>(user_addr, id) == size, 0);
        // Get corresponding position size and address on book
        let (p_s, p_a) = b_ch_a<BCT, QCT, E1>(host, id);
        // Assert added to order book correctly
        assert!(p_s == size && p_a == user_addr, 1);
        // Assert min ask ID on book updated correctly
        assert!(b_ch_a_m<BCT, QCT, E1>(host) == id, 2);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E1>>(user_addr);
        // Assert coin holdings in collateral unchanged
        assert!(coin_value<BCT>(&o_c.b_c) == 100 &&
                coin_value<QCT>(&o_c.q_c) == 200, 3);
        // Assert updated collateral available amounts
        assert!(o_c.b_a == 70 && o_c.q_a == 200, 4);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for user having insufficient collateral
    public entry fun submit_bid_failure_collateral(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 1, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E1>(econia, user, 100, 200);
        // Attempt submitting invalid bid for 10 base coins at a scaled
        // price of 201 (201 quote coins for 10 scaled coins)
        submit_bid<BCT, QCT, E1>(user, address_of(econia), 201, 10);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for user placing order that crosses spread
    public entry fun submit_bid_failure_crossed_spread(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 0, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E0>(econia, user, 100, 200);
        let host = address_of(econia); // Get market host address
        // Submit bid of price 5, size 2
        submit_bid<BCT, QCT, E0>(user, host, 5, 2);
        let user_addr = address_of(user); // Get user address
        inc_seq_number(user_addr); // Increment mock sequence number
        // Submit ask of price 7, size 3
        submit_ask<BCT, QCT, E0>(user, host, 7, 3);
        inc_seq_number(user_addr); // Increment mock sequence number
        // Submit invalid bid of price 8, size 4, crossing the spread
        submit_bid<BCT, QCT, E0>(user, host, 8, 4);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful ask submission
    public entry fun submit_bid_success(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        // Initialize test market with scale exponent 1, fund user with
        // 100 base coins and 200 quote coins
        init_test_scaled_market_funded_user<E1>(econia, user, 100, 200);
        let host = address_of(econia); // Get market host address
        let user_addr = address_of(user); // Get user address
        // Get version number of upcoming order
        let order_v_n = get_v_n() + 1;
        // Define order price, number of base coin parcels in order
        let (price, size) = (5, 3);
        let id = id_b(price, order_v_n); // Get order ID
        submit_bid<BCT, QCT, E1>(user, host, price, size); // Submit ask
        // Assert added to user's open orders
        assert!(orders_check_bid<BCT, QCT, E1>(user_addr, id) == size, 0);
        // Get corresponding position size and address on book
        let (p_s, p_a) = b_ch_b<BCT, QCT, E1>(host, id);
        // Assert added to order book correctly
        assert!(p_s == size && p_a == user_addr, 1);
        // Assert max bid ID on book updated correctly
        assert!(b_ch_b_m<BCT, QCT, E1>(host) == id, 2);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E1>>(user_addr);
        // Assert coin holdings in collateral unchanged
        assert!(coin_value<BCT>(&o_c.b_c) == 100 &&
                coin_value<QCT>(&o_c.q_c) == 200, 3);
        // Assert updated collateral available amounts
        assert!(o_c.b_a == 100 && o_c.q_a == 185, 4);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for no such market
    public entry fun submit_limit_order_failure_no_market(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_caps(econia); // Initialize friend-like capabilities
        let user_addr = address_of(user); // Get user address
        create_account(user_addr); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        inc_seq_number(user_addr); // Increment mock sequence number
        // Attempt invalid limit order
        submit_ask<BCT, QCT, E0>(user, address_of(user), 1, 1);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for user not having order collateral container
    public entry fun submit_limit_order_failure_no_o_c(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_econia(econia); // Initialize Econia core resources
        r_r_t_m(econia); // Register test market
        let user_addr = address_of(user); // Get user address
        create_account(user_addr); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        inc_seq_number(user_addr); // Increment mock sequence number
        // Attempt invalid limit order
        submit_bid<BCT, QCT, E0>(user, address_of(econia), 1, 1);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for user not having initialized counter
    fun update_s_c_failure_no_s_c(
        econia: &signer,
        user: &signer
    ) acquires SC {
        init_caps(econia); // Initialize friend-like capabilities
        update_s_c(user, &orders_cap()); // Attempt invalid update
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for trying to update twice in same transaction
    public entry fun update_s_c_failure_same_s_n(
        econia: &signer,
        user: &signer
    ) acquires SC {
        init_caps(econia); // Initialize friend-like capabilities
        let user_addr = address_of(user); // Get user address
        create_account(user_addr); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        // Attempt invalid update during same transaction as init
        update_s_c(user, &orders_cap());
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful update for arbitrary (valid) sequence number
    public entry fun update_s_c_success(
        econia: &signer,
        user: &signer
    ) acquires SC {
        init_caps(econia); // Initialize friend-like capabilities
        let user_addr = address_of(user); // Get user address
        create_account(user_addr); // Initialize Account resource
        init_user(user); // Initialize sequence counter for user
        a_s_s_n(user_addr, 10); // Set mock sequence number
        update_s_c(user, &orders_cap()); // Execute valid counter update
        // Assert sequence counter updated correctly
        assert!(borrow_global<SC>(user_addr).i == 10, 0);
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for attempting to withdraw too many base coins
    public entry fun withdraw_failure_excess_bct(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_test_market_user(econia, user); // Init test market, user
        let addr = address_of(user); // Get user address
        mint_bct_to(addr, 100); // Mint 100 base coins to user
        inc_seq_number(addr); // Increment mock sequence number
        deposit<BCT, QCT, E0>(user, 50, 0); // Deposit collateral
        inc_seq_number(addr); // Increment mock sequence number
        withdraw<BCT, QCT, E0>(user, 51, 0); // Attempt invalid withdraw
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for attempting to withdraw too many quote coins
    public entry fun withdraw_failure_excess_qct(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_test_market_user(econia, user); // Init test market, user
        let addr = address_of(user); // Get user address
        mint_qct_to(addr, 100); // Mint 100 quote coins to user
        inc_seq_number(addr); // Increment mock sequence number
        deposit<BCT, QCT, E0>(user, 0, 50); // Deposit collateral
        inc_seq_number(addr); // Increment mock sequence number
        withdraw<BCT, QCT, E0>(user, 0, 51); // Attempt invalid withdraw
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for no order collateral container initialized
    public entry fun withdraw_failure_no_o_c(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_econia(econia); // Initialize Econia core resources
        withdraw<BCT, QCT, E0>(user, 1, 2); // Attempt invalid withdraw
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for no withdraw indicated
    public entry fun withdraw_failure_no_withdraw(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_test_market_user(econia, user); // Init test market, user
        withdraw<BCT, QCT, E0>(user, 0, 0); // Attempt invalid withdraw
    }

    #[test(
        econia = @Econia,
        user = @TestUser
    )]
    /// Verify successful collateral withdrawals
    public entry fun withdraw_success(
        econia: &signer,
        user: &signer
    ) acquires OC, SC {
        init_test_market_user(econia, user); // Init test market, user
        let addr = address_of(user); // Get user address
        mint_bct_to(addr, 100); // Mint 100 base coins to user
        mint_qct_to(addr, 200); // Mint 200 base coins to user
        inc_seq_number(addr); // Increment mock sequence number
        deposit<BCT, QCT, E0>(user, 75, 150); // Deposit collateral
        inc_seq_number(addr); // Increment mock sequence number
        withdraw<BCT, QCT, E0>(user, 5, 0); // Withdraw 5 base coins
        // Assert correct coin store balances
        assert!(c_b<BCT>(addr) == 30 && c_b<QCT>(addr) == 50, 0);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E0>>(addr);
        // Assert collateral holdings update correctly
        assert!(coin_value<BCT>(&o_c.b_c) == 70 &&
                coin_value<QCT>(&o_c.q_c) == 150, 1);
        // Assert withdraw availability updates correctly
        assert!(o_c.b_a == 70 && o_c.q_a == 150, 2);
        // Manually update available quote coins
        borrow_global_mut<OC<BCT, QCT, E0>>(addr).q_a = 140;
        inc_seq_number(addr); // Increment mock sequence number
        withdraw<BCT, QCT, E0>(user, 0, 20); // Withdraw 20 quote coins
        // Assert correct coin store balances
        assert!(c_b<BCT>(addr) == 30 && c_b<QCT>(addr) == 70, 3);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E0>>(addr);
        // Assert collateral holdings update correctly
        assert!(coin_value<BCT>(&o_c.b_c) == 70 &&
                coin_value<QCT>(&o_c.q_c) == 130, 4);
        // Assert withdraw availability updates correctly
        assert!(o_c.b_a == 70 && o_c.q_a == 120, 5);
        inc_seq_number(addr); // Increment mock sequence number
        withdraw<BCT, QCT, E0>(user, 70, 120); // Withdraw all possible
        // Assert correct coin store balances
        assert!(c_b<BCT>(addr) == 100 && c_b<QCT>(addr) == 190, 6);
        // Borrow immutable reference to user's order collateral
        let o_c = borrow_global<OC<BCT, QCT, E0>>(addr);
        // Assert collateral holdings update correctly
        assert!(coin_value<BCT>(&o_c.b_c) == 0 &&
                coin_value<QCT>(&o_c.q_c) == 10, 7);
        // Assert withdraw availability updates correctly
        assert!(o_c.b_a == 0 && o_c.q_a == 0, 8);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}