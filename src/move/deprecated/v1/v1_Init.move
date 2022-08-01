/// Initialization functionality for Econia core account resources,
/// which must be invoked before trades can be placed.
module Econia::Init {

    use Econia::Caps::init_caps;
    use Econia::Registry::init_registry;
    use Econia::Version::init_mock_version_number;
    use std::signer::address_of as s_a_o;

    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 0;

    #[cmd]
    /// Initialize Econia core account resources, aborting if called by
    /// non-Econia account
    public entry fun init_econia(
        account: &signer
    ) {
        // Verify called by Econia account
        assert!(s_a_o(account) == @Econia, E_NOT_ECONIA);
        init_caps(account); // Init friend-like capabilities
        init_registry(account); // Init market registry
        init_mock_version_number(account); // Init mock version number
    }

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-Econia caller
    public entry fun init_econia_failure_not_econia(
        account: &signer
    ) {
        init_econia(account); // Attempt invalid invocation
    }

    #[test(account = @Econia)]
    /// Verify run-to-completion invocation of sub-initializers
    public entry fun init_econia_success(
        account: &signer
    ) {
        init_econia(account); // Invoke initializer
    }

}