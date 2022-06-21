/// Mock version number functionality for simulating Aptos database
/// version number. Calls to `get_v_n()` can be easily replaced with a
/// Move native function for getting the true database version number
/// (once it is implemented).
module Econia::Version {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend Econia::User;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Mock version number counter
    struct MC has key {
        i: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 0;
    /// When mock version number counter already exists
    const E_MC_EXISTS: u64 = 1;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public script functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize mock version number counter under Econia account,
    /// aborting if called by another signer or if counter exists
    public(script) fun init_mock_version_number(
        account: &signer
    ) {
        let addr = s_a_o(account); // Get account address
        assert!(addr == @Econia, E_NOT_ECONIA); // Assert Econia called
        // Assert mock version number counter doesn't exist already
        assert!(!exists<MC>(addr), E_MC_EXISTS);
        move_to<MC>(account, MC{i: 0}); // Move mock counter to Econia
    }

    // Public script functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Wrapped get-update function for mock version number counter,
    /// calls to which can be easily replaced once a true version number
    /// getter is implemented as a Move native function
    public(friend) fun get_v_n():
    u64
    acquires MC {
        get_updated_mock_version_number()
    }


    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Increment mock version number counter by one and return result.
    /// To reduce overhead, assume `MC` has already been initialized
    fun get_updated_mock_version_number():
    u64
    acquires MC {
        // Borrow mutable reference to mock version number counter value
        let v_n = &mut borrow_global_mut<MC>(@Econia).i;
        *v_n = *v_n + 1; // Increment by 1
        *v_n // Return new value
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test(econia = @Econia)]
    /// Verify successful return sequence
    public(script) fun get_v_n_success(
        econia: &signer
    ) acquires MC {
        init_mock_version_number(econia); // Initialize
        assert!(get_v_n() == 1, 0); // Get mock version number
        assert!(get_v_n() == 2, 1); // Get mock version number
        assert!(get_v_n() == 3, 2); // Get mock version number
    }

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-Econia caller
    public(script) fun init_mock_failure_not_econia(
        account: &signer
    ) {
        init_mock_version_number(account); // Attempt invalid init
    }

    #[test(econia = @Econia)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempted re-initialization
    public(script) fun init_mock_failure_exists(
        econia: &signer
    ) {
        init_mock_version_number(econia); // Initialize
        init_mock_version_number(econia); // Attempt invalid re-init
    }

    #[test(econia = @Econia)]
    /// Verify successful initialization of mock counter
    public(script) fun init_mock_success(
        econia: &signer
    ) acquires MC {
        init_mock_version_number(econia); // Initialize
        // Assert correct initialization
        assert!(borrow_global<MC>(s_a_o(econia)).i == 0, 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}