module econia_faucet::test_usdc {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct TestUSDC {}

    const NAME: vector<u8> = b"Test USD coin";
    const SYMBOL: vector<u8> = b"tUSDC";
    const DECIMALS: u8 = 6;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<TestUSDC>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}