module econia_faucet::example_usdc {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct ExampleUSDC {}

    const NAME: vector<u8> = b"Example USD coin";
    const SYMBOL: vector<u8> = b"eUSDC";
    const DECIMALS: u8 = 6;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<ExampleUSDC>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}