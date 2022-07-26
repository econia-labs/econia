/// Defines and administers the `EconiaCapability`, which is required
/// for assorted cross-module function calls internal to Econia.
module econia::capability {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use std::signer::address_of;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Internal capability for cross-module Econia function calls
    struct EconiaCapability has copy, drop, store {}

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When not called by Econia account
    const E_NOT_ECONIA: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an `EconiaCapability` when called by Econia account
    public fun get_econia_capability(
        account: &signer
    ): EconiaCapability {
        // Assert called by Econia account
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Return an Econia capability
        EconiaCapability{}
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return an `EconiaCapability` to any caller
    public fun get_econia_capability_test():
    EconiaCapability {
        EconiaCapability{}
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Assert failure when called by non-Econia account
    fun test_not_econia(
        account: &signer
    ) {
       get_econia_capability(account); // Attempt invalid invocation
    }

    #[test(account = @econia)]
    /// Verify capability generation
    fun test_get_cap(
        account: &signer
    ) {
       // Get and unpack a capability
       let EconiaCapability{} = get_econia_capability(account);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}