module econia_scripts::scripts {
    use econia::market;
    use econia::user;
    use std::signer::{address_of};
    use std::vector;

    const BUY: bool = true;
    const NO_CUSTODIAN: u64 = 0;

    #[cmd]
    /// Convenience script for `market::place_limit_order_user()`.
    ///
    /// This script will create a user MarketAccount if it does not already
    /// exist and will withdraw from the user's CoinStore to ensure there is
    /// sufficient balance to place the Order.
    public entry fun place_limit_order_user_entry<
        BaseType,
        QuoteType
    >(
        user: &signer,
        market_id: u64,
        integrator: address,
        side: bool,
        size: u64,
        price: u64,
        restriction: u8,
    ) {
        // Create MarketAccount if not exists
        if (!has_user_market_account(address_of(user), market_id)) {
            user::register_market_account<BaseType, QuoteType>(
                user,
                market_id,
                NO_CUSTODIAN
            );
        };

        // Fund the `MarketAccount` with the required balance
        // WIP
        // let (_, lot_size, tick_size, _, _) = registry::get_market_info(market_id)
        let lot_size = 1;
        let tick_size = 1;
        if (side == BUY) {
            user::deposit_from_coinstore<QuoteType>(
                user,
                market_id,
                NO_CUSTODIAN,
                size * price * tick_size
            );
        } else {
            user::deposit_from_coinstore<BaseType>(
                user,
                market_id,
                NO_CUSTODIAN,
                size * lot_size
            );
        };

        // Place the order
        market::place_limit_order_user_entry<BaseType, QuoteType>(
            user,
            market_id,
            integrator,
            side,
            size,
            price,
            restriction
        );
    }

    public fun has_user_market_account(
        user_addr: address,
        market_id: u64
    ): bool {
        let market_accounts =
            user::get_all_market_account_ids_for_market_id(user_addr, market_id);
        let (i, n_custodians) = (0, vector::length(&market_accounts));
        while (i < n_custodians) {
            let custodian_id = (*vector::borrow(&market_accounts, i) as u64); // Least 64 bits are custodian_id
            if (custodian_id == NO_CUSTODIAN) {
                return true
            };
            i = i + 1;
        };
        return false
    }
}