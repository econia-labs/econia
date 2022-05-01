// User ordering and history functionality
module Ultima::User {
    use Std::Signer;
    use Std::Vector;
    use Ultima::Coin;
    use Ultima::Coin::{
        APT,
        Coin,
        report_subunits,
        USD
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

    // Order side definitions
    const BUY: bool = true;
    const SELL: bool = false;

    // Order liquidity provision definitions
    const MAKER: bool = true;
    const TAKER: bool = false;

    // Coin definition for order field
    const APT_BOOL: bool = true;
    const USD_BOOL: bool = false;

    // Collateral cointainer
    struct Collateral<phantom CoinType> has key {
        holdings: Coin<CoinType>,
        available: u64 // Subunits available to withdraw
    }

    // Represents a taker (market) fill against a maker (limit) order
    struct Fill has store {
        time: u64, // Time in microseconds of fill
        amount: u64, // Amount filled (in APT subunits)
        price: u64, // Price of fill (in USD subunits)
    }

    // Represents a single order, always USD-denominated APT (APT/USDC)
    // Colloquially, "one APT costs $120"
    struct Order has store {
        id: u64, // From order book counter
        time: u64, // Time in microseconds of order placement
        liq: bool, // true for maker, false for taker
        side: bool, // true for buy APT, false for sell APT
        price: u64, // In USD subunits, if maker order
        amount: u64, // Number of APT subunits when placed
        filled: u64, // Number of APT subunits already filled
        open: bool, // true if still open, false if closed
        cancelled: bool, // true if was cancelled
        cancel_time: u64, // Time in microseconds of cancellation
        /*
        Fills are appended to the vector as they are made, hence earlier
        fills have a lower index. If `liq` is `true` (if maker AKA
        limit order), then `fills` will represent fills made against
        this order. If `liq` is `false`, (if taker AKA market order),
        then `fills` will represent fills that this order made against
        the book.
        */
        fills: vector<Fill>
    }

    // Resource container for user order history
    struct Orders has key {
        // Appended as they are made, hence earlier orders have lower
        // indices
        history: vector<Order>
    }

    // Get holdings and available amount for given coin type
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

    // Deposit given coin to collateral container
    fun deposit<CoinType>(
        addr: address,
        coin: Coin<CoinType>
    ) acquires Collateral {
        let target =
            &mut borrow_global_mut<Collateral<CoinType>>(addr).holdings;
        let (added, _, _) = Coin::merge_coin_to_target(coin, target);
        let available_ref =
            &mut borrow_global_mut<Collateral<CoinType>>(addr).available;
        *available_ref = *available_ref + added;
    }

    // Deposit specified amounts to corresponding collateral containers
    // Withdraws from Coin::Balance
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

    // Return number of orders for given address
    public fun num_orders(
        addr: address
    ): u64
     acquires Orders {
        let history = & borrow_global<Orders>(addr).history;
        Vector::length<Order>(history)
    }

    // Initialize user collateral containers and order history
    public(script) fun init_account(
        account: &signer,
    ) {
        publish_collateral<APT>(account);
        publish_collateral<USD>(account);
        publish_orders(account);
    }

    // Publish empty collateral container for given coin type at account
    fun publish_collateral<CoinType>(
        account: &signer
    ) {
        let addr = Signer::address_of(account);
        assert!(!exists<Collateral<CoinType>>(addr), E_ALREADY_HAS_COLLATERAL);
        let empty = Coin::get_empty_coin<CoinType>();
        move_to(account, Collateral<CoinType>{holdings: empty, available: 0});
    }

    // Publish empty order history at account
    fun publish_orders(
        account: &signer
    ) {
        let addr = Signer::address_of(account);
        assert!(!exists<Orders>(addr), E_ALREADY_HAS_ORDERS);
        move_to(account, Orders{history: Vector::empty<Order>()});
    }

    // Append an order to a user's order history
    // Does not do perform data validity checks
    fun record_order(
        addr: address,
        order: Order
    ) acquires Orders {
        let history = &mut borrow_global_mut<Orders>(addr).history;
        Vector::push_back<Order>(history, order);
    }

    // Record a mock order to a user's order history
    // Useful for testing, can only be called by Ultima account
    public(script) fun record_mock_order(
        account: &signer,
        addr: address,
        id: u64,
        time: u64,
        liq: bool,
        side: bool,
        price: u64,
        amount: u64,
        filled: u64,
        open: bool,
        cancelled: bool,
        cancel_time: u64,
    ) acquires Orders {
        assert!(Signer::address_of(account) == @Ultima, E_INVALID_RECORDER);
        record_order(addr, Order{
            id,
            time, // Have this be a timestamp
            liq,
            side,
            price,
            amount,
            filled,
            open,
            cancelled,
            cancel_time,
            fills: Vector::empty<Fill>()
        });
    }

    // Withdraw requested amount from collateral container at address
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
            Coin::split_coin_from_target<CoinType>(amount, target);
        result
    }

    // Withdraw specified amounts from collateral containers into
    // Coin::Balance
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
            2,
            false,
            false,
            3,
            4,
            5,
            false,
            false,
            6
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
            addr,
            1,
            2,
            false,
            false,
            3,
            4,
            5,
            false,
            false,
            6
        );
        // Verify proper history length
        let history = &borrow_global<Orders>(addr).history;
        assert!(Vector::length(history) == 1, E_RECORD_ORDER_INVALID);
    }

    // Verify order data recorded to history in proper order
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
            time: 2,
            liq: false,
            side: true,
            price: 3,
            amount: 4,
            filled: 5,
            open: true,
            cancelled: false,
            cancel_time: 6,
            fills: Vector::empty<Fill>()
        });
        record_order(addr, Order{
            id: 10,
            time: 20,
            liq: true,
            side: false,
            price: 30,
            amount: 40,
            filled: 50,
            open: false,
            cancelled: true,
            cancel_time: 60,
            fills: Vector::empty<Fill>()
        });

        // Verify proper history length
        let history = &borrow_global<Orders>(addr).history;
        assert!(Vector::length(history) == 2, E_RECORD_ORDER_INVALID);

        // Verify contents of first order
        let first_order = Vector::borrow(history, 0);
        assert!(first_order.id == 1, E_RECORD_ORDER_INVALID);
        assert!(first_order.id == 1, E_RECORD_ORDER_INVALID);
        assert!(first_order.time == 2, E_RECORD_ORDER_INVALID);
        assert!(first_order.liq == false, E_RECORD_ORDER_INVALID);
        assert!(first_order.side == true, E_RECORD_ORDER_INVALID);
        assert!(first_order.price == 3, E_RECORD_ORDER_INVALID);
        assert!(first_order.amount == 4, E_RECORD_ORDER_INVALID);
        assert!(first_order.filled == 5, E_RECORD_ORDER_INVALID);
        assert!(first_order.open == true, E_RECORD_ORDER_INVALID);
        assert!(first_order.cancelled == false, E_RECORD_ORDER_INVALID);
        assert!(first_order.cancel_time == 6, E_RECORD_ORDER_INVALID);
        assert!(
            Vector::is_empty<Fill>(&first_order.fills),
            E_RECORD_ORDER_INVALID
        );

        // Verify contents of second order
        let second_order = Vector::borrow(history, 1);
        assert!(second_order.id == 10, E_RECORD_ORDER_INVALID);
        assert!(second_order.time == 20, E_RECORD_ORDER_INVALID);
        assert!(second_order.liq == true, E_RECORD_ORDER_INVALID);
        assert!(second_order.side == false, E_RECORD_ORDER_INVALID);
        assert!(second_order.price == 30, E_RECORD_ORDER_INVALID);
        assert!(second_order.amount == 40, E_RECORD_ORDER_INVALID);
        assert!(second_order.filled == 50, E_RECORD_ORDER_INVALID);
        assert!(second_order.open == false, E_RECORD_ORDER_INVALID);
        assert!(second_order.cancelled == true, E_RECORD_ORDER_INVALID);
        assert!(second_order.cancel_time == 60, E_RECORD_ORDER_INVALID);
        assert!(
            Vector::is_empty<Fill>(&second_order.fills),
            E_RECORD_ORDER_INVALID
        );
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