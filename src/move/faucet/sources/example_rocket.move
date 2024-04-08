module econia_faucet::example_rocket {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct ExampleRocket {}

    const NAME: vector<u8> = x"F09F9A80";
    const SYMBOL: vector<u8> = x"F09F9A80";
    const DECIMALS: u8 = 8;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<ExampleRocket>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}
