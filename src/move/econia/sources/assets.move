/// Mock asset types for on- and off-chain testing.
module econia::assets {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::coin;
    use std::signer::address_of;
    use std::string::utf8;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Container for mock coin type capabilities
    struct CoinCapabilities<phantom CoinType> has key {
        mint_capability: coin::MintCapability<CoinType>,
        burn_capability: coin::BurnCapability<CoinType>,
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
    /// When coin capabilities have not been initialized
    const E_NO_CAPABILITIES: u64 = 2;

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

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    /// Burn `coins`
    ///
    /// # Assumes
    /// * That since `coins` exist in the first place, that
    ///   `CoinCapabilities` must exist in the Econia account
    public fun burn<CoinType>(
        coins: coin::Coin<CoinType>
    ) acquires CoinCapabilities {
        // Borrow immutable reference to burn capability
        let burn_capability = &borrow_global<CoinCapabilities<CoinType>>(
                @econia).burn_capability;
        coin::burn<CoinType>(coins, burn_capability); // Burn coins
    }

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Initialize mock base and quote coin types under Econia account
    public entry fun init_coin_types(
        account: &signer
    ) {
        init_coin_type<BC>(account, BASE_COIN_NAME, BASE_COIN_SYMBOL,
            BASE_COIN_DECIMALS); // Initialize mock base coin
        init_coin_type<QC>(account, QUOTE_COIN_NAME, QUOTE_COIN_SYMBOL,
            QUOTE_COIN_DECIMALS); // Initialize mock quote coin
    }

    #[cmd]
    /// Mint new `amount` of `CoinType`, aborting if not called by
    /// Econia account or if `CoinCapabilities` uninitialized
    public entry fun mint<CoinType>(
        account: &signer,
        amount: u64
    ): coin::Coin<CoinType>
    acquires CoinCapabilities {
        // Get account address
        let account_address = address_of(account);
        // Assert caller is Econia
        assert!(account_address == @econia, E_NOT_ECONIA);
        assert!(exists<CoinCapabilities<CoinType>>(account_address),
            E_NO_CAPABILITIES); // Assert coin capabilities initialized
        // Borrow immutable reference to mint capability
        let mint_capability = &borrow_global<CoinCapabilities<CoinType>>(
                account_address).mint_capability;
        // Mint specified amount
        coin::mint<CoinType>(amount, mint_capability)
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize given coin type under Econia account
    fun init_coin_type<CoinType>(
        account: &signer,
        coin_name: vector<u8>,
        coin_symbol: vector<u8>,
        decimals: u64,
    ) {
        // Assert caller is Econia
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Assert Econia does not already have coin capabilities stored
        assert!(!exists<CoinCapabilities<CoinType>>(@econia),
            E_HAS_CAPABILITIES);
        // Initialize coin, storing capabilities
        let (mint_capability, burn_capability) = coin::initialize<CoinType>(
            account, utf8(coin_name), utf8(coin_symbol), decimals, false);
        // Store capabilities under Econia account
        move_to<CoinCapabilities<CoinType>>(account,
            CoinCapabilities<CoinType>{mint_capability, burn_capability});
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base agnostic asset type
    struct BA{}

    #[test_only]
    /// Mock agnostic asset type
    struct MA{}

    #[test_only]
    /// Mock coin type
    struct MC{}

    #[test_only]
    /// Quote agnostic asset type
    struct QA{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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

    #[test(account = @econia)]
    /// Verify successful mint, then burn
    fun test_mint_and_burn(
        account: &signer
    ) acquires CoinCapabilities {
        init_coin_types(account); // Initialize both coin types
        let base_coin = mint<BC>(account, 20); // Mint base coin
        // Assert correct value minted
        assert!(coin::value(&base_coin) == 20, 0);
        burn<BC>(base_coin); // Burn coins
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for unauthorized caller
    fun test_mint_not_econia(
        account: &signer
    ): coin::Coin<BC>
    acquires CoinCapabilities {
        mint<BC>(account, 20) // Attempt invalid mint
    }

    #[test(account = @econia)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for uninitialized capabilities
    fun test_mint_no_capabilities(
        account: &signer
    ): coin::Coin<BC>
    acquires CoinCapabilities {
        mint<BC>(account, 20) // Attempt invalid mint
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}