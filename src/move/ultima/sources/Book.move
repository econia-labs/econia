// Order book functionality
module Ultima::Book {

    use Std::Signer;
    use Std::Vector;

    // Error codes
    const E_INVALID_PUBLISH: u64 = 0;
    const E_INVALID_BOOK_INIT: u64 = 1;

    // Order side definitions
    const BID: bool = true;
    const ASK: bool = false;

    // Represents a single unfilled ask or bid at a given price
    struct Order has store {
        id: u64, // From counter
        user: address, // Address of user who placed the order
        unfilled: u64 // Amount remaining to match, in APT subunits
    }

    // Represents a single price level for either asks or bids
    // Implemented as a binary search tree node
    struct Price has store {
        // Limit price, in USD subunits, for one subunit of APT
        price: u64,
        // Orders appended as they are placed, and removed once filled
        orders: vector<Order> // Unfilled orders having this price
    }

    // Order book container
    struct Book has key {
        counter: u64, // Incrementing counter that tracks order id
        // Lowest price at start of vector, highest price at end
        bids: vector<Price>,
        // Lowest price at start of vector, highest price at end
        asks: vector<Price>
    }

    // Publish an order book at the Ultima account
    public(script) fun publish_book(
        account: &signer
    ) {
        assert!(Signer::address_of(account) == @Ultima, E_INVALID_PUBLISH);
        move_to(account, Book{
            counter: 0,
            bids: Vector::empty<Price>(),
            asks: Vector::empty<Price>()
        });
    }

    /*
    // Record an order in either bids or asks
    fun record_order(
        user: address, // User who placed order
        side: bool, // true for buy, false for sell
        price: u64, // Limit price, in USD subunits per APT subunit
        subunits: u64 // APT subunits to match
    ): u64 // The corresponding order ID number
    acquires Book {
        // Get counter id then increment
        let book = borrow_global_mut<Book>(@Ultima);
        let id = book.counter;
        let order = Order{id, user, unfilled: subunits};
        book.counter = book.counter + 1;
        // Get vector corresponding to proper side
        if (side == BID) {
            s = book.bids
        } else {
            s = book.asks
        }
        // Loop over price levels within the side
        let i = 0;
        let lower = 0;
        let n = Vector::length<Price>(s);
        // If lower <
        while(i < n)) {
            p = Vector::borrow_mut<Price>(s, i);

            if`

            lower =

            i = i + 1
        }
        // No match, so append to the end of the vector

        id
    }
    */

    // Verify empty order book published
    #[test(account = @Ultima)]
    public(script) fun publish_book_success(
        account: signer
    ) acquires Book {
        let addr = Signer::address_of(&account);
        publish_book(&account);
        let book = borrow_global<Book>(addr);
        assert!(book.counter == 0, E_INVALID_BOOK_INIT);
        assert!(Vector::is_empty<Price>(&book.bids), E_INVALID_BOOK_INIT);
        assert!(Vector::is_empty<Price>(&book.asks), E_INVALID_BOOK_INIT);
    }

    // Verify only Ultima can publish book
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    public(script) fun publish_book_failure(
        account: signer
    ) {
        publish_book(&account);
    }
}