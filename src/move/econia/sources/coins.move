/// Mock coin types for on- and off-chain testing
module econia::coins {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use std::signer::address_of;
    use std::string::utf8;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Container for mock coin type capabilities
    struct CoinCapabilities has key {
        base_mint_cap: coin::MintCapability<BC>,
        base_burn_cap: coin::BurnCapability<BC>,
        quote_mint_cap: coin::MintCapability<QC>,
        quote_burn_cap: coin::BurnCapability<QC>,
    }

    /// Base coin type
    struct BC{}

    /// Quote coin type
    struct QC{}

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When caller is not Econia
    const E_NOT_ECONIA: u64 = 0;
    /// When coin capabilities have already been initialized
    const E_HAS_CAPABILITIES: u64 = 1;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Base coin name
    const BASE_COIN_NAME: vector<u8> = b"Base coin";
    /// Base coin symbol
    const BASE_COIN_SYMBOL: vector<u8> = b"BC";
    /// Base coin decimals
    const BASE_COIN_DECIMALS: u64 = 4;
    /// Quote coin name
    const QUOTE_COIN_NAME: vector<u8> = b"Quote coin";
    /// Quote coin symbol
    const QUOTE_COIN_SYMBOL: vector<u8> = b"QC";
    /// Quote coin decimals
    const QUOTE_COIN_DECIMALS: u64 = 12;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize mock base and quote coin types under Econia account
    public entry fun init_coin_types(
        account: &signer
    ) {
        // Assert caller is Econia
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Assert Econia does not already have coin capabilities stored
        assert!(!exists<CoinCapabilities>(@econia), E_HAS_CAPABILITIES);
        // Initialize base coin, storing capabilities
        let (base_mint_cap, base_burn_cap) = coin::initialize<BC>(
            account, utf8(BASE_COIN_NAME), utf8(BASE_COIN_SYMBOL),
            BASE_COIN_DECIMALS, false);
        // Initialize quote coin, storing capabilities
        let (quote_mint_cap, quote_burn_cap) = coin::initialize<QC>(
            account, utf8(QUOTE_COIN_NAME), utf8(QUOTE_COIN_SYMBOL),
            QUOTE_COIN_DECIMALS, false);
        // Store capabilities under Econia account
        move_to<CoinCapabilities>(account, CoinCapabilities{
            base_mint_cap, base_burn_cap, quote_mint_cap, quote_burn_cap});
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for capabilities already registered
    fun test_init_has_caps(
        econia: &signer
    ) {
        init_coin_types(econia); // Initialize coin types
        init_coin_types(econia); // Attempt invalid re-init
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for unauthorized caller
    fun test_init_not_econia(
        account: &signer
    ) {
        init_coin_types(account); // Attempt invalid init
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}