/// User-side book keeping and, optionally, collateral management.
///
/// # Market account custodians
///
/// For any given market, designated by a unique market ID, a user can
/// register multiple `MarketAccount`s, distinguished from one another
/// by their corresponding "general custodian ID". The custodian
/// capability having this ID is required to approve all market
/// transactions within the market account with the exception of generic
/// asset transfers, which are approved by a market-wide "generic
/// asset transfer custodian" in the case of a market having at least
/// one non-coin asset. When a general custodian ID is marked
/// `NO_CUSTODIAN`, a signing user is required to approve general
/// transactions rather than a custodian capability.
///
/// For example: market 5 has a generic (non-coin) base asset, a coin
/// quote asset, and generic asset transfer custodian ID 6. A user
/// opens two market accounts for market 5, one having general
/// custodian ID 7, and one having general custodian ID `NO_CUSTODIAN`.
/// When a user wishes to deposit base assets to the first market
/// account, custodian 6 is required for authorization. Then when the
/// user wishes to submit an ask, custodian 7 must approve it. As for
/// the second account, a user can deposit and withdraw quote coins,
/// and place or cancel trades via a signature, but custodian 6 is
/// still required to verify base deposits and withdrawals.
///
/// In other words, the market-wide generic asset transfer custodian ID
/// overrides the user-specific general custodian ID only when
/// depositing or withdrawing generic assets, otherwise the
/// user-specific general custodian ID takes precedence. Notably, a user
/// can register a `MarketAccount` having the same general custodian ID
/// and generic asset transfer custodian ID, and here, no overriding
/// takes place. For example, if market 8 requires generic asset
/// transfer custodian ID 9, a user can still register a market account
/// having general custodian ID 9, and then custodian 9 will be required
/// to authorize all of a user's transactions for the given
/// `MarketAccount`
///
/// # Market account ID
///
/// Since any of a user's `MarketAccount`s are specified by a
/// unique combination of market ID and general custodian ID, a user's
/// market account ID is thus defined as a 128-bit number, where the
/// most-significant ("first") 64 bits correspond to the market ID, and
/// the least-significant ("last") 64 bits correspond to the general
/// custodian ID.
///
/// For a market ID of `255` (`0b11111111`) and a general custodian ID
/// of `170` (`0b10101010`), for example, the corresponding market
/// account ID has the first 64 bits
/// `0000000000000000000000000000000000000000000000000000000011111111`
/// and the last 64 bits
/// `0000000000000000000000000000000000000000000000000000000010101010`,
/// corresponding to the base-10 integer `4703919738795935662250`. Note
/// that when a user opts to sign general transactions rather than
/// delegate to a general custodian, the market account ID uses a
/// general custodian ID of `NO_CUSTODIAN`, corresponding to `0`.
module econia::user {

    // Dependency planning stubs
    public(friend) fun return_0(): u8 {0}

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::critbit::{u, u_long};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Positions to bitshift for operating on first 64 bits
    const FIRST_64: u8 = 64;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return market account ID for given `market_id` and
    /// `general_custodian_id`
    public fun get_market_account_id(
        market_id: u64,
        general_custodian_id: u64
    ): u128 {
        (market_id as u128) << FIRST_64 | (general_custodian_id as u128)
    }

    /// Get market ID encoded in `market_account_id`
    public fun get_market_id(
        market_account_id: u128
    ): u64 {
        (market_account_id >> FIRST_64 as u64)
    }

    /// Get general custodian ID encoded in `market_account_id`
    public fun get_general_custodian_id(
        market_account_id: u128
    ): u64 {
        (market_account_id & (HI_64 as u128) as u64)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify expected return
    fun test_get_general_custodian_id() {
        // Define market_account id (60 characters on first two lines,
        // 8 on last)
        let market_account_id = u_long(
            b"111111111111111111111111111111111111111111111111111111111111",
            b"111100000000000000000000000000000000000000000000000000000000",
            b"10101010"
        );
        // Assert expected return
        assert!(get_general_custodian_id(market_account_id) ==
            (u(b"10101010") as u64), 0);
    }

    #[test]
    /// Verify expected return
    fun test_get_market_account_id() {
        // Declare market ID
        let market_id = (u(b"1101") as u64);
        // Declare general custodian ID
        let general_custodian_id = (u(b"1010") as u64);
        // Define expected return (60 characters on first two lines, 8
        // on last)
        let market_account_id = u_long(
            b"000000000000000000000000000000000000000000000000000000000000",
            b"110100000000000000000000000000000000000000000000000000000000",
            b"00001010"
        );
        // Assert expected return
        assert!(get_market_account_id(market_id, general_custodian_id) ==
            market_account_id, 0);
    }

    #[test]
    /// Verify expected return
    fun test_get_market_id() {
        // Define market_account id (60 characters on first two lines,
        // 8 on last)
        let market_account_id = u_long(
            b"000000000000000000000000000000000000000000000000000000001010",
            b"101011111111111111111111111111111111111111111111111111111111",
            b"11111111"
        );
        // Assert expected return
        assert!(get_market_id(market_account_id) ==
            (u(b"10101010") as u64), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}