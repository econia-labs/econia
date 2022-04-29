// APT and USD coin model mint/transfer implementations

module Ultima::Coins {
    use Std::Signer;

    // Error codes
    const E_ALREADY_HAS_HOLDINGS: u64 = 0;
    const E_BALANCE_NOT_INIT_EMPTY: u64 = 1;
    const E_NOT_ULTIMA_SIGNER: u64 = 2;
    const E_WRONG_MINT_BALANCE: u64 = 3;
    const E_INSUFFICIENT_BALANCE: u64 = 4;
    const E_SAME_ADDRESS: u64 = 5;
    const E_WRONG_TRANSFER_AMOUNT: u64 = 6;

    // Coin type specifiers
    struct APT {}
    struct USD {}

    // Generic coin type
    struct Coin<phantom CoinType> has store {
        subunits: u64 // Indivisible subunits (e.g. Satoshi for BTC)
    }

    // Scale for converting subunits to decimal (base-10 exponent)
    // With a scale of 3, for example, 1 subunit = 0.001 base unit
    const APT_COIN_SCALE: u8 = 6;
    const USD_COIN_SCALE: u8 = 6;

    // Total holdings for a given user
    struct UltimaHoldings has key {
        apt: Coin<APT>,
        usd: Coin<USD>
    }

    // Publish an empty UltimaHoldings resource under an account address
    // Must be called before transferring to the account
    public(script) fun publish_ultima_holdings(
        account: signer // Account to publish under
    ) {
        let empty_apt = Coin<APT>{subunits: 0};
        let empty_usd = Coin<USD>{subunits: 0};
        assert!(
            !exists<UltimaHoldings>(Signer::address_of(&account)),
            E_ALREADY_HAS_HOLDINGS
        );
        move_to(&account, UltimaHoldings{apt: empty_apt, usd: empty_usd});
    }

    // Return total holdings under an account address
    public fun balance_of(
        owner: address // Account to check holdings of
    ) : (
        u64, // APT subunits
        u64 // USD subunits
    ) acquires UltimaHoldings {
        let apt_subunits = borrow_global<UltimaHoldings>(owner).apt.subunits;
        let usd_subunits = borrow_global<UltimaHoldings>(owner).usd.subunits;
        (apt_subunits, usd_subunits)
    }

    // Deposit APT and USD to given address
    // Does not account for u64 overflow errors
    fun deposit(
        addr: address, // Address to deposit to
        apt_coin: Coin<APT>, // APT to deposit
        usd_coin: Coin<USD> // USD to desposit
    ) acquires UltimaHoldings {
        let (apt_balance, usd_balance) = balance_of(addr);
        let apt_balance_ref_mut =
            &mut borrow_global_mut<UltimaHoldings>(addr).apt.subunits;
        let Coin{subunits: apt_subunits} = apt_coin;
        *apt_balance_ref_mut = apt_balance + apt_subunits;
        let usd_balance_ref_mut =
            &mut borrow_global_mut<UltimaHoldings>(addr).usd.subunits;
        let Coin{subunits: usd_subunits} = usd_coin;
        *usd_balance_ref_mut = usd_balance + usd_subunits;
    }

    // Mint APT and USD amount to the Ultima module address
    // Can only be invoked by the Ultima module address
    public(script) fun mint(
        account: signer, // Signing acount
        apt_subunits: u64, // Amount APT subunits to mint
        usd_subunits: u64 // Amount of USD subunits to mint
    ) acquires UltimaHoldings {
        let account_addr = Signer::address_of(&account);
        assert!(account_addr == @Ultima, E_NOT_ULTIMA_SIGNER);
        deposit(
            account_addr,
            Coin<APT>{subunits: apt_subunits},
            Coin<USD>{subunits: usd_subunits}
        );
    }

    // Withdraw APT and USD from given address
    fun withdraw(
        addr: address, // Address to withdraw from
        apt_subunits: u64, // APT subunits to withdraw
        usd_subunits: u64 // USD subunits to withdraw
    ) : (
        Coin<APT>, // APT with specified subunits
        Coin<USD> // USD with specified subunits
    ) acquires UltimaHoldings {
        let (apt_balance, usd_balance) = balance_of(addr);
        // Assert balance is actually available
        assert!(apt_balance >= apt_subunits, E_INSUFFICIENT_BALANCE);
        assert!(usd_balance >= usd_subunits, E_INSUFFICIENT_BALANCE);
        let apt_balance_ref_m =
            &mut borrow_global_mut<UltimaHoldings>(addr).apt.subunits;
        *apt_balance_ref_m = apt_balance - apt_subunits;
        let usd_balance_ref_m =
            &mut borrow_global_mut<UltimaHoldings>(addr).usd.subunits;
        *usd_balance_ref_m = usd_balance - usd_subunits;
        (
            Coin<APT>{subunits: apt_subunits},
            Coin<USD>{subunits: usd_subunits}
        )
    }

    // Transfer APT and USD between addresses
    public(script) fun transfer(
        from: signer, // Sender of coins
        to: address, // Recipient of coins
        apt_subunits: u64, // APT subunits to transfer (can be 0)
        usd_subunits: u64, // USD subunits to transfer (can be 0)
    ) acquires UltimaHoldings {
        let from_addr = Signer::address_of(&from);
        // Assert sender and recipient are not same account
        assert!(from_addr != to, E_SAME_ADDRESS);
        let (apt_coin, usd_coin) =
            withdraw(from_addr, apt_subunits, usd_subunits);
        deposit(to, apt_coin, usd_coin);
    }

    // Verify error for checking balance when no holdings resource
    #[test]
    #[expected_failure]
    fun balance_of_dne() acquires UltimaHoldings {
        balance_of(@TestUser1);
    }

    // Verify Ultima address can mint circulating supply
    #[test(
        user1_tx1 = @TestUser1,
        user1_tx2 = @TestUser1,
        user1_tx3 = @TestUser1,
        user2_tx1 = @TestUser2,
        user2_tx2 = @TestUser2,
        ultima_tx1 = @Ultima,
        ultima_tx2 = @Ultima,
        ultima_tx3 = @Ultima
    )]
    public(script) fun mint_and_transfer(
        user1_tx1: signer, // Non-Ultima address, signer for 1st tx
        user1_tx2: signer, // Non-Ultima address, signer for 2nd tx
        user1_tx3: signer, // Non-Ultima address, signer for 3rd tx
        user2_tx1: signer, // Another non-Ultima address, for 1st tx
        user2_tx2: signer, // Another non-Ultima address, for 2nd tx
        ultima_tx1: signer, // Ultima address, signer for 1st tx
        ultima_tx2: signer, // Ultima address, signer for 2nd tx
        ultima_tx3: signer, // Ultima address, signer for 3rd tx
    ) acquires UltimaHoldings {
        // Initialize addresses to empty holdings
        publish_ultima_holdings(user1_tx1);
        publish_ultima_holdings(user2_tx1);
        publish_ultima_holdings(ultima_tx1);

        // Get addresses
        let user1_addr = Signer::address_of(&user1_tx2);
        let user2_addr = Signer::address_of(&user2_tx2);
        let ult_addr = Signer::address_of(&ultima_tx2);

        // Mint to Ultima address and transfer to user1
        mint(ultima_tx2, 250, 1275);
        transfer(ultima_tx3, user1_addr, 100, 1000);
        let (user1_apt, user1_usd) = balance_of(user1_addr);
        let (ult_apt, ult_usd) = balance_of(ult_addr);

        // Verify amounts
        assert!(user1_apt == 100, E_WRONG_TRANSFER_AMOUNT);
        assert!(user1_usd == 1000, E_WRONG_TRANSFER_AMOUNT);
        assert!(ult_apt == 150, E_WRONG_TRANSFER_AMOUNT);
        assert!(ult_usd == 275, E_WRONG_TRANSFER_AMOUNT);

        // Transfer again from user1 to user2
        transfer(user1_tx3, user2_addr, 25, 750);
        let (user1_apt, user1_usd) = balance_of(user1_addr);
        let (user2_apt, user2_usd) = balance_of(user2_addr);

        // Verify amounts
        assert!(user1_apt == 75, E_WRONG_TRANSFER_AMOUNT);
        assert!(user1_usd == 250, E_WRONG_TRANSFER_AMOUNT);
        assert!(user2_apt == 25, E_WRONG_TRANSFER_AMOUNT);
        assert!(user2_usd == 750, E_WRONG_TRANSFER_AMOUNT);
    }

    // Verify Ultima address can mint APT and USD to itself
    #[test(
        ultima_signer_tx1 = @Ultima,
        ultima_signer_tx2 = @Ultima
    )]
    public(script) fun mint_ultima(
        ultima_signer_tx1: signer, // Ultima account signer, 1st tx
        ultima_signer_tx2: signer // Ultima account signer, 2nd tx
    ) acquires UltimaHoldings {
        publish_ultima_holdings(ultima_signer_tx1);
        let ultima_addr = Signer::address_of(&ultima_signer_tx2);
        mint(ultima_signer_tx2, 123, 456);
        let(apt_subunits, usd_subunits) = balance_of(ultima_addr);
        // Assert correct balance minted
        assert!(apt_subunits == 123, E_WRONG_MINT_BALANCE);
        assert!(usd_subunits == 456, E_WRONG_MINT_BALANCE);
    }

    // Verify arbitrary user can properly initialize UltimaHoldings
    #[test(account = @TestUser1)]
    public(script) fun publish_balance_has_zero(
        account: signer // Account to publish holdings resource to
    ) acquires UltimaHoldings {
        let addr = Signer::address_of(&account);
        publish_ultima_holdings(account);
        let(apt_subunits, usd_subunits) = balance_of(addr);
        // Assert balance initialized to 0
        assert!(apt_subunits == 0, E_BALANCE_NOT_INIT_EMPTY);
        assert!(usd_subunits == 0, E_BALANCE_NOT_INIT_EMPTY);
    }

    // Verify error asserted when UltimaHoldings published twice
    #[test(
        account_tx1 = @TestUser1,
        account_tx2 = @TestUser1,
    )]
    #[expected_failure(abort_code = 0)]
    public(script) fun publish_holdings_twice(
        account_tx1: signer, // Account to publish holdings resource
        account_tx2: signer // Account to re-publish holdings resource
    ) {
        publish_ultima_holdings(account_tx1);
        publish_ultima_holdings(account_tx2);
    }

    // Verify account cannot transfer funds to self
    #[test(
        ultima_tx1 = @Ultima,
        ultima_tx2 = @Ultima,
        ultima_tx3 = @Ultima
    )]
    #[expected_failure(abort_code = 5)]
    public(script) fun self_transfer (
        ultima_tx1: signer, // Ultima account signer, 1st tx
        ultima_tx2: signer, // Ultima account signer, 2nd tx
        ultima_tx3: signer // Ultima account signer, 3rd tx
    ) acquires UltimaHoldings {
        publish_ultima_holdings(ultima_tx1);
        mint(ultima_tx2, 123, 456);
        let ultima_tx3_addr = Signer::address_of(&ultima_tx3);
        transfer(ultima_tx3, ultima_tx3_addr, 5, 10);
    }

    // Verify unauthorized user cannot mint coins
    #[test(not_ultima = @TestUser1)]
    #[expected_failure(abort_code = 2)]
    public(script) fun unauthorized_minter(
        not_ultima: signer // Signer that is not Ultima account
    ) acquires UltimaHoldings {
        mint(not_ultima, 0, 0);
    }

    // Verify error for withdrawing when no holdings resource
    #[test]
    #[expected_failure]
    fun withdraw_dne() acquires UltimaHoldings {
        (Coin<APT>{subunits: _}, Coin<USD>{subunits: _}) =
            withdraw(@TestUser1, 0, 0);
    }

    // Verify error for trying to withdraw too much APT
    #[test(
        account_tx1 = @TestUser1,
        account_tx2 = @TestUser1,
    )]
    #[expected_failure(abort_code = 4)]
    public(script) fun withdraw_too_much_apt(
        account_tx1: signer, // Account trying to over-withdraw, 1st tx
        account_tx2: signer // Account trying to over-withdraw, 2nd tx
    ) acquires UltimaHoldings {
        publish_ultima_holdings(account_tx1);
        (Coin<APT>{subunits: _}, Coin<USD>{subunits: _}) =
            withdraw(Signer::address_of(&account_tx2), 1, 0);
    }

    // Verify error for trying to withdraw too much USD
    // Near-duplicate of withdraw_too_much_apt() to assure 100% coverage
    #[test(
        account_tx1 = @TestUser1,
        account_tx2 = @TestUser1,
    )]
    #[expected_failure(abort_code = 4)]
    public(script) fun withdraw_too_much_usd(
        account_tx1: signer, // Account trying to over-withdraw, 1st tx
        account_tx2: signer, // Account trying to over-withdraw, 2nd tx
    ) acquires UltimaHoldings {
        publish_ultima_holdings(account_tx1);
        (Coin<APT>{subunits: _}, Coin<USD>{subunits: _}) =
            withdraw(Signer::address_of(&account_tx2), 0, 1);
    }
}