/// # Bit structure
///
/// An order id is a 128-bit number, where the most-significant
/// ("first") 64 bits indicate the price of the maker order, in ticks
/// per lot, regardless of whether it is an ask or bid. The
/// least-significant ("last") 64 bits are derived from a counter for
/// the market on which the order is placed, or more specifically, from
/// the corresponding `econia::market::OrderBook.counter`. This encoded
/// counter value is unmodified in the case of an ask, but has each
/// bit flipped in the case of a bid.
///
/// ## Example ask
///
/// For a price of `255` (`0b11111111`) and a counter of `170`
/// (`0b10101010`), an ask would have an order ID with the
/// first 64 bits
/// `0000000000000000000000000000000000000000000000000000000011111111`
/// and the last 64 bits
/// `0000000000000000000000000000000000000000000000000000000010101010`,
/// corresponding to the base-10 integer `4703919738795935662250`
///
/// ## Example bid
///
/// For a price of `15` (`0b1111`) and a counter of `63` (`0b111111`),
/// a bid would have an order ID with the first 64 bits
/// `0000000000000000000000000000000000000000000000000000000000001111`
/// and the last 64 bits
/// `1111111111111111111111111111111111111111111111111111111111000000`,
/// corresponding to the base-10 integer `295147905179352825792`
///
/// # Motivations
///
/// Maker orders in an order book are represented as outer nodes in an
/// `econia::critbit::CritBitTree`, which allows for traversal across
/// nodes during the matching process.
///
/// ## Taker buy example
///
/// In the case of a taker buy, the matching engine first fills against
/// the oldest ask at the lowest price, then fills against the second
/// oldest ask at the lowest price (if there is one). The process
/// continues, prioritizing older positions, until the price level has
/// been exhausted, at which point the matching engine moves onto the
/// next-lowest price level, similarly filling against positions in
/// chronological priority.
///
/// Here, with the first 64 bits of the order ID corresponding to price
/// and the last 64 bits corresponding to a counter, asks are
/// automatically sorted, upon insertion to the tree, into price-time
/// priority: first ascending from lowest price to highest price, then
/// ascending from lowest counter to highest counter within a price
/// level. All the matching engine must do is iterate through inorder
/// successor traversals until the taker buy has been filled.
///
/// ## Taker sell example
///
/// In the case of a taker sell, the ordering of prices is reversed, but
/// the price-time priority is not: first the matching engine should
/// fill against bids at the highest price level, starting with the
/// oldest position, then fill against newer positions, before moving
/// onto the next price level. Hence, the final 64 bits of the order ID
/// are all flipped, because this allows the matching engine to simply
/// iterate through inorder predecessor traversals until the taker buy
/// has been filled.
///
/// More specifically, by flipping the final 64 bits, order IDs from
/// lower counter values are sorted above those from higher counter
/// values, within a given price level: at price of `1` (`0b1`), a maker
/// order with counter `15` (`0b1111`) has an order ID with bits
/// `11111111111111111111111111111111111111111111111111111111111110000`,
/// corresponding to the base-10 integer `36893488147419103216`, while
/// an order at the same price with counter `63` (`0b111111`) has an
/// order ID with bits
/// `11111111111111111111111111111111111111111111111111111111111000000`,
/// corresponding to the base-10 integer `36893488147419103168`. The
/// order with the counter `63` thus has an order ID of lesser value
/// than that of the order with counter `15`, and as such, during the
/// matching engine's iterated inorder predecessor traversal, the
/// order with counter `63` will be filled second.
///
/// ---
///
module econia::order_id {

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::critbit::{u, u_long};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Positions to bitshift for operating on first 64 bits
    const FIRST_64: u8 = 64;
    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return counter of an ask having `order_id`
    public fun counter_ask(
        order_id: u128
    ): u64 {
        (order_id & (HI_64 as u128) as u64)
    }

    /// Return counter of a bid having `order_id`
    public fun counter_bid(
        order_id: u128
    ): u64 {
        (order_id & (HI_64 as u128) as u64) ^ HI_64
    }

    /// Return order ID for `price` and `counter` on given `side`
    public fun order_id(
        price: u64,
        counter: u64,
        side: bool
    ): u128 {
        // Return corresponding order ID type based on side
        if (side == ASK) order_id_ask(price, counter) else
            order_id_bid(price, counter)
    }

    /// Return order ID for ask with `price` and `counter`
    public fun order_id_ask(
        price: u64,
        counter: u64
    ): u128 {
        (price as u128) << FIRST_64 | (counter as u128)
    }

    /// Return order ID for bid with `price` and `counter`
    public fun order_id_bid(
        price: u64,
        counter: u64
    ): u128 {
        (price as u128) << FIRST_64 | (counter ^ HI_64 as u128)
    }

    /// Return price of given `order_id`, (works for ask or bid)
    public fun price(order_id: u128): u64 {(order_id >> FIRST_64 as u64)}

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify expected return
    fun test_counter_ask() {
        // Define order id (60 characters on first two lines, 8 on last)
        let order_id = u_long(
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111100000000000000000000000000000000000000000000000000000000",
            b"10101010"
        );
        // Assert expected return
        assert!(counter_ask(order_id) == (u(b"10101010") as u64), 0);
    }

    #[test]
    /// Verify expected return
    fun test_counter_bid() {
        // Define order id (60 characters on first two lines, 8 on last)
        let order_id = u_long(
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111011111111111111111111111111111111111111111111111111111111",
            b"11110101"
        );
        // Assert expected return
        assert!(counter_bid(order_id) == (u(b"1010") as u64), 0);
    }

    #[test]
    /// Assert wrapped returns same as unwrapped returns
    fun test_order_id() {
        assert!(order_id(123, 456, ASK) == order_id_ask(123, 456), 0);
        assert!(order_id(234, 567, BID) == order_id_bid(234, 567), 0);
    }

    #[test]
    /// Verify expected return
    fun test_order_id_ask() {
        // Define price and counter
        let (price, counter) = ((u(b"1101") as u64), (u(b"1010") as u64));
        // Define expected return (60 characters on first two lines, 8
        // on last)
        let order_id = u_long(
            b"000000000000000000000000000000000000000000000000000000000000",
            b"110100000000000000000000000000000000000000000000000000000000",
            b"00001010"
        );
        // Assert expected return
        assert!(order_id_ask(price, counter) == order_id, 0);
    }

    #[test]
    /// Verify expected return
    fun test_order_id_bid() {
        // Define price and counter
        let (price, counter) = ((u(b"1000") as u64), (u(b"1010") as u64));
        // Define expected return (60 characters on first two lines, 8
        // on last)
        let order_id = u_long(
            b"000000000000000000000000000000000000000000000000000000000000",
            b"100011111111111111111111111111111111111111111111111111111111",
            b"11110101"
        );
        // Assert expected return
        assert!(order_id_bid(price, counter) == order_id, 0);
    }

    #[test]
    /// Verify expected return
    fun test_price() {
        // Define order id (60 characters on first two lines, 8 on last)
        let order_id = u_long(
            b"000000000000000000000000000000000000000000000000000000001010",
            b"101011111111111111111111111111111111111111111111111111111111",
            b"11111111"
        );
        // Assert expected return
        assert!(price(order_id) == (u(b"10101010") as u64), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}