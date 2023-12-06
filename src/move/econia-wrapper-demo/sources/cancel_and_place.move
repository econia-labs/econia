module wrapper_publisher::cancel_and_place {

    use econia::market;
    use std::vector;

    /// Ask size and price vectors are not same length.
    const E_ASK_SIZE_PRICE_MISMATCH: u64 = 0;
    /// Bid size and price vectors are not same length.
    const E_BID_SIZE_PRICE_MISMATCH: u64 = 1;

    public entry fun cancel_and_place<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        ask_order_ids_to_cancel: vector<u128>,
        bid_order_ids_to_cancel: vector<u128>,
        ask_sizes_to_place: vector<u64>,
        ask_prices_to_place: vector<u64>,
        bid_sizes_to_place: vector<u64>,
        bid_prices_to_place: vector<u64>,
        integrator: address,
        restriction: u8,
        self_match_behavior: u8
    ) {
        let n_ask_sizes = vector::length(&ask_sizes_to_place);
        let n_ask_prices = vector::length(&ask_prices_to_place);
        let n_bid_sizes = vector::length(&bid_sizes_to_place);
        let n_bid_prices = vector::length(&bid_prices_to_place);
        assert!(n_ask_sizes == n_ask_prices, E_ASK_SIZE_PRICE_MISMATCH);
        assert!(n_bid_sizes == n_bid_prices, E_BID_SIZE_PRICE_MISMATCH);
        let ask_flag = market::get_ASK();
        let bid_flag = market::get_BID();
        vector::for_each_ref(&ask_order_ids_to_cancel, |order_id_ref| {
            market::cancel_order_user(user, market_id, ask_flag, *order_id_ref)
        });
        vector::for_each_ref(&bid_order_ids_to_cancel, |order_id_ref| {
            market::cancel_order_user(user, market_id, bid_flag, *order_id_ref)
        });
        let i = 0;
        while (i < n_ask_sizes) {
            market::place_limit_order_user<BaseType, QuoteType>(
                user,
                market_id,
                integrator,
                ask_flag,
                *vector::borrow(&ask_sizes_to_place, i),
                *vector::borrow(&ask_prices_to_place, i),
                restriction,
                self_match_behavior
            );
            i = i + 1;
        };
        i = 0;
        while (i < n_bid_sizes) {
            market::place_limit_order_user<BaseType, QuoteType>(
                user,
                market_id,
                integrator,
                bid_flag,
                *vector::borrow(&bid_sizes_to_place, i),
                *vector::borrow(&bid_prices_to_place, i),
                restriction,
                self_match_behavior
            );
            i = i + 1;
        };
    }

}