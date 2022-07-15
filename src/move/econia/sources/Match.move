/// Matching engine functionality, integrating user-side and book-side
/// modules
module Econia::Match {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Econia::Book::{
        cancel_position,
        FriendCap as BookCap,
        init_traverse_fill,
        n_asks,
        n_bids,
        scale_factor,
        refresh_extreme_order_id,
        traverse_pop_fill
    };

    use Econia::User::{
        process_fill
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ask flag
    const ASK: bool = true;
    /// Bid flag
    const BID: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Fill a market order against the book as much as possible,
    /// returning when there is no liquidity left or when order is
    /// completely filled
    ///
    /// # Parameters
    /// * `host` Host of corresponding order book
    /// * `addr`: Address of user placing market order
    /// * `side`: `ASK` or `BID`, denoting the side on the order book
    ///   which should be filled against. If `ASK`, user is submitting
    ///   a market buy, if `BID`, user is submitting a market sell
    /// * `size`: Base coin parcels to be filled
    /// * `book_cap`: Immutable reference to `Econia::Book:FriendCap`
    ///
    /// # Terminology
    /// * "Incoming order" is the market order being matched against
    ///   the order book
    /// * "Target position" is the position on the book for each stage
    ///   of iterated traversal
    ///
    /// # Returns
    /// * `u64`: Amount of base coin parcels left unfilled
    ///
    /// # Assumptions
    /// * Order book has been properly initialized at host address
    public fun fill_market_order<B, Q, E>(
        host: address,
        addr: address,
        side: bool,
        size: u64,
        book_cap: &BookCap
    ): u64 {
        // Get number of positions on corresponding order book side
        let n_positions = if (side == ASK) n_asks<B, Q, E>(host, book_cap)
            else n_bids<B, Q, E>(host, book_cap);
        // Get scale factor of corresponding order book
        let scale_factor = scale_factor<B, Q, E>(host, book_cap);
        // Return full order size if no positions on book
        if (n_positions == 0) return size;
        // Initialize traversal, storing ID of target position, address
        // of user holding it, the parent field of corresponding tree
        // node, child index of corresponding node, amount filled, and
        // if an exact match between incoming order and target position
        let (target_id, target_addr, target_p_f, target_c_i, filled, exact) =
            init_traverse_fill<B, Q, E>(host, addr, side, size, book_cap);
        loop { // Begin traversal loop
            // Route funds between conterparties, update open orders
            process_fill<B, Q, E>(target_addr, addr, side, target_id, filled,
                                  scale_factor, exact);
            size = size - filled; // Decrement size left to match
            // If incoming order unfilled and can traverse
            if (size > 0 && n_positions > 1) {
                // Traverse pop fill to next position
                (target_id, target_addr, target_p_f, target_c_i, filled, exact)
                    = traverse_pop_fill<B, Q, E>(
                        host, addr, side, size, n_positions, target_id,
                        target_p_f, target_c_i, book_cap);
                // Decrement count of positions on book for given side
                n_positions = n_positions - 1;
            } else { // If should not continute iterated traverse fill
                // Determine if a partial target fill was made
                let partial_target_fill = (size == 0 && !exact);
                // If anything other than a partial target fill made
                if (!partial_target_fill) {
                    // Cancel target position
                    cancel_position<B, Q, E>(host, side, target_id, book_cap);
                };
                // Refresh the max bid/min ask ID for the order book
                refresh_extreme_order_id<B, Q, E>(host, side, book_cap);
                break // Break out of iterated traversal loop
            };
        };
        size // Return unfilled size on market order
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}