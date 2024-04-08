module econia_faucet::example_poop {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct ExamplePoop {}

    const NAME: vector<u8> = x"F09F92A9";
    const SYMBOL: vector<u8> = x"F09F92A9";
    const DECIMALS: u8 = 6;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<ExamplePoop>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}
