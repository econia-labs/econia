// Order submission/history functionality
module Ultima::Order {
    //use AptosFramework::Table;
    //use AptosFramework::Timestamp;
    use Std::Signer;
    //use Std::Vector;
    use Ultima::Coin::{
        APT,
        Coin,
        get_empty_coin,
        report_subunits,
        USD
    };

    // Error codes
    const E_ALREADY_HAS_ACCOUNT: u64 = 0;
    const E_NONZERO_INITIAL_BALANCE: u64 = 1;

    // Order side definitions
    const BUY: bool = true;
    const SELL: bool = false;

    // Order liquidity provision definitions
    const MAKER: bool = true;
    const TAKER: bool = false;

    // Coin definition
    const APT_BOOL: bool = true;
    const USD_BOOL: bool = false;

    // Represents a taker (market) fill against a maker (limit) order
    struct Fill has store {
        time: u64, // Time in microseconds of fill
        amount: u64, // Amount filled (in APT subunits)
        price: u64, // Price of fill (in USD subunits)
    }

    // Represents a single order, always USD-denominated APT (APT/USDC)
    // Colloquially, "one APT costs $120"
    struct Order has store {
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
        orders have a lower index. If `liq` is `true` (if maker AKA
        limit order), then `fills` will represent fills made against
        this order. If `liq` is `false`, (if taker AKA market order),
        then `fills` will represent fills that this order made against
        the book.
        */
        fills: vector<Fill>
    }

    // Resource container for user coins and trade history
    struct Account has key {
        apt_holdings: Coin<APT>,
        usd_holdings: Coin<USD>,
        // Amount of coin holdings subunits not locked as collateral
        // on outstanding orders
        apt_available: u64,
        usd_available: u64,
        // Key is order id from orderbook counter, value is order
        orders: u64 //Table::Table<u64, Order>
    }

    // Publish an empty account container at given account
    public(script) fun publish_account(
        account: &signer,
    ) {
        assert!(
            !exists<Account>(Signer::address_of(account)),
            E_ALREADY_HAS_ACCOUNT
        );
        move_to(account, Account{
            apt_holdings: get_empty_coin<APT>(),
            usd_holdings: get_empty_coin<USD>(),
            apt_available: 0,
            usd_available: 0,
            orders: 0 //Table::create<u64, Order>()
        })
    }

    // Get account balance information for given address
    public fun account_balance(
        addr: address
    ): (
        u64, // APT holdings
        u64, // USD holdings
        u64, // APT available
        u64 // USD available
    ) acquires Account {
        (
            report_subunits<APT>(&borrow_global<Account>(addr).apt_holdings),
            report_subunits<USD>(&borrow_global<Account>(addr).usd_holdings),
            borrow_global<Account>(addr).apt_available,
            borrow_global<Account>(addr).usd_available,
        )
    }

    // Verify successful initialization of account
    #[test(account = @TestUser)]
    public(script) fun publish_account_success(
        account: signer
    ) acquires Account {
        publish_account(&account);
        let (apt_holdings, usd_holdings, apt_available, usd_available) =
            account_balance(Signer::address_of(&account));
        assert!(apt_holdings == 0, E_NONZERO_INITIAL_BALANCE);
        assert!(usd_holdings == 0, E_NONZERO_INITIAL_BALANCE);
        assert!(apt_available == 0, E_NONZERO_INITIAL_BALANCE);
        assert!(usd_available == 0, E_NONZERO_INITIAL_BALANCE);
    }

    // Verify account can not be published twice
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    public(script) fun publish_account_twice(
        account: signer
    ) {
        publish_account(&account);
        publish_account(&account);
    }
}