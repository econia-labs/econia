// AptCoin and UsdCoin mint/transfer implementations

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
    struct AptCoin {}
    struct UsdCoin {}

    // Generic coin type
    struct Coin<phantom CoinType> has store {
        subunits: u64 // Indivisible subunits (e.g. Satoshi for BTC)
    }

    // Scale for converting subunits to decimal (base-10 exponent)
    // With a scale of 3, for example, 1 subunit = 0.001 base unit
    const E_APT_COIN_SCALE: u8 = 6;
    const E_USD_COIN_SCALE: u8 = 6;

    // Total holdings for a given user
    struct UltimaHoldings has key {
        apt: Coin<AptCoin>,
        usd: Coin<UsdCoin>
    }

    // Publish an empty UltimaHoldings resource under an account address
    // Must be called before minting/transferring to the account
    public fun publish_ultima_holdings(
        account_ref: &signer // Account to publish under
    ) {
        let empty_apt = Coin<AptCoin>{subunits: 0};
        let empty_usd = Coin<UsdCoin>{subunits: 0};
        assert!(
            !exists<UltimaHoldings>(Signer::address_of(account_ref)),
            E_ALREADY_HAS_HOLDINGS
        );
        move_to(
            account_ref,
            UltimaHoldings{apt: empty_apt, usd: empty_usd}
        );
    }

    // Return total holdings under an account address
    public fun balance_of(
        owner: address // Account to check holdings of
    ) : (
        u64, // AptCoin subunits
        u64 // UsdCoin subunits
    ) acquires UltimaHoldings {
        let apt_subunits = borrow_global<UltimaHoldings>(owner).apt.subunits;
        let usd_subunits = borrow_global<UltimaHoldings>(owner).usd.subunits;
        (apt_subunits, usd_subunits)
    }

    // Deposit AptCoin and UsdCoin to given address
    // Does not account for u64 overflow errors
    fun deposit(
        addr: address, // Address to deposit to
        apt_coin: Coin<AptCoin>, // AptCoin to deposit
        usd_coin: Coin<UsdCoin> // UsdCoin to desposit
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

    // Mint AptCoin and UsdCoin amount to the Ultima module address
    // Can only be invoked by the Ultima module address
    public(script) fun mint(
        ultima_signer: signer, // The Ultima account
        apt_subunits: u64, // Amount AptCoin subunits to mint
        usd_subunits: u64 // Amount of UsdCoin subunits to mint
    ) acquires UltimaHoldings {
        assert!(
            Signer::address_of(&ultima_signer) == @Ultima,
            E_NOT_ULTIMA_SIGNER
        );
        deposit(
            Signer::address_of(&ultima_signer),
            Coin<AptCoin>{subunits: apt_subunits},
            Coin<UsdCoin>{subunits: usd_subunits}
        );
    }

    // Withdraw AptCoin and UsdCoin from given address
    fun withdraw(
        addr: address, // Address to withdraw from
        apt_subunits: u64, // AptCoin subunits to withdraw
        usd_subunits: u64 // UsdCoin subunits to withdraw
    ) : (
        Coin<AptCoin>, // AptCoin with specified subunits
        Coin<UsdCoin> // UsdCoin with specified subunits
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
            Coin<AptCoin>{subunits: apt_subunits},
            Coin<UsdCoin>{subunits: usd_subunits}
        )
    }

    // Transfer AptCoin and UsdCoin between addresses
    public fun transfer(
        from: &signer, // Sender of coins
        to: address, // Recipient of coins
        apt_subunits: u64, // AptCoin subunits to transfer (can be 0)
        usd_subunits: u64, // UsdCoin subunits to transfer (can be 0)
    ) acquires UltimaHoldings {
        let from_addr = Signer::address_of(from);
        // Assert sender and recipient are not same account
        assert!(from_addr != to, E_SAME_ADDRESS);
        let (apt_coin, usd_coin) =
            withdraw(from_addr, apt_subunits, usd_subunits);
        deposit(to, apt_coin, usd_coin);
    }

    // Verify arbitrary user can properly initialize UltimaHoldings
    #[test(account = @TestUser1)]
    fun publish_balance_has_zero(
        account: signer // Account to publish holdings resource to
    ) acquires UltimaHoldings {
        let addr = Signer::address_of(&account);
        publish_ultima_holdings(&account);
        let(apt_subunits, usd_subunits) = balance_of(addr);
        // Assert balance initialized to 0
        assert!(apt_subunits == 0, E_BALANCE_NOT_INIT_EMPTY);
        assert!(usd_subunits == 0, E_BALANCE_NOT_INIT_EMPTY);
    }

    // Verify error asserted when UltimaHoldings published twice
    #[test(account = @TestUser1)]
    #[expected_failure(abort_code = 0)]
    fun publish_holdings_twice_error(
        account: signer // Account trying to publish holdings resource
    ) {
        publish_ultima_holdings(&account);
        publish_ultima_holdings(&account);
    }

    // Verify Ultima address can mint AptCoin and UsdCoin to itself
    #[test(ultima_signer = @Ultima)]
    public(script) fun mint_ultima(
        ultima_signer: signer // The Ultima account
    ) acquires UltimaHoldings {
        let ultima_addr = Signer::address_of(&ultima_signer);
        publish_ultima_holdings(&ultima_signer);
        mint(ultima_signer, 123, 456);
        let(apt_subunits, usd_subunits) = balance_of(ultima_addr);
        // Assert correct balance minted
        assert!(apt_subunits == 123, E_WRONG_MINT_BALANCE);
        assert!(usd_subunits == 456, E_WRONG_MINT_BALANCE);
    }

    // Verify unauthorized user cannot mint coins
    #[test(not_ultima = @TestUser1)]
    #[expected_failure(abort_code = 2)]
    public(script) fun unauthorized_minter(
        not_ultima: signer // Signer that is not Ultima address
    ) acquires UltimaHoldings {
        mint(not_ultima, 0, 0);
    }

    // Verify Ultima address can mint and transfer to arbitrary user
    #[test(
        not_ultima = @TestUser1, // Address that is not Ultima address
        ultima_mint = @Ultima, // Ultima signer for mint tx
        ultima_transfer = @Ultima // Ultima signer for transfer tx
    )]
    public(script) fun mint_and_transfer(
        not_ultima: signer,
        ultima_mint: signer,
        ultima_transfer: signer
    ) acquires UltimaHoldings {
        // Initialize both addresses to empty holdings
        publish_ultima_holdings(&not_ultima);
        publish_ultima_holdings(&ultima_mint);

        // Mint to Ultima address and transfer over
        let not_addr = Signer::address_of(&not_ultima);
        let ult_addr = Signer::address_of(&ultima_mint);
        mint(ultima_mint, 250, 1275);
        transfer(&ultima_transfer, not_addr, 100, 1000);
        let (not_apt, not_usd) = balance_of(not_addr);
        let (ult_apt, ult_usd) = balance_of(ult_addr);

        // Verify amounts
        assert!(not_apt == 100, E_WRONG_TRANSFER_AMOUNT);
        assert!(not_usd == 1000, E_WRONG_TRANSFER_AMOUNT);
        assert!(ult_apt == 150, E_WRONG_TRANSFER_AMOUNT);
        assert!(ult_usd == 275, E_WRONG_TRANSFER_AMOUNT);
    }
}
