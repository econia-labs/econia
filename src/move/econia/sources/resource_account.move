/// Manages an Econia-owned resource account.
module econia::resource_account {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::account::{Self, SignerCapability};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::incentives;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Stores a signing capability for the Econia resource account.
    struct SignerCapabilityStore has key {
        /// Signer capability for Econia resource account.
        signer_capability: SignerCapability
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return resource account address.
    public(friend) fun get_address():
    address
    acquires SignerCapabilityStore {
        // Borrow immutable reference to signer capability.
        let signer_capability_ref = &borrow_global<SignerCapabilityStore>(
            @econia).signer_capability;
        // Return its address.
        account::get_signer_capability_address(signer_capability_ref)
    }

    /// Return resource account signer.
    public(friend) fun get_signer():
    signer
    acquires SignerCapabilityStore {
        // Borrow immutable reference to signer capability.
        let signer_capability_ref = &borrow_global<SignerCapabilityStore>(
            @econia).signer_capability;
        // Return associated signer.
        account::create_signer_with_capability(signer_capability_ref)
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize the Econia resource account upon module publication.
    ///
    /// # Seed considerations
    /// * Resource account creation seed supplied as an empty vector,
    ///   pending the acceptance of `aptos-core` PR #4173. If PR is not
    ///   accepted by version release, will be updated with similar
    ///   functionality.
    fun init_module(
        econia: &signer
    ) {
        // Create resource account, storing signer capability.
        let (_, signer_capability) =
            account::create_resource_account(econia, b"");
        // Store signing capability under Econia account.
        move_to(econia, SignerCapabilityStore{signer_capability});
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    struct TestStruct has key {}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Initialize resource account for testing.
    public fun init_test() {
        // Get signer for Econia account.
        let econia = account::create_signer_with_capability(
            &account::create_test_signer_cap(@econia));
        init_module(&econia); // Init resource account.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify initialization, signer use, address lookup.
    fun test_mixed()
    acquires SignerCapabilityStore {
        init_test(); // Init the resource account.
        // Move to resource account a test struct.
        move_to<TestStruct>(&get_signer(), TestStruct{});
        // Verify existence via address lookup.
        assert!(exists<TestStruct>(get_address()), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}