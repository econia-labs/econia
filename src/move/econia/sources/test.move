/// Sample function calls for on-chain testing.
module econia::test {

    use econia::assets::{Self, BC, QC};
    use econia::market;
    use econia::registry;
    use econia::user;

    const ASK: bool = true;
    const ASK_PRICE: u64 = 10;
    const ASK_SIZE: u64 = 100;
    const CUSTODIAN_ID: u64 = 0;
    const LOT_SIZE: u64 = 10;
    const MARKET_ID: u64 = 0;
    const MINT_AMOUNT: u64 = 1000000000;
    const TICK_SIZE: u64 = 25;

    /// Set up the registry, init coin types, register a market,
    /// register a market account, deposit coins, and place a trade.
    fun init_module(
        econia: &signer
    ) {

        registry::init_registry(econia); // Initialize registry.
        assets::init_coin_types(econia); // Initialize coin types.
        // Register a pure coin market.
        market::register_market_pure_coin<BC, QC>(econia, LOT_SIZE, TICK_SIZE);
        // Register a user to trade on the market.
        user::register_market_account<BC, QC>(econia, MARKET_ID, CUSTODIAN_ID);
        // Deposit quote coins to user's market account.
        user::deposit_coins<QC>(@econia, MARKET_ID, CUSTODIAN_ID,
            assets::mint(econia, MINT_AMOUNT));
        // Deposit base coins to user's market account.
        user::deposit_coins<BC>(@econia, MARKET_ID, CUSTODIAN_ID,
            assets::mint(econia, MINT_AMOUNT));
        // Place an ask.
        market::place_limit_order_user<BC, QC>(econia, @econia, MARKET_ID,
            ASK, ASK_SIZE, ASK_PRICE, false, false, false);
    }

    #[test(econia = @econia)]
    /// Verify function runs to completion without error.
    fun test_init_module(econia: &signer) {init_module(econia);}

}