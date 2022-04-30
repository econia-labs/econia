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

    /*
    // Withdraw given coin type from collateral container
    fun withdraw<CoinType> (
        addr: address,
        amount: u64 // Number of subunits to withdraw
    ) acquires Collateral {
    */

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
        Coin::publish_balances(&user);
        Coin::airdrop(&ultima, Signer::address_of(&user), 10, 1000);

        // Move into collateral containers
        init_account(&user);
        deposit_coins(&user, 2, 300);

        // Verify holdings
        let addr = Signer::address_of(&user);
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
}