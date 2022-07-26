/// Initializers for core Econia resources
module econia::init {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use std::signer::address_of;
    use econia::registry;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    /// When caller is not Econia
    const E_NOT_ECONIA: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize Econia with core resources needed for trading
    public entry fun init_econia(
        account: &signer
    ) {
        // Assert caller is Econia account
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Init capability store for registry to make cross-module calls
        registry::init_econia_capability_store(account);
        registry::init_registry(account); // Init registry
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-Econia caller
    fun test_init_not_econia(
        account: &signer
    ) {
        init_econia(account); // Attempt invalid init
    }

    #[test(account = @econia)]
    /// Verify invocation runs to completion for Econia as caller
    fun test_init(
        account: &signer
    ) {
        init_econia(account); // Call valid init
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}