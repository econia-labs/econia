/// User account and order functionality
module Ultima::User {
    use Std::Signer;
    use Std::Vector;
    // Identifier Coin::<member> sometimes used for disambiguation:
    // for instance, Coin::deposit_coins versus User::deposit_coins.
    // Additionally, if a member is only used in test code, coverage
    // reporting will raise warnings about unused aliases. Hence
    // test-only calls to members of Coin may have the redundant
    // Coin::<member> specifier even there is no name collision with a
    // member of User
    use Ultima::Coin;
    use Ultima::Coin::{
        APT,
        burn,
        Coin,
        get_empty_coin,
        merge_coin_to_target,
        merge_coins,
        report_subunits,
        split_coin,
        split_coin_from_target,
        USD,
        yield_coin
    };

    // Error codes
    const E_ALREADY_HAS_COLLATERAL: u64 = 0;
    const E_COLLATERAL_NOT_EMPTY: u64 = 1;
    const E_ALREADY_HAS_ORDERS: u64 = 2;
    const E_ORDERS_NOT_EMPTY: u64 = 3;
    const E_DEPOSIT_FAILURE: u64 = 4;
    const E_INSUFFICIENT_COLLATERAL: u64 = 5;
    const E_RECORD_ORDER_INVALID: u64 = 6;
    const E_INVALID_RECORDER: u64 = 7;
    const E_NO_ORDERS: u64 = 8;
    const E_MATCH_ERROR: u64 = 9;
    const E_INVALID_TRIGGER: u64 = 10;

    // Order side definitions
    const BUY: bool = true;
    const SELL: bool = false;

    /// Collateral cointainer
    struct Collateral<phantom CoinType> has key {
        holdings: Coin<CoinType>,
        available: u64 // Subunits available to withdraw
    }

    /// A single limit order, always USD-denominated APT (APT/USDC).
    /// Colloquially, "one APT costs $120"
    struct Order has store {
        id: u64, // From order book counter
        side: bool, // true for buy APT, false for sell APT
        // Limit price, in USD subunits, for one subunit of APT
        price: u64,
        unfilled: u64, // Amount remaining to match, in APT subunits
    }

    /// Resource container for open limit orders
    struct Orders has key {
        // Appended as they are made, and removed once filled
        open: vector<Order>
    }

    /// Get holdings and available amount for given coin type
    public fun collateral_balances<CoinType>(
        addr: address
    ): (
        u64, // Holdings in subunits
        u64 // Available to withdraw
    ) acquires Collateral {
        (
            report_subunits<CoinType>(
                &borrow_global<Collateral<CoinType>>(addr).holdings
            ),
            borrow_global<Collateral<CoinType>>(addr).available
        )
    }

    /// Deposit given coin to collateral container
    fun deposit<CoinType>(
        addr: address,
        coin: Coin<CoinType>
    ) acquires Collateral {
        let target =
            &mut borrow_global_mut<Collateral<CoinType>>(addr).holdings;
        let (added, _, _) = merge_coin_to_target(coin, target);
        let available_ref =
            &mut borrow_global_mut<Collateral<CoinType>>(addr).available;
        *available_ref = *available_ref + added;
    }

    /// Deposit specified amounts to corresponding collateral
    /// containers, withdrawing from Coin::Balance
    public(script) fun deposit_coins(
        account: &signer,
        apt_subunits: u64,
        usd_subunits: u64
    ) acquires Collateral {
        let (apt, usd) =
            Coin::withdraw_coins(account, apt_subunits, usd_subunits);
        let addr = Signer::address_of(account);
        deposit<APT>(addr, apt);
        deposit<USD>(addr, usd);
    }

    /// Match order for given address and order id. Should pass only APT
    /// or USD depending on the order side. If passed APT returns USD,
    /// and if passed USD returns APT
    fun match_order(
        addr: address,
        id: u64,
        apt: Coin<APT>, // Can have 0 subunits
        usd: Coin<USD> // Can have 0 subunits
    ): (
        Coin<APT>, // Can have 0 subunits
        Coin<USD> // Can have 0 subunits
    ) acquires Collateral, Orders {
        let open_orders = &mut borrow_global_mut<Orders>(addr).open;
        // Since Vector::borrow_mut<Order> will abort for invalid
        // indices, skip checks on length of vector/loop count
        // Similarly ignore integer underflow range checks
        let i = 0;
        loop {
            let order = Vector::borrow_mut<Order>(open_orders, i);
            if (order.id == id) { // Found the order to match
                // Empty placeholders to return later
                let apt_final = get_empty_coin<APT>();
                let usd_final = get_empty_coin<USD>();
                if (order.side == BUY) {
                    // Calculate amounts to disperse to user and book
                    let apt_for_user = report_subunits<APT>(&apt);
                    let usd_for_book = order.price * apt_for_user;
                    // Update order fill amount
                    order.unfilled = order.unfilled - apt_for_user;
                    // Split inbound APT, deposit to user
                    let (apt_to_deposit, apt_to_return) =
                        split_coin<APT>(apt, apt_for_user);
                    deposit<APT>(addr, apt_to_deposit);
                    // Withdraw USD from user collateral for book
                    let withdrawn_usd = withdraw<USD>(addr, usd_for_book);
                    let usd_to_return = merge_coins(usd, withdrawn_usd);
                    // Merge final APT and USD into placeholders
                    merge_coin_to_target(apt_to_return, &mut apt_final);
                    merge_coin_to_target(usd_to_return, &mut usd_final);
                } else { // If a SELL
                    // Calculate amounts to disperse to user and book
                    let usd_for_user = report_subunits<USD>(&usd);
                    let apt_for_book = usd_for_user / order.price;
                    // Update order fill amount
                    order.unfilled = order.unfilled - apt_for_book;
                    // Split inbound USD, deposit to user
                    let (usd_to_deposit, usd_to_return) =
                        split_coin<USD>(usd, usd_for_user);
                    deposit<USD>(addr, usd_to_deposit);
                    // Withdraw APT from user collateral for book
                    let withdrawn_apt = withdraw<APT>(addr, apt_for_book);
                    let apt_to_return = merge_coins(apt, withdrawn_apt);
                    // Merge final APT and USD into placeholders
                    merge_coin_to_target(apt_to_return, &mut apt_final);
                    merge_coin_to_target(usd_to_return, &mut usd_final);
                };
                // If order fully matched, remove from orders resource
                if (order.unfilled == 0) {
                    let Order{id: _, side: _, price: _, unfilled: _} =
                        Vector::remove<Order>(open_orders, i);
                };
                return(apt_final, usd_final)
            };
            i = i + 1;
        }
    }

    /// Return number of open orders for given address
    public fun num_orders(
        addr: address
    ): u64
     acquires Orders {
        let open = & borrow_global<Orders>(addr).open;
        Vector::length<Order>(open)
    }

    /// Initialize user collateral containers and open orders resource
    public(script) fun init_account(
        account: &signer,
    ) {
        publish_collateral<APT>(account);
        publish_collateral<USD>(account);
        publish_orders(account);
    }

    /// Publish empty collateral container for given CoinType at account
    fun publish_collateral<CoinType>(
        account: &signer
    ) {
        let addr = Signer::address_of(account);
        assert!(!exists<Collateral<CoinType>>(addr), E_ALREADY_HAS_COLLATERAL);
        let empty = get_empty_coin<CoinType>();
        move_to(account, Collateral<CoinType>{holdings: empty, available: 0});
    }

    /// Publish empty open orders resource at account
    fun publish_orders(
        account: &signer
    ) {
        let addr = Signer::address_of(account);
        assert!(!exists<Orders>(addr), E_ALREADY_HAS_ORDERS);
        move_to(account, Orders{open: Vector::empty<Order>()});
    }

    /// Append an order to a user's open orders resource
    fun record_order(
        addr: address,
        order: Order
    ) acquires Orders {
        let open = &mut borrow_global_mut<Orders>(addr).open;
        Vector::push_back<Order>(open, order);
    }

    /// Record a mock order to a user's open orders resource. Designed
    /// for testing, can only be called by Ultima account
    public(script) fun record_mock_order(
        account: &signer,
        addr: address,
        id: u64,
        side: bool,
        price: u64,
        unfilled: u64,
    ) acquires Orders {
        assert!(Signer::address_of(account) == @Ultima, E_INVALID_RECORDER);
        record_order(addr, Order{id, side, price, unfilled});
    }

    /// Directly match an order against a user's open orders. Designed
    /// for testing, can only be called by Ultima account
    public(script) fun trigger_match_order(
        account: &signer,
        addr: address,
        id: u64,
        apt_subunits: u64,
        usd_subunits: u64,
    ) acquires Collateral, Orders {
        assert!(Signer::address_of(account) == @Ultima, E_INVALID_TRIGGER);
        let apt_yielded = yield_coin<APT>(account, apt_subunits);
        let usd_yielded = yield_coin<USD>(account, usd_subunits);
        let (apt_match, usd_match) =
            match_order(addr, id, apt_yielded, usd_yielded);
        burn<APT>(account, apt_match);
        burn<USD>(account, usd_match);
    }

    /// Withdraw requested amount from collateral container at address
    fun withdraw<CoinType>(
        addr: address,
        amount: u64 // Number of subunits to withdraw
    ): Coin<CoinType>
    acquires Collateral {
        // Verify amount available, decrement marker accordingly
        let available_ref =
            &mut borrow_global_mut<Collateral<CoinType>>(addr).available;
        let available = *available_ref;
        assert!(amount <= available, E_INSUFFICIENT_COLLATERAL);
        *available_ref = *available_ref - amount;

        // Split off return coin from holdings
        let target =
            &mut borrow_global_mut<Collateral<CoinType>>(addr).holdings;
        let (result, _, _) =
            split_coin_from_target<CoinType>(amount, target);
        result
    }

    /// Withdraw specified amounts from collateral into Coin::Balance
    public(script) fun withdraw_coins(
        account: &signer,
        apt_subunits: u64,
        usd_subunits: u64
    ) acquires Collateral {
        let addr = Signer::address_of(account);
        let apt = withdraw<APT>(addr, apt_subunits);
        let usd = withdraw<USD>(addr, usd_subunits);
        Coin::deposit_coins(addr, apt, usd);
    }

    // Verify successful deposits to user account
    #[test(
        user = @TestUser,
        ultima = @Ultima
    )]
    public(script) fun deposit_coins_success(
        user: signer,
        ultima: signer
    ) acquires Collateral {
        // Airdrop coins
        let addr = Signer::address_of(&user);
        Coin::publish_balances(&user);
        Coin::airdrop(&ultima, addr, 10, 1000);

        // Move into collateral containers
        init_account(&user);
        deposit_coins(&user, 2, 300);

        // Verify holdings
        let (apt_holdings, apt_available) = collateral_balances<APT>(addr);
        assert!(apt_holdings == 2, E_DEPOSIT_FAILURE);
        assert!(apt_available == 2, E_DEPOSIT_FAILURE);
        let (usd_holdings, usd_available) = collateral_balances<USD>(addr);
        assert!(usd_holdings == 300, E_DEPOSIT_FAILURE);
        assert!(usd_available == 300, E_DEPOSIT_FAILURE);
    }

    // Verify limit orders matched correctly
    #[test(
        user = @TestUser,
        ultima = @Ultima
    )]
    public(script) fun match_order_success(
        user: signer,
        ultima: signer,
    ) acquires Collateral, Orders {
        // Init and fund account
        let addr = Signer::address_of(&user);
        init_account(&user);
        deposit<APT>(addr, yield_coin<APT>(&ultima, 1000));
        deposit<USD>(addr, yield_coin<USD>(&ultima, 2000));
        // Record orders
        record_order(addr, Order{
            id: 1,
            side: BUY,
            price: 15,
            unfilled: 8,
        });
        record_order(addr, Order{
            id: 2,
            side: SELL,
            price: 20,
            unfilled: 9,
        });
        // Partially match the buy order
        let (apt1, usd1) = match_order(
            addr,
            1,
            yield_coin<APT>(&ultima, 3),
            get_empty_coin<USD>()
        );
        // Verify results
        assert!(report_subunits(&apt1) == 0, E_MATCH_ERROR);
        assert!(report_subunits(&usd1) == 45, E_MATCH_ERROR);
        let open_orders = &borrow_global<Orders>(addr).open;
        let order1 = Vector::borrow<Order>(open_orders, 0);
        assert!(order1.unfilled == 5, E_MATCH_ERROR);
        let (apt_holdings, apt_available) = collateral_balances<APT>(addr);
        assert!(apt_holdings == 1000 + 3, E_MATCH_ERROR);
        assert!(apt_available == 1000 + 3, E_MATCH_ERROR);
        let (usd_holdings, usd_available) = collateral_balances<USD>(addr);
        assert!(usd_holdings == 2000 - 45, E_MATCH_ERROR);
        assert!(usd_available == 2000 - 45, E_MATCH_ERROR);

        // Fully match the sell order
        let (apt2, usd2) = match_order(
            addr,
            2,
            get_empty_coin<APT>(),
            yield_coin<USD>(&ultima, 180)
        );
        // Verify results
        assert!(report_subunits(&apt2) == 9, E_MATCH_ERROR);
        assert!(report_subunits(&usd2) == 0, E_MATCH_ERROR);
        let open_os = &borrow_global<Orders>(addr).open;
        assert!(Vector::length<Order>(open_os) == 1, E_MATCH_ERROR);
        let (apt_h, apt_a) = collateral_balances<APT>(addr);
        assert!(apt_h == 1000 + 3 - 9, E_MATCH_ERROR);
        assert!(apt_a == 1000 + 3 - 9, E_MATCH_ERROR);
        let (usd_h, usd_a) = collateral_balances<USD>(addr);
        assert!(usd_h == 2000 - 45 + 180, E_MATCH_ERROR);
        assert!(usd_a == 2000 - 45 + 180, E_MATCH_ERROR);

        // Burn unconsumed resources
        burn<APT>(&ultima, apt1);
        burn<APT>(&ultima, apt2);
        burn<USD>(&ultima, usd1);
        burn<USD>(&ultima, usd2);
    }

    // Verify collateral container initialized empty
    #[test(account = @TestUser)]
    fun publish_collateral_success(
        account: signer
    ) acquires Collateral {
        publish_collateral<APT>(&account);
        let addr = Signer::address_of(&account);
        let (holdings, available) = collateral_balances<APT>(addr);
        assert!(holdings == 0, E_COLLATERAL_NOT_EMPTY);
        assert!(available == 0, E_COLLATERAL_NOT_EMPTY);
    }

    // Verify cannot publish collateral cointainer twice
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    fun publish_collateral_twice(
        account: signer
    ) {
        publish_collateral<APT>(&account);
        publish_collateral<APT>(&account);
    }

    // Verify orders container initialized empty
    #[test(account = @TestUser)]
    fun publish_orders_success(
        account: signer
    ) acquires Orders {
        publish_orders(&account);
        let addr = Signer::address_of(&account);
        assert!(num_orders(addr) == 0, E_ORDERS_NOT_EMPTY);
    }

    // Verify cannot publish orders cointainer twice
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 2)]
    fun publish_orders_twice(
        account: signer
    ) {
        publish_orders(&account);
        publish_orders(&account);
    }

    // Verify mock order cannot be placed unless by Ultima account
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 7)]
    public(script) fun record_mock_order_failure(
        account: signer
    ) acquires Orders {
        record_mock_order(
            &account,
            Signer::address_of(&account),
            1,
            false,
            2,
            3,
        );
    }

    // Verify history updated when mock order placed
    #[test(account = @Ultima)]
    public(script) fun record_mock_order_success(
        account: signer
    ) acquires Orders {
        // Initialize account
        let addr = Signer::address_of(&account);
        publish_orders(&account);
        record_mock_order(
            &account,
            Signer::address_of(&account),
            1,
            false,
            2,
            3,
        );
        // Verify proper open orders vector length
        let open = &borrow_global<Orders>(addr).open;
        assert!(Vector::length(open) == 1, E_RECORD_ORDER_INVALID);
    }

    // Verify order data recorded to open orders vector in proper order
    // Does not perform data value validity checks
    #[test(account = @TestUser)]
    fun record_order_success(
        account: signer
    ) acquires Orders {
        // Init account
        let addr = Signer::address_of(&account);
        publish_orders(&account);
        // Record orders
        record_order(addr, Order{
            id: 1,
            side: true,
            price: 2,
            unfilled: 3,
        });
        record_order(addr, Order{
            id: 10,
            side: false,
            price: 20,
            unfilled: 30,
        });

        // Verify proper open orders vector length
        let open = &borrow_global<Orders>(addr).open;
        assert!(Vector::length(open) == 2, E_RECORD_ORDER_INVALID);

        // Verify contents of first order
        let first_order = Vector::borrow(open, 0);
        assert!(first_order.id == 1, E_RECORD_ORDER_INVALID);
        assert!(first_order.side == true, E_RECORD_ORDER_INVALID);
        assert!(first_order.price == 2, E_RECORD_ORDER_INVALID);
        assert!(first_order.unfilled == 3, E_RECORD_ORDER_INVALID);

        // Verify contents of second order
        let second_order = Vector::borrow(open, 1);
        assert!(second_order.id == 10, E_RECORD_ORDER_INVALID);
        assert!(second_order.side == false, E_RECORD_ORDER_INVALID);
        assert!(second_order.price == 20, E_RECORD_ORDER_INVALID);
        assert!(second_order.unfilled == 30, E_RECORD_ORDER_INVALID);
    }

    // Verify matching cannot be directly triggered unless by Ultima
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 10)]
    public(script) fun trigger_match_order_failure(
        account: signer
    ) acquires Collateral, Orders {
        trigger_match_order(&account, Signer::address_of(&account), 1, 1, 1);
    }

    // Verify order matching invocation when triggered by Ultima
    #[test(account = @Ultima)]
    public(script) fun trigger_match_order_invocation(
        account: signer
    ) acquires Collateral, Orders {
        // Perform minimum initialization so matching does not abort
        // Init and fund account
        let addr = Signer::address_of(&account);
        init_account(&account);
        deposit<APT>(addr, yield_coin<APT>(&account, 1));
        // Record orders
        record_order(addr, Order{
            id: 1,
            side: SELL,
            price: 1,
            unfilled: 1,
        });
        trigger_match_order(&account, addr, 1, 0, 1);
    }

    // Verify unable to withdraw more than available balance
    #[test(
        user = @TestUser,
        ultima = @Ultima
    )]
    #[expected_failure(abort_code = 5)]
    public(script) fun withdraw_failure(
        user: signer,
        ultima: signer
    ): Coin<APT> // Return since unable to destruct
     acquires Collateral {
        // Airdrop coins
        let addr = Signer::address_of(&user);
        Coin::publish_balances(&user);
        Coin::airdrop(&ultima, addr, 10, 0);

        // Move into collateral containers
        init_account(&user);
        deposit_coins(&user, 10, 0);

        // Attempt to withdraw too much
        withdraw<APT>(addr, 11)
    }

    // Verify successful withdraw of coins from collateral
    #[test(
        user = @TestUser,
        ultima = @Ultima
    )]
    public(script) fun withdraw_coins_success(
        user: signer,
        ultima: signer
    ) acquires Collateral {
        // Airdrop coins
        let addr = Signer::address_of(&user);
        Coin::publish_balances(&user);
        Coin::airdrop(&ultima, addr, 10, 1000);

        // Move into collateral containers
        init_account(&user);
        deposit_coins(&user, 10, 1000);

        // Withdraw from collateral
        withdraw_coins(&user, 2, 300);

        // Verify collateral balances
        let (apt_holdings, apt_available) = collateral_balances<APT>(addr);
        assert!(apt_holdings == 8, E_DEPOSIT_FAILURE);
        assert!(apt_available == 8, E_DEPOSIT_FAILURE);
        let (usd_holdings, usd_available) = collateral_balances<USD>(addr);
        assert!(usd_holdings == 700, E_DEPOSIT_FAILURE);
        assert!(usd_available == 700, E_DEPOSIT_FAILURE);
    }
}