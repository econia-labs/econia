module econia_faucet::example_apt {
    use aptos_std::string;
    use econia_faucet::faucet;

    struct ExampleAPT {}

    const NAME: vector<u8> = b"Example Aptos";
    const SYMBOL: vector<u8> = b"eAPT";
    const DECIMALS: u8 = 8;
    const MONITOR_SUPPLY: bool = false;

    fun init_module(account: &signer) {
        faucet::initialize<ExampleAPT>(
            account,
            string::utf8(NAME),
            string::utf8(SYMBOL),
            DECIMALS,
            MONITOR_SUPPLY
        );
    }
}