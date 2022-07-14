/// # Test-oriented architecture
///
/// Some modules, like `Econia::Registry`, rely heavily on Move native
/// functions defined in the `AptosFramework`, for which the `move`
/// CLI's coverage testing tool does not offer general support (at
/// least as of the time of this writing). Thus, since the `aptos` CLI
/// does not offer any coverage testing support whatsoever (again, at
/// least as of the time of this writing), such modules cannot be
/// coverage tested per straightforward methods. Other modules, however,
/// do not depend as strongly on `AptosFramework` functions, and as
/// such, whenever possible, they are implemented purely in Move to
/// enable coverage testing, for example, like `Econia::CritBit`.
///
/// The pairing of pure-Move and non-pure-Move modules occasionally
/// requires workarounds, for instance, like the pseudo-friend
/// capability `Econia::Book::FriendCap`, a cumbersome alternative to
/// the use of a `public(friend)` function: a more straightforward
/// approach would involve only exposing `Econia::Book::init_book`, for
/// example, to friend modules, but this would involve the declaration
/// of `Econia::Registry` module as a friend, and since
/// `Econia::Registry` relies on `AptosFramework` native functions, the
/// `move` CLI test compiler would thus break when attempting to link
/// the corresponding files, even when only attempting to run coverage
/// tests on `Econia::Book`. Hence, the use of `Econia::Book:FriendCap`,
/// a friend-like capability, which allows `Econia::Book` to be
/// implemented purely in Move and to be coverage tested using the
/// `move` CLI, while also restricting access to friend-like modules.
///
/// # Capability aggregation
///
/// Rather than having friend-like capabilities managed by individual
/// modules, they are aggregated here for ease of use, and are
/// initialized all at once per `init_caps()`. As a `public(friend)`
/// function, this is only intended to be called by
/// `Econia::Init::init_econia()`, which essentially configures
/// the Econia account to facilitate trading.
///
/// Similarly, capability access functions like `book_f_c()` are also
/// provided as `public(friend)` functions, to be accessed only by
/// select modules, namely those which contain Aptos native functions
/// and which depend on pure-Move modules offering
/// friend-like capabilities: `Econia::Registry`, for instance, is
/// listed as a friend, since it requires access to
/// `Econia::Book::FriendCap`.
///
/// ---
///
module Econia::Caps {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use Econia::Book::{
        FriendCap as BFC,
        get_friend_cap as b_g_f_c
    };

    use Econia::Orders::{
        FriendCap as OFC,
        get_friend_cap as o_g_f_c
    };

    use Std::Signer::{
        address_of as s_a_o
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use Econia::Book::{
        init_book as b_i_b,
        BT,
        ET,
        QT
    };

    #[test_only]
    use Econia::Orders::{
        init_orders as o_i_o,
    };
    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend Econia::Init;
    friend Econia::Registry;
    friend Econia::User;
    friend Econia::Match;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Container for friend-like capabilities
    struct FC has key {
        /// `Econia::Book` capability
        b: BFC,
        /// `Econia::Orders` capability
        o: OFC
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When account/address is not Econia
    const E_NOT_ECONIA: u64 = 0;
    /// When friend-like capabilities container already exists
    const E_FC_EXISTS: u64 = 1;
    /// When no friend-like capabilities container
    const E_NO_FC: u64 = 2;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return `Econia::Book` friend-like capability
    public(friend) fun book_f_c():
    BFC
    acquires FC {
        assert!(has_f_c(), E_NO_FC); // Assert capabilities initialized
        borrow_global<FC>(@Econia).b // Return requested capability
    }

    /// Return true if friend capability container initialized
    public(friend) fun has_f_c(): bool {exists<FC>(@Econia)}

    /// Initialize friend-like capabilities, storing under Econia
    /// account, aborting if called by another account or if capability
    /// container already exists
    public(friend) fun init_caps(
        account: &signer
    ) {
        let addr = s_a_o(account); // Get signer address
        assert!(addr == @Econia, E_NOT_ECONIA); // Assert Econia signer
        // Assert friend-like capabilities container does not yet exist
        assert!(!exists<FC>(addr), E_FC_EXISTS);
        // Move friend-like capabilities container to Econia account
        move_to<FC>(account, FC{b: b_g_f_c(account), o: o_g_f_c(account)});
    }

    /// Return `Econia::Orders` friend-like capability
    public(friend) fun orders_f_c():
    OFC
    acquires FC {
        assert!(has_f_c(), E_NO_FC); // Assert capabilities initialized
        borrow_global<FC>(@Econia).o // Return requested capability
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Assert failure for uninitialized capabilities
    fun book_f_c_failure() acquires FC {book_f_c();}

    #[test(econia = @Econia)]
    /// Verify successful returns pre- and post-initialization
    fun has_f_c_success(
        econia: &signer
    ) {
        // Assert capability container not indicated
        assert!(!has_f_c(), 0);
        init_caps(econia); // Initialize capability container
        assert!(has_f_c(), 1); // Assert capability container indicated
    }

    #[test(econia = @Econia)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure when capability container already exists
    fun init_caps_failure_exists(
        econia: &signer
    ) {
        init_caps(econia); // Initialize
        init_caps(econia); // Attempt invalid re-initialization
    }

    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure when not called by Econia
    fun init_caps_failure_not_econia(
        account: &signer
    ) {
        init_caps(account); // Attempt invalid initialization
    }

    #[test(econia = @Econia)]
    /// Verify successful initialization of capabilities
    fun init_caps_success(
        econia: &signer
    ) acquires FC {
        init_caps(econia); // Initialize capabilities
        // Invoke function requiring book capability
        b_i_b<BT, QT, ET>(econia, 0, &book_f_c());
        // Invoke function requiring orders capability
        o_i_o<BT, QT, ET>(econia, 0, &orders_f_c());
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    /// Assert failure for uninitialized capabilities
    fun orders_f_c_failure() acquires FC {orders_f_c();}

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}