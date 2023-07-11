module econia_faucet::test_eth {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct TestETH {}

    const NAME: vector<u8> = b"Test Ether";
    const SYMBOL: vector<u8> = b"tETH";
    const DECIMALS: u8 = 18;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<TestETH>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}