module econia_faucet::test_apt {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct TestAPT {}

    const NAME: vector<u8> = b"Test Aptos";
    const SYMBOL: vector<u8> = b"tAPT";
    const DECIMALS: u8 = 8;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<TestAPT>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}